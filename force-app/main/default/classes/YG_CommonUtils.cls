/*
*******************************************************************************************************
* (C) Copyright 2020 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Chitrakishore
* @version 1.0
* @created 25/05/2020
* @description 
* This class is used to define methods that can be reused across the application such as date format etc.

* @test class name - YG_CommonControllerTest

*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*
*
*/

public class YG_CommonUtils {
    
   /* @AuraEnabled
    public static String getSwLicenceExpiryStr(Date licenseExpiryDate){
        system.debug('In getSwLicenceExpiryStr() licenseExpiryDate::'+licenseExpiryDate);
        
        String swLicenseExpiryStr = '-';
        
        try{
            Date todayDate = date.today();
            if(null != licenseExpiryDate){
                if(licenseExpiryDate < todayDate){
               	 	swLicenseExpiryStr = 'Expired';
                } else {
                    
                    Integer noOfdays = 0; 
                    Integer noOfMonths = 0;
                    //For months
                    if( licenseExpiryDate.month()  -  todayDate.month()  > 0) {
                        noOfMonths = licenseExpiryDate.month()  -  todayDate.month(); 
                    }   
                    //For days
                    if( licenseExpiryDate.day() - todayDate.day()  > 0) {
                        noOfdays = licenseExpiryDate.day()  -  todayDate.day();
                    } 
                    
                }
            }
                                    
            system.debug('swLicenseExpiryStr :::'+swLicenseExpiryStr);
            
        }catch(Exception e){
            system.debug('Exception Cause::'+e.getCause());
            system.debug('Exception LineNumber::'+e.getLineNumber());
            system.debug('Exception Message::'+e.getMessage());
            system.debug('Exception StackTrace::'+e.getStackTraceString());
            system.debug('Exception TypeName::'+e.getTypeName());
            YG_Utility.logError('GetUserInfo','Community Component Error',e.getStackTraceString(),
                               'Class:YG_CommonUtils; Method: getSwLicenceExpiryStr(); Line #:'+e.getLineNumber()+'; Message:'+e.getMessage(),
                               UserInfo.getUserId());
        }
        
        return swLicenseExpiryStr;
    }*/
    
    // This method is for getting the warranty expiry date
    public static String getWarrantyExpiryStr(Date shippingDate, Integer warrantyPeriod){
        
        system.debug('In getWarrantyExpiryStr() shippingDate ::'+shippingDate);
        
        String warrantyExpiryStr = '-';
        
        try{
                    
            Date now = date.today();  
            Date warrantyEndDate = shippingDate.addYears(1);
            
            if(null != shippingDate){
                Date warrantyExpiryDate = shippingDate.addYears(warrantyPeriod);
                System.debug('warrantyExpiryDate::'+ warrantyExpiryDate);
                if(warrantyExpiryDate <= now){
               	 	warrantyExpiryStr = System.Label.YG_Expired;
                } else {
                    
           
					Integer months = now.monthsBetween(warrantyExpiryDate);
              
                	if (now.day() > warrantyExpiryDate.day()) {
                  		months--;
                	}
                    
                	if(months < 3) {
                   		integer years = (months / 12);
                    	months = months - (years * 12);
            
                    	Date rolledBackEndDate = warrantyEndDate.addMonths(0 - months);
                   	 	Integer days = now.daysBetween(rolledBackEndDate);
            
                    	String noOfYears = String.valueOf(years) + ' Year(s) ' + String.valueOf(months) + ' Month(s)' + String.valueOf(days)+' Days' ;
                    	system.debug('No of years ' + noOfYears);
                        
                        // create custom labels
                		//warrantyExpiryStr ='Warranty expiring in '+String.valueOf(months) + ' Months ' + String.valueOf(days)+' Days';
                        warrantyExpiryStr =System.Label.YG_Warranty_Expiring+' '+String.valueOf(months) +' '+ System.Label.YG_Months +' '+ String.valueOf(days)+' '+System.Label.YG_Days;
                 
                	}                     
                    
                }
            }
                                    
            system.debug('warrantyExpiryStr :::'+warrantyExpiryStr);
            
        }catch(Exception e){
            system.debug('Exception Cause::'+e.getCause());
            system.debug('Exception LineNumber::'+e.getLineNumber());
            system.debug('Exception Message::'+e.getMessage());
            system.debug('Exception StackTrace::'+e.getStackTraceString());
            system.debug('Exception TypeName::'+e.getTypeName());
            YG_Utility.logError('GetUserInfo','Community Component Error',e.getStackTraceString(),
                               'Class:YG_CommonUtils; Method: getWarrantyExpiryStr(); Line #:'+e.getLineNumber()+'; Message:'+e.getMessage(),
                               UserInfo.getUserId());
        }
        
        return warrantyExpiryStr;
    } 
    
    // This method is for getting the language code base on the locale key
    public static String getLanguageCode(String languageLocaleKey){
        String langCode = 'EN';
        if(languageLocaleKey.EqualsIgnoreCase('ja')){
           langCode = 'JA';
        }
        return langCode;
        
    }
        
    // This method is for converting the string to date
    public static Date convertStringToDate(String dateStr){   
        
        Date convertedDate = null;
        
        if(null !=dateStr){
            String yyyy=dateStr.substring(0,4);
            String mm=dateStr.substring(4,6);
            String dd=dateStr.substring(6,8);
            
            String finalDateStr = yyyy+'-'+mm+'-'+dd;
            
            convertedDate = Date.valueOf(finalDateStr);
        }
        
        return convertedDate;
        
    }

}