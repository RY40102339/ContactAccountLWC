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
*  04/19/2021           Kavya                   Removed Customer_Plant__c Object and replaced with AccountContactRelation Object
*/
public class YG_ContractAPIHandler {
    
    public static User userInformation =  YG_Utility.getLoggedInUserInfo(UserInfo.getUserId());
    //public static User userInformation =  YG_Utility.getLoggedInUserInfo('005p0000003rbfUAAQ'); //User01
    //public static User userInformation =  YG_Utility.getLoggedInUserInfo('005p0000004Hvs7AAC');	//anand
    //public static User userInformation =  YG_Utility.getLoggedInUserInfo('005p0000004HwDGAA0'); //selva
    
    /*This method is used to check the Contract API Sync Enable
* 
* */
    @AuraEnabled
    public static Boolean checkContractSync(){
        
        Boolean contractSync = false;
        //get loggedin user contact id
        DateTime lastSyncDate = userInformation.Contact.Account.LastContractSyncAPIDate__c;
        System.debug('lastSyncDate::'+lastSyncDate);
        Id accId = userInformation.Contact.AccountId;
        
        //Datetime in GMT
        DateTime dt = DateTime.now();
        System.debug('dt::'+dt);
        
        //get Contract execution date code
        Map<String, YG_Community_Configuration__c> allValues = YG_Community_Configuration__c.getAll();
        String days = allValues.get('Contract API Sync Duration in Days').Text_1__c;
        String selfRegAccId = allValues.get('YGSelfRegisterAccountId').Text_1__c;
        
        if(lastSyncDate ==  null && accId != selfRegAccId){
            contractSync = true;
        }else{
            if(accId != selfRegAccId){
                System.debug('lastSyncDate.addDays(Integer.valueOf(days)::'+lastSyncDate.addDays(Integer.valueOf(days)));
                if(lastSyncDate.addDays(Integer.valueOf(days)) < dt){
                    System.debug('contractSync');
                    contractSync = true;
                }
            }
        }
        
        if(contractSync){
            System.debug('contractSync');
            
        }
        System.debug('contractSync::'+contractSync);
        return contractSync;
    }
    
    
    /*This method is used to get the List of parent contract for the logged in user
* Used Contract API : Input - Account number
* 					   Output - List of parent contract no (contractIdCrm)
* */
    @AuraEnabled
    public static Map<String, Id> getContractAPI(){
        
        Map<String, YG_Community_Configuration__c> allValues = new Map<String, YG_Community_Configuration__c>();        
        allValues = YG_Community_Configuration__c.getAll();
        String systemid = allValues.get('ShippingAPISystemId').Text_1__c;
        System.debug('systemid ::: '+systemid);
        String endpointURL = allValues.get('ContractAPIEndpointUrl').Text_1__c;
        System.debug('endpointURL ::: '+endpointURL);
        //To get account and contact Id
        String accNo = userInformation.Contact.Account.AccountNumber;
        System.debug('accNo ::: '+accNo);
        String accId = userInformation.Contact.AccountID;
        System.debug('accId ::: '+accId);
        Id conId = userInformation.Contact.Id;        
        String response;
        List<String> contractNoList = new List<String>();
        Map<String, Id> serviceContResult=new Map<String, Id>();
        //List<ServiceContract> servContList=new List<ServiceContract>();
        //Map<String, Id> parentServContMap=new Map<String, Id>();
        
        //getting the existing parent contract record
        List<ServiceContract> exisParentContList=[Select Id,Name From ServiceContract Where AccountId=:accId];
        System.debug('exisParentContList::'+exisParentContList);
        System.debug('exisParentContListSize::'+exisParentContList.size());
        
        // Instantiate a new http object
        Http http = new Http();
        HttpResponse res = new HttpResponse();
        // Instantiate a new HTTP request, specify the method (POST) as well as the endpoint
        HttpRequest req = new HttpRequest(); 
        //configure the Contract API request details
        String contractAPIURL = endpointURL+'?systemid='+systemid;
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');
        req.setMethod('POST');
        req.setTimeout(120000);
        req.setEndpoint(contractAPIURL);
        try{
            //req.setBody('{"type":"contract","dlvCustomerBranch": {"customerBranchCd": "200203364"}}');
            req.setBody('{"type":"contract","dlvCustomerBranch": {"customerBranchCd": "'+accNo+'"}}');
            res = http.send(req);
            if(res.getStatusCode() == 200){
                response = res.getBody();
                String resp1 = res.getBody();
                System.debug('resp1::'+resp1);
                if(response != null){
                    List<ContractAPI> responseList = (List<ContractAPI>)JSON.deserialize(response, List<ContractAPI>.class); 
                    System.debug('responseList::'+responseList);
                    
                    for(ContractAPI cont: responseList){
                        if(!contractNoList.contains(cont.contractIdCrm) && cont.contractIdCrm != null){
                            contractNoList.add(cont.contractIdCrm);
                        }
                        /*ServiceContract servCont=new ServiceContract();
if(cont.contractIdCrm != null){
for(ServiceContract exisServ: exisParentContList){
if(exisServ.Name == cont.contractIdCrm){
servCont.Id =  exisServ.Id;
}
}
servCont.Name = cont.contractIdCrm;
servCont.AccountId = accId;
servContList.add(servCont);
}*/
                    }
                    System.debug('contractNoList::'+contractNoList);
                }
            }
            //if(servContList.size() > 0 && !servContList.isEmpty()){
            if(contractNoList.size() > 0 && !contractNoList.isEmpty()){
                serviceContResult = YG_ContractAPIHandler.getContractItem(contractNoList);
                //upsert servContList;
            }
            System.debug('serviceContResult::'+serviceContResult);
            /*for(ServiceContract parentServCont : servContList){
parentServContMap.put(parentServCont.Name, parentServCont.Id);
}
System.debug('parentServContMap::'+parentServContMap);*/
        }catch(Exception e){
            system.debug('Exception Cause::'+e.getCause());
            system.debug('Exception LineNumber::'+e.getLineNumber());
            system.debug('Exception Message::'+e.getMessage());
            system.debug('Exception StackTrace::'+e.getStackTraceString());
            system.debug('Exception TypeName::'+e.getTypeName());
            YG_Utility.logError('API','Community Component Error',e.getStackTraceString(),
                                'Class:YG_ContractAPIHandler; Method: getContractAPI(); Line #:'+e.getLineNumber()
                                +'; Message:'+e.getMessage(),
                                UserInfo.getUserId());
        }
        //return parentServContMap;
        return serviceContResult;
        
    }
    
