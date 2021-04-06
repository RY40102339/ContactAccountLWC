/********************************************************************************************************
* (C) Copyright 2020 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Vinod A
* @version 1.0
* @created 18/05/2020
* @description 
* This test class for YG_GridController apex class.
*
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*
*
*/
@istest
public class YG_ProductDetailsCSVTest {
    @istest static void allProdTestMethod(){
        //Insert test account record
        Account acc = new account();
        acc.name='Test Account';        
        //acc.DUNS_Number__c=102224222; 
        insert acc;    
        
        //Insert test contact record
        Contact con = new Contact();   
        con.FirstName='User';
        con.LastName='testContact';
        con.Email='testContact@chevron.com';
        con.accountid=acc.id; 
        insert con;
        
        //Insert test portal user record
        User user = new User();   
        user.ProfileID = [Select Id From Profile Where Name='Customer Portal User'].id; 
        System.debug('user.ProfileID');
        user.EmailEncodingKey = 'ISO-8859-1';   user.LanguageLocaleKey = 'en_US';   user.TimeZoneSidKey = 'America/New_York';   
        user.LocaleSidKey = 'en_US';   user.FirstName = 'User';   user.LastName = 'testContact';   user.Username = 'testContact@chevron.com';      
        user.CommunityNickname = 'User222';   user.Alias = 'user';   user.Email = 'testContact@chevron.com';   user.IsActive = true;   
        user.ContactId = con.Id;  
        insert user;   
        
        //Insert test plant record
        List<Plant__c> plantList=new List<Plant__c>();
        Plant__c plant1=new Plant__c();
        plant1.Name = 'TestPlant';
        plant1.Account__c = acc.Id;  
        plant1.Plant_Code__c = '300000142';
        plant1.Lang_Code__c = 'EN';
        plantList.add(plant1);
        insert plantList;
        
        List<Id> pltId = new List<Id>();
        for(Plant__c plt: plantList){
            pltId.add(plt.Id);
        }
        
        //Insert test customer plant record
        List<Customer_Plant__c> cusPlantList=new List<Customer_Plant__c>();
        Customer_Plant__c cusPlant1=new Customer_Plant__c();
        cusPlant1.Contact__c = con.Id;
        cusPlant1.Plant__c = plant1.Id;
        cusPlantList.add(cusPlant1);
        insert cusPlantList;
        
        //Insert test project record
        List<Project__c> projectList=new List<Project__c>();
        Project__c proj1=new Project__c();
        proj1.Account__c = acc.Id;
        proj1.Plant__c = plant1.Id;
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
        prod2.Production_Date__c = Date.newInstance(2014, 12, 17);
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
        ass1.Plant__c = plant1.Id;
        ass1.MS_Code__c = 'AAI543-H50';
        ass1.Lang_Code__c = 'EN';
        ass1.Status = 'Installed';
        
        assList.add(ass1);
        
        Asset ass2=new Asset();
        ass2.Name = 'SU1234568';
        ass2.Product2Id = prod2.Id;
        ass2.AccountId = acc.Id;
        ass2.ContactId = con.Id;
        ass2.SerialNumber = 'SU1234568';
        ass2.Plant__c = plant1.Id;
        ass2.MS_Code__c = 'AAI543-H50';
        ass2.Lang_Code__c = 'EN';
        ass2.Status = 'Installed';
        
        assList.add(ass2);     
        
        Asset ass3=new Asset();
        ass3.Name = 'SU1234569';
        ass3.Product2Id = prod2.Id;
        ass3.AccountId = acc.Id;
        ass3.ContactId = con.Id;
        ass3.SerialNumber = 'SU1234569';
        ass3.Plant__c = plant1.Id;
        ass3.MS_Code__c = 'AAI543-H50';
        ass3.Status = 'Installed';
        ass3.Lang_Code__c = 'EN';
        
        assList.add(ass3); 
        
        Asset ass4=new Asset();
        ass4.Name = 'SU1234579';
        ass4.Product2Id = prod2.Id;
        ass4.AccountId = acc.Id;
        ass4.ContactId = con.Id;
        ass4.SerialNumber = 'SU1234579';
        ass4.Plant__c = plant1.Id;
        ass4.MS_Code__c = 'AAI543-H50';
        ass4.Status = 'Installed';
        ass4.Lang_Code__c = 'EN';
        
        assList.add(ass4); 
        
        Asset ass5=new Asset();
        ass5.Name = 'SU1234589';
        ass5.Product2Id = prod2.Id;
        ass5.AccountId = acc.Id;
        ass5.ContactId = con.Id;
        ass5.SerialNumber = 'SU1234589';
        ass5.Plant__c = plant1.Id;
        ass5.MS_Code__c = 'AAI543-H50';
        ass5.Status = 'Installed';
        ass5.Lang_Code__c = 'EN';
        
        assList.add(ass5); 
        
        insert assList;
        
        //Insert test Customer_Asset__c record
        List<Customer_Asset__c> cusAssList=new List<Customer_Asset__c>();
        Customer_Asset__c cusAss1=new Customer_Asset__c();
        cusAss1.Contact__c = con.Id;
        cusAss1.Asset__c = ass1.Id;
        cusAssList.add(cusAss1);
        Customer_Asset__c cusAss2=new Customer_Asset__c();
        cusAss2.Contact__c = con.Id;
        cusAss2.Asset__c = ass2.Id;
        cusAssList.add(cusAss2);
        Customer_Asset__c cusAss3=new Customer_Asset__c();
        cusAss3.Contact__c = con.Id;
        cusAss3.Asset__c = ass3.Id;
        cusAssList.add(cusAss3);
        Customer_Asset__c cusAss4=new Customer_Asset__c();
        cusAss4.Contact__c = con.Id;
        cusAss4.Asset__c = ass4.Id;
        cusAssList.add(cusAss4);
        insert cusAssList;
        
        //Insert test task record
        List<task> tskList=new List<task>();
        task t1=new task();
        t1.OwnerId = UserInfo.getUserId();
        t1.Subject = 'Recalled Products';
        t1.Type = 'Recalled Products';
        t1.Is_Active__c = 'True';
        t1.Priority = 'Normal';
        t1.Status = 'open';
        t1.Asset__c = ass1.id;
        t1.Lang_code__c = 'EN';
        tskList.add(t1);
        
        task t2=new task();
        t2.OwnerId = UserInfo.getUserId();
        t2.Subject = 'Firmware Update';
        t2.Type = 'Firmware Update';
        t2.Is_Active__c = 'True';
        t2.Priority = 'Normal';
        t2.Status = 'open';
        t2.Product__c = prod2.id;
        t2.Lang_code__c = 'EN';
        tskList.add(t2);
        
        task t3=new task();
        t3.OwnerId = UserInfo.getUserId();
        t3.Subject = 'Calibration Recommended';
        t3.Type = 'Calibration Recommended';
        t3.Is_Active__c = 'True';
        t3.Priority = 'Normal';
        t3.Status = 'open';
        t3.Asset__c = ass1.id;
        t3.Lang_code__c = 'EN';
        tskList.add(t3);
        
        task t4=new task();
        t4.OwnerId = UserInfo.getUserId();
        t4.Subject = 'Battery Replacement';
        t4.Type = 'Battery Replacement';
        t4.Is_Active__c = 'True';
        t4.Priority = 'Normal';
        t4.Status = 'open';
        t4.Asset__c = ass2.id;
        t4.Lang_code__c = 'EN';
        tskList.add(t4);
        
        task t5=new task();
        t5.OwnerId = UserInfo.getUserId();
        t5.Subject = 'Firmware Update';
        t5.Type = 'Firmware Update';
        t5.Is_Active__c = 'True';
        t5.Priority = 'Normal';
        t5.Status = 'open';
        t5.Product__c = prod2.id;
        t5.Lang_code__c = 'EN';
        tskList.add(t5);
        
        task t6=new task();
        t6.Subject = 'Discontinued Products';
        t6.OwnerId = UserInfo.getUserId();
        t6.Type = 'Discontinued Products';
        t6.Is_Active__c = 'True';
        t6.Priority = 'Normal';
        t6.Status = 'open';
        t6.Asset__c = ass4.id;
        t6.Lang_code__c = 'EN';
        tskList.add(t6);
        
        task t7=new task();
        t7.Subject = 'Regulation Changes';
        t7.OwnerId = UserInfo.getUserId();
        t7.Type = 'Regulation Changes';
        t7.Is_Active__c = 'True';
        t7.Priority = 'Normal';
        t7.Status = 'open';
        t7.Asset__c = ass4.id;
        t7.Lang_code__c = 'EN';
        tskList.add(t7);
        
        insert tskList;
        
        List<ServiceContract> servConList = new List<ServiceContract>();
        ServiceContract servCon = new ServiceContract();
        	servCon.Name = 'CV7000 Light supportplan';
        	servCon.AccountId = acc.id;
        	servCon.Contract_No__c = 'AUF04638-0001-002';
            servCon.Description = 'support plan for CV7000';
            servCon.Contract_Type__c = 'Annual support (hardware)';            
            servCon.YG_Sales_Manager_Name__c = 'jp';
            servCon.Contract_categories__c = 'Life Innovation';
        	servCon.StartDate = Date.newInstance(2021, 02, 28);
        	servCon.EndDate = Date.newInstance(2021, 06, 28);
        	servConList.add(servCon);
        
		ServiceContract servCon1 = new ServiceContract();        
        	servCon1.Name = 'CV7000 Light supportplan';
        	servCon1.AccountId = acc.id;
        	servCon1.Contract_No__c = 'AUF04638-0001-002';
            servCon1.Description = 'support plan for CV7000';
            servCon1.Contract_Type__c = 'BCP';            
            servCon1.YG_Sales_Manager_Name__c =null;
            servCon1.Contract_categories__c = 'Test & Measurement';
        	servCon1.StartDate = Date.newInstance(2021, 03, 28);
        	servCon1.EndDate = Date.newInstance(2021, 05, 28);
        	servConList.add(servCon1);
            insert servConList;
        
        List<Entitlement> entitleList = new List<Entitlement>();
        Entitlement entitle = new Entitlement();
            entitle.Name = 'Maintenace';
            entitle.Entitlement_type__c = 'Periodic';
            entitle.AccountId = acc.id;
            entitle.ServiceContractId = servCon.id; 
            entitle.AssetId = ass1.id; 
        	entitleList.add(entitle);
        
        Entitlement entitle1 = new Entitlement();
            entitle1.Name = 'Maintenace';
            entitle1.Entitlement_type__c = 'Periodic';
            entitle1.AccountId = acc.id;
            entitle1.ServiceContractId = servCon1.id; 
            entitle1.AssetId = ass1.id; 
        	entitleList.add(entitle1);
            insert entitleList;
        
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
        
        Entitlement entitl1=new Entitlement();
        entitl1.Name = 'Patrol Inspection';
        entitl1.AccountId = acc.Id;
        entitl1.Type = 'Times to visit';
        entitl1.ServiceContractId = servCont1.Id;
        entitl1.Entitlement_type__c = 'Patrol';
        entitl1.Per__c = 'LCA';
        entitl1.Entitlement_balance__c = 2;
        entitl1.Entitlement_quantity__c = 5;
        insert entitl1;
        System.debug('entitl1::*'+entitl1);
        
        Scope_of_Product__c sop1=new Scope_of_Product__c(); 
        sop1.Name = 'SU1234567';
        sop1.Service_Contract__c = servCont1.Id;
        sop1.Asset__c = ass1.Id;
        insert sop1;
        
        Test.startTest();
        system.runAs(user){
            List<Id> listIds=new List<Id>();
            List<Id> listId2=new List<Id>();
            listId2.add(prod2.Id);
            
            YG_ProductDetailsCSV.getCsvData(listIds, '', '');
            YG_ProductDetailsCSV.getCsvData(listIds, '','Contracts');	
            YG_ProductDetailsCSV.getCsvData(listIds, 'Field+Instruments', 'Calibration'); //Error Catch block covering
            YG_ProductDetailsCSV.getCsvData(listId2, 'Field+Instruments', '');  
            
            YG_ProductDetailsCSV.ServiceContractWrapper serviceContractWrap = new YG_ProductDetailsCSV.ServiceContractWrapper();
            serviceContractWrap = YG_ProductDetailsCSV.getServiceContractCSV('300000142');
        }
        
        Test.stopTest();
    }
}