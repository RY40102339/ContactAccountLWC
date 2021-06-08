/*
*******************************************************************************************************
* (C) Copyright 2020 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Selvaraj T
* @version 1.0
* @created 05/05/2020
* @description 
* This utility class is used to get data from user object, custom settings and custom metadata types.
*
* @test class name - YG_UtilityTest
*
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  06/03/2020			Vinod					Modified Code for getting the url from the custom setting. 
*  08/24/2020			Selvaraj T				Modified logged in user info query to get shipping country.
*  09/07/2020			Selvaraj T				Added new method to get logged in users date and time.
*/

public class YG_Utility {
    
    //This method is used to get the logged in user details.
    @AuraEnabled
    public static User getLoggedInUserInfo(Id userId){
        system.debug('userId::'+userId);
        
        User loggedInUser = null;
        
        try{
            
            loggedInUser = [SELECT Id,Name,Username,LastName,FirstName,Email,LanguageLocaleKey,ContactId,Contact.AccountId,Contact.MailingCountry,
                            Contact.Account.ShippingCountry,Contact.Account.AccountNumber,Contact.Name,Contact.Email,Contact.Fax,Contact.Account.Has_Asset__c,
                            Contact.Title,Contact.Department,Contact.Phone,Contact.MobilePhone, Contact.Profile_Image__c, Contact.Account.LastContractSyncAPIDate__c                           
                            FROM USER WHERE Id =: userId];
          
            system.debug('loggedInUser::'+loggedInUser);
            
        }catch(Exception e){
            system.debug('Exception Cause::'+e.getCause());
            system.debug('Exception LineNumber::'+e.getLineNumber());
            system.debug('Exception Message::'+e.getMessage());
            system.debug('Exception StackTrace::'+e.getStackTraceString());
            system.debug('Exception TypeName::'+e.getTypeName());
            YG_Utility.logError('GetUserInfo','Community Component Error',e.getStackTraceString(),
                               'Class:YG_Utility; Method: getLoggedInUserInfo(); Line #:'+e.getLineNumber()+'; Message:'+e.getMessage(),
                               UserInfo.getUserId());
        }
        
        return loggedInUser;
    } 
    
    //This method is called in all apex classes when an error occurred
    public static void logError(String module, String errorType, String errorDescription, String apexName, String userId) {
        if(module.length()>50){
            module = module.substring(0, 49);
        }
        
        if(errorDescription.length()>32768){
            errorDescription = errorDescription.substring(0, 32767);
        }
        
        Id uId = null;
        if(userId!=null){
            uId = Id.valueOf(userId);
        } 
        
        ErrorLog__c error = new ErrorLog__c(Module_ID__c=module,
                                                      Error_Type__c=errorType,
                                                      Error_Description__c=errorDescription,
                                                      Error_Brief__c=apexName,
                                                      Error_Generated_By__c=uId);
        insert error;
    }
     
    /**
     * This method is for getting the community url from custom setting.
     **/ 
    @AuraEnabled
    public static String  getCommunityURL() {
        
        Map<String, YG_Community_Configuration__c> allValues = new Map<String, YG_Community_Configuration__c>();
        
        allValues = YG_Community_Configuration__c.getAll();
        System.debug('::::'+allValues.get('Community URL').Text_1__c);
        
        return allValues.get('Community URL').Text_1__c;
    }
    
    /**
     * This method is for getting the community base url from custom setting.
     **/
    @AuraEnabled
    public static String  getCommunityBaseURL() {
        
        Map<String, YG_Community_Configuration__c> allValues = new Map<String, YG_Community_Configuration__c>();
        
        allValues = YG_Community_Configuration__c.getAll();
        System.debug('::::'+allValues.get('YG Customer Portal Base URL').Text_1__c);
        
        return allValues.get('YG Customer Portal Base URL').Text_1__c;
    }
    
    /**
     * This method is for getting the learn more link url from custom setting for using in the product page.
     **/
    @AuraEnabled
    public static String  getCustomerPortalLMLink() {
        
        Map<String, YG_Community_Configuration__c> allValues = new Map<String, YG_Community_Configuration__c>();
        
        allValues = YG_Community_Configuration__c.getAll();
        System.debug('::::'+allValues.get('Customer Portal LearnMoreLink').Text_1__c);
        
        return allValues.get('Customer Portal LearnMoreLink').Text_1__c;
    }
     
    /**
     * This method is for getting the contact support link url from custom setting for using in the product page.
     **/
    @AuraEnabled
    public static String  getCustomerPortalCSLink() {
        
        Map<String, YG_Community_Configuration__c> allValues = new Map<String, YG_Community_Configuration__c>();
        
        allValues = YG_Community_Configuration__c.getAll();
        System.debug('::::'+allValues.get('Customer Portal ContactSupportLink').Text_1__c);
        
        return allValues.get('Customer Portal ContactSupportLink').Text_1__c;
    }
    
  	//This method is used to get the defaults settings in custom settings
  	@AuraEnabled
    public static Map<String, YG_Community_Configuration__c> getCustomConfig(){
        
        Map<String, YG_Community_Configuration__c> config = new Map<String, YG_Community_Configuration__c>();
        
        config = YG_Community_Configuration__c.getAll();
	    system.debug('config::'+config);

        return config;
    }
    
    //This method is used to get the logged in user local time 
    @AuraEnabled
    public static Datetime getUserLocalTime(){
        
        Datetime localDtTime = null;
        
        try{
            Datetime now = Datetime.now();
            system.debug('now::'+now);
            
            Integer offset = UserInfo.getTimezone().getOffset(now);
            system.debug('offset::'+offset);
            
            localDtTime = now.addSeconds(offset/1000);
            system.debug('localDtTime::'+localDtTime);
        }
        catch(Exception e){
            system.debug('Exception Cause::'+e.getCause());
            system.debug('Exception LineNumber::'+e.getLineNumber());
            system.debug('Exception Message::'+e.getMessage());
            system.debug('Exception StackTrace::'+e.getStackTraceString());
            system.debug('Exception TypeName::'+e.getTypeName());
            YG_Utility.logError('GetUserLocalTime','Community Component Error',e.getStackTraceString(),
                               'Class:YG_Utility; Method: getUserLocalTime(); Line #:'+e.getLineNumber()+'; Message:'+e.getMessage(),
                               UserInfo.getUserId());
        }
        
        return localDtTime;
        
    }
}