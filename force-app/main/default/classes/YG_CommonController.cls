/*
*******************************************************************************************************
* (C) Copyright 2020 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Chitrakishore
* @version 1.0
* @created 15/06/2020
* @description 
* This class is used to write the methods for common functionality for all the modules.
*
* @test class name - YG_CommonControllerTest
*
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  12/04/2020			Jayaprasath				Added getMenuInfo()
*  04/19/2021			Kavya					Removed Customer_Plant__c Object and replaced with AccountContactRelation Object
*
*/

public class YG_CommonController {
    
    public static User userInformation =  YG_Utility.getLoggedInUserInfo(UserInfo.getUserId());
    
    @AuraEnabled
    public static CommonWrapper getPlantInfo(String langCode){
        
        Id cusPltId;
        
        List<DataWrapper> wrapperList = new List<DataWrapper>();
        
        CommonWrapper commonWrapper = new CommonWrapper();
       // try{
            if(null == langCode){
               langCode = 'EN';
            }
            
            system.debug('userInformation.ContactId :::'+userInformation.ContactId);
            // Retrieve logged in user's plants info
            /*List<Customer_Plant__c> cusPlantList = YG_HelperClass.getCusPlantInfo(userInformation.ContactId,langCode);*/
        List<AccountContactRelation> cusPlantList = YG_HelperClass.getCusPlantInfo(userInformation.ContactId,langCode);
            
            system.debug('cusPlantList::'+cusPlantList);
            
            /*for(Customer_Plant__c cusPlant: cusPlantList){
                DataWrapper wrapper = new DataWrapper();
                wrapper.plantCode = cusPlant.Plant__r.Plant_Code__c;
                wrapper.plantName = cusPlant.Plant__r.Plant_Name__c;                
                wrapperList.add(wrapper);
                
            }*/
        for(AccountContactRelation cusPlant: cusPlantList){
                DataWrapper wrapper = new DataWrapper();
                wrapper.plantCode = cusPlant.Account.AccountNumber;
                wrapper.plantName = cusPlant.Account.Name;                
                wrapperList.add(wrapper);
                
            }
            system.debug('wrapperList :::'+ wrapperList);
			commonWrapper.wrapper = wrapperList;    
            system.debug('commonWrapper :::'+ commonWrapper);
            
       /* }catch(Exception e){
            system.debug('Exception Cause::'+e.getCause());
            system.debug('Exception LineNumber::'+e.getLineNumber());
            system.debug('Exception Message::'+e.getMessage());
            system.debug('Exception StackTrace::'+e.getStackTraceString());
            system.debug('Exception TypeName::'+e.getTypeName());
            YG_Utility.logError('Plant Page','Community Component Error',e.getStackTraceString(),
                               'Class:YG_CommonController; Method: getPlantInfo(); Line #:'+e.getLineNumber()+'; Message:'+e.getMessage(),
                               UserInfo.getUserId());
        }*/
        
        return commonWrapper;
    }
    
    public class CommonWrapper{
        @AuraEnabled public List<DataWrapper> wrapper; 
    }
    
    public class DataWrapper{
        @AuraEnabled public string plantCode; 
        @AuraEnabled public string plantName;
    }
    
    //This method is used to check the user's account has assigned plant or not
    @AuraEnabled 
    public static String checkContractOrIndividualCustomer(){
        Id accId = userInformation.Contact.AccountId;
        Id conId = userInformation.Contact.Id;
        String result;
        system.debug('userInformation.accId :::'+accId);
        system.debug('userInformation.conId :::'+conId);
        //Query to get the account number
        Account acc=[Select Id, AccountNumber From Account Where Id=: accId];
        System.debug('acc.AccountNumber'+acc.AccountNumber);
        if(acc.AccountNumber == null){
            result = 'Request Product';
        }else{
            result = 'Request Plant';
        }
        return result;
    }
    
    //This method is used to check the user's has product
    @AuraEnabled 
    public static MenuWrapper getMenuInfo(){
        Id conId = userInformation.Contact.Id;
        Id accId = userInformation.Contact.AccountId;
        String result;
        MenuWrapper menu = new MenuWrapper();
        try{
            
            List<Customer_Asset__c> custAsst = [Select Id from Customer_Asset__c where Contact__c =: conId ];
        	/*List<Customer_Plant__c> custPlnt = [Select Id,Contact__r.Account.AccountNumber,status__c from Customer_Plant__c where Contact__c = : conId ];*/
            List<AccountContactRelation> custPlnt = [Select Id,Contact.Account.AccountNumber,status__c from AccountContactRelation where ContactId = : conId ];
            Map<String, YG_Community_Configuration__c> allValues = new Map<String, YG_Community_Configuration__c>();        
        	allValues = YG_Community_Configuration__c.getAll();
            Id selfRegAccId = allValues.get('YGSelfRegisterAccountId').Text_1__c;
            set<string> myset = new set<string>(); 
            
            //to identify Self Reg User
            if(accId == selfRegAccId){
                
                if(custAsst.size() != 0){
                    menu.notify = 0; 
                }
                else{
                    menu.notify = 1;
                }
                menu.systemCount =  1; 
				menu.selfRegUser = true; 
                menu.productCount =  custAsst.size(); 
            }
            else{
              /*  For(Customer_Plant__c cp :custPlnt){ 
                    myset.add(cp.status__c); 
                }*/
                 For(AccountContactRelation cp :custPlnt){ 
                    myset.add(cp.status__c); 
                }
                if(myset.contains('Approved site access'))
                {
                    menu.systemCount =  custPlnt.size(); 
                }else{
                    menu.systemCount =  0; 
                }
                 
                menu.productCount =  custAsst.size(); 
                menu.selfRegUser = false;                
                if(custPlnt.size() == 0 && custAsst.size() == 0){
                    menu.notify = 2; 
                }
            }
            system.debug('menu'+menu);
            
        }
        catch(Exception e){
            system.debug('Exception Cause::'+e.getCause());
            system.debug('Exception LineNumber::'+e.getLineNumber());
            system.debug('Exception Message::'+e.getMessage());
            system.debug('Exception StackTrace::'+e.getStackTraceString());
            system.debug('Exception TypeName::'+e.getTypeName());
            YG_Utility.logError('Menu page','Menu Info Error',e.getStackTraceString(),
                                'Class:YG_CommonController; Method: getMenuInfo(); Line #:'+e.getLineNumber()+'; Message:'+e.getMessage(),
                                UserInfo.getUserId());
        }
        
        
        return menu;
    }
	public class MenuWrapper{
         @AuraEnabled public Integer productCount = 0;
         @AuraEnabled public Integer systemCount = 0;
         @AuraEnabled public Integer notify = 1;
         @AuraEnabled public Boolean selfRegUser;
    }
}