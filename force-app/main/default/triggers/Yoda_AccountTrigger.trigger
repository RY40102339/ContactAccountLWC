trigger Yoda_AccountTrigger on Account (before delete, before insert, before update, after delete, after insert, after undelete, after update){
  //Trigger updateCurrency only after insert
  //Check for bypass setting on User record <Mandatory for all Triggers>
  if(Bypass_Settings__c.getinstance().Bypass_Flow_Rules__c)
      return;
    if(Trigger.isAfter){  
        if(Trigger.isInsert){
            //Set Currency based on Shipping Country else default to User Currency (if country not in list given)
            Yoda_AccountTriggerHelper.updateAccount(Trigger.New);
         }
      }
}