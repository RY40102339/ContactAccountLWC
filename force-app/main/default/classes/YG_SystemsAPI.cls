/********************************************************************************************************
* (C) Copyright 2020 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Selvaraj T
* @version 1.0
* @created 01/06/2021
* @description : This class is used to make an API call to external system to fetch and store the system details.
* @test class name - YG_SystemsAPITest and YG_SystemsAPIMockCallout
*
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  04/20/2021           Vinod 					Removed Plant__c Object and replaced with Account Object also removed Customer_Plant__c Object and replaced with AccountContactRelation Object.
*												Removed Plant__c(Plant) Lookup field from Asset and Project Objects and newly added PlantAccount__c(Account) Lookup field in Asset and Project Object.
*/

public class YG_SystemsAPI {
    
    public static User userInformation =  YG_Utility.getLoggedInUserInfo(UserInfo.getUserId());
    
    //This method is used to get the customer plant list of loggedin user
    @AuraEnabled
    public static Map<String,String> getCustomerPlantDetails(){
        
        Map<String,String> plantCodeMap = new Map<String,String>(); //map to store the plant code and its id
        /*List<Customer_Plant__c> cusPlantList = new List<Customer_Plant__c>();*/
        List<AccountContactRelation> cusPlantList = new List<AccountContactRelation>();
        
        try{
            //get loggedin user contact id
            Id conId = userInformation.ContactId;
            
            //Datetime in GMT
            DateTime dt = DateTime.now();
            
            //get deliveraable execution date code
            Map<String, YG_Community_Configuration__c> allValues = YG_Community_Configuration__c.getAll();
            String days = allValues.get('Deliverable API Execution Days').Text_1__c;
            
            //get customer plant based on loggedin user contact id
           /* cusPlantList = [Select Plant__r.Id,Plant__r.Plant_Code__c, Plant__r.API_Last_Executed_Date__c From Customer_Plant__c Where Status__c = 'Approved site access'
                        and Contact__c =: conId order by Plant__r.Name Asc];*/
            cusPlantList = [Select AccountId,Account.AccountNumber, Account.System_API_Last_Sync_Date__c From AccountContactRelation Where Status__c = 'Approved site access'
                        and ContactId =: conId order by Account.Name Asc];
            
            if(cusPlantList.size() > 0){
               /* for(Customer_Plant__c pltCode: cusPlantList){
                    DateTime delAPIDt = pltCode.Plant__r.API_Last_Executed_Date__c;
                    if(delAPIDt != null){
                        delAPIDt = delAPIDt.addDays(Integer.valueof(days.trim()));
                    }
                    if(!plantCodeMap.containsKey(pltCode.Plant__r.Plant_Code__c) && (dt > delAPIDt || delAPIDt == null)){
                        plantCodeMap.put(pltCode.Plant__r.Plant_Code__c,pltCode.Plant__r.Id);
                    }
                }*/
                for(AccountContactRelation pltCode: cusPlantList){
                    DateTime delAPIDt = pltCode.Account.System_API_Last_Sync_Date__c ;
                    if(delAPIDt != null){
                        delAPIDt = delAPIDt.addDays(Integer.valueof(days.trim()));
                    }
                    if(!plantCodeMap.containsKey(pltCode.Account.AccountNumber) && (dt > delAPIDt || delAPIDt == null)){
                        plantCodeMap.put(pltCode.Account.AccountNumber,pltCode.AccountId);
                    }
                }
            }
            if(!plantCodeMap.isEmpty()){
                system.debug('plantCodeMap::'+plantCodeMap);
                return plantCodeMap;
            }
        }
        catch(Exception e){
            YG_Utility.logError('HomePage','Backend Process Error',e.getStackTraceString(),
                                'Class:YG_SystemsAPI; Method: getCustomerPlantDetails(); Line #:'+e.getLineNumber()+'; Message:'+e.getMessage(),
                                UserInfo.getUserId());
        }
        return null;
    }
    