    //Contract API response Wrapper class
    public class ContractAPI{
        @AuraEnabled public String type;
        @AuraEnabled public String contractIdCrm;
    }
    
    
    /*This method is used to get the Contract details using the contractItem API
* Input : contractIdCrm  
* Output : Contract details response to store in the service contract Object.
* */
    @AuraEnabled
    public static Map<String, Id> getContractItem(List<String> contractList){
        //public static Map<String, Id> getContractItem(Map<String, Id> parentContracts){
        
        System.debug('contractList::'+contractList);
        //System.debug('parentContracts::'+parentContracts);
        Map<String, YG_Community_Configuration__c> allValues = new Map<String, YG_Community_Configuration__c>();        
        allValues = YG_Community_Configuration__c.getAll();
        String systemid = allValues.get('ShippingAPISystemId').Text_1__c;
        System.debug('systemid ::: '+systemid);
        Id accId = userInformation.Contact.AccountID; //This is used to get the accound id and used to store in service contract object
        System.debug('accId ::: '+accId);
        Map<String, Id> servContResMap=new Map<String, Id>(); // store the service contract with ID.
        
        String endpointURL = allValues.get('ContractItemAPIEndpointUrl').Text_1__c;
        System.debug('endpointURL ::: '+endpointURL);
        String contractItemAPIURL = endpointURL+'?systemid='+systemid;
        ContractItemAPIWrapp contItemMainWrap=new ContractItemAPIWrapp();
        List<ServiceContract> servContractList=new List<ServiceContract>();
        List<ServiceContract> servContList=new List<ServiceContract>(); //list is used to check for the existing service contract
        List<String> lcaNoList=new List<String>(); //to store the Listof LCA no for the scope of products API
        
        //Map for the LCA contract type
        Map<Integer, String> contType=new Map<Integer, String>();
        contType.put(010, 'LCA');
        contType.put(020, 'Exa');
        contType.put(030, 'Parts Management');
        contType.put(040, 'Spot service');
        
        HTTP http = new HTTP();
        HttpRequest req = new HttpRequest();  
        HttpResponse res = new HttpResponse();  
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');
        req.setEndpoint(contractItemAPIURL); 
        req.setMethod('POST'); 
        req.setTimeout(120000);
        Try{
            //Query the service contract for to check the existing contract using accId
            servContList = [Select Id, Contract_No__c, StartDate, EndDate From ServiceContract Where Account.Id =: accId];
            System.debug('servContList::'+servContList);
            
            for(String cont: contractList){
                //for(String cont: parentContracts.keySet()){
                System.debug('cont::'+cont);
                //req.setBody('{"contract": {"contractIdCrm": "YEA-L00328"}}');
                req.setBody('{"contract": {"contractIdCrm": "'+cont+'"},"contractStatus":"CONTRACTED"}');
                //req.setBody('{"contract": {"contractIdCrm": "YEA-L00337"},"contractStatus":"CONTRACTED"}');
                res = http.send(req);
                if(res.getStatusCode() == 200){
                    String resp1 = res.getBody();
                    //System.debug('resp1::'+resp1);
                    List<ContractItemAPIList> contItemResponse = (List<ContractItemAPIList>)JSON.deserialize(resp1, List<ContractItemAPIList>.class);
                    System.debug('contItemResponse::'+contItemResponse);
                    
                    for(ContractItemAPIList contItem: contItemResponse){
                        //Store the LCA no in a list
                        if(!lcaNoList.contains(contItem.lcaNoCrm) && contItem.lcaNoCrm != null){
                            lcaNoList.add(contItem.lcaNoCrm);
                        }  
                    }
                    
                    for(ContractItemAPIList contItem: contItemResponse){
                        ServiceContract servCont=new ServiceContract();
                        if(servContList.size() > 0){
                            for(ServiceContract serv: servContList){
                                if(serv.Contract_No__c == contItem.lcaNoCrm){
                                    servCont.Id = serv.Id;
                                }
                            }
                        }
                        servCont.Contract_No__c = contItem.lcaNoCrm;
                        if(contItem.contract.contractMemo != null){
                            servCont.Name = contItem.contract.contractMemo;
                        }
                        if(contItem.contract.contractIdCrm != null){
                            //servCont.ParentServiceContractId = parentContracts.get(contItem.contract.contractIdCrm);
                            servCont.Parent_Contract_No__c = cont;
                        }
                        servCont.Description = contItem.contractItemMemo;
                        servCont.AccountId = accId;
                        String sDate = contItem.contractStartDate;
                        String sResult = sDate.substring(0,sDate.length()-1);
                        Date startDt = Date.valueOf(sResult);
                        servCont.StartDate = startDt;
                        String eDate = contItem.contractEndDate;
                        String eResult = eDate.substring(0,sDate.length()-1);
                        Date endDt = Date.valueOf(eResult);
                        servCont.EndDate = endDt;   
                        servCont.Contract_categories__c = 'Industrial Automation';
                        servCont.Contract_Type__c = 'LCA';
                        String contractType = contType.get(contItem.contractDivCd.divCd);
                        System.debug('contractType::'+contractType);
                        if(contItem.contractUser != null){
                            String firstName = contItem.contractUser.firstName;
                            String lastName = contItem.contractUser.lastName;
                            servCont.YG_Sales_Manager_Name__c = firstName+''+lastName;
                            servCont.YG_Sales_Manager_Email__c = contItem.contractUser.emailAddress;
                            servCont.YG_Sales_Manager_contact_no__c = contItem.contractUser.telNo;
                        }
                        if(contItem.renewalContractItem != null){
                            servCont.Renewed_Contract__c = contItem.renewalContractItem.lcaNoCrm;
                        }
                        servContractList.add(servCont);
                    }
                }
            }
            System.debug('servContractList::'+servContractList);
            if(servContractList.size() > 0){
                System.debug('servContractList::'+servContractList);
                upsert servContractList;
                System.debug('servContractListSize::'+servContractList.size());
            } 
            for(ServiceContract servRes : servContractList){
                servContResMap.put(servRes.Contract_No__c, servRes.Id);
            }
        }Catch(Exception e){
            system.debug('Exception Cause::'+e.getCause());
            system.debug('Exception LineNumber::'+e.getLineNumber());
            system.debug('Exception Message::'+e.getMessage());
            system.debug('Exception StackTrace::'+e.getStackTraceString());
            system.debug('Exception TypeName::'+e.getTypeName());
            YG_Utility.logError('API','Community Component Error',e.getStackTraceString(),
                                'Class:YG_ContractAPIHandler; Method: getContractItem(); Line #:'+e.getLineNumber()
                                +'; Message:'+e.getMessage(),
                                UserInfo.getUserId());
        }
        System.debug('servContResMap::'+servContResMap);
        return servContResMap;
    }
    public class ContractItemAPIWrapp{
        @AuraEnabled public boolean success =false;
        @AuraEnabled public String errorCode;
        @AuraEnabled public List<ContractItemAPIList> contractItemList;
    }
    public class ContractItemAPIList{
        @AuraEnabled public String lcaNoCrm;
        @AuraEnabled public String contractItemMemo;
        @AuraEnabled public String contractStartDate;
        @AuraEnabled public String contractEndDate;
        @AuraEnabled public contract contract;
        @AuraEnabled public contractDivCd contractDivCd;
        @AuraEnabled public contractUser contractUser;
        @AuraEnabled public renewalContractItem renewalContractItem;
    }
    public class contract{
        @AuraEnabled public String contractMemo;
        @AuraEnabled public String contractIdCrm;
    }
    public class contractDivCd{
        @AuraEnabled public Integer divCd;
    }
    public class contractUser{
        @AuraEnabled public String firstName;
        @AuraEnabled public String lastName;
        @AuraEnabled public String emailAddress;
        @AuraEnabled public String telNo;
    }
    public class renewalContractItem{
        @AuraEnabled public String lcaNoCrm;
    }
    
