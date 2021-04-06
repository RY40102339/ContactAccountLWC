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
* This test class for YG_ProductInformationController apex class.
*
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  13/08/2020			Vinod					Modified for the code coverage.
*
*/
@isTest
public class YG_ProductInformationControllerTest {
    
    //test method for YG_ProductInformationController.getProductInformation() method
    @istest static void productInfoTestMethod(){
        
        //Insert test account record
        Account acc = new account();
        acc.name='Test AccountDocData';        
        //acc.DUNS_Number__c=102224222; 
        insert acc;
        
        //Insert test contact record
        Contact con = new Contact();   
        con.FirstName='User';
        con.LastName='DocContact1';
        con.Email='testContact@chevron.com';
        con.accountid=acc.id; 
        insert con;
        
        //Insert test portal user record
        User user = new User();   
        user.ProfileID = [Select Id From Profile Where Name='Customer Portal User'].id; 
        System.debug('user.ProfileID');
        user.EmailEncodingKey = 'ISO-8859-1';   user.LanguageLocaleKey = 'en_US';   user.TimeZoneSidKey = 'America/New_York';   
        user.LocaleSidKey = 'en_US';   user.FirstName = 'User';   user.LastName = 'testContact';   user.Username = 'testContact@chevron.com';      
        user.CommunityNickname = 'User222';   user.Alias = 'user';   user.Email = 'testContact@chevron.com';   user.IsActive = true;   
        user.ContactId = con.Id;  
        insert user;  
        
        //Insert test category hierarchy record
        List<Category_Hierarchy__c> catHierUppLvlList=new List<Category_Hierarchy__c>();
        Category_Hierarchy__c catHierL1=new Category_Hierarchy__c(Category_Code__c = '10000000', Category_Level__c = 1, Display_Sequence__c = 500, Upper_Category_Code__c = NULL);
        catHierUppLvlList.add(catHierL1); //Field Ins
        
        insert catHierUppLvlList;
        
        List<Category_Hierarchy__c> catHierLowLvlList=new List<Category_Hierarchy__c>();
        
        Category_Hierarchy__c catHierL11=new Category_Hierarchy__c(Category_Code__c = '11000000', Category_Level__c = 2, Display_Sequence__c = 500, Category_Hierarchy__c = catHierL1.id);
        catHierLowLvlList.add(catHierL11); //Flow meters
        
        insert catHierLowLvlList;
        
        Category_Hierarchy__c catHierL12=new Category_Hierarchy__c(Category_Code__c = '11100000', Category_Level__c = 3, Display_Sequence__c = 500, Category_Hierarchy__c = catHierL11.id);
        insert catHierL12; //Admag
        
        Category_Hierarchy__c catHierL13=new Category_Hierarchy__c(Category_Code__c = '11200000', Category_Level__c = 3, Display_Sequence__c = 500, Category_Hierarchy__c = catHierL11.id);
        insert catHierL13; //Carolis flow meters
        
        
        //Insert test category record
        List<Category__c> catList=new List<Category__c>();
        Category__c catg1=new Category__c(Name = 'ADMAG AXG', Category_Hierarchy__c = catHierL12.Id,
                                          Category_Type__c = 'Product', Language_Code__c = 'EN');
        catList.add(catg1);
        
        Category__c catg2=new Category__c(Name = 'Carolis Flow Meters', Category_Hierarchy__c = catHierL13.Id,
                                          Category_Type__c = 'Product', Language_Code__c = 'EN');
        catList.add(catg2);
        
        insert catList;
        
        //Insert test product record
        List<Product2> prodList=new List<Product2>();
        
        Product2 prod1=new Product2();
        prod1.Name = 'ADMAG AXG: Magnetic Flow Meter';
        prod1.Model_Code__c = 'AX01C';
        prod1.Category__c = catg1.Id;
        prod1.Type__c = 'ADMAG AXG';
        prod1.Production_Date__c = Date.newInstance(2014, 12, 17);
        prodList.add(prod1);
        
        Product2 prod2=new Product2();
        prod2.Name = 'Carolis Flow Meter';
        prod2.Model_Code__c = 'CFM01';
        prod2.Category__c = catg2.Id;
        prod2.Production_Date__c = Date.newInstance(2014, 12, 17);
        prodList.add(prod2);
        
        insert prodList;
        
        //Insert test asset record
        List<Asset> assList=new List<Asset>();
        Asset ass1=new Asset();
        ass1.Name = 'SU1234567';
        ass1.Product2Id = prod1.Id;
        ass1.AccountId = acc.Id;
        ass1.ContactId = con.Id;
        ass1.SerialNumber = 'SU1234567';
        ass1.MS_Code__c = 'AAI543-H50';
        //ass1.Shipping_Date__c = Date.newInstance(2019, 7, 28);
        ass1.Status = 'Installed';
        ass1.Order_Date__c = Date.newInstance(2019, 6, 28);
        ass1.Product_Carrier__c = 'S1';
        ass1.Production_Date__c = Date.newInstance(2019, 7, 28);
        ass1.Tokuchu_no__c = 'ATH02988-0002-000';
        ass1.Xj_no__c = 'XJDY-4058';
        assList.add(ass1);
        
        Asset ass2=new Asset();
        ass2.Name = 'CF1234568';
        ass2.Product2Id = prod2.Id;
        ass2.AccountId = acc.Id;
        ass2.ContactId = con.Id;
        ass2.SerialNumber = 'CF1234568';
        ass2.MS_Code__c = 'AAI543-H51';
        ass2.Status = 'Installed';
        ass2.Product_Carrier__c = '';
        ass2.Production_Date__c = Date.newInstance(2019, 7, 28);
        ass2.Tokuchu_no__c = '';
        ass2.Xj_no__c = '';
        assList.add(ass2);
        
        insert assList;
        
        //Insert Product extendion records
        List<Product_Extension__c> prodExtList = new List<Product_Extension__c>();
        
        Product_Extension__c prodExt1 = new Product_Extension__c();
        prodExt1.Name = 'Output Mode;Linear/ Square Root';
		prodExt1.Asset__c = ass1.Id;
        prodExt1.Description__c = '01:Linear';
        prodExt1.Type__c = 'Ordering Instructions';
        prodExt1.Order_Code__c = 'H46';
        prodExtList.add(prodExt1);
                
        insert prodExtList;
        
        System.RunAs(user){
            
            //executing getProductInformation() method based on above testdata
            YG_ProductInformationController.ProdInfoWrapper prodWrap=new YG_ProductInformationController.ProdInfoWrapper();
            prodWrap = YG_ProductInformationController.getProductInformation('SU1234567');
            System.assertEquals('AX01C', prodWrap.modelCode);	
            System.assertEquals('ADMAG AXG', prodWrap.prodCatName);
            
            YG_ProductInformationController.ProdInfoWrapper prodWrap1=new YG_ProductInformationController.ProdInfoWrapper();
            prodWrap1 = YG_ProductInformationController.getProductInformation('CF1234568');
            System.assertEquals('CFM01', prodWrap1.modelCode);
            
            List<Product_Extension__c> prodExtnList = YG_ProductInformationController.getProdExtensionDetails('SU1234567','Ordering Instructions');
            System.assertEquals(1, prodExtnList.size());            
            
        }
        
    }
    
}