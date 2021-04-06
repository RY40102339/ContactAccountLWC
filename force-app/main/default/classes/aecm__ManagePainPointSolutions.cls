/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class ManagePainPointSolutions {
    global ManagePainPointSolutions() {

    }
    @InvocableMethod(label='Create Or Delete Pain Point Solutions')
    global static List<aecm.ManagePainPointSolutions.ResultWrapper> processPainPoints(List<aecm.ManagePainPointSolutions.PainPointsWrapper> painPointsInput) {
        return null;
    }
global class PainPointsWrapper {
    @InvocableVariable(label='Existing Pain Point Solutions collection' required=false)
    global List<aecm__Pain_Point_Solutions__c> existingPainPointSolutions;
    @InvocableVariable(label='Program Project Status' required=false)
    global String programProjectStatus;
    @InvocableVariable(label='Selected Capability Pain Points string' required=false)
    global String selectedPainPointsStr;
    @InvocableVariable(label='Solution Design Record' required=true)
    global aecm__Solution_Design__c solutionDesign;
    global PainPointsWrapper() {

    }
}
global class ResultWrapper {
    @InvocableVariable(label='Message' required=false)
    global String message;
    @InvocableVariable(label='Message Type' required=false)
    global String messageType;
    global ResultWrapper() {

    }
}
}
