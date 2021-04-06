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
* This class contains the method which is commonly used across other classes.
*
* @test class name - YG_HelperClassTest
*
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  06/19/2020			Chitrakishore			Modified code for passing the lang code.
*  09/08/2020           Jayaprasath             Updated the Status__c in Customer_Plant__c query 
*  09/09/2020           Jayaprasath				Included getPlantList() & getCusPlantList() to get the Plant List from Logged Acc.
*  10/13/2020			Selvaraj T				Commented the phase date fields in product object
*  10/22/2020       	Jayaprasath				Removed Shipping_Date__c field from this class and commented toCalculateAssetWarrent
*/

public class YG_HelperClass {
    
    public static User userInformation =  YG_Utility.getLoggedInUserInfo(UserInfo.getUserId());
    
    //This method is used to get customer plant of the logged in user based on contact id.
    @AuraEnabled
    public static List<Customer_Plant__c> getCusPlantInfo(Id conId){
        
        system.debug('conId::'+conId); 
        List<Customer_Plant__c> cusPlant = new List<Customer_Plant__c>();
        
        try{
            
            cusPlant = [SELECT Contact__c,Plant__c,Plant__r.Name,Plant__r.Account__c,Plant__r.Plant_Code__c,Plant__r.Plant_Name__c 
                        FROM Customer_Plant__c WHERE Contact__c =: conId and Status__c = 'Approved site access'];
            
            system.debug('cusPlant::'+cusPlant);            
            
        }catch(Exception e){
            system.debug('Exception Cause::'+e.getCause());
            system.debug('Exception LineNumber::'+e.getLineNumber());
            system.debug('Exception Message::'+e.getMessage());
            system.debug('Exception StackTrace::'+e.getStackTraceString());
            system.debug('Exception TypeName::'+e.getTypeName());
            YG_Utility.logError('GetCustomerPlantDetails','Community Component Error',e.getStackTraceString(),
                                'Class:YG_HelperClass; Method: getCusPlantInfo(); Line #:'+e.getLineNumber()+'; Message:'+e.getMessage(),
                                UserInfo.getUserId());
        }
        
        return cusPlant;
    }
    
    //This method is used to get customer plant of the logged in user based on contact id and lang code.
    @AuraEnabled
    public static List<Customer_Plant__c> getCusPlantInfo(Id conId,String langCode){
        
        system.debug('conId::'+conId); 
        List<Customer_Plant__c> cusPlant = new List<Customer_Plant__c>();
        
        try{
            
            cusPlant = [SELECT Contact__c,Plant__c,Plant__r.Name,Plant__r.Account__c,Plant__r.Plant_Code__c,Plant__r.Plant_Name__c 
                        FROM Customer_Plant__c WHERE Contact__c =: conId AND Plant__r.Lang_Code__c =:langCode and Status__c = 'Approved site access' 
                        ORDER BY Plant__r.Name ASC];
            
            system.debug('cusPlant::'+cusPlant);            
            
        }catch(Exception e){
            system.debug('Exception Cause::'+e.getCause());
            system.debug('Exception LineNumber::'+e.getLineNumber());
            system.debug('Exception Message::'+e.getMessage());
            system.debug('Exception StackTrace::'+e.getStackTraceString());
            system.debug('Exception TypeName::'+e.getTypeName());
            YG_Utility.logError('GetCustomerPlantDetails','Community Component Error',e.getStackTraceString(),
                                'Class:YG_HelperClass; Method: getCusPlantInfo(); Line #:'+e.getLineNumber()+'; Message:'+e.getMessage(),
                                UserInfo.getUserId());
        }
        
        return cusPlant;
    }
    
    //This method is used to get customer plant list from the logged in user based on account id and lang code.
    @AuraEnabled
    public static List<Contact> getCusPlantList(Id accId){
        
        system.debug('accId::'+accId); 
        List<Contact> conPlant = new List<Contact>();
        
        try{
            
            conPlant = [select name,Profile_Image__c, (select Plant__c,Plant__r.Name,Status__c,Plant__r.Plant_Name__c from Customer_Plant__r) from contact where accountid =: accId and status__c=:true];
            
            system.debug('conPlant::'+conPlant);            
            
        }catch(Exception e){
            system.debug('Exception Cause::'+e.getCause());
            system.debug('Exception LineNumber::'+e.getLineNumber());
            system.debug('Exception Message::'+e.getMessage());
            system.debug('Exception StackTrace::'+e.getStackTraceString());
            system.debug('Exception TypeName::'+e.getTypeName());
            YG_Utility.logError('GetCustomerPlantList','Community Component Error',e.getStackTraceString(),
                                'Class:YG_HelperClass; Method: getCusPlantList(); Line #:'+e.getLineNumber()+'; Message:'+e.getMessage(),
                                UserInfo.getUserId());
        }
        
        return conPlant;
    }
    
