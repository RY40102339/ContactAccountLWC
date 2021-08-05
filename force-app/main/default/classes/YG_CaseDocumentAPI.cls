/*
*******************************************************************************************************
* (C) Copyright 2020 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Jayaprasath TJ
* @version 1.0
* @created 03/31/2021
* @description  
* This class is used for exposing the REST API url for the case API.
*
* @test class name - 
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  04/06/2021           Gokilavani             invoking the Case Attachment API by passing the caseId from UI
*/
public class YG_CaseDocumentAPI {
     public static User userInformation =  YG_Utility.getLoggedInUserInfo(UserInfo.getUserId());
    /** 
     * This method is for invoking the Case API call passing the caseId as parameter from the UI.
     **/ 
    @AuraEnabled
    public static String CaseDocumentAPI(ID caseId){
        String status;
        String StrIncidentNumber;
        System.debug('caseId::'+caseId);
        try{
            Case servorgCase = [SELECT id,ServAir_Incident_Number__c,Product.Category__r.Service_Org__c,Asset.Product2.Category__r.Service_Org__c from Case where Id =:caseId limit 1];
           // system.debug('servorgCase--'+servorgCase);
             StrIncidentNumber=servorgCase.ServAir_Incident_Number__c;
            
            if((servorgCase.Product.Category__r.Service_Org__c == 'IA-PS' || servorgCase.Product.Category__r.Service_Org__c == 'IA-SS'|| servorgCase.Asset.Product2.Category__r.Service_Org__c == 'IA-SS'|| servorgCase.Asset.Product2.Category__r.Service_Org__c == 'IA-PS'))
            {
              //  List<Contentversion> versionDataObjList=new List<Contentversion>();
                List<ContentDocumentLink> contentDocLinkId=[SELECT ContentDocumentId  FROM ContentDocumentLink where LinkedEntityId in ( SELECT Id FROM Case where id in(:caseId)) and LinkedEntity.Type='Case'];
                System.debug('contentDocLinkId---'+contentDocLinkId);
                
                List<Id> cId=new List<Id>();
                for(ContentDocumentLink link:contentDocLinkId){
                    cId.add(link.ContentDocumentId);
                }
                System.debug('cId.size()--'+cId.size());
                
                if(cId.size() > 0){ //To check attachment is available for the case
                    //To get file body
					//versionDataObjList=[select versionData,PathOnClient from Contentversion where contentDocumentid in :cId];
          			// System.debug('versionDataObjList---'+versionDataObjList);
                    for(Contentversion v:[select versionData,PathOnClient from Contentversion where contentDocumentid in :cId]){
                       // string StrVersionData = EncodingUtil.base64Encode(v.versionData);
                        Blob versionData=v.VersionData;
                        String title=v.PathOnClient;
                       // System.debug('StrVersionData---'+StrVersionData);
                       	System.debug('versionData---'+versionData);
                        System.debug('title---'+title);
                        System.debug('StrIncidentNumber---'+StrIncidentNumber);
                        callCaseAPI(StrIncidentNumber,versionData,title);
                       // System.debug('status--'+status);
                    }
                }
            } 
        }catch (Exception e){
            system.debug('Exception Cause::'+e.getCause());
            system.debug('Exception LineNumber::'+e.getLineNumber());
            system.debug('Exception Message::'+e.getMessage());
            system.debug('Exception StackTrace::'+e.getStackTraceString());
            system.debug('Exception TypeName::'+e.getTypeName());
            YG_Utility.logError('case API','Community Component Error',e.getStackTraceString(),
                                'Class:YG_CaseAPI; Method: callCaseDocumentAPI(); Line #:'+e.getLineNumber()
                                +'; Message:'+e.getMessage(),
                                UserInfo.getUserId());
        }
       

        return status;
   }
 @future(callout=true) 
    public static void callCaseAPI(String incidentNumber,Blob versionData,String title){
        
        // Call Custom Setting to get the API Config keys
        Map<String, YG_Community_Configuration__c> commConfig = new Map<String, YG_Community_Configuration__c>();        
        commConfig = YG_Community_Configuration__c.getAll();
        String systemId = commConfig.get('ShippingAPISystemId').Text_1__c;
        String Url = commConfig.get('Case Document API EndPoint URL').Text_1__c;
        
        String status;
        
        //String caseSearch = 'https://library.yokogawa.com:8180/incident/attachfiletocase';
        String endpointURL = Url+'?systemid='+systemId;
        System.debug('endpointURL ::: '+endpointURL);
        String response = '';
        
        // Instantiate a new http object
        Http binding = new Http();
        HttpResponse res = null;
        
        // Instantiate a new HTTP request
        HttpRequest req = new HttpRequest();      
        req.setHeader('Content-Type','application/json'); 
        req.setHeader('Accept', 'application/json');
        req.setEndpoint(endpointURL);  
        //req.setBody('{"incident": {"incidentNo": "'+incidentNumber+'"},"attachmentFile": {"content": "'+EncodingUtil.base64Encode(versionData)+'","fileName": "'+title+'"}}}');
        req.setBody('{'+
                    '"incident": {'+
                    '"incidentNo": "'+incidentNumber+'"'+
                    '},'+
                    '"timelineEntry": {'+
                    '"timeline": {'+
                    '"timelineComment": ""'+
                    '},'+
                    '"attachmentFile": {'+
                    '"content": "'+EncodingUtil.base64Encode(versionData)+'",'+
                    '"fileName": "'+title+'"'+
                    '}'+
                    '}'+
                    '}');
        req.setTimeout(120000);
        req.setMethod('POST'); 
        System.debug('request::'+req.getBody());
        
        try {
            res = binding.send(req);
            
            System.Debug('Status code ::: '+res.getStatusCode());
            System.Debug('response ::: '+res);
            System.Debug('response headers ::: '+res.getHeaderKeys());
            System.Debug('response header ::: '+res.getHeader('X-CLA-Code'));
            
            // Parse the JSON response
            if (res.getStatusCode() == 200) {
                status=res.getStatus();
                System.debug('Success');
            }
            
        } catch(Exception e){
            system.debug('Exception Cause::'+e.getCause());
            system.debug('Exception LineNumber::'+e.getLineNumber());
            system.debug('Exception Message::'+e.getMessage());
            system.debug('Exception StackTrace::'+e.getStackTraceString());
            system.debug('Exception TypeName::'+e.getTypeName());
            YG_Utility.logError('case API','Community Component Error',e.getStackTraceString(),
                                'Class:YG_CaseAPI; Method: callCaseAPI(); Line #:'+e.getLineNumber()
                                +'; Message:'+e.getMessage(),
                                UserInfo.getUserId());
        }
       // return status;
    }
    
}