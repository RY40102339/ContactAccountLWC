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
*  9/10/2021            Kameron F.              Created class
*  12/3/2021			Kameron F.				Added Visibility tests
*/
@isTest
public class YODA_Account_OppRltdListControllerTest {
    @testSetup
    static void mainSetup(){
        UserRole ur = new UserRole(Name = 'Supervisor');
        insert ur;
        UserRole ur2 = new UserRole(Name = 'Team Member', ParentRoleID = ur.Id);
        insert ur2;
        
                // Create a test user
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com'+RandomId, UserRoleID = ur2.id);
        
        User u2 = new User(Alias = 'standt2', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser2@testorg.com'+RandomId, UserRoleID = ur.id);
        List<User> usersList = new List<User>{u,u2};
            insert usersList;
        
    }
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
        User u = [SELECT Alias FROM User WHERE Alias = 'standt'];
		User u2 = [SELECT Alias FROM User WHERE Alias = 'standt2'];
		//run as system user
        System.runAs(u) {
            System.assert(!YODA_Account_OppRltdListController.IsAccountTeamMemberOpptyMethod(acc.id));
        }
        acc.OwnerId = u.id;
        
        update acc;
        
        System.runAs(u) {
            System.assert(YODA_Account_OppRltdListController.IsAccountTeamMemberOpptyMethod(acc.id));   
        }
        System.runAs(u2){
            System.assert(YODA_Account_OppRltdListController.IsAccountTeamMemberMethod(acc.id));
        }
        
        /*atm = new AccountTeamMember(UserId = u.id, AccountId = acc.Id);
        Insert atm;
        */
        acc.ownerid = UserInfo.getUserId();
        update acc;
        
        System.runAs(u2){
            System.assert(!YODA_Account_OppRltdListController.IsAccountTeamMemberMethod(acc.id));
        }
        atm = new AccountTeamMember(UserId = u.id, AccountId = acc.Id);
        Insert atm;
        System.runAs(u2){
            System.assert(YODA_Account_OppRltdListController.IsAccountTeamMemberMethod(acc.id));
        }
        System.runAs(u){
            System.assert(YODA_Account_OppRltdListController.IsAccountTeamMemberMethod(acc.id));
        }
    }
}