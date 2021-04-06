/*
*******************************************************************************************************
* (C) Copyright 2020 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Jayaprasath
* @version 1.0
* @created 09/30/2020
* @description 
* This test class for YG_LoggedUserRoleController apex class.
*
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  
*/

@istest
public class YG_LoggedUserRoleControllerTest {
    
     @istest static void getOverviewGridTestMethod(){
        //Insert test account record
        Account acc = new account();
        acc.name='ABC Test Account';
        insert acc;    
        
        //Insert test contact record
        List<Contact> cCount = new List<Contact>();
        Contact con = new Contact();   
        con.FirstName='User';
        con.LastName='CVX AU';
        con.Email='cvxauuser011@chevron.com';
        con.accountid=acc.id;
        con.Portal_User_Roles__c='CA';
        con.phone = '7845123256';
        con.Company_Name__c = 'testVerticurl';
        con.Status__c = true;
        cCount.add(con);
         
         //Insert test contact record
        Contact con1 = new Contact();   
        con1.FirstName='User1';
        con1.LastName='CVX';
        con1.Email='cvxauuser0211@chevron.com';
        con1.accountid=acc.id;
        con1.Portal_User_Roles__c='CU';
        con1.phone = '8745123256';
        con1.Company_Name__c = 'testYOK'; 
        con1.Status__c = true;
        cCount.add(con1);
         
         Contact c=new Contact();
         c.LastName = 'JP';
         c.Portal_User_Roles__c = 'CU';
         c.AccountId = acc.id;
         c.Status__c = true;
         c.Company_Name__c = 'test';
         cCount.add(c);
         insert cCount;
        
     
        //Inserting test portal user record
        Profile profile = [Select Id From Profile Where Name='Customer Portal User'];
        User user = new User(Alias = 'comm', Email='yg.qa167@gmail.com',ContactId=con.id,
                             EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                             LocaleSidKey='en_US', ProfileId = profile.Id,
                             TimeZoneSidKey='America/Los_Angeles', UserName='yg.qa167@gmail.com');
        insert user;
        
         
        YG_Community_Configuration__c selfRegAcc = new YG_Community_Configuration__c(name= 'YGSelfRegisterAccountId',Text_1__c=acc.id);
        insert selfRegAcc;
         
          System.RunAs(user){
              test.startTest();
                //Line to cover getNotifyUserRole() method 
              
              YG_LoggedUserRoleController.NoftifyUserRoleWapper obj = new YG_LoggedUserRoleController.NoftifyUserRoleWapper();
              try {
                  obj=YG_LoggedUserRoleController.getNotifyUserRole();
              } catch(DMLException e) {
                  
              }
              
              test.stopTest();
           
          }
         
    }

}