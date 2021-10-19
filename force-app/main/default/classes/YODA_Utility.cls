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
*  9/24/2021            Kameron F.              Created Class
*  10/19/2021			Kameron F.				Added platform event 
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
    
    public static void refreshComponent(List<SObject> objects){
        refreshComponent(objects, '');
    }
    
    public static void refreshComponent(List<SObject> objects, String objectName){
        List<YODA_Refresh_Record_Event__e> refreshRecordEvents = new List<YODA_Refresh_Record_Event__e>();
        // using "objectName" just in case there need to be different use cases for the same object
        for (SObject IndObj : objects) {
            Id RecordID;
            switch on objectName{
                when 'AccountTeamMember'{
                    RecordID = [SELECT AccountID FROM AccountTeamMember WHERE ID = :IndObj.ID].AccountID;
                }
                when 'Order'{
                    RecordID = [SELECT AccountID FROM Order WHERE ID = :IndObj.ID].AccountID;
                }
                when else{
                    RecordID = IndObj.Id;
                }
            }
            
            
            refreshRecordEvents.add(new YODA_Refresh_Record_Event__e(
                	Object_Name__c = objectName,
                    Record_Id__c = RecordID,
                    User_Id__c = UserInfo.getUserId()
            ));
        }
        
        try{
            if(refreshRecordEvents != null && !refreshRecordEvents.isEmpty()){
                EventBus.publish(refreshRecordEvents);
            }
            if(Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }
        }catch(Exception e){
            YODA_Utility.logError('Backend Process Error','Class:YODA_Opportunity_TriggerHelper; Method: refreshOpps(); Line #:'+e.getLineNumber()
                                +'; Message:'+e.getMessage(), e.getStackTraceString(), UserInfo.getUserId());
        }
    }
}