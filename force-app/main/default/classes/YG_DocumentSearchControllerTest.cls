/********************************************************************************************************
* (C) Copyright 2020 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Vinod A
* @version 1.0
* @created 10/11/2020
* @description 
* This class used to test the YG_DocumentSearchController
*
* @test class name - 
*
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  
*/
@istest
public class YG_DocumentSearchControllerTest {
    
    @istest static void testMethod1(){
        
         //Inserting test account record
        Account acc = new account();
        acc.name='XYZ Account';   
        acc.AccountNumber = '200086397';
        //acc.DUNS_Number__c=102224533; 
        insert acc; 
        
        //Inserting test contact record
        Contact con = new Contact();   
        con.FirstName='User';
        con.LastName='CVX AU';
        con.Email='cvxauuser011@chevron.com';
        con.accountid=acc.id; 
        insert con;
        
         //Inserting test Category Hierarchy record
        List<Category_Hierarchy__c> catHierUppLvlList=new List<Category_Hierarchy__c>();
        Category_Hierarchy__c catHierL1=new Category_Hierarchy__c(Category_Code__c = '20000000', Category_Level__c = 1, Display_Sequence__c = 500, Upper_Category_Code__c = NULL);
        catHierUppLvlList.add(catHierL1); // DCS
        
        insert catHierUppLvlList;
        
        List<Category_Hierarchy__c> catHierLowLvlList=new List<Category_Hierarchy__c>();
        Category_Hierarchy__c catHierL21=new Category_Hierarchy__c(Category_Code__c = '21000000', Category_Level__c = 2, Display_Sequence__c = 500, Upper_Category_Code__c = NULL, Category_Hierarchy__c = catHierL1.id);
        catHierLowLvlList.add(catHierL21); //Hardware 
        
        Category_Hierarchy__c catHierL22=new Category_Hierarchy__c(Category_Code__c = '22000000', Category_Level__c = 2, Display_Sequence__c = 500, Upper_Category_Code__c = NULL, Category_Hierarchy__c = catHierL1.id);
        catHierLowLvlList.add(catHierL22); //software 
        
        insert catHierLowLvlList;
        
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
        
        Insert catList;
        
        //Inserting test product record
        List<Product2> prodList=new List<Product2>();
        
        Product2 prod1=new Product2();
        prod1.Name = 'Distributed Control Systems (DCS)';
        prod1.Model_Code__c = 'AFV10D';
        prod1.Product_Type__c = 'Station';
        prod1.Category__c = catg2.Id;
       // prod1.Production_Date__c = Date.newInstance(2014, 12, 17);
        prod1.Lang_Code__c = 'EN';
        prod1.IsActive = true;
        prodList.add(prod1);
        
        Product2 prod1NumericModcode=new Product2();
        prod1NumericModcode.Name = 'Distributed Control Systems (DCS)';
        prod1NumericModcode.Model_Code__c = '123';
        prod1NumericModcode.Product_Type__c = 'Station';
        prod1NumericModcode.Category__c = catg2.Id;
       // prod1NumericModcode.Production_Date__c = Date.newInstance(2014, 12, 17);
        prod1NumericModcode.Lang_Code__c = 'EN';
        prod1NumericModcode.IsActive = true;
        prodList.add(prod1NumericModcode);
        
        Product2 prod1NumericModcode2=new Product2();
        prod1NumericModcode2.Name = 'Distributed Control Systems (DCS)';
        prod1NumericModcode2.Model_Code__c = '12';
        prod1NumericModcode2.Product_Type__c = 'Station';
        prod1NumericModcode2.Category__c = catg2.Id;
       // prod1NumericModcode2.Production_Date__c = Date.newInstance(2014, 12, 17);
        prod1NumericModcode2.Lang_Code__c = 'EN';
        prod1NumericModcode2.IsActive = true;
        prodList.add(prod1NumericModcode2);
        
        Product2 prod2=new Product2();
        prod2.Name = 'PC';
        prod2.Model_Code__c = 'PC';
        prod2.Product_Type__c = 'Station';
        prod2.Category__c = catg3.Id;
      //  prod2.Production_Date__c = Date.newInstance(2014, 12, 17);
        prod2.Lang_Code__c = 'EN';
        prod2.IsActive = true;
        prodList.add(prod2);
        
        Product2 prod3=new Product2();
        prod3.Name = 'Analog Input Module (4 to 20 mA, 16-Channel, Isolated)';
        prod3.Model_Code__c = 'AAI143';
        prod3.Product_Type__c = 'Hardware';
        prod3.Category__c = catg2.Id;
       // prod3.Production_Date__c = Date.newInstance(2014, 12, 17);
        prod3.Lang_Code__c = 'EN';
        prod3.IsActive = true;
        prodList.add(prod3);
        
        Product2 prod4=new Product2();
        prod4.Name = 'Analog Output Module (4 to 20 mA, 16-Channel, Isolated)';
        prod4.Model_Code__c = 'AAI543';
        prod4.Product_Type__c = 'Hardware';
        prod4.Category__c = catg2.Id;
      //  prod4.Production_Date__c = Date.newInstance(2014, 12, 17);
        prod4.Lang_Code__c = 'EN';
        prod4.IsActive = true;
        prodList.add(prod4);
        
        Product2 prod5=new Product2();
        prod5.Name = 'Node Expansion Package (for AFV10)';
        prod5.Model_Code__c = 'LFS1550';
        prod5.Product_Type__c = 'Software';
        prod5.Category__c = catg3.Id;
       // prod5.Production_Date__c = Date.newInstance(2014, 12, 17);
        prod5.Lang_Code__c = 'EN';
        prod5.IsActive = true;
        prodList.add(prod5);
        
        Insert prodList;
        
        
         Profile profile = [Select Id From Profile Where Name='Customer Portal User'];
        User user = new User(Alias = 'comm', Email='yg.qa167@gmail.com',ContactId=con.id,
                             EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                             LocaleSidKey='en_US', ProfileId = profile.Id,
                             TimeZoneSidKey='America/Los_Angeles', UserName='yg.qa167@gmail.com');
        insert user;
        System.RunAs(user){
            
            List<Category__c> catList1 =[Select Name, Category_Hierarchy__r.Category_Code__c, Category_Hierarchy__r.Category_Level__c, 
                        Category_Hierarchy__r.Upper_Category_Code__c, Language_Code__c from Category__c Where Category_Hierarchy__r.Upper_Category_Code__c ='21000000' And Language_Code__c ='EN'];
            System.debug('catList1::'+catList1);
            
            Map<String, String> catLevel1 = YG_DocumentSearchController.getCategoryLevel1();
            System.debug('catLevel1::'+catLevel1);
            YG_DocumentSearchController.childCategoryWrapper childWrap=new YG_DocumentSearchController.childCategoryWrapper();
            YG_DocumentSearchController.childCategoryWrapper childWrap2=new YG_DocumentSearchController.childCategoryWrapper();
            YG_DocumentSearchController.childCategoryWrapper childWrap3=new YG_DocumentSearchController.childCategoryWrapper();
            childWrap = YG_DocumentSearchController.getCategoryHierarchy('20000000');
            System.debug('childWrap::'+childWrap);
            childWrap2 = YG_DocumentSearchController.getCategoryHierarchy('21000000');
            //childWrap2.models[0]
            //System.assertEquals(modelcodes[0], 'AFV10D');
            System.debug('childWrap2::'+childWrap2);
            childWrap3 = YG_DocumentSearchController.getCategoryHierarchy('22000000');
            System.debug('childWrap3::'+childWrap3);
        }
    }

}