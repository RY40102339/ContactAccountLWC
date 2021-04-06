/*
*******************************************************************************************************
* (C) Copyright 2020 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Chitrakishore
* @version 1.0
* @created 13/07/2020
* @description 
* This class is used to write the methods for API related call.
*
* @test class name - YG_ProductRegistrationControllerTest
*
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  08/26/2020           Jayaprasath             Modified code for displaying grid and deletion on API Response obj.
*  09/04/2020			Selvaraj T				Modified the field assignment shipping date to production date using product registration.
*  09/24/2020 			Jayaprasath				Removed plant and updated customer Asset
*/

public class YG_ProductRegistrationController {
    
    public static User userInformation =  YG_Utility.getLoggedInUserInfo(UserInfo.getUserId());
    /**
* This method is for searching the searial number through API call.
*
**/  
    @AuraEnabled
    public static SerialNumSearchWrapper searchSerialNumber(String serialNumber) {                 
        
        SerialNumSearchWrapper searchWrapper = new SerialNumSearchWrapper();
        System.debug('Inside YG_ProductRegistrationController  ::: callRestWS ::: serialNumber :::'+serialNumber);        
        String serialno = serialNumber;
        String languageId = YG_CommonUtils.getLanguageCode(userInformation.LanguageLocaleKey);
        Id conId = userInformation.Contact.Id;   
        
        //Boolean serialNumberExist=false;
        List<SearchResult> responseList = new List<SearchResult>();
        
        List<assetGrid> assetWapList=new List<assetGrid>();
        searchWrapper.success = true;
        try {
            List<Asset> assetList = YG_HelperClass.getAssetBySerialNumber(serialno, languageId);        
            //Asset asset =null;
            System.debug('assetList  '+ assetList.size());
            YG_ProductAPIHandler.ShippingAPIResponseWrapper shipWrapper =null;
            if(assetList.size()== 0) {
                
                System.debug('Inside IF >>>>>>');
                YG_ProductAPIHandler.SearchSerialNumWrapper searchSerialNumResult = 
                    YG_ProductAPIHandler.searchSerialNoCallout(serialno, languageId);
                
                System.debug('searchSerialNumResult ::: '+searchSerialNumResult);
                
                searchWrapper.success = searchSerialNumResult.success;
                searchWrapper.errorCode = searchSerialNumResult.errorCode;
                
                //List<Asset_API_Response__c>  assetResponse = new List<Asset_API_Response__c>();
                
                if (searchSerialNumResult.success) { 
                    System.debug('Inside If ::: searchSerialNumResult.success');
                    shipWrapper = searchSerialNumResult.shippingAPIResponse;
                                     
                    if(null !=shipWrapper){                        
                       saveShippingResponse(shipWrapper,languageId);   
                    }
                    
                } else { 
                    searchWrapper.success=false;   
                }  
                
            }
          
            assetList = YG_HelperClass.getAssetBySerialNumber(serialno, languageId);
            system.debug('assetList'+assetList);
            if(assetList != null && assetList.size()>0){
                
                searchWrapper.serialNumberExist = true;
            	Asset asset = assetList.get(0);
                system.debug('asset****'+asset);
                List<Serial_Number_Search_Result__c> searchedAsset
                    = [Select Contact__c, Asset__c
                    from Serial_Number_Search_Result__c where Asset__r.SerialNumber =: asset.SerialNumber and 
                      Contact__r.id=: conId];
			system.debug('searchedAsset'+searchedAsset);                
               
                if(null == searchedAsset || searchedAsset.size() == 0 || searchedAsset.isEmpty()) {
                    system.debug('IN');                
                    system.debug('IN--asset.id'+asset.id);                
                    Serial_Number_Search_Result__c searchResult = new Serial_Number_Search_Result__c();
                    searchResult.Asset__c = asset.id;
                    searchResult.Contact__c = conId;
                    insert searchResult;
                    system.debug('searchResult Insert'+searchResult);
                }        
            }
            
            List<Customer_Asset__c> custAssets = [Select Contact__c, Asset__c, Asset__r.SerialNumber from Customer_Asset__c where Contact__c =: conId and Asset__r.SerialNumber =: serialno];
            List<Serial_Number_Search_Result__c> searchResults 
                    = [Select Contact__c, Asset__c, Asset__r.SerialNumber, Asset__r.Product2.Name, Asset__r.MS_Code__c, Asset__r.Production_Date__c, Asset__r.Product2.Model_Code__c from Serial_Number_Search_Result__c where Contact__c =: conId and Asset__r.SerialNumber =: serialno];
            system.debug('searchResults'+searchResults);
            system.debug('custAssets'+custAssets);
            for(Serial_Number_Search_Result__c searchResult : searchResults) {
                
                AssetGrid assetGridData = new AssetGrid();
                Asset cAsset = searchResult.Asset__r;
                    if(null != custAssets && custAssets.size() > 0) {
                        for(Customer_Asset__c custAsset: custAssets){ 
                            system.debug('cAsset.SerialNumber'+cAsset.SerialNumber);
                            system.debug('custAsset.Asset__r.SerialNumber'+custAsset.Asset__r.SerialNumber);
                            if(cAsset.SerialNumber == custAsset.Asset__r.SerialNumber){  
                                system.debug('flag1');
                                assetGridData.flag = Label.YG_Serial_number + ' ' + cAsset.SerialNumber + ' ' + Label.YG_Product_Reg_Msg2;
                            }
                        }
                    }
                assetGridData.serialNumber = cAsset.SerialNumber;
                if(cAsset.Product2.Name == null){
                    assetGridData.productName = '-'; 
                }
                else{
                	assetGridData.productName = cAsset.Product2.Name;     
                }
                if(cAsset.MS_Code__c == null){
                    assetGridData.msCode = '-';
                }
                else{
                    assetGridData.msCode = cAsset.MS_Code__c;                    
                }               
                assetGridData.productionDate = cAsset.Production_Date__c;                     
                searchWrapper.modelCode = cAsset.Product2.Model_Code__c;
                assetWapList.add(assetGridData);
            }
            searchWrapper.assetGridList = assetWapList;
            system.debug('assetWapList'+assetWapList);
             
        
        } catch(Exception e){
            system.debug('Exception Cause::'+e.getCause());
            system.debug('Exception LineNumber::'+e.getLineNumber());
            system.debug('Exception Message::'+e.getMessage());
            system.debug('Exception StackTrace::'+e.getStackTraceString());
            system.debug('Exception TypeName::'+e.getTypeName());
            YG_Utility.logError('API','Community Component Error',e.getStackTraceString(),
                                'Class:v; Method: searchSerialNumber(); Line #:'
                                +e.getLineNumber()+'; Message:'+e.getMessage(),
                                UserInfo.getUserId());
        }    
        //system.debug('serialNumberExist ::: '+serialNumberExist);
        system.debug('searchWrapper ::: '+searchWrapper);
        return searchWrapper;
    }
    
