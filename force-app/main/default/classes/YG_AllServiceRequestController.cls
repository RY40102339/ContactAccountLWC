/********************************************************************************************************
* (C) Copyright 2020 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Vinod A
* @version 1.0
* @created 08/14/2020
* @description 
* This class used to get all the service request.
*
* @test class name - YG_AllServiceRequestControllerTest
*
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  11/19/2020			Selvaraj.T				Update the logic according to changes
*/

public class YG_AllServiceRequestController {
    
    public static User userInformation =  YG_Utility.getLoggedInUserInfo(UserInfo.getUserId());
    
    //This method is used to get the grid details in all service request page
    @AuraEnabled 
    public static ServiceRequestGridWrapper getServiceRequestGridDetails(List<String> filterValue,String catType,String caseStatus,Integer loadLimit, Integer offset){
        
        system.debug('filterValue::'+filterValue);
        system.debug('catType::'+catType);
        system.debug('caseStatus::'+caseStatus);
        system.debug('loadLimit::'+loadLimit);
        system.debug('offset::'+offset);
        
        
        ServiceRequestGridWrapper servReqWrap = new ServiceRequestGridWrapper();
        List<Case> allCaseList = new List<Case>(); //List to store all the case data
        List<Case> gridCaseList = new List<Case>(); //List to store the case data based on limit
        List<CaseData> caseDataList = new List<CaseData>(); //List to store the case grid data
        List<String> caseStatList = new List<String>();
        List<String> filteredCaseList = new List<String>();
        Integer totalCaseCnt = 0;
        Integer prodCaseCnt = 0;
        Integer sysCaseCnt = 0;
        Integer inqCaseCnt = 0;
        List<String> prodService=new List<String>{'050','030','040','080','100','900'};
            List<String> sysService=new List<String>{'010','020','040','060','070','100','900'};
                Map<String, String> serviceMap=new Map<String, String>();
        List<Id> allCaseId = new List<Id>();
        List<Id> prodId = new List<Id>();
        List<Id> sysId = new List<Id>();
        List<Id> inqId = new List<Id>();
        
        
        try{
            //To get the map of services
            Schema.DescribeFieldResult fieldResult = Case.Service_You_Require__c.getDescribe();
            List<Schema.PicklistEntry> serviceList = fieldResult.getPicklistValues();
            
            for(Schema.PicklistEntry serv : serviceList){
                serviceMap.put(serv.getValue(), serv.getLabel());
            }
            system.debug('serviceMap::'+serviceMap);
            
            //Get the user lang code
            String langCode = YG_CommonUtils.getLanguageCode(userInformation.LanguageLocaleKey); 
            system.debug('langCode::'+langCode);            
            
            //To get account and contact Id
            Id accId = userInformation.Contact.AccountId;
            Id conId = userInformation.Contact.Id;
            system.debug('accId::'+accId);
            system.debug('conId::'+conId);
            
            //get self registered account id
            Map<String, YG_Community_Configuration__c> allValues = YG_Community_Configuration__c.getAll();
            String selfRegAccId = allValues.get('YGSelfRegisterAccountId').Text_1__c;
            
            //Case Status logic
            if(caseStatus == ''){
                caseStatList.add('Active');
                caseStatList.add('Closed');
            }else{
                caseStatList.add(caseStatus);
            }
            
            if(filterValue.size()>0){
                List<Case> cseList = [Select Id From Case Where account.id = :accId And (toLabel(Service_You_Require__c) IN :filterValue OR
                                                                                         Reason IN :filterValue OR Product.Name IN :filterValue OR Asset.Product2.Name IN :filterValue)];
                for(Case cse: cseList){
                    filteredCaseList.add(cse.Id);
                }
            }
            system.debug('filteredCaseList::'+filteredCaseList.size());
            
            //query all cases under specific contact
            if(accId == selfRegAccId){
                if(filteredCaseList.size()>0){
                    allCaseList = [Select Id, CreatedDate, Description, Progress__c, Service_You_Require__c, Asset.Product2.Name, Asset.Product2.Model_Code__c,
                                   ProductId, AssetId, Asset.Product2.Category__r.Category_type__c, Product.Category__r.Category_type__c, Asset.SerialNumber,
                                   Type, Reason, Product.Name, Product.Model_Code__c, CaseNumber,Status,ServAir_Created_Date__c From Case Where account.id = :accId And contact.id = :conId And Type IN ('Request For Service','Submit An Inquiry')
                                   And Status IN :caseStatList And Id IN :filteredCaseList];
                }else{
                    allCaseList = [Select Id, CreatedDate, Description, Progress__c, Service_You_Require__c, Asset.Product2.Name, Asset.Product2.Model_Code__c,
                                   ProductId, AssetId, Asset.Product2.Category__r.Category_type__c, Product.Category__r.Category_type__c, Asset.SerialNumber,
                                   Type, Reason, Product.Name, Product.Model_Code__c, CaseNumber,Status,ServAir_Created_Date__c From Case Where account.id = :accId And contact.id = :conId And Type IN ('Request For Service','Submit An Inquiry')
                                   And Status IN :caseStatList];
                }
            }else{
                if(filteredCaseList.size()>0){
                    allCaseList = [Select Id, CreatedDate, Description, Progress__c, Service_You_Require__c, Asset.Product2.Name, Asset.Product2.Model_Code__c,
                                   ProductId, AssetId, Asset.Product2.Category__r.Category_type__c, Product.Category__r.Category_type__c, Asset.SerialNumber,
                                   Type, Reason, Product.Name, Product.Model_Code__c, CaseNumber,Status,ServAir_Created_Date__c From Case Where account.id = :accId And Type IN ('Request For Service','Submit An Inquiry')
                                   And Status IN :caseStatList And Id IN :filteredCaseList];
                }else{
                    allCaseList = [Select Id, CreatedDate, Description, Progress__c, Service_You_Require__c, Asset.Product2.Name, Asset.Product2.Model_Code__c,
                                   ProductId, AssetId, Asset.Product2.Category__r.Category_type__c, Product.Category__r.Category_type__c, Asset.SerialNumber,
                                   Type, Reason, Product.Name, Product.Model_Code__c, CaseNumber,Status,ServAir_Created_Date__c From Case Where account.id = :accId And Type IN ('Request For Service','Submit An Inquiry')
                                   And Status IN :caseStatList];
                }
            }
            
            system.debug('allCaseList::'+allCaseList.size());
            
            //looping the case list to get case count for service and inquiry
            for(Case cse: allCaseList){
                if(cse.Type == 'Request For Service' && ((cse.Product.Category__r.Category_type__c == 'Product' || cse.Asset.Product2.Category__r.Category_type__c == 'Product') || (cse.AssetId == null && cse.ProductId == null)) && cse.Service_You_Require__c != null && prodService.contains(cse.Service_You_Require__c)){
                    prodCaseCnt++;
                    allCaseId.add(cse.Id);
                    prodId.add(cse.Id);
                }
                if(!allCaseId.contains(cse.Id) && !prodId.contains(cse.Id) && cse.Type == 'Request For Service' && cse.Service_You_Require__c != null && ((cse.Product.Category__r.Category_type__c == 'System' || cse.Asset.Product2.Category__r.Category_type__c == 'System' ) || (cse.AssetId == null && cse.ProductId == null))  && sysService.contains(cse.Service_You_Require__c)){
                    sysCaseCnt++;
                    allCaseId.add(cse.Id);
                    sysId.add(cse.Id);
                }
                if(cse.Type == 'Submit An Inquiry' && cse.Reason != null){
                    inqCaseCnt++;
                    allCaseId.add(cse.Id);
                    inqId.add(cse.Id);
                }
            }
            
            //query case based on button selection in UI
            if(catType == ''){
                if(filteredCaseList.size()>0){
                    gridCaseList = [Select Id, CreatedDate, Description, Progress__c, Service_You_Require__c, Asset.Product2.Name, Asset.Product2.Model_Code__c,
                                    ProductId, AssetId, Asset.Product2.Category__r.Category_type__c, Product.Category__r.Category_type__c, Asset.SerialNumber,
                                    Type, Reason, Product.Name, Product.Model_Code__c, CaseNumber,Status,ServAir_Created_Date__c From Case Where Id IN :allCaseId 
                                    Order by CreatedDate Desc Limit :loadLimit OFFSET :offset];
                }else{
                    gridCaseList = [Select Id, CreatedDate, Description, Progress__c, Service_You_Require__c, Asset.Product2.Name, Asset.Product2.Model_Code__c,
                                    ProductId, AssetId, Asset.Product2.Category__r.Category_type__c, Product.Category__r.Category_type__c, Asset.SerialNumber,
                                    Type, Reason, Product.Name, Product.Model_Code__c, CaseNumber,Status,ServAir_Created_Date__c From Case Where Id IN :allCaseId 
                                    Order by CreatedDate Desc Limit :loadLimit OFFSET :offset];
                }
                
            }
            
            if(catType == 'Product'){
                if(filteredCaseList.size()>0){
                    gridCaseList = [Select Id, CreatedDate, Description, Progress__c, Service_You_Require__c, Asset.Product2.Name, Asset.Product2.Model_Code__c,
                                    ProductId, AssetId, Asset.Product2.Category__r.Category_type__c, Product.Category__r.Category_type__c, Asset.SerialNumber,
                                    Type, Reason, Product.Name, Product.Model_Code__c, CaseNumber,Status,ServAir_Created_Date__c From Case Where Id IN :prodId 
                                    Order by CreatedDate Desc Limit :loadLimit OFFSET :offset]; 
                }else{
                    gridCaseList = [Select Id, CreatedDate, Description, Progress__c, Service_You_Require__c, Asset.Product2.Name, Asset.Product2.Model_Code__c,
                                    ProductId, AssetId, Asset.Product2.Category__r.Category_type__c, Product.Category__r.Category_type__c, Asset.SerialNumber,
                                    Type, Reason, Product.Name, Product.Model_Code__c, CaseNumber,Status,ServAir_Created_Date__c From Case Where Id IN :prodId 
                                    Order by CreatedDate Desc Limit :loadLimit OFFSET :offset]; 
                }
                
            }
            
            if(catType == 'System'){
                if(filteredCaseList.size()>0){
                    gridCaseList = [Select Id, CreatedDate, Description, Progress__c, Service_You_Require__c, Asset.Product2.Name, Asset.Product2.Model_Code__c,
                                    ProductId, AssetId, Asset.Product2.Category__r.Category_type__c, Product.Category__r.Category_type__c, Asset.SerialNumber,
                                    Type, Reason, Product.Name, Product.Model_Code__c, CaseNumber,Status,ServAir_Created_Date__c From Case Where Id IN :sysId 
                                    Order by CreatedDate Desc Limit :loadLimit OFFSET :offset]; 
                }else{
                    gridCaseList = [Select Id, CreatedDate, Description, Progress__c, Service_You_Require__c, Asset.Product2.Name, Asset.Product2.Model_Code__c,
                                    ProductId, AssetId, Asset.Product2.Category__r.Category_type__c, Product.Category__r.Category_type__c, Asset.SerialNumber,
                                    Type, Reason, Product.Name, Product.Model_Code__c, CaseNumber,Status,ServAir_Created_Date__c From Case Where Id IN :sysId
                                    Order by CreatedDate Desc Limit :loadLimit OFFSET :offset]; 
                }
            }
            
            if(catType == 'Inquiry'){
                if(filteredCaseList.size()>0){
                    gridCaseList = [Select Id, CreatedDate, Description, Progress__c, toLabel(Service_You_Require__c), Asset.Product2.Name, Asset.Product2.Model_Code__c,
                                    ProductId, AssetId, Asset.Product2.Category__r.Category_type__c, Product.Category__r.Category_type__c, Asset.SerialNumber,
                                    Type, Reason, Product.Name, Product.Model_Code__c, CaseNumber,Status,ServAir_Created_Date__c From Case Where Id IN :inqId 
                                    Order by CreatedDate Desc Limit :loadLimit OFFSET :offset];
                }else{
                    gridCaseList = [Select Id, CreatedDate, Description, Progress__c, toLabel(Service_You_Require__c), Asset.Product2.Name, Asset.Product2.Model_Code__c,
                                    ProductId, AssetId, Asset.Product2.Category__r.Category_type__c, Product.Category__r.Category_type__c, Asset.SerialNumber,
                                    Type, Reason, Product.Name, Product.Model_Code__c, CaseNumber,Status,ServAir_Created_Date__c From Case Where Id IN :inqId 
                                    Order by CreatedDate Desc Limit :loadLimit OFFSET :offset];
                }
            }
            
            
            system.debug('gridCaseList::'+gridCaseList.size());
            
            //looping the case list to get grid data for service and inquiry
            for(Case cse: gridCaseList){
                if(cse.Service_You_Require__c != null || cse.Reason != null){
                    CaseData csedat = new CaseData();
                    
                    if(cse.ServAir_Created_Date__c != null){
                        date dte = cse.ServAir_Created_Date__c.date();
                        Datetime dt = Datetime.newInstance(dte.year(),dte.month(),dte.day());
                        String dateSub = dt.format('dd MMM YYYY'); 
                        csedat.dateSubmitted = dateSub;
                        csedat.rawDate = dt.format('YYYYMMdd'); 
                    }else{
                        date dte = cse.CreatedDate.date();
                        Datetime dt = Datetime.newInstance(dte.year(),dte.month(),dte.day());
                        String dateSub = dt.format('dd MMM YYYY');
                        csedat.dateSubmitted = dateSub;
                        csedat.rawDate = dt.format('YYYYMMdd');
                    }
                    
                    csedat.status = cse.status;
                    csedat.caseNumber = cse.CaseNumber;
                    
                    if(cse.Type == 'Request For Service'){
                        csedat.serviceType = serviceMap.get(cse.Service_You_Require__c);
                    }
                    
                    if(cse.Type == 'Submit An Inquiry' && cse.Reason != null){
                        csedat.serviceType = cse.Reason;
                    }
                    
                    if(cse.ProductId != null){
                        csedat.productName = cse.Product.Name;
                        csedat.modelCode = cse.Product.Model_Code__c;
                    }
                    
                    if(cse.AssetId != null){
                        csedat.productName = cse.Asset.Product2.Name;
                        csedat.modelCode = cse.Asset.Product2.Model_Code__c;
                        if(cse.Asset.SerialNumber != null){
                            csedat.serialNumber = 'S/N ' +cse.Asset.SerialNumber;    
                        }else{
                            csedat.serialNumber = '';
                        }
                    }
                    
                    if(cse.ProductId == null && cse.AssetId == null){
                        csedat.productName = 'Others';
                    }
                    
                    caseDataList.add(csedat);		
                }
            }
            
            totalCaseCnt = prodCaseCnt + sysCaseCnt + inqCaseCnt;
            
            servReqWrap.totalCaseCnt = totalCaseCnt;
            servReqWrap.prodCaseCnt = prodCaseCnt;
            servReqWrap.sysCaseCnt = sysCaseCnt;
            servReqWrap.inqCaseCnt = inqCaseCnt;
            servReqWrap.caseDataList = caseDataList;
            
        }
        catch(Exception e){
            system.debug('Exception Cause::'+e.getCause());
            system.debug('Exception LineNumber::'+e.getLineNumber());
            system.debug('Exception Message::'+e.getMessage());
            system.debug('Exception StackTrace::'+e.getStackTraceString());
            system.debug('Exception TypeName::'+e.getTypeName());
            YG_Utility.logError('AllServiceRequest page','Community Component Error',e.getStackTraceString(),
                                'Class:YG_AllServiceRequestController; Method: getServiceRequestGridDetails(); Line #:'+e.getLineNumber()+'; Message:'+e.getMessage(),
                                UserInfo.getUserId());
        }
        
        system.debug('servReqWrap::'+servReqWrap);
        return servReqWrap;
        
    }
    
