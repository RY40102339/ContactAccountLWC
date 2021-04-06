/********************************************************************************************************
* (C) Copyright 2020 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Vinod A
* @version 1.0
* @created 19/05/2020
* @description 
* This class is used to get the notification details from the serialno and modelcode.
*
* @test class name - YG_NotificationBarControllerTest.
*
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  07/01/2020			Vinod A					code coverage updated based on plant selection implementation.
*
*/
public class YG_NotificationBarController {
    
     public static User userInformation =  YG_Utility.getLoggedInUserInfo(UserInfo.getUserId());
    
    /**
* This method is for getting the notification details based on the serial number & model code.
* 
**/    
    @AuraEnabled
    public static NotificationBarWrapper getNotificationBarData(String serialno, String modelCode/*, String plantCode*/){
        
        System.debug('serialno::'+serialno);
        System.debug('modelCode::'+modelCode);
        //System.debug('plantCode::'+plantCode);
        
        NotificationBarWrapper notiBar=new NotificationBarWrapper();
        Integer notiCount = 0;
        List<task> tsk=new List<task>();
        List<task> tsk1=new List<task>();
        //String langCode='EN';
        String langCode = YG_CommonUtils.getLanguageCode(userInformation.LanguageLocaleKey);
        try{
            ID contactId = userInformation.Contact.ID;  
            List<Id> assetIds =  YG_HelperClass.getCustomerAssets(contactId);
            
            //Plant__c plantObj = YG_HelperClass.getPlantID(plantCode,langCode);
            //System.debug('plantObj::'+plantObj);
            //get the task data and display the notification based on serialno
            System.debug('assetIds::'+assetIds);
            if(assetIds.size() > 0 && !assetIds.isEmpty()){
            if(modelCode == '' && serialno != null){
                //Query to check the calibration
                tsk = [Select Subject, ActivityDate, Owner.Name, Is_Active__c, Lang_code__c,
                       Product__c, Asset__r.SerialNumber, Asset__c,Is_Download_Available__c, Type from task 
                       Where Asset__r.SerialNumber =:serialno And Is_Active__c = 'True' AND Asset__r.ID IN :assetIds AND Lang_code__c =:langCode];
                System.debug('tsk::'+tsk);
                
                //Query to check the Firmware
                if(serialno != null && assetIds.size() > 0){
                    String firmModelCode;
                    List<Asset> ass = [Select Name, Product2Id, Product2.Model_Code__c From Asset Where SerialNumber=:serialno And ID IN :assetIds];
                    if(ass[0].Product2.Model_Code__c != null){
                        firmModelCode = ass[0].Product2.Model_Code__c;
                        System.debug('::firmModelCode::'+firmModelCode);
                    }
                    if(firmModelCode != null){
                        tsk1 = [Select Subject, ActivityDate, Owner.Name, Is_Active__c, Lang_code__c,
                                Product__c, Asset__r.SerialNumber,Asset__r.MS_Code__c, Asset__c,Is_Download_Available__c, Type from task 
                                Where Product__r.Model_Code__c=:firmModelCode And Is_Active__c = 'True' AND Lang_code__c =:langCode];
                    }
                    System.debug('tsk1::'+tsk1);
                }
                /*if(tsk.size()>0){
                    for(task t: tsk){
                        if(t.Type == 'Calibration Recommended' && t.Asset__r.SerialNumber != null){
                            notiBar.calibration = t.Subject;
                            notiBar.isActiveSerial = true;
                            notiBar.iscalibration = true;
                            notiCount ++;
                        }
                    }
                }*/
                System.debug('tsk1.size()::'+tsk1.size());
                /*if(tsk1.size()>0){
                    for(task t1: tsk1){
                        System.debug('t1.Type::'+t1.Type);
                        if(t1.Type == 'Firmware Update'){
                            notiBar.firmware = t1.Subject;
                            notiBar.isActiveSerial = true;
                            notiBar.isfirmware = true;
                            notiCount ++;
                            if(t1.Is_Download_Available__c == true){
                                notiBar.isfirmwareDownload = true;
                            }
                            else{
                                notiBar.isfirmwareDownload = false;
                            }
                        }
                    }
                }*/
                
                if(tsk.size() <=0 && tsk1.Size() <=0){
                    notiBar.isActiveSerial = false;
                }
                notiBar.notificationCnt = notiCount;
                System.debug('notiBar::'+notiBar);
            }
        }
            
            //get the task data and display the notification based on modelCode
            if(modelCode != '' && serialno == ''){
                
                //List<Asset> assList= [Select MS_Code__c, Lang_Code__c, Project__c, Product2Id, Plant__c From Asset Where ]
                Integer calibCount = 0;
                tsk = [Select Subject, ActivityDate, Owner.Name, Is_Active__c, Lang_code__c,
                       Product__c, Asset__r.SerialNumber,Asset__r.MS_Code__c, Asset__c,Is_Download_Available__c, Type from task 
                       Where Asset__r.Product2.Model_Code__c=:modelCode And Is_Active__c = 'True' AND Asset__r.ID IN :assetIds];
                System.debug('tsk::'+tsk);                
                /*if(tsk.size()>0){
                    for(task t: tsk){
                        
                        if(t.Type == 'Discontinued Products' && t.Asset__r.MS_Code__c != null){
                            notiBar.discontinueProd = t.Subject;
                            notiBar.isActiveModel = true;
                            notiBar.isDiscontinue = true;
                            notiCount ++;
                            if(t.Is_Download_Available__c == true){
                                notiBar.isDiscontinueDownload = true;
                            }
                            else{
                                notiBar.isDiscontinueDownload = false;
                            }
                        }
                        
                        if(t.Type == 'Recalled Products' && t.Asset__r.SerialNumber != null){
                            notiBar.isActiveModel = true;
                            notiBar.recalled = t.Subject;
                            notiBar.isRecalled = true;
                            notiCount ++;
                        }
                        
                        if(t.Type == 'Calibration Recommended' && t.Asset__r.SerialNumber != null){
                            notiBar.calibration = t.Subject;
                            notiBar.isActiveModel = true;
                            notiBar.iscalibration = true;
                            notiCount ++;
                            calibCount = calibCount + 1;
                        }
                    }
                }
                else{
                    notiBar.isActiveModel = false;
                }*/
                notiBar.notificationCnt = notiCount;
                notiBar.calibrationCnt = calibCount;
                System.debug('notiBar::'+notiBar);
            }
            
            System.debug('tsk.size()::'+tsk.size());
            
        }Catch(Exception e){
            system.debug('Exception Cause::'+e.getCause());
            system.debug('Exception LineNumber::'+e.getLineNumber());
            system.debug('Exception Message::'+e.getMessage());
            system.debug('Exception StackTrace::'+e.getStackTraceString());
            system.debug('Exception TypeName::'+e.getTypeName());
            YG_Utility.logError('ProductDetailsPage','Backend Process Error',e.getStackTraceString(),
                                'Class:YG_NotificationBarController; Method: getNotificationBarData(); Line #:'+e.getLineNumber()+'; Message:'+e.getMessage(),
                                UserInfo.getUserId());
        }
        
        return notiBar;
    }
    
    public class NotificationBarWrapper{
        @AuraEnabled public boolean isActiveSerial;
        @AuraEnabled public boolean isActiveModel;
        @AuraEnabled public boolean iscalibration;
        @AuraEnabled public String calibration;
        @AuraEnabled public Integer calibrationCnt;
        @AuraEnabled public boolean isfirmware;
        @AuraEnabled public String firmware;
        @AuraEnabled public boolean isfirmwareDownload;
        @AuraEnabled public boolean isDiscontinue;
        @AuraEnabled public String discontinueProd;
        @AuraEnabled public boolean isDiscontinueDownload;
        @AuraEnabled public boolean isRecalled;
        @AuraEnabled public String recalled;
        @AuraEnabled public Integer notificationCnt;
        
    }
}