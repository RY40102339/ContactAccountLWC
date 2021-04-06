/*
*******************************************************************************************************
* (C) Copyright 2020 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Jayaprasath
* @version 1.0
* @created 01/07/2021
* @description 
* This class is used to write the methods for User deactivation.
*
* @test class name - 
*
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  
*/

public class YG_DeactivateCDCAPI {
    @future(callout = true)
    public static void deactivateUser(Set<String> allEmails){
        System.debug('allEmails* '+allEmails);
        
        // Call Custom Setting to get the CDC API Config keys
        Map<String, YG_Community_Configuration__c> allValues = new Map<String, YG_Community_Configuration__c>();        
        allValues = YG_Community_Configuration__c.getAll();
        String userkey = allValues.get('CDC User Key').Text_1__c;
        String secret = allValues.get('CDC Secret Key').Text_1__c;
        String apiKey = allValues.get('CDC APIKey').Text_1__c;
        String endpointURL = allValues.get('CDC setAccountInfo Endpoint URL').Text_1__c;
        String response = '';
        String status = 'false';
        Boolean success = false;        
        String UID = [Select Gigya_UID__c from Contact where email in: allEmails and status__c =: true].Gigya_UID__c;//get user Gigya_UID
        system.debug('UID'+UID);
        
        // Instantiate a new http object
        Http binding = new Http();
        HttpResponse res=null;
        
        // Instantiate a new HTTP request
        HttpRequest req = new HttpRequest();      
        req.setHeader('Content-Type','application/x-www-form-urlencoded');
        String curlbody ='userKey='+EncodingUtil.urlEncode(userkey,'UTF-8')+'&secret='+EncodingUtil.urlEncode(secret,'UTF-8')+'&apiKey='+EncodingUtil.urlEncode(apiKey,'UTF-8')+'&UID='+EncodingUtil.urlEncode(UID,'UTF-8')+'&isActive='+EncodingUtil.urlEncode(status,'UTF-8');  
        system.debug('curlbody++'+curlbody);
        req.setBody(curlbody);
        req.setEndpoint(endpointURL);  
        req.setTimeout(120000);
        req.setMethod('POST');  
        
        try {
            
            res = binding.send(req);
             
            System.Debug('Status code ::: '+res.getstatusCode());
            System.Debug('response ::: '+res);
            System.Debug('response headers ::: '+res.getHeaderKeys());
            System.Debug('response header ::: '+res.getHeader('X-CLA-Code'));
            
            response = res.getBody();
            responseAPI resAPI = (responseAPI)JSON.deserialize(response, responseAPI.class);
            System.debug('response Body ::: '+response);
            System.Debug('responseData ::: '+resAPI.statusCode);
            
             // Parse the JSON response getStatusCode
            if (resAPI.statusCode == '200') {
                System.debug('User has been decativated from CDC successfully');              
                success = true;
                
            }
            else {   
                System.debug('The status code returned was not expected: ' + res.getStatusCode() + ' ' + res.getStatus());
            }
        }catch(Exception e){
            system.debug('Exception Cause::'+e.getCause());
            system.debug('Exception LineNumber::'+e.getLineNumber());
            system.debug('Exception Message::'+e.getMessage());
            system.debug('Exception StackTrace::'+e.getStackTraceString());
            system.debug('Exception TypeName::'+e.getTypeName());
            YG_Utility.logError('CDC UpdatePassword API','Community Component Error',e.getStackTraceString(),
                               'Class:YG_UpdatePasswordCDCAPI; Method: getUpdatePassword(); Line #:'+e.getLineNumber()
                                +'; Message:'+e.getMessage(),
                               UserInfo.getUserId());
        }
        
        

    }

     public class responseAPI {
		public String statusCode;        
    }
    
}