/*
*******************************************************************************************************
* (C) Copyright 2020 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Selvaraj T
* @version 1.0
* @created 01/11/2021
* @description 
* This class is used to write the Apex test class coverage for YG_SystemsAPI Mock Callout.
*
*  Change History:
*  MM/DD/YYYY      Developer Name      Comments
*  
*  
*
*/

public class YG_SystemsAPIMockCallout implements HttpCalloutMock {

    public HTTPResponse respond(HTTPRequest request) {
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        if(request.getEndpoint().contains('deliverables/')){
             res.setBody('[{'+
                           '"type" : "deliverables",'+
                           '"approvedFlag" : false,'+
                           '"createDatetime" : "2019-09-10T07:23:56.000Z",'+
                           '"createUserCd" : "GISS20190910",'+
                           '"deletedFlag" : false,'+
                           '"editLockFlag" : false,'+
                           '"id" : "F30127BD-D39B-11E9-94D1-0AE1E5432EEC",'+
                           '"publicType" : "PUBLIC",'+
                           '"tenantId" : "162E577A-D1AA-466B-AE5C-AF1D38105F96",'+
                           '"unlockProhibitFlag" : false,'+
                           '"updateDatetime" : "2019-10-03T07:40:11.000Z",'+
                           '"updateUserCd" : "GISS20190910",'+
                           '"version" : 1,'+
                           '"deliverablesNo" : "D000007891",'+
                           '"dlvStatusDivCd" : {'+
                              '"approvedFlag" : false,'+
                              '"createDatetime" : "2018-10-22T08:25:29.000Z",'+
                              '"createUserCd" : "INITIAL",'+
                              '"deletedFlag" : false,'+
                              '"editLockFlag" : false,'+
                              '"id" : "24F0DAE3-5F7F-4FE9-950F-6DB85F44EF5E",'+
                              '"publicType" : "PUBLIC",'+
                              '"tenantId" : "162E577A-D1AA-466B-AE5C-AF1D38105F96",'+
                              '"unlockProhibitFlag" : false,'+
                              '"updateDatetime" : "2018-10-22T08:25:29.000Z",'+
                              '"updateUserCd" : "INITIAL",'+
                              '"version" : 1,'+
                              '"displaySeq" : 15,'+
                              '"div" : {'+
                                 '"approvedFlag" : false,'+
                                 '"createDatetime" : "2018-10-22T08:25:29.000Z",'+
                                 '"createUserCd" : "INITIAL",'+
                                 '"deletedFlag" : false,'+
                                 '"editLockFlag" : false,'+
                                 '"id" : "64BC5C07-BAFA-436F-B16E-2C1DBE193977",'+
                                 '"publicType" : "PUBLIC",'+
                                 '"tenantId" : "162E577A-D1AA-466B-AE5C-AF1D38105F96",'+
                                 '"unlockProhibitFlag" : false,'+
                                 '"updateDatetime" : "2018-10-22T08:25:29.000Z",'+
                                 '"updateUserCd" : "INITIAL",'+
                                 '"version" : 1,'+
                                 '"divColumn" : "dlvStatusDivCd",'+
                                 '"linefeedFlag" : false,'+
                                 '"name" : "Operation Status",'+
                                 '"note" : ""'+
                              '},'+
                              '"divCd" : "3",'+
                              '"divCdSeq" : 3'+
                           '},'+
                           '"name" : "ABU JARJUR",'+
                           '"dlvCreateTypeCrm" : "GISS",'+
                           '"plantCrm" : {'+
                              '"approvedFlag" : false,'+
                              '"createDatetime" : "2019-10-02T04:19:15.000Z",'+
                              '"createUserCd" : "INITIAL",'+
                              '"deletedFlag" : false,'+
                              '"editLockFlag" : false,'+
                              '"id" : "CB50C547-E4CB-11E9-B7DC-06328AF41CA4",'+
                              '"publicType" : "PUBLIC",'+
                              '"tenantId" : "162E577A-D1AA-466B-AE5C-AF1D38105F96",'+
                              '"unlockProhibitFlag" : false,'+
                              '"updateDatetime" : "2019-10-02T04:19:15.000Z",'+
                              '"updateUserCd" : "INITIAL",'+
                              '"version" : 1,'+
                              '"expandMemo1" : "YMA00028",'+
                              '"address" : "",'+
                              '"addressLocal" : "",'+
                              '"deleteFlagCrm" : false,'+
                              '"faxNo" : "",'+
                              '"name" : "ABU JARJUR",'+
                              '"nameLocal" : "",'+
                              '"note" : "",'+
                              '"plantNo" : "300000592",'+
                              '"telNo" : "",'+
                              '"zipCode" : ""'+
                           '},'+
                           '"projectNameCrm" : "ABU JARJUR",'+
                           '"systemIdCrm" : "VP707365",'+
                           '"totalControllerQtyCrm" : 8.0,'+
                           '"totalPcQtyCrm" : 6.0'+
                           '}]');
        
        }
        else if(request.getEndpoint().contains('deliverablesproduct/')){
            res.setBody('[{'+
                       '"type" : "deliverablesProduct",'+
                       '"approvedFlag" : false,'+
                       '"createDatetime" : "2019-09-10T07:23:56.000Z",'+
                       '"createUserCd" : "GISS20190910",'+
                       '"deletedFlag" : false,'+
                       '"editLockFlag" : false,'+
                       '"id" : "F301C82A-D39B-11E9-94D1-0AE1E5432EEC",'+
                       '"publicType" : "PUBLIC",'+
                       '"tenantId" : "162E577A-D1AA-466B-AE5C-AF1D38105F96",'+
                       '"unlockProhibitFlag" : false,'+
                       '"updateDatetime" : "2019-10-03T07:39:57.000Z",'+
                       '"updateUserCd" : "GISS20190910",'+
                       '"version" : 1,'+
                       '"deliverables" : {'+
                          '"approvedFlag" : false,'+
                          '"createDatetime" : "2019-09-10T07:23:56.000Z",'+
                          '"createUserCd" : "GISS20190910",'+
                          '"deletedFlag" : false,'+
                          '"editLockFlag" : false,'+
                          '"id" : "F30127BD-D39B-11E9-94D1-0AE1E5432EEC",'+
                          '"publicType" : "PUBLIC",'+
                          '"tenantId" : "162E577A-D1AA-466B-AE5C-AF1D38105F96",'+
                          '"unlockProhibitFlag" : false,'+
                          '"updateDatetime" : "2019-10-03T07:40:11.000Z",'+
                          '"updateUserCd" : "GISS20190910",'+
                          '"version" : 1,'+
                          '"deliverablesNo" : "D000007891",'+
                          '"name" : "ABU JARJUR",'+
                          '"dlvCreateTypeCrm" : "GISS",'+
                          '"projectNameCrm" : "ABU JARJUR",'+
                          '"systemIdCrm" : "VP707365",'+
                          '"totalControllerQtyCrm" : 8.0,'+
                          '"totalPcQtyCrm" : 6.0'+
                       '},'+
                       '"dlvProductSeq" : 1,'+
                       '"dlvStatusDivCd" : {'+
                          '"approvedFlag" : false,'+
                          '"createDatetime" : "2018-10-22T08:25:29.000Z",'+
                          '"createUserCd" : "INITIAL",'+
                          '"deletedFlag" : false,'+
                          '"editLockFlag" : false,'+
                          '"id" : "24F0DAE3-5F7F-4FE9-950F-6DB85F44EF5E",'+
                          '"publicType" : "PUBLIC",'+
                          '"tenantId" : "162E577A-D1AA-466B-AE5C-AF1D38105F96",'+
                          '"unlockProhibitFlag" : false,'+
                          '"updateDatetime" : "2018-10-22T08:25:29.000Z",'+
                          '"updateUserCd" : "INITIAL",'+
                          '"version" : 1,'+
                          '"displaySeq" : 15,'+
                          '"div" : {'+
                             '"approvedFlag" : false,'+
                             '"createDatetime" : "2018-10-22T08:25:29.000Z",'+
                             '"createUserCd" : "INITIAL",'+
                             '"deletedFlag" : false,'+
                             '"editLockFlag" : false,'+
                             '"id" : "64BC5C07-BAFA-436F-B16E-2C1DBE193977",'+
                             '"publicType" : "PUBLIC",'+
                             '"tenantId" : "162E577A-D1AA-466B-AE5C-AF1D38105F96",'+
                             '"unlockProhibitFlag" : false,'+
                             '"updateDatetime" : "2018-10-22T08:25:29.000Z",'+
                             '"updateUserCd" : "INITIAL",'+
                             '"version" : 1,'+
                             '"divColumn" : "dlvStatusDivCd",'+
                             '"linefeedFlag" : false,'+
                             '"name" : "Operation Status",'+
                             '"note" : ""'+
                          '},'+
                          '"divCd" : "3",'+
                          '"divCdSeq" : 3'+
                       '},'+
                       '"product" : {'+
                          '"approvedFlag" : false,'+
                          '"createDatetime" : "2018-10-23T05:38:12.000Z",'+
                          '"createUserCd" : "INITIAL",'+
                          '"deletedFlag" : false,'+
                          '"editLockFlag" : false,'+
                          '"id" : "4696D257-1469-11E9-9475-000C292F3873",'+
                          '"publicType" : "PUBLIC",'+
                          '"tenantId" : "162E577A-D1AA-466B-AE5C-AF1D38105F96",'+
                          '"unlockProhibitFlag" : false,'+
                          '"updateDatetime" : "2018-10-23T05:38:12.000Z",'+
                          '"updateUserCd" : "INITIAL",'+
                          '"version" : 1,'+
                          '"name" : "CENTUM VP R6",'+
                          '"productCd" : "6",'+
                          '"productType" : "PRODUCT",'+
                          '"productUsageType" : "COMPONENTS",'+
                          '"purchasePointQty" : 0.0,'+
                          '"purchasePointUseFlag" : true,'+
                          '"replenishmentQty" : 0.0,'+
                          '"stockControlType" : "PURCHASE",'+
                          '"systemCtrlProductFlagCrm" : false'+
                       '},'+
                       '"qty" : 1.0,'+
                       '"systemIdCrm" : "VP707365",'+
                       '"thirdPartyFlagCrm" : false'+
                       '}]');
        
        
        
        
        }
        else if(request.getEndpoint().contains('stationlist/')){
            res.setBody('{'+
                           '"Data":{'+
                              '"SystemID":"VP711178",'+
                              '"ProductName":"CENTUM VP",'+
                              '"RevInfGenerationDate":"2020-03-19",'+ 
                              '"RevInfGenerationTime":"14:06:22",'+
                              '"UserName":"SONATRACH",'+
                              '"CompanyName":"SONATRACH",'+
                              '"ProjectInformation":"SONATRACH-HRM-3",'+
                              '"ProjectName":"HRM-3",'+
                              '"VnetStatusBUS1":"READY",'+
                              '"VnetStatusBUS2":"READY",'+
                              '"VnetRedundancy":"dual",'+
                              '"Stations":['+
                                 '{'+
                                    '"StationType":"FCS",'+ 
                                    '"VnetDomainNumber":2,'+
                                    '"VnetStationNumber":1,'+
                                    '"StationOrAlias":"FCS0201",'+
                                    '"ModelCode":"A2FV50D",'+
                                    '"VnetHostname":"FCS0201",'+
                                    '"VnetIPAddress":"172.16.2.1",'+
                                    '"Status":"READY",'+
                                    '"StationName":"FCS0201",'+
                                    '"Comment":"",'+
                                    '"RevisionNumber":"R6.05.00",'+
                                    '"GenerationDate":"2020-02-17 15:07:01",'+
                                    '"EnetHostname":"",'+
                                    '"EnetIPAddress":"",'+
                                    '"UserName":"",'+
                                    '"CompanyName":"",'+
                                    '"ProjectName":"",'+
                                    '"ProjectIDOrLicenseID":"",'+
                                    '"OtherSideDomainNumber":"",'+
                                    '"OtherSideStationNumber":""'+
                                 '},'+
                                 '{'+
                                    '"StationType":"FCS",'+
                                    '"VnetDomainNumber":2,'+
                                    '"VnetStationNumber":4,'+
                                    '"StationOrAlias":"FCS0204",'+
                                    '"ModelCode":"A2FV50D",'+
                                    '"VnetHostname":"FCS0204",'+
                                    '"VnetIPAddress":"172.16.2.4",'+
                                    '"Status":"READY",'+
                                    '"StationName":"FCS0204",'+
                                    '"Comment":"",'+
                                    '"RevisionNumber":"R6.05.00",'+
                                    '"GenerationDate":"2020-03-18 16:27:08",'+
                                    '"EnetHostname":"",'+
                                    '"EnetIPAddress":"",'+
                                    '"UserName":"",'+
                                    '"CompanyName":"",'+
                                    '"ProjectName":"",'+
                                    '"ProjectIDOrLicenseID":"",'+
                                    '"OtherSideDomainNumber":"",'+
                                    '"OtherSideStationNumber":""'+
                                 '},'+
                                 '{'+
                                    '"StationType":"FCS",'+
                                    '"VnetDomainNumber":2,'+
                                    '"VnetStationNumber":2,'+
                                    '"StationOrAlias":"FCS0202",'+
                                    '"ModelCode":"A2FV50D",'+
                                    '"VnetHostname":"FCS0202",'+
                                    '"VnetIPAddress":"172.16.2.2",'+
                                    '"Status":"READY",'+
                                    '"StationName":"FCS0202",'+
                                    '"Comment":"",'+
                                    '"RevisionNumber":"R6.05.00",'+
                                    '"GenerationDate":"2020-02-24 15:22:28",'+
                                    '"EnetHostname":"",'+
                                    '"EnetIPAddress":"",'+
                                    '"UserName":"",'+
                                    '"CompanyName":"",'+
                                    '"ProjectName":"",'+
                                    '"ProjectIDOrLicenseID":"",'+
                                    '"OtherSideDomainNumber":"",'+
                                    '"OtherSideStationNumber":""'+
                                 '},'+
                                 '{'+
                                    '"StationType":"FCS",'+
                                    '"VnetDomainNumber":2,'+
                                    '"VnetStationNumber":3,'+
                                    '"StationOrAlias":"FCS0203",'+
                                    '"ModelCode":"A2FV50D",'+
                                    '"VnetHostname":"FCS0203",'+
                                    '"VnetIPAddress":"172.16.2.3",'+
                                    '"Status":"READY",'+
                                    '"StationName":"FCS0203",'+
                                    '"Comment":"",'+
                                    '"RevisionNumber":"R6.05.00",'+
                                    '"GenerationDate":"2020-02-13 15:01:36",'+
                                    '"EnetHostname":"",'+
                                    '"EnetIPAddress":"",'+
                                    '"UserName":"",'+
                                    '"CompanyName":"",'+
                                    '"ProjectName":"",'+
                                    '"ProjectIDOrLicenseID":"",'+
                                    '"OtherSideDomainNumber":"",'+
                                    '"OtherSideStationNumber":""'+
                                 '},'+
                                 '{'+
                                    '"StationType":"SCS",'+
                                    '"VnetDomainNumber":2,'+
                                    '"VnetStationNumber":21,'+
                                    '"StationOrAlias":"SCS0221",'+
                                    '"ModelCode":"S2SC70D-F",'+
                                    '"VnetHostname":"",'+
                                    '"VnetIPAddress":"",'+
                                    '"Status":"READY",'+
                                    '"StationName":"SCS0221",'+
                                    '"Comment":"ESD COMP A&B",'+
                                    '"RevisionNumber":"R4.03.16",'+
                                    '"GenerationDate":"",'+
                                    '"EnetHostname":"",'+
                                    '"EnetIPAddress":"",'+
                                    '"UserName":"",'+
                                    '"CompanyName":"",'+
                                    '"ProjectName":"",'+
                                    '"ProjectIDOrLicenseID":"",'+
                                    '"OtherSideDomainNumber":"",'+
                                    '"OtherSideStationNumber":""'+
                                 '},'+
                                 '{'+
                                    '"StationType":"SCS",'+
                                    '"VnetDomainNumber":2,'+
                                    '"VnetStationNumber":31,'+
                                    '"StationOrAlias":"SCS0231",'+
                                    '"ModelCode":"S2SC70D-F",'+
                                    '"VnetHostname":"",'+
                                    '"VnetIPAddress":"",'+
                                    '"Status":"READY",'+
                                    '"StationName":"SCS0231",'+
                                    '"Comment":"FGS FACP",'+
                                    '"RevisionNumber":"R4.03.16",'+
                                    '"GenerationDate":"",'+
                                    '"EnetHostname":"",'+
                                    '"EnetIPAddress":"",'+
                                    '"UserName":"",'+
                                    '"CompanyName":"",'+
                                    '"ProjectName":"",'+
                                    '"ProjectIDOrLicenseID":"",'+
                                    '"OtherSideDomainNumber":"",'+
                                    '"OtherSideStationNumber":""'+
                                 '},'+
                                 '{'+
                                    '"StationType":"SCS",'+
                                    '"VnetDomainNumber":2,'+
                                    '"VnetStationNumber":22,'+
                                    '"StationOrAlias":"SCS0222",'+
                                    '"ModelCode":"S2SC70D-F",'+
                                    '"VnetHostname":"",'+
                                    '"VnetIPAddress":"",'+
                                    '"Status":"READY",'+
                                    '"StationName":"SCS0222",'+
                                    '"Comment":"ESD COMP & UTILITY",'+
                                    '"RevisionNumber":"R4.03.16",'+
                                    '"GenerationDate":"",'+
                                    '"EnetHostname":"",'+
                                    '"EnetIPAddress":"",'+
                                    '"UserName":"",'+
                                    '"CompanyName":"",'+
                                    '"ProjectName":"",'+
                                    '"ProjectIDOrLicenseID":"",'+
                                    '"OtherSideDomainNumber":"",'+
                                    '"OtherSideStationNumber":""'+
                                 '},'+
                                 '{'+
                                    '"StationType":"SCS",'+
                                    '"VnetDomainNumber":2,'+
                                    '"VnetStationNumber":32,'+
                                    '"StationOrAlias":"SCS0232",'+
                                    '"ModelCode":"S2SC70D-F",'+
                                    '"VnetHostname":"",'+
                                    '"VnetIPAddress":"",'+
                                    '"Status":"READY",'+
                                    '"StationName":"SCS0232",'+
                                    '"Comment":"FGS GAP",'+
                                    '"RevisionNumber":"R4.03.16",'+
                                    '"GenerationDate":"",'+
                                    '"EnetHostname":"",'+
                                    '"EnetIPAddress":"",'+
                                    '"UserName":"",'+
                                    '"CompanyName":"",'+
                                    '"ProjectName":"",'+
                                    '"ProjectIDOrLicenseID":"",'+
                                    '"OtherSideDomainNumber":"",'+
                                    '"OtherSideStationNumber":""'+
                                 '},'+
                                 '{'+
                                    '"StationType":"HIS",'+
                                    '"VnetDomainNumber":2,'+
                                    '"VnetStationNumber":39,'+
                                    '"StationOrAlias":"HIS0239",'+
                                    '"ModelCode":"PC",'+
                                    '"VnetHostname":"M0239",'+
                                    '"VnetIPAddress":"172.16.2.39",'+
                                    '"Status":"READY",'+
                                    '"StationName":"",'+
                                    '"Comment":"",'+
                                    '"RevisionNumber":"",'+
                                    '"GenerationDate":"",'+
                                    '"EnetHostname":"E0239",'+
                                    '"EnetIPAddress":"172.17.2.39",'+
                                    '"UserName":"",'+
                                    '"CompanyName":"",'+
                                    '"ProjectName":"",'+
                                    '"ProjectIDOrLicenseID":"",'+
                                    '"OtherSideDomainNumber":"",'+
                                    '"OtherSideStationNumber":""'+
                                 '},'+
                                 '{'+
                                    '"StationType":"HIS",'+
                                    '"VnetDomainNumber":2,'+
                                    '"VnetStationNumber":64,'+
                                    '"StationOrAlias":"HIS0264",'+
                                    '"ModelCode":"PC",'+
                                    '"VnetHostname":"M0264",'+
                                    '"VnetIPAddress":"172.16.2.64",'+
                                    '"Status":"READY",'+
                                    '"StationName":"HIS0264",'+
                                    '"Comment":"",'+
                                    '"RevisionNumber":"R6.05.00",'+
                                    '"GenerationDate":"",'+
                                    '"EnetHostname":"E0264",'+
                                    '"EnetIPAddress":"172.17.2.64",'+
                                    '"UserName":"SONATRACH",'+
                                    '"CompanyName":"SONATRACH",'+
                                    '"ProjectName":"HRM-3",'+
                                    '"ProjectIDOrLicenseID":"VP711178",'+
                                    '"OtherSideDomainNumber":"",'+
                                    '"OtherSideStationNumber":""'+
                                 '},'+
                                 '{'+
                                    '"StationType":"HIS",'+
                                    '"VnetDomainNumber":2,'+
                                    '"VnetStationNumber":51,'+
                                    '"StationOrAlias":"STN0251",'+
                                    '"ModelCode":"PC",'+
                                    '"VnetHostname":"",'+
                                    '"VnetIPAddress":"",'+
                                    '"Status":"FAIL",'+
                                    '"StationName":"",'+
                                    '"Comment":"",'+
                                    '"RevisionNumber":"",'+
                                    '"GenerationDate":"",'+
                                    '"EnetHostname":"",'+
                                    '"EnetIPAddress":"",'+
                                    '"UserName":"",'+
                                    '"CompanyName":"",'+
                                    '"ProjectName":"",'+
                                    '"ProjectIDOrLicenseID":"",'+
                                    '"OtherSideDomainNumber":"",'+
                                    '"OtherSideStationNumber":""'+
                                 '},'+
                                 '{'+
                                    '"StationType":"HIS",'+
                                    '"VnetDomainNumber":2,'+
                                    '"VnetStationNumber":53,'+
                                    '"StationOrAlias":"STN0253",'+
                                    '"ModelCode":"PC",'+
                                    '"VnetHostname":"",'+
                                    '"VnetIPAddress":"",'+
                                    '"Status":"READY",'+
                                    '"StationName":"",'+
                                    '"Comment":"",'+
                                    '"RevisionNumber":"",'+
                                    '"GenerationDate":"",'+
                                    '"EnetHostname":"",'+
                                    '"EnetIPAddress":"",'+
                                    '"UserName":"",'+
                                    '"CompanyName":"",'+
                                    '"ProjectName":"",'+
                                    '"ProjectIDOrLicenseID":"",'+
                                    '"OtherSideDomainNumber":"",'+
                                    '"OtherSideStationNumber":""'+
                                 '},'+
                                 '{'+
                                    '"StationType":"HIS",'+
                                    '"VnetDomainNumber":2,'+
                                    '"VnetStationNumber":40,'+
                                    '"StationOrAlias":"HIS0240",'+
                                    '"ModelCode":"PC",'+
                                    '"VnetHostname":"M0240",'+
                                    '"VnetIPAddress":"172.16.2.40",'+
                                    '"Status":"FAIL",'+
                                    '"StationName":"",'+
                                    '"Comment":"",'+
                                    '"RevisionNumber":"",'+
                                    '"GenerationDate":"",'+
                                    '"EnetHostname":"E0240",'+
                                    '"EnetIPAddress":"172.17.2.40",'+
                                    '"UserName":"",'+
                                    '"CompanyName":"",'+
                                    '"ProjectName":"",'+
                                    '"ProjectIDOrLicenseID":"",'+
                                    '"OtherSideDomainNumber":"",'+
                                    '"OtherSideStationNumber":""'+
                                 '},'+
                                 '{'+
                                    '"StationType":"HIS",'+
                                    '"VnetDomainNumber":2,'+
                                    '"VnetStationNumber":41,'+
                                    '"StationOrAlias":"HIS0241",'+
                                    '"ModelCode":"PC",'+
                                    '"VnetHostname":"M0241",'+
                                    '"VnetIPAddress":"172.16.2.41",'+
                                    '"Status":"READY",'+
                                    '"StationName":"",'+
                                    '"Comment":"",'+
                                    '"RevisionNumber":"",'+
                                    '"GenerationDate":"",'+
                                    '"EnetHostname":"E0241",'+
                                    '"EnetIPAddress":"172.17.2.41",'+
                                    '"UserName":"",'+
                                    '"CompanyName":"",'+
                                    '"ProjectName":"",'+
                                    '"ProjectIDOrLicenseID":"",'+
                                    '"OtherSideDomainNumber":"",'+
                                    '"OtherSideStationNumber":""'+
                                 '},'+
                                 '{'+
                                    '"StationType":"HIS",'+
                                    '"VnetDomainNumber":2,'+
                                    '"VnetStationNumber":54,'+
                                    '"StationOrAlias":"STN0254",'+
                                    '"ModelCode":"PC",'+
                                    '"VnetHostname":"",'+
                                    '"VnetIPAddress":"",'+
                                    '"Status":"READY",'+
                                    '"StationName":"",'+
                                    '"Comment":"",'+
                                    '"RevisionNumber":"",'+
                                    '"GenerationDate":"",'+
                                    '"EnetHostname":"",'+
                                    '"EnetIPAddress":"",'+
                                    '"UserName":"",'+
                                    '"CompanyName":"",'+
                                    '"ProjectName":"",'+
                                    '"ProjectIDOrLicenseID":"",'+
                                    '"OtherSideDomainNumber":"",'+
                                    '"OtherSideStationNumber":""'+
                                 '},'+
                                 '{'+
                                    '"StationType":"HIS",'+
                                    '"VnetDomainNumber":2,'+
                                    '"VnetStationNumber":46,'+
                                    '"StationOrAlias":"HIS0246",'+
                                    '"ModelCode":"PC",'+
                                    '"VnetHostname":"M0246",'+
                                    '"VnetIPAddress":"172.16.2.46",'+
                                    '"Status":"FAIL",'+
                                    '"StationName":"",'+
                                    '"Comment":"",'+
                                    '"RevisionNumber":"",'+
                                    '"GenerationDate":"",'+
                                    '"EnetHostname":"E0246",'+
                                    '"EnetIPAddress":"172.17.2.46",'+
                                    '"UserName":"",'+
                                    '"CompanyName":"",'+
                                    '"ProjectName":"",'+
                                    '"ProjectIDOrLicenseID":"",'+
                                    '"OtherSideDomainNumber":"",'+
                                    '"OtherSideStationNumber":""'+
                                 '},'+
                                 '{'+
                                    '"StationType":"HIS",'+
                                    '"VnetDomainNumber":2,'+
                                    '"VnetStationNumber":43,'+
                                    '"StationOrAlias":"HIS0243",'+
                                    '"ModelCode":"PC",'+
                                    '"VnetHostname":"M0243",'+
                                    '"VnetIPAddress":"172.16.2.43",'+
                                    '"Status":"READY",'+
                                    '"StationName":"",'+
                                    '"Comment":"",'+
                                    '"RevisionNumber":"",'+
                                    '"GenerationDate":"",'+
                                    '"EnetHostname":"E0243",'+
                                    '"EnetIPAddress":"172.17.2.43",'+
                                    '"UserName":"",'+
                                    '"CompanyName":"",'+
                                    '"ProjectName":"",'+
                                    '"ProjectIDOrLicenseID":"",'+
                                    '"OtherSideDomainNumber":"",'+
                                    '"OtherSideStationNumber":""'+
                                 '},'+
                                 '{'+
                                    '"StationType":"HIS",'+
                                    '"VnetDomainNumber":2,'+
                                    '"VnetStationNumber":52,'+
                                    '"StationOrAlias":"STN0252",'+
                                    '"ModelCode":"PC",'+
                                    '"VnetHostname":"",'+
                                    '"VnetIPAddress":"",'+
                                    '"Status":"FAIL",'+
                                    '"StationName":"",'+
                                    '"Comment":"",'+
                                    '"RevisionNumber":"",'+
                                    '"GenerationDate":"",'+
                                    '"EnetHostname":"",'+
                                    '"EnetIPAddress":"",'+
                                    '"UserName":"",'+
                                    '"CompanyName":"",'+
                                    '"ProjectName":"",'+
                                    '"ProjectIDOrLicenseID":"",'+
                                    '"OtherSideDomainNumber":"",'+
                                    '"OtherSideStationNumber":""'+
                                 '},'+
                                 '{'+
                                    '"StationType":"HIS",'+
                                    '"VnetDomainNumber":2,'+
                                    '"VnetStationNumber":42,'+
                                    '"StationOrAlias":"HIS0242",'+
                                    '"ModelCode":"PC",'+
                                    '"VnetHostname":"M0242",'+
                                    '"VnetIPAddress":"172.16.2.42",'+
                                    '"Status":"FAIL",'+
                                    '"StationName":"",'+
                                    '"Comment":"",'+
                                    '"RevisionNumber":"",'+
                                    '"GenerationDate":"",'+
                                    '"EnetHostname":"E0242",'+
                                    '"EnetIPAddress":"172.17.2.42",'+
                                    '"UserName":"",'+
                                    '"CompanyName":"",'+
                                    '"ProjectName":"",'+
                                    '"ProjectIDOrLicenseID":"",'+
                                    '"OtherSideDomainNumber":"",'+
                                    '"OtherSideStationNumber":""'+
                                 '}'+
                              ']'+
                           '},'+
                           '"ReturnCode":0'+
                           '}');
        }
        else if(request.getEndpoint().contains('stationdetail/') && (request.getEndpoint().contains('FCS') || request.getEndpoint().contains('SCS') || request.getEndpoint().contains('CGW'))){
            res.setBody('{'+
   '"Data":{'+
      '"SystemID":"VP711178",'+
      '"Modules":['+
         '{'+
            '"ModuleType":"N-ESB Bus Module",'+
            '"Position":"Left",'+
            '"ModelCode":"A2EN501",'+
            '"StyleCode":"",'+
            '"VEHICLE_Revision":"",'+
            '"IPEX_Revision":"",'+
            '"BOOT_Revision":"",'+
            '"SerialNumber":"",'+
            '"StyleCode_Manufacturer":"",'+
            '"ModelCode_Manufacturer":"",'+
            '"Status":"READY",'+
            '"UnitNumber":"0"'+
         '},'+
         '{'+
            '"ModuleType":"N-ESB Bus Module",'+
            '"Position":"Left",'+
            '"ModelCode":"A2EN501",'+
            '"StyleCode":"",'+
            '"VEHICLE_Revision":"",'+
            '"IPEX_Revision":"",'+
            '"BOOT_Revision":"",'+
            '"SerialNumber":"",'+
            '"StyleCode_Manufacturer":"",'+
            '"ModelCode_Manufacturer":"",'+
            '"Status":"READY",'+
            '"UnitNumber":"0"'+
         '},'+
         '{'+
            '"ModuleType":"N-ESB Bus Module",'+
            '"Position":"Left",'+
            '"ModelCode":"A2EN501",'+
            '"StyleCode":"",'+
            '"VEHICLE_Revision":"",'+
            '"IPEX_Revision":"",'+
            '"BOOT_Revision":"",'+
            '"SerialNumber":"",'+
            '"StyleCode_Manufacturer":"",'+
            '"ModelCode_Manufacturer":"",'+
            '"Status":"READY",'+
            '"UnitNumber":"0"'+
         '},'+
         '{'+
            '"ModuleType":"N-ESB Bus Module",'+
            '"Position":"Left",'+
            '"ModelCode":"A2EN501",'+
            '"StyleCode":"",'+
            '"VEHICLE_Revision":"",'+
            '"IPEX_Revision":"",'+
            '"BOOT_Revision":"",'+
            '"SerialNumber":"",'+
            '"StyleCode_Manufacturer":"",'+
            '"ModelCode_Manufacturer":"",'+
            '"Status":"READY",'+
            '"UnitNumber":"0"'+
         '},'+
         '{'+
            '"ModuleType":"CPU Module",'+
            '"Position":"Right",'+
            '"ModelCode":"CP471",'+
            '"StyleCode":"1",'+
            '"VEHICLE_Revision":"",'+
            '"IPEX_Revision":"0",'+
            '"BOOT_Revision":"3",'+
            '"SerialNumber":"C2UC23140H",'+
            '"StyleCode_Manufacturer":"1",'+
            '"ModelCode_Manufacturer":"CP471-00",'+
            '"Status":"",'+
            '"UnitNumber":""'+
         '}'+
      '],'+
      '"IOModules":['+
         '{'+
            '"UnitNumber":"1",'+
            '"SlotNumber":"1",'+
            '"ModelCode":"A2MMM843",'+
            '"StyleCode":"2",'+
            '"SuffixCode":"SS1000",'+
            '"SerialNumber":"C3UE30346X",'+
            '"Status":"READY"'+
         '},'+
         '{'+
            '"UnitNumber":"2",'+
            '"SlotNumber":"2",'+
            '"ModelCode":"A2MMM843",'+
            '"StyleCode":"",'+
            '"SuffixCode":"",'+
            '"SerialNumber":"",'+
            '"Status":""'+
         '},'+
         '{'+
            '"UnitNumber":"0",'+
            '"SlotNumber":"1",'+
            '"ModelCode":"A2EN501",'+
            '"StyleCode":"",'+
            '"SuffixCode":"S00000",'+
            '"SerialNumber":"C3UF04005Q",'+
            '"Status":""'+
         '},'+
         '{'+
            '"UnitNumber":"1",'+
            '"SlotNumber":"2",'+
            '"ModelCode":"A2MDV843",'+
            '"StyleCode":"",'+
            '"SuffixCode":"",'+
            '"SerialNumber":"",'+
            '"Status":""'+
         '},'+
         '{'+
            '"UnitNumber":"2",'+
            '"SlotNumber":"2",'+
            '"ModelCode":"A2MMM843",'+
            '"StyleCode":"",'+
            '"SuffixCode":"",'+
            '"SerialNumber":"",'+
            '"Status":""'+
         '},'+
         '{'+
            '"UnitNumber":"1",'+
            '"SlotNumber":"1",'+
            '"ModelCode":"A2MMM843",'+
            '"StyleCode":"2",'+
            '"SuffixCode":"SS1000",'+
            '"SerialNumber":"C3UE30325X",'+
            '"Status":"READY"'+
         '}'+
      ']'+
   '},'+
   '"ReturnCode":0'+
'}');
        }
        else if(request.getEndpoint().contains('stationdetail/') && request.getEndpoint().contains('HIS')){
            res.setBody('{'+
                       '"Data":{'+
                          '"SystemID":"VP711178",'+
                          '"SerialNumber":"",'+
                          '"OperatingSystem":"Microsoft Windows Server 2008 R2 Standard",'+
                          '"ServicePack":"Service Pack 1",'+
                          '"Model":"",'+
                          '"Manufacturer":"",'+
                          '"Packages":['+
                             '{'+
                                '"PackageCode":"LHS5490",'+
                                '"PackageDescription":"Self-documentation Package"'+
                             '},'+
                             '{'+
                                '"PackageCode":"VP_F1800",'+
                                '"PackageDescription":"Control Function for Field Control Station (for A2FV50) (Large Type)"'+
                             '},'+
                             '{'+
                                '"PackageCode":"LHS4410",'+
                                '"PackageDescription":"Control Drawing Status Display Package"'+
                             '},'+
                             '{'+
                                '"PackageCode":"LHS5495",'+
                                '"PackageDescription":"Electronic Instruction Manual"'+
                             '},'+
                             '{'+
                                '"PackageCode":"LHS5150",'+
                                '"PackageDescription":"Graphic Builder"'+
                             '},'+
                             '{'+
                                '"PackageCode":"VP_F3100",'+
                                '"PackageDescription":"Project I/O License"'+
                             '},'+
                             '{'+
                                '"PackageCode":"VP_E5250",'+
                                '"PackageDescription":"Change Management Package"'+
                             '},'+
                             '{'+
                                '"PackageCode":"VP_E5215",'+
                                '"PackageDescription":"Tuning Parameter Management Package (for Module-based Engineering)"'+
                             '},'+
                             '{'+
                                '"PackageCode":"LHS1100",'+
                                '"PackageDescription":"Standard Operation and Monitoring Function (Logical IO points are 6000 or less)"'+
                             '},'+
                             '{'+
                                '"PackageCode":"LHS5420",'+
                                '"PackageDescription":"Test Function"'+
                             '},'+
                             '{'+
                                '"PackageCode":"LHS4420",'+
                                '"PackageDescription":"Logic Chart Status Display Package"'+
                             '}'+
                          '],'+
                          '"Softwares":['+
                          ']'+
                       '},'+
                       '"ReturnCode":0'+
					'}');
        }
        else if(request.getEndpoint().contains('stationdetail/') && request.getEndpoint().contains('BCV')){
            res.setBody('{'+
                           '"Data":{'+
                              '"SystemID":"VP704674",'+
                              '"OperatingSystem":"Microsoft Windows Server 2008 R2 Standard",'+
                              '"ServicePack":"Service Pack 1", '+
                              '"Model":"PowerEdge R730",'+
                              '"Manufacturer":"Dell Inc."'+
                           '},'+
                           '"ReturnCode":0'+
                        '}');
        }
        res.setStatusCode(200);
        return res;
    }
    
}