/*
*******************************************************************************************************
* (C) Copyright 2021 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Kameron F
* @version 1.0
* @created 9/14/2021
* @description  
* This class is used for return data to the yODAAccountOppRltdList component. Mainly uses logic from 
* VF page test class YODA_Account_OptyRltdLstCls_Test
*
* @test class name - YODA_Account_OppRltdListControllerTest
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  9/10/2021             Kameron F.             Created class
*/
@isTest
public class YODA_Account_OppRltdListControllerTest {
    // Test class for the main controller for yODAAccountOppRltdList
    @isTest
    static void checkOpportunities() {
        Account acc = new Account(Name = 'Test');
        Insert acc;
        //RecordType rt = [SELECT SobjectType, Id, IsActive FROM RecordType where SobjectType='Opportunity' LIMIT 1];
        Opportunity opp = new Opportunity(Name = 'Test opp',
                                          //RecordTypeId = rt.Id,
                                          StageName = 'Prospecting',
                                          CloseDate = Date.today(),
                                          AccountId = acc.Id);
        Insert opp;
        AccountTeamMember atm = new AccountTeamMember(UserId = UserInfo.getUserId(),
                                                      AccountId = acc.Id);
        Insert atm;
		
        System.assertEquals(1, YODA_Account_OppRltdListController.getOpps(acc.id).size());
        YODA_Account_OppRltdListController.getUrl();
        
        // Create a test user
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com'+RandomId);
		//run as system user
        System.runAs(u) {
            System.assert(!YODA_Account_OppRltdListController.IsAccountTeamMemberMethod(acc.id));
        }
        acc.OwnerId = u.id;
        
        update acc;
        
        System.runAs(u) {
            System.assert(YODA_Account_OppRltdListController.IsAccountTeamMemberMethod(acc.id));
        }
    }
}