/*
*******************************************************************************************************
* (C) Copyright 2020 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Jayaprasath
* @version 1.0
* @created 09/11/2020
* @description 
* This test class for YG_OverviewPlantDetails apex class.
*
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  04/21/2021 			Kavya					Removed Plant__c Object and replaced with Account Object.
*/

@istest
public class YG_OverviewPlantDetailsTest {
    @istest static void getOverviewPlantDetailsTestMethod(){
        //Insert test account record
        Account acc = new account();
        acc.name='ABC Test Account';
         acc.Type = 'Customer';
        insert acc;    
        
        //Insert test contact record
        Contact con = new Contact();   
        con.FirstName='User';
        con.LastName='CVX AU';
        con.Email='cvxauuser011@chevron.com';
        con.accountid=acc.id; 
        insert con;
        
        //Inserting test portal user record
        Profile profile = [Select Id From Profile Where Name='Customer Portal User'];
        User user = new User(Alias = 'comm', Email='yg.qa167@gmail.com',ContactId=con.id,
                             EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                             LocaleSidKey='en_US', ProfileId = profile.Id,
                             TimeZoneSidKey='America/Los_Angeles', UserName='yg.qa167@gmail.com');
        insert user;
        
        //Inserting test plant record
       /* List<Plant__c> plantList=new List<Plant__c>();
            Plant__c plant1=new Plant__c();
            plant1.Name = 'TestPlant';
            plant1.Account__c = acc.Id;  
            plant1.Plant_Code__c = '300000142';
            plant1.Lang_Code__c = 'EN';
            plant1.Location__c ='';
            plant1.Telephone_number__c ='';
            plant1.Fax_number__c ='';
        plantList.add(plant1);*/
        
        //Inserting test plant record
        List<Account> plantList=new List<Account>();
            Account plant1=new Account();
            plant1.Name = 'TestPlant';
            plant1.ParentId = acc.Id;  
            plant1.AccountNumber = '300000142';
       		plant1.Type = 'Plant';
            plant1.ShippingPostalCode ='';
       		plant1.ShippingStreet ='';
            plant1.Phone ='';
            plant1.Fax ='';
        plantList.add(plant1);
        
      /*  Plant__c plant2=new Plant__c();
            plant2.Name = 'TestPlant';
            plant2.Account__c = acc.Id;  
            plant2.Plant_Code__c = '300000123';
            plant2.Lang_Code__c = 'EN';
            plant2.Location__c ='MY';
            plant2.Telephone_number__c ='1265545';
            plant2.Fax_number__c ='12135665';*/
        Account plant2=new Account();
            plant2.Name = 'TestPlant';
            plant2.ParentId = acc.Id;  
            plant2.AccountNumber = '300000123';
       		plant2.Type = 'Plant';
            plant2.ShippingPostalCode ='';
       		plant2.ShippingStreet ='';
            plant2.Phone ='1265545';
            plant2.Fax ='12135665';
        
       /* Plant__c plant3=new Plant__c();
            plant3.Name = 'TestPlant';
            plant3.Account__c = acc.Id;  
            plant3.Plant_Code__c = '300000124';
            plant3.Lang_Code__c = 'EN';
            plant3.Location__c ='MY';
            plant3.Telephone_number__c ='1265545';
            plant3.Fax_number__c ='hhh';
        plantList.add(plant3);        
        insert plantList;*/
        
        Account plant3=new Account();
            plant3.Name = 'TestPlant';
            plant3.ParentId = acc.Id;  
            plant3.AccountNumber = '300000124';
        	plant3.Type = 'Plant';
            plant3.ShippingPostalCode ='';
       		plant3.ShippingStreet ='';
            plant3.Phone ='1265545';
            plant3.Fax ='hhh';
        plantList.add(plant3);        
        insert plantList;
        
        System.RunAs(user){
              test.startTest();
                //Line to cover getOverviewGridDetails() method 
                YG_OverviewPlantDetails.getOverviewPlantDetails('300000142');
            	YG_OverviewPlantDetails.getOverviewPlantDetails('300000123');
              test.stopTest();
           
          } 


    }

}