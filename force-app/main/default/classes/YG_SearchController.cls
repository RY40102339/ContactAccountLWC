/*
*******************************************************************************************************
* (C) Copyright 2020 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Selvaraj T
* @version 1.0
* @created 14/05/2020
* @description 
* This class is used to return the data based on the user search filter criteria.
*
* @test class name - YG_SearchControllerTest
*
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  06/18/2020			Chitrakishore			Modified code for search based on plant Id.
*  07/21/2020			Vinod A					Modified code for search based on the product categories in the allproducts page
*  07/24/2020			Selvaraj T				Modified code for search based on station name and model code in the allsystems page
*  09/14/2020			Jayaprasath				Modified code for search based on Contact Id for manage colleague page
*  09/23/2020			Jayaprasath				Modified code with empty condtion for manage colleague page
*  07/24/2020			Selvaraj T				Added code for search in Software License page
*  10/22/2020			Jayaprasath				Modified code for search under product-detail page
*  10/22/2020			Selvaraj T				Modified code for searching stations and model based on project code 
*/

public class YG_SearchController {
    
    public static User userInformation =  YG_Utility.getLoggedInUserInfo(UserInfo.getUserId());
    /**
     *  This method is for getting the details from the sObject based on the search key word provided in the search filter, 
     *  page name, category name and model code.  
     **/ 
    
