/*
*******************************************************************************************************
* (C) Copyright 2020 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Chitrakishore M
* @version 1.0
* @created 01/12/2020
* @description  
* This class is used for exposing the REST API url for the webhook.
*
* @test class name - 
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  
*/

@RestResource(urlMapping='/notificationlistener/*')
global without sharing class YG_WebHookRestResource {
    
    public static String jsonRequest;
          
    @HttpPost
    global static Response_Info doPost()
    {
        RestRequest restRequestdata = RestContext.request;
        RestResponse res = RestContext.response;
        Response_Info responseData = new Response_Info();
        
        String emailAddress = 'null';
        List<Contact> c = new List<Contact>();
		Request_Info requestDetails = new Request_Info();
        List<String> uidList = new List<String>();
        List<EventWrapper> eventWrapperList = new List<EventWrapper>();
        
        // Call Custom Setting to get the CDC API Config keys
        Map<String, YG_Community_Configuration__c> allValues = new Map<String, YG_Community_Configuration__c>();        
        allValues = YG_Community_Configuration__c.getAll();
        String apiKey = allValues.get('CDC APIKey').Text_1__c;
        
        
        try {
		            
            if (restRequestdata != null && restRequestdata.requestBody != null) {  
                jsonRequest = restRequestdata.requestBody.toString();                  
            }
            System.debug('::::jsonRequest:::::' + jsonRequest);
            
            if(null !=jsonRequest){
            	requestDetails = (Request_Info) System.JSON.deserialize(jsonRequest, Request_Info.class);
            	System.debug(':::requestDetails::::' + requestDetails);
            }
            
            String uidValue= '';
            
            for(Events dataObj : requestDetails.events){
                
                if(null !=dataObj.apiKey && apiKey.equalsIgnoreCase(dataObj.apiKey)){
                    if(dataObj.type.equalsIgnoreCase('accountCreated') || 
                       dataObj.type.equalsIgnoreCase('accountUpdated')){
                           EventWrapper eventWrapperObj = new EventWrapper();
                           eventWrapperObj.accountType = dataObj.type;
                           eventWrapperObj.uid = dataObj.data.uid;
                           eventWrapperList.add(eventWrapperObj);
                       }
                }
                              
            }
                      
            YG_AccountCDCAPI.getAccountInfo(eventWrapperList);
            
        }
		catch (Exception e) {
                       
            responseData.status = 'Fail';
            responseData.message = 'Internal Server Error';
            responseData.code = '500';            
                
            system.debug('Exception Cause::'+e.getCause());
            system.debug('Exception LineNumber::'+e.getLineNumber());
            system.debug('Exception Message::'+e.getMessage());
            system.debug('Exception StackTrace::'+e.getStackTraceString());
            system.debug('Exception TypeName::'+e.getTypeName());
            YG_Utility.logError('API','Community Component Error',e.getStackTraceString(),
                               'Class:YG_WebHookRestResource; Method: doPost(); Line #:'+e.getLineNumber()
                                +'; Message:'+e.getMessage(),null);
        }
        
        return responseData;
                
    }
    
    
    public class Request_Info {
        public List<Events> events;
        public String nonce;
        public String timestamp;
    }
    
    public class Events{
        public String type;
        public String id;
        public String timestamp;
        public String callId;
        public String apiKey;
        public Data data;
    }
    
    
    public class Data{
        public String accountType;
        public String uid;
    }
    
    public class EventWrapper{
        public String accountType;
        public String uid;
    }
    
    global class Response_Info {
        public String status;
        public String message;
        public String code;
        
        public Response_Info(){
            this.status = 'success';
            this.message = 'Successfully connected!';
            this.code='200';
        }
    }

}