    /*
     * This method is used to upsert the system and assets related to customer plant
     * Calling Deliverable List and Deliverable Product List API in Loop
    */
    @AuraEnabled 
    public static Boolean getDeliverableNoAndSystemId(List<String> plantCodeList){
        
        system.debug('plantCodeList::'+plantCodeList);
        
        Boolean isSuccess = false;
        
        // Instantiate a new http object
        Http http = new Http();
        HttpResponse res = new HttpResponse();
        
        // Instantiate a new HTTP request
        HttpRequest req = new HttpRequest();
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');
        req.setMethod('POST');
        req.setTimeout(120000);
        
        List<deliverableListAPI> deliverableSystemList = new List<deliverableListAPI>();
        Map<String,String> plantMap = new Map<String,String>(); //map to store the plant code and its id
        Map<String,String> plantdeliverableNoMap = new Map<String,String>(); //map to store deliverable no as Key and plant code as value
        Map<String,String> deiverableNoSystemMap = new Map<String,String>(); //map to store deliverable no as Key and system id as value
        List<Project__c> projList = new List<Project__c>();
        
        try{
            
            //get the plant details of logged in customer 
            plantMap = getCustomerPlantDetails();
            
            //get the account id and account number
            Id accId = userInformation.Contact.AccountId;
            String accountNumber = userInformation.Contact.Account.AccountNumber;
            Boolean ifAcc = false; 
		
			//get the request url details from community settings
			Map<String, YG_Community_Configuration__c> allValues = YG_Community_Configuration__c.getAll();
            String devListEndPoint = allValues.get('DeliverableListAPIEndpointUrl').Text_1__c;
			String systemid = allValues.get('ShippingAPISystemId').Text_1__c;
            String devListReq = devListEndPoint+'?systemid='+systemid;
            req.setEndpoint(devListReq);
            
            if(plantCodeList.size()>0){
                
                //get the project using plant code
                /*List<Project__c> existProjList = [Select Id, Name, Project_Code__c From Project__c Where 
                                             		Plant__r.Plant_Code__c =: plantCodeList];*/
                List<Project__c> existProjList = [Select Id, Name, Project_Code__c From Project__c Where 
                                             		PlantAccount__r.AccountNumber =: plantCodeList];
                for(String pltCode: plantCodeList /*plantMap.keySet()*/){
                    if(pltCode == accountNumber){
                        ifAcc = true;
                        req.setBody('{"dlvCustomerBranch": {"customerBranchCd": "'+accountNumber+'"}}');
                    }else{
                        req.setBody('{"type":"deliverables","plantCrm": {"plantNo": "'+pltCode+'"}}');
                    }
                    
                    res = http.send(req);
                    
                    if(res.getStatusCode() == 200){
                        String response = res.getBody();
                        
                        //parse deliverableList API response
                        deliverableSystemList = (List<deliverableListAPI>)JSON.deserialize(response, List<deliverableListAPI>.class);
                        
                        //get the deliverable no and system id along with plant code
                        for(deliverableListAPI resp: deliverableSystemList){
                            plantdeliverableNoMap.put(resp.deliverablesNo,pltCode);
                            deiverableNoSystemMap.put(resp.deliverablesNo,resp.systemIdCrm);
                            
                            //create a project
                            Project__c proj = new Project__c();
                            proj.Name = resp.systemIdCrm;
                            proj.Account__c = accId;
                            proj.PlantAccount__c = plantMap.get(pltCode);
                            //proj.Account__c = plantMap.get(pltCode);
                            proj.Project_Code__c = resp.systemIdCrm;
                            for(Project__c p: existProjList){
                                if(p.Project_Code__c == resp.systemIdCrm){
                                    proj.Id = p.Id;
                                    proj.Name = p.Name;
                                }
                            }
                            projList.add(proj);
                        }
                    }
                }
            }
            if(projList.size()>0 && !plantdeliverableNoMap.isEmpty() && !deiverableNoSystemMap.isEmpty() && plantdeliverableNoMap != null && deiverableNoSystemMap != null){
                isSuccess = getDeliverableAssetDetails(plantdeliverableNoMap,plantMap,deiverableNoSystemMap,projList,ifAcc);                
            }
        }
        catch(Exception e){
            YG_Utility.logError('HomePage','Backend Process Error',e.getStackTraceString(),
                                'Class:YG_SystemsAPI; Method: getDeliverableNoAndSystemId(); Line #:'+e.getLineNumber()+'; Message:'+e.getMessage(),
                                UserInfo.getUserId());
        }
        system.debug('isSuccess::'+isSuccess);
        return isSuccess;
    }
    
    //Wrapper to store the deliverableList API response
    public class deliverableListAPI{
        @AuraEnabled public String deliverablesNo; //used in deliverable product api end point
		@AuraEnabled public String systemIdCrm; //used in system list api end point
        @AuraEnabled public String plantCode; //store the plant code
    }
    
