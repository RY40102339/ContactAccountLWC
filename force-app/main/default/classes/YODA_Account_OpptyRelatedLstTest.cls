@isTest
public class YODA_Account_OpptyRelatedLstTest {

    public static testMethod void testIsAccountTeamMember(){
        test.startTest();
          account accRec = new account(name='Account: Test Info');
          insert accRec;
            
            apexpages.currentpage().getParameters().put('id', accRec.id);
            apexpages.standardController sc = new apexpages.standardController(accRec);
            salesrep_AccountOpptyRelatedLstCls sarLst = new salesrep_AccountOpptyRelatedLstCls(sc);
          sarLst.IsAccountTeamMember = sarLst.IsAccountTeamMember;
          sarLst.getOpprtySize();
          sarLst.AccountId = sarLst.AccountId;
        test.stopTest();
    }
}