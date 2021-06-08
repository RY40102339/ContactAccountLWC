/*
*******************************************************************************************************
* (C) Copyright 2020 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Selvaraj T
* @version 1.0
* @created 22/07/2020
* @description 
* This test class for YG_SystemsController apex class.
*
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  09/30/2020           Selvaraj T				Updated the code and increased the code coverage
*  04/22/2021			Kavya					Removed Plant__c Object and replaced with Account Object also removed Customer_Plant__c Object and replaced with AccountContactRelation Object.
*												Removed Plant__c(Plant) Lookup field from Asset and Project Objects and newly added PlantAccount__c(Account) Lookup field in Asset  and Project Object.
*
*/

@isTest
public class YG_SystemsControllerTest {
    
    @isTest static void systemsTestMethod() {
        
        //Inserting test account record
        Account acc = new account();
        acc.name='XYZ Account';
		acc.AccountNumber = '123456';        
        acc.Type = 'Customer';
        insert acc;
        
        //Insert Self Registered Account
        Account acc1 = new account();
        acc1.name='Self Registered Account';
        acc.Type = 'Customer';	
		acc1.AccountNumber = '';        
        insert acc1; 
        
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
       /* List<Customer_Plant__c> cusPlantList=new List<Customer_Plant__c>();
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
        
        //Inserting test Parent project record
        List<Project__c> projectList=new List<Project__c>();
        Project__c proj1=new Project__c();
       proj1.Account__c = acc.Id;
        proj1.PlantAccount__c = plant1.Id;
        proj1.Name = 'Test Project';
        proj1.Project_Code__c = 'VP700250';
        proj1.Last_System_Update_Date__c = Date.today();
        proj1.Revision_No__c = 'R1.0';
        projectList.add(proj1);
        
        Project__c proj2=new Project__c();
        proj2.Account__c = acc.Id;
        proj2.PlantAccount__c = plant1.Id;
        proj2.Name = 'Test Project1';
        proj2.Project_Code__c = 'VP700255';
        proj2.Last_System_Update_Date__c = Date.today();
        proj2.Revision_No__c = 'R1.0';
        projectList.add(proj2);
        
        insert projectList;
        
        //Inserting child Parent project record
        List<Project__c> projectList1=new List<Project__c>();
        Project__c proj3=new Project__c();
        proj3.Account__c = acc.Id;
        proj3.PlantAccount__c = plant1.Id;
        proj3.Name = 'Test Project';
        proj3.Project_Code__c = 'VP700251';
        proj3.Last_System_Update_Date__c = Date.today();
        proj3.Revision_No__c = 'R1.0';
        proj3.Parent_Project__c = proj1.Id;
        projectList1.add(proj3);
        
        insert projectList1;
        
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
        prod1.Name = 'Distributed Control Systems (DCS)';
        prod1.Model_Code__c = 'AFV10D';
        prod1.Product_Type__c = 'Station';
        prod1.Category__c = catg2.Id;
       // prod1.Production_Date__c = Date.newInstance(2014, 12, 17);
        prod1.Lang_Code__c = 'EN';
        prodList.add(prod1);
        
        Product2 prod2=new Product2();
        prod2.Name = 'PC';
        prod2.Model_Code__c = 'PC';
        prod2.Product_Type__c = 'Station';
        prod2.Category__c = catg3.Id;
       // prod2.Production_Date__c = Date.newInstance(2014, 12, 17);
        prod2.Lang_Code__c = 'EN';
        prodList.add(prod2);
        
        Product2 prod3=new Product2();
        prod3.Name = 'Test BCV';
        prod3.Model_Code__c = 'BCV01';
        prod3.Product_Type__c = 'Station';
        prod3.Category__c = catg3.Id;
      //  prod3.Production_Date__c = Date.newInstance(2014, 12, 17);
        prod3.Lang_Code__c = 'EN';
        prodList.add(prod3);
        
        Insert prodList;
        
        //Inserting test asset record
        List<Asset> assList=new List<Asset>();
        Asset ass1=new Asset();
        ass1.Name = 'FCS0111';
        ass1.Product2Id = prod1.Id;
       ass1.AccountId = acc.Id;
        ass1.ContactId = con.Id;
        ass1.PlantAccount__c = plant1.Id;
        ass1.Project__c = proj1.Id;
        ass1.Lang_Code__c = 'EN';
        ass1.Revision_No__c = 'R1.0';
        ass1.Domain__c = 1;
        ass1.Station_Number__c = 2;
        ass1.Station_Type__c = 'FCS';
        assList.add(ass1);
        
        Asset ass2=new Asset();
        ass2.Name = 'HIS0101';
        ass2.Product2Id = prod2.Id;
        ass2.AccountId = acc.Id;
        ass2.ContactId = con.Id;
        ass2.PlantAccount__c = plant1.Id;
        ass2.Project__c = proj1.Id;
        ass2.Lang_Code__c = 'EN';
        ass2.Revision_No__c = 'R1.0';
        ass2.Domain__c = 1;
        ass2.Station_Number__c = 1;
        ass2.Station_Type__c = 'HIS';
        ass2.Product_Name__c = 'Test Project';
        assList.add(ass2);
        
        Asset ass3=new Asset();
        ass3.Name = 'BCV0202';
        ass3.Product2Id = prod3.Id;
        ass3.AccountId = acc.Id;
        ass3.ContactId = con.Id;
        ass3.PlantAccount__c = plant1.Id;
        ass3.Project__c = proj1.Id;
        ass3.Lang_Code__c = 'EN';
        ass3.Revision_No__c = 'R1.0';
        ass3.Domain__c = 2;
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
        mtnPhase1.Product__c = prod1.Id;
        mtnPhaseList.add(mtnPhase1);
        
        Maintenance_Phase__c mtnPhase2 = new Maintenance_Phase__c();
        mtnPhase2.Sales_Phase_Start_Date__c = Date.newInstance(2020, 01, 10);
        mtnPhase2.Sales_Phase_End_Date__c = Date.newInstance(2021, 03, 10);
        mtnPhase2.Maintenance_Phase1_Start_Date__c = Date.newInstance(2021, 03, 11);
        mtnPhase2.Maintenance_Phase1_End_Date__c = Date.newInstance(2022, 09, 17);
        mtnPhase2.Maintenance_Phase2_Start_Date__c = Date.newInstance(2022, 09, 18);
        mtnPhase2.Maintenance_Phase2_End_Date__c = Date.newInstance(2023, 12, 17);
        mtnPhase2.Ext_Maintenance_Start_Date__c = Date.newInstance(2023, 12, 18);
        mtnPhase2.Ext_Maintenance_End_Date__c = Date.newInstance(2024, 12, 17);
        mtnPhase2.Product__c = prod3.Id;
        mtnPhase2.Sub_Item__c = 'R1.0';
        mtnPhaseList.add(mtnPhase2);
        
        Maintenance_Phase__c mtnPhase3 = new Maintenance_Phase__c();
        mtnPhase3.Sales_Phase_Start_Date__c = Date.newInstance(2014, 01, 10);
        mtnPhase3.Sales_Phase_End_Date__c = Date.newInstance(2015, 01, 09);
        mtnPhase3.Maintenance_Phase1_Start_Date__c = Date.newInstance(2015, 01, 10);
        mtnPhase3.Maintenance_Phase1_End_Date__c = Date.newInstance(2018, 09, 17);
        mtnPhase3.Maintenance_Phase2_Start_Date__c = Date.newInstance(2018, 09, 18);
        mtnPhase3.Maintenance_Phase2_End_Date__c = Date.newInstance(2050, 12, 17);
        mtnPhase3.Ext_Maintenance_Start_Date__c = Date.newInstance(2050, 12, 18);
        mtnPhase3.Ext_Maintenance_End_Date__c = Date.newInstance(2055, 12, 17);
		mtnPhase3.Item__c = 'Test Project';
		mtnPhase3.Sub_Item__c = 'R1.0';        
        mtnPhaseList.add(mtnPhase3);
        
        insert mtnPhaseList;
        
        
        //Inserting Service Contracts records
        List<ServiceContract> servContList = new List<ServiceContract>();
        ServiceContract servCont1 = new ServiceContract();
        servCont1.Name = 'Test Service Contract';
        servCont1.Contract_No__c = 'SC-0001';
        servCont1.StartDate = Date.newInstance(2020, 09, 29);
        servCont1.EndDate = Date.newInstance(2021, 02, 17);
        servCont1.Contract_Type__c = 'LCA';
        servContList.add(servCont1);
        
        ServiceContract servCont2 = new ServiceContract();
        servCont2.Name = 'Test Service Contract';
        servCont2.Contract_No__c = 'SC-0001';
        servCont2.StartDate = Date.newInstance(2020, 09, 29);
        servCont2.EndDate = Date.newInstance(2025, 02, 17);
        servCont2.Contract_Type__c = 'LCA';
        servContList.add(servCont2);
        
        insert servContList;
        
        //Inserting SOP record
        Scope_of_Product__c sop1 = new Scope_of_Product__c();
        sop1.Service_Contract__c = servCont1.Id;
        sop1.Asset__c = ass2.Id;
        insert sop1;
        
        //Insert custom setting records
        List<YG_Community_Configuration__c> configList = new List<YG_Community_Configuration__c>();
		YG_Community_Configuration__c apiDays=new YG_Community_Configuration__c();
        apiDays.Name = 'Deliverable API Execution Days';
        apiDays.Text_1__c = '1';
        configList.add(apiDays); 
        
        YG_Community_Configuration__c selfAcc=new YG_Community_Configuration__c();
        selfAcc.Name = 'YGSelfRegisterAccountId';
        selfAcc.Text_1__c = acc1.Id;
        configList.add(selfAcc); 
        
        insert configList;
        
        //Filter List
        List<String> filterData = new List<String>();
        List<String> filterData1 = new List<String>{'FCS0111','AAI143'};
            
            System.RunAs(user){
                
                Test.startTest();
                
                Boolean isAPICall = YG_SystemsController.callDelivAPI('300000142');
                system.assertEquals(true, isAPICall);
                
                YG_SystemsController.systemWrapper sysWrap = new YG_SystemsController.systemWrapper();
                sysWrap = YG_SystemsController.getAllSystemsDetails('300000142', '');
                system.assertEquals(1, sysWrap.projCodeList.size());
                
                YG_SystemsController.systemWrapper sysWrap1 = new YG_SystemsController.systemWrapper();
                sysWrap1 = YG_SystemsController.getAllSystemsDetails('300000142', 'VP700250');
                system.assertEquals(1, sysWrap.servConWrap.size());
                
                YG_SystemsController.systemWrapper sysWrap2 = new YG_SystemsController.systemWrapper();
                sysWrap2 = YG_SystemsController.getAllSystemsDetails('123', '');
                
                YG_SystemsController.projectWrapper projWrap = new YG_SystemsController.projectWrapper();
                projWrap = YG_SystemsController.getAllStationDetails('300000142', 'VP700250',filterData1);
                system.assertEquals(1, projWrap.statWrap.size());
                
                YG_SystemsController.projectWrapper projWrap1 = new YG_SystemsController.projectWrapper();
                projWrap1 = YG_SystemsController.getAllStationDetails('', '',filterData);
                
                String phaseEndExcep = YG_SystemsController.getPhaseEndsIn(null);
                                        
                Test.stopTest();
                
            }        
    }
}