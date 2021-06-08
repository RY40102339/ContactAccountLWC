/*
*******************************************************************************************************
* (C) Copyright 2020 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Selvaraj T
* @version 1.0
* @created 17/07/2020
* @description 
* This class is used to write the methods for All systems Page.
*
* @test class name - YG_SystemsControllerTest
*
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  09/15/2020			Selvaraj T              Class is rewritten based on new page design and ERD updates
*  11/03/2020			Selvaraj T              Updated the logic to handle multiple projects under single plant
*  04/20/2021           Kavya                   Removed Plant__c Object and replaced with Account Object.
*												Removed Plant__c(Plant) Lookup field from Asset and Project Objects and newly added PlantAccount__c(Account) Lookup field in Asset  and Project Object.
*/


public class YG_SystemsController {
    
    
    public static User userInformation =  YG_Utility.getLoggedInUserInfo(UserInfo.getUserId());
    
   	/**
   	 * Method to decide wherether to call deliverable api or not
   	 * 
   	 * */
    @AuraEnabled
    public static Boolean callDelivAPI(String plantCode){
        
        Boolean callAPI = false;
        DateTime dt = DateTime.now();
        
        try{
            
            Id accId = userInformation.Contact.AccountId;
            
            //get deliveraable execution date code
            Map<String, YG_Community_Configuration__c> allValues = YG_Community_Configuration__c.getAll();
            String days = allValues.get('Deliverable API Execution Days').Text_1__c;
            String selfRegAccId = allValues.get('YGSelfRegisterAccountId').Text_1__c;
            
            if(plantCode != '' && plantCode != null){
               /* Plant__c plt = [Select Id, Name, Account__c, API_Last_Executed_Date__c From Plant__c where Plant_Code__c = :plantCode AND Account__c = :accId AND Account__c != :selfRegAccId Limit 1];*/
                 Account plt = [Select Id, Name, ParentId, System_API_Last_Sync_Date__c From Account where ((AccountNumber = :plantCode AND ParentId = :accId) OR (AccountNumber = :plantCode AND Id = :accId)) AND ParentId != :selfRegAccId Limit 1];
              /*  DateTime delAPIDt = plt.API_Last_Executed_Date__c;*/
                DateTime delAPIDt = plt.System_API_Last_Sync_Date__c;
                if(delAPIDt != null){
                    delAPIDt = delAPIDt.addDays(Integer.valueof(days.trim()));
                }
                if(dt > delAPIDt || delAPIDt == null){
                    callAPI = true;
                }
            }
        }
        catch(Exception e){
            YG_Utility.logError('callDelivAPI','Community Component Error',e.getStackTraceString(),
                                'Class:YG_SystemsController; Method: callDelivAPI(); Line #:'+e.getLineNumber()+'; Message:'+e.getMessage(),
                                UserInfo.getUserId());
        }
        return callAPI;
    }
    
