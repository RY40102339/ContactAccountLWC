/*
*******************************************************************************************************
* (C) Copyright 2020 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Chitrakishore M
* @version 1.0
* @created 18/12/2020
* @description  
* This class is used for exposing the REST API url for the webhook.
*
* @test class name - 
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  
*/

@isTest
public class YG_WebHookRestResourceTest {
    
    static testmethod void webHookRestResourceMethod(){
 
        	YG_Community_Configuration__c apiKey = new YG_Community_Configuration__c(name= 'CDC APIKey',Text_1__c='3_B2wrSrOEFEWC_Pc6DQI0NmyU9SrKJhNgNzFRNDQAUsmmGDa5HLbf0AlgwnnXOwVr');
            insert apiKey;
            
            Map<String, YG_Community_Configuration__c> allValues = new Map<String, YG_Community_Configuration__c>();        
            allValues = YG_Community_Configuration__c.getAll();
            String api_Key = allValues.get('CDC APIKey').Text_1__c;
            
        	YG_WebHookRestResource.Request_Info requestInfo = new YG_WebHookRestResource.Request_Info();
            YG_WebHookRestResource.Events event = new YG_WebHookRestResource.Events();
            YG_WebHookRestResource.Data data = new YG_WebHookRestResource.Data();
        	List<YG_WebHookRestResource.Events> events = new List<YG_WebHookRestResource.Events>();
        
        	data.accountType = 'full';
        	data.uid = 'e2304ca2955b42b49006483818fc175c';
        
        	event.apiKey = api_Key;
            event.callId = 'a4e6ec632db048e3b0NmyU9SrKJhNgNzFRNDQAUsmmGDa5HLbf0AlgwnnXOwVr';
            event.data = data;
        	event.id = 'b11f9df0-08f9-4106-96b4-494c0105edfd';
        	event.timestamp = '1605777558';
        	event.type = 'accountUpdated';
        	events.add(event);
        
        	requestInfo.events = events;
        	requestInfo.nonce = 'de97dd12-a0b0-4208-be92-ef0bac0bd0c3';
        	requestInfo.timestamp ='1605777560';
               
        
            //Test.setMock(HttpCalloutMock.class, new YG_WebHookRestResourceMockCallout());
            test.startTest();
            
        	//Instantiate the Rest Context
            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
            
            req.requestURI = '/services/apexrest/notificationlistener';	//Request URL
            req.httpMethod = 'POST'; //Request Type
            req.requestBody = Blob.valueof(JSON.serialize(requestInfo, true));
            RestContext.request = req;
            RestContext.response =res;
                        
        	YG_WebHookRestResource.Response_Info response = new YG_WebHookRestResource.Response_Info();
            response = YG_WebHookRestResource.doPost();
            System.debug('Response ::: '+response);
            Test.stopTest();
        
    }

}