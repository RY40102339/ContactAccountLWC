/*
*******************************************************************************************************
* (C) Copyright 2020 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Citrakishore M
* @version 1.0
* @created 11/11/2020
* @description  
* This class is used to call the case registration API.
*
* @test class name - 
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  
*/


public class YG_CaseRegistrationAPIController {
    
    public static User userInformation =  YG_Utility.getLoggedInUserInfo(UserInfo.getUserId());
    
    @future(callout=true)
    public static void callCaseRegistrationAPI(ID caseId){

        Case caseAfterIns = [Select CaseNumber,Description,Subject,type,Service_you_require__c,Product.Model_Code__c,Asset.Product2.Model_Code__c from case where id =:caseId];
        
        YG_CaseRegistrationAPIController.CaseRegInputParamWrapper caseRegInput = new YG_CaseRegistrationAPIController.CaseRegInputParamWrapper();
        caseRegInput.incidentNote = caseAfterIns.Description;
        caseRegInput.incidentMemo = caseAfterIns.Subject;
        if(null != caseAfterIns.Type && caseAfterIns.Type.equals('Request For Service'))
        	caseRegInput.caseTypeCrm = '010';
        
        caseRegInput.caseNumber = caseAfterIns.CaseNumber;
        if(null != caseAfterIns.Product.Model_Code__c){
        	caseRegInput.productCd = caseAfterIns.Product.Model_Code__c;    
        }
        else{
            caseRegInput.productCd = caseAfterIns.Asset.Product2.Model_Code__c;
        }
        caseRegInput.caseClassTypeCrm = caseAfterIns.Service_you_require__c;
        
        Map<String, YG_Community_Configuration__c> allValues = new Map<String, YG_Community_Configuration__c>();        
        allValues = YG_Community_Configuration__c.getAll();
        String systemid = allValues.get('ShippingAPISystemId').Text_1__c;
        System.debug('systemid ::: '+systemid);
        String endpointURL = allValues.get('Case Registration API Endpoint URL').Text_1__c;
        
        String caseRegURL = endpointURL+'?systemid='+systemid;
        
        String response = '';
        // Instantiate a new http object
        Http http = new Http();
        HttpResponse res=null;
        
        // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
        HttpRequest req = new HttpRequest();  
        req.setHeader('Content-Type','application/json'); 
        req.setHeader('Accept', 'application/json');          
        req.setEndpoint(caseRegURL);   
        req.setMethod('POST');    
        req.setBody(getRequestBody(userInformation,caseRegInput));
        System.Debug('req:'+req);
        System.Debug('request ::: '+req);
        
        CaseRegisterationAPIResponseWrapper caseResponseObj = null;
        try {
            res = http.send(req);
           
            System.Debug('Status code ::: '+res.getStatusCode());
            System.Debug('response >>>> ::: '+res.getBody());
            //System.Debug('response headers ::: '+res.getHeaderKeys());
            //System.Debug('response header ::: '+res.getHeader('X-CLA-Code'));
            
            
            if (res.getStatusCode() == 200){                
                  
                response = JSON.serializePretty( JSON.deserializeUntyped(res.getBody()) );
                
                //System.debug('response ::: '+response);                    
                caseResponseObj = (CaseRegisterationAPIResponseWrapper) System.JSON.deserialize(res.getBody(), CaseRegisterationAPIResponseWrapper.class);
                //System.debug('caseResponseObj ::: '+caseResponseObj);   
                
                caseAfterIns.ServAir_Incident_Number__c = caseResponseObj.incidentNo;
                update caseAfterIns;
                
             }  else { 
            	//parse the error code
                System.debug(' httpResponse ' + res.getBody() );
                //docWrapper.success = false;
                //throw new CalloutException( res.getBody() );                
            }

        } catch(Exception e){
            system.debug('Exception Cause::'+e.getCause());
            system.debug('Exception LineNumber::'+e.getLineNumber());
            system.debug('Exception Message::'+e.getMessage());
            system.debug('Exception StackTrace::'+e.getStackTraceString());
            system.debug('Exception TypeName::'+e.getTypeName());
            YG_Utility.logError('API','Community Component Error',e.getStackTraceString(),
                               'Class:YG_CaseRegistrationAPIController; Method: callCaseRegistrationAPI(); Line #:'+e.getLineNumber()
                                +'; Message:'+e.getMessage(),
                               UserInfo.getUserId());
            
        }        

    }
    