    /**
	 *This method is used to get the all systems in single plant.
     *
	 **/
    @AuraEnabled
    public static systemWrapper getAllSystemsDetails(String plantCode, String projectCode){
        
        system.debug('plantCode::'+plantCode);
        system.debug('projectCode::'+projectCode);
        
        systemWrapper sysWrap = new systemWrapper(); //Wrapper to store all system details
        Id pltId = null; //Store the plant Id
        List<Project__c> projList = new List<Project__c>(); //List to store the projects
        List<String> projCodeList = new List<String>(); //List of string to store the project code
        Map<String,String> projMap = new Map<String,String>(); //Map to store the parent and child project
        List<String> filterValue = new List<String>(); //List of string to store the filter
        List<Asset> asstList = new List<Asset>(); //list to store the asset details
        List<String> projIdList = new List<String>(); //List to store the project id
        
        try{
            
            //Get the language code of the user
            String langCode = YG_CommonUtils.getLanguageCode(userInformation.LanguageLocaleKey);
            system.debug('langCode::'+langCode);
            
            //Get plant id based on the plant code
            if(plantCode != null && plantCode != ''){
                
                sysWrap.plantCode = plantCode;
                
                //get the plant details from plant code
              /*  Plant__c plant = YG_HelperClass.getPlantID(plantCode,langCode);*/
                Account plant = YG_HelperClass.getPlantID(plantCode,langCode);
                pltId = plant.id;
                system.debug('pltId::'+pltId);
                
                //get the project which has assets
                asstList = [Select Project__c From Asset where PlantAccount__r.Id=:pltId AND Station_Type__c != null];
                for(Asset ast: asstList){
                    if(!projIdList.contains(ast.Project__c)){
                        projIdList.add(ast.Project__c);
                    }
                }
                
                //Get the project asociated to the plant
                projList = [Select Id,Name,Project_Code__c,Last_System_Update_Date__c,Revision_No__c, Parent_Project__c,  
                            Parent_Project__r.Project_Code__c from Project__c where PlantAccount__r.Id=:pltId And Id =:projIdList order by CreatedDate Asc];
                
                system.debug('projList::'+projList);
                
                //Logic to get independent and integrated systems (parent and child projects)
                for(Project__c proj: projList){
                    if(proj.Parent_Project__c != null){
                        if(!projMap.containsKey(proj.Parent_Project__r.Project_Code__c)){
                            String str = proj.Parent_Project__r.Project_Code__c + ' / '+ proj.Project_Code__c;
                        	projMap.put(proj.Parent_Project__r.Project_Code__c, str);
                        }else{
                            String str = projMap.get(proj.Parent_Project__r.Project_Code__c) + ' / ' + proj.Project_Code__c;
                            projMap.put(proj.Parent_Project__r.Project_Code__c, str);
                        }
                    }else{
                        if(!projMap.containsKey(proj.Project_Code__c)){
                            projMap.put(proj.Project_Code__c,proj.Project_Code__c);
                        }
                    }
                }
                system.debug('projMap::'+projMap);
                
                if(projMap != null){
                    projCodeList = projMap.values();
                }
                
                if(projCodeList.size() > 1){
                    sysWrap.isViewSystems = true;
                }
                
                if(projCodeList.size() > 0){
                    sysWrap.projCodeList = projCodeList;
                }
                
                if(projectCode == '' && projCodeList.size() > 0){
                    system.debug('projCodeList::'+projCodeList[0]);
                    projectCode = projCodeList[0];
                    sysWrap.projWrap = getAllStationDetails(plantCode,projectCode,filterValue);
                    sysWrap.servConWrap = getContractDetails(pltId,projectCode,langCode);
                }else{
                    sysWrap.projWrap = getAllStationDetails(plantCode,projectCode,filterValue);
                    sysWrap.servConWrap = getContractDetails(pltId,projectCode,langCode);
                }                
                
            }
            
        }
        catch(Exception e){
            system.debug('Exception Cause::'+e.getCause());
            system.debug('Exception LineNumber::'+e.getLineNumber());
            system.debug('Exception Message::'+e.getMessage());
            system.debug('Exception StackTrace::'+e.getStackTraceString());
            system.debug('Exception TypeName::'+e.getTypeName());
            YG_Utility.logError('AllSystemsPage','Backend Process Error',e.getStackTraceString(),
                                'Class:YG_SystemsController; Method: getAllSystemsDetails(); Line #:'+e.getLineNumber()+'; Message:'+e.getMessage(),
                                UserInfo.getUserId());
        }
        
        system.debug('sysWrap::'+sysWrap);
        return sysWrap;
        
    }
    
	//Wrapper to store the systems available under the plant 
    public class systemWrapper{
        
