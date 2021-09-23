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
*  9/23/2021            Kameron F.              Updated API names for region
*/

public with sharing class YODA_Contact_TriggerHelper {
    // Only used in after insert; Self-updates the region field to get around the MailCountry picklist/String issue
    // Kam 9/9/2021
    public static void UpdateRegion(List<Contact> Cons){
        // Ensures that method only runs when the Region is null
        if(Cons[0].Region__c == Null){
            
            List<Contact> newConList = [SELECT MailingCountry, Region__c FROM Contact WHERE ID IN :Cons];
            
            for(Contact Con: newConList){
                Con.Region__c = getRegion(Con.MailingCountry);
            }

            // Self-updating to update Contact
            try{
                update newConList;
            }catch(Exception ex){
                system.debug('Exception : '+ex.getMessage());
            }
        }
    }

    // Based on the MailingCountry field on Contact, return the relevant region (Case-sensitive);
    // Kam 9/9/2021
    public static String getRegion(String MailingCountry){
        String finString = 'None'; // Default case
        // Based on MailingCountry, return the appropriate Region
        switch on MailingCountry {
            when 'Aruba','Anguilla','Netherlands Antilles','Antigua and Barbuda','Bahamas','Belize','Bermuda','Barbados','Canada','Costa Rica','Côte d\'Ivoire','Cayman Islands','Dominica','Dominican Republic','Guadeloupe','Grenada','Guatemala','Honduras','Haiti','Jamaica','Saint Kitts AND Nevis','Mexico','Northern Mariana Islands','Nicaragua','Panama','Puerto Rico','El Salvador','Turks and Caicos Islands','Trinidad and Tobago','United States Minor Outlying Islands','United States','Saint Vincent and the Grenadines','Virgin Islands, British','Virgin Islands (U.S.)','Saint Lucia'{
                finString = 'YCA';//'North America';
            }
            when 'Korea, Democratic People\'s Republic of','Korea, Republic of'{
                finString = 'YKO';//'Korea';
            }
            when 'China','Hong Kong','Macao'{
                finString = 'YCN';//'China';
            }
            when 'Australia','Cocos Islands','Christmas Island','Fiji','Heard Island and McDonald Islands','Indonesia','Norfolk Island','Papua New Guinea','Maldives','Singapore','New Zealand','Cambodia','Myanmar','Brunei Darussalam','Malaysia','Cook Islands','Tokelau','Philippines','Thailand','Viet Nam','BANGLADESH','BHUTAN','INDIA','SRI LANKA','MALDIVES','NEPAL','Pakistan','Taiwan'{
                finString = 'YEA';//'Asean & Oceania';
            }
            when 'Albania','Andorra','Austria','Bosnia and Herzegovina','Bulgaria','Croatia','Czechia','France','French Guiana','French Polynesia','French Southern Territories','Hungary','Ireland','Macedonia','Martinique','Mayotte','Monaco','Montenegro','New Caledonia','Norway','Poland','Portugal','Réunion','Romania','Serbia','Slovakia','Slovenia','Spain','Saint Pierre and Miquelon','Switzerland','Turkey','Wallis and Futuna','Bouvet Island','Denmark','Estonia','Faroe Islands','Finland','Greenland','Iceland','Israel','Latvia','Lithuania','Netherlands','Svalbard and Jan Mayen','Sweden','Belgium','Luxembourg','British Indian Ocean Territory','Virgin Islands (British)','Gibraltar','Montserrat','Pitcairn','Saint Helena','Ascension and Tristan da Cunha','South Georgia and the South Sandwich Islands','United Kingdom of Great Britain and Northern Ireland','Germany','Liechtenstein','Cyprus','Greece','Italy','Malta','San Marino','Holy See'{
                finString = 'YEF';//'Europe';
            }
            when 'Algeria','Angola','Bahrain','Benin','Botswana','Burkina Faso','Burundi','Cameroon','Cabo Verde','Central African Republic','Chad','Comoros','Congo (the Democratic Republic of the)','Djibouti','Egypt','Equatorial Guinea','Eritrea','Ethiopia','Gabon','Gambia','Ghana','Guinea','Guinea-Bissau','Iraq','Jordan','Kenya','Kuwait','Lebanon','Lesotho','Liberia','Libya','Madagascar','Malawi','Mali','Mauritius','Mauritania','Morocco','Mozambique','Namibia','Niger','Nigeria','Oman','Qatar','Rwanda','Congo','Sao Tome and Principe','Saudi Arabia','Senegal','Seychelles','Sierra Leone','Somalia','South Africa','Sudan','South Sudan','Eswatini','Syrian Arab Republic','Tanzania','United Republic of','Togo','Tunisia','United Arab Emirates','Uganda','Western Sahara','Yemen','Zambia','Zimbabwe'{
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
            when 'Afghanistan','Antarctica','Timor-Leste','Falkland Islands','Georgia','Iran','Kiribati','Marshall Islands','Micronesia','Nauru','Niue','Palau','Palestine','State of','Samoa','Solomon Islands','Tonga','Tuvalu','Vanuatu','Mongolia'{
                finString = 'Global';//'Global';
            }
        }

        return finString;
    }
}