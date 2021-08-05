/*
*******************************************************************************************************
* (C) Copyright 2020 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Citrakishore M
* @version 1.0
* @created 26/11/2020
* @description  
* This class is used to call the case registration API.
*
* Change History:
*  MM/DD/YYYY           Developer Name          Comments
*  04/21/2021           Kavya 					Removed Plant__c Object and replaced with Account Object.
*												Removed Plant__c(Plant) Lookup field from Asset and newly added PlantAccount__c(Account) Lookup field in Asset Object.
*/

@isTest
public class YG_CaseRegisterationAPIControllerTest {
	
    static testmethod void caseRegisterationAPITestMethod(){
        
        //Insert test account record
        Account acc = new account();
        acc.name='XYZ Account';
         acc.Type = 'Customer';
        //acc.DUNS_Number__c=102224533; 
        insert acc;    

        //Insert test contact record        
        Contact con = new Contact();   
        con.FirstName='User';
        con.LastName='CVX AU';
        con.Email='cvxauuser011@chevron.com';
        con.accountid=acc.id; 
        insert con;
        
        //Insert test product record
        List<Product2> prodList=new List<Product2>();
        
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
        
        Product2 prod2=new Product2();
        prod2.Name = 'Device Smart Communicators BT200';
        prod2.Model_Code__c = 'BT200';
        prod2.Category__c = catg3.Id;
        //prod2.Production_Date__c = Date.newInstance(2014, 12, 17);
        prod2.Lang_Code__c = 'EN';
        prodList.add(prod2);        
        Insert prodList;
        
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
        
        //Insert test asset record
        Asset ass1=new Asset();
        ass1.Name = '5F89965C-FF92-11E8-B7DC-06328AF41CA4';
        ass1.Product2Id = prod2.Id;
        ass1.AccountId = acc.Id;
        ass1.ContactId = con.Id;
        ass1.SerialNumber = 'SU1234567';
        ass1.PlantAccount__c = plant1.Id;
        ass1.MS_Code__c = 'AAI543-H50';
        //ass1.Shipping_Date__c = Date.newInstance(2019, 7, 28);
        ass1.Lang_Code__c = 'EN';
        ass1.Status = 'Installed'; 
        insert ass1;
        
        ServiceContract servCont=new ServiceContract();
        servCont.Name = '라이온코리아(인천) N(세제)(통합) Plant LION Co. Korea (Incheon)';
        servCont.Contract_No__c = 'YKO-L00078-2001-01';
        servCont.AccountId = acc.Id;
        servCont.StartDate = date.today()-30;
        servCont.EndDate = date.today()+90;
        Insert servCont;

                
        Case caseObj = new Case();
        //caseObj1.CaseNumber='';
        caseObj.ServAir_Incident_Number__c = 'YEA-C2011-00094';
        caseObj.Status = 'Closed';
        caseObj.Account = acc;
        caseObj.Description='This case was created from inspection.';
        caseObj.Subject='This is for EXA series prodcuts PM';
        caseObj.type='Request For Service';
        caseObj.Priority='030';
        caseObj.Plant_Code__c='300000142';
        caseObj.Service_you_require__c='010';
        caseObj.Product =prod2;
        caseObj.Asset = ass1;
        insert caseObj;
      
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
            
            YG_Community_Configuration__c systemIdConfig = new YG_Community_Configuration__c(name= 'ShippingAPISystemId',Text_1__c='AxkHnJ89');
            YG_Community_Configuration__c usageAreaConfig = new YG_Community_Configuration__c(name= 'ShippingAPIUsageArea',Text_1__c='1');
            YG_Community_Configuration__c endpointConfig = new YG_Community_Configuration__c(name= 'Case Registration API Endpoint URL',Text_1__c='https://library.yokogawa.com/incident/caseregistration/');
            YG_Community_Configuration__c serviceOrgId = new YG_Community_Configuration__c(name= 'Case Registration API serviceOrgId',Text_1__c='D0E4D312-0C56-4543-A454-66B9D8A89D93');
            
            insert systemIdConfig;
            insert usageAreaConfig;
            insert endpointConfig;
            insert serviceOrgId;
            
            Test.setMock(HttpCalloutMock.class, new YG_CaseRegAPIMockCallout());
            test.startTest();
            
            HttpResponse  response = New HttpResponse();
            
            ID caseId = caseObj.Id;
            
            YG_CaseRegistrationAPIController.callCaseRegistrationAPI(caseId);
                
                
            Test.stopTest();
            
        }
        
    }
}