    /*This method is used to get the contract product details using the lcaNoCrm
* Input - List of contract lcaNoCrm from the Repsonse of getContractItem method
* Output - products and assets associated with the contract
* */
    @AuraEnabled //@future(callout=true)
    public static Boolean getContractProduct(){ /*Map<String, Id> servContResMap, List<String> plantCode*/
        
        //System.debug('servContResMap::'+servContResMap);
        //System.debug('plantCode::'+plantCode);
        Map<String, YG_Community_Configuration__c> allValues = new Map<String, YG_Community_Configuration__c>();        
        allValues = YG_Community_Configuration__c.getAll();
        String systemid = allValues.get('ShippingAPISystemId').Text_1__c;
        System.debug('systemid ::: '+systemid);
        Boolean result = false;
        //Datetime in GMT
        DateTime dt = DateTime.now();
        
        String endpointURL = allValues.get('ContractProductAPIEndpointUrl').Text_1__c;
        System.debug('endpointURL ::: '+endpointURL);
        String contractProductAPIURL = endpointURL+'?systemid='+systemid;
        List<Scope_of_Product__c> scopeOfProdList=new List<Scope_of_Product__c>(); //list is used to check for the existing Scope of product
        List<Scope_of_Product__c> scopeOfProdResList=new List<Scope_of_Product__c>(); //list is used to check for to store the result 
        //List<String> modelCodeList=new List<String>(); //Used to store the scope of products model code list
        Map<String, Id> prodModelcodeMap=new Map<String, Id>(); //get the product details for the scope of products
        //List<String> assetNameList=new List<String>();
        Map<String, Id> assMap=new Map<String, Id>();
        /*List<Customer_Plant__c> cusPlantList=new List<Customer_Plant__c>();
        List<AccountContactRelation> cusPlantList=new List<AccountContactRelation>();*/
        List<Asset> contAssetList=new List<Asset>();
        List<String> deliverableAsset=new List<String>(); // this list is used to check for the duplicate deliverable id for the user account
        
        Id accId = userInformation.Contact.AccountID; //This is used to get the accound id 
        System.debug('accId ::: '+accId);
        Map<String, Id> servContResMap = YG_ContractAPIHelper.getServiceContractMap(accId);
        System.debug('servContResMap ::: '+servContResMap);
        //get Contract Lca no from map
        List<String> contractLcaNoList = new List<String>();
        contractLcaNoList.addall(servContResMap.keySet());
        System.debug('contractLcaNoList::'+contractLcaNoList);
        Map<String, String> scopOfIdDeliIdMap=new Map<String, String>();
        
        //Query the service contract for to check the existing contract using lcaNoCrm
        if(contractLcaNoList.size()>0){
            scopeOfProdList = [Select Id, Name, Asset__r.Name, Product__r.Model_Code__c From Scope_of_Product__c Where Service_Contract__r.Contract_No__c IN: contractLcaNoList];
        }
        System.debug('scopeOfProdList::'+scopeOfProdList);
        
        HTTP http = new HTTP();
        HttpRequest req = new HttpRequest();  
        HttpResponse res = new HttpResponse();  
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');
        req.setEndpoint(contractProductAPIURL); 
        req.setMethod('POST'); 
        req.setTimeout(120000);
        //String lca = 'YEA-L00337-1801-01';
        //String lca = 'YEA-L00344-1802-01';
        //String lca = 'YKO-L00038-2002-01';
        try{
            /*List<Asset> existAssetList = YG_ContractAPIHelper.getAssetDetails(plantCode);
System.debug('existAssetList::'+existAssetList);
for(Asset ass:existAssetList){
assetNameList.add(ass.Name);
}
System.debug('assetNameList::'+assetNameList);*/
            assMap = YG_ContractAPIHelper.getAssetMap(accId);
            System.debug('assMap::'+assMap);
            prodModelcodeMap = YG_ContractAPIHelper.getProductdetails();
            System.debug('prodModelcodeMap::'+prodModelcodeMap);
            for(String lca : contractLcaNoList){
                req.setBody('{"contractItem": {"lcaNoCrm": "'+lca+'","contractStatus":"CONTRACTED"}}');
                res = http.send(req);
                String resp1 = res.getBody();
                //System.debug('resp1::'+resp1);
                List<ContractProductAPIList> contProdResponse = (List<ContractProductAPIList>)JSON.deserialize(resp1, List<ContractProductAPIList>.class);
                System.debug('contProdResponse::'+contProdResponse);
                if(res.getStatusCode() == 200){
                    //System.debug('resp1::'+resp1);
                    
                    for(ContractProductAPIList contProd : contProdResponse){
                        Scope_of_Product__c scopeOfProd=new Scope_of_Product__c();
                        System.debug('contProd::'+contProd);
                        
                        if(contProd.contractItem.lcaNoCrm != null){
                            String lcaNo = contProd.contractItem.lcaNoCrm;
                            scopeOfProd.Service_Contract__c = servContResMap.get(lcaNo);
                        }
                        
                        for(Scope_of_Product__c servProd: scopeOfProdList){
                            //Checking for the existing scope of product record
                            //System.debug('servProd.Name::'+servProd.Name);
                            //System.debug('contProd.id::'+contProd.id);
                            if(servProd.Name == contProd.id){
                                scopeOfProd.Id = servProd.Id;
                            }
                        }
                        scopeOfProd.Name = contProd.id;
                        
                        if(contProd.deliverablesProduct != null){
                            if(!deliverableAsset.contains(contProd.deliverablesProduct.id)){
                                deliverableAsset.add(contProd.deliverablesProduct.id);
                                Asset contAsset=new Asset();
                                if(assMap.containsKey(contProd.deliverablesProduct.id)){
                                    contAsset.Id = assMap.get(contProd.deliverablesProduct.id);
                                    System.debug('contProd.deliverbalesProduct.id::'+contProd.deliverablesProduct.id);
                                }
                                scopeOfProd.DeliverableId__c = contProd.deliverablesProduct.id;
                                contAsset.Name = contProd.deliverablesProduct.id;
                                contAsset.AccountId = accId;
                                contAssetList.add(contAsset);
                            }
                        }
                        
                        
                        scopeOfProd.Full_Model_MS_Code__c = contProd.fullModelCrm;
                        if(contProd.serialNo != null){
                            scopeOfProd.Serial_no__c = contProd.serialNo;
                        }
                        if(contProd.softwareRevisionCrm != null){
                            scopeOfProd.Software_Revision__c = contProd.softwareRevisionCrm;
                        }
                        if(contProd.contractTermsNote != null){
                            scopeOfProd.Scope_Description__c = contProd.contractTermsNote;
                        }
                        if(contProd.contractItem.lcaNoCrm != null){
                            String lcaNo = contProd.contractItem.lcaNoCrm;
                            System.debug('lcaNo::'+lcaNo);
                            scopeOfProd.Service_Contract__c = servContResMap.get(lcaNo);
                        }
                        if(contProd.product != null){
                            //Store the model code in a list
                            if(contProd.product.productCd != null){
                                scopeOfProd.Product__c = prodModelcodeMap.get(contProd.product.productCd);
                            }
                        }
                        scopeOfProdResList.add(scopeOfProd);
                        
                    }
                    
                    /*for(ContractProductAPIList contProd1 : contProdResponse){
System.debug('contProd1::'+contProd1);
Asset contAsset=new Asset();    
//Checking the existing Asset Id
System.debug('assMap::'+assMap);
if(assMap.size() > 0){
if(contProd1.deliverablesProduct != null){
if(assMap.get(contProd1.deliverablesProduct.id) != null){
contAsset.Id =  assMap.get(contProd1.deliverablesProduct.id);
}
}
}
System.debug('contProd1.deliverablesProduct.id;::'+contProd1.deliverablesProduct.id);
contAsset.Name = contProd1.deliverablesProduct.id;
contAsset.AccountId = accId;
//scopOfIdDeliIdMap.put(contProd.deliverablesProduct.id, contProd.id); // Map used to get the deliverable id and scopofprod id
contAssetList.add(contAsset);
}*/
                    
                    
                }
            }
            System.debug('scopeOfProdResList1::'+scopeOfProdResList);
            System.debug('contAssetList::'+contAssetList);
            if(contAssetList.size() > 0){
                upsert contAssetList;
            }
            System.debug('contAssetList::'+contAssetList);
            for(Scope_of_Product__c sopResponse : scopeOfProdResList){
                for(Asset upsertAsset: contAssetList){
                    //System.debug('upsertAsset::'+upsertAsset);
                    //System.debug('upsertAsset.Name::'+upsertAsset.Name);
                    //System.debug('sopResponse.DeliverableId__c::'+sopResponse.DeliverableId__c);
                    if(upsertAsset.Name == sopResponse.DeliverableId__c){
                        sopResponse.Asset__c = upsertAsset.id;
                        System.debug('sopResponse.Asset__c::'+sopResponse.Asset__c);
                    }
                }
            }
            System.debug('scopeOfProdResList2::'+scopeOfProdResList);
            
            if(scopeOfProdResList.size() > 0){
                upsert scopeOfProdResList;
                result = true;
            }
            
            Account accUpdate=new Account();
            accUpdate.Id = accId;
            accUpdate.LastContractSyncAPIDate__c = dt;
            update accUpdate;
            
            
        }Catch(Exception e){
            system.debug('Exception Cause::'+e.getCause());
            system.debug('Exception LineNumber::'+e.getLineNumber());
            system.debug('Exception Message::'+e.getMessage());
            system.debug('Exception StackTrace::'+e.getStackTraceString());
            system.debug('Exception TypeName::'+e.getTypeName());
            YG_Utility.logError('API','Community Component Error',e.getStackTraceString(),
                                'Class:YG_ContractAPIHandler; Method: getContractProduct(); Line #:'+e.getLineNumber()
                                +'; Message:'+e.getMessage(),
                                UserInfo.getUserId());
        }
        System.debug('result::'+result);
        return result;
    }
    public class ContractProductAPIWrapp{
        @AuraEnabled public boolean success =false;
        @AuraEnabled public String errorCode;
        @AuraEnabled public List<ContractProductAPIList> ContractProductList;
    }
    
