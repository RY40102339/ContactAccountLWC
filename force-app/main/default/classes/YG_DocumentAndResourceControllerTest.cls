/********************************************************************************************************
* (C) Copyright 2020 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Vinod A
* @version 1.0
* @created 25/05/2020
* @description 
* This test class for YG_DocumentAndResourceController apex class.
*
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  07/01/2020			Vinod					plant selection added for code coverage.
*  04/21/2021 			Kavya 					Removed Plant__c Object and replaced with Account Object.
*												Removed Plant__c(Plant) Lookup field from Asset and newly added PlantAccount__c(Account) Lookup field in Asset Object. 					
*/
@istest
public class YG_DocumentAndResourceControllerTest {
    
    @testSetup
    static void createTestData(){
		
        //Inserting test account record
        Account acc = new account();
        acc.name='Test AccountDocData';    
        acc.Type = 'Customer';
        //acc.DUNS_Number__c=102224222; 
        insert acc;
        
        //Inserting test contact record
        Contact con = new Contact();   
        con.FirstName='User';
        con.LastName='DocContact1';
        con.Email='testContact@chevron.com';
        con.accountid=acc.id; 
        insert con;
        
        //Inserting test portal user record
        User user = new User();   
        user.ProfileID = [Select Id From Profile Where Name='Customer Portal User'].id; 
        System.debug('user.ProfileID');
        user.EmailEncodingKey = 'ISO-8859-1';   user.LanguageLocaleKey = 'en_US';   user.TimeZoneSidKey = 'America/New_York';   
        user.LocaleSidKey = 'en_US';   user.FirstName = 'User';   user.LastName = 'testContact';   user.Username = 'testContact@chevron.com';      
        user.CommunityNickname = 'User222';   user.Alias = 'user';   user.Email = 'testContact@chevron.com';   user.IsActive = true;   
        user.ContactId = con.Id;  
        insert user;  
        
        //Inserting test plant record
       /* List<Plant__c> plantList=new List<Plant__c>();
        Plant__c plant1=new Plant__c();
        plant1.Name = 'TestPlantDoc';
        plant1.Account__c = acc.Id;  
        plant1.Plant_Code__c = '300000142';
        plant1.Lang_Code__c = 'EN';
        plantList.add(plant1);
        insert plantList;*/
        
        //Inserting test plant record
       List<Account> plantList=new List<Account>();
        Account plant1=new Account();
        plant1.Name = 'TestPlantDoc';
        plant1.ParentId = acc.Id;  
        plant1.AccountNumber = '300000142';
         plant1.Type = 'Plant';
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
        //prod1.Production_Date__c = Date.newInstance(2014, 12, 17);
        prodList.add(prod1);
        
        Product2 prod2=new Product2();
        prod2.Name = 'Device Smart Communicators BT200';
        prod2.Model_Code__c = 'BT200';
        prod2.Category__c = catg3.Id;
        //prod2.Production_Date__c = Date.newInstance(2014, 12, 17);
        prodList.add(prod2);
        
        insert prodList;
        
        //Inserting test asset record
        List<Asset> assList=new List<Asset>();
        Asset ass1=new Asset();
        ass1.Name = 'SU1234567';
        ass1.Product2Id = prod1.Id;
        ass1.AccountId = acc.Id;
        ass1.ContactId = con.Id;
        ass1.SerialNumber = 'SU1234567';
        ass1.PlantAccount__c = plant1.Id;
        ass1.MS_Code__c = 'AAI543-H50';
        //ass1.Shipping_Date__c = Date.newInstance(2019, 7, 28);
        ass1.Status = 'Installed';
        
        assList.add(ass1);
        insert assList;
        
        //Inserting test document record
        List<Document__c> docList=new List<Document__c>();
        
        Document__c doc1=new Document__c();
        doc1.Name = 'IM_ADMAG_AXG';
        doc1.Type__c = 'Document';
        doc1.Category__c = 'Instruction Manuals';
        doc1.Lang_Code__c = 'EN';
        doc1.Product__c = prod1.Id;
        //doc1.MS_Code__c = ass1.Id;
        doc1.MS_Code__c = 'AAI543-H50';
        doc1.File_Extension__c = 'PDF';
        doc1.File_Size__c = '4000';
        docList.add(doc1);
        
        Document__c doc11=new Document__c();
        doc11.Name = 'IM_ADMAG_AXG';
        doc11.Type__c = 'Document';
        doc11.Category__c = 'Instruction Manuals';
        doc11.Lang_Code__c = 'EN';
        doc11.Product__c = prod1.Id;
        //doc1.MS_Code__c = ass1.Id;
        doc11.MS_Code__c = 'AAI543-H50';
        doc11.File_Extension__c = 'PDF';
        doc11.File_Size__c = '400';
        docList.add(doc11);
        
        Document__c docCert=new Document__c();
        docCert.Name = 'IM_ADMAG_AXG';
        docCert.Type__c = 'Document';
        docCert.Category__c = 'Certificates';
        docCert.Lang_Code__c = 'EN';
        docCert.Product__c = prod1.Id;
        //doc1.MS_Code__c = ass1.Id;
        docCert.MS_Code__c = 'AAI543-H50';
        docCert.File_Extension__c = 'PDF';
        docCert.File_Size__c = '4000';
        docList.add(docCert);
        
        Document__c docCert2=new Document__c();
        docCert2.Name = 'IM_ADMAG_AXG';
        docCert2.Type__c = 'Document';
        docCert2.Category__c = 'Certificates';
        docCert2.Lang_Code__c = 'EN';
        docCert2.Product__c = prod1.Id;
        //doc1.MS_Code__c = ass1.Id;
        docCert2.MS_Code__c = 'AAI543-H50';
        docCert2.File_Extension__c = 'PDF';
        docCert2.File_Size__c = '400';
        docList.add(docCert2);
        
        Document__c doc2=new Document__c();
        doc2.Name = 'Soft_ADMAG_AXG';
        doc2.Type__c = 'Document';
        doc2.Category__c = 'Certificates';
        doc2.Lang_Code__c = 'EN';
        doc2.Product__c = prod1.Id;
        doc2.File_Extension__c = 'PDF';
        doc2.File_Size__c = '1500';
        docList.add(doc2);
        
        Document__c doc3=new Document__c();
        doc3.Name = 'TM_ADMAG_AXG';
        doc3.Type__c = 'Resources';
        doc3.Category__c = 'Training Modules';
        doc3.Lang_Code__c = 'EN';
        doc3.Product__c = prod1.Id;
        doc3.MS_Code__c = ass1.Id;
        doc3.File_Extension__c = 'PDF';
        doc3.File_Size__c = '1500';
        docList.add(doc3);
        
        Document__c doc4=new Document__c();
        doc4.Name = 'FAQ_ADMAG_AXG';
        doc4.Type__c = 'Resources';
        doc4.Category__c = 'Training Modules';
        doc4.Lang_Code__c = 'EN';
        doc4.Product__c = prod1.Id;
        doc4.File_Extension__c = 'PDF';
        doc4.File_Size__c = '3000';
        docList.add(doc4);
        
        insert docList;
        
        //Inserting test custom setting record
        YG_Community_Configuration__c commConfig2=new YG_Community_Configuration__c();
        commConfig2.Name = 'YG Customer Portal Base URL';
        commConfig2.Text_1__c = 'https://dev1-yg.cs31.force.com';
        insert commConfig2;
        
        //Inserting test file
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Image';
        cv.PathOnClient = 'TestImage.jpg';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        Insert cv;
        
        //Get Content Documents
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
        
        //Create ContentDocumentLink 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = doc1.Id;
        cdl.ContentDocumentId = conDocId;
        cdl.shareType = 'V';
        Insert cdl;
        
        //Inserting test file
         ContentVersion cv1 = new ContentVersion();
        cv1.Title = 'Test Image';
        cv1.PathOnClient = 'TestImage.jpg';
        cv1.VersionData = Blob.valueOf('Test Content');
        cv1.IsMajorVersion = true;
        Insert cv1;
        
        //Get Content Documents
        Id conDocId1 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv1.Id].ContentDocumentId;
        