    public class ServiceRequestGridWrapper{
        @AuraEnabled public Integer totalCaseCnt = 0;
        @AuraEnabled public Integer prodCaseCnt = 0;
        @AuraEnabled public Integer sysCaseCnt = 0;
        @AuraEnabled public Integer inqCaseCnt = 0;
        @AuraEnabled public List<CaseData> caseDataList;
    }
    
    public class CaseData{
        @AuraEnabled public String caseNumber;
        @AuraEnabled public String dateSubmitted;
        @AuraEnabled public String rawDate;
        @AuraEnabled public String status = '-';
        @AuraEnabled public String serviceType = '';
        @AuraEnabled public String productName = '';
        @AuraEnabled public String modelCode = '';
        @AuraEnabled public String serialNumber = '';
    }
    
    //This method is to get data for csv
    @AuraEnabled 
    public static ServiceRequestCSVWrapper getServiceRequestCSVDetails(){
        
        ServiceRequestCSVWrapper csvWrap = new ServiceRequestCSVWrapper();
        List<Case> csvCaseList = new List<Case>();
        List<CaseCSVData> caseCSVDataList = new List<CaseCSVData>();
        
        try{
            
            //To get account and contact Id
            Id accId = userInformation.Contact.AccountId;
            Id conId = userInformation.Contact.Id;
            system.debug('accId::'+accId);
            system.debug('conId::'+conId);
            
            //get self registered account id
            Map<String, YG_Community_Configuration__c> allValues = YG_Community_Configuration__c.getAll();
            String selfRegAccId = allValues.get('YGSelfRegisterAccountId').Text_1__c;
            
            //get csv data
            if(accId == selfRegAccId){
                csvCaseList = [Select Id, CreatedDate, Description, Progress__c, toLabel(Service_You_Require__c), Asset.Product2.Name, Asset.Product2.Model_Code__c,
                               ProductId, AssetId, Asset.Product2.Category__r.Category_type__c, Product.Category__r.Category_type__c, Asset.SerialNumber,
                               Type, Reason, Product.Name, Product.Model_Code__c, CaseNumber,Status,ServAir_Created_Date__c From Case Where account.id = :accId And contact.id = :conId And Type IN ('Request For Service','Submit An Inquiry')
                               And Status IN ('Active','Closed') Order by CreatedDate Desc]; 
            }else{
                csvCaseList = [Select Id, CreatedDate, Description, Progress__c, toLabel(Service_You_Require__c), Asset.Product2.Name, Asset.Product2.Model_Code__c,
                               ProductId, AssetId, Asset.Product2.Category__r.Category_type__c, Product.Category__r.Category_type__c, Asset.SerialNumber,
                               Type, Reason, Product.Name, Product.Model_Code__c, CaseNumber,Status,ServAir_Created_Date__c From Case Where account.id = :accId And Type IN ('Request For Service','Submit An Inquiry')
                               And Status IN ('Active','Closed') Order by CreatedDate Desc];  
            }
            
            
            //looping the case list to get grid data for service and inquiry
            for(Case cse: csvCaseList){
                if(cse.Service_You_Require__c != null || cse.Reason != null){
                    CaseCSVData csedat = new CaseCSVData();
                    
                    if(cse.ServAir_Created_Date__c != null){
                        date dte = cse.ServAir_Created_Date__c.date();
                        Datetime dt = Datetime.newInstance(dte.year(),dte.month(),dte.day());
                        String dateSub = dt.format('dd MMM YYYY'); 
                        csedat.dateSubmitted = dateSub;
                        
                    }else{
                        date dte = cse.CreatedDate.date();
                        Datetime dt = Datetime.newInstance(dte.year(),dte.month(),dte.day());
                        String dateSub = dt.format('dd MMM YYYY');
                        csedat.dateSubmitted = dateSub;
                        
                    }
                    csedat.status = cse.status;
                    csedat.caseNumber = cse.CaseNumber;
                    
                    if(cse.Type == 'Request For Service' && ((cse.Product.Category__r.Category_type__c == 'Product' || cse.Asset.Product2.Category__r.Category_type__c == 'Product') || (cse.AssetId == null && cse.ProductId == null)) && cse.Service_You_Require__c != null){
                        csedat.serviceType = cse.Service_You_Require__c;
                    }
                    if(cse.Type == 'Request For Service' && cse.Service_You_Require__c != null && (cse.Product.Category__r.Category_type__c == 'System' || cse.Asset.Product2.Category__r.Category_type__c == 'System')){
                        csedat.serviceType = cse.Service_You_Require__c;
                    }
                    if(cse.Type == 'Submit An Inquiry' && cse.Reason != null){
                        csedat.serviceType = cse.Reason;
                    }
                    
                    if(cse.ProductId != null){
                        csedat.productName = cse.Product.Name;
                        csedat.modelCode = cse.Product.Model_Code__c;
                    }
                    
                    if(cse.AssetId != null){
                        csedat.productName = cse.Asset.Product2.Name;
                        csedat.modelCode = cse.Asset.Product2.Model_Code__c;
                        csedat.serialNumber = ',S/N ' + cse.Asset.SerialNumber;
                    }
                    
                    if(cse.ProductId == null && cse.AssetId == null){
                        csedat.productName = 'Others';
                    }
                    
                    caseCSVDataList.add(csedat);		
                }
            }
            
            if(caseCSVDataList.size()>0){
                csvWrap.caseCSVDataList = caseCSVDataList;
            }
            
        }
        catch(Exception e){
            system.debug('Exception Cause::'+e.getCause());
            system.debug('Exception LineNumber::'+e.getLineNumber());
            system.debug('Exception Message::'+e.getMessage());
            system.debug('Exception StackTrace::'+e.getStackTraceString());
            system.debug('Exception TypeName::'+e.getTypeName());
            YG_Utility.logError('AllServiceRequest page','Community Component Error',e.getStackTraceString(),
                                'Class:YG_AllServiceRequestController; Method: ServiceRequestCSVWrapper(); Line #:'+e.getLineNumber()+'; Message:'+e.getMessage(),
                                UserInfo.getUserId());
        }
        system.debug('csvWrap::'+csvWrap);
        return csvWrap;
    }
    
