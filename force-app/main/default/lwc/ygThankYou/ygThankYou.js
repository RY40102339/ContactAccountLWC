import { LightningElement,wire } from 'lwc';
import getCommunityURL from '@salesforce/apex/YG_Utility.getCommunityURL';
import getCaseDetails from '@salesforce/apex/YG_ServiceRequestAndInquiries.getCaseDetails';
import tyMsgLbl from '@salesforce/label/c.YG_Thank_you_message';
import subReqLbl from '@salesforce/label/c.YG_Submit_New_Request';
import viewAllReqLbl from '@salesforce/label/c.YG_View_All_Request_History';
import inqTypeLbl from "@salesforce/label/c.YG_Inquiry_Type";
import inqaboutLbl from "@salesforce/label/c.YG_What_is_your_inquiry_about";
import tellUsLbl from "@salesforce/label/c.YG_Tell_us_about_your_inquiry";
import prodServLbl from "@salesforce/label/c.YG_Product_to_service";
import servReqLbl from "@salesforce/label/c.YG_Service_you_require";
import descriptionLbl from "@salesforce/label/c.YG_Sys_Description";
import optionLbl from "@salesforce/label/c.YG_Optional";
import otherLbl from "@salesforce/label/c.YG_Other";

export default class YgThankYou extends LightningElement {

    label = { tyMsgLbl, subReqLbl, viewAllReqLbl, inqTypeLbl, inqaboutLbl, tellUsLbl, prodServLbl, 
        servReqLbl, descriptionLbl, optionLbl, otherLbl};
     
    communityURL = '';
    submitServReqLink = '';
    viewServReqHisLink = '';

    requestForService = false; 
    submitInquiry = false;

    caseno = '';  
    type = '';serviceYouRequire = '-'; productName = '-' ; description = '-'; inqtype = '-';


    constructor() {
        super();

        let pageURL = window.location.href;
        let pagePath = window.location.pathname;
        let pageName = pagePath.substr(3);


        let fullStr = window.location.search.substring(1);
        let splitStr = fullStr.split("&");
        let modno = '';
        for (var i = 0; i < splitStr.length; i++) {
            var pair = splitStr[i].split("=");
            if (pair[0] == 'caseid') {
                modno = pair[1];
                this.caseno = pair[1];
            }
        }

        getCommunityURL({})
            .then(result => {
                this.communityURL = result;
                this.submitServReqLink = this.communityURL + 'service-request-and-inquiries';
                this.viewServReqHisLink = this.communityURL + 'allservicerequest';
            }).catch(error => {
                this.error = error;
                console.log('commUrl: ' + JSON.stringify(this.error));
            });

        if(this.caseno != ''){
            getCaseDetails({ caseid: this.caseno })
                .then(result => {
                    console.log('Result Case:: '+JSON.stringify(result));

                    if(result.Type == 'Submit An Inquiry'){
                        this.type = result.Reason;
                        this.submitInquiry = true;
                        if(result.ProductId != undefined){
                            this.productName = result.Product.Model_Code__c+', '+result.Product.Name ;
                        }else if(result.AssetId != undefined){
                            this.productName = result.Asset.SerialNumber;                            
                        }else{
                            this.productName = this.label.otherLbl;
                        }
                        this.description = result.Description; 
                        this.inqtype = result.Reason;
                    }

                    if(result.Type == 'Request For Service'){
                        this.type = result.Type;
                        this.requestForService = true;
                        if(result.ProductId != undefined){
                            this.productName = result.Product.Model_Code__c+', '+result.Product.Name ;
                        }else if(result.AssetId != undefined){
                            this.productName = result.Asset.SerialNumber ;
                        }else{
                            this.productName = this.label.otherLbl;
                        } 
                        this.description = result.Description; 
                        this.serviceYouRequire = result.Service_you_require__c;
                    }

                    
                }).catch(error => {
                    this.error = error;
                    console.log('TY page prepop Err:: ' + JSON.stringify(this.error));
                });
        }
        

    }


}