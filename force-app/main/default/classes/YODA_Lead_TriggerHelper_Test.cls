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
*/
@isTest
public class YODA_Lead_TriggerHelper_Test {
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