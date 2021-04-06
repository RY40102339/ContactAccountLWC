/********************************************************************************************************
* (C) Copyright 2020 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Vinod A
* @version 1.0
* @created 08/31/2020
* @description 
* This test class for YG_AllServiceRequestController apex class.
*
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*
*
*/

@istest
public class YG_AllServiceRequestControllerTest {
    
    @isTest static void ygAllServiceGridTest() {
        
        //Insert test account record
        Account acc = new account();
        acc.name='Test Account'; 
        acc.AccountNumber = '1212121';
        insert acc;
        
        //Insert self registered account record
        Account acc1 = new account();
        acc1.name='Self Registered';        
        insert acc1; 
        
        //Insert test contact record
        Contact con = new Contact();   
        con.FirstName='User';
        con.LastName='testContact';
        con.Email='testContact@chevron.com';
        con.accountid=acc.id; 
        insert con;
        
        //Insert test portal user record
        User user = new User();   
        user.ProfileID = [Select Id From Profile Where Name='Customer Portal User'].id; 
        System.debug('user.ProfileID');
        user.EmailEncodingKey = 'ISO-8859-1';   user.LanguageLocaleKey = 'en_US';   user.TimeZoneSidKey = 'America/New_York';   
        user.LocaleSidKey = 'en_US';   user.FirstName = 'User';   user.LastName = 'testContact';   user.Username = 'testContact@chevron.com';      
        user.CommunityNickname = 'User222';   user.Alias = 'user';   user.Email = 'testContact@chevron.com';   user.IsActive = true;   
        user.ContactId = con.Id;  
        insert user;   
        
        //Insert test Category Hierarchy record
        List<Category_Hierarchy__c> catHierListTop=new List<Category_Hierarchy__c>();
        Category_Hierarchy__c catHierTop1=new Category_Hierarchy__c(Category_Code__c = '10000000', Category_Level__c = 1, Display_Sequence__c = 500,
                                                                    Upper_Category_Code__c = NULL);
        catHierListTop.add(catHierTop1);
        
        Category_Hierarchy__c catHierL1=new Category_Hierarchy__c(Category_Code__c = '20000000', Category_Level__c = 1, Display_Sequence__c = 500, 
                                                                  Upper_Category_Code__c = NULL);
        catHierListTop.add(catHierL1);
        
        insert catHierListTop;
        
        List<Category_Hierarchy__c> catHierListTop2=new List<Category_Hierarchy__c>();
        Category_Hierarchy__c catHierTop2=new Category_Hierarchy__c(Category_Code__c = '11000000', Category_Level__c = 2, Display_Sequence__c = 500,
                                                                 Upper_Category_Code__c = '10000000', Category_Hierarchy__c = catHierTop1.id);
        catHierListTop2.add(catHierTop2);
        
        Category_Hierarchy__c catHierL21=new Category_Hierarchy__c(Category_Code__c = '21000000', Category_Level__c = 2, Display_Sequence__c = 500, 
                                                                   Upper_Category_Code__c = NULL, Category_Hierarchy__c = catHierL1.id);
        catHierListTop2.add(catHierL21); //Hardware 
        
        Category_Hierarchy__c catHierL22=new Category_Hierarchy__c(Category_Code__c = '22000000', Category_Level__c = 2, Display_Sequence__c = 500, 
                                                                   Upper_Category_Code__c = NULL, Category_Hierarchy__c = catHierL1.id);
        catHierListTop2.add(catHierL22); //software
        
        insert catHierListTop2;
        
        List<Category_Hierarchy__c> catHierListTop3=new List<Category_Hierarchy__c>();
        Category_Hierarchy__c catHierTop3=new Category_Hierarchy__c(Category_Code__c = '12000000', Category_Level__c = 3, Display_Sequence__c = 500,
                                                                 Upper_Category_Code__c = '11000000', Category_Hierarchy__c = catHierTop2.id);
        catHierListTop3.add(catHierTop3);
        
        insert catHierListTop3;
                
        //Insert test category record
        List<Category__c> catList=new List<Category__c>();
        Category__c catg1=new Category__c(Name = 'Field Instruments', Category_Hierarchy__c = catHierTop1.Id,
                                          Category_Type__c = 'Product', Language_Code__c = 'EN');
        catList.add(catg1);
        
        Category__c catg2=new Category__c(Name = 'Device Smart Communicators', Category_Hierarchy__c = catHierTop2.Id,
                                          Category_Type__c = 'Product', Language_Code__c = 'EN');
        catList.add(catg2);
        
        Category__c catg3=new Category__c(Name = 'Device Smart Communicators BT200', Category_Hierarchy__c = catHierTop3.Id,
                                          Category_Type__c = 'Product', Language_Code__c = 'EN');
        catList.add(catg3);
        
        Category__c catg4 = new Category__c(Name = 'Distributed Control Systems (DCS)', Category_Hierarchy__c = catHierL1.Id,
                                            Category_Type__c = 'System', Language_Code__c = 'EN');
        catList.add(catg4);
        
        Category__c catg5 = new Category__c(Name = 'Hardware', Category_Hierarchy__c = catHierL21.Id,
                                            Category_Type__c = 'System', Language_Code__c = 'EN');
        catList.add(catg5);
        
        Category__c catg6 = new Category__c(Name = 'Software', Category_Hierarchy__c = catHierL22.Id,
                                            Category_Type__c = 'System', Language_Code__c = 'EN');
        catList.add(catg6);
        
        insert catList;
        System.debug('catList::'+catList);
        
        //Insert test product record
        List<Product2> prodList=new List<Product2>();
        Product2 prod1=new Product2();
        prod1.Name = 'Device Smart Communicators BT200';
        prod1.Model_Code__c = 'BT200';
        prod1.Category__c = catg3.Id;
        prod1.Production_Date__c = Date.newInstance(2014, 12, 17);
        prod1.Lang_Code__c = 'EN';
        prodList.add(prod1);
        
        Product2 prod2=new Product2();
        prod2.Name = 'DCS';
        prod2.Model_Code__c = 'AFV10D';
        prod2.Category__c = catg5.Id;
        prod2.Production_Date__c = Date.newInstance(2014, 12, 17);
        prod2.Lang_Code__c = 'EN';
        prodList.add(prod2);
        
        Insert prodList;
        System.debug('prodList::*'+prodList);
        
        //Insert test asset record
        List<Asset> assList=new List<Asset>();
        Asset ass1=new Asset();
        ass1.Name = 'SU1234567';
        ass1.Product2Id = prod1.Id;
        ass1.AccountId = acc.Id;
        ass1.ContactId = con.Id;
        ass1.SerialNumber = 'SU1234567';
        ass1.MS_Code__c = 'AAI543-H50';
        ass1.Lang_Code__c = 'EN';
        assList.add(ass1);
        
        Asset ass2=new Asset();
        ass2.Name = 'FCS0101';
        ass2.Product2Id = prod2.Id;
        ass2.AccountId = acc.Id;
        ass2.ContactId = con.Id;
        ass2.Station_Number__c = 2;
        ass2.Domain__c = 1;
        ass2.Station_Type__c = 'FCS';
        ass2.Lang_Code__c = 'EN';
        assList.add(ass2);     
        
        insert assList;
        
		//Insert Case Records 
		List<Case> cseList = new List<Case>(); 
        List<String> prodService=new List<String>{'050','030','040','080','100','900'};
        List<String> sysService=new List<String>{'010','020','040','060','070','100','900'};
            for(Integer i=0; i<prodService.size(); i++){
                Case case1=new Case();
                case1.ContactId = con.Id;
                case1.AccountId  = acc.Id;
                case1.Service_you_require__c = prodService[i];
                case1.AssetId = ass1.Id;
                case1.Type = 'Request For Service';
                case1.Reason = '';
                case1.Status = 'Active';
                case1.Progress__c = 'Request Submitted 1';
                cseList.add(case1);
            }
        
        for(Integer i=0; i<sysService.size(); i++){
            Case case2=new Case();
            case2.ContactId = con.Id;
            case2.AccountId  = acc.Id;
            case2.Service_you_require__c = sysService[i];
            case2.productId = prod2.Id;
            case2.Type = 'Request For Service';
            case2.Reason = '';
            case2.Status = 'Active';
            case2.Progress__c = 'Request Submitted 2';
            case2.ServAir_Created_Date__c = Date.today();
            cseList.add(case2);
        }
        
        Case case3=new Case();
        case3.ContactId = con.Id;
        case3.AccountId  = acc.Id;
        case3.Service_you_require__c = '010';
        case3.Type = 'Request For Service';
        case3.Reason = '';
        case3.Status = 'Active';
        case3.Progress__c = 'Request Submitted 3';
        case3.ServAir_Created_Date__c = Date.today();
        cseList.add(case3);
        
        Case case4=new Case();
        case4.ContactId = con.Id;
        case4.AccountId  = acc.Id;
        case4.Type = 'Submit An Inquiry';
        case4.Reason = 'Technical Support';
        case4.Status = 'Closed';
        case4.Progress__c = 'Closed';
        case4.ServAir_Created_Date__c = Date.today();
        cseList.add(case4);
        
        Case case5=new Case();
        case5.ContactId = con.Id;
        case5.AccountId  = acc.Id;
        case5.Type = 'Submit An Inquiry';
        case5.Reason = 'Others';
        case5.Status = 'Active';
        case5.Progress__c = 'InProgress';
        case5.ServAir_Created_Date__c = Date.today();
        cseList.add(case5);
        
        Case case6=new Case();
        case6.ContactId = con.Id;
        case6.AccountId  = acc.Id;
        case6.Type = 'Submit An Inquiry';
        case6.Reason = 'Sales and Quote';
        case6.Status = 'Active';
        case6.Progress__c = 'InProgress';
        case6.ServAir_Created_Date__c = Date.today();
        cseList.add(case6);
        
        Case case7=new Case();
        case7.ContactId = con.Id;
        case7.AccountId  = acc.Id;
        case7.Service_you_require__c = '050';
        case7.AssetId = ass1.Id;
        case7.Type = 'Request For Service';
        case7.Reason = '';
        case7.Status = 'Active';
        case7.Progress__c = 'Request Submitted 1';
        cseList.add(case7);
        
        Case case8=new Case();
        case8.ContactId = con.Id;
        case8.AccountId  = acc.Id;
        case8.Service_you_require__c = '010';
        case8.productId = prod2.Id;
        case8.Type = 'Request For Service';
        case8.Reason = '';
        case8.Status = 'Active';
        case8.Progress__c = 'Request Submitted 2';
        case8.ServAir_Created_Date__c = Date.today();
        cseList.add(case8);
        
        insert cseList;
        system.debug('cseList::'+cseList.size());
        
        //Inserting Service Contracts records
        List<ServiceContract> servContList = new List<ServiceContract>();
        ServiceContract servCont1 = new ServiceContract();
        servCont1.Name = 'Test Service Contract';
        servCont1.Contract_No__c = 'SC-0001';
        servCont1.StartDate = Date.newInstance(2020, 09, 29);
        servCont1.EndDate = Date.newInstance(2021, 02, 17);
        servCont1.Contract_Type__c = 'LCA';
        servContList.add(servCont1);
        
        ServiceContract servCont2 = new ServiceContract();
        servCont2.Name = 'Test Service Contract';
        servCont2.Contract_No__c = 'SC-0001';
        servCont2.StartDate = Date.newInstance(2020, 09, 29);
        servCont2.EndDate = Date.newInstance(2025, 02, 17);
        servCont2.Contract_Type__c = 'LCA';
        servContList.add(servCont2);
        
        insert servContList;
        
        //Inserting SOP record
        Scope_of_Product__c sop1 = new Scope_of_Product__c();
        sop1.Service_Contract__c = servCont1.Id;
        sop1.Asset__c = ass1.Id;
        insert sop1;
        
        //Insert custom setting records
        List<YG_Community_Configuration__c> configList = new List<YG_Community_Configuration__c>();        
        YG_Community_Configuration__c selfAcc=new YG_Community_Configuration__c();
        selfAcc.Name = 'YGSelfRegisterAccountId';
        selfAcc.Text_1__c = acc1.Id;
        configList.add(selfAcc); 
        insert configList;
        
        system.runAs(user){
            Test.startTest();
            List<String> empty=new List<String>();
            List<String> filterValue=new List<String>{'Technical Support','Schedule Maintenance','Calibration'};
            
            YG_AllServiceRequestController.ServiceRequestGridWrapper servReqWrap = new YG_AllServiceRequestController.ServiceRequestGridWrapper();
            servReqWrap = YG_AllServiceRequestController.getServiceRequestGridDetails(empty, '', 'Active', 100, 0);
            system.assertEquals(18, servReqWrap.caseDataList.size());
            
            YG_AllServiceRequestController.ServiceRequestGridWrapper servReqWrap1 = new YG_AllServiceRequestController.ServiceRequestGridWrapper();
            servReqWrap1 = YG_AllServiceRequestController.getServiceRequestGridDetails(empty, 'Product', '', 100, 0);
            system.assertEquals(7, servReqWrap1.caseDataList.size());
            
            YG_AllServiceRequestController.ServiceRequestGridWrapper servReqWrap2 = new YG_AllServiceRequestController.ServiceRequestGridWrapper();
            servReqWrap2 = YG_AllServiceRequestController.getServiceRequestGridDetails(empty, 'System', '', 100, 0);
            system.assertEquals(9, servReqWrap2.caseDataList.size());
            
            YG_AllServiceRequestController.ServiceRequestGridWrapper servReqWrap3 = new YG_AllServiceRequestController.ServiceRequestGridWrapper();
            servReqWrap3 = YG_AllServiceRequestController.getServiceRequestGridDetails(empty, 'Inquiry', '', 100, 0);
            system.assertEquals(3, servReqWrap3.caseDataList.size());
            
            YG_AllServiceRequestController.ServiceRequestGridWrapper servReqWrap4 = new YG_AllServiceRequestController.ServiceRequestGridWrapper();
            servReqWrap4 = YG_AllServiceRequestController.getServiceRequestGridDetails(filterValue, '', '', 100, 0);
            system.assertEquals(6, servReqWrap4.caseDataList.size());
            
            YG_AllServiceRequestController.ServiceRequestGridWrapper servReqWrap5 = new YG_AllServiceRequestController.ServiceRequestGridWrapper();
            servReqWrap5 = YG_AllServiceRequestController.getServiceRequestGridDetails(filterValue, 'Product', '', 100, 0);
            system.assertEquals(2, servReqWrap5.caseDataList.size());
            
            YG_AllServiceRequestController.ServiceRequestGridWrapper servReqWrap6 = new YG_AllServiceRequestController.ServiceRequestGridWrapper();
            servReqWrap6 = YG_AllServiceRequestController.getServiceRequestGridDetails(filterValue, 'System', '', 100, 0);
            system.assertEquals(3, servReqWrap6.caseDataList.size());
            
            YG_AllServiceRequestController.ServiceRequestGridWrapper servReqWrap7 = new YG_AllServiceRequestController.ServiceRequestGridWrapper();
            servReqWrap7 = YG_AllServiceRequestController.getServiceRequestGridDetails(filterValue, 'Inquiry', '', 100, 0);
            system.assertEquals(1, servReqWrap7.caseDataList.size());
            
            YG_AllServiceRequestController.ServiceRequestCSVWrapper csvData = YG_AllServiceRequestController.getServiceRequestCSVDetails();
            system.assertEquals(19, csvData.caseCSVDataList.size());
            
            YG_AllServiceRequestController.ServiceRequestChartWrapper chartDat = YG_AllServiceRequestController.getServiceRequestChartDetails();
            system.assertEquals(6, chartDat.prodChartDataList.size());
            system.assertEquals(7, chartDat.sysChartDataList.size());
            system.assertEquals(3, chartDat.inqChartDataList.size());
            
            String caseNo = [Select CaseNumber From Case Where id = :case6.id].CaseNumber;
            YG_AllServiceRequestController.modelServiceInfo modelServ = YG_AllServiceRequestController.getServiceReqInfo(caseNo);
            system.assertEquals('Sales and Quote', modelServ.serviceType);
            
            String caseNo1 = [Select CaseNumber From Case Where id = :case3.id].CaseNumber;
            YG_AllServiceRequestController.modelServiceInfo modelServ1 = YG_AllServiceRequestController.getServiceReqInfo(caseNo1);
            system.assertEquals('Schedule Maintenance', modelServ1.serviceType);
            
            String caseNo2 = [Select CaseNumber From Case Where id = :case7.id].CaseNumber;
            YG_AllServiceRequestController.modelServiceInfo modelServ2 = YG_AllServiceRequestController.getServiceReqInfo(caseNo2);
            system.assertEquals('Calibration', modelServ2.serviceType);
            
            String caseNo3 = [Select CaseNumber From Case Where id = :case8.id].CaseNumber;
            YG_AllServiceRequestController.modelServiceInfo modelServ3 = YG_AllServiceRequestController.getServiceReqInfo(caseNo3);
            system.assertEquals('Schedule Maintenance', modelServ3.serviceType);
            
			YG_AllServiceRequestController.modelServiceInfo modelServExcep = YG_AllServiceRequestController.getServiceReqInfo('caseNo');
			String updDescExcep = YG_AllServiceRequestController.toUpdateCaseDescription('caseNo3','test');
            YG_AllServiceRequestController.CaseHistoryWrapper cseHisExcep = YG_AllServiceRequestController.getCaseHistory('caseNo3');

            String updDesc = YG_AllServiceRequestController.toUpdateCaseDescription(caseNo3,'test');
            system.assertEquals('test', updDesc);
            
            YG_AllServiceRequestController.CaseHistoryWrapper cseHis = YG_AllServiceRequestController.getCaseHistory(caseNo3);
            system.assertEquals(1, cseHis.hisWrap.size());
            
            Test.stopTest();    
        }   
    }  
    
