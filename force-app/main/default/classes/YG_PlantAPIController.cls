/*
*******************************************************************************************************
* (C) Copyright 2020 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Chitrakishore M
* @version 1.0
* @created 22/09/2020
* @description  
* This class is used to call the plant API.
*
* @test class name - 
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  
*/

public class YG_PlantAPIController {
    
    public static User userInformation =  YG_Utility.getLoggedInUserInfo(UserInfo.getUserId());    
    //public static User userInformation =  YG_Utility.getLoggedInUserInfo('005p0000004HwDG');
    @AuraEnabled
    public static PlantResponseWrapper callPlantAPI(){

        PlantResponseWrapper plantResponseWrapper = new PlantResponseWrapper();         
        String accountNumber = userInformation.Contact.Account.AccountNumber;
        
        Map<String, YG_Community_Configuration__c> allValues = new Map<String, YG_Community_Configuration__c>();        
        allValues = YG_Community_Configuration__c.getAll();
        String systemid = allValues.get('ShippingAPISystemId').Text_1__c;
        System.debug('systemid ::: '+systemid);
        String endpointURL = allValues.get('PlantAPIEndpointUrl').Text_1__c;
        
        String plantURL = endpointURL+'?systemid='+systemid;
        
        System.debug('AccountNumber ::: '+ accountNumber);
        
        List<Plant__c> plantList =[Select ID,Name,Plant_Code__c,Country__c,Location__c,Telephone_number__c,Fax_number__c,Account__c from Plant__c where Account__c =:userInformation.Contact.Account.Id];
               
        String response = '';
        // Instantiate a new http object
        Http http = new Http();
        HttpResponse res=null;
        
        // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
        HttpRequest req = new HttpRequest();  
        req.setHeader('Content-Type','application/json'); 
        req.setHeader('Accept', 'application/json');          
        req.setEndpoint(plantURL);  
        req.setTimeout(120000);
        req.setMethod('POST');    
        req.setBody(getRequestBody(accountNumber));
        System.Debug('req:'+req);
        System.Debug('request ::: '+req);
        
        try {
            res = http.send(req);
           
            System.Debug('Status code ::: '+res.getStatusCode());
            System.Debug('response ::: '+res);
            System.Debug('response headers ::: '+res.getHeaderKeys());
            System.Debug('response header ::: '+res.getHeader('X-CLA-Code'));
            
            List<Plant__c> plantListToUpsert = new List<Plant__c>();
            
            if (res.getStatusCode() == 200){                
                 
                    response = JSON.serializePretty( JSON.deserializeUntyped(res.getBody()) ); 
                    System.debug('response ::: '+response);
                    List<PlantAPIResponseWrapper>  plantResponse = 
                        (List<PlantAPIResponseWrapper>)JSON.deserialize(response, List<PlantAPIResponseWrapper>.class);                      
                    
                    System.debug('plantResponse ::: '+plantResponse);
                    System.debug('plantResponse ::: Size ::: '+plantResponse.size());
                
                if(null !=plantResponse && plantResponse.size()>0){
                    for(PlantAPIResponseWrapper plantObj : plantResponse){
                        Plant__c plant = new Plant__c();                        
                        String name = plantObj.name;                        
                        if(null != plantObj.name){
                            if(name.length() <= 79){
                                plant.Name = name;
                            }
                            else{
                            	plant.Name = name.substring(0,79);    
                            }                            
                        }
                        plant.Plant_Name__c = plantObj.name;
                        plant.Plant_Code__c=plantObj.plantNo;
                        if(null !=plantObj.countryDivCd){
                       	  plant.Country__c =plantObj.countryDivCd.divCd;
                          //plant.Country__c ='IN';
                        }
                        
                        if(null != plantObj.address){
                        	plant.Location__c = plantObj.address+' '+plantObj.zipCode;
                        }
                        plant.Telephone_number__c = plantObj.telNo;
                        plant.Fax_number__c = plantObj.faxNo;      
                        //plant.Account__c = account.Id;
                        plant.Account__c = userInformation.Contact.Account.Id;
                        if(plantList != null){
                        	setPlantId(plantList, plant);
                        }
                        plantListToUpsert.add(plant);
                    }                  
               
                 	System.debug('Plant List ::: '+plantList);
                 	upsert plantListToUpsert;
                    
                    plantResponseWrapper.plantList = plantListToUpsert;
                    
                }else{
                    
                    plantResponseWrapper.plantList = plantList;
                    
                }
                    
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
                               'Class:YG_PlantAPIController; Method: callPlantAPI(); Line #:'+e.getLineNumber()
                                +'; Message:'+e.getMessage(),
                               UserInfo.getUserId());
            //plantResponse.success = false;
        }        
        System.debug('plantResponseWrapper ::: '+plantResponseWrapper);
        return plantResponseWrapper;
    }
    
