/*
*******************************************************************************************************
* (C) Copyright 2021 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Kameron F
* @version 1.0
* @created 10/19/2021
* @description  
* This class is used for creating Yoda_Error_Logs for debugging
*
* @test class name - YODA_Account_OrderRltdListControllerTest
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  10/19/2021           Kameron F.              Created Test Class
*/

@isTest
public class YODA_Account_OrderRltdListControllerTest {
    @isTest
    static void testController(){
        List<Account> accList = new List<Account>();
        
		accList.add(new Account(Name='Test'));
        accList.add(new Account(Name='Not the Account'));
        
        insert accList;
        
        List<Order> ordList = new List<Order>();
        
        Date randDate = Date.newInstance(2023, 1, 28);
        
        for(Integer i = 0;i<5;i++){
            ordList.add(new Order(AccountID=accList[0].id,EffectiveDate=randDate,Status='Draft'));
            ordList.add(new Order(AccountID=accList[1].id,EffectiveDate=randDate,Status='Draft'));
        }
		
		insert ordList;

        ordList = YODA_Account_OrderRltdListController.getOrders(accList[0].id);
        
        System.assertEquals(5,ordList.size());

        Order indOrder;
        
        // Create a test user
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com'+RandomId);
		//run as system user
        System.runAs(u) {
			indOrder = YODA_Account_OrderRltdListController.getIndividualOrder(ordList[2].id);
            System.assertEquals(true, indOrder!=null);
        }
    }
}