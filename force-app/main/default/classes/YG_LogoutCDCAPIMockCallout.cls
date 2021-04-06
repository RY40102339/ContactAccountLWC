/********************************************************************************************************
* (C) Copyright 2020 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Jayaprasath
* @version 1.0
* @created 02/04/2021
* @description 
* This class is used to write the Apex test class coverage for YG_LogoutCDCAPI.
*
*  Change History:
*  MM/DD/YYYY           Developer Name          Comments
*  
*
*/
@isTest
public class YG_LogoutCDCAPIMockCallout implements HttpCalloutMock {

    public HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setHeader('X-CLA-Code', YG_Constants.CL_CODE_SUCCESS);
        
        System.debug('request.getEndpoint() ::: '+request.getEndpoint());
        res.setBody(' { '+
                  '"connectedProviders": "facebook,site",'+
                  '"UID": "17704c1dxxxXXXXxXXxXxXXXxx3126c47",'+
                  '"logoutActiveSession": true,'+
                  '"statusCode": 200,'+
                  '"errorCode": 0,'+
                  '"statusReason": "OK",'+
                  '"callId": "ddb3f8e144c84cb5b1bc5f010bddab2b",'+
                  '"time": "2015-03-22T11:42:25.943Z"'+

                     '}');
                      
        res.setStatusCode(200);
        return res;
             
   }  
    
}