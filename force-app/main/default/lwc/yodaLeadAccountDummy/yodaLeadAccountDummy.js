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
import {subscribe, unsubscribe, onError}  from 'lightning/empApi';
import Id from '@salesforce/user/Id';
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
    clickedURLAlready = false;
    isLoading = true;
    
    currentUserId;
    subscription = {};
    CHANNEL_NAME = '/event/YODA_Refresh_Record_Event__e'

    // this insures that recordid is not null
    @api set recordId(value) {
        this._recordId = value;  
        this.currentUserId = Id;

        subscribe(this.CHANNEL_NAME, -1, this.handleEvent).then(response=>{
            this.subscription = response;
        });

        this.refreshData();
    }

    refreshData(){
        this.leadHasContact = false;
        this.clickedURLAlready = false;
        this.isLoading = true;
        this.leadHasContact = false;
        this.isMissingAccount = false;
        getUrl().then(result=>{
            if(result){
                this.URL = result+'/lightning/cmp/runtime_sales_lead__convertDesktopConsole?leadConvert__leadId='+this.recordId+'&ws=%2Flightning%2Fr%2FLead%2F'+this.recordId+'%2Fview';
                this.checkAccountMethod();
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
            this.continueAction();
        })
        .catch(error=>{
            console.log(error);
        })
    }

    handleEvent = event =>{
        const refreshRecordEvent = event.data.payload;

        if(refreshRecordEvent.Record_Id__c === this.recordId&&refreshRecordEvent.Object_Name__c==='Lead'){
            this.refreshData();
        }
    }

    continueAction(){
        console.log('Continue Pressed 2');
        if(this.leadHasContact==true){
            if(this.isMissingAccount!=null&&this.isMissingAccount!=true&&this.isMissingAccount!=undefined){
                this.continueButton();
            }
        }
    }
    continueButton(){
        if(!this.clickedURLAlready){
            this.clickedURLAlready = true;
            let target = this.template.querySelector('[data-id=URLToGoTO]');
            target.click();
            this.createdDummyAccount();
            this.cancelAction();
        }
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
                this.relatedContact();
            }else{
                this.leadHasContact = true;
                this.continueAction();
            }
        })
        .catch(error=>{
            console.log(error);
        })
    }
}