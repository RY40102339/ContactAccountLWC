/*
*******************************************************************************************************
* (C) Copyright 2020 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Chitrakishore
* @version 1.0
* @created 27/07/2020
* @description 
* This class is used to write the Apex test class coverage for API related call.
*
* @test class name - YG_ProductRegistrationControllerTest
*
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  09/03/2020			Vinod					Improved Code coverage
*  
*
*/

@isTest
public class YG_ProductRegistrationControllerTest {
    
    static testmethod void systemModuleTestMethod(){
        
        //Test.startTest();
        
        //Insert test account record
        Account acc = new account();
        acc.name='XYZ Account';        
        //acc.DUNS_Number__c=102224533; 
        insert acc;    

		//Insert test contact record        
        Contact con = new Contact();   
        con.FirstName='User';
        con.LastName='CVX AU';
        con.Email='cvxauuser011@chevron.com';
        con.accountid=acc.id; 
        insert con;
      
        Profile profile = [Select Id From Profile Where Name='Customer Portal User'];
        
        //Insert test customer portal user record   
        User user = new User(Alias = 'comm', Email='yg.qa167@gmail.com',ContactId=con.id,
                             EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                             LocaleSidKey='en_US', ProfileId = profile.Id,
                             TimeZoneSidKey='America/Los_Angeles', UserName='yg.qa167@gmail.com');
        
        insert user;
           
        System.debug('userId'+user.Id);
        
        
        //execute method as portal user   
        System.RunAs(user){
            System.debug('Current User: ' + UserInfo.getUserName());
            System.debug('loggedInUser Id: ' + UserInfo.getUserId());
            System.debug('Current Profile: ' + UserInfo.getProfileId());
            
            User loggedInUser= YG_Utility.getLoggedInUserInfo(UserInfo.getUserId());
            
            //Insert test plant record   
            List<Plant__c> plantList=new List<Plant__c>();
            Plant__c plant1=new Plant__c();
            plant1.Name = 'TestPlant';
            plant1.Account__c = acc.Id;  
            plant1.Plant_Code__c = '300000142';
            plant1.Lang_Code__c = 'EN';
            plantList.add(plant1);
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
            
            Serial_Number_Search_Result__c snSearchRes = new Serial_Number_Search_Result__c();
            snSearchRes.Asset__c = ass1.id;
            snSearchRes.Contact__c = con.Id;
            insert snSearchRes;
            
            YG_Community_Configuration__c systemIdConfig = new YG_Community_Configuration__c(name= 'ShippingAPISystemId',Text_1__c='AxkHnJ89');
            YG_Community_Configuration__c usageAreaConfig = new YG_Community_Configuration__c(name= 'ShippingAPIUsageArea',Text_1__c='1');
            YG_Community_Configuration__c endpointConfig = new YG_Community_Configuration__c(name= 'ShippingAPIEndpointURL',Text_1__c='https://library.yokogawa.com/shipment/search/');
            
            insert systemIdConfig;
            insert usageAreaConfig;
            insert endpointConfig;
            
            String plantCode='300000142';
            String serialNumber = '91W610216';
            String languageId = 'EN';
            
            Test.setMock(HttpCalloutMock.class, new YG_ProductAPIMockCallout());
            test.startTest();
            system.runAs(user){
                try{
                    
                    HttpResponse  response = New HttpResponse ();
                    
                    YG_ProductRegistrationController.SerialNumSearchWrapper searchWrapper = YG_ProductRegistrationController.searchSerialNumber(serialNumber);
                    System.assertNotEquals(null, searchWrapper);
                    System.assertEquals(true, searchWrapper.success);
                    
                    //String assetToRegisterListAsStr = '[{"langCode":"EN","modelCode":"EJX530A","msCode":"EJX530A-JAS4N-017EL/FF1/D1/N4/A1/HC","plantCode":"300000142","productCareer":"S2","productionDate":"2020-06-03","serialNumber":"91W610216"}]';
                    String assetToRegisterListAsStr = '["FCS0111"]';
                    YG_ProductRegistrationController.SerialNumRegisterWrapper registerWrapper = YG_ProductRegistrationController.registerSerialNumber( assetToRegisterListAsStr);
                    System.assertEquals(true, registerWrapper.success);
                    
                    YG_ProductRegistrationController.SerialNumSearchWrapper searchWrapper1 = YG_ProductRegistrationController.searchSerialNumber('SU1234567');
                    System.assertEquals(true, searchWrapper1.serialNumberExist);
                    System.assertEquals(true, searchWrapper1.success);
                    
                }
                catch(Exception e){
                    
                }
            }
            
            Test.stopTest();
            
        }
    }
}