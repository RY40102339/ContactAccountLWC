/********************************************************************************************************
* (C) Copyright 2020 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Jayaprasath
* @version 1.0
* @created 01/21/2021
* @description 
* This class is used to call the CDC API for Account.
*
*  Change History:
*  MM/DD/YYYY           Developer Name          Comments
*  
*
*/

public class YG_GetAccountCDCAPI {
    
    public static void getAccountAPIInfo(String uid){
         system.debug('UID***'+uid);
        // Call Custom Setting to get the CDC API Config keys
        Map<String, YG_Community_Configuration__c> allValues = new Map<String, YG_Community_Configuration__c>();        
        allValues = YG_Community_Configuration__c.getAll();
        String userkey = allValues.get('CDC User Key').Text_1__c;
        String secret = allValues.get('CDC Secret Key').Text_1__c;
        String apiKey = allValues.get('CDC APIKey').Text_1__c;
        String endpointURL = allValues.get('CDC getAccountInfo Endpoint URL').Text_1__c;
        String response = '';
        String extraProfileField = 'phones,address';
        String errorNote = '';
        
        // Instantiate a new http object
        Http binding = new Http();
        HttpResponse res=null;
        
        // Instantiate a new HTTP request
        HttpRequest req = new HttpRequest();      
        req.setHeader('Content-Type','application/x-www-form-urlencoded');
        String curlbody = 'userKey='+EncodingUtil.urlEncode(userkey,'UTF-8')+'&secret='+EncodingUtil.urlEncode(secret,'UTF-8')+'&apiKey='+EncodingUtil.urlEncode(apiKey,'UTF-8')+'&UID='+EncodingUtil.urlEncode(uid,'UTF-8');  
        String curlparam = endpointURL+'?extraProfileFields='+EncodingUtil.urlEncode(extraProfileField,'UTF-8');
        req.setBody(curlbody);
        req.setEndpoint(curlparam);  
        req.setTimeout(120000);
        req.setMethod('POST'); 
        
        try {
            res = binding.send(req);
           
            System.Debug('Status code ::: '+res.getStatusCode());
            System.Debug('response ::: '+res.getBody());
            System.Debug('response headers ::: '+res.getHeaderKeys());
            System.Debug('response header ::: '+res.getHeader('X-CLA-Code'));
           
            // Parse the JSON response
            if (res.getStatusCode() == 200) {                
                response = JSON.serializePretty( JSON.deserializeUntyped(res.getBody())); 
                System.debug('response Body ::: '+response);
                YG_AccountCDCAPI.callAccountAPIInfo(response);   
            } 
            else {
                errorNote = 'The status code returned was not expected: ' + res.getStatusCode() + ' ' + res.getStatus();
                System.debug(errorNote);
            }
            
        } catch(Exception e){
            system.debug('Exception Cause::'+e.getCause());
            system.debug('Exception LineNumber::'+e.getLineNumber());
            system.debug('Exception Message::'+e.getMessage());
            system.debug('Exception StackTrace::'+e.getStackTraceString());
            system.debug('Exception TypeName::'+e.getTypeName());
            YG_Utility.logError('CDC Account API','Community Component Error',e.getStackTraceString(),
                               'Class:YG_GetAccountCDCAPI; Method: getAccountAPIInfo(); Line #:'+e.getLineNumber()
                                +'; Message:'+e.getMessage(),
                               UserInfo.getUserId());
        }
        
    }
    
}