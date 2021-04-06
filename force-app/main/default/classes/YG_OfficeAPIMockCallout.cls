/*
*******************************************************************************************************
* (C) Copyright 2020 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Chitrakishore
* @version 1.0
* @created 27/01/2021
* @description 
* This class is used to write the Apex test class coverage for Case API Mock Callout.
*
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  
*  
*
*/

@isTest
public class YG_OfficeAPIMockCallout implements HttpCalloutMock{
    
    public HTTPResponse respond(HTTPRequest request) {
       
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setHeader('X-CLA-Code', YG_Constants.CL_CODE_SUCCESS);
        
        System.debug('request.getEndpoint() ::: '+request.getEndpoint());
        res.setBody('[ { '+
                  		'"entity_group" : [ {'+
                        '"office_fax_number" : "(81)-422-52-6440",'+
                        '"office_phone_number" : "(81)-422-52-0439",'+
                        '"address_language" : "EN",'+
                        '"address" : "2-9-32 Nakacho, Musashino-Shi",'+
                        '"region_name_language" : "EN",'+
                        '"region_name" : "Tokyo",'+
                        '"region" : "13",'+
                        '"postal_code" : "180-8750",'+
                        '"office_type_name_language" : "EN",'+
                        '"office_type_name" : "Legal entity",'+
                        '"office_type" : "1",'+
                        '"entity_status" : "1",'+
                        '"entity_country_language" : "EN",'+
                        '"entity_country_name" : "Japan",'+
                        '"entity_country" : "JP",'+
                        '"entity_name_language" : "EN",'+
                        '"entity_name" : "Head office",'+
                        '"entity_code" : "1",'+
                        '"company_status" : "1",'+
                        '"company_country_language" : "EN",'+
                        '"company_country_name" : "Japan",'+
                        '"company_country" : "JP",'+
                        '"company_name_language" : "EN",'+
                        '"company_name" : "Yokogawa Solution Service Corporation",'+
                        '"company_code" : "1T00"'+
                      '} ],'+
                      '"classification_country_language" : "EN",'+
                      '"classification_country_name" : "Japan",'+
                      '"classification_country" : "JP",'+
                      '"classification_name" : "Sales YCO",'+
                      '"classification_code" : "0002"'+
                    '}, {'+
                      '"entity_group" : [ {'+
                        '"office_fax_number" : "(81)-422-52-6440",'+
                        '"office_phone_number" : "(81)-422-52-0439",'+
                        '"address_language" : "EN",'+
                        '"address" : "2-9-32 Nakacho, Musashino-Shi",'+
                        '"region_name_language" : "EN",'+
                        '"region_name" : "Tokyo",'+
                        '"region" : "13",'+
                        '"postal_code" : "180-8750",'+
                        '"office_type_name_language" : "EN",'+
                        '"office_type_name" : "Legal entity",'+
                        '"office_type" : "1",'+
                        '"entity_status" : "1",'+
                        '"entity_country_language" : "EN",'+
                        '"entity_country_name" : "Japan",'+
                        '"entity_country" : "JP",'+
                        '"entity_name_language" : "EN",'+
                        '"entity_name" : "Head office",'+
                        '"entity_code" : "1",'+
                        '"company_status" : "1",'+
                        '"company_country_language" : "EN",'+
                        '"company_country_name" : "Japan",'+
                        '"company_country" : "JP",'+
                        '"company_name_language" : "EN",'+
                        '"company_name" : "Yokogawa Solution Service Corporation",'+
                        '"company_code" : "1T00"'+
                      '} ],'+
                      '"classification_country_language" : "EN",'+
                      '"classification_country_name" : "Japan",'+
                      '"classification_country" : "JP",'+
                      '"classification_name" : "Service YCO",'+
                      '"classification_code" : "0003"'+                
            '}]');
                      
        res.setStatusCode(200);
        return res;
    }

}