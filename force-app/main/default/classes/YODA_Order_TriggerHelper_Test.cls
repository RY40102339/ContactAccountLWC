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
* This file is used for testing Order trigger operations
*
* @test class name - YODA_Order_TriggerHelper_Test
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  10/13/2021           Kameron F.              Created Test
*/

@isTest
public class YODA_Order_TriggerHelper_Test {
	@isTest
    static void platformEventTest(){
        Date Start = Date.newInstance(2021, 12, 25);
        List<Order> oppList = new List<Order>();
        Order ord = new Order(EffectiveDate=Start);
        
        Test.startTest();
        
        YODA_Refresh_Record_Event__e RRE = new YODA_Refresh_Record_Event__e(Record_Id__c='00000000013100000000123');
        
        Database.SaveResult sr = EventBus.publish(RRE);
   
        insert ord;
          
        Test.stopTest();
        
        System.assertEquals(false, sr.isSuccess(),'Platform event failed to publish');
    }
}