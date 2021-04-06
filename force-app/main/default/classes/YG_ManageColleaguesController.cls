/*
*******************************************************************************************************
* (C) Copyright 2020 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Jayaprasath
* @version 1.0
* @created 09/07/2020
* @description 
* This class is used to write the methods for ManageColleagues page.
*
* @test class name - YG_ManageColleaguesControllerTest
*
*  Change History:
*  MM/DD/YYYY           Developer Name          Comments
*  
*/

public class YG_ManageColleaguesController {
    
    public static User userInformation =  YG_Utility.getLoggedInUserInfo(UserInfo.getUserId());
    //public static User userInformation =  YG_Utility.getLoggedInUserInfo('005p0000003rbfUAAQ');
    
    //This method is used to get the grid data for ManageColleagues page 
    @AuraEnabled
    public static ManageColleaguesWrapper getManageColleaguesGridDetails(List<Id> clgIdList){
                
        String langCode = YG_CommonUtils.getLanguageCode(userInformation.LanguageLocaleKey); 
        Integer notifyCount = 0;
        
        ManageColleaguesWrapper manageColleaguesWap=new ManageColleaguesWrapper();
        List<ManageColleaguesData> manageColleaguesList=new List<ManageColleaguesData>();
        
             try{
            //To get account and contact Id
            Id accId = userInformation.Contact.AccountId;
            Id conId = userInformation.Contact.Id;
            system.debug('accId::'+accId);
            system.debug('conId::'+conId);
            
            //To get the Customer plant List
                 List<Contact> cusPlantList = new List<Contact>();
                 
                 //this condition is used while filter by name 
                 if(clgIdList.size() > 0 && !clgIdList.isEmpty()){
                     system.debug('clgIdList ::'+clgIdList);
                     cusPlantList = [select name,toLabel(Portal_User_Roles__c),Profile_Image__c, (select Plant__c,Plant__r.Plant_Name__c,Status__c from Customer_Plant__r) from contact where id =: clgIdList and status__c =: true];
                     manageColleaguesWap.totalcontact =cusPlantList.size();
                     system.debug('cusPlantList** ::'+cusPlantList);                     
                  }
                 else{            
                    cusPlantList = [select name,toLabel(Portal_User_Roles__c),Profile_Image__c, (select Plant__c,Plant__r.Plant_Name__c,Status__c from Customer_Plant__r) from contact where accountid =: accId and id !=: conId and status__c =: true];
                     manageColleaguesWap.totalcontact =cusPlantList.size();
                     system.debug('cusPlantList size ::'+manageColleaguesWap.totalcontact);
                 }
                  
                for(Contact csPL:cusPlantList) 
                {  
                    String Name;
                    Map<String,List<String>> approvedPlantMap = new Map<String,List<String>>();
                    List<String> approvedPlantList=new List<String>();
                    Map<String,List<String>> requestedPlantMap = new Map<String,List<String>>();
                    List<String> requestedPlantList=new List<String>();
                    ManageColleaguesData manageColleaguesGridData =new ManageColleaguesData();
                    
                    
                    Name = csPL.Name;
                    manageColleaguesGridData.Id = csPL.Id;
                    manageColleaguesGridData.name = csPL.Name;
                    manageColleaguesGridData.role = csPL.Portal_User_Roles__c;
                    manageColleaguesGridData.profileImage = csPL.Profile_Image__c;
                    
                    for(Customer_Plant__c csPL2:csPL.Customer_Plant__r){
                        //this condition is to check if plant name is not null
                        if(csPL2.Plant__r.Plant_Name__c != null){
                            //this condition is to get only the approved plant name
                            if(csPL2.Status__c == 'Approved site access'){
                                approvedPlantList.add(csPL2.Plant__r.Plant_Name__c);
                                approvedPlantMap.put(Name,approvedPlantList);  
                            }
                            //this condition is to get only the requested plant name
                            if(csPL2.Status__c == 'Request site access'){
                                requestedPlantList.add(csPL2.Plant__r.Plant_Name__c);
                                requestedPlantMap.put(csPL2.Status__c,requestedPlantList); 
                                notifyCount ++;
                            }
                        }
                    } 
                    
                    for(Customer_Plant__c csPL3:csPL.Customer_Plant__r){
                        //this condition is to check if there is no plant assigned for the user 
                        if(csPL3.Status__c != 'Request site access')
                        {
                             manageColleaguesGridData.sites = approvedPlantMap;
                        }
                        
                        if(notifyCount >=1){
                            manageColleaguesGridData.notifications = requestedPlantMap;
                        }
                    }
                   
                     system.debug('notifyCount'+notifyCount);
                     manageColleaguesWap.notificationCount =notifyCount;
                    
                    manageColleaguesList.add(manageColleaguesGridData);
                    manageColleaguesWap.manageColleaguesDataList = manageColleaguesList;
                    system.debug('grid data'+manageColleaguesList);
                }
                 
             }catch(Exception e){
            system.debug('Exception Cause::'+e.getCause());
            system.debug('Exception LineNumber::'+e.getLineNumber());
            system.debug('Exception Message::'+e.getMessage());
            system.debug('Exception StackTrace::'+e.getStackTraceString());
            system.debug('Exception TypeName::'+e.getTypeName());
            YG_Utility.logError('ManageColleagues page','Community Component Error',e.getStackTraceString(),
                                'Class:YG_ManageColleaguesController; Method: getManageColleaguesGridDetails(); Line #:'+e.getLineNumber()+'; Message:'+e.getMessage(),
                                UserInfo.getUserId());
        }
        
        return manageColleaguesWap;
        
    
    }
    
