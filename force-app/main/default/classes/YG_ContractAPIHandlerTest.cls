/********************************************************************************************************
* (C) Copyright 2020 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Vinod A
* @version 1.0
* @created 22/07/2020
* @description 
* This test class for YG_ContractAPIHandler apex class.
*
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  04/21/2021 			Kavya 					Removed Plant__c Object and replaced with Account Object also removed Customer_Plant__c Object and replaced with AccountContactRelation Object.
*												Removed Plant__c(Plant) Lookup field from Asset and newly added PlantAccount__c(Account) Lookup field in Asset Object.
*
*/

@isTest
public class YG_ContractAPIHandlerTest {
    
    @testSetup static void testDataSetup() {
        
    }
    
    @isTest static void contractTestMethod() {
        
        //Inserting test account record
        Account acc = new account();
        acc.name='XYZ Account';   
        acc.AccountNumber = '200086397';
          acc.Type = 'Customer';
        //acc.DUNS_Number__c=102224533; 
        insert acc; 
        
        //Inserting test contact record
        Contact con = new Contact();   
        con.FirstName='User';
        con.LastName='CVX AU';
        con.Email='cvxauuser011@chevron.com';
        con.accountid=acc.id; 
        insert con;
        
        //Inserting test plant record
        /*List<Plant__c> plantList=new List<Plant__c>();
        Plant__c plant1=new Plant__c();
        plant1.Name = 'TestPlant';
        plant1.Account__c = acc.Id;  
        plant1.Plant_Code__c = '300000123';
        plant1.Lang_Code__c = 'EN';
        plantList.add(plant1);
        insert plant1;*/
        
        //Inserting test plant record
        List<Account> plantList=new List<Account>();
        Account plant1=new Account();
        plant1.Name = 'TestPlant';
        plant1.ParentId = acc.Id;  
        plant1.AccountNumber = '300000123';
        plant1.Type = 'Plant';
        plantList.add(plant1);
        insert plant1;
        
        List<String> pltList=new List<String>();
        /*for(Plant__c plt: plantList){
            pltList.add(plt.Plant_Code__c);
        }*/
        for(Account plt: plantList){
            pltList.add(plt.AccountNumber);
        }
        
        //Inserting test customer plant record
       /* List<Customer_Plant__c> cusPlantList=new List<Customer_Plant__c>();
        Customer_Plant__c cusPlant1=new Customer_Plant__c();
        cusPlant1.Contact__c = con.Id;
        cusPlant1.Plant__c = plant1.Id;
        cusPlant1.Status__c = 'Approved site access';
        cusPlantList.add(cusPlant1);
        insert cusPlant1;*/
        
        //Inserting test customer plant record
        List<AccountContactRelation> cusPlantList=new List<AccountContactRelation>();
        AccountContactRelation cusPlant1=new AccountContactRelation();
        cusPlant1.ContactId = con.Id;
        cusPlant1.AccountId = plant1.Id;
        cusPlant1.Status__c = 'Approved site access';
        cusPlantList.add(cusPlant1);
        insert cusPlant1;
        
        Asset ass=new Asset();
        ass.Name = '0A74B68F-D39C-11E9-94D1-0AE1E5432EEC';
        ass.AccountId = acc.Id;
        ass.PlantAccount__c = plant1.Id;
        insert ass;
        
        ServiceContract servCont=new ServiceContract();
        servCont.Name = '라이온코리아(인천) N(세제)(통합) Plant LION Co. Korea (Incheon)';
        servCont.Contract_No__c = 'YKO-L00078-2001-01';
        servCont.AccountId = acc.Id;
        servCont.StartDate = date.today()-30;
        servCont.EndDate = date.today()+90;
        Insert servCont;
        
        //Insert custom setting records
        List<YG_Community_Configuration__c> configList = new List<YG_Community_Configuration__c>();
        YG_Community_Configuration__c contractApi = new YG_Community_Configuration__c();
        contractApi.Name = 'ContractAPIEndpointUrl';
        contractApi.Text_1__c = 'https://library.yokogawa.com:8180/contract/search';
        configList.add(contractApi);
        
        YG_Community_Configuration__c contractItemApi = new YG_Community_Configuration__c();
        contractItemApi.Name = 'ContractItemAPIEndpointUrl';
        contractItemApi.Text_1__c = 'https://library.yokogawa.com:8180/contractitem/search';
        configList.add(contractItemApi);
        
        YG_Community_Configuration__c contProdApi = new YG_Community_Configuration__c();
        contProdApi.Name = 'ContractProductAPIEndpointUrl';
        contProdApi.Text_1__c = 'https://library.yokogawa.com:8180/contractproduct/search';
        configList.add(contProdApi);
        
        YG_Community_Configuration__c contMainteApi = new YG_Community_Configuration__c();
        contMainteApi.Name = 'ContractMainteCrmAPIEndpointUrl';
        contMainteApi.Text_1__c = 'https://library.yokogawa.com:8180/contractmaintecrm/search';
        configList.add(contMainteApi);
        
        YG_Community_Configuration__c inspectApi = new YG_Community_Configuration__c();
        inspectApi.Name = 'ContractInspectionAPIEndpointUrl';
        inspectApi.Text_1__c = 'https://library.yokogawa.com:8180/inspect/search';
        configList.add(inspectApi);
        
        YG_Community_Configuration__c systemid=new YG_Community_Configuration__c();
        systemid.Name = 'ShippingAPISystemId';
        systemid.Text_1__c = 'F5cJnZkn';
        configList.add(systemid);
        
        YG_Community_Configuration__c contSync=new YG_Community_Configuration__c();
        contSync.Name = 'Contract API Sync Duration in Days';
        contSync.Text_1__c = '1';
        configList.add(contSync);
        
        YG_Community_Configuration__c selfReg=new YG_Community_Configuration__c();
        selfReg.Name = 'YGSelfRegisterAccountId';
        selfReg.Text_1__c = '001p000000tzRDXAA2';
        configList.add(selfReg);
        
        insert configList;
        
        Profile profile = [Select Id From Profile Where Name='Customer Portal User'];
        User user = new User(Alias = 'comm', Email='yg.qa167@gmail.com',ContactId=con.id,
                             EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                             LocaleSidKey='en_US', ProfileId = profile.Id,
                             TimeZoneSidKey='America/Los_Angeles', UserName='yg.qa167@gmail.com');
        insert user;
        System.RunAs(user){
            
            Test.startTest();
            
            Boolean resValue = YG_ContractAPIHandler.checkContractSync();
            Map<String, Id> contractMap = new Map<String, Id>();
            //System.debug('contractMap::::'+contractMap);
            
            List<YG_ContractAPIHandler.ContractAPI> responseList=new List<YG_ContractAPIHandler.ContractAPI>();
            //Calling mock response
            Test.setMock(HttpCalloutMock.class, new YG_ContractAPIHandlerMockCallout());
            contractMap = YG_ContractAPIHandler.getContractAPI();
            System.debug('contractMap::'+contractMap);
            Id contId = contractMap.get('YKO-L00078-2001-01');
            Map<String, Id> inputContProd=new Map<String, Id>();
            String contNo = servCont.Contract_No__c;
            Id contractId = servCont.Id;
            inputContProd.put(contNo,contractId);
            System.debug('inputContProd::'+inputContProd);
            System.debug('pltList::'+pltList);
            
            //For the Negative test case
            Boolean result = YG_ContractAPIHandler.getContractProduct();
            System.debug('result::'+result);
            Map<String, Map<String, Id>> servMenuMap=new Map<String, Map<String, Id>>();
            servMenuMap = YG_ContractAPIHandler.getContractServMenu('YEA-L00316-1806-01');
            
            Test.stopTest();
        }
        
    }
    
