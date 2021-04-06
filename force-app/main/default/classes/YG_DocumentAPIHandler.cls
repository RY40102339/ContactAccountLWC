/*
*******************************************************************************************************
* (C) Copyright 2020 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Chitrakishore
* @version 1.0
* @created 11/08/2020
* @description 
* This class is used to write the methods for Document and the LES API related callout.
*
* @test class name - 
*
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  
*  
*
*/

public class YG_DocumentAPIHandler {
    
    
    
    /**
     * This method is for calling the Document API callout.
     * 
     **/ 
    @AuraEnabled
    
    public static DocumentWrapper searchDocumentCallout(String msCode,String modelCode,String languageId){
		
		System.debug('Inside searchSerialNoCallout ::: msCode ::: '+msCode+' ::: modelCode ::: '+modelCode+' ::: languageId :::'+languageId);        
        DocumentWrapper docWrapper = new DocumentWrapper();
       
        Map<String, YG_Community_Configuration__c> allValues = new Map<String, YG_Community_Configuration__c>();        
        allValues = YG_Community_Configuration__c.getAll();
        String systemid = allValues.get('ShippingAPISystemId').Text_1__c;
        System.debug('systemid ::: '+systemid);
        String endpointURL = allValues.get('DocumentAPIEndpointUrl').Text_1__c;
        
        String docURL = null;
        if(null != msCode && msCode.trim().length() >0)
         docURL = endpointURL+'?doctypeid=GS,IM,TI,SD&mscode='+msCode+'&languageid='+languageId
                          +'&systemid='+systemid+'&outputitem='+YG_Constants.DOCUMENT_OUTPUT_ITEM; 
        
        if(null != modelCode && modelCode.trim().length() >0)
            docURL = endpointURL+'?doctypeid=GS,IM,TI,SD&model='+modelCode+'&languageid='+languageId
                          +'&systemid='+systemid+'&outputitem='+YG_Constants.DOCUMENT_OUTPUT_ITEM; 
        
        String response = '';
        // Instantiate a new http object
        Http http = new Http();
        HttpResponse res=null;
        
        // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
        HttpRequest req = new HttpRequest();                  
        req.setEndpoint(docURL);   
        req.setMethod('GET'); 
        
        //req.setBody(getRequestBody(serialno,languageId,usagearea,systemid));
        System.Debug('request ::: '+req);
        
        try {
            res = http.send(req);
            ///System.Debug('response body ::: '+res.getBody());        
            //System.Debug('Status code ::: '+res.getStatusCode());
            //System.Debug('response ::: '+res);
            System.Debug('response headers ::: '+res.getHeaderKeys());
            System.Debug('response header ::: '+res.getHeader('X-CLA-Code'));
            
            if (res.getStatusCode() == 200){
                
                if (res.getHeader('X-CLA-Code').equals(YG_Constants.CL_CODE_SUCCESS)) { 
                    response = JSON.serializePretty( JSON.deserializeUntyped(res.getBody()) ); 
                    System.debug('response ::: '+response);
                    List<DocumentAPIResponseWrapper>  documentResponse = 
                        (List<DocumentAPIResponseWrapper>)JSON.deserialize(response, List<DocumentAPIResponseWrapper>.class);                       
                    docWrapper.success = true;
                    docWrapper.documentAPIResponseList = documentResponse;
                    System.debug('documentResponse ::: '+documentResponse); 
                } else { 
                    //parse the error code                    
                    docWrapper.success = false;
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
                               'Class:YG_DocumentAPIHandler; Method: searchDocumentCallout(); Line #:'+e.getLineNumber()
                                +'; Message:'+e.getMessage(),
                               UserInfo.getUserId());
            docWrapper.success = false;
        }    
        
        return docWrapper;
        
    }
    
    /**
     * This method is for calling the LES certificate API callout.
     * 
     **/ 
    public static DocumentWrapper searchCertificateCallout(String serialNumber,String languageId){
		
		System.debug('Inside searchCertificateCallout ::: serialNumber ::: '+serialNumber+' ::: languageId :::'+languageId);        
        DocumentWrapper docWrapper = new DocumentWrapper();
       
        Map<String, YG_Community_Configuration__c> allValues = new Map<String, YG_Community_Configuration__c>();        
        allValues = YG_Community_Configuration__c.getAll();
        String systemid = allValues.get('ShippingAPISystemId').Text_1__c;
        System.debug('systemid ::: '+systemid);
        String endpointURL = allValues.get('CertificateAPIEndpointUrl').Text_1__c;
        
        String certificateURL = endpointURL+'?serialno='+serialNumber+'&languageid='+languageId
                          +'&systemid='+systemid; //+'&outputitem='+YG_Constants.OUTPUT_ITEM; 
        
        String response = '';
        // Instantiate a new http object
        Http http = new Http();
        HttpResponse res=null;
        
        // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
        HttpRequest req = new HttpRequest();                  
        req.setEndpoint(certificateURL);   
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
                    List<DocumentAPIResponseWrapper>  documentResponse = 
                        (List<DocumentAPIResponseWrapper>)JSON.deserialize(response, List<DocumentAPIResponseWrapper>.class);                       
                    docWrapper.success = true;
                    docWrapper.documentAPIResponseList = documentResponse;
                    System.debug('documentResponse ::: '+documentResponse); 
                } else { 
                    //parse the error code
                    System.debug(' httpResponse ' + res.getBody() ); 
                    docWrapper.success = false;
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
                               'Class:YG_DocumentAPIHandler; Method: searchCertificateCallout(); Line #:'+e.getLineNumber()
                                +'; Message:'+e.getMessage(),
                               UserInfo.getUserId());
            docWrapper.success = false;
        }    
        
        return docWrapper;
        
    }
    
    public class DocumentWrapper{
        @AuraEnabled public List<DocumentAPIResponseWrapper> documentAPIResponseList = new List<DocumentAPIResponseWrapper>();
        @AuraEnabled public boolean success =false;
        @AuraEnabled public String errorCode;
    }
    
    public class DocumentAPIResponseWrapper{
        @AuraEnabled public String Model;
        @AuraEnabled public String DocType;
        @AuraEnabled public String LanguageID;
        @AuraEnabled public String DownloadURL;
        @AuraEnabled public String DocName;
        @AuraEnabled public String DocNo;
        @AuraEnabled public String FileSize;
        
        //for Certificate
        @AuraEnabled public String DocumentName;
        @AuraEnabled public String SerialNo;
        @AuraEnabled public String DocumentId;
        
    }

}