     public class ManageColleaguesWrapper{
        @AuraEnabled public List<ManageColleaguesData> manageColleaguesDataList;
         
         @AuraEnabled public Integer totalcontact;
         @AuraEnabled public Integer notificationCount;
    }
    public class ManageColleaguesData{
        @AuraEnabled public String Id;
        @AuraEnabled public String name;
        @AuraEnabled public String role;
        @AuraEnabled public String profileImage='';
        @AuraEnabled public Map<String,List<String>> sites;
        @AuraEnabled public Map<String,List<String>> notifications = new Map<String,List<String>>();
    }
    
    
    // This method is to display the user details on the popup 
    // This method is used in Manage Colleagues and update profile pages
    @AuraEnabled
    public static UserDetalisWapper getSelectedUserDetail(String conId){
        System.debug('conId::'+conId);
        Id conIds;
        //Condtion to check the contact id is null 
        if(conId == null){
            conIds = userInformation.Contact.Id;
        }
        else{
            conIds = conId;
        }
        
        UserDetalisWapper userDetailsWap=new UserDetalisWapper();
        List<LogAccPlant> logAccPlantList=new List<LogAccPlant>();
        List<popupplantDet> popupplantList=new List<popupplantDet>();
        
        try{
        Id accId = userInformation.Contact.AccountId;
        String langCode = YG_CommonUtils.getLanguageCode(userInformation.LanguageLocaleKey); 
        
            Map<String, YG_Community_Configuration__c> allValues = new Map<String, YG_Community_Configuration__c>();        
            allValues = YG_Community_Configuration__c.getAll();
            Id selfRegAccId = allValues.get('YGSelfRegisterAccountId').Text_1__c;
            
            //To get the plant List
            List<Plant__c> plantList = YG_HelperClass.getPlantList(accId,langCode);
            
                 for(Plant__c pl:plantList){
                     LogAccPlant logAccPlantData =new LogAccPlant();
                     logAccPlantData.plant = pl.Plant_Name__c;
                     logAccPlantData.plantcode = pl.Plant_Code__c;
                     logAccPlantList.add(logAccPlantData);
                     userDetailsWap.logAccPlantLists = logAccPlantList;
                     system.debug('Plant List ::'+logAccPlantList);
                 }
        
        List<Contact> cusPlantList = [Select Name, Email, Phone,toLabel(Portal_User_Roles__c),Profile_Image__c,Account.Name,Company_Name__c,  (select Plant__c,Plant__r.Plant_Name__c,Status__c,Plant__r.Plant_Code__c  from Customer_Plant__r)  from Contact where id=:conIds and status__c =: true];
          
            for(Contact con:cusPlantList){
                popupplantDet popupplantData =new popupplantDet();
                
                // To display the user details on manage colleagues popup
                userDetailsWap.name = con.Name;
                userDetailsWap.email = con.Email;
                userDetailsWap.phone = con.Phone;
                if(con.id == userInformation.Contact.Id){
                    userDetailsWap.role = 'LoggedUser';
                }
                else{
                    userDetailsWap.role = con.Portal_User_Roles__c;
                }
                userDetailsWap.profileImage = con.Profile_Image__c;
                
                // To display the user details on updated profile page  
                if(accId == selfRegAccId){
                    userDetailsWap.accountName = con.Company_Name__c;
                }
                else{
                	userDetailsWap.accountName = con.Account.Name;    
                }
                
                
                String Name;
                Map<String,List<String>> approvedPlantMap = new Map<String,List<String>>();
                List<String> approvedPlantList=new List<String>();
                Map<String,List<String>> requestedPlantMap = new Map<String,List<String>>();
                List<String> requestedPlantList=new List<String>();
               
                Name = 'ApprovedSite';
                for(Customer_Plant__c csPL2:con.Customer_Plant__r){
                    //this condition is only for update profile page, to get only the approved plant name
                    if(csPL2.Status__c == 'Approved site access'){
                        approvedPlantList.add(csPL2.Plant__r.Plant_Name__c);
                        approvedPlantMap.put(Name,approvedPlantList);  
                    }
                    
                    //this condition is to check if plant name is not null and get only the requested plant name 
                    if(csPL2.Plant__r.Plant_Name__c != null){
                        if(csPL2.Status__c == 'Request site access'){
                            requestedPlantList.add(csPL2.Plant__r.Plant_Code__c);
                            requestedPlantMap.put(csPL2.Status__c,requestedPlantList);            
                        }
                    }
                }
                system.debug('requestedPlantMap :::'+requestedPlantMap);
                
                for(Customer_Plant__c csPL:con.Customer_Plant__r){ 
                    //this condition is to send the requested plant to popup
                    if(csPL.Status__c == 'Request site access')
                    {
                        popupplantData.plantcodes = requestedPlantList;
                    }
                    
                    //this condition is only for update profile page to get the approved site list
                        if(csPL.Status__c != 'Request site access')
                        {
                             userDetailsWap.approvedSites = approvedPlantMap;
                        }
                   
                }
                
                popupplantList.add(popupplantData);
                userDetailsWap.popupplantLists = popupplantList;
                system.debug('Contact List ::'+popupplantList);
            }

            
        }catch(Exception e){
            system.debug('Exception Cause::'+e.getCause());
            system.debug('Exception LineNumber::'+e.getLineNumber());
            system.debug('Exception Message::'+e.getMessage());
            system.debug('Exception StackTrace::'+e.getStackTraceString());
            system.debug('Exception TypeName::'+e.getTypeName());
            YG_Utility.logError('ManageColleagues page','Community Component Error',e.getStackTraceString(),
                                'Class:YG_ManageColleaguesController; Method: getSelectedUserDetail(); Line #:'+e.getLineNumber()+'; Message:'+e.getMessage(),
                                UserInfo.getUserId());
        }
        
        return userDetailsWap;
    }
    
