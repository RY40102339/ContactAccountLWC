/*
*******************************************************************************************************
* (C) Copyright 2020 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Selvaraj T
* @version 1.0
* @created 13/10/2020
* @description 
* This class is used to write the methods for Software Licenses page.
*
* @test class name - YG_SoftwareLicensesControllerTest
*
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  
*
*/


public class YG_SoftwareLicensesController {
    
    public static User userInformation =  YG_Utility.getLoggedInUserInfo(UserInfo.getUserId());
    
    /**
	 *This method is used to get the software licenses details under particular plant.
     *
	 **/
    @AuraEnabled
    public static softwareWrapper getSoftwareLicenseDetails(String plantCode, List<String> filterValue,Integer loadLimit, Integer offset){
        
        system.debug('plantCode::'+plantCode);
		system.debug('filterValue::'+filterValue);
		system.debug('loadLimit::'+loadLimit);
		system.debug('offset::'+offset);                                                                     
        
        softwareWrapper softWrap = new softwareWrapper();                                                                
        List<softwareLicenseWrapper> softwareLicenseWrapperList = new List<softwareLicenseWrapper>(); //Wrapper list to store the software licenses
        Id pltId = null; //Store the plant Id
        List<Project__c> projList = new List<Project__c>(); //List to store the project record
        List<Id> productId = new List<Id>(); //List to store the product id
        Map<Id,String> projectIdMap = new Map<Id,String>(); //List to store the project id
        List<Maintenance_Phase__c> mtnPhaseList = new List<Maintenance_Phase__c>(); //List to store the maintenance phase details
        List<Asset> assetList = new List<Asset>(); //List to store the asset details
        List<String> astProductName = new List<String>(); //List to store the product name from asset object
        String noti = 'Software no longer supported';
        
        try{
            
            //Get the language code of the user
            String langCode = YG_CommonUtils.getLanguageCode(userInformation.LanguageLocaleKey);
            system.debug('langCode::'+langCode);
            
            //get centum model code and empty model code
            Map<String, YG_Community_Configuration__c> allValues = YG_Community_Configuration__c.getAll();
            String centumModCode = allValues.get('Centum Products Model Code').Text_1__c;
            String emptyModCode = allValues.get('Display Empty Model Code').Text_1__c;
            List<String> centumModCodeLst = centumModCode.split(',');
            List<String> emptyModCodeLst = emptyModCode.split(','); //display '-' in UI for model code in list
            
            //Get plant id based on the plant code
            if(plantCode != null && plantCode != ''){
            
                Plant__c plant = YG_HelperClass.getPlantID(plantCode,langCode);
                pltId = plant.id;
                system.debug('pltId::'+pltId);
                
                //Get the project asociated to the plant
                projList = [Select Id,Name,Project_Code__c,Revision_No__c from Project__c where Plant__r.Id=:pltId];
                system.debug('projList::'+projList);
                for(Project__c proj: projList){
                    projectIdMap.put(proj.Id,proj.Project_Code__c);
                }
                
                //List to get the total software license count
                softWrap.totalSoftwareCount = [Select Count() FROM Asset WHERE Plant__c = :pltId AND Product2.Category__r.Name = 'Software'];
                
                //Get asset details based on the plant id
                if(filterValue.size()>0 && !filterValue.isEmpty() && filterValue != null){
                    assetList = [SELECT Station_Type__c, Product_Name__c, Product2Id ,Product2.Name,Product2.Model_Code__c,Revision_No__c,Project__c,
                                 Project__r.Name, Project__r.Revision_No__c FROM Asset 
                                 WHERE Plant__c = :pltId AND Product2.Category__r.Name = 'Software' AND Product2.Name IN :filterValue  
                                 ORDER BY Product2.Name];
                }
                else{
                    assetList = [SELECT Station_Type__c, Product_Name__c, Product2Id ,Product2.Name,Product2.Model_Code__c,Revision_No__c,Project__c,
                                 Project__r.Name, Project__r.Revision_No__c FROM Asset 
                                 WHERE Plant__c = :pltId AND Product2.Category__r.Name = 'Software' ORDER BY Product2.Name 
                                 LIMIT :loadLimit OFFSET :offset];
                }
                
                for(Asset ar : assetList){
                    if(!productId.contains(ar.Product2Id)){
                        productId.add(ar.Product2Id);
                    }
                    if(ar.Product_Name__c != null && ar.Product_Name__c != '' && !astProductName.contains(ar.Product_Name__c)){
                        astProductName.add(ar.Product_Name__c);
                    }
                    if((ar.Station_Type__c == null || ar.Station_Type__c == '') && !astProductName.contains(ar.Project__r.Name)){
                        astProductName.add(ar.Project__r.Name);
                    }
                }
                
                system.debug('productId::'+productId.size());
                system.debug('astProductName::'+astProductName);
                
                //get maintenance phase details based on product and project id
                mtnPhaseList = [Select Ext_Maintenance_End_Date__c,Ext_Maintenance_Start_Date__c,Maintenance_Phase1_End_Date__c,
                                Maintenance_Phase1_Start_Date__c,Maintenance_Phase2_End_Date__c,Maintenance_Phase2_Start_Date__c,
                                Sales_Phase_End_Date__c,Sales_Phase_Start_Date__c,Product__c,Product__r.Model_Code__c,Item__c,Sub_Item__c 
                                From Maintenance_Phase__c Where Product__c IN :productId OR Item__c = :astProductName];
                
                system.debug('mtnPhaseList::'+mtnPhaseList);
                
                //Iterate the asset list to construct the wrapper
                for(Asset ar : assetList){
                    softwareLicenseWrapper sftLcnWrap = new softwareLicenseWrapper();
                    List<String> notiList = new List<String>();
                    if(ar.Product2.Model_Code__c != null){
                        if(emptyModCodeLst.contains(ar.Product2.Model_Code__c)){
                            sftLcnWrap.modelCode = '-';   
                        }else{
                            sftLcnWrap.modelCode = ar.Product2.Model_Code__c;    
                        }
                    }
                    //sftLcnWrap.modelCode = (String)ar.get('Model_Code__c');
                    sftLcnWrap.name = ar.Product2.Name;
                    sftLcnWrap.id = ar.Product2Id;
                    if(projectIdMap.get(ar.Project__c) != null){
                        sftLcnWrap.systemId = projectIdMap.get(ar.Project__c);
                    }
                    if(ar.Revision_No__c != null){
                        sftLcnWrap.revisionNo = ar.Revision_No__c;
                    }
                    if(centumModCodeLst.contains(ar.Product2.Model_Code__c) && ar.Project__r.Revision_No__c != null){
                     	sftLcnWrap.revisionNo = ar.Project__r.Revision_No__c;   
                    }
                    for(Maintenance_Phase__c mtnPhase: mtnPhaseList){
                        if(centumModCodeLst.contains(ar.Product2.Model_Code__c)){
                            if(mtnPhase.Item__c == ar.Project__r.Name && mtnPhase.Sub_Item__c == ar.Project__r.Revision_No__c && ar.Project__r.Revision_No__c != ''){
                                system.debug('inside centum');
                                system.debug('inside centum'+ar.Product2.Model_Code__c);
                                YG_SystemsController.productPhase prodPhase = YG_SystemsController.getPhaseDetails(mtnPhase);
                                string phase = prodPhase.prodMtnPhase;
                                string phaseEndingIn = prodPhase.phaseEndingIn;
                                String str = '';
                                if(phaseEndingIn.contains('_')){
                                    str = phaseEndingIn.replace('_','');
                                    str = phase + ' ' + Label.YG_ending_in + ' ' +str;
                                    if(!notiList.contains(str)){
                                        notiList.add(str);
                                    }
                                }
                                if(phaseEndingIn == 'Invalid'){
                                    if(!notiList.contains(noti)){
										notiList.add(noti);                                        
                                    }
                                }
                                
                                /*
                                if( Date.today() > mtnPhase.Ext_Maintenance_End_Date__c){
                                    sftLcnWrap.inquiryReq = true;
                                    if(!notiList.contains(phase)){
                                     	notiList.add(Label.YG_Software_no_longer_supported);   
                                    }
                                } */
                            }
                        }
                        if(ar.Station_Type__c == 'HIS'){
                            if(mtnPhase.Item__c == ar.Product_Name__c && mtnPhase.Sub_Item__c == ar.Revision_No__c && ar.Revision_No__c != ''){
                                YG_SystemsController.productPhase prodPhase = YG_SystemsController.getPhaseDetails(mtnPhase);
                                string phase = prodPhase.prodMtnPhase;
                                string phaseEndingIn = prodPhase.phaseEndingIn;
                                String str = '';
                                if(phaseEndingIn.contains('_') && phaseEndingIn != 'Invalid'){
                                    str = phaseEndingIn.replace('_','');
                                    str = phase + ' ' + Label.YG_ending_in + ' ' +str;
                                    if(!notiList.contains(str)){
                                        notiList.add(str);
                                    }
                                }
                                if(phaseEndingIn == 'Invalid'){
                                    if(!notiList.contains(noti)){
                                        notiList.add(noti);
                                    }
                                }
                                /*if( Date.today() > mtnPhase.Ext_Maintenance_End_Date__c){
                                    sftLcnWrap.inquiryReq = true;
                                    notiList.add(Label.YG_Software_no_longer_supported);
                                }*/
                            }
                        }
                        if(ar.Station_Type__c != 'HIS' && !centumModCodeLst.contains(ar.Product2.Model_Code__c)){
                            if(mtnPhase.Product__c == ar.Product2Id && ar.Revision_No__c == mtnPhase.Sub_Item__c && ar.Revision_No__c != ''){
                                YG_SystemsController.productPhase prodPhase = YG_SystemsController.getPhaseDetails(mtnPhase);
                                string phase = prodPhase.prodMtnPhase;
                                string phaseEndingIn = prodPhase.phaseEndingIn;
                                String str = '';
                                if(phaseEndingIn.contains('_') && phaseEndingIn != 'Invalid'){
                                    str = phaseEndingIn.replace('_','');
                                    str = phase + ' ' + Label.YG_ending_in + ' ' +str;
                                    if(!notiList.contains(str)){
                                        notiList.add(str);
                                    }
                                }
                                if(phaseEndingIn == 'Invalid'){
                                    if(!notiList.contains(noti)){
                                        notiList.add(noti);
                                    }
                                }
                                /*if( Date.today() > mtnPhase.Ext_Maintenance_End_Date__c){
                                    sftLcnWrap.inquiryReq = true;
                                    notiList.add(Label.YG_Software_no_longer_supported);
                                }*/
                            }
                        }
                    }
                    system.debug('sftLcnWrap.name::'+sftLcnWrap.name);
                    system.debug('notiList::'+notiList);
                    sftLcnWrap.notiList = notiList;
                    
                    if(sftLcnWrap != null){
                        softwareLicenseWrapperList.add(sftLcnWrap);
                        softWrap.softWrapList = softwareLicenseWrapperList;
                    }
                }
            }else{
                softWrap.totalSoftwareCount = 0;
                softWrap.softWrapList = new List<softwareLicenseWrapper>();
            }
        	
        }
        catch(Exception e){
            softWrap.totalSoftwareCount = 0;
            softWrap.softWrapList = new List<softwareLicenseWrapper>();
            system.debug('Exception Cause::'+e.getCause());
            system.debug('Exception LineNumber::'+e.getLineNumber());
            system.debug('Exception Message::'+e.getMessage());
            system.debug('Exception StackTrace::'+e.getStackTraceString());
            system.debug('Exception TypeName::'+e.getTypeName());
            YG_Utility.logError('SoftwareLicensesPage','Backend Process Error',e.getStackTraceString(),
                                'Class:YG_SoftwareLicensesController; Method: getSoftwareLicenseDetails(); Line #:'+e.getLineNumber()+'; Message:'+e.getMessage(),
                                UserInfo.getUserId());
        }
        
        system.debug('softwareWrapper::'+ softWrap);
        return softWrap;
        
    }
    
    //Wrapper to store the software available under the plant
    public class softwareWrapper{
        @AuraEnabled public Integer totalSoftwareCount = 0;
        @AuraEnabled public List<softwareLicenseWrapper> softWrapList = new List<softwareLicenseWrapper>();
    }
    
    public class softwareLicenseWrapper{
        @AuraEnabled public String name = '';
        @AuraEnabled public String id = '';
        @AuraEnabled public String systemId = '-';
        @AuraEnabled public String modelCode = '-';
        @AuraEnabled public String revisionNo = '-';
        @AuraEnabled public Boolean inquiryReq = false;
        @AuraEnabled public List<String> notiList;
    }

}