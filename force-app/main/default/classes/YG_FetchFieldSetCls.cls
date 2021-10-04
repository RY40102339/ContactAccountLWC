public with sharing class YG_FetchFieldSetCls {
    
    @AuraEnabled
    public static FieldSetForm getForm(Id recordId, String objectName, String fieldSetName, string chdildRecordtype, string childRecTypeName) {
        FieldSetForm form = new FieldSetForm(getFields(recordId, objectName, fieldSetName),chdildRecordtype,childRecTypeName);        
        system.debug('form>>>'+form.childRecordtype);    
        return form;
    }
    
    private static List<Field> getFields(Id recordId, String objectName, String fieldSetName) {
        Schema.SObjectType objectType = null;
        
        if (recordId != null)  objectType = recordId.getSobjectType();
        else if (String.isNotBlank(objectName)) objectType = Schema.getGlobalDescribe().get(objectName);
        
        Schema.DescribeSObjectResult objectDescribe = objectType.getDescribe();
        Map<String, Schema.FieldSet> fieldSetMap = objectDescribe.fieldSets.getMap();
        Schema.FieldSet fieldSet = fieldSetMap.get(fieldSetName);
        List<Schema.FieldSetMember> fieldSetMembers = fieldSet.getFields();

        List<Field> fields = new List<Field>();
        for (Schema.FieldSetMember fsm : fieldSetMembers) {
            Field f = new Field(fsm);
            fields.add(f);
        }
        return fields;
    }
    
    public class FieldSetForm {
        @AuraEnabled public List<Field> Fields = new List<Field>();
        @AuraEnabled public string childRecordtype;
        @AuraEnabled public string childRecordtypeName;
        public FieldSetForm(List<Field> Fields, string childRecordtype, string childRecordtypeName) {
            this.Fields=Fields;
            this.childRecordtype = childRecordtype;
            this.childRecordtypeName = childRecordtypeName;
        }
    }
}