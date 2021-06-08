/*
*******************************************************************************************************
* (C) Copyright 2020 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Chitrakishore M
* @version 1.0
* @created 21/04/2021
* @description  
* This class is used for exposing the REST API url for the plant details.
*
* @test class name - 
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  
*/

@isTest
public class YG_PlantAPIRestResourceTest {
    
    static testmethod void plantRestResourceMethod(){
        
        Account acc = new Account();
        //acc.ParentId ='200124172'; 
        acc.AccountNumber ='200124172';
        acc.Name ='THE BAHRAIN PETROLEUM COMPANY B.S.C.(CLOSED)';
        acc.Type ='Customer';
        insert acc;
        
        Account acc1 = new Account();
        acc1.ParentId =acc.Id; 
        acc1.AccountNumber ='200124172';
        acc1.Name ='THE BAHRAIN PETROLEUM COMPANY B.S.C.(CLOSED)';
        acc1.Type ='Plant';
        insert acc1;
        
        YG_PlantAPIRestResource.Request_InfoList reqInfo = new YG_PlantAPIRestResource.Request_InfoList();
        YG_PlantAPIRestResource.PlantResponse plantres = new YG_PlantAPIRestResource.PlantResponse();
        YG_PlantAPIRestResource.PlantDetail plantDet = new YG_PlantAPIRestResource.PlantDetail();
        
        
        reqInfo.accountNo = '200124172';
                
        test.startTest();
            
        //Instantiate the Rest Context
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/getPlant';	//Request URL
        req.httpMethod = 'POST'; //Request Type
        req.requestBody = Blob.valueof(JSON.serialize(reqInfo, true));
        RestContext.request = req;
        RestContext.response =res;
        
        
        plantres = YG_PlantAPIRestResource.plantSync();
        System.debug('Response ::: '+plantres);
        Test.stopTest();
        
        
        
        
    }
    
}