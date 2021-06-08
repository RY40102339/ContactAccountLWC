/*
*******************************************************************************************************
* (C) Copyright 2020 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Selvaraj T
* @version 1.0
* @created 11/06/2020
* @description 
* This class is used to get the account logo and display in header.
*
* @test class name - YG_HeaderControllerTest
*
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*
*
*/

public class YG_HeaderController {
    
    public static User userInformation =  YG_Utility.getLoggedInUserInfo(UserInfo.getUserId());
    
    //This method is used to get the account logo based on logged in user 
    @AuraEnabled
    public static Account getAccountData(){
        
        Account acc = null;
        
        try{
            
            Id accId = userInformation.Contact.AccountId;
            system.debug('accId::'+accId);
            
            acc = [Select Id, Name, Account_Logo__c, AccountNumber from Account where id= :accId Limit 1];
            system.debug('acc::'+acc);
        }
        catch(Exception e){
            system.debug('Exception Cause::'+e.getCause());
            system.debug('Exception LineNumber::'+e.getLineNumber());
            system.debug('Exception Message::'+e.getMessage());
            system.debug('Exception StackTrace::'+e.getStackTraceString());
            system.debug('Exception TypeName::'+e.getTypeName());
            YG_Utility.logError('Header','Backend Process Error',e.getStackTraceString(),
                                'Class:getAccountLogo; Method: getAccountLogo(); Line #:'+e.getLineNumber()+'; Message:'+e.getMessage(),
                                UserInfo.getUserId());
        }
        
        return acc;
    }

}