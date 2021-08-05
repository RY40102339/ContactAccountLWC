/*
*******************************************************************************************************
* (C) Copyright 2020 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Chitrakishore
* @version 1.0
* @created 27/01/2021
* @description 
* This class is used to write the Apex test class coverage for Case API Mock Callout.
*
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  04/21/2021			Kavya					Removed Plant__c Object and replaced with Account Object.
*  
*
*/

@isTest
public class YG_OfficeAPITest {
    
    static testmethod void officeAPITestMethod(){
        
        //Insert test account record
        Account acc = new account();
        acc.name='XYZ Account'; 
         acc.Type = 'Customer';
        insert acc;    

        //Insert test contact record        
        Contact con = new Contact();   
        con.FirstName='User';
        con.LastName='CVX AU';
        con.Email='cvxauuser011@chevron.com';
        con.accountid=acc.id; 
        insert con;

        //Inserting test plant record
       /* List<Plant__c> plantList=new List<Plant__c>();
        Plant__c plant1=new Plant__c();
        plant1.Name = 'TestPlantDoc';
        plant1.Account__c = acc.Id;  
        plant1.Plant_Code__c = '300000142';
        plant1.Lang_Code__c = 'EN';
        plantList.add(plant1);
        insert plantList;*/
        
        //Inserting test plant record
        List<Account> plantList=new List<Account>();
        Account plant1=new Account();
        plant1.Name = 'TestPlantDoc';
        plant1.ParentId = acc.Id;  
        plant1.AccountNumber = '300000142';
         plant1.Type = 'Plant';
        plantList.add(plant1);
        insert plantList;
        
       
        
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
            //System.debug('Current User: ' + UserInfo.getUserName());
            //System.debug('loggedInUser Id: ' + UserInfo.getUserId());
            //System.debug('Current Profile: ' + UserInfo.getProfileId());
            
            User loggedInUser= YG_Utility.getLoggedInUserInfo(UserInfo.getUserId());
            
            YG_Community_Configuration__c systemIdConfig = new YG_Community_Configuration__c(name= 'ShippingAPISystemId',Text_1__c='AxkHnJ89');
            YG_Community_Configuration__c endpointConfig = new YG_Community_Configuration__c(name= 'OfficeAPIEndPointURL',Text_1__c='https://dev-library.yokogawa.com:8180/entity/search');
            
            insert systemIdConfig;
            insert endpointConfig;
            
            Test.setMock(HttpCalloutMock.class, new YG_OfficeAPIMockCallout());
            test.startTest();
            
            HttpResponse  response = New HttpResponse();
                                  
            String countryCode ='EN';
            String classificationCode ='1';
            String officeType='1';
            YG_OfficeAPI.callOfficeAPIInfo(countryCode,classificationCode,officeType);
                
                
            Test.stopTest();
        }
	}

}