    /*
     * This method is used to get the system and its assets details using system id
	*/
    @AuraEnabled
    public static Boolean getSystemDetails(List<String> plantCodeList){
                 
        Boolean isSuccess = false;
		List<String> systemIdList = new List<String>(); //List to store the all the system id
        List<Data> dtList = new List<Data>(); //List to store the api response
        List<Project__c> projList = new List<Project__c>(); //List to store the project records
        List<Asset> asstList = new List<Asset>(); //List to store the asset records
        List<String> modCodeList = new List<String>(); //List to store the model code
        Map<String,String> plantMap = new Map<String,String>(); //map to store plant code as Key and id as value
        Map<String,String> plantSystemIdMap = new Map<String,String>(); //map to store System Id as Key and Plant code as value
        /*List<Plant__c> pltList = new List<Plant__c>();*/ //list to update plants
        List<Account> pltList = new List<Account>(); //list to update plants
        // Instantiate a new http object
        Http http = new Http();
        HttpResponse res = new HttpResponse();
        
        // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setTimeout(120000);
        
        try{
            
            //get the plant details of logged in customer 
            plantMap = getCustomerPlantDetails();
            
            //get loggedin user account id
            Id accId = userInformation.Contact.AccountId;
            
            //get the project using system id
          /*  List<Project__c> existingProjList = [Select Id, Plant__c, Plant__r.Plant_Code__c, Project_Code__c, Last_System_Update_Date__c From Project__c Where 
                                         		 Plant__r.Plant_Code__c =: plantCodeList];*/
            List<Project__c> existingProjList = [Select Id, Account__c, PlantAccount__r.AccountNumber, Project_Code__c, Last_System_Update_Date__c From Project__c Where 
                                         		 PlantAccount__r.AccountNumber =: plantCodeList];
            //get the list of system id from map
            for(Project__c p: existingProjList){
              /*  plantSystemIdMap.put(p.Project_Code__c,p.Plant__r.Plant_Code__c);*/
                plantSystemIdMap.put(p.Project_Code__c,p.PlantAccount__r.AccountNumber);
                systemIdList.add(p.Project_Code__c);
            }
            
            //get the assets using system id 
            List<Asset> existingAsstList = [Select Id, Name, Project__r.Project_Code__c From Asset Where 
                                            Project__r.Project_Code__c =: plantSystemIdMap.keyset() ];
            
            //get the request url details from community settings
			Map<String, YG_Community_Configuration__c> allValues = YG_Community_Configuration__c.getAll();
            String stationListEndPoint = allValues.get('StationListAPIEndpointUrl').Text_1__c;
			String systemid = allValues.get('ShippingAPISystemId').Text_1__c;
            
            if(systemIdList.size()>0){
                
                //call the API for all system id and capture the response in the list 
                for(String sysId: systemIdList){
                    String systemReq = stationListEndPoint+'?systemid='+systemid+'&gisssystemid='+sysId;
                    req.setEndpoint(systemReq);
                    res = http.send(req);
                    
                    if(res.getStatusCode() == 200){
                        String response = res.getBody();
                        system.debug('response::'+response);
                        
                        //parse systemList API response
                        systemListAPI sysAPIRes = (systemListAPI)JSON.deserialize(response, systemListAPI.class);
                        if(sysAPIRes.ReturnCode == 0){
                            Data dt = sysAPIRes.Data;
                            //comparing the last system update date
                            if(existingProjList.size() > 0){
                                for(Project__c proj: existingProjList){
                                    if(dt.SystemID == proj.Project_Code__c && (date.valueOf(dt.RevInfGenerationDate) > proj.Last_System_Update_Date__c || proj.Last_System_Update_Date__c == null)){
                                        dtList.add(dt);
                                    }
                                    else if(dt.SystemID != proj.Project_Code__c && !plantSystemIdMap.containsKey(dt.SystemID)){
                                        dtList.add(dt);
                                    }
                                } 
                            }else{
                                dtList.add(dt);
                            }
                        }
                    }
                }
                
                if(dtList.size()>0){
                    //iterate the api response to save the system details 
                    system.debug('dtList::'+dtList.size());
                    for(Data d: dtList){
                        String plantCode = plantSystemIdMap.get(d.SystemID);
                        Project__c proj = new Project__c();
                        for(Project__c p: existingProjList){
                            if(d.SystemID == p.Project_Code__c){
                                proj.Id = p.Id;
                            }
                        }
                        proj.Account__c = accId;
                        proj.Name = d.ProductName;
                        proj.Last_System_Update_Date__c = date.valueOf(d.RevInfGenerationDate);
                        proj.PlantAccount__c = plantMap.get(plantCode);
                        proj.Project_Code__c = d.SystemID;
                        
                        //Get the highest revision number of HIS 
                        String highestRevNo = '';
                        for(Stations st: d.Stations){
                            modCodeList.add(st.ModelCode);
                            if(st.StationType == 'HIS' && st.RevisionNumber != ''){
								String revNo = st.RevisionNumber;
                                if(revNo > highestRevNo){
                                    highestRevNo = revNo;
                                }	                                
                            }
                        }
                        proj.Revision_No__c = highestRevNo;
                        projList.add(proj);
                    }
                    
                    if(projList.size() > 0){
                        //insert system records
                        upsert projList;
                        
                        //get the insert project and product list using model code
                        List<Project__c> insertedProjList = projList;
                        List<Product2> productList = [Select Id, Model_Code__c From Product2 Where Model_Code__c IN :modCodeList];
                        Map<String,Id> projMap = new Map<String,String>();
                        Map<String,Id> prodMap = new Map<String,String>();
                        for(Project__c proj: insertedProjList){
                            projMap.put(proj.Project_Code__c, proj.Id);
                        }
                        for(Product2 prod: productList){
                            prodMap.put(prod.Model_Code__c, prod.Id);
                        }
                        
                        //iterate the api response to save the asset details
                        for(Data da: dtList){
                            String plantCode = plantSystemIdMap.get(da.SystemID);
                            for(Stations stn: da.Stations){
                                Asset asst = new Asset();
                                for(Asset ast : existingAsstList){
                                    if(ast.Project__r.Project_Code__c == da.SystemID && ast.Name == stn.StationOrAlias){
                                        asst.Id = ast.Id;
                                    }
                                }
                                asst.Name = stn.StationOrAlias;
                                asst.Domain__c = decimal.valueOf(stn.VnetDomainNumber);
                                asst.Station_Type__c = stn.StationType;
                                asst.Product_Name__c = stn.ProductName;
                                asst.Station_Number__c = decimal.valueOf(stn.VnetStationNumber);
                                asst.Revision_No__c = stn.RevisionNumber;
                                asst.PlantAccount__c = plantMap.get(plantCode);
                                asst.Project__c = projMap.get(da.SystemID);
                                asst.AccountId = accId;
                                if(prodMap.get(stn.ModelCode) != null){
                                    asst.Product2Id = prodMap.get(stn.ModelCode);
                                }
                                asstList.add(asst);
                            }
                        }
                        if(asstList.size()>0){
							upsert asstList;
                            isSuccess = true;
                        }
                    }
                }
                
                if(plantCodeList.size()>0){
                    for(String str: plantCodeList){
                       /* Plant__c plt = new Plant__c();*/
                         Account plt = new Account();
                        plt.Id = plantMap.get(str);
                        plt.System_API_Last_Sync_Date__c = DateTime.now(); //store the GMT TimeZone
                        pltList.add(plt);
                    }
                    if(pltList.size() > 0){
                        update pltList;
                        isSuccess = true;   
                    }
                }
            }            
        }
        catch(Exception e){
            YG_Utility.logError('HomePage','Backend Process Error',e.getStackTraceString(),
                                'Class:YG_SystemsAPI; Method: getSystemDetails(); Line #:'+e.getLineNumber()+'; Message:'+e.getMessage(),
                                UserInfo.getUserId());
        }
        return isSuccess;
    }
    
