/*
*******************************************************************************************************
* (C) Copyright 2020 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Chitrakishore
* @version 1.0
* @created 12/08/2020
* @description 
* This class is used to write the methods for API related call.
*
* @test class name - YG_DocumentControllerTest
*
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  04/19/2021           Kavya                   Removed Plant__c Object and replaced with Account Object and modified new account lookup field on Asset Object.
*  												Removed Plant__c(Plant) Lookup field from Asset and newly added PlantAccount__c(Account) Lookup field in Asset Object.
*
*/

public class YG_DocumentController {
    
    
    public static User userInformation =  YG_Utility.getLoggedInUserInfo(UserInfo.getUserId());
    
    /**
     * This method is for the document API callout and inserting the response to the Document custom object.
     *  
     **/ 
    
    @AuraEnabled    
    public static void getDocumentAPIDetails(String serialNo, List<String> modelCode, String plantCode, String frm){ 
        
        String languageId = YG_CommonUtils.getLanguageCode(userInformation.LanguageLocaleKey);               
        //mainWrapper mainWrap = new mainWrapper();
        
        System.debug('modelCode :::'+modelCode);
        System.debug('serialNo :::'+serialNo);
        
        Product2 prodObj = null;
        String msCode=null;
        ID contactId = userInformation.Contact.ID;  
        try{
            if(null != serialNo && serialNo.trim().length() >0){
                
            	 Asset assetObj;
                 if('product-history'.equalsIgnoreCase(frm)) {
                 	assetObj=[Select MS_Code__c, Product2.Model_Code__c From Asset 
                                      	Where SerialNumber =: serialNo 
                                        AND Lang_Code__c =: languageId limit 1];
                 } else {
                 /*  Plant__c plantObj = YG_HelperClass.getPlantID(plantCode,languageId);*/
                      Account plantObj = YG_HelperClass.getPlantID(plantCode,languageId);
                   assetObj=[Select MS_Code__c, Product2.Model_Code__c From Asset 
                                      	Where PlantAccount__r.Id=:plantObj.Id 
                                      	AND SerialNumber =: serialNo 
                                        AND Lang_Code__c =: languageId limit 1];
                    
                 }
            	
                
                msCode = assetObj.MS_Code__c;                  
                System.debug('getDocumentAPIDetails msCode ::: '+ msCode);
            }
                    
               	Boolean docExist = YG_HelperClass.getAssetOrProductDetails(modelCode, msCode, languageId);        
                //Asset asset =null;
            	System.debug('docExist ::: '+docExist);
            
            	YG_DocumentAPIHandler.DocumentWrapper documentResult = null;
                YG_DocumentAPIHandler.DocumentWrapper certificateResult = null;
            
            	if(!docExist){  
                    
                    List<Document__c> documentList = new List<Document__c>();
                    List<YG_DocumentAPIHandler.DocumentAPIResponseWrapper> docWrapperList 
                            = new List<YG_DocumentAPIHandler.DocumentAPIResponseWrapper>();
                       System.debug('serialNo**'+serialNo);
                    
                    if(null !=modelCode && modelCode.size()>0){
                        for(String model : modelCode) {
                            
                            documentResult = YG_DocumentAPIHandler.searchDocumentCallout(null , model, languageId);
                            
                             if (null !=documentResult && documentResult.success) { 
                                System.debug('Inside If of documentResult');
                               docWrapperList = documentResult.documentAPIResponseList;
                                System.debug('Inside If of docWrapperList :::'+docWrapperList) ;
                               for(YG_DocumentAPIHandler.DocumentAPIResponseWrapper docWrapper : docWrapperList){
                                    Document__c document = populateDocument(docWrapper, 'docs',serialNo, msCode, languageId);
                                    System.debug('document ::: '+document);
                                    documentList.add(document);
                                }
                            }
                        }
                    }
                 
                    
                    else if(null != serialNo  ){
                      /*  certificateResult = YG_DocumentAPIHandler.searchCertificateCallout(serialNo, languageId);  
                        if(null !=certificateResult && certificateResult.success){
                            System.debug('Inside If of certificateResult');
                            docWrapperList = certificateResult.documentAPIResponseList;
                            System.debug('Inside If of docWrapperList>>> :::'+docWrapperList) ;
                            for(YG_DocumentAPIHandler.DocumentAPIResponseWrapper docWrapper : docWrapperList){
                                Document__c document = populateDocument(docWrapper, 'certs',serialNo, msCode , languageId);
                                System.debug('document ::: '+document);
                                documentList.add(document);
                            }
                    	}
                        System.debug('getDocumentAPIDetails msCode ::: '+ msCode);
                        documentResult = YG_DocumentAPIHandler.searchDocumentCallout(msCode , null ,languageId);
                            
                             if (null !=documentResult && documentResult.success) { 
                                System.debug('Inside If of documentResult');
                               docWrapperList = documentResult.documentAPIResponseList;
                                System.debug('Inside If of docWrapperList :::'+docWrapperList) ;
                               for(YG_DocumentAPIHandler.DocumentAPIResponseWrapper docWrapper : docWrapperList){
                                    Document__c document = populateDocument(docWrapper, 'docs', serialNo, msCode, languageId);
                                    System.debug('document ::: '+document);
                                    documentList.add(document);
                                }
                            }
                      */  
                        
                      List<Document__c> docCerttificationList = getCertificationDocumentList(serialNo,languageId,msCode);
                      documentList = docCerttificationList; 
                    }
                    
                    if(documentList.size() >0){ 
                    	insert documentList;
                    }                 
                
            }
            
        }catch(Exception e){
            system.debug('Exception Cause::'+e.getCause());
            system.debug('Exception LineNumber::'+e.getLineNumber());
            system.debug('Exception Message::'+e.getMessage());
            system.debug('Exception StackTrace::'+e.getStackTraceString());
            system.debug('Exception TypeName::'+e.getTypeName());
            YG_Utility.logError('API','Community Component Error',e.getStackTraceString(),
                               'Class:v; Method: getDocumentAPIDetails(); Line #:'
                                +e.getLineNumber()+'; Message:'+e.getMessage(),
                               UserInfo.getUserId());
        }
    
        //return mainWrap;
    }
    
