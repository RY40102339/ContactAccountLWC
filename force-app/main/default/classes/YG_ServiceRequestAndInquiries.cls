/*
*******************************************************************************************************
* (C) Copyright 2020 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Selvaraj T
* @version 1.0
* @created 14/08/2020
* @description 
* This class is used to write the methods for Service Request and Inquiry Page.
*
* @test class name - YG_ServiceRequestAndInquiriesTest
*
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  09/08/2020           Jayaprasath             Updated the Status__c in Customer_Plant__c query 
*
*/


public class YG_ServiceRequestAndInquiries {
    
    public static User userInformation =  YG_Utility.getLoggedInUserInfo(UserInfo.getUserId());   

     /**
	 *This method is used to get the logged in user contact details based on plant code.
     *
	 **/
    @AuraEnabled
    public static Contact getYourDetails(){
        
        Contact con = new Contact();
        
        try{
            
            Id conId = userInformation.Contact.Id;
            system.debug('conId::'+conId);
            
            con = [Select Name, Title, Phone, MailingAddress From Contact Where Id = :conId and status__c =: true];
            
            if(con.Title == null){
                con.Title = '-';
            }
            
        }
        catch(Exception e){
            system.debug('Exception Cause::'+e.getCause());
            system.debug('Exception LineNumber::'+e.getLineNumber());
            system.debug('Exception Message::'+e.getMessage());
            system.debug('Exception StackTrace::'+e.getStackTraceString());
            system.debug('Exception TypeName::'+e.getTypeName());
            YG_Utility.logError('ServiceRequestandInquiryPage','Backend Process Error',e.getStackTraceString(),
                                'Class:YG_ServiceRequestAndInquiries; Method: getYourDetails(); Line #:'+e.getLineNumber()+'; Message:'+e.getMessage(),
                                UserInfo.getUserId());
        }
        
        system.debug('con::'+con);
        return con;
        
    }
    
