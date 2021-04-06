/*
*******************************************************************************************************
* (C) Copyright 2020 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Chitrakishore
* @version 1.0
* @created 02/03/2021
* @description 
* This class is used to write the Apex test class coverage for Product API Mock Callout.
*
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  
*  
*
*/

@isTest
public class YG_ProductAPIMockCallout implements HttpCalloutMock{
    
    
		public HTTPResponse respond(HTTPRequest request) {
       
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setHeader('X-CLA-Code', YG_Constants.CL_CODE_SUCCESS);
        
        System.debug('request.getEndpoint() ::: '+request.getEndpoint());
        res.setBody('[{'+
                    '"SerialNo": "91U601404",'+
                    '"ModelCode": "EJXC40A",'+
                    '"MSCode": "EJXC40A-D55RWTWTB-11/EC5/Z",'+
                    '"ProductName": "Digital Remote Sensor",'+
                    '"ProductCareer": "S1",'+
                    '"TokuchuNo": "ATL09553-0001-002",'+
                    '"XJNo": "XJEJWC40-D7",'+
                    '"LinkageNo": null,'+
                    '"ProjectDefinition": null,'+
                    '"ProductionDate": "20180628",'+
                    '"OrderNo": null,'+
                    '"PONo": null,'+
                    '"OrderDate": null,'+
                    '"CombiProd": ['+
                        '{'+
                            '"ProductName": "Digital Remote Sensor",'+
                                '"ModelCode": "EJXC40A",'+
                                    '"SerialNo": "91U601404",'+
                                        '"ParentChildFlag": "1"'+
                                            '},'+
                        '{'+
                            '"ProductName": "Gauge Pressure Transmitter",'+
                                '"ModelCode": "EJX530A",'+
                                    '"SerialNo": "91U425639",'+
                                        '"ParentChildFlag": "2"'+
                                            '},'+
                        '{'+
                            '"ProductName": "Gauge Pressure Transmitter",'+
                                '"ModelCode": "EJX530A",'+
                                    '"SerialNo": "91U425640",'+
                                        '"ParentChildFlag": "2"'+
                                            '},'+
                        '{'+
                            '"ProductName": "Flushing Connection Ring",'+
                                '"ModelCode": "C10FR",'+
                                    '"SerialNo": "91U601402",'+
                                        '"ParentChildFlag": "2"'+
                                            '},'+
                        '{'+
                            '"ProductName": "Flushing Connection Ring",'+
                                '"ModelCode": "C10FR",'+
                                    '"SerialNo": "91U601403",'+
                                        '"ParentChildFlag": "2"'+
                                            '},'+
                        '{'+
                            '"ProductName": "Direct Mount Flanged Diaphragm Seal",'+
                                '"ModelCode": "C20FW",'+
                                    '"SerialNo": "91U700415",'+
                                        '"ParentChildFlag": "2"'+
                                            '},'+
                        '{'+
                            '"ProductName": "Direct Mount Flanged Diaphragm Seal",'+
                                '"ModelCode": "C20FW",'+
                                    '"SerialNo": "91U700416",'+
                                        '"ParentChildFlag": "2"'+
                                            '}'+
                    '],'+
                    '"OrderInstSummary": ['+
                        '{'+
                            '"TitleCode": "502",'+
                                '"InstName": "RANGE",'+
                                    '"InstData": "Min/Max: 0 - 2, Unit: bar"'+
                                        '},'+
                        '{'+
                            '"TitleCode": "H46",'+
                                '"InstName": "OUTPUT MODE;LINEAR/ SQUARE ROOT",'+
                                    '"InstData": "01:LINEAR"'+
                                        '}'+
                    '],'+
                    '"OrderInstSpecified": []'+
                    '}]');
                      
        res.setStatusCode(200);
        return res;
    }
}