        @AuraEnabled public Boolean isViewSystems = false; //set to true if there are multiple projects
        @AuraEnabled public String plantCode; //store the plant code
        @AuraEnabled public List<String> projCodeList = new List<String>(); //store the list of project code
        @AuraEnabled public projectWrapper projWrap = new projectWrapper(); //store the station details
        @AuraEnabled public List<serviceContractWrap> servConWrap = new List<serviceContractWrap>(); //store the contract details
        
    }
    
    
    /**
	 *This method is used to get the consolidated station details for All Systems page.
     *
	 **/
    @AuraEnabled
    public static projectWrapper getAllStationDetails(String plantCode, String projectCode, List<String> filterValue){
        
        system.debug('plantCode::'+plantCode);
        system.debug('projectCode::'+projectCode);
        system.debug('filterValue::'+filterValue);
        
        projectWrapper projWrap = new projectWrapper();
        List<projectDetailsWrapper> projDetWrapList = new List<projectDetailsWrapper>();
        List<stationWrapper> statWrapList = new List<stationWrapper>();
        Id pltId = null; //Store the plant Id
        Map<Id,Project__c> projMap = new Map<Id,Project__c>(); //List to store the project details
        List<Integer> domainNo = new List<Integer>(); //List to store domain number
        List<Id> prodId = new List<Id>(); //List to store product id
        List<Id> statProdId = new List<Id>(); //List to store product id of the station
        List<String> astProductName = new List<String>(); //List to store the product name from asset object
        List<Asset> assetList = new List<Asset>(); //List to store the asset details
        List<Maintenance_Phase__c> maintenancePhaseList = new List<Maintenance_Phase__c>(); //List to store the maintenance phase
        Map<Id,Asset> statMap = new Map<Id,Asset>(); //Map to store the station record Id and its name
        Map<Id,List<Id>> statModMap = new Map<Id,List<Id>>(); //Map to store the station record id and its associated product id
        Integer key = 0;
        String noti = 'Software/Hardware no longer supported';
        
        try{
            
            //Get the language code of the user
            String langCode = YG_CommonUtils.getLanguageCode(userInformation.LanguageLocaleKey);
            system.debug('langCode::'+langCode);
            
            //Get plant id based on the plant code
            /*Plant__c plant = YG_HelperClass.getPlantID(plantCode,langCode);*/
            Account plant = YG_HelperClass.getPlantID(plantCode,langCode);
            pltId = plant.id;
            system.debug('pltId::'+pltId);
            
            //Convert to string to List
            List<String> projCodeList = projectCode.split(' / ');
            system.debug('projCodeList::'+projCodeList);
            
            //Get Project Details
            List<Project__c> projList = [Select Id,Name,Project_Code__c,Last_System_Update_Date__c,Revision_No__c, Parent_Project__c,  
                        				 Parent_Project__r.Project_Code__c from Project__c where PlantAccount__r.Id=:pltId And 
                                         Project_Code__c IN :projCodeList order by CreatedDate Asc];
            
         	
            //get project id and record in map
            for(Project__c proj: projList){
                if(!projMap.containsKey(proj.Id)){
                    projMap.put(proj.Id,proj);
                }
            }
            system.debug('projMap::'+projMap);
            
            //Get assets based on the project code
            if(projCodeList.size() > 0){
                
                if(filterValue.size()>0 && !filterValue.isEmpty() && filterValue != null){
                    
                    List<Asset> statList = [Select Parent.Name From Asset where Project__r.Project_Code__c IN :projCodeList AND Product2.Model_Code__c IN :filterValue AND Lang_Code__c = :langCode];
                    system.debug('statList::'+statList);
                    
                    if(statList.size() > 0 && !statList.isEmpty()){
                        for(Asset staName: statList){
                            if(!filterValue.contains(staName.Parent.Name)){
                                filterValue.add(staName.Parent.Name);
                            }
                        }
                    }
                    
                    assetList = [SELECT Id,Name,PlantAccount__c,Product2Id,Project__c,Product_Name__c,Product2.Category__r.Name,
                                 Product2.Name,Product2.Model_Code__c,Station_Type__c,Domain__c, Revision_No__c,Station_Number__c
                                 FROM Asset WHERE Project__r.Project_Code__c IN :projCodeList AND (Name IN :filterValue OR Product2.Model_Code__c IN :filterValue) 
                                 AND Product2.Category__r.Category_Type__c = 'System' AND Lang_Code__c = :langCode AND PlantAccount__r.Id=:pltId Order By Domain__c ASC];
                    
                    
                }else{
                    
                    assetList = [SELECT Id,Name,PlantAccount__c,Product2Id,Product_Name__c,Product2.Name,Product2.Model_Code__c,Station_Type__c,Product2.Category__r.Name,Station_Number__c,
                                 Domain__c, Revision_No__c FROM Asset WHERE Project__r.Project_Code__c IN :projCodeList AND Product2.Category__r.Category_Type__c = 'System' 
                                 AND Lang_Code__c=:langCode AND PlantAccount__r.Id=:pltId Order By Domain__c, Name ASC];
                
                }
            }            
            system.debug('assetList::'+assetList);
            
            for(Asset asst: assetList){
                
                if(asst.Product2Id != null && !prodId.contains(asst.Product2Id)){
                    prodId.add(asst.Product2Id);
                }
                
                if(asst.Product_Name__c != null && asst.Product_Name__c != '' && !astProductName.contains(asst.Product_Name__c)){
                    astProductName.add(asst.Product_Name__c);
                }
                
                if(asst.Station_Type__c != '' && asst.Domain__c != null && asst.Station_Type__c != null){
                    statMap.put(asst.Id,asst);
                }
                
                if(asst.Domain__c != null && !domainNo.contains(asst.Domain__c.intValue())){
                    domainNo.add(asst.Domain__c.intValue());
                }
                
                if(asst.Station_Type__c != '' && asst.Station_Type__c != null && asst.Domain__c != null && !statProdId.contains(asst.Product2Id)){
                    statProdId.add(asst.Product2Id);
                }
                
            }
            
            //Assigning project details to the wrapper
            if(domainNo.size() > 0){
                projWrap.domainNo = domainNo;
                projWrap.isDomain = true;
            }
            
            //Get the maintenance phase details based on the product id in specific project
            if(prodId.size() > 0){
                maintenancePhaseList = [SELECT Id,Product__c,Product__r.Category__r.Name,Sales_Phase_Start_Date__c,Sales_Phase_End_Date__c,Maintenance_Phase1_End_Date__c,Maintenance_Phase1_Start_Date__c,
                                        Maintenance_Phase2_End_Date__c,Maintenance_Phase2_Start_Date__c,Ext_Maintenance_End_Date__c,Ext_Maintenance_Start_Date__c,Item__c,Sub_Item__c,
                                        Product__r.Model_Code__c FROM Maintenance_Phase__c WHERE Product__c IN :prodId OR Item__c = :astProductName];
            }
            
            system.debug('maintenancePhaseList::'+maintenancePhaseList.size());
            system.debug('maintenancePhaseList::'+maintenancePhaseList);
            
            //Get Project Details in wrapper
            for(Project__c proj: projMap.values()){
                projectDetailsWrapper projDetWrap = new projectDetailsWrapper();
                projDetWrap.projectName = proj.Name;
                projDetWrap.projectCode = proj.Project_Code__c;
                projDetWrap.sysRevNo = proj.Revision_No__c;
                if(proj.Last_System_Update_Date__c != null){
                    Datetime dt = Datetime.newInstance(proj.Last_System_Update_Date__c.year(),proj.Last_System_Update_Date__c.month(),proj.Last_System_Update_Date__c.day());
                    projDetWrap.lastSysUpdateDate = dt.format('dd MMM YYYY');
                }else{
                    projDetWrap.lastSysUpdateDate = '-';
                }
                for(Maintenance_Phase__c mtnPhase: maintenancePhaseList){
                    if(mtnPhase.Item__c == proj.Name && mtnPhase.Sub_Item__c == proj.Revision_No__c){
                        productPhase prodPhase = YG_SystemsController.getPhaseDetails(mtnPhase);
                        if(prodPhase.prodMtnPhase != '-'){
                            projDetWrap.sysMtnPhase = prodPhase.prodMtnPhase.replace(Label.YG_Maintenance+' ','');
                        }
                        projDetWrap.sysColorClassName = prodPhase.colorClassName;
                    }
                    
                }
                projDetWrapList.add(projDetWrap);
            }
            
            
            //Station wrapper logic goes here
            for(Id statId: statMap.keySet()){
                
                Asset assRec = statMap.get(statId);
                String dn = string.valueOf(assRec.Domain__c.intValue());
                String sn = string.valueOf(assRec.Station_Number__c.intValue());
                
                stationWrapper statRec = new stationWrapper();
                statRec.key = 'Station' + key++;
                statRec.domainNo = assRec.Domain__c.intValue();
                statRec.stationName = assRec.Name;
                statRec.stationModelCode = assRec.Product2.Model_Code__c;
                statRec.statProdSubType = assRec.Station_Type__c;
                statRec.stationRevisionNo = assRec.Revision_No__c;
                statRec.stationRecId = statId;
                statRec.stationNo = assRec.Station_Number__c.intValue();
                if(assRec.Domain__c.intValue() < 10 && assRec.Domain__c.intValue() > 0){
                    dn = '0'+ dn;
                }
                if(assRec.Station_Number__c.intValue() < 10 && assRec.Station_Number__c.intValue() > 0){
                    sn = '0'+ sn;
                }
                statRec.dnsn = dn + sn;
                List<String> notiList = new List<String>(); //List to store the notifications
                String str = '';
                
                //logic to calculate maintenance phase of stations
                for(Maintenance_Phase__c mtnPhase: maintenancePhaseList){
                    if(assRec.Station_Type__c == 'HIS'){
                        if(mtnPhase.Item__c == assRec.Product_Name__c && mtnPhase.Sub_Item__c == assRec.Revision_No__c && assRec.Revision_No__c != ''){
                            productPhase prodPhase = YG_SystemsController.getPhaseDetails(mtnPhase);
                            if(prodPhase.prodMtnPhase != '-'){
                                statRec.prodMtnPhase = 'Software '+prodPhase.prodMtnPhase;
                            }
                            statRec.colorClassName = prodPhase.colorClassName;
                            str = prodPhase.phaseEndingIn;
                            
                            if(str.contains('_') && str != 'Invalid'){
                                str = str.replace('_','');
                                str = assRec.Product2.Model_Code__c +' '+Label.YG_Maintenance_Phase_Ending_In+' '+ str;
                                if(!notiList.contains(str)){
                                    notiList.add(str);                            
                                }
                            }
                            if(str == 'Invalid'){
                                if(!notiList.contains('Software no longer supported')){
                                    notiList.add('Software no longer supported');   
                                }
                            }
                        }
                    }
                    if(assRec.Station_Type__c != 'HIS' && assRec.Product2.Category__r.Name == 'Hardware' && assRec.Product2.Model_Code__c == mtnPhase.Product__r.Model_Code__c){
                        productPhase prodPhase = YG_SystemsController.getPhaseDetails(mtnPhase);
                        if(prodPhase.prodMtnPhase != '-'){
                            statRec.prodMtnPhase = assRec.Product2.Category__r.Name+' '+prodPhase.prodMtnPhase;
                        }
                        statRec.colorClassName = prodPhase.colorClassName;
                        str = prodPhase.phaseEndingIn;
                        
                        if(str.contains('_') && str != 'Invalid'){
                            str = str.replace('_','');
                            str = assRec.Product2.Model_Code__c +' '+Label.YG_Maintenance_Phase_Ending_In+' '+ str;
                            if(!notiList.contains(str)){
                                notiList.add(str);                            
                            }
                        }
                        if(str == 'Invalid'){
                            if(!notiList.contains(assRec.Product2.Category__r.Name+' '+'no longer supported')){
                                notiList.add(assRec.Product2.Category__r.Name+' '+'no longer supported');   
                            }
                        }
                    }
                    
                    if(assRec.Station_Type__c != 'HIS' && assRec.Product2.Category__r.Name == 'Software' && assRec.Product2.Model_Code__c == mtnPhase.Product__r.Model_Code__c && mtnPhase.Sub_Item__c == assRec.Revision_No__c && assRec.Revision_No__c != ''){
                        productPhase prodPhase = YG_SystemsController.getPhaseDetails(mtnPhase);
                        if(prodPhase.prodMtnPhase != '-'){
                            statRec.prodMtnPhase = assRec.Product2.Category__r.Name+' '+prodPhase.prodMtnPhase;
                        }
                        statRec.colorClassName = prodPhase.colorClassName;
                        str = prodPhase.phaseEndingIn;
                        
                        if(str.contains('_') && str != 'Invalid'){
                            str = str.replace('_','');
                            str = assRec.Product2.Model_Code__c +' '+Label.YG_Maintenance_Phase_Ending_In+' '+ str;
                            if(!notiList.contains(str)){
                                notiList.add(str);                            
                            }
                        }
                        if(str == 'Invalid'){
                            if(!notiList.contains(assRec.Product2.Category__r.Name+' '+'no longer supported')){
                                notiList.add(assRec.Product2.Category__r.Name+' '+'no longer supported');   
                            }
                        }
                    }
                }	                
                statRec.statNotiList = notiList;   
                statWrapList.add(statRec);
            }
            
            if(projDetWrapList.size() > 0){
                projWrap.projDetWrap = projDetWrapList;
                projWrap.isProjDet = true;
            }else{
                projWrap.projDetWrap = new List<projectDetailsWrapper>();
                projWrap.isProjDet = false;
            }
            
            if(statWrapList.size() > 0){
                projWrap.statWrap = statWrapList;
                projWrap.isStatWrap = true;
            }else{
                projWrap.statWrap = new List<stationWrapper>();
                projWrap.isStatWrap = false;
            }
            
            
        }
        catch(Exception e){
            system.debug('Exception Cause::'+e.getCause());
            system.debug('Exception LineNumber::'+e.getLineNumber());
            system.debug('Exception Message::'+e.getMessage());
            system.debug('Exception StackTrace::'+e.getStackTraceString());
            system.debug('Exception TypeName::'+e.getTypeName());
            YG_Utility.logError('AllSystemsPage','Backend Process Error',e.getStackTraceString(),
                                'Class:YG_SystemsController; Method: getAllStationDetails(); Line #:'+e.getLineNumber()+'; Message:'+e.getMessage(),
                                UserInfo.getUserId());
        }
        
        system.debug('projWrap::'+projWrap);
        return projWrap;
        
    }

    
    //Wrapper to store the stations available under the plant and project
    public class projectWrapper{
        
