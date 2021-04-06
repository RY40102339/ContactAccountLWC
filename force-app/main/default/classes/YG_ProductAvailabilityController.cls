/*
*******************************************************************************************************
* (C) Copyright 2020 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Selvaraj T
* @version 1.0
* @created 16/10/2020
* @description 
* This class is used to get the suffix code details of the specific ms code using Product API.
*
* @test class name - YG_ProductMasterAPIControllerTest
*
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  
*  
*
*/

public class YG_ProductAvailabilityController {
    
    /**
     * This method is to get the suffix code details of the ms code.
     *
     **/ 
    
    @AuraEnabled
    public static productAvailabilityWrapper getSuffixCodes(String msCode){
        
        system.debug('msCode::'+msCode);
        
        //Instantiate the wrapper
        productAvailabilityWrapper prodAvaiWrap = new productAvailabilityWrapper();
        List<SuffixCode> suffixCodeList = new List<SuffixCode>();
        
        try{
            
            //calling product master API controller
            YG_ProductMasterAPIController.productModelWrapper apiResponse = new YG_ProductMasterAPIController.productModelWrapper();
            apiResponse = YG_ProductMasterAPIController.getSuffixCodeDetails(msCode);
            
            system.debug('apiResponse::'+apiResponse);
            
            if(apiResponse.success){
                
                YG_ProductMasterAPIController.productMasterResponseWrapper msCodeResList = apiResponse.prodMasterResponse;
                prodAvaiWrap.msCode = msCodeResList.MSCode;
                prodAvaiWrap.model = msCodeResList.Model;
                
                if(msCodeResList.ModelStatus != '1'){
                    prodAvaiWrap.availability = 'Discontinued';
                    prodAvaiWrap.orderAvailabilty = 'The product or some of its options are discontinued';
                }else{
                    prodAvaiWrap.availability = 'Available';
                }                
                
                List<YG_ProductMasterAPIController.Suffix> sufResList = apiResponse.prodMasterResponse.Suffix;
                List<YG_ProductMasterAPIController.Option> optResList = apiResponse.prodMasterResponse.Option;
                
                //iterate the suffix code
                for(YG_ProductMasterAPIController.Suffix sfx: sufResList){
                    system.debug('sfx::::'+sfx);
                    SuffixCode sfxCode = new SuffixCode();
                    List<string> suffixSpecDesc = new List<string>();
                    sfxCode.suffixCode = sfx.SuffixID;
                    sfxCode.suffixLevelName = sfx.SuffixLevelName;
                    if(sfx.SuffixSpecDesc1 != null && sfx.SuffixSpecDesc1 != ''){
                        suffixSpecDesc.add(sfx.SuffixSpecDesc1); 
                    }
                    if(sfx.SuffixSpecDesc2 != null && sfx.SuffixSpecDesc2 != ''){
                        suffixSpecDesc.add(sfx.SuffixSpecDesc2); 
                    }
                    if(sfx.SuffixSpecDesc3 != null && sfx.SuffixSpecDesc3 != ''){
                        suffixSpecDesc.add(sfx.SuffixSpecDesc3); 
                    }
                    if(sfx.SuffixSpecDesc4 != null && sfx.SuffixSpecDesc4 != ''){
                        suffixSpecDesc.add(sfx.SuffixSpecDesc4); 
                    }
                    if(suffixSpecDesc.size() > 0){
                        sfxCode.suffixSpecDesc = suffixSpecDesc;
                    }
                    if(sfx.SuffixStatus != '1'){
                        sfxCode.suffixStatus = 'Discontinued';
                        prodAvaiWrap.orderAvailabilty = 'The product or some of its options are discontinued';
                    }else{
                        sfxCode.suffixStatus = 'Available';
                    }
                    if(sfxCode != null){
                        suffixCodeList.add(sfxCode);
                    }
                }
                
                //iterate the option list
                for(YG_ProductMasterAPIController.Option opt: optResList){
                    SuffixCode optCode = new SuffixCode();
                    system.debug('opt::::'+opt);
                    List<string> optionSpecDesc = new List<string>();
                    optCode.suffixCode = opt.OptionID;
                    optCode.suffixLevelName = opt.OptionGroupName;
                    if(opt.OptionSpecDesc1 != null && opt.OptionSpecDesc1 != ''){
                        optionSpecDesc.add(opt.OptionSpecDesc1); 
                    }
                    if(opt.OptionSpecDesc2 != null && opt.OptionSpecDesc2 != ''){
                        optionSpecDesc.add(opt.OptionSpecDesc2); 
                    }
                    if(opt.OptionSpecDesc3 != null && opt.OptionSpecDesc3 != ''){
                        optionSpecDesc.add(opt.OptionSpecDesc3); 
                    }
                    if(opt.OptionSpecDesc4 != null && opt.OptionSpecDesc4 != ''){
                        optionSpecDesc.add(opt.OptionSpecDesc4); 
                    }
                    if(optionSpecDesc.size() > 0){
                        optCode.suffixSpecDesc = optionSpecDesc;
                    }
                    if(opt.OptionStatus != '1'){
                        optCode.suffixStatus = 'Discontinued';
                        prodAvaiWrap.orderAvailabilty = 'The product or some of its options are discontinued';
                    }else{
                        optCode.suffixStatus = 'Available';
                    }
                    if(optCode != null){
                        suffixCodeList.add(optCode);
                    }
                }
                
                if(suffixCodeList.size() > 0){
                    prodAvaiWrap.suffix = suffixCodeList;
                }
                
            }else{
                prodAvaiWrap = new productAvailabilityWrapper();
                prodAvaiWrap.orderAvailabilty = '';
                prodAvaiWrap.msCode = '';
                prodAvaiWrap.model = '';
                prodAvaiWrap.availability = '';
            }
        }
        catch(Exception e){
            system.debug('Exception Cause::'+e.getCause());
            system.debug('Exception LineNumber::'+e.getLineNumber());
            system.debug('Exception Message::'+e.getMessage());
            system.debug('Exception StackTrace::'+e.getStackTraceString());
            system.debug('Exception TypeName::'+e.getTypeName());
            YG_Utility.logError('ProductAvailability','Backend Process Error',e.getStackTraceString(),
                               'Class:YG_ProductAvailabilityController; Method: getSuffixCodes(); Line #:'+e.getLineNumber()
                                +'; Message:'+e.getMessage(),
                               UserInfo.getUserId());
        } 
        
        system.debug('prodAvaiWrap::'+prodAvaiWrap);
        return prodAvaiWrap;
        
        
    }
    
    //Wrapper to store the product availability
    public class productAvailabilityWrapper{
        @AuraEnabled public String msCode = '';
        @AuraEnabled public String orderAvailabilty = 'Available with the same specifications';
        @AuraEnabled public String model = '';
        @AuraEnabled public String availability = '';
        @AuraEnabled public List<SuffixCode> suffix = new List<SuffixCode>();
    }
    
    public class SuffixCode{
        @AuraEnabled public string suffixLevelName = '';
        @AuraEnabled public string suffixCode = '';
        @AuraEnabled public List<string> suffixSpecDesc;
        @AuraEnabled public string suffixStatus = '';
    }

}