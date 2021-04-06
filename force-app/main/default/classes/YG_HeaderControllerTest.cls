/********************************************************************************************************
* (C) Copyright 2020 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Selvaraj T
* @version 1.0
* @created 02/06/2020
* @description 
* This test class for YG_HeaderController apex class.
*
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*
*
*/
@isTest
public class YG_HeaderControllerTest {
    
    @isTest static void testAccLogo(){
        
        //Inserting test account record
        Account acc = new account();
        acc.name='XYZ Account';        
        //acc.DUNS_Number__c=102224533;
        acc.Account_Logo__c = 'https://www.test.com';
        insert acc;    
        
        //Inserting test contact record
        Contact con = new Contact();   
        con.FirstName='User';
        con.LastName='CVX AU';
        con.Email='cvxauuser011@chevron.com';
        con.accountid=acc.id; 
        insert con;
        
        //Inserting test portal user record
        Profile profile = [Select Id From Profile Where Name='Customer Portal User'];
        
        User user = new User(Alias = 'comm', Email='yg.qa167@gmail.com',ContactId=con.id,
                             EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                             LocaleSidKey='en_US', ProfileId = profile.Id,
                             TimeZoneSidKey='America/Los_Angeles', UserName='yg.qa167@gmail.com');
        insert user;
            
        string accLogo = YG_HeaderController.getAccountLogo();
        system.assertEquals(null, accLogo);
        
    }

}