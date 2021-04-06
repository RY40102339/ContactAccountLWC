/********************************************************************************************************
* (C) Copyright 2020 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Vinod
* @version 1.0
* @created 20/11/2020
* @description 
* This class is used to write the Apex test class coverage for Derivative API Mock Callout.
*
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  
*  
*
*/

@isTest
public class YG_DirectiveAPIAndCertAPIMockCallout implements HttpCalloutMock{
    
    public HTTPResponse respond(HTTPRequest request) {
       
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setHeader('X-CLA-Code', YG_Constants.CL_CODE_SUCCESS);
        res.setHeader('X-CLA-Message', YG_Constants.X_CLA_Message);
        System.debug('request.getEndpoint() ::: '+request.getEndpoint());
       if(request.getEndpoint().contains('certificate/search1')){
            res.setBody('[ { '+
                        '"DirectiveNo": "0003",'+
                        '"DirectiveName": "Declaration of comformity",'+
                        '"Model": "EJA110E",'+
                        '"ModelName": "Differential Pressure Transmitter",'+
                        '"AdditionalNotes": "Morocco",'+
                        '"PassedCertNo": "AMA001-C01",'+
                        '"DownloadURL": "library.yokogawa.com/certificate/download1/AxkHnJ89/RDC-AMA0001/EN/"'+
                        '"CertSearchMemo": "",'+
                        '"PageNo": 1,'+
                        '"ViewCount": 1,'+
                        '"StartLine": 1,'+
                        '"EndLine": 1,'+
                        '"Count": 1'+
                        '}]');
       }else if(request.getEndpoint().contains('directivesearch/')){
           res.setBody('['+
                        '{'+
                        '"DirectiveNo": "0014",'+
                        '"DirectiveName": "Communication"'+
                        '},'+
                        '{'+
                        '"DirectiveNo": "0003",'+
                        '"DirectiveName": "Declaration of comformity"'+
                        '},'+
                        '{'+
                        '"DirectiveNo": "0001",'+
                        '"DirectiveName": "EAC (Non Ex)"'+
                        '},'+
                        '{'+
                        '"DirectiveNo": "0004",'+
                        '"DirectiveName": "Explosion protection (Ex)"'+
                        '},'+
                        '{'+
                        '"DirectiveNo": "0012",'+
                        '"DirectiveName": "Marine certificate"'+
                        '},'+
                        '{'+
                        '"DirectiveNo": "0011",'+
                        '"DirectiveName": "Radio"'+
                        '},'+
                        '{'+
                        '"DirectiveNo": "0013",'+
                        '"DirectiveName": "SIL"'+
                        '}'+
                        ']');
       }
        res.setStatusCode(200);
        return res;
    }
    
}