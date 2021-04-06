/*
*******************************************************************************************************
* (C) Copyright 2020 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Jayaprasath
* @version 1.0
* @created 10/15/2020
* @description 
* This class is used to write the methods for ProductDetail page.
*
* @test class name - 
*
*  Change History:
*  MM/DD/YYYY           Developer Name          Comments
*  
*/
public class YG_ProductDetailGrid {
    public static User userInformation =  YG_Utility.getLoggedInUserInfo(UserInfo.getUserId());
    //public static User userInformation =  YG_Utility.getLoggedInUserInfo('005p0000003rbfUAAQ');
    
    //This method is used to display Ms Code grid data in Product detail page 
    @AuraEnabled
    public static ProductDetailMsCodeWrapper getProductDetailMsCodeGrid(String modelcode,List<String> filterValue){
        system.debug('modelcode'+modelcode);
        ProductDetailMsCodeWrapper productDetailWap = new ProductDetailMsCodeWrapper();
        List<MsCodeData> msCodeDataList = new List<MsCodeData>();        
        String langCode = YG_CommonUtils.getLanguageCode(userInformation.LanguageLocaleKey); 
        Integer Key = 0;
        List <Integer > arr = new List<Integer>();
        Integer sum = 0;
        Integer TotalSum = 0;
        String topCatCode;
        
        try{
            
            //To get account and contact Id
            Id accId = userInformation.Contact.AccountId;
            Id conId = userInformation.Contact.Id;
            List<Id> assetIds=new List<Id>();
             
                assetIds =  YG_HelperClass.getCustomerAssets(conId);
            
            List<AggregateResult> assetList = new List<AggregateResult>();
            List<Asset> assetList1 = new List<Asset>();
                //this condition is used while filter by name 
                if(filterValue.size() > 0 && !filterValue.isEmpty()  && filterValue!=null){
                  List<Asset>  assetLists = [SELECT MS_Code__c FROM Asset where Id in: assetIds and SerialNumber =: filterValue];
                    
                    if(assetLists.size() > 0 && !assetLists.isEmpty()){
                        for(Asset assMscode: assetLists){
                            if(!filterValue.contains(assMscode.MS_Code__c)){
                                filterValue.add(assMscode.MS_Code__c);
                            }
                        }
                    }
          
                	assetList = [SELECT MS_Code__c, COUNT(SerialNumber) qty FROM Asset where Id in: assetIds and (MS_Code__c =: filterValue or SerialNumber =: filterValue) GROUP BY MS_Code__c];
                }
                else{
                	assetList  = [SELECT MS_Code__c, COUNT(SerialNumber) qty FROM Asset where Id in: assetIds and Product2.Model_Code__c =: modelcode GROUP BY MS_Code__c];
                }
            
            assetList1 = [SELECT Product2.Top_Category__c, Product2.Category__r.Name FROM Asset where Id in: assetIds and Product2.Model_Code__c =: modelcode];
            
            system.debug('List '+assetList);
            system.debug('count1 '+assetList.size());
            system.debug('count2 '+assetList.size());
            
            for(AggregateResult ass:assetList){
                MsCodeData msCodeGridData =new  MsCodeData();
                msCodeGridData.msCode = (String)ass.get('MS_Code__c');
                
                /*
                //calling YG_ProductAvailabilityController
                YG_ProductAvailabilityController.productAvailabilityWrapper prodAvail = new YG_ProductAvailabilityController.productAvailabilityWrapper();
            	prodAvail = YG_ProductAvailabilityController.getSuffixCodes((String)ass.get('MS_Code__c'));
                //system.debug('prodAvail'+prodAvail);
                system.debug('prodAvail'+prodAvail.orderAvailNoti);
                msCodeGridData.msCodeNotification = prodAvail.orderAvailNoti;
                */
                
                msCodeGridData.qty = (Integer)ass.get('qty');
                msCodeGridData.key = 'Product' + Key++;
                sum =+ (Integer)ass.get('qty');
                arr.add((Integer)ass.get('qty'));
                msCodeDataList.add(msCodeGridData);
             	productDetailWap.msCodeDataLists = msCodeDataList;
            }
            system.debug('msCodeDataList'+msCodeDataList);
            system.debug('sum'+sum);
            
                for(Integer i = 0; i<arr.size() ; i++)
            {
                TotalSum += arr[i];
            }
            System.debug('************Total**********' + TotalSum);
            productDetailWap.totalcount = TotalSum;
            
           
            for(Asset asst:assetList1){
                topCatCode = asst.Product2.Top_Category__c;
             	productDetailWap.productName = asst.Product2.Category__r.Name;
                System.debug('topCatCode**********' + asst.Product2.Top_Category__c);
                System.debug('productName**********' + asst.Product2.Category__r);
            }
            
            
             if(topCatCode != null){
                Category__c CatName = [Select Id, Name, Category_Hierarchy__c from Category__c where 
                                       Category_Hierarchy__r.Category_Code__c =: topCatCode AND 
                                       Language_Code__c =: langCode Limit 1];
                productDetailWap.topCategoryName = CatName.Name;
                 
                 AggregateResult[] productCount=[Select Product2.Id from Asset where Id IN :assetIds 
                                           AND Product2.Top_Category__c =:topCatCode GROUP BY Product2.Id];
                 productDetailWap.productIdCount = productCount.size();
            }
            
        }catch(Exception e){
            system.debug('Exception Cause::'+e.getCause());
            system.debug('Exception LineNumber::'+e.getLineNumber());
            system.debug('Exception Message::'+e.getMessage());
            system.debug('Exception StackTrace::'+e.getStackTraceString());
            system.debug('Exception TypeName::'+e.getTypeName());
            YG_Utility.logError('ProductDetail page','Community Component Error',e.getStackTraceString(),
                                'Class:YG_ProductDetailGrid; Method: getProductDetailMsCodeGrid(); Line #:'+e.getLineNumber()+'; Message:'+e.getMessage(),
                                UserInfo.getUserId());
        }
         return productDetailWap;
    }
    
