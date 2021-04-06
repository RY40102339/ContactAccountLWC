import { LightningElement, wire, api } from 'lwc';
import getDocAndResourceDetails from '@salesforce/apex/YG_DocumentAndResourceController.getDocAndResourceDetails';
//import getStationDocDetails from '@salesforce/apex/YG_ViewStationDetailsController.getStationDocDetails';
//import getStationSysRepDetails from '@salesforce/apex/YG_ViewStationDetailsController.getStationSysRepDetails';
import { registerListener, unregisterAllListeners } from 'c/pubSub';
import { CurrentPageReference } from 'lightning/navigation';
import documentsLbl from '@salesforce/label/c.YG_Documents';
import downloadsLbl from '@salesforce/label/c.YG_Downloads';

export default class YgDocuments extends LightningElement {

    @wire(CurrentPageReference) pageRef;
    @api serialNumber;
    label = {
        documentsLbl, downloadsLbl
    };

    docData; sysRep;
    error;
    productHistory = false;
    statDetails = false;
    softwareDetails = false;
    pageName;
    statName = '';
    systemId = '';
    docShow = false;

    constructor() {
        super();


        let fullStr = window.location.search.substring(1);
        let splitStr = fullStr.split("&");
        let srlno = '';
        let modelCodeNo = '';
        let modelCode = '';
        let statName = '';
        for (var i = 0; i < splitStr.length; i++) {
            var pair = splitStr[i].split("=");
            if (pair[0] == 'serialno') {
                srlno = pair[1];
            }
            if (pair[0] == 'modcode') {
                modelCodeNo = pair[1];
            }
            if (pair[0] == 'type') {
                statName = pair[1];
                this.statName = statName;
            }
            if (pair[0] == 'modelCode') {
                modelCode = pair[1];
            }
            if (pair[0] == 'sysid') {
                this.systemId = pair[1];
            }

        }

        let pageURL = window.location.href;
        let pagePath = window.location.pathname;
        let pageName = pagePath.substr(3);
        this.pageName = pageName;

        if (this.pageName === 'product-details') {
            console.log('Inside the prod det doc::');
            getDocAndResourceDetails({
                type: "Document", serialNo: '', modelCode: modelCodeNo,
                plantCode: null, frm: this.pageName
            })
                .then(result => {
                    console.log('result.subWrap.::' + JSON.stringify(result));
                    console.log('result.subWrap.length::' + result.subWrap.length);
                    if (result.subWrap.length === 0) {
                        this.docShow = false;
                        this.template.querySelector('.row').classList.add('d-none');
                    }
                    else {
                        this.docShow = true;
                        this.docData = result;
                        console.log('product-details-doc:: ' + JSON.stringify(this.docData));
                    }
                    this.template.querySelector('.col-lg-10').classList.add('m-l-r-12');
                }).catch(error => {
                    this.error = error;
                    console.log('product-details-errordoc:: ' + JSON.stringify(this.error));
                });
        }
    }

    connectedCallback() {
        registerListener('plantFilter', this.getStatDetFilteredPltDoc, this);
        this.getProdHistoryDoc(this.serialNumber);
    }

    disconnectedCallback() {
        unregisterAllListeners(this);
    }

    @api
    getProdHistoryDoc(sNo) {

        if (sNo != undefined) {
            getDocAndResourceDetails({
                type: "Document", serialNo: sNo, modelCode: '',
                plantCode: null, frm: 'product-history'
            }).then(result => {
                if (result.subWrap.length === 0) {
                    this.docShow = false;
                    this.template.querySelector('.row').classList.add('d-none');
                }
                else {

                    this.docShow = true;
                    this.docData = result;
                }
                this.template.querySelector('.col-lg-10').classList.add('m-l-r-8', 'p-0');
            }).then(() => {
                this.template.querySelector('.notification').innerHTML = 'Documents for S/N: ' + sNo;
                this.template.querySelector('.col-lg-10').classList.remove('pr-lg-5');
            }).catch(error => {
                this.error = error;
                console.log('product-historyerrordoc:: ' + JSON.stringify(this.error));
            });
        }
    }

    getStatDetFilteredPltDoc(plantCode) {

        let fullStr = window.location.search.substring(1);
        let splitStr = fullStr.split("&");
        let srlno = '';
        let modelCodeNo = '';
        let modelCode = '';
        let statName = '';
        for (var i = 0; i < splitStr.length; i++) {
            var pair = splitStr[i].split("=");
            if (pair[0] == 'serialno') {
                srlno = pair[1];
            }
            if (pair[0] == 'modcode') {
                modelCodeNo = pair[1];
            }
            if (pair[0] == 'type') {
                statName = pair[1];
                this.statName = statName;
            }
            if (pair[0] == 'modelCode') {
                modelCode = pair[1];
            }
        }

        let pageURL = window.location.href;
        let pagePath = window.location.pathname;
        let pageName = pagePath.substr(3);
        this.pageName = pageName;
        /*
        if (this.pageName === 'station-details') {
            this.statDetails = true;
            getStationDocDetails({ projectCode: this.systemId, statName: this.statName, plantCode: plantCode })
                .then(result => {
                    this.docData = result;
                    this.template.querySelector('.col-lg-10').classList.add('mt-14');
                })
                .catch(error => {
                    this.error = error.message;
                    console.log('station-details-errordoc:: ' + JSON.stringify(this.error));
                });

            getStationSysRepDetails({
                projectCode: this.systemId, statName: this.statName,
                plantCode: plantCode
            })
                .then(result => {
                    this.sysRep = result;
                    if (result.length == 0) {
                        this.template.querySelector('.sysRep').classList.add('d-none');
                    }
                    this.template.querySelector('.col-lg-10').classList.add('mt-14');
                })
                .catch(error => {
                    this.error = error.message;
                    console.log('station-details-errordoc:: ' + JSON.stringify(this.error));
                });
        }*/
        if (pageName === 'product-details') {
            console.log('Inside the prod det doc::');
            getDocAndResourceDetails({
                type: "Document", serialNo: '', modelCode: modelCodeNo,
                plantCode: null, frm: pageName
            })
                .then(result => {
                    console.log('result.subWrap.::' + JSON.stringify(result));
                    console.log('result.subWrap.length::' + result.subWrap.length);
                    if (result.subWrap.length === 0) {
                        this.docShow = false;
                        this.template.querySelector('.row').classList.add('d-none');
                    }
                    else {
                        this.docShow = true;
                        this.docData = result;
                        console.log('product-details-doc:: ' + JSON.stringify(this.docData));
                    }
                    this.template.querySelector('.col-lg-10').classList.add('m-l-r-12');
                }).catch(error => {
                    this.error = error;
                    console.log('product-details-errordoc:: ' + JSON.stringify(this.error));
                });
        }
        if (pageName === 'product-history') {
            getDocAndResourceDetails({
                type: "Document", serialNo: srlno, modelCode: '',
                plantCode: null, frm: pageName
            })
                .then(result => {
                    if (result.subWrap.length === 0) {
                        this.docShow = false;
                    }
                    else {
                        this.docShow = true;
                        this.docData = result;
                    }
                    this.template.querySelector('.col-lg-10').classList.add('m-l-r-12');
                }).catch(error => {
                    this.error = error;
                    console.log('product-historyerrordoc:: ' + JSON.stringify(this.error));
                });
        }


    }

}