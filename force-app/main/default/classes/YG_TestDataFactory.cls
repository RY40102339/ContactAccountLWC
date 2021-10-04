/*
*******************************************************************************************************
* (C) Copyright 2020 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Pravakar
* @version 1.0
* @created 20/07/2021
* @description 
* This is a data factory class.
*
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  
*/
public with sharing class YG_TestDataFactory {
    public static List<Account> createAccounts(Integer numAccts, String type, String parentAccId) {
        List<Account> lstAccounts = new List<Account>();
        for(Integer i=0;i<numAccts;i++) {
            Account objAcc = new Account(Name='TestAccount' + i, Type = type);
            if(parentAccId!=null && parentAccId!='') objAcc.ParentId = parentAccId;
            lstAccounts.add(objAcc);
        }
        return lstAccounts;
    }
    public static List<Contact> createContacts(Integer numCons, String accId, String portalUserRole, Boolean isActive) {
        List<Contact> lstContact = new List<Contact>();
        for(Integer i=0;i<numCons;i++) {
            Contact objCon = new Contact(LastName='TestConLast' + i, FirstName='TestConLast' + i, Email='TestConEmail'+ i+'@test.com', Portal_User_Roles__c=portalUserRole, Status__c=isActive);
            if(accId !=null && accId != '') objCon.accountid = accId;
            lstContact.add(objCon);
        }
        return lstContact;
    }
    public static List<AccountContactRelation> createAccountContactRelations (Integer nums, Id accId, Id conId) {
        List<AccountContactRelation> lstAccConRel = new List<AccountContactRelation>();
        for(Integer i=0;i<nums;i++) {
            AccountContactRelation objAccConRel = new AccountContactRelation(AccountId=accId, ContactId=conId);
            lstAccConRel.add(objAccConRel);
        }
        return lstAccConRel;
    }
    public static List<Category_Hierarchy__c> createCategoryHierarchies (Integer nums){
        List<Category_Hierarchy__c> lstCatHier=new List<Category_Hierarchy__c>();
        for(Integer i=0;i<nums;i++) {
            Category_Hierarchy__c objCatHier = new Category_Hierarchy__c(Name = 'Test Hirarchy'+i);
            lstCatHier.add(objCatHier);
        }
        return lstCatHier;
    }
    public static List<Category__c> createCategories (Integer nums, Id catHireId){
        List<Category__c> lstCategory=new List<Category__c>();
        for(Integer i=0;i<nums;i++) {
            Category__c objCategory = new Category__c(Name = 'Test Category'+i);
            if(catHireId!=null && catHireId!='') objCategory.Category_Hierarchy__c = catHireId;
            lstCategory.add(objCategory);
        }
        return lstCategory;
    }
    public static List<Product2> createProducts (Integer nums){
        List<Product2> lstProduct=new List<Product2>();
        for(Integer i=0;i<nums;i++) {
            Product2 objProduct = new Product2(Name = 'Test Category'+i);
            lstProduct.add(objProduct);
        }
        return lstProduct;
    }
    public static List<Asset> createAssets (Integer nums, Id ProdId, Id AccId, Id ConId){
        List<Asset> lstAsset=new List<Asset>();
        for(Integer i=0;i<nums;i++) {
            Asset objAsset = new Asset(Name = 'Test Asset'+i, Product2Id=ProdId, AccountId=AccId, ContactId=ConId);
            lstAsset.add(objAsset);
        }
        return lstAsset;
    }
    public static List<Customer_Asset__c> createCustomerAssets (Integer nums, Id assetId, Id ContractId){
        List<Customer_Asset__c> lstCustomAsset=new List<Customer_Asset__c>();
        for(Integer i=0;i<nums;i++) {
            Customer_Asset__c objCustomAsset = new Customer_Asset__c(Asset__c=assetId, Contact__c=ContractId);
            lstCustomAsset.add(objCustomAsset);
        }
        return lstCustomAsset;
    }
    public static List<ServiceContract> createServiceContracts (Integer nums, Id accId){
        List<ServiceContract> lstServContract=new List<ServiceContract>();
        for(Integer i=0;i<nums;i++) {
            ServiceContract objServContract = new ServiceContract(Name='Test Service'+i, AccountId=accId);
            lstServContract.add(objServContract);
        }
        return lstServContract;
    }
    public static List<Entitlement> createEntitlements (Integer nums, Id accId){
        List<Entitlement> lstEntitlement=new List<Entitlement>();
        for(Integer i=0;i<nums;i++) {
            Entitlement objEntitlement = new Entitlement(Name='Test Entitlement'+i, AccountId=accId);
            lstEntitlement.add(objEntitlement);
        }
        return lstEntitlement;
    }
    public static List<Case> createCases (Integer nums, Id accId,Id conId, String typ, String stat, String reas, String prog, Date createdDate){
        List<Case> lstCase=new List<Case>();
        for(Integer i=0;i<nums;i++) {
            Case objCase = new Case(AccountId=accId, ContactId=conId, Type=typ, Status=stat, Reason=reas, Progress__c=prog, ServAir_Created_Date__c = createdDate);
            lstCase.add(objCase);
        }
        return lstCase;
    }
    public static List<User> createUsers (Integer nums, Id profId){
        List<User> lstUser=new List<User>();
        for(Integer i=0;i<nums;i++) {
            User objUser = new User(FirstName='Test First'+i, LastName='Test Last'+i, ProfileID=profId, Alias='Test Alias'+i, isActive=true, Email='testEmail'+i+'@test.com');
            lstUser.add(objUser);
        }
        return lstUser;
    }
    public static User createUser (String firstName, String lastName, String alias, String email, String userName, Boolean isActive, Id profId, Id ConId, String langLocKey){
        User objUser = new User();
        objUser.FirstName = firstName;
        objUser.LastName = lastName;
        objUser.Email = email;
        objUser.Alias = alias;
        objUser.IsActive = isActive;
        objUser.profileId = profId;
        objUser.Username = userName;
        objUser.ContactId = ConId;
        objUser.LanguageLocaleKey=langLocKey;
        return objUser;
    }  
    public static Case createCase (Id accID, Id conId, Id prodId, String type, String reason, String status){
        Case objCase = new Case();
        objCase.AccountId = accID;
        objCase.ContactId = conId;
        objCase.productId = prodId;
        objCase.Type = type;
        objCase.Reason = reason;
        objCase.Status = status;
        return objCase;
    }  
    public static Product2 createProduct (String name,String modelCode, String langCode, Id catId){
        Product2 objProduct = new Product2();
        objProduct.Name = name;
        objProduct.Model_Code__c = modelCode;
        objProduct.Lang_Code__c = langCode;
        objProduct.Category__c = catId;
        return objProduct;
    }  
    public static Entitlement createEntitlement (String name,String type, Id accId, Id serviceId, Id assetId){
        Entitlement objEntitlement = new Entitlement();
        objEntitlement.Name = name;
        objEntitlement.Entitlement_type__c = type;
        objEntitlement.AccountId = accId;
        objEntitlement.ServiceContractId = serviceId; 
        objEntitlement.AssetId = assetId; 
        return objEntitlement;
    } 
    public static ServiceContract createServiceContract (String name,String conType, Id accId, String conNumber, String salesMangName, String contCategory, Date startDate, Date endDate){
        ServiceContract objServCon = new ServiceContract();
        objServCon.Name = name;
        objServCon.AccountId = accId;
        objServCon.Contract_No__c = conNumber;
        objServCon.Contract_Type__c = conType;            
        objServCon.YG_Sales_Manager_Name__c = salesMangName;
        objServCon.Contract_categories__c = contCategory;
        objServCon.StartDate = startDate;
        objServCon.EndDate = endDate;
        return objServCon;
    } 
    public static Asset createAsset (String name,String slNo, Id accId, String msCode, String status, String langCode, Id prodId, Id conId, Id plantAccId){
        Asset objAsset=new Asset();
        objAsset.Name = name;
        objAsset.Product2Id = prodId;
        objAsset.AccountId = accId;
        objAsset.ContactId = conId;
        objAsset.SerialNumber = slNo;
      //  objAsset.PlantAccount__c = plantAccId;
       // objAsset.Project__c = projectId;
        objAsset.MS_Code__c = msCode;
        objAsset.Status = status;
        objAsset.Lang_Code__c=langCode;
        return objAsset;
    }  
    public static Category__c createCategory (String name, String catType, String langCode, Id catHierId){
        Category__c objCategory = new Category__c();
        objCategory.Name=name;
        objCategory.Category_Hierarchy__c = catHierId;
        objCategory.Category_Type__c = catType;
        objCategory.Language_Code__c = langCode;
        return objCategory;
    }
    public static Category_Hierarchy__c createCategoryHire (String catCode, Integer catLevel, Integer disSeq, Id catHireId, String upperCatCode){
        Category_Hierarchy__c objCatHire = new Category_Hierarchy__c();
        objCatHire.Category_Code__c= catCode;
        objCatHire.Category_Level__c = catLevel;
        objCatHire.Display_Sequence__c = disSeq;
        objCatHire.Category_Hierarchy__c = catHireId;
        objCatHire.Upper_Category_Code__c=upperCatCode;
        return objCatHire;
    }
    public static Project__c createProject (Id accId, String pojCode){
        Project__c objProj=new Project__c();
        objProj.Account__c = accId;
        objProj.Project_Code__c = pojCode;
        return objProj;
    }
    public static WorkOrder createWorkOrder (string status, string WOrderOrigin){
        WorkOrder WO= new WorkOrder();
        WO.Status=status;
        WO.Work_Order_Origin__c=WOrderOrigin;
        return WO;
    }
}