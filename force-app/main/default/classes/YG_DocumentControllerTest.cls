/*
*******************************************************************************************************
* (C) Copyright 2020 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Chitrakishore
* @version 1.0
* @created 25/08/2020
* @description 
* This class is used to write the Apex test class coverage for document API related call.
*
* 
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  
*  
*
*/

@isTest
public class YG_DocumentControllerTest {
    
    static testmethod void documentAPITestMethod(){
        
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
            
            //Inserting test plant record
            List<Plant__c> plantList=new List<Plant__c>();
            Plant__c plant1=new Plant__c();
            plant1.Name = 'TestPlantDoc';
            plant1.Account__c = acc.Id;  
            plant1.Plant_Code__c = '300000142';
            plant1.Lang_Code__c = 'EN';
            plantList.add(plant1);
            insert plantList;
            
            //Inserting test Category Hierarchy and Category record
            List<Category_Hierarchy__c> catHierList=new List<Category_Hierarchy__c>();
            Category_Hierarchy__c catHier3=new Category_Hierarchy__c(Category_Code__c = '12000000', Category_Level__c = 3, Display_Sequence__c = 500,
                                                                     Category_Hierarchy__c = NULL);
            catHierList.add(catHier3);
            Category_Hierarchy__c catHier6=new Category_Hierarchy__c(Category_Code__c = 'A0000000', Category_Level__c = 3, Display_Sequence__c = 500,
                                                                     Category_Hierarchy__c = NULL);
            catHierList.add(catHier6);
            
            insert catHierList;
            
            List<Category__c> catList=new List<Category__c>();
            Category__c catg6=new Category__c(Name = 'ADMAG AXG', Category_Hierarchy__c = catHier6.Id,
                                              Category_Type__c = 'Product', Language_Code__c = 'EN');
            catList.add(catg6);
            Category__c catg3=new Category__c(Name = 'Device Smart Communicators BT200', Category_Hierarchy__c = catHier3.Id,
                                              Category_Type__c = 'Product', Language_Code__c = 'EN');
            catList.add(catg3);
            insert catList;
                
                
                //Inserting test product record
            List<Product2> prodList=new List<Product2>();
            
            Product2 prod1=new Product2();
            prod1.Name = 'ADMAG AXG: Magnetic Flow Meter';
            prod1.Model_Code__c = 'AX01C';
            prod1.Category__c = catg6.Id;
            prod1.Production_Date__c = Date.newInstance(2014, 12, 17);
            prodList.add(prod1);
            
            Product2 prod2=new Product2();
            prod2.Name = 'Device Smart Communicators BT200';
            prod2.Model_Code__c = 'BT200';
            prod2.Category__c = catg3.Id;
            prod2.Production_Date__c = Date.newInstance(2014, 12, 17);
            prodList.add(prod2);
            
            Product2 prod3=new Product2();
            prod3.Name = 'Device Smart Communicators BT200';
            prod3.Model_Code__c = 'EJA110J';
            prod3.Category__c = catg3.Id;
            prod3.Production_Date__c = Date.newInstance(2014, 12, 17);
            prod3.Lang_Code__c = 'JA';
            prodList.add(prod3);
            
            insert prodList;
            
            //Inserting test asset record
            List<Asset> assList=new List<Asset>();
            Asset ass1=new Asset();
            ass1.Name = 'SU1234567';
            ass1.Product2Id = prod1.Id;
            ass1.AccountId = acc.Id;
            ass1.ContactId = con.Id;
            ass1.SerialNumber = 'SU1234567';
            ass1.Plant__c = plant1.Id;
            ass1.MS_Code__c = 'AAI543-H50';
            //ass1.Shipping_Date__c = Date.newInstance(2019, 7, 28);
            ass1.Lang_Code__c = 'EN';
            ass1.Status = 'Installed';
            
            assList.add(ass1);
            insert assList;
            
            //Inserting test document record
           /* List<Document__c> docList=new List<Document__c>();
            
            Document__c doc1=new Document__c();
            doc1.Name = 'IM_ADMAG_AXG';
            doc1.Type__c = 'Document';
            doc1.Category__c = 'Instruction Manuals';
            doc1.Lang_Code__c = 'EN';
            doc1.Product__c = prod1.Id;
            //doc1.MS_Code__c = ass1.Id;
            doc1.MS_Code__c = 'AAI543-H50';
            doc1.File_Extension__c = 'PDF';
            doc1.File_Size__c = '4MB';
            docList.add(doc1);
            
            Document__c doc2=new Document__c();
            doc2.Name = 'Soft_ADMAG_AXG';
            doc2.Type__c = 'Document';
            doc2.Category__c = 'Software';
            doc2.Lang_Code__c = 'EN';
            doc2.Product__c = prod1.Id;
            doc2.File_Extension__c = 'PDF';
            doc2.File_Size__c = '2MB';
            docList.add(doc2);
            
            Document__c doc3=new Document__c();
            doc3.Name = 'TM_ADMAG_AXG';
            doc3.Type__c = 'Resources';
            doc3.Category__c = 'Training Modules';
            doc3.Lang_Code__c = 'EN';
            doc3.Product__c = prod1.Id;
            doc2.MS_Code__c = ass1.Id;
            doc3.File_Extension__c = 'PDF';
            doc3.File_Size__c = '1MB';
            docList.add(doc3);
            
            Document__c doc4=new Document__c();
            doc4.Name = 'FAQ_ADMAG_AXG';
            doc4.Type__c = 'Resources';
            doc4.Category__c = 'Training Modules';
            doc4.Lang_Code__c = 'EN';
            doc4.Product__c = prod1.Id;
            doc4.File_Extension__c = 'PDF';
            doc4.File_Size__c = '3MB';
            docList.add(doc4);
            
            insert docList;*/
                
            YG_Community_Configuration__c systemIdConfig = new YG_Community_Configuration__c(name= 'ShippingAPISystemId',Text_1__c='AxkHnJ89');
            YG_Community_Configuration__c usageAreaConfig = new YG_Community_Configuration__c(name= 'ShippingAPIUsageArea',Text_1__c='1');
            YG_Community_Configuration__c docEndpointConfig = new YG_Community_Configuration__c(name= 'DocumentAPIEndpointUrl',Text_1__c='https://library.yokogawa.com/document/search');
            YG_Community_Configuration__c certEndpointConfig = new YG_Community_Configuration__c(name= 'CertificateAPIEndpointUrl',Text_1__c='https://library.yokogawa.com/contents/search');
            
            insert systemIdConfig;
            insert usageAreaConfig;
            insert docEndpointConfig;
            insert certEndpointConfig;
            
            String plantCode='300000142';
            String serialNumber='SU1234567';
            List<String> modelCode= new list<String> {'AX01C','AX01B'};
            String msCode = 'AAI543-H50';
            String frm = 'product-history';
                
            Test.setMock(HttpCalloutMock.class, new YG_DocumentAPIMockCallout());        
            Test.startTest();
            //HttpResponse  response = New HttpResponse ();        
        	
            YG_DocumentController.getDocumentAPIDetails(serialNumber,modelCode,plantCode,frm);
            
            List<Document__c> docList = YG_DocumentController.getCertificationDocumentList(serialNumber,'EN',msCode);
            
            //YG_DocumentAPIHandler.DocumentWrapper docWap = new YG_DocumentAPIHandler.DocumentWrapper();
            //docWap = YG_DocumentAPIHandler.searchCertificateCallout('91U601404','en');
            
            Test.stopTest();
        }
    }
}