/*
*******************************************************************************************************
* (C) Copyright 2020 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Chitrakishore M
* @version 1.0
* @created 27/01/2021
* @description  
* This class is used for exposing the REST API url for the case API.
*
* @test class name - 
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  
*/

@isTest
public class YG_CaseAPITest {
	
    static testmethod void caseAPITestMethod(){
        
        //Insert test account record
        Account acc = new account();
        acc.name='XYZ Account'; 
        insert acc;    

        //Insert test contact record        
        Contact con = new Contact();   
        con.FirstName='User';
        con.LastName='CVX AU';
        con.Email='cvxauuser011@chevron.com';
        con.accountid=acc.id; 
        insert con;

        //Inserting test plant record
        List<Plant__c> plantList=new List<Plant__c>();
        Plant__c plant1=new Plant__c();
        plant1.Name = 'TestPlantDoc';
        plant1.Account__c = acc.Id;  
        plant1.Plant_Code__c = '300000142';
        plant1.Lang_Code__c = 'EN';
        plantList.add(plant1);
        insert plantList;
        
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
        prod2.Production_Date__c = Date.newInstance(2014, 12, 17);
        prod2.Lang_Code__c = 'EN';
        prodList.add(prod2);
        
        Insert prodList;
        
        //Insert test asset record
        List<Asset> assList=new List<Asset>();
        Asset ass1=new Asset();
        ass1.Name = '5F89965C-FF92-11E8-B7DC-06328AF41CA4';
        ass1.Product2Id = prod2.Id;
        ass1.AccountId = acc.Id;
        ass1.ContactId = con.Id;
        ass1.SerialNumber = 'SU1234567';
        ass1.Plant__c = plant1.Id;
        ass1.MS_Code__c = 'AAI543-H50';
        //ass1.Shipping_Date__c = Date.newInstance(2019, 7, 28);
        ass1.Lang_Code__c = 'EN';
        ass1.Status = 'Installed';       
        assList.add(ass1);
        
        ServiceContract servCont=new ServiceContract();
        servCont.Name = '라이온코리아(인천) N(세제)(통합) Plant LION Co. Korea (Incheon)';
        servCont.Contract_No__c = 'YKO-L00078-2001-01';
        servCont.AccountId = acc.Id;
        servCont.StartDate = date.today()-30;
        servCont.EndDate = date.today()+90;
        Insert servCont;
       
        
        Case caseObj = new Case();
        caseObj.ServAir_Incident_Number__c = 'YEA-C2011-00094';
        caseObj.Status = 'Closed';
        //caseObj.Asset.Id = ass1.Id;
        caseObj .Account = acc;
        caseObj.Subject = 'This is for EXA series prodcuts PM';
        caseObj.Description = 'This case was created from inspection.';
        caseObj.ServiceContract =servCont;
        caseObj.Origin= '';
        caseObj.Priority='030';
        caseObj.Plant_Code__c='300000142';
        caseObj.Product =prod2;
        caseObj.Service_you_require__c='010';
        //caseObj.ContactEmail ='cvxauuser011@chevron.com';
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
            //System.debug('Current User: ' + UserInfo.getUserName());
            //System.debug('loggedInUser Id: ' + UserInfo.getUserId());
            //System.debug('Current Profile: ' + UserInfo.getProfileId());
            
            User loggedInUser= YG_Utility.getLoggedInUserInfo(UserInfo.getUserId());
            
            YG_Community_Configuration__c systemIdConfig = new YG_Community_Configuration__c(name= 'ShippingAPISystemId',Text_1__c='AxkHnJ89');
            YG_Community_Configuration__c endpointConfig = new YG_Community_Configuration__c(name= 'Case Search',Text_1__c='https://library.yokogawa.com:8180/incident/casesearch');
            
            insert systemIdConfig;
            insert endpointConfig;
            
            Test.setMock(HttpCalloutMock.class, new YG_CaseAPIMockCallout());
            Test.startTest();
            
            HttpResponse  response = New HttpResponse();
            
            List<String> plantCodeList= new List<String>();
            for(Plant__c plantObj:plantList){
                plantCodeList.add(plantObj.Plant_Code__c);
            }
            
            
            YG_CaseAPI.callCaseAPIInfo();
                
                
            Test.stopTest();
        }
	}
}