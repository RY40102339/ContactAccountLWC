/********************************************************************************************************
* (C) Copyright 2020 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Vinod A
* @version 1.0
* @created 07/31/2020
* @description : This class will gets the data for download csv file in All Product page, All Service Request page
*				 And All Contracts page,
*				 In All Service Request page to get the data for the Button notification count and the donutChart,
*				 In All Contracts page to get the data for the Button notification count.
* @test class name - YG_ProductDetailsCSVTest
*
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  10/22/2020       	Jayaprasath				Removed Shipping_Date__c field from this class
*
*/
public class YG_ProductDetailsCSV {
    
    public static User userInformation =  YG_Utility.getLoggedInUserInfo(UserInfo.getUserId());
    //public static User userInformation =  YG_Utility.getLoggedInUserInfo('005p0000003rbfUAAQ');
    
    @AuraEnabled
    public static dataWrapper getCsvData(List<Id> prodIdList, String prodCat, String btnValue){
        
        system.debug('prodIdList::'+prodIdList);
        system.debug('prodCat::'+prodCat);
        system.debug('btnValue::'+btnValue);
               
        List<Id> emptyProdId=new List<Id>();
        List<Asset> assetList=new List<Asset>(); //To store the Asset List
        String topCatCode = '';
        dataWrapper dataWrap=new dataWrapper();
        List<csvDataWrapper> csvWrapperList=new List<csvDataWrapper>(); //To get the total csv data
        List<csvDataWrapper> csvProdDet=new List<csvDataWrapper>(); //To get the button filter csv data
        List<String> prodNameList=new List<String>(); //To get the total product count
        
        Try{
            
            //get logged in user lang code
            String langCode = YG_CommonUtils.getLanguageCode(userInformation.LanguageLocaleKey); 
            Date now =  date.today();
            
            //For Top category 
            if(prodCat != ''){
                prodCat = prodCat.replace('+', ' ');
                system.debug('prodCat::'+prodCat);
            }
            
            //Get the user account Id
            ID contactId = userInformation.Contact.ID;  
            AggregateResult[] totProdSize;
            List<Id> assetIds =  YG_HelperClass.getCustomerAssets(contactId);
            
            //get contract assets
            List<Entitlement> entmList = [Select AssetId, Asset.Product2Id, ServiceContract.StartDate, ServiceContract.EndDate 
                                          From Entitlement Where AssetId IN :assetIds and AssetId != null];
            if(btnValue == 'Contracts' && prodIdList.isEmpty()){
                assetIds.clear();
                for(Entitlement ent: entmList){
                    assetIds.add(ent.AssetId);
                }
            }
            
            //Query top category code based on product category
            if(prodCat != ''){
                topCatCode = [Select Name,Category_Hierarchy__r.Category_Code__c FROM Category__c
                              WHERE Name = :prodCat AND Language_Code__c =: langCode].Category_Hierarchy__r.Category_Code__c;
            }
            
            //To get the asset and product records.
            if(prodIdList.size() > 0 && !prodIdList.isEmpty()){
                assetList = YG_HelperClass.getAssetsandProductInfo(assetIds, 'Product', topCatCode,langCode,prodIdList);
            }
            else{
                assetList = YG_HelperClass.getAssetsandProductInfo(assetIds, 'Product', topCatCode,langCode,emptyProdId);
            }
            
            List<Id> assId=new List<Id>();
            List<Id> ProdId=new List<Id>();
            for(Asset asst: assetList){
                System.debug('asst::'+asst);
                if(!assId.contains(asst.Id)){
                    assId.add(asst.Id); 
                }
                if(!ProdId.contains(asst.Product2.Id)){
                    ProdId.add(asst.Product2.Id );
                }
            }
            
            if(assetList.size() > 0){
                prodNameList.clear(); //To get the total product count
                for(Asset ass: assetList){
                    csvDataWrapper csv=new csvDataWrapper();
                    List<String> noti=new List<String>();
                    csv.productCategories = ass.Product2.Product_Categories__c;
                    csv.productNameAndCode = ass.Product2.Name+' '+ass.Product2.Model_Code__c;
                    if(!prodNameList.contains(csv.productNameAndCode)){
                        prodNameList.add(csv.productNameAndCode);
                    }
                    csv.serialNos = ass.SerialNumber;
                    for(Entitlement ent: entmList){
                        if(ent.AssetId == ass.Id){
                            Date endDate = ent.ServiceContract.EndDate;
                            if(endDate != null){
                                Integer months = now.monthsBetween(endDate);
                                if(endDate < now){
                                    noti.add('Contract expired');
                                }
                                if(endDate >= now && months < 6){
                                    noti.add('Contract expiring soon');
                                }
                            }  
                        }
                    }
                    
                    
                    
                    csv.notifications = noti;
                    csvWrapperList.add(csv);  
                }
                dataWrap.csvData =csvWrapperList;
                dataWrap.totalProducts = prodNameList.size();
            }
            /*
            //This is used to sort using button parameter.
            if(csvSort != null & csvSort != ''){
                Integer totalProd = 0;	// To calculate the total serial nos
                prodNameList.clear();
                List<String> prodNameList1=new List<String>(); //To get the total product count
                System.debug('csvSort Inside');
                for(csvDataWrapper csvSortData: dataWrap.csvData){
                    for(String noticheck: csvSortData.notifications){
                        if(noticheck.contains(csvSort)){
                            if(!prodNameList.contains(csvSortData.productNameAndCode)){
                                prodNameList.add(csvSortData.productNameAndCode);
                            }
                            totalProd = totalProd+1; // To calculate the total serial nos
                            csvProdDet.add(csvSortData);
                        }
                    }
                }
                dataWrap.csvData =csvProdDet;
                dataWrap.totalProducts = prodNameList.size();
            }
            System.debug('csvsortdataWrap.totalProducts::'+dataWrap.totalProducts);
            System.debug('csvProdDet::'+csvProdDet);
            System.debug('csvProdDet.size()::'+csvProdDet.size());*/
            
        }Catch(Exception e){
            system.debug('Exception Cause::'+e.getCause());
            system.debug('Exception LineNumber::'+e.getLineNumber());
            system.debug('Exception Message::'+e.getMessage());
            system.debug('Exception StackTrace::'+e.getStackTraceString());
            system.debug('Exception TypeName::'+e.getTypeName());
            YG_Utility.logError('AllProductsCSV','Community Component Error',e.getStackTraceString(),
                                'Class:YG_ProductDetailsCSV; Method: getCsvData(); Line #:'+e.getLineNumber()+'; Message:'+e.getMessage(),
                                UserInfo.getUserId());
        }
        
        System.debug('dataWrap::'+dataWrap);
        return dataWrap;
        
    }
    
