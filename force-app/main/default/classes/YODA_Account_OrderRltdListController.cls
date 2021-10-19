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
* This file is used for the yODAAccountOrderRltdList component 
*
* @test class name - YODA_Account_OrderRltdListControllerTest
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  10/13/2021           Kameron F.              Created Class
*  10/19/2021			Kameron F.				Added individual order method
*/

public without sharing class YODA_Account_OrderRltdListController {
    // returns list of orders for controller
    @AuraEnabled(cacheable=true)
    public static List<Order> getOrders(Id recordId){
        return [SELECT OrderNumber, Account_End_User__r.Name, SO_Number__c, PoNumber, TotalAmount, Sales_Person__r.Name FROM Order WHERE AccountID = :recordId]; 
    }
    @AuraEnabled(cacheable=true)
    public static Order getIndividualOrder(Id recordId){
        return [SELECT OrderNumber , SO_Number__c, PoNumber, AccountId, Account.Name,
                Account_End_User__r.Name, Account_Ship_To__r.Name,
                Requested_Delivery_Date__c, Planned_Delivery_Date__c, // first column
                TotalAmount, CurrencyIsoCode, Company_Currency__c, PoDate, 
                Sales_Person__r.Name, Sales_Office__c, Terms_of_Payment__c,// second column
                OwnerId, Owner.Name, CreatedById, CreatedBy.Name,CreatedDate, // first column
                LastModifiedById, LastModifiedBy.Name,LastModifiedDate, // second
                Description, // first
                Status, EffectiveDate //second
                FROM Order WHERE ID = :recordId];
    }
    // Leaving this as it will likely be necessary in the future
    // Kameron 10/7/2021
    /*@AuraEnabled(cacheable=true)
    public static List<String> translatedLabels(List<String> labels){
        Component.Apex.OutputText output = new Component.Apex.OutputText();
        for(String ind : labels){
            output.expressions.value = '{!$Label.' + ind + '}';
            ind = String.valueOf(output.value);
        }
        return labels;
    }*/
}