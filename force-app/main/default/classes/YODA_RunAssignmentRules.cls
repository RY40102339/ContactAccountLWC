/*
*******************************************************************************************************
* (C) Copyright 2021 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Hemalatha Gorthy
* @version 1.0
* @created 16/08/2021
* @description 
* This is a Run Assignment Rules class on Lead.
*
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  08/16/2021           Hemalatha Gorthy        Apex class to run assignment rules on Lead.
*/
public class YODA_RunAssignmentRules {

    @InvocableMethod
    public static void assignLeads(List<Id> leadIds){
      try{
        reRunAssignmentRules(leadIds);
                }
      catch (Exception e){
            System.debug('Exception hit:' + e);
        }
      finally { }
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
        update myLead;    
    }
}