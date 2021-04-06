import { LightningElement, wire } from 'lwc';
import getProductInformation from '@salesforce/apex/YG_ProductInformationController.getProductInformation';
import getCommunityURL from '@salesforce/apex/YG_Utility.getCommunityURL';
import { CurrentPageReference } from 'lightning/navigation';
import { fireEvent, registerListener, unregisterAllListeners } from 'c/pubSub';
import prodInformationLbl from '@salesforce/label/c.YG_Product_Information';
import productionDateLbl from '@salesforce/label/c.YG_Production_date';
import purchasedDateLbl from '@salesforce/label/c.YG_Purchased_date';
import warrentyLbl from '@salesforce/label/c.YG_Warranty';
import coveredLbl from '@salesforce/label/c.YG_Covered';
import lcaLbl from '@salesforce/label/c.YG_LCA';
import serialNoCodeLbl from '@salesforce/label/c.YG_Serial_no_code';
import typeLbl from '@salesforce/label/c.YG_Type';
import modelCodeLbl from '@salesforce/label/c.YG_Model_code';
import msCodeLbl from '@salesforce/label/c.YG_MS_code';
import prodNameLbl from '@salesforce/label/c.YG_Product_name';
import productCarrierLbl from '@salesforce/label/c.YG_Product_carrier';
import tokuchuNoLbl from '@salesforce/label/c.YG_Tokuchu_no';
import xjNoLbl from '@salesforce/label/c.YG_XJ_no';


export default class YgProductInformation extends LightningElement {

    @wire(CurrentPageReference) pageRef;
    label = {
        prodInformationLbl, productionDateLbl, purchasedDateLbl, warrentyLbl, coveredLbl, lcaLbl, serialNoCodeLbl, typeLbl,
        modelCodeLbl, msCodeLbl, prodNameLbl, productCarrierLbl, tokuchuNoLbl, xjNoLbl
    };
    prodInfoData;
    error;
    //plant_Code = '';
    serial;
    hostURL;

    constructor() {
        super();

        let fullStr = window.location.search.substring(1);
        let splitStr = fullStr.split("&");
        let srlno = '';
        let communityURL;
        for (var i = 0; i < splitStr.length; i++) {
            var pair = splitStr[i].split("=");
            if (pair[0] == 'serialno') {
                srlno = pair[1];
                this.serial = pair[1];
            }
        }
        getCommunityURL()
            .then(result => {
                communityURL = result;
                this.hostURL = result;
            })
            .catch(error => {
                this.error = error;
                console.log('communityURL: ' + JSON.stringify(this.error));
            });

        getProductInformation({ serialNo: srlno })
            .then(result => {
                this.prodInfoData = result;
                fireEvent(this.pageRef, 'prodHisName', result);
                fireEvent(this.pageRef, 'prodHisBackButton', result);
            }).catch(error => {
                this.error = error;
                console.log('prodInfoDataError: ' + JSON.stringify(this.error));
            });

    }

    connectedCallback() {
        //registerListener("plantFilter", this.getFilteredProductInfomationPlant, this);
    }

    disconnectedCallback() {
        //unregisterAllListeners(this);
    }
    /*

    getFilteredProductInfomationPlant(plantCode) {
        this.plant_Code = plantCode;
        getProductInformation({ serialNo: this.serial, plantCode: this.plant_Code })
            .then(result => {
                console.log('productInfo' + JSON.stringify(result));
                console.log('productInfo serialNoCode' + JSON.stringify(result.serialNoCode));
                if (result.serialNoCode === undefined) {
                    console.log('Inside if >>>> ');
                    let url = this.hostURL + 'all-products?pc=' + this.plant_Code;
                    console.log('URL >>>> ' + url);
                    window.location.href = url;
                }
                else {
                    this.prodInfoData = result;
                    fireEvent(this.pageRef, 'prodHisName', result);
                    fireEvent(this.pageRef, 'prodHisBackButton', result);
                }
                this.template.querySelector('.col-lg-10').classList.add('m-l-r-12');
            }).catch(error => {
                this.error = error;
                console.log('prodInfoDataError: ' + JSON.stringify(this.error));
            });
    }*/
}