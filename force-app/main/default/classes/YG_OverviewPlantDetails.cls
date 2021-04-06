/*
*******************************************************************************************************
* (C) Copyright 2020 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Jayaprasath
* @version 1.0
* @created 09/11/2020
* @description 
* This class is used to write the methods for Overview page Site section.
*
* @test class name - 
*
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  
*/

public class YG_OverviewPlantDetails {
    
     public static User userInformation =  YG_Utility.getLoggedInUserInfo(UserInfo.getUserId());
     //public static User userInformation =  YG_Utility.getLoggedInUserInfo('005p0000003rbfUAAQ');
     
    //This method is used to get the site overview section in Overview page 
    @AuraEnabled
    public static OverviewPlantWrapper getOverviewPlantDetails(String plantCode){
        
        System.debug('plantCode::'+plantCode);
        
        String langCode = YG_CommonUtils.getLanguageCode(userInformation.LanguageLocaleKey); 
        OverviewPlantWrapper overviewPlantWap=new OverviewPlantWrapper();
        
        
        try{
            
            Id accId = userInformation.Contact.AccountId;
            
             //To get the plant id
            Plant__c plant =  [SELECT ID,Name,Plant_Name__c,Plant_Code__c,Lang_Code__c,//Country__c,
                               Fax_number__c,Location__c,Telephone_number__c,Account__r.Name, Account__r.Short_Name__c 
                               FROM Plant__c WHERE Plant_Code__c =: plantCode AND Account__c =: accId AND Lang_Code__c =:langCode];
            
                 
                    overviewPlantWap.name = plant.Plant_Name__c;
                    overviewPlantWap.accname = plant.Account__r.Name;
                    overviewPlantWap.sitenumber = plant.Plant_Code__c;
                   
                    if(plant.Account__r.Short_Name__c == null){
                        overviewPlantWap.shortname = '-'; 
                    }
                    else{
                        overviewPlantWap.shortname = plant.Account__r.Short_Name__c;
                    }
                    /*if(plant.Country__c == null){
                        overviewPlantWap.country = '-';  
                    }
                    else{
                        overviewPlantWap.country = plant.Country__c;
                    }*/
                    if(plant.Location__c == null){
                        overviewPlantWap.location = '-';   
                    }
                    else{
                        overviewPlantWap.location = plant.Location__c;
                    }
                    if(plant.Telephone_number__c == null){
                        overviewPlantWap.phone = '-';    
                    }
                    else{
                        overviewPlantWap.phone = plant.Telephone_number__c;
                    }
                    if(plant.Fax_number__c == null){
                        overviewPlantWap.fax = '-';     
                    }
                    else{
                        overviewPlantWap.fax = plant.Fax_number__c; 
                    }
            
                
                 system.debug('Plant List ::'+overviewPlantWap);
                

            
            }
        
        catch(Exception e){
            system.debug('Exception Cause::'+e.getCause());
            system.debug('Exception LineNumber::'+e.getLineNumber());
            system.debug('Exception Message::'+e.getMessage());
            system.debug('Exception StackTrace::'+e.getStackTraceString());
            system.debug('Exception TypeName::'+e.getTypeName());
            YG_Utility.logError('Overview page Site section','Community Component Error',e.getStackTraceString(),
                                'Class:YG_OverviewPlantDetails; Method: getOverviewPlantDetails(); Line #:'+e.getLineNumber()+'; Message:'+e.getMessage(),
                                UserInfo.getUserId());
        }
        return overviewPlantWap;
        }
    
     public class OverviewPlantWrapper{
        @AuraEnabled public String name;
        @AuraEnabled public String sitenumber;
        @AuraEnabled public String accname;
        @AuraEnabled public String shortname;
        @AuraEnabled public String country;
        @AuraEnabled public String location;
        @AuraEnabled public String phone;
        @AuraEnabled public String fax;
    }

}