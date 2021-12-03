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
*  10/12/2021			Kameron F.				Updated to without sharing
*  12/3/2021			Kameron F.				Updated to with sharing and added visibity on components
*/
public with sharing class YODA_Account_OppRltdListController {
    // Returns opportunities for the account
    // Kam 9/10/2021
    @AuraEnabled(cacheable=true)
    public static List<Opportunity> getOpps(Id recordId){
        List<Opportunity> oppList = [SELECT Name, StageName, Owner.Name, End_User__c, End_User__r.Name, LastModifiedDate FROM Opportunity WHERE AccountId = :recordId];
        System.debug(oppList);
        return oppList;
    }
    // Called from Oppty list component
    @AuraEnabled(cacheable=true)
    public static boolean IsAccountTeamMemberOpptyMethod(Id recordId){
        List<AccountTeamMember> acctTeamMembers = [SELECT Id, OpportunityAccessLevel FROM AccountTeamMember WHERE UserId = :UserInfo.getUserId() 
                                                    AND AccountId = :recordId AND OpportunityAccessLevel = 'Edit'];
        List<Account> acctOwner = [SELECT Id FROM Account WHERE OwnerId = :UserInfo.getUserId() AND Id = :recordId];
        return IsAccountTeamMemberMethodHelper(recordId, acctTeamMembers, acctOwner);
    }
    
    // Checks if the user has proper access to the Account
    // Kam 9/10/2021 but mostly used logic from the VF controller
    // Called from Order list component 
    @AuraEnabled(cacheable=true)
    public static boolean IsAccountTeamMemberMethod(Id recordId){
		//Get Account team member of current Account record.
		// Check to see if I can get Opportunity access value here
        List<AccountTeamMember> acctTeamMembers = [SELECT Id, UserId, OpportunityAccessLevel FROM AccountTeamMember WHERE UserId = :UserInfo.getUserId() 
                                                    AND AccountId = :recordId];
        List<Account> acctOwner = [SELECT Id, Owner.UserRoleId  FROM Account WHERE OwnerId = :UserInfo.getUserId() AND Id = :recordId];
        
        if(acctTeamMembers.isEmpty()&&acctOwner.isEmpty())
            return roleCheck(recordID);
        
        return IsAccountTeamMemberMethodHelper(recordId, acctTeamMembers,acctOwner);
    }    
    
    // Finds all Roles above users with access this account record. Currently only used for Orders
    public static Set<ID> collectRolesAbove(Set<ID> RoleSet, List<UserRole> AllRoles){
        Set<ID> currentRoleSet = new Set<ID>();
        
        for(UserRole userRole :AllRoles){
            if(RoleSet.contains(userRole.ID)&&userRole.ParentRoleId!=null){
                currentRoleSet.add(userRole.ParentRoleId);
            }
        }
        // For all roles above users with visibilites, keep this
        // For direct supervisors of users with visibilites, remove this
        if(!currentRoleSet.isEmpty()){
            currentRoleSet.addAll(collectRolesAbove(currentRoleSet,AllRoles));
        }
        
        return currentRoleSet;
    }
    
    // Checks is the user is above someone with full visbility to this record
    // Only enters method if user is not owner or on account team
    // Used for Orders
    public static boolean roleCheck(ID recordID){
		Boolean isAboveAccountMember = false;
        ID currentUserRoleId = UserInfo.getUserRoleId();
        Set<ID> acctTeamID = new Set<ID>();
        
        // Collecting all users with primary access
        for(AccountTeamMember ATM : [SELECT User.UserRoleID , Id, UserId, OpportunityAccessLevel FROM AccountTeamMember WHERE AccountId = :recordId]){
            acctTeamID.add(ATM.User.UserRoleID );
        }
        // Gets account owner
        for(Account acc: [SELECT Id, Owner.UserRoleID FROM Account WHERE Id = :recordId]){
            acctTeamID.add(acc.Owner.UserRoleID );
        }
        Set<ID> currentRoleIds = new Set<ID>();
        
	    if(currentUserRoleId!=null){
            List<UserRole> AllRoles = [SELECT ID, ParentRoleId FROM UserRole];
            currentRoleIds = collectRolesAbove(acctTeamID, AllRoles); // recursively calls to collect all roles above users with access
        }
        
        if(currentRoleIds.contains(currentUserRoleId)){
            isAboveAccountMember = true;
        }
		return isAboveAccountMember;
    }
    
    public static boolean IsAccountTeamMemberMethodHelper(Id recordId, List<AccountTeamMember> acctTeamMembers, List<Account> acctOwner){
        Boolean IsAccountTeamMember = false;
        
        List<Opportunity> oppList = [SELECT Id FROM Opportunity WHERE AccountID = :recordId Limit 1];
        
        List<UserRecordAccess> recordAccess = new List<UserRecordAccess>(); 
        
        if(!oppList.isEmpty())
        	recordAccess   = [SELECT RecordId FROM UserRecordAccess WHERE UserId=:UserInfo.getUserId() AND HasEditAccess  = true AND RecordId = :oppList[0].id];

        //Get Opportunity team member of current Account record.        
        if (!acctTeamMembers.isEmpty() || !acctOwner.isEmpty() || !recordAccess.isEmpty()) {
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