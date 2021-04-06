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
* This test class for YG_CadImageController apex class.
*
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  07/01/2020			Vinod					code coverage update for plant selection implemention.
*
*/

@istest
public class YG_CadImageControllerTest {
    
    
    @istest static void getImageTestMethod(){
        
       //Inserting test account record
        Account acc = new account();
        acc.name='Test Account';        
        //acc.DUNS_Number__c=102224222; 
        insert acc;    
        
        //Inserting test contact record
        Contact con = new Contact();   
        con.FirstName='User';
        con.LastName='testContact';
        con.Email='testContact@chevron.com';
        con.accountid=acc.id; 
        insert con;
        
        //Inserting test plant record
        Plant__c plant1=new Plant__c();
        plant1.Name = 'TestPlant';
        plant1.Account__c = acc.Id;  
        plant1.Plant_Code__c = '300000142';
        plant1.Lang_Code__c = 'EN';
        insert plant1;
        
        //Inserting test Category Hierarchy and Category record
        Category_Hierarchy__c catHier6=new Category_Hierarchy__c(Category_Code__c = 'A0000000', Category_Level__c = 3, Display_Sequence__c = 500,
                                                                 Upper_Category_Code__c = 'B0000000');
        insert catHier6;
        
        Category__c catg6=new Category__c(Name = 'ADMAG AXG', Category_Hierarchy__c = catHier6.Id,
                                          Category_Type__c = 'Product', Language_Code__c = 'EN');
        insert catg6;
        
        //Inserting test product record
        Product2 prod1=new Product2();
        prod1.Name = 'ADMAG AXG: Magnetic Flow Meter';
        prod1.Model_Code__c = 'AX01C';
        prod1.Category__c = catg6.Id;
        prod1.Production_Date__c = Date.newInstance(2014, 12, 17);
        insert prod1;
        
        //Inserting test product record
        Product2 prod2=new Product2();
        prod2.Name = 'Flow Meter';
        prod2.Model_Code__c = 'ASS123';
        prod2.Category__c = catg6.Id;
        prod2.Production_Date__c = Date.newInstance(2014, 12, 17);
        insert prod2;
        
        //Inserting test asset record
        Asset ass1=new Asset();
        ass1.Name = 'SU1234567';
        ass1.Product2Id = prod1.Id;
        ass1.AccountId  = acc.Id;
        ass1.ContactId  = con.Id;
        ass1.SerialNumber = 'SU1234567';
        ass1.Plant__c = plant1.Id;
        ass1.MS_Code__c = 'AAI543-H50';
        //ass1.Shipping_Date__c = Date.newInstance(2019, 7, 28);
        ass1.Status = 'Installed';
        insert ass1;
        
        //Inserting test asset record
        Asset ass2=new Asset();
        ass2.Name = 'SU1234222';
        ass2.Product2Id = prod1.Id;
        ass2.AccountId  = acc.Id;
        ass2.ContactId  = con.Id;
        ass2.SerialNumber = 'SU1234222';
        ass2.Plant__c = plant1.Id;
        ass2.MS_Code__c = 'AAI543-H50';
        //ass2.Shipping_Date__c = Date.newInstance(2019, 7, 28);
        ass2.Status = 'Installed';
        insert ass2;
        
       
        
        ContentVersion cv = new ContentVersion();
        cv.Title = 'AX01C_02';
        cv.PathOnClient = 'AX01C_02.jpg';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        insert cv;
        
         List<ContentFolderItem> ContentFolItem = [SELECT Id, Title, FileExtension FROM ContentFolderItem WHERE ParentContentFolderId IN (SELECT Id FROM ContentFolder WHERE Name =: prod1.Model_Code__c)];
        System.debug('ContentFolItem ::'+ContentFolItem );
        List<Id> idList=new List<Id>();
        for(ContentFolderItem cont : ContentFolItem ){
            idList.add(cont.Id);
        }
        System.debug('idList::'+idList);
        List<ContentVersion> imgId2 = [SELECT Id,Title FROM ContentVersion where ContentDocumentId IN: idList];
        System.debug('imgId2 ::'+imgId2 );
        
        //Executing the YG_CadImageController class after test data setup
        test.startTest();
        YG_CadImageController.imgWrapper imgWrap=new YG_CadImageController.imgWrapper();
        imgWrap = YG_CadImageController.getImageUrl('AX01C', '');
        //System.assertEquals('ADMAG AXG: Magnetic Flow Meter', imgWrap.prodName);
        System.debug('imgWrap::'+imgWrap);
        Try{
        imgWrap = YG_CadImageController.getImageUrl('222', '');
            }
        catch(Exception e){
            System.debug('exception::'+e);
        }
        /*YG_CadImageController.imgWrapper imgWrap2=new YG_CadImageController.imgWrapper();
        imgWrap2 = YG_CadImageController.getImageUrl('', '');
        Map<String, String> mapImg=new Map<String, String>();
        Map<String, String> mapImg1=new Map<String, String>();
        Map<String, String> mapImg2=new Map<String, String>();
        mapImg = YG_CadImageController.getImageUrl('AX01C', '');
        System.debug('mapImg::'+mapImg);
        String url = mapImg.get('ADMAG AXG: Magnetic Flow Meter');
        System.assertNotEquals('', url);
        
        mapImg1 = YG_CadImageController.getImageUrl('', 'SU1234567');
        String url1 = mapImg.get('SU1234567');
        System.assertNotEquals('', url1);
        
        mapImg2 = YG_CadImageController.getImageUrl('', 'SU1234222');
        String url2 = mapImg.get('SU1234222');
        System.assertNotEquals('', url2);*/
        test.stopTest();
    }
    
}