    public class UserDetalisWapper{
        @AuraEnabled public List<LogAccPlant> logAccPlantLists;
        @AuraEnabled public List<popupplantDet> popupplantLists;
        @AuraEnabled public String name;
        @AuraEnabled public String email;
        @AuraEnabled public String phone;
        @AuraEnabled public String role;
        @AuraEnabled public String profileImage='';   
        @AuraEnabled public Map<String,List<String>> approvedSites = new Map<String,List<String>>();
        @AuraEnabled public String accountName;
    }
    
     public class LogAccPlant{
        @AuraEnabled public String plant; 
        @AuraEnabled public String plantcode; 
     }
    
    public class popupplantDet{
        @AuraEnabled public Map<String,List<String>> plantcode;
        @AuraEnabled public List<String> plantcodes;
     }


    // This method is used to approve requested plant from the popup1 
    @AuraEnabled
    public static void getApprovePlant(String conId,List<String> plantIDList){
        System.debug('conId::'+conId);
        System.debug('plantIDList::'+plantIDList);
        
        List<Customer_Plant__c> cusPlantToupdate = [select Plant__c,Plant__r.Plant_Name__c,Status__c,Contact__r.Email,Contact__r.Name from Customer_Plant__c where Contact__c =: conId and Plant__r.Plant_Code__c IN : plantIDList ];
        List<Customer_Plant__c> cusPlantUpd = new List<Customer_Plant__c>();
        
        try{
            List<String> emailTo = new List<String>();
            String conName = '';
            List<String> plantNameList = new List<String>();
            //to delete the existing plant request 
                for(Customer_Plant__c c:cusPlantToupdate){
                    c.Status__c = 'Approved site access';
                    emailTo.add(c.Contact__r.Email);
                    plantNameList.add(c.Plant__r.Plant_Name__c);
                    conName = c.Contact__r.Name;
                    cusPlantUpd.add(c);
                } 
            system.debug('cusPlantUpd ::'+cusPlantUpd);
                update cusPlantUpd;
            
             //this is to send email notification when admin approves 
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address =: Label.YG_Email_From_Address  ];
                    if ( owea.size() > 0 ) {
                        email.setOrgWideEmailAddressId(owea.get(0).Id);
                    }
                email.setToAddresses(emailTo);            
                email.setSubject(Label.YG_Email_Subject_Plant_Approve);            
                email.setHtmlBody(Label.YG_Email_Salutations+' '+ conName +', <br/><br/> '+ Label.YG_Email_Body_Plant +' '+ plantNameList +' '+ Label.YG_Email_Body_Plant_Approve2 +'<br/><br/>'+ Label.YG_Email_Signature);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
           
        }catch(Exception e){
            system.debug('Exception Cause::'+e.getCause());
            system.debug('Exception LineNumber::'+e.getLineNumber());
            system.debug('Exception Message::'+e.getMessage());
            system.debug('Exception StackTrace::'+e.getStackTraceString());
            system.debug('Exception TypeName::'+e.getTypeName());
            YG_Utility.logError('ManageColleagues page','Community Component Error',e.getStackTraceString(),
                                'Class:YG_ManageColleaguesController; Method: getApprovePlant(); Line #:'+e.getLineNumber()+'; Message:'+e.getMessage(),
                                UserInfo.getUserId());
        }  
    }    
    
    // This method is used to decline requested plant from the popup1 
    @AuraEnabled
    public static void getDeclinePlant(String conId,List<String> plantIDList){
        System.debug('conId::'+conId);
        System.debug('plantIDList::'+plantIDList);
        
        List<Customer_Plant__c> cusPlantToupdate = [select Plant__c,Plant__r.Plant_Name__c,Status__c,Contact__r.Email,Contact__r.Name from Customer_Plant__c where Contact__c =: conId and Plant__r.Plant_Code__c IN : plantIDList ];
        List<Customer_Plant__c> cusPlantUpd = new List<Customer_Plant__c>();
        
        try{
            List<String> emailTo = new List<String>();
            List<String> plantNameList = new List<String>();
            String conName = '';
            //to delete the existing plant request 
                for(Customer_Plant__c c:cusPlantToupdate){
                    c.Status__c = 'Decline site access';
                    emailTo.add(c.Contact__r.Email);
                    plantNameList.add(c.Plant__r.Plant_Name__c);
                    conName = c.Contact__r.Name;
                    cusPlantUpd.add(c);
                } 
            system.debug('cusPlantUpd ::'+cusPlantUpd);
                update cusPlantUpd;
                        
             //this is to send email notification when admin decline 
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address =: Label.YG_Email_From_Address ];
                    // Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    if ( owea.size() > 0 ) {
                        email.setOrgWideEmailAddressId(owea.get(0).Id);
                    }
                email.setToAddresses(emailTo);            
                email.setSubject(Label.YG_Email_Subject_Plant_Decline);
                email.setHtmlBody(Label.YG_Email_Salutations+' '+ conName +', <br/><br/> '+ Label.YG_Email_Body_Plant +' '+ plantNameList +' '+ Label.YG_Email_Body_Plant_Decline2 +'<br/><br/>'+ Label.YG_Email_Signature);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
           
          
        }catch(Exception e){
            system.debug('Exception Cause::'+e.getCause());
            system.debug('Exception LineNumber::'+e.getLineNumber());
            system.debug('Exception Message::'+e.getMessage());
            system.debug('Exception StackTrace::'+e.getStackTraceString());
            system.debug('Exception TypeName::'+e.getTypeName());
            YG_Utility.logError('ManageColleagues page','Community Component Error',e.getStackTraceString(),
                                'Class:YG_ManageColleaguesController; Method: getDeclinePlant(); Line #:'+e.getLineNumber()+'; Message:'+e.getMessage(),
                                UserInfo.getUserId());
        }  
    }
    
    // This method is used to update requested plant from the popup 
    @AuraEnabled
    public static void getUpdatePlant(String conId,List<String> plantIDList){
        System.debug('conId::'+conId);
        System.debug('plantIDList::'+plantIDList);
        Id  accId = [select id, Accountid from contact where id =: conId].Accountid;
       // List<Plant__c> plantDetails = ;
        List<Customer_Plant__c> cusPlantToupdate = [select Plant__c,Plant__r.Plant_Name__c,Status__c,Plant__r.Plant_Code__c from Customer_Plant__c where Contact__c =: conId ];
        List<Customer_Plant__c> cusPlantIns = new List<Customer_Plant__c>();
        List<String> cusPlantCompare = new List<String>();
        Set<String> declineList = new Set<String>();
        List<String> declinePlantNameList = new List<String>();
        List<String> approvedPlantNameList = new List<String>();
        Set<String> newList = new Set<String>();
        Set<String> comparePlantList = new Set<String>(); 
        List<String> emailTo = new List<String>();
        String conName = '';
        List<String> emailTo1 = new List<String>();
        String conName1 = '';
        Boolean FlagApprove, FlagDecline;
        List<Customer_Plant__c> cusPlantUpdateList = new List<Customer_Plant__c>();
        List<Customer_Plant__c> cusPlantUpdateList1 = new List<Customer_Plant__c>();
        
        try{
            
           
            //to to find decline starts
            for(Customer_Plant__c c : cusPlantToupdate){
                declineList.add(c.Plant__r.Plant_Code__c);
            }

            comparePlantList.addAll(plantIDList);
           
            if(declineList.removeAll(comparePlantList)){
                declineList.removeAll(comparePlantList);
            }
            
            System.debug('Plant status to updated as Decline' + declineList);
            
            for(Customer_Plant__c cus : [select Plant__c,Plant__r.Plant_Name__c,Status__c,Plant__r.Plant_Code__c,Contact__r.Email,Contact__r.Name from Customer_Plant__c where Contact__c =: conId and Plant__r.Plant_Code__c IN : declineList]){
                if(cus.Status__c != 'Decline site access'){
                    cus.Status__c = 'Decline site access';
                    emailTo.add(cus.Contact__r.Email);
                    declinePlantNameList.add(cus.Plant__r.Plant_Name__c);
                    conName = cus.Contact__r.Name;
                    cusPlantUpdateList.add(cus);                    
                    FlagDecline = True;
                }                
            }
            update cusPlantUpdateList;
            
            //this is to send email notification when admin decline 
            if(FlagDecline == True){
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address =: Label.YG_Email_From_Address ];
                    // Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    if ( owea.size() > 0 ) {
                        email.setOrgWideEmailAddressId(owea.get(0).Id);
                    }
                email.setToAddresses(emailTo);            
                email.setSubject(Label.YG_Email_Subject_Plant_Decline);            
                email.setHtmlBody(Label.YG_Email_Salutations+' '+ conName +', <br/><br/> '+ Label.YG_Email_Body_Plant +' '+ declinePlantNameList +' '+ Label.YG_Email_Body_Plant_Decline2 +'<br/><br/>'+ Label.YG_Email_Signature);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
            }
                        
            // to find decline ENDS
            
            
            //to update the Status as Approved for requested sites
            for(Customer_Plant__c cus1 : [select Plant__c,Plant__r.Plant_Name__c,Status__c,Plant__r.Plant_Code__c,Contact__r.Email,Contact__r.Name from Customer_Plant__c where Contact__c =: conId and Plant__r.Plant_Code__c IN : plantIDList])
            {
                if(cus1.Status__c == 'Request site access' || cus1.Status__c == 'Decline site access' ){
                    cus1.Status__c = 'Approved site access';
                    system.debug('Plant__r.Plant_Code__c' +cus1.Plant__r.Plant_Code__c);
                    emailTo1.add(cus1.Contact__r.Email);
                    conName1 = cus1.Contact__r.Name;
                    approvedPlantNameList.add(cus1.Plant__r.Plant_Name__c);
                    cusPlantUpdateList1.add(cus1);
                    FlagApprove = True;
                }
                newList.add(cus1.Plant__r.Plant_Code__c);
                system.debug('newList inside if :: '+newList);
            }
            update cusPlantUpdateList1;
            
            
                if(comparePlantList.removeAll(newList)){
                    comparePlantList.removeAll(newList);
                 }  
                System.debug('new plant' + comparePlantList);
            

            //to insert the requested plants 
                for(Plant__c p: [select Id,Plant_Code__c,Plant_Name__c from Plant__c where Plant_Code__c IN : comparePlantList and Account__c =: accId ])
                {
                    Customer_Plant__c insertCustPlant = new Customer_Plant__c();
                    insertCustPlant.Contact__c =conId;
                    insertCustPlant.Status__c='Approved site access';
                    insertCustPlant.Plant__c = p.Id;
                    cusPlantIns.add(insertCustPlant);
                    approvedPlantNameList.add(P.Plant_Name__c);
                }
                insert cusPlantIns;
           
            //this is to send email notification when admin approves 
            if(FlagApprove == True){
                Messaging.SingleEmailMessage email1 = new Messaging.SingleEmailMessage();
                    OrgWideEmailAddress[] owea1 = [select Id from OrgWideEmailAddress where Address =: Label.YG_Email_From_Address ];
                    if ( owea1.size() > 0 ) {
                        email1.setOrgWideEmailAddressId(owea1.get(0).Id);
                    }
                email1.setToAddresses(emailTo1);            
                email1.setSubject(Label.YG_Email_Subject_Plant_Approve);            
                email1.setHtmlBody(Label.YG_Email_Salutations+' '+ conName1 +', <br/><br/> '+ Label.YG_Email_Body_Plant +' '+ approvedPlantNameList +' '+ Label.YG_Email_Body_Plant_Approve2 +'<br/><br/>'+ Label.YG_Email_Signature);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email1 });
            }
            
        }catch(Exception e){
            system.debug('Exception Cause::'+e.getCause());
            system.debug('Exception LineNumber::'+e.getLineNumber());
            system.debug('Exception Message::'+e.getMessage());
            system.debug('Exception StackTrace::'+e.getStackTraceString());
            system.debug('Exception TypeName::'+e.getTypeName());
            YG_Utility.logError('ManageColleagues page','Community Component Error',e.getStackTraceString(),
                                'Class:YG_ManageColleaguesController; Method: getUpdatePlant(); Line #:'+e.getLineNumber()+'; Message:'+e.getMessage(),
                                UserInfo.getUserId());
            //apexpages.addmessage(new apexpages.message(apexpages.severity.error,e.getMessage()));
        }  
    }
    
     // This method is to deactivate the user details from the popup 
    @AuraEnabled
    public static Boolean getUserDeactive(String contactId, Boolean btnDeactive){
        system.debug('contactId&&&'+contactId);
        Boolean success = false;
        try{
            Id conId;
            
            if(contactId == null){
               conId = userInformation.Contact.Id; 
            }
            else{
                conId = contactId;
            }
             
            system.debug('conId&&&'+conId);
            Contact con = [Select id,Status__c,email from contact where id = : conId and status__c =: true limit 1 ];
            Set<String> allEmails = new Set<String>();
            allEmails.add(con.Email);
            
            if(btnDeactive == true){   
                success = true;                
                YG_DeactivateHelper.updateContact(allEmails);
                YG_DeactivateCDCAPI.deactivateUser(allEmails);
                YG_DeactivateHelper.deactivateUser(allEmails);
                
            }
            
        }catch(Exception e){
            system.debug('Exception Cause::'+e.getCause());
            system.debug('Exception LineNumber::'+e.getLineNumber());
            system.debug('Exception Message::'+e.getMessage());
            system.debug('Exception StackTrace::'+e.getStackTraceString());
            system.debug('Exception TypeName::'+e.getTypeName());
            YG_Utility.logError('ManageColleagues page','Community Component Error',e.getStackTraceString(),
                                'Class:YG_ManageColleaguesController; Method: getUserDeactive(); Line #:'+e.getLineNumber()+'; Message:'+e.getMessage(),
                                UserInfo.getUserId());
        }
        system.debug('success++'+success);
        return success;
    }
    
    
    // This method is to make the user Admin from the popup 
    @AuraEnabled
    public static UserAdminWapper getUserAdmin(String conId, String btnAdmin){
        System.debug('conId::'+conId);
        System.debug('btnDeactive::'+btnAdmin);
        Id accId = userInformation.Contact.AccountId;
        UserAdminWapper userAdminWap=new UserAdminWapper();
        List<Contact> con = [Select id, toLabel(Portal_User_Roles__c) from Contact where id = :conId and status__c =: true];
        List<Id> getConid =new List<Id>();
        Id contactid;
        try{
            if(btnAdmin == 'Set as admin'){
                for(Contact c:con){
                    userAdminWap.role = 'Customer Admin';
                    getConid.add(c.id);
                    contactid = c.id;
                }                
                getAdminPlant(contactid,accId);
                YG_SetAdminCDCAPI.getUpdateAdmin(getConid,'CA','1');
            }
            if(btnAdmin == 'Revoke admin'){                
                for(Contact c:con){
                    userAdminWap.role = 'Customer';
                    getConid.add(c.id);
                }
                YG_SetAdminCDCAPI.getUpdateAdmin(getConid,'CU','0');
            }
            
        }catch(Exception e){
            system.debug('Exception Cause::'+e.getCause());
            system.debug('Exception LineNumber::'+e.getLineNumber());
            system.debug('Exception Message::'+e.getMessage());
            system.debug('Exception StackTrace::'+e.getStackTraceString());
            system.debug('Exception TypeName::'+e.getTypeName());
            YG_Utility.logError('ManageColleagues page','Community Component Error',e.getStackTraceString(),
                                'Class:YG_ManageColleaguesController; Method: getUserAdmin(); Line #:'+e.getLineNumber()+'; Message:'+e.getMessage(),
                                UserInfo.getUserId());
        }
                
        
        return userAdminWap;
    }
    
     public class UserAdminWapper{
        @AuraEnabled public String role;        
    }
    
        
    // This method is used to request plant from the popup in update profile page 
    @AuraEnabled
    public static void getPlantRequest(List<String> plantIDList){
        
        System.debug('plantIDList::'+plantIDList);
        Id conId = userInformation.Contact.Id;
        Id accId = userInformation.Contact.AccountId;
        String conName2 = userInformation.Contact.Name;
        List<Contact> adminList = [select Name,Email from contact where toLabel(Portal_User_Roles__c) != 'Customer' and accountId = : accId and status__c =: true];
        System.debug('adminList::'+adminList);
        List<Plant__c> plantDetails = [select Id,Name,Plant_Code__c,Plant_Name__c from Plant__c where Plant_Code__c IN : plantIDList and Account__c = : accId];
        List<Customer_Plant__c> cusPlantList = [select Plant__c,Plant__r.Plant_Name__c,Status__c,Plant__r.Plant_Code__c from Customer_Plant__c where Contact__c =: conId and Plant__r.Plant_Code__c IN : plantIDList];
        List<Customer_Plant__c> cusPlantIns = new List<Customer_Plant__c>();
        List<String> adminName = new List<String>();
        List<String> requestPlantList  = new List<String>(); 
        String communityURL = YG_Utility.getCommunityURL();
        String pageURL = communityURL+'manage-colleagues';
        List<Customer_Plant__c> cusPlantUpdateList = new List<Customer_Plant__c>();
        
        try{
            if(cusPlantList.size()>0){
                for(Customer_Plant__c cp: cusPlantList)
                {
                    cp.Status__c = 'Request site access';
                    requestPlantList.add(cp.Plant__r.Plant_Name__c);
                    cusPlantUpdateList.add(cp);
                }
                update cusPlantUpdateList;
            } 
            else{
                //to insert the requested plants 
                for(Plant__c p: plantDetails)
                {
                    Customer_Plant__c insertCustPlant = new Customer_Plant__c();
                    insertCustPlant.Contact__c =conId;
                    insertCustPlant.Status__c='Request site access';
                    insertCustPlant.Plant__c = p.Id;
                    requestPlantList.add(p.Plant_Name__c);
                    cusPlantIns.add(insertCustPlant);
                }
                insert cusPlantIns;                
            }
            
            Messaging.Email[] messages = new Messaging.Email[0];
            for(Contact c: adminList){
                List<String> adminEmail  = new List<String>();
                adminName.add(c.Name);
                adminEmail.add(c.Email);
                System.debug('adminName::'+adminName);
                System.debug('adminEmail::'+adminEmail);
                
                //this is to send email notification to admin when customer request for plant 
                Messaging.SingleEmailMessage email2 = new Messaging.SingleEmailMessage();
                OrgWideEmailAddress[] owea2 = [select Id from OrgWideEmailAddress where Address =: Label.YG_Email_From_Address ];
                system.debug('owea2'+owea2);
                if ( owea2.size() > 0 ) {
                    email2.setOrgWideEmailAddressId(owea2.get(0).Id);
                }
                email2.setToAddresses(adminEmail);            
                email2.setSubject(Label.YG_Email_Subject_Plant_Request);            
                email2.setHtmlBody(Label.YG_Email_Salutations+' '+ c.Name +', <br/><br/>'+ conName2 +' '+ Label.YG_Email_Body_Plant_Request +' '+ requestPlantList +'. '+Label.YG_Manage_Access +' <br/> <a href="'+pageURL+'">'+pageURL+'</a><br/><br/>'+ Label.YG_Email_Signature);
  				messages.add(email2);
            }
            Messaging.sendEmail(messages);
            
        }catch(Exception e){
            system.debug('Exception Cause::'+e.getCause());
            system.debug('Exception LineNumber::'+e.getLineNumber());
            system.debug('Exception Message::'+e.getMessage());
            system.debug('Exception StackTrace::'+e.getStackTraceString());
            system.debug('Exception TypeName::'+e.getTypeName());
            YG_Utility.logError('ManageColleagues page','Community Component Error',e.getStackTraceString(),
                                'Class:YG_ManageColleaguesController; Method: getPlantRequest(); Line #:'+e.getLineNumber()+'; Message:'+e.getMessage(),
                                UserInfo.getUserId());
        }  
    } 


    //To make all the admin user plant as approved 
    @AuraEnabled
    public static void getAdminPlant(Id contactId, Id accId){
        
        String langCode = YG_CommonUtils.getLanguageCode(userInformation.LanguageLocaleKey); 
        
        //To get the plant List
        List<Plant__c> plantList = YG_HelperClass.getPlantList(accId,langCode);
        List<Customer_Plant__c> cusPlantList = [select Plant__c,Plant__r.Plant_Name__c,Status__c,Plant__r.Plant_Code__c from Customer_Plant__c where Contact__c =: contactId];
        List<Customer_Plant__c> cusPlantIns = new List<Customer_Plant__c>();
        List<Customer_Plant__c> cusPlantUpd = new List<Customer_Plant__c>();
        Set<String> allcustomerplantList = new Set<String>();
        Set<String> allplantList = new Set<String>();
        Set<String> comparePlantList = new Set<String>(); 
         try{
             //check if the account has plant
             if(plantList.size() > 0){
                     //to get the list of Customer Plant and update if not approved 
                     for(Customer_Plant__c c : cusPlantList){                 
                         if(c.Status__c != 'Approved site access'){
                             c.Status__c = 'Approved site access';
                             cusPlantUpd.add(c);
                         }
                         allcustomerplantList.add(c.Plant__c);                
                     }
                     update cusPlantUpd;
                                          
                     //to get the list of Plant
                     for(Plant__c p : plantList){
                         allplantList.add(p.id);
                     }
                     
                     comparePlantList.addAll(allcustomerplantList);
                     system.debug('comparePlantList'+comparePlantList);
                     
                     //to get the non assigned Customer Plant of an User
                     if(allplantList.removeAll(comparePlantList)){
                         allplantList.removeAll(comparePlantList);
                     }
                     system.debug('allplantList'+allplantList);
                     
                     //to insert the Customer Plant
                     for(String insCustplant : allplantList){
                         Customer_Plant__c insertCustPlant = new Customer_Plant__c();
                         insertCustPlant.Contact__c = contactId;
                         insertCustPlant.Status__c = 'Approved site access';
                         insertCustPlant.Plant__c = insCustplant;                   
                         cusPlantIns.add(insertCustPlant);
                     }
                     insert cusPlantIns; 
                     system.debug('cusPlantIns'+cusPlantIns);
             }
             
             //if there is no plant in account call PlantAPI
             else{
                 
                 YG_PlantAPIController.PlantResponseWrapper plantResponse = YG_PlantAPIController.callPlantAPI();
                 for(Plant__c pRes : plantResponse.plantList){
                     system.debug('pRes'+pRes);
                     Customer_Plant__c insertCustPlant = new Customer_Plant__c();
                         insertCustPlant.Contact__c = contactId;
                         insertCustPlant.Status__c = 'Approved site access';
                         insertCustPlant.Plant__c = pRes.id;
                     	 cusPlantIns.add(insertCustPlant);
                 }
                  
                 insert cusPlantIns;
             }
             
             
         }catch(Exception e){
            system.debug('Exception Cause::'+e.getCause());
            system.debug('Exception LineNumber::'+e.getLineNumber());
            system.debug('Exception Message::'+e.getMessage());
            system.debug('Exception StackTrace::'+e.getStackTraceString());
            system.debug('Exception TypeName::'+e.getTypeName());
            YG_Utility.logError('ManageColleagues page','Community Component Error',e.getStackTraceString(),
                                'Class:YG_ManageColleaguesController; Method: getAdminPlant(); Line #:'+e.getLineNumber()+'; Message:'+e.getMessage(),
                                UserInfo.getUserId());
        } 
    }
           
                
    
}