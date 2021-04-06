/********************************************************************************************************
* (C) Copyright 2020 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Jayaprasath
* @version 1.0
* @created 01/08/2021
* @description 
* This class is used to call the CDC API to Update Profile.
*
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  
*
*/

public class YG_UpdateProfileCDCAPI {
    
    public static User userInformation =  YG_Utility.getLoggedInUserInfo(UserInfo.getUserId());
    
    @future(callout = true)
    public static void getUpdateProfile(String fName, String lName, String wEmail, String phone, String profileImage){
        
        system.debug('fName**'+fName);        
        system.debug('lName**'+lName);        
        system.debug('wEmail**'+wEmail);        
		system.debug('phone**'+phone);
		system.debug('profileImage**'+profileImage);        
        // Call Custom Setting to get the CDC API Config keys
        Map<String, YG_Community_Configuration__c> allValues = new Map<String, YG_Community_Configuration__c>();        
        allValues = YG_Community_Configuration__c.getAll();
        String userkey = allValues.get('CDC User Key').Text_1__c;
        String secret = allValues.get('CDC Secret Key').Text_1__c;
        String apiKey = allValues.get('CDC APIKey').Text_1__c;
        String endpointURL = allValues.get('CDC setAccountInfo Endpoint URL').Text_1__c;
        String response = '';
        
        Id conId = userInformation.Contact.Id;//get logged user contact id
        //Id conId = '003p000000fK22P';
        String UID = [Select Gigya_UID__c from Contact where id = : conId and status__c =: true].Gigya_UID__c;//get logged user Gigya_UID
        system.debug('UID'+UID);
        
        String uEmail = userInformation.Email;//get logged user Email
        String uFName = userInformation.FirstName;//get logged user FirstName
        String uLname = userInformation.LastName;//get logged user LastName
        String uPhone = userInformation.Contact.Phone;//get logged user Phone
        String uImage = userInformation.Contact.Profile_Image__c ;//get logged user Image
        String removeLoginEmails = '';
        String addLoginEmails = '';
        
        profile profileAPI =new profile();//Wrapper initialization
        data dataAPI =new data();//Wrapper initialization
        
        if(fName != null){
            profileAPI.firstName = fName;
        }
        else{
            profileAPI.firstName = uFName;
        }
        
        if(lName !=null){
            profileAPI.lastName = lName;
        }
        else{
            profileAPI.lastName = uLname;
        }
        
        if(wEmail !=null){
            //to update the new email id
            if(wEmail != uEmail){
                removeLoginEmails = uEmail;
                addLoginEmails = wEmail;
                profileAPI.email = wEmail;
            }
            else{
                 profileAPI.email = uEmail;
            }
        }
        else{
            profileAPI.email = uEmail;
        }
        
        if(profileImage != null){
            profileAPI.photoURL = profileImage;
        }
        else{
            profileAPI.photoURL = uImage;
        }
        
        
        if(phone !=null){
           dataAPI.phone = phone;  
        }
        else{
            dataAPI.phone = uPhone;
        }
        String profile_jsonRequestBody = '{"firstName":"'+profileAPI.firstName+'","lastName":"'+profileAPI.lastName+'","email":"'+profileAPI.email+'","photoURL":"'+profileAPI.photoURL+'","phones":{"number":"'+ dataAPI.phone+'"}}';
        String data_jsonRequestBody = JSON.serialize(dataAPI);
                    
        // Instantiate a new http object
        Http binding = new Http();
        HttpResponse res=null;
        
        // Instantiate a new HTTP request
        HttpRequest req = new HttpRequest();      
        req.setHeader('Content-Type','application/x-www-form-urlencoded');
        String curlbody ='userKey='+EncodingUtil.urlEncode(userkey,'UTF-8')+'&secret='+EncodingUtil.urlEncode(secret,'UTF-8')+'&apiKey='+EncodingUtil.urlEncode(apiKey,'UTF-8')+'&UID='+EncodingUtil.urlEncode(UID,'UTF-8')+'&data='+EncodingUtil.urlEncode(data_jsonRequestBody,'UTF-8')+'&profile='+EncodingUtil.urlEncode(profile_jsonRequestBody,'UTF-8')+'&removeLoginEmails='+EncodingUtil.urlEncode(removeLoginEmails,'UTF-8')+'&addLoginEmails='+EncodingUtil.urlEncode(addLoginEmails,'UTF-8');  
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
                System.debug('User details has been updated successfully in CDC');
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
            YG_Utility.logError('CDC Update Profile API','Community Component Error',e.getStackTraceString(),
                               'Class:YG_UpdateProfileCDCAPI; Method: getUpdateProfile(); Line #:'+e.getLineNumber()
                                +'; Message:'+e.getMessage(),
                               UserInfo.getUserId());
        }
        
    }  
    
    public class responseAPI {
		public String statusCode;        
    }
    
    public class profile {
		public String firstName;
        public String lastName;
        public String email;
        public String photoURL;
    }
    public class data {
		public String phone;
    }
	
}