    /*
     * This method is used to get the assets details using deliverable no
     * Method input - plantdeliverableNoMap - deliverable no as Key and plant code as value
     * Method input - plantMap - plant code as Key and id as value
     * Method input - deiverableNoSystemMap - deliverable no as Key and system id as value
	*/
    @AuraEnabled
    public static Boolean getDeliverableAssetDetails(Map<String,String> plantdeliverableNoMap, Map<String,String> plantMap, Map<String,String> deiverableNoSystemMap, List<Project__c> projList, Boolean ifAcc){
        
        Boolean isSuccess = false;
        List<String> modelCodeList = new List<String>(); //List to store the model code
        List<String> delAsstIdList = new List<String>(); //List to store the deliverable asset id
        Map<String,List<deliverableProductListAPI>> deliResMap = new Map<String,List<deliverableProductListAPI>>(); //map to store the deliverable no & response
        List<Product2> prodList = new List<Product2>(); //List to store the products
        List<Asset> existingAsstList = new List<Asset>(); //List to store the existing asset
        List<Asset> asstList = new List<Asset>(); //List to store and upsert the asset                                             
                                                      
        // Instantiate a new http object
        Http http = new Http();
        HttpResponse res = new HttpResponse();
        
        // Instantiate a new HTTP request
        HttpRequest req = new HttpRequest();
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');
        req.setMethod('POST');
        req.setTimeout(120000);
        
        try{
            
            //get loggedin user account id
            Id accId = userInformation.Contact.AccountId;
            
            //get the request url details from community settings
			Map<String, YG_Community_Configuration__c> allValues = YG_Community_Configuration__c.getAll();
			String systemid = allValues.get('ShippingAPISystemId').Text_1__c;
            String deliProdEndPoint = allValues.get('DeliverableProductAPIEndpointUrl').Text_1__c;
            String deliProdListReq = deliProdEndPoint+'?systemid='+systemid;
            
            //get deliverable no from map
            List<String> deliverableNoList = new List<String>();
            deliverableNoList.addall(plantdeliverableNoMap.keySet());  
            
            
            if(deliverableNoList.size() > 0){
                //configure the deliverable Product List API request details
                req.setEndpoint(deliProdListReq);
                
                for(String str: deliverableNoList){
                    req.setBody('{"type":"deliverablesProduct","deliverables": {"deliverablesNo": "'+str+'"}}');
                    res = http.send(req);
                    
                    if(res.getStatusCode() == 200){
                        String resp = res.getBody();
                        
                        //parse deliverable Product List API response
                        List<deliverableProductListAPI> deliProdListRes = (List<deliverableProductListAPI>)JSON.deserialize(resp, List<deliverableProductListAPI>.class);
                        deliResMap.put(str,deliProdListRes);
                        system.debug('str::'+str);
                        system.debug('deliProdListRes::'+deliProdListRes);
                        
                        //Logic to create or update the existing assets based on response
                        for(deliverableProductListAPI deliProd: deliProdListRes){
                            modelCodeList.add(deliProd.product.productCd);
                            delAsstIdList.add(deliProd.id);
                        }
                    }
                }
                
                //upsert project list
                if(projList.size() > 0){
					upsert projList;  
                }
                
                //get the related products
                if(modelCodeList.size() > 0){
                    prodList = [Select id, Model_Code__c From Product2 Where Model_Code__c = :modelCodeList];
                }
                
                //get the existing system asset using plant code
               /* List<Asset> existList = [Select id,Name From Asset Where Plant__r.Plant_Code__c =: plantMap.keyset()
                                         OR Name = :delAsstIdList];*/
                List<Asset> existList = [Select id,Name From Asset Where PlantAccount__r.AccountNumber =: plantMap.keyset()
                                         OR Name = :delAsstIdList];
                system.debug('existList::'+existList);
                
                for(String str: deliResMap.keyset()){
                    for(deliverableProductListAPI deliProd: deliResMap.get(str)){
                        String pltCode = plantdeliverableNoMap.get(str);
                        String projCode = deiverableNoSystemMap.get(str);
                        Asset asst = new Asset();
                        for(Asset ast: existList){
                            if(ast.Name == deliProd.id){
                                asst.Id = ast.id;
                            }
                        }	
                        asst.Name = deliProd.id;
                        asst.Revision_No__c = deliProd.softwareRevisionCrm;
                        asst.PlantAccount__c = plantMap.get(pltCode);
                        for(Project__c proj: projList){
                            if(proj.Project_Code__c == projCode){
                                asst.Project__c = proj.Id;
                            }
                        }
                        for(Product2 prod: prodList){
                            if(prod.Model_Code__c == deliProd.product.productCd){
                                asst.Product2Id = prod.id;
                            }
                        }
                        asst.AccountId = accId;
                        asstList.add(asst);
                    }
                }
                
                if(asstList.size() > 0){
                    if(ifAcc){
                        Account acc = new Account();
                        acc.Id = accId;
                        acc.Has_Asset__c = true;
                        update acc;
                    }
                    upsert asstList;
                    isSuccess = true;
                }
                
            }
            
        }
        catch(Exception e){
            isSuccess = false;
            YG_Utility.logError('HomePage','Backend Process Error',e.getStackTraceString(),
                                'Class:YG_SystemsAPI; Method: getDeliverableAssetDetails(); Line #:'+e.getLineNumber()+'; Message:'+e.getMessage(),
                                UserInfo.getUserId());
        }
        return isSuccess;
    }
    
