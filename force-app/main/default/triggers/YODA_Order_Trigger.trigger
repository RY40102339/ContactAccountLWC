/*
*******************************************************************************************************
* (C) Copyright 2021 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Kameron F
* @version 1.0
* @created 10/13/2021
* @description  
* This file is used for Order trigger operations
*
* @test class name - YODA_Order_TriggerHelper_Test
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  10/13/2021             Kameron F.            Created Trigger
*/

trigger YODA_Order_Trigger on Order (after insert, after update) {
    //Check for bypass setting on User record <Mandatory for all Triggers>
    if(Bypass_Settings__c.getinstance().Bypass_Flow_Rules__c)
        return;
    if(Trigger.isAfter){
        if(Trigger.isUpdate||Trigger.isInsert){
			YODA_Order_TriggerHelper.refreshOrders(Trigger.new);
        }
    }
}