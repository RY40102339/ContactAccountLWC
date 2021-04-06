/********************************************************************************************************
* (C) Copyright 2020 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Vinod A
* @version 1.0
* @created 09/11/2020
* @description 
* This class used to get Document search page functionalities
*
* @test class name - 
*
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  
*/

public class YG_DocumentSearchController {

    public static User userInformation =  YG_Utility.getLoggedInUserInfo(UserInfo.getUserId());
    //public static User userInformation =  YG_Utility.getLoggedInUserInfo('005p0000003rbfUAAQ');
    
    //This method is used to get the Level 1 category
    @AuraEnabled
    public static Map<String, String> getCategoryLevel1(){
        Map<String, String> category1Map=new Map<String, String>(); //Result map to get the category level 1 Name and its code
        List<String> categoryLev1Code=new List<String>(); 
        
        String langCode = YG_CommonUtils.getLanguageCode(userInformation.LanguageLocaleKey);
        System.debug('langCode::'+langCode);
        //To get the category level 1 records
        List<Category__c> categoryList=new List<Category__c>();        
        categoryList = [Select Name, Category_Hierarchy__r.Category_Code__c, Category_Hierarchy__r.Category_Level__c, 
                        Category_Hierarchy__r.Upper_Category_Code__c, Language_Code__c from Category__c Where Category_Hierarchy__r.Category_Level__c = 1 And Language_Code__c=:langCode Limit 49999];
        System.debug('categoryList::'+categoryList);
        
        for(Category__c cat: categoryList){
            if(cat.Name != null && cat.Category_Hierarchy__r.Category_Code__c != null){
                category1Map.put(cat.Name, cat.Category_Hierarchy__r.Category_Code__c);
            }
        }
        System.debug('category1Map::'+category1Map);
        return category1Map;
    }
    
    //This method is used to get the Category child levels
    @AuraEnabled 
    public static childCategoryWrapper getCategoryHierarchy(String parentCatCode){
        	
		//String parentCatCode = '12000000';
        System.debug('parentCatCode::'+parentCatCode);
        childCategoryWrapper childWrap=new childCategoryWrapper();
        List<LowerInfo> childInfoList=new List<LowerInfo>();
        List<Model> modelList=new List<Model>();
        String langCode = YG_CommonUtils.getLanguageCode(userInformation.LanguageLocaleKey);
        System.debug('langCode::'+langCode);
        List<Integer> modelInteger=new List<Integer>(); 
        
        //Category__c cat=new Category__c();
        List<Product2> productList=new List<Product2>(); //This list is used to get the list of product model codes.
		List<Category__c> categoryList=new List<Category__c>();        
        categoryList = [Select Name, Category_Hierarchy__r.Category_Code__c, Category_Hierarchy__r.Category_Level__c, 
                        Category_Hierarchy__r.Upper_Category_Code__c, Language_Code__c from Category__c Where Category_Hierarchy__r.Upper_Category_Code__c =: parentCatCode And Language_Code__c =: langCode
                        ORDER BY Name];
        System.debug('categoryList::'+categoryList);
		
        if(categoryList.size() > 0 && !categoryList.isEmpty()){
            for(Category__c category: categoryList){
                LowerInfo childCat=new LowerInfo();
                childCat.categoryName = category.Name;
                childCat.categoryID = category.Category_Hierarchy__r.Category_Code__c;
                childInfoList.add(childCat);
            }
            System.debug('childInfoList::'+childInfoList);
        }else{
            System.debug('Inside Model');
            productList = [Select Id, Name, Model_Code__c, Category__c, Lang_Code__c, IsActive From Product2 
                           Where Category__r.Category_Hierarchy__r.Category_Code__c =:parentCatCode And IsActive = True ORDER BY Model_Code__c];
            System.debug('productList::'+productList);
            if(productList.size() > 0 && !productList.isEmpty()){
                Model mod=new Model();
                List<String> prodModels=new List<String>();
                for(Product2 prodModel: productList){
                    if(prodModel.Model_Code__c.isNumeric()){
                        modelInteger.add(Integer.valueOf(prodModel.Model_Code__c));
                    }
                    //prodModels.add(prodModel.Model_Code__c);
                }
                System.debug('modelInteger::'+modelInteger);
                System.debug('modelIntegerSize::'+modelInteger.size());
                //sort logic for model codes
                for(Integer i = 0 ; i < modelInteger.size() ; i ++) {
                    for(integer j = i+1 ; j <= modelInteger.size() -1 ; j ++ ){
                        integer x = 0 ;
                        if(modelInteger[i] >  modelInteger[j]){
                            x = modelInteger[i]  ;
                            modelInteger[i] = modelInteger[j]  ;
                            modelInteger[j]  = x;
                            system.debug('modelInteger::'+modelInteger) ;
                        }
                    }
                }
                System.debug('modelInteger result::'+modelInteger);
                for(Integer IntMod: modelInteger){
                    //Adding first all the numeric model in ascending in list
                    prodModels.add(String.valueOf(IntMod));
                }
                for(Product2 prodModel: productList){
                    if(!prodModel.Model_Code__c.isNumeric()){
                        prodModels.add(prodModel.Model_Code__c);
                    }
                }
                
                mod.modelcodes = prodModels;
                modelList.add(mod);
            }
            System.debug('modelList::'+modelList);
        }
        if(childInfoList != null){
        childWrap.childInfo = childInfoList;
            }
        if(modelList != null){
            childWrap.models = modelList;
        }
        System.debug('childWrap::'+childWrap);
        
        return childWrap;
        
    }
    
    public class childCategoryWrapper{
        @AuraEnabled public List<UpperInfo> parentInfo;
        @AuraEnabled public List<LowerInfo> childInfo;
        @AuraEnabled public List<Model> models;
    }
    public class UpperInfo{
        @AuraEnabled public String categoryID;
        @AuraEnabled public String categoryName;
    }
    public class LowerInfo{
        @AuraEnabled public String categoryID;
        @AuraEnabled public String categoryName;
    }
    
    public class Model{
        @AuraEnabled public List<String> modelcodes;
    }
    
    
}