    public class ContractProductAPIList{
        @AuraEnabled public String id;
        @AuraEnabled public String contractTermsNote;
        @AuraEnabled public String fullModelCrm;
        @AuraEnabled public String softwareRevisionCrm;
        @AuraEnabled public String serialNo;
        @AuraEnabled public contractItem contractItem;
        @AuraEnabled public deliverablesProduct deliverablesProduct;
        @AuraEnabled public product product;
    }
    public class contractItem{
        @AuraEnabled public String lcaNoCrm;
    }
    public class deliverablesProduct{
        @AuraEnabled public String id;
    }
    public class product{
        @AuraEnabled public String productCd;
    }
    
    /*This method is used to get the contract Service Menu's using the lcaNoCrm
* Input - List of contract lcaNoCrm from the Repsonse of getContractItem method
* Output - products and assets associated with the contract
* */
    @AuraEnabled 
    public static Map<String, Map<String, Id>> getContractServMenu(String lcaNo){
        
        System.debug('lcaNo::'+lcaNo);
        Map<String, YG_Community_Configuration__c> allValues = new Map<String, YG_Community_Configuration__c>();        
        allValues = YG_Community_Configuration__c.getAll();
        String systemid = allValues.get('ShippingAPISystemId').Text_1__c;
        System.debug('systemid ::: '+systemid);
        List<Entitlement> entitlementList=new List<Entitlement>();
        Map<String, Id> servContIdMap=new Map<String, Id>();
        Map<String, Id> entitleMap=new Map<String, Id>(); //To store the final entitlement id and ContractMainteCrmID__c
        Map<String, Map<String, Id>> resultMap=new Map<String, Map<String, Id>>(); //Result map with the lca no and entitleMap
        Map<String, String> contractTypeMap=new Map<String, String>();
        contractTypeMap.put('NON_APPLICATION', 'N/A');
        contractTypeMap.put('CASE_COUNT', 'Case count');
        contractTypeMap.put('SR_CLOSED_COUNT', 'Times of visit');
        contractTypeMap.put('WORK_HOURS', 'Work hours');
        Map<String, String> perPeriodMap=new Map<String, String>();
        perPeriodMap.put('LCA_PERIOD', 'Contract period');
        perPeriodMap.put('YEAR', 'Year');
        perPeriodMap.put('MONTH', 'Month');
        perPeriodMap.put('WEEK', 'Week');
        
        String endpointURL = allValues.get('ContractMainteCrmAPIEndpointUrl').Text_1__c;
        System.debug('endpointURL ::: '+endpointURL);
        String contractMainteCrmAPIURL = endpointURL+'?systemid='+systemid;
        
        Id accId = userInformation.Contact.AccountID; //This is used to get the accound id and used to store in Entitlement object
        System.debug('accId ::: '+accId);
        servContIdMap = YG_ContractAPIHelper.getServiceContractMap(accId);
        System.debug('servContIdMap ::: '+servContIdMap);
        
        List<Entitlement> entitleList=[Select Name, AccountId, ContractMainteCrmID__c, ServiceContract.Contract_No__c, ServiceContract.Id  From Entitlement Where ServiceContract.Contract_No__c =: lcaNo];
        System.debug('entitleList1::'+entitleList);
        
        HTTP http = new HTTP();
        HttpRequest req = new HttpRequest();  
        HttpResponse res = new HttpResponse();  
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');
        req.setEndpoint(contractMainteCrmAPIURL); 
        req.setMethod('POST'); 
        req.setTimeout(120000);
        
        try{
            //for(String lca : contractLcaNoList){
            req.setBody('{"contractItem": {"lcaNoCrm": "'+lcaNo+'","contractStatus":"CONTRACTED"}}');
            res = http.send(req);
            String resp1 = res.getBody();
            System.debug('resp1::'+resp1);
            List<ContractMainteCrmAPIList> contMainteResponse = (List<ContractMainteCrmAPIList>)JSON.deserialize(resp1, List<ContractMainteCrmAPIList>.class);
            if(res.getStatusCode() == 200){
                //System.debug('resp1::'+resp1);
                System.debug('contMainteResponse::'+contMainteResponse);
                for(ContractMainteCrmAPIList contMainte : contMainteResponse){
                    System.debug('contMainte::'+contMainte);
                    Entitlement servContEntitle=new Entitlement();
                    for(Entitlement entitle: entitleList){
                        if(entitle.ContractMainteCrmID__c == contMainte.id){
                            servContEntitle.Id = entitle.Id;
                        }
                    }
                    servContEntitle.Name = contMainte.mainte.name;
                    servContEntitle.ContractMainteCrmID__c = contMainte.id;
                    servContEntitle.AccountId = accId;
                    servContEntitle.ServiceContractId = servContIdMap.get(lcaNo);
                    if(contMainte.entitlementTypeCrm != null){
                        servContEntitle.Entitlement_type__c = contractTypeMap.get(contMainte.entitlementTypeCrm);
                    }
                    if(contMainte.entitlementPeriodTypeCrm != null){
                        servContEntitle.Per__c = perPeriodMap.get(contMainte.entitlementPeriodTypeCrm);
                    }
                    servContEntitle.Entitlement_quantity__c = contMainte.entitlementQtyCrm;
                    servContEntitle.Entitlement_balance__c = contMainte.entitlementQtyCrm - contMainte.entitlementUsedCrm;
                    system.debug('servContEntitle::'+servContEntitle);
                    entitlementList.add(servContEntitle);
                    
                }
            }
            system.debug('entitlementList::'+entitlementList);
            if(entitlementList.size() > 0){
                upsert entitlementList;
            }
            for(Entitlement resEntitle: entitlementList){
                entitleMap.put(resEntitle.ContractMainteCrmID__c, resEntitle.Id);
            }
            System.debug('entitleMap::'+entitleMap);
            
            resultMap.put(lcaNo, entitleMap); //Final result
            System.debug('resultMap::'+resultMap);
            //}
        }Catch(Exception e){
            system.debug('Exception Cause::'+e.getCause());
            system.debug('Exception LineNumber::'+e.getLineNumber());
            system.debug('Exception Message::'+e.getMessage());
            system.debug('Exception StackTrace::'+e.getStackTraceString());
            system.debug('Exception TypeName::'+e.getTypeName());
            YG_Utility.logError('API','Community Component Error',e.getStackTraceString(),
                                'Class:YG_ContractAPIHandler; Method: getContractServMenu(); Line #:'+e.getLineNumber()
                                +'; Message:'+e.getMessage(),
                                UserInfo.getUserId());
        }
        return resultMap;
    }
    
