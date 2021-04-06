/*
*******************************************************************************************************
* (C) Copyright 2020 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Chitrakishore
* @version 1.0
* @created 21/10/2020
* @description 
* This class is used to write the Apex test class coverage for Plant API Mock Callout.
*
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  
*  
*
*/

@isTest
public class YG_PlantAPIMockCallout implements HttpCalloutMock{
    
	public HTTPResponse respond(HTTPRequest request) {
       
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setHeader('X-CLA-Code', YG_Constants.CL_CODE_SUCCESS);
        
        System.debug('request.getEndpoint() ::: '+request.getEndpoint());
        res.setBody('[ { '+
                  '"type": "plantCrm",'+
                  '"approvedFlag": false,'+
                  '"createDatetime": "2018-11-01T00:00:00.000Z",'+
                  '"createUserCd": "INITIAL",'+
                  '"deletedFlag": false,'+
                  '"editLockFlag": false,'+
                  '"id": "33B5B770-FF81-11E8-B7DC-06328AF41CA4",'+
                  '"publicType": "PUBLIC",'+
                  '"tenantId": "162E577A-D1AA-466B-AE5C-AF1D38105F96",'+
                  '"unlockProhibitFlag": false,'+
                  '"updateDatetime": "2019-02-07T08:39:23.000Z",'+
                  '"updateUserCd": "AUYKGW-46802020",'+
                  '"version": 2,'+
                  '"customer":       {'+
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
                  '"customerBranch":       {'+
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
                     '"customer":          {'+
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
                  '"deleteFlagCrm": false,'+
                  '"name": "Chevron Gorgon Utilities",'+
                  '"plantNo": "300000158"'+
            '}]');
                      
        res.setStatusCode(200);
        return res;
    }
}