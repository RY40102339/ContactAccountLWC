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