/********************************************************************************************************
* (C) Copyright 2020 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Vinod A
* @version 1.0
* @created 03/12/2020
* @description 
* This class used to get Certificate API search page functionalities
*
* @test class name - 
*
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  
*/
public class YG_CertificateSearchAPIHandler {
    
    public static User userInformation =  YG_Utility.getLoggedInUserInfo(UserInfo.getUserId());
    //public static User userInformation =  YG_Utility.getLoggedInUserInfo('005p0000003rbfUAAQ');
    
    @AuraEnabled
    public static DirectiveSearchResult getDirectiveSearch(){
        DirectiveSearchResult dirRes=new DirectiveSearchResult();
        List<String> codeList=new List<String>();
        List<ResData> certResGridList=new List<ResData>();
        
        String directiveURL = null;
        String response = null;
        Map<String, YG_Community_Configuration__c> allValues=new Map<String, YG_Community_Configuration__c>();
        allValues = YG_Community_Configuration__c.getAll();
        String systemid = allValues.get('ShippingAPISystemId').Text_1__c;
        System.debug('systemid ::: '+systemid);
        String endpointURL = allValues.get('DirectiveSearchAPIEndpointUrl').Text_1__c;
        System.debug('endpointURL ::: '+endpointURL);
        String langCode = YG_CommonUtils.getLanguageCode(userInformation.LanguageLocaleKey);
        System.debug('langCode::'+langCode);
        
        
        directiveURL = endpointURL+'?systemid='+systemid+'&languageid='+langCode;
        System.debug('directiveURL::'+directiveURL);
        
        
        HTTP http=new HTTP();
        HttpResponse res=new HttpResponse();
        HttpRequest req=new HttpRequest();
        req.setEndpoint(directiveURL);
        req.setTimeout(120000);
        req.setMethod('GET');
        
        Try{
            res = http.send(req);
            System.Debug('response body ::: '+res.getBody());        
            System.Debug('Status code ::: '+res.getStatusCode());
            System.Debug('response ::: '+res);                                             
            System.Debug('response headers ::: '+res.getHeaderKeys());                                             
            System.Debug('response header ::: '+res.getHeader('X-CLA-Code'));    
            if (res.getStatusCode() == 200){ 
                dirRes.success = true;
                response = JSON.serializePretty( JSON.deserializeUntyped(res.getBody()) ); 
                System.debug('response ::: '+response);
                if(response != null){
                    List<ResData> responseList = 
                        (List<ResData>)JSON.deserialize(response, List<ResData>.class); 
                    dirRes.ResponseData = responseList;
                    //To get all the derivative code
                    for(ResData resWrap:  responseList){
                        codeList.add(resWrap.DirectiveNo);
                        ResData certResGrid=new ResData();
                        certResGrid.DirectiveName = resWrap.DirectiveName;
                        certResGrid.DirectiveNo = resWrap.DirectiveNo;
                        certResGrid.chkBox = 'checkBox-'+resWrap.DirectiveNo;
                        certResGridList.add(certResGrid);
                    }
                }
                System.debug('certResGridList ::: '+certResGridList);
                dirRes.allDerivativeCode = codeList;
                dirRes.ResponseData = certResGridList;
                System.debug('codeList ::: '+codeList);
                System.debug('dirRes ::: '+dirRes);
                
            }
        }Catch(exception e){  
            dirRes.success = false;
            system.debug('Exception Cause::'+e.getCause());
            system.debug('Exception LineNumber::'+e.getLineNumber());
            system.debug('Exception Message::'+e.getMessage());
            system.debug('Exception StackTrace::'+e.getStackTraceString());
            system.debug('Exception TypeName::'+e.getTypeName());
            YG_Utility.logError('API','Community Component Error',e.getStackTraceString(),
                                'Class:YG_DocumentAPIHandler; Method: searchDocumentCallout(); Line #:'+e.getLineNumber()
                                +'; Message:'+e.getMessage(),
                                UserInfo.getUserId());
        }
        
        return dirRes;
    }
    
    
    @AuraEnabled
    public static CertificateWrapper searchCertificate(String searchKeyword, String modelKeyword, String categoryCode, String modelCode, String msCode, 
                                                       String certType, String certificateNo, Integer start, Integer loadLimit){
                                                           
                                                           System.debug('searchKeyword::'+searchKeyword);
                                                           System.debug('modelKeyword::'+modelKeyword);
                                                           System.debug('categoryCode::'+categoryCode);
                                                           System.debug('modelCode::'+modelCode);
                                                           System.debug('msCode::'+msCode);
                                                           System.debug('certType::'+certType);
                                                           System.debug('certificateNo::'+certificateNo);
                                                           System.debug('start::'+start);
                                                           System.debug('loadLimit::'+loadLimit);                                        
                                                           CertificateWrapper certWrapper=new CertificateWrapper();
                                                           String langCode = YG_CommonUtils.getLanguageCode(userInformation.LanguageLocaleKey);
                                                           System.debug('langCode::'+langCode);
                                                           Map<String, YG_Community_Configuration__c> allValues=new Map<String, YG_Community_Configuration__c>();
                                                           allValues = YG_Community_Configuration__c.getAll();
                                                           String systemid = allValues.get('ShippingAPISystemId').Text_1__c;
                                                           System.debug('systemid ::: '+systemid);
                                                           String endpointURL = allValues.get('CertificateSearchAPIEndpointUrl').Text_1__c;
                                                           System.debug('endpointURL ::: '+endpointURL);
                                                           Integer cnt = 0;
                                                           
                                                           String certURL = null;
                                                           String model = '';
                                                           if(modelKeyword != ''){
                                                               model =   modelKeyword;                                         
                                                           }
                                                           if(modelCode != ''){
                                                               model = modelCode;                                        
                                                           }
                                                           System.debug('model::'+model);
                                                           
                                                           //To Encode the keyword and Mscode
                                                           searchKeyword = encodingUtil.urlEncode(searchKeyword,'utf-8').replace('+', '%20');
                                                           System.debug('searchKeyword Encode::'+searchKeyword);
                                                           if(msCode != null){
                                                               msCode = encodingUtil.urlEncode(msCode,'utf-8').replace('+', '%20');
                                                           }
                                                           System.debug('msCode::'+msCode);
                                                           
                                                           //The parameter for the endpoint assigning - categoryid, model and msCode are the parameter can't call at sametime in an endpoint
                                                           if(categoryCode != ''){
                                                               certURL = endpointURL+'?startrecord='+start+'&requestcount='+loadLimit+'&directiveno='+certType+'&systemid='+systemid+
                                                                   '&languageid='+langCode+'&keyword='+searchKeyword+'&passedcertno='+certificateNo+'&categoryid='+categoryCode;
                                                           }else if(model != ''){
                                                               certURL = endpointURL+'?startrecord='+start+'&requestcount='+loadLimit+'&directiveno='+certType+'&systemid='+systemid+
                                                                   '&languageid='+langCode+'&keyword='+searchKeyword+'&passedcertno='+certificateNo+'&model='+model;
                                                           }else{
                                                               certURL = endpointURL+'?startrecord='+start+'&requestcount='+loadLimit+'&directiveno='+certType+'&systemid='+systemid+
                                                                   '&languageid='+langCode+'&keyword='+searchKeyword+'&passedcertno='+certificateNo+'&mscode='+msCode;
                                                           }
                                                           System.debug('certURL::'+certURL);
                                                           String response = '';
                                                           
                                                           // Instantiate a new http object
                                                           HTTP http=new HTTP();
                                                           HttpResponse res=null;
                                                           
                                                           // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
                                                           HttpRequest req = new HttpRequest();                  
                                                           req.setEndpoint(certURL);
                                                           req.setTimeout(120000);
                                                           req.setMethod('GET');
                                                           
                                                           try {
                                                               res = http.send(req);
                                                               System.Debug('response body ::: '+res.getBody());        
                                                               System.Debug('Status code ::: '+res.getStatusCode());
                                                               System.Debug('response ::: '+res);
                                                               System.Debug('response headers ::: '+res.getHeaderKeys());
                                                               System.Debug('response header ::: '+res.getHeader('X-CLA-Code'));
                                                               
                                                               if (res.getStatusCode() == 200){
                                                                   
                                                                   if (res.getHeader('X-CLA-Code').equals(YG_Constants.CL_CODE_SUCCESS)) { 
                                                                       System.debug('res.getBody()::'+res.getBody());
                                                                       response = JSON.serializePretty( JSON.deserializeUntyped(res.getBody())); 
                                                                       System.debug('response ::: '+response);
                                                                       List<CertificateAPIResponseWrapper>  certResponse = 
                                                                           (List<CertificateAPIResponseWrapper>)JSON.deserialize(response, List<CertificateAPIResponseWrapper>.class); 
                                                                       certWrapper.success = true;
                                                                       System.debug('certResponse ::: '+certResponse);
                                                                       //if(certResponse[0].Count != null){
                                                                           //certWrapper.totalCnt = certResponse[0].Count;
                                                                      //}
                                                                       certWrapper.certificateAPIResponseList = certResponse;
                                                                       System.debug('certResponse ::: '+certResponse); 
                                                                       //for(CertificateAPIResponseWrapper certWrap:certResponse){
                                                                        //cnt = certWrap.Count;
                                                                       //}
                                                                       //certWrapper.totalCnt = cnt;
                                                                   }
                                                               }
                                                           }catch(Exception e){
                                                               system.debug('Exception Cause::'+e.getCause());
                                                               system.debug('Exception LineNumber::'+e.getLineNumber());
                                                               system.debug('Exception Message::'+e.getMessage());
                                                               system.debug('Exception StackTrace::'+e.getStackTraceString());
                                                               system.debug('Exception TypeName::'+e.getTypeName());
                                                               YG_Utility.logError('API','Community Component Error',e.getStackTraceString(),
                                                                                   'Class:YG_DocumentAPIHandler; Method: searchDocumentCallout(); Line #:'+e.getLineNumber()
                                                                                   +'; Message:'+e.getMessage(),
                                                                                   UserInfo.getUserId());
                                                               certWrapper.success = false;
                                                           } 
                                                           
                                                           
                                                           
                                                           System.debug('certWrapper ::: '+certWrapper); 
                                                           return certWrapper;
                                                           
                                                       }
    
    public class CertificateWrapper{
        @AuraEnabled public List<CertificateAPIResponseWrapper> certificateAPIResponseList;
        @AuraEnabled public boolean success =false;
        //@AuraEnabled public Integer totalCnt;
        @AuraEnabled public String errorCode;
    }
    public class CertificateAPIResponseWrapper{
        @AuraEnabled public String DirectiveName;
        @AuraEnabled public String ModelName;
        @AuraEnabled public String Model;
        @AuraEnabled public String DownloadURL;
        @AuraEnabled public String PassedCertNo;
        @AuraEnabled public String AdditionalNotes;
        @AuraEnabled public String CertSearchMemo;
        @AuraEnabled public Integer Count;
    }
    
    
    public class DirectiveSearchResult {
        @AuraEnabled public boolean success =false;
        @AuraEnabled public List<ResData> ResponseData;
        @AuraEnabled public List<String> allDerivativeCode;
        
    }
    
    public class ResData{
        @AuraEnabled public String DirectiveName;
        @AuraEnabled public String DirectiveNo;
        @AuraEnabled public String chkBox;// this is used to know the ui checkbox id
    }
    
}