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
*/

public with sharing class YODA_Contact_TriggerHelper {
    // Only used in after insert; Self-updates the region field to get around the MailCountry picklist/String issue
    // Kam 9/9/2021
    public static void updateContact(List<Contact> cons){
        List<Contact> newConList = [SELECT AccountID, Email, MailingAddress, MailingCity, MailingCountry, 
                                    MailingPostalCode, MailingState, MailingStreet, Region__c, OwnerID,
                                    Account.BillingCity, Account.BillingCountry, Account.BillingPostalCode, Account.BillingState, Account.BillingStreet,
                                    Account.ShippingCity, Account.ShippingCountry, Account.ShippingPostalCode, Account.ShippingState, Account.ShippingStreet
                                    FROM Contact 
                                    WHERE ID IN :cons WITH SECURITY_ENFORCED];

		
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
        String finString = [SELECT Region__c From User Where Id = :owner WITH SECURITY_ENFORCED].Region__c; // Default case
        // Based on MailingCountry, return the appropriate Region
        
        finString = regionSwitch(mailingCountry, finString);

        return finString;
    }
}