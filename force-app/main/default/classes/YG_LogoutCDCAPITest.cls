/********************************************************************************************************
* (C) Copyright 2020 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Jayaprasath
* @version 1.0
* @created 02/04/2021
* @description 
* This class is used to write the Apex test class coverage for YG_LogoutCDCAPI.
*
*  Change History:
*  MM/DD/YYYY           Developer Name          Comments
*  04/21/2021			Kavya					Removed Plant__c Object and replaced with Account Object.
*
*/

@isTest
public class YG_LogoutCDCAPITest {
    
    static testmethod void logoutCDCAPITestMethod(){
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
        con.Gigya_UID__c = '48207f845b854397b19b40e972156b62';
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
        User user = new User(Alias = 'comm', Email='yg.test@gmail.com',ContactId=con.id,
                             EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                             LocaleSidKey='en_US', ProfileId = profile.Id,
                             TimeZoneSidKey='America/Los_Angeles', UserName='yg.test@gmail.com');
        
        insert user;
           
        System.debug('userId'+user.Id);
        
         //execute method as portal user   
        System.RunAs(user){
            System.debug('Current User: ' + UserInfo.getUserName());
            System.debug('loggedInUser Id: ' + UserInfo.getUserId());
            System.debug('Current Profile: ' + UserInfo.getProfileId());
            
            User loggedInUser= YG_Utility.getLoggedInUserInfo(UserInfo.getUserId());
            
            YG_Community_Configuration__c userkey = new YG_Community_Configuration__c(name= 'CDC User Key',Text_1__c='AK5wDuYDS/nK');
            YG_Community_Configuration__c secret = new YG_Community_Configuration__c(name= 'CDC Secret Key',Text_1__c='ahIkjsv9iBJuWWyrl5/U9oCR+t7oLg/H');
            YG_Community_Configuration__c apiKey = new YG_Community_Configuration__c(name= 'CDC APIKey',Text_1__c='3_yVCM13to0NZ_YDdZcY8ULjHZ70yEk0mEINhaRbXA7CDd2Ir2jvHnmxrMZ-PUa22V');
            YG_Community_Configuration__c endpointURL = new YG_Community_Configuration__c(name= 'CDC Logout Endpoint URL',Text_1__c='https://accounts.us1.gigya.com/accounts.logout');
            
            insert userkey;
            insert secret;
            insert apiKey;
            insert endpointURL;
            
            String UID = con.Gigya_UID__c;
            
            Test.setMock(HttpCalloutMock.class, new YG_SetAccountInfoAPIMockCallout());
            test.startTest();
            
            YG_LogoutCDCAPI log =new YG_LogoutCDCAPI();
            log.checkSession();
            
            HttpResponse  response = New HttpResponse();                  
            
            try{
            	YG_LogoutCDCAPI.YG_LogoutCDCAPI(con.id);    
                YG_LogoutCDCAPI.YG_LogoutCDCAPI(null);    
            }
            catch(Exception e){
                
            }
            
            Test.stopTest();
        }
    }

}