    public static string getRequestBody (String accountNumber){        
        
        string requestBody = '{"customerBranch": {"customerBranchCd": "'+accountNumber+'"}}';                                
        System.debug('request body :::: '+requestBody);                              
        return requestBody;
    }
    
    private static Plant__c setPlantId (List<Plant__c> plantList, Plant__c plant){        
        
        if(plantList != null && plantList.size() > 0 ){
            for(Plant__c plantObj : plantList){
                if(plantObj.Plant_Code__c.equals(plant.Plant_Code__c)){
                    plant.Id = plantObj.Id;
                }
            }            
        }
        return plant;
    }
    
    
    public class PlantAPIResponseWrapper{
        public String type;
        public String approvedFlag;
        public String createDatetime;
        public String createUserCd;
        public String deletedFlag;
        public String editLockFlag;
        public String id;
        public String publicType;
        public String tenantId;
        public String unlockProhibitFlag;
        public String updateDatetime;
        public String updateUserCd;
        public String version;
        public String address;
        public CountryDivCD countryDivCd;
        public CustomerBranch customerBranch;
        public String deleteFlagCrm;
        public String faxNo;
        public String name;
        public String plantNo;
        public String telNo;
        public String zipCode;       
    }
    
    public class CustomerBranch{
        public String approvedFlag;
        public String createDatetime;
        public String createUserCd;
        public String deletedFlag;
        public String editLockFlag;
        public String publicType;
        public String tenantId;
        public String unlockProhibitFlag;
        public String updateDatetime;
        public String updateUserCd;
        public String version;
        public String address;
        public String addressGlobal;
        public String addressLocal;
        public String customerBranchCd;
        public String name;
        public String nameGlobal;
        public String nameLocal;
        public String zipCode;
        public String communicationLangCrm;
        public String deleteFlagCrm;
        public String disabledFlagCrm;
        public String shortListFlagCrm;
        public String ygsAccountGroupCrm;
        public String ygsAuthorityGroupCrm;
        public String ygsGovernmentSignCrm;
        public String ygsIndustryCdCrm;
        public String ygsRegionCrm;
        public String ygsTimeZoneCrm;
        public String ygsTransportZoneCrm;
        public String yokogawaFlagCrm;
     }
    
    public class CountryDivCD{
        public String approvedFlag;
        public String createDatetime;
        public String createUserCd;
        public String deletedFlag;
        public String editLockFlag;
        public String id;
        public String publicType;
        public String tenantId;
        public String unlockProhibitFlag;
        public String updateDatetime;
        public String updateUserCd;
        public String version;
        public String displaySeq;
        public CustomerDiv div;
        public String divCd;
        public String divCdSeq;
    }
    
    public class CustomerDiv{
        
        public String approvedFlag;
        public String createDatetime;
        public String createUserCd;
        public String deletedFlag;
        public String editLockFlag;
        public String id;
        public String publicType;
        public String tenantId;
        public String unlockProhibitFlag;
        public String updateDatetime;
        public String updateUserCd;
        public String version;
        public String divColumn;
        public String linefeedFlag;
        public String name;
        public String note;
        
    }
    
    public class PlantResponseWrapper{
        @AuraEnabled public List<Plant__c> plantList;
    }

}