        //Create ContentDocumentLink 
        ContentDocumentLink cdl1 = New ContentDocumentLink();
        cdl1.LinkedEntityId = ass1.Id;
        cdl1.ContentDocumentId = conDocId1;
        cdl1.shareType = 'V';
        Insert cdl1;
    }
    
    //Test Method to invoke the YG_DocumentAndResourceController class
    @istest static void getDocandResTestMethod(){
        
        YG_DocumentAndResourceController.mainWrapper mainWrap=new YG_DocumentAndResourceController.mainWrapper();
        mainWrap = YG_DocumentAndResourceController.getDocAndResourceDetails('Document', 'SU1234567', '','300000142', 'product-details');
        System.assertEquals(1, mainWrap.subWrap.size());
        System.assertEquals(null, mainWrap.moduleName);
        mainWrap = YG_DocumentAndResourceController.getDocAndResourceDetails('Document', '', 'AX01C','300000142', 'product-details');
        mainWrap = YG_DocumentAndResourceController.getDocAndResourceDetails('Document', '', 'AX01C','300000142', '');
        //System.assertEquals(2, mainWrap.subWrap.size());
        //System.assertEquals('ADMAG AXG: Magnetic Flow Meter', mainWrap.moduleName);
        
        mainWrap = YG_DocumentAndResourceController.getDocAndResourceDetails('Resources', '', 'AX01C','300000142','product-details');
        //System.assertEquals(null, mainWrap.moduleName);
        mainWrap = YG_DocumentAndResourceController.getDocAndResourceDetails('Resources', 'SU1234567','','300000142','product-details');
        System.assertEquals(1,mainWrap.subWrap.size());

    }
}