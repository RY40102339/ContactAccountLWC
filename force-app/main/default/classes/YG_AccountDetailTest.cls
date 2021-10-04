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
* This test class for YG_AccountDetail apex class.
*
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*
*
*/
@isTest
public with sharing class YG_AccountDetailTest {

    @isTest
    private static void getAccountTest(){
        
        Test.startTest();
        PageReference pageRef = Page.YG_AccountRegistrationForm;
        Account accrecord = new Account();
        accrecord.Name = 'test';
        accrecord.ShippingCountry = 'India';
        insert accrecord;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('accID',accrecord.id);
        YG_AccountDetail testfunction = new YG_AccountDetail();
        Account acc = testfunction.getAccount();
        system.assertEquals(acc != null, true,'There is no record to return');
        Test.stopTest();
        
    }
    
}