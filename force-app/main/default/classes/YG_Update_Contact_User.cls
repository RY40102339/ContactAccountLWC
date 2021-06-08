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
* This class is used to update the contact and .
*
*  Change History:
*  MM/DD/YYYY           Developer Name          Comments
*  
*
*/

public class YG_Update_Contact_User {
    //@future(callout = true)
    public static void updateContact(String response){
        system.debug('updateContact::response***'+response);
        String errorNote = '';
        try {
            Map<String, YG_Community_Configuration__c> allValues = new Map<String, YG_Community_Configuration__c>();        
            allValues = YG_Community_Configuration__c.getAll();
            String selfRegAccId = allValues.get('YGSelfRegisterAccountId').Text_1__c;
            
            Map<String, Object> resObj = (Map<String, Object>) JSON.deserializeUntyped(response);
            Map<String, Object> resprofile = (Map<String, Object>)resObj.get('profile');
            Map<String, Object> resphone = (Map<String, Object>)resprofile.get('phones');
            String phonenumber;
            if(String.valueOf(resphone) != null){
                phonenumber = String.valueOf(resphone).substringAfter('=');//get the phone number from response
            }
            String phNo;
            if(phonenumber != null){
                phNo = phonenumber.substringBeforeLast('}');
            }
            Map<String, Object> resdata = (Map<String, Object>)resObj.get('data');
            Map<String, Object> resCustomerPortal = (Map<String, Object>)resdata.get('customerportal');
            System.debug('resCustomerPortal.plantList::'+resCustomerPortal);
            String resplantList = (String)resCustomerPortal.get('plantList');
            System.debug('resplantList::'+resplantList);
            List<plantList> plantDetList=new List<plantList>();
            if(resplantList != null){
                List<YG_Update_Contact_User.plantList> plantDeserialize = (List<YG_Update_Contact_User.plantList>)JSON.deserialize(resplantList, List<YG_Update_Contact_User.plantList>.class);
                System.debug('plantDeserialize::'+plantDeserialize);
                for(YG_Update_Contact_User.plantList res: plantDeserialize ){
                    plantList pla=new plantList();
                    pla.plantCode = res.plantCode;
                    pla.plantName = res.plantName;
                    plantDetList.add(pla);
                }
                System.debug('plantDetList::'+plantDetList);    
            }
            AccountAPIResponseWrapper accResponse = (AccountAPIResponseWrapper)JSON.deserialize(response, AccountAPIResponseWrapper.class);
            
            Id accountID;//to store the self register account id
            Id getAccId;// to get account id to map contact
            Boolean updateFlag = false;
            List<Account> accVerify= new List<Account>();
            
            Contact con = [Select id,Lastname,FirstName,Email,Phone,Portal_User_Roles__c,MailingStreet,
                           MailingCity,MailingState,MailingPostalCode,MailingCountry,Title,Profile_Image__c
                           from Contact where Gigya_UID__c =: accResponse.uid];
            Contact updateContact =new Contact();
            updateContact.id = con.id;
            Boolean inviteFlag = false;
            Id getConid;
			Id accConId;            
            
            //verify CDC account_number is null to identify self register user
            if(accResponse.data.account_number == null){
                accountID = selfRegAccId;
            }
            else{
                accVerify = [Select id from Account where AccountNumber =: accResponse.data.account_number];
            }
            //check Response email id is verified before updating into SFDC
            if(!accResponse.emails.verified.isEmpty()){
                
                //verify existing account_number before updating into SFDC
                if(accVerify.size() == null || accVerify.size() == 0){
                    getAccId = accountID;   
                }
                else{
                    //Register through Invitation
                    for(Account ac:accVerify){
                        getAccId = ac.Id; 
                        inviteFlag = true;
                    }
                }
                
                if(con.Lastname != accResponse.profile.lastName){
                    updateContact.Lastname = accResponse.profile.lastName; 
                    updateFlag = true;
                }                    
                if(con.FirstName != accResponse.profile.firstName){
                    updateContact.FirstName = accResponse.profile.firstName;
                    updateFlag = true;
                }                        
                if(con.Email != accResponse.profile.email){
                    updateContact.Email = accResponse.profile.email;
                    updateFlag = true;
                }
                if(con.Phone != phNo){
                    //updateContact.Phone = accResponse.data.phone;
                    if(String.valueOf(resphone) != null){
                    updateContact.Phone = phonenumber.substringBeforeLast('}');
                    updateFlag = true;
                    }
                }
                //validate the portal user role 
                if(con.Portal_User_Roles__c != accResponse.data.customerportal.role){
                    if(accResponse.data.customerportal.role != null || accResponse.data.customerportal.role != ''){
                        updateContact.Portal_User_Roles__c = accResponse.data.customerportal.role;    
                    }
                    else{
                        if(accResponse.data.idportal_auth == '1'){
                            updateContact.Portal_User_Roles__c = 'CA';
                        }
                        if(accResponse.data.idportal_auth == '0'){
                            updateContact.Portal_User_Roles__c = 'CU';
                        }                            
                    }
                    updateFlag = true;
                }  
                    //to update all the plant as approved for invite admin user 
                    getConid = con.id;
                    if(getAccId != null && getConid != null){
                        AccountContactRelation accConRel = [Select Id from AccountContactRelation Where AccountId =:getAccId And ContactId=:getConid Limit 1 ];
                        accConId = accConRel.id;
                    }
                    Map<String, Id> plantAccMap=new Map<String, Id>(); // This map is used to store the existing plantAcc map
                    List<AccountContactRelation> accContNewRel=new List<AccountContactRelation>(); //To inset the list of plant form response
                	List<AccountContactRelation> accContNewRelupdate=new List<AccountContactRelation>(); //To update the customer account asset associated record
                    if(inviteFlag = true){
                        //To get the Account Contact relation for the contact
                        List<AccountContactRelation> accContRel = [SELECT ContactId,AccountId,Account.Name,Account.AccountNumber ,Account.ParentId
                        FROM AccountContactRelation WHERE ContactId =: getConid and IsDirect = false];
                        System.debug('accContRel'+accContRel);
                        
                        List<Account> plaAccList = YG_HelperClass.getPlantList(getAccId,'');
                        for(Account plantAcc : plaAccList){
                            plantAccMap.put(plantAcc.AccountNumber, plantAcc.Id);
                            
                        }
                        
                        if(plantDetList.size() > 0 && !plantDetList.isEmpty()){
                            if(accContRel.size() > 0 ){
                                Delete accContRel;
                            }
                            for(plantList plantRes: plantDetList){
                                AccountContactRelation accCon=new AccountContactRelation();
                                if(accResponse.data.account_number == plantRes.plantCode){
                                    if(accConId != null){
                                        accCon.Id = accConId;
                                        accCon.Status__c = 'Approved site access';
                                        accContNewRelupdate.add(accCon);
                                    }
                                }
                                if(plantAccMap.get(plantRes.plantCode) != Null && accResponse.data.account_number != plantRes.plantCode){
                                    accCon.AccountId = plantAccMap.get(plantRes.plantCode);
                                    accCon.ContactId = getConid;
                                    accCon.Status__c = 'Approved site access';
                                    accContNewRel.add(accCon);
                                }
                            }
                            System.debug('accContNewRel::'+accContNewRel);
                            System.debug('accContNewRelupdate::'+accContNewRelupdate);
                            if(accContNewRelupdate.size() > 0){
                                update accContNewRelupdate;
                            }
                            if(accContNewRel.size() > 0){
                                Insert accContNewRel;
                            }
                            updateFlag = true;
                        }else{
                            System.debug('inside1');
                            if(inviteFlag = true && con.Portal_User_Roles__c != 'CU'){
                            YG_ManageColleaguesController.getAdminPlant(getConid,getAccId);
                            updateFlag = true;
                            }
                        }
                        
                    }
                                     
                if(con.MailingStreet != accResponse.profile.address){
                    updateContact.MailingStreet = accResponse.profile.address;
                    updateFlag = true;
                }                        
                if(con.MailingCity != accResponse.profile.city){
                    updateContact.MailingCity = accResponse.profile.city;
                    updateFlag = true;
                }                        
                if(con.MailingState != accResponse.profile.state){
                    updateContact.MailingState = accResponse.profile.state;
                    updateFlag = true;
                }                        
                if(con.MailingPostalCode != accResponse.profile.zip){
                    updateContact.MailingPostalCode = accResponse.profile.zip;
                    updateFlag = true;
                }                        
                if(con.MailingCountry != accResponse.profile.country){
                    updateContact.MailingCountry = accResponse.profile.country;
                    updateFlag = true;
                }                         
                if(con.Title != accResponse.data.job_title){
                    updateContact.Title = accResponse.data.job_title;  
                    updateFlag = true;
                }                        
                if(con.Profile_Image__c != accResponse.profile.photoURL){
                    updateContact.Profile_Image__c = accResponse.profile.photoURL;
                    updateFlag = true;
                }
                
                if(updateFlag == true){
                    system.debug('updateContact** '+updateContact);
                    update updateContact;
                    errorNote = 'Contact obj in SFDC has been updated Sucessfully';
                    system.debug(errorNote);
                }
                else{
                    errorNote = 'No modification in SFDC Contact fields';
                    system.debug(errorNote);
                }
            }
            else{
                errorNote = 'Email is not verified';
                system.debug(errorNote);    
            }               
            
            
        } catch(Exception e){
            system.debug('Exception Cause::'+e.getCause());
            system.debug('Exception LineNumber::'+e.getLineNumber());
            system.debug('Exception Message::'+e.getMessage());
            system.debug('Exception StackTrace::'+e.getStackTraceString());
            system.debug('Exception TypeName::'+e.getTypeName());
            YG_Utility.logError('Update Contact','Community Component Error',e.getStackTraceString(),
                                'Class:YG_Update_Contact_User; Method: updateContact(); Line #:'+e.getLineNumber()
                                +';Message:'+e.getMessage() ,
                                UserInfo.getUserId());
        }
        
    }
    