    public class ServiceRequestCSVWrapper{
        @AuraEnabled public List<CaseCSVData> caseCSVDataList;
    }
    
    public class CaseCSVData{
        @AuraEnabled public String caseNumber;
        @AuraEnabled public String dateSubmitted;
        @AuraEnabled public String status = '-';
        @AuraEnabled public String serviceType = '';
        @AuraEnabled public String productName = '';
        @AuraEnabled public String modelCode = '';
        @AuraEnabled public String serialNumber = '';
    }
    
    //This method is used to get the chart details in all service request page
    @AuraEnabled  
    public static ServiceRequestChartWrapper getServiceRequestChartDetails(string caseType,string caseStatus){
        
        system.debug('caseType::'+caseType);
        system.debug('caseStatus::'+caseStatus);
        
        ServiceRequestChartWrapper chartWrap = new ServiceRequestChartWrapper();
        List<ChartData> prodChartDataList = new List<ChartData>(); //List to store product chart data
        List<ChartData> sysChartDataList = new List<ChartData>(); //List to store system chart data
        List<ChartData> inqChartDataList = new List<ChartData>(); //List to store inquiry chart data
        List<AggregateResult> caseTypeProdList = new List<AggregateResult>();
        List<AggregateResult> caseTypeSystemList = new List<AggregateResult>();
        List<AggregateResult> caseTypeInqList = new List<AggregateResult>();
        List<Case> allCaseList = new List<Case>();
        List<Id> allCaseId = new List<Id>();
        List<Id> prodCaseId = new List<Id>();
        List<Id> sysCaseId = new List<Id>();
        List<Id> inqCaseId = new List<Id>();
        List<String> prodService=new List<String>{'050','030','040','080','100','900'};
            List<String> sysService=new List<String>{'010','020','040','060','070','100','900'};
                
                //Defining array for chart color 
                String [] arrayOfColorcode = new List<String>();
        Integer i = 0,j = 0,k = 0;
        arrayOfColorcode.add('#FFEE00');
        arrayOfColorcode.add('#F1BC1A');
        arrayOfColorcode.add('#CE4E0E');
        arrayOfColorcode.add('#0458AA');
        arrayOfColorcode.add('#00316C');
        arrayOfColorcode.add('#00694C');
        arrayOfColorcode.add('#00A04C');
        
        try{
            
            //Get the user lang code
            String langCode = YG_CommonUtils.getLanguageCode(userInformation.LanguageLocaleKey); 
            system.debug('langCode::'+langCode);            
            
            //To get account and contact Id
            Id accId = userInformation.Contact.AccountId;
            Id conId = userInformation.Contact.Id;
            system.debug('accId::'+accId);
            system.debug('conId::'+conId);
            
            //get self registered account id
            Map<String, YG_Community_Configuration__c> allValues = YG_Community_Configuration__c.getAll();
            String selfRegAccId = allValues.get('YGSelfRegisterAccountId').Text_1__c;
            
            if(accId == selfRegAccId){
                allCaseList = [Select Id, CreatedDate, Description, Progress__c, Service_You_Require__c, Asset.Product2.Name, Asset.Product2.Model_Code__c,
                               ProductId, AssetId, Asset.Product2.Category__r.Category_type__c, Product.Category__r.Category_type__c, Asset.SerialNumber,
                               Type, Reason, Product.Name, Product.Model_Code__c, CaseNumber,Status,ServAir_Created_Date__c From Case Where account.id = :accId And Contact.id = :conId And 
                               Type IN ('Request For Service','Submit An Inquiry')];
            }else{
                allCaseList = [Select Id, CreatedDate, Description, Progress__c, Service_You_Require__c, Asset.Product2.Name, Asset.Product2.Model_Code__c,
                               ProductId, AssetId, Asset.Product2.Category__r.Category_type__c, Product.Category__r.Category_type__c, Asset.SerialNumber,
                               Type, Reason, Product.Name, Product.Model_Code__c, CaseNumber,Status,ServAir_Created_Date__c From Case Where account.id = :accId And 
                               Type IN ('Request For Service','Submit An Inquiry')];
            }
            
            //looping the case list to get case Id
            for(Case cse: allCaseList){
                if(cse.Type == 'Request For Service' && ((cse.Product.Category__r.Category_type__c == 'Product' || cse.Asset.Product2.Category__r.Category_type__c == 'Product') || (cse.AssetId == null && cse.ProductId == null)) && cse.Service_You_Require__c != null && prodService.contains(cse.Service_You_Require__c)){
                    prodCaseId.add(cse.Id);
                    allCaseId.add(cse.Id);
                }
                if(!allCaseId.contains(cse.Id) && !prodCaseId.contains(cse.Id) && cse.Type == 'Request For Service' && cse.Service_You_Require__c != null && ((cse.Product.Category__r.Category_type__c == 'System' || cse.Asset.Product2.Category__r.Category_type__c == 'System' ) || (cse.AssetId == null && cse.ProductId == null))  && sysService.contains(cse.Service_You_Require__c)){
                    sysCaseId.add(cse.Id);
                    allCaseId.add(cse.Id);
                }
                if(cse.Type == 'Submit An Inquiry' && cse.Reason != null){
                    inqCaseId.add(cse.Id);
                    allCaseId.add(cse.Id);
                }
            }
            
            system.debug('prodCaseId::'+prodCaseId.size());
            system.debug('sysCaseId::'+sysCaseId.size());
            system.debug('inqCaseId::'+inqCaseId.size());
            
            if(caseType == ''){
                if(caseStatus == ''){
                    caseTypeProdList = [Select Count(id) cnt, toLabel(Service_You_Require__c) From Case where 
                                        Id IN :prodCaseId Group By Service_You_Require__c];
                    
                    caseTypeSystemList = [Select Count(id) cnt, toLabel(Service_You_Require__c) From Case where 
                                          Id IN :sysCaseId Group By Service_You_Require__c];
                    
                    caseTypeInqList = [Select Count(id) cnt, Reason From Case where Id IN :inqCaseId 
                                       Group By Reason];
                }else{
                    caseTypeProdList = [Select Count(id) cnt, toLabel(Service_You_Require__c) From Case where 
                                        Status = :caseStatus AND Id IN :prodCaseId Group By Service_You_Require__c];
                    
                    caseTypeSystemList = [Select Count(id) cnt, toLabel(Service_You_Require__c) From Case where 
                                          Status = :caseStatus AND Id IN :sysCaseId Group By Service_You_Require__c];
                    
                    caseTypeInqList = [Select Count(id) cnt, Reason From Case where Status = :caseStatus AND Id IN :inqCaseId 
                                       Group By Reason]; 
                }
                
            }
            
            if(caseType == 'Product'){
                if(caseStatus == ''){
                    caseTypeProdList = [Select Count(id) cnt, toLabel(Service_You_Require__c) From Case where 
                                        Id IN :prodCaseId Group By Service_You_Require__c];
                }else{
                    caseTypeProdList = [Select Count(id) cnt, toLabel(Service_You_Require__c) From Case where 
                                        Status = :caseStatus AND Id IN :prodCaseId Group By Service_You_Require__c]; 
                }
            }
            
            if(caseType == 'System'){
                if(caseStatus == ''){
                    caseTypeSystemList = [Select Count(id) cnt, toLabel(Service_You_Require__c) From Case where 
                                          Id IN :sysCaseId Group By Service_You_Require__c];
                }else{
                    caseTypeSystemList = [Select Count(id) cnt, toLabel(Service_You_Require__c) From Case where 
                                          Status = :caseStatus AND Id IN :sysCaseId Group By Service_You_Require__c];
                }
            }
            
            if(caseType == 'Inquiry'){
                if(caseStatus == ''){
                    caseTypeInqList = [Select Count(id) cnt, Reason From Case where Id IN :inqCaseId 
                                       Group By Reason]; 
                }else{
                    caseTypeInqList = [Select Count(id) cnt, Reason From Case where Status = :caseStatus AND Id IN :inqCaseId 
                                       Group By Reason];
                }
            }
            
            system.debug('caseTypeProdList::'+caseTypeProdList);
            system.debug('caseTypeSystemList::'+caseTypeSystemList);
            system.debug('caseTypeInqList::'+caseTypeInqList);
            
            for(AggregateResult res: caseTypeProdList){
                ChartData prodChart = new ChartData();
                
                if((String)res.get('Service_You_Require__c') == '050'){
                    prodChart.value = (Integer)res.get('cnt');
                    prodChart.label = Label.YG_Calibration +': '+(Integer)res.get('cnt');
                    prodChart.color = arrayOfColorcode[i];
                }
                if((String)res.get('Service_You_Require__c') == '030'){
                    prodChart.value = (Integer)res.get('cnt');
                    prodChart.label = Label.YG_Repair +': '+(Integer)res.get('cnt');
                    prodChart.color = arrayOfColorcode[i];
                }
                if((String)res.get('Service_You_Require__c') == '040'){
                    prodChart.value = (Integer)res.get('cnt');
                    prodChart.label = Label.YG_Training +': '+(Integer)res.get('cnt');
                    prodChart.color = arrayOfColorcode[i];
                }
                
                if((String)res.get('Service_You_Require__c') == '080'){
                    prodChart.value = (Integer)res.get('cnt');
                    prodChart.label = Label.YG_Diagnosis +': '+(Integer)res.get('cnt');
                    prodChart.color = arrayOfColorcode[i];
                }
                if((String)res.get('Service_You_Require__c') == '100'){
                    prodChart.value = (Integer)res.get('cnt');
                    prodChart.label = Label.YG_Mods +': '+(Integer)res.get('cnt');
                    prodChart.color = arrayOfColorcode[i];
                }
                if((String)res.get('Service_You_Require__c') == '900'){
                    prodChart.value = (Integer)res.get('cnt');
                    prodChart.label = Label.YG_Others +': '+(Integer)res.get('cnt');
                    prodChart.color = arrayOfColorcode[i];
                }
                
                i++;
                if(prodChart != null){
                    prodChartDataList.add(prodChart);
                }
            }
            
            for(AggregateResult res: caseTypeSystemList){
                ChartData sysChart = new ChartData();
                system.debug('res::'+res);               
                if((String)res.get('Service_You_Require__c') == '010'){
                    sysChart.value = (Integer)res.get('cnt');
                    sysChart.label = Label.YG_Maintenance +': '+(Integer)res.get('cnt');
                    sysChart.color = arrayOfColorcode[j];
                }
                if((String)res.get('Service_You_Require__c') == '020'){
                    sysChart.value = (Integer)res.get('cnt');
                    sysChart.label = Label.YG_On_Call +': '+(Integer)res.get('cnt');
                    sysChart.color = arrayOfColorcode[j];
                }
                if((String)res.get('Service_You_Require__c') == '040'){
                    sysChart.value = (Integer)res.get('cnt');
                    sysChart.label = Label.YG_Training +': '+(Integer)res.get('cnt');
                    sysChart.color = arrayOfColorcode[j];
                }
                if((String)res.get('Service_You_Require__c') == '060'){
                    sysChart.value = (Integer)res.get('cnt');
                    sysChart.label = Label.YG_Sys_Upgrade +': '+(Integer)res.get('cnt');
                    sysChart.color = arrayOfColorcode[j];
                }
                if((String)res.get('Service_You_Require__c') == '070'){
                    sysChart.value = (Integer)res.get('cnt');
                    sysChart.label = Label.YG_Security +': '+(Integer)res.get('cnt');
                    sysChart.color = arrayOfColorcode[j];
                }
                if((String)res.get('Service_You_Require__c') == '100'){
                    sysChart.value = (Integer)res.get('cnt');
                    sysChart.label = Label.YG_Mods +': '+(Integer)res.get('cnt');
                    sysChart.color = arrayOfColorcode[j];
                }
                if((String)res.get('Service_You_Require__c') == '900'){
                    sysChart.value = (Integer)res.get('cnt');
                    sysChart.label = Label.YG_Others +': '+(Integer)res.get('cnt');
                    sysChart.color = arrayOfColorcode[j];
                }
                
                j++;
                
                if(sysChart != null){
                    sysChartDataList.add(sysChart);
                }
            }
            
            for(AggregateResult res: caseTypeInqList){
                ChartData inqChart = new ChartData();
                
                if((String)res.get('Reason') == 'Sales and Quote'){
                    inqChart.value = (Integer)res.get('cnt');
                    inqChart.label = Label.YG_Sales_Quote +': '+(Integer)res.get('cnt');
                    inqChart.color = arrayOfColorcode[k];
                }
                if((String)res.get('Reason') == 'Technical Support'){
                    inqChart.value = (Integer)res.get('cnt');
                    inqChart.label = Label.YG_Technical_Support +': '+(Integer)res.get('cnt');
                    inqChart.color = arrayOfColorcode[k];
                }
                if((String)res.get('Reason') == 'Others'){
                    inqChart.value = (Integer)res.get('cnt');
                    inqChart.label = Label.YG_Others +': '+(Integer)res.get('cnt');
                    inqChart.color = arrayOfColorcode[k];
                }
                
                k++;
                if(inqChart != null){
                    inqChartDataList.add(inqChart);
                }
            }
            
            chartWrap.prodChartDataList = prodChartDataList;
            chartWrap.sysChartDataList = sysChartDataList;
            chartWrap.inqChartDataList = inqChartDataList;
            
        }
        catch(Exception e){
            system.debug('Exception Cause::'+e.getCause());
            system.debug('Exception LineNumber::'+e.getLineNumber());
            system.debug('Exception Message::'+e.getMessage());
            system.debug('Exception StackTrace::'+e.getStackTraceString());
            system.debug('Exception TypeName::'+e.getTypeName());
            YG_Utility.logError('AllServiceRequest page','Community Component Error',e.getStackTraceString(),
                                'Class:YG_AllServiceRequestController; Method: getServiceRequestChartDetails(); Line #:'+e.getLineNumber()+'; Message:'+e.getMessage(),
                                UserInfo.getUserId());
        }
        
        system.debug('chartWrap::'+chartWrap);
        return chartWrap;
        
    }
    