    public class ProductDetailMsCodeWrapper{
        @AuraEnabled public List<MsCodeData> msCodeDataLists; 
        @AuraEnabled public Integer totalcount;
        @AuraEnabled public String topCategoryName;
        @AuraEnabled public String productName;
        @AuraEnabled public Integer productIdCount;
    }
    
    public class MsCodeData{
        @AuraEnabled public String msCode;
        @AuraEnabled public Integer qty;
        @AuraEnabled public String msCodeNotification ='-'; 
        @AuraEnabled public String key;
    }
    
   
    //This method is used to display Serial number grid data in Product detail page 
    @AuraEnabled
    public static ProductDetailSerialWrapper getProductDetailSerialGrid(List<String> mscode){
        
        ProductDetailSerialWrapper productDetailWap = new ProductDetailSerialWrapper();
        List<SerialNoData> serialNoDataList = new List<SerialNoData>();
                
        String langCode = YG_CommonUtils.getLanguageCode(userInformation.LanguageLocaleKey); 
        
        
        try{
            
            //To get account and contact Id
            Id accId = userInformation.Contact.AccountId;
            Id conId = userInformation.Contact.Id;	
            List<Id> assetIds=new List<Id>();
             
                assetIds =  YG_HelperClass.getCustomerAssets(conId);
            
            List<Asset> assetList = [SELECT SerialNumber,Tag_No__c,Production_Date__c FROM Asset where Id in: assetIds and MS_Code__c  IN : mscode];
            
            for(Asset ass:assetList){
                SerialNoData serialNoGridData = new SerialNoData();
                serialNoGridData.serialNo = ass.SerialNumber;
                if(ass.Tag_No__c != null){
                    serialNoGridData.tagNo = ass.Tag_No__c;
                }
                else{
                    serialNoGridData.tagNo = '-';
                }
                if(ass.Production_Date__c != null){
                    Date d = ass.Production_Date__c;
                    String dt = DateTime.newInstance(d.year(),d.month(),d.day()).format('d MMM YYYY');
                    system.debug(logginglevel.error,dt);
                    serialNoGridData.prodDate = dt;
                }
                else{
                	serialNoGridData.prodDate = '-';
                }
                serialNoDataList.add(serialNoGridData);
                productDetailWap.serialNoDataLists = serialNoDataList;
            }
            system.debug('serialNoDataList'+serialNoDataList);
                
            }catch(Exception e){
            system.debug('Exception Cause::'+e.getCause());
            system.debug('Exception LineNumber::'+e.getLineNumber());
            system.debug('Exception Message::'+e.getMessage());
            system.debug('Exception StackTrace::'+e.getStackTraceString());
            system.debug('Exception TypeName::'+e.getTypeName());
            YG_Utility.logError('ProductDetail page','Community Component Error',e.getStackTraceString(),
                                'Class:YG_ProductDetailGrid; Method: getProductDetailSerialGrid(); Line #:'+e.getLineNumber()+'; Message:'+e.getMessage(),
                                UserInfo.getUserId());
        }
         return productDetailWap;
    }
    public class ProductDetailSerialWrapper{
        @AuraEnabled public List<SerialNoData> serialNoDataLists;         
    }
     public class SerialNoData{
        @AuraEnabled public String serialNo;
        @AuraEnabled public String tagNo = '-';
        @AuraEnabled public String prodDate = '-';
        @AuraEnabled public String serialNoNotification ='-';        
    }
    
