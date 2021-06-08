/********************************************************************************************************
* (C) Copyright 2020 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Jayaprasath
* @version 1.0
* @created 11/30/2020
* @description 
* This class is used to call the CDC API for Account.
*
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  
*
*/

public class YG_AccountCDCAPI {
    
    
    public static User userInformation =  YG_Utility.getLoggedInUserInfo(UserInfo.getUserId());
    
    public static void getAccountInfo(List<YG_WebHookRestResource.EventWrapper> eventList){
        
        for(YG_WebHookRestResource.EventWrapper eventWrapperObj : eventList){
            YG_GetAccountCDCAPI.getAccountAPIInfo(eventWrapperObj.uid);
        }
        
    }
    
    
    public static void callAccountAPIInfo(String response){
        system.debug('callAccountAPIInfo::response***'+response);
        
        // Call Custom Setting to get the CDC API Config keys
        Map<String, YG_Community_Configuration__c> allValues = new Map<String, YG_Community_Configuration__c>();        
        allValues = YG_Community_Configuration__c.getAll();
        String selfRegAccId = allValues.get('YGSelfRegisterAccountId').Text_1__c;
        Id profileId = allValues.get('Customer Portal User ProfileId').Text_1__c;
        Id contactonwerId = allValues.get('Admin SoE').Text_1__c;
        String errorNote = '';
        List<String> EmailTo = new List<String>();
        
        try {
            
            Map<String, Object> resObj = (Map<String, Object>) JSON.deserializeUntyped(response);
            System.debug('resObj::'+resObj);
            Map<String, Object> resprofile = (Map<String, Object>)resObj.get('profile');
            Map<String, Object> resphone = (Map<String, Object>)resprofile.get('phones');
            String phonenumber;
            if(String.valueOf(resphone) != null){
                phonenumber = String.valueOf(resphone).substringAfter('=');//get the phone number from response
            }
            Map<String, Object> resdata = (Map<String, Object>)resObj.get('data');
            Map<String, Object> resCustomerPortal = (Map<String, Object>)resdata.get('customerportal');
            System.debug('resCustomerPortal.plantList::'+resCustomerPortal);
            String resplantList = (String)resCustomerPortal.get('plantList');
            System.debug('resplantList::'+resplantList);
            List<plantList> plantDetList=new List<plantList>();
            if(resplantList != null){
                List<YG_AccountCDCAPI.plantList> plantDeserialize = (List<YG_AccountCDCAPI.plantList>)JSON.deserialize(resplantList, List<YG_AccountCDCAPI.plantList>.class);
                System.debug('plantDeserialize::'+plantDeserialize);
                for(YG_AccountCDCAPI.plantList res: plantDeserialize ){
                    plantList pla=new plantList();
                    pla.plantCode = res.plantCode;
                    pla.plantName = res.plantName;
                    plantDetList.add(pla);
                }
                System.debug('plantDetList::'+plantDetList);
            }
            AccountAPIResponseWrapper accResponse = (AccountAPIResponseWrapper)JSON.deserialize(response, AccountAPIResponseWrapper.class);                
            System.debug('accResponse::'+accResponse);
            
            Boolean inviteFlag = false;
            Id accountID;//to store the self register account id
            Id getAccId;// to get account id to map contact
            Id getConid;
            Id accConId;
            List<Account> accVerify= new List<Account>();
            List<Contact> conUID = [Select id,Gigya_UID__c from Contact where Gigya_UID__c =: accResponse.uid];
            //to setup user locale .
            User_Locale_Settings__mdt userLocale = new User_Locale_Settings__mdt();
            userLocale = [select EmailEncodingKey__c, LanguageLocaleKey__c, LocaleSidKey__c, 
                          TimeZoneSidKey__c from User_Locale_Settings__mdt 
                          where MasterLabel =: accResponse.data.language ];
            
            //check Response email id is verified before inserting into SFDC
            if(!accResponse.emails.verified.isEmpty()){
                
                //verify CDC account_number is null to identify self register user
                if(accResponse.data.account_number == null){
                    accountID = selfRegAccId;
                }
                else{
                    accVerify = [Select id from Account where AccountNumber =: accResponse.data.account_number];
                }
                System.debug('accVerify::'+accVerify);
                //verify existing account_number before inserting into SFDC
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
                
                //verify Response UID with SFDC Contact UID field before inserting into SFDC
                if(conUID.size() == null || conUID.size() == 0){
                    
                    //check for existing contact with same email
                    List<Contact> existCon = [Select Id From Contact Where Email = :accResponse.profile.email Limit 1];
                    System.debug('existCon'+existCon);
                    //create contact
                    Contact con = new Contact();
                    if(existCon.size() > 0 && !existCon.isEmpty()){
                        con.Id = existCon[0].Id;
                    }
                    String Name;
                    Name = accResponse.profile.firstName+accResponse.profile.lastName;
                    EmailTo.add(accResponse.profile.email);                       
                    con.Lastname = accResponse.profile.lastName; 
                    con.FirstName = accResponse.profile.firstName;
                    con.Company_Name__c = accResponse.data.companyname;
                    con.Email = accResponse.profile.email;
                    con.Gigya_UID__c = accResponse.UID;
                    con.AccountId = getAccId;
                    if(phonenumber != null){
                        con.Phone = phonenumber.substringBeforeLast('}');
                    }
                    if(accResponse.data.customerportal.role != null || accResponse.data.customerportal.role != ''){
                        con.Portal_User_Roles__c = accResponse.data.customerportal.role;    
                    }
                    else{
                        if(accResponse.data.idportal_auth == '1'){
                            con.Portal_User_Roles__c = 'CA';
                        }
                        if(accResponse.data.idportal_auth == '0'){
                            con.Portal_User_Roles__c = 'CU';
                        }                            
                    }
                    con.MailingStreet = accResponse.profile.address;
                    con.MailingCity = accResponse.profile.city;
                    con.MailingState = accResponse.profile.state;
                    con.MailingPostalCode = accResponse.profile.zip;
                    con.MailingCountry = accResponse.profile.country;
                    con.Title = accResponse.data.job_title;
                    con.Profile_Image__c = accResponse.profile.photoURL;
                    con.OwnerId = contactonwerId;
                    Upsert con;
                    

                    
                    //to update all the plant as approved for invite admin user 
                    getConid = con.id;
                    if(getAccId != null && getConid != null){
                        AccountContactRelation accConRel = [Select Id from AccountContactRelation Where AccountId =:getAccId And ContactId=:getConid Limit 1 ];
                        accConId = accConRel.id;
                    }
                    Boolean isExecute = false; //This variable is use to check execute or not the acc con relation insertion from response.
                    Map<String, Id> plantAccMap=new Map<String, Id>(); // This map is used to store the existing plantAcc map
                    List<AccountContactRelation> accContNewRel=new List<AccountContactRelation>(); //To inset the list of plant form response
                    List<AccountContactRelation> accContNewRelupdate=new List<AccountContactRelation>(); //To update the customer account asset associated record
                    
                    //plantListResp = accResponse.data.customerportal.plantList;
                    if(inviteFlag = true){
                        //To get the Account Contact relation for the contact
                        List<AccountContactRelation> accContRel = YG_HelperClass.getCusPlantInfo(getConid);
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
                                	//This is for the direct account update for 
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
                        }else{
                            if(inviteFlag = true && con.Portal_User_Roles__c != 'CU'){
                                YG_ManageColleaguesController.getAdminPlant(getConid,getAccId);
                            }
                        }
                    }
                    
                    //check for existing user with same username
                    System.debug('accResponse.profile.email::'+accResponse.profile.email);
                    List<User> existUser = [Select Id From User Where Username = :accResponse.profile.email Limit 1];
                    System.debug('existUser::'+existUser);
                    User us = new User();
                    if(existUser.size() > 0 && !existUser.isEmpty()){
                        //update existing user
                        us.Id = existUser[0].Id;
                        String nicknm;
                        us.Lastname = accResponse.profile.lastName;
                        us.FirstName = accResponse.profile.firstName;
                        us.Alias = accResponse.profile.firstName.substring(0,1)+accResponse.profile.lastName.substring(0,1);
                        us.Email = accResponse.profile.email;
                        us.Username = accResponse.profile.email;
                        us.FederationIdentifier = accResponse.profile.email;
                        //validate the nickname 
                        nicknm = accResponse.profile.email.SubStringBefore('@') +'_'+math.random();
                        if(nicknm.length() <= 40){
                            us.CommunityNickname =   nicknm;  
                        }
                        else{
                            us.CommunityNickname =   nicknm.substring(0,40);
                        }                        
                        us.ContactId = con.Id;
                        if(phonenumber != null){
                            us.Phone = phonenumber.substringBeforeLast('}');
                        }
                        us.Street = accResponse.profile.address;
                        us.City = accResponse.profile.city;
                        us.State = accResponse.profile.state;
                        us.PostalCode = accResponse.profile.zip;
                        us.Country = accResponse.profile.country;                        
                        us.TimeZoneSidKey = userLocale.TimeZoneSidKey__c;                            
                        us.LocaleSidKey = userLocale.LocaleSidKey__c;                            
                        us.EmailEncodingKey = userLocale.EmailEncodingKey__c;                            
                        us.ProfileId = profileId;
                        us.LanguageLocaleKey = userLocale.LanguageLocaleKey__c;                             
                        Update us;
                    }else{
                        //create new user
                        String nicknm;
                        us.Lastname = accResponse.profile.lastName;
                        us.FirstName = accResponse.profile.firstName;
                        us.Alias = accResponse.profile.firstName.substring(0,1)+accResponse.profile.lastName.substring(0,1);
                        us.Email = accResponse.profile.email;
                        us.Username = accResponse.profile.email;
                        us.FederationIdentifier = accResponse.profile.email;
                        //validate the nickname 
                        nicknm = accResponse.profile.email.SubStringBefore('@') +'_'+math.random();
                        if(nicknm.length() <= 40){
                            us.CommunityNickname =   nicknm;  
                        }
                        else{
                            us.CommunityNickname =   nicknm.substring(0,40);
                        }                        
                        us.ContactId = con.Id;
                        if(phonenumber != null){
                            us.Phone = phonenumber.substringBeforeLast('}');
                        }
                        us.Street = accResponse.profile.address;
                        us.City = accResponse.profile.city;
                        us.State = accResponse.profile.state;
                        us.PostalCode = accResponse.profile.zip;
                        us.Country = accResponse.profile.country;                        
                        us.TimeZoneSidKey = userLocale.TimeZoneSidKey__c;                            
                        us.LocaleSidKey = userLocale.LocaleSidKey__c;                            
                        us.EmailEncodingKey = userLocale.EmailEncodingKey__c;                            
                        us.ProfileId = profileId;
                        us.LanguageLocaleKey = userLocale.LanguageLocaleKey__c;                             
                        Insert us;
                    }
                   
                    
                    //send email notification to the user after user insertion in SFDC 
                    OrgWideEmailAddress[] owa = [select Id from OrgWideEmailAddress where Address =: Label.YG_Email_From_Address ];
                    EmailTemplate templateId = [Select id from EmailTemplate where name =: Label.YG_YG_iCP_Account_Creation_Email_Temp];                        
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setTemplateID(templateId.Id);
                    mail.setSaveAsActivity(false);
                    mail.setOrgWideEmailAddressId(owa.get(0).Id);
                    mail.setToAddresses(EmailTo);            
                    mail.setTargetObjectId(us.id);
                    mail.setWhatId(us.id);
                    Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {mail};  
                        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                    if (results[0].success) 
                    {
                        errorNote = 'The email was sent successfully.';
                        System.debug(errorNote);
                    } else {
                        errorNote = 'The email failed to send: ' +  results[0].errors[0].message;
                        System.debug(errorNote);
                    }  
                    
                }
                else{
                    errorNote = 'UID - '+ accResponse.uid +' already exist in SFDC';
                    system.debug(errorNote); 
                    YG_Update_Contact_User.updateContact(response);
                    YG_Update_Contact_User.updateUser(response);
                } 
                
            }
            else{
                errorNote = accResponse.profile.email + ' - Email id is not verified';
                system.debug(errorNote); 
            }
            
        } catch(Exception e){
            system.debug('Exception Cause::'+e.getCause());
            system.debug('Exception LineNumber::'+e.getLineNumber());
            system.debug('Exception Message::'+e.getMessage());
            system.debug('Exception StackTrace::'+e.getStackTraceString());
            system.debug('Exception TypeName::'+e.getTypeName());
            YG_Utility.logError('CDC API','Community Component Error',e.getStackTraceString(),
                                'Class:YG_AccountCDCAPI; Method: callAccountAPIInfo(); Line #:'+e.getLineNumber()
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