    //This method is used to get plant of the logged in user based on plan code and lang code.
    @AuraEnabled
    public static Plant__c getPlantID(String plantCode,String langCode){
        
        system.debug('plantCode::'+plantCode); 
        Plant__c plant=null;        
        
        try{
            
            Id accId = userInformation.Contact.AccountId;
            
            plant = [SELECT ID,Name,Plant_Code__c,Lang_Code__c,Plant_Name__c FROM Plant__c WHERE Plant_Code__c =: plantCode 
                     AND Lang_Code__c =:langCode AND Account__c = :accId];
            
            system.debug('plant::'+plant);            
            
        }catch(Exception e){
            system.debug('Exception Cause::'+e.getCause());
            system.debug('Exception LineNumber::'+e.getLineNumber());
            system.debug('Exception Message::'+e.getMessage());
            system.debug('Exception StackTrace::'+e.getStackTraceString());
            system.debug('Exception TypeName::'+e.getTypeName());
            YG_Utility.logError('GetPlantDetails','Community Component Error',e.getStackTraceString(),
                                'Class:YG_HelperClass; Method: getPlantID(); Line #:'+e.getLineNumber()+'; Message:'+e.getMessage(),
                                UserInfo.getUserId());
        }
        
        return plant;
    }
    
    
    //This method is used to get plant list of the logged in user based on account.
    @AuraEnabled
    public static List<Plant__c> getPlantList(Id accId,String langCode){
        
        system.debug('Account ID::'+accId); 
        List<Plant__c> plantList = new List<Plant__c>();
        
        try{
            
            plantList = [SELECT ID,Name,Plant_Code__c,Lang_Code__c,Plant_Name__c FROM Plant__c WHERE Account__c =: accId AND Lang_Code__c =:langCode];
            
            system.debug('plant::'+plantList);            
            
        }catch(Exception e){
            system.debug('Exception Cause::'+e.getCause());
            system.debug('Exception LineNumber::'+e.getLineNumber());
            system.debug('Exception Message::'+e.getMessage());
            system.debug('Exception StackTrace::'+e.getStackTraceString());
            system.debug('Exception TypeName::'+e.getTypeName());
            YG_Utility.logError('GetListofPlantDetails','Community Component Error',e.getStackTraceString(),
                                'Class:YG_HelperClass; Method: getPlantList(); Line #:'+e.getLineNumber()+'; Message:'+e.getMessage(),
                                UserInfo.getUserId());
        }
        
        return plantList;
    }
    
    /*This method is used in YG_ViewStationDetailsController - class not used
    //This method is used to get station asset details of the logged in user based on project id and station name.
    @AuraEnabled
    public static List<Asset> getStationsAssetsInfo(List<Id> projectID, String prodType, String statName, List<Id> srlId,String langCode){
        
        system.debug('projectID::'+projectID);
        system.debug('statName::'+statName);
        system.debug('srlId::'+srlId);
        List<Asset> assetList = new List<Asset>();
        
        try{
            if(srlId != null){
                assetList = [SELECT Id,Name,AccountId,MS_Code__c,Order_Date__c,ParentId,Plant__c,Product2Id,Product_Carrier__c,Project__c,
                             SerialNumber,Status,Tokuchu_no__c,Xj_no__c,Product2.Name,Product2.Model_Code__c,Product2.Product_Type__c
                             FROM Asset WHERE Project__r.Id IN :projectID AND Product2.Category__r.Category_Type__c = :prodType
                             AND Parent.Name = :statName AND Id IN :srlId AND Lang_Code__c=:langCode];
            }else{
                assetList = [SELECT Id,Name,AccountId,MS_Code__c,Order_Date__c,ParentId,Plant__c,Product2Id,Product_Carrier__c,Project__c,
                             SerialNumber,Status,Tokuchu_no__c,Xj_no__c,Product2.Name,Product2.Model_Code__c,Product2.Product_Type__c
                             FROM Asset WHERE Project__r.Id IN :projectID AND Product2.Category__r.Category_Type__c = :prodType
                             AND Parent.Name = :statName AND Lang_Code__c=:langCode];                
            }
            system.debug('assetList::'+assetList);            
            
        }catch(Exception e){
            system.debug('Exception Cause::'+e.getCause());
            system.debug('Exception LineNumber::'+e.getLineNumber());
            system.debug('Exception Message::'+e.getMessage());
            system.debug('Exception StackTrace::'+e.getStackTraceString());
            system.debug('Exception TypeName::'+e.getTypeName());
            YG_Utility.logError('GetAssetforStationDetails','Backend Process Error',e.getStackTraceString(),
                                'Class:YG_HelperClass; Method: getStationsAssetsInfo(); Line #:'+e.getLineNumber()+'; Message:'+e.getMessage(),
                                UserInfo.getUserId());
        }
        
        return assetList;
    }
    */
    
    
    //This method is used to get asset details of the logged in user based on plant id and product type.
    @AuraEnabled
    public static List<Asset> getAssetsInfo(List<Id> filterId, String prodType, String topCatCode,String langCode){
        
        system.debug('filterId::'+filterId);
        system.debug('topCatCode::'+topCatCode);
        List<Asset> assetList = new List<Asset>();
        
        try{
            
            if(prodType == 'Product'){
                if(topCatCode != ''){
                    assetList = [SELECT Id,Name,AccountId,MS_Code__c,Order_Date__c,ParentId,Plant__c,Product2Id,Product_Carrier__c,Project__c,
                                 SerialNumber,Status,Tokuchu_no__c,Xj_no__c,Product2.Name,Product2.Model_Code__c,Product2.Product_Type__c, 
                                 Product2.Top_Category__c, Product2.Product_Categories__c, Project__r.Project_Code__c FROM Asset WHERE ID IN :filterId AND Product2.Category__r.Category_Type__c = :prodType 
                                 AND Product2.Top_Category__c = :topCatCode AND Lang_Code__c=:langCode];
                }else{
                    assetList = [SELECT Product2Id, Product2.Top_Category__c FROM Asset WHERE ID IN :filterId AND 
                                 Product2.Category__r.Category_Type__c = :prodType AND Lang_Code__c=:langCode];
                }
            }
            
            if(prodType == 'System'){
                assetList = [SELECT Id,Name,AccountId,MS_Code__c,Order_Date__c,ParentId,Plant__c,Product2Id,Product_Carrier__c,Project__c,
                             SerialNumber,Status,Tokuchu_no__c,Xj_no__c,Product2.Name,Product2.Model_Code__c,Product2.Product_Type__c, Project__r.Project_Code__c FROM Asset 
                             WHERE Project__c IN :filterId AND Product2.Category__r.Category_Type__c = :prodType AND Lang_Code__c=:langCode Order By Name];
            }
            system.debug('assetList::'+assetList);            
            
        }catch(Exception e){
            system.debug('Exception Cause::'+e.getCause());
            system.debug('Exception LineNumber::'+e.getLineNumber());
            system.debug('Exception Message::'+e.getMessage());
            system.debug('Exception StackTrace::'+e.getStackTraceString());
            system.debug('Exception TypeName::'+e.getTypeName());
            YG_Utility.logError('GetAssetDetails','Community Component Error',e.getStackTraceString(),
                                'Class:YG_HelperClass; Method: getAssetsInfo(); Line #:'+e.getLineNumber()+'; Message:'+e.getMessage(),
                                UserInfo.getUserId());
        }
        
        return assetList;
    }
    
