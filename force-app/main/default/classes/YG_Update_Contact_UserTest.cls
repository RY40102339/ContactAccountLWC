/*
*******************************************************************************************************
* (C) Copyright 2020 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Jayaprasath
* @version 1.0
* @created 02/25/2021
* @description 
* This test class for YG_Update_Contact_User apex class.
*
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  
*
*/

@isTest
public class YG_Update_Contact_UserTest {
    
    @isTest 
    static void updateProfileTestMethod() {
      
        //Insert test account record
        Account acc = new account();
        acc.name='XYZ Account';
		acc.AccountNumber = '123456'; 
        insert acc;    

        
        //Insert test contact record
        Contact con = new Contact();   
        con.FirstName='User';
        con.LastName='CVX AU';
        con.Email='cvxauuser011@chevron.com';
        con.accountid=acc.id; 
        con.Portal_User_Roles__c = 'CU';
        con.Status__c = true;
        con.Gigya_UID__c = '48207f845b854397b19b40e972156b62';
        con.MailingCity = 'tup';
        con.MailingState = 'tn';
        insert con;
            
        Profile profile = [Select Id From Profile Where Name='Customer Portal User'];
        
        //Insert test customer portal user record   
        User user = new User(Alias = 'comm', Email='yg.test@gmail.com',ContactId=con.id,
                             EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                             LocaleSidKey='en_US', ProfileId = profile.Id,
                             TimeZoneSidKey='America/Los_Angeles', UserName='yg.test@gmail.com', FederationIdentifier='yg.test@gmail.com');
        
        insert user;
           
        System.debug('userId'+user.Id);
        
			
		//Insert test account record
        Account acc1 = new account();
        acc1.name='XYZ Account';
		acc1.AccountNumber = '234567'; 
        insert acc1;    

        
        //Insert test contact record
        Contact con1 = new Contact();   
        con1.FirstName='User1';
        con1.LastName='CVX AU1';
        con1.Email='cvxauuser01123@chevron.com';
        con1.accountid=acc1.id; 
        con1.Portal_User_Roles__c = 'CA';
        con1.Status__c = true;
        con1.Gigya_UID__c = '48207f845b854397b19b40e972156b72';
        con1.MailingCity = 'cbe';
        con1.MailingState = 'tn';
        insert con1;
            
        Profile profile1 = [Select Id From Profile Where Name='Customer Portal User'];
        
        //Insert test customer portal user record   
        User user1 = new User(Alias = 'comm', Email='yg1.test@gmail.com',ContactId=con1.id,
                             EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                             LocaleSidKey='en_US', ProfileId = profile1.Id,
                             TimeZoneSidKey='America/Los_Angeles', UserName='yg1.test@gmail.com', FederationIdentifier='yg1.test@gmail.com');
        
        insert user1;
        
        Plant__c plant1=new Plant__c();
            plant1.Name = 'TestPlant1';
            plant1.Account__c = acc1.Id;  
            plant1.Plant_Code__c = '300000142';
            plant1.Lang_Code__c = 'EN';
            plant1.Location__c ='';
            plant1.Telephone_number__c ='';
            plant1.Fax_number__c ='';
        	plant1.Plant_Name__c = 'TestPlant1';
        	insert plant1;
        
        Plant__c plant2=new Plant__c();
            plant2.Name = 'TestPlant2';
            plant2.Account__c = acc1.Id;  
            plant2.Plant_Code__c = '300000123';
            plant2.Lang_Code__c = 'EN';
            plant2.Location__c ='MY';
            plant2.Telephone_number__c ='1265545';
            plant2.Fax_number__c ='12135665';
        	plant2.Plant_Name__c = 'TestPlant2';
        	insert plant2;
        
        Customer_Plant__c cusPlant1 = new Customer_Plant__c();
        	cusPlant1.Contact__c = con1.id;
            cusPlant1.Status__c = 'Decline site access';
            cusPlant1.Plant__c = plant1.id;
        	insert cusPlant1;

		        
         
            System.debug('Current User: ' + UserInfo.getUserName());
            System.debug('loggedInUser Id: ' + UserInfo.getUserId());
            System.debug('Current Profile: ' + UserInfo.getProfileId());
            
            User loggedInUser= YG_Utility.getLoggedInUserInfo(UserInfo.getUserId());
            
            YG_Community_Configuration__c selfRegAcc = new YG_Community_Configuration__c(name= 'YGSelfRegisterAccountId',Text_1__c=acc.id);
            YG_Community_Configuration__c prfID = new YG_Community_Configuration__c(name= 'Customer Portal User ProfileId',Text_1__c=profile.Id);
           	YG_Community_Configuration__c systemIdConfig = new YG_Community_Configuration__c(name= 'ShippingAPISystemId',Text_1__c='AxkHnJ89');
            YG_Community_Configuration__c usageAreaConfig = new YG_Community_Configuration__c(name= 'ShippingAPIUsageArea',Text_1__c='1');
            YG_Community_Configuration__c endpointConfig = new YG_Community_Configuration__c(name= 'PlantAPIEndpointUrl',Text_1__c='https://library.yokogawa.com/plantcrm/search/');
            
            insert systemIdConfig;
            insert usageAreaConfig;
            insert endpointConfig;
            insert selfRegAcc;
            insert prfID;
            
            
            String res = '{ '+
              '"callId": "daba91000c0141f499343054d53b8627",'+
              '"errorCode": 0,'+
              '"apiVersion": 2,'+
              '"statusCode": 200,'+
              '"statusReason": "OK",'+
              '"time": "2021-02-02T09:28:43.037Z",'+
              '"registeredTimestamp": 1607669228000,'+
              '"UID": "48207f845b854397b19b40e972156b62",'+
              '"created": "2020-12-11T06:47:08.492Z",'+
              '"createdTimestamp": 1607669228000,'+
              '"data": {'+
                '"ProfileID": "00ep0000000IVAO",'+
                '"login_permission_customerportal": "on",'+
                '"language": "en",'+
                '"custportal_userID": "anand.selvarasu-20201211064708@verticurl.com",'+
                '"login_permission_snow": "false",'+
                '"customerportal": {'+
                  '"role": "CA"'+
                '},'+
                '"phone": "911234567890",'+
                '"companyname": "Verticurl",'+
                '"snow": {'+
                  '"primaryadmin": "false"'+
                '},'+
                '"idportal_auth": "1",'+
                '"job_title": "Verticurl",'+
                '"account": "Verticurl"'+
              '},'+
              '"subscriptions": {},'+
              '"preferences": {'+
                '"terms": {'+
                  '"lca_terms": {'+
                    '"isConsentGranted": true,'+
                    '"docDate": "2020-04-19T00:00:00Z",'+
                    '"lastConsentModified": "2020-12-11T06:47:08.617Z",'+
                    '"tags": [],'+
                    '"customData": [],'+
                    '"entitlements": []'+
                  '}'+
                '},'+
                '"privacy": {'+
                  '"lca_privacy": {'+
                    '"isConsentGranted": true,'+
                    '"docDate": "2020-04-23T00:00:00Z",'+
                    '"lastConsentModified": "2020-12-11T06:47:08.617Z",'+
                    '"tags": [],'+
                    '"customData": [],'+
                    '"entitlements": []'+
                  '}'+
                '}'+
              '},'+
              '"emails": {'+
                '"verified": ['+
                  '"anand.selvarasu@verticurl.com"'+
                '],'+
                '"unverified": ['+
                  '"anand123.selvarasu@verticurl.com"'+
                ']'+
              '},'+
              '"isActive": true,'+
              '"isRegistered": true,'+
              '"isVerified": true,'+
              '"lastLogin": "2021-02-02T06:33:10.283Z",'+
              '"lastLoginTimestamp": 1612247590000,'+
              '"lastUpdated": "2021-01-28T05:24:58.176Z",'+
              '"lastUpdatedTimestamp": 1611811498176,'+
              '"loginProvider": "site",'+
              '"oldestDataUpdated": "2020-12-11T06:47:08.492Z",'+
              '"oldestDataUpdatedTimestamp": 1607669228492,'+
              '"profile": {'+
                '"firstName": "Anand",'+
                '"lastName": "Selvarasu",'+
                '"address": "Testing",'+
                '"country": "IN",'+
                '"email": "anand.selvarasu@verticurl.com",'+
                '"phones": {'+
                  '"number": "+911234567890"'+
                '},'+
                '"photoURL": "https://dev1-yg.cs31.force.com/servlet/servlet.ImageServer?id=015p0000000kzJgAAI&oid=00Dp00000004u6mEAA",'+
                '"zip": "641002"'+
              '},'+
              '"registered": "2020-12-11T06:47:08.763Z",'+
              '"socialProviders": "site",'+
              '"verified": "2021-01-21T15:48:10.580Z",'+
              '"verifiedTimestamp": 1611244090580'+
              
            '}';
            
        
			String res1 = '{ '+
              '"callId": "daba91000c0141f499343054d53b8627",'+
              '"errorCode": 0,'+
              '"apiVersion": 2,'+
              '"statusCode": 200,'+
              '"statusReason": "OK",'+
              '"time": "2021-02-02T09:28:43.037Z",'+
              '"registeredTimestamp": 1607669228000,'+
              '"UID": "48207f845b854397b19b40e972156b72",'+
              '"created": "2020-12-11T06:47:08.492Z",'+
              '"createdTimestamp": 1607669228000,'+
              '"data": {'+
                '"ProfileID": "00ep0000000IVAO",'+
                '"account_number": "234567",'+
                '"login_permission_customerportal": "on",'+
                '"language": "en",'+
                '"custportal_userID": "anand.selvarasu-20201211064708@verticurl.com",'+
                '"login_permission_snow": "false",'+
                '"customerportal": {'+
                  '"role": "SA"'+
                '},'+
                '"phone": "911234567890",'+
                '"companyname": "Verticurl1",'+
                '"snow": {'+
                  '"primaryadmin": "false"'+
                '},'+
                '"idportal_auth": "3",'+
                '"job_title": "Verticurl1",'+
                '"account": "Verticurl1"'+
              '},'+
              '"subscriptions": {},'+
              '"preferences": {'+
                '"terms": {'+
                  '"lca_terms": {'+
                    '"isConsentGranted": true,'+
                    '"docDate": "2020-04-19T00:00:00Z",'+
                    '"lastConsentModified": "2020-12-11T06:47:08.617Z",'+
                    '"tags": [],'+
                    '"customData": [],'+
                    '"entitlements": []'+
                  '}'+
                '},'+
                '"privacy": {'+
                  '"lca_privacy": {'+
                    '"isConsentGranted": true,'+
                    '"docDate": "2020-04-23T00:00:00Z",'+
                    '"lastConsentModified": "2020-12-11T06:47:08.617Z",'+
                    '"tags": [],'+
                    '"customData": [],'+
                    '"entitlements": []'+
                  '}'+
                '}'+
              '},'+
              '"emails": {'+
                '"verified": ['+
                  '"anand.selvarasu1@verticurl.com"'+
                '],'+
                '"unverified": ['+
                  '"anand123.selvarasu1@verticurl.com"'+
                ']'+
              '},'+
              '"isActive": true,'+
              '"isRegistered": true,'+
              '"isVerified": true,'+
              '"lastLogin": "2021-02-02T06:33:10.283Z",'+
              '"lastLoginTimestamp": 1612247590000,'+
              '"lastUpdated": "2021-01-28T05:24:58.176Z",'+
              '"lastUpdatedTimestamp": 1611811498176,'+
              '"loginProvider": "site",'+
              '"oldestDataUpdated": "2020-12-11T06:47:08.492Z",'+
              '"oldestDataUpdatedTimestamp": 1607669228492,'+
              '"profile": {'+
                '"firstName": "Anand1",'+
                '"lastName": "Selvarasu1",'+
                '"address": "Testing1",'+
                '"country": "US",'+
                '"city": "cbe",'+
                '"state": "ka",'+
                '"email": "anand.selvarasu1@verticurl.com",'+
                '"phones": {'+
                  '"number": "+911234567880"'+
                '},'+
                '"photoURL": "https://dev1-yg.cs31.force.com/servlet/servlet.ImageServer?id=015p0000000kzJgAAI&oid=00Dp00000004u6mEAA",'+
                '"zip": "6410021"'+
              '},'+
              '"registered": "2020-12-11T06:47:08.763Z",'+
              '"socialProviders": "site",'+
              '"verified": "2021-01-21T15:48:10.580Z",'+
              '"verifiedTimestamp": 1611244090580'+
              
            '}';            
            
          //execute method as portal user   
         test.startTest();
            
        System.RunAs(user){
            Test.setMock(HttpCalloutMock.class, new YG_PlantAPIMockCallout());
            try{                
                YG_Update_Contact_User.updateContact(res);
                YG_Update_Contact_User.updateUser(res1);
            }
            catch(Exception e){
                
            } 
        }
        
        
        System.RunAs(user1){
            Test.setMock(HttpCalloutMock.class, new YG_PlantAPIMockCallout());
            
            try{                
                YG_Update_Contact_User.updateContact(res1);
            }
            catch(Exception e){
                
            }            
        }
            Test.stopTest();
	}
}