/*
*******************************************************************************************************
* (C) Copyright 2021 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Hemalatha Gorthy
* @version 1.0 
* @created 9/24/2021
* @description  
* This test class is used for the YODA_AccountTriggerHelper apex class
*
* @test class name - YODA_AccountTriggerHelper_Test
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  9/9/2021             Hemalatha Gorthy        Created Test Class
*  9/27/2021            Hemalatha Gorthy        Updated to include JPY.
*/

@isTest
public class Yoda_AccountTriggerHelper_Test {
	@isTest
    static void accAccountTest(){
        //Positive test cases
            //List of Countries to test.
            List<String> countryList = New List<String> {'Belgium', 'United States', 'China', 'United Kingdom', 'Korea, Republic of', 'Singapore', 'India', 'Japan'};
            //List of Currencies in the order of Countries listed above.
            List<String> currList = New List<String> {'EUR', 'USD', 'CNY', 'GBP', 'KRW', 'SGD', 'INR', 'JPY'};
            //Create test data of accounts with shipping country listed above.
            List<Account> acs = new List<Account>(); 
        	//Loop through each country to create Accounts.
            for(Integer i=0;i<countryList.size();i++) {
                Account a = new Account(Name='TestAccount' + i, ShippingCountry = countryList[i]);
                acs.add(a);
            }
        	//Insert test account with country Fiji.
            Account ac1 = new Account(Name='TesterAccount',ShippingCountry='Fiji');
            acs.add(ac1);
            //Test starts here
            Test.StartTest();  
            insert acs;
            //Test stops here
            Test.StopTest();  
            //Retrieve created Accounts to verify Currency.
            Boolean validateCurr = true;
            List<String> verifyCurr = new List<String>();
            List<Account> verifyList = [SELECT CurrencyIsoCode FROM Account WHERE Name LIKE 'TestAccount'];
            for(Account verifyacs: verifyList){
                //validate currency from currency list
                if(!(currList.contains(verifyacs.CurrencyIsoCode))){
                    validateCurr = false;
                }
            }
            //Validate currency.
            System.assertEquals(true, validateCurr, 'Currency in list of available currencies.');

        //Negative test case
            //Retrieve user.currency and compare with Account.CurrencyIsoCode for Shipping Country as Japan.
            Account acJapan = [SELECT CurrencyIsoCode FROM Account WHERE Name = 'TesterAccount'];
            System.assertEquals(UserInfo.getDefaultCurrency(), acJapan.CurrencyIsoCode, 'User default currency applied.');
	}
}