    public static List<Document__c> getCertificationDocumentList(String serialNo,String languageId,String msCode){
        
        YG_DocumentAPIHandler.DocumentWrapper documentResult = null;
        YG_DocumentAPIHandler.DocumentWrapper certificateResult = null;
        List<Document__c> documentList = new List<Document__c>();
        List<YG_DocumentAPIHandler.DocumentAPIResponseWrapper> docWrapperList 
                            = new List<YG_DocumentAPIHandler.DocumentAPIResponseWrapper>();
        
        certificateResult = YG_DocumentAPIHandler.searchCertificateCallout(serialNo, languageId);  
        System.debug('certificateResult ::: '+certificateResult);
        if(null !=certificateResult && certificateResult.success){
            System.debug('Inside If of certificateResult');
            docWrapperList = certificateResult.documentAPIResponseList;
            System.debug('Inside If of docWrapperList>>> :::'+docWrapperList) ;
            for(YG_DocumentAPIHandler.DocumentAPIResponseWrapper docWrapper : docWrapperList){
                Document__c document = populateDocument(docWrapper, 'certs',serialNo, msCode , languageId);
                System.debug('document ::: '+document);
                documentList.add(document);
            }
        }
        System.debug('getDocumentAPIDetails msCode ::: '+ msCode);
        documentResult = YG_DocumentAPIHandler.searchDocumentCallout(msCode , null ,languageId);
        
        if (null !=documentResult && documentResult.success) { 
            System.debug('Inside If of documentResult');
            docWrapperList = documentResult.documentAPIResponseList;
            System.debug('Inside If of docWrapperList :::'+docWrapperList) ;
            for(YG_DocumentAPIHandler.DocumentAPIResponseWrapper docWrapper : docWrapperList){
                Document__c document = populateDocument(docWrapper, 'docs', serialNo, msCode, languageId);
                System.debug('document ::: '+document);
                documentList.add(document);
            }
        }
        
        return documentList;
        
    }
    
    
    
    /**
     * This method is for inserting the responses from the document API callout to the custom object (i.e.Document__c) 
     * 
     **/ 
    private static Document__c populateDocument(YG_DocumentAPIHandler.DocumentAPIResponseWrapper docWrapper,
                                        String type,String serialNo, String msCode, String languageId){
    	Document__c document = new Document__c();
        String docName =  docWrapper.DocName;    
        
        if('certs'.equals(type)){
           	docName = docWrapper.DocumentName;                                     
        }                                    
        if(null != docName && docName.length() > 80){
            document.Name = docName.substring(0,79);
            document.Document_Name__c = docName;
            
        }else{
            document.Name = docName; 
            document.Document_Name__c = docName;
        }
                    
       	document.Lang_Code__c = languageId;
        document.Link__c = 'https://'+docWrapper.DownloadURL;
        document.File_Size__c = docWrapper.FileSize;
        document.File_Extension__c = YG_Constants.FILE_EXTENSION;
        document.Type__c = YG_Constants.FILE_TYPE;
                                            
        System.debug('msCode ::: '+msCode);
        System.debug('serialNo ::: '+serialNo);
                                            
        if(null != msCode && msCode.trim().length() >0){
             System.debug('Inside if ::: msCode ::: '+msCode);
        	document.MS_Code__c = msCode;
        }
        /*if(null != serialNo && serialNo.trim().length() >0){
        	document.Serial_Number__c = serialNo;                                        
       	}*/
        
                                            
        if(null != docWrapper.DocType){
            if(docWrapper.DocType.EqualsIgnoreCase('GS')){
                document.Category__c = YG_Constants.GENERAL_SPECIFICATION;
            }else if(docWrapper.DocType.EqualsIgnoreCase('IM')){
                document.Category__c = YG_Constants.INSTRUCTION_MANUAL;
            }else if(docWrapper.DocType.EqualsIgnoreCase('TI')){
                document.Category__c = YG_Constants.TECHNICAL_INFORMATION;
            }else if(docWrapper.DocType.EqualsIgnoreCase('SD')){
                document.Category__c = YG_Constants.DRAWING;
            }
            //document.MS_Code__c = docWrapper.MSCode;
            Product2 prodObj = YG_HelperClass.getProductDetails(docWrapper.Model,docWrapper.LanguageID);
            if(null != prodObj){
                document.Product__c = prodObj.Id;
            } 
       	} else if('certs'.equals(type)){
        	document.Category__c = YG_Constants.CERTIFICATE;    
            
            List<Asset> assetList = YG_HelperClass.getAssetBySerialNumber(docWrapper.SerialNo, languageId);
            if(assetList.size() > 0) {
                document.Serial_Number__c = assetList.get(0).id; 
            }
            
        }
        return document;
    }

}