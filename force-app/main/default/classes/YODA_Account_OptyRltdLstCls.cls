/*
*******************************************************************************************************
* (C) Copyright 2021 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Hemalatha Gorthy
* @version 1.0
* @created 03/08/2021
* @description 
* This is a Opportunity Related List class on Account FlexiPage.
*
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  08/03/2021           Hemalatha Gorthy        New Visualforce Page to display Opportunity Related List on Account FlexiPage.
*/
public class YODA_Account_OptyRltdLstCls {
    
    public Account parentAccount { get; set; }
    public String selectedRecordType { get; set; }
    
    public YODA_Account_OptyRltdLstCls(ApexPages.StandardController controller) {
        this.parentAccount = (Account) controller.getRecord();
    }
    
    public boolean IsAccountTeamMember{
        get{
            //Get Account team member of current Account record.
            List<AccountTeamMember> acctTeamMembers = [SELECT Id FROM AccountTeamMember WHERE UserId = :UserInfo.getUserId() 
                                                       AND AccountId = :parentAccount.Id];
            //Get Account Owner of current account and match with current login user.
            List<Account> acctOwner = [SELECT Id FROM Account WHERE OwnerId = :UserInfo.getUserId() AND Id = :parentAccount.Id];
            //Get Opportunity team member of current Account record.        
            if (!acctTeamMembers.isEmpty() || !acctOwner.isEmpty()) {
                isAccountTeamMember = true;}
            else {
                isAccountTeamMember = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You need to be part of Account Team or Account Owner to create Opportunity'));
            }
            return IsAccountTeamMember;
        }
        set{
            IsAccountTeamMember = value;
        }
    }    
    
    public integer getOpprtySize(){
        return [select id from opportunity where accountId =:parentAccount.Id].size();
    }
    
    public PageReference createOpp() {
        try {
            Opportunity op = new Opportunity(
                RecordTypeId = selectedRecordType,
                Name = 'Test',
                StageName = 'Identify (SAL)',
                CloseDate = Date.today());
            insert op;
            return new PageReference('/006/e?retURL=%2F' + op.Id + '&RecordType=' + op.RecordTypeId + '&ent=Opportunity&nooverride=1');
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Reach out to Salesforce team for further assistance' + e.getMessage()));
        }
        return null;
    }
    public pageReference switch() {
        PageReference pageRef = new PageReference(URL.getSalesforceBaseUrl().toExternalForm()+'/lightning/o/Opportunity/new?count=2&nooverride=1&useRecordTypeCheck=1&navigationLocation=LIST_VIEW');
        pageRef.setRedirect(true);
        return pageRef;
    }   
}