    public static string getRequestBody (User userInformation,CaseRegInputParamWrapper caseRegInput){
        
        String accountNumber = userInformation.Contact.Account.AccountNumber;
        String emailAddress = userInformation.Contact.Email;
        String fax = userInformation.Contact.Fax;
        String name = userInformation.Contact.Name;
        String title = userInformation.Contact.Title;
        String department = userInformation.Contact.Department;
        String phone = userInformation.Contact.Phone;
        String mobile = userInformation.Contact.MobilePhone;
        
        Map<String, YG_Community_Configuration__c> allValues = new Map<String, YG_Community_Configuration__c>();        
        allValues = YG_Community_Configuration__c.getAll();
		String serviceOrgId = allValues.get('Case Registration API serviceOrgId').Text_1__c;
        
        String requestBody ='{'+                               
                                '"dlvCustomerBranch": {'+
                                '"customerBranchCd": "'+accountNumber+'"'+
                                '},'+
                                '"incidentMemo": "'+caseRegInput.incidentMemo+'",'+
                                '"incidentNote": "'+caseRegInput.incidentNote+'",'+
                                //'"serviceOrg": {'+
                                //'"id": "'+serviceOrgId+'"'+
                                //'},'+
                                '"caseTypeCrm": "'+caseRegInput.caseTypeCrm+'",'+
                                '"caseClassTypeCrm": "'+caseRegInput.caseClassTypeCrm+'",'+
                                '"productCrm": {'+
                                '"productCd": "'+caseRegInput.productCd+'"'+
                                '},'+
            					'"sourceDivCdCrm": {'+
            					'"divCd": "050" '+
            					'},'+
                                '"expandMemo1": "'+caseRegInput.caseNumber+'",'+
            					'"incidentContactCrms":{'+
                                    '"incidentContactCrm": {'+
                                        '"contactDivCd": {'+
                                            '"divCd": "010"'+
                                            '},'+
                                        '"emailAddress": "'+emailAddress+'",'+
                                        '"faxNo": "'+fax+'",'+
                                        '"contactName": "'+name+'",'+
                                        '"positionName": "'+title+'",'+
                                        '"organizationName": "'+department+'",'+
                                        '"telNo": "'+phone+'",'+
                                        '"telNo2": "'+mobile+'"'+
                                    '}'+
            				    '}'+
                            '}';
        
        System.debug('request body :::: '+requestBody);                              
        return requestBody;
    }
    
    public class CaseRegisterationAPIResponseWrapper{
        
        @AuraEnabled public String incidentNo;//ServAir_Incident_Number__c
        @AuraEnabled public String incidentStatus; //Status
        @AuraEnabled public String primaryDlvProduct;//Asset
        @AuraEnabled public Datetime customerRequestDatetime;//Preferred_Service_Inquiry_Date__c + Preferred_Service_Inquiry_Time__c
        //@AuraEnabled public String dlvCustomerBranch;//Input:::Account
        @AuraEnabled public String incidentMemo;//Input:::Subject
        @AuraEnabled public String incidentNote;//Input::: Description
        @AuraEnabled public String contractItem;//ServiceContract
        @AuraEnabled public String caseTypeCrm;//Input::: Case_Main_Type__c
        @AuraEnabled public String caseClassTypeCrm;//Input::: Case_Sub_Type__c
        @AuraEnabled public SourceDivCdCrm sourceDivCdCrm;//Source
        @AuraEnabled public Datetime closedDatetimeCrm;//ClosedDate
        //@AuraEnabled public String priorityDivCdCrm;//Priority
        @AuraEnabled public String plantCrm;//plant
        @AuraEnabled public String product;//Product
        @AuraEnabled public String targetLcaMainteIdCrm;//Entitlement
        
    }
    
    public class SourceDivCdCrm{
        @AuraEnabled public Integer divCd;        
        
    }    
    
    public class CaseRegInputParamWrapper{
        @AuraEnabled public String incidentMemo;
        @AuraEnabled public String incidentNote;
        @AuraEnabled public String caseTypeCrm;
        @AuraEnabled public String caseClassTypeCrm;
        @AuraEnabled public String productCd;
        @AuraEnabled public String caseNumber;
    }


}