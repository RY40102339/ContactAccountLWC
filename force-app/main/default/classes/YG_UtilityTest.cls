/********************************************************************************************************
* (C) Copyright 2020 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Vinod A
* @version 1.0
* @created 03/06/2020
* @description 
* This test class for YG_Utility apex class.
*
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  10/05/2020			Selvaraj T				Worked on improving the code coverage
*
*/
@istest
public class YG_UtilityTest {
    
    @istest static void utilityTestMethod(){
        
        //Insert test account record
        Account acc = new account();
        acc.name='XYZ Account';        
        //acc.DUNS_Number__c=102224533; 
        insert acc;    
        
        //Insert test contact record
        Contact con = new Contact();   
        con.FirstName='User';
        con.LastName='CVX AU';
        con.Email='cvxauuser011@chevron.com';
        con.accountid=acc.id; 
        insert con;
        
        //Insert test portal user record
        UserRole user_Role = [SELECT Id FROM UserRole WHERE DeveloperName = 'Customer_Portal_Developer' LIMIT 1];
        Profile profile = [Select Id From Profile Where Name='Customer Portal User'];
        User user = new User(Alias = 'comm', Email='yg.qa167@gmail.com',ContactId=con.id,
                             EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                             LocaleSidKey='en_US', ProfileId = profile.Id,
                             TimeZoneSidKey='America/Los_Angeles', UserName='yg.qa167@gmail.com');
        
        insert user;
        
        System.debug('userId'+user.Id);
        
        //Insert test custom setting record for community URL
        YG_Community_Configuration__c commConfig=new YG_Community_Configuration__c();
        commConfig.Name = 'Community URL';
        commConfig.Text_1__c = 'https://test-yg.cs31.force.com/s/';
        insert commConfig;
        
        //Insert test custom setting record for base community URL
        YG_Community_Configuration__c commConfig2=new YG_Community_Configuration__c();
        commConfig2.Name = 'YG Customer Portal Base URL';
        commConfig2.Text_1__c = 'https://test-yg.cs31.force.com';
        insert commConfig2;
        
        //Insert test custom setting record for learn more link
        YG_Community_Configuration__c commConfig3=new YG_Community_Configuration__c();
        commConfig3.Name = 'Customer Portal LearnMoreLink';
        commConfig3.Text_1__c = 'https://www.yokogawa.com/in/solutions/products-platforms/';
        insert commConfig3;
        
        //Insert test custom setting record for contact support link
         YG_Community_Configuration__c commConfig4=new YG_Community_Configuration__c();
        commConfig4.Name = 'Customer Portal ContactSupportLink';
        commConfig4.Text_1__c = 'https://www.yokogawa.com/contact/';
        insert commConfig4;
        
        //execute class as portal user
        System.RunAs(user){
            System.debug('Current User: ' + UserInfo.getUserName());
            System.debug('loggedInUser Id: ' + UserInfo.getUserId());
            System.debug('Current Profile: ' + UserInfo.getProfileId());
            
            User loggedInUser= YG_Utility.getLoggedInUserInfo(UserInfo.getUserId());
            System.assertEquals(loggedInUser.LastName, 'Testing');
            
            YG_Utility.logError('Product Grid Page', 'Backend Process Error', 'Null pointer Exception', 'YG_GridController', user.Id);
            ErrorLog__c error = [Select Error_Brief__c, Error_Description__c, Error_Generated_By__c, Error_Type__c, Module_ID__c From ErrorLog__c];
            System.assertEquals(error.Error_Type__c, 'Backend Process Error');
            
            String commURL = YG_Utility.getCommunityURL();
            System.assertNotEquals('', commURL);
            
            String baseCommURL = YG_Utility.getCommunityBaseURL();
            System.assertNotEquals('', baseCommURL);
            
            String supportURL = YG_Utility.getCustomerPortalLMLink();
            System.assertNotEquals('', supportURL);
            
            String learnMoreURL = YG_Utility.getCustomerPortalCSLink();
            System.assertNotEquals('', learnMoreURL);
            
            Map<String, YG_Community_Configuration__c> loadLimit = YG_Utility.getCustomConfig();
            system.debug('loadLimit::'+loadLimit);
            
            DateTime dttm = YG_Utility.getUserLocalTime();
            
            Id usrId = '0052w0000028U59';
            try{
                User loggedInUser1= YG_Utility.getLoggedInUserInfo(usrId);
                System.debug('loggedInUser1::'+loggedInUser1);
            }
            Catch(Exception e){
                System.debug('Error in user id'+e.getMessage());
            }

        }
         
    }
}