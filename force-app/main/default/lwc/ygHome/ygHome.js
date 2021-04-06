import { LightningElement, track } from "lwc";
import checkContractSync from '@salesforce/apex/YG_ContractAPIHandler.checkContractSync';
import getContractAPI from '@salesforce/apex/YG_ContractAPIHandler.getContractAPI';
import getContractProduct from '@salesforce/apex/YG_ContractAPIHandler.getContractProduct';
import callCaseAPIInfo from '@salesforce/apex/YG_CaseAPI.callCaseAPIInfo';
import YG_CustomerPortal from "@salesforce/resourceUrl/YG_CustomerPortal";
import { loadStyle } from "lightning/platformResourceLoader";

export default class YgHome extends LightningElement {
    //Customer plant details var
    plantCodeList = [];
    @track isLoading = true;

    constructor() {
        super();
        console.log("Begin Time " + new Date().toLocaleString());

        checkContractSync()
            .then(result => {
                console.log('Contract Sync Result::' + result);
                return result;
            })
            .then(result => {

                this.template.querySelector('.progress-bar').classList.remove('grey-dark-bg');
                this.template.querySelector('.progress-bar').classList.add('secondary-yellow');
                this.template.querySelector('.txt-load').innerHTML = 'Syncing the contract data.';
                console.log('Contract Sync Result 1::' + result);
                console.log("Contract Begin Time " + new Date().toLocaleString());
                if (result) {
                    getContractAPI()
                        .then(result => {
                            console.log('Contract API Result::' + result);
                            if (result != null) {
                                console.log("SOP Begin Time " + new Date().toLocaleString());
                                getContractProduct()
                                    .then(result => {
                                        console.log('SOP API Result::' + result);
                                        console.log("SOP END Time " + new Date().toLocaleString());
                                    }).then(() => {
                                        this.template.querySelector('.progress-bar').classList.remove('secondary-yellow');
                                        this.template.querySelector('.progress-bar').classList.add('blue-primary-bg');
                                        this.template.querySelector('.txt-load').innerHTML = 'Syncing the contract product data.';
                                    })
                                    .catch(error => {
                                        console.log('SOP API Error::' + JSON.stringify(error.message));
                                    })
                                callCaseAPIInfo()
                                    .then(result => {
                                        console.log('Case API Result::' + result);
                                        console.log("Case END Time " + new Date().toLocaleString());
                                        window.location.href = "overview";
                                    }).then(() => {
                                        this.template.querySelector('.progress-bar').classList.remove('blue-primary-bg');
                                        this.template.querySelector('.progress-bar').classList.add('secondary-orange');
                                        this.template.querySelector('.txt-load').innerHTML = 'Syncing the case data.';
                                    })
                                    .catch(error => {
                                        console.log('Case API Error::' + JSON.stringify(error.message));
                                    })
                            } else {
                                callCaseAPIInfo()
                                    .then(result => {
                                        console.log('Case API Result::' + result);
                                        console.log("Case END Time " + new Date().toLocaleString());
                                        window.location.href = "overview";
                                    }).then(() => {
                                        this.template.querySelector('.progress-bar').classList.remove('blue-primary-bg');
                                        this.template.querySelector('.progress-bar').classList.add('secondary-orange');
                                        this.template.querySelector('.txt-load').innerHTML = 'Syncing the case data.';
                                    })
                                    .catch(error => {
                                        console.log('Case API Error::' + JSON.stringify(error.message));
                                    })
                            }
                            console.log("End Time " + new Date().toLocaleString());
                        }).catch(error => {
                            console.log('Contract API Error::' + JSON.stringify(error.message));
                        })
                } else {
                    window.location.href = "overview";
                }
            })
            .catch(error => {
                console.log('Contract Sync Error::' + JSON.stringify(error.message));
            })

    }

    connectedCallback() {
        Promise.all([
            loadStyle(this, YG_CustomerPortal + "/YG_CSS/common.css"),
            loadStyle(this, YG_CustomerPortal + "/YG_CSS/style.css")
        ]);
    }

}