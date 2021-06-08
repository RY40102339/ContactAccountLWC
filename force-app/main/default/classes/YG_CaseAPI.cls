/*
*******************************************************************************************************
* (C) Copyright 2020 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Chitrakishore M
* @version 1.0
* @created 05/01/2021
* @description  
* This class is used for exposing the REST API url for the case API.
*
* @test class name - 
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  04/19/2021           Kavya                   Removed Plant__c Object and replaced with Account Object
*/

public class YG_CaseAPI {
    
    public static User userInformation =  YG_Utility.getLoggedInUserInfo(UserInfo.getUserId());
    
    //public static User userInformation =  YG_Utility.getLoggedInUserInfo('');
    
    
    /** 
     * This method is for invoking the Case API call passing the plancode as parameter from the UI.
     **/ 

    @AuraEnabled 
    public static void callCaseAPIInfo(/*List<String> plantCode*/){
        
        List<Case> caseList = new List<Case>();
        List<String> plantCode = new List<String>();
        
        // Call Custom Setting to get the CDC API Config keys
        Map<String, YG_Community_Configuration__c> allValues = new Map<String, YG_Community_Configuration__c>();        
        allValues = YG_Community_Configuration__c.getAll();
        String systemId = allValues.get('ShippingAPISystemId').Text_1__c;
        
        String caseSearch = allValues.get('Case Search').Text_1__c;
        String endpointURL = caseSearch+'?systemid='+systemId;
        System.debug('endpointURL ::: '+endpointURL);
        String response = '';
        
        String accountId = userInformation.Contact.AccountId;
        String accountNumber = userInformation.Contact.Account.AccountNumber;
        String langCode = YG_CommonUtils.getLanguageCode(userInformation.LanguageLocaleKey);
                
        // Instantiate a new http object
        Http binding = new Http();
        HttpResponse res = null;
        
        // Instantiate a new HTTP request
        HttpRequest req = new HttpRequest();      
        req.setHeader('Content-Type','application/json'); 
        req.setHeader('Accept', 'application/json');
        req.setEndpoint(endpointURL);  
        req.setBody(getRequestBody(accountNumber));
        req.setTimeout(120000);
        req.setMethod('POST'); 
        
        try {
            
           /* List<Plant__c> pltList = [Select Plant_Code__c From Plant__c Where Account__c = :accountId];
            for(Plant__c plt: pltList){
                plantCode.add(plt.Plant_Code__c);
            }*/
               List<Account> pltList = [Select AccountNumber From Account Where Id = :accountId and Type = 'Plant'];
            for(Account plt: pltList){
                plantCode.add(plt.AccountNumber);
            }
            
            res = binding.send(req);
           
            //System.Debug('Status code ::: '+res.getStatusCode());
            //System.Debug('response ::: '+res);
            //System.Debug('response headers ::: '+res.getHeaderKeys());
            //System.Debug('response header ::: '+res.getHeader('X-CLA-Code'));
           
             // Parse the JSON response
            if (res.getStatusCode() == 200) {
                
                response = JSON.serializePretty( JSON.deserializeUntyped(res.getBody())); 
                System.debug('response Body ::: '+response);
                
                if (res.getStatusCode() == 200){
                    response = JSON.serializePretty( JSON.deserializeUntyped(res.getBody()) ); 
                    System.debug('response ::: '+response);
                    List<CaseSearch>  searchResponse = 
                        (List<CaseSearch>)JSON.deserialize(response, List<CaseSearch>.class); 
                    
                    //System.debug('searchResponse ::: '+searchResponse);
                    System.debug('searchResponse ::: Size :::  '+searchResponse.size());
                    
                                       
                    if (null != searchResponse && searchResponse.size() >0){
                        List<String> deliverablesIdList = new List<String>();
                        List<String> productModelCodeList = new List<String>();
                        List<String> lcaContractCrmList = new List<String>();
                       
                        for(CaseSearch csObj: searchResponse){
                              if(csObj.primaryDeliverablesProduct != null 
                                 && csObj.primaryDeliverablesProduct.deliverables !=null 
                                 && csObj.productCrm !=null
                                 && !deliverablesIdList.contains(csObj.productCrm.productCd)){
                                  
                                 
                                  deliverablesIdList.add(csObj.primaryDeliverablesProduct.deliverables.id);                                         
                             }
                             
                             if(csObj.productCrm != null && csObj.productCrm.productCd !=null
                               && !productModelCodeList.contains(csObj.productCrm.productCd)){
                                 productModelCodeList.add(csObj.productCrm.productCd) ;                                      
                             }
                             
                             if(csObj.ContractItem != null && csObj.ContractItem.lcaNoCrm !=null){
                                 lcaContractCrmList.add(csObj.ContractItem.lcaNoCrm);                                       
                             }
                            
                        }
                        Map<String, Asset> existingAssetMap = getCaseAsset(deliverablesIdList, langCode);
                        Map<String, Product2> existingProductMap = getCaseProduct(productModelCodeList, langCode);
                        Map<String, ServiceContract> serviceContractMap = getCaseContract(lcaContractCrmList);
                        
                        System.debug('existingProductMap :::: '+existingProductMap);
                        
                         User userObj = [Select ID from user where name='User API' limit 1];                    
                         for(CaseSearch csObj: searchResponse){
                             Case caseObj = new Case();                      
                             Map<String, Case> existingCases = getExistingServAirCases(plantCode);
                             system.debug('existingCases :::'+existingCases+' ::: csObj.incidentNo ::: '+csObj.incidentNo);
                             if(existingCases.containsKey(csObj.incidentNo)){
                                 caseObj = existingCases.get(csObj.incidentNo);                  
                                
                             }else {
                                 caseObj.Created_By__c =  userObj.Id;
                             }                  
                             
                             Account account = userInformation.Contact.Account;
                             caseObj.Account =account;
                             caseObj.ContractMainteCrmID__c = csObj.targetLcaMainteIdCrm;                          
                             
                             caseObj.Account = account;
                             ID caseRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByName().get('Service Inquiry').getRecordTypeId();
                             caseObj.RecordTypeId = caseRecordTypeId;
                             caseObj.Type = 'Request For Service';
                             
                             if(null!= csObj.incidentNo)
                             	caseObj.ServAir_Incident_Number__c = csObj.incidentNo;
                             
                             if(null != csObj.incidentStatus && ('TEMPORARILY'.equalsIgnoreCase(csObj.incidentStatus)
                                || 'TEMPORARILY_ABANDONED'.equalsIgnoreCase(csObj.incidentStatus) || 'RECEIPTED'.equalsIgnoreCase(csObj.incidentStatus)
                                || 'WORK_PLANNING'.equalsIgnoreCase(csObj.incidentStatus) || 'ASSIGNED'.equalsIgnoreCase(csObj.incidentStatus)
                                || 'WORK_PLANNED'.equalsIgnoreCase(csObj.incidentStatus) || 'WORK_STARTED'.equalsIgnoreCase(csObj.incidentStatus)
                                || 'WORK_APPROVAL_REQUEST'.equalsIgnoreCase(csObj.incidentStatus) || 'WORK_APPROVED'.equalsIgnoreCase(csObj.incidentStatus)
                                || 'WORK_COMPLETED'.equalsIgnoreCase(csObj.incidentStatus))){
                                   caseObj.Status = 'Active';                                  
                                }else if('NO_WORK_COMPLETED'.equalsIgnoreCase(csObj.incidentStatus)
                                			|| 'INCIDENT_COMPLETED'.equalsIgnoreCase(csObj.incidentStatus)){
                                   caseObj.Status = 'Closed'; 
                                } 
                             	
                             
                             if(null != csObj.incidentMemo)
                             	caseObj.Subject = csObj.incidentMemo;
                             
                             if(null != csObj.incidentNote)
                             	caseObj.Description = csObj.incidentNote;
                             
                             if(null !=csObj && null!=csObj.sourceDivCdCrm && null!=csObj.sourceDivCdCrm.divCd){
                                caseObj.Origin = csObj.sourceDivCdCrm.divCd;
                             }
                             String fName;
                             String lName;
                             if(null !=csObj && null!=csObj.ServiceUser && null!=csObj.ServiceUser.firstName){
                                 fName = csObj.ServiceUser.firstName;
                             }
                             if(null !=csObj && null!=csObj.ServiceUser && null!=csObj.ServiceUser.lastName){
                                 lName = csObj.ServiceUser.lastName;
                             }
                             if(fName != null && lName != null){
                                 caseObj.Assigned_To_Name__c = fName+' '+lName;
                             }
                             if(null !=csObj && null!=csObj.ServiceUser && null!=csObj.ServiceUser.emailAddress){
                                 caseObj.Assigned_To_Email__c = csObj.ServiceUser.emailAddress;
                             }	
                             
                             if(null !=csObj && null!=csObj.priorityDivCdCrm && null!=csObj.priorityDivCdCrm.divCd){
                                caseObj.Priority = csObj.priorityDivCdCrm.divCd;
                             }
                             
                             if(null !=csObj && null!=csObj.plantCrm && null!=csObj.plantCrm.plantNo){
                                	caseObj.Plant_Code__c = csObj.plantCrm.plantNo;
                             }
                             
                            if(null != csObj.caseClassTypeCrm){
                            	caseObj.Service_you_require__c = getCaseClassTypeCrm(csObj.caseClassTypeCrm);
                             }
                             
                            if(csObj.primaryDeliverablesProduct != null && csObj.primaryDeliverablesProduct.deliverables !=null){
                                caseObj.Deliverables_ID__c = csObj.primaryDeliverablesProduct.deliverables.id;
                                
                                if(existingAssetMap.containsKey(csObj.primaryDeliverablesProduct.deliverables.id)){
                                     caseObj.AssetId = existingAssetMap.get(csObj.primaryDeliverablesProduct.deliverables.id).Id;
                                 }                                         
                             }
                             
                             if(csObj.productCrm != null && csObj.productCrm.productCd !=null){
                                 System.debug('Inside ProductCrm::: csObj.productCrm.productCd ::: '+csObj.productCrm.productCd);
                                 if(existingProductMap.containsKey(csObj.productCrm.productCd) && 
                                    existingProductMap.get(csObj.productCrm.productCd) !=null){
                                     System.debug('Inside IF>>>>>>>>>');
                                     //caseObj.Product = existingProductMap.get(csObj.primaryProduct.productCd);
                                     Product2 prod = new Product2();
                                     prod = existingProductMap.get(csObj.productCrm.productCd);
                                     System.debug('prod ::: '+prod);   
                                     caseObj.ProductId = prod.Id;
                                 }                                         
                             }
                             
                             System.debug('caseObj.Product :::: '+caseObj.Product);
                             
                             if(csObj.ContractItem != null && csObj.ContractItem.lcaNoCrm !=null){
                                 if(serviceContractMap.containsKey(csObj.ContractItem.lcaNoCrm)){
                                     caseObj.ServiceContractId = serviceContractMap.get(csObj.ContractItem.lcaNoCrm).Id;
                                 }                                         
                             }
                             if(null !=csObj.createDatetime){
                             	caseObj.ServAir_Created_Date__c = Datetime.valueOf(csObj.createDatetime.replace('T',' '));
                             }  
                             System.debug('caseObj.Product ::: '+  caseObj.Product);
                             System.debug('caseObj ::: '+  caseObj);
                             caseList.add(caseObj);
                            
                        }
                     }
                                       
                    System.debug('caseList ::: '+caseList);
                    upsert caseList;
                    
                }
                
            }
            
        } catch(Exception e){
            system.debug('Exception Cause::'+e.getCause());
            system.debug('Exception LineNumber::'+e.getLineNumber());
            system.debug('Exception Message::'+e.getMessage());
            system.debug('Exception StackTrace::'+e.getStackTraceString());
            system.debug('Exception TypeName::'+e.getTypeName());
            YG_Utility.logError('CDC API','Community Component Error',e.getStackTraceString(),
                               'Class:YG_CaseAPI; Method: callCaseAPIInfo(); Line #:'+e.getLineNumber()
                                +'; Message:'+e.getMessage(),
                               UserInfo.getUserId());
        }
        
    }
    
