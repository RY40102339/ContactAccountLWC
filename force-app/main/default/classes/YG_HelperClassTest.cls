/********************************************************************************************************
* (C) Copyright 2020 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Vinod A
* @version 1.0
* @created 02/06/2020
* @description 
* This test class for YG_HelperClass apex class.
*
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  10/13/2020			Selvaraj T				Commented the phase date fields in product object  
*  04/21/2021			Kavya					Removed Plant__c Object and replaced with Account Object also removed Customer_Plant__c Object and replaced with AccountContactRelation Object.
*												Removed Plant__c(Plant) Lookup field from Asset and Project Objects and newly added PlantAccount__c(Account) Lookup field in Asset  and Project Object.

*/
@isTest
public class YG_HelperClassTest {
    
    @isTest static void ygHelperTestMethod2() {
        
        //Inserting test account record
        Account acc = new account();
        acc.name='XYZ Account';   
        acc.Type = 'Customer';
        insert acc;    
        
        //Inserting test contact record
        Contact con = new Contact();   
        con.FirstName='User';
        con.LastName='CVX AU';
        con.Email='cvxauuser011@chevron.com';
        con.accountid=acc.id; 
        con.Status__c = true;
        insert con;
        
        //Inserting test portal user record
        UserRole user_Role = [SELECT Id FROM UserRole WHERE DeveloperName = 'Customer_Portal_Developer' LIMIT 1];
        Profile profile = [Select Id From Profile Where Name='Customer Portal User'];
        
        User user = new User(Alias = 'comm', Email='yg.qa167@gmail.com',ContactId=con.id,
                             EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                             LocaleSidKey='en_US', ProfileId = profile.Id,
                             TimeZoneSidKey='America/Los_Angeles', UserName='yg.qa167@gmail.com');
        
        insert user;
        
        //Inserting test plant record
        /*List<Plant__c> plantList=new List<Plant__c>();
        Plant__c plant1=new Plant__c();
        plant1.Name = 'TestPlant';
        plant1.Account__c = acc.Id;  
        plant1.Plant_Code__c = '300000142';
        plant1.Lang_Code__c = 'EN';
        plant1.Plant_Name__c = 'TestPlant';
        plantList.add(plant1);
        insert plantList;*/
        List<Account> plantList=new List<Account>();
        Account plant1=new Account();
        plant1.Name = 'TestPlant';
        plant1.ParentId = acc.Id;  
        plant1.AccountNumber = '300000142';
        plant1.Type = 'Plant';
        plantList.add(plant1);
        insert plantList;
        
        //Inserting test customer plant record
        /*List<Customer_Plant__c> cusPlantList=new List<Customer_Plant__c>();
        Customer_Plant__c cusPlant1=new Customer_Plant__c();
        cusPlant1.Contact__c = con.Id;
        cusPlant1.Plant__c = plant1.Id;
        cusPlant1.Status__c = 'Approved site access';
        cusPlantList.add(cusPlant1);
        insert cusPlantList;*/
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
        proj1.Account__c = acc.Id;
        proj1.PlantAccount__c = plant1.Id;
        proj1.Project_Code__c = 'VP700250';
        projectList.add(proj1);
        insert projectList;
        
         //Insert test Category Hierarchy record
        List<Category_Hierarchy__c> catHierListTop=new List<Category_Hierarchy__c>();
        Category_Hierarchy__c catHierTop1=new Category_Hierarchy__c(Category_Code__c = '10000000', Category_Level__c = 1, Display_Sequence__c = 500,
                                                                    Upper_Category_Code__c = NULL);
        catHierListTop.add(catHierTop1);
        
        Category_Hierarchy__c catHierL1=new Category_Hierarchy__c(Category_Code__c = '20000000', Category_Level__c = 1, Display_Sequence__c = 500, 
                                                                  Upper_Category_Code__c = NULL);
        catHierListTop.add(catHierL1);
        
        insert catHierListTop;
        
        List<Category_Hierarchy__c> catHierListTop2=new List<Category_Hierarchy__c>();
        Category_Hierarchy__c catHierTop2=new Category_Hierarchy__c(Category_Code__c = '11000000', Category_Level__c = 2, Display_Sequence__c = 500,
                                                                 Upper_Category_Code__c = '10000000', Category_Hierarchy__c = catHierTop1.id);
        catHierListTop2.add(catHierTop2);
        
        Category_Hierarchy__c catHierL21=new Category_Hierarchy__c(Category_Code__c = '21000000', Category_Level__c = 2, Display_Sequence__c = 500, 
                                                                   Upper_Category_Code__c = NULL, Category_Hierarchy__c = catHierL1.id);
        catHierListTop2.add(catHierL21); //Hardware 
        
        Category_Hierarchy__c catHierL22=new Category_Hierarchy__c(Category_Code__c = '22000000', Category_Level__c = 2, Display_Sequence__c = 500, 
                                                                   Upper_Category_Code__c = NULL, Category_Hierarchy__c = catHierL1.id);
        catHierListTop2.add(catHierL22); //software
        
        insert catHierListTop2;
        
        List<Category_Hierarchy__c> catHierListTop3=new List<Category_Hierarchy__c>();
        Category_Hierarchy__c catHierTop3=new Category_Hierarchy__c(Category_Code__c = '12000000', Category_Level__c = 3, Display_Sequence__c = 500,
                                                                 Upper_Category_Code__c = '11000000', Category_Hierarchy__c = catHierTop2.id);
        catHierListTop3.add(catHierTop3);
        
        insert catHierListTop3;
                
        //Insert test category record
        List<Category__c> catList=new List<Category__c>();
        Category__c catg1=new Category__c(Name = 'Field Instruments', Category_Hierarchy__c = catHierTop1.Id,
                                          Category_Type__c = 'Product', Language_Code__c = 'EN');
        catList.add(catg1);
        
        Category__c catg2=new Category__c(Name = 'Device Smart Communicators', Category_Hierarchy__c = catHierTop2.Id,
                                          Category_Type__c = 'Product', Language_Code__c = 'EN');
        catList.add(catg2);
        
        Category__c catg3=new Category__c(Name = 'Device Smart Communicators BT200', Category_Hierarchy__c = catHierTop3.Id,
                                          Category_Type__c = 'Product', Language_Code__c = 'EN');
        catList.add(catg3);
        
        Category__c catg4 = new Category__c(Name = 'Distributed Control Systems (DCS)', Category_Hierarchy__c = catHierL1.Id,
                                            Category_Type__c = 'System', Language_Code__c = 'EN');
        catList.add(catg4);
        
        Category__c catg5 = new Category__c(Name = 'Hardware', Category_Hierarchy__c = catHierL21.Id,
                                            Category_Type__c = 'System', Language_Code__c = 'EN');
        catList.add(catg5);
        
        Category__c catg6 = new Category__c(Name = 'Software', Category_Hierarchy__c = catHierL22.Id,
                                            Category_Type__c = 'System', Language_Code__c = 'EN');
        catList.add(catg6);
        
        insert catList;
        
        //Inserting test product record
        List<Product2> prodList=new List<Product2>();
        Product2 prod1=new Product2();
        prod1.Name = 'Device Smart Communicators BT200';
        prod1.Model_Code__c = 'BT200';
        prod1.Category__c = catg3.Id;
        //prod1.Production_Date__c = Date.newInstance(2014, 12, 17);
        prod1.Lang_Code__c = 'EN';
        prodList.add(prod1);
        
        Product2 prod2=new Product2();
        prod2.Name = 'DCS';
        prod2.Model_Code__c = 'AFV10D';
        prod2.Category__c = catg5.Id;
        //prod2.Production_Date__c = Date.newInstance(2014, 12, 17);
        prod2.Lang_Code__c = 'EN';
        prodList.add(prod2);       
        
        Insert prodList;    
        
        //Inserting test asset record
        List<Asset> assList=new List<Asset>();
        Asset ass1=new Asset();
        ass1.Name = 'FCS0111';
        ass1.Product2Id = prod2.Id;
        ass1.AccountId = acc.Id;
        ass1.ContactId = con.Id;
        ass1.PlantAccount__c = plant1.Id;
        ass1.Project__c = proj1.Id;
        ass1.Lang_Code__c = 'EN';
        assList.add(ass1);
        
        Asset ass2=new Asset();
        ass2.Name = 'Test123';
        ass2.Product2Id = prod1.Id;
        ass2.AccountId = acc.Id;
        ass2.ContactId = con.Id;
        ass2.PlantAccount__c = plant1.Id;
        ass2.Lang_Code__c = 'EN';
        ass2.SerialNumber = 'Test123';
        assList.add(ass2);
        
        Insert assList;
        
        system.debug('assList::'+assList);
        
        //insert customer asset
        List<Customer_Asset__c> cusAsstLst = new List<Customer_Asset__c>();
        Customer_Asset__c cusAst = new Customer_Asset__c();
        cusAst.Contact__c = con.Id;
        cusAst.Asset__c = ass2.Id;
        cusAsstLst.add(cusAst);
        
        insert cusAsstLst;
        
        Document__c doc = new Document__c();
        doc.Name = 'Test Doc';
        doc.Document_Name__c = 'Test Document';
        doc.MS_Code__c = 'Test Doc';
        doc.Product__c = prod1.id;
        doc.Lang_Code__c = 'EN';
        doc.Category__c = 'Technical Information';
        doc.Type__c = 'Document';
        doc.File_Extension__c = 'PDF';
        doc.File_Size__c = '100';
        insert doc;
        
        //Inserting Service Contracts records
        List<ServiceContract> servContList = new List<ServiceContract>();
        ServiceContract servCont1 = new ServiceContract();
        servCont1.Name = 'Test Service Contract';
        servCont1.Contract_No__c = 'SC-0001';
        servCont1.StartDate = Date.newInstance(2020, 09, 29);
        servCont1.EndDate = Date.newInstance(2021, 02, 17);
        servCont1.Contract_Type__c = 'BCP';
        servContList.add(servCont1);
        
        ServiceContract servCont2 = new ServiceContract();
        servCont2.Name = 'Test Service Contract';
        servCont2.Contract_No__c = 'SC-0001';
        servCont2.StartDate = Date.newInstance(2020, 09, 29);
        servCont2.EndDate = Date.newInstance(2025, 02, 17);
        servCont2.Contract_Type__c = 'LCA';
        servContList.add(servCont2);
        
        insert servContList;
        
        //Inserting SOP record
        Scope_of_Product__c sop1 = new Scope_of_Product__c();
        sop1.Service_Contract__c = servCont1.Id;
        sop1.Asset__c = ass2.Id;
        insert sop1;
         
        //get asset ids
        List<Id> asstId = new List<Id>();
        for(Customer_Asset__c ast: cusAsstLst){
            asstId.add(ast.Asset__c);
        }
        
        //get project Ids
        List<Id> projId = new List<Id>();
        for(Project__c proj: projectList){
            projId.add(proj.Id);
        }
        
        //get product ids
        List<Id> prodId = new List<Id>();
        for(Product2 pd: prodList){
            prodId.add(pd.Id);
        }
        
        //Execute the code as portal user
        System.RunAs(user){
            
            test.startTest();
            
            List<Id> emptyList = new List<Id>();
            
            //Executing the getCusPlantInfo() method
            /*List<Customer_Plant__c> cusPlant = YG_HelperClass.getCusPlantInfo(con.Id);
            system.assertEquals(1, cusPlant.size());*/
            
            List<AccountContactRelation> cusPlant = YG_HelperClass.getCusPlantInfo(con.Id);
            system.assertEquals(1, cusPlant.size());
            
            /*List<Customer_Plant__c> cusPlt1 = YG_HelperClass.getCusPlantInfo(con.Id, 'EN');
            system.assertEquals(1, cusPlt1.size());*/
            List<AccountContactRelation> cusPlt1 = YG_HelperClass.getCusPlantInfo(con.Id, 'EN');
            system.assertEquals(1, cusPlt1.size());
            
            //Executing the getCusPlantList() method
            List<Contact> conLst = YG_HelperClass.getCusPlantList(acc.Id);
            system.assertEquals(1, conLst.size());
            
            //Executing the getPlantID() method
            //Plant__c plt = YG_HelperClass.getPlantID('300000142', 'EN');
            //system.assertEquals('300000142', plt.Plant_Code__c);
            Account plt = YG_HelperClass.getPlantID('300000142', 'EN');
            System.debug('plt:::'+plt);
            system.assertEquals('300000142', plt.AccountNumber);
            
            //Plant__c pltExcep = YG_HelperClass.getPlantID('1212', 'EN');
            Account pltExcep = YG_HelperClass.getPlantID('1212', 'EN');
            
            //Executing the getPlantList() method
            //List<Plant__c> pltList = YG_HelperClass.getPlantList(acc.Id,'EN');
            //system.assertEquals(1, pltList.size());
            List<Account> pltList = YG_HelperClass.getPlantList(acc.Id,'EN');
            System.debug('pltList::'+pltList);
            system.assertEquals(1, pltList.size());
            
            //Executing the getAssetsInfo() method
            List<Asset> astList = YG_HelperClass.getAssetsInfo(asstId,'Product','','EN');
            system.assertEquals(1, astList.size());
            
            List<Asset> astList1 = YG_HelperClass.getAssetsInfo(asstId,'Product','1212121','EN');
            system.assertEquals(0, astList1.size());
            
            List<Asset> astList2 = YG_HelperClass.getAssetsInfo(projId,'System','','EN');
            system.assertEquals(1, astList2.size());
            
            List<Asset> astListExcep = YG_HelperClass.getAssetsInfo(null,'System','','EN');
            
            //Executing the getAssetsandProductInfo() method
            List<Asset> astProdLst = YG_HelperClass.getAssetsandProductInfo(asstId,'Product','','EN',emptyList);
            system.assertEquals(1, astProdLst.size());
            
            List<Asset> astProdLst1 = YG_HelperClass.getAssetsandProductInfo(asstId,'Product','','EN',prodId);
            system.assertEquals(1, astProdLst1.size());
            
            List<Asset> astProdLstExcep = YG_HelperClass.getAssetsandProductInfo(asstId,'Product','12121','EN',emptyList);
            List<Asset> astProdLstExcep1 = YG_HelperClass.getAssetsandProductInfo(asstId,'Product','12121','EN',prodId);
            
            //Executing the getProductInfo() method
            List<Product2> prodList1 = YG_HelperClass.getProductInfo(prodId, 'Product', 'EN');
            system.assertEquals(1, prodList1.size());
            
            List<Product2> prodList2 = YG_HelperClass.getProductInfo(prodId, 'Hardware', 'EN');
            system.assertEquals(0, prodList2.size());
            
            List<Product2> prodList3 = YG_HelperClass.getProductInfo(null, 'Hardware', 'EN');
            
            //Executing the getAggAssetsInfo() method
            AggregateResult[] aggAst = YG_HelperClass.getAggAssetsInfo('Product','','EN',10,0,asstId);
            system.assertEquals(1, aggAst.size());
            
            AggregateResult[] aggAst1 = YG_HelperClass.getAggAssetsInfo('Product','1212','EN',10,0,null);
            
            //Executing the getWidthClassGraph() method
            String result1 = YG_HelperClass.getWidthClassGraph(1);
            System.assertEquals('w-15px', result1);
            String result2 = YG_HelperClass.getWidthClassGraph(7);
            System.assertEquals('w-25px', result2);
            String result3 = YG_HelperClass.getWidthClassGraph(25);
            System.assertEquals('w-40px', result3);
            String result4 = YG_HelperClass.getWidthClassGraph(50);
            System.assertEquals('w-55px', result4);
            String result5 = YG_HelperClass.getWidthClassGraph(70);
            System.assertEquals('w-68px', result5);
            String result6 = YG_HelperClass.getWidthClassGraph(102);
            System.assertEquals('w-82px', result6);
            String result7 = YG_HelperClass.getWidthClassGraph(0);
            System.debug('result7::'+result7);
            
            //Executing the getProductDetails() method
            Product2 prodData = YG_HelperClass.getProductDetails('BT200','EN');
            System.assertEquals('BT200', prodData.Model_Code__c);
            
            Product2 prodData1 = YG_HelperClass.getProductDetails('BT210','EN');
            
            //Executing the getAssetBySerialNumber() method
            List<Asset> atList = YG_HelperClass.getAssetBySerialNumber('Test123','EN');
            System.assertEquals(1, atList.size());
            
            //Executing the getAssetBySerialNumber() method
            List<String> strList =  YG_HelperClass.getAssetBySerialNumber(new List<String>{'BT200'});
            System.assertEquals(1, strList.size());
            
            //Executing the convertStringToDate() method
            Date dt = YG_HelperClass.convertStringToDate('20210303');
            
            //Executing the getAssetOrProductDetails() method
            Boolean boo = YG_HelperClass.getAssetOrProductDetails(new List<String>{'BT200'},null,'EN');
            System.assertEquals(true, boo);
            
            Boolean boo1 = YG_HelperClass.getAssetOrProductDetails(null,'Test Doc','EN');
            System.assertEquals(true, boo);
            
            //Executing the retrieveDocumentByMsCodeOrSerialNo() method
            List<Document__c> docList = YG_HelperClass.retrieveDocumentByMsCodeOrSerialNo ('Test Doc','','Document','EN');
            System.assertEquals(1, docList.size());
            
            //Executing the getCustomerAssets() method
            List<ID> idList = YG_HelperClass.getCustomerAssets(con.Id);
            System.assertEquals(1, idList.size());
            
            //Executing the getServiceContractExpiry() method
            String str = YG_HelperClass.getServiceContractExpiry(date.today());
            System.assertEquals('Expires today', str); 
            
            String str1 = YG_HelperClass.getServiceContractExpiry(date.today().addmonths(3));
            
            //Executing the getServiceContracts() method
            List<Id> idList1 = YG_HelperClass.getServiceContracts('300000142', asstId);
            System.assertEquals(1, idList1.size());
                       
            test.stopTest();            
        }    
        
    }
}