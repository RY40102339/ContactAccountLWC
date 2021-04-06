/*
*******************************************************************************************************
* (C) Copyright 2020 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Selvaraj T
* @version 1.0
* @created 19/10/2020
* @description 
* This test class for YG_SoftwareLicensesController apex class.
*
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  
*  
*
*/

@isTest
public class YG_SoftwareLicensesControllerTest {
    
    @isTest
    static void systemsTestMethod() {
        
        //Inserting test account record
        Account acc = new account();
        acc.name='XYZ Account';        
        insert acc; 
        
        //Inserting test contact record
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
        List<Plant__c> plantList=new List<Plant__c>();
        Plant__c plant1=new Plant__c();
        plant1.Name = 'TestPlant';
        plant1.Account__c = acc.Id;  
        plant1.Plant_Code__c = '300000142';
        plant1.Lang_Code__c = 'EN';
        plantList.add(plant1);
        insert plantList;
        
        //Inserting test customer plant record
        List<Customer_Plant__c> cusPlantList=new List<Customer_Plant__c>();
        Customer_Plant__c cusPlant1=new Customer_Plant__c();
        cusPlant1.Contact__c = con.Id;
        cusPlant1.Plant__c = plant1.Id;
        cusPlantList.add(cusPlant1);
        insert cusPlantList;
        
        //Inserting test project record
        List<Project__c> projectList=new List<Project__c>();
        Project__c proj1=new Project__c();
        proj1.Account__c = acc.Id;
        proj1.Plant__c = plant1.Id;
        proj1.Name = 'Test Project';
        proj1.Project_Code__c = 'VP700250';
        proj1.Last_System_Update_Date__c = Date.today();
        proj1.Revision_No__c = 'R1.0';
        projectList.add(proj1);
        
        insert projectList;
        
        //Inserting test Category Hierarchy record
        List<Category_Hierarchy__c> catHierUppLvlList=new List<Category_Hierarchy__c>();
        Category_Hierarchy__c catHierL1=new Category_Hierarchy__c(Category_Code__c = '20000000', Category_Level__c = 1, Display_Sequence__c = 500, Upper_Category_Code__c = NULL);
        catHierUppLvlList.add(catHierL1); // DCS
        
        insert catHierUppLvlList;
        
        List<Category_Hierarchy__c> catHierLowLvlList=new List<Category_Hierarchy__c>();
        Category_Hierarchy__c catHierL21=new Category_Hierarchy__c(Category_Code__c = '21000000', Category_Level__c = 2, Display_Sequence__c = 500, Upper_Category_Code__c = NULL, Category_Hierarchy__c = catHierL1.id);
        catHierLowLvlList.add(catHierL21); //Hardware 
        
        Category_Hierarchy__c catHierL22=new Category_Hierarchy__c(Category_Code__c = '22000000', Category_Level__c = 2, Display_Sequence__c = 500, Upper_Category_Code__c = NULL, Category_Hierarchy__c = catHierL1.id);
        catHierLowLvlList.add(catHierL22); //software 
        
        insert catHierLowLvlList;
        
        //Inserting test Category record
        List<Category__c> catList=new List<Category__c>();
        Category__c catg1 = new Category__c(Name = 'Distributed Control Systems (DCS)', Category_Hierarchy__c = catHierL1.Id,
                                            Category_Type__c = 'System', Language_Code__c = 'EN');
        catList.add(catg1);
        
        Category__c catg2 = new Category__c(Name = 'Hardware', Category_Hierarchy__c = catHierL21.Id,
                                            Category_Type__c = 'System', Language_Code__c = 'EN');
        catList.add(catg2);
        
        Category__c catg3 = new Category__c(Name = 'Software', Category_Hierarchy__c = catHierL22.Id,
                                            Category_Type__c = 'System', Language_Code__c = 'EN');
        catList.add(catg3);
        
        Insert catList;
        
        //Inserting test product record
        List<Product2> prodList=new List<Product2>();
        
        Product2 prod1=new Product2();
        prod1.Name = 'Centum VP R5';
        prod1.Model_Code__c = '5';
        prod1.Category__c = catg3.Id;
        prod1.Production_Date__c = Date.newInstance(2014, 12, 17);
        prod1.Lang_Code__c = 'EN';
        prodList.add(prod1);
        
        Product2 prod2=new Product2();
        prod2.Name = 'Centum VP R6';
        prod2.Model_Code__c = '6';
        prod2.Category__c = catg3.Id;
        prod2.Production_Date__c = Date.newInstance(2014, 12, 17);
        prod2.Lang_Code__c = 'EN';
        prodList.add(prod2);
        
        Product2 prod3=new Product2();
        prod3.Name = 'Other Software';
        prod3.Model_Code__c = 'OST123';
        prod3.Category__c = catg3.Id;
        prod3.Production_Date__c = Date.newInstance(2014, 12, 17);
        prod3.Lang_Code__c = 'EN';
        prodList.add(prod3);
        
        Insert prodList;
        
        //Inserting test asset record
        List<Asset> assList=new List<Asset>();
        Asset ass1=new Asset();
        ass1.Name = '544545-54554-ff66556';
        ass1.Product2Id = prod1.Id;
        ass1.AccountId = acc.Id;
        ass1.ContactId = con.Id;
        ass1.Plant__c = plant1.Id;
        ass1.Project__c = proj1.Id;
        ass1.Lang_Code__c = 'EN';
        ass1.Revision_No__c = 'R1.0';
        assList.add(ass1);
        
        Asset ass2=new Asset();
        ass2.Name = 'HIS0102';
        ass2.Product2Id = prod2.Id;
        ass2.AccountId = acc.Id;
        ass2.ContactId = con.Id;
        ass2.Plant__c = plant1.Id;
        ass2.Project__c = proj1.Id;
        ass2.Lang_Code__c = 'EN';
        ass2.Revision_No__c = 'R1.0';
        ass2.Domain__c = 1;
        ass2.Station_Number__c = 2;
        ass2.Station_Type__c = 'HIS';
        ass2.Product_Name__c = 'HIS Product';
        assList.add(ass2);
        
        Asset ass3=new Asset();
        ass3.Name = 'OST0102';
        ass3.Product2Id = prod3.Id;
        ass3.AccountId = acc.Id;
        ass3.ContactId = con.Id;
        ass3.Plant__c = plant1.Id;
        ass3.Project__c = proj1.Id;
        ass3.Lang_Code__c = 'EN';
        ass3.Revision_No__c = 'R1.0';
        ass3.Domain__c = 1;
        ass3.Station_Number__c = 2;
        ass3.Station_Type__c = 'BCV';
        assList.add(ass3);
        
        Insert assList;
        
        //Inserting Product Extension records
        List<Maintenance_Phase__c> mtnPhaseList = new List<Maintenance_Phase__c>();
        Maintenance_Phase__c mtnPhase1 = new Maintenance_Phase__c();
        mtnPhase1.Sales_Phase_Start_Date__c = Date.newInstance(2020, 01, 10);
        mtnPhase1.Sales_Phase_End_Date__c = Date.newInstance(2021, 03, 10);
        mtnPhase1.Maintenance_Phase1_Start_Date__c = Date.newInstance(2021, 03, 11);
        mtnPhase1.Maintenance_Phase1_End_Date__c = Date.newInstance(2022, 09, 17);
        mtnPhase1.Maintenance_Phase2_Start_Date__c = Date.newInstance(2022, 09, 18);
        mtnPhase1.Maintenance_Phase2_End_Date__c = Date.newInstance(2023, 12, 17);
        mtnPhase1.Ext_Maintenance_Start_Date__c = Date.newInstance(2023, 12, 18);
        mtnPhase1.Ext_Maintenance_End_Date__c = Date.newInstance(2024, 12, 17);
        mtnPhase1.Item__c = 'Test Project';
        mtnPhase1.Sub_Item__c = 'R1.0';
        mtnPhaseList.add(mtnPhase1);
        
        Maintenance_Phase__c mtnPhase2 = new Maintenance_Phase__c();
        mtnPhase2.Sales_Phase_Start_Date__c = Date.newInstance(2010, 01, 10);
        mtnPhase2.Sales_Phase_End_Date__c = Date.newInstance(2012, 01, 09);
        mtnPhase2.Maintenance_Phase1_Start_Date__c = Date.newInstance(2012, 01, 10);
        mtnPhase2.Maintenance_Phase1_End_Date__c = Date.newInstance(2014, 09, 17);
        mtnPhase2.Maintenance_Phase2_Start_Date__c = Date.newInstance(2014, 09, 18);
        mtnPhase2.Maintenance_Phase2_End_Date__c = Date.newInstance(2016, 12, 17);
        mtnPhase2.Ext_Maintenance_Start_Date__c = Date.newInstance(2016, 12, 18);
        mtnPhase2.Ext_Maintenance_End_Date__c = Date.newInstance(2020, 10, 18);
        mtnPhase2.Item__c = 'HIS Product';
        mtnPhase2.Sub_Item__c = 'R1.0';
        mtnPhaseList.add(mtnPhase2);
        
        Maintenance_Phase__c mtnPhase3 = new Maintenance_Phase__c();
        mtnPhase3.Sales_Phase_Start_Date__c = Date.newInstance(2020, 01, 10);
        mtnPhase3.Sales_Phase_End_Date__c = Date.newInstance(2021, 03, 10);
        mtnPhase3.Maintenance_Phase1_Start_Date__c = Date.newInstance(2021, 03, 11);
        mtnPhase3.Maintenance_Phase1_End_Date__c = Date.newInstance(2022, 09, 17);
        mtnPhase3.Maintenance_Phase2_Start_Date__c = Date.newInstance(2022, 09, 18);
        mtnPhase3.Maintenance_Phase2_End_Date__c = Date.newInstance(2023, 12, 17);
        mtnPhase3.Ext_Maintenance_Start_Date__c = Date.newInstance(2023, 12, 18);
        mtnPhase3.Ext_Maintenance_End_Date__c = Date.newInstance(2024, 12, 17);
        mtnPhase3.Product__c = prod3.Id;
        mtnPhase3.Sub_Item__c = 'R1.0';
        mtnPhaseList.add(mtnPhase3);
        
        insert mtnPhaseList;
        
        //Insert custom setting records
        List<YG_Community_Configuration__c> configList = new List<YG_Community_Configuration__c>();
        YG_Community_Configuration__c centumProd = new YG_Community_Configuration__c();
        centumProd.Name = 'Centum Products Model Code';
        centumProd.Text_1__c = '1,2,3,4,5,6,21,22,23,24,25,26';
        configList.add(centumProd);
        
        YG_Community_Configuration__c emptyMod = new YG_Community_Configuration__c();
        emptyMod.Name = 'Display Empty Model Code';
        emptyMod.Text_1__c = '1,2,3,4,5,6,21,22,23,24,25,26,41,42,43,44,45,51';
        configList.add(emptyMod);
        
        insert configList;
        
        //Filter List
        List<String> filterData = new List<String>();
        List<String> filterData1 = new List<String>{'Centum VP R6'};
        
        System.RunAs(user){
            
            Test.startTest();
            
            YG_SoftwareLicensesController.softwareWrapper softLic = new YG_SoftwareLicensesController.softwareWrapper();
            softLic = YG_SoftwareLicensesController.getSoftwareLicenseDetails('300000142', filterData, 10, 0);
            system.assertEquals(3, softLic.totalSoftwareCount);
            
            YG_SoftwareLicensesController.softwareWrapper softLic1 = new YG_SoftwareLicensesController.softwareWrapper();
            softLic1 = YG_SoftwareLicensesController.getSoftwareLicenseDetails('300000142', filterData1, 10, 0);
            system.assertEquals(1, softLic1.softWrapList.size());
            
            YG_SoftwareLicensesController.softwareWrapper softLic2 = new YG_SoftwareLicensesController.softwareWrapper();
            softLic2 = YG_SoftwareLicensesController.getSoftwareLicenseDetails('', filterData, 10, 0);
            system.assertEquals(0, softLic2.softWrapList.size());
            
            YG_SoftwareLicensesController.softwareWrapper softLic3 = new YG_SoftwareLicensesController.softwareWrapper();
            softLic3 = YG_SoftwareLicensesController.getSoftwareLicenseDetails('12345', filterData, 10, 0);
            system.assertEquals(0, softLic3.totalSoftwareCount);
            
            Test.stopTest();
            
        }
        
    }

}