/*
*******************************************************************************************************
* (C) Copyright 2020 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Selvaraj T
* @version 1.0
* @created 01/11/2021
* @description 
* This class is used to write the Apex test class coverage for YG_SystemsAPI.
*
*  Change History:
*  MM/DD/YYYY      Developer Name      Comments
*  
*  
*
*/

@isTest
public class YG_SystemsAPITest {
    
    @isTest static void ygDeliverableAPITest() {
        
        //Inserting test account record
        Account acc = new account();
        acc.name='Test Account';  
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
        List<Plant__c> plantList=new List<Plant__c>();
        Plant__c plant1=new Plant__c();
        plant1.Name = 'TestPlant';
        plant1.Account__c = acc.Id;  
        plant1.Plant_Code__c = '300000123';
        plant1.Lang_Code__c = 'EN';
        plant1.API_Last_Executed_Date__c = null;
        plantList.add(plant1);
        insert plantList;
        
        //Inserting test customer plant record
        List<Customer_Plant__c> cusPlantList=new List<Customer_Plant__c>();
        Customer_Plant__c cusPlant1=new Customer_Plant__c();
        cusPlant1.Contact__c = con.Id;
        cusPlant1.Plant__c = plant1.Id;
        cusPlant1.Status__c = 'Approved site access';
        cusPlantList.add(cusPlant1);
        insert cusPlantList;
        
        //Inserting test Category Hierarchy record
        List<Category_Hierarchy__c> catHierList=new List<Category_Hierarchy__c>();
        Category_Hierarchy__c catHier1=new Category_Hierarchy__c(Category_Code__c = '20000000', Category_Level__c = 1, Display_Sequence__c = 500,
                                                                 Upper_Category_Code__c = NULL);
        catHierList.add(catHier1);
        insert catHierList; 
        
        //Inserting test Category record
        List<Category__c> catList=new List<Category__c>();
        Category__c catg1=new Category__c(Name = 'Software', Category_Hierarchy__c = catHier1.Id,
                                          Category_Type__c = 'System', Language_Code__c = 'EN');
        catList.add(catg1);
        insert catList;
        
        //Insert Product
        List<Product2> prodList=new List<Product2>();
        Product2 prod1=new Product2();
        prod1.Name = 'Test Product';
        prod1.Model_Code__c = '6';
        prod1.Category__c = catg1.Id;
        prod1.Product_Type__c = 'Software'; 
        prodList.add(prod1);
        insert prodList;
        
        //Insert custom setting records
        List<YG_Community_Configuration__c> configList = new List<YG_Community_Configuration__c>();
        YG_Community_Configuration__c deliApi = new YG_Community_Configuration__c();
        deliApi.Name = 'DeliverableListAPIEndpointUrl';
        deliApi.Text_1__c = 'https://library.yokogawa.com:8180/deliverables/search';
        configList.add(deliApi);
        
        YG_Community_Configuration__c deliProdApi = new YG_Community_Configuration__c();
        deliProdApi.Name = 'DeliverableProductAPIEndpointUrl';
        deliProdApi.Text_1__c = 'https://library.yokogawa.com:8180/deliverablesproduct/search';
        configList.add(deliProdApi);
        
        YG_Community_Configuration__c systemid=new YG_Community_Configuration__c();
        systemid.Name = 'ShippingAPISystemId';
        systemid.Text_1__c = 'F5cJnZkn';
        configList.add(systemid);
        
        YG_Community_Configuration__c apiDays=new YG_Community_Configuration__c();
        apiDays.Name = 'Deliverable API Execution Days';
        apiDays.Text_1__c = '1';
        configList.add(apiDays);
        
        insert configList;
        
        System.runAs(user) {
            Test.startTest();
            
            Map<String,String> plantMap = YG_SystemsAPI.getCustomerPlantDetails();
            
            Test.setMock(HttpCalloutMock.class, new YG_SystemsAPIMockCallout());
            
            Boolean isSuccessDelAPI = YG_SystemsAPI.getDeliverableNoAndSystemId(new List<String>{'300000123'});
            system.assertEquals(true, isSuccessDelAPI);
            
            Boolean isfailedDelAPI = YG_SystemsAPI.getDeliverableNoAndSystemId(null);
            system.assertEquals(false, isfailedDelAPI);
            
            Test.stopTest();
            
        }
    }
    