    /**
     * This method is used for getting the case object passing the plant code as paramter.
     **/ 
    public static Map<String, Case> getExistingServAirCases(List<String> plantCode){
        
        List<Case> caseObjList =[Select ServAir_Incident_Number__c,Status,Asset.MS_Code__c,
                                  Account.Name,Subject,Description,ServiceContract.Contract_No__c,Origin,Priority,Plant_Code__c,
                                  Product.Model_Code__c,Service_you_require__c
                                  from Case where ContactEmail=:userInformation.Contact.email
                                   or Plant_Code__c IN: plantCode] ;
        
         Map<String,Case> caseObjMap = new Map<String, Case>();
         for(Case caseObj:caseObjList){
             if(null != caseObj.ServAir_Incident_Number__c && caseObj.ServAir_Incident_Number__c.trim().length() >0){
             	caseObjMap.put(caseObj.ServAir_Incident_Number__c, caseObj);
             }
         }
                
        return caseObjMap;
    }
    
    /**
     * This method is for getting the asset object passing the deliverable id and langcode.
     **/ 
    public static Map<String, Asset> getCaseAsset(List<String> deliverableIdList, String langCode){
        List<Asset> assetObjList = [Select ID, name from Asset where name IN:deliverableIdList and Lang_Code__c =:langCode];     
        
        Map<String, Asset> assetMap = new Map<String, Asset>();
        if (null != assetObjList && assetObjList.size() >0){
            for(Asset asset: assetObjList){
                assetMap.put(asset.name, asset);
            }
        }
        
        return assetMap;
    }
    