    @isTest static void contractTestMethod2() {
        
        //Inserting test account record
        Account acc = new account();
        acc.name='XYZ Account';   
        acc.AccountNumber = '200086397';
         acc.Type = 'Customer';
        //acc.DUNS_Number__c=102224533; 
        insert acc; 
        
        //Inserting test contact record
        Contact con = new Contact();   
        con.FirstName='User';
        con.LastName='CVX AU';
        con.Email='cvxauuser011@chevron.com';
        con.accountid=acc.id; 
        insert con;
        
        //Inserting test plant record
       /* List<Plant__c> plantList=new List<Plant__c>();
        Plant__c plant1=new Plant__c();
        plant1.Name = 'TestPlant';
        plant1.Account__c = acc.Id;  
        plant1.Plant_Code__c = '300000123';
        plant1.Lang_Code__c = 'EN';
        plantList.add(plant1);
        insert plant1;*/
        
        //Inserting test plant record
       List<Account> plantList=new List<Account>();
        Account plant1=new Account();
        plant1.Name = 'TestPlant';
        plant1.ParentId = acc.Id;  
        plant1.AccountNumber = '300000123';
        plant1.Type = 'Plant';
        plantList.add(plant1);
        insert plant1;
        
        List<String> pltList=new List<String>();
        /*for(Plant__c plt: plantList){
            pltList.add(plt.Plant_Code__c);
        }*/
        for(Account plt: plantList){
            pltList.add(plt.AccountNumber);
        }
        
        //Inserting test customer plant record
        /*List<Customer_Plant__c> cusPlantList=new List<Customer_Plant__c>();
        Customer_Plant__c cusPlant1=new Customer_Plant__c();
        cusPlant1.Contact__c = con.Id;
        cusPlant1.Plant__c = plant1.Id;
        cusPlant1.Status__c = 'Approved site access';
        cusPlantList.add(cusPlant1);
        insert cusPlant1;*/
        
        //Inserting test customer plant record
        List<AccountContactRelation> cusPlantList=new List<AccountContactRelation>();
        AccountContactRelation cusPlant1=new AccountContactRelation();
        cusPlant1.ContactId = con.Id;
        cusPlant1.AccountId = plant1.Id;
        cusPlant1.Status__c = 'Approved site access';
        cusPlantList.add(cusPlant1);
        insert cusPlant1;
        
        Asset ass=new Asset();
        ass.Name = '0A74B68F-D39C-11E9-94D1-0AE1E5432EEC';
        ass.AccountId = acc.Id;
        ass.PlantAccount__c = plant1.Id;
        insert ass;
        
        ServiceContract servCont=new ServiceContract();
        servCont.Name = '라이온코리아(인천) N(세제)(통합) Plant LION Co. Korea (Incheon)';
        servCont.Contract_No__c = 'YKO-L00078-2001-01';
        servCont.AccountId = acc.Id;
        servCont.StartDate = date.today()-30;
        servCont.EndDate = date.today()+90;
        Insert servCont;
        
        //Insert custom setting records
        List<YG_Community_Configuration__c> configList = new List<YG_Community_Configuration__c>();
        YG_Community_Configuration__c contractApi = new YG_Community_Configuration__c();
        contractApi.Name = 'ContractAPIEndpointUrl';
        contractApi.Text_1__c = 'https://library.yokogawa.com:8180/contract/search';
        configList.add(contractApi);
        
        YG_Community_Configuration__c contractItemApi = new YG_Community_Configuration__c();
        contractItemApi.Name = 'ContractItemAPIEndpointUrl';
        contractItemApi.Text_1__c = 'https://library.yokogawa.com:8180/contractitem/search';
        configList.add(contractItemApi);
        
        YG_Community_Configuration__c contProdApi = new YG_Community_Configuration__c();
        contProdApi.Name = 'ContractProductAPIEndpointUrl';
        contProdApi.Text_1__c = 'https://library.yokogawa.com:8180/contractproduct/search';
        configList.add(contProdApi);
        
        YG_Community_Configuration__c contMainteApi = new YG_Community_Configuration__c();
        contMainteApi.Name = 'ContractMainteCrmAPIEndpointUrl';
        contMainteApi.Text_1__c = 'https://library.yokogawa.com:8180/contractmaintecrm/search';
        configList.add(contMainteApi);
        
        YG_Community_Configuration__c inspectApi = new YG_Community_Configuration__c();
        inspectApi.Name = 'ContractInspectionAPIEndpointUrl';
        inspectApi.Text_1__c = 'https://library.yokogawa.com:8180/inspect/search';
        configList.add(inspectApi);
        
        YG_Community_Configuration__c systemid=new YG_Community_Configuration__c();
        systemid.Name = 'ShippingAPISystemId';
        systemid.Text_1__c = 'F5cJnZkn';
        configList.add(systemid);
        
        YG_Community_Configuration__c contSync=new YG_Community_Configuration__c();
        contSync.Name = 'Contract API Sync Duration in Days';
        contSync.Text_1__c = '1';
        configList.add(contSync);
        
        YG_Community_Configuration__c selfReg=new YG_Community_Configuration__c();
        selfReg.Name = 'YGSelfRegisterAccountId';
        selfReg.Text_1__c = '001p000000tzRDXAA2';
        configList.add(selfReg);
        
        insert configList;
        
        Profile profile = [Select Id From Profile Where Name='Customer Portal User'];
        User user = new User(Alias = 'comm', Email='yg.qa167@gmail.com',ContactId=con.id,
                             EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                             LocaleSidKey='en_US', ProfileId = profile.Id,
                             TimeZoneSidKey='America/Los_Angeles', UserName='yg.qa167@gmail.com');
        insert user;
        System.RunAs(user){
            
            Test.startTest();
            //Calling mock response
            Test.setMock(HttpCalloutMock.class, new YG_ContractAPIHandlerMockCallout());
            Boolean result = YG_ContractAPIHandler.getContractProduct();
            System.assertEquals(true, result);
            Map<String, Map<String, Id>> servMenuMap=new Map<String, Map<String, Id>>();

            
            Test.stopTest();
        }
        
    }
    
