/*
*******************************************************************************************************
* (C) Copyright 2020 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Jayaprasath
* @version 1.0
* @created 09/18/2020
* @description 
* This class is used to write the methods for User deactivation from ManageColleagues page.
*
* @test class name - 
*
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  
*/

public class YG_DeactivateHelper {
    
    @future(callout = true)
    public static void deactivateUser(Set<String> allEmails){
        System.debug('deactivateUser--allEmails--'+allEmails);
        
        List<User> usersToUpdate = new List<User>();
        List<User> userListToDeactivate = [select id from User where username in: allEmails];
            
        for(User u : userListToDeactivate){
            u.isactive = false;
			u.status__c = false;
            usersToUpdate.add(u);
        }
        System.debug('apex userListToDeactivate'+usersToUpdate);
        update usersToUpdate;
    }
    
    @future(callout = true)
    public static void updateContact(Set<String> allEmails){
        System.debug(allEmails);
        
        List<Contact> contactToUpdate = new List<Contact>();
        List<Contact> con = [Select id,Status__c,email from Contact where email in: allEmails and status__c =: true];
        
        for(Contact c : con){
			c.Status__c = false;
            contactToUpdate.add(c);
        }
		System.debug(' contact status update'+contactToUpdate);
        update contactToUpdate;

    }
    
}