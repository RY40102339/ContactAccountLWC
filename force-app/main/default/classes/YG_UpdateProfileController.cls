/*
*******************************************************************************************************
* (C) Copyright 2020 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Selvaraj T
* @version 1.0
* @created 29/09/2020
* @description 
* This class is used to update the contact profile details.
*
* @test class name - YG_UpdateProfileControllerTest
*
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  
*
*/

public class YG_UpdateProfileController {
    
    public static User userInformation =  YG_Utility.getLoggedInUserInfo(UserInfo.getUserId());

    /**
	 *This method is used to get the logged in user's contact details.
     *
	 **/
    @AuraEnabled
    public static contact getContactDetails(){
        
        //Get contact id of logged in user
        Id conId = userInformation.ContactId;
        Contact con = new Contact();
        
        try{
            con = [Select Id,FirstName, LastName, Email, Phone, Calibration_Subscription__c, Contract_Subscription__c,
                   Newsletter1_Subscription__c, Newsletter2_Subscription__c, Newsletter3_Subscription__c, 
                   Profile_Update_Subscription__c, Service_Request_Subscription__c, Software_Request_Subscription__c,
                   Profile_Image__c From Contact where Id =: conId and status__c =: true];
            system.debug('con::'+con);
          	
            if(con.FirstName == null){
                con.FirstName = '';
            }
            if(con.Email == null){
                con.Email = '';
            }
            if(con.Phone == null){
                con.Phone = '';
            }
            if(con.Profile_Image__c == null){
                con.Profile_Image__c = '';
            }            
        }
        catch(Exception e){
            system.debug('Exception Cause::'+e.getCause());
            system.debug('Exception LineNumber::'+e.getLineNumber());
            system.debug('Exception Message::'+e.getMessage());
            system.debug('Exception StackTrace::'+e.getStackTraceString());
            system.debug('Exception TypeName::'+e.getTypeName());
            YG_Utility.logError('GetContactDetails','Community Component Error',e.getStackTraceString(),
                               'Class:YG_UpdateProfileController; Method: getContactDetails(); Line #:'+e.getLineNumber()+'; Message:'+e.getMessage(),
                               UserInfo.getUserId());
        }
        
        return con;
    }
    
    /**
	 *This method is used to update the logged in user's contact details.
     *
	 **/
    @AuraEnabled
    public static Boolean updateContactData(Contact cont,String strFileName, String base64Data){
        
        system.debug('cont** '+cont);
        system.debug('strFileName** '+strFileName);
        system.debug('base64Data** '+base64Data);
        Boolean isSuccess = false;
        Document myDocument = new Document();
        String url ;

        try{
            
            if(strFileName != null){                
                // Decoding base64Data
                base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
                
                //Get contact id of logged in user
                Id conId = userInformation.ContactId;
                Contact con = [Select id from Contact where id =: conId and Status__c =: true];
                
                Folder dummyFolder = [SELECT Id FROM Folder where name =: 'Profile Image'];
                
                myDocument.FolderId = dummyFolder.id;        
                myDocument.Body = EncodingUtil.base64Decode(base64Data);        
                myDocument.ContentType = 'image/jpg';        
                myDocument.Name = conId+'_'+strFileName;
                myDocument.IsPublic = true;        
                insert myDocument;
                
                Map<String, YG_Community_Configuration__c> allValues = new Map<String, YG_Community_Configuration__c>();
                allValues = YG_Community_Configuration__c.getAll();
                String basURL = allValues.get('YG Customer Portal Base URL').Text_1__c;
                url = basURL+'/servlet/servlet.ImageServer?id='+myDocument.id+'&oid='+UserInfo.getOrganizationId ();
                system.debug('url'+url); 
            }
            
            
            if(cont.id != null){
                //Update cont;
                YG_UpdateProfileCDCAPI.getUpdateProfile(cont.FirstName, cont.LastName, cont.Email, cont.Phone, url);
                isSuccess = true;
                System.debug('User details has been sent to update in CDC');
            }else{
                isSuccess = false;
            }
            
        }
        catch(Exception e){
            system.debug('Exception Cause::'+e.getCause());
            system.debug('Exception LineNumber::'+e.getLineNumber());
            system.debug('Exception Message::'+e.getMessage());
            system.debug('Exception StackTrace::'+e.getStackTraceString());
            system.debug('Exception TypeName::'+e.getTypeName());
            YG_Utility.logError('UpdateContactDetails','Community Component Error',e.getStackTraceString(),
                               'Class:YG_UpdateProfileController; Method: updateContactData(); Line #:'+e.getLineNumber()+'; Message:'+e.getMessage(),
                               UserInfo.getUserId());
        }
        
        return isSuccess;
        
    }
    
 //this method is used to validate email in update profile page
    @AuraEnabled
    public static emailValidationWap emailValidate(String email) {
        system.debug('email**'+email);
        emailValidationWap emailWap =new emailValidationWap();
        String conEmail = userInformation.Contact.email;
         system.debug('conEmail**'+conEmail);
        try{
            List<User> us = [select username from user where username =: email];
            
            if (us.size()>=1){                
                for(User u:us){
                    if(u.username == conEmail){
                        emailWap.exist = false;
                        emailWap.newemail = false;
                        system.debug('No change in email');
                    }
                    else{
                        emailWap.exist = true;
                        system.debug('Email id already exist');
                    }
                }
            }
            else{
                emailWap.exist = false;
                emailWap.newemail = true;
                emailWap.newemailid = email;
                system.debug('New email id found');
            }
        }
         catch(Exception e){
            system.debug('Exception Cause::'+e.getCause());
            system.debug('Exception LineNumber::'+e.getLineNumber());
            system.debug('Exception Message::'+e.getMessage());
            system.debug('Exception StackTrace::'+e.getStackTraceString());
            system.debug('Exception TypeName::'+e.getTypeName());
            YG_Utility.logError('To validate Email','Community Component Error',e.getStackTraceString(),
                               'Class:YG_UpdateProfileController; Method: emailValidate(); Line #:'+e.getLineNumber()+'; Message:'+e.getMessage(),
                               UserInfo.getUserId());
        }
        return emailWap;
    }
   
      public class emailValidationWap {
		 @AuraEnabled public Boolean exist = false; 
         @AuraEnabled public Boolean newemail = false;
         @AuraEnabled public String newemailid;
    }      
    
}