    //This method is used to get the AssetandProductInfo details for csv
    public static List<Asset> getAssetsandProductInfo(List<Id> assetIds, String prodType, 
                                                      String topCatCode,String langCode, List<Id> prodIds){
        List<Asset> assetProductList = new List<Asset>();
        System.debug('prodType::'+prodType);
        System.debug('topCatCode::'+topCatCode);
        System.debug('langCode::'+langCode);
       // System.debug('productIds::'+productIds);
        //Try{
            System.debug('Inside');
            if(topCatCode != ''){
                if(prodIds != null && prodIds.size() > 0 && !prodIds.isEmpty()){
                	assetProductList = [SELECT Id,Name,AccountId,MS_Code__c,Order_Date__c,ParentId,Plant__c,Product2Id,Product_Carrier__c,Project__c,
                                    SerialNumber,Status,Tokuchu_no__c,Xj_no__c,Product2.Name,Product2.Model_Code__c,Product2.Product_Type__c, 
                                    Product2.Top_Category__c, Product2.Product_Categories__c FROM Asset WHERE ID IN :assetIds AND Product2.Category__r.Category_Type__c = :prodType 
                                    AND Product2.Top_Category__c = :topCatCode AND Lang_Code__c=:langCode AND Product2.Id IN :prodIds];
                }else{
                    assetProductList = [SELECT Id,Name,AccountId,MS_Code__c,Order_Date__c,ParentId,Plant__c,Product2Id,Product_Carrier__c,Project__c,
                                    SerialNumber,Status,Tokuchu_no__c,Xj_no__c,Product2.Name,Product2.Model_Code__c,Product2.Product_Type__c, 
                                    Product2.Top_Category__c, Product2.Product_Categories__c FROM Asset WHERE ID IN :assetIds AND Product2.Category__r.Category_Type__c = :prodType 
                                    AND Product2.Top_Category__c = :topCatCode AND Lang_Code__c=:langCode];
                }
                
            }else{
                if(prodIds != null && prodIds.size() > 0 && !prodIds.isEmpty()){
                assetProductList = [SELECT Id,Name,AccountId,MS_Code__c,Order_Date__c,ParentId,Plant__c,Product2Id,Product_Carrier__c,Project__c,
                                    SerialNumber,Status,Tokuchu_no__c,Xj_no__c,Product2.Name,Product2.Model_Code__c,Product2.Product_Type__c,
                                    Product2.Product_Categories__c FROM Asset WHERE ID IN :assetIds AND Product2.Category__r.Category_Type__c = :prodType AND Lang_Code__c=:langCode
                                    AND Product2.Id IN :prodIds];
                }else{
                    assetProductList = [SELECT Id,Name,AccountId,MS_Code__c,Order_Date__c,ParentId,Plant__c,Product2Id,Product_Carrier__c,Project__c,
                                    SerialNumber,Status,Tokuchu_no__c,Xj_no__c,Product2.Name,Product2.Model_Code__c,Product2.Product_Type__c,
                                    Product2.Product_Categories__c FROM Asset WHERE ID IN :assetIds AND Product2.Category__r.Category_Type__c = :prodType AND Lang_Code__c=:langCode];
                }
                
            }
            System.debug('assetProductList::'+assetProductList);
            System.debug('assetProductList.size()::'+assetProductList.size());
        //}
        /*Catch(Exception e){
            system.debug('Exception Cause::'+e.getCause());
            system.debug('Exception LineNumber::'+e.getLineNumber());
            system.debug('Exception Message::'+e.getMessage());
            system.debug('Exception StackTrace::'+e.getStackTraceString());
            system.debug('Exception TypeName::'+e.getTypeName());
            YG_Utility.logError('getAssetsandProductInfo','Community Component Error',e.getStackTraceString(),
                                'Class:YG_HelperClass; Method: getAssetsandProductInfo(); Line #:'+e.getLineNumber()+'; Message:'+e.getMessage(),
                                UserInfo.getUserId());
        }*/
        return assetProductList;
    }
    //This method is used to get product details of the logged in user based on the product id from asset object and product type. 
    @AuraEnabled
    public static List<Product2> getProductInfo(List<Id> productId, string prodType, String langCode){
        
        system.debug('productId::'+productId);
        system.debug('prodType::'+prodType);
        system.debug('langCode::'+langCode);
        List<Product2> productList = new List<Product2>();
        
        try{
            if(prodType != 'Hardware'){
                productList = [SELECT Id,Name,Model_Code__c,Production_Date__c,Product_Type__c,
                               Type__c, Product_Categories__c, Category__r.Id, Category__r.Name, Category__r.Category_Type__c, Category__r.Category_Hierarchy__r.Category_Level__c,
                               Category__r.Category_Hierarchy__r.Upper_Category_Code__c,Category__r.Category_Hierarchy__r.Category_Code__c 
                               FROM Product2 WHERE Id IN :productId and Category__r.Category_Type__c = :prodType AND Lang_Code__c=:langCode];// and language_code];
            }
            if(prodType == 'Hardware'){
                System.debug('Inside product info hardware');
                productList = [SELECT Id,Name,Model_Code__c,Production_Date__c,Product_Type__c,
                               Type__c, Product_Categories__c, Category__r.Id, Category__r.Name, Category__r.Category_Type__c, Category__r.Category_Hierarchy__r.Category_Level__c,
                               Category__r.Category_Hierarchy__r.Upper_Category_Code__c,Category__r.Category_Hierarchy__r.Category_Code__c 
                               FROM Product2 WHERE Id IN :productId and Category__r.Category_Type__c = 'System' AND Lang_Code__c=:langCode AND Product_Type__c=:prodType];// and language_code];
            }
            system.debug('productList::'+productList);
            
        }catch(Exception e){
            system.debug('Exception Cause::'+e.getCause());
            system.debug('Exception LineNumber::'+e.getLineNumber());           system.debug('Exception Message::'+e.getMessage());
            system.debug('Exception StackTrace::'+e.getStackTraceString());
            system.debug('Exception TypeName::'+e.getTypeName());
            YG_Utility.logError('GetProductDetails','Community Component Error',e.getStackTraceString(),
                                'Class:YG_HelperClass; Method: getProductInfo(); Line #:'+e.getLineNumber()+'; Message:'+e.getMessage(),
                                UserInfo.getUserId());
        }
        
        return productList;
    }
    
