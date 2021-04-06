/********************************************************************************************************
* (C) Copyright 2020 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Jayaprasath
* @version 1.0
* @created 12/23/2020
* @description 
* This class is used to call the CDC API to Logout.
*
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  
*
*/

public class YG_LogoutCDCAPI {
    
    public static User userInformation =  YG_Utility.getLoggedInUserInfo(UserInfo.getUserId());
   
public pagereference checkSession(){
    system.debug('checkSession');
    Id conId = userInformation.Contact.Id;//get logged user contact id
    YG_LogoutCDCAPI.YG_LogoutCDCAPI(conId);
    return null;
}
//@future(callout = true)
public static void  YG_LogoutCDCAPI(id contactId){
    // Call Custom Setting to get the CDC API Config keys
        Map<String, YG_Community_Configuration__c> allValues = new Map<String, YG_Community_Configuration__c>();        
        allValues = YG_Community_Configuration__c.getAll();
        String userkey = allValues.get('CDC User Key').Text_1__c;
        String secret = allValues.get('CDC Secret Key').Text_1__c;
        String apiKey = allValues.get('CDC APIKey').Text_1__c;
        String endpointURL = allValues.get('CDC Logout Endpoint URL').Text_1__c;
        String response = '';
        Boolean success = false;
    	Id conId;
        if(contactId != null){
            conId = contactId;
        }else{
            conId = userInformation.Contact.Id;//get logged user contact id
        }        
    	system.debug('Logout contact ID --'+conId);
        String UID = [Select Gigya_UID__c from Contact where id = : conId].Gigya_UID__c;//get logged user Gigya_UID
        system.debug('UID'+UID);
        // Instantiate a new http object
        Http binding = new Http();
        HttpResponse res=null;
        
        // Instantiate a new HTTP request
        HttpRequest req = new HttpRequest();      
        req.setHeader('Content-Type','application/x-www-form-urlencoded');
        String curlbody = 'apiKey='+EncodingUtil.urlEncode(apiKey,'UTF-8')+'&secret='+EncodingUtil.urlEncode(secret,'UTF-8')+'&userkey='+EncodingUtil.urlEncode(userkey,'UTF-8')+'&UID='+EncodingUtil.urlEncode(UID,'UTF-8');  
        req.setBody(curlbody);
        req.setEndpoint(endpointURL);  
        req.setTimeout(120000);
        req.setMethod('POST'); 
        
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
                System.debug('Logged out Successfully');
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
            YG_Utility.logError('CDC Logout API','Community Component Error',e.getStackTraceString(),
                               'Class:YG_LogoutCDCAPI; Method: logoutmethod(); Line #:'+e.getLineNumber()
                                +'; Message:'+e.getMessage(),
                               UserInfo.getUserId());
        }   
    //return success;
     
 }
    public class responseAPI {
		public String statusCode;        
    }

}