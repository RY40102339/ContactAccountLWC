/*
*******************************************************************************************************
* (C) Copyright 2020 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Selvaraj T
* @version 1.0
* @created 30/09/2020
* @description 
* This test class for YG_UpdateProfileController apex class.
*
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  
*
*/

@isTest
public class YG_UpdateProfileControllerTest {
    
    @isTest static void updateProfileTestMethod() {
        
        //Inserting test account record
        Account acc = new account();
        acc.name='XYZ Account';  
        insert acc; 
        
        //Inserting test contact record
        List<Contact> conList = new List<Contact>();
        Contact con = new Contact();   
        con.FirstName='User';
        con.LastName='CVX AU';
        con.Email='cvxauuser011@chevron.com';
        con.Phone = '12345';
        con.accountid=acc.id; 
        
        conList.add(con);
        
        Contact con1 = new Contact();
        con.FirstName='User1';
        con1.LastName='CVX AU';
        con1.accountid=acc.id;
        con1.email='jp@test.com';
        con1.Phone = '12345';
        con1.Gigya_UID__c= '7425852741';
        con1.status__c = true;
        conList.add(con1);
        
        insert conList;
        
        //Inserting test portal user record
        Profile profile = [Select Id From Profile Where Name='Customer Portal User'];
        List<User> usrList = new List<User>();
        User user = new User(Alias = 'comm', Email='yg.qa167@gmail.com',ContactId=con.id,
                             EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                             LocaleSidKey='en_US', ProfileId = profile.Id,
                             TimeZoneSidKey='America/Los_Angeles', UserName='yg.qa167@gmail.com');
        usrList.add(user);
        
        User user1 = new User(Alias = 'comm', Email='yg.qa168@gmail.com',ContactId=con1.id,
                             EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                             LocaleSidKey='en_US', ProfileId = profile.Id,
                             TimeZoneSidKey='America/Los_Angeles', UserName='jp@test.com');
        usrList.add(user1);
        
        insert usrList;
        
        
            
            YG_Community_Configuration__c userkey = new YG_Community_Configuration__c(name= 'CDC User Key',Text_1__c='AK5wDuYDS/nK');
            YG_Community_Configuration__c secret = new YG_Community_Configuration__c(name= 'CDC Secret Key',Text_1__c='ahIkjsv9iBJuWWyrl5/U9oCR+t7oLg/H');
            YG_Community_Configuration__c apiKey = new YG_Community_Configuration__c(name= 'CDC APIKey',Text_1__c='3_yVCM13to0NZ_YDdZcY8ULjHZ70yEk0mEINhaRbXA7CDd2Ir2jvHnmxrMZ-PUa22V');
            YG_Community_Configuration__c endpointURL = new YG_Community_Configuration__c(name= 'CDC setAccountInfo Endpoint URL',Text_1__c='https://accounts.us1.gigya.com/accounts.setAccountInfo');
            YG_Community_Configuration__c basURL = new YG_Community_Configuration__c(name= 'YG Customer Portal Base URL',Text_1__c='001p000000tzRDXAA2');
            insert userkey;
            insert secret;
            insert apiKey;
            insert endpointURL;
        	insert basURL;
            
        String UID = con1.Gigya_UID__c;
        
        System.RunAs(user1){
            Test.setMock(HttpCalloutMock.class, new YG_SetAccountInfoAPIMockCallout());
            test.startTest();
            
            try{
                User loggedInUser= YG_Utility.getLoggedInUserInfo(UserInfo.getUserId());
                
                contact cont = YG_UpdateProfileController.getContactDetails();
                
                Boolean isSuccess = YG_UpdateProfileController.updateContactData(cont,'jp.jpg','');
                Boolean isSuccess1 = YG_UpdateProfileController.updateContactData(null,null,null);
                
				YG_UpdateProfileController.emailValidationWap em = new YG_UpdateProfileController.emailValidationWap();
                em = YG_UpdateProfileController.emailValidate('jp@test.com');
                em = YG_UpdateProfileController.emailValidate('jp1@test.com');
            }
            catch(Exception e){
                
            }
            
            Test.stopTest();
            
        }
        
    }
}