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
* This class used to get Certificate search page functionalities
*
* @test class name - 
*
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  
*/

@istest
public class YG_CertificateSearchAPIHandlerTest {
    
    @istest static void directiveSearchTestMethod(){
        //Insert custom setting records
        List<YG_Community_Configuration__c> configList = new List<YG_Community_Configuration__c>();
        
        
        
        YG_Community_Configuration__c derivativeApi = new YG_Community_Configuration__c();
        derivativeApi.Name = 'DirectiveSearchAPIEndpointUrl';
        derivativeApi.Text_1__c = 'https://library.yokogawa.com/certificate/directivesearch';
        configList.add(derivativeApi);
        
        YG_Community_Configuration__c systemid=new YG_Community_Configuration__c();
        systemid.Name = 'ShippingAPISystemId';
        systemid.Text_1__c = 'F5cJnZkn';
        configList.add(systemid);
        
        insert configList;
        
        Test.startTest();
        
        //Calling mock response
        Test.setMock(HttpCalloutMock.class, new YG_DocumentAPIMockCallout());
        YG_CertificateSearchAPIHandler.DirectiveSearchResult deriSearch=new YG_CertificateSearchAPIHandler.DirectiveSearchResult();
        deriSearch = YG_CertificateSearchAPIHandler.getDirectiveSearch();
        //System.assertEquals(null, deriSearch.ResponseData);
        System.assertEquals(true, deriSearch.success);
        Test.stopTest();
    }
    
    @istest static void certificateSearchTestMethod(){
        //Insert custom setting records
        List<YG_Community_Configuration__c> configList = new List<YG_Community_Configuration__c>();
        
        YG_Community_Configuration__c certApi = new YG_Community_Configuration__c();
        certApi.Name = 'CertificateSearchAPIEndpointUrl';
        certApi.Text_1__c = 'https://library.yokogawa.com/certificate/search1';
        configList.add(certApi);
        
         YG_Community_Configuration__c systemid=new YG_Community_Configuration__c();
        systemid.Name = 'ShippingAPISystemId';
        systemid.Text_1__c = 'F5cJnZkn';
        configList.add(systemid);
        
        insert configList;
         Test.startTest();
        
        //Calling mock response
        Test.setMock(HttpCalloutMock.class, new YG_DocumentAPIMockCallout());
        YG_CertificateSearchAPIHandler.CertificateWrapper certWrap=new YG_CertificateSearchAPIHandler.CertificateWrapper();
        certWrap = YG_CertificateSearchAPIHandler.searchCertificate('EJA', 'EJA110E', '', '', '', '0014,0003,0001,0004,0012,0017,0011,0013', 'AMA001-C01', 1, 3);
        System.assertNotEquals(null, certWrap.certificateAPIResponseList);
        System.assertEquals(true, certWrap.success);
        Test.stopTest();
    }
    
    @istest static void certificateSearchTestMethod2(){
        //Insert custom setting records
        List<YG_Community_Configuration__c> configList = new List<YG_Community_Configuration__c>();
        
        YG_Community_Configuration__c certApi = new YG_Community_Configuration__c();
        certApi.Name = 'CertificateSearchAPIEndpointUrl';
        certApi.Text_1__c = 'https://library.yokogawa.com/certificate/search1';
        configList.add(certApi);
        
         YG_Community_Configuration__c systemid=new YG_Community_Configuration__c();
        systemid.Name = 'ShippingAPISystemId';
        systemid.Text_1__c = 'F5cJnZkn';
        configList.add(systemid);
        
        insert configList;
         Test.startTest();
        
        //Calling mock response
        Test.setMock(HttpCalloutMock.class, new YG_DirectiveAPIAndCertAPIMockCallout());
        YG_CertificateSearchAPIHandler.CertificateWrapper certWrap=new YG_CertificateSearchAPIHandler.CertificateWrapper();
        certWrap = YG_CertificateSearchAPIHandler.searchCertificate('EJA', 'EJA110E', '', '', '', '0014,0003,0001,0004,0012,0017,0011,0013', 'AMA001-C01', 1, 3);
        System.assertEquals(null, certWrap.certificateAPIResponseList);
        System.assertEquals(false, certWrap.success);
        Test.stopTest();
    }

}