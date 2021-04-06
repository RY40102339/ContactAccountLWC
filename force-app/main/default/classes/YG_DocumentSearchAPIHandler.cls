/********************************************************************************************************
* (C) Copyright 2020 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Vinod A
* @version 1.0
* @created 10/11/2020
* @description 
* This class used to get Document search page functionalities
*
* @test class name - 
*
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  
*/
public class YG_DocumentSearchAPIHandler {
    
    public static User userInformation =  YG_Utility.getLoggedInUserInfo(UserInfo.getUserId());
    //public static User userInformation =  YG_Utility.getLoggedInUserInfo('005p0000003rbfUAAQ');
    
    @Auraenabled
    public static DocumentWrapper searchDocument(String searchKeyword, String modelKeyword, String categoryCode, String modelCode, String docType, 
                                                 Integer getIncludeProduct, Integer start, Integer loadLimit){
                                                     //public static DocumentWrapper searchDocument(){
                                                     //String searchKeyword = 'EJXC40A';
                                                     //String modelKeyword = '';
                                                     //String categoryCode = '';
                                                     //String docType= 'Bull,GS,IM,TI,SD';
                                                     //Integer getIncludeProduct = 0;
                                                     //Integer start = 1;
                                                     
                                                     System.debug('searchKeyword::'+searchKeyword);
                                                     System.debug('modelKeyword::'+modelKeyword);
                                                     System.debug('categoryCode::'+categoryCode);
                                                     System.debug('modelCode::'+modelCode);
                                                     System.debug('docType::'+docType);
                                                     System.debug('getIncludeProduct::'+getIncludeProduct);
                                                     System.debug('start::'+start);
                                                     System.debug('loadLimit::'+loadLimit);
                                                     DocumentWrapper docWrapper = new DocumentWrapper();
                                                     String langCode = YG_CommonUtils.getLanguageCode(userInformation.LanguageLocaleKey);
                                                     System.debug('langCode::'+langCode);
                                                     
                                                     Map<String, YG_Community_Configuration__c> allValues=new Map<String, YG_Community_Configuration__c>();
                                                     allValues = YG_Community_Configuration__c.getAll();
                                                     String systemid = allValues.get('ShippingAPISystemId').Text_1__c;
                                                     System.debug('systemid ::: '+systemid);
                                                     String endpointURL = allValues.get('DocumentAPIEndpointUrl').Text_1__c;
                                                     System.debug('endpointURL ::: '+endpointURL);
                                                     //String loadLimit = allValues.get('Search API Load Record Limit').Text_1__c;
                                                     //System.debug('loadLimit ::: '+loadLimit);
                                                     Integer cnt = 0;
                                                     String docURL = null;
                                                     String model = '';
                                                     if(docType == 'all'){
                                                         docType= 'Bull,GS,IM,TI,SD';                                            
                                                     }                                         
                                                     if(modelKeyword != ''){
                                                         model =   modelKeyword;                                         
                                                     }
                                                     if(modelCode != '' && modelCode != '0'){
                                                         model = modelCode;                                        
                                                     }
                                                     System.debug('model::'+model);
                                                     //To Encode the keyword
                                                     searchKeyword = encodingUtil.urlEncode(searchKeyword,'utf-8').replace('+', '%20');
                                                     System.debug('searchKeyword Encode::'+searchKeyword);
                                                     //The parameter for the endpoint assigning - categoryid and model both parameter can't use at same in an endpoint
                                                     if(categoryCode != '' && model == '' ){
                                                         docURL = endpointURL+'?keyword='+searchKeyword+'&doctypeid='+ docType +'&startrecord='+start+'&requestcount='+loadLimit+'&languageid='+langCode
                                                             +'&systemid='+systemid+'&categoryid='+categoryCode+'&getorderstop='+getIncludeProduct; 
                                                     }else{
                                                         docURL = endpointURL+'?keyword='+searchKeyword+'&doctypeid='+ docType +'&startrecord='+start+'&requestcount='+loadLimit+'&model='+model+'&languageid='+langCode
                                                             +'&systemid='+systemid+'&getorderstop='+getIncludeProduct;   
                                                     }
                                                     System.debug('docURL::'+docURL);
                                                     
                                                     String response = '';
                                                     
                                                     // Instantiate a new http object
                                                     HTTP http=new HTTP();
                                                     HttpResponse res=null;
                                                     
                                                     // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
                                                     HttpRequest req = new HttpRequest();                  
                                                     req.setEndpoint(docURL);
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
                                                                 response = JSON.serializePretty( JSON.deserializeUntyped(res.getBody()) ); 
                                                                 System.debug('response ::: '+response);
                                                                 List<DocumentAPIResponseWrapper>  documentResponse = 
                                                                     (List<DocumentAPIResponseWrapper>)JSON.deserialize(response, List<DocumentAPIResponseWrapper>.class);  
                                                                 for(DocumentAPIResponseWrapper docWrap:documentResponse){
                                                                     cnt = docWrap.Count;
                                                                 }
                                                                 String result = res.getHeader('X-CLA-Message');
                                                                 if(result == 'Normal' ){
                                                                  docWrapper.resResult = 'Normal';
                                                                 }else{
                                                                  docWrapper.resResult = 'Error';
                                                                 }
                                                                 docWrapper.success = true;
                                                                 docWrapper.totalCnt = cnt;
                                                                 docWrapper.documentAPIResponseList = documentResponse;
                                                                 System.debug('documentResponse ::: '+documentResponse); 
                                                                 docWrapper.documentAPIResponseList = YG_DocumentSearchAPIHandler.getDocumentSearchGridData(documentResponse);
                                                                 System.debug('documentResponse Modified for grid ::: '+documentResponse); 
                                                                 
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
                                                     System.debug('docWrapper:::'+docWrapper);
                                                     return docWrapper;
                                                 }
    
