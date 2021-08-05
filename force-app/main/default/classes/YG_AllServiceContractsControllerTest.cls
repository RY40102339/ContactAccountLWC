/********************************************************************************************************
* (C) Copyright 2020 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Vinod A
* @version 1.0
* @created 10/05/2020
* @description 
* This test class for YG_AllServiceContractsController apex class.
*
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  04/21/2021           Kavya 					Removed Plant__c Object and replaced with Account Object also removed Customer_Plant__c Object and replaced with AccountContactRelation Object.
*												Removed Plant__c(Plant) Lookup field from Asset and Project Objects and newly added PlantAccount__c(Account) Lookup field in Asset  and Project Object.
*
*/

@isTest
public class YG_AllServiceContractsControllerTest {
    
    
    @istest static void ygAllServiceContractTestMethod(){
        
        //Insert test account record
        Account acc = new account();
        acc.name='Sample Account';   
        acc.Type = 'Customer';
        //acc.DUNS_Number__c=107906668; 
        insert acc;
        
        //Insert test contact record
        Contact con = new Contact();   
        con.FirstName='client';
        con.LastName='test';
        con.Email='testclient@chevron.com';
        con.accountid=acc.id; 
        insert con;
        
        //Insert test portal user record
        User user = new User();   
        user.ProfileID = [Select Id From Profile Where Name='Customer Portal User'].id; 
        System.debug('user.ProfileID');
        user.EmailEncodingKey = 'ISO-8859-1';   user.LanguageLocaleKey = 'en_US';   user.TimeZoneSidKey = 'America/New_York';   
        user.LocaleSidKey = 'en_US';   user.FirstName = 'client';   user.LastName = 'test';   user.Username = 'testclient@chevron.com';      
        user.CommunityNickname = 'client22';   user.Alias = 'client';   user.Email = 'testclient@chevron.com';   user.IsActive = true;   
        user.ContactId = con.Id;  
        insert user; 
        
        //Insert test plant record
        //List<Plant__c> plantList=new List<Plant__c>();
     /*   Plant__c plant1=new Plant__c();
        plant1.Name = 'TestPlant';
        plant1.Account__c = acc.Id;  
        plant1.Plant_Code__c = '300000142';
        plant1.Lang_Code__c = 'EN';
        //plantList.add(plant1);
        insert plant1;*/
        
        //Insert test plant record
        //List<Plant__c> plantList=new List<Plant__c>();
         Account plant1=new Account();
        plant1.Name = 'TestPlant';
        plant1.ParentId = acc.Id;  
        plant1.AccountNumber = '300000142';
         plant1.Type = 'Plant';
        //plantList.add(plant1);
        insert plant1;
        //insert plantList;
        
        //Insert test customer plant record
       /* List<Customer_Plant__c> cusPlantList=new List<Customer_Plant__c>();
        Customer_Plant__c cusPlant1=new Customer_Plant__c();
        cusPlant1.Contact__c = con.Id;
        cusPlant1.Plant__c = plant1.Id;
        cusPlantList.add(cusPlant1);
        insert cusPlantList;*/
        
        //Insert test customer plant record
        List<AccountContactRelation> cusPlantList=new List<AccountContactRelation>();
        AccountContactRelation cusPlant1=new AccountContactRelation();
        cusPlant1.ContactId = con.Id;
        cusPlant1.AccountId = plant1.Id;
        cusPlantList.add(cusPlant1);
        insert cusPlantList;
        
        //Insert test project record
        List<Project__c> projectList=new List<Project__c>();
        Project__c proj1=new Project__c();
        proj1.Account__c = acc.Id;
       	proj1.PlantAccount__c = plant1.Id;
        proj1.Project_Code__c = 'VP700250';
        projectList.add(proj1);
        insert projectList;
        
        //Insert test Category Hierarchy record
        List<Category_Hierarchy__c> catHierListTop=new List<Category_Hierarchy__c>();
        Category_Hierarchy__c catHierTop1=new Category_Hierarchy__c(Category_Code__c = '10000000', Category_Level__c = 1, Display_Sequence__c = 500,
                                                                    Upper_Category_Code__c = NULL);
        catHierListTop.add(catHierTop1);
        insert catHierListTop;
        
        List<Category_Hierarchy__c> catHierList=new List<Category_Hierarchy__c>();
        Category_Hierarchy__c catHier2=new Category_Hierarchy__c(Category_Code__c = '11000000', Category_Level__c = 2, Display_Sequence__c = 500,
                                                                 Upper_Category_Code__c = '10000000', Category_Hierarchy__c = catHierTop1.id);
        catHierList.add(catHier2);
        Category_Hierarchy__c catHier3=new Category_Hierarchy__c(Category_Code__c = '12000000', Category_Level__c = 3, Display_Sequence__c = 500,
                                                                 Upper_Category_Code__c = '11000000', Category_Hierarchy__c = catHierTop1.id);
        catHierList.add(catHier3);
        
        insert catHierList;
        System.debug('catHierList::'+catHierList);
        
        //Insert test category record
        List<Category__c> catList=new List<Category__c>();
        Category__c catg1=new Category__c(Name = 'Field Instruments', Category_Hierarchy__c = catHierTop1.Id,
                                          Category_Type__c = 'Product', Language_Code__c = 'EN');
        catList.add(catg1);
        Category__c catg2=new Category__c(Name = 'Device Smart Communicators', Category_Hierarchy__c = catHier2.Id,
                                          Category_Type__c = 'Product', Language_Code__c = 'EN');
        catList.add(catg2);
        Category__c catg3=new Category__c(Name = 'Device Smart Communicators BT200', Category_Hierarchy__c = catHier3.Id,
                                          Category_Type__c = 'Product', Language_Code__c = 'EN');
        catList.add(catg3);
        
        insert catList;
        System.debug('catList::'+catList);
        
        //Insert test product record
        List<Product2> prodList=new List<Product2>();
        
        Product2 prod2=new Product2();
        prod2.Name = 'Device Smart Communicators BT200';
        prod2.Model_Code__c = 'BT200';
        prod2.Category__c = catg3.Id;
       // prod2.Production_Date__c = Date.newInstance(2014, 12, 17);
        prod2.Lang_Code__c = 'EN';
        prodList.add(prod2);
        
        Insert prodList;
        System.debug('prodList::*'+prodList);
        
        //Insert test asset record
        List<Asset> assList=new List<Asset>();
        Asset ass1=new Asset();
        ass1.Name = 'SU1234567';
        ass1.Product2Id = prod2.Id;
        ass1.AccountId = acc.Id;
        ass1.ContactId = con.Id;
        ass1.SerialNumber = 'SU1234567';
       	ass1.PlantAccount__c = plant1.Id;
        ass1.MS_Code__c = 'AAI543-H50';
        //ass1.Shipping_Date__c = Date.newInstance(2019, 7, 28);
        ass1.Lang_Code__c = 'EN';
        ass1.Status = 'Installed';
        
        assList.add(ass1);
        
        Asset ass2=new Asset();
        ass2.Name = 'SU1234568';
        ass2.Product2Id = prod2.Id;
        ass2.AccountId = acc.Id;
        ass2.ContactId = con.Id;
        ass2.SerialNumber = 'SU1234568';
        ass2.PlantAccount__c = plant1.Id;
        ass2.MS_Code__c = 'AAI543-H50';
        ass2.Lang_Code__c = 'EN';
        //ass2.Shipping_Date__c = Date.newInstance(2014, 12, 28);
        ass2.Status = 'Installed';
        
        assList.add(ass2);     
        
        Asset ass3=new Asset();
        ass3.Name = 'SU1234569';
        ass3.Product2Id = prod2.Id;
        ass3.AccountId = acc.Id;
        ass3.ContactId = con.Id;
        ass3.SerialNumber = 'SU1234569';
        ass3.PlantAccount__c = plant1.Id;
        ass3.MS_Code__c = 'AAI543-H50';
        //ass3.Shipping_Date__c = Date.newInstance(2014, 12, 28);
        ass3.Status = 'Installed';
        ass3.Lang_Code__c = 'EN';
        
        assList.add(ass3); 
        
        Asset ass4=new Asset();
        ass4.Name = 'SU1234579';
        ass4.Product2Id = prod2.Id;
        ass4.AccountId = acc.Id;
        ass4.ContactId = con.Id;
        ass4.SerialNumber = 'SU1234579';
        ass4.PlantAccount__c = plant1.Id;
        ass4.MS_Code__c = 'AAI543-H50';
        //ass4.Shipping_Date__c = Date.newInstance(2014, 12, 28);
        ass4.Status = 'Installed';
        ass4.Lang_Code__c = 'EN';
        
        assList.add(ass4); 
        
        Asset ass5=new Asset();
        ass5.Name = 'SU1234589';
        ass5.Product2Id = prod2.Id;
        ass5.AccountId = acc.Id;
        ass5.ContactId = con.Id;
        ass5.SerialNumber = 'SU1234589';
        ass5.PlantAccount__c = plant1.Id;
        ass5.MS_Code__c = 'AAI543-H50';
        //ass5.Shipping_Date__c = Date.newInstance(2014, 12, 28);
        ass5.Status = 'Installed';
        ass5.Lang_Code__c = 'EN';
        
        assList.add(ass5); 
        
        insert assList;
        System.debug('assList::*'+assList);
        
        //Inserting Customer Asset
        List<Customer_Asset__c> customerAsset=new List<Customer_Asset__c>();
        Customer_Asset__c custAss1=new Customer_Asset__c();
        custAss1.Asset__c = ass1.Id;
        custAss1.Contact__c = con.Id;
        customerAsset.add(custAss1);
        
        Customer_Asset__c custAss2=new Customer_Asset__c();
        custAss2.Asset__c = ass2.Id;
        custAss2.Contact__c = con.Id;
        customerAsset.add(custAss2);
        
        Customer_Asset__c custAss3=new Customer_Asset__c();
        custAss3.Asset__c = ass3.Id;
        custAss3.Contact__c = con.Id;
        customerAsset.add(custAss3);
        
        Customer_Asset__c custAss4=new Customer_Asset__c();
        custAss4.Asset__c = ass4.Id;
        custAss4.Contact__c = con.Id;
        customerAsset.add(custAss4);
        
        Customer_Asset__c custAss5=new Customer_Asset__c();
        custAss5.Asset__c = ass5.Id;
        custAss5.Contact__c = con.Id;
        customerAsset.add(custAss5);
        
        insert customerAsset;
        System.debug('customerAsset::*'+customerAsset);
        //Inserting Service Contract record
        //Service contract active and expiry in less than 6 month
        ServiceContract servCont1=new ServiceContract();
        servCont1.Name = 'UMM AL HOUL Power Control System';
        servCont1.AccountId = acc.Id;
        servCont1.Contract_No__c = 'YEA-L0001-1901-01';
        servCont1.Description = '2019 LCA Control Systems for the GAS Processing Plant';
        servCont1.ContactId = con.Id;
        servCont1.Contract_categories__c = 'Industrial Automation';
        servCont1.Contract_Type__c = 'LCA';
        servCont1.Language_Code__c = 'EN';
        servCont1.YG_Sales_Manager_Name__c = 'Rob Bush';
        servCont1.StartDate = date.newInstance(2019, 09, 09);
        servCont1.EndDate = date.today() + 30;
        servCont1.YG_Sales_Manager_contact_no__c = '909090909';
        servCont1.YG_Sales_Manager_Email__c = 'ygManager@gmail.com';
        insert servCont1;
        System.debug('servCont1::*'+servCont1);
        
        Entitlement entitle1=new Entitlement();
        entitle1.Name = 'Patrol Inspection';
        entitle1.AccountId = acc.Id;
        entitle1.Type = 'Times to visit';
        entitle1.ServiceContractId = servCont1.Id;
        entitle1.Entitlement_type__c = 'Patrol';
        entitle1.Per__c = 'LCA';
        entitle1.Entitlement_balance__c = 2;
        entitle1.Entitlement_quantity__c = 5;
        insert entitle1;
        System.debug('entitle1::*'+entitle1);
        
        Case cas=new Case();
        cas.ContactId = con.Id;
        cas.AccountId = acc.Id;
        cas.AssetId = ass1.Id;
        cas.EntitlementId = entitle1.Id;
        cas.Subject = 'Case Raised';
        cas.Progress__c = 'Request Submitted';
        insert cas;
        
        Case casHis=new Case();
        casHis.Id = cas.Id;
        casHis.Progress__c = 'Request Closed';
        update casHis;
        
        
        
        
        
        
        /*Inspection__c inspec1=new Inspection__c();
        inspec1.Actual_Date__c = date.today() + 31;
        inspec1.Scheduled_Date__c = date.today() +30;
        inspec1.Entitlement__c = entitle1.Id;
        inspec1.Type__c = 'Patrol';
        insert inspec1;
        Inspection__c inspec2=new Inspection__c();
        inspec2.Actual_Date__c = date.today() + 61;
        inspec2.Scheduled_Date__c = date.today() +60;
        inspec2.Entitlement__c = entitle1.Id;
        inspec2.Type__c = 'Patrol';
        insert inspec2;*/
        
        //Service contract expired
        ServiceContract servCont2=new ServiceContract();
        servCont2.Name = 'M421103 Origin Energy Marex AMC';
        servCont2.AccountId = acc.Id;
        servCont2.Contract_No__c = 'YEA-L00330-2007-01';
        servCont2.Description = 'M421103 Origin Energy Eraring Marex AMC 2020 - 2021';
        servCont2.ContactId = con.Id;
        servCont2.Contract_categories__c = 'Industrial Automation';
        servCont2.Contract_Type__c = 'LCA';
        servCont2.Language_Code__c = 'EN';
        servCont2.YG_Sales_Manager_Name__c = 'Rob Bush';
        servCont2.StartDate = date.newInstance(2019, 09, 09);
        servCont2.EndDate = date.today() - 30;
        servCont2.YG_Sales_Manager_contact_no__c = '909090909';
        servCont2.YG_Sales_Manager_Email__c = 'ygManager@gmail.com';
        insert servCont2;
        System.debug('servCont2::*'+servCont2);
        
        //Service contract Inactive
        ServiceContract servCont3=new ServiceContract();
        servCont3.Name = 'M450805 TERRITORY GENERATION ROC';
        servCont3.AccountId = acc.Id;
        servCont3.Contract_No__c = 'YEA-L00144-1911-01';
        servCont3.Description = 'M450805 Territory Generation LCA 2019-2020';
        servCont3.ContactId = con.Id;
        servCont3.Contract_categories__c = 'Industrial Automation';
        servCont3.Contract_Type__c = 'LCA';
        servCont3.Language_Code__c = 'EN';
        servCont3.YG_Sales_Manager_Name__c = 'Rob Bush';
        servCont3.StartDate = date.today() + 30;
        servCont3.EndDate = date.today() + 90;
        servCont3.YG_Sales_Manager_contact_no__c = '909090909';
        servCont3.YG_Sales_Manager_Email__c = 'ygManager@gmail.com';
        insert servCont3;
        System.debug('servCont3::*'+servCont3);
        
        //Service contract Active and BCP
        ServiceContract servCont4=new ServiceContract();
        servCont4.Name = 'Best Condition Plan';
        servCont4.AccountId = acc.Id;
        servCont4.Contract_No__c = '73F3-BC6782J';
        servCont4.Description = 'AQ1215A OTDR MULTI FIELD TESTER';
        servCont4.ContactId = con.Id;
        servCont4.Contract_categories__c = 'Test & Measurement';
        servCont4.Contract_Type__c = 'BCP';
        servCont4.Language_Code__c = 'EN';
        servCont4.YG_Sales_Manager_Name__c = 'Rob Bush';
        servCont4.StartDate = date.today() - 30;
        servCont4.EndDate = date.today() + 300;
        servCont4.YG_Sales_Manager_contact_no__c = '909090909';
        servCont4.YG_Sales_Manager_Email__c = 'ygManager@gmail.com';
        insert servCont4;
        System.debug('servCont4::*'+servCont4);
        
        Entitlement entitle2=new Entitlement();
        entitle2.Name = 'Calibration';
        entitle2.AccountId = acc.Id;
        entitle2.Type = 'Periodic';
        entitle2.ServiceContractId = servCont4.Id;
        entitle2.Per__c = '12 Months';
        entitle2.Entitlement_balance__c = 2;
        entitle2.Entitlement_quantity__c = 5;
        entitle2.AssetId = ass1.Id;
        entitle2.AccountId = acc.Id;
        insert entitle2;
        System.debug('entitle2::*'+entitle2);
        
        Scope_of_Product__c sop1=new Scope_of_Product__c(); 
        sop1.Name = 'SU1234567';
        sop1.Service_Contract__c = servCont1.Id;
        sop1.Asset__c = ass1.Id;
        insert sop1;
        
        User userRecord = [select id from user where UserName='testclient@chevron.com'];
        System.runAs(userRecord) {
            Test.startTest();
            User loggedInUser= YG_Utility.getLoggedInUserInfo(UserInfo.getUserId());
            List<Id> servcontId=new List<Id>();
            List<Id> servcontIdList=new List<Id>();
            servcontIdList.add(servCont1.Id);
            System.debug('servcontIdList::'+servcontIdList);
            YG_AllServiceContractsController.ServiceContractWrapper result=new YG_AllServiceContractsController.ServiceContractWrapper();
            result = YG_AllServiceContractsController.getAllServiceContracts('300000142',null,null,servcontId,10,0);
            //System.debug('result1::'+result);
            System.assertEquals(1, result.expirySixMonths);
            System.assertEquals(1, result.activeContract);
            System.assertEquals(1, result.expiredContract);
            System.assertEquals(1, result.futureContract);
            result = YG_AllServiceContractsController.getAllServiceContracts('300000142','Active',null,servcontId,10,0);
            System.assertEquals(1, result.activeContract);
            result = YG_AllServiceContractsController.getAllServiceContracts('300000142','Expires',null,servcontId,10,0);
            System.assertEquals(1, result.expirySixMonths);
            result = YG_AllServiceContractsController.getAllServiceContracts('300000142','Expires','Industrial Automation',servcontId,10,0);
            System.assertEquals(1, result.expirySixMonths);
            result = YG_AllServiceContractsController.getAllServiceContracts('300000142',null,'Industrial Automation',servcontId,10,0);
            System.assertEquals(3, result.radioBtnCnt);
            result = YG_AllServiceContractsController.getAllServiceContracts('300000142','Active','Industrial Automation',servcontId,10,0);
            System.assertEquals(1, result.activeContract);
            
            
            //Checking for the filter search
            result = YG_AllServiceContractsController.getAllServiceContracts('300000142',null,null,servcontIdList,10,0);
            System.assertEquals(4, result.totalContractCnt);
            result = YG_AllServiceContractsController.getAllServiceContracts('300000142','Active',null,servcontIdList,10,0);
            System.assertEquals(1, result.activeContract);
            
            
            Test.stopTest();
        }
    }
    