        @AuraEnabled public Boolean isDomain = false; //set to true if there is domain
        @AuraEnabled public Boolean isProjDet = false; //set to true if there is project for plant code
        @AuraEnabled public Boolean isStatWrap = false; //set to true if there are staions under a project
        @AuraEnabled public List<Integer> domainNo = new List<Integer>(); //list to store the domains
        @AuraEnabled public List<projectDetailsWrapper> projDetWrap = new List<projectDetailsWrapper>(); //store the project details
        @AuraEnabled public List<stationWrapper> statWrap = new List<stationWrapper>(); //store the station details
        
    }
    
    //Sub wrapper to store the project details
    public class projectDetailsWrapper{
        
        @AuraEnabled public String projectName = '-'; // store the project name (system name)
        @AuraEnabled public String projectCode = '-'; // store the project code (system id)
        @AuraEnabled public String sysRevNo = '-'; // store the revision number of system
        @AuraEnabled public String sysMtnPhase = '-'; // store the maintenance phase of system
        @AuraEnabled public String sysColorClassName; // store the css color based on maintenance phase
        @AuraEnabled public String lastSysUpdateDate; // store the last system update of the project
        
    }
    
    //Sub wrapper to store the station details
    public class stationWrapper{
        
        @AuraEnabled public Integer domainNo; // store the domain number of the station
        @AuraEnabled public String stationName; // store the station name (asset name)
        @AuraEnabled public String statProdSubType; // store the station type of the station
        @AuraEnabled public String stationModelCode; // store the model code of the station
        @AuraEnabled public String stationRevisionNo; // store the revision number of the station
        @AuraEnabled public Id stationRecId; // store the station sfdc record id
        @AuraEnabled public String prodMtnPhase = '-'; // store the maintenance phase of the station
        @AuraEnabled public String colorClassName; // store the css color based on maintenance phase
        @AuraEnabled public List<String> statNotiList; // store the notifications related to stations
        @AuraEnabled public Integer stationNo; // store the station number of the station
        @AuraEnabled public String dnsn; // store the domain and station number of the station
        @AuraEnabled public String key; // store the autonumber used in UI
        
    }
    