    private static Asset populateAsset(YG_ProductAPIHandler.ShippingAPIResponseWrapper shipWrapper, String languageId){
        Asset asset = new Asset();
        asset.Name = shipWrapper.serialNo;
        asset.MS_Code__c = shipWrapper.msCode;
        asset.SerialNumber = shipWrapper.serialNo;
        asset.Lang_Code__c = languageId;
        asset.Tokuchu_no__c = shipWrapper.tokuchuNo;
        asset.Xj_no__c = shipWrapper.xJNo;     
        asset.Product_Carrier__c = shipWrapper.productCareer; 
        asset.Production_Date__c = YG_CommonUtils.convertStringToDate(shipWrapper.productionDate);
        Product2 prodObj = YG_HelperClass.getProductDetails(shipWrapper.modelCode, languageId);
        system.debug('prodObj ::: '+prodObj);
        if(null !=prodObj)
        	asset.Product2Id = prodObj.Id;
        return asset;
    }
    
    public static void saveShippingResponse(YG_ProductAPIHandler.ShippingAPIResponseWrapper searchedSerialRes, 
     	String languageId){
            
            System.debug('Inside processCombiProducts');
            System.debug('searchedSerialRes ::: '+searchedSerialRes);
            System.debug('languageId ::: '+languageId);            
            
            List<YG_ProductAPIHandler.ShippingAPIResponseWrapper> combiChildList 
                = new List<YG_ProductAPIHandler.ShippingAPIResponseWrapper> ();
            
            YG_ProductAPIHandler.ShippingAPIResponseWrapper combiParent = null;
                   
            List<Asset> childAssets = new List<Asset>();      
            List<YG_ProductAPIHandler.CombiProd> combiProducts = searchedSerialRes.combiProd;
            
            // if there is combination products, call shipping API for each serial number
            for(YG_ProductAPIHandler.CombiProd combiObj : combiProducts){
                
              	YG_ProductAPIHandler.ShippingAPIResponseWrapper shippinResponse = null; 
                
                if(searchedSerialRes.SerialNo.equals(combiObj.SerialNo)){
                     shippinResponse = searchedSerialRes;
                }
                else {
                    YG_ProductAPIHandler.SearchSerialNumWrapper searchSerialNumResult = YG_ProductAPIHandler.searchSerialNoCallout(combiObj.SerialNo, languageId);                
                     if (searchSerialNumResult.success) {  
                         shippinResponse = searchSerialNumResult.shippingAPIResponse;
                     }
                }
                // Find out the parent and child products
                if('1'.equals(combiObj.ParentChildFlag)){
                    combiParent = shippinResponse;
                }
                else{
                    combiChildList.add(shippinResponse); 
                }
                
            }
            
            if(combiChildList.size() > 1) {
                
                Asset parentAsset = populateAsset(combiParent, languageId);
                
                for(YG_ProductAPIHandler.ShippingAPIResponseWrapper shippingAPIResponse: combiChildList){
                    
                    childAssets.add(populateAsset(shippingAPIResponse, languageId));
                      
                }
                System.debug('childAssets ::: '+childAssets); 
                // Save parent Asset
                insert parentAsset;
                
                // Set Parent Id for the child Assets
                List<Asset> childAssetsToInsert = new List<Asset>();            
                for(Asset childAsset: childAssets ){
                    childAsset.parentId =  parentAsset.Id;
                    childAssetsToInsert.add(childAsset);  
                }
                // Save child assets of combination products
           		insert childAssetsToInsert; 
                storeOrderindInstructions(parentAsset, childAssetsToInsert,  combiParent, combiChildList);
                                
            } else {
                Asset searchAsset = populateAsset(searchedSerialRes, languageId);   
                System.debug('Inside else ');
                insert searchAsset; 
                List<Product_Extension__c> orderInstListToInsert = new List<Product_Extension__c> ();
            	if(null != searchedSerialRes.orderInstSummary && searchedSerialRes.orderInstSummary.size()>1){
              		orderInstListToInsert.addAll(populateOrderingInstruction(searchAsset, searchedSerialRes.orderInstSummary));
                    insert orderInstListToInsert;
            	}
            }                      
        }
   
