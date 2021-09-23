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
* This test class is used for the YODA_Contact_TriggerHelper apex class
*
* @test class name - YODA_Contact_TriggerHelper_Test
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  9/9/2021             Kameron F.              Created Class
*  9/23/2021            Kameron F.              Updated API names for region
*/

@isTest
public class YODA_Contact_TriggerHelper_Test {
    // Main test class for Region updates from the Contact Trigger Helper class
    // Kam 9/9/2021
	@isTest
    static void regionTest(){
        Contact con = new Contact(LastName='Tester',MailingCountry='Korea, Democratic People\'s Republic of');
        insert con;
        
        con = [SELECT Region__c FROM Contact WHERE LastName = 'Tester'];
        
        System.assertEquals('YKO', con.Region__c);
        
        // Test that updating contact does not change region
        con.LastName = 'Tester01';
        con.MailingCountry = 'China';
        
        update con;
        
        con = [SELECT Region__c FROM Contact WHERE LastName = 'Tester01'];
        
        
        System.assertNotEquals('YCN', con.Region__c);
        
        // Check each possible outcome from the getRegion method 
        System.assertEquals('YEF',YODA_Contact_TriggerHelper.getRegion('Austria'));
        System.assertEquals('YCA',YODA_Contact_TriggerHelper.getRegion('Canada'));
        System.assertEquals('YCN',YODA_Contact_TriggerHelper.getRegion('Macao'));
        System.assertEquals('YEA',YODA_Contact_TriggerHelper.getRegion('Fiji'));
        System.assertEquals('YMA',YODA_Contact_TriggerHelper.getRegion('Cameroon'));
        System.assertEquals('YRU',YODA_Contact_TriggerHelper.getRegion('Kazakhstan'));
        System.assertEquals('YSA',YODA_Contact_TriggerHelper.getRegion('Chile'));
        System.assertEquals('YJP',YODA_Contact_TriggerHelper.getRegion('Japan'));
        System.assertEquals('Global',YODA_Contact_TriggerHelper.getRegion('Antarctica'));
        System.assertEquals('None',YODA_Contact_TriggerHelper.getRegion('AUSTRIA'));
    }
}