    //This method is used to get the data from API response and save as grid.
    public static List<DocumentAPIResponseWrapper> getDocumentSearchGridData(List<DocumentAPIResponseWrapper> docWrapper){
        System.debug('getDocumentSearchGridData::'+docWrapper);
        List<DocumentAPIResponseWrapper> docWrapList=new List<DocumentAPIResponseWrapper>();
        for(DocumentAPIResponseWrapper docWrap:  docWrapper){
            //System.debug('docWrap::'+docWrap);
            DocumentAPIResponseWrapper documentWrap=new DocumentAPIResponseWrapper();
            documentWrap.docName = docWrap.docName;
            documentWrap.docNo = docWrap.docNo;
            documentWrap.DocRevNo = docWrap.DocRevNo;
            documentWrap.DownloadURL = docWrap.DownloadURL;
            documentWrap.DocType = docWrap.DocType;
            documentWrap.Model = docWrap.Model;
            documentWrap.EntryNo = docWrap.EntryNo;
            documentWrap.FileRevNo = docWrap.FileRevNo;
            documentWrap.LanguageID = docWrap.LanguageID;
            documentWrap.Count = docWrap.Count;
            String dateVal = docWrap.AreaOpenDate;
            if(dateVal != null){
                Datetime dt = YG_HelperClass.convertStringToDate(dateVal);
                System.debug('dt::'+dt);
                System.debug('dt::'+dt.format('dd MMM YYYY'));
                documentWrap.AreaOpenDate =  dt.format('dd MMM YYYY');
            }
            documentWrap.Rawfilesize = docWrap.FileSize;
            documentWrap.Rawdate = docWrap.AreaOpenDate;
            if(docWrap.FileSize != null){
                String hrSize;
                decimal m;
                decimal size = decimal.valueOf(docWrap.FileSize);
                if(size > 1024){
                 m = size.divide(1024.0, 1, System.RoundingMode.UP);
                    if( m >= 1){
                    hrSize = m +' MB';
                } else {
                    hrSize = size +' KB';
                }
                }else{
                 hrSize = size +' KB';
                }
                
                
                documentWrap.FileSize =  hrSize;
            }
            if(docWrap.DocType == 'Bull'){
                documentWrap.DocType = 'Brochure';
            }
            if(docWrap.DocType == 'GS'){
                documentWrap.DocType = 'General Specifications';
            }
            if(docWrap.DocType == 'IM'){
                documentWrap.DocType = 'Users Manual';
            }
            if(docWrap.DocType == 'TI'){
                documentWrap.DocType = 'Technical Information';
            }
            if(docWrap.DocType == 'SD'){
                documentWrap.DocType = 'Drawings';
            }
            docWrapList.add(documentWrap);
        }
        System.debug('Modified::'+docWrapList);
        return docWrapList;
    }
    
    
    public class DocumentWrapper{
        @AuraEnabled public List<DocumentAPIResponseWrapper> documentAPIResponseList = new List<DocumentAPIResponseWrapper>();
        @AuraEnabled public boolean success =false;
        @AuraEnabled public Integer totalCnt;
        @AuraEnabled public String resResult;
        @AuraEnabled public String errorCode;
    }
    
    public class DocumentAPIResponseWrapper{
        @AuraEnabled public String docName;
        @AuraEnabled public String docNo;
        @AuraEnabled public String DocRevNo;
        @AuraEnabled public String DownloadURL;
        @AuraEnabled public String Model;
        @AuraEnabled public String DocType;
        @AuraEnabled public String LanguageID;
        @AuraEnabled public String AreaOpenDate;
        @AuraEnabled public String FileSize;
        @AuraEnabled public String Rawfilesize;
        @AuraEnabled public String Rawdate;
        @AuraEnabled public String EntryNo;
        @AuraEnabled public String FileRevNo;
        @AuraEnabled public Integer Count;
        //@AuraEnabled public Date dateValue;
        
    }
    
    
    
}