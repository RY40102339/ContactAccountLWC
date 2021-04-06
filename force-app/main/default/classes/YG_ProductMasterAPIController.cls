/*
*******************************************************************************************************
* (C) Copyright 2020 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Selvaraj T
* @version 1.0
* @created 12/10/2020
* @description 
* This class is used to get the suffix code details of the specific ms code using Product API.
*
* @test class name - YG_ProductMasterAPIControllerTest
*
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  
*  
*
*/

public class YG_ProductMasterAPIController {
    
    public static User userInformation =  YG_Utility.getLoggedInUserInfo(UserInfo.getUserId());
    //public static User userInformation =  YG_Utility.getLoggedInUserInfo('005p0000003rbfUAAQ');
    
    /**
     * This method is to get the suffix code details of the ms code from Product API.
     *
     **/ 
    @AuraEnabled
    public static productModelWrapper getSuffixCodeDetails(String msCode){
        
        system.debug('msCode::'+msCode);
        
        String inpMSCode = msCode;
        String languageId = YG_CommonUtils.getLanguageCode(userInformation.LanguageLocaleKey); //get user's language
        
        //initialize the wrapper 
        productModelWrapper prodModWrap = new productModelWrapper();
        List<productMasterResponseWrapper> prodMasterResWrapList = new List<productMasterResponseWrapper>();
       
        // Instantiate a new http object
        Http http = new Http();
        HttpResponse res=null;
        
        // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
        HttpRequest req = new HttpRequest();                  
        
        try{
            
            //get the request url details from community settings
            Map<String, YG_Community_Configuration__c> allValues = new Map<String, YG_Community_Configuration__c>();
            allValues = YG_Community_Configuration__c.getAll();
            String endpointURL = allValues.get('ProductMasterAPIEndpointURL').Text_1__c;
            String usagearea = allValues.get('ShippingAPIUsageArea').Text_1__c;
            String systemid = allValues.get('ShippingAPISystemId').Text_1__c;
            
            String requestURL = endpointURL+'?mscode='+inpMSCode+'&languageid='+languageId
                +'&usagearea='+usagearea+'&systemid='+systemid;
            
            req.setEndpoint(requestURL);   
            req.setMethod('GET'); 
            
            //hitting the API
            res = http.send(req);
            System.Debug('response body ::: '+res.getBody());        
            System.Debug('Status code ::: '+res.getStatusCode());
            System.Debug('response ::: '+res);
            System.Debug('response headers ::: '+res.getHeaderKeys());
            System.Debug('response header ::: '+res.getHeader('X-CLA-Code'));
            
            //Parsing the JSON response from API
            if(res.getHeader('X-CLA-Code').equals(YG_Constants.CL_CODE_SUCCESS) && res.getStatusCode() == 200){ 
                prodMasterResWrapList = (List<productMasterResponseWrapper>)JSON.deserialize(res.getBody(), List<productMasterResponseWrapper>.class); 
                prodModWrap.success = true;
                prodModWrap.prodMasterResponse = prodMasterResWrapList.get(0);
            }
            else{
                prodModWrap.success = false;
                prodModWrap.errorCode = res.getHeader('X-CLA-Code');
            }
            
        }
        catch(Exception e){
            system.debug('Exception Cause::'+e.getCause());
            system.debug('Exception LineNumber::'+e.getLineNumber());
            system.debug('Exception Message::'+e.getMessage());
            system.debug('Exception StackTrace::'+e.getStackTraceString());
            system.debug('Exception TypeName::'+e.getTypeName());
            YG_Utility.logError('API','Backend Process Error',e.getStackTraceString(),
                               'Class:YG_ProductMasterAPIController; Method: getSuffixCodeDetails(); Line #:'+e.getLineNumber()
                                +'; Message:'+e.getMessage(),
                               UserInfo.getUserId());
            prodModWrap.success = false;
        } 
        
        return prodModWrap;
        
    }
    
    //Wrapper to store the API response
    public class productModelWrapper{
        @AuraEnabled public Boolean success =false;
        @AuraEnabled public String errorCode;
        @AuraEnabled public productMasterResponseWrapper prodMasterResponse;
    }
    
    public class productMasterResponseWrapper{
        @AuraEnabled public string MSCode;
        @AuraEnabled public string Model;
        @AuraEnabled public string ProductName;
        @AuraEnabled public string ModelStatus;
        @AuraEnabled public string ModelStartDate;
        @AuraEnabled public string ModelEndDate;
        @AuraEnabled public List<Suffix> Suffix;
        @AuraEnabled public List<Option> Option;
    }
    
    public class Suffix{
        @AuraEnabled public string SuffixLevel;
        @AuraEnabled public string SuffixLevelName;
        @AuraEnabled public string SuffixID;
        @AuraEnabled public string SuffixSpecDesc1;
        @AuraEnabled public string SuffixSpecDesc2;
        @AuraEnabled public string SuffixSpecDesc3;
        @AuraEnabled public string SuffixSpecDesc4;
        @AuraEnabled public string SuffixStatus;
        @AuraEnabled public string SuffixStartDate;
        @AuraEnabled public string SuffixEndDate;
    }
    
    public class Option{
        @AuraEnabled public string OptionGroup;
        @AuraEnabled public string OptionGroupName;
        @AuraEnabled public string OptionID;
        @AuraEnabled public string OptionSpecDesc1;
        @AuraEnabled public string OptionSpecDesc2;
        @AuraEnabled public string OptionSpecDesc3;
        @AuraEnabled public string OptionSpecDesc4;
        @AuraEnabled public string OptionStatus;
        @AuraEnabled public string OptionStartDate;
        @AuraEnabled public string OptionEndDate;
    }

}