    /*This method is used in YG_SubMenuController - method not used
    //This method is used to get parent product category list of the logged in user.
    @AuraEnabled
    public static Map<String, String> getCategoryInfo(List<String> categoryCode, Map<String, String> parentCatCode,String langCode){
        
        system.debug('categoryCode::'+categoryCode);
        List<Category__c> categoryList = new List<Category__c>();
        List<String> upperCatCode = new List<String>();
        try{
            
            categoryList = [SELECT Name, Category_Hierarchy__r.Category_Code__c, 
                            Category_Hierarchy__r.Category_Level__c, 
                            Category_Hierarchy__r.Upper_Category_Code__c 
                            from Category__c 
                            WHERE Category_Hierarchy__r.Category_Code__c IN :categoryCode 
                            AND Category_Hierarchy__r.Category_Code__c != null 
                            AND Language_Code__c =:langCode];
            
            for(Category__c catCode: categoryList){
                String upcatCode = catCode.Category_Hierarchy__r.Upper_Category_Code__c;
                String catCodes = catCode.Category_Hierarchy__r.Category_Code__c;
                Decimal upcatLvl = catCode.Category_Hierarchy__r.Category_Level__c;
                system.debug('upcatCode::' + upcatCode);
                system.debug('upcatLvl::' + upcatLvl);
                if(upcatLvl == 1 && !parentCatCode.containsKey(upcatCode)){
                    //upperCatCode.clear();
                    parentCatCode.put(catCodes, catCode.Name);
                }
                if(upcatLvl != 1 && !upperCatCode.contains(upcatCode)){
                    upperCatCode.add(upcatCode);
                }
            }
            
            system.debug('upperCatCode::' + upperCatCode);
            system.debug('upperCatCodeSize::' + upperCatCode.size());
            
            //calling the same method recursively to get parent code
            if(upperCatCode.size()>0 && upperCatCode != null && !upperCatCode.isEmpty()){
                getCategoryInfo(upperCatCode, parentCatCode,langCode);
            }           
            
        }catch(Exception e){
            system.debug('Exception Cause::'+e.getCause());
            system.debug('Exception LineNumber::'+e.getLineNumber());
            system.debug('Exception Message::'+e.getMessage());
            system.debug('Exception StackTrace::'+e.getStackTraceString());
            system.debug('Exception TypeName::'+e.getTypeName());
            YG_Utility.logError('GetCategoryDetails','Community Component Error',e.getStackTraceString(),
                                'Class:YG_HelperClass; Method: getCategoryInfo(); Line #:'+e.getLineNumber()+'; Message:'+e.getMessage(),
                                UserInfo.getUserId());
        }
        system.debug('parentCatCode::' + parentCatCode);
        return parentCatCode;
    }*/
    
