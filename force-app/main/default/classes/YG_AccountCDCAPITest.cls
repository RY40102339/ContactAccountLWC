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
        acc.Type = 'Customer';
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
            List<Account> plantList=new List<Account>();
            Account plant1=new Account();
            plant1.Name = 'TestPlant1';
            plant1.ParentId = acc.Id;  
            plant1.AccountNumber = '300000142';
          	plant1.Type = 'Plant';
            plant1.ShippingPostalCode ='';
            plant1.ShippingStreet = '';
            plant1.Phone ='';
            plant1.Fax ='';
        Insert plant1;
        //plantList.add(plant1);
        
      
         Account plant2=new Account();
            plant2.Name = 'TestPlant2';
            plant2.ParentId = acc.Id;  
            plant2.AccountNumber = '300000123';
          	plant2.Type = 'Plant';
            plant2.ShippingPostalCode ='';
         	plant2.ShippingStreet = '';
            plant2.Phone ='1265545';
            plant2.Fax ='12135665';
        	Insert plant2;
        //plantList.add(plant2);
        //insert plantList;
        System.debug('plantList:::'+plantList);
        
        AccountContactRelation accCon1=new AccountContactRelation();
        accCon1.AccountId = plant1.Id;
        accCon1.ContactId = con.Id;
        accCon1.Status__c = 'Approved site access';
        Insert accCon1;
        
        AccountContactRelation accCon2=new AccountContactRelation();
        accCon2.AccountId = plant2.Id;
        accCon2.ContactId = con.Id;
        accCon2.Status__c = 'Approved site access';
        Insert accCon2;
        
        
        
        Profile profile = [Select Id From Profile Where Name='Customer Portal User'];
        //UserRole userrole = [Select Id, DeveloperName From UserRole Limit 1];
        //Insert test customer portal user record   
        User user = new User(Alias = 'comm', Email='yg.test@gmail.com',ContactId=con.id,
                             EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                             LocaleSidKey='en_US', ProfileId = profile.Id,
                             TimeZoneSidKey='America/Los_Angeles', UserName='yg.test@gmail.com', FederationIdentifier='yg.test@gmail.com');
        
        insert user;
        
       // User adminUser = [Select Id, UserRoleId From User Where Profile.Name = 'Customer Portal User' Limit 1];
        
        //adminUser.UserRoleId = userRole.Id;
        //update adminUser;

        

        System.debug('userId'+user.Id);
        
         
        
         //execute method as portal user   
        System.RunAs(user){
            System.debug('Current User: ' + UserInfo.getUserName());
            System.debug('loggedInUser Id: ' + UserInfo.getUserId());
            System.debug('Current Profile: ' + UserInfo.getProfileId());
            User loggedInUser= YG_Utility.getLoggedInUserInfo(UserInfo.getUserId());
            
            String userId = user.Id;
            List<AccountContactRelation> accCon = YG_HelperClass.getCusPlantInfo(loggedInUser.ContactId);
            System.debug('***+ '+accCon);
            List<YG_Community_Configuration__c> lstConf = new List<YG_Community_Configuration__c>(); 
            YG_Community_Configuration__c selfRegAcc = new YG_Community_Configuration__c(name= 'YGSelfRegisterAccountId',Text_1__c=acc.id);
            YG_Community_Configuration__c prfID = new YG_Community_Configuration__c(name= 'Customer Portal User ProfileId',Text_1__c=profile.id);
			YG_Community_Configuration__c apiKey = new YG_Community_Configuration__c(name= 'CDC APIKey',Text_1__c='3_B2wrSrOEFEWC_Pc6DQI0NmyU9SrKJhNgNzFRNDQAUsmmGDa5HLbf0AlgwnnXOwVr');
            YG_Community_Configuration__c userkey = new YG_Community_Configuration__c(name= 'CDC User Key',Text_1__c='AK5wDuYDS/nK');
            YG_Community_Configuration__c secret = new YG_Community_Configuration__c(name= 'CDC Secret Key',Text_1__c='ahIkjsv9iBJuWWyrl5/U9oCR+t7oLg/H');
            YG_Community_Configuration__c endpointURL = new YG_Community_Configuration__c(name= 'CDC getAccountInfo Endpoint URL',Text_1__c='https://accounts.us1.gigya.com/accounts.getAccountInfo');
            YG_Community_Configuration__c systemIdConfig = new YG_Community_Configuration__c(name= 'ShippingAPISystemId',Text_1__c='AxkHnJ89');
            YG_Community_Configuration__c endpointConfig = new YG_Community_Configuration__c(name= 'PlantAPIEndpointUrl',Text_1__c='https://library.yokogawa.com/plantcrm/search/');
            YG_Community_Configuration__c adminSOE = new YG_Community_Configuration__c(name= 'Admin SoE',Text_1__c=userId);
            YG_Community_Configuration__c CDCSetAccInfoURL = new YG_Community_Configuration__c(name= 'CDC setAccountInfo Endpoint URL',Text_1__c='https://accounts.us1.gigya.com/accounts.setAccountInfo');
            
            lstConf.add(selfRegAcc);
            lstConf.add(prfID);
            lstConf.add(apiKey);
            lstConf.add(userkey);
            lstConf.add(secret);
            lstConf.add(endpointURL);
            lstConf.add(systemIdConfig);
            lstConf.add(endpointConfig);
            lstConf.add(adminSOE);
            lstConf.add(CDCSetAccInfoURL);
            
            insert lstConf;
            
            String apiK = apiKey.Text_1__c;
            

            
        	Test.setMock(HttpCalloutMock.class, new YG_GetAccountCDCAPIMockCallout());
            test.startTest();
            
            //try{
                
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
                //YG_AccountCDCAPI.callAccountAPIInfo(resp1);
            	//YG_AccountCDCAPI.callAccountAPIInfo(resp);
                //YG_AccountCDCAPI.callAccountAPIInfo(resp1);
            //}
            //catch(Exception e){
                
            //}
            
            Test.stopTest();
        }
		
    }
    static testmethod void accountCDCAPITestMethod2(){
        
        //Insert test account record
        Account acc = new account();
        acc.name='XYZ Account';
        acc.Type = 'Customer';
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
            List<Account> plantList=new List<Account>();
            Account plant1=new Account();
            plant1.Name = 'TestPlant1';
            plant1.ParentId = acc.Id;  
            plant1.AccountNumber = '300000142';
          	plant1.Type = 'Plant';
            plant1.ShippingPostalCode ='';
            plant1.ShippingStreet = '';
            plant1.Phone ='';
            plant1.Fax ='';
        Insert plant1;
        //plantList.add(plant1);
        
      
         Account plant2=new Account();
            plant2.Name = 'TestPlant2';
            plant2.ParentId = acc.Id;  
            plant2.AccountNumber = '300000123';
          	plant2.Type = 'Plant';
            plant2.ShippingPostalCode ='';
         	plant2.ShippingStreet = '';
            plant2.Phone ='1265545';
            plant2.Fax ='12135665';
        	Insert plant2;
        //plantList.add(plant2);
        //insert plantList;
        System.debug('plantList:::'+plantList);
        
        AccountContactRelation accCon1=new AccountContactRelation();
        accCon1.AccountId = plant1.Id;
        accCon1.ContactId = con.Id;
        accCon1.Status__c = 'Approved site access';
        Insert accCon1;
        
        AccountContactRelation accCon2=new AccountContactRelation();
        accCon2.AccountId = plant2.Id;
        accCon2.ContactId = con.Id;
        accCon2.Status__c = 'Approved site access';
        Insert accCon2;
        
        
        
        Profile profile = [Select Id From Profile Where Name='Customer Portal User'];
        
        //Insert test customer portal user record   
        User user = new User(Alias = 'comm', Email='yg.test@gmail.com',ContactId=con.id,
                             EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                             LocaleSidKey='en_US', ProfileId = profile.Id,
                             TimeZoneSidKey='America/Los_Angeles', UserName='yg.test@gmail.com', FederationIdentifier='yg.test@gmail.com');
        
        insert user;
        
        System.debug('userId'+user.Id);
        
         
        
         //execute method as portal user   
        System.RunAs(user){
            System.debug('Current User: ' + UserInfo.getUserName());
            System.debug('loggedInUser Id: ' + UserInfo.getUserId());
            System.debug('Current Profile: ' + UserInfo.getProfileId());
            User loggedInUser= YG_Utility.getLoggedInUserInfo(UserInfo.getUserId());
            
            String userId = user.Id;
            List<AccountContactRelation> accCon = YG_HelperClass.getCusPlantInfo(loggedInUser.ContactId);
            System.debug('***+ '+accCon);
            List<YG_Community_Configuration__c> lstConf = new List<YG_Community_Configuration__c>(); 
            YG_Community_Configuration__c selfRegAcc = new YG_Community_Configuration__c(name= 'YGSelfRegisterAccountId',Text_1__c=acc.id);
            YG_Community_Configuration__c prfID = new YG_Community_Configuration__c(name= 'Customer Portal User ProfileId',Text_1__c=profile.id);
			YG_Community_Configuration__c apiKey = new YG_Community_Configuration__c(name= 'CDC APIKey',Text_1__c='3_B2wrSrOEFEWC_Pc6DQI0NmyU9SrKJhNgNzFRNDQAUsmmGDa5HLbf0AlgwnnXOwVr');
            YG_Community_Configuration__c userkey = new YG_Community_Configuration__c(name= 'CDC User Key',Text_1__c='AK5wDuYDS/nK');
            YG_Community_Configuration__c secret = new YG_Community_Configuration__c(name= 'CDC Secret Key',Text_1__c='ahIkjsv9iBJuWWyrl5/U9oCR+t7oLg/H');
            YG_Community_Configuration__c endpointURL = new YG_Community_Configuration__c(name= 'CDC getAccountInfo Endpoint URL',Text_1__c='https://accounts.us1.gigya.com/accounts.getAccountInfo');
            YG_Community_Configuration__c systemIdConfig = new YG_Community_Configuration__c(name= 'ShippingAPISystemId',Text_1__c='AxkHnJ89');
            YG_Community_Configuration__c endpointConfig = new YG_Community_Configuration__c(name= 'PlantAPIEndpointUrl',Text_1__c='https://library.yokogawa.com/plantcrm/search/');
            YG_Community_Configuration__c adminSOE = new YG_Community_Configuration__c(name= 'Admin SoE',Text_1__c=userId);
            YG_Community_Configuration__c CDCSetAccInfoURL = new YG_Community_Configuration__c(name= 'CDC setAccountInfo Endpoint URL',Text_1__c='https://accounts.us1.gigya.com/accounts.setAccountInfo');
            
            lstConf.add(selfRegAcc);
            lstConf.add(prfID);
            lstConf.add(apiKey);
            lstConf.add(userkey);
            lstConf.add(secret);
            lstConf.add(endpointURL);
            lstConf.add(systemIdConfig);
            lstConf.add(endpointConfig);
            lstConf.add(adminSOE);
            lstConf.add(CDCSetAccInfoURL);
            
            insert lstConf;
            
            String apiK = apiKey.Text_1__c;
            

            
        	Test.setMock(HttpCalloutMock.class, new YG_GetAccountCDCAPIMockCallout2());
            test.startTest();
            
            //try{
                
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
                //YG_AccountCDCAPI.callAccountAPIInfo(resp1);
            	//YG_AccountCDCAPI.callAccountAPIInfo(resp);
                //YG_AccountCDCAPI.callAccountAPIInfo(resp1);
            //}
            //catch(Exception e){
                
            //}
            
            Test.stopTest();
        }
		
    }
    
}