    @isTest static void contractTestMethod3() {
        //Inserting test account record
        Account acc = new account();
        acc.name='XYZ Account';   
        acc.AccountNumber = '200086397';
        acc.Type = 'Customer';
        //acc.DUNS_Number__c=102224533; 
        insert acc; 
        
        //Inserting test contact record
        Contact con = new Contact();   
        con.FirstName='User';
        con.LastName='CVX AU';
        con.Email='cvxauuser011@chevron.com';
        con.accountid=acc.id; 
        insert con;
        
        //Inserting test plant record
       /* List<Plant__c> plantList=new List<Plant__c>();
        Plant__c plant1=new Plant__c();
        plant1.Name = 'TestPlant';
        plant1.Account__c = acc.Id;  
        plant1.Plant_Code__c = '300000123';
        plant1.Lang_Code__c = 'EN';
        plantList.add(plant1);
        insert plant1;*/
        
        //Inserting test plant record
       List<Account> plantList=new List<Account>();
        Account plant1=new Account();
        plant1.Name = 'TestPlant';
        plant1.ParentId = acc.Id;  
        plant1.AccountNumber = '300000123';
        plant1.Type = 'Plant';
        plantList.add(plant1);
        insert plant1;
        
        List<String> pltList=new List<String>();
        /*for(Plant__c plt: plantList){
            pltList.add(plt.Plant_Code__c);
        }*/
        for(Account plt: plantList){
            pltList.add(plt.AccountNumber);
        }
        
        //Inserting test customer plant record
       /* List<Customer_Plant__c> cusPlantList=new List<Customer_Plant__c>();
        Customer_Plant__c cusPlant1=new Customer_Plant__c();
        cusPlant1.Contact__c = con.Id;
        cusPlant1.Plant__c = plant1.Id;
        cusPlant1.Status__c = 'Approved site access';
        cusPlantList.add(cusPlant1);
        insert cusPlant1;*/
        
        //Inserting test customer plant record
        List<AccountContactRelation> cusPlantList=new List<AccountContactRelation>();
        AccountContactRelation cusPlant1=new AccountContactRelation();
        cusPlant1.ContactId = con.Id;
        cusPlant1.AccountId = plant1.Id;
        cusPlant1.Status__c = 'Approved site access';
        cusPlantList.add(cusPlant1);
        insert cusPlant1;
        
        Asset ass=new Asset();
        ass.Name = '0A74B68F-D39C-11E9-94D1-0AE1E5432EEC';
        ass.AccountId = acc.Id;
        ass.PlantAccount__c = plant1.Id;
        insert ass;
        
        ServiceContract servCont=new ServiceContract();
        servCont.Name = '라이온코리아(인천) N(세제)(통합) Plant LION Co. Korea (Incheon)';
        servCont.Contract_No__c = 'YKO-L00078-2001-01';
        servCont.AccountId = acc.Id;
        servCont.StartDate = date.today()-30;
        servCont.EndDate = date.today()+90;
        Insert servCont;
        
        //Insert custom setting records
        List<YG_Community_Configuration__c> configList = new List<YG_Community_Configuration__c>();
        
        YG_Community_Configuration__c contMainteApi = new YG_Community_Configuration__c();
        contMainteApi.Name = 'ContractMainteCrmAPIEndpointUrl';
        contMainteApi.Text_1__c = 'https://library.yokogawa.com:8180/contractmaintecrm/search';
        configList.add(contMainteApi);
        
        YG_Community_Configuration__c inspectApi = new YG_Community_Configuration__c();
        inspectApi.Name = 'ContractInspectionAPIEndpointUrl';
        inspectApi.Text_1__c = 'https://library.yokogawa.com:8180/inspect/search';
        configList.add(inspectApi);
        
        YG_Community_Configuration__c systemid=new YG_Community_Configuration__c();
        systemid.Name = 'ShippingAPISystemId';
        systemid.Text_1__c = 'F5cJnZkn';
        configList.add(systemid);
        
        insert configList;
        
        Profile profile = [Select Id From Profile Where Name='Customer Portal User'];
        User user = new User(Alias = 'comm', Email='yg.qa167@gmail.com',ContactId=con.id,
                             EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                             LocaleSidKey='en_US', ProfileId = profile.Id,
                             TimeZoneSidKey='America/Los_Angeles', UserName='yg.qa167@gmail.com');
        insert user;
        System.RunAs(user){
            
            Test.startTest();
            //Calling mock response
            Test.setMock(HttpCalloutMock.class, new YG_ContractAPIHandlerMockCallout());
            Map<String, Map<String, Id>> servMenuMap=new Map<String, Map<String, Id>>();
            servMenuMap = YG_ContractAPIHandler.getContractServMenu('YEA-L00316-1806-01');
            Map<String, Id> entitleResMap = new Map<String, Id>();
            String lcaNo = null;
            boolean resultVal = false;
            for(String lca: servMenuMap.keySet()){
                lcaNo = lca;
                entitleResMap =  servMenuMap.get(lca);
            }
            System.assertEquals('YEA-L00316-1806-01', lcaNo);
            //Negative test case
            Boolean res = YG_ContractAPIHandler.getInspectionDetails(servMenuMap);
            System.debug('res::'+res);
            //resultMap::{YEA-L00316-1806-01={155C7BDB-9F03-42E5-B0F9-AD018B696759=550p00000009E7fAAE, A41A473C-0667-40D0-8645-50B2F42FEA0F=550p00000009E7gAAE, C80F05AB-9A6A-401A-811A-D12950CA3DEC=550p00000009E7hAAE}}
            Test.stopTest();
        }
    }
    
