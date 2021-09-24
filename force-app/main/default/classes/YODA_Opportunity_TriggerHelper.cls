/*
*******************************************************************************************************
* (C) Copyright 2021 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Kameron F
* @version 1.0
* @created 9/14/2021
* @description  
* This class is used for publishing the YODA_Refresh_Record_Event__e for yODAAccountOppRltdList 
* to use for refreshing data
* 
* @test class name - YODA_Opportunity_TriggerHelper_Test
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  9/14/2021             Kameron F.              Created class
*/

public class YODA_Opportunity_TriggerHelper {
    
    public static void refreshOpps(List<Opportunity> Opps){
        List<YODA_Refresh_Record_Event__e> refreshRecordEvents = new List<YODA_Refresh_Record_Event__e>();
        for (Opportunity Opp : Opps) {
            refreshRecordEvents.add(new YODA_Refresh_Record_Event__e(
                    Record_Id__c = Opp.Id,
                    User_Id__c = UserInfo.getUserId()
            ));
        }
        try{
            if(refreshRecordEvents != null && !refreshRecordEvents.isEmpty()){
                EventBus.publish(refreshRecordEvents);
            }
        }catch(Exception e){
            System.debug('Exception during publishing of refresh platform events-->'+e.getMessage());
        }
    }
}