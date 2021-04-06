/*
*******************************************************************************************************
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

@isTest
public class YG_GridControllerTest {
    
    //Test method for all products page YG_GridController class getProductInfo() method.
    @isTest static void ygAllProdGridTest() {
        
        //Inserting test account record
        Account acc = new account();
        acc.name='Test Account';        
        acc.AccountNumber='102224222'; 
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
        user.EmailEncodingKey = 'ISO-8859-1';   user.LanguageLocaleKey = 'en_US';   user.TimeZoneSidKey = 'America/New_York';   
        user.LocaleSidKey = 'en_US';   user.FirstName = 'User';   user.LastName = 'testContact';   user.Username = 'testContact@chevron.com';      
        user.CommunityNickname = 'User222';   user.Alias = 'user';   user.Email = 'testContact@chevron.com';   user.IsActive = true;   
        user.ContactId = con.Id;  
        insert user;   
        
        
        //Inserting test Category Hierarchy record
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
        
        System.debug('catHierList::'+catHierList);
        
        //Inserting test Category record
        List<Category__c> catList=new List<Category__c>();
        Category__c catg1=new Category__c(Name = 'Field Instruments', Category_Hierarchy__c = catHier1.Id,
                                          Category_Type__c = 'Product', Language_Code__c = 'EN');
        catList.add(catg1);
        Category__c catg2=new Category__c(Name = 'Device Smart Communicators', Category_Hierarchy__c = catHier2.Id,
                                          Category_Type__c = 'Product', Language_Code__c = 'EN');
        catList.add(catg2);
        Category__c catg3=new Category__c(Name = 'Device Smart Communicators BT200', Category_Hierarchy__c = catHier3.Id,
                                          Category_Type__c = 'Product', Language_Code__c = 'EN');
        catList.add(catg3);
        Category__c catg4=new Category__c(Name = 'HART Communicator YHC5150X', Category_Hierarchy__c = catHier4.Id,
                                          Category_Type__c = 'Product', Language_Code__c = 'EN');
        catList.add(catg4);
        Category__c catg5=new Category__c(Name = 'Flow Meters', Category_Hierarchy__c = catHier5.Id,
                                          Category_Type__c = 'Product', Language_Code__c = 'EN');
        catList.add(catg5);
        Category__c catg6=new Category__c(Name = 'ADMAG AXG', Category_Hierarchy__c = catHier6.Id,
                                          Category_Type__c = 'Product', Language_Code__c = 'EN');
        catList.add(catg6);
        Category__c catg7=new Category__c(Name = 'ROTAMASS PRIME', Category_Hierarchy__c = catHier7.Id,
                                          Category_Type__c = 'Product', Language_Code__c = 'EN');
        catList.add(catg7);
        Category__c catg8=new Category__c(Name = 'Test and Measurement', Category_Hierarchy__c = catHier8.Id,
                                          Category_Type__c = 'Product', Language_Code__c = 'EN');
        catList.add(catg8);
        Category__c catg9=new Category__c(Name = 'Oscilloscopes', Category_Hierarchy__c = catHier9.Id,
                                          Category_Type__c = 'Product', Language_Code__c = 'EN');
        catList.add(catg9);
        Category__c catg10=new Category__c(Name = 'Mixed Signal Oscilloscope', Category_Hierarchy__c = catHier10.Id,
                                           Category_Type__c = 'Product', Language_Code__c = 'EN');
        catList.add(catg10);
        
        insert catList;
        
        System.debug('catList::'+catList);
        
        //Inserting test product record
        List<Product2> prodList=new List<Product2>();
        Product2 prod1=new Product2();
        prod1.Name = 'ADMAG AXG: Magnetic Flow Meter';
        prod1.Model_Code__c = 'AX01C';
        prod1.Category__c = catg6.Id;
        prod1.Production_Date__c = Date.newInstance(2014, 12, 17);
        insert prod1;
        System.debug('prod1::'+prod1.Id);
        
        Product2 topProd = [SELECT ID, Top_Category__c FROM Product2 Where Product2.Id = :prod1.Id Limit 1];
        System.debug('topProd:::'+topProd.Top_Category__c);
        
        Product2 prod2=new Product2();
        prod2.Name = 'Device Smart Communicators BT200';
        prod2.Model_Code__c = 'BT200';
        prod2.Category__c = catg3.Id;
        prod2.Production_Date__c = Date.newInstance(2014, 12, 17);
        prodList.add(prod2);
        
        Product2 prod3=new Product2();
        prod3.Name = 'Vortex Flow Meters';
        prod3.Model_Code__c = 'DY015';
        prod3.Category__c = catg7.Id;
        prod3.Production_Date__c = Date.newInstance(2014, 12, 17);
        prodList.add(prod3);
        
        Product2 prod4=new Product2();
        prod4.Name = 'YHC5150X';
        prod4.Model_Code__c = 'YHC51';
        prod4.Category__c = catg4.Id;
        prod4.Production_Date__c = Date.newInstance(2014, 12, 17);
        prodList.add(prod4);
        
        Insert prodList;
        
        
        //Inserting test asset record
        List<Asset> assList=new List<Asset>();
        Asset ass1=new Asset();
        ass1.Name = 'SU1234567';
        ass1.Product2Id = prod1.Id;
        ass1.AccountId = acc.Id;
        ass1.ContactId = con.Id;
        ass1.SerialNumber = 'SU1234567';
        ass1.MS_Code__c = 'AAI543-H50';
        ass1.Lang_Code__c = 'EN';
        assList.add(ass1);   
        
        Asset ass2=new Asset();
        ass2.Name = 'SU1234568';
        ass2.Product2Id = prod1.Id;
        ass2.AccountId = acc.Id;
        ass2.ContactId = con.Id;
        ass2.SerialNumber = 'SU1234568';
        ass2.MS_Code__c = 'AAI543-H50';
        ass2.Lang_Code__c = 'EN';
        assList.add(ass2);     
        
        Asset ass3=new Asset();
        ass3.Name = 'SU1234569';
        ass3.Product2Id = prod1.Id;
        ass3.AccountId = acc.Id;
        ass3.ContactId = con.Id;
        ass3.SerialNumber = 'SU1234569';
        ass3.MS_Code__c = 'AAI543-H50';
        ass3.Lang_Code__c = 'EN';
        assList.add(ass3); 
        
        insert assList;
        
        //Insert customer asset
        List<Customer_Asset__c> cusAssList = new List<Customer_Asset__c>();
        Customer_Asset__c cus1 = new Customer_Asset__c();
        cus1.Asset__c = ass1.Id;
        cus1.Contact__c = con.Id;
        cusAssList.add(cus1);
        
        Customer_Asset__c cus2 = new Customer_Asset__c();
        cus2.Asset__c = ass2.Id;
        cus2.Contact__c = con.Id;
        cusAssList.add(cus2);
        
        Customer_Asset__c cus3 = new Customer_Asset__c();
        cus3.Asset__c = ass3.Id;
        cus3.Contact__c = con.Id;
        cusAssList.add(cus3);
        
        insert cusAssList;
        
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
       
        System.runAs(user) {
            test.startTest();
            
            List<Id> emptyList = new List<Id>();
            List<Id> filterList = new List<Id>{prod1.Id};
            
            YG_GridController.productWrapper prodWrap = new YG_GridController.productWrapper();
            prodWrap = YG_GridController.getProductDetails(emptyList, '', 10, 0, '');
            system.assertEquals(1, prodWrap.productSize);
            
            YG_GridController.productWrapper prodWrap1 = new YG_GridController.productWrapper();
            prodWrap1 = YG_GridController.getProductDetails(filterList, '', 10, 0, '');
            system.assertEquals(1, prodWrap1.productSize);
            
            YG_GridController.productWrapper prodWrap2 = new YG_GridController.productWrapper();
            prodWrap2 = YG_GridController.getProductDetails(emptyList, '', 10, 0, 'Contracts');
            system.assertEquals(1, prodWrap1.productSize);
            
            YG_GridController.productWrapper prodWrap3 = new YG_GridController.productWrapper();
            prodWrap3 = YG_GridController.getProductDetails(emptyList, 'Field Instruments', 10, 0, '');
            system.assertEquals(0, prodWrap3.productSize);
            
            YG_GridController.productWrapper prodWrap4 = new YG_GridController.productWrapper();
            prodWrap4 = YG_GridController.getProductDetails(filterList, 'Field Instruments', 10, 0, 'Contracts');
            system.assertEquals(0, prodWrap4.productSize);
            
            YG_GridController.productWrapper prodWrap5 = new YG_GridController.productWrapper();
            prodWrap5 = YG_GridController.getProductDetails(emptyList, 'Exception', 10, 0, '');
            
            test.stopTest();
        }
        
    }
}