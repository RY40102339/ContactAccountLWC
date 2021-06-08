/*
*******************************************************************************************************
* (C) Copyright 2020 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Vinod A
* @version 1.0
* @created 24/05/2020
* @description 
* This test class for YG_SubMenuController apex class.
*
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*
*
*/
@istest
public class YG_SubMenuControllerTest {
    

    @istest static void subMenuTest(){
        
        //Insert test account record
        Account acc = new account();
        acc.name='Test Account';        
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
        
        //Insert test category hierarchy record
        Category_Hierarchy__c catHier1=new Category_Hierarchy__c(Category_Code__c = '10000000', Category_Level__c = 1, Display_Sequence__c = 500,
                                                                 Upper_Category_Code__c = NULL);
        insert catHier1;
       
        
        List<Category_Hierarchy__c> catHierList=new List<Category_Hierarchy__c>();
        Category_Hierarchy__c catHier2=new Category_Hierarchy__c(Category_Code__c = '11000000', Category_Level__c = 2, Display_Sequence__c = 500,
                                                                 Upper_Category_Code__c = '10000000', Category_Hierarchy__c = catHier1.Id);
        catHierList.add(catHier2);
        Category_Hierarchy__c catHier3=new Category_Hierarchy__c(Category_Code__c = '12000000', Category_Level__c = 2, Display_Sequence__c = 500,
                                                                 Upper_Category_Code__c = '10000000', Category_Hierarchy__c = catHier1.Id);
        catHierList.add(catHier3);
        insert catHierList;
        
        //Insert test category record
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
        
        insert catList;
        
        //Insert test product record
        List<Product2> prodList=new List<Product2>();
         
        Product2 prod1=new Product2();
        prod1.Name = 'Device Smart Communicators BT200';
        prod1.Model_Code__c = 'BT200';
        prod1.Category__c = catg3.Id;
      //  prod1.Production_Date__c = Date.newInstance(2014, 12, 17);
        prod1.Lang_Code__c = 'EN';
        prodList.add(prod1);       
        
        Insert prodList;
        
        List<Product2> prodList1 = [Select Id, Name, Top_Category__c From Product2 where ID = :prod1.id];
        system.debug('prodList1::'+prodList1);    
            
        //Insert test assest record
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
        
        //Inserting customer assets records
        List<Customer_Asset__c> cusAssetIdList = new List<Customer_Asset__c>();
        Customer_Asset__c custAsst = new Customer_Asset__c();
        custAsst.Contact__c = con.id;
        custAsst.Asset__c = ass1.id;
        cusAssetIdList.add(custAsst);
        insert cusAssetIdList;

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
        List<Scope_of_Product__c> listSop = new List<Scope_of_Product__c>();
        Scope_of_Product__c sop1 = new Scope_of_Product__c();
        sop1.Service_Contract__c = servCont1.Id;
        sop1.Asset__c = ass1.Id;
        listSop.add(sop1);
        
        Scope_of_Product__c sop2 = new Scope_of_Product__c();
        sop2.Service_Contract__c = servCont1.Id;
        sop2.Asset__c = ass1.Id;
        listSop.add(sop2);
        
        insert listSop;
        
        System.runAs(user) {
            test.startTest();
            List<YG_SubMenuController.SubMenuWrapper> submenuList=new List<YG_SubMenuController.SubMenuWrapper>();
            submenuList = YG_SubMenuController.getSubMenus();
            System.assertEquals(1, submenuList.size());
            test.stopTest();
        }
    }
    
}