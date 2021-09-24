/*
*******************************************************************************************************
* (C) Copyright 2021 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Kameron F
* @version 1.0
* @created 9/14/2021
* @description  
* This trigger is for handling changes made to Opportunity record
*
* @test class name - YODA_Opportunity_TriggerHelper_Test
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  9/14/2021             Kameron F.              Created Trigger
*/

trigger YODA_Opportunity_Trigger on Opportunity (after insert, after update) {
    //Check for bypass setting on User record <Mandatory for all Triggers>
    if(Bypass_Settings__c.getinstance().Bypass_Flow_Rules__c)
        return;
    if(Trigger.isAfter){
        if(Trigger.isUpdate||Trigger.isInsert){
			YODA_Opportunity_TriggerHelper.refreshOpps(Trigger.new);
        }
    }
}