/********************************************************************************************************
* (C) Copyright 2020 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Vinod A
* @version 1.0
* @created 15/05/2020
* @description 
* This test class for YG_NotificationBarController apex class.
*
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*
*
*/
@istest
public class YG_NotificationBarControllerTest {
    
    //@testSetup
    @istest 
    static void createTestData(){
         Test.startTest();
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.AllowSave = true; 
        
        //Insert test account record
        Account acc = new account();
        acc.name='Test AccountDocData';        
        //acc.DUNS_Number__c=102224222; 
        insert acc;
        
        //Insert contact account record
        Contact con = new Contact();   
        con.FirstName='User';
        con.LastName='DocContact1';
        con.Email='testContact@chevron.com';
        con.accountid=acc.id; 
        con.Status__c = true;
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
        
        //Insert test plant record
        List<Plant__c> plantList=new List<Plant__c>();
        Plant__c plant1=new Plant__c();
        plant1.Name = 'TestPlantDoc';
        plant1.Account__c = acc.Id;  
        plant1.Plant_Code__c = '300000142';
        plant1.Lang_Code__c = 'EN';
        plantList.add(plant1);
        insert plantList;
        
        //Inserting test plant record
        List<Customer_Plant__c> cusPlantList=new List<Customer_Plant__c>();
        Customer_Plant__c cusPlant = new Customer_Plant__c();
        	cusPlant.Contact__c = con.id;
            cusPlant.Status__c = 'Request site access';
            cusPlant.Plant__c = plant1.id;
        	cusPlantList.add(cusPlant);
        Customer_Plant__c cusPlant1 = new Customer_Plant__c();
        	cusPlant1.Contact__c = con.id;
            cusPlant1.Status__c = 'Decline site access';
            cusPlant1.Plant__c = plant1.id;
        	cusPlantList.add(cusPlant1); 
        insert cusPlantList;
        
        //Insert test category hierarchy record
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
        
        //Insert test product record
        List<Product2> prodList=new List<Product2>();
        
        Product2 prod1=new Product2();
        prod1.Name = 'ADMAG AXG: Magnetic Flow Meter';
        prod1.Model_Code__c = 'AX01C';
        prod1.Category__c = catg6.Id;
        prod1.Production_Date__c = Date.newInstance(2014, 12, 17);
        //prodList.add(prod1);
        insert prod1;
        
        //Insert test task record
        
        //tskList.add(t1);
        
        task t2=new task();
        t2.Subject = 'other';
        t2.WhatId = prod1.Id;
        t2.OwnerId = UserInfo.getUserId();
        t2.subject = 'Firmware Update';
        t2.Type = 'Firmware Update';
        t2.Is_Active__c = 'True';
        t2.Priority = 'Normal';
        t2.Status = 'open';
        t2.Lang_code__c  = 'EN';
        
        insert t2;
        task t2calib=new task();
        t2calib.Subject = 'other';
        t2calib.WhatId = prod1.Id;
        t2calib.OwnerId = UserInfo.getUserId();
        t2calib.subject = 'Calibration Recommended';
        t2calib.Type = 'Calibration Recommended';
        t2calib.Is_Active__c = 'True';
        t2calib.Priority = 'Normal';
        t2calib.Status = 'open';
        t2calib.Lang_code__c  = 'EN';
        
        insert t2calib;
        //tskList.add(t2);
        
        //Insert test asset record
        List<Asset> assList=new List<Asset>();
        Asset ass1=new Asset();
        ass1.Name = 'SU1234569';
        ass1.Product2Id = prod1.Id;
        ass1.AccountId = acc.Id;
        ass1.ContactId = con.Id;
        ass1.SerialNumber = 'SU1234569';
        ass1.Plant__c = plant1.Id;
        ass1.MS_Code__c = 'AAI543-H50';
        //ass1.Shipping_Date__c = Date.newInstance(2019, 7, 28);
        ass1.Status = 'Installed';
        
        insert ass1;
        
        Asset ass3=new Asset();
        ass3.Name = 'SU1234567';
        ass3.Product2Id = prod1.Id;
        ass3.AccountId = acc.Id;
        ass3.ContactId = con.Id;
        ass3.SerialNumber = 'SU1234567';
        ass3.Plant__c = plant1.Id;
        ass3.MS_Code__c = 'AAI543-H50';
        ass3.Status = 'Installed';
        ass3.Lang_Code__c = 'EN';
        insert ass3;
        
        List<task> tskList=new List<task>();
        task t1=new task();
        t1.Subject = 'Discontinued products';
        t1.type = 'Discontinued products';
        t1.Is_Active__c = 'True';
        t1.Priority = 'Normal';
        t1.Status = 'open';
        t1.Asset__c = ass3.Id;
        t1.Lang_code__c = 'EN';
        t1.ActivityDate = Date.newInstance(2019, 7, 28);
        t1.Is_Download_Available__c = true;
        insert t1;
        system.debug('task t1::'+t1);
        
        task t3=new task();
        t3.Subject = 'Calibration Recommended';
        t3.Type = 'Calibration Recommended';
        t3.Is_Active__c = 'True';
        t3.Priority = 'Normal';
        t3.Status = 'open';
        t3.Asset__c = ass1.Id;
        t3.Lang_code__c = 'EN';
        insert t3;
        //tskList.add(t3);
        
        task t5=new task();
        t5.Subject = 'Firmware Update';
        t5.Type = 'Firmware Update';
        t5.Is_Active__c = 'True';
        t5.Product__c = prod1.Id;
        t5.Lang_code__c = 'EN';
        insert t5;
        //tskList.add(t5);
        
        task t4=new task();
        t4.Subject = 'other';
        t4.WhatId = ass1.Id;
        t4.OwnerId = UserInfo.getUserId();
        t4.subject = 'Calibration Recommended';
        t4.Type = 'Calibration Recommended';
        t4.Is_Active__c = 'True';
        t4.Priority = 'Normal';
        t4.Status = 'open';
        t4.Asset__c = ass1.Id;
        t4.Lang_code__c = 'EN';
        insert t4;
        //tskList.add(t4);
        
        //insert tskList;
        
        Product2 prod2=new Product2();
        prod2.Name = 'Device Smart Communicators BT200';
        prod2.Model_Code__c = 'BT200';
        prod2.Category__c = catg3.Id;
        prod2.Production_Date__c = Date.newInstance(2014, 12, 17);
        prodList.add(prod2);
        
        insert prodList;
        
        task t2calib1=new task();
        t2calib1.Subject = 'other';
        t2calib1.WhatId = prod2.Id;
        t2calib1.OwnerId = UserInfo.getUserId();
        t2calib1.subject = 'Calibration Recommended';
        t2calib1.Type = 'Calibration Recommended';
        t2calib1.Is_Active__c = 'True';
        t2calib1.Priority = 'Normal';
        t2calib1.Status = 'open';
        t2calib1.Lang_code__c  = 'EN';
        
        insert t2calib1;
        
        Asset ass2=new Asset();
        ass2.Name = 'BT1234567';
        ass2.Product2Id = prod2.Id;
        ass2.AccountId = acc.Id;
        ass2.ContactId = con.Id;
        ass2.SerialNumber = 'BT1234567';
        ass2.Plant__c = plant1.Id;
        ass2.MS_Code__c = 'AAI543-BT';
        //ass2.Shipping_Date__c = Date.newInstance(2019, 7, 28);
        ass2.Status = 'Installed';
        
        insert ass2;
        
        task t6=new task();
        t6.Subject = 'Discontinued Products';
        t6.subject = 'Discontinued Products';
        t6.Type = 'Discontinued Products';
        t6.Is_Active__c = 'True';
        t6.Priority = 'Normal';
        t6.Status = 'open';
        t6.Asset__c = ass2.Id;
        t6.Lang_code__c ='EN';
        
        insert t6;
        
        task t7=new task();
        t7.Subject = 'Recalled Products';
        t7.WhatId = ass1.Id;
        t7.OwnerId = UserInfo.getUserId();
        t7.subject = 'Recalled Products';
        t7.Type = 'Recalled Products';
        t7.Is_Active__c = 'True';
        t7.Priority = 'Normal';
        t7.Status = 'open';
        t7.Asset__c = ass2.Id;
        t7.Lang_code__c = 'EN';
        
        insert t7;
        
        List<Customer_Asset__c> cusAssList=new List<Customer_Asset__c>();
        Customer_Asset__c cusAss1=new Customer_Asset__c();
     	cusAss1.Contact__c = con.Id;
    	cusAss1.Asset__c = ass1.Id;
     	cusAssList.add(cusAss1);
        Customer_Asset__c cusAss2=new Customer_Asset__c();
     	cusAss2.Contact__c = con.Id;
    	cusAss2.Asset__c = ass3.Id;
     	cusAssList.add(cusAss2);
        insert cusAssList;
        
    //}
    
    //Test method to execute getNotificationBarData() method in YG_NotificationBarController class based on above test data
   // @istest static void notificationBarTest(){
       
        system.runAs(user){
            User loggedInUser= YG_Utility.getLoggedInUserInfo(UserInfo.getUserId());
            YG_NotificationBarController.NotificationBarWrapper notiBarDatas=new YG_NotificationBarController.NotificationBarWrapper();
            notiBarDatas = YG_NotificationBarController.getNotificationBarData('SU1234567','');
            System.debug('notiBarDatas::'+notiBarDatas);
            /*Select Subject, ActivityDate, Owner.Name, Is_Active__c, Lang_code__c,
                                Product__c, Asset__r.SerialNumber,Asset__r.MS_Code__c, Asset__c,Is_Download_Available__c, Type from task 
                                Where Product__r.Model_Code__c='AX01C';*/
            //System.assertEquals(3, notiBarDatas.notificationCnt);
            //System.assertEquals(true, notiBarDatas.isfirmware);
            //System.assertEquals(true, notiBarDatas.iscalibration);
            
            notiBarDatas = YG_NotificationBarController.getNotificationBarData('','BT200');
            //System.debug('notiBarDatas::'+notiBarDatas);
            //System.assertEquals(true, notiBarDatas.isActiveModel);
            //System.assertEquals(true, notiBarDatas.isRecalled);
        }    
        Test.stopTest();
        
    }
}