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
public class YODA_Utility {
	//This method is called in all apex classes when an error occurred
    public static void logError(String errorType, String errorDescription, String apexName, String userId) {
        if(errorDescription.length()>32768){
            errorDescription = errorDescription.substring(0, 32767);
        }
        
        Id uId = null;
        if(userId!=null){
            uId = Id.valueOf(userId);
        } 
        
        Yoda_Error_log__c error = new Yoda_Error_log__c(Error_Type__c=errorType,
                                                      Error_Description__c=errorDescription,
                                                      Error_Brief__c=apexName,
                                                      Error_Generated_By__c=uId);
        insert error;
    }
}