    /*Method not used
    //This method is used to get all the categories in category object based on category type.    
    @AuraEnabled
    public static List<Category__c> getAllCategories(String catType,String langCode){
        
        List<Category__c> categoryList = new List<Category__c>();
        
        try{
            categoryList = [Select Name,Category_Hierarchy__r.Category_Code__c, Category_Hierarchy__r.Category_Level__c, 
                            Category_Hierarchy__r.Upper_Category_Code__c From Category__c WHERE Language_Code__c =:langCode AND 
                            Category_Hierarchy__r.Upper_Category_Code__c != 'NULL' AND Category_Type__c = :catType 
                            ORDER By Category_Hierarchy__r.Category_Level__c Desc];
            
        }catch(Exception e){
            system.debug('Exception Cause::'+e.getCause());
            system.debug('Exception LineNumber::'+e.getLineNumber());
            system.debug('Exception Message::'+e.getMessage());
            system.debug('Exception StackTrace::'+e.getStackTraceString());
            system.debug('Exception TypeName::'+e.getTypeName());
            YG_Utility.logError('GetAllCategory','Community Component Error',e.getStackTraceString(),
                                'Class:YG_HelperClass; Method: getAllCategories(); Line #:'+e.getLineNumber()+'; Message:'+e.getMessage(),
                                UserInfo.getUserId());
        }
        system.debug('categoryList::' + categoryList);
        return categoryList;
    }*/
    
    /*This method is used in YG_ViewStationDetailsController,YG_StationDetailsChartController - class not used
    //This method is used to get project details based on plant id.
    @AuraEnabled
    public static List<Project__c> getProjectInfo(Id planId){
        
        system.debug('planId::'+planId);        
        List<Project__c> projectList = new List<Project__c>();
        try{
            
            //project = [Select Id,Name,Project_Code__c from Project__c where Plant__r.Id=:planId limit 1];
            
            projectList = [Select Id,Name,Project_Code__c from Project__c where Plant__r.Id=:planId];
            
            
            
        }catch(Exception e){
            system.debug('Exception Cause::'+e.getCause());
            system.debug('Exception LineNumber::'+e.getLineNumber());
            system.debug('Exception Message::'+e.getMessage());
            system.debug('Exception StackTrace::'+e.getStackTraceString());
            system.debug('Exception TypeName::'+e.getTypeName());
            YG_Utility.logError('getProjectInfo','Community Component Error',e.getStackTraceString(),
                                'Class:YG_HelperClass; Method: getProjectInfo(); Line #:'+e.getLineNumber()+'; Message:'+e.getMessage(),
                                UserInfo.getUserId());
        }
        system.debug('projectList::'+projectList);     
        
        return projectList;
    }
    */

    //Get aggregate asset info
    @AuraEnabled
    public static AggregateResult[] getAggAssetsInfo(String prodType, String topCatCode,
                                                     String langCode, Integer lmt, Integer offset, List<Id> assetIds){
        
        system.debug('topCatCode::'+topCatCode);
        system.debug('lmt::'+lmt);
        system.debug('offset::'+offset);
        AggregateResult[] assetList;
        
        try{
            if(prodType == 'Product'){
                if(topCatCode != ''){
                    assetList = [SELECT count(SerialNumber) snCnt,Product2.Id,Product2.Name,Product2.Model_Code__c FROM Asset 
                                 WHERE Product2.Category__r.Category_Type__c = :prodType AND Lang_Code__c=:langCode AND Product2.Top_Category__c = :topCatCode 
                                 AND ID in : assetIds
                                 GROUP BY Product2.Id,Product2.Name,Product2.Model_Code__c ORDER BY Product2.Model_Code__c ASC LIMIT :lmt OFFSET :offset];
                }else{
                    assetList = [SELECT count(SerialNumber) snCnt ,Product2.Id,Product2.Name,Product2.Model_Code__c FROM Asset 
                                 WHERE Product2.Category__r.Category_Type__c = :prodType AND Lang_Code__c=:langCode 
                                 AND ID in : assetIds GROUP BY 
                                 Product2.Id,Product2.Name,Product2.Model_Code__c ORDER BY Product2.Model_Code__c ASC LIMIT :lmt OFFSET :offset];
                }
            }
        }catch(Exception e){
            system.debug('Exception Cause::'+e.getCause());
            system.debug('Exception LineNumber::'+e.getLineNumber());
            system.debug('Exception Message::'+e.getMessage());
            system.debug('Exception StackTrace::'+e.getStackTraceString());
            system.debug('Exception TypeName::'+e.getTypeName());
            YG_Utility.logError('GetAssetDetails','Community Component Error',e.getStackTraceString(),
                                'Class:YG_HelperClass; Method: getAggAssetsInfo(); Line #:'+e.getLineNumber()+'; Message:'+e.getMessage(),
                                UserInfo.getUserId());
        }
        system.debug('assetList::'+assetList);
        return assetList;
    }
    
    //This method is used to get the Width class for product details graph in overview page
    @AuraEnabled
    public static String getWidthClassGraph(Integer firmCnt){
        String firmWidthClass;
        
        if(firmCnt >= 1 && firmCnt <= 5 ){
            firmWidthClass = 'w-15px';
        }
        if(firmCnt >= 6 && firmCnt <= 14 ){
            firmWidthClass = 'w-25px';
        }
        if(firmCnt >= 15 && firmCnt <= 29 ){
            firmWidthClass = 'w-40px';
        }
        if(firmCnt >= 30 && firmCnt <= 59 ){
            firmWidthClass = 'w-55px';
        }
        if(firmCnt >= 60 && firmCnt <= 100 ){
            firmWidthClass = 'w-68px';
        }
        if(firmCnt >= 101 ){
            firmWidthClass = 'w-82px';
        }
           
        return firmWidthClass;
    }
    
