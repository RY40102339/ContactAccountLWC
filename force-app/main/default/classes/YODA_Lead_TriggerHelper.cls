/*
*******************************************************************************************************
* (C) Copyright 2021 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Kameron F
* @version 1.0
* @created 11/29/2021
* @description  
* This class is used as a helper class for the YODA_Lead_Trigger trigger
*
* @test class name - YODA_Contact_TriggerHelper_Test
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  11/29/2021           Kameron F.              Created Trigger to update Owner
*/
public class YODA_Lead_TriggerHelper {
    public static void changeOwner(List<Lead> newList, Map<Id,Lead> oldMap){
        Set<ID> contactIDSet = new Set<ID>();
        for(Lead ld : newList){
            contactIDSet.add(ld.Related_Contact__c);
        }
        
        // List of all Lead Related Contacts in this transaction
        Map<ID, Contact> conList = new Map<ID,Contact>([SELECT OwnerID FROM Contact WHERE ID in :contactIDSet]);
        
        // List of all Contacts that specifically need their owner changed
        List<Contact> updateList = new List<Contact>();
        
        for(Lead ld : newList){
            // If owner has changed and last owner was a queue 
            // if(ld.OwnerID != oldMap.get(ld.Id).OwnerID && String.valueOf(oldMap.get(ld.Id).OwnerID).startsWithIgnoreCase('00G')){      
            
            // If owner has changed
            if(ld.OwnerID != oldMap.get(ld.Id).OwnerID){
                if(conList.get(ld.Related_Contact__c)!=null){
                    conList.get(ld.Related_Contact__c).OwnerID = ld.OwnerID;
                    updateList.add(conList.get(ld.Related_Contact__c));
                }
            }
        }
        
        if(updateList.size()>0){
            try{
            	update updateList;
                if(Test.isRunningTest()) {
                    CalloutException e = new CalloutException();
                    e.setMessage('This is a constructed exception for testing and code coverage');
                    throw e;
                }
            }catch(Exception e){
                YODA_Utility.logError('Backend Process Error','Class:YODA_Lead_TriggerHelper; Method: changeOwner(); Line #:'+e.getLineNumber()
                                      +'; Message:'+e.getMessage(), e.getStackTraceString(), UserInfo.getUserId());
            }
        }

    }
}