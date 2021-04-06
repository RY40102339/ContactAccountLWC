/********************************************************************************************************
* (C) Copyright 2020 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Vinod A
* @version 1.0
* @created 20/11/2020
* @description 
* This class used to get Document search page functionalities
*
* @test class name - 
*
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  
*/
@istest
public class YG_DocumentSearchAPIHandlerTest {

    static testmethod void documentAPITestMethod(){
        
        //Insert custom setting records
        List<YG_Community_Configuration__c> configList = new List<YG_Community_Configuration__c>();
        
        YG_Community_Configuration__c docApi = new YG_Community_Configuration__c();
        docApi.Name = 'DocumentAPIEndpointUrl';
        docApi.Text_1__c = 'https://library.yokogawa.com/document/search';
        configList.add(docApi);
        
        YG_Community_Configuration__c systemid=new YG_Community_Configuration__c();
        systemid.Name = 'ShippingAPISystemId';
        systemid.Text_1__c = 'F5cJnZkn';
        configList.add(systemid);
        
        insert configList;
        
        Test.startTest();
        
        //Calling mock response
            Test.setMock(HttpCalloutMock.class, new YG_DocumentAPIMockCallout());
        
        YG_DocumentSearchAPIHandler.DocumentWrapper docWrap=new YG_DocumentSearchAPIHandler.DocumentWrapper();
        
        docWrap = YG_DocumentSearchAPIHandler.searchDocument('EJXC40A', '', '', '', 'all', 0, 1, 5);
        System.debug('docWrap::'+docWrap);
        Test.stopTest();
    }
}