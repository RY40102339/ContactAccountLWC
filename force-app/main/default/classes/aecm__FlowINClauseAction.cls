/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class FlowINClauseAction {
    global FlowINClauseAction() {

    }
    @InvocableMethod(label='Get records with IN clause filter')
    global static List<aecm.FlowINClauseAction.FlowOutputParameters> filterRecords(List<aecm.FlowINClauseAction.FlowInputParameters> input) {
        return null;
    }
global class FlowInputParameters {
    @InvocableVariable(label='Fields to query(Comma seperated)' required=true)
    global String fieldsToQuery;
    @InvocableVariable(label='Field Api name for IN Clause filter' required=true)
    global String filterField;
    @InvocableVariable(label='Text type collection of filter values' required=true)
    global List<String> filteringValuesCollection;
    @InvocableVariable(label='Api name of the Object' required=true)
    global String objectApiName;
    global FlowInputParameters() {

    }
}
global class FlowOutputParameters {
    @InvocableVariable(label='Record Collection' required=false)
    global List<SObject> records;
    global FlowOutputParameters() {

    }
}
}
