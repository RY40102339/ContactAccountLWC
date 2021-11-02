/*
*******************************************************************************************************
* (C) Copyright 2021 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Kameron F
* @version 1.0
* @created 10/12/2021
* @description  
* This is the main trigger for Lead DML operations.
*
* @test class name - YODA_Contact_TriggerHelper_Test
*  Change History:
*  MM/DD/YYYY      Developer Name      Comments
*  10/12/2021      Kameron F.          Created Trigger
*/
trigger Yoda_Lead_Trigger on Lead (before insert,after update) {
    //Check for bypass setting on User record <Mandatory for all Triggers>
    if(Bypass_Settings__c.getinstance().Bypass_Flow_Rules__c){
        return;
    }
    if(Trigger.isAfter){
        if(Trigger.isUpdate){
        //    YODA_Lead_TriggerHelper.CloneRecord(Trigger.new,Trigger.oldMap);
			YODA_Utility.refreshComponent(Trigger.new,'Lead');
        }
    }
}