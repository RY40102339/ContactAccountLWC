/********************************************************************************************************
* (C) Copyright 2020 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Jayaprasath
* @version 1.0
* @created 02/24/2021
* @description 
* This class is used to write the Apex test class coverage for YG_DeactivateHelper.
*
*  Change History:
*  MM/DD/YYYY           Developer Name          Comments
*  
*
*/

@isTest
public class YG_DeactivateHelperTest {
    
    static testmethod void deactivateHelperTestMethod(){
         test.startTest();
          
        //Insert test account record
        Account acc = new account();
        acc.name='XYZ Account'; 
        insert acc;    

        //Insert test contact record 
        Contact con = new Contact();   
        con.FirstName='User';
        con.LastName='CVX AU';
        con.Email='cvxauuser011@chevron.com';
        con.accountid=acc.id; 
        con.Gigya_UID__c = '48207f845b854397b19b40e972156b62';
        insert con;
        
        //Insert test contact record 
        Contact con1 = new Contact();   
        con1.FirstName='User1';
        con1.LastName='CVX AU1';
        con1.Email='cvxauuser0111@chevron.com';
        con1.accountid=acc.id; 
        con1.Gigya_UID__c = '48207f845b854397b19b40e972156b63';
        insert con1;

        //Inserting test plant record
        List<Plant__c> plantList=new List<Plant__c>();
        Plant__c plant1=new Plant__c();
        plant1.Name = 'TestPlantDoc';
        plant1.Account__c = acc.Id;  
        plant1.Plant_Code__c = '300000142';
        plant1.Lang_Code__c = 'EN';
        plantList.add(plant1);
        insert plantList;
        
       
        
        Profile profile = [Select Id From Profile Where Name='Customer Portal User'];
        
        //Insert test customer portal user record   
        User user = new User(Alias = 'comm', Email='yg.test@gmail.com',ContactId=con.id,
                             EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                             LocaleSidKey='en_US', ProfileId = profile.Id,
                             TimeZoneSidKey='America/Los_Angeles', UserName='yg.test@chevron.com');
        
        insert user;
           
        System.debug('userId'+user.Id);
        
        User user1 = new User(Alias = 'comm', Email='yg.test1@gmail.com',ContactId=con1.id,
                             EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                             LocaleSidKey='en_US', ProfileId = profile.Id,
                             TimeZoneSidKey='America/Los_Angeles', UserName='cvxauuser0111@chevron.com');
        
        insert user1;
      
        
         //execute method as portal user   
        System.RunAs(user){
            System.debug('Current User: ' + UserInfo.getUserName());
            System.debug('loggedInUser Id: ' + UserInfo.getUserId());
            System.debug('Current Profile: ' + UserInfo.getProfileId());
            
            User loggedInUser= YG_Utility.getLoggedInUserInfo(UserInfo.getUserId());
            
            Set<String> emailSet  = new Set<String>();
            emailSet.add(con.email);
            
            try{
                YG_DeactivateHelper.deactivateUser(emailSet);
            	YG_DeactivateHelper.updateContact(emailSet);
            }
            catch(Exception e){
                
            }
        }
        
        System.RunAs(user1){
            System.debug('Current User: ' + UserInfo.getUserName());
            System.debug('loggedInUser Id: ' + UserInfo.getUserId());
            System.debug('Current Profile: ' + UserInfo.getProfileId());
            
            User loggedInUser= YG_Utility.getLoggedInUserInfo(UserInfo.getUserId());
            
            Set<String> emailSet1  = new Set<String>();
            emailSet1.add(con1.email);
            
            try{
                YG_DeactivateHelper.deactivateUser(emailSet1);
            	YG_DeactivateHelper.updateContact(emailSet1);
            }
            catch(Exception e){
                
            }
        }
        
         Test.stopTest();
    }	
}