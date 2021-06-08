/*
*******************************************************************************************************
* (C) Copyright 2020 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Jayaprasath
* @version 1.0
* @created 03/02/2021
* @description 
* This class is used to write the Apex test class coverage for API related call.
*
* @test class name - YG_CommonUtils
*
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  
*  
*
*/

@isTest
public class YG_CommonUtilsTest {
    
    @isTest static void commonUtilsTestMethod(){
     Test.startTest();
        
        //Insert test account record
        Account acc = new account();
        acc.name='XYZ Account'; 
        acc.AccountNumber = null; 
        insert acc;

		//Insert test contact record        
        Contact con = new Contact();   
        con.FirstName='User';
        con.LastName='CVX AU';
        con.Email='cvxauuser011@chevron.com';
        con.accountid=acc.id; 
        con.Status__c = true;
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
           
             try{  
                 Date d= Date.newInstance(2016, 12, 9);
                 Date d1= Date.newInstance(2020, 07, 01);
                 Integer i=01;
                 YG_CommonUtils.getWarrantyExpiryStr(d,i);
                 YG_CommonUtils.getWarrantyExpiryStr(d1,i);
                 
                 String LanguageCode = YG_CommonUtils.getLanguageCode('');
                 LanguageCode = YG_CommonUtils.getLanguageCode('ja');
                 
                 Date strToDate = YG_CommonUtils.convertStringToDate('19940122');
            }
            catch (Exception e) {
                System.debug('Error in testclass ::: '+e.getMessage());
            }
        }
        
        Test.stopTest();
        
    }

}