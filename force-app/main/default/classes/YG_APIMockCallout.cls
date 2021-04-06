/*
*******************************************************************************************************
* (C) Copyright 2020 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Chitrakishore
* @version 1.0
* @created 28/07/2020
* @description 
* This class is used to write the Apex test class coverage for API Mock Callout.
*
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  12/10/2020			Selvaraj T				Added the response body for YG_ProductMasterAPIController
*  
*
*/
@isTest
public class YG_APIMockCallout implements HttpCalloutMock{
    
    public HTTPResponse respond(HTTPRequest request) {
        
        //System.assertEquals('https://library.yokogawa.com/shipment/search/?serialno=91W610216&languageid=EN&usagearea=1&systemid=AxkHnJ89', req.getEndpoint());
        //System.assertEquals('GET', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setHeader('X-CLA-Code', YG_Constants.CL_CODE_SUCCESS);
        
        System.debug('request.getEndpoint() ::: '+request.getEndpoint());
        
        if(request.getEndpoint().contains('mscode')){
            res.setBody('[{'+
                        '"MSCode":"YTA610-JB1A2DB\\'+'/NF2","Model":"YTA610","ProductName":"Temperature Transmitter","ModelStatus":"1","ModelStartDate":null,"ModelEndDate":null,'+
                        '"Suffix":[{'+
                        '"SuffixLevel":"01","SuffixLevelName":"Output","SuffixID":"-J","SuffixSpecDesc1":"4 to 20mA DC with digital communication",'+
                        '"SuffixSpecDesc2":"HART protocol","SuffixSpecDesc3":null,"SuffixSpecDesc4":null,"SuffixStatus":"1","SuffixStartDate":null,"SuffixEndDate":null'+
                        '},{'+
                        '"SuffixLevel":"02","SuffixLevelName":"Suffix","SuffixID":"B","SuffixSpecDesc1":"Chinese","SuffixSpecDesc2":null,"SuffixSpecDesc3":"test",'+
                        '"SuffixSpecDesc4":"test","SuffixStatus":"2","SuffixStartDate":null,"SuffixEndDate":null'+
                        '}],'+ 
                        '"Option":[{'+
                        '"OptionGroup":"009","OptionGroupName":"Optional Features","OptionID":"\\'+'/NF2","OptionSpecDesc1":"NEPSI flameproof",'+
                        '"OptionSpecDesc2":", and dust ignition (4-20mA type)","OptionSpecDesc3":"test","OptionSpecDesc4":"test","OptionStatus":"1",'+
                        '"OptionStartDate":null,"OptionEndDate":null'+
                        '}]'+
                        '}]');
            
        }else{
            res.setBody('[ { '+ 
                        '"OrderInstSpecified" : [ ],'+
                        '"OrderInstSummary" : [ {'+
                        '"InstData" : "Min/Max: 0 - 100, Unit: %, Features: LINEAR",'+
                        '"InstName" : "SCALE-1",'+
                        '"TitleCode" : "500"'+
                        '}, {'+
                        '"InstData" : "5",'+
                        '"InstName" : "HART PROTOCOL REV",'+
                        '"TitleCode" : "Z30"'+
                        '} ],'+
                        '"CombiProd" : [ ],'+
                        '"OrderDate" : null,'+
                        '"PONo" : null,'+
                        '"OrderNo" : null,'+
                        '"ProductionDate" : "20200603",'+
                        '"ProjectDefinition" : null,'+
                        '"LinkageNo" : null,'+
                        '"XJNo" : null,'+
                        '"TokuchuNo" : null,'+
                        '"ProductCareer" : "S2",'+
                        '"ProductName" : "Gauge Pressure Transmitter",'+
                        '"MSCode" : "EJX530A-JAS4N-017EL/FF1/D1/N4/A1/HC",'+
                        '"ModelCode" : "EJX530A",'+
                        '"SerialNo" : "91W610216"'+
                        '} ]');
        }
        res.setStatusCode(200);
        return res;
    }
}