    @isTest static void contractTestMethod4() {
        //Inserting test account record
        Account acc = new account();
        acc.name='XYZ Account';   
        acc.AccountNumber = '200086397';
        acc.Type = 'Customer';
        //acc.DUNS_Number__c=102224533; 
        insert acc; 
        
        //Inserting test contact record
        Contact con = new Contact();   
        con.FirstName='User';
        con.LastName='CVX AU';
        con.Email='cvxauuser011@chevron.com';
        con.accountid=acc.id; 
        insert con;
        
        //Inserting test plant record
       /* List<Plant__c> plantList=new List<Plant__c>();
        Plant__c plant1=new Plant__c();
        plant1.Name = 'TestPlant';
        plant1.Account__c = acc.Id;  
        plant1.Plant_Code__c = '300000123';
        plant1.Lang_Code__c = 'EN';
        plantList.add(plant1);
        insert plant1;*/
        
        //Inserting test plant record
        List<Account> plantList=new List<Account>();
        Account plant1=new Account();
        plant1.Name = 'TestPlant';
        plant1.ParentId = acc.Id;  
        plant1.AccountNumber = '300000123';
         plant1.Type = 'Plant';
        plantList.add(plant1);
        insert plant1;
        
        List<String> pltList=new List<String>();
       /* for(Plant__c plt: plantList){
            pltList.add(plt.Plant_Code__c);
        }*/
        for(Account plt: plantList){
            pltList.add(plt.AccountNumber);
        }
        
        //Inserting test customer plant record
        /*List<Customer_Plant__c> cusPlantList=new List<Customer_Plant__c>();
        Customer_Plant__c cusPlant1=new Customer_Plant__c();
        cusPlant1.Contact__c = con.Id;
        cusPlant1.Plant__c = plant1.Id;
        cusPlant1.Status__c = 'Approved site access';
        cusPlantList.add(cusPlant1);
        insert cusPlant1;*/
        
         //Inserting test customer plant record
        List<AccountContactRelation> cusPlantList=new List<AccountContactRelation>();
        AccountContactRelation cusPlant1=new AccountContactRelation();
        cusPlant1.ContactId = con.Id;
        cusPlant1.AccountId = plant1.Id;
        cusPlant1.Status__c = 'Approved site access';
        cusPlantList.add(cusPlant1);
        insert cusPlant1;
        
        Asset ass=new Asset();
        ass.Name = '0A74B68F-D39C-11E9-94D1-0AE1E5432EEC';
        ass.AccountId = acc.Id;
        ass.PlantAccount__c = plant1.Id;
        insert ass;
        
        ServiceContract servCont=new ServiceContract();
        servCont.Name = '라이온코리아(인천) N(세제)(통합) Plant LION Co. Korea (Incheon)';
        servCont.Contract_No__c = 'YKO-L00078-2001-01';
        servCont.AccountId = acc.Id;
        servCont.StartDate = date.today()-30;
        servCont.EndDate = date.today()+90;
        Insert servCont;
        
        //Insert custom setting records
        List<YG_Community_Configuration__c> configList = new List<YG_Community_Configuration__c>();
        
        YG_Community_Configuration__c inspectApi = new YG_Community_Configuration__c();
        inspectApi.Name = 'ContractInspectionAPIEndpointUrl';
        inspectApi.Text_1__c = 'https://library.yokogawa.com:8180/inspect/search';
        configList.add(inspectApi);
        
        YG_Community_Configuration__c systemid=new YG_Community_Configuration__c();
        systemid.Name = 'ShippingAPISystemId';
        systemid.Text_1__c = 'F5cJnZkn';
        configList.add(systemid);
        
        insert configList;
        
        Profile profile = [Select Id From Profile Where Name='Customer Portal User'];
        User user = new User(Alias = 'comm', Email='yg.qa167@gmail.com',ContactId=con.id,
                             EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                             LocaleSidKey='en_US', ProfileId = profile.Id,
                             TimeZoneSidKey='America/Los_Angeles', UserName='yg.qa167@gmail.com');
        insert user;
        System.RunAs(user){
            
            Test.startTest();
            //Calling mock response
            Test.setMock(HttpCalloutMock.class, new YG_ContractAPIHandlerMockCallout());
            Map<String, Map<String, Id>> inspectMap=new Map<String, Map<String, Id>>();
            String lca = 'YEA-L00316-1806-01';
            Map<String, Id> mapValues=new Map<String, Id>();
            mapValues.put('155C7BDB-9F03-42E5-B0F9-AD018B696759', '550p00000009E7fAAE');
            mapValues.put('A41A473C-0667-40D0-8645-50B2F42FEA0F', '550p00000009E7gAAE');
            mapValues.put('C80F05AB-9A6A-401A-811A-D12950CA3DEC', '550p00000009E7hAAE');
            Boolean res = YG_ContractAPIHandler.getInspectionDetails(inspectMap);
            System.assertEquals(true, res);
            Test.stopTest();
        }
    }
    
