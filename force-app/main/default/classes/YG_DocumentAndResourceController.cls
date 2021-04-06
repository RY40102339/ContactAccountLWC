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
* This class is used to get documents and references based on the model code and serialno.
*
* @test class name - YG_DocumentAndResourceControllerTest
*
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  08/21/2020			Chitrakishore			Modified the code for the document API call			
*  10/22/2020       	Jayaprasath				Removed Shipping_Date__c field from this class
*/
public class YG_DocumentAndResourceController {
    
    public static User userInformation =  YG_Utility.getLoggedInUserInfo(UserInfo.getUserId());
    //public static User userInformation =  YG_Utility.getLoggedInUserInfo('005p0000003rbfUAAQ');
    
    //This method is used to get the documents of the product
    @AuraEnabled
    public static mainWrapper getDocAndResourceDetails(String type, String serialNo, String modelCode, 
                                                       String plantCode, String frm){  
        
        System.debug('type::'+type);
        System.debug('serialNo::'+serialNo);
        System.debug('modelCode::'+modelCode);
        System.debug('plantCode::'+plantCode);
        List<String> modelList = null;
        if(null != modelCode && modelCode.trim().length()>0){
            modelList = new List<String>();
            modelList.add(modelCode);
        }
        
        if('Document'.equalsIgnoreCase(type)){
            
            System.debug('Document flow ====');
            System.debug('serialNo:: ' +serialNo);
            System.debug('modelCode::' +modelCode);            
            
            YG_DocumentController.getDocumentAPIDetails(serialNo, modelList, plantCode, frm);
        }
                
        List<Document__c> docList=new List<Document__c>(); //List to store documents record
     	List<Document__c> docList1=new List<Document__c>(); //List to store documents record with the updated size
        String[] docOrder;
        if(frm == 'product-details'){                                                           
        //docOrder to hide the certification accordion in product-details page
        docOrder =new String[]{'Instruction Manuals', 'General Specifications', 'Drawings', 'Software', 'FAQs', 'Training Modules', 'Technical Information', 'Specifications and Functions', 'Technical InformationLink'};
            }else{                
        docOrder =new String[]{'Instruction Manuals', 'General Specifications', 'Certificates', 'Drawings', 'Software', 'FAQs', 'Training Modules', 'Technical Information', 'Specifications and Functions', 'Technical InformationLink'};
         }
                                                           
        List<ID> fileIDs = new List<ID>(); //List to store document id
        Map<ID, ID> docIdFileIdMap=new Map<ID, ID>(); //Map to store the document and file id
        List<String> docCategory=new List<String>(); // List to store the document categories
        List<String> prodModel=new List<String>(); // List to store the product model code
        
        mainWrapper mainWrap = new mainWrapper();        
        String langCode = YG_CommonUtils.getLanguageCode(userInformation.LanguageLocaleKey); 
        System.debug('In getDocAndResourceDetails langCode::'+langCode);
        try{
            
            
            
            //Logic to get the document data based on serial number
            if(serialNo != null && serialNo.trim().length() >0){
                List<Asset> assetList = YG_HelperClass.getAssetBySerialNumber(serialNo, langCode);
                Asset assetRec = null;
                if(assetList.size() > 0 ){
                    assetRec = assetList.get(0);                    
                    String assetMScode = assetRec.MS_Code__c;
                	String assetModelCode = assetRec.Product2.Model_Code__c;
                 
                	if('Document'.equalsIgnoreCase(type)){
                       docList = YG_HelperClass.retrieveDocumentByMsCodeOrSerialNo(assetMScode, serialNo, type, langCode);
                       System.debug('Inside If ::: docList::'+docList.size());                       
                    }
                    if('Resources'.equalsIgnoreCase(type)){
                        if(assetModelCode != ''){
                            docList= [Select Name, Category__c, File_Extension__c, File_Size__c, Lang_Code__c, Link__c, Product__c, MS_Code__c, Project__c,
                                      Type__c, Product__r.name From Document__c Where Product__r.Model_Code__c =: assetModelCode And Type__c =:type];
                            System.debug('ResList::'+docList.size());
                        }
                    }                    
                }
            }
            
            //Logic to get the document data based on model code
            if(modelCode != null && modelCode.trim().length() >0 ){
                List<Asset> assetList = new List<Asset>();
                List<String> msCodeList=new List<String>();
                
                 ID contactId = userInformation.Contact.ID;  
                List<Id> assetIds =  YG_HelperClass.getCustomerAssets(contactId);
                //Quering with the model code to get the ms code
                if('product-details'.equalsIgnorecase(frm) || 'product-history'.equalsIgnoreCase(frm)) {
                    assetList = [SELECT Id,Name,AccountId,MS_Code__c,Order_Date__c,ParentId,Plant__c,Product2Id,Product_Carrier__c,Project__c,
                             SerialNumber,Status,Tokuchu_no__c,Xj_no__c, Product2.name, Product2.Top_Category__c, Product2.category__r.Name FROM Asset
                             Where Product2.Model_Code__c =:modelCode AND Id in: assetIds];
                } else {
                    Plant__c plantObj = YG_HelperClass.getPlantID(plantCode,langCode);
                    System.debug('plantObj::'+plantObj);
                	assetList = [SELECT Id,Name,AccountId,MS_Code__c,Order_Date__c,ParentId,Plant__c,Product2Id,Product_Carrier__c,Project__c,
                             SerialNumber,Status,Tokuchu_no__c,Xj_no__c, Product2.name, Product2.Top_Category__c, Product2.category__r.Name FROM Asset
                             Where Product2.Model_Code__c =:modelCode AND Plant__r.Id=:plantObj.Id];
                }
                System.debug('assetList::'+assetList);
                
                if(assetList != null && !assetList.isEmpty()){
                    //Adding the list of mscode to get the matching MScode documents.
                    mainWrap.moduleName = assetList.get(0).Product2.Name;
                    for(Asset assMsCode : assetList){
                        
                        msCodeList.add(assMsCode.MS_Code__c);
                    }
                    System.debug('msCodeList::'+msCodeList);
                
                	if(type == 'Document'){
                    
                        //Query to get the same mscode of Instruction Manuals ,Technical Information, Certificate, Software in documents object
                    	if(msCodeList !=null && !msCodeList.isEmpty()){
                        
                        	docList= [Select Name, Document_Name__c, Category__c, File_Extension__c, File_Size__c, Lang_Code__c, Link__c, Product__c, MS_Code__c, Project__c,
                                  Type__c, Product__r.name From Document__c 
                                      Where (MS_Code__c IN: msCodeList or Product__r.Model_Code__c =: modelCode)
                                      And Type__c =:type];
                        
							System.debug('docList::getting the matching mscode of Instruction Manuals ,Technical Information, Certificate, Software'+docList);
                   	 	}
                    } 
                    
                    if(type == 'Resources'){                    
                                           
                        docList= [Select Name, Document_Name__c, Category__c, File_Extension__c, File_Size__c, Lang_Code__c, Link__c, Product__c, MS_Code__c, Project__c,
                                  Type__c, Product__r.name From Document__c Where Product__r.Model_Code__c =: modelCode 
                                  And Type__c =:type ];

                   		System.debug('Final Resouce List::'+docList);
                	}
                }
            }
            
            System.debug('docList::'+docList);
            
            
            for(Integer i=0; i<docOrder.size(); i++){
                docCategory.add(docOrder[i]);
            }   
            
            //To set the file size SI unit(KB and MB)
            //To set the file size SI unit(KB and MB)
            for(Document__c docFilesize: docList){
                Document__c docSizeUpt=new Document__c();
                if(docFilesize.File_Size__c != null){
                    String hrSize;
                    decimal size = decimal.valueOf(docFilesize.File_Size__c);
                    
                    //decimal m = size/1024.0;
                    if(size != 0){
                        if(docFilesize.Category__c == 'Certificates'){
                            decimal k = size.divide(1024.0, 1, System.RoundingMode.UP);
                            decimal  m = size.divide(1048576.0, 1, System.RoundingMode.UP);
                            if( m >= 1){
                                hrSize = m +' MB';
                            }
                            else if( k >= 1){
                                hrSize = k +' KB';
                            } else {
                                hrSize = size +' B';
                            }
                        }else{
                            decimal m = size.divide(1024.0, 1, System.RoundingMode.UP);
                            if( m >= 1){
                                hrSize = m +' MB';
                            } else {
                                hrSize = size +' KB';
                            }
                        }
                    }else{
                        hrSize = '-';
                    }
                    docFilesize.File_Size__c = hrSize;
                     
                }else{
                    docFilesize.File_Size__c = '-';
                }
                
                docList1.add(docFilesize);
            }
            System.debug('docList1:::'+docList1);
            //Logic to get document record for each model code in wrapper list

            List<subWrapper> subWr = new List<subWrapper>();
            List<specWrapper> specWr = new List<specWrapper>();
            for(String cat : docCategory){
                subWrapper sub = new subWrapper();
                specWrapper spec = new specWrapper();
                List<sObject> objList = new List<sObject>();
                for(Document__c dd: docList1){
                    //if(dd.Product__r.name == modCategory && dd.Category__c == cat){
                    if(dd.Category__c == cat){
                        if(dd.Category__c != 'Specifications and Functions' && dd.Category__c != 'Technical InformationLink'){
                            System.debug('dd.Category__c::'+dd.Category__c);
                            sub.catName = dd.Category__c;
                            System.debug('dd::'+dd);
                            objList.add(dd); 
                        }
                        
                        if(dd.Category__c == 'Specifications and Functions'){
                            if(dd.Link__c !=null){
                                spec.specificationAndFunctionLink = dd.Link__c;
                            }
                        }
                        if(dd.Category__c == 'Technical InformationLink'){
                            if(dd.Link__c !=null){
                                spec.technicalInfoLink = dd.Link__c;
                            }
                        }
                    }
                }
                System.debug('objList.size::'+objList.size());
                if(objList.size()>0){
                    sub.catName = sub.catName+' ('+objList.size()+')';
                    sub.sObj = objList;
                    subWr.add(sub);   
                }
                if(spec.specificationAndFunctionLink != null){
                    specWr.add(spec);
                }
                if(spec.technicalInfoLink != null){
                    specWr.add(spec);
                }
                
            }
            mainWrap.subWrap = subWr;
            mainWrap.specWrap = specWr;
            
        }catch(Exception e){
            system.debug('Exception Cause::'+e.getCause());
            system.debug('Exception LineNumber::'+e.getLineNumber());
            system.debug('Exception Message::'+e.getMessage());
            system.debug('Exception StackTrace::'+e.getStackTraceString());
            system.debug('Exception TypeName::'+e.getTypeName());
            YG_Utility.logError('Documents&Resource','Community Component Error',e.getStackTraceString(),
                                'Class:YG_DocumentAndResourceController; Method: getDocAndResourceDetails(); Line #:'+e.getLineNumber()+'; Message:'+e.getMessage(),
                                UserInfo.getUserId());
        }
        system.debug('mainWrap::'+mainWrap);
       
        return mainWrap;
    }
    
        
    //Wrapper class to store the model name and its document record
    public class mainWrapper{
        @AuraEnabled public String moduleName;
        @AuraEnabled public List<subWrapper> subWrap;
        @AuraEnabled public List<specWrapper> specWrap;
    }
    
    
    public class DocContentIdWrapper{
        @AuraEnabled public ID docId;
        @AuraEnabled public ID contentDocumentId;
        @AuraEnabled public ID contentVersionId;
    }
    //Wrapper class to store Resources- Specification and technical links
    public class specWrapper{
        @AuraEnabled public String specificationAndFunctionLink;
        @AuraEnabled public String technicalInfoLink;
    }
    //Wrapper class to store the document category and its document record
    public class subWrapper{
        @AuraEnabled public String catName;
        @AuraEnabled public List<sObject> sObj;
        
    }
}