    public class ServiceRequestChartWrapper{
        @AuraEnabled public List<ChartData> prodChartDataList;
        @AuraEnabled public List<ChartData> sysChartDataList;
        @AuraEnabled public List<ChartData> inqChartDataList;
    }
    
    public class ChartData{
        @AuraEnabled public Integer value; //serviceTypeCount
        @AuraEnabled public String label; //serviceType
        @AuraEnabled public String color; //colorcode
    }
    
    //This method is used to get the data for the service request details popup window
    @AuraEnabled
    public static modelServiceInfo  getServiceReqInfo(String caseNo){
        
        System.debug('caseNo::'+caseNo);
        modelServiceInfo modelWindowInfo=new modelServiceInfo();
        List<Scope_of_Product__c> sopList = new List<Scope_of_Product__c>();
        Case caseDetails=new Case();
        Map<String, Id> assetMap=new Map<String, Id>();
        
        Try{
            
            if(caseNo != '' && caseNo != null){
                caseDetails = [Select Id, Type, CaseNumber, Reason, CreatedDate, ProductId, Product.Name, Product.Model_Code__c, Product.Category__r.Category_type__c,AssetId, Asset.SerialNumber,Deliverables_ID__c,
                               Asset.Product2.Name, Asset.Product2.Model_Code__c, ServAir_Incident_Number__c, Assigned_To_Name__c, Asset.Product2.Category__r.Category_type__c, Contact.Name, Description, Owner.Name, CreatedBy.Name,ServAir_Created_Date__c,Asset.Id,
                               toLabel(Service_you_require__c) From case Where CaseNumber=: caseNo Limit 1];
                
                system.debug('caseDetails::'+caseDetails);
                if(caseDetails.AssetId == null){
                    case caseAssetUpt=new case();
                    if(caseDetails.Deliverables_ID__c != null){
                        List<Asset> ass = [Select Id, Name from asset where Name =: caseDetails.Deliverables_ID__c Limit 1];
                        if(ass.size() > 0){
                            caseAssetUpt.AssetId = ass[0].Id;
                            caseAssetUpt.Id = caseDetails.Id;
                            update caseAssetUpt;
                            System.debug('Updated');
                        }
                    }
                }
                
                if(caseDetails.ServAir_Incident_Number__c != null){
                    modelWindowInfo.caseNum = caseDetails.ServAir_Incident_Number__c;
                }else{
                    modelWindowInfo.caseNum = caseDetails.CaseNumber;
                }
                modelWindowInfo.description = caseDetails.Description;
                modelWindowInfo.caseCreatedBy = caseDetails.CreatedBy.Name;
                if(caseDetails.Assigned_To_Name__c != null){
                    modelWindowInfo.caseAssignedTo = caseDetails.Assigned_To_Name__c;
                }else{
                    modelWindowInfo.caseAssignedTo = '-';
                }
                
                if(caseDetails.Type == 'Request For Service'){
                    modelWindowInfo.serviceType = caseDetails.Service_you_require__c;
                }else if(caseDetails.Type == 'Submit An Inquiry'){
                    modelWindowInfo.serviceType = caseDetails.Reason;
                }else{
                    modelWindowInfo.serviceType = '-';
                }
                
                if(caseDetails.ServAir_Created_Date__c != null){
                    date cddte = caseDetails.ServAir_Created_Date__c.date();
                    Datetime cddt = Datetime.newInstance(cddte.year(),cddte.month(),cddte.day());
                    String cddateVal = cddt.format('dd MMM YYYY'); 
                    modelWindowInfo.submittedDate = cddateVal;
                }else{
                    date cddte = caseDetails.CreatedDate.Date();
                    Datetime cddt = Datetime.newInstance(cddte.year(),cddte.month(),cddte.day());
                    String cddateVal = cddt.format('dd MMM YYYY'); 
                    modelWindowInfo.submittedDate = cddateVal;
                }
                
                
                if(caseDetails.AssetId != null){
                    
                    sopList = [Select Asset__c, Service_Contract__c, Service_Contract__r.Name, Service_Contract__r.Contract_No__c, Service_Contract__r.StartDate,
                               Service_Contract__r.EndDate, Service_Contract__r.Contract_Type__c From Scope_of_Product__c Where Asset__c = :caseDetails.AssetId
                               Order by Service_Contract__r.EndDate Desc];
                    
                    if(sopList.size()>0){
                        for(Scope_of_Product__c sop: sopList){
                            if(sop.Service_Contract__r.EndDate < Date.today()){
                                date dte = sop.Service_Contract__r.EndDate;
                                Datetime dt = Datetime.newInstance(dte.year(),dte.month(),dte.day());
                                String dateVal = dt.format('dd MMM YYYY'); 
                                modelWindowInfo.contractType.add(sop.Service_Contract__r.Contract_Type__c+', '+Label.YG_Ended+dateVal);
                            }else{
                                modelWindowInfo.contractType.add(sop.Service_Contract__r.Contract_Type__c);
                            }
                        }
                    }
                    
                    /*
if(ent != null){
if(ent.ServiceContract.EndDate < Date.today()){
date dte = ent.ServiceContract.EndDate;
Datetime dt = Datetime.newInstance(dte.year(),dte.month(),dte.day());
String dateVal = dt.format('dd MMM YYYY'); 
modelWindowInfo.contractType = ent.ServiceContract.Contract_Type__c+', '+Label.YG_Ended+dateVal;
}else{
modelWindowInfo.contractType = ent.ServiceContract.Contract_Type__c;
}
}else{
modelWindowInfo.contractType = '-';
}*/
                    
                    if(caseDetails.Asset.SerialNumber != null){
                        modelWindowInfo.serialNumber = caseDetails.Asset.SerialNumber;
                    }else{
                        modelWindowInfo.serialNumber = '-';
                    }
                    modelWindowInfo.productName = caseDetails.Asset.Product2.Name;
                    if(caseDetails.Product.Category__r.Category_type__c == 'Product'){
                        modelWindowInfo.modelCode = caseDetails.Asset.Product2.Model_Code__c;
                    }
                }else{
                    modelWindowInfo.serialNumber = '-';
                }
                
                if(caseDetails.ProductId != null){
                    modelWindowInfo.serialNumber = '-';
                    modelWindowInfo.productName = caseDetails.Product.Name;
                    modelWindowInfo.contractType = new List<String>();
                    if(caseDetails.Product.Category__r.Category_type__c == 'Product'){
                        modelWindowInfo.modelCode = caseDetails.Product.Model_Code__c;
                    }
                }
                
                if(caseDetails.AssetId == null && caseDetails.ProductId == null){
                    modelWindowInfo.serialNumber = '-';
                    modelWindowInfo.contractType = new List<String>();
                    modelWindowInfo.modelCode = '';
                    modelWindowInfo.productName = 'Others';
                }
                
            }
            
            
            System.debug('modelWindowInfo::'+modelWindowInfo);
            
        }catch(Exception e){
            system.debug('Exception Cause::'+e.getCause());
            system.debug('Exception LineNumber::'+e.getLineNumber());
            system.debug('Exception Message::'+e.getMessage());
            system.debug('Exception StackTrace::'+e.getStackTraceString());
            system.debug('Exception TypeName::'+e.getTypeName()); 
            YG_Utility.logError('AllServiceRequestPage','Community Component Error',e.getStackTraceString(),
                                'Class:YG_AllServiceRequestController; Method: getServiceReqInfo(); Line #:'+e.getLineNumber()+'; Message:'+e.getMessage(),
                                UserInfo.getUserId()); 
        }
        return modelWindowInfo;
    }
    
