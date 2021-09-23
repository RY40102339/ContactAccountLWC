/*
*******************************************************************************************************
* (C) Copyright 2021 Yokogawa. All rights reserved.
* This code is property of Yokogawa. Use, duplication and
* disclosure in any form without permission of copyright holder is prohibited.
* 
******************************************************************************************************* 
* @author Kameron F
* @version 1.0
* @created 9/10/2021
* @description  
* This file is used on for the yODAAccountOppRltdList component 
*
* @test class name - YODA_Contact_TriggerHelper_Test
*  Change History:
*  MM/DD/YYYY			Developer Name			Comments
*  9/10/2021             Kameron F.             Created LWC
*  9/15/2021             Kameron F.             Added data refresh after edit
*  9/17/2021             Kameron F.             Updated instanceURL for new Opps
*/
import { api, LightningElement, wire, track } from 'lwc';
import {NavigationMixin} from 'lightning/navigation';
import getOpps from '@salesforce/apex/YODA_Account_OppRltdListController.getOpps';
import IsAccountTeamMemberMethod from '@salesforce/apex/YODA_Account_OppRltdListController.IsAccountTeamMemberMethod';
import {deleteRecord} from 'lightning/uiRecordApi';
import {refreshApex} from '@salesforce/apex';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import getUrl from '@salesforce/apex/YODA_Account_OppRltdListController.getUrl';
import Id from '@salesforce/user/Id';
import { subscribe, unsubscribe, onError}  from 'lightning/empApi';
export default class YODAAccountOppRltdList extends NavigationMixin(LightningElement) {
    @api
    recordId;

    currentUserId;
    subscription = {};
    isLoading = true;
    CHANNEL_NAME = '/event/YODA_Refresh_Record_Event__e'

    @track IsAccountTeamMember

     // If there are no results, then it displays that to the user using this 
     hasOpps;

     // Stores result.data 
     @track Opportunities;
     
     // Stores the result so data can be refresh
     @track
     Opps;
 
     // Stores URL for the org so we can redirect to recordtype page
    // Kam 9/10/2021
    instanceURL

    actions = [
        {label: 'Edit', name: 'edit'},
        {label: 'Delete', name: 'delete'}
    ]
    columns2 = [
        {label:'Name',fieldName:'Name',editable:false,type:'text'},
        {label: 'Owner', fieldName:'ProfileUrl',editable:false,type:'url',
        typeAttributes:{label:{fieldName:'OwnerName'}}, target:'_blank'}
    ]
    columns = [
        {editable:false,type:'action', typeAttributes: {rowActions:this.actions,menuAlignment: 'auto'}},
        {label: 'Opportunity Name', fieldName:'NameUrl',editable:false,type:'url', initialWidth:170,
        typeAttributes: {label: {fieldName:'Name'}}, target: '_blank'},
        {label: 'Owner', fieldName:'ProfileUrl',editable:false,type:'url',
        typeAttributes:{label:{fieldName:'OwnerName'}}, target:'_blank'},
        {label: 'Stage', fieldName:'StageName',editable:false,type:'text'},
        {label: 'Lastmodified Date', fieldName:'LastModifiedDate',editable:false, initialWidth:200,type:'date',typeAttributes:{
            year: "numeric",
            month: "numeric",
            day: "numeric",
            hour: "numeric",
            minute: "numeric"
        }},
        {label: 'End User', fieldName:'EndUserUrl',editable:false,type:'url',
        typeAttributes:{label:{fieldName:'EndUser'}}, target:'_blank'},
    ];

