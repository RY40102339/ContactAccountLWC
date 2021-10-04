public with sharing class YG_SAP_AccountRegistrationForm {
    public String selectedRequestType{get;set;}
    public String selectedCustomerType{get;set;}
    public account acctDetail;
    
    public YG_SAP_AccountRegistrationForm(ApexPages.StandardController controller) {
        acctDetail = (Account)controller.getRecord();
    }

    public PageReference saveAndRedirect() {
        PageReference redirect = new PageReference('/apex/YG_AccountRegistrationForm');
        redirect.getParameters().put('accID',acctDetail.Id);
        redirect.getParameters().put('selectedRequestType',selectedRequestType);
        redirect.getParameters().put('selectedCustomerType',selectedCustomerType);
        redirect.setRedirect(true);
        return redirect;
    } 
}