    public class modelServiceInfo{
        @AuraEnabled public String caseNum;
        @AuraEnabled public String submittedDate;
        @AuraEnabled public String productName;
        @AuraEnabled public String modelCode = '';
        @AuraEnabled public String serialNumber = '-';
        @AuraEnabled public List<String> contractType = new List<String>();
        @AuraEnabled public String caseCreatedBy;
        @AuraEnabled public String description;
        @AuraEnabled public String caseAssignedTo;
        @AuraEnabled public String serviceType;
    }
    
    //This method is used to update the case description 
    @AuraEnabled
    public static String toUpdateCaseDescription(String caseNo, String notes){
        
        System.debug('caseNo:::'+caseNo);
        System.debug('notes:::'+notes);
        
        Case caseList;
        String result;
        
        Try{
            
            caseList = [Select Id, CaseNumber, Description from case Where CaseNumber =: caseNo Limit 1];
            caseList.Description = notes;
            
            update caseList;
            result = caseList.Description;
            
        }Catch(Exception e){
            system.debug('Exception Cause::'+e.getCause());
            system.debug('Exception LineNumber::'+e.getLineNumber());
            system.debug('Exception Message::'+e.getMessage());
            system.debug('Exception StackTrace::'+e.getStackTraceString());
            system.debug('Exception TypeName::'+e.getTypeName()); 
            YG_Utility.logError('AllServiceRequestPage','Community Component Error',e.getStackTraceString(),
                                'Class:YG_AllServiceRequestController; Method: toUpdateCaseDescription(); Line #:'+e.getLineNumber()+'; Message:'+e.getMessage(),
                                UserInfo.getUserId());  
        }
        
        System.debug('Updated Desciption:: '+result); 
        return result;
    }
    