    /**
	 *This method is used to get the phase details of the product for All Systems page.
     *
	 **/    
    @AuraEnabled
    public static productPhase getPhaseDetails(Maintenance_Phase__c mtnPhase){
        
        system.debug('mtnPhase::'+mtnPhase);
        system.debug('mtnPhase::'+mtnPhase.Product__r.Model_Code__c);
        productPhase prodPhase = new productPhase();
        
        try{
            //Calculating the product phase details 
            if((mtnPhase.Sales_Phase_Start_Date__c != null && mtnPhase.Sales_Phase_End_Date__c != null) ||  (mtnPhase.Sales_Phase_Start_Date__c != null && mtnPhase.Sales_Phase_End_Date__c == null)){
                if(mtnPhase.Sales_Phase_Start_Date__c <= date.today() && date.today() <= mtnPhase.Sales_Phase_End_Date__c){
                    prodPhase.prodMtnPhase = Label.YG_Sys_Sales_phase;
                    prodPhase.colorClassName = 'secondary-green';
                    prodPhase.phaseEndingIn = YG_SystemsController.getPhaseEndsIn(mtnPhase.Sales_Phase_End_Date__c);
                }else{
                    prodPhase.prodMtnPhase = Label.YG_Sys_Sales_phase;
                    prodPhase.colorClassName = 'secondary-green';
                    prodPhase.phaseEndingIn = '-';
                }						
            }            
            if((mtnPhase.Maintenance_Phase1_Start_Date__c != null && mtnPhase.Maintenance_Phase1_End_Date__c != null) || (mtnPhase.Maintenance_Phase1_Start_Date__c != null && mtnPhase.Maintenance_Phase1_End_Date__c == null)){
                if(mtnPhase.Maintenance_Phase1_Start_Date__c <= date.today() && date.today() <= mtnPhase.Maintenance_Phase1_End_Date__c){
                    prodPhase.prodMtnPhase = Label.YG_Sys_Maintenance_phase_1;
                    prodPhase.colorClassName = 'secondary-yellow';
                    prodPhase.phaseEndingIn = YG_SystemsController.getPhaseEndsIn(mtnPhase.Maintenance_Phase1_End_Date__c); 				
                }else{
                    prodPhase.prodMtnPhase = Label.YG_Sys_Maintenance_phase_1;
                    prodPhase.colorClassName = 'secondary-yellow';
                    prodPhase.phaseEndingIn = '-';
                }						
            }
            if((mtnPhase.Maintenance_Phase2_Start_Date__c != null && mtnPhase.Maintenance_Phase2_End_Date__c != null) || (mtnPhase.Maintenance_Phase2_Start_Date__c != null && mtnPhase.Maintenance_Phase2_End_Date__c == null)){
                if(mtnPhase.Maintenance_Phase2_Start_Date__c <= date.today() && date.today() <= mtnPhase.Maintenance_Phase2_End_Date__c){
                    prodPhase.prodMtnPhase = Label.YG_Sys_Maintenance_phase_2;
                    prodPhase.colorClassName = 'secondary-orange';
                    prodPhase.phaseEndingIn = YG_SystemsController.getPhaseEndsIn(mtnPhase.Maintenance_Phase2_End_Date__c); 
                }else{
                    prodPhase.prodMtnPhase = Label.YG_Sys_Maintenance_phase_2;
                    prodPhase.colorClassName = 'secondary-orange';
                    prodPhase.phaseEndingIn = '-';
                }						
            }
            if((mtnPhase.Ext_Maintenance_Start_Date__c != null && mtnPhase.Ext_Maintenance_End_Date__c != null) || (mtnPhase.Ext_Maintenance_Start_Date__c != null && mtnPhase.Ext_Maintenance_End_Date__c == null)){
                if(mtnPhase.Ext_Maintenance_Start_Date__c <= date.today() && date.today() <= mtnPhase.Ext_Maintenance_End_Date__c){
                    prodPhase.prodMtnPhase = Label.YG_Sys_Extended_phase;
                    prodPhase.colorClassName = 'grey-medium';
                    prodPhase.phaseEndingIn = 'Invalid'/*YG_SystemsController.getPhaseEndsIn(mtnPhase.Ext_Maintenance_End_Date__c)*/; 
                }else{
                    prodPhase.prodMtnPhase = Label.YG_Sys_Extended_phase;
                    prodPhase.colorClassName = 'grey-medium';
                    prodPhase.phaseEndingIn = 'Invalid';
                }						
            }
            
        }
        catch(Exception e){
            system.debug('Exception Cause::'+e.getCause());
            system.debug('Exception LineNumber::'+e.getLineNumber());
            system.debug('Exception Message::'+e.getMessage());
            system.debug('Exception StackTrace::'+e.getStackTraceString());
            system.debug('Exception TypeName::'+e.getTypeName());
            YG_Utility.logError('AllSystemsPage','Backend Process Error',e.getStackTraceString(),
                                'Class:YG_SystemsController; Method: getPhaseDetails(); Line #:'+e.getLineNumber()+'; Message:'+e.getMessage(),
                                UserInfo.getUserId());
            
        }
        
        system.debug('prodPhase::'+prodPhase);
        return prodPhase;
        
    }
	