    @istest static void getTotalContractSizeTest(){
        
//Insert test account record
        Account acc = new account();
        acc.name='Sample Account';        
        acc.Type = 'Customer';
        //acc.DUNS_Number__c=107906668; 
        insert acc;
        
        //Insert test contact record
        Contact con = new Contact();   
        con.FirstName='client';
        con.LastName='test';
        con.Email='testclient@chevron.com';
        con.accountid=acc.id; 
        insert con;
        
        //Insert test portal user record
        User user = new User();   
        user.ProfileID = [Select Id From Profile Where Name='Customer Portal User'].id; 
        System.debug('user.ProfileID');
        user.EmailEncodingKey = 'ISO-8859-1';   user.LanguageLocaleKey = 'en_US';   user.TimeZoneSidKey = 'America/New_York';   
        user.LocaleSidKey = 'en_US';   user.FirstName = 'client';   user.LastName = 'test';   user.Username = 'testclient@chevron.com';      
        user.CommunityNickname = 'client22';   user.Alias = 'client';   user.Email = 'testclient@chevron.com';   user.IsActive = true;   
        user.ContactId = con.Id;  
        insert user; 
        
        //Insert test plant record
        //List<Plant__c> plantList=new List<Plant__c>();
       /* Plant__c plant1=new Plant__c();
        plant1.Name = 'TestPlant';
        plant1.Account__c = acc.Id;  
        plant1.Plant_Code__c = '300000142';
        plant1.Lang_Code__c = 'EN';*/
         Account plant1=new Account();
        plant1.Name = 'TestPlant';
        plant1.ParentId = acc.Id;  
        plant1.AccountNumber = '300000142';
         plant1.Type = 'Plant';
       // plant1.Lang_Code__c = 'EN';
        //plantList.add(plant1);
        insert plant1;
        //insert plantList;
        
        //Insert test customer plant record
      /*  List<Customer_Plant__c> cusPlantList=new List<Customer_Plant__c>();
        Customer_Plant__c cusPlant1=new Customer_Plant__c();
        cusPlant1.Contact__c = con.Id;
        cusPlant1.Plant__c = plant1.Id;*/
          //Insert test customer plant record
        List<AccountContactRelation> cusPlantList=new List<AccountContactRelation>();
        AccountContactRelation cusPlant1=new AccountContactRelation();
        cusPlant1.ContactId = con.Id;
        cusPlant1.AccountId = plant1.Id;
        cusPlantList.add(cusPlant1);
        insert cusPlantList;
        
        //Insert test project record
        List<Project__c> projectList=new List<Project__c>();
        Project__c proj1=new Project__c();
        proj1.Account__c = acc.Id;
        proj1.PlantAccount__c = plant1.Id;
        proj1.Project_Code__c = 'VP700250';
        projectList.add(proj1);
        insert projectList;
        
        //Insert test Category Hierarchy record
        List<Category_Hierarchy__c> catHierListTop=new List<Category_Hierarchy__c>();
        Category_Hierarchy__c catHierTop1=new Category_Hierarchy__c(Category_Code__c = '10000000', Category_Level__c = 1, Display_Sequence__c = 500,
                                                                    Upper_Category_Code__c = NULL);
        catHierListTop.add(catHierTop1);
        insert catHierListTop;
        
        List<Category_Hierarchy__c> catHierList=new List<Category_Hierarchy__c>();
        Category_Hierarchy__c catHier2=new Category_Hierarchy__c(Category_Code__c = '11000000', Category_Level__c = 2, Display_Sequence__c = 500,
                                                                 Upper_Category_Code__c = '10000000', Category_Hierarchy__c = catHierTop1.id);
        catHierList.add(catHier2);
        Category_Hierarchy__c catHier3=new Category_Hierarchy__c(Category_Code__c = '12000000', Category_Level__c = 3, Display_Sequence__c = 500,
                                                                 Upper_Category_Code__c = '11000000', Category_Hierarchy__c = catHierTop1.id);
        catHierList.add(catHier3);
        
        insert catHierList;
        System.debug('catHierList::'+catHierList);
        
        //Insert test category record
        List<Category__c> catList=new List<Category__c>();
        Category__c catg1=new Category__c(Name = 'Field Instruments', Category_Hierarchy__c = catHierTop1.Id,
                                          Category_Type__c = 'Product', Language_Code__c = 'EN');
        catList.add(catg1);
        Category__c catg2=new Category__c(Name = 'Device Smart Communicators', Category_Hierarchy__c = catHier2.Id,
                                          Category_Type__c = 'Product', Language_Code__c = 'EN');
        catList.add(catg2);
        Category__c catg3=new Category__c(Name = 'Device Smart Communicators BT200', Category_Hierarchy__c = catHier3.Id,
                                          Category_Type__c = 'Product', Language_Code__c = 'EN');
        catList.add(catg3);
        
        insert catList;
        System.debug('catList::'+catList);
        
        //Insert test product record
        List<Product2> prodList=new List<Product2>();
        
        Product2 prod2=new Product2();
        prod2.Name = 'Device Smart Communicators BT200';
        prod2.Model_Code__c = 'BT200';
        prod2.Category__c = catg3.Id;
       // prod2.Production_Date__c = Date.newInstance(2014, 12, 17);
        prod2.Lang_Code__c = 'EN';
        prodList.add(prod2);
        
        Insert prodList;
        System.debug('prodList::*'+prodList);
        
        //Insert test asset record
        List<Asset> assList=new List<Asset>();
        Asset ass1=new Asset();
        ass1.Name = 'SU1234567';
        ass1.Product2Id = prod2.Id;
        ass1.AccountId = acc.Id;
        ass1.ContactId = con.Id;
        ass1.SerialNumber = 'SU1234567';
        ass1.PlantAccount__c = plant1.Id;
        ass1.MS_Code__c = 'AAI543-H50';
        //ass1.Shipping_Date__c = Date.newInstance(2019, 7, 28);
        ass1.Lang_Code__c = 'EN';
        ass1.Status = 'Installed';
        
        assList.add(ass1);
        
        Asset ass2=new Asset();
        ass2.Name = 'SU1234568';
        ass2.Product2Id = prod2.Id;
        ass2.AccountId = acc.Id;
        ass2.ContactId = con.Id;
        ass2.SerialNumber = 'SU1234568';
        ass2.PlantAccount__c = plant1.Id;
        ass2.MS_Code__c = 'AAI543-H50';
        ass2.Lang_Code__c = 'EN';
        //ass2.Shipping_Date__c = Date.newInstance(2014, 12, 28);
        ass2.Status = 'Installed';
        
        assList.add(ass2);     
        
        Asset ass3=new Asset();
        ass3.Name = 'SU1234569';
        ass3.Product2Id = prod2.Id;
        ass3.AccountId = acc.Id;
        ass3.ContactId = con.Id;
        ass3.SerialNumber = 'SU1234569';
        ass3.PlantAccount__c = plant1.Id;
        ass3.MS_Code__c = 'AAI543-H50';
        //ass3.Shipping_Date__c = Date.newInstance(2014, 12, 28);
        ass3.Status = 'Installed';
        ass3.Lang_Code__c = 'EN';
        
        assList.add(ass3); 
        
        Asset ass4=new Asset();
        ass4.Name = 'SU1234579';
        ass4.Product2Id = prod2.Id;
        ass4.AccountId = acc.Id;
        ass4.ContactId = con.Id;
        ass4.SerialNumber = 'SU1234579';
        ass4.PlantAccount__c = plant1.Id;
        ass4.MS_Code__c = 'AAI543-H50';
        //ass4.Shipping_Date__c = Date.newInstance(2014, 12, 28);
        ass4.Status = 'Installed';
        ass4.Lang_Code__c = 'EN';
        
        assList.add(ass4); 
        
        Asset ass5=new Asset();
        ass5.Name = 'SU1234589';
        ass5.Product2Id = prod2.Id;
        ass5.AccountId = acc.Id;
        ass5.ContactId = con.Id;
        ass5.SerialNumber = 'SU1234589';
        ass5.PlantAccount__c = plant1.Id;
        ass5.MS_Code__c = 'AAI543-H50';
        //ass5.Shipping_Date__c = Date.newInstance(2014, 12, 28);
        ass5.Status = 'Installed';
        ass5.Lang_Code__c = 'EN';
        
        assList.add(ass5); 
        
        insert assList;
        System.debug('assList::*'+assList);
        
        //Inserting Customer Asset
        List<Customer_Asset__c> customerAsset=new List<Customer_Asset__c>();
        Customer_Asset__c custAss1=new Customer_Asset__c();
        custAss1.Asset__c = ass1.Id;
        custAss1.Contact__c = con.Id;
        customerAsset.add(custAss1);
        
        Customer_Asset__c custAss2=new Customer_Asset__c();
        custAss2.Asset__c = ass2.Id;
        custAss2.Contact__c = con.Id;
        customerAsset.add(custAss2);
        
        Customer_Asset__c custAss3=new Customer_Asset__c();
        custAss3.Asset__c = ass3.Id;
        custAss3.Contact__c = con.Id;
        customerAsset.add(custAss3);
        
        Customer_Asset__c custAss4=new Customer_Asset__c();
        custAss4.Asset__c = ass4.Id;
        custAss4.Contact__c = con.Id;
        customerAsset.add(custAss4);
        
        Customer_Asset__c custAss5=new Customer_Asset__c();
        custAss5.Asset__c = ass5.Id;
        custAss5.Contact__c = con.Id;
        customerAsset.add(custAss5);
        
        insert customerAsset;
        System.debug('customerAsset::*'+customerAsset);
        //Inserting Service Contract record
        //Service contract active and expiry in less than 6 month
        ServiceContract servCont1=new ServiceContract();
        servCont1.Name = 'UMM AL HOUL Power Control System';
        servCont1.AccountId = acc.Id;
        servCont1.Contract_No__c = 'YEA-L0001-1901-01';
        servCont1.Description = '2019 LCA Control Systems for the GAS Processing Plant';
        servCont1.ContactId = con.Id;
        servCont1.Contract_categories__c = 'Industrial Automation';
        servCont1.Contract_Type__c = 'LCA';
        servCont1.Language_Code__c = 'EN';
        servCont1.YG_Sales_Manager_Name__c = 'Rob Bush';
        servCont1.StartDate = date.newInstance(2019, 09, 09);
        servCont1.EndDate = date.today() + 30;
        servCont1.YG_Sales_Manager_contact_no__c = '909090909';
        servCont1.YG_Sales_Manager_Email__c = 'ygManager@gmail.com';
        insert servCont1;
        System.debug('servCont1::*'+servCont1);
        
        Entitlement entitle1=new Entitlement();
        entitle1.Name = 'Patrol Inspection';
        entitle1.AccountId = acc.Id;
        entitle1.Type = 'Times to visit';
        entitle1.ServiceContractId = servCont1.Id;
        entitle1.Entitlement_type__c = 'Patrol';
        entitle1.Per__c = 'LCA';
        entitle1.Entitlement_balance__c = 2;
        entitle1.Entitlement_quantity__c = 5;
        insert entitle1;
        System.debug('entitle1::*'+entitle1);
        
        Case cas=new Case();
        cas.ContactId = con.Id;
        cas.AccountId = acc.Id;
        cas.AssetId = ass1.Id;
        cas.EntitlementId = entitle1.Id;
        cas.Subject = 'Case Raised';
        cas.Progress__c = 'Request Submitted';
        insert cas;
        
        Case casHis=new Case();
        casHis.Id = cas.Id;
        casHis.Progress__c = 'Request Closed';
        update casHis;
        
        
        
        
        
        
        /*Inspection__c inspec1=new Inspection__c();
        inspec1.Actual_Date__c = date.today() + 31;
        inspec1.Scheduled_Date__c = date.today() +30;
        inspec1.Entitlement__c = entitle1.Id;
        inspec1.Type__c = 'Patrol';
        insert inspec1;
        Inspection__c inspec2=new Inspection__c();
        inspec2.Actual_Date__c = date.today() + 61;
        inspec2.Scheduled_Date__c = date.today() +60;
        inspec2.Entitlement__c = entitle1.Id;
        inspec2.Type__c = 'Patrol';
        insert inspec2;*/
        
        //Service contract expired
        ServiceContract servCont2=new ServiceContract();
        servCont2.Name = 'M421103 Origin Energy Marex AMC';
        servCont2.AccountId = acc.Id;
        servCont2.Contract_No__c = 'YEA-L00330-2007-01';
        servCont2.Description = 'M421103 Origin Energy Eraring Marex AMC 2020 - 2021';
        servCont2.ContactId = con.Id;
        servCont2.Contract_categories__c = 'Industrial Automation';
        servCont2.Contract_Type__c = 'LCA';
        servCont2.Language_Code__c = 'EN';
        servCont2.YG_Sales_Manager_Name__c = 'Rob Bush';
        servCont2.StartDate = date.newInstance(2019, 09, 09);
        servCont2.EndDate = date.today() - 30;
        servCont2.YG_Sales_Manager_contact_no__c = '909090909';
        servCont2.YG_Sales_Manager_Email__c = 'ygManager@gmail.com';
        insert servCont2;
        System.debug('servCont2::*'+servCont2);
        
        //Service contract Inactive
        ServiceContract servCont3=new ServiceContract();
        servCont3.Name = 'M450805 TERRITORY GENERATION ROC';
        servCont3.AccountId = acc.Id;
        servCont3.Contract_No__c = 'YEA-L00144-1911-01';
        servCont3.Description = 'M450805 Territory Generation LCA 2019-2020';
        servCont3.ContactId = con.Id;
        servCont3.Contract_categories__c = 'Industrial Automation';
        servCont3.Contract_Type__c = 'LCA';
        servCont3.Language_Code__c = 'EN';
        servCont3.YG_Sales_Manager_Name__c = 'Rob Bush';
        servCont3.StartDate = date.today() + 30;
        servCont3.EndDate = date.today() + 90;
        servCont3.YG_Sales_Manager_contact_no__c = '909090909';
        servCont3.YG_Sales_Manager_Email__c = 'ygManager@gmail.com';
        insert servCont3;
        System.debug('servCont3::*'+servCont3);
        
        //Service contract Active and BCP
        ServiceContract servCont4=new ServiceContract();
        servCont4.Name = 'Best Condition Plan';
        servCont4.AccountId = acc.Id;
        servCont4.Contract_No__c = '73F3-BC6782J';
        servCont4.Description = 'AQ1215A OTDR MULTI FIELD TESTER';
        servCont4.ContactId = con.Id;
        servCont4.Contract_categories__c = 'Test & Measurement';
        servCont4.Contract_Type__c = 'BCP';
        servCont4.Language_Code__c = 'EN';
        servCont4.YG_Sales_Manager_Name__c = 'Rob Bush';
        servCont4.StartDate = date.today() - 30;
        servCont4.EndDate = date.today() + 300;
        servCont4.YG_Sales_Manager_contact_no__c = '909090909';
        servCont4.YG_Sales_Manager_Email__c = 'ygManager@gmail.com';
        insert servCont4;
        System.debug('servCont4::*'+servCont4);
        
        Entitlement entitle2=new Entitlement();
        entitle2.Name = 'Calibration';
        entitle2.AccountId = acc.Id;
        entitle2.Type = 'Periodic';
        entitle2.ServiceContractId = servCont4.Id;
        entitle2.Per__c = '12 Months';
        entitle2.Entitlement_balance__c = 2;
        entitle2.Entitlement_quantity__c = 5;
        entitle2.AssetId = ass1.Id;
        entitle2.AccountId = acc.Id;
        insert entitle2;
        System.debug('entitle2::*'+entitle2);
        
        Scope_of_Product__c sop1=new Scope_of_Product__c(); 
        sop1.Name = 'SU1234567';
        sop1.Service_Contract__c = servCont1.Id;
        sop1.Asset__c = ass1.Id;
        insert sop1;
        
        //Expired contract
        ServiceContract servCont5=new ServiceContract();
        servCont5.Name = 'Best Condition Plan expired';
        servCont5.AccountId = acc.Id;
        servCont5.Contract_No__c = 'BC6782J';
        servCont5.Description = 'BC6782J OTDR MULTI FIELD TESTER';
        servCont5.ContactId = con.Id;
        servCont5.Contract_categories__c = 'Test & Measurement';
        servCont5.Contract_Type__c = 'BCP';
        servCont5.Language_Code__c = 'EN';
        servCont5.YG_Sales_Manager_Name__c = 'Rob Bush';
        servCont5.StartDate = date.today() - 30;
        servCont5.EndDate = date.today() -15;
        servCont5.YG_Sales_Manager_contact_no__c = '909090909';
        servCont5.YG_Sales_Manager_Email__c = 'ygManager@gmail.com';
        insert servCont5;
        System.debug('servCont4::*'+servCont5);
        
        User userRecord = [select id from user where UserName='testclient@chevron.com'];
        System.runAs(userRecord) {
            Test.startTest();
            List<Id> servcontId=new List<Id>();
            List<Id> servcontIdList=new List<Id>();
            servcontIdList.add(servCont1.Id);
            System.debug('servcontIdList::'+servcontIdList);
            YG_AllServiceContractsController.ServiceContractWrapper result=new YG_AllServiceContractsController.ServiceContractWrapper();
            //Checking for the filter search
            result = YG_AllServiceContractsController.getAllServiceContracts('300000142',null,null,servcontIdList,10,0);
            //System.assertEquals(4, result.totalContractCnt);
            result = YG_AllServiceContractsController.getAllServiceContracts('300000142','Active',null,servcontIdList,10,0);
            //System.assertEquals(1, result.activeContract);
            result = YG_AllServiceContractsController.getAllServiceContracts('300000142',null,'Industrial Automation',servcontIdList,10,0);
            //System.assertEquals(null, result.radioBtnCnt);
            result = YG_AllServiceContractsController.getAllServiceContracts('300000142','Expires',null,servcontIdList,10,0);
            //System.assertEquals(1, result.expirySixMonths);
            result = YG_AllServiceContractsController.getAllServiceContracts('300000142','Expires','Industrial Automation',servcontIdList,10,0);
            //System.assertEquals(1, result.expirySixMonths);
            result = YG_AllServiceContractsController.getAllServiceContracts('300000142','Active','Industrial Automation',servcontIdList,10,0);
            //System.assertEquals(1, result.activeContract);
            
            Integer resultCnt = YG_AllServiceContractsController.getTotalContractSize('300000142');
             System.debug('resultCnt::'+resultCnt);
            System.assertEquals(5, resultCnt);
            YG_AllServiceContractsController.ContractInfoWrapper contWrap=new YG_AllServiceContractsController.ContractInfoWrapper();
            contWrap = YG_AllServiceContractsController.getContractInfo('YEA-L0001-1901-01');
            System.assertEquals('YEA-L0001-1901-01', contWrap.contractNum);
            System.assertEquals('UMM AL HOUL Power Control System', contWrap.contractName);
            YG_AllServiceContractsController.ServiceMenuWrapper servMenu=new YG_AllServiceContractsController.ServiceMenuWrapper();
            servMenu = YG_AllServiceContractsController.getServiceMenuList('YEA-L0001-1901-01');
            System.assertEquals(1, servMenu.servMenuList.size());
            YG_AllServiceContractsController.ServMenuHistoryWrapper servHis=new YG_AllServiceContractsController.ServMenuHistoryWrapper();
            servHis = YG_AllServiceContractsController.getServiceMenuTimeLine('YEA-L0001-1901-01',null);
            Map<String, String> dropDown=new Map<String, String>();
            dropDown = YG_AllServiceContractsController.getServiceMenuDropdown('YEA-L0001-1901-01');
            String res = YG_AllServiceContractsController.getContract('YEA-L0001-1901-01');
            System.assertEquals('UMM AL HOUL Power Control System', res);
            String casid = cas.Id;
            Case cs= YG_AllServiceContractsController.getContractCaseSubmitThankYouPageDetails(casid);
            //System.assertEquals('Request For Service', cs.Type);
            System.assertEquals('Case Raised', cs.Subject);
            Test.stopTest();
        }
        
        
        
    }
    
