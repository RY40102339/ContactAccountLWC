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
public class YG_CaseAPIMockCallout implements HttpCalloutMock{
	
    public HTTPResponse respond(HTTPRequest request) {
       
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setHeader('X-CLA-Code', YG_Constants.CL_CODE_SUCCESS);
        
        System.debug('request.getEndpoint() ::: '+request.getEndpoint());
        res.setBody('[ { '+
                  '"warrantyFlagCrm" : false,'+
                  '"warrantyEscFlagCrm" : false,'+
                  '"thirdPartyFlagCrm" : false,'+
                  '"thirdPartyEscFlagCrm" : false,'+
                  '"targetLcaMainteIdCrm" : "2E23033C-1B16-4EA5-8F20-1893C2EB6A08",'+
                  '"socEscFlagCrm" : false,'+
                  '"serviceRequestFlagCrm" : false,'+
                  '"salesMailSendFlagCrm" : false,'+
                  '"rrcEscFlagCrm" : false,'+
                  '"resolutionHourCrm" : 0.0,'+
                  '"priorityDivCdCrm" : {'+
                    '"divCdSeq" : 3,'+
                    '"divCd" : "030",'+
                    '"div" : {'+
                      '"note" : "",'+
                      '"name" : "Priority",'+
                      '"linefeedFlag" : false,'+
                      '"divColumn" : "priorityDivCdCrm",'+
                      '"version" : 1,'+
                      '"updateUserCd" : "INITIAL",'+
                      '"updateDatetime" : "2018-10-22T08:25:39.000Z",'+
                      '"unlockProhibitFlag" : false,'+
                      '"tenantId" : "162E577A-D1AA-466B-AE5C-AF1D38105F96",'+
                      '"publicType" : "PUBLIC",'+
                      '"id" : "2F639BE6-4540-4B0F-B5ED-F002576A4F11",'+
                      '"editLockFlag" : false,'+
                      '"deletedFlag" : false,'+
                      '"createUserCd" : "INITIAL",'+
                      '"createDatetime" : "2018-10-22T08:25:39.000Z",'+
                      '"approvedFlag" : false'+
                    '},'+
                    '"displaySeq" : 15,'+
                    '"version" : 1,'+
                    '"updateUserCd" : "INITIAL",'+
                    '"updateDatetime" : "2018-10-22T08:25:39.000Z",'+
                    '"unlockProhibitFlag" : false,'+
                    '"tenantId" : "162E577A-D1AA-466B-AE5C-AF1D38105F96",'+
                    '"publicType" : "PUBLIC",'+
                    '"id" : "4EE9BF3D-82C1-4F52-BD49-27B18BCBBED0",'+
                    '"editLockFlag" : false,'+
                    '"deletedFlag" : false,'+
                    '"createUserCd" : "INITIAL",'+
                    '"createDatetime" : "2018-10-22T08:25:39.000Z",'+
                    '"approvedFlag" : false'+
                  '},'+
                  '"majorTroubleFlagCrm" : false,'+
                  '"knowledgeFlagCrm" : false,'+
                  '"irEscFlagCrm" : false,'+
                  '"grcEscFlagCrm" : false,'+
                  '"doaFlagCrm" : false,'+
                  '"complaintFlagCrm" : false,'+
                  '"chargeableFlagCrm" : false,'+
                  '"caseStatusCrm" : "IN_PROGRESS_BY_OWNER",'+
                  '"serviceUser" : {'+
                    '"userLicenseType" : "GENERAL",'+
                    '"userCd" : "AUYKGW-46806055",'+
                    '"themeType" : "mint-choc",'+
                    '"telNo" : "61-8-6141-7085",'+
                    '"loginFailureCount" : 0,'+
                    '"lastName" : "Santos",'+
                    '"firstName" : "Michael",'+
                    '"emailAddress" : "Michael.Santos@au.yokogawa.com",'+
                    '"displayLimitFlag" : true,'+
                    '"disabledFlag" : false,'+
                    '"bpmUserFlag" : true,'+
                    '"approvalAuthorityFlag" : false,'+
                    '"apiEnabledFlag" : false,'+
                    '"version" : 5,'+
                    '"updateUserCd" : "AUYKGW-46806055",'+
                    '"updateDatetime" : "2019-03-05T01:38:18.000Z",'+
                    '"unlockProhibitFlag" : false,'+
                    '"tenantId" : "162E577A-D1AA-466B-AE5C-AF1D38105F96",'+
                    '"publicType" : "PUBLIC",'+
                    '"id" : "C33E2D93-0E40-407A-836A-3E439E3A7B44",'+
                    '"editLockFlag" : false,'+
                    '"deletedFlag" : false,'+
                    '"createUserCd" : "ALL_SYS_ADMIN",'+
                    '"createDatetime" : "2018-12-13T10:41:27.000Z",'+
                    '"approvedFlag" : false'+
                  '},'+
                  '"serviceOrg" : {'+
                    '"telNo" : "61-8-6141-7000",'+
                    '"outsourceFlag" : false,'+
                    '"organizationCd" : "O0000000007",'+
                    '"name" : "YAU-Chevron:Sub Service Team within YAU ",'+
                    '"faxNo" : "61-8-6141-7067",'+
                    '"effectDate" : "2018-04-01Z",'+
                    '"addressLocal" : "unit 1, 115 Belmont Avenue, Belmont WA 6104 Australia",'+
                    '"address" : "unit 1, 115 Belmont Avenue, Belmont WA 6104 Australia",'+
                    '"version" : 2,'+
                    '"updateUserCd" : "ALL_SYS_ADMIN",'+
                    '"updateDatetime" : "2018-11-13T00:20:07.000Z",'+
                    '"unlockProhibitFlag" : false,'+
                    '"tenantId" : "162E577A-D1AA-466B-AE5C-AF1D38105F96",'+
                    '"publicType" : "PUBLIC",'+
                    '"id" : "BCE3C474-BBAA-4253-B3EE-8C42AFE0B532",'+
                    '"editLockFlag" : false,'+
                    '"deletedFlag" : false,'+
                    '"createUserCd" : "ALL_SYS_ADMIN",'+
                    '"createDatetime" : "2018-11-13T00:04:48.000Z",'+
                    '"approvedFlag" : false'+
                  '},'+
                  '"serviceChargeType" : "FREE",'+
                  '"receiptUser" : {'+
                    '"userLicenseType" : "GENERAL",'+
                    '"userCd" : "AUYKGW-46806055",'+
                    '"themeType" : "mint-choc",'+
                    '"telNo" : "61-8-6141-7085",'+
                    '"loginFailureCount" : 0,'+
                    '"lastName" : "Santos",'+
                    '"firstName" : "Michael",'+
                    '"emailAddress" : "Michael.Santos@au.yokogawa.com",'+
                    '"displayLimitFlag" : true,'+
                    '"disabledFlag" : false,'+
                    '"bpmUserFlag" : true,'+
                    '"approvalAuthorityFlag" : false,'+
                    '"apiEnabledFlag" : false,'+
                    '"version" : 5,'+
                    '"updateUserCd" : "AUYKGW-46806055",'+
                    '"updateDatetime" : "2019-03-05T01:38:18.000Z",'+
                    '"unlockProhibitFlag" : false,'+
                    '"tenantId" : "162E577A-D1AA-466B-AE5C-AF1D38105F96",'+
                    '"publicType" : "PUBLIC",'+
                    '"id" : "C33E2D93-0E40-407A-836A-3E439E3A7B44",'+
                    '"editLockFlag" : false,'+
                    '"deletedFlag" : false,'+
                    '"createUserCd" : "ALL_SYS_ADMIN",'+
                    '"createDatetime" : "2018-12-13T10:41:27.000Z",'+
                    '"approvedFlag" : false'+
                  '},'+
                  '"receiptOrg" : {'+
                    '"telNo" : "61-8-6141-7000",'+
                    '"outsourceFlag" : false,'+
                    '"organizationCd" : "O0000000007",'+
                    '"name" : "YAU-Chevron:Sub Service Team within YAU ",'+
                    '"faxNo" : "61-8-6141-7067",'+
                    '"effectDate" : "2018-04-01Z",'+
                    '"addressLocal" : "unit 1, 115 Belmont Avenue, Belmont WA 6104 Australia",'+
                    '"address" : "unit 1, 115 Belmont Avenue, Belmont WA 6104 Australia",'+
                    '"version" : 2,'+
                    '"updateUserCd" : "ALL_SYS_ADMIN",'+
                    '"updateDatetime" : "2018-11-13T00:20:07.000Z",'+
                    '"unlockProhibitFlag" : false,'+
                    '"tenantId" : "162E577A-D1AA-466B-AE5C-AF1D38105F96",'+
                    '"publicType" : "PUBLIC",'+
                    '"id" : "BCE3C474-BBAA-4253-B3EE-8C42AFE0B532",'+
                    '"editLockFlag" : false,'+
                    '"deletedFlag" : false,'+
                    '"createUserCd" : "ALL_SYS_ADMIN",'+
                    '"createDatetime" : "2018-11-13T00:04:48.000Z",'+
                    '"approvedFlag" : false'+
                  '},'+
                  '"receiptDatetime" : "2019-03-05T05:25:05.000Z",'+
                  '"originalDeleteFlag" : false,'+
                  '"incidentStatus" : "RECEIPTED",'+
                  '"incidentSeq" : 1,'+
                  '"incidentNo" : "YEA-C1903-00025",'+
                  '"incidentMemo" : "M451603 - Chevron - Wheatstone - 2019",'+
                  '"dlvCustomerBranch" : {'+
                    '"yokogawaFlagCrm" : false,'+
                    '"ygsTransportZoneCrm" : "ZAU9000001",'+
                    '"ygsTimeZoneCrm" : "AUSWA",'+
                    '"ygsRegionCrm" : "WA",'+
                    '"ygsIndustryCdCrm" : "12010",'+
                    '"ygsGovernmentSignCrm" : "Z2",'+
                    '"ygsAuthorityGroupCrm" : "2U00",'+
                    '"ygsAccountGroupCrm" : "Y002",'+
                    '"shortListFlagCrm" : true,'+
                    '"disabledFlagCrm" : false,'+
                    '"deleteFlagCrm" : false,'+
                    '"communicationLangCrm" : "EN",'+
                    '"zipCode" : "6000",'+
                    '"nameLocal" : "CHEVRON AUSTRALIA PTY LTD",'+
                    '"nameGlobal" : "CHEVRON AUSTRALIA PTY LTD",'+
                    '"name" : "CHEVRON AUSTRALIA PTY LTD",'+
                    '"customerBranchCd" : "200066853",'+
                    '"customer" : {'+
                      '"ygsIndustryCdCrm" : "29000",'+
                      '"ygsAuthorityGroupCrm" : "2U00",'+
                      '"deleteFlagCrm" : false,'+
                      '"name" : "CHEVRON AUSTRALIA PTY LTD",'+
                      '"customerCd" : "100051983",'+
                      '"consumerFlag" : false,'+
                      '"version" : 2,'+
                      '"updateUserCd" : "ASTERIA2",'+
                      '"updateDatetime" : "2019-02-04T03:04:31.000Z",'+
                      '"unlockProhibitFlag" : false,'+
                      '"tenantId" : "162E577A-D1AA-466B-AE5C-AF1D38105F96",'+
                      '"publicType" : "PUBLIC",'+
                      '"id" : "5a5ff881-05d2-4700-85e6-a616c66583c7",'+
                      '"editLockFlag" : false,'+
                      '"deletedFlag" : false,'+
                      '"createUserCd" : "ASTERIA",'+
                      '"createDatetime" : "2018-12-05T06:01:00.000Z",'+
                      '"approvedFlag" : false'+
                    '},'+
                    '"addressLocal" : "PERTH L24, QV1, 250 ST GEORGES TCE",'+
                    '"addressGlobal" : "PERTH L24, QV1, 250 ST GEORGES TCE",'+
                    '"address" : "PERTH L24, QV1, 250 ST GEORGES TCE",'+
                    '"version" : 2,'+
                    '"updateUserCd" : "IF_USER_0409",'+
                    '"updateDatetime" : "2019-04-11T08:28:32.000Z",'+
                    '"unlockProhibitFlag" : false,'+
                    '"tenantId" : "162E577A-D1AA-466B-AE5C-AF1D38105F96",'+
                    '"publicType" : "PUBLIC",'+
                    '"id" : "b6556e25-db96-4374-9bbe-c9ddbd841fbb",'+
                    '"editLockFlag" : false,'+
                    '"deletedFlag" : false,'+
                    '"createUserCd" : "ASTERIA",'+
                    '"createDatetime" : "2018-12-05T12:57:50.000Z",'+
                    '"approvedFlag" : false'+
                  '},'+
                  '"dlvCustomer" : {'+
                    '"ygsIndustryCdCrm" : "29000",'+
                    '"ygsAuthorityGroupCrm" : "2U00",'+
                    '"deleteFlagCrm" : false,'+
                    '"name" : "CHEVRON AUSTRALIA PTY LTD",'+
                    '"customerCd" : "100051983",'+
                    '"consumerFlag" : false,'+
                    '"version" : 2,'+
                    '"updateUserCd" : "ASTERIA2",'+
                    '"updateDatetime" : "2019-02-04T03:04:31.000Z",'+
                    '"unlockProhibitFlag" : false,'+
                    '"tenantId" : "162E577A-D1AA-466B-AE5C-AF1D38105F96",'+
                    '"publicType" : "PUBLIC",'+
                    '"id" : "5a5ff881-05d2-4700-85e6-a616c66583c7",'+
                    '"editLockFlag" : false,'+
                    '"deletedFlag" : false,'+
                    '"createUserCd" : "ASTERIA",'+
                    '"createDatetime" : "2018-12-05T06:01:00.000Z",'+
                    '"approvedFlag" : false'+
                  '},'+
                  '"customerBranch" : {'+
                    '"yokogawaFlagCrm" : false,'+
                    '"ygsTransportZoneCrm" : "ZAU9000001",'+
                    '"ygsTimeZoneCrm" : "AUSWA",'+
                    '"ygsRegionCrm" : "WA",'+
                    '"ygsIndustryCdCrm" : "12010",'+
                    '"ygsGovernmentSignCrm" : "Z2",'+
                    '"ygsAuthorityGroupCrm" : "2U00",'+
                    '"ygsAccountGroupCrm" : "Y002",'+
                    '"shortListFlagCrm" : true,'+
                    '"disabledFlagCrm" : false,'+
                    '"deleteFlagCrm" : false,'+
                    '"communicationLangCrm" : "EN",'+
                    '"zipCode" : "6000",'+
                    '"nameLocal" : "CHEVRON AUSTRALIA PTY LTD",'+
                    '"nameGlobal" : "CHEVRON AUSTRALIA PTY LTD",'+
                    '"name" : "CHEVRON AUSTRALIA PTY LTD",'+
                    '"customerBranchCd" : "200066853",'+
                    '"customer" : {'+
                      '"ygsIndustryCdCrm" : "29000",'+
                      '"ygsAuthorityGroupCrm" : "2U00",'+
                      '"deleteFlagCrm" : false,'+
                      '"name" : "CHEVRON AUSTRALIA PTY LTD",'+
                      '"customerCd" : "100051983",'+
                      '"consumerFlag" : false,'+
                      '"version" : 2,'+
                      '"updateUserCd" : "ASTERIA2",'+
                      '"updateDatetime" : "2019-02-04T03:04:31.000Z",'+
                      '"unlockProhibitFlag" : false,'+
                      '"tenantId" : "162E577A-D1AA-466B-AE5C-AF1D38105F96",'+
                      '"publicType" : "PUBLIC",'+
                      '"id" : "5a5ff881-05d2-4700-85e6-a616c66583c7",'+
                      '"editLockFlag" : false,'+
                      '"deletedFlag" : false,'+
                      '"createUserCd" : "ASTERIA",'+
                      '"createDatetime" : "2018-12-05T06:01:00.000Z",'+
                      '"approvedFlag" : false'+
                    '},'+
                    '"addressLocal" : "PERTH L24, QV1, 250 ST GEORGES TCE",'+
                    '"addressGlobal" : "PERTH L24, QV1, 250 ST GEORGES TCE",'+
                    '"address" : "PERTH L24, QV1, 250 ST GEORGES TCE",'+
                    '"version" : 2,'+
                    '"updateUserCd" : "IF_USER_0409",'+
                    '"updateDatetime" : "2019-04-11T08:28:32.000Z",'+
                    '"unlockProhibitFlag" : false,'+
                    '"tenantId" : "162E577A-D1AA-466B-AE5C-AF1D38105F96",'+
                    '"publicType" : "PUBLIC",'+
                    '"id" : "b6556e25-db96-4374-9bbe-c9ddbd841fbb",'+
                    '"editLockFlag" : false,'+
                    '"deletedFlag" : false,'+
                    '"createUserCd" : "ASTERIA",'+
                    '"createDatetime" : "2018-12-05T12:57:50.000Z",'+
                    '"approvedFlag" : false'+
                  '},'+
                  '"customer" : {'+
                    '"ygsIndustryCdCrm" : "29000",'+
                    '"ygsAuthorityGroupCrm" : "2U00",'+
                    '"deleteFlagCrm" : false,'+
                    '"name" : "CHEVRON AUSTRALIA PTY LTD",'+
                    '"customerCd" : "100051983",'+
                    '"consumerFlag" : false,'+
                    '"version" : 2,'+
                    '"updateUserCd" : "ASTERIA2",'+
                    '"updateDatetime" : "2019-02-04T03:04:31.000Z",'+
                    '"unlockProhibitFlag" : false,'+
                    '"tenantId" : "162E577A-D1AA-466B-AE5C-AF1D38105F96",'+
                    '"publicType" : "PUBLIC",'+
                    '"id" : "5a5ff881-05d2-4700-85e6-a616c66583c7",'+
                    '"editLockFlag" : false,'+
                    '"deletedFlag" : false,'+
                    '"createUserCd" : "ASTERIA",'+
                    '"createDatetime" : "2018-12-05T06:01:00.000Z",'+
                    '"approvedFlag" : false'+
                  '},'+
                  '"contractItem" : {'+
                    '"sumDealPriceCrm" : 1000000.0,'+
                    '"salesMailSendFlagCrm" : false,'+
                    '"revUpFlagCrm" : false,'+
                    '"revNoCrm" : 1,'+
                    '"proposedFlagCrm" : false,'+
                    '"opportunityCreatedFlagCrm" : false,'+
                    '"multiYearLcaFlagCrm" : false,'+
                    '"lcaNoCrm" : "YEA-L00328-1901-01",'+
                    '"ifCreatedFlagCrm" : false,'+
                    '"gissIfTypeCrm" : "NEW",'+
                    '"expiredMailTargetFlagCrm" : false,'+
                    '"expiredMailSendFlagCrm" : false,'+
                    '"expiredAlertDateCrm" : "2019-09-30Z",'+
                    '"contractedDate" : "2019-03-05Z",'+
                    '"contractStatus" : "CONTRACTED",'+
                    '"contractStartDate" : "2019-01-01Z",'+
                    '"contractItemSeq" : 1,'+
                    '"contractItemMemo" : "M451603 - Chevron - Wheatstone - 2019",'+
                    '"contractEndDate" : "2019-12-31Z",'+
                    '"contract" : {'+
                      '"ifCreatedFlagCrm" : false,'+
                      '"firstContractedDateCrm" : "2016-01-01Z",'+
                      '"contractIdCrm" : "YEA-L00328",'+
                      '"contractNo" : "2ce4dcf4-6d56-41dd-986a-bad0b514e62c",'+
                      '"contractMemo" : "M451603 - Chevron - Wheatstone",'+
                      '"contractCancelFlag" : false,'+
                      '"version" : 2,'+
                      '"updateUserCd" : "AUYKGW-46802020",'+
                      '"updateDatetime" : "2019-03-05T03:32:21.000Z",'+
                      '"unlockProhibitFlag" : false,'+
                      '"tenantId" : "162E577A-D1AA-466B-AE5C-AF1D38105F96",'+
                      '"publicType" : "PUBLIC_PARENT",'+
                      '"ownerOrgId" : "BCE3C474-BBAA-4253-B3EE-8C42AFE0B532",'+
                      '"id" : "B949B819-8488-47C4-B2A4-F1ED08330D4E",'+
                      '"editLockFlag" : false,'+
                      '"deletedFlag" : false,'+
                      '"createUserCd" : "AUYKGW-46802020",'+
                      '"createDatetime" : "2019-03-05T03:27:19.000Z",'+
                      '"approvedFlag" : false'+
                    '},'+
                    '"version" : 2,'+
                    '"updateUserCd" : "AUYKGW-46802020",'+
                    '"updateDatetime" : "2019-03-05T03:32:22.000Z",'+
                    '"unlockProhibitFlag" : true,'+
                    '"tenantId" : "162E577A-D1AA-466B-AE5C-AF1D38105F96",'+
                    '"publicType" : "PUBLIC",'+
                    '"id" : "7B7D1723-C8B1-4965-AE2D-5EC0D0545E82",'+
                    '"editLockFlag" : true,'+ 
                    '"deletedFlag" : false,'+
                    '"createUserCd" : "AUYKGW-46802020",'+
                    '"createDatetime" : "2019-03-05T03:28:48.000Z",'+
                    '"approvedFlag" : false'+
                  '},'+
                  '"version" : 1,'+
                  '"updateUserCd" : "AUYKGW-46806055",'+
                  '"updateDatetime" : "2019-03-05T05:25:05.000Z",'+
                  '"unlockProhibitFlag" : false,'+
                  '"tenantId" : "162E577A-D1AA-466B-AE5C-AF1D38105F96",'+
                  '"publicType" : "PUBLIC_PARENT",'+
                  '"ownerOrgId" : "BCE3C474-BBAA-4253-B3EE-8C42AFE0B532",'+
                  '"id" : "21F49DED-1CA8-4B95-AF3A-62C3789310CF",'+
                  '"editLockFlag" : false,'+
                  '"deletedFlag" : false,'+
                  '"createUserCd" : "AUYKGW-46806055",'+
                  '"createDatetime" : "2019-03-05T05:25:05.000Z",'+
                  '"approvedFlag" : false,'+
                  '"type" : "incident"'+                
            '},{'+                   
                          '"warrantyEscFlagCrm" : false,'+
                          '"thirdPartyFlagCrm" : true,'+
                          '"thirdPartyEscFlagCrm" : false,'+
                          '"softwareRevisionCrm" : "NA",'+
                          '"socEscFlagCrm" : false,'+
                          '"serviceRequestFlagCrm" : false,'+
                          '"serialNoCrm" : "NA",'+
                          '"salesMailSendFlagCrm" : false,'+
                          '"rrcEscFlagCrm" : false,'+
                          '"resolutionHourCrm" : 0.0,'+
                          '"recommendationNoteCrm" : "",'+
                          '"productClassDivCdCrm" : {'+
                            '"divCdSeq" : 32,'+
                            '"divCd" : "P2200",'+
                            '"div" : {'+
                              '"note" : "",'+
                              '"name" : "Product Class Code",'+
                              '"linefeedFlag" : false,'+
                              '"divColumn" : "productClassDivCdCrm",'+
                              '"version" : 1,'+
                              '"updateUserCd" : "INITIAL",'+
                              '"updateDatetime" : "2018-10-22T08:25:39.000Z",'+
                              '"unlockProhibitFlag" : false,'+
                              '"tenantId" : "162E577A-D1AA-466B-AE5C-AF1D38105F96",'+
                              '"publicType" : "PUBLIC",'+
                              '"id" : "7253DB21-B149-4378-9D25-96EE7A787AE3",'+
                              '"editLockFlag" : false,'+
                              '"deletedFlag" : false,'+
                              '"createUserCd" : "INITIAL",'+
                              '"createDatetime" : "2018-10-22T08:25:39.000Z",'+
                              '"approvedFlag" : false'+
                            '},'+
                            '"displaySeq" : 160,'+
                            '"version" : 1,'+
                            '"updateUserCd" : "INITIAL",'+
                            '"updateDatetime" : "2018-10-22T08:25:31.000Z",'+
                            '"unlockProhibitFlag" : false,'+
                            '"tenantId" : "162E577A-D1AA-466B-AE5C-AF1D38105F96",'+
                            '"publicType" : "PUBLIC",'+
                            '"id" : "B6DA369B-0E03-40C5-81BF-6747C0000032",'+
                            '"editLockFlag" : false,'+
                            '"deletedFlag" : false,'+
                            '"createUserCd" : "INITIAL",'+
                            '"createDatetime" : "2018-10-22T08:25:31.000Z",'+
                            '"approvedFlag" : false'+
                          '},'+
                    	  '"productCrm" : {'+
                            '"systemCtrlProductFlagCrm" : false,'+
                            '"stockControlType" : "STOCK",'+
                            '"replenishmentQty" : 0.0,'+
                            '"purchasePointUseFlag" : true,'+
                            '"purchasePointQty" : 0.0,'+
                            '"productUsageType" : "COMPONENTS",'+
                            '"productType" : "PRODUCT",'+
                            '"productCd" : "EJX530A",'+
                            '"nameLocal" : "Gauge Pressure Transmitter",'+
                            '"nameGlobal" : "Gauge Pressure Transmitter",'+
                            '"name" : "Gauge Pressure Transmitter",'+
                            '"version" : 4,'+
                            '"updateUserCd" : "ASTERIA",'+
                            '"updateDatetime" : "2019-01-30T12:18:28.000Z",'+
                            '"unlockProhibitFlag" : false,'+
                            '"tenantId" : "162E577A-D1AA-466B-AE5C-AF1D38105F96",'+
                            '"publicType" : "PUBLIC",'+
                            '"id" : "f780a843-deb8-461b-b599-d80c9d3ef0c6",'+
                            '"editLockFlag" : false,'+
                            '"deletedFlag" : false,'+
                            '"createUserCd" : "ASTERIA",'+
                            '"createDatetime" : "2018-12-05T10:27:51.000Z",'+
                            '"approvedFlag" : false'+
                          '},'+	                                
                          '"primaryDeliverablesProduct" : {'+
                            '"thirdPartyFlagCrm" : false,'+
                            '"systemIdCrm" : "VP702082",'+
                            '"qty" : 1.0,'+
                            '"productDate" : "2012-10-22Z",'+
                            '"dlvProductSeq" : 1,'+
                            '"deliverables" : {'+
                              '"systemIdCrm" : "VP702082",'+
                              '"projectNameCrm" : "APLNG",'+
                              '"dlvCreateTypeCrm" : "GISS",'+
                              '"name" : "APLNG Test Rig",'+
                              '"deliverablesNo" : "D000000279",'+
                              '"version" : 7,'+
                              '"updateUserCd" : "INITIAL_DELIV",'+
                              '"updateDatetime" : "2019-03-12T06:00:01.000Z",'+
                              '"unlockProhibitFlag" : false,'+
                              '"tenantId" : "162E577A-D1AA-466B-AE5C-AF1D38105F96",'+
                              '"publicType" : "PUBLIC",'+
                              '"id" : "5F86434E-FF92-11E8-B7DC-06328AF41CA4",'+
                              '"editLockFlag" : false,'+
                              '"deletedFlag" : false,'+
                              '"createUserCd" : "INITIAL",'+
                              '"createDatetime" : "2018-11-01T00:00:00.000Z",'+
                              '"approvedFlag" : false'+
                            '},'+
                            '"version" : 7,'+
                            '"updateUserCd" : "INITIAL_DELIV",'+
                            '"updateDatetime" : "2019-03-12T06:00:01.000Z",'+
                            '"unlockProhibitFlag" : false,'+
                            '"tenantId" : "162E577A-D1AA-466B-AE5C-AF1D38105F96",'+
                            '"publicType" : "PUBLIC",'+
                            '"id" : "5F864AE0-FF92-11E8-B7DC-06328AF41CA4",'+
                            '"editLockFlag" : false,'+
                            '"deletedFlag" : false,'+
                            '"createUserCd" : "INITIAL",'+
                            '"createDatetime" : "2018-11-01T00:00:00.000Z",'+
                            '"approvedFlag" : false'+
                          '},'+
                    	  '"plantCrm" : {'+
                            '"plantNo" : "300000110",'+
                            '"name" : "APLNG Test Rig",'+
                            '"deleteFlagCrm" : false,'+
                            '"version" : 3,'+
                            '"updateUserCd" : "AUYKGW-46802020",'+
                            '"updateDatetime" : "2019-01-19T10:23:09.000Z",'+
                            '"unlockProhibitFlag" : false,'+
                            '"tenantId" : "162E577A-D1AA-466B-AE5C-AF1D38105F96",'+
                            '"publicType" : "PUBLIC",'+
                            '"id" : "33B4326B-FF81-11E8-B7DC-06328AF41CA4",'+
                            '"editLockFlag" : false,'+
                            '"deletedFlag" : false,'+
                            '"createUserCd" : "INITIAL",'+
                            '"createDatetime" : "2018-11-01T00:00:00.000Z",'+
                            '"approvedFlag" : false'+
                          '},'+
                          '"priorityDivCdCrm" : {'+
                            '"divCdSeq" : 3,'+
                            '"divCd" : "030",'+
                            '"div" : {'+
                              '"note" : "",'+
                              '"name" : "Priority",'+
                              '"linefeedFlag" : false,'+
                              '"divColumn" : "priorityDivCdCrm",'+
                              '"version" : 1,'+
                              '"updateUserCd" : "INITIAL",'+
                              '"updateDatetime" : "2018-10-22T08:25:39.000Z",'+
                              '"unlockProhibitFlag" : false,'+
                              '"tenantId" : "162E577A-D1AA-466B-AE5C-AF1D38105F96",'+
                              '"publicType" : "PUBLIC",'+
                              '"id" : "2F639BE6-4540-4B0F-B5ED-F002576A4F11",'+
                              '"editLockFlag" : false,'+
                              '"deletedFlag" : false,'+
                              '"createUserCd" : "INITIAL",'+
                              '"createDatetime" : "2018-10-22T08:25:39.000Z",'+
                              '"approvedFlag" : false'+
                            '},'+
                            '"displaySeq" : 15,'+
                            '"version" : 1,'+
                            '"updateUserCd" : "INITIAL",'+
                            '"updateDatetime" : "2018-10-22T08:25:39.000Z",'+
                            '"unlockProhibitFlag" : false,'+
                            '"tenantId" : "162E577A-D1AA-466B-AE5C-AF1D38105F96",'+
                            '"publicType" : "PUBLIC",'+
                            '"id" : "4EE9BF3D-82C1-4F52-BD49-27B18BCBBED0",'+
                            '"editLockFlag" : false,'+
                            '"deletedFlag" : false,'+
                            '"createUserCd" : "INITIAL",'+
                            '"createDatetime" : "2018-10-22T08:25:39.000Z",'+
                            '"approvedFlag" : false'+
                          '},'+
                          '"majorTroubleFlagCrm" : true,'+
                          '"knowledgeFlagCrm" : false,'+
                          '"irEscFlagCrm" : false,'+
                          '"grcEscFlagCrm" : false,'+
                          '"fullModelCrm" : "GC8000",'+
                          '"executedResolutionNoteCrm" : "Set 034QT0030 Reserved stream number to “0”.",'+
                          '"doaFlagCrm" : false,'+
                          '"complaintFlagCrm" : true,'+
                          '"closedUserCrm" : {'+
                            '"userLicenseType" : "GENERAL",'+
                            '"userCd" : "AUYKGW-46806026",'+
                            '"themeType" : "afternoon",'+
                            '"telNo" : "61-8-6141-7003",'+
                            '"loginFailureCount" : 0,'+
                            '"lastName" : "Kingsley",'+
                            '"firstName" : "Chris",'+
                            '"emailAddress" : "Chris.Kingsley@au.yokogawa.com",'+
                            '"displayLimitFlag" : true,'+
                            '"disabledFlag" : false,'+
                            '"bpmUserFlag" : true,'+
                            '"approvalAuthorityFlag" : false,'+
                            '"apiEnabledFlag" : false,'+
                            '"version" : 2,'+
                            '"updateUserCd" : "ALL_SYS_ADMIN",'+
                            '"updateDatetime" : "2018-12-18T11:19:57.000Z",'+
                            '"unlockProhibitFlag" : false,'+
                            '"tenantId" : "162E577A-D1AA-466B-AE5C-AF1D38105F96",'+
                            '"publicType" : "PUBLIC",'+
                            '"id" : "D835EBED-9904-4842-A55F-2677A960A976",'+
                            '"editLockFlag" : false,'+
                            '"deletedFlag" : false,'+
                            '"createUserCd" : "ALL_SYS_ADMIN",'+
                            '"createDatetime" : "2018-12-13T10:41:26.000Z",'+
                            '"approvedFlag" : false'+
                          '},'+
                          '"closedDatetimeCrm" : "2017-09-01T03:46:52.000Z",'+
                          '"chargeableFlagCrm" : true,'+
                          '"caseTypeCrm" : "ENG",'+
                          '"caseStatusCrm" : "CLOSED",'+
                          '"caseClassTypeCrm" : "ON_CALL",'+
                          '"actionTakenTypeCrm" : "EMAIL",'+
                          '"actionTakenNoteCrm" : "Communication raised with Kelvin Leong to try to identify cause of alarm.",'+
                          '"workOrg" : {'+
                            '"telNo" : "61-2-8870-1100",'+
                            '"outsourceFlag" : false,'+
                            '"organizationCd" : "O0000000006",'+
                            '"name" : "YAU:Country Repporting to YEA",'+
                            '"faxNo" : "61-2-8870-1100",'+
                            '"effectDate" : "2018-04-01Z",'+
                            '"addressLocal" : "Tower A, 112-118 Talavera Road, Macquarie Park NSW 2113, Australia",'+
                            '"address" : "Tower A, 112-118 Talavera Road, Macquarie Park NSW 2113, Australia",'+
                            '"version" : 2,'+
                            '"updateUserCd" : "ALL_SYS_ADMIN",'+
                            '"updateDatetime" : "2018-11-13T00:20:06.000Z",'+
                            '"unlockProhibitFlag" : false,'+
                            '"tenantId" : "162E577A-D1AA-466B-AE5C-AF1D38105F96",'+
                            '"publicType" : "PUBLIC",'+
                            '"id" : "3F324137-E808-4FD4-B1F2-1DEE424F2AE9",'+
                            '"editLockFlag" : false,'+
                            '"deletedFlag" : false,'+
                            '"createUserCd" : "ALL_SYS_ADMIN",'+
                            '"createDatetime" : "2018-11-13T00:04:48.000Z",'+
                            '"approvedFlag" : false'+
                          '},'+
                          '"serviceUser" : {'+
                            '"userLicenseType" : "GENERAL",'+
                            '"userCd" : "AUYKGW-46806026",'+
                            '"themeType" : "afternoon",'+
                            '"telNo" : "61-8-6141-7003",'+
                            '"loginFailureCount" : 0,'+
                            '"lastName" : "Kingsley",'+
                            '"firstName" : "Chris",'+
                            '"emailAddress" : "Chris.Kingsley@au.yokogawa.com",'+
                            '"displayLimitFlag" : true,'+
                            '"disabledFlag" : false,'+
                            '"bpmUserFlag" : true,'+
                            '"approvalAuthorityFlag" : false,'+
                            '"apiEnabledFlag" : false,'+
                            '"version" : 2,'+
                            '"updateUserCd" : "ALL_SYS_ADMIN",'+
                            '"updateDatetime" : "2018-12-18T11:19:57.000Z",'+
                            '"unlockProhibitFlag" : false,'+
                            '"tenantId" : "162E577A-D1AA-466B-AE5C-AF1D38105F96",'+
                            '"publicType" : "PUBLIC",'+
                            '"id" : "D835EBED-9904-4842-A55F-2677A960A976",'+
                            '"editLockFlag" : false,'+
                            '"deletedFlag" : false,'+
                            '"createUserCd" : "ALL_SYS_ADMIN",'+
                            '"createDatetime" : "2018-12-13T10:41:26.000Z",'+
                            '"approvedFlag" : false'+
                          '},'+
                          '"serviceOrg" : {'+
                            '"telNo" : "61-8-6141-7000",'+
                            '"outsourceFlag" : false,'+
                            '"organizationCd" : "O0000000007",'+
                            '"name" : "YAU-Chevron:Sub Service Team within YAU ",'+
                            '"faxNo" : "61-8-6141-7067",'+
                            '"effectDate" : "2018-04-01Z",'+
                            '"addressLocal" : "unit 1, 115 Belmont Avenue, Belmont WA 6104 Australia",'+
                            '"address" : "unit 1, 115 Belmont Avenue, Belmont WA 6104 Australia",'+
                            '"version" : 2,'+
                            '"updateUserCd" : "ALL_SYS_ADMIN",'+
                            '"updateDatetime" : "2018-11-13T00:20:07.000Z",'+
                            '"unlockProhibitFlag" : false,'+
                            '"tenantId" : "162E577A-D1AA-466B-AE5C-AF1D38105F96",'+
                            '"publicType" : "PUBLIC",'+
                            '"id" : "BCE3C474-BBAA-4253-B3EE-8C42AFE0B532",'+
                            '"editLockFlag" : false,'+
                            '"deletedFlag" : false,'+
                            '"createUserCd" : "ALL_SYS_ADMIN",'+
                            '"createDatetime" : "2018-11-13T00:04:48.000Z",'+
                            '"approvedFlag" : false'+
                          '},'+
                          '"receiptDatetime" : "2017-08-22T16:00:00.000Z",'+
                          '"originalDeleteFlag" : false,'+
                          '"incidentStatus" : "NO_WORK_COMPLETED",'+
                          '"incidentSeq" : 0,'+
                          '"incidentNote" : "GC Tag 034QT0030 is creating multiple error 550 FTP fail alarms",'+
                          '"incidentNo" : "YEA-C1708-00068",'+
                          '"incidentMemo" : "PCAS Error 550 - FTP Fail",'+
                          '"dlvCustomerBranch" : {'+
                            '"yokogawaFlagCrm" : false,'+
                            '"ygsTransportZoneCrm" : "ZAU9000001",'+
                            '"ygsTimeZoneCrm" : "AUSWA",'+
                            '"ygsRegionCrm" : "WA",'+
                            '"ygsIndustryCdCrm" : "12010",'+
                            '"ygsGovernmentSignCrm" : "Z2",'+
                            '"ygsAuthorityGroupCrm" : "2U00",'+
                            '"ygsAccountGroupCrm" : "Y002",'+
                            '"shortListFlagCrm" : true,'+
                            '"disabledFlagCrm" : false,'+
                            '"deleteFlagCrm" : false,'+
                            '"communicationLangCrm" : "EN",'+
                            '"zipCode" : "6000",'+
                            '"nameLocal" : "CHEVRON AUSTRALIA PTY LTD",'+
                            '"nameGlobal" : "CHEVRON AUSTRALIA PTY LTD",'+
                            '"name" : "CHEVRON AUSTRALIA PTY LTD",'+
                            '"customerBranchCd" : "200066853",'+
                            '"customer" : {'+
                              '"ygsIndustryCdCrm" : "29000",'+
                              '"ygsAuthorityGroupCrm" : "2U00",'+
                              '"deleteFlagCrm" : false,'+
                              '"name" : "CHEVRON AUSTRALIA PTY LTD",'+
                              '"customerCd" : "100051983",'+
                              '"consumerFlag" : false,'+
                              '"version" : 2,'+
                              '"updateUserCd" : "ASTERIA2",'+
                              '"updateDatetime" : "2019-02-04T03:04:31.000Z",'+
                              '"unlockProhibitFlag" : false,'+
                              '"tenantId" : "162E577A-D1AA-466B-AE5C-AF1D38105F96",'+
                              '"publicType" : "PUBLIC",'+
                              '"id" : "5a5ff881-05d2-4700-85e6-a616c66583c7",'+
                              '"editLockFlag" : false,'+
                              '"deletedFlag" : false,'+
                              '"createUserCd" : "ASTERIA",'+
                              '"createDatetime" : "2018-12-05T06:01:00.000Z",'+
                              '"approvedFlag" : false'+
                            '},'+
                            '"addressLocal" : "PERTH L24, QV1, 250 ST GEORGES TCE",'+
                            '"addressGlobal" : "PERTH L24, QV1, 250 ST GEORGES TCE",'+
                            '"address" : "PERTH L24, QV1, 250 ST GEORGES TCE",'+
                            '"version" : 2,'+
                            '"updateUserCd" : "IF_USER_0409",'+
                            '"updateDatetime" : "2019-04-11T08:28:32.000Z",'+
                            '"unlockProhibitFlag" : false,'+
                            '"tenantId" : "162E577A-D1AA-466B-AE5C-AF1D38105F96",'+
                            '"publicType" : "PUBLIC",'+
                            '"id" : "b6556e25-db96-4374-9bbe-c9ddbd841fbb",'+
                            '"editLockFlag" : false,'+
                            '"deletedFlag" : false,'+
                            '"createUserCd" : "ASTERIA",'+
                            '"createDatetime" : "2018-12-05T12:57:50.000Z",'+
                            '"approvedFlag" : false'+
                          '},'+
                          '"defectFindDatetime" : "2017-08-23T00:00:00.000Z",'+
                          '"customerBranch" : {'+
                            '"yokogawaFlagCrm" : false,'+
                            '"ygsTransportZoneCrm" : "ZAU9000001",'+
                            '"ygsTimeZoneCrm" : "AUSWA",'+
                            '"ygsRegionCrm" : "WA",'+
                            '"ygsIndustryCdCrm" : "12010",'+
                            '"ygsGovernmentSignCrm" : "Z2",'+
                            '"ygsAuthorityGroupCrm" : "2U00",'+
                            '"ygsAccountGroupCrm" : "Y002",'+
                            '"shortListFlagCrm" : true,'+
                            '"disabledFlagCrm" : false,'+
                            '"deleteFlagCrm" : false,'+
                            '"communicationLangCrm" : "EN",'+
                            '"zipCode" : "6000",'+
                            '"nameLocal" : "CHEVRON AUSTRALIA PTY LTD",'+
                            '"nameGlobal" : "CHEVRON AUSTRALIA PTY LTD",'+
                            '"name" : "CHEVRON AUSTRALIA PTY LTD",'+
                            '"customerBranchCd" : "200066853",'+
                            '"customer" : {'+
                              '"ygsIndustryCdCrm" : "29000",'+
                              '"ygsAuthorityGroupCrm" : "2U00",'+
                              '"deleteFlagCrm" : false,'+
                              '"name" : "CHEVRON AUSTRALIA PTY LTD",'+
                              '"customerCd" : "100051983",'+
                              '"consumerFlag" : false,'+
                              '"version" : 2,'+
                              '"updateUserCd" : "ASTERIA2",'+
                              '"updateDatetime" : "2019-02-04T03:04:31.000Z",'+
                              '"unlockProhibitFlag" : false,'+
                              '"tenantId" : "162E577A-D1AA-466B-AE5C-AF1D38105F96",'+
                              '"publicType" : "PUBLIC",'+
                              '"id" : "5a5ff881-05d2-4700-85e6-a616c66583c7",'+
                              '"editLockFlag" : false,'+
                              '"deletedFlag" : false,'+
                              '"createUserCd" : "ASTERIA",'+
                              '"createDatetime" : "2018-12-05T06:01:00.000Z",'+
                              '"approvedFlag" : false'+
                            '},'+
                            '"addressLocal" : "PERTH L24, QV1, 250 ST GEORGES TCE",'+
                            '"addressGlobal" : "PERTH L24, QV1, 250 ST GEORGES TCE",'+
                            '"address" : "PERTH L24, QV1, 250 ST GEORGES TCE",'+
                            '"version" : 2,'+
                            '"updateUserCd" : "IF_USER_0409",'+
                            '"updateDatetime" : "2019-04-11T08:28:32.000Z",'+
                            '"unlockProhibitFlag" : false,'+
                            '"tenantId" : "162E577A-D1AA-466B-AE5C-AF1D38105F96",'+
                            '"publicType" : "PUBLIC",'+
                            '"id" : "b6556e25-db96-4374-9bbe-c9ddbd841fbb",'+
                            '"editLockFlag" : false,'+
                            '"deletedFlag" : false,'+
                            '"createUserCd" : "ASTERIA",'+
                            '"createDatetime" : "2018-12-05T12:57:50.000Z",'+
                            '"approvedFlag" : false'+
                          '},'+
                          '"expandMemo1" : "CAS-17H-0329",'+
                          '"version" : 1,'+
                          '"updateUserCd" : "INITIAL",'+
                          '"updateDatetime" : "2018-11-01T00:00:00.000Z",'+
                          '"unlockProhibitFlag" : true,'+
                          '"tenantId" : "162E577A-D1AA-466B-AE5C-AF1D38105F96",'+
                          '"publicType" : "PUBLIC_PARENT",'+
                          '"ownerOrgId" : "BCE3C474-BBAA-4253-B3EE-8C42AFE0B532",'+
                          '"id" : "331ED3F7-01E1-11E9-B7DC-06328AF41CA4",'+
                          '"editLockFlag" : true,'+
                          '"deletedFlag" : false,'+
                          '"createUserCd" : "INITIAL",'+
                          '"createDatetime" : "2018-11-01T00:00:00.000Z",'+
                          '"approvedFlag" : false,'+
                          '"type" : "incident"'+
                        '}'+ 
                    ']');
                      
        res.setStatusCode(200);
        return res;
    }
}