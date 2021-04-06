/********************************************************************************************************
* (C) Copyright 2020 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Vinod A
* @version 1.0
* @created 20/05/2020
* @description 
* This class is used to get product history data for displaying in the product history page.	
*
* @test class name - YG_ProductHistoryControllerTest
*
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  07/01/2020			Vinod A					Code coverage updated based on the plant implementation.
*  08/25/2020			Vinod A					Logic has been changed : Instead of task case history has been showed. 
*
*/
public class YG_ProductHistoryController {
    
    // This method is for the getting the product history data based on the serial number.
    @AuraEnabled
    public static ProdHistoryWrapper getProductHistory(String serialNo/*, String plantCode*/){
        
        system.debug('serialNo::'+serialNo);
        //system.debug('plantCode::'+plantCode);
        
        List<Integer> yr= new List<Integer>();
        ProdHistoryWrapper prodHisWrap = new ProdHistoryWrapper();
        List<HistoryWrap> hisWrapList = new List<HistoryWrap>();
        Id cusPltId;
        String langCode='EN';
        List<task> tsk=new List<task>();
        List<Case> caseList=new List<Case>();
        List<CaseHistory> casehist=new List<CaseHistory>();
        List<Id> casId=new List<Id>();
        try{
            /*Plant__c plant = YG_HelperClass.getPlantID(plantCode,langCode);
            cusPltId = plant.id;
            system.debug('selected plant::'+cusPltId);*/
            //Asset ass=[Select Id, SerialNumber, MS_Code__c, Lang_Code__c From Asset Where SerialNumber=:serialNo And Plant__c=:cusPltId Limit 1];
            //plantSerialNo = ass.SerialNumber;
            //get task list based on serial number
            tsk = [Select Asset__c, Asset__r.Name, ActivityDate, Subject from task Where Asset__r.Name =:serialNo
                              ORDER BY ActivityDate Desc];
            
            system.debug('tsk::'+tsk);
            caseList = [Select Id, CaseNumber, Description from case Where Asset.Name =: serialNo Limit 1];
            for(Case caseId : caseList){
                casId.add(caseId.Id);
            }
            //List<Id> casId = caseList.Id;
            casehist = [select NewValue, OldValue, CreatedDate from CaseHistory where CaseId IN: casId and Field='Progress__c' ORDER BY CreatedDate Desc];
            
            System.debug('casehist::'+casehist);
            for(CaseHistory c: casehist){
                if(c.CreatedDate != null){
                    Integer year = c.CreatedDate.Year();
                    if(!yr.contains(year)){
                        yr.add(year);
                    }
                }
            }
            
            /*for(task t: tsk){
                if(t.ActivityDate != null){
                    Integer year = t.ActivityDate.Year();
                    if(!yr.contains(year)){
                        yr.add(year);
                    }
                }
            }*/
            System.debug('yr::'+yr);
           
            //logic to get product history based on year
            for(Integer year : yr){
                HistoryWrap hisWra = new HistoryWrap();
                hisWra.prodYear = year;
                List<sObjectData> objList = new List<sObjectData>();
                for(CaseHistory ph: casehist){
                    sObjectData sOData = new sObjectData();
                    if(ph.CreatedDate.Year() == year){
                        sOData.description = ph.NewValue.toString();
                        Datetime dt = Datetime.newInstance(ph.CreatedDate.year(),ph.CreatedDate.month(),ph.CreatedDate.day());
                        sOData.hisDate = dt.format('dd MMMM YYYY');    
                        objList.add(sOData); 
                    }
                }
                hisWra.prodHis = objList;
                hisWrapList.add(hisWra);
            }
            /*for(Integer year : yr){
                HistoryWrap hisWra = new HistoryWrap();
                hisWra.prodYear = year;
                List<sObjectData> objList = new List<sObjectData>();
                for(task ph: tsk){
                    sObjectData sOData = new sObjectData();
                    if(ph.ActivityDate.Year() == year){
                        sOData.description = ph.Subject;
                        Datetime dt = Datetime.newInstance(ph.ActivityDate.year(),ph.ActivityDate.month(),ph.ActivityDate.day());
                        sOData.hisDate = dt.format('dd MMMM YYYY');    
                        objList.add(sOData); 
                    }
                }
                hisWra.prodHis = objList;
                hisWrapList.add(hisWra);
            }*/
            system.debug('hisWrapList::'+hisWrapList);
            prodHisWrap.hisWrap = hisWrapList;
            system.debug('prodHisWrap::'+prodHisWrap);
        }
        catch(Exception e){
            system.debug('Exception Cause::'+e.getCause());
            system.debug('Exception LineNumber::'+e.getLineNumber());
            system.debug('Exception Message::'+e.getMessage());
            system.debug('Exception StackTrace::'+e.getStackTraceString());
            system.debug('Exception TypeName::'+e.getTypeName());
            YG_Utility.logError('ProductHistory','Community Component Error',e.getStackTraceString(),
                                'Class:YG_ProductHistoryController; Method: getProductHistory(); Line #:'+e.getLineNumber()+'; Message:'+e.getMessage(),
                                UserInfo.getUserId());
        }
        
        
        return prodHisWrap;
        
    }
    
    //wrapper class to store the list of product history record
    public class ProdHistoryWrapper{
        @AuraEnabled public List<HistoryWrap> hisWrap;
    }
    
    //wrapper class to store the year and list of product history record
    public class HistoryWrap{
        @AuraEnabled public Integer prodYear;
        @AuraEnabled public List<sObjectData> prodHis;
    }
    
    public class sObjectData{
        @AuraEnabled public string description;
        @AuraEnabled public string hisDate;
    }
}