/*
*******************************************************************************************************
* (C) Copyright 2021 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Kameron F
* @version 1.0
* @created 9/9/2021
* @description  
* This class is used for updating the Region__c field on Contact based on MailingCountry
*
* @test class name - YODA_Contact_TriggerHelper_Test
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  9/9/2021             Kameron F.              Created Trigger to update Region__c
*  9/27/2021            Hemalatha Gorthy        Update Mailing address from Account Billing/Shipping
*/

trigger YODA_Contact_Trigger on Contact (after insert) {
    //Check for bypass setting on User record <Mandatory for all Triggers>
    if(Bypass_Settings__c.getinstance().Bypass_Flow_Rules__c){
        return;
    }
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            // Main handler for updating Contact
        	YODA_Contact_TriggerHelper.updateContact(Trigger.New);
        }
    }
}