    /*Method not used
    //This method is used to get the station size in the stationdetails page header
    @AuraEnabled
    public static Integer toGetStationSize(String plantCode){
        System.debug('PlantCode::'+PlantCode);
        Integer stationSize;
        String langCode = 'EN';
        List<Id> prodId=new List<Id>();
        try{
            Plant__c plantRec = YG_HelperClass.getPlantID(plantCode, langCode);
            Id plantId = plantRec.id;
            List<Asset> stationAssetList = [SELECT Id,Name From Asset Where Product2.Product_Type__c = 'Station' 
                                            AND Plant__c = : plantId AND Lang_Code__c=:langCode AND Domain__c != null];
            System.debug('stationAssetList::'+stationAssetList);
            stationSize = stationAssetList.size();
            System.debug('stationSize::'+stationSize);
         }
        catch(Exception e){
            system.debug('Exception Cause::'+e.getCause());
            system.debug('Exception LineNumber::'+e.getLineNumber());
            system.debug('Exception Message::'+e.getMessage());
            system.debug('Exception StackTrace::'+e.getStackTraceString());
            system.debug('Exception TypeName::'+e.getTypeName());
            YG_Utility.logError('GetAssetDetails','Community Component Error',e.getStackTraceString(),
                                'Class:YG_HelperClass; Method: toGetStationSize(); Line #:'+e.getLineNumber()+'; Message:'+e.getMessage(),
                                UserInfo.getUserId());
        }
        return stationSize;
    }
	*/
    
    
    //This method is used to get plant of the logged in user based on plan code and lang code.
    @AuraEnabled
    public static Product2 getProductDetails(String modelCode,String langCode){
        
        system.debug('modelCode::'+modelCode); 
        system.debug('langCode::'+langCode); 
        Product2 prod=null;        
        
        try{
            
            prod = [SELECT ID,Name,Model_Code__c,Lang_Code__c FROM Product2 WHERE Model_Code__c =: modelCode 
                     AND Lang_Code__c =:langCode];
            
            system.debug('prod::'+prod);            
            
        }catch(Exception e){
            system.debug('Exception Cause::'+e.getCause());
            system.debug('Exception LineNumber::'+e.getLineNumber());
            system.debug('Exception Message::'+e.getMessage());
            system.debug('Exception StackTrace::'+e.getStackTraceString());
            system.debug('Exception TypeName::'+e.getTypeName());
            YG_Utility.logError('GetProductDetails','Community Component Error',e.getStackTraceString(),
                                'Class:YG_HelperClass; Method: getProductDetails(); Line #:'+e.getLineNumber()+'; Message:'+e.getMessage(),
                                UserInfo.getUserId());
        }
        
        return prod;
    }
    
    
    /**
     * This method is to get the asset details based on serial number and language code.
     **/ 
	@AuraEnabled
    public static List<Asset> getAssetBySerialNumber(String serialNo,  String languageCode){    
        
        List<Asset> assetList =[Select Id,name,SerialNumber, MS_Code__c, Product2.Name, Product2.Model_Code__c,Account.Id, Plant__c, Production_Date__c  from Asset 
                            where SerialNumber=:serialNo and lang_Code__c =: languageCode]; 
        
        return assetList;
    
    }
    
    
    
    /**
     * This method is to get the serial number from Asset based on model code.
     * 
     **/ 
    @AuraEnabled
    public static List<String> getAssetBySerialNumber(List<String> modelCode){    
        
        List<String> serialList = new List<String>();     
        List<Asset> assetList =[Select SerialNumber from Asset where Product2.Model_Code__c=:modelCode]; 
        
        for(Asset asset:assetList){
            serialList.add(asset.SerialNumber);
        }
        
        return serialList;
    
    }
    
    /**
     * This method is to convert the date string to Date
     **/ 
    @AuraEnabled
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
    
