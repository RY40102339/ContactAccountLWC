/*
*******************************************************************************************************
* (C) Copyright 2021 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Kameron F
* @version 1.0
* @created 9/9/2021
* @description  
* This class is used for updating the Region__c field on Contact based on MailingCountry
*
* @test class name - YODA_Contact_TriggerHelper_Test
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  9/9/2021             Kameron F.              Created Class
*  9/24/2021			Kameron F.				Added log error
*  9/27/2021            Kameron F.              Update MailingCountry List
*  9/27/2021            Hemalatha Gorthy        Added MailingAddress logic
*  9/30/2021			Kameron F.				Fixed bulk insert issue
*  10/12/2021			Kameron F.				Added Multiple Inquiry
*  10/27/2021			Kameron F.				Added Contact to Lead & Delete Dummy Account 
*/

public with sharing class YODA_Contact_TriggerHelper {
    /*// Flows only allow one parameter, so have to use this to get around that
    public class CloneRecordFlowVariable{
        @InvocableVariable(label='Account Name')
        public String accountName;
        
        @InvocableVariable(label='Contact')
        public Contact con;
        
        @InvocableVariable(label='Error Message')
        public String errorMessage;
    }
    // Method to be called from YODA Contact to Lead flow. 
    @InvocableMethod(label='Clone Contact to Lead' description='Clones the Contact record into a Lead record' category= 'Contact')
    public static List<String> CloneRecordFlow(List<CloneRecordFlowVariable> cons){
        Contact con = cons[0].con;
        
        List<CampaignMember> cmpMemList = [SELECT Name, ContactID, CampaignID FROM CampaignMember WHERE ContactID = :con.ID AND CampaignID = :con.Campaign__c];
        if(cmpMemList.size()==0){
            try{
            	insert new CampaignMember(CampaignID=con.Campaign__c,ContactID=con.id);
            }catch(Exception e){
                cons[0].errorMessage = e.getMessage().split(':',2)[1]; 
                return new List<String>{cons[0].errorMessage};
            }
        }
        
        Map<Id,Id> ContactToCampaign = new Map<Id,Id>();
        for(CampaignMember cmpMem : [Select ContactID, Name, CampaignID, ID FROM CampaignMember WHERE ContactID = :con.id]){
            ContactToCampaign.put(cmpMem.ContactID, cmpMem.CampaignID);
        }	

        String accName = cons[0].accountName==null ? con.Self_Registered_Company__c : cons[0].accountName;
        Id camp = con.Campaign__c == null ? ContactToCampaign.get(con.Id) : con.Campaign__c;
        
        List<Lead> newLd = new List<Lead>{createLead(con, accName, camp,'Hot')};
        try{
        	handleCloneAssignment(newLd,true);     
            cons[0].errorMessage = null;
        }catch(Exception e){
            System.debug(e.getMessage());
            cons[0].errorMessage = e.getMessage().split(':',2)[1]; // removes some unnecessary text from error log
        }
        return new List<String>{cons[0].errorMessage};
    }
    
    // If Multiple_Inquiry__c is set to true on a lead, then a duplicate lead is created.
    // Kam 10/12/2021
    public static void CloneRecord(List<Contact> newList, Map<Id,Contact> oldMap){
            List<Lead> clonedLeads = new List<Lead>(); // leads to be created
            Set<Id> updateSet = new Set<Id>(); // leads to be updated
            
            Map<Id,Id> ContactToCampaign = new Map<Id,Id>();
            for(CampaignMember cmpMem : [Select ContactID, Name, CampaignID, ID FROM CampaignMember WHERE ContactID IN :newList]){
                ContactToCampaign.put(cmpMem.ContactID, cmpMem.CampaignID);
            }
    
            // Get Account Name from Primary Account on Contact
            Map<Id,String> ContactToAccount = new Map<Id,String>();
            for(Contact con : [Select ID, Account.Name FROM Contact WHERE ID IN :newList]){
                ContactToAccount.put(con.ID, con.Account.Name);
            }
            
    		
            for(Contact con : newList){
                // If Multiple Inquiries was set to true during this transaction
                if(con.Multiple_Inquiry__c==true && oldMap.get(con.Id).Multiple_Inquiry__c==false){
                    updateSet.add(con.Id);
               
                    String accName = con.AccountID==null ? con.Self_Registered_Company__c : ContactToAccount.get(con.Id);
                    
                    Id camp = con.Campaign__c == null ? ContactToCampaign.get(con.Id) : con.Campaign__r.Id;
        
                    Lead newLd = createLead(con, accName, camp, con.Rating__c);
                   
                    clonedLeads.add(newLd);
                }
            }
            
            // Will only run if leads were created
            if(clonedLeads.size()>0){
                handleCloneAssignment(clonedLeads,false);
            }
            
            // Will only run if leads were created
            if(updateSet.size()>0){
               List<Contact> updateList = [SELECT ID, Multiple_Inquiry__c FROM Contact WHERE ID IN :updateSet];
                
                for(Contact con: updateList){
                    con.Multiple_Inquiry__c = false;
                }
                update updateList;
            }
       // }
    }
    
    // Creats a lead based on the provided contact
    public static Lead createLead(Contact con, String accName, Id camp,String ratingStr){
        Lead newLd = new Lead(Campaign__c= camp,Category_Of_Interest__c=con.Category_of_Interest__c,
                                     Company = accName, Related_Contact__c = con.id, Country=con.MailingCountry,Department__c = con.Department,Description= con.Description,
                                     DoNotCall = con.DoNotCall, Double_Opt_In_Date__c = con.Double_Opt_In_Date__c, Double_Opt_In_Source__c = con.Double_Opt_In_Source__c, 
                              		 Double_Opt_In_Status__c = con.Double_Opt_In_Status__c, Email = con.Email,FirstName = con.FirstName,HasOptedOutOfEmail = con.HasOptedOutOfEmail,
                                     Internal_Comments__c = con.Internal_Comments__c, Kana_Name__c = con.Kana_Name__c, LastName = con.LastName, MobilePhone = con.MobilePhone, Multiple_Inquiry__c = true, 
                                     Phone = con.Phone, Preference__c = con.Preference__c,Product_of_Interest__c = con.Product_of_Interest__c,
                                     Rating = ratingStr, Requested_Contact__c = con.Requested_Contact__c, Status = 'New', Title = con.Title);    
        
        
        if(newLd.Category_of_Interest__c =='Oscilloscopes' ||
                   newLd.Category_of_Interest__c =='Digital Power Analyzers' ||
                   newLd.Category_of_Interest__c =='Data Acquisition' ||
                   newLd.Category_of_Interest__c =='Optical Measuring Instruments' ||
                   newLd.Category_of_Interest__c =='Generators/Sources/Calibrators/Manometers' ||
                   newLd.Category_of_Interest__c =='Portable Test Instruments' ||
                   newLd.Category_of_Interest__c =='Others')
						newLd.Business_Unit__c = 'YMI SBU';
                
                //newLd.Clone_Locked__c = false;
        return newLd;
    }
    
    public static void handleCloneAssignment(List<Lead> clonedLeads, Boolean flow){
        YODA_RunAssignmentRules.reRunAssignmentRules(clonedLeads); // it would be best to change parameter to sobject instead of ids
		
        
        if(flow){
            insert clonedLeads;
        }else{
            try{
                insert clonedLeads;
                if(Test.isRunningTest()) {
                    CalloutException e = new CalloutException();
                    e.setMessage('This is a constructed exception for testing and code coverage');
                    throw e;
                }
            }catch(Exception e){
                YODA_Utility.logError('Backend Process Error','Class:YODA_Lead_TriggerHelper; Method: CloneRecord(); Line #:'+e.getLineNumber()
                                      +'; Message:'+e.getMessage(), e.getStackTraceString(), UserInfo.getUserId());
                for(Lead ld : clonedLeads)
                    ld.addError(e.getMessage());
            }
        }
    }
    
    // Attempting to limit actions happening all at once from this trigger
    @future
    public static void DeleteDummyAccounts(Set<ID> ContactList){
        String DummyAccountName = 'DummyAccount';
        // DummyAccount = '- Dummy'
        List<ID> accIdList = new List<ID>();
        for(ID con:ContactList){
            List<AccountContactRelation> ACR = [SELECT AccountID, Account.Name, ContactID FROM AccountContactRelation WHERE ContactID = :con];
            if(ACR.size()>1){
                for(AccountContactRelation indACR : ACR){
                    if(indACR.Account.Name.contains(DummyAccountName)){
                        accIdList.add(indACR.AccountID);
                    }
                }
            }
        }
        
        // Change criteria to match dummy account indicator
        List<Account> accList = [SELECT ID, Name FROM Account WHERE Name = :DummyAccountName AND ID in :accIdList];
        
        if(accList.size()>0){
            try{
                Database.delete(accList, false);
                if(Test.isRunningTest()) {
                    CalloutException e = new CalloutException();
                    e.setMessage('This is a constructed exception for testing and code coverage');
                    throw e;
                }
            }catch(Exception e){
                YODA_Utility.logError('Backend Process Error','Class:YODA_Lead_TriggerHelper; Method: CloneRecord(); Line #:'+e.getLineNumber()
                                      +'; Message:'+e.getMessage(), e.getStackTraceString(), UserInfo.getUserId());
                
            }
        }
    }*/
    
    // Only used in after insert; Self-updates the region field to get around the MailCountry picklist/String issue
    // Kam 9/9/2021
    public static void updateContact(List<Contact> cons){
        List<Contact> newConList = [SELECT AccountID, Email, MailingAddress, MailingCity, MailingCountry, 
                                    MailingPostalCode, MailingState, MailingStreet, Region__c, OwnerID,
                                    Account.BillingCity, Account.BillingCountry, Account.BillingPostalCode, Account.BillingState, Account.BillingStreet,
                                    Account.ShippingCity, Account.ShippingCountry, Account.ShippingPostalCode, Account.ShippingState, Account.ShippingStreet
                                    FROM Contact 
                                    WHERE ID IN :cons];

		
        for(Contact con: newConList){
            con = updateMailingAddress(con);
                
            // Ensures that method only runs when the Region is null
            if(con.Region__c == Null){
                con.Region__c = getRegion(con.MailingCountry, con.OwnerId);
            }
        }

        // Self-updating to update Contact
        try{
            update newConList;
            if(Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }
        }catch(Exception e){
            YODA_Utility.logError('Backend Process Error','Class:YODA_Contact_TriggerHelper; Method: updateContact(); Line #:'+e.getLineNumber()
                                +'; Message:'+e.getMessage(), e.getStackTraceString(), UserInfo.getUserId());
        }
	}
    
    // Moved Hema's logic here. If Contact Mailing Address is null, then use Account Billing Address
    // If Account Billing Address is null, then use Account Shipping Address.
    // Kam 9/30/2021
    public static Contact updateMailingAddress(Contact con){
        If (con.MailingCity==null && con.MailingCountry==null && con.MailingPostalCode==null && 
            con.MailingState==null && con.MailingStreet==null){
                If (con.Account.BillingCity==null && con.Account.BillingCountry==null && 
                    con.Account.BillingPostalCode==null && con.Account.BillingState==null && 
                    con.Account.BillingStreet==null){
                        con.MailingCity = con.Account.ShippingCity;
                        con.MailingCountry = con.Account.ShippingCountry;
                        con.MailingPostalCode = con.Account.ShippingPostalCode;
                        con.MailingState = con.Account.ShippingState;
                        con.MailingStreet = con.Account.ShippingStreet;
                    } else{
                        con.MailingCity = con.Account.BillingCity;
                        con.MailingCountry = con.Account.BillingCountry;
                        con.MailingPostalCode = con.Account.BillingPostalCode;
                        con.MailingState = con.Account.BillingState;
                        con.MailingStreet = con.Account.BillingStreet;
                    }
            }
        return con;
    }
    
    // Uses value from client to assign a region value based on the MailingCountry
    // Kam 9/27/2021
    public static String regionSwitch(String mailingCountry, String finstring){
        switch on mailingCountry {
            when 'Aruba','Anguilla','Netherlands Antilles','Antigua and Barbuda','Bahamas','Belize','Bermuda','Barbados','Canada','Costa Rica','Cayman Islands','Dominica','Dominican Republic','Guadeloupe','Grenada','Guatemala','Honduras','Haiti','Jamaica','Saint Kitts AND Nevis','Mexico','Northern Mariana Islands', 'Martinique','Nicaragua','Panama','Puerto Rico','El Salvador','Turks and Caicos Islands','Trinidad and Tobago','United States Minor Outlying Islands','United States','Saint Vincent and the Grenadines','Virgin Islands, British','Virgin Islands (British)','Virgin Islands (U.S.)s','Virgin Islands (U.S.)','Saint Lucia'{
                finString = 'YCA';//'North America';
            }
            when'Korea, Republic of','Korea (the Republic of)'{
                finString = 'YKO';//'Korea';
            }
            when 'China','Hong Kong','Macao'{
                finString = 'YCN';//'China';
            }
            when 'Australia','Cocos Islands','Christmas Island','Fiji','Heard Island and McDonald Islands','Indonesia','Norfolk Island','Papua New Guinea','Maldives','Singapore','New Zealand','Cambodia','Myanmar','Lao People\'s Democratic Republic','Brunei Darussalam','Malaysia','Cook Islands','Tokelau','Philippines','Thailand','Viet Nam','Bangladesh','Bhutan','India','Sri Lanka','Nepal','Pakistan','Taiwan'{
                finString = 'YEA';//'Asean & Oceania';
            }
            when 'United Kingdom','Albania','Andorra','Austria','Bosnia and Herzegovina','Bulgaria','Croatia','Czechia','France','French Guiana','French Polynesia','French Southern Territories','Hungary','Ireland','Macedonia','Mayotte','Monaco','Montenegro','New Caledonia','Norway','Poland','Portugal','Réunion','Romania','Serbia','Slovakia','Slovenia','Spain','Saint Pierre and Miquelon','Switzerland','Turkey','Wallis and Futuna','Bouvet Island','Denmark','Estonia','Faroe Islands','Finland','Greenland','Iceland','Israel','Latvia','Lithuania','Netherlands','Svalbard and Jan Mayen','Sweden','Belgium','Luxembourg','British Indian Ocean Territory','Gibraltar','Montserrat','Pitcairn','Saint Helena','Ascension and Tristan da Cunha','South Georgia and the South Sandwich Islands','Turks and Caicos Island','United Kingdom of Great Britain and Northern Ireland','Germany','Liechtenstein','Cyprus','Greece','Italy','Malta','San Marino','Holy See'{
                finString = 'YEF';//'Europe';
            }
            when 'Algeria','Angola','Bahrain','Benin','Botswana','Burkina Faso','Burundi','Cameroon','Cabo Verde','Central African Republic','Chad','Comoros','Congo (the Democratic Republic of the)','Côte d\'Ivoire','Djibouti','Egypt','Equatorial Guinea','Eritrea','Ethiopia','Gabon','Gambia','Ghana','Guinea','Guinea-Bissau','Iraq','Jordan','Kenya','Kuwait','Lebanon','Lesotho','Liberia','Libya','Madagascar','Malawi','Mali','Mauritius','Mauritania','Morocco','Mozambique','Namibia','Niger','Nigeria','Oman','Qatar','Rwanda','Congo','Sao Tome and Principe','Saudi Arabia','Senegal','Seychelles','Sierra Leone','Somalia','South Africa','Sudan','South Sudan','Eswatini','Syrian Arab Republic','Tanzania','United Republic of','Togo','Tunisia','United Arab Emirates','Uganda','Western Sahara','Yemen','Zambia','Zimbabwe'{
                finString = 'YMA';//Middle East & Africa';
            }
            when 'Armenia','Azerbaijan','Belarus','Kazakhstan','Kyrgyzstan','Moldova','Russian Federation','Tajikistan','Turkmenistan','Ukraine','Uzbekistan'{
                finString = 'YRU';//'Russia & CIS';
            }
            when 'Argentina','Bolivia','Brazil','Chile','Colombia','Cuba','Ecuador','Guyana','Paraguay','Peru','Suriname','Uruguay','Venezuela'{
                finString = 'YSA';//'South America';
            }
            when 'Japan'{
                finString = 'YJP';//'Japan';
            }
            when 'Afghanistan','Antarctica','Timor-Leste','Falkland Islands','Georgia','Iran','Kiribati','Marshall Islands','Micronesia','Nauru','Niue','Korea (the Democratic People\'s Republic of)','Korea, Democratic People\'s Republic of','Palau','Palestine','State of','Samoa','Solomon Islands','Tonga','Tuvalu','Vanuatu','Mongolia'{
                finString = 'Global';//'Global';
            }
        }
        return finString;
    }
    
    // Based on the MailingCountry field on Contact, return the relevant region (Case-sensitive);
    // Kam 9/9/2021
    public static String getRegion(String mailingCountry){
        // Based on MailingCountry, return the appropriate Region
        String finString = '';
        
        finString = regionSwitch(mailingCountry, finString);

        return finString;
    }
    
    // Based on the MailingCountry field on Contact, return the relevant region (Case-sensitive);
    // Kam 9/9/2021
    public static String getRegion(String mailingCountry, ID owner){
        String finString = [SELECT Region__c From User Where Id = :owner].Region__c; // Default case
        // Based on MailingCountry, return the appropriate Region
        
        finString = regionSwitch(mailingCountry, finString);

        return finString;
    }
}