    @future(callout = true)
    public static void updateUser(String response){
        system.debug('updateUser::response***'+response);
        String errorNote = '';
        try {
            Map<String, Object> resObj = (Map<String, Object>) JSON.deserializeUntyped(response);
            Map<String, Object> resprofile = (Map<String, Object>)resObj.get('profile');
            Map<String, Object> resphone = (Map<String, Object>)resprofile.get('phones');
            String phonenumber = String.valueOf(resphone).substringAfter('=');//get the phone number from response
            String phNo;
			if(phonenumber != null){
                phNo = phonenumber.substringBeforeLast('}');
            }
            
            AccountAPIResponseWrapper accResponse = (AccountAPIResponseWrapper)JSON.deserialize(response, AccountAPIResponseWrapper.class);                
            
            Boolean updateFlag = false;
            
            Contact con = [Select id,Lastname,FirstName,Email,Phone,Portal_User_Roles__c,MailingStreet,
                           MailingCity,MailingState,MailingPostalCode,MailingCountry,Title,Profile_Image__c
                           from Contact where Gigya_UID__c =: accResponse.uid];
            System.debug('con:::'+con);
            System.debug('accResponse.uid'+accResponse.uid);
            User us = [Select id from User where contactid =: con.id];
            User updateUser = new User();
            updateUser.id = us.id;
            //to setup user locale 
            User_Locale_Settings__mdt userLocale = new User_Locale_Settings__mdt();
            userLocale = [select EmailEncodingKey__c, LanguageLocaleKey__c, LocaleSidKey__c, TimeZoneSidKey__c from User_Locale_Settings__mdt where MasterLabel =: accResponse.data.language ];
            Boolean inviteFlag = false;
            
            //check Response email id is verified before updating into SFDC
            System.debug('accResponse.emails.verified::'+accResponse.emails.verified);
            if(!accResponse.emails.verified.isEmpty()){
                
                System.debug('con.Lastname::'+con.Lastname);
                System.debug('accResponse.profile.lastName::'+accResponse.profile.lastName);
                if(con.Lastname != accResponse.profile.lastName){
                    updateUser.Lastname = accResponse.profile.lastName;
                    updateFlag = true;
                }
                 System.debug('con.FirstName::'+con.FirstName);
                System.debug('accResponse.profile.firstName::'+accResponse.profile.firstName);
                if(con.FirstName != accResponse.profile.firstName){
                    updateUser.FirstName = accResponse.profile.firstName;
                    updateFlag = true;
                }                        
                if(con.Email != accResponse.profile.email){
                    updateUser.Email = accResponse.profile.email;
                    updateUser.Username = accResponse.profile.email;
                    updateUser.FederationIdentifier = accResponse.profile.email;
                    updateFlag = true;
                }
                if(con.Phone != phNo){
                    //updateUser.Phone = accResponse.data.phone;
                    if(phonenumber != null){
                        updateUser.Phone = phonenumber.substringBeforeLast('}');
                        updateFlag = true;
                    }
                }                    
                if(con.MailingStreet != accResponse.profile.address){
                    updateUser.Street = accResponse.profile.address; 
                    updateFlag = true;
                }                        
                if(con.MailingCity != accResponse.profile.city){
                    updateUser.City = accResponse.profile.city;
                    updateFlag = true;
                }                        
                if(con.MailingState != accResponse.profile.state){
                    updateUser.State = accResponse.profile.state; 
                    updateFlag = true;
                }                        
                if(con.MailingPostalCode != accResponse.profile.zip){
                    updateUser.PostalCode = accResponse.profile.zip;
                    updateFlag = true;
                }                        
                if(con.MailingCountry != accResponse.profile.country){
                    updateUser.Country = accResponse.profile.country;                        
                    updateUser.TimeZoneSidKey = userLocale.TimeZoneSidKey__c;                            
                    updateUser.LocaleSidKey = userLocale.LocaleSidKey__c;                            
                    updateUser.EmailEncodingKey = userLocale.EmailEncodingKey__c;                            
                    updateUser.LanguageLocaleKey = userLocale.LanguageLocaleKey__c;
                    updateFlag = true;
                }
                
                if(updateFlag == true){
                    system.debug('updateUser** '+updateUser);
                    update updateUser;
                    errorNote = 'User obj in SFDC has been updated Sucessfully';
                    system.debug(errorNote);
                }
                else{
                    errorNote = 'No modification in SFDC User fields';
                    system.debug(errorNote);
                }
            }
            else{
                errorNote = 'Email is not verified';
                system.debug(errorNote);    
            }
            
            
            
        } catch(Exception e){
            system.debug('Exception Cause::'+e.getCause());
            system.debug('Exception LineNumber::'+e.getLineNumber());
            system.debug('Exception Message::'+e.getMessage());
            system.debug('Exception StackTrace::'+e.getStackTraceString());
            system.debug('Exception TypeName::'+e.getTypeName());
            YG_Utility.logError('Update USER','Community Component Error',e.getStackTraceString(),
                                'Class:YG_Update_Contact_User; Method: updateUser(); Line #:'+e.getLineNumber()
                                +'; Message:'+e.getMessage(),
                                UserInfo.getUserId());
        }
        
    }
    
    public class AccountAPIResponseWrapper{
        public String callId;
        public String UID;
        public data data;
        public emails emails;           
        public profile profile;         
        public String isActive;
        public String isRegistered;
        public String isVerified;        
    }
    public class data{
        public String account_number;
        public String language;
        public String custportal_userID;
        //public String phone;
        public String companyname;
        public String account;
        public customerportal customerportal;
        public String job_title;
        public String idportal_auth;
    }
    public class customerportal{
        public String role;
    }
    public class emails{
        public List<String> verified;
        public List<String> unverified;
    }
    public class profile{
        public String firstName;
        public String lastName;
        public String email;
        public String city;        
        public String state;
        public String zip;
        public String country;
        public String photoURL;
        public String address;
    }
    public class plantList{
        public String plantName;
        public String plantCode;
    }  
}