    @isTest static void ygStationsAPITest() {
        
        //Inserting test account record
        Account acc = new account();
        acc.name='Test Account';  
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
        List<Plant__c> plantList=new List<Plant__c>();
        Plant__c plant1=new Plant__c();
        plant1.Name = 'TestPlant';
        plant1.Account__c = acc.Id;  
        plant1.Plant_Code__c = '300000123';
        plant1.Lang_Code__c = 'EN';
        plant1.API_Last_Executed_Date__c = null;
        plantList.add(plant1);
        insert plantList;
        
        //Inserting test customer plant record
        List<Customer_Plant__c> cusPlantList=new List<Customer_Plant__c>();
        Customer_Plant__c cusPlant1=new Customer_Plant__c();
        cusPlant1.Contact__c = con.Id;
        cusPlant1.Plant__c = plant1.Id;
        cusPlant1.Status__c = 'Approved site access';
        cusPlantList.add(cusPlant1);
        insert cusPlantList;
        
        //Create a Project
        List<Project__c> projList = new List<Project__c>();
        Project__c proj = new Project__c();
        proj.Name = 'VP711178';
        proj.Project_Code__c = 'VP711178';
        proj.Account__c = acc.Id;
        proj.Plant__c = plant1.Id;
        projList.add(proj);
        insert projList;        
        
        //Inserting test Category Hierarchy record
        List<Category_Hierarchy__c> catHierList=new List<Category_Hierarchy__c>();
        Category_Hierarchy__c catHier1=new Category_Hierarchy__c(Category_Code__c = '20000000', Category_Level__c = 1, Display_Sequence__c = 500,
                                                                 Upper_Category_Code__c = NULL);
        catHierList.add(catHier1);
        insert catHierList; 
        
        //Inserting test Category record
        List<Category__c> catList=new List<Category__c>();
        Category__c catg1=new Category__c(Name = 'Software', Category_Hierarchy__c = catHier1.Id,
                                          Category_Type__c = 'System', Language_Code__c = 'EN');
        catList.add(catg1);
        insert catList;
        
        //Insert Product
        List<Product2> prodList=new List<Product2>();
        Product2 prod1=new Product2();
        prod1.Name = 'Test Product';
        prod1.Model_Code__c = '6';
        prod1.Category__c = catg1.Id;
        prod1.Product_Type__c = 'Software'; 
        prodList.add(prod1);
        insert prodList;
        
        //Insert custom setting records
        List<YG_Community_Configuration__c> configList = new List<YG_Community_Configuration__c>();
        
        YG_Community_Configuration__c stationApi = new YG_Community_Configuration__c();
        stationApi.Name = 'StationListAPIEndpointUrl';
        stationApi.Text_1__c = 'https://library.yokogawa.com:8180/stationlist/search';
        configList.add(stationApi); 
        
        YG_Community_Configuration__c statDetailsApi = new YG_Community_Configuration__c();
        statDetailsApi.Name = 'StationDetailsAPIEndpointUrl';
        statDetailsApi.Text_1__c = 'https://library.yokogawa.com:8180/stationdetail/search';
        configList.add(statDetailsApi);
        
        YG_Community_Configuration__c systemid=new YG_Community_Configuration__c();
        systemid.Name = 'ShippingAPISystemId';
        systemid.Text_1__c = 'F5cJnZkn';
        configList.add(systemid);
        
        YG_Community_Configuration__c apiDays=new YG_Community_Configuration__c();
        apiDays.Name = 'Deliverable API Execution Days';
        apiDays.Text_1__c = '1';
        configList.add(apiDays);
        
        insert configList;
        
        System.runAs(user) {
            Test.startTest();
            
            Map<String,String> plantMap = YG_SystemsAPI.getCustomerPlantDetails();
            
            Test.setMock(HttpCalloutMock.class, new YG_SystemsAPIMockCallout());            
            
            Boolean isSuccessStaAPI =  YG_SystemsAPI.getSystemDetails(new List<String>{'300000123'});
            system.assertEquals(true, isSuccessStaAPI);
            
            Boolean isfailedStaAPI =  YG_SystemsAPI.getSystemDetails(null);
            system.assertEquals(false, isfailedStaAPI);
            
            Test.stopTest();            
        }
    }
    
