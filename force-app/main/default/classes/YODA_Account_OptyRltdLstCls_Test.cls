@IsTest(SeeAllData = False)
public class YODA_Account_OptyRltdLstCls_Test {
	@isTest
    static void checkOpportunities(){
        Account acc = new Account(Name = 'Test');
        Insert acc;
        RecordType rt = [SELECT SobjectType, Id, IsActive FROM RecordType where SobjectType='Opportunity' LIMIT 1];
        Opportunity opp = new Opportunity(Name = 'Test opp',
                                          RecordTypeId = rt.Id,
                                          StageName = 'Identify (SAL)',
                                          CloseDate = Date.today(),
                                          AccountId = acc.Id);
        Insert opp;
        AccountTeamMember atm = new AccountTeamMember(UserId = UserInfo.getUserId(),
                                                      AccountId = acc.Id);
        Insert atm;
        // create a page reference 
        PageReference pageRef = Page.YODA_Account_OpptyRelatedLstVfp;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('Id', String.valueOf(acc.Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(acc);
        YODA_Account_OptyRltdLstCls testAccPlan = new YODA_Account_OptyRltdLstCls(sc);
        testAccPlan.selectedRecordType = rt.Id;
        testAccPlan.getOpprtySize();
        system.assertEquals(1, testAccPlan.getOpprtySize());
        Boolean team = testAccPlan.IsAccountTeamMember;
        system.assertEquals(true, team);
        // Setting Account team member
        testAccPlan.IsAccountTeamMember = false;
        testAccPlan.createOpp();
        testAccPlan.switch();
        //record type to null
        testAccPlan.selectedRecordType = '';
        testAccPlan.createOpp();
        // Create a test user
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com'+RandomId);
		//run as system user
        System.runAs(u) {
            // create second page reference 
            PageReference pageRef2 = Page.YODA_Account_OpptyRelatedLstVfp;
            Test.setCurrentPage(pageRef2);
            pageRef.getParameters().put('Id', String.valueOf(acc.Id));
            ApexPages.StandardController sc2 = new ApexPages.StandardController(acc);
            YODA_Account_OptyRltdLstCls testAccPlan2 = new YODA_Account_OptyRltdLstCls(sc2);
            Boolean team2 = testAccPlan.IsAccountTeamMember;
            system.assertEquals(false, team2);
        }
    }
}