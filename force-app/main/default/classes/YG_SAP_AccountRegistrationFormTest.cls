/********************************************************************************************************
* (C) Copyright 2020 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Vipul Kumar
* @version 1.0
* @created 20/09/2021
* @description 
* This test class for YG_SAP_AccountRegistrationForm apex class.
*
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*
*
*/
@isTest
public with sharing class YG_SAP_AccountRegistrationFormTest {
    @isTest
    private static void testClass()
    {
        PageReference pageRef = Page.YG_SAP_AccountRegistrationForm;
	    //Create a new instance of Account
        Account acc = new Account(Name = 'TestAccountName',ShippingCountry = 'India');
            insert acc;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('acc',acc.id);
            ApexPages.StandardController sc = new ApexPages.standardController(acc);
            YG_SAP_AccountRegistrationForm controller = new YG_SAP_AccountRegistrationForm(sc);
            System.assertNotEquals(null,controller.saveAndRedirect(),'Test');
            //Create a new instance of standard controller
       
    }
    
}