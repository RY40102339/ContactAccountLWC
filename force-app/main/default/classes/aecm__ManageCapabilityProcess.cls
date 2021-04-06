/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class ManageCapabilityProcess {
    global ManageCapabilityProcess() {

    }
    @InvocableMethod(label='Create Or Delete Capability Process')
    global static List<aecm.ManageCapabilityProcess.ResultWrapper> processCapability(List<aecm.ManageCapabilityProcess.CapabilitiesWrapper> CapabilitiesInput) {
        return null;
    }
global class CapabilitiesWrapper {
    @InvocableVariable(label='Existing Capability Process collection' required=false)
    global List<aecm__Capability_Process__c> existingCapabilityProcess;
    @InvocableVariable(label='Process Record' required=true)
    global aecm__Process__c Process;
    @InvocableVariable(label='Selected Capability collection' required=false)
    global List<aecm__Capability__c> selectedCapability;
    global CapabilitiesWrapper() {

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
