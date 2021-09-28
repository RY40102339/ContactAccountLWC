/*
*******************************************************************************************************
* (C) Copyright 2021 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Kameron F
* @version 1.0
* @created 9/24/2021
* @description  
* This class is used for creating Yoda_Error_Logs for debugging
*
* @test class name - YODA_Utility_Test
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  9/24/2021             Kameron F.             Created Class
*/
@isTest
public class YODA_Utility_Test {
	@isTest
    static void utilityTestMethod(){
        // Attempt to make a record that will cause an exception        
        try{
            insert new Contact();
        }catch(Exception e){
            String highLimit = 'Must Exceed Limit'; // 32768 limit
            for(Integer i = 0;i<11;i++)
                highLimit += highLimit;
            YODA_Utility.logError('Backend Process Error',highLimit,
                                  'Class:YODA_Utility_Test; Method: utilityTestMethod(); Line #:'+e.getLineNumber()
                                  +'; Message:'+e.getMessage(),
                                  UserInfo.getUserId());
        }
        
        Yoda_Error_Log__c YEL = [SELECT Name,Error_Type__c,Error_Description__c,Error_Generated_By__c FROM Yoda_Error_Log__c];
        System.assertEquals(32767,YEL.Error_Description__c.length());
        
        //Attempt to insert record that will not cause an exception
        try{
            insert new Account(Name='Test');
        }catch(Exception e){
            YODA_Utility.logError('Backend Process Error',e.getStackTraceString(),
                                  'Class:YODA_Utility_Test; Method: utilityTestMethod(); Line #:'+e.getLineNumber()
                                  +'; Message:'+e.getMessage(),
                                  UserInfo.getUserId());
        }
        
        List<Yoda_Error_Log__c> YELList = [SELECT Name,Error_Type__c,Error_Description__c,Error_Generated_By__c FROM Yoda_Error_Log__c];
        System.assert(YELList.size()==1);
    }
}