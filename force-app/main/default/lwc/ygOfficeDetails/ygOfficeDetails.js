import { LightningElement, track } from 'lwc';
import getOfficeDetails from '@salesforce/apex/YG_ServiceRequestAndInquiries.getOfficeDetails';
import ygContLbl from '@salesforce/label/c.YG_Yokogawa_Contact';
import telLbl from '@salesforce/label/c.YG_Tel';
import salesofficeLbl from '@salesforce/label/c.YG_Sales_Office';
import serviceCenterLbl from '@salesforce/label/c.YG_Service_Center';

export default class YgOfficeDetails extends LightningElement {

    @track salesOfficeDet = [];
    @track serviceCenterDet = [];
    error;
    hidePlant = false;

    label = { ygContLbl, telLbl, salesofficeLbl, serviceCenterLbl };

    constructor() {
        super();

        let pagePath = window.location.pathname;
        let pageName = pagePath.substr(3);
        if (pageName === 'thank-you') {
            this.hidePlant = true;
        }

        getOfficeDetails({})
            .then(result => {
                var conts = result;
                let sofc = this.label.salesofficeLbl;
                let sctr = this.label.serviceCenterLbl;
                for (var key in conts) {

                    //Sales Office = 0002
                    if (key == '0002') {
                        this.salesOfficeDet.push({ value: conts[key], key: sofc });
                    }
                    //Sales Office = 0003
                    if (key == '0003') {
                        this.serviceCenterDet.push({ value: conts[key], key: sctr });
                    }
                }
            }).catch(error => {
                this.error = error;
                console.log('Office Details Cmp: ' + JSON.stringify(this.error));
            });
    }
    /*
        renderedCallback() {
            if (this.hidePlant === true) {
                this.template.querySelector('.d-sm-block').classList.add('mt-14');
            }
        }*/
}