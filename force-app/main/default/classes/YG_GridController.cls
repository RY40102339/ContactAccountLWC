/*
*******************************************************************************************************
* (C) Copyright 2020 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Selvaraj T
* @version 1.0
* @created 05/05/2020
* @description 
* This class is used to write the methods for All Stations, All Products and Product Details Page.
*
* @test class name - YG_GridControllerTest
*
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  15/06/2020           Selvaraj T              Updated the grid logic for product related pages and added grid new column as Qty
*  06/19/2020			Chitrakishore			Modified code for passing the lang code.  
*  10/22/2020       	Jayaprasath				Removed Shipping_Date__c field from this class
*/
public class YG_GridController {
    
    public static User userInformation =  YG_Utility.getLoggedInUserInfo(UserInfo.getUserId());
    //public static User userInformation =  YG_Utility.getLoggedInUserInfo('005p0000003rbfUAAQ');
    
    
    /**
	* This method is used to store the grid data for ALL Products page.
	* params: List<Id> - List of Id is used as filter all products grid data based on model code
	* params: String - Has top category and display grid data based on product top category
	**/ 
    @AuraEnabled
    public static productWrapper getProductDetails(List<Id> prodIdList, String prodCat,
                                                   Integer loadLimit, Integer offset, String btnValue){
        
        system.debug('prodIdList::'+prodIdList);
        system.debug('prodCat::'+prodCat);
        system.debug('btnValue::'+btnValue);
        
        productWrapper prodWrap=new productWrapper();
        List<prodDetails> prodDetList=new List<prodDetails>();
                                                       
        List<Id> productId = new List<Id>(); //List to store the product id
        List<Product2> productList = new List<Product2>(); //List to store the product details
        AggregateResult[] totProdSize = new AggregateResult[]{};
        Map<Id,Integer> prodContractMap = new Map<Id,Integer>();
        List<Id> contractAsstList = new List<Id>();
        String topCatCode = '';
        Date now =  date.today();
        Integer contractSize = 0, contractTotSize = 0;    
                                                  
        
        try{
   
            //For Top category 
            if(prodCat != ''){
                prodCat = prodCat.replace('+', ' ');
                system.debug('prodCat::'+prodCat);
            }
            
            //get logged in user lang code
            String langCode = YG_CommonUtils.getLanguageCode(userInformation.LanguageLocaleKey); 
            
            //Get all asset id for particular customer
            ID contactId = userInformation.Contact.ID;  
            List<Id> assetIds = new List<Id>();
            if(prodIdList.size() > 0 && !prodIdList.isEmpty()){
                List<Customer_Asset__c> asstList = [Select Asset__r.Id From Customer_Asset__c Where  Asset__r.Product2Id IN: prodIdList
                                        and Contact__r.ID =: contactId];
                for(Customer_Asset__c asst: asstList){
                    assetIds.add(asst.Asset__r.Id);
                }
            }else{
                assetIds =  YG_HelperClass.getCustomerAssets(contactId);
            }
            
            //get contract assets
            List<Scope_of_Product__c> sopList = [Select Asset__c, Asset__r.Product2Id, Service_Contract__r.StartDate, Service_Contract__r.EndDate 
                                          From Scope_of_Product__c Where Asset__c IN :assetIds and Asset__c != null];
            system.debug('Contract List::'+sopList.size());
            for(Scope_of_Product__c sop: sopList){
                Date endDate = sop.Service_Contract__r.EndDate;
                if(endDate != null){
                    Integer months = now.monthsBetween(endDate);
                    if(endDate < now || (endDate >= now && months < 6)){
                        contractSize++;
                        if(!prodContractMap.containsKey(sop.Asset__r.Product2Id)){
                            prodContractMap.put(sop.Asset__r.Product2Id,1);
                        }else{
                            Integer i = prodContractMap.get(sop.Asset__r.Product2Id) + 1;
                            prodContractMap.put(sop.Asset__r.Product2Id,i);
                        }
                    }
                    if(!contractAsstList.contains(sop.Asset__c)){
                        contractAsstList.add(sop.Asset__c);
                    }
                }
            }
            system.debug('contractAsstList::'+contractAsstList);
            system.debug('prodContractMap::'+prodContractMap);
                                    
            //Query top category code based on product category
            AggregateResult[] allAssProdId = new AggregateResult[]{};
            if(prodCat != ''){

                topCatCode = [Select Name,Category_Hierarchy__r.Category_Code__c FROM Category__c
                              WHERE Name = :prodCat AND Language_Code__c =: langCode].Category_Hierarchy__r.Category_Code__c;
                
                if(btnValue == 'Contracts'){
                    totProdSize = [Select count(Product2Id), Product2.Model_Code__c from Asset 
                               Where Id in:contractAsstList AND Product2.Category__r.Category_Type__c = 'Product' 
                               And Lang_Code__c=:langCode AND Product2.Top_Category__c = :topCatCode
                               GROUP BY Product2.Model_Code__c];
                }else{
                    totProdSize = [Select count(Product2Id), Product2.Model_Code__c from Asset 
                               Where Id in:assetIds AND Product2.Category__r.Category_Type__c = 'Product' 
                               And Lang_Code__c=:langCode AND Product2.Top_Category__c = :topCatCode
                               GROUP BY Product2.Model_Code__c];
                }
                
                allAssProdId = [Select count(SerialNumber) sn, product2.Id from asset 
                                where Id in:assetIds AND Product2.Top_Category__c = :topCatCode 
                                AND Product2.Category__r.Category_Type__c = 'Product' AND Lang_Code__c=:langCode 
                                Group By product2.Id];
                
            }else{
                
                if(btnValue == 'Contracts'){
                    totProdSize = [Select count(Product2Id), Product2.Model_Code__c from Asset 
                               Where Product2.Category__r.Category_Type__c = 'Product' 
                               AND Id in:contractAsstList And Lang_Code__c=:langCode GROUP BY Product2.Model_Code__c];
                }else{
                    totProdSize = [Select count(Product2Id), Product2.Model_Code__c from Asset 
                               Where Product2.Category__r.Category_Type__c = 'Product' 
                               AND Id in:assetIds And Lang_Code__c=:langCode GROUP BY Product2.Model_Code__c];
                }
                 system.debug('totProdSize::'+totProdSize);
                
                allAssProdId = [Select count(SerialNumber) sn, product2.Id from Asset 
                                where Product2.Category__r.Category_Type__c = 'Product' 
                                AND  Id in:assetIds AND Lang_Code__c=:langCode Group By product2.Id];
            }
            

            //Get the product id from asset object based on customer asset
            AggregateResult[] assetList = new AggregateResult[]{};
            if(btnValue == 'Contracts'){
               assetList = YG_HelperClass.getAggAssetsInfo('Product', topCatCode,langCode,loadLimit,offset, contractAsstList); 
            }else{
               assetList = YG_HelperClass.getAggAssetsInfo('Product', topCatCode,langCode,loadLimit,offset, assetIds); 
            }
            
            for(AggregateResult ar: assetList){
                Id prodId = (Id)ar.get('Id');
                if(!productId.contains(prodId)){
                    productId.add(prodId); 
                }
            }
            
            //Get the model code and product record by passing the product id from asset Object
            if(prodIdList.size() > 0 && !prodIdList.isEmpty()){
                productList = YG_HelperClass.getProductInfo(prodIdList, 'Product',langCode);
            }else{
                productList = YG_HelperClass.getProductInfo(productId, 'Product',langCode);
            } 
            
            //Set Column Name
            List<String> cols = new List<String>{System.Label.YG_Product_Categories,System.Label.YG_ProductName_Model,System.Label.YG_Qty,System.Label.YG_Notification};
            prodWrap.colDet = cols;
            
            //Logic to add the product details in wrapper and display in grid
            for(Product2 prod: productList){
                prodDetails prodDet = new prodDetails();
                List<String> serialNo = new List<String>();
                Integer qty = 0;
                Integer contractExpired = 0;
                Integer contractToBeExpired = 0;
                
                prodDet.products =prod.Product_Categories__c;
                prodDet.modelCode = prod.Model_Code__c;
                prodDet.productNameAndCode = prod.Name +' '+prod.Model_Code__c;
                
                prodDet.notifications = new List<String>();
                
                for(AggregateResult ast: allAssProdId){
                    if(prod.Id == (Id)ast.get('Id')){
                        qty = (Integer)ast.get('sn');
                    }
                }
               
                for(Scope_of_Product__c sop: sopList){
                    Date endDate = sop.Service_Contract__r.EndDate;
                    if(prod.Id == sop.Asset__r.Product2Id && endDate != null){
                        Integer months = now.monthsBetween(endDate);
                        if(endDate < now){
                            contractExpired++;
                            prodDet.notifications.add(contractExpired + ' Contracts expired');
                        }
                        if(endDate >= now && months < 6){
                            contractToBeExpired++;
                            prodDet.notifications.add(contractToBeExpired + ' Contracts expiring soon');
                        }
                    }
                }
                
                prodDet.qty = qty;
                if(prodContractMap.get(prod.Id) != null){
                    contractTotSize = contractTotSize + prodContractMap.get(prod.Id);
                }
                prodDetList.add(prodDet);
            }

            prodWrap.prodDet = prodDetList;
            prodWrap.productSize = totProdSize.size();
            if(prodIdList.size() > 0 && !prodIdList.isEmpty()){
                prodWrap.contractSize = contractTotSize;
            }else{
                 prodWrap.contractSize = contractSize;
            }
            
            
            /*
            if(csvSort != ''){
                List<prodDetails> csvProdDet=new List<prodDetails>();
                for(prodDetails csvData: prodWrap.prodDet){
                    System.debug('csvData::'+csvData);
                    if(csvData.notifications != null){
                        List<String> notificationCheck = csvData.notifications;
                        if(notificationCheck.size() > 0){
                            for(String noticheck: notificationCheck){
                                if(noticheck != null){
                                    if(noticheck.contains(csvSort)){
                                        csvProdDet.add(csvData);
                                    }
                                }
                            }
                        } 
                    }
                }
                system.debug('csvProdDet::'+csvProdDet);
                system.debug('csvProdDet.size()::'+csvProdDet.size());
                prodWrap.prodDet = csvProdDet;
            }*/
        }
        catch(Exception e){
            system.debug('Exception Cause::'+e.getCause());
            system.debug('Exception LineNumber::'+e.getLineNumber());
            system.debug('Exception Message::'+e.getMessage());
            system.debug('Exception StackTrace::'+e.getStackTraceString());
            system.debug('Exception TypeName::'+e.getTypeName());
            YG_Utility.logError('AllProductsPage','Community Component Error',e.getStackTraceString(),
                                'Class:YG_GridController; Method: getProductDetails(); Line #:'+e.getLineNumber()+'; Message:'+e.getMessage(),
                                UserInfo.getUserId());
            //throw new AuraHandledException(e.getMessage());
        }
        
        
        system.debug('prodWrap::'+prodWrap);
        return prodWrap;
    } 
    
    
    //This Wrapper class is used to store the grid data for All Products page.
    public class productWrapper{
        @AuraEnabled public List<prodDetails> prodDet = new List<prodDetails>();
        @AuraEnabled public List<String> colDet = new List<String>();
        @AuraEnabled public Integer productSize = 0;
        @AuraEnabled public Integer contractSize = 0;
    }
    
    public class prodDetails{
        @AuraEnabled public string products;
        @AuraEnabled public string modelCode;
        @AuraEnabled public string productNameAndCode;
        @AuraEnabled public integer qty;
        @AuraEnabled public List<string> notifications = new List<String>();
        @AuraEnabled public integer notificationCount = 0;
    }
   
        
}