     @isTest static void contractTestMethod5() {
        //Inserting test account record
        Account acc = new account();
        acc.name='XYZ Account';   
        acc.AccountNumber = '200086397';
        acc.Type = 'Customer';
        //acc.DUNS_Number__c=102224533; 
        insert acc; 
        
        //Inserting test contact record
        Contact con = new Contact();   
        con.FirstName='User';
        con.LastName='CVX AU';
        con.Email='cvxauuser011@chevron.com';
        con.accountid=acc.id; 
        insert con;
        
        /*//Inserting test plant record
        List<Plant__c> plantList=new List<Plant__c>();
        Plant__c plant1=new Plant__c();
        plant1.Name = 'TestPlant';
        plant1.Account__c = acc.Id;  
        plant1.Plant_Code__c = '300000123';
        plant1.Lang_Code__c = 'EN';
        plantList.add(plant1);
        insert plant1;*/
        
         //Inserting test plant record
        List<Account> plantList=new List<Account>();
        Account plant1=new Account();
        plant1.Name = 'TestPlant';
        plant1.ParentId = acc.Id;  
        plant1.AccountNumber = '300000123';
         plant1.Type = 'Plant';
        plantList.add(plant1);
        insert plant1;
         
        List<String> pltList=new List<String>();
       /* for(Plant__c plt: plantList){
            pltList.add(plt.Plant_Code__c);
        }*/
         for(Account plt: plantList){
            pltList.add(plt.AccountNumber);
        }
        
       /* //Inserting test customer plant record
        List<Customer_Plant__c> cusPlantList=new List<Customer_Plant__c>();
        Customer_Plant__c cusPlant1=new Customer_Plant__c();
        cusPlant1.Contact__c = con.Id;
        cusPlant1.Plant__c = plant1.Id;
        cusPlant1.Status__c = 'Approved site access';
        cusPlantList.add(cusPlant1);
        insert cusPlant1;*/
         
         //Inserting test customer plant record
        List<AccountContactRelation> cusPlantList=new List<AccountContactRelation>();
        AccountContactRelation cusPlant1=new AccountContactRelation();
        cusPlant1.ContactId = con.Id;
        cusPlant1.AccountId = plant1.Id;
        cusPlant1.Status__c = 'Approved site access';
        cusPlantList.add(cusPlant1);
        insert cusPlant1;
        
        Asset ass=new Asset();
        ass.Name = '0A74B68F-D39C-11E9-94D1-0AE1E5432EEC';
        ass.AccountId = acc.Id;
        ass.PlantAccount__c = plant1.Id;
        insert ass;
        
        ServiceContract servCont=new ServiceContract();
        servCont.Name = '라이온코리아(인천) N(세제)(통합) Plant LION Co. Korea (Incheon)';
        servCont.Contract_No__c = 'YKO-L00078-2001-01';
        servCont.AccountId = acc.Id;
        servCont.StartDate = date.today()-30;
        servCont.EndDate = date.today()+90;
        Insert servCont;
        
        //Insert custom setting records
        List<YG_Community_Configuration__c> configList = new List<YG_Community_Configuration__c>();
        YG_Community_Configuration__c contractApi = new YG_Community_Configuration__c();
        contractApi.Name = 'ContractAPIEndpointUrl';
        contractApi.Text_1__c = 'https://library.yokogawa.com:8180/contract/search';
        configList.add(contractApi);
        
        YG_Community_Configuration__c contractItemApi = new YG_Community_Configuration__c();
        contractItemApi.Name = 'ContractItemAPIEndpointUrl';
        contractItemApi.Text_1__c = 'https://library.yokogawa.com:8180/contractitem/search';
        configList.add(contractItemApi);
        
        YG_Community_Configuration__c contProdApi = new YG_Community_Configuration__c();
        contProdApi.Name = 'ContractProductAPIEndpointUrl';
        contProdApi.Text_1__c = 'https://library.yokogawa.com:8180/contractproduct/search';
        configList.add(contProdApi);
        
        YG_Community_Configuration__c contMainteApi = new YG_Community_Configuration__c();
        contMainteApi.Name = 'ContractMainteCrmAPIEndpointUrl';
        contMainteApi.Text_1__c = 'https://library.yokogawa.com:8180/contractmaintecrm/search';
        configList.add(contMainteApi);
        
        YG_Community_Configuration__c inspectApi = new YG_Community_Configuration__c();
        inspectApi.Name = 'ContractInspectionAPIEndpointUrl';
        inspectApi.Text_1__c = 'https://library.yokogawa.com:8180/inspect/search';
        configList.add(inspectApi);
        
        YG_Community_Configuration__c systemid=new YG_Community_Configuration__c();
        systemid.Name = 'ShippingAPISystemId';
        systemid.Text_1__c = 'F5cJnZkn';
        configList.add(systemid);
        
        YG_Community_Configuration__c contSync=new YG_Community_Configuration__c();
        contSync.Name = 'Contract API Sync Duration in Days';
        contSync.Text_1__c = '1';
        configList.add(contSync);
        
        YG_Community_Configuration__c selfReg=new YG_Community_Configuration__c();
        selfReg.Name = 'YGSelfRegisterAccountId';
        selfReg.Text_1__c = '001p000000tzRDXAA2';
        configList.add(selfReg);
        
        insert configList;
        
        Profile profile = [Select Id From Profile Where Name='Customer Portal User'];
        User user = new User(Alias = 'comm', Email='yg.qa167@gmail.com',ContactId=con.id,
                             EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                             LocaleSidKey='en_US', ProfileId = profile.Id,
                             TimeZoneSidKey='America/Los_Angeles', UserName='yg.qa167@gmail.com');
        insert user;
        System.RunAs(user){
            
            Test.startTest();
            //Without Calling mock response
            Map<String, Id> contractMap = new Map<String, Id>();
             contractMap = YG_ContractAPIHandler.getContractAPI();
            System.assertEquals(0, contractMap.size());
            Test.stopTest();
        }
    }
    
}