     /**
      * This method is for getting the product list passing the model code and the lang code.
      **/ 
     public static Map<String, Product2> getCaseProduct(List<String> modelCodeList, String langCode){
         
        System.debug('Inside getCaseProduct ::: modelCodeList :::'+modelCodeList+' ::: langCode :::'+langCode); 
        List<Product2> productObjList = [Select ID, name, Model_Code__c,/*Product_Categories__c,*/Lang_Code__c from Product2 where Model_Code__c IN: modelCodeList and Lang_Code__c =:langCode];     
        Map<String, Product2> productMap = new Map<String, Product2>();
        if (null != productObjList && productObjList.size() >0){
            for(Product2 product: productObjList){
                productMap.put(product.Model_Code__c, product);
            }
        }     
        return productMap;
    }
    
    /**
     * This method is for getting the contract list passing the contract no as parmeter.
     **/ 
    public static Map<String, ServiceContract>  getCaseContract(List<String> contractNoList){
        List<ServiceContract> contractObjList = [Select ID, Contract_No__c from ServiceContract where Contract_No__c IN:contractNoList];     
        Map<String, ServiceContract> contractMap = new Map<String, ServiceContract>();
        if (null != contractObjList && contractObjList.size() >0){
            for(ServiceContract contract: contractObjList){
                contractMap.put(contract.Contract_No__c, contract);
            }
        }
        return contractMap;
    }
    
