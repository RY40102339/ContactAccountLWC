global with sharing class YG_EmailComponetCtrl {
    global String languageType {get;set;}
    global final String firstName {get;set;}
    global final String lastName {get;set;} 
    global final String caseNumber {get;set;}
    global final date caseEndDate {get;set;}
    
    global final String caseAccount {get;set;}
    global final String caseCustomRef {get;set;}
    global final String workOrdNum {get;set;}
    global final String caseAsset {get;set;}
    global final String caseAssetSLNum {get;set;}
    global final String caseDesc {get;set;}
    global final String workOrdNote {get;set;}

    global final String workOrdStatus {get;set;}
    global Boolean isClosed {get;set;}
    global final String workOrdSol {get;set;}

    global List<string> getEmailContent() {
        system.debug('input from email : '+languageType+'>>>>'+firstName+'>>>'+lastName+'>>>'+caseNumber+'>>>'+caseEndDate);
        string[] lstRegistedLang = [SELECT MasterLabel, Language_Code__c, Table_Content__c, Email_Content__c FROM YG_Email_Content__mdt where Language_Code__c='Reg_Code' limit 1].Table_Content__c.split('`');
        system.debug('lstRegistedLang>>>'+lstRegistedLang);
        if(languageType == null || languageType == '' || !lstRegistedLang.contains(languageType)){
            YG_Email_Content__mdt threatMappings = [SELECT MasterLabel, Language_Code__c, Table_Content__c, Email_Content__c FROM YG_Email_Content__mdt where Language_Code__c='EN' limit 1];
            List<string> lstEmailContent=threatMappings.Email_Content__c.split('`');
            return lstEmailContent;
        } else{
            YG_Email_Content__mdt threatMappings = [SELECT MasterLabel, Language_Code__c, Table_Content__c, Email_Content__c FROM YG_Email_Content__mdt where Language_Code__c=:languageType limit 1];
            List<string> lstEmailContent=threatMappings.Email_Content__c.split('`');
            return lstEmailContent;
        }       
    }
    global Map<string, string> getTableContent(){
        system.debug('input from email : '+caseAccount+'>>>>'+caseCustomRef+'>>>'+workOrdNum+'>>>'+caseAsset+'>>>'+caseAssetSLNum+'>>>'+caseDesc+'>>>'+workOrdNote); 
        Map<string, string> mapTable = new Map<string, string>();
        string[] lstRegistedLang = [SELECT MasterLabel, Language_Code__c, Table_Content__c, Email_Content__c FROM YG_Email_Content__mdt where Language_Code__c='Reg_Code' limit 1].Table_Content__c.split('`');
        if(languageType == null || languageType == '' || !lstRegistedLang.contains(languageType)){
            YG_Email_Content__mdt threatMappings = [SELECT MasterLabel, Language_Code__c, Table_Content__c, Email_Content__c FROM YG_Email_Content__mdt where Language_Code__c='EN' limit 1];
            List<string> lstTableContent=threatMappings.Table_Content__c.split('`');
            mapTable= fetchTableData(lstTableContent, mapTable);
            if(mapTable.size()==0)  mapTable.put('customer:', 'test');
            system.debug('mapTable>>>>>'+mapTable);
            return mapTable;
        }else{
            YG_Email_Content__mdt threatMappings = [SELECT MasterLabel, Language_Code__c, Table_Content__c, Email_Content__c FROM YG_Email_Content__mdt where Language_Code__c=:languageType limit 1];
            List<string> lstTableContent=threatMappings.Table_Content__c.split('`');
            mapTable= fetchTableData(lstTableContent, mapTable);
            if(mapTable.size()==0)  mapTable.put('customer:', 'test');
            system.debug('mapTable>>>>>'+mapTable);
            return mapTable;
        }
    }
    global Map<string, string> fetchTableData (List<string> lstTableContent, Map<string, string> mapTable){
        if(caseAccount!=null) mapTable.put(lstTableContent[0], caseAccount); 
        else mapTable.put(lstTableContent[0], ''); 
        if(caseCustomRef!=null) mapTable.put(lstTableContent[1], caseCustomRef); 
        else mapTable.put(lstTableContent[1], ''); 
        if(workOrdNum!=null) mapTable.put(lstTableContent[2], workOrdNum);
        else mapTable.put(lstTableContent[2], '');
        if(caseAsset!=null) mapTable.put(lstTableContent[3], caseAsset);
        else mapTable.put(lstTableContent[3], '');
        if(caseAssetSLNum!=null) mapTable.put(lstTableContent[4], caseAssetSLNum);
        else mapTable.put(lstTableContent[4], '');
        if(caseDesc!=null) mapTable.put(lstTableContent[5], caseDesc);
        else mapTable.put(lstTableContent[5], '');
        if(isClosed != true && workOrdNote!=null) mapTable.put(lstTableContent[6], workOrdNote);
        else mapTable.put(lstTableContent[6], '');
        if(isClosed == true && caseEndDate!=null) mapTable.put(lstTableContent[7], string.valueof(caseEndDate));
        else mapTable.put(lstTableContent[7], '');
        if(isClosed == true && workOrdSol!=null) mapTable.put(lstTableContent[8], workOrdSol);
        else mapTable.put(lstTableContent[8], '');
        return mapTable;
    } 
}