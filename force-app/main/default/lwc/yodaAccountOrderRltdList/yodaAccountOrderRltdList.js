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
*  10/13/2021           Kameron F.              Created LWC
*  10/18/2021           Kameron F.              Added Clickable link to view records without sharing
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
import getIndividualOrder from '@salesforce/apex/YODA_Account_OrderRltdListController.getIndividualOrder';
import TIME_ZONE from '@salesforce/i18n/timeZone';

export default class YodaAccountOrderRltdList extends NavigationMixin(LightningElement) {
    @api recordId;

    @track IsAccountTeamMember
    IsAccountTeamMemberRefresh
    
    timeZone = TIME_ZONE; // Used in the lightning formatted date time

    isLoading = false;
    size = "Orders";
    // instanceURL;
    viewAllURL;
    generalURL; // used to get access to instanceURL for multiple objects

    currentUserId;
    subscription = {};
    CHANNEL_NAME = '/event/YODA_Refresh_Record_Event__e'

    hasOrders;
    Orders;
    Ords;

    showConfirmDialog;
    showViewRecord; // toggles modal that shows individual record

    actions = [
        {label: 'View', name: 'view'},
        {label: 'Edit', name: 'edit'},
        /*{label: 'Delete', name: 'delete'}*/
    ];

    columns = [
        {editable:false,type:'action', typeAttributes: {rowActions:this.actions,menuAlignment: 'auto'}},
        {label: 'Order Name', fieldName:'Name',editable:false,type:'text', initialWidth:130},
        {label: 'End User', fieldName:'EndUserUrl',editable:false,type:'url', initialWidth:170,
        typeAttributes: {label: {fieldName:'EndUser'}}, target: '_blank'},
        {label: 'Order Amount', fieldName:'TotalAmount',editable:false,type:'text'},
        {label: 'PO Number', fieldName:'PoNumber',editable:false,type:'text'},
        {label: 'Sales Person', fieldName:'SalesPersonUrl',editable:false,type:'url', initialWidth:170,
        typeAttributes: {label: {fieldName:'SalesPerson'}}, target: '_blank'}
    ];

