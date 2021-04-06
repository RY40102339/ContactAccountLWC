/********************************************************************************************************
* (C) Copyright 2020 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Vinod A
* @version 1.0
* @created 19/05/2020
* @description 
* This class is used to get data for the product information section in product history page.
*
* @test class name - YG_ProductInformationControllerTest
*
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  08/13/2020			Vinod A					Logic modified for Production date should be captured at the Asset level.
*  09/22/2020			Selvaraj T				Added new methods for ordering instructions and product availability
*
*/
public class YG_ProductInformationController  {
    
    //This method is for getting the product information details based on the serial number.
    @AuraEnabled
    public static ProdInfoWrapper getProductInformation(String serialNo/*, String plantCode*/){
        
        System.debug('serialNo::'+serialNo);
        //System.debug('plantCode::'+plantCode);
        ProdInfoWrapper prodInfoWrap=new ProdInfoWrapper();
        String topCatCode;
        Id assId;
        Id cusPltId;
        String langCode='EN';
        
        try{
            /*Plant__c plant = YG_HelperClass.getPlantID(plantCode,langCode);
            System.debug('plant::'+plant);
            cusPltId = plant.id;
            system.debug('selected plant::'+cusPltId);*/
            
            //Get contract details for the serial no
            List<Entitlement> entitle=new List<Entitlement>();
            entitle = [Select Id, Name, AccountId, ServiceContractId, AssetId, Per__c, Entitlement_quantity__c, Entitlement_type__c, 
                           Entitlement_balance__c, ServiceContract.Name, ServiceContract.Contract_No__c, ServiceContract.Contract_Type__c, Asset.Product2.Name From Entitlement Where Asset.Name =: serialNo Limit 1];
            System.debug('entitle::'+entitle);
            if(entitle.size() > 0){
                if(entitle[0].ServiceContract.Contract_No__c != null){
                    prodInfoWrap.prodContractType = entitle[0].ServiceContract.Contract_Type__c;
                    prodInfoWrap.prodContractNo = entitle[0].ServiceContract.Contract_No__c;
                }
            }else{
                prodInfoWrap.prodContractNo = '-';
            }
            
            //get asset details based on the serial number
            for(Asset ass : [SELECT Id,Name,AccountId,MS_Code__c,Order_Date__c,ParentId,Plant__c,Product2Id,Product_Carrier__c,Project__c, Production_Date__c,
                             SerialNumber,Status,Tokuchu_no__c,Xj_no__c, Product2.name, Product2.Type__c, Product2.Model_Code__c,
                             Product2.Top_Category__c, Product2.Production_Date__c, Product2.Category__r.Name  FROM Asset Where SerialNumber=:serialNo]){
                                 topCatCode = ass.Product2.Top_Category__c;
                                 System.debug('ass::'+ass);
                                 if(ass != null){
                                     System.debug('ass.Production_Date__c::'+ass.Product2.Production_Date__c);
                                     if(ass.Production_Date__c != null ){
                                         Datetime dt = Datetime.newInstance(ass.Production_Date__c.year(),ass.Production_Date__c.month(),ass.Production_Date__c.day());
                                         prodInfoWrap.productionDate = dt.format('dd MMMM YYYY');
                                     }
                                     else{
                                         prodInfoWrap.productionDate = '-';
                                     }
                                     System.debug('ass.Order_Date__c::'+ass.Order_Date__c);
                                     if(ass.Order_Date__c != null){
                                         Datetime dt1 = Datetime.newInstance(ass.Order_Date__c.year(),ass.Order_Date__c.month(),ass.Order_Date__c.day());
                                         prodInfoWrap.purchasedDate = dt1.format('dd MMMM YYYY');
                                     }
                                     else{
                                         prodInfoWrap.purchasedDate = '-';
                                     }
                                    /* System.debug('Shipping_Date__c::'+ass.Shipping_Date__c);
                                     if(ass.Shipping_Date__c != null ){
                                         Datetime dt2 = Datetime.newInstance(ass.Shipping_Date__c.year(),ass.Shipping_Date__c.month(),ass.Shipping_Date__c.day());
                                         prodInfoWrap.WarrStartDate = dt2.format('dd MMMM YYYY');
                                         Date endDate = ass.Shipping_Date__c;
                                         Date warrEnd = endDate.addYears(1);
                                         Datetime dt3 = Datetime.newInstance(warrEnd.year(),warrEnd.month(),warrEnd.day());
                                         prodInfoWrap.WarrEndDate = dt3.format('dd MMMM YYYY');
                                     }
                                     else{
                                         prodInfoWrap.WarrStartDate = '-';
                                         prodInfoWrap.WarrEndDate = '-';
                                     }
                                     */
                                     System.debug('ass.SerialNumber::'+ass.SerialNumber);
                                     if(ass.SerialNumber != null && ass.SerialNumber != ''){
                                         prodInfoWrap.serialNoCode = ass.SerialNumber;
                                     }
                                     System.debug('ass.Product2.type__c::'+ass.Product2.type__c);
                                     if(ass.Product2.type__c != null && ass.Product2.type__c != ''){
                                         prodInfoWrap.prodType = ass.Product2.type__c;
                                     }
                                     else{
                                         prodInfoWrap.prodType = '-';
                                     }
                                     System.debug('ass.Product2.Model_Code__c::'+ass.Product2.Model_Code__c);
                                     if(ass.Product2.Model_Code__c != null && ass.Product2.Model_Code__c != ''){
                                         prodInfoWrap.modelCode = ass.Product2.Model_Code__c;
                                     }
                                     else{
                                         prodInfoWrap.modelCode = '-';
                                     }
                                     System.debug('ass.MS_Code__c::'+ass.MS_Code__c);
                                     if(ass.MS_Code__c != null && ass.MS_Code__c != ''){
                                         prodInfoWrap.msCode = ass.MS_Code__c;
                                     }
                                     else{
                                         prodInfoWrap.msCode = '-';
                                     }
                                     if(ass.Product2.Name != null && ass.Product2.Name != ''){
                                         prodInfoWrap.prodName = ass.Product2.Name;
                                     }
                                     System.debug('ass.Product_Carrier__c::'+ass.Product_Carrier__c);
                                     if(ass.Product_Carrier__c != null && ass.Product_Carrier__c != ''){
                                         prodInfoWrap.prodCarrier = ass.Product_Carrier__c;
                                     }
                                     else{
                                         prodInfoWrap.prodCarrier = '-';
                                     }
                                     System.debug('ass.Tokuchu_no__c::'+ass.Tokuchu_no__c);
                                     if(ass.Tokuchu_no__c != null && ass.Tokuchu_no__c != ''){
                                         prodInfoWrap.tokuchuNo = ass.Tokuchu_no__c;
                                     }
                                     else{
                                         prodInfoWrap.tokuchuNo = '-';
                                     }
                                     if(ass.Xj_no__c != null && ass.Xj_no__c != ''){
                                         prodInfoWrap.xjNo = ass.Xj_no__c;
                                     }
                                     else{
                                         prodInfoWrap.xjNo = '-';
                                     }
                                     if(ass.Product2.Category__r.Name != null && ass.Product2.Category__r.Name != ''){
                                         prodInfoWrap.prodCatName = ass.Product2.Category__r.Name;
                                     }
                                 }
                             }
            System.debug('topCatCode::'+topCatCode);
            
            if(topCatCode != NULL && topCatCode != ''){ 
                Category__c CatName = [Select Id, Name, Category_Hierarchy__c from Category__c where Category_Hierarchy__r.Category_Code__c =: topCatCode Limit 1];
                prodInfoWrap.topCatName = CatName.Name;
            }
            
        }catch(Exception e){
            system.debug('Exception Cause::'+e.getCause());
            system.debug('Exception LineNumber::'+e.getLineNumber());
            system.debug('Exception Message::'+e.getMessage());
            system.debug('Exception StackTrace::'+e.getStackTraceString());
            system.debug('Exception TypeName::'+e.getTypeName());
            YG_Utility.logError('ProductHistoryPage','Community Component Error',e.getStackTraceString(),
                                'Class:YG_ProductInformationController; Method: getProductInformation(); Line #:'+e.getLineNumber()+'; Message:'+e.getMessage(),
                                UserInfo.getUserId());
            
        }
        
        System.debug('prodInfoWrap::'+prodInfoWrap);
        return prodInfoWrap;
    }
    
