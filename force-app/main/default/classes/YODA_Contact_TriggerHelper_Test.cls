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
*  9/24/2021            Kameron F.              Fixed MailingCountry
*/
@isTest
public class YODA_Contact_TriggerHelper_Test {
    // Main test class for Region updates from the Contact Trigger Helper class
    // Kam 9/9/2021
	@isTest
    static void regionTest(){
        // How to create an account in test class when state country code is enabld
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com'+RandomId,Region__c='YEF');
        insert u;
        Test.startTest();
        Account acc = new Account(Name='TestAccount1010101');
        insert acc;
        
        List<Contact> con = new List<Contact>();
        con.add(new Contact(LastName='Tester01010101',MailingCountry='Andorra',Email='TestEmail00001@Email.com',AccountId=acc.id,OwnerId=u.id));
        System.debug(con);
        insert con;
 		
        //YODA_Contact_TriggerHelper.UpdateRegion(con);
        Contact indcon = [SELECT MailingCountry, Region__c,OwnerId FROM Contact WHERE Email = 'TestEmail00001@Email.com'];
        System.debug(indcon);
        System.assertEquals('YEF', indcon.Region__c);
        Test.stopTest();
        
        // Test that updating contact does not change region
        indcon.LastName = 'Tester0010101011';
        indcon.MailingCountry = 'China';
        
        update con;
        
        con = [SELECT Region__c FROM Contact WHERE LastName = 'Tester0010101011'];
        
        
        System.assertNotEquals('YCN', indcon.Region__c);
        
        // Check each possible outcome from the getRegion method 
        System.assertEquals('YKO',YODA_Contact_TriggerHelper.getRegion('Korea, Republic of'));
        System.assertEquals('YCA',YODA_Contact_TriggerHelper.getRegion('Canada'));
        System.assertEquals('YCN',YODA_Contact_TriggerHelper.getRegion('Macao'));
        System.assertEquals('YEA',YODA_Contact_TriggerHelper.getRegion('Fiji'));
        System.assertEquals('YMA',YODA_Contact_TriggerHelper.getRegion('Cameroon'));
        System.assertEquals('YRU',YODA_Contact_TriggerHelper.getRegion('Kazakhstan'));
        System.assertEquals('YSA',YODA_Contact_TriggerHelper.getRegion('Chile'));
        System.assertEquals('YJP',YODA_Contact_TriggerHelper.getRegion('Japan'));
        System.assertEquals('Global',YODA_Contact_TriggerHelper.getRegion('Antarctica'));
        System.assertEquals('',YODA_Contact_TriggerHelper.getRegion('AUSTRIA'));
    }
}