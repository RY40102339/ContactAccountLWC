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
import { track, api, LightningElement, wire } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import dummy from '@salesforce/apex/YODA_LeadAccountDummyController.CreateAccount'
import checkAccount from '@salesforce/apex/YODA_LeadAccountDummyController.MissingAccount';
import {NavigationMixin} from 'lightning/navigation';
import getUrl from '@salesforce/apex/YODA_Account_OppRltdListController.getUrl';
import hasRelatedContact from '@salesforce/apex/YODA_LeadAccountDummyController.hasRelatedContact';

export default class YodaLeadAccountDummy extends NavigationMixin(LightningElement) {
    _recordId;
    @track
    isMissingAccount = false;
    divIsVisible = false;
    @track
    URL;
    @track
    leadHasContact = false;
    //https://yg--yodadev1.lightning.force.com/lightning/cmp/runtime_sales_lead__convertDesktopConsole?leadConvert__leadId=00Q1s00000169UdEAI&uid=1635365753667&ws=%2Flightning%2Fr%2FLead%2F00Q1s00000169UdEAI%2Fview
    //https://yg--yodadev1.lightning.force.com/lightning/cmp/runtime_sales_lead__convertDesktopConsole?leadConvert__leadId=00Q1s00000169UdEAI&uid=1635365782260
    // this insures that recordid is not null
    @api set recordId(value) {
        this._recordId = value;  
        getUrl().then(result=>{
            this.URL = result+'/lightning/cmp/runtime_sales_lead__convertDesktopConsole?leadConvert__leadId='+this.recordId+'&ws=%2Flightning%2Fr%2FLead%2F'+this.recordId+'%2Fview';
        })
        this.relatedContact();
        this.checkAccountMethod();
        
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
            console.log('has contact check')
            console.log(result);
            this.leadHasContact = result;
            this.continueAction();
        })
        .catch(error=>{
            console.log(error);
        })
    }

    continueAction(){
        if(this.leadHasContact&&!this.isMissingAccount){
            let target = this.template.querySelector('[data-id=URLToGoTO]');
            target.click();
            this.createdDummyAccount();
            this.cancelAction();
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
            if(result==true){
                this.isMissingAccount = true;
            }else{
                this.continueAction();
            }
                
        })
        .catch(error=>{
            console.log(error);
        })
    }
}