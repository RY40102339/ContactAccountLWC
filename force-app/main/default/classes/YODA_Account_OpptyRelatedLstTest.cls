@isTest
public class YODA_Account_OpptyRelatedLstTest {

    public static testMethod void testIsAccountTeamMember(){
        test.startTest();
          account accRec = new account(name='Account: Test Info');
          insert accRec;
            
            apexpages.currentpage().getParameters().put('id', accRec.id);
            apexpages.standardController sc = new apexpages.standardController(accRec);
            YODA_Account_OpptyRelatedLstCls oppLst = new YODA_Account_OpptyRelatedLstCls(sc);
            oppLst.IsAccountTeamMember = oppLst.IsAccountTeamMember;
            oppLst.getOpprtySize();
            oppLst.AccountId = oppLst.AccountId;
        test.stopTest();
    }
}