/********************************************************************************************************
* (C) Copyright 2020 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Jayaprasath
* @version 1.0
* @created 12/22/2020
* @description 
* This class is used to call the CDC API to Reset Password.
*
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  
*
*/

public class YG_ResetPasswordCDCAPI {
    @AuraEnabled
    public static Boolean getResetPassword(String pswrdResetToken, String newPswrd){
        system.debug('pswrdResetToken**'+pswrdResetToken);
        system.debug('newPswrd**'+newPswrd);
        
        // Call Custom Setting to get the CDC API Config keys
        Map<String, YG_Community_Configuration__c> allValues = new Map<String, YG_Community_Configuration__c>();        
        allValues = YG_Community_Configuration__c.getAll();
        String secret = allValues.get('CDC Secret Key').Text_1__c;
        String apiKey = allValues.get('CDC APIKey').Text_1__c;
        String endpointURL = allValues.get('CDC resetPassword Endpoint URL').Text_1__c;
        String passwordResetToken = pswrdResetToken;
        String newPassword = newPswrd;
        String response = '';
        Boolean success = false;
        
        // Instantiate a new http object
        Http binding = new Http();
        HttpResponse res=null;
        
        // Instantiate a new HTTP request
        HttpRequest req = new HttpRequest();      
        req.setHeader('Content-Type','application/x-www-form-urlencoded');
        String curlparam = endpointURL+'?apiKey='+EncodingUtil.urlEncode(apiKey,'UTF-8')+'&passwordResetToken='+EncodingUtil.urlEncode(passwordResetToken,'UTF-8')+'&newPassword='+EncodingUtil.urlEncode(newPassword,'UTF-8');  
        req.setEndpoint(curlparam);  
        req.setTimeout(120000);
        req.setMethod('GET'); 
        
        try {
            
             res = binding.send(req);
           
            System.Debug('Status code ::: '+res.getStatusCode());
            System.Debug('response ::: '+res);
            System.Debug('response headers ::: '+res.getHeaderKeys());
            System.Debug('response header ::: '+res.getHeader('X-CLA-Code'));
           
            response = res.getBody();
            responseAPI resAPI = (responseAPI)JSON.deserialize(response, responseAPI.class);
            System.debug('response Body ::: '+response);
            System.Debug('responseData ::: '+resAPI.statusCode);
            
             // Parse the JSON response getStatusCode
            if (resAPI.statusCode == '200') {
                response = JSON.serializePretty( JSON.deserializeUntyped(res.getBody())); 
                System.debug('response Body ::: '+response);
                System.debug('Password Reset Successfully');
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
            YG_Utility.logError('CDC ResetPassword API','Community Component Error',e.getStackTraceString(),
                               'Class:YG_ResetPasswordCDCAPI; Method: getResetPassword(); Line #:'+e.getLineNumber()
                                +'; Message:'+e.getMessage(),
                               UserInfo.getUserId());
        }
        
        return success;
    }   

    public class responseAPI {
		public String statusCode;        
    }
}