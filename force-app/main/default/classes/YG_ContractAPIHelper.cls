/********************************************************************************************************
* (C) Copyright 2020 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Vinod A
* @version 1.0
* @created 05/01/2021
* @description 
* This class used to get Contract API 
*
* @test class name - 
*
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  
*/
public class YG_ContractAPIHelper {
    
    //This method is used to get the service contract for the respected account
    /*@AuraEnabled
    public static List<ServiceContract> getServiceContractList(Id accId){
        List<ServiceContract> servContList=new List<ServiceContract>();
        servContList = [Select Id, Contract_No__c, StartDate, EndDate From ServiceContract Where AccountId=: accId];
        System.debug('servContList::'+servContList);
        return servContList;
    }*/
    
    //This method is used to get the Service contract with the SFDC Id
    @AuraEnabled
    public static Map<String, Id> getServiceContractMap(Id accId){
        Map<String, Id> servContMap=new Map<String, Id>();
        List<ServiceContract> servContList=new List<ServiceContract>();
        servContList = [Select Id, Contract_No__c, StartDate, EndDate From ServiceContract Where AccountId=: accId];
        for(ServiceContract servCont: servContList){
            servContMap.put(servCont.Contract_No__c, servCont.Id);
        }
        System.debug('servContMap::'+servContMap);
        return servContMap;
    }
    
    //This method is used to get the Asset for the plant code 
	/*@AuraEnabled 
    public static List<Asset> getAssetDetails(List<String> plantCode){
        //get the existing system asset using plant code
            List<Asset> existAssetList = [Select Name From Asset Where Plant__r.Plant_Code__c IN: plantCode AND Station_Type__c = ''];
        System.debug('existAssetList::'+existAssetList);
        return existAssetList;
    }*/
    
    @AuraEnabled 
    public static Map<String, Id> getAssetMap(Id accId){
        //get the existing system asset using plant code
        System.debug('accId::'+accId);
        Map<String, Id> assetMap=new Map<String, Id>();
        
        List<Asset> existAssetList = [Select Name, Id From Asset Where Account.Id =:accId AND Station_Type__c = ''];
        System.debug('existAssetList::'+existAssetList);
        for(Asset ass:existAssetList){
            assetMap.put(ass.name, ass.id);
        }
        System.debug('assetMap::'+assetMap);
        return assetMap;
    }
    
    //This method is used to get the Product modelcode and its SFDC ID //for the service contract
    @AuraEnabled
    public static Map<String, Id> getProductdetails(/*List<String> modCodeList*/){
        Map<String, Id> prodModelcode = new Map<String, Id>();
        //if(modCodeList.size() > 0){
            List<Product2> productList = [Select Id, Model_Code__c From Product2 /*Where Model_Code__c IN :modCodeList*/];
            for(Product2 prod: productList){
                prodModelcode.put(prod.Model_Code__c, prod.Id);
            }
        //}
        return prodModelcode;
    }
    
}