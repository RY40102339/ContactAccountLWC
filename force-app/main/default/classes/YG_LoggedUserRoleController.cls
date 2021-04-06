/*
*******************************************************************************************************
* (C) Copyright 2020 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Jayaprasath
* @version 1.0
* @created 09/17/2020
* @description 
* This class is used to write the methods for Logged user roles.
*
* @test class name - YG_LoggedUserRoleControllerTest
*
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  
*/

public class YG_LoggedUserRoleController {
    
    public static User userInformation =  YG_Utility.getLoggedInUserInfo(UserInfo.getUserId());
    //public static User userInformation =  YG_Utility.getLoggedInUserInfo('005p0000003rbfUAAQ');
   

     // This method is to display the user details on the popup 
    @AuraEnabled
    public static NoftifyUserRoleWapper getNotifyUserRole(){
        
        NoftifyUserRoleWapper userRoleWap=new NoftifyUserRoleWapper();
        Id conId = userInformation.Contact.Id;
        Id accId = userInformation.Contact.AccountId;
        try{
        	//to get the logged contact info
            Contact con = [Select id, toLabel(Portal_User_Roles__c), FirstName, LastName, Email, Phone, Account.Name,  
                           Company_Name__c from Contact where id = :conId and status__c =: true ];
            userRoleWap.fName = con.FirstName;
            userRoleWap.lName = con.LastName;
            userRoleWap.email = con.Email;
            userRoleWap.phone = con.Phone;            
            userRoleWap.Role = con.Portal_User_Roles__c;
           
            //to identify the self register account 
            Map<String, YG_Community_Configuration__c> allValues = new Map<String, YG_Community_Configuration__c>();        
            allValues = YG_Community_Configuration__c.getAll();
            Id selfRegAccId = allValues.get('YGSelfRegisterAccountId').Text_1__c;
            
            if(accId == selfRegAccId){
                userRoleWap.selfAcc = true;
                userRoleWap.company = con.Company_Name__c;	
            }
            else{
                userRoleWap.selfAcc = false;
                userRoleWap.company = con.Account.Name;
            } 
            
            
            //This method is used to get the contact count to show/hide deactivate button in update profile page
            List<Contact> conCount = [Select toLabel(Portal_User_Roles__c) from Contact where AccountId = :accId and status__c =: true];
            Integer count = 0;
            if(conCount.size()> 1){
                for(Contact c:conCount){
                    system.debug('c'+c);
                    if(c.Portal_User_Roles__c != 'Customer'){
                        count++;
                    }
                }    
            }            
            userRoleWap.roleCount = count;
            
        }catch(Exception e){
            system.debug('Exception Cause::'+e.getCause());
            system.debug('Exception LineNumber::'+e.getLineNumber());
            system.debug('Exception Message::'+e.getMessage());
            system.debug('Exception StackTrace::'+e.getStackTraceString());
            system.debug('Exception TypeName::'+e.getTypeName());
            YG_Utility.logError('ManageColleagues page','Community Component Error',e.getStackTraceString(),
                                'Class:YG_LoggedUserRoleController; Method: getNotifyUserRole(); Line #:'+e.getLineNumber()+'; Message:'+e.getMessage(),
                                UserInfo.getUserId());
        }
        
   return userRoleWap;
    }
    
     public class NoftifyUserRoleWapper{
         @AuraEnabled public String fName;
         @AuraEnabled public String lName;
         @AuraEnabled public String email;
         @AuraEnabled public String phone;
         @AuraEnabled public String company;
         @AuraEnabled public String role;
         @AuraEnabled public Integer roleCount;
         @AuraEnabled public Boolean selfAcc;
    }
    
}