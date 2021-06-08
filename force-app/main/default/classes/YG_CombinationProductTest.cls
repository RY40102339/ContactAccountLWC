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
* This test class for YG_CombinationProduct apex class.
*
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  04/21/2021 			Kavya 					Removed Plant__c Object and replaced with Account Object.
*											    Removed Plant__c(Plant) Lookup field from Asset and Project Objects and newly added PlantAccount__c(Account) Lookup field in Asset and Project Object.
*/

@istest
public class YG_CombinationProductTest {
     @istest static void getCombinationProductTestMethod(){
         //Insert test account record
         Account acc = new account();
         acc.name='ABC Test Account';  
         acc.Type = 'Customer';
         //acc.DUNS_Number__c=102224533; 
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
         plantList.add(plant1);*/
         
         //Inserting test plant record
         List<Account> plantList=new List<Account>();
         Account plant1=new Account();
         plant1.Name = 'TestPlant';
         plant1.ParentId = acc.Id;  
         plant1.AccountNumber = '300000142';
         plant1.Type = 'Plant';
         plantList.add(plant1);
        
        /* Plant__c plant2=new Plant__c();
         plant2.Name = 'TestPlant2';
         plant2.Account__c = acc.Id;  
         plant2.Plant_Code__c = '300000123';
         plant2.Lang_Code__c = 'EN';
         plantList.add(plant2);
         insert plantList;*/
         Account plant2=new Account();
         plant2.Name = 'TestPlant2';
         plant2.ParentId = acc.Id;  
         plant2.AccountNumber = '300000123';
         plant2.Type = 'Plant';
         plantList.add(plant2);
         insert plantList;
         
         //Insert test project record   
         List<Project__c> projectList=new List<Project__c>();
         Project__c proj1=new Project__c();
        proj1.Account__c = acc.Id;
         proj1.PlantAccount__c = plant1.Id;
         proj1.Project_Code__c = 'VP700250';
         projectList.add(proj1);
         insert projectList; 
         
         List<Category_Hierarchy__c> catHierList=new List<Category_Hierarchy__c>();
         Category_Hierarchy__c catHier1=new Category_Hierarchy__c(Category_Code__c = '10000000', Category_Level__c = 1, Display_Sequence__c = 500,
                                                                  Category_Hierarchy__c = NULL);
         catHierList.add(catHier1);
         insert catHierList;
         
         List<Category__c> catList=new List<Category__c>();
         Category__c catg1 = new Category__c(Name = 'Distributed Control Systems (DCS)', Category_Hierarchy__c = catHier1.Id,
                                             Category_Type__c = 'System', Language_Code__c = 'EN');
         
         catList.add(catg1);
         insert catList;
         
         List<Product2> prodList=new List<Product2>();
         Product2 prod1=new Product2();
         prod1.Name = 'Node Expansion Package (for AFV10)';
         prod1.Model_Code__c = 'LFS1550';
         prod1.Product_Type__c = 'Hardware';
         prod1.Category__c = catg1.Id;
         //prod1.Production_Date__c = Date.newInstance(2014, 12, 17);
         prodList.add(prod1);            
         Insert prodList;
         
         List<Asset> aList=new List<Asset>();         
         Asset ass1=new Asset();
         ass1.Name = 'FCS0111';
         ass1.Product2Id = prod1.Id;
         ass1.AccountId = acc.Id;
         ass1.ContactId = con.Id;
         ass1.SerialNumber = 'FCS0111';
         ass1.PlantAccount__c = plant1.Id;
         ass1.Project__c = proj1.Id;
         ass1.MS_Code__c = 'FCS0111';
         ass1.Status = 'Installed';
         ass1.Lang_Code__c='EN';
         ass1.ParentId = null;
         aList.add(ass1);
         
         Asset ass2=new Asset();
         ass2.Name = 'SU1234567';
         ass2.Product2Id = prod1.Id;
         ass2.AccountId = acc.Id;
         ass2.ContactId = con.Id;
         ass2.SerialNumber = 'SU1234567';
         ass2.PlantAccount__c = plant1.Id;
         ass2.Project__c = proj1.Id;
         ass2.MS_Code__c = 'LXY12345';
         ass2.Status = 'Installed';
         ass2.Lang_Code__c='EN';
         ass2.ParentId = ass1.ID;
         aList.add(ass2);
         insert aList;
         
         List<Asset> aList1=new List<Asset>();
         Asset ass3=new Asset();
         ass3.Name = 'SU1234567';
         ass3.Product2Id = prod1.Id;
         ass3.AccountId = acc.Id;
         ass3.ContactId = con.Id;
         ass3.SerialNumber = 'SU1234567';
         ass3.PlantAccount__c = plant1.Id;
         ass3.Project__c = proj1.Id;
         ass3.MS_Code__c = 'LXY12345';
         ass3.Status = 'Installed';
         ass3.Lang_Code__c='EN';
         ass3.ParentId = ass1.ID;
         aList1.add(ass3);
         insert aList1;         
        
         System.RunAs(user){
             test.startTest();
             YG_CombinationProduct.ProductWapper obj = new YG_CombinationProduct.ProductWapper();
             try {                 
                 //Line to cover getAssetDetails() method
                 obj=YG_CombinationProduct.getAssetDetails(null);                 
                 obj=YG_CombinationProduct.getAssetDetails('SU1234567');
                 obj=YG_CombinationProduct.getAssetDetails('FCS0111');
             } catch(Exception e) {
                 
             }             
             test.stopTest();
         } 
    }

}