    // Table shown if not record Owner or if not on the Account Team
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
            // this.instanceURL = data+'/lightning/o/Order/new?nooverride=1&useRecordTypeCheck=1&defaultFieldValues=AccountId='+this.recordId+'&backgroundContext=%2Flightning%2Fr%2FAccount%2F'+this.recordId+'%2Fview';
            this.generalURL = data+'/lightning/r/';
        }
    }

    @wire(IsAccountTeamMemberMethod,{recordId:'$recordId'})
    wiredAccountTeam(result){
        this.IsAccountTeamMemberRefresh = result;
        this.IsAccountTeamMember = result.data;
        this.loadingDone();
    }

    // The main data retrieval method. 
    // Kam 10/4/2021
    @wire(getOrders,{recordId:'$recordId'})
    wiredOrders(result){
        this.Ords = result;
        if(result.data){
            this.hasOrders = result.data.length>0;

            //this.size = result.data.length>10 ? "Orders (10+)": "Orders ("+result.data.length+")"; 
            this.size = "Orders ("+result.data.length+")"; 
            this.Orders = result.data;
            let rows = [];
            // This is here so we can store the End User URL and any future custom properties
            this.Orders.forEach(element => {
                let finElement = {};
                finElement.Name = element.OrderNumber;
                //finElement.NameUrl = '/'+element.Id;
                finElement.Id = element.Id;

                if(element.TotalAmount!=null)
                    finElement.TotalAmount = element.TotalAmount;
                if(element.PoNumber!=null)
                    finElement.PoNumber = element.PoNumber;
                if(element.SO_Number__c)
                    finElement.SoNumber = element.SO_Number__c;
                if(element.Sales_Person__c!=null){
                    finElement.SalesPerson = element.Sales_Person__r.Name;
                    finElement.SalesPersonUrl =this.generalURL+"User/"+element.Sales_Person__r.Id+"/view?ws=%2Flightning%2Fr%2FAccount%2F"+this.recordId+"/view";
                }
                if(element.Account_End_User__c!=null){
                    finElement.EndUser = element.Account_End_User__r.Name;
                    finElement.EndUserUrl =this.generalURL+"Account/"+element.Account_End_User__r.Id+"/view?ws=%2Flightning%2Fr%2FAccount%2F"+this.recordId+"/view";
                }
                
                rows.push(finElement);
            });
            
            this.Orders = rows;
            this.loadingDone();
        }
    }

    @wire(getIndividualOrder, { recordId: '$recordToBeViewed'})
    wiredIndividualOrder({ error, data }) {
        if (data) {
            this.individualOrder = data;
            let finElement = {};
            finElement.OrderNumber = this.individualOrder.OrderNumber;
            finElement.SO_Number__c = this.individualOrder.SO_Number__c;
            finElement.PoNumber = this.individualOrder.PoNumber;

            if(this.individualOrder.AccountId){
                finElement.AccountId = this.individualOrder.AccountId;
                finElement.Account_Name = this.individualOrder.Account.Name;
                finElement.Account_NameURL = this.generalURL + 'Account/'+this.individualOrder.AccountId+'/view';
            }

            if(this.individualOrder.Account_End_User__r){
                finElement.Account_End_User_Name = this.individualOrder.Account_End_User__r.Name;
                finElement.Account_End_User_URL = this.generalURL + 'Account/'+this.individualOrder.Account_End_User__c+'/view';
            }

            if(this.individualOrder.Account_Ship_To__r)
                finElement.Account_Ship_To_Name = this.individualOrder.Account_Ship_To__r.Name;

            finElement.Requested_Delivery_Date__c = this.individualOrder.Requested_Delivery_Date__c;
            finElement.Planned_Delivery_Date__c = this.individualOrder.Planned_Delivery_Date__c;
            //finElement.Sales_Organization__c = this.individualOrder.Sales_Organization__c;
            finElement.TotalAmount = this.individualOrder.TotalAmount;
            finElement.CurrencyIsoCode = this.individualOrder.CurrencyIsoCode;
            finElement.Company_Currency__c = this.individualOrder.Company_Currency__c;
            finElement.PoDate = this.individualOrder.PoDate;

            if(this.individualOrder.Sales_Person__r){
                finElement.SalesPerson = this.individualOrder.Sales_Person__r.Name;
                finElement.SalesPersonUrl = this.generalURL+"User/"+this.individualOrder.Sales_Person__r.Id+"/view?ws=%2Flightning%2Fr%2FAccount%2F"+this.recordId+"/view";
            }

            finElement.Sales_Office__c = this.individualOrder.Sales_Office__c;
            finElement.Terms_of_Payment__c = this.individualOrder.Terms_of_Payment__c;
            
            if(this.individualOrder.OwnerId){
                finElement.Owner = this.individualOrder.Owner.Name;
                finElement.OwnerURL = this.generalURL+"User/"+this.individualOrder.OwnerId+"/view?ws=%2Flightning%2Fr%2FAccount%2F"+this.recordId+"/view";;
            }

            if(this.individualOrder.CreatedById){
                finElement.CreatedBy = this.individualOrder.CreatedBy.Name;
                finElement.CreatedByURL = this.generalURL+"User/"+this.individualOrder.CreatedById+"/view?ws=%2Flightning%2Fr%2FAccount%2F"+this.recordId+"/view";;
                finElement.CreatedDate = this.individualOrder.CreatedDate;
            }

            if(this.individualOrder.LastModifiedById){
                finElement.LastModifiedBy = this.individualOrder.LastModifiedBy.Name;
                finElement.LastModifiedByURL = this.generalURL+"User/"+this.individualOrder.LastModifiedById+"/view?ws=%2Flightning%2Fr%2FAccount%2F"+this.recordId+"/view";;
                finElement.LastModifiedDate = this.individualOrder.LastModifiedDate;
            }

            // truncates description
            if(this.individualOrder.Description){
                if(this.individualOrder.Description.length>1000)
                    finElement.Description= this.individualOrder.Description.substring(0,1000)+"...";
                else
                    finElement.Description= this.individualOrder.Description
            }

            finElement.Status= this.individualOrder.Status;
            finElement.EffectiveDate= this.individualOrder.EffectiveDate;

            this.individualOrder = finElement;
            this.showViewRecord = true; // loads modal for viewing record after values are set
            this.error = undefined;
        }else if(error){
            console.log(JSON.stringify(error));
        }
    }

    get FieldStyle(){
        return 'slds-col slds-size_2-of-12 slds-truncate';
    }

    get ValueStyle(){
        return 'slds-col slds-size_4-of-12 slds-truncate';
    }

    // Description is handled different due to it's character limit and placement in page layout
    get ValueStyleDescription(){
        return 'slds-col slds-size_4-of-12';
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

        if(refreshRecordEvent.Record_Id__c === this.recordId&&refreshRecordEvent.Object_Name__c==='AccountTeamMember'){
            refreshApex(this.IsAccountTeamMemberRefresh);
        }
        
        if(refreshRecordEvent.Record_Id__c === this.recordId&&refreshRecordEvent.Object_Name__c==='Order'){
            this.refreshData();
        }
    }
    renderedCallback(){
        // Sets header color for lightning-card/lightning-layout
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

        // Platform event subscription to get refresh events on orders
        subscribe(this.CHANNEL_NAME, -1, this.handleEvent).then(response=>{
            this.subscription = response;
        });
    }
    
    loadingDone(){
        // Runs from both wired methods to ensure that both sets of data are done loading
        if(this.IsAccountTeamMember!=null && this.Orders!=null){
            this.isLoading = false;
        }
    }

    // Leaving in case specifications change
    /*recordQueuedToBeDeleted;
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
    }*/

    recordToBeViewed;
    @track individualOrder;

    confirmCancelView(){
        this.showViewRecord = false;
        this.individualOrder = null; 
        this.recordToBeViewed = null;
    }

    viewClicked(event){
        this.recordToBeViewed = event.currentTarget.dataset.id;
    }

    // Holds the delete and edit actions right now
    // Kam 10/4/2021
    /*handleRowAction(event){
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
            case 'view':
                this.viewClicked(event);
                break;
        }
    }*/
}