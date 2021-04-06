/*
*******************************************************************************************************
* (C) Copyright 2020 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Jayaprasath
* @version 1.0
* @created 08/14/2020
* @description 
* This class is used to write the methods for Overview page Grid section.
*
* @test class name - YG_OverviewGridControllerTest
*
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  11/19/2020			Selvaraj.T				Re-Written the class logic according to changes
*/

public class YG_OverviewGridController {
    
    public static User userInformation =  YG_Utility.getLoggedInUserInfo(UserInfo.getUserId());
    
    //This method is used to get the case count for Overview page 
    @AuraEnabled
    public static caseOverviewWrapper getCaseOverviewDetails(String plantCode, String catType, Integer recordLimit, Integer offset){
        
        system.debug('catType::'+catType);
        system.debug('recordLimit::'+recordLimit);
        system.debug('offset::'+offset);
        system.debug('plantCode::'+plantCode);
        
        caseOverviewWrapper cseWrap = new caseOverviewWrapper();
        List<CaseChartData> caseChartList = new List<CaseChartData>(); // case data for chart
        List<CaseData> caseDataList = new List<CaseData>(); // case data for grid
        List<Case> allCaseList = new List<Case>(); // to store the all case records in List
        List<Case> allCaseList2 = new List<Case>();
        List<Id> prodCseId=new List<Id>();
        List<Id> sysCseId=new List<Id>();
        List<Id> inqCseId=new List<Id>();
        List<Case> caseList = new List<Case>(); // to store the case records in List
        List<AggregateResult> caseTypeList = new List<AggregateResult>();
        List<String> prodService=new List<String>{'050','030','040','080','100','900'};
        List<String> sysService=new List<String>{'010','020','040','060','070','100','900'};
        Integer totalCaseCnt = 0;
        Integer prodCaseCnt = 0;
        Integer sysCaseCnt = 0;
        Integer inqCaseCnt = 0;
        Integer activeBtnSize;
        
        //Defining array for chart color 
        String [] arrayOfColorcode = new List<String>();
        Integer i = 0;
        arrayOfColorcode.add('#FFEE00');
        arrayOfColorcode.add('#F1BC1A');
        arrayOfColorcode.add('#CE4E0E');
        arrayOfColorcode.add('#0458AA');
        arrayOfColorcode.add('#00316C');
        arrayOfColorcode.add('#00694C');
        arrayOfColorcode.add('#00A04C');
        
        try{
            
            //Get the user lang code
            String langCode = YG_CommonUtils.getLanguageCode(userInformation.LanguageLocaleKey); 
            system.debug('langCode::'+langCode);            
            
            //To get account and contact Id
            Id accId = userInformation.Contact.AccountId;
            Id conId = userInformation.Contact.Id;
            system.debug('accId::'+accId);
            system.debug('conId::'+conId);
            
            //get self registered account id
            Map<String, YG_Community_Configuration__c> allValues = YG_Community_Configuration__c.getAll();
            String selfRegAccId = allValues.get('YGSelfRegisterAccountId').Text_1__c;
            
            //query all cases under specific account / contact without plant code
            if(accId == selfRegAccId){
                allCaseList = [Select Id, CreatedDate, Description, Progress__c, Service_You_Require__c,
                               ProductId, AssetId, Asset.Product2.Category__r.Category_type__c, Product.Category__r.Category_type__c, 
                               Type, Reason, ServAir_Created_Date__c From Case Where account.id = :accId And contact.id = :conId And status = 'Active' And Type IN ('Request For Service','Submit An Inquiry')];
            }else{
                allCaseList = [Select Id, CreatedDate, Description, Progress__c, Service_You_Require__c,
                               ProductId, AssetId, Asset.Product2.Category__r.Category_type__c, Product.Category__r.Category_type__c, 
                               Type, Reason, ServAir_Created_Date__c From Case Where account.id = :accId And status = 'Active' And Type IN ('Request For Service','Submit An Inquiry')];
            }
            system.debug('allCaseList::'+allCaseList.size());
            
            if(allCaseList.size() > 0){
                /*for(Case cas: allCaseList){
                    if(!casId.contains(cas.Id)){
                        casId.add(cas.Id);
                    }
                }
                System.debug('casId::'+casId);*/
                
                //looping the case list to get case count for service and inquiry
                for(Case cse: allCaseList){
                    if(cse.Type == 'Request For Service' && ((cse.Product.Category__r.Category_type__c == 'Product' || cse.Asset.Product2.Category__r.Category_type__c == 'Product') || (cse.AssetId == null && cse.ProductId == null)) && cse.Service_You_Require__c != null && prodService.contains(cse.Service_You_Require__c)){
                        prodCaseCnt++;
                        prodCseId.add(cse.Id);
                    }
                    if(!prodCseId.contains(cse.Id) && cse.Type == 'Request For Service' && cse.Service_You_Require__c != null && ((cse.Product.Category__r.Category_type__c == 'System' || cse.Asset.Product2.Category__r.Category_type__c == 'System') || (cse.AssetId == null && cse.ProductId == null)) && sysService.contains(cse.Service_You_Require__c)){
                        sysCaseCnt++;
                        sysCseId.add(cse.Id);
                    }
                    if(cse.Type == 'Submit An Inquiry' && cse.Reason != null){
                        inqCaseCnt++;
                        inqCseId.add(cse.Id);
                    }
                }
                
                totalCaseCnt = prodCaseCnt + sysCaseCnt + inqCaseCnt;
                
                if(catType == ''){
                    if(prodCaseCnt > 0){
                        catType = 'Product';
                    }else if(sysCaseCnt > 0){
                        catType = 'System';
                    }else{
                        catType = 'Inquiry';
                    }  
                }
                
                cseWrap.totalCaseCnt = totalCaseCnt;
                cseWrap.prodCaseCnt = prodCaseCnt;
                cseWrap.sysCaseCnt = sysCaseCnt;
                cseWrap.inqCaseCnt = inqCaseCnt;            
                cseWrap.activeBtn = catType;
                                
                //get case based on the product category type
                if(catType == 'Product'){
                    cseWrap.activeBtnSize = prodCaseCnt;
                    
                    caseList = [Select Id, CaseNumber, Subject, CreatedDate, Description, Progress__c, toLabel(Service_You_Require__c),
                                Product.Name, Asset.SerialNumber, Type, Reason, ServAir_Created_Date__c From Case Where
                                Id IN: prodCseId Order by CreatedDate Desc LIMIT :recordLimit OFFSET :offset]; 
                    
                    caseTypeList = [Select Count(id) cnt, toLabel(Service_You_Require__c) From Case where Id IN: prodCseId
                                    Group By Service_You_Require__c];
                }
                
                if(catType == 'System'){
                    cseWrap.activeBtnSize = sysCaseCnt;
                    
                    caseList = [Select Id, CaseNumber, Subject, CreatedDate, Description, Progress__c, toLabel(Service_You_Require__c),
                                Product.Name, Asset.SerialNumber, Type, Reason, ServAir_Created_Date__c From Case Where Id IN: sysCseId 
                                Order by CreatedDate Desc LIMIT :recordLimit OFFSET :offset];
                    
                    caseTypeList = [Select Count(id) cnt, toLabel(Service_You_Require__c) From Case where Id IN: sysCseId
                                    Group By Service_You_Require__c];
                }
                
                if(catType == 'Inquiry'){
                    cseWrap.activeBtnSize = inqCaseCnt;
                    
                    caseList = [Select Id, CaseNumber, Subject, CreatedDate, Description, Progress__c, toLabel(Service_You_Require__c),
                                Product.Name, Asset.SerialNumber, Type, Reason, ServAir_Created_Date__c From Case Where Id IN: inqCseId 
                                Order by CreatedDate Desc LIMIT :recordLimit OFFSET :offset]; 
                    
                    caseTypeList = [Select Count(id) cnt, Reason From Case where Id IN: inqCseId Group By Reason];
                }
                
                system.debug('caseList::'+caseList.size());
                system.debug('caseTypeList::'+caseTypeList);
                for(Case cse: caseList){
                    CaseData csedat = new CaseData();
                    
                    if(cse.ServAir_Created_Date__c != null){
                        date dte = cse.ServAir_Created_Date__c.date();
                        Datetime dt = Datetime.newInstance(dte.year(),dte.month(),dte.day());
                        String dateVal = dt.format('dd MMM YYYY'); 
                        csedat.submitDate = dateVal;
                    }else{
                        date dte = cse.CreatedDate.date();
                        Datetime dt = Datetime.newInstance(dte.year(),dte.month(),dte.day());
                        String dateVal = dt.format('dd MMM YYYY'); 
                        csedat.submitDate = dateVal;
                    }
                    csedat.serviceType = cse.Service_You_Require__c;
                    csedat.reason = cse.Reason;
                    csedat.caseId = cse.CaseNumber;
                    csedat.subject = cse.subject;
                    
                    if(cse.Product.Name !=null){
                        csedat.product = cse.Product.Name;  
                    }
                    else if(cse.Asset.SerialNumber !=null){
                        csedat.product =  cse.Asset.SerialNumber; 
                    }
                    else{
                        csedat.product = '';
                    }
                    
                    if(cse.Progress__c !=null){
                        csedat.progress = cse.Progress__c;     
                    }
                    else{
                        csedat.progress = '-';
                    }
                    
                    if(cse.description !=null){
                        csedat.description = cse.description;     
                    }
                    else{
                        csedat.description = '-';
                    }
                    
                    caseDataList.add(csedat);
                }
                
                system.debug('caseDataList::'+caseDataList);
                if(caseDataList.size() > 0){
                    cseWrap.caseDataList = caseDataList;
                }
                
                
                for(AggregateResult res: caseTypeList){
                    CaseChartData cseChart = new CaseChartData();
                    
                    if(catType == 'Product'){
                        if((String)res.get('Service_You_Require__c') == '050'){
                            cseChart.serviceTypeCount = (Integer)res.get('cnt');
                            cseChart.serviceType = Label.YG_Calibration;
                            cseChart.colorcode = arrayOfColorcode[i];
                        }
                        if((String)res.get('Service_You_Require__c') == '030'){
                            cseChart.serviceTypeCount = (Integer)res.get('cnt');
                            cseChart.serviceType = Label.YG_Repair;
                            cseChart.colorcode = arrayOfColorcode[i];
                        }
                        if((String)res.get('Service_You_Require__c') == '040'){
                            cseChart.serviceTypeCount = (Integer)res.get('cnt');
                            cseChart.serviceType = Label.YG_Training;
                            cseChart.colorcode = arrayOfColorcode[i];
                        }
                        
                        if((String)res.get('Service_You_Require__c') == '080'){
                            cseChart.serviceTypeCount = (Integer)res.get('cnt');
                            cseChart.serviceType = Label.YG_Diagnosis;
                            cseChart.colorcode = arrayOfColorcode[i];
                        }
                        if((String)res.get('Service_You_Require__c') == '100'){
                            cseChart.serviceTypeCount = (Integer)res.get('cnt');
                            cseChart.serviceType = Label.YG_Mods;
                            cseChart.colorcode = arrayOfColorcode[i];
                        }
                        if((String)res.get('Service_You_Require__c') == '900'){
                            cseChart.serviceTypeCount = (Integer)res.get('cnt');
                            cseChart.serviceType = Label.YG_Others;
                            cseChart.colorcode = arrayOfColorcode[i];
                        }
                    }
                    
                    if(catType == 'System'){
                        if((String)res.get('Service_You_Require__c') == '010'){
                            cseChart.serviceTypeCount = (Integer)res.get('cnt');
                            cseChart.serviceType = Label.YG_Maintenance;
                            cseChart.colorcode = arrayOfColorcode[i];
                        }
                        if((String)res.get('Service_You_Require__c') == '020'){
                            cseChart.serviceTypeCount = (Integer)res.get('cnt');
                            cseChart.serviceType = Label.YG_On_Call;
                            cseChart.colorcode = arrayOfColorcode[i];
                        }
                        if((String)res.get('Service_You_Require__c') == '040'){
                            cseChart.serviceTypeCount = (Integer)res.get('cnt');
                            cseChart.serviceType = Label.YG_Training;
                            cseChart.colorcode = arrayOfColorcode[i];
                        }
                        if((String)res.get('Service_You_Require__c') == '060'){
                            cseChart.serviceTypeCount = (Integer)res.get('cnt');
                            cseChart.serviceType = Label.YG_Sys_Upgrade;
                            cseChart.colorcode = arrayOfColorcode[i];
                        }
                        if((String)res.get('Service_You_Require__c') == '070'){
                            cseChart.serviceTypeCount = (Integer)res.get('cnt');
                            cseChart.serviceType = Label.YG_Security;
                            cseChart.colorcode = arrayOfColorcode[i];
                        }
                        if((String)res.get('Service_You_Require__c') == '100'){
                            cseChart.serviceTypeCount = (Integer)res.get('cnt');
                            cseChart.serviceType = Label.YG_Mods;
                            cseChart.colorcode = arrayOfColorcode[i];
                        }
                        if((String)res.get('Service_You_Require__c') == '900'){
                            cseChart.serviceTypeCount = (Integer)res.get('cnt');
                            cseChart.serviceType = Label.YG_Others;
                            cseChart.colorcode = arrayOfColorcode[i];
                        }
                    }
                    
                    if(catType == 'Inquiry'){
                        if((String)res.get('Reason') == 'Sales and Quote'){
                            cseChart.serviceTypeCount = (Integer)res.get('cnt');
                            cseChart.serviceType = Label.YG_Sales_Quote;
                            cseChart.colorcode = arrayOfColorcode[i];
                        }
                        if((String)res.get('Reason') == 'Technical Support'){
                            cseChart.serviceTypeCount = (Integer)res.get('cnt');
                            cseChart.serviceType = Label.YG_Technical_Support;
                            cseChart.colorcode = arrayOfColorcode[i];
                        }
                        if((String)res.get('Reason') == 'Others'){
                            cseChart.serviceTypeCount = (Integer)res.get('cnt');
                            cseChart.serviceType = Label.YG_Others;
                            cseChart.colorcode = arrayOfColorcode[i];
                        }
                    }
                    
                    i++;
                    caseChartList.add(cseChart);
                    
                }
                
                system.debug('caseChartList::'+caseChartList);
                
                if(caseChartList.size() > 0){
                    cseWrap.caseChartList = caseChartList;
                }
            }
        }catch(Exception e){
            system.debug('Exception Cause::'+e.getCause());
            system.debug('Exception LineNumber::'+e.getLineNumber());
            system.debug('Exception Message::'+e.getMessage());
            system.debug('Exception StackTrace::'+e.getStackTraceString());
            system.debug('Exception TypeName::'+e.getTypeName());
            YG_Utility.logError('Overview page','Community Component Error',e.getStackTraceString(),
                                'Class:YG_OverviewGridController; Method: getCaseCountOverviewDetails(); Line #:'+e.getLineNumber()+'; Message:'+e.getMessage(),
                                UserInfo.getUserId());
        }
        
        system.debug('cseWrap::'+cseWrap);
        return cseWrap;
    }
    
    public class caseOverviewWrapper{
        @AuraEnabled public Integer totalCaseCnt = 0;
        @AuraEnabled public Integer prodCaseCnt = 0;
        @AuraEnabled public Integer sysCaseCnt = 0;
        @AuraEnabled public Integer inqCaseCnt = 0;
        @AuraEnabled public String activeBtn;
        @AuraEnabled public Integer activeBtnSize;
        @AuraEnabled public List<CaseChartData> caseChartList;
        @AuraEnabled public List<CaseData> caseDataList;
    }
    
    public class CaseChartData{
        @AuraEnabled public Integer serviceTypeCount;
        @AuraEnabled public String serviceType;
        @AuraEnabled public String colorcode;
    }
    
    public class CaseData{
        @AuraEnabled public String submitDate;
        @AuraEnabled public String product;
        @AuraEnabled public String serviceType;
        @AuraEnabled public String progress; 
        @AuraEnabled public String subject;
        @AuraEnabled public String reason;
        @AuraEnabled public String caseId;
        @AuraEnabled public String description;
    }
    
}