    /**
     * This method is for getting the request body passing the account no as parameter for the case API call.
     **/  
    public static string getRequestBody (String accountNo){        
        //accountNo = '200088314';
        string requestBody = '{"dlvCustomerBranch": {"customerBranchCd": "'+accountNo+'"}}';                                
        //System.debug('request body :::: '+requestBody);                              
        return requestBody;
    }
     
    /**
     * This method is for getting the case type value passing the caseClassTypeCrm getting from the API response.
     **/ 
    public static String getCaseClassTypeCrm(String caseClassTypeCrm){
        
        String caseType='';       
        switch on caseClassTypeCrm{
            when 'MAINTE' {
                caseType = '010';
            } 
            when 'ON_CALL' {
                caseType = '020';
            }
            when 'BENCH_REPAIR' {
                caseType = '030';
            }
            when 'TRAINING' {
                caseType = '040';
            }
            when 'CALIBRATION' {
                caseType = '050';
            }
            when 'UPGRADE' {
                caseType = '060';
            }
            when 'SECURITY' {
                caseType = '070';
            }
            when 'DIAGNOSIS' {
                caseType = '080';
            }
            when 'VALUE_UP' {
                caseType = '100';
            }
            when 'OTHER_CHARGEALBLE' {
                caseType = '110';
            }
            when 'PROPOSAL' {
                caseType = '300';
            }
            when 'OTHERS' {
                caseType = '900';
            }
           
        }
        
        return caseType;
        
    }
    
    public class CaseSearchResponse{
         public List<CaseSearch> caseSearch;
    }
    