    //This method is used to update the case History 
    @AuraEnabled
    public static CaseHistoryWrapper getCaseHistory(String caseNo){
        
        System.debug('caseNo:::'+caseNo);
        Case cse = new Case();
        CaseHistoryWrapper caseWrap=new CaseHistoryWrapper();
        List<HistoryWrap> hisList = new List<HistoryWrap>();
        
        Try{
            cse = [Select Id, CaseNumber, Description, CreatedDate, Progress__c from case Where CaseNumber =: caseNo Limit 1];
            Id casId = cse.Id;
            System.debug('cse::'+cse);
            
            List<CaseHistory> caseOldhist = [select NewValue, OldValue, CreatedDate from CaseHistory where CaseId=: casId and Field='Progress__c' ORDER BY CreatedDate Asc Limit 1];
            system.debug('caseOldhist::'+caseOldhist);
            HistoryWrap hisOldData = new HistoryWrap();
            Datetime dte;
            if(caseOldhist.size() > 0){
                if(caseOldhist[0].OldValue != null){
                    hisOldData.description = caseOldhist[0].OldValue.toString();
                    dte = Datetime.newInstance(caseOldhist[0].CreatedDate.year(),caseOldhist[0].CreatedDate.month(),caseOldhist[0].CreatedDate.day());
                    hisOldData.hisDate = dte.format('dd MMMM YYYY'); 
                }
            }else{
                hisOldData.description = cse.Progress__c;
                dte = Datetime.newInstance(cse.CreatedDate.year(),cse.CreatedDate.month(),cse.CreatedDate.day());
                hisOldData.hisDate = dte.format('dd MMMM YYYY'); 
            }
            
            
            List<CaseHistory> casehist = [select NewValue, OldValue, CreatedDate from CaseHistory where CaseId=: casId and Field='Progress__c' ORDER BY CreatedDate Desc];
            System.debug('casehist::'+casehist);
            
            for(CaseHistory cs: casehist){
                HistoryWrap hisData = new HistoryWrap();
                hisData.description = cs.NewValue.toString();
                Datetime dt = Datetime.newInstance(cs.CreatedDate.year(),cs.CreatedDate.month(),cs.CreatedDate.day());
                hisData.hisDate = dt.format('dd MMMM YYYY');    
                hisList.add(hisData); 
            }
            
            system.debug('hisOldData::'+hisOldData);
            if(hisOldData.description != null){
                hisList.add(hisOldData);
            }
            
            
            System.debug('hisList::'+hisList);
            caseWrap.hisWrap = hisList;
        }
        Catch(Exception e){
            system.debug('Exception Cause::'+e.getCause());
            system.debug('Exception LineNumber::'+e.getLineNumber());
            system.debug('Exception Message::'+e.getMessage());
            system.debug('Exception StackTrace::'+e.getStackTraceString());
            system.debug('Exception TypeName::'+e.getTypeName()); 
            YG_Utility.logError('AllServiceRequestPage','Community Component Error',e.getStackTraceString(),
                                'Class:YG_AllServiceRequestController; Method: getCaseHistory(); Line #:'+e.getLineNumber()+'; Message:'+e.getMessage(),
                                UserInfo.getUserId());  
        }
        
        return caseWrap;
    }
    
    public class CaseHistoryWrapper{
        @AuraEnabled public List<HistoryWrap> hisWrap;
    }
    
    public class HistoryWrap{
        @AuraEnabled public string description;
        @AuraEnabled public string hisDate;
    }
    
}