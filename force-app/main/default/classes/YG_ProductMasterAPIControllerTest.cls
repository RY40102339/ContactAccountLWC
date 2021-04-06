/*
*******************************************************************************************************
* (C) Copyright 2020 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Selvaraj T
* @version 1.0
* @created 12/10/2020
* @description 
* This is test class for YG_ProductMasterAPIController.
*
*
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  
*  
*
*/

@isTest
public class YG_ProductMasterAPIControllerTest {
    
    @isTest static void testData(){
        
        //inserting test configuration records
        List<YG_Community_Configuration__c> commConfigList = new List<YG_Community_Configuration__c>();
       	
        YG_Community_Configuration__c endPointUrl=new YG_Community_Configuration__c();
        endPointUrl.Name = 'ProductMasterAPIEndpointURL';
        endPointUrl.Text_1__c = 'https://library.yokogawa.com/productmaster/search';
        commConfigList.add(endPointUrl);
        
        YG_Community_Configuration__c usagearea=new YG_Community_Configuration__c();
        usagearea.Name = 'ShippingAPIUsageArea';
        usagearea.Text_1__c = '1';
        commConfigList.add(usagearea);
        
        YG_Community_Configuration__c systemid=new YG_Community_Configuration__c();
        systemid.Name = 'ShippingAPISystemId';
        systemid.Text_1__c = 'AxkHnJ89';
        commConfigList.add(systemid);
        
        insert commConfigList;
         
        //for exception calling callout along with DML context
        Test.setMock(HttpCalloutMock.class, new YG_APIMockCallout());
        YG_ProductMasterAPIController.productModelWrapper prodModWrap1 = YG_ProductMasterAPIController.getSuffixCodeDetails('YTA610-JB1A2DB/NF2');
        system.assertEquals(false, prodModWrap1.success);
        
        
        //making callout in separate context
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new YG_APIMockCallout());
        
        YG_ProductMasterAPIController.productModelWrapper prodModWrap = YG_ProductMasterAPIController.getSuffixCodeDetails('YTA610-JB1A2DB/NF2');
        system.assertEquals(true, prodModWrap.success);
        
        YG_ProductAvailabilityController.productAvailabilityWrapper prodAvaiWrap = YG_ProductAvailabilityController.getSuffixCodes('YTA610-JB1A2DB/NF2');
        system.assertEquals('YTA610', prodAvaiWrap.model);
        
        Test.stopTest();
        
    }
}