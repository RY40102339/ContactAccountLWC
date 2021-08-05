/*
*******************************************************************************************************
* (C) Copyright 2020 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Vinod A
* @version 1.0
* @created 25/05/2020
* @description 
* This test class for YG_ProductHistoryController apex class.
*
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  10/05/2020			Selvaraj T				Worked on improving the code coverage
*  04/22/2021			Kavya					Removed Plant__c Object and replaced with Account Object also removed Customer_Plant__c Object and replaced with AccountContactRelation Object.
*												Removed Plant__c(Plant) Lookup field from Asset and Project Objects and newly added PlantAccount__c(Account) Lookup field in Asset  and Project Object.
*/

@isTest
public class YG_ProductHistoryControllerTest {
	
    //method to setup test data
    @testSetup
    static void createTestData(){
        
        //Inserting test account record
        Account acc = new account();
        acc.name='Test Account'; 
         acc.Type = 'Customer';
        //acc.DUNS_Number__c=102224222; 
        insert acc;    
        
        //Inserting test contact record
        Contact con = new Contact();   
        con.FirstName='User';
        con.LastName='testContact';
        con.Email='testContact@chevron.com';
        con.accountid=acc.id; 
        insert con;
        
        //Inserting test portal user record
        User user = new User();   
        user.ProfileID = [Select Id From Profile Where Name='Customer Portal User'].id; 
        System.debug('user.ProfileID');
        user.EmailEncodingKey = 'ISO-8859-1';   user.LanguageLocaleKey = 'en_US';   user.TimeZoneSidKey = 'America/New_York';   
        user.LocaleSidKey = 'en_US';   user.FirstName = 'User';   user.LastName = 'testContact';   user.Username = 'testContact@chevron.com';      
        user.CommunityNickname = 'User222';   user.Alias = 'user';   user.Email = 'testContact@chevron.com';   user.IsActive = true;   
        user.ContactId = con.Id;  
        insert user;   
        
        //Inserting test plant record
        /*List<Plant__c> plantList=new List<Plant__c>();
        Plant__c plant1=new Plant__c();
        plant1.Name = 'TestPlant';
        plant1.Account__c = acc.Id;  
        plant1.Plant_Code__c = '300000142';
        plant1.Lang_Code__c = 'EN';
        plantList.add(plant1);
        insert plantList;*/
        
        //Inserting test plant record
        List<Account> plantList=new List<Account>();
        Account plant1=new Account();
        plant1.Name = 'TestPlant';
        plant1.ParentId = acc.Id;  
        plant1.AccountNumber = '300000142';
        plant1.Type = 'Plant';
        plantList.add(plant1);
        insert plantList;
        
        //Inserting test customer plant record
        /*List<Customer_Plant__c> cusPlantList=new List<Customer_Plant__c>();
        Customer_Plant__c cusPlant1=new Customer_Plant__c();
        cusPlant1.Contact__c = con.Id;
        cusPlant1.Plant__c = plant1.Id;
        cusPlantList.add(cusPlant1);
        insert cusPlantList;*/
        
         //Inserting test customer plant record
        List<AccountContactRelation> cusPlantList=new List<AccountContactRelation>();
        AccountContactRelation cusPlant1=new AccountContactRelation();
        cusPlant1.ContactId = con.Id;
        cusPlant1.AccountId = plant1.Id;
        cusPlantList.add(cusPlant1);
        insert cusPlantList;
        
        //Inserting test project record
        List<Project__c> projectList=new List<Project__c>();
        Project__c proj1=new Project__c();
       proj1.Account__c = acc.Id;
        proj1.PlantAccount__c = plant1.Id;
        proj1.Project_Code__c = 'VP700250';
        projectList.add(proj1);
        insert projectList;
        
        //Inserting test category hierarchy record
        List<Category_Hierarchy__c> catHierList=new List<Category_Hierarchy__c>();
        Category_Hierarchy__c catHier1=new Category_Hierarchy__c(Category_Code__c = '10000000', Category_Level__c = 1, Display_Sequence__c = 500,
                                                                 Upper_Category_Code__c = NULL);
        catHierList.add(catHier1);
        Category_Hierarchy__c catHier2=new Category_Hierarchy__c(Category_Code__c = '11000000', Category_Level__c = 2, Display_Sequence__c = 500,
                                                                 Upper_Category_Code__c = '10000000');
        catHierList.add(catHier2);
        Category_Hierarchy__c catHier3=new Category_Hierarchy__c(Category_Code__c = '12000000', Category_Level__c = 3, Display_Sequence__c = 500,
                                                                 Upper_Category_Code__c = '11000000');
        catHierList.add(catHier3);
        Category_Hierarchy__c catHier4=new Category_Hierarchy__c(Category_Code__c = '13000000', Category_Level__c = 3, Display_Sequence__c = 500,
                                                                 Upper_Category_Code__c = '11000000');
        catHierList.add(catHier4);
        Category_Hierarchy__c catHier5=new Category_Hierarchy__c(Category_Code__c = 'B0000000', Category_Level__c = 2, Display_Sequence__c = 500,
                                                                 Upper_Category_Code__c = '10000000');
        catHierList.add(catHier5);
        Category_Hierarchy__c catHier6=new Category_Hierarchy__c(Category_Code__c = 'A0000000', Category_Level__c = 3, Display_Sequence__c = 500,
                                                                 Upper_Category_Code__c = 'B0000000');
        catHierList.add(catHier6);
        Category_Hierarchy__c catHier7=new Category_Hierarchy__c(Category_Code__c = 'C0000000', Category_Level__c = 3, Display_Sequence__c = 500,
                                                                 Upper_Category_Code__c = 'B0000000');
        catHierList.add(catHier7);
        Category_Hierarchy__c catHier8=new Category_Hierarchy__c(Category_Code__c = '20000001', Category_Level__c = 1, Display_Sequence__c = 500,
                                                                 Upper_Category_Code__c = NULL);
        catHierList.add(catHier8);
        Category_Hierarchy__c catHier9=new Category_Hierarchy__c(Category_Code__c = '22000022', Category_Level__c = 2, Display_Sequence__c = 500,
                                                                 Upper_Category_Code__c = '20000001');
        catHierList.add(catHier9);
        Category_Hierarchy__c catHier10=new Category_Hierarchy__c(Category_Code__c = '33000033', Category_Level__c = 3, Display_Sequence__c = 500,
                                                                  Upper_Category_Code__c = '22000022');
        catHierList.add(catHier10);
        
        insert catHierList;
        
        //Inserting test category record
        List<Category__c> catList=new List<Category__c>();
       
        Category__c catg3=new Category__c(Name = 'Device Smart Communicators BT200', Category_Hierarchy__c = catHier3.Id,
                                          Category_Type__c = 'Product', Language_Code__c = 'EN');
        catList.add(catg3);
        Category__c catg4=new Category__c(Name = 'HART Communicator YHC5150X', Category_Hierarchy__c = catHier4.Id,
                                          Category_Type__c = 'Product', Language_Code__c = 'EN');
        catList.add(catg4);
       
        Category__c catg6=new Category__c(Name = 'ADMAG AXG', Category_Hierarchy__c = catHier6.Id,
                                          Category_Type__c = 'Product', Language_Code__c = 'EN');
        catList.add(catg6);
        Category__c catg7=new Category__c(Name = 'ROTAMASS PRIME', Category_Hierarchy__c = catHier7.Id,
                                          Category_Type__c = 'Product', Language_Code__c = 'EN');
        catList.add(catg7);
       
        insert catList;
        
        //Inserting test product record
        List<Product2> prodList=new List<Product2>();
        
        Product2 prod1=new Product2();
        prod1.Name = 'ADMAG AXG: Magnetic Flow Meter';
        prod1.Model_Code__c = 'AX01C';
        prod1.Category__c = catg6.Id;
       // prod1.Production_Date__c = Date.newInstance(2014, 12, 17);
        prodList.add(prod1);
        
        //Inserting test task record
        List<task> tskList=new List<task>();
        task t1=new task();
        t1.Subject = 'other';
        t1.WhatId = prod1.Id;
        t1.OwnerId = UserInfo.getUserId();
        t1.Subject = 'Discontinued products';
        t1.Type = 'Discontinued products';
        t1.Is_Active__c = 'True';
        t1.Priority = 'Normal';
        t1.Status = 'open';
        tskList.add(t1);
        
        task t2=new task();
        t2.Subject = 'other';
        t2.WhatId = prod1.Id;
        t2.OwnerId = UserInfo.getUserId();
        t2.Subject = 'Firmware Update';
        t2.Type = 'Firmware Update';
        t2.Is_Active__c = 'True';
        t2.Priority = 'Normal';
        t2.Status = 'open';
        tskList.add(t2);
        
        
        Product2 prod2=new Product2();
        prod2.Name = 'Device Smart Communicators BT200';
        prod2.Model_Code__c = 'BT200';
        prod2.Category__c = catg3.Id;
     //   prod2.Production_Date__c = Date.newInstance(2014, 12, 17);
        prodList.add(prod2);
        
        Product2 prod3=new Product2();
        prod3.Name = 'Vortex Flow Meters';
        prod3.Model_Code__c = 'DY015';
        prod3.Category__c = catg7.Id;
     //   prod3.Production_Date__c = Date.newInstance(2014, 12, 17);
        prodList.add(prod3);
        
        Product2 prod4=new Product2();
        prod4.Name = 'YHC5150X';
        prod4.Model_Code__c = 'YHC51';
        prod4.Category__c = catg4.Id;
       // prod4.Production_Date__c = Date.newInstance(2014, 12, 17);
        prodList.add(prod4);
        
        Insert prodList;
        System.debug('prodList::*'+prod3.Id);
        
        //Inserting test asset record
        List<Asset> assList=new List<Asset>();
        Asset ass1=new Asset();
        ass1.Name = 'SU1234567';
        ass1.Product2Id = prod1.Id;
        ass1.AccountId = acc.Id;
        ass1.ContactId = con.Id;
        ass1.SerialNumber = 'SU1234567';
        ass1.PlantAccount__c = plant1.Id;
        ass1.MS_Code__c = 'AAI543-H50';
        //ass1.Shipping_Date__c = Date.newInstance(2019, 7, 28);
        ass1.Status = 'Installed';
        
        assList.add(ass1);   
        
        task t3=new task();
        t3.Subject = 'other';
        t3.WhatId = ass1.Id;
        t3.OwnerId = UserInfo.getUserId();
        t3.Subject = 'Calibration Recommended';
        t3.Type = 'Calibration Recommended';
        t3.ActivityDate = Date.newInstance(2019, 7, 28);
        t3.Asset__c = ass1.Id;
        t3.Is_Active__c = 'True';
        t3.Priority = 'Normal';
        t3.Status = 'open';
        tskList.add(t3);
        
        
        Asset ass2=new Asset();
        ass2.Name = 'SU1234568';
        ass2.Product2Id = prod1.Id;
        ass2.AccountId = acc.Id;
        ass2.ContactId = con.Id;
        ass2.SerialNumber = 'SU1234568';
        ass2.PlantAccount__c = plant1.Id;
        ass2.MS_Code__c = 'AAI543-H50';
        //ass2.Shipping_Date__c = Date.newInstance(2014, 12, 28);
        ass2.Status = 'Installed';
        
        assList.add(ass2);     
        
        Asset ass3=new Asset();
        ass3.Name = 'SU1234569';
        ass3.Product2Id = prod1.Id;
       ass3.AccountId = acc.Id;
        ass3.ContactId = con.Id;
        ass3.SerialNumber = 'SU1234569';
        ass3.PlantAccount__c = plant1.Id;
        ass3.MS_Code__c = 'AAI543-H50';
        //ass3.Shipping_Date__c = Date.newInstance(2014, 12, 28);
        ass3.Status = 'Installed';
        
        assList.add(ass3); 
        
        insert assList;
        
        task t4=new task();
        t4.Subject = 'other';
        t4.WhatId = ass1.Id;
        t4.OwnerId = UserInfo.getUserId();
        t4.Subject = 'Calibration Recommended';
        t4.Type = 'Calibration Recommended';
        t4.ActivityDate = Date.newInstance(2020, 7, 28);
        t4.Asset__c = ass1.Id;
        t4.Is_Active__c = 'True';
        t4.Priority = 'Normal';
        t4.Status = 'open';
        tskList.add(t4);
        
        insert tskList;
        
        Case case1=new Case();
        case1.Status = 'Active only';
        case1.Origin = 'Web';
        case1.ContactId = con.Id;
        case1.AccountId = acc.Id;
        case1.Progress__c = 'Request Submitted';
        case1.Description = 'Test';
        case1.CreatedDate = date.today()-10;
        //case1.Case_Main_Type__c = 'Critical services';
        //case1.Case_Sub_Type__c = 'Software corrupted';
        case1.AssetId = ass1.Id;
        //case1.Plant__c = plant1.Id;
        insert case1;
        
        Case updCase1 = [Select Progress__c From Case where Id = :case1.Id];
        updCase1.Progress__c = 'Request Completed';
        update updCase1;
        
        CaseHistory caseHis = new CaseHistory();
        caseHis.Field = 'Progress__c';
        caseHis.CaseId = case1.Id;
        insert caseHis;
    }
    
    //test method to execute YG_ProductHistoryController.getProductHistory() method based on above data 
    @istest static void prodHistoryTestMethod(){
        
        test.startTest();
        YG_ProductHistoryController.ProdHistoryWrapper prodHisWrap=new YG_ProductHistoryController.ProdHistoryWrapper();
        prodHisWrap = YG_ProductHistoryController.getProductHistory('SU1234567');
        System.assertEquals(null, prodHisWrap.hisWrap);
		test.stopTest();
    }

}