/********************************************************************************************************
* (C) Copyright 2020 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Jayaprasath
* @version 1.0
* @created 01/04/2021
* @description 
* This class is used to call the CDC API to Set user as Admin.
*
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  
*
*/

public class YG_SetAdminCDCAPI {
    
    public static User userInformation =  YG_Utility.getLoggedInUserInfo(UserInfo.getUserId());
    
    @future(callout = true)
    public static void getUpdateAdmin(List<Id> contactId,String role,String idPortal,String plants){
        system.debug('role**'+role);
        system.debug('Plants**'+plants);
        
        // Call Custom Setting to get the CDC API Config keys
        Map<String, YG_Community_Configuration__c> allValues = new Map<String, YG_Community_Configuration__c>();        
        allValues = YG_Community_Configuration__c.getAll();
        String userkey = allValues.get('CDC User Key').Text_1__c;
        String secret = allValues.get('CDC Secret Key').Text_1__c;
        String apiKey = allValues.get('CDC APIKey').Text_1__c;
        String endpointURL = allValues.get('CDC setAccountInfo Endpoint URL').Text_1__c;
        String response = '';
        String errorNote = '';
        String UID = [Select Gigya_UID__c from Contact where id in: contactId and status__c =: true].Gigya_UID__c;//get logged user Gigya_UID
        system.debug('UID'+UID);
       
        data dataAPI =new data();//Wrapper initialization
        List<customerportal> cpList = new List<customerportal>();
        customerportal cp = new customerportal();
        String jsonString;
        String jsonRequestBody;
        
        if(Plants == ''){
        dataAPI.idportal_auth = idPortal;
        cp.role = role;
        cpList.add(cp);
        //dataAPI.customerportal = cpList; 
        jsonString = '{"idportal_auth":"'+idPortal+'","customerportal":{"role":"'+role+'"}}';
        jsonRequestBody = JSON.serialize(dataAPI);
        }else{
            //{customerportal:{'plantList':'[{"plantCode": "300000170","plantName": "Chevron Wheatstone Downstream OTS1"}]'}}
            jsonString = '{"customerportal":{"plantList":\''+plants+'\'}}';
            jsonRequestBody = JSON.serialize(dataAPI);
        }
        
        system.debug('data ::'+dataAPI);
        system.debug('jsonString ::'+jsonString);
        system.debug('jsonRequestBody ::'+jsonRequestBody);
        
        
        // Instantiate a new http object
        Http binding = new Http();
        HttpResponse res=null;
        
        // Instantiate a new HTTP request
        HttpRequest req = new HttpRequest();      
        req.setHeader('Content-Type','application/x-www-form-urlencoded');
        String curlbody ='userKey='+EncodingUtil.urlEncode(userkey,'UTF-8')+'&secret='+EncodingUtil.urlEncode(secret,'UTF-8')+'&apiKey='+EncodingUtil.urlEncode(apiKey,'UTF-8')+'&UID='+EncodingUtil.urlEncode(UID,'UTF-8')+'&data='+EncodingUtil.urlEncode(jsonString,'UTF-8');  
        system.debug('curlbody++'+curlbody);
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
                errorNote = 'Role updated Sucessfully';
                system.debug(errorNote);
            }
            else { 
                errorNote = 'The status code returned was not expected: ' + res.getStatusCode() + ' ' + res.getStatus();
                System.debug(errorNote);
            }
        }catch(Exception e){
            system.debug('Exception Cause::'+e.getCause());
            system.debug('Exception LineNumber::'+e.getLineNumber());
            system.debug('Exception Message::'+e.getMessage());
            system.debug('Exception StackTrace::'+e.getStackTraceString());
            system.debug('Exception TypeName::'+e.getTypeName());
            YG_Utility.logError('CDC Set Admin API','Community Component Error',e.getStackTraceString(),
                               'Class:YG_SetAdminCDCAPI; Method: getUpdateAdmin(); Line #:'+e.getLineNumber()
                                +'; Message:'+e.getMessage(),
                               UserInfo.getUserId());
        }
        
    }   
    
    public class responseAPI {
		public String statusCode;        
    }
    
    public class data {
		public customerportal customerportal;
        public String idportal_auth;
    }
    public class customerportal{
        public String role = 'CA';
        public List<plantList> plantList;
    }
    public class plantList{
        public String plantCode;
        public String plantName;
    }

}