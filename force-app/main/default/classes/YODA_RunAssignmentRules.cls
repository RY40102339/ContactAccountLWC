/*
*******************************************************************************************************
* (C) Copyright 2021 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Hemalatha Gorthy
* @version 1.0
* @created 08/17/2021
* @description 
* This is to Run assignment rules on Lead.
*
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  08/17/2021           Hemalatha Gorthy        Run assignment rules on Lead.
*  10/04/2021           Hemalatha Gorthy        Country field added to fix Lead creation in Test class.
*/
public class YODA_RunAssignmentRules {

    @InvocableMethod
    public static void assignLeads(List<Id> leadIds){
        	reRunAssignmentRules(leadIds);
    }
    
    @future
    public static void reRunAssignmentRules(List<Id> leadIds){
        Database.DMLOptions dmo = new Database.DMLOptions();
       // dmo.AssignmentRuleHeader.useDefaultRule = TRUE; 
        
        AssignmentRule AR = [select id from AssignmentRule where SobjectType = 'Lead' and Active = true limit 1];
        dmo.AssignmentRuleHeader.assignmentRuleId = AR.Id;
        
        Lead myLead = [SELECT Id, firstname, lastname, OwnerId, Owner.Name, Rating, Country, Business_Unit__c  FROM Lead WHERE Id IN :leadIds LIMIT 1];
        myLead.setOptions(dmo);
        //Database.update(toAssign,dmo);
        try{
        	update myLead; 
        }catch(Exception ex){
            system.debug('Exception : '+ex.getMessage());
        }
    }
}