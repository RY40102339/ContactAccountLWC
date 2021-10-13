/*
*******************************************************************************************************
* (C) Copyright 2021 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Kameron F
* @version 1.0
* @created 10/35/2021
* @description  
* This file is used for the yODAAccountOrderRltdList component 
*
* @test class name - YODA_Account_OrderRltdListControllerTest
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  10/13/2021           Kameron F.              Created Test
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
    }
}