/*
*******************************************************************************************************
* (C) Copyright 2021 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Kameron F
* @version 1.0
* @created 10/13/2021
* @description  

* This file is used for handling Order trigger operations
* @test class name - YODA_AccountTeamMemberTriggerHelper_Test
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  10/19/2021           Kameron F.              Created Trigger
*/

public class YODA_Order_TriggerHelper {
    public static void refreshOrders(List<Order> Orders){
        List<YODA_Refresh_Record_Event__e> refreshRecordEvents = new List<YODA_Refresh_Record_Event__e>();
        for (Order IndOrder : Orders) {
            refreshRecordEvents.add(new YODA_Refresh_Record_Event__e(
                    Record_Id__c = IndOrder.Id,
                    User_Id__c = UserInfo.getUserId()
            ));
        }
        try{
            if(refreshRecordEvents != null && !refreshRecordEvents.isEmpty()){
                EventBus.publish(refreshRecordEvents);
            }
        }catch(Exception e){
            YODA_Utility.logError('Backend Process Error','Class:YODA_Opportunity_TriggerHelper; Method: refreshOpps(); Line #:'+e.getLineNumber()
                                +'; Message:'+e.getMessage(), e.getStackTraceString(), UserInfo.getUserId());
        }
    }
}
