/*
*******************************************************************************************************
* (C) Copyright 2021 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Kameron F
* @version 1.0
* @created 10/13/2021
* @description  
* This file is used on for the yODAAccountOrderRltdList component 
*
* @test class name - YODA_Account_OrderRltdListControllerTest
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  10/13/2021             Kameron F.             Created LWC
*/

import { LightningElement,wire,track,api } from 'lwc';
import {deleteRecord} from 'lightning/uiRecordApi';
import {refreshApex} from '@salesforce/apex';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {NavigationMixin} from 'lightning/navigation';
import {subscribe, unsubscribe, onError}  from 'lightning/empApi';
import IsAccountTeamMemberMethod from '@salesforce/apex/YODA_Account_OppRltdListController.IsAccountTeamMemberMethod';
import getUrl from '@salesforce/apex/YODA_Account_OppRltdListController.getUrl';
import Id from '@salesforce/user/Id';
import getOrders from '@salesforce/apex/YODA_Account_OrderRltdListController.getOrders';
//import NAME_FIELD from '@salesforce/label/Order.OrderNumber';
// 
export default class YodaAccountOrderRltdList extends NavigationMixin(LightningElement) {
    @api recordId;

    @track IsAccountTeamMember

    isLoading = false;
    size = "Orders";
    instanceURL;
    viewAllURL;

    currentUserId;
    subscription = {};
    CHANNEL_NAME = '/event/YODA_Refresh_Record_Event__e'

    hasOrders;
    Orders;
    Ords;

    showConfirmDialog

    actions = [
        {label: 'Edit', name: 'edit'},
        {label: 'Delete', name: 'delete'}
    ];

    columns = [
        {editable:false,type:'action', typeAttributes: {rowActions:this.actions,menuAlignment: 'auto'}},
        {label: 'Order Name', fieldName:'NameUrl',editable:false,type:'url', initialWidth:130,
        typeAttributes: {label: {fieldName:'Name'}}, target: '_blank'},
        {label: 'End User', fieldName:'EndUserUrl',editable:false,type:'url', initialWidth:170,
        typeAttributes: {label: {fieldName:'EndUser'}}, target: '_blank'},
        {label: 'Order Amount', fieldName:'TotalAmount',editable:false,type:'text'},
        {label: 'PO Number', fieldName:'PoNumber',editable:false,type:'text'},
        {label: 'Sales Person', fieldName:'SalesPersonUrl',editable:false,type:'url', initialWidth:170,
        typeAttributes: {label: {fieldName:'SalesPerson'}}, target: '_blank'}
    ];

    columns2 = [
        {label:'Order Name',fieldName:'Name',editable:false,type:'text'},
        {label: 'Order Amount', fieldName:'TotalAmount',editable:false,type:'text'}
    ];

    @wire(getUrl)
    wiredURL({error,data}){
        if(data){
            // URL changes that bring up record type, leaves opened account in background, and auto fills
            // Kam 10/4/2021
            this.viewAllURL = data+'/lightning/r/Account/'+this.recordId+'/related/Orders/view?ws=%2Flightning%2Fr%2FAccount%2F'+this.recordId+'%2Fview';
            this.instanceURL = data+'/lightning/o/Order/new?nooverride=1&useRecordTypeCheck=1&defaultFieldValues=AccountId='+this.recordId+'&backgroundContext=%2Flightning%2Fr%2FAccount%2F'+this.recordId+'%2Fview';
        }
    }

    @wire(IsAccountTeamMemberMethod,{recordId:'$recordId'})
    wiredAccountTeam(result){
        this.IsAccountTeamMember = result.data;
        this.loadingDone();
    }

    // The main data retrieval method. 
    // Kam 9/10/2021
    @wire(getOrders,{recordId:'$recordId'})
    wiredOrders(result){
        this.Ords = result;
        if(result.data){
            this.hasOrders = result.data.length>0;

            this.size = result.data.length>10 ? "Orders (10+)": "Orders ("+result.data.length+")"; 

            this.Orders = result.data;
            let rows = [];
            // This is here so we can store the End User URL and any future custom properties
            this.Orders.forEach(element => {
                let finElement = {};
                finElement.Name = element.OrderNumber;
                finElement.NameUrl = '/'+element.Id;
                finElement.Id = element.Id;

                if(element.TotalAmount!=null)
                    finElement.TotalAmount = element.TotalAmount;
                if(element.PoNumber!=null)
                    finElement.PoNumber = element.PoNumber;
                if(element.Sales_Person__c!=null){
                    finElement.SalesPerson = element.Sales_Person__r.Name;
                    finElement.SalesPersonUrl = '/' + element.Sales_Person__r.Id
                }
                if(element.Account_End_User__c!=null){
                    finElement.EndUser = element.Account_End_User__r.Name;
                    finElement.EndUserUrl = '/'+element.Account_End_User__r.Id;
                }
                
                rows.push(finElement);
            });
            this.Orders = rows;
            
            this.loadingDone();
        }
    }

    registerErrorListener() {
        // Invoke onError empApi method
        onError(error => {
            //console.log('Received error from server: ', JSON.stringify(error));
            // Error contains the server-side error
        });
    }

    refreshData(){
        this.isLoading = false;
        return refreshApex(this.Ords); 
    }

    handleEvent = event =>{
        const refreshRecordEvent = event.data.payload;
        // If changes to opportunities were done by this user, then refresh
        if (refreshRecordEvent.User_Id__c === this.currentUserId) {
            this.refreshData();
        }
    }
    renderedCallback(){
        const style = document.createElement('style');
        style.innerText = `
        c-yoda-account-order-rltd-list .slds-card__header {
            background-color: #f2f2f2;
            margin-bottom:0px;
        }
        c-yoda-account-order-rltd-list .slds-card__body{
            margin-top:0px;
        }
        `;
        this.template.querySelector('lightning-card').appendChild(style);
    }
    connectedCallback(){
        this.currentUserId = Id;
        this.registerErrorListener(); 

        subscribe(this.CHANNEL_NAME, -1, this.handleEvent).then(response=>{
            this.subscription = response;
        });
    }
    
    loadingDone(){
        // Runs from both wired methods to ensure that both sets of data are done loading
        //console.log('IsAccountTeamMember: ' +this.IsAccountTeamMember+', Opp list: '+this.Opportunities)
        if(this.IsAccountTeamMember!=null && this.Orders!=null){
            this.isLoading = false;
        }
    }

    recordQueuedToBeDeleted;
    confirmDelete(){
        deleteRecord(this.recordQueuedToBeDeleted)
            .then(()=>{
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Record deleted',
                        variant: 'success'
                    })
                );
                this.refreshData();
            })
            .catch(error => { // Likely will occur when trying to delete a record that no longer exists
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error deleting record',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });   
            this.confirmCancel();
    }

    confirmCancel(){
        this.showConfirmDialog = false;
        this.recordQueuedToBeDeleted = null;
        this.isLoading = false;
    }

    // Holds the delete and edit actions right now
    // Kam 10/4/2021
    handleRowAction(event){
        const action = event.detail.action;
        switch(action.name){
            case 'delete':
                this.isLoading = true;
                this.recordQueuedToBeDeleted = event.detail.row.Id;
                this.showConfirmDialog = true;
                break;
            case 'edit':
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: event.detail.row.Id,
                        actionName: 'edit',
                    }
                });
                break;
        }
    }
}