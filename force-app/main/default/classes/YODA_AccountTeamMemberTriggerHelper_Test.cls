/*
*******************************************************************************************************
* (C) Copyright 2021 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Kameron F
* @version 1.0
* @created 10/19/2021
* @description  
* This class is used for creating Yoda_Error_Logs for debugging
*
* @test class name - YODA_AccountTeamMemberTriggerHelper_Test
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  10/19/2021           Kameron F.              Created Trigger
*/

@isTest
public class YODA_AccountTeamMemberTriggerHelper_Test {
	@isTest
    static void testDML(){
        List<Account> accList = new List<Account>();
		accList.add(new Account(Name='TestAcc'));
        accList.add(new Account(Name='TestAcc2'));
        insert accList;
        Date dt = Date.newInstance(2022, 1, 30);
        AccountTeamMember ATM = new AccountTeamMember(AccountID = accList[0].id, UserId = UserInfo.getUserId());
        
        insert ATM;

        delete ATM;
        
        Bypass_Settings__c setToAdd = new Bypass_Settings__c(Bypass_Flow_Rules__c=true);
        insert setToAdd;
        
        ATM = new AccountTeamMember(AccountID = accList[1].id, UserId = UserInfo.getUserId());
        
        insert ATM;

    }
}