    // Code block that uses YODA_Refresh_Record_Event__e platform event to refresh table
    // Kam 9/15/2021
    registerErrorListener() {
        // Invoke onError empApi method
        onError(error => {
            //console.log('Received error from server: ', JSON.stringify(error));
            // Error contains the server-side error
        });
    }
    handleEvent = event =>{
        const refreshRecordEvent = event.data.payload;
        // If changes to opportunities were done by this user, then refresh
        if (refreshRecordEvent.User_Id__c === this.currentUserId) {
            this.refreshData();
        }
    }
    connectedCallback(){
        this.currentUserId = Id;
        this.registerErrorListener(); 

        subscribe(this.CHANNEL_NAME, -1, this.handleEvent).then(response=>{
            this.subscription = response;
        });

        if(this.Opps&this.Opps.data){
            this.refreshData();
        }
    }
    size = "Opportunities";

    disconnectedCallback() {
        unsubscribe(this.subscription, response => {
            console.log('Successfully unsubscribed');
        });
    }
    // The main data retrieval method. 
    // Kam 9/10/2021
    @wire(getOpps,{recordId:'$recordId'})
    wiredOpps(result){
        this.Opps = result;
        console.log(result);
        console.log(JSON.stringify(result));
        console.log('Should have just printed result 3');
        if(result.data){
            console.log('Opp list with result.data: '+JSON.stringify(result.data));
            this.hasOpps = result.data.length>0;

            this.size = result.data.length>10 ? "Opportunities (10+)": "Opportunities ("+result.data.length+")"; 

            this.Opportunities = result.data;
            let rows = [];
            // This is here so we can store the Profile URL and any future custom properties
            this.Opportunities.forEach(element => {
                let finElement = {};
                finElement.Name = element.Name;
                finElement.NameUrl = '/'+element.Id;
                finElement.ProfileUrl = '/'+element.OwnerId;

                if(element.End_User__r!=null){
                    finElement.EndUser = element.End_User__r.Name;
                    finElement.EndUserUrl = '/'+element.End_User__r.Id;
                }

                finElement.LastModifiedDate = element.LastModifiedDate;
                finElement.StageName = element.StageName;
                finElement.OwnerName = element.Owner.Name;
                finElement.Id = element.Id;
                rows.push(finElement);
            });
            this.Opportunities = rows;
            this.loadingDone();
            // run a method to check if both are true 
        }
       
    }
   
    // Detects if the user has correct access to these records
    @wire(IsAccountTeamMemberMethod,{recordId:'$recordId'})
    wiredAccountTeam(result){
        this.IsAccountTeamMember = result.data;
        this.loadingDone();
    }

    loadingDone(){
        //console.log(this.IsAccountTeamMember+' '+this.Opportunities.length)
        // Runs from bother wired methods to ensure that both sets of data are done loading
        console.log('IsAccountTeamMember: ' +this.IsAccountTeamMember+', Opp list: '+this.Opportunities)
        if(this.IsAccountTeamMember!=null && this.Opportunities!=null){
            this.isLoading = false;
        }
    }

    refreshData(){
        this.isLoading = false;
        return refreshApex(this.Opps); 
    }

    @wire(getUrl)
    wiredURL({error,data}){
        if(data){
            // URL changes that bring up record type, leave opened account in background, and auto fills
            // Kam 9/17/2021
            this.instanceURL = 'https://yg--yodadev1.lightning.force.com/lightning/o/Opportunity/new?nooverride=1&useRecordTypeCheck=1&backgroundContext=%2Flightning%2Fr%2FAccount%2F0011s000001xpe3AAA%2Fview&ws=%2Flightning%2Fr%2FAccount%2F0011s000001xpe3AAA%2Fview&count=9';
            //this.instanceURL = data+'/lightning/o/Opportunity/new?nooverride=1&useRecordTypeCheck=1&defaultFieldValues=AccountId='+this.recordId+'&backgroundContext=%2Flightning%2Fr%2FAccount%2F'+this.recordId+'%2Fview';
        }
    }

    // Holds the delete and edit actions right now
    // Kam 9/10/2021
    handleRowAction(event){
        const action = event.detail.action;
        const row = event.detail.row;
        switch(action.name){
            case 'delete':
                this.isLoading = true;
                deleteRecord(event.detail.row.Id)
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