	//Wrapper to store the product's maintenance phase and its phase ending details    
    public class productPhase{
        
        @AuraEnabled public String prodMtnPhase = '-';
        @AuraEnabled public String colorClassName = '';
        @AuraEnabled public String phaseEndingIn = '';
        
    }
    
    /**
	 *This method is used to get the phase ending details of the product for All Systems page.
     *
	 **/     
    @AuraEnabled
    public static String getPhaseEndsIn(Date endDate){
        
        system.debug('endDate::'+endDate);
        
        String phaseEndsIn = '-';
        
        try{
            //Calculating the phase ending in details based on today's date and phase end date
            Date now =  date.today();
            Date phaseEndDate = endDate;
            
            if(endDate < now){
                phaseEndsIn = Label.YG_Expired;
            }
            else if(endDate == now){
                phaseEndsIn = Label.YG_Expires_today;
            }
            else{
                
                Integer months = now.monthsBetween(phaseEndDate);
                if (now.day() > phaseEndDate.day()) {
                    months--;
                }
                
                Date rolledBackEndDate = phaseEndDate.addMonths(0 - months);
                Integer days = now.daysBetween(rolledBackEndDate);
                
                Integer years =Integer.valueOf(Math.floor(months / 12));
                months = months - (years * 12);
                
                String noOfYears = String.valueOf(years) + 'y_' + String.valueOf(months) + 'm_' + String.valueOf(days) + 'd' ;
                List<String> splitYrs = noOfYears.split('_');
                
                if(splitYrs[0] == '0y'){
                    if(months < 6){
                        phaseEndsIn = '_' + String.valueOf(months) + 'm ' + String.valueOf(days) + 'd';
                    }/*else{
                        phaseEndsIn = String.valueOf(months) + 'm ' + String.valueOf(days) + 'd';
                    }*/
                }
                /*else{
                    phaseEndsIn = String.valueOf(years) + 'y ' + String.valueOf(months) + 'm';
                }*/
                
            }
            
        }
        catch(Exception e){
            system.debug('Exception Cause::'+e.getCause());
            system.debug('Exception LineNumber::'+e.getLineNumber());
            system.debug('Exception Message::'+e.getMessage());
            system.debug('Exception StackTrace::'+e.getStackTraceString());
            system.debug('Exception TypeName::'+e.getTypeName());
            YG_Utility.logError('AllSystemsPage','Backend Process Error',e.getStackTraceString(),
                                'Class:YG_SystemsController; Method: getPhaseEndsIn(); Line #:'+e.getLineNumber()+'; Message:'+e.getMessage(),
                                UserInfo.getUserId());
        }
        
        system.debug('phaseEndsIn::'+phaseEndsIn);
        return phaseEndsIn;
    }
     
    
    /**
	 *This method is used to get the contracts related to the plant.
     *
	 **/
    @AuraEnabled
    public static List<serviceContractWrap> getContractDetails(String plantId, String projectCode, String langCode){
        
        system.debug('plantId::'+ plantId);
        system.debug('projectCode::'+ projectCode);
        system.debug('langCode::'+ langCode);
        
        List<serviceContractWrap> servContWrapList = new List<serviceContractWrap>();
        //List<Service_Contract_Plant__c> servContList = new List<Service_Contract_Plant__c>(); //List to store the contract
        List<Asset> assetList = new List<Asset>();
        List<Id> asstId = new List<Id>();
        List<Scope_of_Product__c> sopList = new List<Scope_of_Product__c>();
        
        try{
            
            //Convert to string to List
            List<String> projCodeList = projectCode.split(' / ');
            system.debug('projCodeList::'+projCodeList);
            
            assetList = [SELECT Id,Name,AccountId,MS_Code__c,ParentId,PlantAccount__c,Product2Id,
                         SerialNumber,Product2.Name,Product2.Model_Code__c,Product2.Product_Type__c,
                         Domain__c, Revision_No__c FROM Asset WHERE Project__r.Project_Code__c IN :projCodeList AND Product2.Category__r.Category_Type__c = 'System' 
                         AND Lang_Code__c=:langCode AND PlantAccount__r.Id=:plantId];
            
            
            for(Asset asst: assetList){
                asstId.add(asst.Id);
            }
            
            system.debug('asstId::'+asstId);
            
            sopList = [Select Asset__c, Service_Contract__c, Service_Contract__r.Name, Service_Contract__r.Contract_No__c, Service_Contract__r.StartDate,
                        Service_Contract__r.EndDate, Service_Contract__r.Renewed_Contract__c From Scope_of_Product__c Where Asset__c IN :asstId And Service_Contract__r.Renewed_Contract__c = null];
            
        	system.debug('sopList::'+ sopList);
            
            if(sopList.size() > 0){
                
                for(Scope_of_Product__c servCon : sopList){
                    serviceContractWrap servContWrap = new serviceContractWrap();
                    servContWrap.contractName = servCon.Service_Contract__r.Name;
                    servContWrap.contractNo = servCon.Service_Contract__r.Contract_No__c;
                    
                    Datetime startDate = Datetime.newInstance(servCon.Service_Contract__r.StartDate.year(),servCon.Service_Contract__r.StartDate.month(),servCon.Service_Contract__r.StartDate.day());
                	servContWrap.contractStartDt = startDate.format('dd MMM '+startDate.year());
                    
                    Datetime endDate = Datetime.newInstance(servCon.Service_Contract__r.EndDate.year(),servCon.Service_Contract__r.EndDate.month(),servCon.Service_Contract__r.EndDate.day());
                	servContWrap.contractEndDt = endDate.format('dd MMM '+endDate.year());
                    
                    //Calculating the contract expiry based on today's date and contract end date
                    String contractExpsIn = YG_SystemsController.getPhaseEndsIn(servCon.Service_Contract__r.EndDate);
                       
                    if(contractExpsIn != '-'){
                        contractExpsIn = contractExpsIn.replace('_','');
                        servContWrap.contractExpsIn = contractExpsIn;
                        servContWrap.contractAction = Label.YG_Renew_LCA;
                    }else{
                        servContWrap.contractExpsIn = '';
                        servContWrap.contractAction = '';
                    }
                    
                    servContWrapList.add(servContWrap);
                }
            }         
        }
        catch(Exception e){
            system.debug('Exception Cause::'+e.getCause());
            system.debug('Exception LineNumber::'+e.getLineNumber());
            system.debug('Exception Message::'+e.getMessage());
            system.debug('Exception StackTrace::'+e.getStackTraceString());
            system.debug('Exception TypeName::'+e.getTypeName());
            YG_Utility.logError('AllSystemsPage','Backend Process Error',e.getStackTraceString(),
                                'Class:YG_SystemsController; Method: getContractDetails(); Line #:'+e.getLineNumber()+'; Message:'+e.getMessage(),
                                UserInfo.getUserId());
        }
        
        system.debug('servContWrapList::'+servContWrapList);
        return servContWrapList;
    }
    
    //Wrapper to store the service contract details
    public class serviceContractWrap{
        @AuraEnabled public String contractName;
        @AuraEnabled public String contractNo;
        @AuraEnabled public String contractStartDt;
        @AuraEnabled public String contractEndDt;
        @AuraEnabled public String contractExpsIn = '';
        @AuraEnabled public String contractAction;
    }
}