    //This testmethod is used test the 
    @istest static void ygAllServiceContractTestMethod2(){
        //Insert test account record
        Account acc = new account();
        acc.name='Sample Account';  
        acc.AccountNumber = '200124172';
        acc.Type = 'Customer';
        //acc.DUNS_Number__c=107906668; 
        insert acc;
        
        //Insert test contact record
        Contact con = new Contact();   
        con.FirstName='client';
        con.LastName='test';
        con.Email='testclient@chevron.com';
        con.accountid=acc.id; 
        insert con;
        
        //Insert test plant record
       /* Plant__c plant1=new Plant__c();
        plant1.Name = 'TestPlant';
        plant1.Account__c = acc.Id;  
        plant1.Plant_Code__c = '300000142';
        plant1.Lang_Code__c = 'EN';
        insert plant1;*/
        //Insert test plant record
        Account plant1=new Account();
        plant1.Name = 'TestPlant';
        plant1.ParentId = acc.Id;  
        plant1.AccountNumber = '300000142';
         plant1.Type = 'Plant';
        insert plant1;
        
        //Insert test customer plant record
       /* List<Customer_Plant__c> cusPlantList=new List<Customer_Plant__c>();
        Customer_Plant__c cusPlant1=new Customer_Plant__c();
        cusPlant1.Contact__c = con.Id;
        cusPlant1.Plant__c = plant1.Id;*/
        List<AccountContactRelation> cusPlantList=new List<AccountContactRelation>();
        AccountContactRelation cusPlant1=new AccountContactRelation();
        cusPlant1.ContactId = con.Id;
        cusPlant1.AccountId = plant1.Id;
        cusPlantList.add(cusPlant1);
        insert cusPlantList;
        
        //Insert test Category Hierarchy record
        List<Category_Hierarchy__c> catHierListTop=new List<Category_Hierarchy__c>();
        Category_Hierarchy__c catHierTop1=new Category_Hierarchy__c(Category_Code__c = '10000000', Category_Level__c = 1, Display_Sequence__c = 500,
                                                                    Upper_Category_Code__c = NULL);
        catHierListTop.add(catHierTop1);
        insert catHierListTop;
        
        List<Category_Hierarchy__c> catHierList=new List<Category_Hierarchy__c>();
        Category_Hierarchy__c catHier2=new Category_Hierarchy__c(Category_Code__c = '11000000', Category_Level__c = 2, Display_Sequence__c = 500,
                                                                 Upper_Category_Code__c = '10000000', Category_Hierarchy__c = catHierTop1.id);
        catHierList.add(catHier2);
        Category_Hierarchy__c catHier3=new Category_Hierarchy__c(Category_Code__c = '12000000', Category_Level__c = 3, Display_Sequence__c = 500,
                                                                 Upper_Category_Code__c = '11000000', Category_Hierarchy__c = catHierTop1.id);
        catHierList.add(catHier3);
        
        insert catHierList;
        System.debug('catHierList::'+catHierList);
        
        //Insert test category record
        List<Category__c> catList=new List<Category__c>();
        Category__c catg1=new Category__c(Name = 'Distributed Control Systems (DCS)', Category_Hierarchy__c = catHierTop1.Id,
                                          Category_Type__c = 'System', Language_Code__c = 'EN');
        catList.add(catg1);
        Category__c catg2=new Category__c(Name = 'Hardware', Category_Hierarchy__c = catHier2.Id,
                                          Category_Type__c = 'System', Language_Code__c = 'EN');
        catList.add(catg2);
        Category__c catg3=new Category__c(Name = 'Software', Category_Hierarchy__c = catHier3.Id,
                                          Category_Type__c = 'System', Language_Code__c = 'EN');
        catList.add(catg3);
        
        insert catList;
        System.debug('catList::'+catList);
        
        Product2 prod1=new Product2();
        prod1.Name = 'CENTUM VP R4';
        prod1.Model_Code__c = '4';
        prod1.Category__c = catg3.Id;
        prod1.Lang_Code__c = 'EN';
        insert prod1;
        
        
        
        ServiceContract servCont=new ServiceContract();
        servCont.Name = 'Comprehensive LCA contract for BAPCO';
        servCont.Contract_No__c = 'YMA-L00001-2001-01';
        servCont.Description = 'DCS LCA contract';
        servCont.AccountId = acc.Id;
        servCont.Parent_Contract_No__c = 'YMA-L00001';
        servCont.StartDate = date.newInstance(2020, 01, 01);
        servCont.EndDate = date.newInstance(2023, 01, 21);
        servCont.Contract_categories__c = 'Industrial Automation';
        servCont.Contract_Type__c = 'LCA';
        servCont.YG_Sales_Manager_Name__c = 'PradeepGururaj';
        servCont.YG_Sales_Manager_Email__c = 'pradeep.gururaj@bh.yokogawa.com';
        insert servCont;
        
        
        //Insert test asset record
        List<Asset> assList=new List<Asset>();
        Asset ass1=new Asset();
        ass1.Name = '6393FCAF-D39C-11E9-94D1-0AE1E5432EEC';
        ass1.Product2Id = prod1.Id;
        ass1.AccountId = acc.Id;
        ass1.PlantAccount__c = plant1.Id;
        ass1.Lang_Code__c = 'EN';
        Insert ass1;
        
        Scope_of_Product__c sop1=new Scope_of_Product__c();
        sop1.Name = '0A2B0485-D6FA-4131-B39C-745C6AE204A2';
        sop1.Product__c = prod1.Id;
        sop1.Asset__c = ass1.Id;
        sop1.Service_Contract__c = servCont.Id;
        sop1.DeliverableId__c = '6393FCAF-D39C-11E9-94D1-0AE1E5432EEC';
        insert sop1;
        
        
        ServiceContract servCont2=new ServiceContract();
        servCont2.Name = 'Comprehensive LCA contract for BAPCO';
        servCont2.Contract_No__c = 'YMA-L00001-1809-01';
        servCont2.Description = 'DCS LCA contract';
        servCont2.AccountId = acc.Id;
        servCont2.Parent_Contract_No__c = 'YMA-L00001';
        servCont2.StartDate = date.newInstance(2018, 01, 01);
        servCont2.EndDate = date.newInstance(2019, 01, 21);
        servCont2.Contract_categories__c = 'Industrial Automation';
        servCont2.Contract_Type__c = 'LCA';
        servCont2.YG_Sales_Manager_Name__c = 'PradeepGururaj';
        servCont2.YG_Sales_Manager_Email__c = 'pradeep.gururaj@bh.yokogawa.com';
        servCont2.Renewed_Contract__c = 'YMA-L00001-2001-01';
        insert servCont2;
        
        //BCP contract
        ServiceContract servCont3=new ServiceContract();
        servCont3.Name = 'Best Condition Plan';
        servCont3.Contract_No__c = '73F3-BC6782J';
        servCont3.Description = 'AQ1215A OTDR MULTI FIELD TESTER';
        servCont3.AccountId = acc.Id;
        servCont3.Parent_Contract_No__c = 'YMA-L00001';
        servCont3.StartDate = date.newInstance(2018, 01, 01);
        servCont3.EndDate = date.newInstance(2019, 01, 21);
        servCont3.Contract_categories__c = 'Test & Measurement';
        servCont3.Contract_Type__c = 'BCP';
        servCont3.YG_Sales_Manager_Name__c = 'Judy Alexander';
        servCont3.YG_Sales_Manager_Email__c = 'JudyAlexander@bh.yokogawa.com';
        insert servCont3;
        
        Asset ass2=new Asset();
        ass2.Name = '6393FCAF';
        ass2.Product2Id = prod1.Id;
        ass2.AccountId = acc.Id;
        ass2.PlantAccount__c = plant1.Id;
        ass2.Lang_Code__c = 'EN';
        Insert ass2;
        
        Customer_Asset__c cusAss=new Customer_Asset__c();
        cusAss.Asset__c = ass2.Id;
        cusAss.Contact__c = con.Id;
        insert cusAss;
        
        
        Scope_of_Product__c sop2=new Scope_of_Product__c();
        sop2.Name = '0A2B0485';
        sop2.Product__c = prod1.Id;
        sop2.Asset__c = ass2.Id;
        sop2.Service_Contract__c = servCont3.Id;
        sop2.DeliverableId__c = '6393FCAF';
        insert sop2;
        
        //Serv contract expires less than 6 months
        ServiceContract servCont4=new ServiceContract();
        servCont4.Name = 'Best Condition Plan';
        servCont4.Contract_No__c = '73F3-BC6782J';
        servCont4.Description = 'AQ1215A OTDR MULTI FIELD TESTER';
        servCont4.AccountId = acc.Id;
        servCont4.Parent_Contract_No__c = 'YMA-L00001';
        servCont4.StartDate = date.today();
        servCont4.EndDate = date.today()+30;
        servCont4.Contract_categories__c = 'Test & Measurement';
        servCont4.Contract_Type__c = 'BCP';
        servCont4.YG_Sales_Manager_Name__c = 'Judy Alexander';
        servCont4.YG_Sales_Manager_Email__c = 'JudyAlexander@bh.yokogawa.com';
        insert servCont4;
        //Insert test portal user record
        User user = new User();   
        user.ProfileID = [Select Id From Profile Where Name='Customer Portal User'].id; 
        System.debug('user.ProfileID');
        user.EmailEncodingKey = 'ISO-8859-1';   user.LanguageLocaleKey = 'en_US';   user.TimeZoneSidKey = 'America/New_York';   
        user.LocaleSidKey = 'en_US';   user.FirstName = 'client';   user.LastName = 'test';   user.Username = 'testclient@chevron.com';      
        user.CommunityNickname = 'client22';   user.Alias = 'client';   user.Email = 'testclient@chevron.com';   user.IsActive = true;   
        user.ContactId = con.Id;  
        insert user; 
        
        User userRecord = [select id from user where UserName='testclient@chevron.com'];
        System.runAs(userRecord) {
            Test.startTest();
            List<Id> servIds=new List<Id>();
            YG_AllServiceContractsController.ServiceContractWrapper servContWrap1=new YG_AllServiceContractsController.ServiceContractWrapper();
            servContWrap1 = YG_AllServiceContractsController.getAllServiceContracts('300000142', null, null, servIds, 10, 0);
            System.debug('servContWrap1::'+servContWrap1);
            System.assertEquals(4, servContWrap1.totalContractCnt);
            System.assertEquals(1, servContWrap1.activeContract);
            System.assertEquals(2, servContWrap1.expiredContract);
            
            servContWrap1 = YG_AllServiceContractsController.getAllServiceContracts('300000142', 'Active', null, servIds, 10, 0);
            System.assertEquals(1, servContWrap1.activeContract);
            
            //test on the filter 
            List<Id> servcontIdList=new List<Id>();
            servcontIdList.add(servCont.Id);
            System.debug('servcontIdList::'+servcontIdList);
            
            servContWrap1 = YG_AllServiceContractsController.getAllServiceContracts('300000142',null,null,servcontIdList,10,0);
            servContWrap1 = YG_AllServiceContractsController.getAllServiceContracts('300000142','Active',null,servcontIdList,10,0);
            servContWrap1 = YG_AllServiceContractsController.getAllServiceContracts('300000142', null,'Industrial Automation',servcontIdList,10,0);
            
            Test.stopTest();
        }
    }
    
    
}