/*
*******************************************************************************************************
* (C) Copyright 2020 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Gokilavani
* @version 1.0
* @created 04/19/2021
* @description  
* This class is used for exposing the REST API url for the case API.
*
* @test class name - 
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  
*/

@isTest
public class YG_CaseDocumentAPITest {
    
    @isTest static void testCaseDocumentAPI(){
        
        //Inserting test account record
        Account acc = new account();
        acc.name='XYZ Account';  
        acc.Type = 'Customer';
        acc.AccountNumber = '1212121';
        acc.ShippingCountry = 'India';
        insert acc; 
        
        //Inserting self registered test account record
        Account acc1 = new account();
        acc1.name='Self Registered Account';        
        insert acc1; 
        
        //Inserting test contact record
        Contact con = new Contact();   
        con.FirstName='caseTest';
        con.LastName='DocAPI';
        con.Email='caseTestAPI@chevron.com';
        con.accountid=acc.id; 
        con.phone = '(123)-456-789';
        con.title = 'Plant Manager';
        insert con;
        
        
        //Inserting self registered test contact record
        Contact con1 = new Contact();   
        con1.FirstName='self';
        con1.LastName='Contact';
        con1.Email='selfregistered@chevron.com';
        con1.accountid=acc1.id; 
        con1.phone = '(124)-456-789';
        con1.title = 'Plant Manager';
        con1.MailingCountry = 'IN';
        insert con1;
        
        //Inserting test portal user record
        Profile profile = [Select Id From Profile Where Name='Customer Portal User'];
        User user = new User(Alias = 'comm', Email='yg.qa167@gmail.com',ContactId=con.id,
                             EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                             LocaleSidKey='en_US', ProfileId = profile.Id,
                             TimeZoneSidKey='America/Los_Angeles', UserName='yg.qa167@gmail.com');
        insert user;
        
        //Inserting test plant record
        List<Account> plantList=new List<Account>();
        Account plant1=new Account();
        plant1.Name = 'TestPlant';
        plant1.ParentId = acc.Id;  
        plant1.AccountNumber = '300000142';
        plant1.Type = 'Plant';
        plantList.add(plant1);
        insert plantList;
        
        //Inserting test customer plant record
        List<AccountContactRelation> cusPlantList=new List<AccountContactRelation>();
        AccountContactRelation cusPlant1=new AccountContactRelation();
        cusPlant1.ContactId = con.Id;
        cusPlant1.AccountId = plant1.Id;
        cusPlant1.Status__c = 'Approved site access';
        cusPlantList.add(cusPlant1);
        insert cusPlantList;
        
        //Inserting test project record
        List<Project__c> projectList=new List<Project__c>();
        Project__c proj1=new Project__c();
        proj1.Account__c = plant1.Id;
        /*proj1.Account__c = acc.Id;
		proj1.Plant__c = plant1.Id;*/
        proj1.Name = 'Test Project';
        proj1.Project_Code__c = 'VP700250';
        projectList.add(proj1);
        insert projectList;
        
        //Inserting test Category Hierarchy record
        List<Category_Hierarchy__c> catHierUppLvlList=new List<Category_Hierarchy__c>();
        Category_Hierarchy__c catHierL1=new Category_Hierarchy__c(Category_Code__c = '20000000', Category_Level__c = 1, Display_Sequence__c = 500, Upper_Category_Code__c = NULL);
        catHierUppLvlList.add(catHierL1); // DCS
        
        Category_Hierarchy__c catHierL2=new Category_Hierarchy__c(Category_Code__c = '10000000', Category_Level__c = 1, Display_Sequence__c = 500, Upper_Category_Code__c = NULL);
        catHierUppLvlList.add(catHierL2); //Field INs
        
        insert catHierUppLvlList;
        
        List<Category_Hierarchy__c> catHierLowLvlList=new List<Category_Hierarchy__c>();
        Category_Hierarchy__c catHierL21=new Category_Hierarchy__c(Category_Code__c = '21000000', Category_Level__c = 2, Display_Sequence__c = 500, Upper_Category_Code__c = NULL, Category_Hierarchy__c = catHierL1.id);
        catHierLowLvlList.add(catHierL21); //Hardware 
        
        Category_Hierarchy__c catHierL22=new Category_Hierarchy__c(Category_Code__c = '22000000', Category_Level__c = 2, Display_Sequence__c = 500, Upper_Category_Code__c = NULL, Category_Hierarchy__c = catHierL1.id);
        catHierLowLvlList.add(catHierL22); //software 
        
        Category_Hierarchy__c catHierL11=new Category_Hierarchy__c(Category_Code__c = '11000000', Category_Level__c = 2, Display_Sequence__c = 500, Upper_Category_Code__c = NULL, Category_Hierarchy__c = catHierL2.id);
        catHierLowLvlList.add(catHierL11); //Flow meters
        
        Category_Hierarchy__c catHier00=new Category_Hierarchy__c(Category_Code__c = '11100000', Category_Level__c = 3, Display_Sequence__c = 500, Upper_Category_Code__c = NULL, Category_Hierarchy__c = catHierL11.id);
        catHierLowLvlList.add(catHier00); // For exception coverage 
        
        insert catHierLowLvlList;
        
        Category_Hierarchy__c catHierL12=new Category_Hierarchy__c(Category_Code__c = '11100000', Category_Level__c = 3, Display_Sequence__c = 500, Upper_Category_Code__c = NULL, Category_Hierarchy__c = catHierL11.id);
        insert catHierL12; //Admag
        
        //Inserting test Category record
        List<Category__c> catList=new List<Category__c>();
        Category__c catg1 = new Category__c(Name = 'Distributed Control Systems (DCS)', Category_Hierarchy__c = catHierL1.Id,
                                            Category_Type__c = 'System', Language_Code__c = 'EN');
        catList.add(catg1);
        
        Category__c catg2 = new Category__c(Name = 'Hardware', Category_Hierarchy__c = catHierL21.Id,
                                            Category_Type__c = 'System', Language_Code__c = 'EN');
        catList.add(catg2);
        
        Category__c catg3 = new Category__c(Name = 'Software', Category_Hierarchy__c = catHierL22.Id,
                                            Category_Type__c = 'System', Language_Code__c = 'EN');
        catList.add(catg3);
        
        Category__c catg4=new Category__c(Name = 'Field Instruments', Category_Hierarchy__c = catHierL2.Id,
                                          Category_Type__c = 'Product', Language_Code__c = 'EN');
        catList.add(catg4);
        
        Category__c catg5=new Category__c(Name = 'Flow Meters', Category_Hierarchy__c = catHierL11.Id,
                                          Category_Type__c = 'Product', Language_Code__c = 'EN');
        catList.add(catg5);
        
        Category__c catg6=new Category__c(Name = 'ADMAG AXG', Category_Hierarchy__c = catHierL12.Id,
                                          Category_Type__c = 'Product', Language_Code__c = 'EN',Service_Org__c = 'IA-PS');
        catList.add(catg6);
        
        Category__c catg7=new Category__c(Name = 'Test Product', Category_Hierarchy__c = catHier00.Id,
                                          Category_Type__c = 'Product', Language_Code__c = 'EN', Service_Org__c = 'IA-PS');
        catList.add(catg7); //For Exception
        
        Insert catList;
        
        //Inserting test product record
        List<Product2> prodList=new List<Product2>();
        
        Product2 prod1=new Product2();
        prod1.Name = 'Distributed Control Systems (DCS)';
        prod1.Model_Code__c = 'AFV10D';
        prod1.Category__c = catg2.Id;
       // prod1.Production_Date__c = Date.newInstance(2014, 12, 17);
        prod1.Lang_Code__c = 'EN';
        prodList.add(prod1);
        
        Product2 prod2=new Product2();
        prod2.Name = 'PC';
        prod2.Model_Code__c = 'PC';
        prod2.Category__c = catg3.Id;
        //prod2.Production_Date__c = Date.newInstance(2014, 12, 17);
        prod2.Lang_Code__c = 'EN';
        prodList.add(prod2);
        
        Product2 prod3=new Product2();
        prod3.Name = 'Analog Input Module (4 to 20 mA, 16-Channel, Isolated)';
        prod3.Model_Code__c = 'AAI143';
        prod3.Product_Type__c = 'Hardware';
        prod3.Category__c = catg2.Id;
       // prod3.Production_Date__c = Date.newInstance(2014, 12, 17);
        prod3.Lang_Code__c = 'EN';
        prodList.add(prod3);
        
        Product2 prod4=new Product2();
        prod4.Name = 'Analog Output Module (4 to 20 mA, 16-Channel, Isolated)';
        prod4.Model_Code__c = 'AAI543';
        prod4.Product_Type__c = 'Hardware';
        prod4.Category__c = catg2.Id;
       // prod4.Production_Date__c = Date.newInstance(2014, 12, 17);
        prod4.Lang_Code__c = 'EN';
        prodList.add(prod4);
        
        Product2 prod5=new Product2();
        prod5.Name = 'Node Expansion Package (for AFV10)';
        prod5.Model_Code__c = 'LFS1550';
        prod5.Product_Type__c = 'Software';
        prod5.Category__c = catg3.Id;
       // prod5.Production_Date__c = Date.newInstance(2014, 12, 17);
        prod5.Lang_Code__c = 'EN';
        prodList.add(prod5);
        
        Product2 prod6=new Product2();
        prod6.Name = 'ADMAG AXG: Magnetic Flow Meter';
        prod6.Model_Code__c = 'SH123145';
        prod6.Product_Type__c = '';
        prod6.Category__c = catg6.Id;
       // prod6.Production_Date__c = Date.newInstance(2014, 12, 17);
        prod6.Lang_Code__c = 'EN';
        prodList.add(prod6);
        
        Product2 prod7=new Product2();
        prod7.Name = 'Test Product';
        prod7.Model_Code__c = 'TestProduct';
        prod7.Product_Type__c = '';
        prod7.Category__c = catg7.id;
       // prod7.Production_Date__c = Date.newInstance(2014, 12, 17);
        prod7.Lang_Code__c = 'EN';
        prodList.add(prod7);
        
        Insert prodList;
        
        //Inserting test asset record
        List<Asset> assList=new List<Asset>();
        Asset ass1=new Asset();
        ass1.Name = 'FCS0111';
        ass1.Product2Id = prod1.Id;
        //ass1.AccountId = acc.Id;
        ass1.AccountId = plant1.Id;
        ass1.ContactId = con.Id;
        ass1.SerialNumber = '';
        //ass1.Plant__c = plant1.Id;
        ass1.Project__c = proj1.Id;
        ass1.MS_Code__c = 'FCS0111';
        ass1.Lang_Code__c = 'EN';
        ass1.Station_Number__c = 11;
        ass1.Station_Type__c = 'FCS';
        ass1.Domain__c = 1;
        insert ass1;
        
        Asset ass2=new Asset();
        ass2.Name = 'HIS0101';
        ass2.Product2Id = prod2.Id;
        ass2.AccountId = plant1.Id;
        //ass2.AccountId = acc.Id;
        ass2.ContactId = con.Id;
        ass2.SerialNumber = '';
        //ass2.Plant__c = plant1.Id;
        ass2.MS_Code__c = 'CP451-10';
        ass2.Project__c = proj1.Id;
        ass2.Lang_Code__c = 'EN';
        ass2.Station_Number__c = 1;
        ass2.Station_Type__c = 'HIS';
        ass2.Domain__c = 1;
        insert ass2;
        
        Asset ass3=new Asset();
        ass3.Name = 'C2MD04027H';
        ass3.Product2Id = prod3.Id;
        ass3.AccountId = plant1.Id;
        // ass3.AccountId = acc.Id;
        ass3.ContactId = con.Id;
        ass3.SerialNumber = 'C2MD04027H';
        // ass3.Plant__c = plant1.Id;
        ass3.MS_Code__c = 'CP451-10';
        ass3.ParentId = ass1.Id;
        ass3.Lang_Code__c = 'EN';
        ass3.Project__c = proj1.Id;
        assList.add(ass3);
        
        Asset ass4=new Asset();
        ass4.Name = 'C2MD04026H';
        ass4.Product2Id = prod4.Id;
        ass4.AccountId = plant1.Id;
        //ass4.AccountId = acc.Id;
        ass4.ContactId = con.Id;
        ass4.SerialNumber = 'C2MD04026H';
        //ass4.Plant__c = plant1.Id;
        ass4.MS_Code__c = 'CP451-10';
        ass4.ParentId = ass1.Id;
        ass4.Lang_Code__c = 'EN';
        ass4.Project__c = proj1.Id;
        assList.add(ass4);
        
        Asset ass5=new Asset();
        ass5.Name = 'LFS1550-V11';
        ass5.Product2Id = prod5.Id;
        ass5.AccountId = plant1.Id;
        //ass5.AccountId = acc.Id;
        ass5.ContactId = con.Id;
        ass5.SerialNumber = 'LFS1550-V11';
        //ass5.Plant__c = plant1.Id;
        ass5.MS_Code__c = 'LFS1550-V11';
        ass5.ParentId = ass2.Id;
        ass5.Lang_Code__c = 'EN';
        ass5.Project__c = proj1.Id;
        assList.add(ass5);
        
        Asset ass6=new Asset();
        ass6.Name = 'SU1234567';
        ass6.Product2Id = prod6.Id;
        ass6.AccountId = plant1.Id;
        //ass6.AccountId = acc.Id;
        ass6.ContactId = con.Id;
        ass6.SerialNumber = 'SU1234567';
        //ass6.Plant__c = plant1.Id;
        ass6.MS_Code__c = 'SU1234567';
        ass6.Lang_Code__c = 'EN';
        ass6.Project__c = proj1.Id;
        assList.add(ass6);
        
        Insert assList;
        
        //form case service request record
        YG_ServiceRequestAndInquiries.createServiceRequest caseServReq = new YG_ServiceRequestAndInquiries.createServiceRequest();
        caseServReq.Type = 'Request For Service';
        caseServReq.serviceType = '010';
        caseServReq.Description = 'T&M products requires testing';
        caseServReq.plantId = plant1.Id;
        
        List<YG_ServiceRequestAndInquiries.prodReqService> caseProdServReqList= new List<YG_ServiceRequestAndInquiries.prodReqService>();
        YG_ServiceRequestAndInquiries.prodReqService caseProdServReq = new YG_ServiceRequestAndInquiries.prodReqService();
        caseProdServReq.Id = ass6.Id;
        caseProdServReq.Name = ass6.Name;
        caseProdServReqList.add(caseProdServReq);
        caseServReq.prodSelected = caseProdServReqList;
        String servReqData = JSON.serialize(caseServReq);
        
        YG_ServiceRequestAndInquiries.createServiceRequest caseServReq1 = new YG_ServiceRequestAndInquiries.createServiceRequest();
        caseServReq1.Type = 'Request For Service';
        caseServReq1.serviceType = '010';
        caseServReq1.Description = 'T&M products requires testing';
        caseServReq1.plantId = plant1.Id;
        
        List<YG_ServiceRequestAndInquiries.prodReqService> caseProdServReqList1= new List<YG_ServiceRequestAndInquiries.prodReqService>();
        YG_ServiceRequestAndInquiries.prodReqService caseProdServReq1 = new YG_ServiceRequestAndInquiries.prodReqService();
        caseProdServReq1.Id = prod1.Id;
        caseProdServReq1.Name = prod1.Name;
        caseProdServReqList1.add(caseProdServReq1);
        
        YG_ServiceRequestAndInquiries.prodReqService caseProdServReq2 = new YG_ServiceRequestAndInquiries.prodReqService();
        caseProdServReq2.Id = ass1.Id;
        caseProdServReq2.Name = ass1.Name;
        caseProdServReqList1.add(caseProdServReq2);
        
        caseServReq1.prodSelected = caseProdServReqList1;
        String servReqData1 = JSON.serialize(caseServReq1);
        
        YG_ServiceRequestAndInquiries.createServiceRequest caseServReq2 = new YG_ServiceRequestAndInquiries.createServiceRequest();
        caseServReq2.Type = 'Request For Service';
        caseServReq2.serviceType = '010';
        caseServReq2.Description = 'T&M products requires testing';
        caseServReq2.plantId = plant1.Id;
        
        List<YG_ServiceRequestAndInquiries.prodReqService> caseProdServReqList2= new List<YG_ServiceRequestAndInquiries.prodReqService>();     
        YG_ServiceRequestAndInquiries.prodReqService caseProdServReq3 = new YG_ServiceRequestAndInquiries.prodReqService();
        caseProdServReq3.Id = '0';
        caseProdServReq3.Name = 'Others';
        caseProdServReqList2.add(caseProdServReq3);
        
        caseServReq2.prodSelected = caseProdServReqList2;
        String servReqData2 = JSON.serialize(caseServReq2);
        
        //insert custom setting record
        List<YG_Community_Configuration__c> configList = new List<YG_Community_Configuration__c>();
        YG_Community_Configuration__c selfReg = new YG_Community_Configuration__c();
        selfReg.Name = 'YGSelfRegisterAccountId';
        selfReg.Text_1__c = acc1.Id;
        configList.add(selfReg);
        
        YG_Community_Configuration__c clsCode = new YG_Community_Configuration__c();
        clsCode.Name = 'Classification_Code';
        clsCode.Text_1__c = '0002,0003';
        configList.add(clsCode);
        
        YG_Community_Configuration__c ofcType=new YG_Community_Configuration__c();
        ofcType.Name = 'Office_Type';
        ofcType.Text_1__c = '1,4';
        configList.add(ofcType);
        
        YG_Community_Configuration__c iaps=new YG_Community_Configuration__c();
        iaps.Name = 'IA-PS';
        iaps.Text_1__c = 'iapsyg@yg.com';
        configList.add(iaps);
        
        YG_Community_Configuration__c iass=new YG_Community_Configuration__c();
        iass.Name = 'IA-SS';
        iass.Text_1__c = 'lassyg@yg.com';
        configList.add(iass);
        
        YG_Community_Configuration__c li=new YG_Community_Configuration__c();
        li.Name = 'LI';
        li.Text_1__c = 'liyg@yg.com';
        configList.add(li);
        
        YG_Community_Configuration__c systemid=new YG_Community_Configuration__c();
        systemid.Name = 'ShippingAPISystemId';
        systemid.Text_1__c = 'F5cJnZkn';
        configList.add(systemid);
        
        YG_Community_Configuration__c apiUrl=new YG_Community_Configuration__c();
        apiUrl.Name = 'Case Registration API Endpoint URL';
        apiUrl.Text_1__c = 'https://library.yokogawa.com/incident/caseregistration';
        configList.add(apiUrl);
        
        YG_Community_Configuration__c caseAPIUrl=new YG_Community_Configuration__c();
        caseAPIUrl.Name = 'Case Document API EndPoint URL';
        caseAPIUrl.Text_1__c = 'https://library.yokogawa.com:8180/incident/attachfiletocase';
        configList.add(caseAPIUrl);
        
        YG_Community_Configuration__c serviceOrgId=new YG_Community_Configuration__c();
        serviceOrgId.Name = 'Case Registration API serviceOrgId';
        serviceOrgId.Text_1__c = 'D0E4D312-0C56-4543-A454-66B9D8A89D93';
        configList.add(serviceOrgId);
        
        insert configList;
        
        Contact cont = YG_ServiceRequestAndInquiries.getYourDetails();
        
        //create service request
        string createServReq = YG_ServiceRequestAndInquiries.createServiceReq(servReqData);
        Id caseId=createServReq;
        
        insert new Contentversion(Title = 'ABC', PathOnClient = 'test', VersionData = EncodingUtil.base64Decode('Unit Test Attachment Body'));
        
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];

        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = caseId;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        cdl.Visibility = 'AllUsers';
        insert cdl;
      
       
        
        System.RunAs(user){
            //Calling mock response
            Test.setMock(HttpCalloutMock.class, new YG_CaseDocumentAPIMockCallout());
            String caseDocumentAPI=YG_CaseDocumentAPI.CaseDocumentAPI(caseId);
            system.assertNotEquals('ERROR', createServReq);
            
            /*string createServReq1 = YG_ServiceRequestAndInquiries.createServiceReq(servReqData1);
			Id caseId1=createServReq1;
			String caseDocumentAPI1=YG_CaseDocumentAPI.CaseDocumentAPI(caseId1);
			system.assertEquals('ERROR', createServReq1);

			string createServReq2 = YG_ServiceRequestAndInquiries.createServiceReq(servReqData2);
			Id caseId2=createServReq2;
			String caseDocumentAPI2=YG_CaseDocumentAPI.CaseDocumentAPI(caseId2);
			system.assertNotEquals('ERROR', createServReq2);*/
            
        }
        
    }
    
}