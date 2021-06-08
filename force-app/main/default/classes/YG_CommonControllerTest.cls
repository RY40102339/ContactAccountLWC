/*
*******************************************************************************************************
* (C) Copyright 2020 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Chitrakishore
* @version 1.0
* @created 25/06/2020
* @description 
* This test class for YG_CommonController apex class.
*
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  04/21/2021 			Kavya 					Removed Plant__c Object and replaced with Account Object also removed Customer_Plant__c Object and replaced with AccountContactRelation Object.

.*												Removed Plant__c(Plant) Lookup field from Asset and Project Objects and newly added PlantAccount__c(Account) Lookup field in Asset  and Project Object.
*  
*
*/

@isTest
public class YG_CommonControllerTest {
    
    @isTest static void commonTestMethod(){
        Test.startTest();
        
        //Insert test account record
        Account acc = new account();
        acc.name='XYZ Account'; 
        acc.AccountNumber = null; 
        acc.Type = 'Customer';
        insert acc;

		//Insert test contact record        
        Contact con = new Contact();   
        con.FirstName='User';
        con.LastName='CVX AU';
        con.Email='cvxauuser011@chevron.com';
        con.accountid=acc.id; 
        con.Status__c = true;
        insert con;
        
        
        Profile profile = [Select Id From Profile Where Name='Customer Portal User'];
        
        //Insert test customer portal user record   
        User user = new User(Alias = 'comm', Email='yg.qa167@gmail.com',ContactId=con.id,
                             EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                             LocaleSidKey='en_US', ProfileId = profile.Id,
                             TimeZoneSidKey='America/Los_Angeles', UserName='yg.qa167@gmail.com');
        
        insert user;
        System.debug('userId'+user.Id);
        
         
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
            /*List<Customer_Plant__c> cusPlantList=new List<Customer_Plant__c>();
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
            //prod1.Production_Date__c = Date.newInstance(2014, 12, 17);
            prodList.add(prod1);
            
            Insert prodList;
            
            List<Asset> assList=new List<Asset>();
            Asset ass1=new Asset();
            ass1.Name = 'FCS0111';
            ass1.Product2Id = prod1.Id;
           ass1.AccountId = acc.Id;
            ass1.ContactId = con.Id;
            ass1.SerialNumber = 'FCS0111';
            ass1.PlantAccount__c = plant1.Id;
            ass1.Project__c = proj1.Id;
            ass1.MS_Code__c = 'FCS0111';
            ass1.Status = 'Installed';
            ass1.Lang_Code__c='EN';
            assList.add(ass1);
        	insert assList;
        
        	List<Customer_Asset__c> custAsstList =new List<Customer_Asset__c>();
        	Customer_Asset__c custAsst = new Customer_Asset__c();
        	custAsst.Contact__C = con.id;	
            custAsst.Asset__c = ass1.id;
        	custAsstList.add(custAsst);
        	insert custAsstList;
        
        YG_Community_Configuration__c selfReg = new YG_Community_Configuration__c(name= 'YGSelfRegisterAccountId',Text_1__c='001p000000tzRDX');
        insert selfReg;
        Id selfRegId = selfReg.Text_1__c;
        
        //execute method as portal user   
        System.RunAs(user){
            System.debug('Current User: ' + UserInfo.getUserName());
            System.debug('loggedInUser Id: ' + UserInfo.getUserId());
            System.debug('Current Profile: ' + UserInfo.getProfileId());
            
            User loggedInUser= YG_Utility.getLoggedInUserInfo(UserInfo.getUserId());
           
            
            String langCode;
            
            try{                
                YG_CommonController.CommonWrapper commWrapper = YG_CommonController.getPlantInfo(langCode);                
                
                YG_CommonController.checkContractOrIndividualCustomer();
                
                YG_CommonController.MenuWrapper commmenuWrapper = YG_CommonController.getMenuInfo();
                
            }
            catch (Exception e) {
                System.debug('Error in testclass for YG_CommonControllerTest.commonTestMethod() ::: '+e.getMessage());
            }
        }
        
        Test.stopTest();
    }
    
    @isTest static void commonTestMethodUser1(){
        Test.startTest();
        
        //Insert test account record
        Account acc = new account();
        acc.name='XYZ Account'; 
        acc.AccountNumber = '963258'; 
        acc.Type = 'Customer';
        insert acc;

		//Insert test contact record        
        Contact con = new Contact();   
        con.FirstName='User';
        con.LastName='CVX AU';
        con.Email='cvxauuser011@chevron.com';
        con.accountid=acc.id; 
        con.Status__c = true;
        insert con;
        
        
        Profile profile = [Select Id From Profile Where Name='Customer Portal User'];
        
        //Insert test customer portal user record   
        User user = new User(Alias = 'comm', Email='yg.qa167@gmail.com',ContactId=con.id,
                             EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                             LocaleSidKey='en_US', ProfileId = profile.Id,
                             TimeZoneSidKey='America/Los_Angeles', UserName='yg.qa167@gmail.com');
        
        insert user;
        System.debug('userId'+user.Id);
        
         
        //Insert test plant record   
           /* List<Plant__c> plantList=new List<Plant__c>();
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
            /*List<Customer_Plant__c> cusPlantList=new List<Customer_Plant__c>();
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
           // prod1.Production_Date__c = Date.newInstance(2014, 12, 17);
            prodList.add(prod1);
            
            Insert prodList;
            
            List<Asset> assList=new List<Asset>();
            Asset ass1=new Asset();
            ass1.Name = 'FCS0111';
            ass1.Product2Id = prod1.Id;
            ass1.AccountId = acc.Id;
            ass1.ContactId = con.Id;
            ass1.SerialNumber = 'FCS0111';
           ass1.PlantAccount__c = plant1.Id;
            ass1.Project__c = proj1.Id;
            ass1.MS_Code__c = 'FCS0111';
            ass1.Status = 'Installed';
            ass1.Lang_Code__c='EN';
            assList.add(ass1);
        	insert assList;
        
        	List<Customer_Asset__c> custAsstList =new List<Customer_Asset__c>();
        	Customer_Asset__c custAsst = new Customer_Asset__c();
        	custAsst.Contact__C = con.id;	
            custAsst.Asset__c = ass1.id;
        	custAsstList.add(custAsst);
        	insert custAsstList;
        
        YG_Community_Configuration__c selfReg = new YG_Community_Configuration__c(name= 'YGSelfRegisterAccountId',Text_1__c=acc.id);
        insert selfReg;
        Id selfRegId = selfReg.Text_1__c;
        
        //execute method as portal user   
        System.RunAs(user){
            System.debug('Current User: ' + UserInfo.getUserName());
            System.debug('loggedInUser Id: ' + UserInfo.getUserId());
            System.debug('Current Profile: ' + UserInfo.getProfileId());
            
            User loggedInUser= YG_Utility.getLoggedInUserInfo(UserInfo.getUserId());
           
            
            String langCode;
            
            try{
                YG_CommonController.checkContractOrIndividualCustomer();
                
                YG_CommonController.MenuWrapper commmenuWrapper = YG_CommonController.getMenuInfo();                
            }
            catch (Exception e) {
                System.debug('Error in testclass for YG_CommonControllerTest.commonTestMethod() ::: '+e.getMessage());
            }
        }
        
        Test.stopTest();
    }

}