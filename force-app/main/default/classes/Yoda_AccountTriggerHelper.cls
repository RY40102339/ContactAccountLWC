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
* This class is YODA_AccountTriggerHelper apex class
* 
* @class name - YODA_AccountTriggerHelper
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  9/9/2021             Hemalatha Gorthy        Created Class.
*  9/27/2021            Hemalatha Gorthy        Updated to include JPY.
*/
public without sharing class Yoda_AccountTriggerHelper {
	// Only used in after insert; 
	// Self updates Currency picklist based on Shipping Country.
    public static void updateAccount(List<Account> acs){
            List<Account> newAcList = [SELECT ShippingCountry, CurrencyIsoCode FROM Account WHERE ID IN :acs WITH SECURITY_ENFORCED];
            //loop through each record to update currency
            for(Account ac: newAcList){
                //Added by SR  on 9/23 to fix the negative scenarios
                 if(!getCurrency(ac.ShippingCountry).equals(''))    {
                        ac.CurrencyIsoCode = getCurrency(ac.ShippingCountry);
                    }
            }
            // Make sure we can update the database before even trying
            //if (!Schema.sObjectType.Account.fields.ShippingCountry.isUpdateable()){
               try{
                    update newAcList;
                }catch(Exception e){
                    YODA_Utility.logError('Backend Process Error','Class:YODA_AccountTriggerHelper; Method: updateAccount(); Line #:'+e.getLineNumber()
                                +'; Message:'+e.getMessage(), e.getStackTraceString(), UserInfo.getUserId());
                }
            //}
    }
    // Based on the ShippingCountry field on Account, return the relevant Currency.
    public static String getCurrency(String shippingCountry){
        String newCurr = '';
        switch on shippingCountry {
            when 'Austria', 'Belgium', 'Cyprus', 'Estonia', 'Finland', 'France', 'Germany', 'Greece', 'Ireland', 'Italy', 'Latvia', 'Lithuania', 'Luxembourg', 'Malta', 'Netherlands', 'Portugal', 'Slovakia', 'Slovenia', 'Spain'{
                newCurr = 'EUR';
            }//ends when 'EUR' condition.
            when 'United States'{
                newCurr = 'USD';
            }//ends when 'USD' condition.
            when 'China'{
                newCurr = 'CNY';
            }//ends when 'CNY' condition.
            when 'United Kingdom'{
                newCurr = 'GBP';
            }//ends when 'GBP' condition.
            when 'Korea, Democratic People\'s Republic of', 'Korea, Republic of'{
                newCurr = 'KRW';
            }//ends when 'KRW' condition.
            when 'Singapore'{
                newCurr = 'SGD';
            }//ends when 'SGD' condition.
            when 'India'{
                newCurr = 'INR';
            }//ends when 'INR' condition.
            when 'Japan'{
                newCurr = 'JPY';
            }//ends when 'JPY' condition.
            }//ends swtich case.
        return newCurr;
	}
    
}