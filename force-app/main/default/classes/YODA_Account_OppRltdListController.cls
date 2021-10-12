/*
*******************************************************************************************************
* (C) Copyright 2021 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Kameron F
* @version 1.0
* @created 9/10/2021
* @description  
* This class is used for return data to the yODAAccountOppRltdList component
*
* @test class name - YODA_Account_OppRltdListControllerTest
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  9/10/2021            Kameron F.              Created class
*. 10/12/2021			Kameron F.				Updated to without sharing
*/
public without sharing class YODA_Account_OppRltdListController {
    // Returns opportunities for the account
    // Kam 9/10/2021
    @AuraEnabled(cacheable=true)
    public static List<Opportunity> getOpps(Id recordId){
        List<Opportunity> oppList = [SELECT Name, StageName, Owner.Name, End_User__c, End_User__r.Name, LastModifiedDate FROM Opportunity WHERE AccountId = :recordId];
        System.debug(oppList);
        return oppList;
    }

    // Checks if the user has proper access to the Account
    // Kam 9/10/2021 but mostly used logic from the VF controller
    @AuraEnabled(cacheable=true)
    public static boolean IsAccountTeamMemberMethod(Id recordId){
        Boolean IsAccountTeamMember = false;

        //Get Account team member of current Account record.
        List<AccountTeamMember> acctTeamMembers = [SELECT Id FROM AccountTeamMember WHERE UserId = :UserInfo.getUserId() 
                                                    AND AccountId = :recordId];
        //Get Account Owner of current account and match with current login user.
        List<Account> acctOwner = [SELECT Id FROM Account WHERE OwnerId = :UserInfo.getUserId() AND Id = :recordId];
        //Get Opportunity team member of current Account record.        
        if (!acctTeamMembers.isEmpty() || !acctOwner.isEmpty()) {
            isAccountTeamMember = true;}
        else {
            isAccountTeamMember = false;
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You need to be part of Account Team or Account Owner to create Opportunity'));
        }  

        return IsAccountTeamMember;
        
    }    
    
    // Returns the URL for the org
    // Kam 9/10/2021
    @AuraEnabled(cacheable=true)
    public static String getUrl(){
        return URL.getSalesforceBaseUrl().toExternalForm();
    }
}