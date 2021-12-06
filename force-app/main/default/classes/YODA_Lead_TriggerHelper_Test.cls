/*
*******************************************************************************************************
* (C) Copyright 2021 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Kameron F
* @version 1.0
* @created 10/12/2021
* @description  
* This is the main helper class for YODA_Lead_Trigger
*
* @test class name - YODA_Contact_TriggerHelper_Test
*  Change History:
*  MM/DD/YYYY      Developer Name      Comments
*  10/12/2021      Kameron F.          Created Class
*  11/29/2021	   Kameron F.		   Added test for ownership change
*  11/30/2021	   Kameron F.		   Added test for null accounts and changing contact
*  12/6/2021	   Kameron F.		   Added test for profile checks
*/
@isTest
public class YODA_Lead_TriggerHelper_Test {
    @testSetup
    static void mainSetup(){
        // Creating Queue
        Group testGroup = new Group(Name='QUEUE NAME', Type='Queue');
        insert testGroup;
        
        QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SobjectType = 'Lead');
        insert testQueue;
        
        List<User> userList = new List<User>();
        
        Profile p2 = [SELECT Id FROM Profile WHERE Name='YODA Sales'];
        Integer RandomId2 =Integer.valueOf(Math.rint(Math.random()*1000000));
        User u = new User(Alias = 'standt2', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p2.Id,
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com'+RandomId2);
        userList.add(u);
        
        Integer RandomId3 =Integer.valueOf(Math.rint(Math.random()*1000000));
        User u2 = new User(Alias = 'standt3', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p2.Id,
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com'+RandomId3);
        userList.add(u2);
        
        insert userList;
        
        // Creating valid personas for Sales Person and Sales Manager
        List<PermissionSetGroup> PSG =  [SELECT ID, MasterLabel FROM PermissionSetGroup WHERE MasterLabel ='YODA Sales Manager' OR MasterLabel ='YODA Sales Person']; 
        List<PermissionSetAssignment> psa = new List<PermissionSetAssignment>();
        for(PermissionSetGroup indPSG : PSG){
        	if(indPSG.MasterLabel=='YODA Sales Manager')
          		psa.add(new PermissionSetAssignment(AssigneeId = u.Id,PermissionSetGroupId =indPSG.id));
            else
                psa.add(new PermissionSetAssignment(AssigneeId = u2.Id,PermissionSetGroupId =indPSG.id));
        }
        insert psa;
        
        // Adding both users to queue
        List<GroupMember> gm = new List<GroupMember>();
       	gm.add(new GroupMember(GroupId = testGroup.ID, UserOrGroupId = u.Id));
        gm.add(new GroupMember(GroupId = testGroup.ID, UserOrGroupId = u2.Id));
    	insert gm;
    }
    @isTest
    static void checkOwnerChange(){
        Group testGroup = [SELECT Name FROM Group WHERE Name = 'QUEUE NAME'];
        User u = [SELECT Alias FROM User WHERE Alias = 'standt2'];
        User u2 = [SELECT Alias FROM User WHERE Alias = 'standt3'];
        
       
        
        List<Contact> conList = new List<Contact>();
        Contact con = new Contact(Self_registered_company__c='TestCo',FirstName='JapanQueue1',LastName='Test',
                                  Rating__c='Hot',Category_Of_interest__c='Data Acquisition',MailingCountry='Aruba',
                                  Email='JapanQueue1@test.com');
        
        Contact con2 = new Contact(Self_registered_company__c='TestCo',FirstName='ArubaQueue',LastName='Test',
                                      Rating__c='Hot',Category_Of_interest__c='Data Acquisition',MailingCountry='Aruba',
                                      Email='ArubaQueue@test.com');
        conList.add(con2);
        conList.add(con);
        insert conList;

        // Assigning lead to queue to start test scenarios
        Lead ld = new Lead(Country='Aruba',LastName='Test',FirstName='1',Category_Of_Interest__c='Others',Company='TestCo',Email='Test@test.com');
        ld.OwnerId = testGroup.ID;
        ld.Related_Contact__c = con.id;
        insert ld;
		
        // Testing most Lead Ownership changes
        System.runAs(u){
            // Testing initial Queue to User
            ld.OwnerId = u.id;
            update ld;
            
            con = [SELECT OwnerID, ID FROM Contact WHERE ID = :ld.Related_Contact__c];
            
            System.assertEquals(u.ID, con.OwnerId);
            
            // Testing to make sure lead owner changes to queue but contact owner does not
            ld.OwnerId = testGroup.ID;
            update ld;
            
            con = [SELECT OwnerID, ID FROM Contact WHERE ID = :ld.Related_Contact__c];
            System.assertNotEquals(testGroup.ID, con.OwnerId);
            
            // Testing to make sure no owner changes occur when contact has account
            ld.OwnerID = u.ID;
            update ld;
            
            Account acc = new Account(Name='TestAcc');
            insert acc;
            
            con.AccountID = acc.ID;
            update con;
            
            ld.OwnerID = u2.ID;
            update ld;
            
            con = [SELECT OwnerID, ID FROM Contact WHERE ID = :ld.Related_Contact__c];
            
            System.assertEquals(u.ID, con.OwnerId);
        }
        // Testing updating the related contact to a new contact to change ownership
		con2.OwnerId = u2.id;
        update con2;
        System.runAs(u2){
            ld.Related_Contact__c = con2.ID;
            ld.OwnerId = u.id;
            update ld;
        }
        con2 = [SELECT OwnerID, ID FROM Contact WHERE ID = :ld.Related_Contact__c];
        
        System.assertEquals(u.ID, con2.OwnerId); 
    }
    @isTest
    static void platformEventTest(){
        Date Start = Date.newInstance(2021, 12, 25);
        //List<Lead> ldList = new List<Lead>();
        Lead ld = new Lead(FirstName='Test',LastName='Tester',Email='TestTester@test.com',Country='Aruba',Company='TestCo');
        
        Test.startTest();
        
        YODA_Refresh_Record_Event__e RRE = new YODA_Refresh_Record_Event__e(Record_Id__c='00000000013100000000123');
        
        Database.SaveResult sr = EventBus.publish(RRE);
   
        insert ld;
          
        ld.LastName = 'Tester 1';
        update ld;
        
        Test.stopTest();
        
        System.assertEquals(false, sr.isSuccess(),'Platform event failed to publish');
        
        Bypass_Settings__c setToAdd = new Bypass_Settings__c(Bypass_Flow_Rules__c=true);
        insert setToAdd;
        
        ld = new Lead(FirstName='TestFail',LastName='Tester',Email='TestFailTester@test.com',Country='Aruba',Company='TestCo');

        insert ld;
    }
	/*@isTest
    static void testMultipleInquiry(){
        Campaign cmp = new Campaign();
        List<Lead> ldList = new List<Lead>();
        List<String> countryList = new List<String>{'Japan','Aruba','Bangladesh','Albania','Belgium','Bermuda','Germany','Cyprus','China',
            ' Australia','Malaysia','Tokelau','Philippines','Thailand','Viet Nam',
            'Korea, Republic of','Algeria','Armenia','Argentina','Afghanistan'};
                
        for(Integer i=0;i<100;i++){
            String ratingChoice = 'Hot';
            if(Math.mod(i,2)==0)
                ratingChoice = 'Warm';
            
           
            
            ldList.add(new Lead(Rating='Hot',Category_Of_Interest__c='Others',Company='TestCo',FirstName='First',LastName='Last',
                                Email='Test@test.com',Country=countryList[Math.mod(i,20)],Multiple_Inquiry__c=false));
        }
        insert ldList;
        
        for(Lead ld:ldList){
            ld.Multiple_Inquiry__c = true;
        }
        
        Test.startTest();
        try{
            update ldList;
        }catch(Exception e){}
        Test.stopTest();
        
        ldList = [SELECT Id, OwnerId, LastName FROM Lead];
        Integer count = 0;
        for(Lead ld:ldList){
            if(Group.SObjectType==ld.OwnerId.getSobjectType()){
                count++;
            }            
        }
        
        System.assertEquals(200, count, 'Owner is changed to Lead Queue');
        
        Bypass_Settings__c setToAdd = new Bypass_Settings__c(Bypass_Flow_Rules__c=true);
        insert setToAdd;
        
        //last time, I was about to insert this and test if it bypasses properly
        ldList[0].LastName += '1';
        update ldList;
    }*/
}