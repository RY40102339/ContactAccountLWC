/*
*******************************************************************************************************
* (C) Copyright 2020 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Jayaprasath
* @version 1.0
* @created 09/30/2020
* @description 
* This test class for YG_OverviewContractGrid apex class.
*
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  
*/

@istest
public class YG_OverviewContractGridTest {
    @istest static void getOverviewContractGridTestMethod(){
        //Insert test account record
        Account acc = new account();
        acc.name='ABC Test Account';
        insert acc;    
        
        //Insert test contact record
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
        
        Plant__c plant2=new Plant__c();
        plant2.Name = 'TestPlant2';
        plant2.Account__c = acc.Id;  
        plant2.Plant_Code__c = '300000123';
        plant2.Lang_Code__c = 'EN';
        plantList.add(plant2);
        insert plantList;
        
        //Insert test project record   
            List<Project__c> projectList=new List<Project__c>();
            Project__c proj1=new Project__c();
            proj1.Account__c = acc.Id;
            proj1.Plant__c = plant1.Id;
            proj1.Project_Code__c = 'VP700250';
            projectList.add(proj1);
            insert projectList;
            
            List<Category_Hierarchy__c> catHierList=new List<Category_Hierarchy__c>();
            Category_Hierarchy__c catHier1=new Category_Hierarchy__c(Category_Code__c = '10000000', Category_Level__c = 1, Display_Sequence__c = 500,
                                                                     Category_Hierarchy__c = NULL);
            catHierList.add(catHier1);
            insert catHierList;
            
            List<Category__c> catList=new List<Category__c>();
            Category__c catg1 = new Category__c(Name = 'Distributed Control Systems (DCS)', Category_Hierarchy__c = catHier1.Id,
                                              Category_Type__c = 'System', Language_Code__c = 'EN');
            
            catList.add(catg1);
            insert catList;
            
            
            List<Product2> prodList=new List<Product2>();
            Product2 prod1=new Product2();
            prod1.Name = 'Node Expansion Package (for AFV10)';
            prod1.Model_Code__c = 'LFS1550';
            prod1.Product_Type__c = 'Hardware';
            prod1.Category__c = catg1.Id;
            prod1.Production_Date__c = Date.newInstance(2014, 12, 17);
            prodList.add(prod1);
            
            Insert prodList;
            
            List<Asset> assList=new List<Asset>();
            Asset ass1=new Asset();
            ass1.Name = 'FCS0111';
            ass1.Product2Id = prod1.Id;
            ass1.AccountId = acc.Id;
            ass1.ContactId = con.Id;
            ass1.SerialNumber = 'FCS0111';
            ass1.Plant__c = plant1.Id;
            ass1.Project__c = proj1.Id;
            ass1.MS_Code__c = 'FCS0111';
            ass1.Status = 'Installed';
            ass1.Lang_Code__c='EN';
            assList.add(ass1);
            
            Asset ass2=new Asset();
            ass2.Name = 'SU1234567';
            ass2.Product2Id = prod1.Id;
            ass2.AccountId = acc.Id;
            ass2.ContactId = con.Id;
            ass2.SerialNumber = 'SU1234567';
            ass2.Plant__c = plant1.Id;
            ass2.Project__c = proj1.Id;
            ass2.MS_Code__c = 'LXY12345';
            ass2.Status = 'Installed';
            ass2.Lang_Code__c='EN';
            assList.add(ass2);
            insert assList;
        
        List<Customer_Asset__c> cusAssetIdList = new List<Customer_Asset__c>();
        Customer_Asset__c custAsst = new Customer_Asset__c();
        	custAsst.Contact__c = con.id;
            custAsst.Asset__c = ass1.id;
            cusAssetIdList.add(custAsst);
            insert cusAssetIdList;
        
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
        
        
    
    System.RunAs(user){
              test.startTest();
                //Line to cover getOverviewContractGrid() method 
                try{
                    YG_OverviewContractGrid.OverviewContractWrapper ovrConWap = new YG_OverviewContractGrid.OverviewContractWrapper();
                	ovrConWap = YG_OverviewContractGrid.getOverviewContractGrid('300000142',3,0);    
                }
                catch(Exception e){
                    
                }
                
              test.stopTest();
           
          } 
    
}

}