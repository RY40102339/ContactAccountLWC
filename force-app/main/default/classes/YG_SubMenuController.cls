/*
*******************************************************************************************************
* (C) Copyright 2020 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Selvaraj T
* @version 1.0
* @created 06/05/2020
* @description 
* This class is used to display the submenu is all products page dynamically.
*
* @test class name - YG_SubMenuControllerTest
*
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  06/19/2020			Chitrakishore			Modified code for passing the lang code.
*  12/02/2020			Selvaraj T				Modified the code for increasing performance.
*/
 
public class YG_SubMenuController {
    
    public static User userInformation =  YG_Utility.getLoggedInUserInfo(UserInfo.getUserId());
    //public static User userInformation =  YG_Utility.getLoggedInUserInfo('005p0000003rbfUAAQ');
    
    @AuraEnabled
    public static List<SubMenuWrapper> getSubMenus(){
                
        List<SubMenuWrapper> subMenuList=new List<SubMenuWrapper>(); //Wrapper to store the product submenu 
        List<Id> productId = new List<Id>(); //list to store the product id
        List<string> categoryCodes = new List<string>(); //list to store the category code
        Map<String,String> catMap = new Map<String,String>(); //map to store the category code as key and category name as value
        Map<String,List<String>> catProdMap = new Map<String,List<String>>(); //map to store the category code as key and product id list as value
        Map<String,Integer> catContractMap = new Map<String,Integer>();
        Integer contractTotCount = 0;
        
        try{
            
            //get the lang code of the user
            String langCode = YG_CommonUtils.getLanguageCode(userInformation.LanguageLocaleKey); 
            
            //get contact id based on logged in user info
            ID contactId = userInformation.Contact.ID;  
            
            //get asset id based on customer asset
            List<Id> assetIds =  YG_HelperClass.getCustomerAssets(contactId);
            
            //get contract from customer assets
            List<Scope_of_Product__c> sopList = [Select Asset__c, Asset__r.Product2Id, Service_Contract__r.StartDate, Service_Contract__r.EndDate, 
                                          Asset__r.Product2.Top_Category__c From Scope_of_Product__c Where Asset__c IN :assetIds and Asset__c != null];
            Date now =  date.today();
            for(Scope_of_Product__c sop: sopList){
                Date endDate = sop.Service_Contract__r.EndDate;
                if(endDate != null){
                    Integer months = now.monthsBetween(endDate);
                    if(endDate < now || (endDate >= now && months < 6)){
                        contractTotCount++;
                        if(!catContractMap.containsKey(sop.Asset__r.Product2.Top_Category__c)){
                            catContractMap.put(sop.Asset__r.Product2.Top_Category__c,1);
                        }else{
                            Integer i = catContractMap.get(sop.Asset__r.Product2.Top_Category__c) + 1;
                            catContractMap.put(sop.Asset__r.Product2.Top_Category__c,i);
                        }
                    }
                }
            }
            
            
            //get product id and top category code based on customer asset
            List<Asset> assetList = YG_HelperClass.getAssetsInfo(assetIds,'Product','',langCode);
            for(Asset asst: assetList){
                if(!productId.contains(asst.Product2Id)){
                	productId.add(asst.Product2Id);
                    
                    List<String> prodId = new List<String>();
                    if(!catProdMap.containsKey(asst.Product2.Top_Category__c)){
                        prodId.add(asst.Product2Id);
                        catProdMap.put(asst.Product2.Top_Category__c,prodId);
                    }else{
                        prodId = catProdMap.get(asst.Product2.Top_Category__c);
                        prodId.add(asst.Product2Id);
                        catProdMap.put(asst.Product2.Top_Category__c,prodId);
                    }
                    
                }
                
                if(!categoryCodes.contains(asst.Product2.Top_Category__c)){
                    categoryCodes.add(asst.Product2.Top_Category__c);
                }
                
            }
            system.debug('productId::'+productId);
            system.debug('categoryCodes::'+categoryCodes);
            system.debug('catProdMap::'+catProdMap);
            
            //get the top categoy name based on top category code
            List<Category__c> catList = [Select Name, Category_Hierarchy__r.Category_Code__c From Category__c Where 
                                         Category_Hierarchy__r.Category_Level__c = 1 And Language_Code__c = :langCode And Category_Hierarchy__r.Category_Code__c =: categoryCodes ];
			
            for(Category__c cat: catList){
                if(!catMap.containsKey(cat.Category_Hierarchy__r.Category_Code__c)){
                    catMap.put(cat.Category_Hierarchy__r.Category_Code__c,cat.Name);
                }
            } 
            system.debug('catMap::'+catMap);
            
            //Wrapper logic goes here
            for(string catCode: catMap.keySet()){
                SubMenuWrapper subMenu = new SubMenuWrapper();
                subMenu.parentCatCode = catCode;
                subMenu.label = catMap.get(catCode);
                subMenu.catProdCount = catProdMap.get(catCode).size();
                if(catContractMap.get(catCode) == null){
                    subMenu.noficationCount = 0;
                }else{
                    subMenu.noficationCount = catContractMap.get(catCode);
                } 
                subMenu.totalNotiCount = contractTotCount;
                subMenuList.add(subMenu) ;
            }
            
            /*
            //get product list based on product od from asset data
            List<Product2> productList = YG_HelperClass.getProductInfo(productId, 'Product',langCode);
            system.debug('productList::'+productList);
            system.debug('productList size::'+productList.size());
            
            //logic to get category codes
            for(Product2 prod: productList){
                string catCode = prod.Category__r.Category_Hierarchy__r.Category_Code__c;
                Decimal level = prod.Category__r.Category_Hierarchy__r.Category_Level__c;
                system.debug('prod.Category__r.level::'+ level);
                if(!categoryCodes.contains(catCode)){
                    categoryCodes.add(catCode);
                }
                
            }
            system.debug('categoryCodes::'+categoryCodes);
            
            //logic to get parent category code
            Map<String, String> parentCatCode = new Map<String, String>();
            parentCatCode = YG_HelperClass.getCategoryInfo(categoryCodes, parentCatCode,langCode);
            system.debug('parentCatCode::'+parentCatCode);
			*/
            /*
            //logic to get total notifications for submenu
            List<YG_NotificationsController.notiWrapper> notiWrap = new List<YG_NotificationsController.notiWrapper>();
            notiWrap = YG_NotificationsController.getNotificationData(assetIds,'Product','',langCode);
            system.debug('notiWrap::'+notiWrap);
            
            Map<String,Integer> allbuttonNotification = new Map<String,Integer>();
            for(YG_NotificationsController.notiWrapper notis: notiWrap){
                for(String str: notis.buttonNotification.keySet()){
                    String subType = str;
                	Integer subTypeCount = notis.buttonNotification.get(str);
                    if(!allbuttonNotification.containsKey(str)){
                        allbuttonNotification.put(subType,subTypeCount);
                    }else{
                        subTypeCount = subTypeCount + allbuttonNotification.get(str);
                        allbuttonNotification.put(subType,subTypeCount);
                    }
                }
            }
            system.debug('allbuttonNotification::'+allbuttonNotification);
                       
            if(parentCatCode != null && !parentCatCode.isEmpty()){
                for(YG_NotificationsController.notiWrapper noti: notiWrap){
                    for(string catCode: parentCatCode.keySet()){
                        if(noti.catCode == catCode){
                            SubMenuWrapper subMenu = new SubMenuWrapper();
                            subMenu.parentCatCode = catCode;
                            subMenu.label = parentCatCode.get(catCode);
                            subMenu.noficationCount = noti.catCodeTotCount;// to call actual method
                            subMenu.catProdCount = noti.catModCodeCount;
                            subMenu.totalNotiCount = allbuttonNotification.get('Notifications in total');
                            subMenuList.add(subMenu) ;
                        }
                    }
                }
            }*/
         
        }catch(Exception e){
            system.debug('Exception Cause::'+e.getCause());
            system.debug('Exception LineNumber::'+e.getLineNumber());
            system.debug('Exception Message::'+e.getMessage());
            system.debug('Exception StackTrace::'+e.getStackTraceString());
            system.debug('Exception TypeName::'+e.getTypeName());
            YG_Utility.logError('GetSubMenus','Community Component Error',e.getStackTraceString(),
                               'Class:YG_SubMenuController; Method: getSubMenus(); Line #:'+e.getLineNumber()+'; Message:'+e.getMessage(),
                               UserInfo.getUserId());
        }
        system.debug('subMenuList::'+subMenuList);
        return subMenuList;
    }
    
    
    //wrapper class to store the submenu list with notification count 
    public class SubMenuWrapper{
        @AuraEnabled public string parentCatCode; //parent category code
        @AuraEnabled public string label; //parent category name
        @AuraEnabled public integer noficationCount = 0; //notification count for each category code
        @AuraEnabled public integer catProdCount = 0; //product count under each category
        @AuraEnabled public integer totalNotiCount = 0; //total notification count of all category code
    }    
}