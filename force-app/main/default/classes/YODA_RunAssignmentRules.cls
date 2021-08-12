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
        System.debug('---'+myLead.firstname+'---'+myLead.lastname+'---\nOWNER BEFORE IS '+ myLead.OwnerId + ' ' + myLead.Owner.Name + ' ' + myLead.Country + ' ' + myLead.Rating + ' ' + myLead.Business_Unit__c);
        myLead.setOptions(dmo);
        //Database.update(toAssign,dmo);
        update myLead;
        Lead l = [SELECT Id, OwnerId, Owner.Name, Rating, Country, Business_Unit__c FROM Lead WHERE Id = :myLead.Id];
        System.debug('\nOWNER AFTER IS '+ l.OwnerId + ' ' + l.Owner.Name+ ' ' + l.Country + ' ' + l.Rating + ' ' + l.Business_Unit__c);
    }
}