    public class dataWrapper{
        @AuraEnabled public Integer totalProducts; 
        @AuraEnabled public List<csvDataWrapper> csvData;
        
    }
    public class csvDataWrapper{
        @AuraEnabled public String productCategories;
        @AuraEnabled public String productNameAndCode;
        @AuraEnabled public String serialNos;
        @AuraEnabled public List<String> notifications;
    }
    
    /*
    @AuraEnabled
    public static ServiceRequestWrapper  getServiceRequestCsv(String plantCode){
        System.debug('plantCode::'+plantCode);
        ServiceRequestWrapper servWrapper=new ServiceRequestWrapper();
        List<ServiceDetails> serviceGrid=new List<ServiceDetails>();
        List<Case> caseRecords=new List<Case>();	//To store the list of case records
        String langCode = 'EN';
        Id cusPltId; // store the plant id
        List<criticalService> criticalServiceList=new List<criticalService>();
        List<productRelatedServices> prodRelateServList=new List<productRelatedServices>();
        List<softwareRelatedServices> softwareRelatedList=new List<softwareRelatedServices>();
        List<inquiresList> inquireList=new List<inquiresList>();
        
        Integer criticalServCnt = 0;
        Integer sysHardwareCount = 0;
        Integer softwareCorruptedCount = 0;
        Integer processEquipFailCount = 0;
        
        Integer prodRelatedServCnt = 0;
        Integer calibCount = 0;
        Integer cleaningCount = 0;
        Integer fixInaccurateInsCount = 0;
        Integer regMaintenanceCount = 0;
        Integer repairCount = 0;
        Integer replaceOldEquipCount = 0;
        Integer prodTroubleshootCount = 0;
        
        Integer sysAndSoftRealtedCnt = 0;
        Integer cyberSecurityCount = 0;
        Integer softwarePatchesCount = 0;
        Integer sysHealthCheckCount = 0;
        Integer sysTroubleshootCount = 0;
        Integer reqUpdateSysAssetCount = 0;
        
        Integer inquiresCnt = 0;
        Integer salesQuoteCount = 0;
        Integer techSupportCnt = 0;
        Integer otherCnt = 0;
        
        try{
            //To get account and contact Id
            Id accId = userInformation.Contact.AccountId;
            Id conId = userInformation.Contact.Id;
            system.debug('accId::'+accId);
            system.debug('conId::'+conId);
            
            
            //To get the plant id
            Plant__c plant = YG_HelperClass.getPlantID(plantCode,langCode);
            cusPltId = plant.id;
            system.debug('selected plant::'+cusPltId);
            
            caseRecords = [Select CaseNumber, Case_Main_Type__c, Case_Sub_Type__c, Status, Type, Reason, AccountId, ContactID, ProductId, 
                           Product.Name, Product.Model_Code__c, AssetId, Asset.Name, Asset.Product2.Name, Asset.Product2.Model_Code__c, 
                           CreatedDate, Progress__c, Inquired_Product__c From case Where Plant__c =: cusPltId And ContactID =:conId ];
            System.debug('caseRecords++::'+caseRecords);
            System.debug('caseRecords++Size::'+caseRecords.size());
            
            for(Case caseDetails: caseRecords){
                ServiceDetails serv=new ServiceDetails();	//Instance to store the grid data's
                System.debug('caseDetails.Case_Main_Type__c:::'+caseDetails.Case_Main_Type__c);
                System.debug('caseDetails.Case_Sub_Type__c:::'+caseDetails.Case_Sub_Type__c);
                if(caseDetails.Case_Sub_Type__c == 'System hardware failure'){
                    sysHardwareCount++;
                }
                //System.debug('sysHardwareCount::'+sysHardwareCount);
                if(caseDetails.Case_Sub_Type__c == 'Software corrupted'){
                    softwareCorruptedCount++;
                }
                //System.debug('softwareCorruptedCount::'+softwareCorruptedCount);
                if(caseDetails.Case_Sub_Type__c == 'Process equipment failure'){
                    processEquipFailCount++;
                }
                //System.debug('processEquipFailCount::'+processEquipFailCount);
                if(caseDetails.Case_Sub_Type__c == 'Calibration'){
                    calibCount++;
                }
                if(caseDetails.Case_Sub_Type__c == 'Cleaning'){
                    cleaningCount++;
                }
                if(caseDetails.Case_Sub_Type__c == 'Fix an inaccurate instrument'){
                    fixInaccurateInsCount++;
                }
                if(caseDetails.Case_Sub_Type__c == 'Regular maintenance'){
                    regMaintenanceCount++;
                }
                if(caseDetails.Case_Sub_Type__c == 'Repair'){
                    repairCount++;
                }
                if(caseDetails.Case_Sub_Type__c == 'Replacement of old equipment'){
                    replaceOldEquipCount++;
                }
                if(caseDetails.Case_Main_Type__c == 'Product related services'){
                    if(caseDetails.Case_Sub_Type__c == 'Troubleshooting'){
                        prodTroubleshootCount++;
                    }
                }
                if(caseDetails.Case_Sub_Type__c == 'Cyber security'){
                    cyberSecurityCount++;
                }
                if(caseDetails.Case_Sub_Type__c == 'Software patches'){
                    softwarePatchesCount++;
                }
                if(caseDetails.Case_Sub_Type__c == 'System healthiness check'){
                    sysHealthCheckCount++;
                }									 
                if(caseDetails.Case_Main_Type__c == 'Systems and Software related services'){
                    if(caseDetails.Case_Sub_Type__c == 'Troubleshooting'){
                        sysTroubleshootCount++;
                    }
                }
                if(caseDetails.Case_Sub_Type__c == 'Request to update system assets'){
                    reqUpdateSysAssetCount++;
                }
                
                if(caseDetails.Reason == 'Sales and Quote'){
                    salesQuoteCount ++;
                }
                if(caseDetails.Reason == 'Technical Support'){
                    techSupportCnt ++;
                }
                if(caseDetails.Reason == 'Others'){
                    otherCnt ++;
                }
                
                if(caseDetails.Case_Main_Type__c != null && caseDetails.Case_Main_Type__c != ''){
                    serv.mainType = caseDetails.Case_Main_Type__c;
                }else{
                    serv.mainType = caseDetails.Type;
                }
                if(caseDetails.Case_Sub_Type__c != null && caseDetails.Case_Sub_Type__c != ''){
                    serv.subType = caseDetails.Case_Sub_Type__c;
                }else{
                    serv.subType = caseDetails.Reason;
                }
                
                //To replace the Date formate
                date caseCreatedDate = caseDetails.CreatedDate.date();
                Datetime dt = Datetime.newInstance(caseCreatedDate.year(),caseCreatedDate.month(),caseCreatedDate.day());
                String dateVal = dt.format('dd MMM YYYY'); 
                serv.caseCreatedDate = dateVal; //To get the date value for the grid
                System.debug('caseDetails.AssetId::'+caseDetails.AssetId);
                if(caseDetails.AssetId != Null){
                    serv.productName = caseDetails.Asset.Product2.Name;
                    serv.modelCode = caseDetails.Asset.Product2.Model_Code__c;
                    serv.assetName = caseDetails.Asset.Name;
                }
                else{
                    if(caseDetails.Product.Name != null){
                        serv.productName = caseDetails.Product.Name;
                        serv.modelCode = caseDetails.Product.Model_Code__c;
                        serv.assetName = '';
                    }else if(caseDetails.Inquired_Product__c != null && caseDetails.Type == 'Submit An Inquiry'){
                        serv.productName = caseDetails.Inquired_Product__c;
                        serv.modelCode = '';
                        serv.assetName = '';
                    }
                    else{
                        serv.productName = '';
                        serv.modelCode = '';
                        serv.assetName = '';
                    }
                }
                if(caseDetails.Progress__c != null && caseDetails.Progress__c != ''){
                    serv.progress = caseDetails.Progress__c;
                }else{
                    serv.progress = '';
                }
                serv.status = caseDetails.Status;
                
                serviceGrid.add(serv);
            }
            
            servWrapper.serviceDet = serviceGrid;
            System.debug('servWrapper::'+servWrapper);
            System.debug('servWrapper::serviceDet::'+servWrapper.serviceDet);
            
            
            criticalServCnt = sysHardwareCount + softwareCorruptedCount + processEquipFailCount;
            System.debug('sysHardwareCount::'+sysHardwareCount); System.debug('softwareCorruptedCount::'+softwareCorruptedCount); System.debug('processEquipFailCount::'+processEquipFailCount);
            System.debug('calibCount::'+calibCount); System.debug('cleaningCount::'+cleaningCount); System.debug('fixInaccurateInsCount::'+fixInaccurateInsCount); System.debug('regMaintenanceCount::'+regMaintenanceCount); System.debug('repairCount::'+repairCount); System.debug('replaceOldEquipCount::'+replaceOldEquipCount); System.debug('prodTroubleshootCount::'+prodTroubleshootCount);
            prodRelatedServCnt = calibCount + cleaningCount + fixInaccurateInsCount + regMaintenanceCount + repairCount + replaceOldEquipCount + prodTroubleshootCount;
            sysAndSoftRealtedCnt = cyberSecurityCount + softwarePatchesCount + sysHealthCheckCount + sysTroubleshootCount + reqUpdateSysAssetCount;
            System.debug('cyberSecurityCount::'+cyberSecurityCount); System.debug('softwarePatchesCount::'+softwarePatchesCount); System.debug('sysHealthCheckCount::'+sysHealthCheckCount); System.debug('sysTroubleshootCount::'+sysTroubleshootCount); System.debug('reqUpdateSysAssetCount::'+reqUpdateSysAssetCount);
            inquiresCnt = salesQuoteCount + techSupportCnt + otherCnt;
            System.debug('salesQuoteCount::'+salesQuoteCount); System.debug('techSupportCnt::'+techSupportCnt); System.debug('otherCnt::'+otherCnt);
            System.debug('criticalServCnt::'+criticalServCnt);
            System.debug('prodRelatedServCnt::'+prodRelatedServCnt);
            System.debug('sysAndSoftRealtedCnt::'+sysAndSoftRealtedCnt);
            System.debug('inquiresCnt::'+inquiresCnt);
            
            //Adding the data for the donut chart in the below format in a list.
            servWrapper.criticalServiceCnt = criticalServCnt;
            if(sysHardwareCount != 0){
                criticalService criticalSubmenu1=new criticalService();
                criticalSubmenu1.label = 'System HW fail: '+sysHardwareCount;
                criticalSubmenu1.value = sysHardwareCount;
                criticalSubmenu1.color = '#FFEE00';
                criticalServiceList.add(criticalSubmenu1);
            }
            if(softwareCorruptedCount != 0){
                criticalService criticalSubmenu2=new criticalService();
                criticalSubmenu2.label = 'SW corrupt: '+softwareCorruptedCount;
                criticalSubmenu2.value = softwareCorruptedCount;
                criticalSubmenu2.color = '#F1BC1A';
                criticalServiceList.add(criticalSubmenu2);
            }
            if(processEquipFailCount != 0){
                criticalService criticalSubmenu3=new criticalService();
                criticalSubmenu3.label = 'Process eqpt: '+processEquipFailCount;
                criticalSubmenu3.value = processEquipFailCount;
                criticalSubmenu3.color = '#CE4E0E';
                criticalServiceList.add(criticalSubmenu3);
            }
            servWrapper.criticalServSubmenuCnt = criticalServiceList;
            servWrapper.systemHardwarefailureCnt = sysHardwareCount;
            servWrapper.softwareCorruptedCnt = softwareCorruptedCount;
            servWrapper.processEquipmentFailureCnt = processEquipFailCount;
            
            
            servWrapper.productRelatedServicesCnt = prodRelatedServCnt;
            if(calibCount != 0){
                productRelatedServices prodRelateSubmenu1=new productRelatedServices();
                prodRelateSubmenu1.label = 'Calibration: '+calibCount;
                prodRelateSubmenu1.value = calibCount;
                prodRelateSubmenu1.color = '#FFEE00';
                prodRelateServList.add(prodRelateSubmenu1);
            }
            if(cleaningCount != 0){
                productRelatedServices prodRelateSubmenu2=new productRelatedServices();
                prodRelateSubmenu2.label = 'Cleaning: '+cleaningCount;
                prodRelateSubmenu2.value = cleaningCount;
                prodRelateSubmenu2.color = '#F1BC1A';
                prodRelateServList.add(prodRelateSubmenu2);
            }
            if(fixInaccurateInsCount != 0){
                productRelatedServices prodRelateSubmenu3=new productRelatedServices();
                prodRelateSubmenu3.label = 'Fix instrument: '+fixInaccurateInsCount;
                prodRelateSubmenu3.value = fixInaccurateInsCount;
                prodRelateSubmenu3.color = '#CE4E0E';
                prodRelateServList.add(prodRelateSubmenu3);
            }
            if(regMaintenanceCount != 0){
                productRelatedServices prodRelateSubmenu4=new productRelatedServices();
                prodRelateSubmenu4.label = 'Maintenance: '+regMaintenanceCount;
                prodRelateSubmenu4.value = regMaintenanceCount;
                prodRelateSubmenu4.color = '#0458AA';
                prodRelateServList.add(prodRelateSubmenu4);
            }
            if(repairCount != 0){
                productRelatedServices prodRelateSubmenu5=new productRelatedServices();
                prodRelateSubmenu5.label = 'Repair: '+repairCount;
                prodRelateSubmenu5.value = repairCount;
                prodRelateSubmenu5.color = '#00316C';
                prodRelateServList.add(prodRelateSubmenu5);
            }
            if(replaceOldEquipCount != 0){
                productRelatedServices prodRelateSubmenu6=new productRelatedServices();
                prodRelateSubmenu6.label = 'Replace eqpt: '+replaceOldEquipCount;
                prodRelateSubmenu6.value = replaceOldEquipCount;
                prodRelateSubmenu6.color = '#00694C';
                prodRelateServList.add(prodRelateSubmenu6);
            }
            if(prodTroubleshootCount != 0){
                productRelatedServices prodRelateSubmenu7=new productRelatedServices();
                prodRelateSubmenu7.label = 'Troubleshooting: '+prodTroubleshootCount;
                prodRelateSubmenu7.value = prodTroubleshootCount;
                prodRelateSubmenu7.color = '#00A04C';
                prodRelateServList.add(prodRelateSubmenu7);
            }
            servWrapper.productRelateSubmenuCnt = prodRelateServList;
            servWrapper.calibrationCnt = calibCount;
            servWrapper.cleaningCnt = cleaningCount;
            servWrapper.fixAnInaccurateInstrumentCnt = fixInaccurateInsCount;
            servWrapper.regularmaintenanceCnt = regMaintenanceCount;
            servWrapper.repairCnt = repairCount;
            servWrapper.replaceOldEquipCnt  = replaceOldEquipCount;
            servWrapper.productTroubleshootingCnt = prodTroubleshootCount;
            
            servWrapper.softwareRelatedServicesCnt = sysAndSoftRealtedCnt;
            if(cyberSecurityCount != 0){
                softwareRelatedServices softwareRelatedSubmenu1=new softwareRelatedServices();
                softwareRelatedSubmenu1.label = 'Cyber security: '+cyberSecurityCount;
                softwareRelatedSubmenu1.value = cyberSecurityCount;
                softwareRelatedSubmenu1.color = '#FFEE00';
                softwareRelatedList.add(softwareRelatedSubmenu1);
            }
            if(softwarePatchesCount != 0){
                softwareRelatedServices softwareRelatedSubmenu2=new softwareRelatedServices();
                softwareRelatedSubmenu2.label = 'SW Patch: '+softwarePatchesCount;
                softwareRelatedSubmenu2.value = softwarePatchesCount;
                softwareRelatedSubmenu2.color = '#F1BC1A';
                softwareRelatedList.add(softwareRelatedSubmenu2);
            }
            if(sysHealthCheckCount != 0){
                softwareRelatedServices softwareRelatedSubmenu3=new softwareRelatedServices();
                softwareRelatedSubmenu3.label = 'System check: '+sysHealthCheckCount;
                softwareRelatedSubmenu3.value = sysHealthCheckCount;
                softwareRelatedSubmenu3.color = '#CE4E0E';
                softwareRelatedList.add(softwareRelatedSubmenu3);
            }
            if(sysTroubleshootCount != 0 ){
                softwareRelatedServices softwareRelatedSubmenu4=new softwareRelatedServices();
                softwareRelatedSubmenu4.label = 'Troubleshooting: '+sysTroubleshootCount;
                softwareRelatedSubmenu4.value = sysTroubleshootCount;
                softwareRelatedSubmenu4.color = '#0458AA';
                softwareRelatedList.add(softwareRelatedSubmenu4);
            }
            if(reqUpdateSysAssetCount != 0 ){
                softwareRelatedServices softwareRelatedSubmenu5=new softwareRelatedServices();
                softwareRelatedSubmenu5.label = 'update system: '+reqUpdateSysAssetCount;
                softwareRelatedSubmenu5.value = reqUpdateSysAssetCount;
                softwareRelatedSubmenu5.color = '#00316C';
                softwareRelatedList.add(softwareRelatedSubmenu5);
            }
            servWrapper.softwareRelatedSubmenuCnt = softwareRelatedList;
            servWrapper.cyberSecurityCnt = cyberSecurityCount;
            servWrapper.softwarePatchesCnt = softwarePatchesCount;
            servWrapper.systemHealthinessCheckCnt = sysHealthCheckCount;
            servWrapper.systemTroubleshootingCnt = sysTroubleshootCount;
            servWrapper.requestToUpdateSystemAssetsCnt = reqUpdateSysAssetCount;
            
            servWrapper.inquires = inquiresCnt;
            if(salesQuoteCount !=0){
                inquiresList inquireySubmenu1=new inquiresList();
                inquireySubmenu1.label = 'Sales & Quote: '+salesQuoteCount;
                inquireySubmenu1.value = salesQuoteCount;
                inquireySubmenu1.color = '#FFEE00';
                inquireList.add(inquireySubmenu1);
            }
            if(techSupportCnt != 0){
                inquiresList inquireySubmenu2=new inquiresList();
                inquireySubmenu2.label = 'Tech Support: '+techSupportCnt;
                inquireySubmenu2.value = techSupportCnt;
                inquireySubmenu2.color = '#F1BC1A';
                inquireList.add(inquireySubmenu2);
            }
            if(otherCnt != 0){
                inquiresList inquireySubmenu3=new inquiresList();
                inquireySubmenu3.label = 'Others: '+otherCnt;
                inquireySubmenu3.value = otherCnt;
                inquireySubmenu3.color = '#CE4E0E';
                inquireList.add(inquireySubmenu3);
            }
            servWrapper.inquiresListCnt = inquireList;
            servWrapper.salesQuoteCnt = salesQuoteCount;
            servWrapper.technicalSupportCnt = techSupportCnt;
            servWrapper.others = otherCnt;
            
        }Catch(Exception e){
            system.debug('Exception Cause::'+e.getCause());
            system.debug('Exception LineNumber::'+e.getLineNumber());
            system.debug('Exception Message::'+e.getMessage());
            system.debug('Exception StackTrace::'+e.getStackTraceString());
            system.debug('Exception TypeName::'+e.getTypeName());
            YG_Utility.logError('getServiceRequestCsvData','Community Component Error',e.getStackTraceString(),
                                'Class:YG_ProductDetailsCSV; Method: getServiceRequestCsv(); Line #:'+e.getLineNumber()+'; Message:'+e.getMessage(),
                                UserInfo.getUserId());
        }
        return servWrapper;
    }
    public class ServiceRequestWrapper{
        @AuraEnabled public Integer criticalServiceCnt;
        @AuraEnabled public List<criticalService> criticalServSubmenuCnt;
        @AuraEnabled public Integer systemHardwarefailureCnt;
        @AuraEnabled public Integer softwareCorruptedCnt;
        @AuraEnabled public Integer processEquipmentFailureCnt;
        
        @AuraEnabled public Integer productRelatedServicesCnt;
        @AuraEnabled public List<productRelatedServices> productRelateSubmenuCnt;
        @AuraEnabled public Integer calibrationCnt;
        @AuraEnabled public Integer cleaningCnt;
        @AuraEnabled public Integer fixAnInaccurateInstrumentCnt;
        @AuraEnabled public Integer regularmaintenanceCnt;
        @AuraEnabled public Integer repairCnt;
        @AuraEnabled public Integer replaceOldEquipCnt;
        @AuraEnabled public Integer productTroubleshootingCnt;
        
        @AuraEnabled public Integer softwareRelatedServicesCnt; 
        @AuraEnabled public List<softwareRelatedServices> softwareRelatedSubmenuCnt;
        @AuraEnabled public Integer cyberSecurityCnt;
        @AuraEnabled public Integer softwarePatchesCnt;
        @AuraEnabled public Integer systemHealthinessCheckCnt;
        @AuraEnabled public Integer systemTroubleshootingCnt;
        @AuraEnabled public Integer requestToUpdateSystemAssetsCnt;
        
        @AuraEnabled public Integer inquires;
        @AuraEnabled public List<inquiresList> inquiresListCnt;
        @AuraEnabled public Integer salesQuoteCnt;
        @AuraEnabled public Integer technicalSupportCnt;
        @AuraEnabled public Integer others;
        //Wrapper List data for Grid
        @AuraEnabled public List<ServiceDetails> serviceDet;   
    }
    public class criticalService{
        @AuraEnabled public String label;
        @AuraEnabled public Integer value;
        @AuraEnabled public String color;
    }
    public class productRelatedServices{
        @AuraEnabled public String label;
        @AuraEnabled public Integer value;
        @AuraEnabled public String color;
    }
    public class softwareRelatedServices{
        @AuraEnabled public String label;
        @AuraEnabled public Integer value;
        @AuraEnabled public String color;
    }
    public class inquiresList{
        @AuraEnabled public String label;
        @AuraEnabled public Integer value;
        @AuraEnabled public String color;
    }
    //Grid Data Wrapper
    public class ServiceDetails{
        @AuraEnabled public String mainType;
        @AuraEnabled public String subType;
        @AuraEnabled public String caseCreatedDate;
        @AuraEnabled public String productName;
        @AuraEnabled public String modelCode;
        @AuraEnabled public String assetName;
        @AuraEnabled public String status;
        @AuraEnabled public String progress;
        
        @AuraEnabled public Map<Date, String> progressStatus;
        @AuraEnabled public List<ServiceStatusHistory> serviceHistory;
    }
    public class ServiceStatusHistory{
        //@AuraEnabled public List<String> progressStatus;
        @AuraEnabled public Map<Date, String> progressStatus;
    }
    */
    
