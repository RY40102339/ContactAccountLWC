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
*/

public without sharing class YODA_Account_OrderRltdListController {
    // returns list of orders for controller
    @AuraEnabled(cacheable=true)
    public static List<Order> getOrders(Id recordId){
        return [SELECT OrderNumber, Account_End_User__r.Name, PoNumber, TotalAmount, Sales_Person__r.Name FROM Order WHERE AccountID = :recordId]; 
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
