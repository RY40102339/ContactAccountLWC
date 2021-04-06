/********************************************************************************************************
* (C) Copyright 2020 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Jayaprasath
* @version 1.0
* @created 02/25/2021
* @description 
* This class is used to write the Apex test class coverage for YG_AccountCDCAPI.
*
*  Change History:
*  MM/DD/YYYY           Developer Name          Comments
*  
*
*/

@isTest
public class YG_AccountCDCAPITest {

    static testmethod void accountCDCAPITestMethod(){
        
        //Insert test account record
        Account acc = new account();
        acc.name='XYZ Account';
		acc.AccountNumber = '1234567'; 
        insert acc;    

        
        //Insert test contact record
        Contact con = new Contact();   
        con.FirstName='User';
        con.LastName='CVX AU';
        con.Email='cvxauuser011@chevron.com';
        con.accountid=acc.id; 
        con.Portal_User_Roles__c = 'CA';
        con.Status__c = true;
        insert con;
            
        Profile profile = [Select Id From Profile Where Name='Customer Portal User'];
        
        //Insert test customer portal user record   
        User user = new User(Alias = 'comm', Email='yg.test@gmail.com',ContactId=con.id,
                             EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                             LocaleSidKey='en_US', ProfileId = profile.Id,
                             TimeZoneSidKey='America/Los_Angeles', UserName='yg.test@gmail.com', FederationIdentifier='yg.test@gmail.com');
        
        insert user;
           
        System.debug('userId'+user.Id);
        
         //Inserting test plant record
        List<Plant__c> plantList=new List<Plant__c>();
            Plant__c plant1=new Plant__c();
            plant1.Name = 'TestPlant1';
            plant1.Account__c = acc.Id;  
            plant1.Plant_Code__c = '300000142';
            plant1.Lang_Code__c = 'EN';
            plant1.Location__c ='';
            plant1.Telephone_number__c ='';
            plant1.Fax_number__c ='';
        	plant1.Plant_Name__c = 'TestPlant1';
        plantList.add(plant1);
        
        Plant__c plant2=new Plant__c();
            plant2.Name = 'TestPlant2';
            plant2.Account__c = acc.Id;  
            plant2.Plant_Code__c = '300000123';
            plant2.Lang_Code__c = 'EN';
            plant2.Location__c ='MY';
            plant2.Telephone_number__c ='1265545';
            plant2.Fax_number__c ='12135665';
        	plant2.Plant_Name__c = 'TestPlant2';
        plantList.add(plant2); 
        
        insert plantList;
        
         //execute method as portal user   
        System.RunAs(user){
            System.debug('Current User: ' + UserInfo.getUserName());
            System.debug('loggedInUser Id: ' + UserInfo.getUserId());
            System.debug('Current Profile: ' + UserInfo.getProfileId());
            
            User loggedInUser= YG_Utility.getLoggedInUserInfo(UserInfo.getUserId());
            
            YG_Community_Configuration__c selfRegAcc = new YG_Community_Configuration__c(name= 'YGSelfRegisterAccountId',Text_1__c=acc.id);
            YG_Community_Configuration__c prfID = new YG_Community_Configuration__c(name= 'Customer Portal User ProfileId',Text_1__c=profile.id);
			YG_Community_Configuration__c apiKey = new YG_Community_Configuration__c(name= 'CDC APIKey',Text_1__c='3_B2wrSrOEFEWC_Pc6DQI0NmyU9SrKJhNgNzFRNDQAUsmmGDa5HLbf0AlgwnnXOwVr');
            YG_Community_Configuration__c userkey = new YG_Community_Configuration__c(name= 'CDC User Key',Text_1__c='AK5wDuYDS/nK');
            YG_Community_Configuration__c secret = new YG_Community_Configuration__c(name= 'CDC Secret Key',Text_1__c='ahIkjsv9iBJuWWyrl5/U9oCR+t7oLg/H');
            YG_Community_Configuration__c endpointURL = new YG_Community_Configuration__c(name= 'CDC getAccountInfo Endpoint URL',Text_1__c='https://accounts.us1.gigya.com/accounts.getAccountInfo');
            YG_Community_Configuration__c systemIdConfig = new YG_Community_Configuration__c(name= 'ShippingAPISystemId',Text_1__c='AxkHnJ89');
            YG_Community_Configuration__c endpointConfig = new YG_Community_Configuration__c(name= 'PlantAPIEndpointUrl',Text_1__c='https://library.yokogawa.com/plantcrm/search/');
            
            insert selfRegAcc;
            insert prfID;
            insert apiKey;
        	insert userkey;
            insert secret;
            insert endpointURL;     
            insert systemIdConfig;
			insert endpointConfig;
            
            String apiK = apiKey.Text_1__c;
            
            String resp = '{ '+
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
                  '"role": "CU"'+
                '},'+
                '"phone": "911234567890",'+
                '"companyname": "Verticurl",'+
                '"snow": {'+
                  '"primaryadmin": "false"'+
                '},'+
                '"idportal_auth": "0",'+
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
                  '"anand.selvarasu123@verticurl.com"'+
                '],'+
                '"unverified": ['+
                  '"anand123.selvarasu123@verticurl.com"'+
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
                '"email": "anand.selvarasu123@verticurl.com",'+
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
            
            String resp1 = '{ '+
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
                '"account_number": "1234567",'+
                '"login_permission_customerportal": "on",'+
                '"language": "en",'+
                '"custportal_userID": "anand.selvarasu-20201211064708@verticurl.com",'+
                '"login_permission_snow": "false",'+
                '"customerportal": {'+
                  '"role": "CU"'+
                '},'+
                '"phone": "911234567890",'+
                '"companyname": "Verticurl",'+
                '"snow": {'+
                  '"primaryadmin": "false"'+
                '},'+
                '"idportal_auth": "0",'+
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
                  '"anand.selvarasu123@verticurl.com"'+
                '],'+
                '"unverified": ['+
                  '"anand123.selvarasu123@verticurl.com"'+
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
                '"email": "anand.selvarasu123@verticurl.com",'+
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
            

        	Test.setMock(HttpCalloutMock.class, new YG_GetAccountCDCAPIMockCallout());
            test.startTest();
            
            try{
                
                
                YG_WebHookRestResource.Request_Info requestInfo = new YG_WebHookRestResource.Request_Info();
                YG_WebHookRestResource.Events event = new YG_WebHookRestResource.Events();
                YG_WebHookRestResource.Data data = new YG_WebHookRestResource.Data();
                List<YG_WebHookRestResource.Events> events = new List<YG_WebHookRestResource.Events>();
                
                data.accountType = 'full';
                data.uid = 'e2304ca2955b42b49006483818fc175c';
                
                event.apiKey = apiK;
                event.callId = 'a4e6ec632db048e3b0NmyU9SrKJhNgNzFRNDQAUsmmGDa5HLbf0AlgwnnXOwVr';
                event.data = data;
                event.id = 'b11f9df0-08f9-4106-96b4-494c0105edfd';
                event.timestamp = '1605777558';
                event.type = 'accountUpdated';
                events.add(event);
                
                requestInfo.events = events;
                requestInfo.nonce = 'de97dd12-a0b0-4208-be92-ef0bac0bd0c3';
                requestInfo.timestamp ='1605777560';
                
                //Instantiate the Rest Context
                RestRequest req = new RestRequest();
                RestResponse res = new RestResponse();
                
                req.requestURI = '/services/apexrest/notificationlistener';	//Request URL
                req.httpMethod = 'POST'; //Request Type
                req.requestBody = Blob.valueof(JSON.serialize(requestInfo, true));
                RestContext.request = req;
                RestContext.response =res;
                
                YG_WebHookRestResource.Response_Info response = new YG_WebHookRestResource.Response_Info();
                response = YG_WebHookRestResource.doPost();
                System.debug('Response ::: '+response);
                
            	YG_AccountCDCAPI.callAccountAPIInfo(resp);
                YG_AccountCDCAPI.callAccountAPIInfo(resp1);
            }
            catch(Exception e){
                
            }
            
            Test.stopTest();
        }
	}
}