    //Wrapper to store the product data for serial number
    public class ProdInfoWrapper{
        @AuraEnabled public string insName;
        @AuraEnabled public Integer prodCount;
        @AuraEnabled public string topCatName;
        @AuraEnabled public string prodCat;
        @AuraEnabled public string prodGrp;
        @AuraEnabled public string purchasedDate;
        @AuraEnabled public string productionDate;
        //@AuraEnabled public string WarrStartDate;
        //@AuraEnabled public string WarrEndDate;
        @AuraEnabled public string serialNoCode;
        @AuraEnabled public string prodType;
        @AuraEnabled public string modelCode;
        @AuraEnabled public string msCode;
        @AuraEnabled public string prodName;
        @AuraEnabled public string prodCarrier;
        @AuraEnabled public string tokuchuNo;
        @AuraEnabled public string xjNo;
        @AuraEnabled public string prodCatName;
        @AuraEnabled public string prodContractType;
        @AuraEnabled public string prodContractNo;
        
    }
    
    //This method is for order instructions based on the serial number.
    @AuraEnabled
    public static List<Product_Extension__c> getProdExtensionDetails(String serialNo, String type){
        
        system.debug('serialNo::'+serialNo);
        system.debug('type::'+type);
        
        List<Product_Extension__c> ordInsList = new List<Product_Extension__c>();
        
        try{
            
            //Get order instruction details
            if(type == 'Ordering Instructions'){
                ordInsList = [Select Name,Order_Code__c,Description__c From Product_Extension__c 
                              Where Asset__r.SerialNumber = :serialNo and Type__c = :type];
            }

			/*//Get product availability details            
            if(type == 'Product Availability'){
                
                String modCode = [Select Product2.Model_Code__c From Asset Where SerialNumber =: serialNo].Product2.Model_Code__c;
                
                ordInsList = [Select Name,Description__c,Availability__c,Suffix_Code__c,Product__c,Product__r.Model_Code__c 
                          	  From Product_Extension__c Where Type__c = :type And Product__r.Model_Code__c = :modCode];
            }*/
            
            
        }
        catch(Exception e){
            system.debug('Exception Cause::'+e.getCause());
            system.debug('Exception LineNumber::'+e.getLineNumber());
            system.debug('Exception Message::'+e.getMessage());
            system.debug('Exception StackTrace::'+e.getStackTraceString());
            system.debug('Exception TypeName::'+e.getTypeName());
            YG_Utility.logError('ProductHistoryPage','Backend Process Error',e.getStackTraceString(),
                                'Class:YG_ProductInformationController; Method: getOrderInstruction(); Line #:'+e.getLineNumber()+'; Message:'+e.getMessage(),
                                UserInfo.getUserId());
        }
        
        system.debug('ordInsList::'+ordInsList);
        return ordInsList;
    }
}