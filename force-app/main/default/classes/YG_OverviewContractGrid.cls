/*
*******************************************************************************************************
* (C) Copyright 2020 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Jayaprasath
* @version 1.0
* @created 09/22/2020
* @description 
* This class is used to write the methods for Overview page Grid section.
*
* @test class name - 
*
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  
*/

public class YG_OverviewContractGrid {
    
    public static User userInformation =  YG_Utility.getLoggedInUserInfo(UserInfo.getUserId());
    
    //This method is used to get the grid data for Overview page 
    @AuraEnabled
    public static OverviewContractWrapper getOverviewContractGrid(String plantCode, Integer loadLimit, Integer offset){
        
        System.debug('plantCode::'+plantCode);
        System.debug('loadLimit::'+loadLimit);
        System.debug('offset::'+offset);
        
        OverviewContractWrapper overviewConWap=new OverviewContractWrapper();
        List<OverviewContractData> overviewConList=new List<OverviewContractData>();
        
        String langCode = YG_CommonUtils.getLanguageCode(userInformation.LanguageLocaleKey); 
        
        try{
            
            //To get account and contact Id
            Id accId = userInformation.Contact.AccountId;
            Id conId = userInformation.Contact.Id;
            system.debug('accId::'+accId);
            system.debug('conId::'+conId);
            Date now = Date.today();
            
            //To get the service contact Id assests
            ID contactId = userInformation.Contact.ID;  
            List<Id> assetIds =  YG_HelperClass.getCustomerAssets(contactId);
            system.debug('*******Customer assetIds::'+assetIds);
            
            List<Id> serviceContractId = YG_HelperClass.getServiceContracts(plantCode, assetIds);
            system.debug('serviceContractId**'+serviceContractId);
            
            //This logic used to get the contract without any sop system assets and this contract relate to the account
            List<Id> servContWithoutSop = YG_AllServiceContractsController.getServContWithoutSOP(accId);
            System.debug('servContWithoutSop::'+servContWithoutSop);
            for(Id servId : servContWithoutSop){
                if(!serviceContractId.contains(servId)){
                    serviceContractId.add(servId);
                }
            }
            System.debug('final serviceContractId::'+serviceContractId);
            
            List<ServiceContract> servCon1 = [SELECT Id, StartDate, EndDate, Renewed_Contract__c FROM ServiceContract where id IN : serviceContractId ORDER BY EndDate ASC ];
            List<Id> selectedServiceContractIdList = new List<Id>();
            Id selectedServiceContractId ; 
            for(ServiceContract sc:servCon1){
                String notify = YG_HelperClass.getServiceContractExpiry(sc.EndDate);
                if(notify != null){
                    selectedServiceContractId = sc.id;
                    selectedServiceContractIdList.add(selectedServiceContractId);
                }
                system.debug('selectedServiceContractIdList::'+selectedServiceContractIdList);
                //To get the expired contract
                if(sc.Renewed_Contract__c == null){
                    if(sc.EndDate < now){
                        selectedServiceContractId = sc.id;
                        selectedServiceContractIdList.add(selectedServiceContractId);
                    }
                }
                system.debug('selectedServiceContractIdList::'+selectedServiceContractIdList);
            }
            system.debug('selectedServiceContractIdListFinalwith expired and less than six mon::'+selectedServiceContractIdList);
            overviewConWap.totalrecsize = selectedServiceContractIdList.size();
            system.debug('check size'+selectedServiceContractIdList.size());
            
            List<ServiceContract> servCon = [SELECT Name, Contract_No__c, Description, StartDate, EndDate, Contract_Type__c, Owner.Name, YG_Sales_Manager_Name__c, YG_Sales_Manager_profile_photo__c, Contract_categories__c, (Select Id, Asset.Product2.Name From Entitlements ) FROM ServiceContract where id IN : selectedServiceContractIdList ORDER BY EndDate ASC Limit :loadLimit offset :offset ];
            system.debug('servCon'+servCon);
            
            for(ServiceContract sc:servCon){ 
                
                OverviewContractData overviewGridData =new OverviewContractData();
                String notify = YG_HelperClass.getServiceContractExpiry(sc.EndDate);
                system.debug('notify'+notify);
                
                overviewGridData.name = sc.Name;
                overviewGridData.contractNo = sc.Contract_No__c;
                overviewGridData.salesManager = sc.YG_Sales_Manager_Name__c;
                if(notify == null){
                    Datetime renewdt1 = Datetime.newInstance(sc.EndDate.year(),sc.EndDate.month(),sc.EndDate.day());
                    String renewdate = renewdt1.format('dd MMM '+sc.EndDate.year());
                    system.debug('renewdate'+renewdate);
                    renewdate = Label.YG_Expired_on + ' '+renewdate;
                    //overviewGridData.notification = renewdate;
                    overviewGridData.expiredNotification = renewdate;
                }else{
                    overviewGridData.notification = notify;
                }
                overviewGridData.contractCategories = sc.Contract_categories__c;
                
                //this condition is to check the contract type
                
                if(sc.Contract_Type__c != 'BCP'){
                    
                    overviewGridData.description = sc.Description;
                    overviewGridData.productName = '';
                    //to check if Sales Manager Name is null
                    if(sc.YG_Sales_Manager_Name__c == null){
                        overviewGridData.salesManager = '';
                    }
                    else{
                        overviewGridData.salesManager = sc.YG_Sales_Manager_Name__c;
                    }
                    
                    overviewGridData.salesManagerImg = sc.YG_Sales_Manager_profile_photo__c;
                    
                }
                
                else{                            
                    overviewGridData.description = '';
                    for(Entitlement en: sc.Entitlements){
                        overviewGridData.productName = en.Asset.Product2.Name;
                        system.debug('productName'+en.Asset.Product2.Name);
                    }
                    
                    User u = [Select Name, FullPhotoUrl from User where id =: sc.OwnerId];
                    //to check if BCP Sales Manager Name is null
                    if(sc.YG_Sales_Manager_Name__c == null){
                        overviewGridData.salesManager = '';
                    }
                    else{
                        overviewGridData.salesManager = u.Name;
                    }
                    
                    //to check if BCP Sales Manager Profile Photo is null
                    if(sc.YG_Sales_Manager_profile_photo__c == null){
                        overviewGridData.salesManagerImg = '';
                    }
                    else{
                        overviewGridData.salesManagerImg = u.FullPhotoUrl;
                    }
                }
                
                overviewConList.add(overviewGridData);
                overviewConWap.overviewContractDataList = overviewConList;
                system.debug('grid data'+overviewConList);
                
            }
            
            
        }catch(Exception e){
            system.debug('Exception Cause::'+e.getCause());
            system.debug('Exception LineNumber::'+e.getLineNumber());
            system.debug('Exception Message::'+e.getMessage());
            system.debug('Exception StackTrace::'+e.getStackTraceString());
            system.debug('Exception TypeName::'+e.getTypeName());
            YG_Utility.logError('OverviewGrid page','Community Component Error',e.getStackTraceString(),
                                'Class:YG_OverviewContractGrid; Method: getOverviewContractGrid(); Line #:'+e.getLineNumber()+'; Message:'+e.getMessage(),
                                UserInfo.getUserId());
        }
        
        return overviewConWap;
    }
    
    public class OverviewContractWrapper{
        @AuraEnabled public List<OverviewContractData> overviewContractDataList;
        @AuraEnabled public Integer totalrecsize;
    }
    public class OverviewContractData{
        @AuraEnabled public String name;
        @AuraEnabled public String description;
        @AuraEnabled public String productName;
        @AuraEnabled public String salesManager;
        @AuraEnabled public String salesManagerImg;
        @AuraEnabled public String notification;
        @AuraEnabled public String expiredNotification;
        @AuraEnabled public String contractNo;
        @AuraEnabled public String contractCategories;
    }
    
}