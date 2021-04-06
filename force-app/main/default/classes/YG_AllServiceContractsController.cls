/********************************************************************************************************
* (C) Copyright 2020 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Vinod A
* @version 1.0
* @created 09/10/2020
* @description 
* This class used to get all the service contracts.
*
* @test class name - YG_AllServiceContractsControllerTest
*
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  
*/
public class YG_AllServiceContractsController {
    
    public static User userInformation =  YG_Utility.getLoggedInUserInfo(UserInfo.getUserId());
    //public static User userInformation =  YG_Utility.getLoggedInUserInfo('005p0000004Hvs7AAC');	//anand
    //public static User userInformation =  YG_Utility.getLoggedInUserInfo('005p0000004HwDGAA0');
    
    @AuraEnabled
    //public static ServiceContractWrapper getServiceContracts(String plantCode,List<Id> servContractIdList, String filterdByStatus, String filteredByIndustry, Integer loadLimit, Integer offset){
    public static ServiceContractWrapper getAllServiceContracts(String plantCode, String filterdByStatus, String filteredByIndustry, List<Id> servContractFilterIdList, Integer loadLimit, Integer offset){
        System.debug('plantCode::'+plantCode);
        System.debug('filterdByStatus::'+filterdByStatus);
        System.debug('filteredByIndustry::'+filteredByIndustry);
        System.debug('servContractFilterIdList::'+servContractFilterIdList);
        ServiceContractWrapper servContract=new ServiceContractWrapper();	//Main Wrapper
        List<ServiceContracts> serviceContractListWrap=new List<ServiceContracts>();	//Sub Wrapper List
        //String plantCode = '300000142';
        //List<Id> servContractIdList=new List<Id>();     
        List<ServiceContract> servContractList=new List<ServiceContract>(); //List to store the service contract records
        List<ServiceContract> servContractList1=new List<ServiceContract>(); //to store total records of an industry
        List<ServiceContract> serviceContractTotalCnt=new List<ServiceContract>(); //List to get the total cnt
        List<Id> servContId=new List<Id>();
        List<Id> contractIdList=new List<Id>(); //To get the list of contract ids associated with plant and cust assets
        List<Id> selectedServiceContractIdList = new List<Id>(); //To get the service contract ids expiry less than 6 months
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
            
            //This logic used to get the contract without any sop system assets and this contract relate to the account
            List<Id> servContWithoutSop = YG_AllServiceContractsController.getServContWithoutSOP(accId);
            System.debug('servContWithoutSop::'+servContWithoutSop);
            for(Id servId : servContWithoutSop){
                if(!contractIdList.contains(servId)){
                    contractIdList.add(servId);
                }
            }
            System.debug('final servCont Ids::'+contractIdList);
            //To get the total service contract count
            serviceContractTotalCnt = [Select Id, Contract_No__c, Name, EndDate, Description, YG_Sales_Manager_Name__c, YG_Sales_Manager_Email__c, YG_Sales_Manager_contact_no__c/*,
                                        (Select Id, Asset.Name, Asset.Product2.Name  From Entitlements)*/
                                        From ServiceContract Where Id IN: contractIdList];
            System.debug('serviceContractTotalCnt::'+serviceContractTotalCnt);
            System.debug('serviceContractTotalCnt.size()::'+serviceContractTotalCnt.size());
            if(serviceContractTotalCnt.size() > 0){
                servContract.totalContractCnt = serviceContractTotalCnt.size();
            }
            System.debug('servContract.totalContractCnt::'+servContract.totalContractCnt);
            
            //To get the Expiry less than 6 months service contract ids
            Id selectedServiceContractId ; 
           	for(ServiceContract sc:serviceContractTotalCnt){
                String notify = YG_HelperClass.getServiceContractExpiry(sc.EndDate);
                if(notify != null){
                    selectedServiceContractId = sc.id;
                    selectedServiceContractIdList.add(selectedServiceContractId);
                }
                 system.debug('selectedServiceContractIdList::'+selectedServiceContractIdList);
                
            }
            
            
            
            //To get the list of service contract id from the selected plant
            if(servContractFilterIdList.size() > 0 && !servContractFilterIdList.isEmpty()){
                System.debug('servContractFilterIdList ::');
                if(servContractFilterIdList.size() > 0 && filterdByStatus != '' && filterdByStatus != 'Expires' && filteredByIndustry == null && filterdByStatus != null){
                    System.debug('servContractFilterIdList  and filterdByStatus only::');
                    servContractList = [Select Id, Contract_No__c, Name, Description, YG_Sales_Manager_Name__c, YG_Sales_Manager_Email__c, YG_Sales_Manager_contact_no__c,
                                    StartDate, EndDate, YG_Sales_Manager_profile_photo__c, Owner.Name, Owner.Email, Owner.Phone,Contract_Type__c, Status, Contract_categories__c,
                                    (Select Id, Asset__r.Name, Asset__r.Product2.Name  From Scope_of_Product__r)
                                    From ServiceContract Where Id IN: servContractFilterIdList And Status =:filterdByStatus];
                }else if(servContractFilterIdList.size() > 0 && filterdByStatus == null  && filteredByIndustry != '' && filteredByIndustry != null ){
                    System.debug('servContractFilterIdList and filteredByIndustry only::');
                    servContractList = [Select Id, Contract_No__c, Name, Description, YG_Sales_Manager_Name__c, YG_Sales_Manager_Email__c, YG_Sales_Manager_contact_no__c,
                                        StartDate, EndDate, YG_Sales_Manager_profile_photo__c, Owner.Name, Owner.Email, Owner.Phone,Contract_Type__c, Status, Contract_categories__c,
                                        (Select Id, Asset__r.Name, Asset__r.Product2.Name  From Scope_of_Product__r)
                                        From ServiceContract Where Id IN: servContractFilterIdList And Contract_categories__c =: filteredByIndustry];
                }else if(servContractFilterIdList.size() > 0 && filterdByStatus != null && filterdByStatus != 'Expires' && filteredByIndustry != null ){
                    System.debug('servContractFilterIdList, filterdByStatus and filteredByIndustry::'); 
                    servContractList = [Select Id, Contract_No__c, Name, Description, YG_Sales_Manager_Name__c, YG_Sales_Manager_Email__c, YG_Sales_Manager_contact_no__c,
                                        StartDate, EndDate, YG_Sales_Manager_profile_photo__c, Owner.Name, Owner.Email, Owner.Phone,Contract_Type__c, Status, Contract_categories__c,
                                        (Select Id, Asset__r.Name, Asset__r.Product2.Name  From Scope_of_Product__r)
                                        From ServiceContract Where Id IN: servContractFilterIdList And Status =:filterdByStatus And Contract_categories__c =: filteredByIndustry ];
                    
                    
                }else if(servContractFilterIdList.size() > 0 && filterdByStatus == 'Expires' && filteredByIndustry == null){
                    System.debug('servContractFilterIdList and Filter by Status Expires less than 6 months::');
                    List<Id> selectFilderIdExpiresStatus=new List<Id>();
                    for(Id expiryId : servContractFilterIdList){
                        if(selectedServiceContractIdList.contains(expiryId)){
                            selectFilderIdExpiresStatus.add(expiryId);
                        }
                    }
                    servContractList = [Select Id, Contract_No__c, Name, Description, YG_Sales_Manager_Name__c, YG_Sales_Manager_Email__c, YG_Sales_Manager_contact_no__c,
                                        StartDate, EndDate, YG_Sales_Manager_profile_photo__c, Owner.Name, Owner.Email, Owner.Phone,Contract_Type__c, Status, Contract_categories__c,
                                        (Select Id, Asset__r.Name, Asset__r.Product2.Name  From Scope_of_Product__r)
                                        From ServiceContract Where Id IN:selectFilderIdExpiresStatus ];
                }else if(servContractFilterIdList.size() > 0 && filterdByStatus == 'Expires' && filteredByIndustry != null){
                    List<Id> selectFilderIdExpiresStatus=new List<Id>();
                    for(Id expiryId : servContractFilterIdList){
                        if(selectedServiceContractIdList.contains(expiryId)){
                            selectFilderIdExpiresStatus.add(expiryId);
                        }
                    }
                    System.debug('Filter by Status Expires less than 6month status and filteredByIndustry::');
                    servContractList = [Select Id, Contract_No__c, Name, Description, YG_Sales_Manager_Name__c, YG_Sales_Manager_Email__c, YG_Sales_Manager_contact_no__c,
                                        StartDate, EndDate, YG_Sales_Manager_profile_photo__c, Owner.Name, Owner.Email, Owner.Phone,Contract_Type__c, Status, Contract_categories__c,
                                        (Select Id, Asset__r.Name, Asset__r.Product2.Name  From Scope_of_Product__r)
                                        From ServiceContract Where Id IN: selectFilderIdExpiresStatus And Contract_categories__c =: filteredByIndustry];
                }else{
                    System.debug('servContractFilterIdList only');
                servContractList = [Select Id, Contract_No__c, Name, Description, YG_Sales_Manager_Name__c, YG_Sales_Manager_Email__c, YG_Sales_Manager_contact_no__c,
                                    StartDate, EndDate, YG_Sales_Manager_profile_photo__c, Owner.Name, Owner.Email, Owner.Phone,Contract_Type__c, Status, Contract_categories__c,
                                    (Select Id, Asset__r.Name, Asset__r.Product2.Name  From Scope_of_Product__r)
                                    From ServiceContract Where Id IN: servContractFilterIdList ];
                    }
            }
            else{
                System.debug('insidefilters');
                  if(filterdByStatus != '' && filterdByStatus != 'Expires' && filteredByIndustry == null && filterdByStatus != null){
                    System.debug('filterdByStatus only::');                
                    servContractList = [Select Id, Contract_No__c, Name, Description, YG_Sales_Manager_Name__c, YG_Sales_Manager_Email__c, YG_Sales_Manager_contact_no__c,
                                        StartDate, EndDate, YG_Sales_Manager_profile_photo__c, Owner.Name, Owner.Email, Owner.Phone,Contract_Type__c, Status, Contract_categories__c,
                                        (Select Id, Asset__r.Name, Asset__r.Product2.Name  From Scope_of_Product__r)
                                        From ServiceContract Where Id IN: contractIdList And Status =:filterdByStatus Limit : loadLimit offset :offset];
                }else if(filterdByStatus == null  && filteredByIndustry != '' && filteredByIndustry != null  ){
                    System.debug('filteredByIndustry only::');
                    servContractList1 = [Select Id, Contract_No__c, Name, Description, YG_Sales_Manager_Name__c, YG_Sales_Manager_Email__c, YG_Sales_Manager_contact_no__c,
                                        StartDate, EndDate, YG_Sales_Manager_profile_photo__c, Owner.Name, Owner.Email, Owner.Phone,Contract_Type__c, Status, Contract_categories__c,
                                        (Select Id, Asset__r.Name, Asset__r.Product2.Name  From Scope_of_Product__r)
                                        From ServiceContract Where Id IN: contractIdList And Contract_categories__c =: filteredByIndustry ];
                    
                    servContractList = [Select Id, Contract_No__c, Name, Description, YG_Sales_Manager_Name__c, YG_Sales_Manager_Email__c, YG_Sales_Manager_contact_no__c,
                                        StartDate, EndDate, YG_Sales_Manager_profile_photo__c, Owner.Name, Owner.Email, Owner.Phone,Contract_Type__c, Status, Contract_categories__c,
                                        (Select Id, Asset__r.Name, Asset__r.Product2.Name  From Scope_of_Product__r)
                                        From ServiceContract Where Id IN: contractIdList And Contract_categories__c =: filteredByIndustry Limit : loadLimit offset :offset];
                }else if( filterdByStatus != null && filterdByStatus != 'Expires' && filteredByIndustry != null ){
                    System.debug('filterdByStatus and filteredByIndustry::'); 
                    servContractList = [Select Id, Contract_No__c, Name, Description, YG_Sales_Manager_Name__c, YG_Sales_Manager_Email__c, YG_Sales_Manager_contact_no__c,
                                        StartDate, EndDate, YG_Sales_Manager_profile_photo__c, Owner.Name, Owner.Email, Owner.Phone,Contract_Type__c, Status, Contract_categories__c,
                                        (Select Id, Asset__r.Name, Asset__r.Product2.Name  From Scope_of_Product__r)
                                        From ServiceContract Where Id IN: contractIdList And Status =:filterdByStatus And Contract_categories__c =: filteredByIndustry Limit : loadLimit offset :offset];
            
                }//if(plantCode != null && filteredByIndustry == null && filteredByIndustry == '' && filterdByStatus == null && filterdByStatus == '' && filterdByStatus == 'Expiry'){
                else if(filterdByStatus == 'Expires' && filteredByIndustry == null){
                    System.debug('Filter by Status Expires less than 6 months::');
                    servContractList = [Select Id, Contract_No__c, Name, Description, YG_Sales_Manager_Name__c, YG_Sales_Manager_Email__c, YG_Sales_Manager_contact_no__c,
                                        StartDate, EndDate, YG_Sales_Manager_profile_photo__c, Owner.Name, Owner.Email, Owner.Phone,Contract_Type__c, Status, Contract_categories__c,
                                        (Select Id, Asset__r.Name, Asset__r.Product2.Name  From Scope_of_Product__r)
                                        From ServiceContract Where Id IN: selectedServiceContractIdList Limit : loadLimit offset :offset];
                }else if(filterdByStatus == 'Expires' && filteredByIndustry != null){
                    System.debug('Filter by Status Expires less than 6month status and filteredByIndustry::');
                    servContractList = [Select Id, Contract_No__c, Name, Description, YG_Sales_Manager_Name__c, YG_Sales_Manager_Email__c, YG_Sales_Manager_contact_no__c,
                                        StartDate, EndDate, YG_Sales_Manager_profile_photo__c, Owner.Name, Owner.Email, Owner.Phone,Contract_Type__c, Status, Contract_categories__c,
                                        (Select Id, Asset__r.Name, Asset__r.Product2.Name  From Scope_of_Product__r)
                                        From ServiceContract Where Id IN: selectedServiceContractIdList And Contract_categories__c =: filteredByIndustry Limit : loadLimit offset :offset];
                }
                else{   
                    System.debug('ALL');
                    //Loaded on page loads first
                    servContractList = [Select Id, Contract_No__c, Name, Description, YG_Sales_Manager_Name__c, YG_Sales_Manager_Email__c, YG_Sales_Manager_contact_no__c,
                                        StartDate, EndDate, YG_Sales_Manager_profile_photo__c, Owner.Name, Owner.Email, Owner.Phone,Contract_Type__c, Status, Contract_categories__c,
                                        (Select Id, Asset__r.Name, Asset__r.Product2.Name  From Scope_of_Product__r)
                                        From ServiceContract Where Id IN: contractIdList Limit : loadLimit offset :offset];	//
                }  
            }
            System.debug('servContractList::'+servContractList);
            System.debug('servContractList.size()::'+servContractList.size());
            if(servContractList1.size() > 0){
                servContract.radioBtnCnt = servContractList1.size(); 
            }
            System.debug('servContractList1::'+servContractList1);
            System.debug('servContractList1.size()::'+servContractList1.size());
            
            
            //To add the data Wrapper
            if(servContractList.size() > 0){
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
                            servContRec.startDate = dt1.format('dd MMM '+dt1.year());
                            Datetime dt2 = Datetime.newInstance(servCont.EndDate.year(),servCont.EndDate.month(),servCont.EndDate.day());
                            servContRec.endDate = dt2.format('dd MMM '+dt2.year());
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
                        System.debug('servContRec.contractName'+servContRec.contractName);
                        servContRec.contractNum = servCont.Contract_No__c;
                        //Converting date to string
                        System.debug('servCont.StartDate::'+servCont.StartDate);
                        Datetime dt1 = Date.newInstance(servCont.StartDate.year(),servCont.StartDate.month(),servCont.StartDate.day());
                        servContRec.startDate = dt1.format('dd MMM '+dt1.year());
                        System.debug('servContRec.startDate');
                        System.debug('servCont.EndDate::'+servCont.EndDate);
                        Datetime dt2 = Date.newInstance(servCont.EndDate.year(),servCont.EndDate.month(),servCont.EndDate.day());
                        System.debug('dt2::'+dt2);
                        servContRec.endDate = dt2.format('dd MMM '+dt2.year());
                        System.debug('servContRec.endDate::'+servContRec.endDate);
                        servContRec.contractDescription = servCont.Description;
                        servContRec.ygSalesManager = servCont.YG_Sales_Manager_Name__c;
                        servContRec.industry = servCont.Contract_categories__c;
                        System.debug('servCont.Status::'+servCont.Status);
                        String serviceContractExpiry = YG_HelperClass.getServiceContractExpiry(servCont.EndDate);
                        if(serviceContractExpiry != null && servCont.Status == 'Active'){
                            System.debug('Inside' +serviceContractExpiry);
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
            
            if(servContractFilterIdList.size() > 0 && !servContractFilterIdList.isEmpty()){
                servContract.expirySixMonths = expiryLessSixMon;
                servContract.activeContract = activeStatus;
                servContract.futureContract = inactiveStatus;
                servContract.expiredContract = expiredStatus;
                /*servContract.industrialAutoCnt = industryAuto;
        		servContract.testAndMeasureCnt = testAndMeasure;
        		servContract.lifeInnovationCnt = lifeInno;*/
                
                
            }else{
                YG_ProductDetailsCSV.ServiceContractWrapper  servNotiWrap= new YG_ProductDetailsCSV.ServiceContractWrapper();
                servNotiWrap =  YG_ProductDetailsCSV.getServiceContractCSV(plantCode);
                servContract.expirySixMonths = servNotiWrap.expirySixMonths;
                servContract.activeContract = servNotiWrap.activeContract;
                servContract.futureContract = servNotiWrap.futureContract;
                servContract.expiredContract = servNotiWrap.expiredContract;
                /*servContract.industrialAutoCnt = servNotiWrap.industrialAutoCnt;
        		servContract.testAndMeasureCnt = servNotiWrap.testAndMeasureCnt;
        		servContract.lifeInnovationCnt = servNotiWrap.lifeInnovationCnt;*/
            }
            System.debug('expiryLessSixMon::'+expiryLessSixMon);
            System.debug('activeStatus::'+activeStatus);
            System.debug('inactiveStatus::'+inactiveStatus);
            System.debug('expiredStatus::'+expiredStatus);
            /*System.debug('industryAuto::'+industryAuto);
            System.debug('testAndMeasure::'+testAndMeasure);
            System.debug('lifeInno::'+lifeInno);*/
            
            System.debug('servContract.expirySixMonths::'+servContract.expirySixMonths);
            System.debug('servContract.activeContract::'+servContract.activeContract);
            System.debug('servContract.futureContract::'+servContract.futureContract);
            System.debug('servContract.expiredContract::'+servContract.expiredContract);
            /*System.debug('servContract.industrialAutoCnt::'+servContract.industrialAutoCnt);
            System.debug('servContract.testAndMeasureCnt::'+servContract.testAndMeasureCnt);
            System.debug('servContract.lifeInnovationCnt::'+servContract.lifeInnovationCnt);*/
            
            
            //This condition is used to get the data for button filter 'Expiry than 6 months'
            if(filterdByStatus == 'Expires' && filteredByIndustry == null){
                System.debug('Expires');
                List<ServiceContracts> serviceContExpListWrap=new List<ServiceContracts>();
                for(ServiceContracts serv: serviceContractListWrap){
                    system.debug('serv111::'+serv);
                    system.debug('serv.notification::'+serv.notification);
                    if(serv.notification != null){
                        String selectedStatus = serv.notification;
                        //if(selectedStatus.contains(filterdByStatus)){
                            system.debug('serv::'+serv);
                            serviceContExpListWrap.add(serv);
                        //}
                    }
                }
                System.debug('serviceContExpListWrap::'+serviceContExpListWrap);
                System.debug('serviceContExpListWrap.Size()::'+serviceContExpListWrap.size());
                servContract.ServiceContractsList = serviceContExpListWrap;
                System.debug('servContract.ServiceContractsList::'+servContract.ServiceContractsList);
            }
            
            //This condition is used to get the data for button filter 'Expiry than 6 months' and with the Selected Industry
            if(filterdByStatus == 'Expires' && filteredByIndustry != null){
                System.debug('Expires with selected Indstry');
                List<ServiceContracts> serviceContExpListWrap=new List<ServiceContracts>();
                for(ServiceContracts serv: serviceContractListWrap){
                    if(serv.notification != null && serv.industry != null){
                        String selectedStatus = serv.notification;
                        String industryName = serv.industry;
                        System.debug('selectedStatus::'+selectedStatus);
                        System.debug('industryName::'+industryName);
                        if(industryName.contains(filteredByIndustry)){
                            system.debug('serv::'+serv);
                            serviceContExpListWrap.add(serv);
                            System.debug('serviceContExpListWrap::'+serviceContExpListWrap);
                        }
                    }
                }
                System.debug('serviceContExpListWrap::'+serviceContExpListWrap);
                System.debug('serviceContExpListWrap.Size()::'+serviceContExpListWrap.size());
                servContract.ServiceContractsList = serviceContExpListWrap;
            }
            System.debug('servContract.ServiceContractsList::'+servContract.ServiceContractsList);
            System.debug('servContract.ServiceContractsList.size()::'+servContract.ServiceContractsList.size());
            
            
        }Catch(Exception e){
            system.debug('Exception Cause::'+e.getCause());
            system.debug('Exception LineNumber::'+e.getLineNumber());
            system.debug('Exception Message::'+e.getMessage());
            system.debug('Exception StackTrace::'+e.getStackTraceString());
            system.debug('Exception TypeName::'+e.getTypeName());
            YG_Utility.logError('getServiceContracts','Community Component Error',e.getStackTraceString(),
                                'Class:YG_AllServiceContractsController; Method: getServiceContracts(); Line #:'+e.getLineNumber()+'; Message:'+e.getMessage(),
                                UserInfo.getUserId());
        }
        System.debug('servContract::'+servContract);
        return servContract;
    }
    
    
    public class ServiceContractWrapper{
        @AuraEnabled public Integer totalContractCnt;
        @AuraEnabled public Integer expirySixMonths;
        @AuraEnabled public Integer activeContract;
        @AuraEnabled public Integer futureContract;
        @AuraEnabled public Integer expiredContract;
        @AuraEnabled public Integer radioBtnCnt;
        /*@AuraEnabled public Integer industrialAutoCnt;
        @AuraEnabled public Integer testAndMeasureCnt;
        @AuraEnabled public Integer lifeInnovationCnt;*/
        
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
    
    //This method is used to get the service contract without the scope of product records and Asset records
    @AuraEnabled
    public static List<Id> getServContWithoutSOP(Id accid){
        System.debug('accid::'+accid);
        List<Servicecontract> servContList=[Select Id, Name,Contract_No__c,(Select Name, Asset__r.Id, Service_Contract__c, Service_Contract__r.Name, Service_Contract__r.Contract_No__c from Scope_of_Product__r) from servicecontract where Account.id =: accid];
        //
        System.debug('servContList::'+servContList);
        System.debug('servContList size::'+servContList.size());
        List<Id> servIds=new List<Id>();
        for(servicecontract serv : servContList){
            if(serv.Scope_of_Product__r.size() <= 0){
                System.debug('serv.Contract_No__c::'+serv.Contract_No__c);
                if(!servIds.contains(serv.Id)){ 
                    servIds.add(serv.Id);
                }
            }
            for(Scope_of_Product__c sop: serv.Scope_of_Product__r){
                if(sop.Asset__r.Id == null){
                    if(!servIds.contains(sop.Service_Contract__c)){
                        System.debug('Service_Contract__r.Contract_No__c::'+sop.Service_Contract__r.Contract_No__c);
                        servIds.add(sop.Service_Contract__c);
                    }
                }
            }
        }
        
        System.debug('servIds::'+servIds);
        return servIds;
    }
    
    //This method is to get the totalServiceContractSize
    @AuraEnabled
    public static Integer getTotalContractSize(String plantCode){
        Integer totalContractSize = 0;
        List<Id> contractIdList=new List<Id>();
        List<ServiceContract> serviceContractTotalCnt=new List<ServiceContract>();
        //To get the service contact Id assests
        ID contactId = userInformation.Contact.ID;  
        ID accId = userInformation.Contact.AccountId;  
        List<Id> assetIds =  YG_HelperClass.getCustomerAssets(contactId);
        system.debug('*******Customer assetIds::'+assetIds);
        //to get the service contract id
        contractIdList = YG_HelperClass.getServiceContracts(plantCode, assetIds);
        System.debug('contractIdList::'+contractIdList);
        
        //This logic used to get the contract without any sop system assets and this contract relate to the account
            List<Id> servContWithoutSop = YG_AllServiceContractsController.getServContWithoutSOP(accId);
            System.debug('servContWithoutSop::'+servContWithoutSop);
            for(Id servId : servContWithoutSop){
                if(!contractIdList.contains(servId)){
                    contractIdList.add(servId);
                }
            }
            System.debug('final servCont Ids::'+contractIdList);
        
        if(contractIdList.size() > 0){
            serviceContractTotalCnt = [Select Id, Contract_No__c, Name, Description, YG_Sales_Manager_Name__c, YG_Sales_Manager_Email__c, YG_Sales_Manager_contact_no__c,
                                        (Select Id, Asset__r.Name, Asset__r.Product2.Name  From Scope_of_Product__r)
                                        From ServiceContract Where Id IN: contractIdList];
            if(serviceContractTotalCnt.size() > 0){
                totalContractSize = serviceContractTotalCnt.size();
            }
        }
        System.debug('totalContractSize::'+totalContractSize);
        return totalContractSize;
    }
    
    //This method is used to get the contract information 
    @AuraEnabled 
    public static ContractInfoWrapper getContractInfo(String contractNumber){
        //String contractNumber = 'YEA-L0001-1901-01';
        String contType ='LCA';
        ContractInfoWrapper contInfo=new ContractInfoWrapper();
        Map<String,String> colorcode=new Map<String, String>();
        colorcode.put( 'Expiring','golden-rod');
        colorcode.put('Active','yok-green');
        colorcode.put('Expired','orange-red');
        ServiceContract servContract=new ServiceContract();
       
        for(ServiceContract servCon: [Select Id, Contract_No__c, Name, Description, YG_Sales_Manager_Name__c, YG_Sales_Manager_Email__c, YG_Sales_Manager_contact_no__c,
                                      StartDate, EndDate, YG_Sales_Manager_profile_photo__c, contact.name, Owner.Name, Owner.Email, Owner.Phone,Contract_Type__c, Status, Contract_categories__c, Account.Name,
                                      (Select Id, Asset__r.Name, Asset__r.Product2.Name, Asset__r.Product2.Model_Code__c  From Scope_of_Product__r)
                                      /*(Select Id,Asset.Name, Asset.Product2.Name, Asset.Product2.Model_Code__c From Entitlements)*/
                                      From ServiceContract Where Contract_No__c =: contractNumber]){
                                          if(servCon.Contract_Type__c != 'LCA'){
                                              for(Scope_of_Product__c entitle: servCon.Scope_of_Product__r){
                                                  contInfo.contractName = servCon.Name;
                                                  contInfo.contractNum =   servCon.Contract_No__c;
                                                  contInfo.contractDescription = servCon.Description;
                                                  contInfo.requestedBy = servCon.Account.Name;
                                                  contInfo.productName = entitle.Asset__r.Product2.Name;
                                                  contInfo.serialNum = entitle.Asset__r.Name;
                                                  contInfo.modCode = entitle.Asset__r.Product2.Model_Code__c;
                                                  contInfo.ygSalesManager = servCon.Owner.Name;
                                                  contInfo.contStatus = servCon.Status;
                                                  contInfo.contClass = colorcode.get(servCon.Status);
                                                  //contInfo.ygSalesManager = 'Judy Alexander';
                                                  if(servCon.StartDate != null){
                                                      Datetime dt1 = Datetime.newInstance(servCon.StartDate.year(),servCon.StartDate.month(),servCon.StartDate.day());
                                                      contInfo.startDate = dt1.format('dd MMMM '+dt1.year());
                                                  }                                          
                                                  if(servCon.EndDate != null){
                                                      Datetime dt2 = Datetime.newInstance(servCon.endDate.year(),servCon.endDate.month(),servCon.endDate.day());
                                                      contInfo.endDate = dt2.format('dd MMMM '+dt2.year());
                                                  }
                                              }
                                          }else{
                                              contInfo.contractName = servCon.Name;
                                              contInfo.contractNum =   servCon.Contract_No__c;
                                              contInfo.contractDescription = servCon.Description;
                                              contInfo.requestedBy = servCon.Account.Name;
                                              contInfo.contStatus = servCon.Status;
                                              contInfo.productName = '';
                                              contInfo.serialNum = '';
                                              contInfo.modCode = '';
                                              contInfo.contClass = colorcode.get(servCon.Status);
                                              contInfo.ygSalesManager = servCon.YG_Sales_Manager_Name__c;
                                              //contInfo.ygSalesManager = 'Judy Alexander';
                                              if(servCon.StartDate != null){
                                                  Datetime dt1 = Datetime.newInstance(servCon.StartDate.year(),servCon.StartDate.month(),servCon.StartDate.day());
                                                  contInfo.startDate = dt1.format('dd MMMM '+dt1.year());
                                              }                                          
                                              if(servCon.EndDate != null){
                                                  Datetime dt2 = Datetime.newInstance(servCon.endDate.year(),servCon.endDate.month(),servCon.endDate.day());
                                                  contInfo.endDate = dt2.format('dd MMMM '+dt2.year());
                                              }
                                          }
                                          
                                      }
        
        System.debug('contInfo::'+contInfo);
        
        
        return contInfo;
        
    }
    public class ContractInfoWrapper{
        @AuraEnabled public String contractName;
        @AuraEnabled public String contractNum;
        @AuraEnabled public String contractDescription;
        @AuraEnabled public String productName;
        @AuraEnabled public String requestedBy;
        @AuraEnabled public String serialNum;
        @AuraEnabled public String modCode;
        @AuraEnabled public String ygSalesManager;
        @AuraEnabled public String startDate;
        @AuraEnabled public String endDate;
        @AuraEnabled public Boolean contTypeLCA;
        @AuraEnabled public String contStatus;
        @AuraEnabled public String contClass;
    }
    
    //This method is used to get the service menu data grid 
    @AuraEnabled
    public static ServiceMenuWrapper getServiceMenuList(String contractNum){
        //String contractNum = 'YEA-L0001-1901-01';
        System.debug('contractNum::'+contractNum);
        ServiceMenuWrapper servMenu=new ServiceMenuWrapper();
        list<ServiceMenuWrap> serviceMenuList=new list<ServiceMenuWrap>();
        List<Id> entitlementIdList=new List<Id>();
        ServiceContract servContract=new ServiceContract();
        Date now = date.today();
        Date conEndDate;
        Try{
            Id accId = userInformation.Contact.AccountId;
            Id conId = userInformation.Contact.Id;
            system.debug('accId::'+accId);
            system.debug('conId::'+conId);
            Id serviceContractId;
            //Query to get the list of entitlement of a service contract
            List<Entitlement> entitleList=new List<Entitlement>();
            entitleList = [Select Id, Name, AccountId, ServiceContractId, AssetId, Per__c, Entitlement_quantity__c, Entitlement_type__c, 
                           Entitlement_balance__c, ServiceContract.Name, Asset.Product2.Name From Entitlement Where ServiceContract.Contract_No__c =: contractNum ];
            System.debug('entitleList::'+entitleList);
            System.debug('entitleList::size::'+entitleList.size());
            for(Entitlement entitle: entitleList){
                entitlementIdList.add(entitle.Id);
                serviceContractId = entitle.ServiceContractId;
            }
            System.debug('entitlementIdList::'+entitlementIdList);
            System.debug('entitlementIdListSize::'+entitlementIdList.size());
            System.debug('serviceContractId::'+serviceContractId);
           
            if(serviceContractId != null){
            servContract = [Select Id, Name, Contract_No__c, StartDate, EndDate, Contract_Type__c, Renewed_Contract__c From ServiceContract Where Id=:serviceContractId];
            System.debug('servContract::'+servContract);
            }
            servMenu.contractNum =  servContract.Contract_No__c;
            servMenu.contractType =  servContract.Contract_Type__c;
            
            Id ServContid = servContract.Id;
            System.debug('ServContid::'+ServContid);
            System.debug('servContract.EndDate::'+servContract.EndDate);
            System.debug('now::'+now);
            //To get the notification bar data
            System.debug('servContract.Renewed_Contract__c'+servContract.Renewed_Contract__c);
            if(servContract.EndDate < now){
                     conEndDate = null;
            }else{
                System.debug('else::');
                conEndDate = servContract.EndDate;
            }
            System.debug('conEndDate::'+conEndDate);
            YG_AllServiceContractsController.NotificationContract notiWrapData=new YG_AllServiceContractsController.NotificationContract();
            notiWrapData = YG_AllServiceContractsController.getNotificationBarData(conEndDate, entitlementIdList, ServContid);
            System.debug('notiWrapData::'+notiWrapData);
            if(notiWrapData.notiCount != null){
                servMenu.notificationCount =  notiWrapData.notiCount;
            }
            if(notiWrapData.contractExpiry != null){
                servMenu.contractExpiryDate = notiWrapData.contractExpiry;
            }
            if(notiWrapData.InspectionDates != null){
                if(notiWrapData.InspectionDates.size() > 0){
                    servMenu.inspecDates = notiWrapData.InspectionDates;
                }
            }
            System.debug('servMenu.notificationCount::'+servMenu.notificationCount);
            System.debug('servMenu.contractExpiryDate::'+servMenu.contractExpiryDate);
            System.debug('servMenu.contractExpiryDate::'+notiWrapData.InspectionDates);
            
            
            //To get the Sermenu grid wrapper data
            if(entitleList.size() > 0){
                for(Entitlement entitle: entitleList){
                    ServiceMenuWrap servmenuWrap=new ServiceMenuWrap();
                    servMenu.productName = entitle.Asset.Product2.Name;
                    if(entitle.Name != null){
                    servmenuWrap.serviceMenu = entitle.Name;
                    }else{
                        servmenuWrap.serviceMenu = '-';
                    }
                    if(entitle.Entitlement_type__c != null){
                    servmenuWrap.entitlementType = entitle.Entitlement_type__c;
                    }else{
                        servmenuWrap.entitlementType = '-';
                    }
                    if(entitle.Entitlement_quantity__c != null){
                    servmenuWrap.entitlementQuantity = entitle.Entitlement_quantity__c;
                    }
                    if(entitle.Entitlement_balance__c != null){
                    servmenuWrap.entitlementBalance = entitle.Entitlement_balance__c;
                    }
                    if(entitle.Per__c != null){
                    servmenuWrap.per = entitle.Per__c;
                    }else{
                        servmenuWrap.per = '-';
                    }
                    
                    serviceMenuList.add(servmenuWrap);
                }
            }
            System.debug('serviceMenuList::'+serviceMenuList);
            if(entitlementIdList.size() > 0){
                servMenu.entitlementIdList = entitlementIdList;
            }
            servMenu.servMenuList = serviceMenuList;
            System.debug('servMenu::'+servMenu);
        }catch(Exception e){
            system.debug('Exception Cause::'+e.getCause());
            system.debug('Exception LineNumber::'+e.getLineNumber());
            system.debug('Exception Message::'+e.getMessage());
            system.debug('Exception StackTrace::'+e.getStackTraceString());
            system.debug('Exception TypeName::'+e.getTypeName()); 
            YG_Utility.logError('ContractDetailsPage','Community Component Error',e.getStackTraceString(),
                                'Class:YG_AllServiceRequestController; Method: getServiceMenuList(); Line #:'+e.getLineNumber()+'; Message:'+e.getMessage(),
                                UserInfo.getUserId());
        }
        return servMenu;
    }
    
    public class ServiceMenuWrapper{
        @AuraEnabled public Integer notificationCount;
        @AuraEnabled public String contractExpiryDate;
        @AuraEnabled public List<String> inspecDates;
        @AuraEnabled public String contractNum;
        @AuraEnabled public String contractType;
        @AuraEnabled public String productName;
        @AuraEnabled public List<Id> entitlementIdList;
        @AuraEnabled public list<ServiceMenuWrap> servMenuList;
    }
    public class ServiceMenuWrap{
        @AuraEnabled public String serviceMenu;
        @AuraEnabled public String entitlementType;
        @AuraEnabled public Decimal entitlementQuantity;
        @AuraEnabled public Decimal entitlementBalance;
        @AuraEnabled public String per;
        
    }
    
    //This method is used to get the Notification bar data in contract-details page
    @AuraEnabled
    public static NotificationContract getNotificationBarData(Date endDt, List<Id> entitlementListID , Id servContractId){
        //public static void getNotificationBarData(){
        System.debug('endDt::'+endDt);
        System.debug('entitlementListID::'+entitlementListID);
        //Getting the date after 6monts
        Datetime dtTime=System.now();
         Date now = date.today();
        date dt= date.newinstance(dtTime.year(), dtTime.month(), dtTime.day());
        date dateAfter=dt.addMonths(+6);
        List<String> inspections=new List<String>(); //to store the inspection dates
        NotificationContract notiContract=new NotificationContract();
        Integer notiCnt = 0;
        
        ServiceContract servCont=[Select Id, Name, Renewed_Contract__c from ServiceContract where Id=:servContractId];
        //To Calculate the expiry duration of the contract
        if(endDt != null){ 
            String serviceContractExpiry = YG_HelperClass.getServiceContractExpiry(endDt);
            System.debug('serviceContractExpiry:::'+serviceContractExpiry);
            if(serviceContractExpiry != null){
                notiContract.contractExpiry = serviceContractExpiry;
                notiCnt ++;
            }
        }else{
            if(servCont.Renewed_Contract__c == null){
                notiContract.contractExpiry = ' Expired';
                notiCnt ++;
            }
        }
        System.debug('notiCnt ::'+notiCnt);
        System.debug('notiContract.contractExpiry ::'+notiCnt);
        //To get the Inspection data 
        //List<Inspection__c> inspectionList=new List<Inspection__c>();
        List<WorkOrder> inspectionList=new List<WorkOrder>();
        Date schedule;
        
        if(entitlementListID.size() > 0){
            //Query to get the 5 inspection schedule date which is from upcoming greater that 6 months
            //inspectionList = [Select Actual_Date__c, Scheduled_Date__c, Status__c, Type__c From Inspection__c Where (Entitlement__c IN: entitlementListID AND Scheduled_Date__c > TODAY) ORDER BY Scheduled_Date__c ASC];
            inspectionList = [Select Id, Actual_Date__c, Scheduled_Date__c, Inspection_Category__c From WorkOrder Where ((Entitlement.Id IN: entitlementListID OR ServiceContract.Id =: servContractId)
                                                                                                                         AND Scheduled_Date__c >= TODAY AND Scheduled_Date__c <=:dateAfter)  ORDER BY Scheduled_Date__c ASC Limit 5];
            System.debug('inspectionList::'+inspectionList);
            System.debug('inspectionList.size()::'+inspectionList.size());
            if(inspectionList.size() > 0) {
                for(WorkOrder wrk: inspectionList){
                    schedule = wrk.Scheduled_Date__c;
                    Datetime dt1 = Datetime.newInstance(schedule.year(),schedule.month(),schedule.day());
                    String insDate= dt1.format('dd MMM YYYY'); 
                    inspections.add(insDate);
                }
                notiContract.InspectionDates = inspections;
            }
            
            if(inspections.size() > 0){
                    notiCnt ++;
                }
             notiContract.notiCount =  notiCnt;
        }
        return notiContract;
        
    }
    
    //Wrapper class to get the notification contract
    public class NotificationContract{
        @AuraEnabled public Integer notiCount;
        @AuraEnabled public String contractExpiry;
        @AuraEnabled public List<String> InspectionDates;
        
    }
    
    //This method is used to get the contract Timeline
    @AuraEnabled
    public static ServMenuHistoryWrapper getServiceMenuTimeLine(String contractNum, String selectEntitlementId){ //
    //public static ServMenuHistoryWrapper getServiceMenuTimeLine(){
        HistoryWrap hisWrap=new HistoryWrap();
        //Id selectEntitlementId = '550p00000000m2PAAQ';
        List<String> entitlementId = new List<String>();//'550p00000000m25AAA';
        /*entitlementId.add('550p00000000m25AAA');
        entitlementId.add('550p00000000m2KAAQ');
        entitlementId.add('550p00000000m2PAAQ');
        entitlementId.add('550p00000000m2UAAQ');
        entitlementId.add('550p00000000m2ZAAQ');
        entitlementId.add('550p00000000m2eAAA');
        entitlementId.add('550p00000000m2jAAA');
        entitlementId.add('550p00000000m2oAAA');*/
        
        
        //Query to get the list of entitlement of a service contract
            List<Entitlement> entitleList=new List<Entitlement>();
            entitleList = [Select Id, Name, AccountId, ServiceContractId, AssetId, Per__c, Entitlement_quantity__c, Entitlement_type__c, 
                           Entitlement_balance__c, ServiceContract.Name,ContractMainteCrmID__c From Entitlement Where ServiceContract.Contract_No__c =: contractNum ];
            System.debug('entitleList::'+entitleList);
            System.debug('entitleList::size::'+entitleList.size());
            for(Entitlement entitle: entitleList){
                entitlementId.add(entitle.ContractMainteCrmID__c);
                
            }
            System.debug('entitlementId::'+entitlementId);
            System.debug('entitlementId.size::'+entitlementId.size());
        
        
        //List<Inspection__c> inspectionList=new List<Inspection__c>();
        List<WorkOrder> inspectionList=new List<WorkOrder>();
        List<Case> entitlementCaseList=new List<Case>();
        List<Id> casId=new List<Id>();
        List<CaseHistory> casehist=new List<CaseHistory>();
        List<Integer> yr= new List<Integer>(); //To store the list of years
        Map<Integer,List<sObjectData>> mapOfTimeline=new Map<Integer,List<sObjectData>>(); //Map to store the timeline chart values
        Map<Integer,List<sObjectData>> mapOfTimeline1=new Map<Integer,List<sObjectData>>();
        Map<Integer,List<sObjectData>> mapOfTimeline2=new Map<Integer,List<sObjectData>>();
        Map<String ,List<caseHis>> mapOfTimelineCaseHis=new Map<String ,List<caseHis>>();
        ServMenuHistoryWrapper servHisWrap = new ServMenuHistoryWrapper();
        List<HistoryWrap> hisWrapList = new List<HistoryWrap>();
        
        
        //Query to get the inspection list details
        /*inspectionList = [Select Name, Actual_Date__c, Scheduled_Date__c, Status__c, Type__c, Entitlement__r.Name from Inspection__c 
                          Where Entitlement__c IN: entitlementId ORDER BY Actual_Date__c Desc];*/
        Try{
        if(selectEntitlementId == null){
            System.debug('inside null');
            inspectionList = [Select Actual_Date__c, Scheduled_Date__c, Status, Inspection_Category__c, Entitlement.Name from WorkOrder 
                              Where Entitlement.ContractMainteCrmID__c IN: entitlementId ORDER BY Actual_Date__c Desc];
            System.debug('inspectionList::'+inspectionList);
            System.debug('inspectionList.size()::'+inspectionList.size());
            
            //Query to get the entitlement cases
            
            entitlementCaseList = [Select Id, CreatedDate, CaseNumber, Description, status, Subject, Entitlement.Id, Entitlement.Name,ContractMainteCrmID__c 
                                   from case Where ContractMainteCrmID__c IN: entitlementId];
            if(entitlementCaseList.size() > 0){
                for(Case caseId : entitlementCaseList){
                    casId.add(caseId.Id);
                }
            }
            System.debug('casId::'+casId);
            
        }else{
            System.debug('inside ID:'+selectEntitlementId);
            inspectionList = [Select Actual_Date__c, Scheduled_Date__c, Status, Inspection_Category__c, Entitlement.Name from WorkOrder 
                              Where Entitlement.ContractMainteCrmID__c =:selectEntitlementId  ORDER BY Actual_Date__c Desc];
            System.debug('inspectionList::'+inspectionList);
            System.debug('inspectionList.size()::'+inspectionList.size());
            
            //Query to get the entitlement cases
            
            entitlementCaseList = [Select Id, CreatedDate, CaseNumber, Description, status, Subject, Entitlement.Id, Entitlement.Name
                                   from case Where ContractMainteCrmID__c =: selectEntitlementId];
            if(entitlementCaseList.size() > 0){
                for(Case caseId : entitlementCaseList){
                    casId.add(caseId.Id);
                }
            }
            System.debug('casId::'+casId);
            System.debug('casId::'+casId);
        }
        
        if(casId.size() > 0){
                casehist = [select CaseId, NewValue, OldValue, CreatedDate from CaseHistory where CaseId IN: casId and Field='Progress__c' ORDER BY CreatedDate Desc];
            }
        //Getting the unique year and adding in the list
        /*if(casehist.size() > 0){
            for(CaseHistory c: casehist){
                if(c.CreatedDate != null){
                    Integer year = c.CreatedDate.Year();
                    if(!yr.contains(year)){
                        yr.add(year);
                    }
                }
            }
        }*/
         if(entitlementCaseList.size() > 0){
            for(case c: entitlementCaseList){
                if(c.CreatedDate != null){
                    Integer year = c.CreatedDate.Year();
                    if(!yr.contains(year)){
                        yr.add(year);
                    }
                }
            }
        }
            
        System.debug('yr:::'+yr);
        if(inspectionList.size() > 0){
            for(WorkOrder ins: inspectionList){
                if(ins.Actual_Date__c != null){
                    Integer year = ins.Actual_Date__c.Year();
                    if(!yr.contains(year)){
                        yr.add(year);
                    }
                }
            }
        }
        System.debug('yr:::'+yr);
        
            //Sorting the years in Descending
            //yr.sort(desc);
            for(Integer i = 0 ; i < yr.size() ; i ++) {
                for(integer j = i+1 ; j <= yr.size() -1 ; j ++ ){
                    integer x = 0 ;
                    if(yr[i] <  yr[j]){
                        x = yr[i]  ;
                        yr[i] = yr[j]  ;
                        yr[j]  = x;
                        system.debug(yr) ;
                    }
                }
            }
        //logic to add the inspection records to the timeline map
        for(Integer year : yr){
            List<sObjectData> sObjList=new List<sObjectData>();
            Integer timeLineYear = year;
            System.debug('year::'+year);
            if(inspectionList.size() > 0){
                sObjectData sObj;
                for(WorkOrder inspec : inspectionList){
                    sObj=new sObjectData();
                    if(inspec.Actual_Date__c != null){
                        System.debug('inspec::'+inspec);
                        if(inspec.Actual_Date__c.Year() == year){
                            System.debug('inspec.Actual_Date__c.Year()::'+inspec.Actual_Date__c.Year());
                            System.debug('Year()::'+year);
                            //sObjectData sObj=new sObjectData();
                            sObj.type = 'Inspection';
                            sObj.description = 'Scheduled Patrol Inspection';
                            sObj.dateValue = inspec.Actual_Date__c;
                            Datetime dt = Datetime.newInstance(inspec.Actual_Date__c.year(),inspec.Actual_Date__c.month(),inspec.Actual_Date__c.day());
                            sObj.hisDate = dt.format('dd MMMM '+dt.year());
                            System.debug('sObj::'+sObj);
                            sObjList.add(sObj);
                            System.debug('sObjList:::'+sObjList);
                        }
                    }
                }
                mapOfTimeline1.put(timeLineYear, sObjList);
                System.debug('mapOfTimeline1:::'+mapOfTimeline1);
            }
            System.debug('sObjList.size():::'+sObjList.size());
        }
        System.debug('mapOfTimeline1:::'+mapOfTimeline1);
        
        //
        
        //logic to add the case records to the timeline map
        
        for(Integer year : yr){
            List<sObjectData> sObjList=new List<sObjectData>();
            sObjectData sObj;
            for(Case caseRec : entitlementCaseList){
                sObj=new sObjectData();
                if(caseRec.CreatedDate.Year() == year){
                    sObj.type = 'Case';
                    sObj.caseno = caseRec.CaseNumber;
                    sObj.status = caseRec.Status;
                    sObj.dateValue = caseRec.CreatedDate;
                    Datetime dt2 = Datetime.newInstance(caseRec.CreatedDate.year(),caseRec.CreatedDate.month(),caseRec.CreatedDate.day());
                    sObj.caseCreatedDate = dt2.format('dd MMMM '+dt2.year());
                    sObj.caseSubject = caseRec.Subject;
                    List<caseHis>  caseHisList=new List<caseHis>();
                    caseHis casHisRec;
                    for(CaseHistory caseHisRec  : casehist){
                        System.debug('caseHisRec::'+caseHisRec);
                        casHisRec=new caseHis();
                        if(caseRec.Id == caseHisRec.CaseId){
                            casHisRec.progress = caseHisRec.NewValue.toString();
                            Datetime dt = Datetime.newInstance(caseHisRec.CreatedDate.year(),caseHisRec.CreatedDate.month(),caseHisRec.CreatedDate.day());
                            casHisRec.hisDate = dt.format('dd MMMM '+dt.year());
                            caseHisList.add(casHisRec);
                        }
                    }
                    mapOfTimelineCaseHis.put(sObj.caseno,  caseHisList);
                    System.debug('mapOfTimelineCaseHis::'+mapOfTimelineCaseHis);
                    //sObj.serCaseHis = caseHisList;
                    sObjList.add(sObj);
                }
            }
            mapOfTimeline2.put(year, sObjList);
            System.debug('sObjList:::'+sObjList);
            System.debug('sObjList.size():::'+sObjList.size());
        }
        System.debug('mapOfTimeline2:::'+mapOfTimeline2);
        //mapOfTimeline1.putAll(mapOfTimeline2);
        //System.debug('mapOfTimeline1:::'+mapOfTimeline1);
        
        //Merging two maps
        
        for(Integer year : yr){
            HistoryWrap hisWra = new HistoryWrap();
            hisWra.prodYear = year;
            List<sObjectData> objList = new List<sObjectData>();
            
            if(mapOfTimeline1.get(year) != null){
                for(sObjectData ph: mapOfTimeline1.get(year)){
                    sObjectData sOData = new sObjectData();
                    if(ph.dateValue.Year() == year){
                        sOData.type = ph.type;
                        sOData.description = ph.description;
                        sOData.dateValue =  ph.dateValue;
                        sOData.hisDate = ph.hisDate;    
                        objList.add(sOData); 
                    }
                }
            }
            
            if(mapOfTimeline2.get(year) != null){
                for(sObjectData ph: mapOfTimeline2.get(year)){
                    sObjectData sOData = new sObjectData();
                    if(ph.dateValue != null){
                        if(ph.dateValue.Year() == year){
                            sOData.type = ph.type;
                            sOData.description = ph.description;
                            sOData.dateValue =  ph.dateValue;
                            sOData.hisDate = ph.hisDate; 
                            sOData.caseno = ph.caseno;
                            sOData.status = ph.status;
                            sOData.caseSubject = ph.caseSubject;
                            sOData.caseCreatedDate = ph.caseCreatedDate;
                            if(ph.caseno != null){
                                List<caseHis> csHisList=new List<caseHis>();
                                //for(caseHis cs: ph.serCaseHis){
                                if(mapOfTimelineCaseHis.get(ph.caseno) != null){
                                    for(caseHis cs: mapOfTimelineCaseHis.get(ph.caseno)){
                                        System.debug('cs:::'+cs);
                                        caseHis csHisRec=new caseHis();
                                        if(cs.progress != null){
                                            csHisRec.progress = cs.progress;
                                        }
                                        if(cs.hisDate != null){
                                            csHisRec.hisDate = cs.hisDate;
                                        }
                                        csHisList.add(csHisRec);
                                        
                                    }
                                }
                                sOData.serCaseHis = csHisList;
                            }
                            objList.add(sOData); 
                        }
                    }
                }
            }
            System.debug('objList::'+objList);
            hisWra.servMenuHis = objList;
            hisWrapList.add(hisWra);
        }
        system.debug('hisWrapList::'+hisWrapList);
        servHisWrap.hisWrap = hisWrapList;
        system.debug('servHisWrap::'+servHisWrap);
        }catch(Exception e){
            system.debug('Exception Cause::'+e.getCause());
            system.debug('Exception LineNumber::'+e.getLineNumber());
            system.debug('Exception Message::'+e.getMessage());
            system.debug('Exception StackTrace::'+e.getStackTraceString());
            system.debug('Exception TypeName::'+e.getTypeName());
        }
        return servHisWrap;
        
    }
    
    //wrapper class to store the year and list of product history record
    public class ServMenuHistoryWrapper{
        @AuraEnabled public List<HistoryWrap> hisWrap;
        @AuraEnabled public Map<Id, String> menusWrap;
    }
    
    public class HistoryWrap{
        @AuraEnabled public Integer prodYear;
        @AuraEnabled public List<sObjectData> servMenuHis; 
        //@AuraEnabled public List<servMenuCaseList> caseHisList;	
    }
    
    public class sObjectData{
        @AuraEnabled public string type;
        @AuraEnabled public string description;
        @AuraEnabled public string hisDate;
        @AuraEnabled public string caseSubject;
        @AuraEnabled public string status;
        @AuraEnabled public string caseno;
        @AuraEnabled public datetime dateValue;
        @AuraEnabled public string caseCreatedDate;
        @AuraEnabled public List<caseHis> serCaseHis;
    }
    
    public class caseHis{
        @AuraEnabled public string progress;
        @AuraEnabled public string hisDate;
    }
    
    //Method to get the service Menu dropdown
    @AuraEnabled
    public static Map<String, String> getServiceMenuDropdown(String contractNum){
        List<Case> entitlementCaseList1=new List<Case>(); //To get the menu
        List<String> entitlementId = new List<String>();
        Map<String, String> menusMap=new Map<String, String>();	//Map is used to get the service menus
        Map<String, String> entitlementDet=new Map<String, String>();
        //Query to get the list of entitlement of a service contract
        List<Entitlement> entitleList=new List<Entitlement>();
        entitleList = [Select Id, Name, AccountId, ServiceContractId, AssetId, Per__c, Entitlement_quantity__c, Entitlement_type__c, 
                       Entitlement_balance__c, ServiceContract.Name, ContractMainteCrmID__c From Entitlement Where ServiceContract.Contract_No__c =: contractNum ];
        System.debug('entitleList::'+entitleList);
        System.debug('entitleList::size::'+entitleList.size());
        for(Entitlement entitle: entitleList){
            entitlementId.add(entitle.ContractMainteCrmID__c);
            entitlementDet.put(entitle.ContractMainteCrmID__c, entitle.Name);
            
        }
        System.debug('entitlementId::'+entitlementId);
        System.debug('entitlementId.size::'+entitlementId.size());
        System.debug('entitlementDet::'+entitlementDet);
        
        //Query to get the service menu
        entitlementCaseList1 = [Select Id, CreatedDate, CaseNumber, Description, status, Subject, Entitlement.Id, Entitlement.Name,ContractMainteCrmID__c
                                from case Where ContractMainteCrmID__c IN: entitlementId];
        if(entitlementCaseList1.size() > 0){
            
            for(Case caseId : entitlementCaseList1){
                if(caseId.ContractMainteCrmID__c != null){
                    String entitleName = entitlementDet.get(caseId.ContractMainteCrmID__c);
                    menusMap.put(caseId.ContractMainteCrmID__c, entitleName);
                }
            }
        }
        System.debug('menusMap::'+menusMap);
        
        return menusMap;
    }
    
    //This method is used to get the contract name used for the submit an inquiry form for renewal of contract
    @AuraEnabled 
    public static String getContract(String contractNo){
        System.debug('contractNo::'+contractNo);
        String ContractName;
        ServiceContract serviceCont=new ServiceContract();
        serviceCont = [Select Id, Name from ServiceContract Where Contract_No__c =: contractNo Limit 1];
        ContractName = serviceCont.Name;
        return ContractName;
    }
     //This method is used to get the submitted case details on the renewal of contract thankyou page
    @AuraEnabled
    public static Case getContractCaseSubmitThankYouPageDetails(String caseid){
        System.debug('caseid::'+caseid);
        Case caseResult=new Case();
        caseResult = [Select Id, Type, Subject, Description, Reason, Service_you_require__c, Product.Name From Case Where id=: caseid];
        return caseResult;
    }
}