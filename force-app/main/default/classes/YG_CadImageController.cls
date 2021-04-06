/********************************************************************************************************
* (C) Copyright 2020 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Vinod A
* @version 1.0
* @created 15/05/2020
* @description 
* This class is used to get the image url for displaying in the product details page based on model code 
or serial number.
*
* @test class name - YG_CadImageControllerTest
*
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  10/22/2020       	Jayaprasath				Removed Shipping_Date__c field from this class
*
*/
public class YG_CadImageController  {
    
    // This method is for getting the image url based on the model code and serial number.
    @AuraEnabled 
    public static imgWrapper getImageUrl(String modelCode, String serialNo/* String plantCode*/){
        
        System.debug(':modelCode::'+modelCode);
        System.debug(':serialNo::'+serialNo);
        //System.debug(':plantCode::'+plantCode); Map<String, List<String>>
        String langCode = 'EN';
        imgWrapper imgWrap=new imgWrapper();
        //Id cusPltId;
        //Map<String,String> Img=new Map<String,String>(); //Map to store the product name and image url
        Map<String,List<String>> Img=new Map<String,List<String>>();
        String[] imgOrder;
        imgOrder =new String[]{'01', '02', '03', '04', '05'};
        List<String> imgOrderList=new List<String>(); // List to store the document categories
        
        try{
            //ID contactId = userInformation.Contact.ID;  
            //List<Id> assetIds =  YG_HelperClass.getCustomerAssets(contactId);
            //Plant__c plant = YG_HelperClass.getPlantID(plantCode,langCode);
            //cusPltId = plant.id;
            //system.debug('selected plant::'+cusPltId);
            
            //Logic to get product name and its respective image based on model code
            /*if(serialNo == '' && modelCode != '' && modelCode != null){
                Asset[] pro = [SELECT Id,Name,AccountId,MS_Code__c,Order_Date__c,ParentId,Plant__c,Product2Id,Product_Carrier__c,Project__c, 
                               SerialNumber,Status,Tokuchu_no__c,Xj_no__c, Product2.name, Product2.Id, 
                               Product2.Top_Category__c,Product2.category__r.Name FROM Asset Where Product2.Model_Code__c =: modelCode 
                               Limit 1];
                System.debug('pro::'+pro);
                //product2 pro=[Select Id,Model_Code__c, Product_Image_URL__c, Name, Type__c From product2 where Model_Code__c =: modelCode Limit 1];
                if(pro[0].Product2.Id != null){
                    List<ContentDocumentLink> imgId = [SELECT ContentDocumentId  FROM ContentDocumentLink where LinkedEntityId =: pro[0].Product2.Id Limit 1];
                    System.debug('imgId::'+imgId);
                    if(imgId.size() > 0){
                        ContentVersion imgId2 = [SELECT Id,Title FROM ContentVersion where ContentDocumentId=:imgId[0].ContentDocumentId Limit 1];
                        String imgPath = '/sfc/servlet.shepherd/version/download/'+imgId2.Id;
                        Img.put(pro[0].Product2.name, imgPath);
                    }
                }
            }
            
            //Logic to get product name and its respective image based on serial number
            if(serialNo != '' & modelCode == ''){
                asset[] ass=[select Id, Name, Product2.Product_Image_URL__c, Product2.Name, Product2.Id from asset Where SerialNumber=:serialNo Limit 1];
                if(ass[0].Product2.Id != null){
                    List<ContentDocumentLink> imgId = [SELECT ContentDocumentId  FROM ContentDocumentLink where LinkedEntityId =: ass[0].Product2.Id Limit 1];
                    if(imgId.size() > 0){
                        ContentVersion imgId2 = [SELECT FileType,Id,Title FROM ContentVersion where ContentDocumentId=:imgId[0].ContentDocumentId Limit 1];
                        String imgPath = '/sfc/servlet.shepherd/version/download/'+imgId2.Id;
                        Img.put(ass[0].Product2.Name, imgPath);
                    }
                }
            } */
            
            for(Integer i=0; i<imgOrder.size(); i++){
                imgOrderList.add(imgOrder[i]);
            }  
            List<String> imgPath=new List<String>();
			ContentWorkspace shareWorkspace = [select id,Name from ContentWorkspace Where Name = 'Asset Library'];
            System.debug('shareWorkspace::'+shareWorkspace);
            ContentFolder contFold = [SELECT Name, ParentContentFolderId FROM ContentFolder Where Name = 'Product Image'];
            //List<ContentFolder> contFold= [Select Name, ParentContentFolderId from ContentFolder Where ParentContentFolderId =: shareWorkspace.id ];
            System.debug('contFold::'+contFold);
            
            List<ContentFolderItem> ContentFolItem = [SELECT Id, Title, FileExtension FROM ContentFolderItem WHERE ParentContentFolderId IN (SELECT Id FROM ContentFolder WHERE Name =: modelCode)];
            System.debug('ContentFolItem ::'+ContentFolItem );
            List<Id> idList=new List<Id>();
            for(ContentFolderItem cont : ContentFolItem ){
                idList.add(cont.Id);
            }
            System.debug('idList::'+idList);
            List<ContentVersion> imgId2 = [SELECT Id,Title FROM ContentVersion where ContentDocumentId IN: idList];
            System.debug('imgId2 ::'+imgId2 );
            String imgUrl;
            for(String order: imgOrderList){
                for(ContentVersion conIds : imgId2){
                    //imgPath = '/sfc/servlet.shepherd/version/download/'+conIds.id;
                    //Spliting the name and order of the from name
                    String sequence= conIds.Title;
                    String ordervalue1 = sequence.split('_')[1];
                    System.debug('ordervalue1::'+ordervalue1);
                    String ordervalue = ordervalue1.substring(0,2);
                    System.debug('ordervalue::'+ordervalue);
                    if(ordervalue == order){
                    imgUrl = '/sfc/servlet.shepherd/version/download/'+conIds.id;
                    imgPath.add(imgUrl);
                    System.debug('imgPath::'+imgPath);
                    }
                    //Img.put('Test', imgPath);
                }
            }
            System.debug('Img::'+Img);
			if(serialNo == '' && modelCode != '' && modelCode != null){
            Asset[] pro = [SELECT Id,Name,AccountId,MS_Code__c,Order_Date__c,ParentId,Plant__c,Product2Id,Product_Carrier__c,Project__c, 
                               SerialNumber,Status,Tokuchu_no__c,Xj_no__c, Product2.name, Product2.Id, 
                               Product2.Top_Category__c,Product2.category__r.Name FROM Asset Where Product2.Model_Code__c =: modelCode 
                               Limit 1];
                if(pro[0].Product2.Id != null){
                    imgWrap.prodName = pro[0].Product2.name;
                    imgWrap.imgUrl = imgPath;
                //Img.put(pro[0].Product2.name, imgPath);
            }
            }
            
        }catch(Exception e){
            system.debug('Exception Cause::'+e.getCause());
            system.debug('Exception LineNumber::'+e.getLineNumber());
            system.debug('Exception Message::'+e.getMessage());
            system.debug('Exception StackTrace::'+e.getStackTraceString());
            system.debug('Exception TypeName::'+e.getTypeName());
            YG_Utility.logError('ProductDetailsPage','Community Component Error',e.getStackTraceString(),
                                'Class:YG_CadImageController; Method: getImageUrl(); Line #:'+e.getLineNumber()+'; Message:'+e.getMessage(),
                                UserInfo.getUserId());
        }
        System.debug('Img::'+Img);
        //return Img;
        return imgWrap;
    }
    public class imgWrapper{
        @AuraEnabled public String prodName;
        @AuraEnabled public List<String> imgUrl;
    }
    
}