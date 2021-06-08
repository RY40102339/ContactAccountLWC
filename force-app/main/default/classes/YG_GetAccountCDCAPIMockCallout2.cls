/********************************************************************************************************
* (C) Copyright 2020 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Vinod
* @version 1.0
* @created 18/05/2021
* @description 
* This class is used to write the Apex test class coverage for YG_GetAccountCDCAPI.
*
*  Change History:
*  MM/DD/YYYY           Developer Name          Comments
*  
*
*/

@isTest
public class YG_GetAccountCDCAPIMockCallout2 implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest request) {
       
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setHeader('X-CLA-Code', YG_Constants.CL_CODE_SUCCESS);
        
        System.debug('request.getEndpoint() ::: '+request.getEndpoint());
        res.setBody('{ '+
              '"callId": "daba91000c0141f499343054d53b8627",'+
              '"errorCode": 0,'+
              '"apiVersion": 2,'+
              '"statusCode": 200,'+
              '"statusReason": "OK",'+
              '"time": "2021-02-02T09:28:43.037Z",'+
              '"registeredTimestamp": 1607669228000,'+
              '"UID": "48207f845b854397b19b40e972156b62",'+
              '"created": "2020-12-11T06:47:08.492Z",'+
              '"createdTimestamp": 1607669228000,'+
              '"data": {'+
                '"ProfileID": "00ep0000000IVAO",'+
                '"account_number": "1234567",'+
                '"login_permission_customerportal": "on",'+
                '"language": "en",'+
                '"custportal_userID": "anand.selvarasu-20201211064708@verticurl.com",'+
                '"login_permission_snow": "false",'+
                '"customerportal": {'+
                  '"role": "CA"'+
                '},'+
                '"phone": "911234567890",'+
                '"companyname": "Verticurl",'+
                '"snow": {'+
                  '"primaryadmin": "false"'+
                '},'+
                '"idportal_auth": "1",'+
                '"job_title": "Verticurl",'+
                '"account": "Verticurl"'+
              '},'+
              '"subscriptions": {},'+
              '"preferences": {'+
                '"terms": {'+
                  '"lca_terms": {'+
                    '"isConsentGranted": true,'+
                    '"docDate": "2020-04-19T00:00:00Z",'+
                    '"lastConsentModified": "2020-12-11T06:47:08.617Z",'+
                    '"tags": [],'+
                    '"customData": [],'+
                    '"entitlements": []'+
                  '}'+
                '},'+
                '"privacy": {'+
                  '"lca_privacy": {'+
                    '"isConsentGranted": true,'+
                    '"docDate": "2020-04-23T00:00:00Z",'+
                    '"lastConsentModified": "2020-12-11T06:47:08.617Z",'+
                    '"tags": [],'+
                    '"customData": [],'+
                    '"entitlements": []'+
                  '}'+
                '}'+
              '},'+
              '"emails": {'+
                '"verified": ['+
                  '"anand.selvarasu@verticurl.com"'+
                '],'+
                '"unverified": ['+
                  '"anand123.selvarasu@verticurl.com"'+
                ']'+
              '},'+
              '"isActive": true,'+
              '"isRegistered": true,'+
              '"isVerified": true,'+
              '"lastLogin": "2021-02-02T06:33:10.283Z",'+
              '"lastLoginTimestamp": 1612247590000,'+
              '"lastUpdated": "2021-01-28T05:24:58.176Z",'+
              '"lastUpdatedTimestamp": 1611811498176,'+
              '"loginProvider": "site",'+
              '"oldestDataUpdated": "2020-12-11T06:47:08.492Z",'+
              '"oldestDataUpdatedTimestamp": 1607669228492,'+
              '"profile": {'+
                '"firstName": "Anand",'+
                '"lastName": "Selvarasu",'+
                '"address": "Testing",'+
                '"country": "IN",'+
                '"email": "anand.selvarasu@verticurl.com",'+
                //'"email": "yg.test@gmail.com",'+
                '"phones": {'+
                  '"number": "+911234567890"'+
                '},'+
                '"photoURL": "https://dev1-yg.cs31.force.com/servlet/servlet.ImageServer?id=015p0000000kzJgAAI&oid=00Dp00000004u6mEAA",'+
                '"zip": "641002"'+
              '},'+
              '"registered": "2020-12-11T06:47:08.763Z",'+
              '"socialProviders": "site",'+
              '"verified": "2021-01-21T15:48:10.580Z",'+
              '"verifiedTimestamp": 1611244090580'+
              
            '}');
                      
        res.setStatusCode(200);
        return res;
    }

}