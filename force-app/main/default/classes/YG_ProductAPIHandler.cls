/*
*******************************************************************************************************
* (C) Copyright 2020 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Chitrakishore
* @version 1.0
* @created 13/07/2020
* @description 
* This class is used to write the methods for API related call.
*
* @test class name - YG_ProductRegistrationControllerTest
*
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  
*  
*
*/

/* with sharing */
public class YG_ProductAPIHandler {
    
    /**
     * This method is for the serial number API call out.
     **/ 
    public static SearchSerialNumWrapper searchSerialNoCallout(String serialno,String languageId){
		
		System.debug('Inside searchSerialNoCallout ::: serialno ::: '+serialno+' ::: languageId :::'+languageId);        
        SearchSerialNumWrapper searchSerialNum = new SearchSerialNumWrapper();
        
        Map<String, YG_Community_Configuration__c> allValues = new Map<String, YG_Community_Configuration__c>();        
        allValues = YG_Community_Configuration__c.getAll();
        String systemid = allValues.get('ShippingAPISystemId').Text_1__c;
        System.debug('systemid ::: '+systemid);
		String usagearea = allValues.get('ShippingAPIUsageArea').Text_1__c;
        String endpointURL = allValues.get('ShippingAPIEndpointURL').Text_1__c;
        
        String shippingURL = endpointURL+'?serialno='+serialno+'&languageid='+languageId
                          +'&usagearea='+usagearea+'&systemid='+systemid; 
        
        String response = '';
        // Instantiate a new http object
        Http http = new Http();
        HttpResponse res=null;
        
        // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
        HttpRequest req = new HttpRequest();                  
        req.setEndpoint(shippingURL);   
        req.setMethod('GET'); 
        
        //req.setBody(getRequestBody(serialno,languageId,usagearea,systemid));
        System.Debug('request ::: '+req);
        
        try {
            res = http.send(req);
            System.Debug('response body ::: '+res.getBody());        
            System.Debug('Status code ::: '+res.getStatusCode());
            System.Debug('response ::: '+res);
            System.Debug('response headers ::: '+res.getHeaderKeys());
            System.Debug('response header ::: '+res.getHeader('X-CLA-Code'));
            
            if (res.getStatusCode() == 200){
                
                if (res.getHeader('X-CLA-Code').equals(YG_Constants.CL_CODE_SUCCESS)) { 
                    response = JSON.serializePretty( JSON.deserializeUntyped(res.getBody()) ); 
                    System.debug('response ::: '+response);
                    List<ShippingAPIResponseWrapper>  shippingResponse = 
                        (List<ShippingAPIResponseWrapper>)JSON.deserialize(response, List<ShippingAPIResponseWrapper>.class);                       
                    searchSerialNum.success = true;
                    searchSerialNum.shippingAPIResponse = shippingResponse.get(0);
                    System.debug('shippingResponse ::: '+shippingResponse); 
                } else { 
                    //parse the error code
                    System.debug(' httpResponse ' + res.getBody() ); 
                    searchSerialNum.success = false;
                    //throw new CalloutException( res.getBody() ); 
                }  
                
            }

        } catch(Exception e){
            system.debug('Exception Cause::'+e.getCause());
            system.debug('Exception LineNumber::'+e.getLineNumber());
            system.debug('Exception Message::'+e.getMessage());
            system.debug('Exception StackTrace::'+e.getStackTraceString());
            system.debug('Exception TypeName::'+e.getTypeName());
            YG_Utility.logError('API','Community Component Error',e.getStackTraceString(),
                               'Class:YG_APIController; Method: callRestWS(); Line #:'+e.getLineNumber()
                                +'; Message:'+e.getMessage(),
                               UserInfo.getUserId());
            searchSerialNum.success = false;
        }    
        
        return searchSerialNum;
        
    }
    
    public class SearchSerialNumWrapper{
        @AuraEnabled public ShippingAPIResponseWrapper shippingAPIResponse = new ShippingAPIResponseWrapper();
        @AuraEnabled public boolean success =false;
        @AuraEnabled public String errorCode;
    }
    
    public class ShippingAPIResponseWrapper{
        
        @AuraEnabled public string serialNo;
        @AuraEnabled public string modelCode;
        @AuraEnabled public string mSCode;
        @AuraEnabled public string productName;
        @AuraEnabled public string productCareer;
        @AuraEnabled public string tokuchuNo;
        @AuraEnabled public string xJNo;
        @AuraEnabled public string linkageNo;
        @AuraEnabled public string projectDefinition;
        @AuraEnabled public String productionDate;
        @AuraEnabled public string orderNo;
        @AuraEnabled public string poNo;
        @AuraEnabled public string orderDate;
        @AuraEnabled public List<CombiProd> combiProd;
        @AuraEnabled public List<OrderInstSummary> orderInstSummary;
        @AuraEnabled public List<OrderInstSpecified> orderInstSpecified;
        
        // not from API
        @AuraEnabled public string parentChildFlag;
        
    }
    
    public class CombiProd{
         @AuraEnabled public string ProductName;
         @AuraEnabled public string ModelCode;
         @AuraEnabled public string SerialNo;
         @AuraEnabled public string ParentChildFlag;
    }
    
    public class OrderInstSummary{
        @AuraEnabled public string TitleCode;
        @AuraEnabled public string InstName;
        @AuraEnabled public string InstData;
    }
    
    public class OrderInstSpecified{
        
    } 
    
    /*public static string getRequestBody (String serialno,String languageId,String usagearea,String systemid){
        
        string requestBody = '{ "serialno" : "'+serialno+'","languageId":"'+languageId+'","usagearea":"'+usagearea+'","systemid":"'+systemid+'"}';
        System.debug('Inside getRequestBody ::: request body ::: '+requestBody);
        return requestBody;
    }*/

}