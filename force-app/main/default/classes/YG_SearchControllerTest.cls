/********************************************************************************************************
* (C) Copyright 2020 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Vinod A
* @version 1.0
* @created 03/06/2020
* @description 
* This test class for YG_SearchController apex class.
*
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  10/05/2020			Selvaraj T				Worked on improving the code coverage	
*  10/13/2020			Selvaraj T				Commented the phase date fields in product object
*  04/22/2021			Kavya					Removed Plant__c Object and replaced with Account Object also removed Customer_Plant__c Object and replaced with AccountContactRelation Object.
*												Removed Plant__c(Plant) Lookup field from Asset and Project Objects and newly added PlantAccount__c(Account) Lookup field in Asset  and Project Object.
*/

@istest
public class YG_SearchControllerTest {
    
    //test method for YG_SearchController.getLookUpValues() method
    @istest static void searchTestMethod(){
        
        //Insert test account record
        Account acc = new account();
        acc.name='ABC Account';    
        acc.Type = 'Customer';
        //acc.DUNS_Number__c=1022245331; 
        insert acc;    
        
        //Insert test contact record
        Contact con = new Contact();   
        con.FirstName='User';
        con.LastName='CVX AU';
        con.Email='cvxauuser011@chevron.com';
        con.accountid=acc.id; 
        insert con;
        
        //Insert test portal user record
        User user = new User();   
        user.ProfileID = [Select Id From Profile Where Name='Customer Portal User'].id; 
        System.debug('user.ProfileID');
        user.EmailEncodingKey = 'ISO-8859-1';   user.LanguageLocaleKey = 'en_US';   user.TimeZoneSidKey = 'America/New_York';   
        user.LocaleSidKey = 'en_US';   user.FirstName = 'User';   user.LastName = 'CVX AU';   user.Username = 'cvxauuser011@chevron.com';      
        user.CommunityNickname = 'User123';   user.Alias = 'user';   user.Email = 'no@email.com';   user.IsActive = true;   
        user.ContactId = con.Id;  
        insert user;   
        System.debug('userId'+user.Id);
        
        //executing method as portal user 
        System.RunAs(user){
            System.debug('Current User: ' + UserInfo.getUserName());
            System.debug('loggedInUser Id: ' + UserInfo.getUserId());
            System.debug('Current Profile: ' + UserInfo.getProfileId());
            
            User loggedInUser= YG_Utility.getLoggedInUserInfo(UserInfo.getUserId());
            System.assertEquals(loggedInUser.Name, 'User CVX AU');
            
            //Insert test plant record
            /*List<Plant__c> plantList=new List<Plant__c>();
            Plant__c plant1=new Plant__c();
            plant1.Name = 'TestPlant';
            plant1.Account__c = acc.Id;  
            plant1.Plant_Code__c = '300000142';
            plant1.Lang_Code__c = 'EN';
            plantList.add(plant1);
            insert plantList;*/
            
            //Insert test plant record
            List<Account> plantList=new List<Account>();
            Account plant1=new Account();
            plant1.Name = 'TestPlant';
            plant1.ParentId = acc.Id;  
            plant1.AccountNumber = '300000142';
            plant1.Type = 'Plant';
            plantList.add(plant1);
            insert plantList;
            
            //Insert test customer plant record
           /* List<Customer_Plant__c> cusPlantList=new List<Customer_Plant__c>();
            Customer_Plant__c cusPlant1=new Customer_Plant__c();
            cusPlant1.Contact__c = con.Id;
            cusPlant1.Plant__c = plant1.Id;
            cusPlant1.Status__c = 'Approved site access';
            cusPlantList.add(cusPlant1);
            insert cusPlantList;*/
            
            //Insert test customer plant record
            List<AccountContactRelation> cusPlantList=new List<AccountContactRelation>();
            AccountContactRelation cusPlant1=new AccountContactRelation();
            cusPlant1.ContactId = con.Id;
            cusPlant1.AccountId = plant1.Id;
            cusPlant1.Status__c = 'Approved site access';
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
            
            //Inserting test Category Hierarchy record
            List<Category_Hierarchy__c> catHierUppLvlList=new List<Category_Hierarchy__c>();
            Category_Hierarchy__c catHierL1=new Category_Hierarchy__c(Category_Code__c = '10000000', Category_Level__c = 1, Display_Sequence__c = 500, Upper_Category_Code__c = NULL);
            catHierUppLvlList.add(catHierL1); //Field INs
            
            Category_Hierarchy__c catHierL2=new Category_Hierarchy__c(Category_Code__c = '20000000', Category_Level__c = 1, Display_Sequence__c = 500, Upper_Category_Code__c = NULL);
            catHierUppLvlList.add(catHierL2); // DCS
            
            insert catHierUppLvlList;
            
            List<Category_Hierarchy__c> catHierLowLvlList=new List<Category_Hierarchy__c>();
            
            Category_Hierarchy__c catHierL11=new Category_Hierarchy__c(Category_Code__c = '11000000', Category_Level__c = 2, Display_Sequence__c = 500, Upper_Category_Code__c = NULL, Category_Hierarchy__c = catHierL1.id);
            catHierLowLvlList.add(catHierL11); //Flow meters
            
            Category_Hierarchy__c catHierL21=new Category_Hierarchy__c(Category_Code__c = '21000000', Category_Level__c = 2, Display_Sequence__c = 500, Upper_Category_Code__c = NULL, Category_Hierarchy__c = catHierL2.id);
            catHierLowLvlList.add(catHierL21); //Hardware 
            
            Category_Hierarchy__c catHierL22=new Category_Hierarchy__c(Category_Code__c = '22000000', Category_Level__c = 2, Display_Sequence__c = 500, Upper_Category_Code__c = NULL, Category_Hierarchy__c = catHierL2.id);
            catHierLowLvlList.add(catHierL22); //software 
            
            Category_Hierarchy__c catHierL12=new Category_Hierarchy__c(Category_Code__c = '11100000', Category_Level__c = 3, Display_Sequence__c = 500, Upper_Category_Code__c = NULL, Category_Hierarchy__c = catHierL11.id);
            catHierLowLvlList.add(catHierL12); //Admag
            
            insert catHierLowLvlList;
            
            //Inserting test Category record
            List<Category__c> catList=new List<Category__c>();
            Category__c catg1 = new Category__c(Name = 'Distributed Control Systems (DCS)', Category_Hierarchy__c = catHierL2.Id,
                                                Category_Type__c = 'System', Language_Code__c = 'EN');
            catList.add(catg1);
            Category__c catg2=new Category__c(Name = 'Hardware', Category_Hierarchy__c = catHierL21.Id,
                                              Category_Type__c = 'System', Language_Code__c = 'EN');
            catList.add(catg2);
            Category__c catg3=new Category__c(Name = 'Software', Category_Hierarchy__c = catHierL22.Id,
                                              Category_Type__c = 'System', Language_Code__c = 'EN');
            catList.add(catg3);
            Category__c catg4=new Category__c(Name = 'Field Instruments', Category_Hierarchy__c = catHierL1.Id,
                                              Category_Type__c = 'Product', Language_Code__c = 'EN');
            catList.add(catg4);
            Category__c catg5=new Category__c(Name = 'ADMAG AXG', Category_Hierarchy__c = catHierL12.Id,
                                              Category_Type__c = 'Product', Language_Code__c = 'EN');
            catList.add(catg5);
            Category__c catg6=new Category__c(Name = 'Flow Meters', Category_Hierarchy__c = catHierL11.Id,
                                              Category_Type__c = 'Product', Language_Code__c = 'EN');
            catList.add(catg6);
            
            Insert catList;
            
            //Insert test product record
            List<Product2> prodList=new List<Product2>();
            
            Product2 prod1=new Product2();
            prod1.Name = 'Analog Input Module (4 to 20 mA, 16-Channel, Isolated)';
            prod1.Model_Code__c = 'AAI143';
            prod1.Product_Type__c = 'Hardware';
            prod1.Category__c = catg2.Id;
          //  prod1.Production_Date__c = Date.newInstance(2014, 12, 17);
            prod1.Lang_Code__c = 'EN';
            prodList.add(prod1);
            
            Product2 prod2=new Product2();
            prod2.Name = 'Analog Output Module (4 to 20 mA, 16-Channel, Isolated)';
            prod2.Model_Code__c = 'AAI543';
            prod2.Product_Type__c = 'Hardware';
            prod2.Category__c = catg2.Id;
          //  prod2.Production_Date__c = Date.newInstance(2014, 12, 17);
            prod2.Lang_Code__c = 'EN';
            prodList.add(prod2);
            
            Product2 prod3=new Product2();
            prod3.Name = 'Distributed Control Systems (DCS)';
            prod3.Model_Code__c = 'AFV10D';
            prod3.Product_Type__c = 'Station';
            prod3.Category__c = catg1.Id;
           // prod3.Production_Date__c = Date.newInstance(2014, 12, 17);
            prod3.Lang_Code__c = 'EN';
            prodList.add(prod3);
            
            Product2 prod4=new Product2();
            prod4.Name = 'PC';
            prod4.Model_Code__c = 'PC';
            prod4.Product_Type__c = 'Station';
            prod4.Category__c = catg3.Id;
           // prod4.Production_Date__c = Date.newInstance(2014, 12, 17);
            prod4.Lang_Code__c = 'EN';
            prodList.add(prod4);
            
            Product2 prod5=new Product2();
            prod5.Name = 'Node Expansion Package (for AFV10)';
            prod5.Model_Code__c = 'LFS1550';
            prod5.Product_Type__c = 'Software';
            prod5.Category__c = catg3.Id;
         //   prod5.Production_Date__c = Date.newInstance(2014, 12, 17);
            prod5.Lang_Code__c = 'EN';
            prodList.add(prod5);
            
            Product2 prod6=new Product2();
            prod6.Name = 'ADMAG AXG: Magnetic Flow Meter';
            prod6.Model_Code__c = 'BT200';
            prod6.Product_Type__c = '';
            prod6.Category__c = catg5.Id;
            //prod6.Production_Date__c = Date.newInstance(2014, 12, 17);
            prod6.Lang_Code__c = 'EN';
            prodList.add(prod6);
            
            Insert prodList;
            
            //Insert test asset record
            List<Asset> assList=new List<Asset>();
            Asset ass1=new Asset();
            ass1.Name = 'FCS0111';
            ass1.Product2Id = prod3.Id;
            ass1.AccountId = acc.Id;
            ass1.ContactId = con.Id;
            ass1.SerialNumber = 'FCS0111';
            ass1.PlantAccount__c = plant1.Id;
            ass1.Project__c = proj1.Id;
            ass1.MS_Code__c = 'FCS0111';
            ass1.Lang_Code__c = 'EN';
            //ass1.Shipping_Date__c = Date.newInstance(2014, 12, 28);
            ass1.Status = 'Installed';
            
            insert ass1;
            
            Asset ass2=new Asset();
            ass2.Name = 'C2MD04026H';
            ass2.Product2Id = prod1.Id;
           ass2.AccountId = acc.Id;
            ass2.ContactId = con.Id;
            ass2.SerialNumber = 'C2MD04026H';
            ass2.PlantAccount__c = plant1.Id;
            ass2.MS_Code__c = 'CP451-10';
            //ass2.Shipping_Date__c = Date.newInstance(2014, 12, 28);
            ass2.Status = 'Installed';
            ass2.ParentId = ass1.Id;
            ass2.Lang_Code__c = 'EN';
            ass2.Project__c = proj1.Id;
            assList.add(ass2);
            
            Asset ass3=new Asset();
            ass3.Name = 'C2MD04033H';
            ass3.Product2Id = prod2.Id;
            ass3.AccountId = acc.Id;
            ass3.ContactId = con.Id;
            ass3.SerialNumber = 'C2MD04033H';
			ass3.PlantAccount__c = plant1.Id;
            ass3.MS_Code__c = 'CP451-10';
            //ass3.Shipping_Date__c = Date.newInstance(2014, 12, 28);
            ass3.Status = 'Installed';
            ass3.ParentId = ass1.Id;
            ass3.Lang_Code__c = 'EN';
            ass3.Project__c = proj1.Id;
            assList.add(ass3);
            
            Asset ass4=new Asset();
            ass4.Name = 'HIS0101';
            ass4.Product2Id = prod4.Id;
           ass4.AccountId = acc.Id;
            ass4.ContactId = con.Id;
            //ass4.SerialNumber = '';
            ass4.PlantAccount__c = plant1.Id;
            ass4.MS_Code__c = 'CP451-10';
            //ass4.Shipping_Date__c = Date.newInstance(2014, 12, 28);
            ass4.Status = 'Installed';
            ass4.Lang_Code__c = 'EN';
            ass4.Project__c = proj1.Id;
            assList.add(ass4);
            
            Asset ass5=new Asset();
            ass5.Name = 'LFS1550-V11';
            ass5.Product2Id = prod5.Id;
           ass5.AccountId = acc.Id;
            ass5.ContactId = con.Id;
            ass5.SerialNumber = 'LFS1550-V11';
           ass5.PlantAccount__c = plant1.Id;
            ass5.MS_Code__c = 'LFS1550-V11';
            //ass5.Shipping_Date__c = Date.newInstance(2014, 12, 28);
            ass5.Status = 'Installed';
            ass5.ParentId = ass4.Id;
            ass5.Lang_Code__c = 'EN';
            ass5.Project__c = proj1.Id;
            assList.add(ass5);
            
            Asset ass6=new Asset();
            ass6.Name = 'BT1234567';
            ass6.Product2Id = prod6.Id;
           ass6.AccountId = acc.Id;
            ass6.ContactId = con.Id;
            ass6.SerialNumber = 'BT1234567';
            ass6.PlantAccount__c = plant1.Id;
            ass6.MS_Code__c = 'BT1234567-1';
            //ass6.Shipping_Date__c = Date.newInstance(2014, 12, 28);
            ass6.Status = 'Installed';
            ass6.Lang_Code__c = 'EN';
            assList.add(ass6);
            
            Insert assList;
            
            List<Case> csList = new List<Case>();
            
            Case cs1 =new Case();
            cs1.Type = 'Submit an Inquiry1';
            cs1.Reason = 'Sales and Quote1';
            cs1.Subject = 'Requires sales quote for a Product1';
            //cs1.Case_Main_Type__c = 'Critical Services';
            //cs1.Case_Sub_Type__c = 'System hardware failure';
            cs1.Progress__c='test';
            cs1.Product = null;
            //cs1.Plant__c = plant1.Id;
            cs1.AccountId = acc.Id;  
            cs1.ContactID = con.id;
            csList.add(cs1);
            
            Insert csList;
            
            //Insert Customer Asset records
            List<Customer_Asset__c> cusAsstList = new List<Customer_Asset__c>();
            Customer_Asset__c cusAsst = new Customer_Asset__c();
            cusAsst.Asset__c = ass6.Id;
            cusAsst.Contact__c = con.Id;
            cusAsstList.add(cusAsst);
            
            Insert cusAsstList;
            
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
            
            //executing YG_SearchController.getLookUpValues() in separate governor limit based on above test data
            Test.startTest();
            //YG_SearchControllerTest.searchTestMethod();
            List<Asset> objList1=new List<Asset>();
            
            List<sObject> objList=new List<sObject>();
            //List<sObject> resObjList=new List<sObject>();
            Product2 pro=new Product2();
             List<sObject> objList2=new List<sObject>();
            objList2.add(cs1);
            
            List<sObject> resObjList = YG_SearchController.getLookUpValues('', objList, 'all-products', null, '','EN','300000142','');
            //System.assertEquals(2, resObjList.size());
            List<sObject> resObjList1 = YG_SearchController.getLookUpValues('AD', objList, 'all-products', 'Field Instruments', '',null,'300000142','');
            System.assertEquals(0, resObjList1.size());
            List<sObject> resObjList2 = YG_SearchController.getLookUpValues('', objList, 'all-products', 'Field Instruments', '','EN','300000142','');
            System.assertEquals(0, resObjList2.size());
            List<sObject> resObjList3 = YG_SearchController.getLookUpValues('De', objList, 'all-products', null, 'AAI143','EN','300000142','');
            System.assertEquals(0, resObjList3.size());
            List<sObject> resObjList4 = YG_SearchController.getLookUpValues('F', objList, 'all-systems', '', '','EN','300000142','VP700250');
            //System.assertEquals(2, resObjList4.size());
            List<sObject> resObjList5 = YG_SearchController.getLookUpValues('AF', objList1, 'all-systems', '', '','EN','300000142','VP700250');
            System.assertEquals(0, resObjList5.size());
            List<sObject> resObjList6 = YG_SearchController.getLookUpValues('AF', objList, 'all-systems', '', '','EN','300000142','');
            System.assertEquals(0, resObjList6.size());
            List<sObject> resObjList7 = YG_SearchController.getLookUpValues('FC', objList, 'station-details', '', '','EN','300000142','');
            System.assertEquals(0, resObjList7.size());
            List<sObject> resObjList8 = YG_SearchController.getLookUpValues('LFS', objList, 'station-details', '', '','EN','300000142','VP700250');
            System.assertEquals(1, resObjList8.size());
            List<sObject> resObjList9 = YG_SearchController.getLookUpValues('B', objList, 'product-details', 'BT200', '','EN','300000142','');
            //System.assertEquals(1, resObjList9.size());
            List<sObject> resObjList10 = YG_SearchController.getLookUpValues('U', objList, 'manage-colleagues', '', '','EN','300000142','');
            //System.assertEquals(1, resObjList9.size());
            List<sObject> resObjList11 = YG_SearchController.getLookUpValues('U', objList, 'allservicerequest', '', '','EN','300000142','');
            //System.assertEquals(2, resObjList11.size());
            List<sObject> resObjList12 = YG_SearchController.getLookUpValues('U', objList2, 'allservicerequest', '', '','EN','300000142','');
            System.assertEquals(0, resObjList12.size());
            List<sObject> resObjList13 = YG_SearchController.getLookUpValues('Z', objList, 'all-contracts', '', '','EN','300000142','');
            System.assertEquals(0, resObjList13.size());
            List<sObject> resObjList14 = YG_SearchController.getLookUpValues('U', objList, 'software-licenses', '', '','EN','300000142','');
             
            Test.stopTest();
        }
    }
    
}