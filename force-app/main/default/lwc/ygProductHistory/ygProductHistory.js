import { LightningElement, track, wire, api } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { fireEvent, registerListener, unregisterAllListeners } from 'c/pubSub';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import YG_CustomerPortal from '@salesforce/resourceUrl/YG_CustomerPortal';
import getProductHistory from '@salesforce/apex/YG_ProductHistoryController.getProductHistory'
import productTimelineLbl from '@salesforce/label/c.YG_Product_Timeline';


export default class YgProductHistory extends LightningElement {

    @wire(CurrentPageReference) pageRef;
    @api serialNumber;
    label = {
        productTimelineLbl
    };
    @track isLoading = true;
    showProdHis = false;
    proHisData;
    error;
    //plant_Code = '';
    serialNum;

    constructor() {
        super();

        let fullStr = window.location.search.substring(1);
        let splitStr = fullStr.split("&");
        let srlno = '';
        for (var i = 0; i < splitStr.length; i++) {
            var pair = splitStr[i].split("=");
            if (pair[0] == 'serialno') {
                srlno = pair[1];
                this.serialNum = pair[1];
            }
        }
        console.log('this.serialNum::' + this.serialNum);

        getProductHistory({ serialNo: srlno })
            .then(result => {
                this.isLoading = false;
                this.proHisData = result.hisWrap;
            }).catch(error => {
                this.isLoading = false;
                this.error = error;
                console.log('prodHisError: ' + JSON.stringify(this.error));
            });

    }

    connectedCallback() {
        this.getProdHistory(this.serialNumber);
    }

    @api
    getProdHistory(sNo) {
        if (sNo != undefined) {
            getProductHistory({ serialNo: sNo })
                .then(result => {
                    this.isLoading = false;
                    if (result.hisWrap.length > 0) {
                        this.showProdHis = true;
                        this.proHisData = result.hisWrap;
                    }
                }).catch(error => {
                    this.isLoading = false;
                    this.error = error;
                    console.log('prodHisError: ' + JSON.stringify(this.error));
                });
        }
    }

    /*
        getFilteredProductHistoryPlant(plantCode) {
            //this.plant_Code = plantCode;
            //console.log('prodHis::' + this.plant_Code);
            getProductHistory({ serialNo: this.serialNum })
                .then(result => {
                    this.isLoading = false;
                    this.proHisData = result.hisWrap;
                }).catch(error => {
                    this.isLoading = false;
                    this.error = error;
                    console.log('prodHisError: ' + JSON.stringify(this.error));
                });
        }*/

}