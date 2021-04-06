/*
*******************************************************************************************************
* (C) Copyright 2020 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Chitrakishore
* @version 1.0
* @created 02/03/2021
* @description 
* This class is used to write the Apex test class coverage for product API related call.
*
* 
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  
*  
*
*/

@isTest
public class YG_ProductAPIHandlerTest {
    
    static testmethod void productAPITestMethod(){
        
        //Insert test account record
        Account acc = new account();
        acc.name='XYZ Account';        
        //acc.DUNS_Number__c=102224533; 
        insert acc;    

		//Insert test contact record        
        Contact con = new Contact();   
        con.FirstName='User';
        con.LastName='CVX AU';
        con.Email='cvxauuser011@chevron.com';
        con.accountid=acc.id; 
        insert con;
        
        Profile profile = [Select Id From Profile Where Name='Customer Portal User'];
        
        //Insert test customer portal user record   
        User user = new User(Alias = 'comm', Email='yg.qa167@gmail.com',ContactId=con.id,
                             EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                             LocaleSidKey='en_US', ProfileId = profile.Id,
                             TimeZoneSidKey='America/Los_Angeles', UserName='yg.qa167@gmail.com');
        
        insert user;
           
        System.debug('userId'+user.Id);
        
        
        //execute method as portal user   
        System.RunAs(user){
            System.debug('Current User: ' + UserInfo.getUserName());
            System.debug('loggedInUser Id: ' + UserInfo.getUserId());
            System.debug('Current Profile: ' + UserInfo.getProfileId());
            
            User loggedInUser= YG_Utility.getLoggedInUserInfo(UserInfo.getUserId());
                
            YG_Community_Configuration__c systemIdConfig = new YG_Community_Configuration__c(name= 'ShippingAPISystemId',Text_1__c='AxkHnJ89');
            YG_Community_Configuration__c usageAreaConfig = new YG_Community_Configuration__c(name= 'ShippingAPIUsageArea',Text_1__c='1');
            YG_Community_Configuration__c prodEndpointConfig = new YG_Community_Configuration__c(name= 'ShippingAPIEndpointURL',Text_1__c='https://library.yokogawa.com/shipment/search/');
                        
            insert systemIdConfig;
            insert usageAreaConfig;
            insert prodEndpointConfig;
            
            String serialNumber='SU1234567';
            String languageId = 'EN';
                
            Test.setMock(HttpCalloutMock.class, new YG_ProductAPIMockCallout());        
            Test.startTest();       
        
            YG_ProductAPIHandler.searchSerialNoCallout(serialNumber,languageId);
            
            Test.stopTest();
        }
        
    }

}