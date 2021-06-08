/*
*******************************************************************************************************
* (C) Copyright 2020 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Jayaprasath
* @version 1.0
* @created 10/05/2020
* @description 
* This test class for YG_ManageColleaguesController apex class.
*
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  
*/

@istest
public class YG_ManageColleaguesControllerTest {
    @istest static void getManageColleaguesTestMethod(){
        //Insert test account record
        Account acc = new account();
        acc.name='ABC Test Account';
		acc.AccountNumber = '102224533'; 
         acc.Type = 'Customer';
        insert acc;    
        
        //Insert test contact record
        List<Contact> contactList=new List<Contact>();
        Contact con = new Contact();   
        con.FirstName='User';
        con.LastName='CVX AU';
        con.Email='cvxauuser011@chevron.com';
        con.accountid=acc.id; 
        con.Portal_User_Roles__c = 'CA';
        con.Status__c = true;
        con.Gigya_UID__c = '48207f845b854397b19b40e972156b62';
        contactList.add(con);
        
        Contact con1 = new Contact();   
        con1.FirstName='User1';
        con1.LastName='CVX AU1';
        con1.Email='cvxauuser0111@chevron.com';
        con1.accountid=acc.id; 
        con1.Portal_User_Roles__c = 'CU';
        con1.status__c = true;
        con1.Gigya_UID__c = '74185412586352dfg852';
        contactList.add(con1);
        
        Contact con2 = new Contact();   
        con2.FirstName='User2';
        con2.LastName='CVX AU2';
        con2.Email='cvxauuser01112@chevron.com';
        con2.accountid=acc.id; 
        con2.Portal_User_Roles__c = 'CU';
        con2.status__c = true;
        contactList.add(con2);
        insert contactList;
        
         Contact con3 = new Contact();   
        con3.FirstName='User3';
        con3.LastName='CVX AU34';
        con3.Email='cvxauuser011123@chevron.com';
        con3.accountid=acc.id; 
        con3.Portal_User_Roles__c = 'CU';
        con3.status__c = true;
        contactList.add(con3);
        
         Contact contest = new Contact();   
        contest.FirstName='Usertest';
        contest.LastName='CVX AU34';
        contest.Email='cvxauuser011123@chevron.com';
        contest.accountid=acc.id; 
        contest.Portal_User_Roles__c = 'CA';
        contest.status__c = true;
        contactList.add(contest);
        
        
        List<Contact> contactLists=new List<Contact>();
        Contact cons = new Contact();   
        cons.FirstName='User3';
        cons.LastName='CVX AU3';
        cons.Email='cvxauuser012@chevron.com';
        cons.accountid=acc.id; 
        cons.Portal_User_Roles__c = 'CU';
        cons.status__c = true;
        cons.Gigya_UID__c = '985412586352dfg852';
        contactLists.add(cons);
        insert contactLists;
       
        
        //Inserting test portal user record
        Profile profile = [Select Id From Profile Where Name='Customer Portal User'];
        User user = new User(Alias = 'comm', Email='yg.qa167@gmail.com',ContactId=con.id,
                             EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                             LocaleSidKey='en_US', ProfileId = profile.Id,
                             TimeZoneSidKey='America/Los_Angeles', UserName='cvxauuser011@chevron.com');
        insert user;
        
        //Inserting test plant record
              
       List<Account> plantList=new List<Account>();
            Account plant1=new Account();
            plant1.Name = 'TestPlant1';
            plant1.ParentId = acc.Id;  
            plant1.AccountNumber = '300000142';
        	plant1.Type = 'Plant';
            plant1.ShippingPostalCode ='';
       		plant1.ShippingStreet ='';
            plant1.Phone ='';
            plant1.Fax ='';
        plantList.add(plant1);
        
        
        Account plant2=new Account();
            plant2.Name = 'TestPlant2';
            plant2.ParentId = acc.Id;  
            plant2.AccountNumber = '300000123';
        	plant2.Type = 'Plant';
            plant2.ShippingPostalCode ='';
       		plant2.ShippingStreet ='';
            plant2.Phone ='1265545';
            plant2.Fax ='12135665';
        plantList.add(plant2);
        
        
        Account plant3=new Account();
            plant3.Name = 'TestPlant3';
            plant3.ParentId = acc.Id;  
            plant3.AccountNumber = '300000124';
        	plant3.Type = 'Plant';
           plant3.ShippingPostalCode ='';
       		plant3.ShippingStreet ='';
            plant3.Phone =null;
            plant3.Fax ='hhh';
        plantList.add(plant3);
        
        
        Account plant4=new Account();
            plant4.Name = 'TestPlant4';
            plant4.ParentId = acc.Id;  
            plant4.AccountNumber = '300000098';
           plant4.Type = 'Plant';
           plant4.ShippingPostalCode ='';
       		plant4.ShippingStreet ='';
            plant4.Phone =null;
            plant4.Fax ='tyu';
        plantList.add(plant4);
        insert plantList;
        
        
        Account plant5=new Account();
            plant5.Name = 'TestPlant5';
            plant5.ParentId = acc.Id;  
            plant5.AccountNumber = '300000188';
             plant5.Type = 'Plant';
           plant5.ShippingPostalCode ='';
       		plant5.ShippingStreet ='';
            plant5.Phone =null;
            plant5.Fax ='tyu';
         	insert plant5;
        
        //Inserting test plant record
       /* List<Customer_Plant__c> cusPlantList=new List<Customer_Plant__c>();*/
        List<AccountContactRelation> cusPlantList=new List<AccountContactRelation>();
      
        AccountContactRelation cusPlant = new AccountContactRelation();
        	cusPlant.ContactId = con.id;
            cusPlant.Status__c = 'Request site access';
            cusPlant.AccountId = plant1.id;
        	cusPlantList.add(cusPlant);
        AccountContactRelation cusPlant1 = new AccountContactRelation();
        	cusPlant1.ContactId = con.id;
            cusPlant1.Status__c = 'Approved site access';
            cusPlant1.AccountId = plant2.id;
        	cusPlantList.add(cusPlant1);
        
       
        AccountContactRelation cusPlant2 = new AccountContactRelation();
        	cusPlant2.ContactId = con1.id;
            cusPlant2.Status__c = 'Decline site access';
            cusPlant2.AccountId = plant2.id;
        	cusPlantList.add(cusPlant2);
         AccountContactRelation cusPlant3 = new AccountContactRelation();
        	cusPlant3.ContactId = con1.id;
            cusPlant3.Status__c = 'Request site access';
            cusPlant3.AccountId = plant3.id;
        	cusPlantList.add(cusPlant3);
        
       
        
        AccountContactRelation cusPlant5 = new AccountContactRelation();
        	cusPlant5.ContactId = con2.id;
            cusPlant5.Status__c = 'Decline site access';
            cusPlant5.AccountId = plant3.id;
        	cusPlantList.add(cusPlant5);
         AccountContactRelation cusPlant4 = new AccountContactRelation();
        	cusPlant4.ContactId = con2.id;
            cusPlant4.Status__c = 'Approved site access';
            cusPlant4.AccountId = plant4.id;
        	cusPlantList.add(cusPlant4);
        
        Insert cusPlantList;
        
         //Insert test custom setting record for community URL
        YG_Community_Configuration__c commConfig=new YG_Community_Configuration__c();
        commConfig.Name = 'Community URL';
        commConfig.Text_1__c = 'https://test-yg.cs31.force.com/s/';
        insert commConfig;
        
        //to pass the plant code as list in arguments 
         List<String> plnIdList=new List<String>();
            /*for(Plant__c plnList :plantList){
                plnIdList.add(plnList.Plant_Code__c);
            }*/
        for(Account plnList :plantList){
                plnIdList.add(plnList.AccountNumber);
            }
        List<String> plnIdList1=new List<String>();
       /* plnIdList1.add(plant5.Plant_Code__c);*/
        plnIdList1.add(plant5.AccountNumber);
        
        
        String cid = cons.id;
        
        //to pass the contact Id as list in arguments 
         List<Id> contList=new List<Id>();
            for(Contact conList :contactList){
                contList.add(conList.id);
            }
        List<Id> contList1 = new List<Id>();
        
            
        YG_Community_Configuration__c selfReg = new YG_Community_Configuration__c(name= 'YGSelfRegisterAccountId',Text_1__c=acc.id);
        YG_Community_Configuration__c userkey = new YG_Community_Configuration__c(name= 'CDC User Key',Text_1__c='AK5wDuYDS/nK');
        YG_Community_Configuration__c secret = new YG_Community_Configuration__c(name= 'CDC Secret Key',Text_1__c='ahIkjsv9iBJuWWyrl5/U9oCR+t7oLg/H');
        YG_Community_Configuration__c apiKey = new YG_Community_Configuration__c(name= 'CDC APIKey',Text_1__c='3_yVCM13to0NZ_YDdZcY8ULjHZ70yEk0mEINhaRbXA7CDd2Ir2jvHnmxrMZ-PUa22V');
        YG_Community_Configuration__c endpointURL = new YG_Community_Configuration__c(name= 'CDC setAccountInfo Endpoint URL',Text_1__c='https://accounts.us1.gigya.com/accounts.setAccountInfo');
        
        insert selfReg;
        insert userkey;
        insert secret;
        insert apiKey;
        insert endpointURL;
        
        String UID = con.Gigya_UID__c;
        
        Test.setMock(HttpCalloutMock.class, new YG_SetAccountInfoAPIMockCallout());
        
        
        System.RunAs(user){
              test.startTest();
            
            
                try {
                    //Line to cover getManageColleaguesGridDetails() method  
                    YG_ManageColleaguesController.ManageColleaguesWrapper obj = new 
                    YG_ManageColleaguesController.ManageColleaguesWrapper();                    
                    obj = YG_ManageColleaguesController.getManageColleaguesGridDetails(contList);
                    obj = YG_ManageColleaguesController.getManageColleaguesGridDetails(contList1);
                    
                    //Line to cover getSelectedUserDetail() method
                    YG_ManageColleaguesController.UserDetalisWapper obj1 = new 
                    YG_ManageColleaguesController.UserDetalisWapper();                    
                    obj1=YG_ManageColleaguesController.getSelectedUserDetail(con1.id);
                    obj1=YG_ManageColleaguesController.getSelectedUserDetail(null);
                    
                    //Line to cover getApprovePlant() method 
                    YG_ManageColleaguesController.getApprovePlant(con1.id,plnIdList);
                    YG_ManageColleaguesController.getApprovePlant(con.id,plnIdList);
                    
                    //Line to cover getDeclinePlant() method 
                    YG_ManageColleaguesController.getDeclinePlant(con1.id,plnIdList);
                    YG_ManageColleaguesController.getDeclinePlant(con.id,plnIdList);
                    
                    //Line to cover getUpdatePlant() method 
                    YG_ManageColleaguesController.getUpdatePlant(con1.id,plnIdList);
                    YG_ManageColleaguesController.getUpdatePlant(con.id,plnIdList);
                    
                    
                    //Line to cover getUserDeactive() method 
                    YG_ManageColleaguesController.getUserDeactive(con.id,false);
                  //  YG_ManageColleaguesController.getUserDeactive(contest.id,true);
                    YG_ManageColleaguesController.getUserDeactive(null,false);
                    // YG_ManageColleaguesController.getUserDeactive(null,true);
                    
                    //Line to cover getUserAdmin() method 
                    YG_ManageColleaguesController.getUserAdmin(cid,'Set as admin');
                    YG_ManageColleaguesController.getUserAdmin(con1.id,'Revoke admin');
                    
                    //Line to cover getPlantRequest() method 
                    YG_ManageColleaguesController.getPlantRequest(plnIdList);
                    YG_ManageColleaguesController.getPlantRequest(plnIdList1);
                    
                    //Line to cover getAdminPlant() method 
                    YG_ManageColleaguesController.getAdminPlant(cons.id,acc.id);
                    // YG_ManageColleaguesController.getAdminPlant(contest.id,acc.id);

                    DMLException dmlEx = new DMLException('Test Ex Email');
                    
                                	
                } catch(DMLException e) {
                    
                }
              test.stopTest();
           
          } 


    }

}