    //Wrapper to store the deliverable product asset details
    public class deliverableProductListAPI{
        @AuraEnabled public String id;
		@AuraEnabled public Product product;
        @AuraEnabled public String softwareRevisionCrm;
    }

	public class Product{
		@AuraEnabled public String id;
		@AuraEnabled public String productCd;
	}
    
    /*
     * This method is used to get the model details of the stations
     * Method input - gissSystemId - Project code of the station clicked in UI
     * Method input - station type - of the station clicked in UI (FCS/HIS/BCV/SCS/CGW)
     * Method input - dnsn - domain number and station number of the station clicked in UI
	*/
    @AuraEnabled
    public static stationDataWrapper getStationDetailsList(Id statId, String gissSystemId, String stationType, String dnsn){
        
        system.debug('statId::'+statId);
        system.debug('gissSystemId::'+gissSystemId);
        system.debug('stationType::'+stationType);
        system.debug('dnsn::'+dnsn);
        
        //Wrapper to be returned in this method
        stationDataWrapper statDataWrap = new stationDataWrapper();
        List<stationData> statDataList = new List<stationData>();
        statDataWrap.productSubType = stationType;
        
        // Instantiate a new http object
        Http http = new Http();
        HttpResponse res = new HttpResponse();
        
        // Instantiate a new HTTP request
        HttpRequest req = new HttpRequest();
        
        try{
            
            //Get Station Model Code
            String statModCode = [Select Name, Product2.Model_Code__c From Asset Where id = :statId].Product2.Model_Code__c;
            
            //get the request url details from community settings
			Map<String, YG_Community_Configuration__c> allValues = YG_Community_Configuration__c.getAll();
			String systemid = allValues.get('ShippingAPISystemId').Text_1__c;
            String statDetailsEndPoint = allValues.get('StationDetailsAPIEndpointUrl').Text_1__c;
            
            //Station Details API request URL
            String statDetailReqUrl = statDetailsEndPoint+'?systemid='+systemid+'&stationtype='+stationType+'&gisssystemid='+gissSystemId+'&dnsn='+dnsn;
            
            //create and send req
            req.setMethod('GET');
            req.setTimeout(120000);
            req.setEndpoint(statDetailReqUrl);
            res = http.send(req);
            
            if(res.getStatusCode() == 200){
                String response = res.getBody();
                system.debug('response::'+response);
                
                //parse systemList API response
                systemListAPI sysAPIRes = (systemListAPI)JSON.deserialize(response, systemListAPI.class);
                
                if(sysAPIRes.ReturnCode == 0){
                    //logic to build the output wrapper for station type - FCS, SCS, CGW
                    if(stationType == 'FCS' || stationType == 'SCS' || stationType == 'CGW'){
                        
                        statDataWrap.statModCode = statModCode;
                        
                        //Assigning columns based product sub type 
                        List<String> colDet = new List<String>{Label.YG_Module,Label.YG_Qty,Label.YG_Sys_Maintenance_phase,Label.YG_Phase_ending_in};
                            statDataWrap.colDet = colDet;
                        
                        //get the api response details
                        List<Modules> moduleList = sysAPIRes.Data.Modules;
                        List<IOModules> iomoduleList = sysAPIRes.Data.IOModules;
                        system.debug('iomoduleList::'+iomoduleList);
                        Map<String, Integer> moduleCountMap = new Map<String, Integer>(); //map to store the module and qty
                        Map<String, String> moduleRevNoMap = new Map<String, String>(); //map to store the module and revision no
                        
                        //logic the populate the moduleCountMap
                        if(moduleList != null && moduleList.size()>0){
                            for(Modules mod: moduleList){
                                moduleRevNoMap.put(mod.ModelCode,mod.RevisionNumber);
                                if(!moduleCountMap.containsKey(mod.ModelCode)){
                                    moduleCountMap.put(mod.ModelCode,1);
                                }else{
                                    integer i = moduleCountMap.get(mod.ModelCode);
                                    moduleCountMap.put(mod.ModelCode,i+1);
                                }
                            }
                        }
                        if(iomoduleList != null && iomoduleList.size()>0){
                            for(IOModules iomod: iomoduleList){
                                moduleRevNoMap.put(iomod.ModelCode,iomod.RevisionNumber);
                                if(!moduleCountMap.containsKey(iomod.ModelCode)){
                                    moduleCountMap.put(iomod.ModelCode,1);
                                }else{
                                    integer j = moduleCountMap.get(iomod.ModelCode);
                                    moduleCountMap.put(iomod.ModelCode,j+1);
                                }
                            }
                        }
                        
                        //logic to build station details wrapper
                        if(moduleCountMap != null && moduleCountMap.keySet().size()>0){
                            system.debug('moduleCountMap::'+moduleCountMap);
                            
                            //get the maintenance phase details based on model code
                            List<Maintenance_Phase__c> maintenancePhaseList = [SELECT Id,Product__c,Product__r.Category__r.Name,Sales_Phase_Start_Date__c,Sales_Phase_End_Date__c,Maintenance_Phase1_End_Date__c,Maintenance_Phase1_Start_Date__c,
                                                                               Maintenance_Phase2_End_Date__c,Maintenance_Phase2_Start_Date__c,Ext_Maintenance_End_Date__c,Ext_Maintenance_Start_Date__c,Item__c,Sub_Item__c,
                                                                               Product__r.Model_Code__c FROM Maintenance_Phase__c WHERE Product__r.Model_Code__c = :moduleCountMap.keySet()];
                            system.debug('maintenancePhaseList::'+maintenancePhaseList);
                            
                            for(String mod: moduleCountMap.keySet()){
                                stationData statData = new stationData();
                                statData.column1 = mod;
                                statData.column2 = String.valueOf(moduleCountMap.get(mod));
                                for(Maintenance_Phase__c mtnPhase: maintenancePhaseList){
                                    if(mtnPhase.Product__r.Category__r.Name == 'Hardware' && mtnPhase.Product__r.Model_Code__c == mod){
                                        YG_SystemsController.productPhase prodPhase = YG_SystemsController.getPhaseDetails(mtnPhase);
                                        if(prodPhase.prodMtnPhase != '-'){
                                            statData.column3 = mtnPhase.Product__r.Category__r.Name+' '+prodPhase.prodMtnPhase;
                                        }
                                        String str = prodPhase.phaseEndingIn;
                                        if(str.contains('_') && str != 'Invalid'){
                                            statData.column4 = str.replace('_',' ');	
                                        }else{
                                            statData.column4 = '-';
                                        }
                                        statData.column5 = prodPhase.colorClassName;
                                    }
                                    if(mtnPhase.Product__r.Category__r.Name == 'Software' && mtnPhase.Product__r.Model_Code__c == mod && mtnPhase.Sub_Item__c == moduleRevNoMap.get(mod) && mtnPhase.Sub_Item__c != ''){
                                        YG_SystemsController.productPhase prodPhase = YG_SystemsController.getPhaseDetails(mtnPhase);
                                        if(prodPhase.prodMtnPhase != '-'){
                                            statData.column3 = mtnPhase.Product__r.Category__r.Name+' '+prodPhase.prodMtnPhase;
                                        }
                                        String str = prodPhase.phaseEndingIn;
                                        if(str.contains('_') && str != 'Invalid'){
                                            statData.column4 = str.replace('_',' ');	
                                        }else{
                                            statData.column4 = '-';
                                        }
                                        statData.column5 = prodPhase.colorClassName;
                                    }
                                }
                                statDataList.add(statData);
                            }
                        }
                        statDataWrap.statModData = statDataList;
                    }
                    
                    //logic to build the output wrapper for station type - HIS
                    if(stationType == 'HIS'){
                        
                        //Assigning columns based product sub type 
                        List<String> colDet = new List<String>{Label.YG_Software_package_name,Label.YG_Sys_Description};
                            statDataWrap.colDet = colDet;
                        
                        string phase = '';
                        //get the maintenace phase of OS
                        if(sysAPIRes.Data.OperatingSystem != '' && sysAPIRes.Data.ServicePack != ''){
                            List<Maintenance_Phase__c> mtnPhase = [Select Ext_Maintenance_End_Date__c,Ext_Maintenance_Start_Date__c,Maintenance_Phase1_End_Date__c,
                                                                   Maintenance_Phase1_Start_Date__c,Maintenance_Phase2_End_Date__c,Maintenance_Phase2_Start_Date__c,
                                                                   Sales_Phase_End_Date__c,Sales_Phase_Start_Date__c,Product__c,Product__r.Model_Code__c,Item__c,Sub_Item__c 
                                                                   From Maintenance_Phase__c Where Item__c =: sysAPIRes.Data.OperatingSystem AND Sub_Item__c =: sysAPIRes.Data.ServicePack 
                                                                   Order by LastModifiedDate Desc Limit 1];
                            
                            if(mtnPhase.size()>0){
                                YG_SystemsController.productPhase prodPhase = YG_SystemsController.getPhaseDetails(mtnPhase[0]);
                                phase = prodPhase.prodMtnPhase;
                            }  
                        }
                        
                        //get the api response details
                        statDataWrap.osName = 'OS: '+sysAPIRes.Data.OperatingSystem+' ('+phase+')';
                        List<Packages> packages = sysAPIRes.Data.Packages;
                        
                        //logic to build station details wrapper
                        if(packages != null && packages.size() > 0){
                            for(Packages pack: packages){
                                stationData statData = new stationData();
                                statData.column1 = pack.PackageCode;
                                statData.column2 = pack.PackageDescription; 
                                statDataList.add(statData);
                            }
                        }
                        statDataWrap.statModData = statDataList;
                    }
                    
                    //logic to build the output wrapper for station type - BCV
                    if(stationType == 'BCV'){
                        statDataWrap.colDet = new List<String>();
                        statDataWrap.statModData = new List<stationData>();
                        statDataWrap.statModCode= '';
                        
                        string phase = '';
                        //get the maintenace phase of OS
                        if(sysAPIRes.Data.OperatingSystem != '' && sysAPIRes.Data.ServicePack != ''){
                            List<Maintenance_Phase__c> mtnPhase = [Select Ext_Maintenance_End_Date__c,Ext_Maintenance_Start_Date__c,Maintenance_Phase1_End_Date__c,
                                                                   Maintenance_Phase1_Start_Date__c,Maintenance_Phase2_End_Date__c,Maintenance_Phase2_Start_Date__c,
                                                                   Sales_Phase_End_Date__c,Sales_Phase_Start_Date__c,Product__c,Product__r.Model_Code__c,Item__c,Sub_Item__c 
                                                                   From Maintenance_Phase__c Where Item__c =: sysAPIRes.Data.OperatingSystem AND Sub_Item__c =: sysAPIRes.Data.ServicePack 
                                                                   Order by LastModifiedDate Desc Limit 1];
                            
                            if(mtnPhase.size()>0){
                                YG_SystemsController.productPhase prodPhase = YG_SystemsController.getPhaseDetails(mtnPhase[0]);
                                phase = prodPhase.prodMtnPhase;
                            }
                        }
                        
                        statDataWrap.osName = 'OS: '+sysAPIRes.Data.OperatingSystem+' ('+phase+')';
                    }
                }
            }
        }
        catch(Exception e){
            YG_Utility.logError('HomePage','Backend Process Error',e.getStackTraceString(),
                                'Class:YG_SystemsAPI; Method: getStationListDetails(); Line #:'+e.getLineNumber()+'; Message:'+e.getMessage(),
                                UserInfo.getUserId());
        }
        system.debug('statDataWrap::'+statDataWrap);
        return statDataWrap;
    }
    
