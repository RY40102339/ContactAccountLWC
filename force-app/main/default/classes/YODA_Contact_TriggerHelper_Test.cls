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
*  MM/DD/YYYY      Developer Name      Comments
*  9/9/2021             Kameron F.              Created Class
*  9/23/2021            Kameron F.              Updated API names for region
*  9/24/2021            Kameron F.              Fixed MailingCountry
*  9/27/2021            Hemalatha Gorthy        Added Account address
*  9/30/2021			Kameron F.				Add coverage for Bypass
*  10/22/2021			Kameron F.				Added test for multiple inquiries
*/
@isTest
public class YODA_Contact_TriggerHelper_Test {
    @testSetup
    static void setuptest(){
        Bypass_Settings__c setToAdd = new Bypass_Settings__c(Bypass_Validation_Rules__c =true);
        insert setToAdd;
        
        Campaign cmp = new Campaign(Name='Test Campaign',Description='Test Campaign',Business_Owner__c=UserInfo.getUserId(),Status='Complete');
        insert cmp;
        
        delete setToAdd;
    }
    /*@isTest 
    static void testMultipleInquiry(){
        Account acc = new Account(Name='TestAccount');
        insert acc;
        
        Campaign cmp = [SELECT Name FROM Campaign WHERE Name='Test Campaign'];
        
        Test.startTest();
        List<CampaignMember> cmpMemList = new List<CampaignMember>();
        List<Contact> conList = new List<Contact>();
        List<String> countryList = new List<String>{'Japan','Aruba','Bangladesh','Albania','Belgium','Bermuda','Germany','Cyprus','China',
            ' Australia','Malaysia','Tokelau','Philippines','Thailand','Viet Nam',
            'Korea, Republic of','Algeria','Armenia','Argentina','Afghanistan'};
                
                for(Integer i=0;i<40;i++){
                    String ratingChoice = 'Hot';
                    if(Math.mod(i,2)==0)
                        ratingChoice = 'Warm';
                    
                    conList.add(new Contact(Campaign__c=cmp.id,Rating__c='Hot',Category_Of_Interest__c='Others',AccountID=acc.id,FirstName='First',LastName='Last',
                                            Email='Test@test.com',MailingCountry=countryList[Math.mod(i,20)],Multiple_Inquiry__c=false));
                    
                }
        insert conList;
        
        List<YODA_Contact_TriggerHelper.CloneRecordFlowVariable> FlowList = new List<YODA_Contact_TriggerHelper.CloneRecordFlowVariable>();
        YODA_Contact_TriggerHelper.CloneRecordFlowVariable FlowVariable = new YODA_Contact_TriggerHelper.CloneRecordFlowVariable();
        FlowVariable.con = conList[0];
        FlowList.add(FlowVariable);
        YODA_Contact_TriggerHelper.CloneRecordFlow(FlowList);
        
        Bypass_Settings__c setToAdd = new Bypass_Settings__c(Bypass_Validation_Rules__c =true);
        insert setToAdd;
        
        cmp.Status='Planned';
        update cmp;
        
        delete setToAdd;
        
        for(Contact con : conList){
            cmpMemList.add(new CampaignMember(CampaignID=cmp.id,ContactID=con.id));
        }
        insert cmpMemList;
        Test.stopTest();
        
        Profile p = [SELECT Id FROM Profile WHERE Name='YHQ Administrator'];
        Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com'+RandomId);
        
		//run as B2B due to profile requirements on multiple inquiry
        System.runAs(u){
            for(Contact con:conList){
                con.Multiple_Inquiry__c = true;
            }
    
            try{
                update conList;
            }catch(Exception e){}
            
            
            List<Lead> ldList = [SELECT Id, OwnerId, Owner.Name, LastName FROM Lead];
            Integer count = 0;
            String ownerList = '';
            System.debug(ldList);
            for(Lead ld:ldList){
                if(Group.SObjectType==ld.OwnerId.getSobjectType()){
                    count++;
                }
                ownerList += ld.Owner.Name+' ';  
            }
        
            System.debug(ownerList);        
            System.assertEquals(40, count, 'Owner is changed to Lead Queue');
            
            // Leaving this in case we find a way to test assignment rules
            // Japan T&M, Other T&M, Tele Japan T&M, Tele Other T&M, Tele YCA T&M, Tele YEA T&M, Tele YEF B T&M,
            // Tele YEF GB T&M, Tele YEF G T&M, Tele YEF I T&M, Tele YEF NL T&M, Tele YEM T&M, Tele YIL T&M, Tele YKO T&M, Tele YMA T&M, Tele YNZ T&M, Tele YPI T&M, 
            // Tele YRU T&M, Tele YSA T&M, Tele YSH T&M, Tele YTH T&M, Tele YVN T&M, YCA CA T&M, YCA MX T&M, YCA T&M, YEA T&M, YEF, YEF B T&M, YEF GB T&M, YEF G T&M, 
            // YEF I T&M, YEF NL T&M, YEM T&M, YIL T&M, YKO T&M, YMA T&M, YMI T&M, YNZ T&M, YPI T&M, YRU T&M, YSA T&M, YSH T&M, YTH T&M, YVN T&M
            
			FlowList = new List<YODA_Contact_TriggerHelper.CloneRecordFlowVariable>();
			FlowVariable = new YODA_Contact_TriggerHelper.CloneRecordFlowVariable();
            FlowVariable.con = conList[0];
           	FlowList.add(FlowVariable);
			
            YODA_Contact_TriggerHelper.CloneRecordFlow(FlowList);
            
            setToAdd = new Bypass_Settings__c(Bypass_Flow_Rules__c=true);
            insert setToAdd;
            
            ldList[0].LastName += '1';
            update ldList;
        }
        
    }*/
    // Main test class for Region updates from the Contact Trigger Helper class
    // Kam 9/9/2021
  	@isTest
    static void addressTest(){
        // How to create an account in test class when state country code is enabld
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        Integer randomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com'+randomId,Region__c='YEF');
        Test.startTest();
        insert u;
        
        //Hema test Account for updateAddress logic.
        //1 account with Shipping and another with Billing address
        //Account acc = new Account(Name='TestAccount1010101'); Hema commented to create list of accounts.
        List<Account> acc = new List<Account>();
        acc.add(new Account(Name='TestAccount1010101'));
        acc.add(new Account(Name='TestAccount1010100', ShippingStreet='Harburger Straße 6', ShippingCity='Buxtehude', ShippingCountry='Germany', ShippingPostalCode='21614'));
        acc.add(new Account(Name='TestAccount1010111', BillingState='New York', BillingCity='Schenectady', BillingCountry='United States', BillingPostalCode='12345'));
        //Hema test Account for updateAddress logic.
        insert acc;
        List<Contact> con = new List<Contact>();
        con.add(new Contact(LastName='Tester01010101',MailingCountry='Andorra',Email='TestEmail00001@Email.com',AccountId=acc[0].id,OwnerId=u.id));
        //Hema test Contact for updateAddress logic.
        con.add(new Contact(LastName='Tester01010100', Email='TestEmail01010100@Email.com',AccountId=acc[1].id,OwnerId=u.id));
        con.add(new Contact(LastName='Tester01010111', Email='TestEmail01010111@Email.com',AccountId=acc[2].id,OwnerId=u.id));
		//Hema test Contact for updateAddress logic.
        insert con;
        //YODA_Contact_TriggerHelper.UpdateRegion(con);
        Contact indcon = [SELECT MailingCountry, Region__c,OwnerId FROM Contact WHERE Email = 'TestEmail00001@Email.com'];
        System.assertEquals('YEF', indcon.Region__c, 'Matched Contact Region YEF.');
        
        
        // Test that updating contact does not change region
        indcon.LastName = 'Tester0010101011';
        indcon.MailingCountry = 'China';
        
        update con;
        Test.stopTest();
        con = [SELECT Region__c FROM Contact WHERE LastName = 'Tester0010101011'];
        
        
        System.assertNotEquals('YCN', indcon.Region__c, 'Does not match COntact Region YCN.');
        
        // Check each possible outcome from the getRegion method 
        System.assertEquals('YKO',YODA_Contact_TriggerHelper.getRegion('Korea, Republic of'), 'Matched Contact Region YKO.');
        System.assertEquals('YCA',YODA_Contact_TriggerHelper.getRegion('Canada'), 'Matched Contact Region YCA.');
        System.assertEquals('YCN',YODA_Contact_TriggerHelper.getRegion('Macao'), 'Matched Contact Region YCN.');
        System.assertEquals('YEA',YODA_Contact_TriggerHelper.getRegion('Fiji'), 'Matched Contact Region YEA.');
        System.assertEquals('YMA',YODA_Contact_TriggerHelper.getRegion('Cameroon'), 'Matched Contact Region YMA.');
        System.assertEquals('YRU',YODA_Contact_TriggerHelper.getRegion('Kazakhstan'), 'Matched Contact Region YRU.');
        System.assertEquals('YSA',YODA_Contact_TriggerHelper.getRegion('Chile'), 'Matched Contact Region YSA.');
        System.assertEquals('YJP',YODA_Contact_TriggerHelper.getRegion('Japan'), 'Matched Contact Region YJP.');
        System.assertEquals('Global',YODA_Contact_TriggerHelper.getRegion('Antarctica'), 'Matched Contact Region Global.');
        System.assertEquals('',YODA_Contact_TriggerHelper.getRegion('AUSTRIA'), 'Matched no Contact Region.');
        
		Bypass_Settings__c setToAdd = new Bypass_Settings__c(Bypass_Flow_Rules__c=true);
        insert setToAdd;
        
        //last time, I was about to insert this and test if it bypasses properly
        indcon = new Contact(FirstName='Test',LastName='TestBypass',AccountID=acc[0].id,Email='TestEmail@test.com');
        insert indcon;
    }
}