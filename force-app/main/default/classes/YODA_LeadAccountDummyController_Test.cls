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
@isTest
public class YODA_LeadAccountDummyController_Test {
    /*@testSetup
    static void setuptest(){
        Bypass_Settings__c setToAdd = new Bypass_Settings__c(Bypass_Validation_Rules__c =true);
        insert setToAdd;
        
        Campaign cmp = new Campaign(Name='Test Campaign',Description='Test Campaign',Business_Owner__c=UserInfo.getUserId());
        insert cmp;
        
        delete setToAdd;
    }
    
	@isTest
    public static void DeleteDummyAccount(){
        
        Profile p = [SELECT Id FROM Profile WHERE Name='YHQ Administrator'];
        Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com'+RandomId);
        
        Contact con;
        //
		//run as B2B due to profile requirements on multiple inquiry
        System.runAs(u){
            Campaign cmp = [SELECT Name FROM Campaign WHERE Name='Test Campaign'];
            
            con = new Contact (OwnerID=u.id,Campaign__c=cmp.id,FirstName='Test', LastName='Tester',Email='test@test.com',MailingCountry='Aruba',Self_registered_company__c='Test co');
            insert con;
            
            List<YODA_Contact_TriggerHelper.CloneRecordFlowVariable> FlowList = new List<YODA_Contact_TriggerHelper.CloneRecordFlowVariable>();
            YODA_Contact_TriggerHelper.CloneRecordFlowVariable FlowVariable = new YODA_Contact_TriggerHelper.CloneRecordFlowVariable();
            FlowVariable.con = con;
            FlowList.add(FlowVariable);
            YODA_Contact_TriggerHelper.CloneRecordFlow(FlowList);

	 	}        
        Lead ld = [SELECT OwnerID, ID, Name, Related_Contact__c FROM Lead WHERE Related_Contact__c = :con.id];
        if(YODA_LeadAccountDummyController.MissingAccount(ld.Id)){
            System.debug(ld);
            YODA_LeadAccountDummyController.CreateAccount(ld.Id);
        }
        System.runAs(u){
            ld.OwnerId=u.id;
            update ld; 
            
        }
        Account acc = [SELECT Name FROM Account WHERE Name ='DummyAccount'];
        
        System.assertNotEquals(null, acc);
        Account finalAcc = new Account(Name='RealAccount');
        insert finalAcc;
        
        Test.startTest();
        con.AccountId = finalAcc.id;
        update con;
        Test.stopTest();
        
        ld.Related_Contact__c = null;
        update ld;
        YODA_RunAssignmentRules.reRunAssignmentRules(new List<Id>{ld.id});
        YODA_RunAssignmentRules.assignLeads(new List<Id>{ld.id});
        YODA_LeadAccountDummyController.hasRelatedContact(ld.id);
        YODA_LeadAccountDummyController.hasRelatedContact(null);
        YODA_LeadAccountDummyController.MissingAccount(null);
        try{
        acc = [SELECT Name FROM Account WHERE Name ='DummyAccount'];
        }catch(Exception e){
            acc = null;
        }
        System.assertEquals(null, acc);
        
        
    }*/
}