    public class CaseSearch{        
         public string warrantyFlagCrm;
         public string warrantyEscFlagCrm;
         public string thirdPartyFlagCrm;
         public SourceDivCdCrm sourceDivCdCrm;
         public string thirdPartyEscFlagCrm;
         public string targetLcaMainteIdCrm;
         public string socEscFlagCrm;
         public string serviceRequestFlagCrm;
         public string salesMailSendFlagCrm;
         public string rrcEscFlagCrm;
         public string resolutionHourCrm;
         public PriorityDivCdCrm priorityDivCdCrm;
         public PlantCrm plantCrm;
         public string majorTroubleFlagCrm;
         public string knowledgeFlagCrm;
         public string irEscFlagCrm;
         public string grcEscFlagCrm;
         public string doaFlagCrm;
         public string complaintFlagCrm;
         public string closedDatetimeCrm;
         public string chargeableFlagCrm;
         public string caseTypeCrm;
         public string caseClassTypeCrm;
         public string caseStatusCrm;
         public ServiceUser serviceUser;
         public ServiceOrg serviceOrg;
         public string serviceChargeType;
         public ReceiptUser receiptUser;
         public ReceiptOrg receiptOrg;
         public string receiptDatetime;
         public PrimaryProduct primaryProduct;
         public PrimaryDeliverablesProduct primaryDeliverablesProduct;
         public string originalDeleteFlag;
         public string incidentStatus;
         public string incidentSeq;
         public string incidentNote;
         public string incidentNo;
         public string incidentMemo;
         public DlvCustomerBranch dlvCustomerBranch;
         public DlvCustomer dlvCustomer;
         public CustomerBranch customerBranch;
         public Customer customer;
         public ContractItem contractItem;
         public string expandMemo1;
         public string version;
         public string updateUserCd;
         public string updateDatetime;
         public string unlockProhibitFlag;
         public string tenantId;
         public string publicType;
         public string ownerOrgId;
         public string id;
         public string editLockFlag;
         public string deletedFlag;
         public string createUserCd;
         public string createDatetime;
         public string approvedFlag;
         public string type;
         public ProductCrm productCrm;
        
    }
    
    public class ProductCrm{
        public string name;
        public string productCd;
        
    }
    
    public class SourceDivCdCrm{
         public string divCd;
    }
    
    public class PriorityDivCdCrm{
         public string divCdSeq;
         public string divCd;
         public Div div;
         public string displaySeq;
         public String version;
         public string updateUserCd;
         public string updateDatetime;
         public string unlockProhibitFlag;
         public string tenantId;
         public string publicType;
         public string id;
         public string editLockFlag;
         public string deletedFlag;
         public string createUserCd;
         public string createDatetime;
         public string approvedFlag;
    }
    
    public class PlantCrm{
         public string plantNo;
    }
    
    public class Div{
         public string note;
         public string name;
         public string linefeedFlag;
         public string divColumn;
         public string version;
         public string updateUserCd;
         public string updateDatetime;
         public string unlockProhibitFlag;
         public string tenantId;
         public string publicType;
         public string id;
         public string editLockFlag;
         public string deletedFlag;
         public string createUserCd;
         public string createDatetime;
         public string approvedFlag;
    }
    
    public class ServiceOrg{
         public string telNo;
         public string outsourceFlag;
         public string organizationCd;
         public string name;
         public string faxNo;
         public string effectDate;
         public string addressLocal;
         public string address;
         public string version;
         public string updateUserCd;
         public string updateDatetime;
         public string unlockProhibitFlag;
         public string tenantId;
         public string publicType;
         public string id;
         public string editLockFlag;
         public string deletedFlag;
         public string createUserCd;
         public string createDatetime;
         public string approvedFlag;
        
    }
    
    public class ServiceUser{
         public string userLicenseType;
         public string userCd;        
         public string themeType;
         public string telNo;
         public string loginFailureCount;
         public string lastName;
         public string firstName;
         public string emailAddress;
         public string displayLimitFlag;
         public string disabledFlag;
         public string bpmUserFlag;
         public string approvalAuthorityFlag;
         public string apiEnabledFlag;
         public string version;
         public string updateUserCd;
         public string updateDatetime;
         public string unlockProhibitFlag;
         public string tenantId;
         public string publicType;
         public string id;
         public string editLockFlag;
         public string deletedFlag;
         public string createUserCd;
         public string createDatetime;
         public string approvedFlag;
    }
    
    public class ReceiptUser{
         public string userLicenseType;
         public String userCd;
         public String themeType;
         public String telNo;
         public String loginFailureCount;
         public String lastName;
         public String emailAddress;
         public String displayLimitFlag;
         public String disabledFlag;
         public String bpmUserFlag;
         public String approvalAuthorityFlag;
         public String apiEnabledFlag;
         public String version;
         public String updateUserCd;
         public String updateDatetime;
         public String unlockProhibitFlag;
         public String tenantId;
         public String publicType;
         public String id;
         public String editLockFlag;
         public String deletedFlag;
         public String createUserCd;
         public String createDatetime;
         public String approvedFlag;        
    }
    
    public class ReceiptOrg{
         public String telNo;
         public String outsourceFlag;
         public String organizationCd;
         public String name;
         public String faxNo;
         public String effectDate;
         public String addressLocal;
         public String address;
         public String version;
         public String updateUserCd;
         public String updateDatetime;
         public String unlockProhibitFlag;
         public String tenantId;
         public String publicType;
         public String id;
         public String editLockFlag;
         public String deletedFlag;
         public string createUserCd;
         public string createDatetime;
         public string approvedFlag;        
    }
    