    @isTest static void ygStationsDetailsAPITest() {
        
        //Inserting test account record
        Account acc = new account();
        acc.name='Test Account';  
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
        List<Plant__c> plantList=new List<Plant__c>();
        Plant__c plant1=new Plant__c();
        plant1.Name = 'TestPlant';
        plant1.Account__c = acc.Id;  
        plant1.Plant_Code__c = '300000123';
        plant1.Lang_Code__c = 'EN';
        plant1.API_Last_Executed_Date__c = null;
        plantList.add(plant1);
        insert plantList;
        
        //Inserting test customer plant record
        List<Customer_Plant__c> cusPlantList=new List<Customer_Plant__c>();
        Customer_Plant__c cusPlant1=new Customer_Plant__c();
        cusPlant1.Contact__c = con.Id;
        cusPlant1.Plant__c = plant1.Id;
        cusPlant1.Status__c = 'Approved site access';
        cusPlantList.add(cusPlant1);
        insert cusPlantList;
		
		//Inserting test Category Hierarchy record
        List<Category_Hierarchy__c> catHierList=new List<Category_Hierarchy__c>();
        Category_Hierarchy__c catHier1=new Category_Hierarchy__c(Category_Code__c = '20000002', Category_Level__c = 1, Display_Sequence__c = 500,
                                                                 Upper_Category_Code__c = NULL);
        catHierList.add(catHier1);
		Category_Hierarchy__c catHier2=new Category_Hierarchy__c(Category_Code__c = '20000001', Category_Level__c = 1, Display_Sequence__c = 500,
                                                                 Upper_Category_Code__c = NULL);
        catHierList.add(catHier2);
        insert catHierList; 
        
        //Inserting test Category record
        List<Category__c> catList=new List<Category__c>();
        Category__c catg1=new Category__c(Name = 'Software', Category_Hierarchy__c = catHier1.Id,
                                          Category_Type__c = 'System', Language_Code__c = 'EN');
        catList.add(catg1);
		Category__c catg2=new Category__c(Name = 'Hardware', Category_Hierarchy__c = catHier2.Id,
                                          Category_Type__c = 'System', Language_Code__c = 'EN');
        catList.add(catg2);
        insert catList;
        
        //Create a Project
        List<Project__c> projList = new List<Project__c>();
        Project__c proj = new Project__c();
        proj.Name = 'VP711178';
        proj.Project_Code__c = 'VP711178';
        proj.Account__c = acc.Id;
        proj.Plant__c = plant1.Id;
        projList.add(proj);
		
		Project__c proj1 = new Project__c();
        proj1.Name = 'VP704674';
        proj1.Project_Code__c = 'VP704674';
        proj1.Account__c = acc.Id;
        proj1.Plant__c = plant1.Id;
        projList.add(proj1);

		Project__c proj2 = new Project__c();
        proj2.Name = 'ATLAS001';
        proj2.Project_Code__c = 'ATLAS001';
        proj2.Account__c = acc.Id;
        proj2.Plant__c = plant1.Id;
        projList.add(proj2);		
		
        insert projList;
		
		//Insert Product
        List<Product2> prodList=new List<Product2>();
        Product2 prod1=new Product2();
        prod1.Name = 'Test Product';
        prod1.Model_Code__c = '6';
        prod1.Category__c = catg1.Id;
        prodList.add(prod1);
		
		Product2 prod2=new Product2();
        prod2.Name = 'Test Product';
        prod2.Model_Code__c = 'A2EN501';
        prod2.Category__c = catg2.Id;
        prodList.add(prod2);
		
        insert prodList;

		//Insert Asset List
		List<Asset> astList = new List<Asset>();
		Asset ast = new Asset();
		ast.Name = 'FCS0201';
		ast.Revision_No__c = 'R1';
		ast.Domain__c = 2;
		ast.Station_Number__c = 1;
		ast.Station_Type__c = 'FCS';
        ast.Product2Id = prod2.Id;
        ast.Project__c = proj.Id;
        ast.AccountId = acc.Id;
        ast.Plant__c = plant1.Id;
		astList.add(ast);
		
		Asset ast1 = new Asset();
		ast1.Name = 'HIS0264';
		ast1.Revision_No__c = 'R1';
		ast1.Domain__c = 2;
		ast1.Station_Number__c = 64;
		ast1.Station_Type__c = 'HIS';
        ast1.Product2Id = prod1.Id;
        ast1.Project__c = proj.Id;
        ast1.AccountId = acc.Id;
        ast1.Plant__c = plant1.Id;
		astList.add(ast1);
		
		Asset ast2 = new Asset();
		ast2.Name = 'SCS0231';
		ast2.Revision_No__c = 'R1';
		ast2.Domain__c = 2;
		ast2.Station_Number__c = 31;
		ast2.Station_Type__c = 'SCS';
        ast2.Product2Id = prod2.Id;
        ast2.Project__c = proj.Id;
        ast2.AccountId = acc.Id;
        ast2.Plant__c = plant1.Id;
		astList.add(ast2);
		
		Asset ast3 = new Asset();
		ast3.Name = 'BCV1055';
		ast3.Domain__c = 10;
		ast3.Station_Number__c = 55;
		ast3.Station_Type__c = 'BCV';
        ast3.Product2Id = prod1.Id;
        ast3.Project__c = proj1.Id;
        ast3.AccountId = acc.Id;
        ast3.Plant__c = plant1.Id;
		astList.add(ast3);
		
		Asset ast4 = new Asset();
		ast4.Name = 'CGW0334';
		ast4.Domain__c = 03;
		ast4.Station_Number__c = 34;
		ast4.Station_Type__c = 'CGW';
        ast4.Product2Id = prod2.Id;
        ast4.Project__c = proj2.Id;
        ast4.AccountId = acc.Id;
        ast4.Plant__c = plant1.Id;
		astList.add(ast4);
		
		insert astList;
		
		
		//Create Maintenance Phase records
		List<Maintenance_Phase__c> mtnList = new List<Maintenance_Phase__c>();
		
		Maintenance_Phase__c mtn = new Maintenance_Phase__c();
		mtn.Product__c = prod2.Id;
		mtn.Sales_Phase_Start_Date__c = Date.today();
		mtnList.add(mtn);
		
		Maintenance_Phase__c mtn1 = new Maintenance_Phase__c();
		mtn1.Product__c = prod1.Id;
		mtn1.Sales_Phase_Start_Date__c = Date.today();
		mtn1.Sub_Item__c = 'R1';
		mtnList.add(mtn1);
		
		Maintenance_Phase__c mtn2 = new Maintenance_Phase__c();
		mtn2.Product__c = prod1.Id;
		mtn2.Sales_Phase_Start_Date__c = Date.today();
		mtn2.Item__c = 'Microsoft Windows Server 2008 R2 Standard';
		mtn2.Sub_Item__c = 'Service Pack 1';
		mtnList.add(mtn2);
        
        insert mtnList;
                
        //Insert custom setting records
        List<YG_Community_Configuration__c> configList = new List<YG_Community_Configuration__c>();
               
        YG_Community_Configuration__c statDetailsApi = new YG_Community_Configuration__c();
        statDetailsApi.Name = 'StationDetailsAPIEndpointUrl';
        statDetailsApi.Text_1__c = 'https://library.yokogawa.com:8180/stationdetail/search';
        configList.add(statDetailsApi);
        
        YG_Community_Configuration__c systemid=new YG_Community_Configuration__c();
        systemid.Name = 'ShippingAPISystemId';
        systemid.Text_1__c = 'F5cJnZkn';
        configList.add(systemid);
        
        insert configList;
        
        System.runAs(user) {
            Test.startTest();
                        
            Test.setMock(HttpCalloutMock.class, new YG_SystemsAPIMockCallout());            
            
            YG_SystemsAPI.stationDataWrapper statDetails = new YG_SystemsAPI.stationDataWrapper();
            statDetails = YG_SystemsAPI.getStationDetailsList(ast.Id, 'VP711178', 'FCS', '0201');
            system.assertEquals('FCS', statDetails.productSubType);
            
            YG_SystemsAPI.stationDataWrapper statDetails1 = new YG_SystemsAPI.stationDataWrapper();
            statDetails1 = YG_SystemsAPI.getStationDetailsList(ast1.Id, 'VP711178', 'HIS', '0264');
            system.assertEquals('HIS', statDetails1.productSubType);
            
            YG_SystemsAPI.stationDataWrapper statDetails2 = new YG_SystemsAPI.stationDataWrapper();
            statDetails2 = YG_SystemsAPI.getStationDetailsList(ast3.Id, 'VP704674', 'BCV', '1055');
            system.assertEquals('BCV', statDetails2.productSubType);
            
            YG_SystemsAPI.stationDataWrapper statDetails3 = new YG_SystemsAPI.stationDataWrapper();
            statDetails3 = YG_SystemsAPI.getStationDetailsList(ast3.Id, 'VP704674', 'Test', '1055');
            system.assertEquals(0, statDetails3.statModData.size());
            
            Test.stopTest();            
        }
    }
}