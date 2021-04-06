/*
*******************************************************************************************************
* (C) Copyright 2020 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Jayaprasath
* @version 1.0
* @created 09/25/2020
* @description 
* This class is used to write the methods for Product-Details page.
*
* @test class name - YG_CombinationProductTest
*
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  10/31/2020			Selvaraj T				Added a condition to avoid querying all asset with empty parent
*  02/24/2021           Jayaprasath             Added '-' if Product Name and Model Code is null
*/

public class YG_CombinationProduct {
    
    public static User userInformation =  YG_Utility.getLoggedInUserInfo(UserInfo.getUserId());
     
    //This method is used to get the grid data for Product-Details page 
    @AuraEnabled
    public static ProductWapper getAssetDetails(String assetIds){
        
        system.debug('serialnumber::'+assetIds);
        
        ProductWapper productWap = new ProductWapper();
        List<Asset> parentAsset = new List<Asset>();
        List<Asset> childAsset = new List<Asset>();
        List<String> childDetails = new List<String>();
        List<String> childSerialNoDetails = new List<String>();
        List<ChildData> childList=new List<ChildData>();
        String partnerIdFrmChild = '';
        String childAssetIds = '';
        Integer flag = 0;
        
        try{
            
            parentAsset = [select id, Name, ParentId, Product2.Name, Product2.Model_Code__c, Parent.Name from Asset where Name =: assetIds ];
            system.debug('parentAsset::'+parentAsset);
            
            for(Asset pa:parentAsset){
                String pName,pModel;
                if(pa.Product2.Name == null){
                    pName = '-';
                }
                else{
                    pName = pa.Product2.Name;
                }
                
                if(pa.Product2.Model_Code__c == null){
                    pModel = '-';
                }
                else{
                    pModel = pa.Product2.Model_Code__c;
                }
                
                // this condition is to get the parent product 
                if(pa.ParentId == null){
                    productWap.parent = pName + ' ('+ pModel +') : ' ;
                    productWap.parentSerialNo = pa.Name;
                    childAssetIds = pa.Name;
                } 
                else{
                    partnerIdFrmChild = pa.Parent.Name;
                    childAssetIds  = pa.Parent.Name;
                    flag ++;
                }
            }
                  
			system.debug('productWap.parent::'+productWap.parent);
            system.debug('partnerIdFrmChild::'+partnerIdFrmChild);
            
            // this condition is to get the parent product from the child record search
            if(flag >0){
                parentAsset = [select id, Name, ParentId, Product2.Name, Product2.Model_Code__c from Asset where Name =: partnerIdFrmChild ];
                system.debug('parentAsset flag::'+parentAsset);
                
                for(Asset paChild:parentAsset){
                    String pName1,pModel1;
                    if(paChild.Product2.Name == null){
                        pName1 = '-';
                    }
                    else{
                        pName1 = paChild.Product2.Name;
                    }
                    
                    if(paChild.Product2.Model_Code__c == null){
                        pModel1 = '-';
                    }
                    else{
                        pModel1 = paChild.Product2.Model_Code__c;
                    }
                    
                    productWap.parent = pName1 + ' ('+ pModel1 +') : ' ;
                    productWap.parentSerialNo = paChild.Name;
                }
                system.debug('Parent Asset flag::'+productWap.parent);
                system.debug('parentSerialNo flag::'+productWap.parentSerialNo);
            }
            
            
            // this condition is to get the child product or siblings
            if(childAssetIds != ''){
                childAsset = [select id, Name, ParentId, Product2.Name, Product2.Model_Code__c from Asset where Parent.Name =: childAssetIds];
                if(childAsset.size()>0){
                    for(Asset ca:childAsset){
                        String pName2,pModel2;
                        if(ca.Product2.Name == null){
                            pName2 = '-';
                        }
                        else{
                            pName2 = ca.Product2.Name;
                        }
                        
                        if(ca.Product2.Model_Code__c == null){
                            pModel2 = '-';
                        }
                        else{
                            pModel2 = ca.Product2.Model_Code__c;
                        }
                        
                        ChildData childCombinationData =new ChildData();
                        childDetails.add(pName2 + ' ('+ pModel2 +') : ');
                        childSerialNoDetails.add(ca.Name);
                        childCombinationData.child = pName2 + ' ('+ pModel2 +') : ';
                        childCombinationData.childSerialNo =ca.Name;
                        childList.add(childCombinationData);
                        productWap.childDataList = childList;
                        productWap.childFlag = true;
                    }
                }
                system.debug('childList'+childList);
            }
            
        }catch(Exception e){
            system.debug('Exception Cause::'+e.getCause());
            system.debug('Exception LineNumber::'+e.getLineNumber());
            system.debug('Exception Message::'+e.getMessage());
            system.debug('Exception StackTrace::'+e.getStackTraceString());
            system.debug('Exception TypeName::'+e.getTypeName());
            YG_Utility.logError('Product-Detail page','Community Component Error',e.getStackTraceString(),
                                'Class:YG_CombinationProduct; Method: getAssetDetails(); Line #:'+e.getLineNumber()+'; Message:'+e.getMessage(),
                                UserInfo.getUserId());
        }
        system.debug('productWap::'+productWap);
        return productWap;
    }
    
    public class ProductWapper{
        @AuraEnabled public String parent = '';
        @AuraEnabled public String parentSerialNo = '';        
        @AuraEnabled public List<ChildData> childDataList;
        @AuraEnabled public Boolean childFlag = false;
    }
     public class ChildData{
         
        @AuraEnabled public String child = '';
        @AuraEnabled public String childSerialNo = '';
     }
        

}