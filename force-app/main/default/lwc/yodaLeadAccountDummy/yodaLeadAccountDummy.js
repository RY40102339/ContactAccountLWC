/*
*******************************************************************************************************
* (C) Copyright 2021 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Kameron F
* @version 1.0
* @created 10/26/2021
* @description  
* This file is used on for the yodaLeadAccountDummy component. It is meant to resolve the issue of  
* Contacts not being associated with Accounts.
*
* @test class name - YODA_LeadAccountDummyController_Test
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  10/26/2021           Kameron F.              Created LWC
*/

import {LightningElement} from 'lwc';
import {NavigationMixin} from 'lightning/navigation';

/*import { track, api, LightningElement, wire } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import dummy from '@salesforce/apex/YODA_LeadAccountDummyController.CreateAccount'
import checkAccount from '@salesforce/apex/YODA_LeadAccountDummyController.MissingAccount';
import {NavigationMixin} from 'lightning/navigation';
import getUrl from '@salesforce/apex/YODA_Account_OppRltdListController.getUrl';
import hasRelatedContact from '@salesforce/apex/YODA_LeadAccountDummyController.hasRelatedContact';*/
export default class YodaLeadAccountDummy extends NavigationMixin(LightningElement) {
    /*_recordId;
    @track
    isMissingAccount = false;
    divIsVisible = false;
    @track
    URL;
    @track
    leadHasContact = false;
    clickedURLAlready = false;
    isLoading = true;
    
    // this insures that recordid is not null
    @api set recordId(value) {
        this._recordId = value;  
        getUrl().then(result=>{
            if(result){
                this.URL = result+'/lightning/cmp/runtime_sales_lead__convertDesktopConsole?leadConvert__leadId='+this.recordId+'&ws=%2Flightning%2Fr%2FLead%2F'+this.recordId+'%2Fview';
                this.checkAccountMethod();
                //this.relatedContact();
            }
        })
        
        
    }
    get recordId() {
        return this._recordId;
    }
    
    cancelAction(){
        this.dispatchEvent(new CloseActionScreenEvent());
    }
    relatedContact(){
        hasRelatedContact({recordId: this.recordId})
        .then(result=>{
            this.isMissingAccount = true;
            this.leadHasContact = result;
            this.isLoading = false;
            //this.checkAccountMethod();
            this.continueAction();
        })
        .catch(error=>{
           // this.checkAccountMethod();
            console.log(error);
        })
    }

    continueAction(){
        if(this.leadHasContact==true){
            if(this.isMissingAccount!=null&&this.isMissingAccount!=true&&this.isMissingAccount!=undefined){
                if(!this.clickedURLAlready){
                    this.clickedURLAlready = true;
                    let target = this.template.querySelector('[data-id=URLToGoTO]');
                    target.click();
                    this.createdDummyAccount();
                    this.cancelAction();
                }
            }
        }
    }

    getURLMethod(){

    }

    // Imperative apex call to create account
    createdDummyAccount(){
        dummy({recordId: this.recordId})
        .then(result=>{
        })
        .catch(error=>{
            console.log(error);
        })
    }
    
    // Imperative apex call to check if related contact is missing account
    checkAccountMethod(){
        checkAccount({recordId: this.recordId})
        .then(result=>{
            console.log('Checkout Missing Account Result:' +result);
            if(result==true){
                this.relatedContact();
            }else{
                this.leadHasContact = true;
                this.continueAction();
            }
                
        })
        .catch(error=>{
            console.log(error);
        })
    }*/
}