    public class ContractMainteCrmAPIWrapp{
        @AuraEnabled public boolean success =false;
        @AuraEnabled public String errorCode;
        @AuraEnabled public List<ContractMainteCrmAPIList> ContractMainteCrmList;
        
    }
    public class ContractMainteCrmAPIList{
        @AuraEnabled public String id;
        @AuraEnabled public String entitlementTypeCrm;
        @AuraEnabled public String entitlementPeriodTypeCrm;
        @AuraEnabled public Double entitlementQtyCrm;
        @AuraEnabled public Double entitlementUsedCrm;
        @AuraEnabled public mainte mainte;
        @AuraEnabled public contractItem contractItem;
    }
    public class mainte{
        @AuraEnabled public String name;
    }
    
    /*This method is used to get the contract Service Menu's using the lcaNoCrm
* Input - List of contract lcaNoCrm from the Repsonse of getContractItem method
* Output - products and assets associated with the contract
* */
    
    @AuraEnabled
    //public static void getInspectionDetails(String lcaNo){
    public static boolean getInspectionDetails(Map<String, Map<String, Id>> result){
        System.debug('result::'+result);
        Map<String, Id> entitleResMap = new Map<String, Id>();
        String lcaNo = null;
        boolean resultVal = false;
        for(String lca: result.keySet()){
            lcaNo = lca;
            entitleResMap =  result.get(lca);
        }
        System.debug('entitleResMap::'+entitleResMap);
        System.debug('lcaNo::'+lcaNo);
        Map<String, Id> servContMap=new Map<String, Id>();
        Map<String, YG_Community_Configuration__c> allValues = new Map<String, YG_Community_Configuration__c>();        
        allValues = YG_Community_Configuration__c.getAll();
        String systemid = allValues.get('ShippingAPISystemId').Text_1__c;
        System.debug('systemid ::: '+systemid);
        List<WorkOrder> resWorkOrderList=new List<WorkOrder>();
        Id ServContId;
        
        String endpointURL = allValues.get('ContractInspectionAPIEndpointUrl').Text_1__c;
        System.debug('endpointURL ::: '+endpointURL);
        String contractInspectAPIURL = endpointURL+'?systemid='+systemid;
        
        Id accId = userInformation.Contact.AccountID; //This is used to get the accound id and used to store in Entitlement object
        System.debug('accId ::: '+accId);
        if(lcaNo != null){
            servContMap = YG_ContractAPIHelper.getServiceContractMap(accId);
        }
        System.debug('servContMap::'+servContMap);
        List<WorkOrder> workOrd=[Select Id, ServiceContract.Id, Inspection_Id__c, ServiceContract.Contract_No__c, Entitlement.Id, Entitlement.ContractMainteCrmID__c 
                                 From WorkOrder Where ServiceContract.Contract_No__c =:lcaNo];
        System.debug('workOrd ::: '+workOrd);
        /*if(workOrd[0].ServiceContract.Id != null){
ServContId = workOrd[0].ServiceContract.Id;
}*/ 
        //Map for the LCA contract type
        Map<String, String> inspectStatusMap=new Map<String, String>();
        inspectStatusMap.put('010', 'Inspection Created');
        inspectStatusMap.put('020', 'Case Created');
        inspectStatusMap.put('050', 'Partially Completed');
        inspectStatusMap.put('090', 'Completed');
        
        HTTP http = new HTTP();
        HttpRequest req = new HttpRequest();  
        HttpResponse res = new HttpResponse();  
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');
        req.setEndpoint(contractInspectAPIURL); 
        req.setMethod('POST'); 
        req.setTimeout(120000);
        
        try{
            //for(String lca : contractLcaNoList){
            req.setBody('{"contractItem": {"lcaNoCrm": "'+lcaNo+'","contractStatus":"CONTRACTED"}}');
            res = http.send(req);
            String resp1 = res.getBody();
            System.debug('resp1::'+resp1);
            List<ContractInspectAPIList> contInspectResponse = (List<ContractInspectAPIList>)JSON.deserialize(resp1, List<ContractInspectAPIList>.class);
            System.debug('contInspectResponse::'+contInspectResponse);
            if(res.getStatusCode() == 200){
                //System.debug('resp1::'+resp1);
                System.debug('contInspectResponse::'+contInspectResponse);
                for(ContractInspectAPIList contInspect : contInspectResponse){
                    WorkOrder wrkOrder=new WorkOrder();
                    for(WorkOrder wrk: workOrd){
                        if(wrk.Inspection_Id__c == contInspect.id){
                            wrkOrder.Id = wrk.Id;
                        }
                    }
                    wrkOrder.Inspection_Id__c = contInspect.id;
                    wrkOrder.AccountId = accId;
                    wrkOrder.ServiceContractId = servContMap.get(lcaNo);
                    wrkOrder.Subject = contInspect.inspectMemo;
                    wrkOrder.Description = contInspect.inspectNote;
                    wrkOrder.EntitlementId = entitleResMap.get(contInspect.targetLcaMainteIdCrm);
                    //inspectPlanDate converting from string to date format
                    if(contInspect.inspectPlanDate != null){
                        String sDate = contInspect.inspectPlanDate;
                        String sResult = sDate.substring(0,sDate.length()-1);
                        Date sheduleDt = Date.valueOf(sResult);
                        wrkOrder.Scheduled_Date__c = sheduleDt;
                    }
                    //inspectReportDate converting from string to date format
                    if(contInspect.inspectReportDate != null){
                        String actualDate = contInspect.inspectReportDate;
                        String actResult = actualDate.substring(0,actualDate.length()-1);
                        Date actualReportDt = Date.valueOf(actResult);
                        wrkOrder.Actual_Date__c = actualReportDt;
                    }
                    if(contInspect.inspectDivCd != null){
                        System.debug('contInspect.inspectDivCd.divCd::'+contInspect.inspectDivCd.divCd);
                        wrkOrder.Status = inspectStatusMap.get(contInspect.inspectDivCd.divCd);
                    }
                    System.debug('wrkOrder::'+wrkOrder);
                    resWorkOrderList.add(wrkOrder);
                }
                resultVal = true;
            }
            System.debug('resWorkOrderList::'+resWorkOrderList);
            if(resWorkOrderList.size() > 0){
                upsert resWorkOrderList;
            }
            
        }catch(Exception e){
            system.debug('getMessage::'+e.getMessage());
            system.debug('getLineNumber::'+e.getLineNumber());
            system.debug('getCause::'+e.getCause());
        }
        return resultVal;
        
    }
    
    public class ContractInspectAPIWrapp{
        @AuraEnabled public boolean success =false;
        @AuraEnabled public String errorCode;
        @AuraEnabled public List<ContractInspectAPIList> ContractMainteCrmList;
    }
    
    public class ContractInspectAPIList{
        @AuraEnabled public String id;
        @AuraEnabled public String inspectMemo;
        @AuraEnabled public String inspectNote;
        @AuraEnabled public String targetLcaMainteIdCrm;
        @AuraEnabled public String inspectStatus;
        @AuraEnabled public String inspectPlanDate;
        @AuraEnabled public String inspectReportDate;
        @AuraEnabled public inspectDivCd inspectDivCd;
    }
    public class inspectDivCd{
        @AuraEnabled public String divCd;
    }
    
}