    /*Method not used
    //To Calculate the Asset Warrenty 
    public static String toCalculateAssetWarrent(Date shipDate, Decimal warrentyPeriod){
        
        Date now = date.today();
        String noOfMonths;
        System.debug('Date shipDate'+shipDate);
        //Date shipDate = ass.Shipping_Date__c;
        //Date warrenty = shipDate.addYears(Integer.valueOf(ass.product2.Warranty_Period__c));
        Date warrenty = shipDate.addYears(Integer.valueOf(warrentyPeriod));
        System.debug('warrenty::'+warrenty);
        Try{
        Integer month = now.monthsBetween(warrenty);
        System.debug('month::'+month);
        if(month < 3 && month >=0 && warrenty > now){
            if (now.day() > warrenty.day()) {
                month--;
            }
            
            integer years = Integer.valueOf(Math.floor(month / 12));
            System.debug('years:::'+years);
            month = month - (years * 12);
            System.debug('month:::'+month);
            
            Date rolledBackEndDate = warrenty.addMonths(0 - month);
            System.debug('rolledBackEndDate:::'+rolledBackEndDate);
            Integer days = now.daysBetween(rolledBackEndDate);
            System.debug('days:::'+days);
            
            noOfMonths ='Warranty expiring in '+String.valueOf(month) + ' Months ' + String.valueOf(days)+' Days'; 
            System.debug('noOfMonths:::'+noOfMonths);
            
        }
        }Catch(Exception e){
            system.debug('Exception Cause::'+e.getCause());
            system.debug('Exception LineNumber::'+e.getLineNumber());
            system.debug('Exception Message::'+e.getMessage());
            system.debug('Exception StackTrace::'+e.getStackTraceString());
            system.debug('Exception TypeName::'+e.getTypeName());
            YG_Utility.logError('GetProductDetails','Community Component Error',e.getStackTraceString(),
                                'Class:YG_HelperClass; Method: toCalculateAssetWarrent(); Line #:'+e.getLineNumber()+'; Message:'+e.getMessage(),
                                UserInfo.getUserId());
        }
        return noOfMonths;
    }
	*/
    
    
    /**
     * This method is for getting the assest and product details passing the modelCode,msCode and language code.
     * 
     **/ 
    @AuraEnabled
    public static boolean getAssetOrProductDetails(List<String> modelCode, String msCode, String langCode){    
        
        List<Document__c> documentList = new List<Document__c>();     
        List<Document__c> docList = null;
        boolean docExist = false;
        
       if(null != msCode){
                
       		docList =[select Id,Name,Document_Name__c,MS_Code__c,Product__r.Model_Code__c, CreatedDate from Document__c 
                      where MS_Code__c=:msCode AND Lang_Code__c =:langCode AND
                      Category__c IN ('General Specifications','Instruction Manuals','Drawings','Technical Information','Certificates')];
       }        
       else if(null != modelCode){
                       
            docList =[select Id,Name,Document_Name__c,MS_Code__c,Product__r.Model_Code__c,CreatedDate from Document__c  
                      where Product__r.Model_Code__c IN: modelCode AND Lang_Code__c =:langCode AND 
                      Category__c IN ('General Specifications','Instruction Manuals','Drawings','Technical Information','Certificates')];
        }           
        
        Date todayDate= Date.today();
        
        for(Document__c doc:docList){
            if(null != doc.CreatedDate){
                if( doc.CreatedDate >= todayDate){
            		docExist = true;
            	}
            	else {
					documentList.add(doc);
                	//docExist = false;                
            	}                
            } 
        }
        if(!docExist && documentList.size() > 0){
            delete documentList;
        }
        
        return docExist;
    
    }
    
    /*
    @AuraEnabled
    public static List<case> getAllCaseDetails(Id PlantId){
	
	return null;        
    }*/
    
    
    /**
     * This method is for checking whether document records are there or not based on the msCode,serial number,
     * type of the document and the language code. 
     * 
     **/ 
    public static List<Document__c>  retrieveDocumentByMsCodeOrSerialNo (String assetMScode, String SerialNo, String type, String langCode){
        
        List<Document__c> docList= [Select Id, Name,Document_Name__c, Category__c, File_Extension__c, File_Size__c, Lang_Code__c, 
                                           Link__c, Product__c, MS_Code__c, Type__c, Product__r.name From Document__c 
                                           Where (MS_Code__c =: assetMScode OR Serial_Number__r.SerialNumber =:SerialNo ) 
                                                 And Type__c =:type AND Lang_Code__c =:langCode];
        
        return docList;
    }
    
    
    ///
    
    //This method is used to get assets of the logged in user.
    @AuraEnabled
    public static List<ID> getCustomerAssets(ID id){
        
        system.debug('Contact ID::'+id); 
        List<Customer_Asset__c> assetIdList = new List<Customer_Asset__c>();
        List<ID> custAssetIdList = new List<ID>();
        
        try{
            //This asset list for the BCP and LI and contracts
            assetIdList =  [SELECT Contact__c, Asset__c, Asset__r.ID, Contact__r.ID FROM Customer_Asset__c WHERE Contact__r.ID =: id /*OR Asset__r.Product2.Category__r.Category_Type__c = 'Product'*/];
            
            system.debug('Customer_Asset__c::'+assetIdList.size());  
            
            if(null != assetIdList && assetIdList.size() >0){
                for (Customer_Asset__c custAsset : assetIdList){
                    custAssetIdList.add(custAsset.Asset__r.ID);
                }
            }
            
        }catch(Exception e){
            system.debug('Exception Cause::'+e.getCause());
            system.debug('Exception LineNumber::'+e.getLineNumber());
            system.debug('Exception Message::'+e.getMessage());
            system.debug('Exception StackTrace::'+e.getStackTraceString());
            system.debug('Exception TypeName::'+e.getTypeName());
            YG_Utility.logError('getCustomerAssets','Community Component Error',e.getStackTraceString(),
                                'Class:YG_HelperClass; Method: getCustomerAssets(); Line #:'+e.getLineNumber()+'; Message:'+e.getMessage(),
                                UserInfo.getUserId());
        }
        
        return custAssetIdList;
    }
    