    @AuraEnabled
    public static List<sObject> getLookUpValues(String searchKeyWord, List<sObject> excludedRec, String pageName, 
                                                String catName,String modelCode,String lang,String plantCode, String projectCode){
        
        system.debug('excludedRec::'+excludedRec);
        system.debug('pageName::'+pageName);
        system.debug('catName::'+catName);
        system.debug('lang::'+lang);
        system.debug('projectCode::'+projectCode);
        system.debug('plantCode::'+plantCode);
        system.debug('userInformation::'+userInformation);
                                                    
                                                    
        String searchKey = '%' + searchKeyWord + '%';
        system.debug('searchKey::'+searchKey);
             
        //Convert to string to List                                            
        if(projectCode != ''){
            List<String> projCodeList = projectCode.split(' / ');
            system.debug('projCodeList::'+projCodeList);
        }                                            
                                                    
        //String langCode = lang;
        String proType = 'Hardware';
        String langCode = YG_CommonUtils.getLanguageCode(userInformation.LanguageLocaleKey);
        Id accountId = userInformation.Contact.AccountId; 
        /*if(null == langCode){
            langCode = 'EN';                           
        } */                                           
                                                    
        List<sObject> returnList = new List <sObject>();
        List<string> lstExcludeitems = new List<string>(); //List to store the exclude the records which is already filtered.
        List<string> lstExcludeitemsName = new List<string>();       
                                                    
        for(sObject item : excludedRec ){
            lstExcludeitems.add(item.id);
        }
                                                    
        for(sObject item : excludedRec ){
            
            String sObjName = item.id.getSObjectType().getDescribe().getName();
            
            if(sObjName == 'Asset'){
                Asset a = (Asset)item;
                lstExcludeitemsName.add(a.Name);
            }
            if(sObjName == 'Product2'){
                Product2 a = (Product2)item;
                lstExcludeitemsName.add(a.Name);
            }
        }      
                                                    
        List<String> prodType = new List<String>{'Hardware','Software'};
        List<String> stype = new List<String>{'FCS','HIS','BCV','CGW','SCS'};
            
        try{
            List<Id> assetIds=new List<Id>();
            String plantId = '';
            if(pageName == 'manage-colleagues'){
               system.debug('in'); 
            }
            else if(pageName != 'all-products' && pageName != 'product-details' && pageName != 'allservicerequest'){
            Plant__c plantObj = YG_HelperClass.getPlantID(plantCode,lang);
            plantId = plantObj.Id;
            System.debug('plantId::'+plantId);
            }
            else{
                Id contactId = userInformation.Contact.ID;  
                assetIds =  YG_HelperClass.getCustomerAssets(contactId);
                 System.debug('assetIds::'+assetIds);
                System.debug('assetIds.size()::'+assetIds.size());
            }
            
            //get filtered data for all products page
            if(pageName == 'all-products' && catName == null){
                
                String sQuery = 'Select Product2.Id, Product2.Name from Asset where Product2.Name LIKE : searchKey AND Product2.Product_type__c =null '+ 
                    ' AND Id IN:assetIds AND Lang_Code__c=:langCode AND Product2.Id NOT IN :lstExcludeitems GROUP BY Product2.Id, Product2.Name';
                List<sObject> lstOfRecords = Database.query(sQuery);
                
                for (sObject obj: lstOfRecords) {
                    returnList.add(obj);
                }
                
                String sQuery1 = 'Select Product2.Id, Product2.Model_Code__c from Asset where Product2.Model_Code__c LIKE : searchKey AND Product2.Product_type__c =null '+ 
                    ' AND Id IN:assetIds AND Lang_Code__c=:langCode AND Product2.Id NOT IN :lstExcludeitems GROUP BY Product2.Id, Product2.Model_Code__c';
                List<sObject> lstOfRecords1 = Database.query(sQuery1);
                
                for (sObject obj: lstOfRecords1) {
                    returnList.add(obj);
                }
                
                //Query to filter the product categories.
                List<Asset> assetList= [Select Product2.Id, Product2.Product_Categories__c from Asset where Product2.Product_Categories__c LIKE : searchKey AND Product2.Product_type__c =null 
                    AND Id IN:assetIds AND Lang_Code__c=:langCode AND Product2.Id NOT IN :lstExcludeitems];
                
                //To remove the duplicate assets
                Map<Id, sObject> lstOfProdCatRecordMap = new Map<Id, sObject>();
                for(Asset asset:assetList){
                    if(! lstOfProdCatRecordMap.containsKey(asset.Product2.Id) ){
                      sObject sObj = asset;
                      lstOfProdCatRecordMap.put(asset.Product2.Id, sObj) ;
                    }
				}
                //Return the prodcategories list
                List<sObject> lstOfProdCatRecords =  new List<sObject>();
                lstOfProdCatRecords.addAll(lstOfProdCatRecordMap.values());//Database.query(sQueryModel);
                System.debug('lstOfProdCatRecords::'+lstOfProdCatRecords);
                    returnList.addAll(lstOfProdCatRecords);
            }
            
            //get filtered data for field instruments page
            if(pageName == 'all-products' && catName != null){
                
                if(catName != null){
                    String topCatName = catName.replace('+', ' ');
                    system.debug('topCatName::'+topCatName);
                    String topCatCode = [Select Name,Category_Hierarchy__r.Category_Code__c FROM Category__c
                                         WHERE Name = :topCatName AND Language_Code__c = :langCode].Category_Hierarchy__r.Category_Code__c;
                    
                    String sQuery = 'Select Product2.Id, Product2.Name from Asset where Product2.Name LIKE : searchKey AND Product2.Top_Category__c= :topCatCode '+
                        			' AND Product2.Product_type__c =null AND Id IN:assetIds AND Lang_Code__c=:langCode AND Product2.Id NOT IN :lstExcludeitems GROUP BY Product2.Id,Product2.Name';
                    
                    List<sObject> lstOfRecords = Database.query(sQuery);
                    for (sObject obj: lstOfRecords) {
                        returnList.add(obj);
                    }
                    
                    String sQuery1 = 'Select Product2.Id, Product2.Model_Code__c from Asset where Product2.Model_Code__c LIKE : searchKey AND Product2.Top_Category__c= :topCatCode AND Product2.Product_type__c =null'+ 
                        ' AND Id IN:assetIds AND Lang_Code__c=:langCode AND Product2.Id NOT IN :lstExcludeitems GROUP BY Product2.Id, Product2.Model_Code__c';
                    List<sObject> lstOfRecords1 = Database.query(sQuery1);
                    
                    for (sObject obj: lstOfRecords1) {
                        returnList.add(obj);
                    }
                    
                    //Query to filter the product categories.
                    List<Asset> assetList= [Select Product2.Id, Product2.Product_Categories__c from Asset where Product2.Product_Categories__c LIKE : searchKey AND Product2.Top_Category__c= :topCatCode
                                            AND Product2.Product_type__c =null AND Id IN:assetIds AND Lang_Code__c=:langCode AND Product2.Id NOT IN :lstExcludeitems];
                    
                    //To remove the duplicate assets
                    Map<Id, sObject> lstOfProdCatRecordMap = new Map<Id, sObject>();
                    for(Asset asset:assetList){
                        if(! lstOfProdCatRecordMap.containsKey(asset.Product2.Id) ){
                            sObject sObj = asset;
                            lstOfProdCatRecordMap.put(asset.Product2.Id, sObj) ;
                        }
                    }
                    //Return the prodcategories list
                    List<sObject> lstOfProdCatRecords =  new List<sObject>();
                    lstOfProdCatRecords.addAll(lstOfProdCatRecordMap.values());//Database.query(sQueryModel);
                    System.debug('lstOfProdCatRecords::'+lstOfProdCatRecords);
                    returnList.addAll(lstOfProdCatRecords);
                }
            }
            
            
            //get filtered data for the all-contracts page
             if(pageName == 'all-contracts'){
                 List<Id> contractIdList=new List<Id>();
                 //To get the service contact Id assests
                 ID contactId = userInformation.Contact.ID;  
                 List<Id> assetIdsCont =  YG_HelperClass.getCustomerAssets(contactId);
                 system.debug('*******Customer assetIds::'+assetIds);
                 //to get the service contract Name
                 contractIdList = YG_HelperClass.getServiceContracts(plantCode, assetIdsCont);
                 System.debug('contractIdList::'+contractIdList);
                 
                 List<Id> servContWithoutSop = YG_AllServiceContractsController.getServContWithoutSOP(accountId);
                 System.debug('servContWithoutSop::'+servContWithoutSop);
                 for(Id servId : servContWithoutSop){
                     if(!contractIdList.contains(servId)){
                         contractIdList.add(servId);
                     }
                 }
                 
                String queryContract = 'Select Id,Name from ServiceContract where Name LIKE : searchKey'+
									' AND Id IN: contractIdList AND Id NOT IN :lstExcludeitems';
                List<sObject> lstOfContRecords = Database.query(queryContract);
                for (sObject obj: lstOfContRecords) {
                        returnList.add(obj);
                    }
                 
                 //This to get the contract no
                 String queryContractNo = 'Select Id,Contract_No__c from ServiceContract where Contract_No__c LIKE : searchKey'+
									' AND Id IN: contractIdList AND Id NOT IN :lstExcludeitems';
                List<sObject> lstOfContRecords1 = Database.query(queryContractNo);
                for (sObject obj1: lstOfContRecords1) {
                        returnList.add(obj1);
                    }
                 
					System.debug('returnList::'+returnList);
            }   
            
            //get filtered data for all service request page
            if(pageName == 'allservicerequest'){
                
                Id contId = userInformation.Contact.ID;  
                Id accId = userInformation.Contact.AccountId;
                
                List<String> excludeCaseRec = new List<String>();
                if(lstExcludeitems.size()>0){
                    List<case> cseRec = [Select toLabel(service_you_require__c), Reason, Product.Name, Asset.Product2.Name 
                                         from Case where Id IN :lstExcludeitems];
                    
                    for(case cse: cseRec){
                        if(!excludeCaseRec.contains(cse.service_you_require__c)){
                            excludeCaseRec.add(cse.service_you_require__c);
                        }
                        if(!excludeCaseRec.contains(cse.Reason)){
                            excludeCaseRec.add(cse.Reason);
                        }
                        if(!excludeCaseRec.contains(cse.Product.Name)){
                            excludeCaseRec.add(cse.Product.Name);
                        }
                        if(!excludeCaseRec.contains(cse.Asset.Product2.Name)){
                            excludeCaseRec.add(cse.Asset.Product2.Name);
                        }
                    }
                    
                }
                
                System.debug('excludeCaseRec::'+excludeCaseRec);

                //Filter by service type
                String sQuery = 'Select Id, toLabel(Service_you_require__c) servReq from case where toLabel(Service_you_require__c) LIKE : searchKey And account.id =\''+accId+'\' And toLabel(Service_you_require__c) NOT IN : excludeCaseRec GROUP BY Id, Service_you_require__c';
                List<sObject> lstOfRecords = Database.query(sQuery);
                system.debug('lstOfRecords::'+lstOfRecords);
                Set<String> caseServReq = new Set<String>();
                for (sObject obj: lstOfRecords) {
                    String serv = (string)obj.get('servReq');
                    if(!caseServReq.contains(serv)){
                        caseServReq.add(serv);
                        sObject sobj = new Case();
                        sobj.id = obj.Id;
                        sobj.put(Schema.Case.Service_you_require__c, serv);
                        returnList.add(sobj);
                    }
                }
                
                //Filter by case reason for Inquires menu
                String caseQuery = 'Select Id, Reason from case where Reason LIKE : searchKey And account.id =\''+accId+'\' And Reason NOT IN : excludeCaseRec GROUP BY Id,Reason';
				List<sObject> lstOfCaseReasonRecords = Database.query(caseQuery);
                system.debug('lstOfCaseReasonRecords::'+lstOfCaseReasonRecords);
				Set<String> caseReason = new Set<String>();
                for (sObject obj: lstOfCaseReasonRecords) {
                    AggregateResult a = (AggregateResult)obj;
                    if(!caseReason.contains((string)a.get('Reason'))){
                        caseReason.add((string)a.get('Reason'));
                        returnList.add(obj);
                    }
                }
                
                //Filter by product
                String productQuery = 'Select Id, Product.Name from case where Product.Name LIKE : searchKey And account.id =\''+accId+'\' And Product.Name NOT IN : excludeCaseRec GROUP BY Id, Product.Name';
                List<sObject> lstOfCaseProdRecords = Database.query(productQuery);
                system.debug('lstOfCaseProdRecords::'+lstOfCaseProdRecords);
                Set<String> caseProdName = new Set<String>();
                for (sObject obj: lstOfCaseProdRecords) {
                    AggregateResult a = (AggregateResult)obj;
                    if(!caseProdName.contains((string)a.get('Name'))){
                        caseProdName.add((string)a.get('Name'));
                        returnList.add(obj);
                    }
                }
                
                //Filter by Asset product
                String assetProdQuery = 'Select Id, Asset.Product2.Name from case where Asset.Product2.Name LIKE : searchKey And account.id =\''+accId+'\' And Asset.Product2.Name NOT IN : excludeCaseRec GROUP BY Id, Asset.Product2.Name';
                List<sObject> lstOfasstProdRecords = Database.query(assetProdQuery);
                system.debug('lstOfasstProdRecords::'+lstOfasstProdRecords);
                for (sObject obj: lstOfasstProdRecords) {
                    AggregateResult a = (AggregateResult)obj;
                    if(!caseProdName.contains((string)a.get('Name'))){
                        caseProdName.add((string)a.get('Name'));
                        returnList.add(obj);
                    }
                }
                
            }
            
            //get filtered data for all systems page
            if(pageName == 'all-systems'){
                
                String sQueryStat = 'Select Id,Name from Asset where Name LIKE : searchKey AND Product2.Category__r.Category_Type__c = \'System\' AND Station_Type__c =:stype '+
									' AND Plant__r.Id=\''+plantId+'\' AND Project__r.Project_Code__c IN :projCodeList AND Lang_Code__c=:langCode AND Name NOT IN :lstExcludeitemsName';
                List<sObject> lstOfStatRecords = Database.query(sQueryStat);
                Set<String> statName = new Set<String>();
                
                system.debug('lstOfStatRecords::'+lstOfStatRecords);
                
                for (sObject obj: lstOfStatRecords) {
                    Asset a = (Asset)obj;
                    if(!statName.contains(a.Name)){
                        statName.add(a.Name);
                        returnList.add(obj);
                    }
                }
                
                String sQueryModel =  'Select Product2.Id,Product2.Model_Code__c from Asset where Product2.Model_Code__c LIKE : searchKey AND Station_Type__c =:stype '+
									 ' AND Plant__r.Id=\''+plantId+'\' AND Project__r.Project_Code__c IN :projCodeList AND Lang_Code__c=:langCode AND Product2.Model_Code__c NOT IN :lstExcludeitemsName GROUP BY Product2.Id,Product2.Model_Code__c';
                List<sObject> lstOfModelRecords = Database.query(sQueryModel);
                Set<String> modCode = new Set<String>();
                
                for (sObject obj: lstOfModelRecords) {
                    AggregateResult a = (AggregateResult)obj;
                    system.debug('a:::'+(string)a.get('Model_Code__c'));
                    if(!modCode.contains((string)a.get('Model_Code__c'))){
                        modCode.add((string)a.get('Model_Code__c'));
                        returnList.add(obj);
                    }
                }
            }
            
            //get filtered data for product details page
            if(pageName == 'product-details'&& catName != null){
               
                String sQuerySerial =  'Select Id, Name from Asset where Name LIKE : searchKey AND Product2.Model_Code__c = :catName '+
									   'AND Id IN:assetIds AND Lang_Code__c=:langCode AND Name NOT IN :lstExcludeitemsName';
                
                List<sObject> lstOfSerialRecords = Database.query(sQuerySerial);
                Set<String> Serial = new Set<String>();
                system.debug('lstOfSerialRecords::'+lstOfSerialRecords);
                
                for (sObject obj: lstOfSerialRecords) {
                    Asset a = (Asset)obj;
                    if(!Serial.contains(a.Name)){
                        Serial.add(a.Name);
                        returnList.add(obj);
                    }
                }
                
                 String sQueryMscode = 'Select Id, MS_Code__c from Asset where MS_Code__c LIKE : searchKey AND Product2.Model_Code__c = :catName '+
									   'AND Id IN:assetIds AND Lang_Code__c=:langCode AND MS_Code__c NOT IN :lstExcludeitemsName GROUP BY Id,MS_Code__c';
  				
                List<sObject> lstOfMscodeRecords = Database.query(sQueryMscode);
                Set<String> Mscode = new Set<String>();
                system.debug('lstOfMscodeRecords::'+lstOfMscodeRecords);
                
                for (sObject obj: lstOfMscodeRecords) {
                    AggregateResult a = (AggregateResult)obj;
                    system.debug('a:::'+(string)a.get('MS_Code__c'));
                    if(!Mscode.contains((string)a.get('MS_Code__c'))){
                        Mscode.add((string)a.get('MS_Code__c'));
                        returnList.add(obj);
                    }
                }
            }
            
            //get filtered data for station details page
            if(pageName == 'station-details' && projectCode != ''){
                //String sQuery =  'Select Id, Name from Asset where Name LIKE: searchKey AND Parent.Name = :catName AND Id NOT IN :lstExcludeitems';
                
                String sQuery =  'Select Id, Name from Asset where Name LIKE : searchKey AND Project__r.Project_Code__c = :projectCode AND Parent.Name = :catName '+
								 ' AND Plant__r.Id=\''+plantId+'\' AND Lang_Code__c=:langCode AND Id NOT IN :lstExcludeitems';
                List<sObject> lstOfRecords = Database.query(sQuery);
                for (sObject obj: lstOfRecords) {
                    returnList.add(obj);
                }
            }
			
 			//get filtered data for manage colleagues page
            if(pageName == 'manage-colleagues'){
                system.debug('lstExcludeitems::'+lstExcludeitems);
                Id accId = userInformation.Contact.AccountId;
                Id conId = userInformation.Contact.Id;
                Boolean status = true;//if contact status is true
				String sQuery = 'Select Id, Name, Status__c from Contact where Name LIKE : searchKey AND Status__c =: status AND AccountId =: accId AND id !=: conId AND Id NOT IN :lstExcludeitems';
            
                List<sObject> lstOfRecords = Database.query(sQuery);
                for (sObject obj: lstOfRecords) {
                    returnList.add(obj);
                }
            }		            
            
            
            //get filtered data for software licenses page
            if(pageName == 'software-licenses'){
                String sQuery =  'Select product2.Id,product2.Name from Asset where product2.Name LIKE : searchKey '+
								 ' AND Lang_Code__c=:langCode AND Plant__r.Id=\''+plantId+'\' AND Product2.Category__r.Name = \'Software\' AND '+
                    			 'product2.Id NOT IN :lstExcludeitems GROUP BY Product2.Id, Product2.Name';
                List<sObject> lstOfRecords = Database.query(sQuery);
                for (sObject obj: lstOfRecords) {
                    returnList.add(obj);
                }
            }
                   
            
        }catch(Exception e){
            system.debug('Exception Cause::'+e.getCause());
            system.debug('Exception LineNumber::'+e.getLineNumber());
            system.debug('Exception Message::'+e.getMessage());
            system.debug('Exception StackTrace::'+e.getStackTraceString());
            system.debug('Exception TypeName::'+e.getTypeName()); 
            YG_Utility.logError('SearchFilter','Community Component Error',e.getStackTraceString(),
                               'Class:YG_SearchController; Method: getLookUpValues(); Line #:'+e.getLineNumber()+'; Message:'+e.getMessage(),
                               UserInfo.getUserId());
        }
        system.debug('returnList::'+returnList);
        return returnList;
    }
    
}