/*
*******************************************************************************************************
* (C) Copyright 2020 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Jayaprasath
* @version 1.0
* @created 10/23/2020
* @description 
* This test class for YG_ProductDetailGrid apex class.
*
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  
*/

@istest
public class YG_ProductDetailGridTest {
 @istest static void getManageColleaguesTestMethod(){
        //Insert test account record
        Account acc = new account();
        acc.name='ABC Test Account'; 
        insert acc;    
        
        //Insert test contact record
        List<Contact> contactList=new List<Contact>();
        Contact con = new Contact();   
        con.FirstName='User';
        con.LastName='CVX AU';
        con.Email='cvxauuser011@chevron.com';
        con.accountid=acc.id; 
        con.Portal_User_Roles__c = 'CA';
        con.Status__c = false;
        contactList.add(con);
        
        Contact con1 = new Contact();   
        con1.FirstName='User';
        con1.LastName='CVX AU';
        con1.Email='cvxauuser011@chevron.com';
        con1.accountid=acc.id; 
        con1.Portal_User_Roles__c = 'CU';
        contactList.add(con1);
        insert contactList;
        
        //Inserting test portal user record
        Profile profile = [Select Id From Profile Where Name='Customer Portal User'];
        User user = new User(Alias = 'comm', Email='yg.qa167@gmail.com',ContactId=con.id,
                             EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                             LocaleSidKey='en_US', ProfileId = profile.Id,
                             TimeZoneSidKey='America/Los_Angeles', UserName='yg.qa167@gmail.com');
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
        prod2.Category__c = catg1.Id;
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
     	ass5.Tag_No__c = '';
        ass5.Production_Date__c = Date.newInstance(2014, 12, 28);
        
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
     
     //to pass the asset name as list in arguments 
         List<String> assLists=new List<String>();
     	 List<String> assListsMscode=new List<String>();
     	 List<String> empt=new List<String>();
         empt.add(null);
            for(Asset ast :assList){
                assLists.add(ast.Name);
                assListsMscode.add(ast.MS_Code__c);
            }
        
        
        System.RunAs(user){
            test.startTest();
                //Line to cover getProductDetailMsCodeGrid() method 
                YG_ProductDetailGrid.getProductDetailMsCodeGrid(prod2.Model_Code__c,empt);
                YG_ProductDetailGrid.getProductDetailMsCodeGrid('',assLists);
            
                //Line to cover getProductDetailSerialGrid() method 
                YG_ProductDetailGrid.getProductDetailSerialGrid(assListsMscode);
            
                //Line to cover getProductDetailCSV() method 
                YG_ProductDetailGrid.getProductDetailCSV(prod2.Model_Code__c,assLists);	
            test.stopTest();           
          } 


    }
}