    //This method is used to get CSV data in Product detail page
    @AuraEnabled
    public static ProductDetailCSVWrapper getProductDetailCSV(String modelcode,List<String> filterValue){
        
        ProductDetailCSVWrapper productDetailCSVWap = new ProductDetailCSVWrapper();
        List<CSVData> csvDataList=new List<CSVData>();
        List<String> mscodeList = new List<String>();
       
        String mscod;
            
        try{
            //To get account and contact Id
            Id accId = userInformation.Contact.AccountId;
            Id conId = userInformation.Contact.Id;
            List<Id> assetIds=new List<Id>();
             	assetIds =  YG_HelperClass.getCustomerAssets(conId);
            
            List<Asset> assetList = new List<Asset>();
            List<Asset> assetList1 = new List<Asset>();
                //this condition is used while filter by name 
            
            if(filterValue.size() > 0 && !filterValue.isEmpty()  && filterValue!=null){
                  List<Asset>  assetLists = [SELECT MS_Code__c FROM Asset where Id in: assetIds and SerialNumber =: filterValue];
                    
                    if(assetLists.size() > 0 && !assetLists.isEmpty()){
                        for(Asset assMscode: assetLists){
                            if(!filterValue.contains(assMscode.MS_Code__c)){
                                filterValue.add(assMscode.MS_Code__c);
                            }
                        }
                    }
          
                	assetList = [SELECT MS_Code__c, SerialNumber, Tag_No__c, Production_Date__c FROM Asset where Id in: assetIds and (MS_Code__c =: filterValue or SerialNumber =: filterValue) ];
                }
                else{
                	assetList  = [SELECT MS_Code__c, SerialNumber, Tag_No__c, Production_Date__c FROM Asset where Id in: assetIds and Product2.Model_Code__c =: modelcode];
                }
            
                system.debug('List '+assetList);
            for(Asset ass:assetList){ 
                CSVData exportCSVData = new CSVData();
                exportCSVData.msCode = ass.MS_Code__c;
                exportCSVData.serialNo = ass.SerialNumber;
                
                if(ass.Tag_No__c != null){
                    exportCSVData.tagNo = ass.Tag_No__c;
                }
                else{
                    exportCSVData.tagNo = '-';
                }
                
                
                //exportCSVData.tagNo = 'Test';
                if(ass.Production_Date__c != null){
                 Date d = ass.Production_Date__c;
                    String dt = DateTime.newInstance(d.year(),d.month(),d.day()).format('d MMM YYYY');
                    system.debug(logginglevel.error,dt);
                    exportCSVData.prodDate = dt;
                }
                csvDataList.add(exportCSVData);
             	productDetailCSVWap.csvDataLists = csvDataList;
            }

            system.debug('productDetailCSVWap'+csvDataList);                
                
            }catch(Exception e){
            system.debug('Exception Cause::'+e.getCause());
            system.debug('Exception LineNumber::'+e.getLineNumber());
            system.debug('Exception Message::'+e.getMessage());
            system.debug('Exception StackTrace::'+e.getStackTraceString());
            system.debug('Exception TypeName::'+e.getTypeName());
            YG_Utility.logError('ProductDetail page','Community Component Error',e.getStackTraceString(),
                                'Class:YG_ProductDetailGrid; Method: getProductDetailSerialGrid(); Line #:'+e.getLineNumber()+'; Message:'+e.getMessage(),
                                UserInfo.getUserId());
        }
         return productDetailCSVWap;
    }
    public class ProductDetailCSVWrapper{
        @AuraEnabled public List<CSVData> csvDataLists;      
    }
    
    public class CSVData{
        @AuraEnabled public String mscode = '-';
        @AuraEnabled public Integer qty = 0;
        @AuraEnabled public String noti = '-';
        @AuraEnabled public String serialNo = '-';
        @AuraEnabled public String tagNo = '-';
        @AuraEnabled public String prodDate = '-';
        @AuraEnabled public String mscodeNotfy ='-';  
        @AuraEnabled public String serialNoNotfy ='-';  
    }
     

}