    @AuraEnabled
    public static ServiceContractWrapper getServiceContractCSV(String plantCode){
        System.debug('plantCode::'+plantCode);
        ServiceContractWrapper servContract=new ServiceContractWrapper(); //Main Wrapper
        List<ServiceContracts> serviceContractListWrap=new List<ServiceContracts>(); //Sub Wrapper List
        List<ServiceContract> servContractList=new List<ServiceContract>(); //List to store the service contract records
        List<ServiceContract> serviceContractTotalCnt=new List<ServiceContract>(); //List to get the total cnt
        List<Id> contractIdList=new List<Id>(); //To get the list of contract ids associated with plant and cust assets
        Integer expiryLessSixMon = 0;
        Integer activeStatus = 0;
        Integer inactiveStatus = 0;
        Integer expiredStatus = 0;
        Integer industryAuto = 0;
        Integer testAndMeasure = 0;
        Integer lifeInno = 0;
        Try{
            ID accId = userInformation.Contact.AccountId;  
            //To get the service contact Id assests
            ID contactId = userInformation.Contact.ID;  
            List<Id> assetIds =  YG_HelperClass.getCustomerAssets(contactId);
            system.debug('*******Customer assetIds::'+assetIds);
            //to get the service contract id
            contractIdList = YG_HelperClass.getServiceContracts(plantCode, assetIds);
             System.debug('contractIdList::'+contractIdList);
            
            List<Id> servContWithoutSop = YG_AllServiceContractsController.getServContWithoutSOP(accId);
            System.debug('servContWithoutSop::'+servContWithoutSop);
            for(Id servId : servContWithoutSop){
                if(!contractIdList.contains(servId)){
                    contractIdList.add(servId);
                }
            }
            System.debug('final servCont Ids::'+contractIdList);
            
            servContractList = [Select Id, Contract_No__c, Name, Description, YG_Sales_Manager_Name__c, YG_Sales_Manager_Email__c, YG_Sales_Manager_contact_no__c,
                                StartDate, EndDate, YG_Sales_Manager_profile_photo__c, Owner.Name, Owner.Email, Owner.Phone,Contract_Type__c, Status, Contract_categories__c ,
                                (Select Id, Asset__r.Name, Asset__r.Product2.Name  From Scope_of_Product__r)/*,
                                (Select Id, Asset.Name, Asset.Product2.Name  From Entitlements) */
                                From ServiceContract Where Id IN: contractIdList];
            
            if(servContractList.size() > 0){
                servContract.totalContractCnt = servContractList.size();
                for(ServiceContract servCont : servContractList){
                    ServiceContracts servContRec=new ServiceContracts();
                    if(servCont.Contract_Type__c != 'LCA'){
                        for(Scope_of_Product__c entitle: servCont.Scope_of_Product__r){
                            System.debug('entitle.Asset.Product2.Name ::'+entitle.Asset__r.Product2.Name );
                            System.debug('entitle.Asset.Name ::'+entitle.Asset__r.Name );
                            System.debug('entitle.Asset.Name ::'+entitle.Asset__r.Name );
                            servContRec.productName = entitle.Asset__r.Product2.Name;
                            servContRec.serialNum = entitle.Asset__r.Name;
                            servContRec.contractName = servCont.Name;
                            servContRec.contractNum = servCont.Contract_No__c;
                            servContRec.ygSalesManager = servCont.Owner.Name;
                            servContRec.industry = servCont.Contract_categories__c;
                            Datetime dt1 = Datetime.newInstance(servCont.StartDate.year(),servCont.StartDate.month(),servCont.StartDate.day());
                            servContRec.startDate = dt1.format('dd MMM YYYY');
                            Datetime dt2 = Datetime.newInstance(servCont.EndDate.year(),servCont.EndDate.month(),servCont.EndDate.day());
                            servContRec.endDate = dt2.format('dd MMM YYYY');
                            String serviceContractExpiry = YG_HelperClass.getServiceContractExpiry(servCont.EndDate);
                            if(serviceContractExpiry != null && servCont.Status == 'Active'){
                                servContRec.notification = serviceContractExpiry;
                                expiryLessSixMon ++;
                            }
                            //To check the Status for the button count
                            if(servCont.Status == 'Active'){
                                activeStatus ++;
                            }
                            if(servCont.Status == 'Inactive'){
                                inactiveStatus ++;
                            }
                            if(servCont.Status == 'Expired'){
                                expiredStatus ++;
                            }
                            /*if(servCont.Contract_categories__c == 'Industrial Automation'){
                                industryAuto ++;
                            }
                            if(servCont.Contract_categories__c == 'Test & Measurement'){
                                testAndMeasure ++;
                            }
                            if(servCont.Contract_categories__c == 'Life Innovation'){
                                lifeInno ++;
                            }*/
                            serviceContractListWrap.add(servContRec);
                        } 
                    }else{
                        servContRec.contractName = servCont.Name;
                        servContRec.contractNum = servCont.Contract_No__c;
                        //Converting date to string
                        Datetime dt1 = Datetime.newInstance(servCont.StartDate.year(),servCont.StartDate.month(),servCont.StartDate.day());
                        servContRec.startDate = dt1.format('dd MMM YYYY');
                        Datetime dt2 = Datetime.newInstance(servCont.EndDate.year(),servCont.EndDate.month(),servCont.EndDate.day());
                        servContRec.endDate = dt2.format('dd MMM YYYY');
                        servContRec.contractDescription = servCont.Description;
                        servContRec.ygSalesManager = servCont.YG_Sales_Manager_Name__c;
                        servContRec.industry = servCont.Contract_categories__c;
                        String serviceContractExpiry = YG_HelperClass.getServiceContractExpiry(servCont.EndDate);
                        if(serviceContractExpiry != null && servCont.Status == 'Active'){
                            servContRec.notification = serviceContractExpiry;
                            expiryLessSixMon ++;
                        }
                        //To check the Status for the button count
                        if(servCont.Status == 'Active'){
                            activeStatus ++;
                        }
                        if(servCont.Status == 'Inactive'){
                            inactiveStatus ++;
                        }
                        if(servCont.Status == 'Expired'){
                            expiredStatus ++;
                        }
                        /*if(servCont.Contract_categories__c == 'Industrial Automation'){
                            industryAuto ++;
                        }
                        if(servCont.Contract_categories__c == 'Test & Measurement'){
                            testAndMeasure ++;
                        }
                        if(servCont.Contract_categories__c == 'Life Innovation'){
                            lifeInno ++;
                        }*/
                        serviceContractListWrap.add(servContRec);
                    }
                }
            }
            System.debug('serviceContractListWrap::'+serviceContractListWrap);
            System.debug('serviceContractListWrap.Size()::'+serviceContractListWrap.size());
            servContract.ServiceContractsList = serviceContractListWrap;
            
            System.debug('expiryLessSixMon::'+expiryLessSixMon);
            System.debug('activeStatus::CSV'+activeStatus);
            System.debug('inactiveStatus::'+inactiveStatus);
            System.debug('expiredStatus::'+expiredStatus);
            servContract.expirySixMonths = expiryLessSixMon;
            servContract.activeContract = activeStatus;
            servContract.futureContract = inactiveStatus;
            servContract.expiredContract = expiredStatus;
            servContract.industrialAutoCnt = industryAuto;
            servContract.testAndMeasureCnt = testAndMeasure;
            servContract.lifeInnovationCnt = lifeInno;
          
        }Catch(Exception e){
            system.debug('Exception Cause::'+e.getCause());
            system.debug('Exception LineNumber::'+e.getLineNumber());
            system.debug('Exception Message::'+e.getMessage());
            system.debug('Exception StackTrace::'+e.getStackTraceString());
            system.debug('Exception TypeName::'+e.getTypeName());
            YG_Utility.logError('getServiceContractCSV','Community Component Error',e.getStackTraceString(),
                                'Class:YG_ProductDetailsCSV; Method: getServiceContractCSV(); Line #:'+e.getLineNumber()+'; Message:'+e.getMessage(),
                                UserInfo.getUserId());
        }
        System.debug('servContract::'+servContract);
        return servContract;
    }
    public class ServiceContractWrapper{
        @AuraEnabled public Integer totalContractCnt = 0;
        @AuraEnabled public Integer expirySixMonths;
        @AuraEnabled public Integer activeContract;
        @AuraEnabled public Integer futureContract;
        @AuraEnabled public Integer expiredContract;
        @AuraEnabled public Integer industrialAutoCnt;
        @AuraEnabled public Integer testAndMeasureCnt;
        @AuraEnabled public Integer lifeInnovationCnt;
        @AuraEnabled public List<ServiceContracts> ServiceContractsList;
    }
    public class ServiceContracts{
        @AuraEnabled public String contractName;
        @AuraEnabled public String contractNum;
        @AuraEnabled public String contractDescription;
        @AuraEnabled public String productName;
        @AuraEnabled public String serialNum;
        @AuraEnabled public String ygSalesManager;
        @AuraEnabled public String startDate;
        @AuraEnabled public String endDate;
        @AuraEnabled public String notification;
        @AuraEnabled public String industry;
        
        
    }
}