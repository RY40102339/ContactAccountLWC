/*
*******************************************************************************************************
* (C) Copyright 2021 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Hemalatha Gorthy
* @version 1.0
* @created 16/08/2021
* @description 
* This is a Run Assignment Rules Test class on Lead.
*
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  08/16/2021           Hemalatha Gorthy        Apex Test class to run assignment rules on Lead.
*/
@IsTest(SeeAllData = False)
public class YODA_RunAssignmentRules_Test {

    @testSetup 
    static void dataSetUp(){
            //Insert a test Lead
            Lead testLead1 = New Lead(Category_of_Interest__c = 'Oscilloscopes',
                                Company = 'TestLead',
                                FirstName = 'Test',
                                LastName = 'Assign',
                                Email = 'testLead@yokogawa.com',
                                Status = 'New',
                                Rating = 'Warm');
            
            Insert testLead1;
}
		
    @isTest
    public static void assignLeadsTest(){
        
        // Get the Lead that is inserted above
		List<id> idList = New List<id>();
        Lead myLead = [SELECT Id, firstname, lastname, OwnerId, Owner.Name, Rating, Country, Business_Unit__c  
                            FROM Lead WHERE Email = 'testLead@yokogawa.com' LIMIT 1];
        idList.add(myLead.id);
        
        //Test starts here
        Test.StartTest();        

        //Update status to 'Tele-Qualified'
        myLead.Status = 'Tele-Qualified';
        myLead.Tele_Qualified_Reason__c = 'Test Lead Assignment Rules';
        Update myLead;
        
		//Run assignment rules 
        YODA_RunAssignmentRules.reRunAssignmentRules(idList);
        
		// Owner is changed to 'Lead Queue'
		System.assertNotEquals(myLead.Owner.Name, Userinfo.getName(), 'Owner is changed to Lead Queue');
        
		Test.StopTest();

	}
}