    public static void storeOrderindInstructions(Asset parentAsset, List<Asset> childAssets, 
    	YG_ProductAPIHandler.ShippingAPIResponseWrapper combiParent, 
        List<YG_ProductAPIHandler.ShippingAPIResponseWrapper> combiChildList){
        
            System.debug('Inside insertChildAssets');
            System.debug('parentAsset ::: '+parentAsset);
            System.debug('childAssets ::: '+childAssets);             
            
            Map<String, List<YG_ProductAPIHandler.OrderInstSummary>> serialOrderInstMap 
                = new Map <String, List<YG_ProductAPIHandler.OrderInstSummary>> ();
            
            List<Product_Extension__c> orderInstListToInsert = new List<Product_Extension__c> ();
            if(null != combiParent.orderInstSummary && combiParent.orderInstSummary.size()>1){
              	orderInstListToInsert.addAll(populateOrderingInstruction(parentAsset, combiParent.orderInstSummary));
            }
            
            for(YG_ProductAPIHandler.ShippingAPIResponseWrapper childShippingWrap : combiChildList){
                if(null != childShippingWrap.orderInstSummary && childShippingWrap.orderInstSummary.size()>1){
                    serialOrderInstMap.put(childShippingWrap.serialNo, childShippingWrap.orderInstSummary);
                }               
            }
             
            for(Asset childAsset : childAssets) {
                List<YG_ProductAPIHandler.OrderInstSummary> orderInstSummary = serialOrderInstMap.get(childAsset.SerialNumber);
                if(null != orderInstSummary){
                    orderInstListToInsert.addAll(populateOrderingInstruction(childAsset, orderInstSummary));
                }
            }
            if(orderInstListToInsert.size() >0){
                insert orderInstListToInsert;
            }
    }