    //This method is used to calculate the Warrenty of the Contract(To find out the contract exping in less than 6 months)
    @AuraEnabled 
    public static String getServiceContractExpiry(Date endDt){
        Date now = date.today();
        String noOfMonths;
        //Date contEndDate = contLimeItem.ServiceContract.EndDate;
        Integer month = now.monthsBetween(endDt);
        System.debug('month::'+month);
        if(month < 6 && month >=0 && endDt >= now){
            if (now.day() > endDt.day()) {
                month--;
            }
            
            integer years = Integer.valueOf(Math.floor(month / 12));
            System.debug('years:::'+years);
            month = month - (years * 12);
            System.debug('month:::'+month);
            
            Date rolledBackEndDate = endDt.addMonths(0 - month);
            System.debug('rolledBackEndDate:::'+rolledBackEndDate);
            Integer days = now.daysBetween(rolledBackEndDate);
            System.debug('days:::'+days);
            
            if(days != 0){
                if(month == 1){
                    if(days == 1){
                        noOfMonths=' Expires in '+String.valueOf(month) + ' month ' + String.valueOf(days)+ ' day'; 
                    }
                    else{
                        noOfMonths=' Expires in '+String.valueOf(month) + ' month ' + String.valueOf(days)+ ' days'; 
                    }
                }else{
                    if(days == 1){
                        noOfMonths=' Expires in '+String.valueOf(month) + ' months ' + String.valueOf(days)+ ' day'; 
                    }else{
                        noOfMonths=' Expires in '+String.valueOf(month) + ' months ' + String.valueOf(days)+ ' days'; 
                    }
                }
                
            }else{
                if(month == 1 && days == 0){
                    noOfMonths =' Expires in '+String.valueOf(month) + ' month';
                }else{
                    if(month != 1 && days == 0){
                    noOfMonths =' Expires in '+String.valueOf(month) + ' months';
                        }
                }
                //noOfMonths =' expires in '+String.valueOf(month) + ' months';
            }
            if(month == 0){
                if(days == 1 && days != 0){
                    noOfMonths=' Expires in '+ String.valueOf(days)+ ' day';
                }else{
                    if(days != 0){
                        noOfMonths=' Expires in '+ String.valueOf(days)+ ' days'; 
                    }
                }
            }
            if(days == 0  && month == 0){
                noOfMonths=' Expires today'; 
            }
            System.debug('noOfMonths:::'+noOfMonths);
            //notiCont.contractExpiry = noOfMonths;
        }
        
        
        return noOfMonths;
    }
    
    //This method is used to get the list of Service contract from the selection of plant
    @AuraEnabled
    public static List<Id> getServiceContracts(String plantCode, List<Id> assetIds){
        System.debug('plantCode::'+plantCode);
        System.debug('assetIds::'+assetIds);
        List<Id> serviceContractId=new List<Id>();
        List<Asset> assetList = new List<Asset>();
        List<Id> assIdList=new List<Id>();
        Id accId = userInformation.Contact.AccountId;
        //Query to get the entitlement Product based contracts list
        //List<Entitlement> entitlementList = [Select Id, AssetId, ServiceContract.Id From Entitlement Where AssetId IN: assetIds /*AND ServiceContract.Contract_Type__c != 'LCA'*/ ];
        /*System.debug('entitlementList::'+entitlementList);
        for(Entitlement entitleRec: entitlementList){
            if(!serviceContractId.contains(entitleRec.ServiceContract.Id)){
                serviceContractId.add(entitleRec.ServiceContract.Id);
            }
        }*/
        //Query to get the entitlement Product based contracts list
        List<Scope_of_Product__c> scopProdList = [Select Id, Service_Contract__r.Id, Asset__c From Scope_of_Product__c Where Asset__r.Id IN: assetIds AND Service_Contract__r.Contract_Type__c != 'LCA'];
        System.debug('scopProdList::'+scopProdList);
        for(Scope_of_Product__c scopRec: scopProdList){
            if(!serviceContractId.contains(scopRec.Service_Contract__r.Id)){
                serviceContractId.add(scopRec.Service_Contract__r.Id);
            }
        }
        
        
        //Query to get the list for LCA based on system Assets on plant selection
        assetList = [SELECT Id,Name,AccountId,MS_Code__c FROM Asset WHERE Plant__r.Plant_Code__c=:plantCode And AccountId=: accId];
        System.debug('assetList::'+assetList);
        System.debug('assetList::'+assetList.size());
        for(Asset ass:assetList){
            assIdList.add(ass.Id);
        }
        System.debug('assIdList::'+assIdList);
        List<Scope_of_Product__c> scopOfProdList = [Select Id, Service_Contract__r.Id, Asset__c From Scope_of_Product__c Where Asset__r.Id IN: assIdList];
        System.debug('scopOfProdList::'+scopOfProdList);
        for(Scope_of_Product__c scopRec: scopOfProdList){
            if(!serviceContractId.contains(scopRec.Service_Contract__r.Id)){
                serviceContractId.add(scopRec.Service_Contract__r.Id);
            }
        }
        /*List<Entitlement> entitlementListLCA = [Select Id, AssetId, ServiceContract.Id From Entitlement Where AssetId IN: assetList ];
        System.debug('entitlementListLCA::'+entitlementListLCA);
        for(Entitlement entitleRec: entitlementListLCA){
            if(!serviceContractId.contains(entitleRec.ServiceContract.Id)){
                serviceContractId.add(entitleRec.ServiceContract.Id);
            }
        }*/
        /*List<Service_Contract_Plant__c> serviceContPlant= [Select Id, Name, Plant__c, Service_Contract__r.Id From Service_Contract_Plant__c Where Plant__r.Plant_Code__c =: plantCode];
        System.debug('serviceContPlant::'+serviceContPlant);
        for(Service_Contract_Plant__c servContractId : serviceContPlant){
            if(!serviceContractId.contains(servContractId.Service_Contract__r.Id)){
                serviceContractId.add(servContractId.Service_Contract__r.Id);
            }
        }*/
         System.debug('serviceContractId::'+serviceContractId);
        return serviceContractId;
    }
  
   
}