    public class PrimaryProduct{
         public string productCd;
    }
    
    public class PrimaryDeliverablesProduct{
         public Deliverables deliverables; 
    }
    
    public class Deliverables{
         public string id;
    }
    
    public class DlvCustomerBranch{
         public string yokogawaFlagCrm;
         public string ygsTransportZoneCrm;
         public string ygsTimeZoneCrm;
         public string ygsRegionCrm;
         public string ygsIndustryCdCrm;
         public string ygsGovernmentSignCrm;
         public string ygsAuthorityGroupCrm;
         public string ygsAccountGroupCrm;
         public string shortListFlagCrm;
         public string disabledFlagCrm;
         public string deleteFlagCrm;
         public string communicationLangCrm;
         public string zipCode;
         public string nameLocal;
         public string nameGlobal;
         public string name;
         public string customerBranchCd;
         public Customer customer;
         public string addressLocal;
         public string addressGlobal;
         public string address;
         public string version;
         public string updateUserCd;
         public string updateDatetime;
         public string unlockProhibitFlag;
         public string tenantId;
         public string publicType;
         public string id;
         public string editLockFlag;
         public string deletedFlag;
         public string createUserCd;
         public string createDatetime;
         public string approvedFlag;
    }
    
    public class Customer{
         public string ygsIndustryCdCrm;
         public string ygsAuthorityGroupCrm;
         public string deleteFlagCrm;
         public string name;
         public string customerCd;
         public string consumerFlag;
         public string version;
         public string updateUserCd;
         public string updateDatetime;
         public string unlockProhibitFlag;
         public string tenantId;
         public string publicType;
         public string id;
         public string editLockFlag;
         public string deletedFlag;
         public string createUserCd;
         public string createDatetime;
         public string approvedFlag;
    }
    
   public class DlvCustomer{
        public string ygsIndustryCdCrm;
        public string ygsAuthorityGroupCrm;
        public string deleteFlagCrm;
        public string name;
        public string customerCd;
        public string consumerFlag;
        public string version;
        public string updateUserCd;
        public string updateDatetime;
        public string unlockProhibitFlag;
        public string tenantId;
        public string publicType;
        public string id;
        public string editLockFlag;
        public string deletedFlag;
        public string createUserCd;
        public string createDatetime;
        public string approvedFlag;        
   }
   
    public class CustomerBranch{
         public string yokogawaFlagCrm;
         public string ygsTransportZoneCrm;
         public string ygsTimeZoneCrm;
         public string ygsRegionCrm;
         public string ygsIndustryCdCrm;
         public string ygsGovernmentSignCrm;
         public string ygsAuthorityGroupCrm;
         public string ygsAccountGroupCrm;
         public string shortListFlagCrm;
         public string disabledFlagCrm;
         public string deleteFlagCrm;
         public string communicationLangCrm;
         public string zipCode;
         public string nameLocal;
         public string nameGlobal;
         public string name;
         public string customerBranchCd;
         public Customer customer;
    }
    
    public class ContractItem{
         public string sumDealPriceCrm;
         public string salesMailSendFlagCrm;
         public string revUpFlagCrm;
         public string revNoCrm;
         public string proposedFlagCrm;
         public string opportunityCreatedFlagCrm;
         public string multiYearLcaFlagCrm;
         public string lcaNoCrm;
         public string ifCreatedFlagCrm;
         public string gissIfTypeCrm;
         public string expiredMailTargetFlagCrm;
         public string expiredMailSendFlagCrm;
         public string expiredAlertDateCrm;
         public string contractedDate;
         public string contractStatus;
         public string contractStartDate;
         public string contractItemSeq;
         public string contractItemMemo;
         public string contractEndDate;
         public Contract contract;
    }
    
    public class Contract{
         public string ifCreatedFlagCrm;
         public string firstContractedDateCrm;
         public string contractIdCrm;
         public string contractNo;
         public string contractMemo;
         public string contractCancelFlag;
         public string version;
         public string updateUserCd;
         public string updateDatetime;
         public string unlockProhibitFlag;
         public string tenantId;
         public string publicType;
         public string ownerOrgId;
         public string id;
         public string editLockFlag;
         public string deletedFlag;
         public string createUserCd;
         public string createDatetime;
         public string approvedFlag;
        
    }

}