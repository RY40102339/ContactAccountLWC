/*
*******************************************************************************************************
* (C) Copyright 2020 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Chitrakishore M
* @version 1.0
* @created 15/04/2021
* @description  
* This class is used for exposing the REST API url for the plant details.
*
* @test class name - 
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  
*/
@RestResource(urlMapping='/getPlant/*')
global without sharing class YG_PlantAPIRestResource {
    
    public static RestRequest restRequestData = new RestRequest();
    public static String jsonRequest;
    
    @HttpPost
    global static PlantResponse plantSync(){
        
        PlantResponse responseData = new PlantResponse();
        Request_InfoList requestDetails = new Request_InfoList();

        boolean invalidAccountNo = true;
        try {
		   restRequestdata = RestContext.request;
            
           System.debug('::::restRequestdata:::::' + restRequestdata);
           if (restRequestdata != null && restRequestdata.requestBody != null) {  
                jsonRequest = restRequestdata.requestBody.toString();
           }
           System.debug('::::jsonRequest:::::' + jsonRequest);
            
           // parse input json request
            
           requestDetails = (Request_InfoList) System.JSON.deserialize(jsonRequest, Request_InfoList.class);
           String accountNo= requestDetails.accountNo;
            
           System.debug('accountNumber ::: '+accountNo); 
            
           List<Account> parentAcctList = [Select ID, AccountNumber,Name from Account where AccountNumber =: accountNo and type='Customer'];
            
            If(null != parentAcctList && parentAcctList.size()>0){
                invalidAccountNo = false;
                Account parentAcct = parentAcctList.get(0);
                responseData.accountNo = parentAcct.AccountNumber;
                responseData.accountName = parentAcct.Name;
                List<Account> plantList = [Select AccountNumber, Name from Account where (Parent.ID =: parentAcct.ID and type='Plant') OR (Id =: parentAcct.ID And Has_Asset__c = True)];
                if(plantList != null && plantList.size() > 0){
                    List<PlantDetail> plantObjList = new List<PlantDetail>();
                    
                    for (Account plant : plantList){
                        PlantDetail plantObj = new PlantDetail();
                        plantObj.plantCode = plant.AccountNumber;
                        plantObj.plantName = plant.Name;
                        plantObjList.add(plantObj);
                    }
                  responseData.plantList = plantObjList;
                    
                }
            }
            
            
        }
		catch (Exception e) {
                       
            //responseData.status = 'Fail';
            responseData.message = 'Internal Server Error';
            responseData.code = '500';           
                
            system.debug('Exception Cause::'+e.getCause());
            system.debug('Exception LineNumber::'+e.getLineNumber());
            system.debug('Exception Message::'+e.getMessage());
            system.debug('Exception StackTrace::'+e.getStackTraceString());
            system.debug('Exception TypeName::'+e.getTypeName());
            YG_Utility.logError('Plant API','Error',e.getStackTraceString(),
                               'Class:YG_PlantAPIRestResource; Method: doPost(); Line #:'+e.getLineNumber()
                                +'; Message:'+e.getMessage(),null);
        }
        
        return responseData;
                
    }
    
    public class Request_InfoList {
        public String accountNo;
    }
    
    global class PlantResponse {
        //public String status;
        public String message;
        public String code;
        public String accountNo;
        public String accountName;
        public list<PlantDetail> plantList;
        public  PlantResponse(){
        	this.plantList = new list<PlantDetail>(); 
            this.message='success';
            this.code='200';
        }
    }
    
    global class PlantDetail {
        public String plantCode;
        public String plantName;
        
    }

}