    public static List<Product_Extension__c> populateOrderingInstruction(Asset relatedTo, 
        List<YG_ProductAPIHandler.OrderInstSummary> orderInstSummary ){
        
        List<Product_Extension__c> orderingInstList = new List<Product_Extension__c>();
        for(YG_ProductAPIHandler.OrderInstSummary orderInst : orderInstSummary){
       		Product_Extension__c orderingInst = new Product_Extension__c();
            orderingInst.Asset__c = relatedTo.Id; 
            orderingInst.Order_Code__c = orderInst.TitleCode;
            orderingInst.Name = orderInst.InstName;
            orderingInst.Description__c = orderInst.InstData;
            orderingInst.Type__c = 'Ordering Instructions';
            orderingInstList.add(orderingInst);
            
        }
        return orderingInstList;
    }
       
    
    public class SerialNumSearchWrapper{
        
        @AuraEnabled public boolean success;
        @AuraEnabled public string errorCode;
        @AuraEnabled public boolean serialNumberExist =false;
       // @AuraEnabled public List<SearchResult> searchResult;
        @AuraEnabled public List<AssetGrid> assetGridList;
        @AuraEnabled public String modelCode;
        
    }
    
    public class SearchResult{
        @AuraEnabled public String modelCode; 
        @AuraEnabled public String msCode;
        @AuraEnabled public String serialNumber;
        @AuraEnabled public String langCode;
        @AuraEnabled public String tokuchuNo;
        @AuraEnabled public String xJNo;     
        @AuraEnabled public String productCareer;
        @AuraEnabled public Date productionDate;
        @AuraEnabled public ID id;
    }
    
    public class AssetGrid{
        @AuraEnabled public String flag;
        @AuraEnabled public String serialNumber;
        @AuraEnabled public String productName; 
        @AuraEnabled public String msCode;
        @AuraEnabled public Date productionDate; 
    }
    
    /**
* This method is for registering the serial number in the Asset
* 
**/
    
    @AuraEnabled
    public static SerialNumRegisterWrapper registerSerialNumber(String assetToRegisterListAsStr) {
        System.debug('assetToRegisterListAsStr'+assetToRegisterListAsStr);
        List<String> assetToRegisterList = ( List<String>)JSON.deserialize(assetToRegisterListAsStr, List<String>.class);
        
        SerialNumRegisterWrapper registerWrapper = new SerialNumRegisterWrapper();
        System.debug('Inside YG_ProductRegistrationController  ::: registerSerialNumber ::: assetToRegisterList :::'+assetToRegisterList);        
        
        String languageId = YG_CommonUtils.getLanguageCode(userInformation.LanguageLocaleKey);    
        Id conId = userInformation.Contact.Id; 
        
        //Asset Name, MS Code, Lang Code
        try {
            
            List<Asset> assetList = [Select Id, SerialNumber from Asset where SerialNumber in: assetToRegisterList  and Lang_Code__c =: languageId];
            
            system.debug('assetList'+assetList);
            List<Customer_Asset__c> customerAssetList = new List<Customer_Asset__c>();            
            for(Asset asset :assetList){
                Customer_Asset__c customerAsset =new Customer_Asset__c();
                customerAsset.Asset__c = asset.Id;
                customerAsset.Contact__c = userInformation.ContactId;
                customerAssetList.add(customerAsset);
            }                                            
            insert customerAssetList; 
            registerWrapper.success = true;
            system.debug('customerAssetList'+customerAssetList);
            //To delete all the serial numbers for the contact id from serial number search result after asset insertion
            List<Serial_Number_Search_Result__c> registeredSearchList = [Select Asset__c from Serial_Number_Search_Result__c where Asset__r.Name in: assetToRegisterList and Contact__c=:conId];
            delete registeredSearchList;
            
        } 
        
        catch(Exception e){
            system.debug('Exception Cause::'+e.getCause());
            system.debug('Exception LineNumber::'+e.getLineNumber());
            system.debug('Exception Message::'+e.getMessage());
            system.debug('Exception StackTrace::'+e.getStackTraceString());
            system.debug('Exception TypeName::'+e.getTypeName());
            YG_Utility.logError('API','Community Component Error',e.getStackTraceString(),'Class:v; Method: registerSerialNumber(); Line #:'
                                +e.getLineNumber()+'; Message:'+e.getMessage(),UserInfo.getUserId());
            
            registerWrapper.success = false;
        }    
        //system.debug('serialNumberExist ::: '+serialNumberExist);
        
        return registerWrapper;
    }
    
    public class SerialNumRegisterWrapper{
        
        @AuraEnabled public boolean success;
        @AuraEnabled public string errorCode;
        @AuraEnabled public boolean serialNumberExist =false;
        @AuraEnabled public List<Asset> searchResult;
        
    }
    
}