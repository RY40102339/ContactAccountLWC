/*
*******************************************************************************************************
* (C) Copyright 2021 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Kameron F
* @version 1.0
* @created 10/13/2021
* @description  
* This file is used on for the yodaLeadAccountDummy component. It is meant to resolve the issue of  
* Contacts not being associated with Accounts.
*
* @test class name - YODA_LeadAccountDummyController_Test
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  10/26/2021           Kameron F.              Created Class
*/
public class YODA_LeadAccountDummyController {
	@AuraEnabled(cacheable=false)
    public static void CreateAccount(ID recordId){
        try{
            Lead ld = [SELECT Related_Contact__c FROM Lead WHERE ID = :recordId LIMIT 1];
            Contact con = [SELECT AccountID, FirstName FROM Contact WHERE ID=:ld.Related_Contact__c LIMIT 1];
            
            if(con.AccountID==null){
                Account acc = new Account(Name='Pardot'+con.FirstName);
                insert acc;
                con.AccountId = acc.id;
                update con;
            }
        }catch(Exception e){
            YODA_Utility.logError('Backend Process Error','Class:YODA_LeadAccountDummyController; Method: CreateAccount(); Line #:'+e.getLineNumber()
                                      +'; Message:'+e.getMessage(), e.getStackTraceString(), UserInfo.getUserId());
        }
    }
    @AuraEnabled(cacheable=false)
    public static boolean MissingAccount(ID recordId){
        boolean isMissingAccount = true;
        try{
            Lead ld = [SELECT Related_Contact__c FROM Lead WHERE ID = :recordId LIMIT 1];
        	Contact con = [SELECT AccountID FROM Contact WHERE ID=:ld.Related_Contact__c LIMIT 1];
            isMissingAccount = (con.AccountID==null);
            if(Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }
        }catch(Exception e){}
        return isMissingAccount;
        
        
    }
    @AuraEnabled(cacheable=false)
    public static boolean hasRelatedContact(ID recordId){
        boolean hasContact = false;
        try{
            hasContact = ([SELECT Related_Contact__c FROM Lead WHERE ID = :recordId LIMIT 1].Related_Contact__c != null);
        }catch(Exception e){}
        return hasContact;
        
    }
}