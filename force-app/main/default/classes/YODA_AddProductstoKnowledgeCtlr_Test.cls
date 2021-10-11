/*
*******************************************************************************************************
* (C) Copyright 2021 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Kameron F
* @version 1.0
* @created 9/9/2021
* @description  
* This class is used for testing the YODA_AddProductstoKnowledgeCtlr controller connected to the 
* YODA_AddProductstoKnowledge VisualForce page
* @test class name - YODA_AddProductstoKnowledgeCtlr_Test
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  9/27/2021             Kameron F.              Created Class
*/
@isTest
public class YODA_AddProductstoKnowledgeCtlr_Test {
    @isTest
    static void main(){
        // Inserting all necessary objects to use the page
        Knowledge__kav KL = new Knowledge__kav(Title='Test', UrlName='TestUrl');
        insert KL;
        Category_Hierarchy__c CH = new Category_Hierarchy__c(Category_Code__c='0001',Category_Level__c=001,Name='TestCH');
        insert CH;
        Category__c CAT = new Category__c(Name='Test',Category_Type__c='TestType',Category_Hierarchy__c=CH.id);
        insert CAT;
        Product2 PR = new Product2(Name='TestProduct',Category__c=CAT.id);
        insert PR;
        Applicable_Model__c AM = new Applicable_Model__c(Knowledge__c = KL.id,Product__c=PR.id);
        insert AM;
        
       
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com'+RandomId);
        
        YODA_AddProductstoKnowledgeCtlr sc = new YODA_AddProductstoKnowledgeCtlr();
		//run as system user
        System.runAs(u) { 
            //PageReference pageRef = Page.YODA_AddProductstoKnowledge;
            PageReference pageRef = Page.YODA_AddProductstoKnowledge;
            pageRef.getParameters().put('knowledgeId',KL.iD);
            Test.setCurrentPage(pageRef);
            
            pageRef.getParameters().put('id', String.valueOf(KL.Id));
            sc.search = '';
            sc.search();
            System.assert(sc.mapWrapper.size()==1);
            
            PR = new Product2(Name='Test',Category__c=CAT.id);
            insert PR;
            
            sc.search='Test';
            sc.search();
            System.assert(sc.mapWrapper.size()==2);
            sc.mapWrapper.get(PR.id).isSelected = true;
        }
        sc.Submit();
        sc.Cancel();
    }
}