    //Wrapper to store the station and station details api response
    public class systemListAPI{
        @AuraEnabled public Data Data;
        @AuraEnabled public Integer ReturnCode;
    }
    
    public class Data{
        //Variable related to project and asset obj - Station Api
        @AuraEnabled public string SystemID;
        @AuraEnabled public string ProductName;
        @AuraEnabled public string RevInfGenerationDate;
        @AuraEnabled public List<Stations> Stations;
        
        //Variable related Station details Api
        @AuraEnabled public List<Modules> Modules; //Station Type - FCS, SCS, CGW
        @AuraEnabled public List<IOModules> IOModules; //Station Type - FCS, SCS, CGW
        @AuraEnabled public List<Packages> Packages; //Station Type - HIS
        @AuraEnabled public string OperatingSystem; //Station Type - HIS, BCV
        @AuraEnabled public string ServicePack; //Station Type - HIS, BCV
    }
    
    public class Stations{
        //Variable related to asset obj - Station Api
        @AuraEnabled public string StationType;
        @AuraEnabled public string VnetDomainNumber;
        @AuraEnabled public string VnetStationNumber;
        @AuraEnabled public string StationOrAlias;
        @AuraEnabled public string ModelCode;
        @AuraEnabled public string RevisionNumber;
        @AuraEnabled public string ProductName;
    }
    
    //Wrapper related Station details Api
    public class Modules{
        @AuraEnabled public string ModelCode;
        @AuraEnabled public string RevisionNumber;
    }
    
    //Wrapper related Station details Api
    public class IOModules{
        @AuraEnabled public string ModelCode;
        @AuraEnabled public string RevisionNumber;
    }
    
    //Wrapper related Station details Api
    public class Packages{
        @AuraEnabled public string PackageCode;
        @AuraEnabled public string PackageDescription;
    }
    
    //Wrapper to store the parsed response of Station details Api to display in UI
    public class stationDataWrapper{
        @AuraEnabled public List<String> colDet = new List<String>();
        @AuraEnabled public String productSubType;
        @AuraEnabled public String statModCode = '';
        @AuraEnabled public List<stationData> statModData = new List<stationData>();
        @AuraEnabled public String osName = ''; //for HIS & BCV only
    }
    
    public class stationData{
        @AuraEnabled public String column1 = '-'; //model code
        @AuraEnabled public String column2 = '-'; //qty
        @AuraEnabled public String column3 = '-'; //maintenance phase
        @AuraEnabled public String column4 = '-'; //phase ending in
        @AuraEnabled public String column5 = '-'; //color class - css
	}
}