    @isTest static void ygAllServiceGridSelfRegisTest() {
        
        //Insert test account record
        Account acc = new account();
        acc.name='Test Account'; 
        acc.AccountNumber = '1212121';
        insert acc;
        
        //Insert self registered account record
        Account acc1 = new account();
        acc1.name='Self Registered';        
        insert acc1; 
        
        //Insert test contact record
        Contact con = new Contact();   
        con.FirstName='User';
        con.LastName='testContact';
        con.Email='testContact@chevron.com';
        con.accountid=acc1.id; 
        insert con;
        
        //Insert test portal user record
        User user = new User();   
        user.ProfileID = [Select Id From Profile Where Name='Customer Portal User'].id; 
        System.debug('user.ProfileID');
        user.EmailEncodingKey = 'ISO-8859-1';   user.LanguageLocaleKey = 'en_US';   user.TimeZoneSidKey = 'America/New_York';   
        user.LocaleSidKey = 'en_US';   user.FirstName = 'User';   user.LastName = 'testContact';   user.Username = 'testContact@chevron.com';      
        user.CommunityNickname = 'User222';   user.Alias = 'user';   user.Email = 'testContact@chevron.com';   user.IsActive = true;   
        user.ContactId = con.Id;  
        insert user;   
        
        //Insert test Category Hierarchy record
        List<Category_Hierarchy__c> catHierListTop=new List<Category_Hierarchy__c>();
        Category_Hierarchy__c catHierTop1=new Category_Hierarchy__c(Category_Code__c = '10000000', Category_Level__c = 1, Display_Sequence__c = 500,
                                                                    Upper_Category_Code__c = NULL);
        catHierListTop.add(catHierTop1);
        
        Category_Hierarchy__c catHierL1=new Category_Hierarchy__c(Category_Code__c = '20000000', Category_Level__c = 1, Display_Sequence__c = 500, 
                                                                  Upper_Category_Code__c = NULL);
        catHierListTop.add(catHierL1);
        
        insert catHierListTop;
        
        List<Category_Hierarchy__c> catHierListTop2=new List<Category_Hierarchy__c>();
        Category_Hierarchy__c catHierTop2=new Category_Hierarchy__c(Category_Code__c = '11000000', Category_Level__c = 2, Display_Sequence__c = 500,
                                                                 Upper_Category_Code__c = '10000000', Category_Hierarchy__c = catHierTop1.id);
        catHierListTop2.add(catHierTop2);
        
        Category_Hierarchy__c catHierL21=new Category_Hierarchy__c(Category_Code__c = '21000000', Category_Level__c = 2, Display_Sequence__c = 500, 
                                                                   Upper_Category_Code__c = NULL, Category_Hierarchy__c = catHierL1.id);
        catHierListTop2.add(catHierL21); //Hardware 
        
        Category_Hierarchy__c catHierL22=new Category_Hierarchy__c(Category_Code__c = '22000000', Category_Level__c = 2, Display_Sequence__c = 500, 
                                                                   Upper_Category_Code__c = NULL, Category_Hierarchy__c = catHierL1.id);
        catHierListTop2.add(catHierL22); //software
        
        insert catHierListTop2;
        
        List<Category_Hierarchy__c> catHierListTop3=new List<Category_Hierarchy__c>();
        Category_Hierarchy__c catHierTop3=new Category_Hierarchy__c(Category_Code__c = '12000000', Category_Level__c = 3, Display_Sequence__c = 500,
                                                                 Upper_Category_Code__c = '11000000', Category_Hierarchy__c = catHierTop2.id);
        catHierListTop3.add(catHierTop3);
        
        insert catHierListTop3;
                
        //Insert test category record
        List<Category__c> catList=new List<Category__c>();
        Category__c catg1=new Category__c(Name = 'Field Instruments', Category_Hierarchy__c = catHierTop1.Id,
                                          Category_Type__c = 'Product', Language_Code__c = 'EN');
        catList.add(catg1);
        
        Category__c catg2=new Category__c(Name = 'Device Smart Communicators', Category_Hierarchy__c = catHierTop2.Id,
                                          Category_Type__c = 'Product', Language_Code__c = 'EN');
        catList.add(catg2);
        
        Category__c catg3=new Category__c(Name = 'Device Smart Communicators BT200', Category_Hierarchy__c = catHierTop3.Id,
                                          Category_Type__c = 'Product', Language_Code__c = 'EN');
        catList.add(catg3);
        
        Category__c catg4 = new Category__c(Name = 'Distributed Control Systems (DCS)', Category_Hierarchy__c = catHierL1.Id,
                                            Category_Type__c = 'System', Language_Code__c = 'EN');
        catList.add(catg4);
        
        Category__c catg5 = new Category__c(Name = 'Hardware', Category_Hierarchy__c = catHierL21.Id,
                                            Category_Type__c = 'System', Language_Code__c = 'EN');
        catList.add(catg5);
        
        Category__c catg6 = new Category__c(Name = 'Software', Category_Hierarchy__c = catHierL22.Id,
                                            Category_Type__c = 'System', Language_Code__c = 'EN');
        catList.add(catg6);
        
        insert catList;
        System.debug('catList::'+catList);
        
        //Insert test product record
        List<Product2> prodList=new List<Product2>();
        Product2 prod1=new Product2();
        prod1.Name = 'Device Smart Communicators BT200';
        prod1.Model_Code__c = 'BT200';
        prod1.Category__c = catg3.Id;
        prod1.Production_Date__c = Date.newInstance(2014, 12, 17);
        prod1.Lang_Code__c = 'EN';
        prodList.add(prod1);
        
        Product2 prod2=new Product2();
        prod2.Name = 'DCS';
        prod2.Model_Code__c = 'AFV10D';
        prod2.Category__c = catg5.Id;
        prod2.Production_Date__c = Date.newInstance(2014, 12, 17);
        prod2.Lang_Code__c = 'EN';
        prodList.add(prod2);
        
        Insert prodList;
        System.debug('prodList::*'+prodList);
        
        //Insert test asset record
        List<Asset> assList=new List<Asset>();
        Asset ass1=new Asset();
        ass1.Name = 'SU1234567';
        ass1.Product2Id = prod1.Id;
        ass1.AccountId = acc1.Id;
        ass1.ContactId = con.Id;
        ass1.SerialNumber = 'SU1234567';
        ass1.MS_Code__c = 'AAI543-H50';
        ass1.Lang_Code__c = 'EN';
        assList.add(ass1);
        
        Asset ass2=new Asset();
        ass2.Name = 'FCS0101';
        ass2.Product2Id = prod2.Id;
        ass2.AccountId = acc1.Id;
        ass2.ContactId = con.Id;
        ass2.Station_Number__c = 2;
        ass2.Domain__c = 1;
        ass2.Station_Type__c = 'FCS';
        ass2.Lang_Code__c = 'EN';
        assList.add(ass2);     
        
        insert assList;
        
		//Insert Case Records 
		List<Case> cseList = new List<Case>(); 
        List<String> prodService=new List<String>{'050','030','040','080','100','900'};
        List<String> sysService=new List<String>{'010','020','040','060','070','100','900'};
            for(Integer i=0; i<prodService.size(); i++){
                Case case1=new Case();
                case1.ContactId = con.Id;
                case1.AccountId  = acc1.Id;
                case1.Service_you_require__c = prodService[i];
                case1.AssetId = ass1.Id;
                case1.Type = 'Request For Service';
                case1.Reason = '';
                case1.Status = 'Active';
                case1.Progress__c = 'Request Submitted 1';
                cseList.add(case1);
            }
        
        for(Integer i=0; i<sysService.size(); i++){
            Case case2=new Case();
            case2.ContactId = con.Id;
            case2.AccountId  = acc1.Id;
            case2.Service_you_require__c = sysService[i];
            case2.productId = prod2.Id;
            case2.Type = 'Request For Service';
            case2.Reason = '';
            case2.Status = 'Active';
            case2.Progress__c = 'Request Submitted 2';
            case2.ServAir_Created_Date__c = Date.today();
            cseList.add(case2);
        }
        
        Case case3=new Case();
        case3.ContactId = con.Id;
        case3.AccountId  = acc1.Id;
        case3.Service_you_require__c = '010';
        case3.Type = 'Request For Service';
        case3.Reason = '';
        case3.Status = 'Active';
        case3.Progress__c = 'Request Submitted 3';
        case3.ServAir_Created_Date__c = Date.today();
        cseList.add(case3);
        
        Case case4=new Case();
        case4.ContactId = con.Id;
        case4.AccountId  = acc1.Id;
        case4.Type = 'Submit An Inquiry';
        case4.Reason = 'Technical Support';
        case4.Status = 'Closed';
        case4.Progress__c = 'Closed';
        case4.ServAir_Created_Date__c = Date.today();
        cseList.add(case4);
        
        Case case5=new Case();
        case5.ContactId = con.Id;
        case5.AccountId  = acc1.Id;
        case5.Type = 'Submit An Inquiry';
        case5.Reason = 'Others';
        case5.Status = 'Active';
        case5.Progress__c = 'InProgress';
        case5.ServAir_Created_Date__c = Date.today();
        cseList.add(case5);
        
        Case case6=new Case();
        case6.ContactId = con.Id;
        case6.AccountId  = acc1.Id;
        case6.Type = 'Submit An Inquiry';
        case6.Reason = 'Sales and Quote';
        case6.Status = 'Active';
        case6.Progress__c = 'InProgress';
        case6.ServAir_Created_Date__c = Date.today();
        cseList.add(case6);
        
        Case case7=new Case();
        case7.ContactId = con.Id;
        case7.AccountId  = acc1.Id;
        case7.Service_you_require__c = '050';
        case7.AssetId = ass1.Id;
        case7.Type = 'Request For Service';
        case7.Reason = '';
        case7.Status = 'Active';
        case7.Progress__c = 'Request Submitted 1';
        cseList.add(case7);
        
        Case case8=new Case();
        case8.ContactId = con.Id;
        case8.AccountId  = acc1.Id;
        case8.Service_you_require__c = '010';
        case8.productId = prod2.Id;
        case8.Type = 'Request For Service';
        case8.Reason = '';
        case8.Status = 'Active';
        case8.Progress__c = 'Request Submitted 2';
        case8.ServAir_Created_Date__c = Date.today();
        cseList.add(case8);
        
        insert cseList;
        system.debug('cseList::'+cseList.size());
        
        //Inserting Service Contracts records
        List<ServiceContract> servContList = new List<ServiceContract>();
        ServiceContract servCont1 = new ServiceContract();
        servCont1.Name = 'Test Service Contract';
        servCont1.Contract_No__c = 'SC-0001';
        servCont1.StartDate = Date.newInstance(2020, 09, 29);
        servCont1.EndDate = Date.newInstance(2021, 02, 17);
        servCont1.Contract_Type__c = 'LCA';
        servContList.add(servCont1);
        
        ServiceContract servCont2 = new ServiceContract();
        servCont2.Name = 'Test Service Contract';
        servCont2.Contract_No__c = 'SC-0001';
        servCont2.StartDate = Date.newInstance(2020, 09, 29);
        servCont2.EndDate = Date.newInstance(2025, 02, 17);
        servCont2.Contract_Type__c = 'LCA';
        servContList.add(servCont2);
        
        insert servContList;
        
        //Inserting SOP record
        Scope_of_Product__c sop1 = new Scope_of_Product__c();
        sop1.Service_Contract__c = servCont1.Id;
        sop1.Asset__c = ass1.Id;
        insert sop1;
        
        //Insert custom setting records
        List<YG_Community_Configuration__c> configList = new List<YG_Community_Configuration__c>();        
        YG_Community_Configuration__c selfAcc=new YG_Community_Configuration__c();
        selfAcc.Name = 'YGSelfRegisterAccountId';
        selfAcc.Text_1__c = acc1.Id;
        configList.add(selfAcc); 
        insert configList;
        
        system.runAs(user){
            Test.startTest();
            List<String> empty=new List<String>();
            List<String> filterValue=new List<String>{'Technical Support','Schedule Maintenance','Calibration'};
            
            YG_AllServiceRequestController.ServiceRequestGridWrapper servReqWrap = new YG_AllServiceRequestController.ServiceRequestGridWrapper();
            servReqWrap = YG_AllServiceRequestController.getServiceRequestGridDetails(empty, '', 'Active', 100, 0);
            system.assertEquals(18, servReqWrap.caseDataList.size());
            
            YG_AllServiceRequestController.ServiceRequestGridWrapper servReqWrap1 = new YG_AllServiceRequestController.ServiceRequestGridWrapper();
            servReqWrap1 = YG_AllServiceRequestController.getServiceRequestGridDetails(empty, 'Product', '', 100, 0);
            system.assertEquals(7, servReqWrap1.caseDataList.size());
            
            YG_AllServiceRequestController.ServiceRequestGridWrapper servReqWrap2 = new YG_AllServiceRequestController.ServiceRequestGridWrapper();
            servReqWrap2 = YG_AllServiceRequestController.getServiceRequestGridDetails(empty, 'System', '', 100, 0);
            system.assertEquals(9, servReqWrap2.caseDataList.size());
            
            YG_AllServiceRequestController.ServiceRequestGridWrapper servReqWrap3 = new YG_AllServiceRequestController.ServiceRequestGridWrapper();
            servReqWrap3 = YG_AllServiceRequestController.getServiceRequestGridDetails(empty, 'Inquiry', '', 100, 0);
            system.assertEquals(3, servReqWrap3.caseDataList.size());
            
            YG_AllServiceRequestController.ServiceRequestGridWrapper servReqWrap4 = new YG_AllServiceRequestController.ServiceRequestGridWrapper();
            servReqWrap4 = YG_AllServiceRequestController.getServiceRequestGridDetails(filterValue, '', '', 100, 0);
            system.assertEquals(6, servReqWrap4.caseDataList.size());
            
            YG_AllServiceRequestController.ServiceRequestGridWrapper servReqWrap5 = new YG_AllServiceRequestController.ServiceRequestGridWrapper();
            servReqWrap5 = YG_AllServiceRequestController.getServiceRequestGridDetails(filterValue, 'Product', '', 100, 0);
            system.assertEquals(2, servReqWrap5.caseDataList.size());
            
            YG_AllServiceRequestController.ServiceRequestGridWrapper servReqWrap6 = new YG_AllServiceRequestController.ServiceRequestGridWrapper();
            servReqWrap6 = YG_AllServiceRequestController.getServiceRequestGridDetails(filterValue, 'System', '', 100, 0);
            system.assertEquals(3, servReqWrap6.caseDataList.size());
            
            YG_AllServiceRequestController.ServiceRequestGridWrapper servReqWrap7 = new YG_AllServiceRequestController.ServiceRequestGridWrapper();
            servReqWrap7 = YG_AllServiceRequestController.getServiceRequestGridDetails(filterValue, 'Inquiry', '', 100, 0);
            system.assertEquals(1, servReqWrap7.caseDataList.size());
            
            YG_AllServiceRequestController.ServiceRequestCSVWrapper csvData = YG_AllServiceRequestController.getServiceRequestCSVDetails();
            system.assertEquals(19, csvData.caseCSVDataList.size());
            
            YG_AllServiceRequestController.ServiceRequestChartWrapper chartDat = YG_AllServiceRequestController.getServiceRequestChartDetails();
            system.assertEquals(6, chartDat.prodChartDataList.size());
            system.assertEquals(7, chartDat.sysChartDataList.size());
            system.assertEquals(3, chartDat.inqChartDataList.size());
            
            String caseNo = [Select CaseNumber From Case Where id = :case6.id].CaseNumber;
            YG_AllServiceRequestController.modelServiceInfo modelServ = YG_AllServiceRequestController.getServiceReqInfo(caseNo);
            system.assertEquals('Sales and Quote', modelServ.serviceType);
            
            String caseNo1 = [Select CaseNumber From Case Where id = :case3.id].CaseNumber;
            YG_AllServiceRequestController.modelServiceInfo modelServ1 = YG_AllServiceRequestController.getServiceReqInfo(caseNo1);
            system.assertEquals('Schedule Maintenance', modelServ1.serviceType);
            
            String caseNo2 = [Select CaseNumber From Case Where id = :case7.id].CaseNumber;
            YG_AllServiceRequestController.modelServiceInfo modelServ2 = YG_AllServiceRequestController.getServiceReqInfo(caseNo2);
            system.assertEquals('Calibration', modelServ2.serviceType);
            
            String caseNo3 = [Select CaseNumber From Case Where id = :case8.id].CaseNumber;
            YG_AllServiceRequestController.modelServiceInfo modelServ3 = YG_AllServiceRequestController.getServiceReqInfo(caseNo3);
            system.assertEquals('Schedule Maintenance', modelServ3.serviceType);
            
			YG_AllServiceRequestController.modelServiceInfo modelServExcep = YG_AllServiceRequestController.getServiceReqInfo('caseNo');
			String updDescExcep = YG_AllServiceRequestController.toUpdateCaseDescription('caseNo3','test');
            YG_AllServiceRequestController.CaseHistoryWrapper cseHisExcep = YG_AllServiceRequestController.getCaseHistory('caseNo3');

            String updDesc = YG_AllServiceRequestController.toUpdateCaseDescription(caseNo3,'test');
            system.assertEquals('test', updDesc);
            
            YG_AllServiceRequestController.CaseHistoryWrapper cseHis = YG_AllServiceRequestController.getCaseHistory(caseNo3);
            system.assertEquals(1, cseHis.hisWrap.size());
            
            Test.stopTest();    
        }   
    }  
}