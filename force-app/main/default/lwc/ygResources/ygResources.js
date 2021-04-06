import { LightningElement, wire } from 'lwc';
import getDocAndResourceDetails from '@salesforce/apex/YG_DocumentAndResourceController.getDocAndResourceDetails';
import resourceLbl from '@salesforce/label/c.YG_Resources';
import funcSpecifiLbl from '@salesforce/label/c.YG_Specifications_and_Functions';
import techInfoLbl from '@salesforce/label/c.YG_Technical_Information';
import { CurrentPageReference } from "lightning/navigation";
import { registerListener, unregisterAllListeners } from "c/pubSub";
export default class YgResources extends LightningElement {
    @wire(CurrentPageReference) pageRef;
    resData;
    error;
    label = {
        resourceLbl, funcSpecifiLbl, techInfoLbl
    };
    plant_Code = "";
    resourceShow = false;
    pageName; modelCodeNum; serial; showResource = false;

    constructor() {
        super();

        let fullStr = window.location.search.substring(1);
        let splitStr = fullStr.split("&");
        let srlno = '';
        let modelCodeNo = '';
        for (var i = 0; i < splitStr.length; i++) {
            var pair = splitStr[i].split("=");
            if (pair[0] == 'serialno') {
                srlno = pair[1];
                this.serial = pair[1];
            }
            if (pair[0] == 'modcode') {
                modelCodeNo = pair[1];
                this.modelCodeNum = pair[1];
            }
        }

        let pageURL = window.location.href;
        let pagePath = window.location.pathname;
        let pageName = pagePath.substr(3);
        this.pageName = pagePath.substr(3);

        /*if (pageName === 'product-details') {
            getDocAndResourceDetails({ type: "Resources", serialNo: '', modelCode: modelCodeNo })
                .then(result => {
                    this.resData = result;
                }).catch(error => {
                    this.error = error;
                    console.log('product-details-errorRes:: ' + JSON.stringify(this.error));
                });
        }

        if (pageName === 'product-history') {
            getDocAndResourceDetails({ type: "Resources", serialNo: srlno, modelCode: '' })
                .then(result => {
                    this.resData = result;
                }).catch(error => {
                    this.error = error;
                    console.log('product-historyerrorRes:: ' + JSON.stringify(this.error));
                });
        }*/

    }

    connectedCallback() {
        registerListener("plantFilter", this.getFilteredResourcePlant, this);
    }

    disconnectedCallback() {
        unregisterAllListeners(this);
    }


    getFilteredResourcePlant(plantCode) {
        this.plant_Code = plantCode;
        console.log("ygResource >>> plant_Code ::: " + this.plant_Code);
        console.log("ygResource >>> pageName ::: " + this.pageName);

        if (this.pageName === 'product-details') {
            console.log('inside resource::');
            console.log('inside this.modelCodeNum::' + this.modelCodeNum);
            console.log('inside this.plant_Code::' + this.plant_Code);
            getDocAndResourceDetails({ type: "Resources", serialNo: '', modelCode: this.modelCodeNum, plantCode: null, frm: this.pageName })
                .then(result => {
                    console.log('inside result method');
                    console.log('product-details-Res-result:: ' + JSON.stringify(result));
                    if (result.subWrap.length === 0 & result.specWrap.length === 0) {
                        this.showResource = false;
                    }
                    else {
                        this.showResource = true;
                        this.resData = result.subWrap;
                        this.sepcData = result.specWrap;
                        console.log('product-details-Res-SubWrap:: ' + JSON.stringify(this.resData));
                    }
                    this.template.querySelector('.col-lg-10').classList.add('m-l-r-12');
                }).catch(error => {
                    this.error = error;
                    console.log('product-details-errorRes:: ' + JSON.stringify(this.error));
                });
        }
        if (this.pageName === 'product-history') {
            getDocAndResourceDetails({ type: "Resources", serialNo: this.serial, modelCode: '', plantCode: null, frm: this.pageName })
                .then(result => {
                    if (result.subWrap.length === 0 & result.specWrap.length === 0) {
                        this.showResource = false;
                    }
                    else {
                        this.showResource = true;
                        this.resData = result.subWrap;
                        this.sepcData = result.specWrap;
                    }
                    this.template.querySelector('.col-lg-10').classList.add('m-l-r-12');
                }).catch(error => {
                    this.error = error;
                    console.log('product-historyerrorRes:: ' + JSON.stringify(this.error));
                });
        }


    }
}