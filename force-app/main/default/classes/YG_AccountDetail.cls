public with sharing class YG_AccountDetail {
    public String selectedRequestType{get;set;}
    private final Account account;
    public String selectedCustomerType{get;set;}

    public YG_AccountDetail() {
        selectedRequestType =ApexPages.currentPage().getParameters().get('selectedRequestType');
        selectedCustomerType =ApexPages.currentPage().getParameters().get('selectedCustomerType');
        account = [SELECT Id, Name,YODA_Account_Number__c,NameLocal,Short_Name__c,Short_Name_Local__c,
                    Integration_YGSSAP_Id__c,Region__c,Industry__r.Integration_Id__c,
                    Type,CurrencyIsoCode,Sales_Organization__c,Distribution_Channel__c,Payment_Mode__c,Credit_Term__c,
                    VAT_Number__c,Tax_Reg_No__c,Payment_Terms__c,Incoterms__c,Email__c,Fax,Website,Phone,ShippingCountry,
                    ShippingState,ShippingStreet,Street_Local__c,ShippingCity,City_Local__c,ShippingPostalCode,CreatedBy.Name,
                    LastModifiedBy.Name,CreatedDate,LastModifiedDate,Description,Industry_Code__c FROM Account
                    WHERE Id = :ApexPages.currentPage().getParameters().get('accID')];
    }
    public Account getAccount() {
        return account;
    }

    //testing purpose
}
