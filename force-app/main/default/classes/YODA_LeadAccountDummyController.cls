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
        Lead ld = [SELECT Related_Contact__c FROM Lead WHERE ID = :recordId LIMIT 1];
        Contact con = [SELECT AccountID FROM Contact WHERE ID=:ld.Related_Contact__c LIMIT 1];
        
        if(con.AccountID==null){
            Account acc = new Account(Name='DummyAccount');
            insert acc;
            con.AccountId = acc.id;
            update con;
        }
    }
    @AuraEnabled(cacheable=false)
    public static boolean MissingAccount(ID recordId){
        try{
            Lead ld = [SELECT Related_Contact__c FROM Lead WHERE ID = :recordId LIMIT 1];
        	Contact con = [SELECT AccountID FROM Contact WHERE ID=:ld.Related_Contact__c LIMIT 1];
            return con.AccountID==null;
        }catch(Exception e){}
        return true;
        
        
    }
    @AuraEnabled(cacheable=true)
    public static boolean hasRelatedContact(ID recordId){
        try{
            return [SELECT Related_Contact__c FROM Lead WHERE ID = :recordId LIMIT 1].Related_Contact__c != null;
        }catch(Exception e){}
        return false;
        
    }
}