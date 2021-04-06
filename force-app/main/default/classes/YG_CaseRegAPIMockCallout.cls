/*
*******************************************************************************************************
* (C) Copyright 2020 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Chitrakishore
* @version 1.0
* @created 26/11/2020
* @description 
* This class is used to write the Apex test class coverage for Case Registration API Mock Callout.
*
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  
*  
*
*/

@isTest
public class YG_CaseRegAPIMockCallout implements HttpCalloutMock{
    
    public HTTPResponse respond(HTTPRequest request) {
       
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setHeader('X-CLA-Code', YG_Constants.CL_CODE_SUCCESS);
        
        System.debug('request.getEndpoint() ::: '+request.getEndpoint());
        res.setBody('{'+
                        '"type": "incident",'+
                        '"approvedFlag": false,'+
                        '"createDatetime": "2020-11-23T14:38:58.703Z",'+
                        '"createUserCd": "GISS-IF-USER",'+
                        '"deletedFlag": false,'+
                        '"editLockFlag": false,'+
                        '"id": "AF1A3DC2-28AB-4632-8FF3-0E146A190968",'+
                        '"ownerOrgId": "C1F4B19F-F49E-416A-B757-C90E7C174FE8",'+
                        '"publicType": "PUBLIC",'+
                        '"unlockProhibitFlag": false,'+
                        '"updateDatetime": "2020-11-23T14:38:58.703Z",'+
                        '"updateUserCd": "GISS-IF-USER",'+
                        '"version": 1,'+
                        '"dlvCustomer": {'+
                            '"approvedFlag": false,'+
                            '"createDatetime": "2018-12-05T06:01:00.000Z",'+
                            '"createUserCd": "ASTERIA",'+
                            '"deletedFlag": false,'+
                            '"editLockFlag": false,'+
                            '"id": "5a5ff881-05d2-4700-85e6-a616c66583c7",'+
                            '"publicType": "PUBLIC",'+
                            '"tenantId": "162E577A-D1AA-466B-AE5C-AF1D38105F96",'+
                            '"unlockProhibitFlag": false,'+
                            '"updateDatetime": "2019-02-04T03:04:31.000Z",'+
                            '"updateUserCd": "ASTERIA2",'+
                            '"version": 2,'+
                            '"consumerFlag": false,'+
                            '"customerCd": "100051983",'+
                            '"name": "CHEVRON AUSTRALIA PTY LTD",'+
                            '"deleteFlagCrm": false,'+
                            '"ygsAuthorityGroupCrm": "2U00",'+
                            '"ygsIndustryCdCrm": "29000"'+
                        '},'+
                        '"dlvCustomerBranch": {'+
                            '"approvedFlag": false,'+
                            '"createDatetime": "2018-12-05T12:57:50.000Z",'+
                            '"createUserCd": "ASTERIA",'+
                            '"deletedFlag": false,'+
                            '"editLockFlag": false,'+
                            '"id": "b6556e25-db96-4374-9bbe-c9ddbd841fbb",'+
                            '"publicType": "PUBLIC",'+
                            '"tenantId": "162E577A-D1AA-466B-AE5C-AF1D38105F96",'+
                            '"unlockProhibitFlag": false,'+
                            '"updateDatetime": "2019-04-11T08:28:32.000Z",'+
                            '"updateUserCd": "IF_USER_0409",'+
                            '"version": 2,'+
                            '"address": "PERTH L24, QV1, 250 ST GEORGES TCE",'+
                            '"addressGlobal": "PERTH L24, QV1, 250 ST GEORGES TCE",'+
                            '"addressLocal": "PERTH L24, QV1, 250 ST GEORGES TCE",'+
                            '"customer": {'+
                                '"approvedFlag": false,'+
                                '"createDatetime": "2018-12-05T06:01:00.000Z",'+
                                '"createUserCd": "ASTERIA",'+
                                '"deletedFlag": false,'+
                                '"editLockFlag": false,'+
                                '"id": "5a5ff881-05d2-4700-85e6-a616c66583c7",'+
                                '"publicType": "PUBLIC",'+
                                '"tenantId": "162E577A-D1AA-466B-AE5C-AF1D38105F96",'+
                                '"unlockProhibitFlag": false,'+
                                '"updateDatetime": "2019-02-04T03:04:31.000Z",'+
                                '"updateUserCd": "ASTERIA2",'+
                                '"version": 2,'+
                                '"consumerFlag": false,'+
                                '"customerCd": "100051983",'+
                                '"name": "CHEVRON AUSTRALIA PTY LTD",'+
                                '"deleteFlagCrm": false,'+
                                '"ygsAuthorityGroupCrm": "2U00",'+
                                '"ygsIndustryCdCrm": "29000"'+
                            '},'+
                            '"customerBranchCd": "200066853",'+
                            '"name": "CHEVRON AUSTRALIA PTY LTD",'+
                            '"nameGlobal": "CHEVRON AUSTRALIA PTY LTD",'+
                            '"nameLocal": "CHEVRON AUSTRALIA PTY LTD",'+
                            '"zipCode": "6000",'+
                            '"communicationLangCrm": "EN",'+
                            '"deleteFlagCrm": false,'+
                            '"disabledFlagCrm": false,'+
                            '"shortListFlagCrm": true,'+
                            '"ygsAccountGroupCrm": "Y002",'+
                            '"ygsAuthorityGroupCrm": "2U00",'+
                            '"ygsGovernmentSignCrm": "Z2",'+
                            '"ygsIndustryCdCrm": "12010",'+
                            '"ygsRegionCrm": "WA",'+
                            '"ygsTimeZoneCrm": "AUSWA",'+
                            '"ygsTransportZoneCrm": "ZAU9000001",'+
                            '"yokogawaFlagCrm": false'+
                        '},'+
                        '"incidentCustomers": {'+
                            '"incidentCustomer": []'+
                        '},'+
                        '"incidentMemo": "Service For - ADMAG AXG: Magnetic Flow Meter",'+
                        '"incidentNo": "YEA-C2011-00094",'+
                        '"incidentNote": "dfghj",'+
                        '"incidentProducts": {'+
                            '"incidentProduct": []'+
                        '},'+
                        '"incidentRemarks": {'+
                            '"incidentRemark": []'+
                        '},'+
                        '"incidentSeq": 1,'+
                        '"incidentStatus": "INCIDENT_COMPLETED",'+
                        '"incidentWorks": {'+
                            '"incidentWork": []'+
                        '},'+
                        '"originalDeleteFlag": false,'+
                        '"receiptDatetime": "2020-11-23T14:38:58.646Z",'+
                        '"serviceOrg": {'+
                            '"approvedFlag": false,'+
                            '"createDatetime": "2018-11-13T00:04:47.000Z",'+
                            '"createUserCd": "ALL_SYS_ADMIN",'+
                            '"deletedFlag": false,'+
                            '"editLockFlag": false,'+
                            '"id": "C1F4B19F-F49E-416A-B757-C90E7C174FE8",'+
                            '"publicType": "PUBLIC",'+
                            '"tenantId": "162E577A-D1AA-466B-AE5C-AF1D38105F96",'+
                            '"unlockProhibitFlag": false,'+
                            '"updateDatetime": "2018-11-13T00:23:44.000Z",'+
                            '"updateUserCd": "ALL_SYS_ADMIN",'+
                            '"version": 2,'+
                            '"address": "5 Bedok South Road, Singapore",'+
                            '"addressLocal": "5 Bedok South Road, Singapore",'+
                            '"effectDate": "2018-04-01Z",'+
                            '"faxNo": "65-6241-2606",'+
                            '"name": "YEA-RCA:YEA Regional Service, Response Centre Aisa",'+
                            '"organizationCd": "O0000000013",'+
                            '"outsourceFlag": false,'+
                            '"telNo": "65-62419933",'+
                            '"zipCode": "469270"'+
                        '},'+
                        '"caseClassTypeCrm": "OTHER_CHARGEALBLE",'+
                        '"caseStatusCrm": "RRC_SUPPORT",'+
                        '"chargeableFlagCrm": false,'+
                        '"complaintFlagCrm": false,'+
                        '"doaFlagCrm": false,'+
                        '"grcEscFlagCrm": false,'+
                        '"incidentContactCrms": {'+
                            '"incidentContactCrmList": []'+
                        '},'+
                        '"irEscFlagCrm": false,'+
                        '"knowledgeFlagCrm": false,'+
                        '"majorTroubleFlagCrm": false,'+
                        '"priorityDivCdCrm": {'+
                            '"approvedFlag": false,'+
                            '"createDatetime": "2018-10-22T08:25:39.000Z",'+
                            '"createUserCd": "INITIAL",'+
                            '"deletedFlag": false,'+
                            '"editLockFlag": false,'+
                            '"id": "4EE9BF3D-82C1-4F52-BD49-27B18BCBBED0",'+
                            '"publicType": "PUBLIC",'+
                            '"tenantId": "162E577A-D1AA-466B-AE5C-AF1D38105F96",'+
                            '"unlockProhibitFlag": false,'+
                            '"updateDatetime": "2018-10-22T08:25:39.000Z",'+
                            '"updateUserCd": "INITIAL",'+
                            '"version": 1,'+
                            '"displaySeq": 15,'+
                            '"div": {'+
                                '"approvedFlag": false,'+
                                '"createDatetime": "2018-10-22T08:25:39.000Z",'+
                                '"createUserCd": "INITIAL",'+
                                '"deletedFlag": false,'+
                                '"editLockFlag": false,'+
                                '"id": "2F639BE6-4540-4B0F-B5ED-F002576A4F11",'+
                                '"publicType": "PUBLIC",'+
                                '"tenantId": "162E577A-D1AA-466B-AE5C-AF1D38105F96",'+
                                '"unlockProhibitFlag": false,'+
                                '"updateDatetime": "2018-10-22T08:25:39.000Z",'+
                                '"updateUserCd": "INITIAL",'+
                                '"version": 1,'+
                                '"divColumn": "priorityDivCdCrm",'+
                                '"linefeedFlag": false,'+
                                '"name": "Priority",'+
                                '"note": ""'+
                            '},'+
                            '"divCd": "030",'+
                            '"divCdSeq": 3'+
                        '},'+
                        '"productCrm": {'+
                            '"approvedFlag": false,'+
                            '"createDatetime": "2018-12-05T10:26:41.000Z",'+
                            '"createUserCd": "ASTERIA",'+
                            '"deletedFlag": false,'+
                            '"editLockFlag": false,'+
                            '"id": "d91f9951-8fe6-4c7e-b895-b703f3e134c5",'+
                            '"publicType": "PUBLIC",'+
                            '"tenantId": "162E577A-D1AA-466B-AE5C-AF1D38105F96",'+
                            '"unlockProhibitFlag": false,'+
                            '"updateDatetime": "2019-01-30T12:14:18.000Z",'+
                            '"updateUserCd": "ASTERIA",'+
                            '"version": 4,'+
                            '"name": "Differential Pressure Transmitter",'+
                            '"nameGlobal": "Differential Pressure Transmitter",'+
                            '"nameLocal": "Differential Pressure Transmitter",'+
                            '"productCd": "EJX110A",'+
                            '"productType": "PRODUCT",'+
                            '"productUsageType": "COMPONENTS",'+
                            '"purchasePointQty": 0,'+
                            '"purchasePointUseFlag": true,'+
                            '"replenishmentQty": 0,'+
                            '"stockControlType": "STOCK",'+
                            '"systemCtrlProductFlagCrm": false'+
                        '},'+
                        '"resolutionHourCrm": 0,'+
                        '"rrcEscFlagCrm": false,'+
                        '"salesMailSendFlagCrm": false,'+
                        '"serviceRequestFlagCrm": false,'+
                        '"socEscFlagCrm": false,'+
                        '"sourceDivCdCrm": {'+
                            '"approvedFlag": false,'+
                            '"createDatetime": "2018-10-22T08:25:40.000Z",'+
                            '"createUserCd": "INITIAL",'+
                            '"deletedFlag": false,'+
                            '"editLockFlag": false,'+
                            '"id": "8395C844-3AFF-46EF-A88F-42C398F25D74",'+
                            '"publicType": "PUBLIC",'+
                            '"tenantId": "162E577A-D1AA-466B-AE5C-AF1D38105F96",'+
                            '"unlockProhibitFlag": false,'+
                            '"updateDatetime": "2018-10-22T08:25:40.000Z",'+
                            '"updateUserCd": "INITIAL",'+
                            '"version": 1,'+
                            '"displaySeq": 25,'+
                            '"div": {'+
                                '"approvedFlag": false,'+
                                '"createDatetime": "2018-10-22T08:25:39.000Z",'+
                                '"createUserCd": "INITIAL",'+
                                '"deletedFlag": false,'+
                                '"editLockFlag": false,'+
                                '"id": "F5BE392A-227A-4D7D-A4F2-E5997D8961BE",'+
                                '"publicType": "PUBLIC",'+
                                '"tenantId": "162E577A-D1AA-466B-AE5C-AF1D38105F96",'+
                                '"unlockProhibitFlag": false,'+
                                '"updateDatetime": "2018-10-22T08:25:39.000Z",'+
                                '"updateUserCd": "INITIAL",'+
                                '"version": 1,'+
                                '"divColumn": "sourceDivCdCrm",'+
                                '"linefeedFlag": false,'+
                                '"name": "Source",'+
                                '"note": ""'+
                            '},'+
                            '"divCd": "050",'+
                            '"divCdSeq": 5'+
                        '},'+
                        '"thirdPartyEscFlagCrm": false,'+
                        '"thirdPartyFlagCrm": false,'+
                        '"warrantyEscFlagCrm": false,'+
                        '"warrantyFlagCrm": false'+
                    '}');
                      
        res.setStatusCode(200);
        return res;
    }

}