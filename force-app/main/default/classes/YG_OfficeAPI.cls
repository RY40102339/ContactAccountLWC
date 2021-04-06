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
*  MM/DD/YYYY           Developer Name          Comments
*  
*/
public class YG_OfficeAPI {
    
    public static User userInformation =  YG_Utility.getLoggedInUserInfo(UserInfo.getUserId());
    
    @AuraEnabled
    public static Map<String, List<OfficeWrapper>> callOfficeAPIInfo(String countryCode,String classificationCode,String officeType){
        
        // Call Custom Setting to get the CDC API Config keys
        Map<String, YG_Community_Configuration__c> allValues = new Map<String, YG_Community_Configuration__c>();        
        allValues = YG_Community_Configuration__c.getAll();
        
        String systemId = allValues.get('ShippingAPISystemId').Text_1__c;        
        String endpointURL = allValues.get('OfficeAPIEndPointURL').Text_1__c;     
               
        String officeAPIURL = endpointURL+'?systemid='+systemid+'&teritory_country='+countryCode+'&classification_code='+classificationCode+'&office_type='+officeType;
       
        System.debug('endpointURL ::: '+officeAPIURL);
        String response = '';
        Map<String, List<OfficeWrapper>> officeObjListMap = new Map<String, List<OfficeWrapper>>();
                       
        // Instantiate a new http object
        Http binding = new Http();
        HttpResponse res=null;
        
        // Instantiate a new HTTP request
        HttpRequest req = new HttpRequest();      
        req.setHeader('Content-Type','application/json'); 
        req.setHeader('Accept', 'application/json');
        req.setEndpoint(officeAPIURL);
        req.setTimeout(120000);
        req.setMethod('GET'); 
        
        try {
            res = binding.send(req);
           
            System.Debug('Status code ::: '+res.getStatusCode());
            System.Debug('response ::: '+res);
            System.Debug('response headers ::: '+res.getHeaderKeys());
            System.Debug('response header ::: '+res.getHeader('X-CLA-Code'));
           
             // Parse the JSON response
            if (res.getStatusCode() == 200) {
                    response = JSON.serializePretty( JSON.deserializeUntyped(res.getBody()) ); 
                    System.debug('response ::: '+response);
                    List<OfficeAPIResponseWrapper>  searchResponse = 
                        (List<OfficeAPIResponseWrapper>)JSON.deserialize(response, List<OfficeAPIResponseWrapper>.class); 
                
                           
                for(OfficeAPIResponseWrapper officeResObj:searchResponse){   
                    String classification_code = officeResObj.classification_code;
                    if(officeResObj.entity_group != null && officeResObj.entity_group.size()>0){
                        List<OfficeWrapper> officeObjList = new List<OfficeWrapper>();
                        for(EntityGroup entityGroup: officeResObj.entity_group){
                            OfficeWrapper officeObj = new OfficeWrapper();                    
                            officeObj.type = classification_code;
                            officeObj.name = entityGroup.company_name;
                            officeObj.address = entityGroup.address;
                            officeObj.contact_Number = entityGroup.office_phone_number;
                            officeObj.country = entityGroup.company_country;
                            officeObj.postal_Code = entityGroup.postal_code;                            
                            officeObjList.add(officeObj);
                        
                        }
                        System.debug('officeObjList ::: '+officeObjList);
                        officeObjListMap.put(classification_code, officeObjList);
                    }
                    
                }
                
             }
            
        } catch(Exception e){
            system.debug('Exception Cause::'+e.getCause());
            system.debug('Exception LineNumber::'+e.getLineNumber());
            system.debug('Exception Message::'+e.getMessage());
            system.debug('Exception StackTrace::'+e.getStackTraceString());
            system.debug('Exception TypeName::'+e.getTypeName());
            YG_Utility.logError('CDC API','Community Component Error',e.getStackTraceString(),
                               'Class:YG_OfficeAPI; Method: callOfficeAPIInfo(); Line #:'+e.getLineNumber()
                                +'; Message:'+e.getMessage(),
                               UserInfo.getUserId());
        }
        
        return officeObjListMap;
        
    }
    
    public class OfficeWrapper{
        @AuraEnabled public string type;
        @AuraEnabled public string name;
        @AuraEnabled public string address;
        @AuraEnabled public string contact_Number;
        @AuraEnabled public string country;
        @AuraEnabled public string postal_Code;  
    }
    
    
    public class OfficeAPIResponseWrapper{
        
        public List<EntityGroup> entity_group;
        public String classification_country_language;
        public String classification_country_name;
        public String classification_country;
        public String classification_name;
        public String classification_code;        
    }
    
    public class EntityGroup{
        public String office_fax_number;
        public String office_phone_number;
        public String address_language;
        public String address;
        public String region_name_language;
        public String region_name;
        public String region;
        public String postal_code;
        public String office_type_name_language;
        public String office_type_name;
        public String office_type;
        public String entity_status;
        public String entity_country_language;
        public String entity_country_name;
        public String entity_country;
        public String entity_name_language;
        public String entity_name;
        public String entity_code;
        public String company_status;
        public String company_country_language;
        public String company_country_name;
        public String company_country;
        public String company_name_language;
        public String company_name;
        public String company_code;
    }

}