public with sharing class YG_FetchRecordtypeHandler {
   
    @AuraEnabled
    public static YG_FetchFieldSetCls.FieldSetForm fetchMainMethods(Id recordId,  String childObject) {
        String parentObject = recordId.getSObjectType().getDescribe().getName();

        string string_limit_1='select id,recordTypeId from ';
        string_limit_1=string_limit_1+parentObject;
        string_limit_1=string_limit_1+' '+'where id=\''+recordId+'\'';

        sObject sOb = Database.query(string_limit_1);

        String recordTypeids=string.valueOf(sOb.get('recordTypeId'));
        string recordTypeName = [Select id,Name,SobjectType from RecordType where id=: recordTypeids Limit 1].Name;
        
        string serchKey=parentObject+'-'+recordTypeName;
        YG_DefaultRecordType__mdt recordtypeChild=[select id,FieldSet__c,ChildRecordType__c from YG_DefaultRecordType__mdt where ParentRecordType__c=:serchKey LIMIT 1];
        string childRecordTypeId = fetchRecordType(childObject,recordtypeChild.ChildRecordType__c);
       
        YG_FetchFieldSetCls.FieldSetForm fieldForm = YG_FetchFieldSetCls.getForm(null,childObject,recordtypeChild.FieldSet__c,childRecordTypeId,recordtypeChild.ChildRecordType__c);
        
        system.debug('fieldForm>>>>'+fieldForm);
        return fieldForm;
    }

    private static string fetchRecordType(String objectName, String recordTypeName){
        SObjectType objToken = Schema.getGlobalDescribe().get(objectName);
        DescribeSObjectResult objDef = objToken.getDescribe();
        Map<String,Schema.RecordTypeInfo> rtMapByName = objDef.getRecordTypeInfosByName();
        Schema.RecordTypeInfo rtByName =  rtMapByName.get(recordTypeName);
        string recid = rtByName.getRecordTypeId();

        system.debug('recid>>>'+recid);
        return recid;
    }
}