    /**
	 *This method is used to create the inquiries submitted by the customer.
     *
	 **/
    @AuraEnabled
    public static String createInquiries(String inquiryData){
        
        system.debug('inquiryData::'+inquiryData);
        String caseInserted  = 'ERROR'; //return error if the case is not created 
        List<Case> caseList = new List<Case>(); //List to store the case submitted by user
        Id recId;
        String sObjName;
        Id caseRecordTypeId; //To store case recordtype id
        
        try{
            
            //Deserialize input object string to case object
            Case caseRec = (Case)JSON.deserialize(inquiryData, Case.class);
            System.debug('caseRec::'+caseRec);
            caseRec.Progress__c = 'Inquiry submitted';
            caseRec.ServAir_Created_Date__c = Datetime.now();
            if(caseRec.ProductId != null){
                recId = caseRec.ProductId;
                sObjName = recId.getSObjectType().getDescribe().getName();  
                system.debug('sObjName::'+sObjName);
                if(sObjName == 'Asset'){
                    caseRec.ProductId = null;
                    caseRec.AssetId = recId;
                }
                if(sObjName == 'Product2'){
                    caseRec.AssetId = null;
                    caseRec.ProductId = recId;
                }
            }
            else{
                caseRec.AssetId = null;
                caseRec.ProductId = null;
            }
            if(caseRec.Reason == 'Sales and Quote'){
                //Get Case SalesInquiry Record Type  Id
                caseRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByName().get('Sales Inquiry').getRecordTypeId();
                caseRec.RecordTypeId = caseRecordTypeId;
            }
            if(caseRec.Reason == 'Technical Support' || caseRec.Reason == 'Others'){
                //Get Case General Record Type  Id
                caseRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByName().get('General Inquiry').getRecordTypeId();
                caseRec.RecordTypeId = caseRecordTypeId;
            }
            System.debug('caseRecordTypeId::'+caseRecordTypeId);
            caseList.add(caseRec);
            system.debug('caseList::'+caseList);
            
            //Database Saveresult method to check the case insertion is success or not
            Database.SaveResult[] srList = Database.insert(caseList, false);
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    caseInserted = sr.getId();
                }else{
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ' ::: ' + err.getMessage());
                        System.debug('Fields that affected this error: ' + err.getFields());
                    }
                    caseInserted  = 'ERROR';
                }
            }
            
        }
        catch(Exception e){
            system.debug('Exception Cause::'+e.getCause());
            system.debug('Exception LineNumber::'+e.getLineNumber());
            system.debug('Exception Message::'+e.getMessage());
            system.debug('Exception StackTrace::'+e.getStackTraceString());
            system.debug('Exception TypeName::'+e.getTypeName());
            YG_Utility.logError('ServiceRequestandInquiryPage','Backend Process Error',e.getStackTraceString(),
                                'Class:YG_ServiceRequestAndInquiries; Method: createInquiries(); Line #:'+e.getLineNumber()+'; Message:'+e.getMessage(),
                                UserInfo.getUserId());
        }
        
        system.debug('caseInserted::'+caseInserted);
        return caseInserted;
        
    }
    
    /**
	 *This method is used to display the products searched by the customer.
     *
	 **/
    @AuraEnabled
    public static List<sObject> getLookUpData(String searchKeyWord, List<sObject> excludedRec){
        
        system.debug('searchKeyWord::'+searchKeyWord);
        system.debug('excludedRec::'+excludedRec);
        
        List<sObject> returnList = new List <sObject>();
                                                 
        String langCode = YG_CommonUtils.getLanguageCode(userInformation.LanguageLocaleKey);                                         
        
        String searchKey = '%' + searchKeyWord + '%';
            
		List<string> lstExcludeitems = new List<string>();
        
        for(sObject item : excludedRec ){
            lstExcludeitems.add(item.id);
        }
        
        try{
            String sQueryProd, sQueryProdModel; String sQueryAsset; String sQueryStation;
            
            //get customer assets
            List<Id> assetIds=new List<Id>();     
            ID contactId = userInformation.Contact.ID;  
            assetIds =  YG_HelperClass.getCustomerAssets(contactId);
            System.debug('assetIds::'+assetIds);
            
            //get customer plant
            List<Customer_Plant__c> cstPlantIds=new List<Customer_Plant__c>();
            List<Id> plantIds=new List<Id>();     
            cstPlantIds = YG_HelperClass.getCusPlantInfo(contactId,langCode);
            for(Customer_Plant__c p : cstPlantIds){
                system.debug('plantIds'+p.Plant__c);
                plantIds.add(p.Plant__c);
            }
            
            //Search using Product Name
            sQueryProd = 'Select Product2.Id, Product2.Name from Asset where Product2.Name LIKE : searchKey '+
                ' AND (Id IN:assetIds OR Plant__r.Id IN: plantIds) AND Lang_Code__c=:langCode AND Product2.Id NOT IN :lstExcludeitems GROUP BY Product2.Id,Product2.Name';
            
            List<sObject> lstOfProdRecords = Database.query(sQueryProd);
            
            for (sObject obj: lstOfProdRecords) {
                returnList.add(obj);
            }
            
            
            //Search using Product Model Code
            sQueryProdModel = 'Select Product2.Id, Product2.Model_Code__c from Asset where Product2.Model_Code__c LIKE : searchKey '+
                ' AND (Id IN:assetIds OR Plant__r.Id IN: plantIds) AND Lang_Code__c=:langCode AND Product2.Model_Code__c NOT IN :lstExcludeitems GROUP BY Product2.Id,Product2.Model_Code__c';
            
            List<sObject> lstOfProdModelRecords = Database.query(sQueryProdModel);
            
            for (sObject obj: lstOfProdModelRecords) {
                returnList.add(obj);
            }
            
            
            //Search using SerialNumber
            sQueryAsset = 'Select Id, Name from Asset where Name LIKE : searchKey '+
                'AND (Id IN:assetIds OR Plant__r.Id IN: plantIds) AND Lang_Code__c=:langCode AND Id NOT IN :lstExcludeitems';
            
            List<sObject> lstOfAssRecords = Database.query(sQueryAsset);
            
            for (sObject obj: lstOfAssRecords) {
                returnList.add(obj);
            }
            
            system.debug('lstOfProdRecords::'+lstOfProdRecords);
            system.debug('lstOfProdModelRecords::'+lstOfProdModelRecords);
            system.debug('lstOfAssRecords::'+lstOfAssRecords);
            
        }
        catch(Exception e){
            system.debug('Exception Cause::'+e.getCause());
            system.debug('Exception LineNumber::'+e.getLineNumber());
            system.debug('Exception Message::'+e.getMessage());
            system.debug('Exception StackTrace::'+e.getStackTraceString());
            system.debug('Exception TypeName::'+e.getTypeName());
            YG_Utility.logError('ServiceRequestandInquiryPage','Backend Process Error',e.getStackTraceString(),
                                'Class:YG_ServiceRequestAndInquiries; Method: getLookUpData(); Line #:'+e.getLineNumber()+'; Message:'+e.getMessage(),
                                UserInfo.getUserId());
        }
        
        system.debug('returnList::'+returnList);
        return returnList;
    }
    
    /**
	 *This method is used to get the top category name for the selected product.
     *
	 **/
     @AuraEnabled
    public static String getTopCategoryName(Id prodAssId){
        
        system.debug('prodAssId::'+prodAssId);
        String catName = '';
        String topCatCode;
        String catCode = '';
        String langCode = 'EN';
        
        try{
            
            String sObjName = prodAssId.getSObjectType().getDescribe().getName();
            
            //get top category code based on selected product
            if(sObjName == 'Asset'){
                String prodId = [Select Product2.Id From Asset Where Id = :prodAssId].Product2.Id;
                topCatCode = [Select Top_Category__c From Product2 Where Id =:prodId limit 1].Top_Category__c;
            }
            
			if(sObjName == 'Product2'){
                topCatCode = [Select Top_Category__c From Product2 Where Id =:prodAssId limit 1].Top_Category__c;
            }
            
            system.debug('topCatCode::'+topCatCode);
			//system.debug('Lang_Code__c::'+topCatCode.Lang_Code__c);
            catCode = topCatCode;
            
            //get top category name from the top category code
           /* Category__c cat = [Select Name From Category__c Where Category_Hierarchy__r.Category_Code__c = :topCatCode
                               And Language_Code__c = :langCode];
            catName = cat.Name;
			*/
        }
        catch(Exception e){
            system.debug('Exception Cause::'+e.getCause());
            system.debug('Exception LineNumber::'+e.getLineNumber());
            system.debug('Exception Message::'+e.getMessage());
            system.debug('Exception StackTrace::'+e.getStackTraceString());
            system.debug('Exception TypeName::'+e.getTypeName());
            YG_Utility.logError('ServiceRequestandInquiryPage','Backend Process Error',e.getStackTraceString(),
                                'Class:YG_ServiceRequestAndInquiries; Method: getTopCategoryName(); Line #:'+e.getLineNumber()+'; Message:'+e.getMessage(),
                                UserInfo.getUserId());
        }
        
        /*system.debug('catName::'+catName);
        return catName;
        */
        system.debug('catCode::'+catCode);
        return catCode;
    }
    
    
    /**
	 *This method is used to create the service request submitted by the customer.
     *
	 **/
    @AuraEnabled
    public static string createServiceReq(String serviceReqData){
        
        system.debug('serviceReqData::'+serviceReqData);
        String langCode = YG_CommonUtils.getLanguageCode(userInformation.LanguageLocaleKey); 
        String serviceIns  = 'ERROR'; //return error if the case is not created
       	List<Case> caseList = new List<Case>(); //List to store the case submitted by user
        Id caseRecordTypeId; //To store case recordtype id
        
        try{
            
            Case servReq = new Case();
            servReq.ServAir_Created_Date__c = Datetime.now();
            createServiceRequest servRec = (createServiceRequest)JSON.deserialize(serviceReqData, createServiceRequest.class);
            system.debug('servRec::'+servRec);
          
            List<prodReqService> prodSelected = servRec.prodSelected;
            
            for(prodReqService prodRec: prodSelected){

				Id recId;
                String sObjName='';
                if(prodRec.Id!='0'){
                    recId = prodRec.Id;
                    sObjName = recId.getSObjectType().getDescribe().getName();    
                }
                
                
                servReq.Progress__c = 'Request submitted';
                caseRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByName().get('Service Inquiry').getRecordTypeId();
                servReq.RecordTypeId = caseRecordTypeId;
                servReq.Service_you_require__c = servRec.serviceType;
                servReq.Description = servRec.Description;
                servReq.Type = servRec.Type;
                 if(prodRec.Id!='0'){
                	servReq.Subject = Label.YG_Service_For +' '+ prodRec.Name;
                 }
                else{
                    servReq.Subject = Label.YG_Service_For +' '+ Label.YG_Other;
                }
                
                if(sObjName == 'Asset'){
                    servReq.AssetId = prodRec.Id;
                }
                if(sObjName == 'Product2'){
                    servReq.ProductId = prodRec.Id;
                }
                
                if(sObjName == null){
                    servReq.AssetId = null;
                    servReq.ProductId = null;
                }
                caseList.add(servReq);
            }
            
            if(caseList.size() > 0){
                Insert caseList;
                serviceIns = caseList[0].id;
                
                Case servorgCase = [SELECT id,Product.Category__r.Service_Org__c,Asset.Product2.Category__r.Service_Org__c from Case where Id =:caseList[0].id limit 1];
                system.debug('servorgCase'+servorgCase);
                
                //call API if service org is IA-PS & IA-SS
                if(serviceIns !=null && (servorgCase.Product.Category__r.Service_Org__c == 'IA-PS' || servorgCase.Product.Category__r.Service_Org__c == 'IA-SS'|| servorgCase.Asset.Product2.Category__r.Service_Org__c == 'IA-SS'|| servorgCase.Asset.Product2.Category__r.Service_Org__c == 'IA-PS'))
                {
                    YG_CaseRegistrationAPIController.callCaseRegistrationAPI(caseList[0].id);
                } 
                
            }
        }
        catch(Exception e){
            serviceIns  = 'ERROR';
            system.debug('Exception Cause::'+e.getCause());
            system.debug('Exception LineNumber::'+e.getLineNumber());
            system.debug('Exception Message::'+e.getMessage());
            system.debug('Exception StackTrace::'+e.getStackTraceString());
            system.debug('Exception TypeName::'+e.getTypeName());
            YG_Utility.logError('ServiceRequestandInquiryPage','Backend Process Error',e.getStackTraceString(),
                                'Class:YG_ServiceRequestAndInquiries; Method: createServiceReq(); Line #:'+e.getLineNumber()+'; Message:'+e.getMessage(),
                                UserInfo.getUserId());
        }
        return serviceIns;
    }
  
    public class createServiceRequest{
        
        @AuraEnabled public string Type;
        @AuraEnabled public string Description;
        @AuraEnabled public string serviceType;
        @AuraEnabled public string plantId;
        @AuraEnabled public string addressId;
        @AuraEnabled public string serviceOrg;
        @AuraEnabled public List<prodReqService> prodSelected;
    }
    
    public class prodReqService{
        @AuraEnabled public string Id;
        @AuraEnabled public string Name;
    }
    
    /**
	 *This method is used to office details of the logged in user.
     *
	 **/
    @AuraEnabled
    public static Map<String,List<YG_OfficeAPI.OfficeWrapper>> getOfficeDetails(){
        
        
        Map<String,List<YG_OfficeAPI.OfficeWrapper>> ofcMap = new Map<String,List<YG_OfficeAPI.OfficeWrapper>>(); //Map to sales and service office details separately 
        List<Office__c> ofcRecList = new List<Office__c>(); //List to store the office details
        Map<String, String> countryCodeMap = new Map<String,String>(); //List to store the country and country code
        
        try{
            
            Id accId = userInformation.Contact.AccountId;
            String country = ''; 
            String countryCode = '';
            
            Map<String, YG_Community_Configuration__c> allValues = YG_Community_Configuration__c.getAll();
            String selfRegAccId = allValues.get('YGSelfRegisterAccountId').Text_1__c;
            String classificationCode = allValues.get('Classification_Code').Text_1__c;
            String officeType = allValues.get('Office_Type').Text_1__c;            
            
            Schema.DescribeFieldResult fieldResult = Plant__c.Country__c.getDescribe();
            List<Schema.PicklistEntry> countryList = fieldResult.getPicklistValues();
            
            for(Schema.PicklistEntry ctry : countryList){
                countryCodeMap.put(ctry.getLabel().toLowerCase(), ctry.getValue());
            }
			system.debug('countryCodeMap::'+countryCodeMap);
            
            if(accId == selfRegAccId){
                countryCode = userInformation.Contact.MailingCountry;
                ofcMap = YG_OfficeAPI.callOfficeAPIInfo(countryCode, classificationCode, officeType);
            }else if(accId != selfRegAccId){
                country = userInformation.Contact.Account.ShippingCountry.toLowerCase(); 
                if(countryCodeMap.containsKey(country)){
                    countryCode = countryCodeMap.get(country);
                    //Call office API
                    ofcMap = YG_OfficeAPI.callOfficeAPIInfo(countryCode, classificationCode, officeType);
                }
            }
            
            /*if(countryCodeMap.containsKey(country)){
                
                countryCode = countryCodeMap.get(country);
                
                //Call office API
                ofcMap = YG_OfficeAPI.callOfficeAPIInfo(countryCode, classificationCode, officeType);
            }
            ofcRecList = [Select Id, Name, Address__c, Contact_Number__c, Type__c  From Office__c Where 
                      toLabel(Country__c) = :country];
                        
            system.debug('ofcRecList::'+ofcRecList);
            
            for(Office__c ofcRec: ofcRecList){
                
                if(ofcRec.Contact_Number__c == null){
                    ofcRec.Contact_Number__c = '-';
                }
                
                if(ofcRec.Type__c == 'Sales Office' || ofcRec.Type__c == 'Both'){
                    String type = 'Sales Office';
                    if(!ofcMap.containsKey(type)){
                        List<Office__c> tempOfcRecList = new List<Office__c>();
                        tempOfcRecList.add(ofcRec);
                        ofcMap.put(type,tempOfcRecList);
                    }else{
                        List<Office__c> tempOfcRecList = ofcMap.get(type);
                        tempOfcRecList.add(ofcRec);
                        ofcMap.put(type,tempOfcRecList);
                    }
                }
                
                if(ofcRec.Type__c == 'Service Center' || ofcRec.Type__c == 'Both'){
                    String type = 'Service Center';
                    if(!ofcMap.containsKey(type)){
                        List<Office__c> tempOfcRecList = new List<Office__c>();
                        tempOfcRecList.add(ofcRec);
                        ofcMap.put(type,tempOfcRecList);
                    }else{
                        List<Office__c> tempOfcRecList = ofcMap.get(type);
                        tempOfcRecList.add(ofcRec);
                        ofcMap.put(type,tempOfcRecList);
                    }
                }
                
            }*/
            
        }
        catch(Exception e){
            system.debug('Exception Cause::'+e.getCause());
            system.debug('Exception LineNumber::'+e.getLineNumber());
            system.debug('Exception Message::'+e.getMessage());
            system.debug('Exception StackTrace::'+e.getStackTraceString());
            system.debug('Exception TypeName::'+e.getTypeName());
            YG_Utility.logError('ServiceRequestandInquiryPage','Backend Process Error',e.getStackTraceString(),
                                'Class:YG_ServiceRequestAndInquiries; Method: getOfficeDetails(); Line #:'+e.getLineNumber()+'; Message:'+e.getMessage(),
                                UserInfo.getUserId());
        }
        
        system.debug('ofcMap::'+ofcMap);
        return ofcMap;
        
    }	
    
    /**
	 *This method is used to get the top category name for the selected product.
     *
	 **/
     @AuraEnabled
    public static String getServiceType(String catCode){
        
       system.debug('catCode::'+catCode);
       String langCode = YG_CommonUtils.getLanguageCode(userInformation.LanguageLocaleKey);                                         
       String serviceType;
        try{
            
			YG_Category_Service_Type__mdt categoryServiceTypeList = new YG_Category_Service_Type__mdt();
           	categoryServiceTypeList = [Select Language_Code__c, Category_Name__c, Service_Type__c, Top_Category_Code__c From YG_Category_Service_Type__mdt Where Language_Code__c = :langCode and Top_Category_Code__c =: catCode limit 1];
			system.debug('categoryServiceTypeList::'+categoryServiceTypeList);
            system.debug('categoryServiceTypeList.Service_Type__c::'+categoryServiceTypeList.Service_Type__c);
            serviceType = categoryServiceTypeList.Service_Type__c;
            //List<String> lstName = serviceType.split(',');
            //System.debug(lstName);
            
            if(categoryServiceTypeList.Service_Type__c!=null){
                serviceType = categoryServiceTypeList.Service_Type__c;
            } 
            else{
                serviceType = 'Other';
            }
        }
        catch(Exception e){
            system.debug('Exception Cause::'+e.getCause());
            system.debug('Exception LineNumber::'+e.getLineNumber());
            system.debug('Exception Message::'+e.getMessage());
            system.debug('Exception StackTrace::'+e.getStackTraceString());
            system.debug('Exception TypeName::'+e.getTypeName());
            YG_Utility.logError('ServiceRequestandInquiryPage','Backend Process Error',e.getStackTraceString(),
                                'Class:YG_ServiceRequestAndInquiries; Method: getServiceType(); Line #:'+e.getLineNumber()+'; Message:'+e.getMessage(),
                                UserInfo.getUserId());
        }
        
        return serviceType;
    }
    
    
    /**
	 *This method is used to get the case details.
     *
	 **/
    @AuraEnabled
    public static Case getCaseDetails(String caseid){
        
        System.debug('caseid::'+caseid);
        Case caseRec=new Case();
        Id conId = userInformation.Contact.Id;                
        
        try{
            
           caseRec = [Select Id, Type, Subject, Description, Reason, toLabel(Service_you_require__c), Product.Name, Product.Model_Code__c,
                       Asset.SerialNumber,Asset.Name,Product.Category__r.Service_Org__c,Asset.Product2.Category__r.Service_Org__c
                       From Case Where id=: caseid];
            
            if(caseRec.Description == '' || caseRec.Description == null){
                caseRec.Description = '-';
            }
            system.debug('nbdajk'+caseRec.Asset.SerialNumber);
            if(caseRec.Asset.Name != null){
                if(caseRec.Asset.SerialNumber == '' || caseRec.Asset.SerialNumber == null){
                    caseRec.Asset.SerialNumber = caseRec.Asset.Name;
                } 
            }
            
            List<String> emailTo = new List<String>();//set to address 
            Map<String, YG_Community_Configuration__c> allValues = new Map<String, YG_Community_Configuration__c>();        
            allValues = YG_Community_Configuration__c.getAll();
            String IA_PS = allValues.get('IA-PS').Text_1__c;
            String IA_SS = allValues.get('IA-SS').Text_1__c;
            String LI = allValues.get('LI').Text_1__c;
            
            //setup to address based on Service Org
            if(caseRec.Product.Category__r.Service_Org__c == 'IA-PS' || caseRec.Asset.Product2.Category__r.Service_Org__c == 'IA-PS'){
                emailTo.add(IA_PS);
            } else if(caseRec.Product.Category__r.Service_Org__c == 'IA-SS' || caseRec.Asset.Product2.Category__r.Service_Org__c == 'IA-SS'){
                emailTo.add(IA_SS);
            }else if(caseRec.Product.Category__r.Service_Org__c == 'LI' || caseRec.Asset.Product2.Category__r.Service_Org__c == 'LI'){
                emailTo.add(LI);
            }
            else {
                emailTo.add(Label.YG_Email_From_Address);
            }
            
            if(caseRec.Type == 'Submit An Inquiry'){
                	setcaseAttach(caseRec.id);                	
                    //send email notification to the user after user insertion in SFDC 
                    OrgWideEmailAddress[] owa = [select Id,Address from OrgWideEmailAddress where Address =: Label.YG_Email_From_Address ];
                    EmailTemplate templateId = [Select id from EmailTemplate where name =: Label.YG_New_Service_inquiry_Email_Temp];                        
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setTemplateID(templateId.Id);
                    mail.setSaveAsActivity(false);
                    mail.setOrgWideEmailAddressId(owa.get(0).Id);
                    mail.setToAddresses(emailTo);            
                    mail.setTargetObjectId(conId);
                	mail.setTreatTargetObjectAsRecipient(false);
                    mail.setWhatId(caseRec.id); 
                    Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {mail};  
                        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                    if (results[0].success) 
                    {
                        System.debug('The email was sent successfully.');
                    } else {
                        System.debug('The email failed to send: ' +  results[0].errors[0].message);
                    }
            }
            else{
                setserviceRequire(caseRec.id);
                setcaseAttach(caseRec.id);
                //send email notification to the user after user insertion in SFDC 
                OrgWideEmailAddress[] owa = [select Id,Address from OrgWideEmailAddress where Address =: Label.YG_Email_From_Address ];
                EmailTemplate templateId = [Select id from EmailTemplate where name =: Label.YG_New_Service_request_Email_Temp];                        
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setTemplateID(templateId.Id);
                mail.setSaveAsActivity(false);
                mail.setOrgWideEmailAddressId(owa.get(0).Id);
                mail.setToAddresses(emailTo);            
                mail.setTargetObjectId(conId);
                mail.setTreatTargetObjectAsRecipient(false);
                mail.setWhatId(caseRec.id); 
                Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {mail}; 
                    system.debug('messages'+messages);
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                if (results[0].success) 
                {
                    System.debug('The email was sent successfully.');
                } else {
                    System.debug('The email failed to send: ' +  results[0].errors[0].message);
                }
                
            }
            
        }
        catch(Exception e){
            system.debug('Exception Cause::'+e.getCause());
            system.debug('Exception LineNumber::'+e.getLineNumber());
            system.debug('Exception Message::'+e.getMessage());
            system.debug('Exception StackTrace::'+e.getStackTraceString());
            system.debug('Exception TypeName::'+e.getTypeName());
            YG_Utility.logError('ThankYouPage','Backend Process Error',e.getStackTraceString(),
                                'Class:YG_ServiceRequestAndInquiries; Method: getCaseDetails(); Line #:'+e.getLineNumber()+'; Message:'+e.getMessage(),
                                UserInfo.getUserId());
        }
        
        system.debug('caseRec::'+caseRec);
        return caseRec;
        
    }
    
	
    /**
	 *This method is used to get the product details to prepopulate UI field.
     *
	 **/
    @AuraEnabled
    public static Asset getProductData(String value){
        
        system.debug('value::'+value);
        Asset asst = new Asset();
        
        try{
            
            asst = [Select Product2.Id, Product2.Name from Asset Where Product2.Id =: value or ms_code__c =: value limit 1];
            
        }
        catch(Exception e){
            system.debug('Exception Cause::'+e.getCause());
            system.debug('Exception LineNumber::'+e.getLineNumber());
            system.debug('Exception Message::'+e.getMessage());
            system.debug('Exception StackTrace::'+e.getStackTraceString());
            system.debug('Exception TypeName::'+e.getTypeName());
            YG_Utility.logError('InquiryPage','Backend Process Error',e.getStackTraceString(),
                                'Class:YG_ServiceRequestAndInquiries; Method: getProductData(); Line #:'+e.getLineNumber()+'; Message:'+e.getMessage(),
                                UserInfo.getUserId());
        }
        
        system.debug('asst::'+asst);
        return asst;
        
    }
    
    //to get the Service you require in email 
    public static List<Case> serviceRequire = new List<Case>();
    public static void setserviceRequire(Id servicecaseId) {
        serviceRequire = [select toLabel(Service_you_require__c) from Case where Id =:servicecaseId];
        system.debug('serviceRequire++'+serviceRequire);
    }    
    public static List<Case> getserviceRequire(){
        return serviceRequire;
    }
    
    //to get the file attachment status in email
    public static String caseAttach = 'No';
    public static List<ContentDocumentLink> caseAttachment = new List<ContentDocumentLink>();
    public static void setcaseAttach(Id caseId) {
         caseAttachment = [SELECT ContentDocumentId, LinkedEntityId  FROM ContentDocumentLink where LinkedEntityId in ( SELECT Id FROM Case where id =: caseId) and LinkedEntity.Type='Case'];
         if(!caseAttachment.isEmpty()){
             caseAttach='Yes';
         }
         system.debug('caseAttach++'+caseAttach);
    }
    
    public static String getcaseAttach(){
        return caseAttach;
    }
    
}