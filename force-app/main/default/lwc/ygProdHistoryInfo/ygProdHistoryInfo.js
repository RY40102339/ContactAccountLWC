import { LightningElement, wire, api } from 'lwc';
import getProductInformation from '@salesforce/apex/YG_ProductInformationController.getProductInformation';
import getSuffixCodes from '@salesforce/apex/YG_ProductAvailabilityController.getSuffixCodes';
import getCommunityURL from '@salesforce/apex/YG_Utility.getCommunityURL';
import { CurrentPageReference } from 'lightning/navigation';
import { fireEvent, registerListener, unregisterAllListeners } from 'c/pubSub';
import productionDateLbl from '@salesforce/label/c.YG_Production_date';
import msCodeLbl from '@salesforce/label/c.YG_MS_code';
import productCarrierLbl from '@salesforce/label/c.YG_Product_carrier';
import tokuchuNoLbl from '@salesforce/label/c.YG_Tokuchu_no';
import xjNoLbl from '@salesforce/label/c.YG_XJ_no';
import contNoLbl from '@salesforce/label/c.YG_Contract_Number';
import reqQtnLbl from "@salesforce/label/c.YG_Request_for_quotation";
import orderAvaiLbl from "@salesforce/label/c.YG_Order_availability";
import reorderLbl from "@salesforce/label/c.YG_Re_order";

export default class YgProdHistoryInfo extends LightningElement {

    @wire(CurrentPageReference) pageRef;
    @api serialNumber;
    label = {
        productionDateLbl, msCodeLbl, productCarrierLbl, tokuchuNoLbl, xjNoLbl, contNoLbl, reqQtnLbl,
        orderAvaiLbl, reorderLbl
    };
    prodInfoData = [];
    error;
    hostURL;
    prodInfo = false;
    servReqURL = '';
    contractUrl = '';
    showContract = true;
    orderAvailabilty = '';
    msCode = '';

    constructor() {
        super();

        getCommunityURL()
            .then(result => {
                this.hostURL = result;
            })
            .catch(error => {
                this.error = error;
                console.log('communityURL: ' + JSON.stringify(this.error));
            });
    }

    connectedCallback() {
        this.getProdInfo(this.serialNumber);
    }

    disconnectedCallback() {
        unregisterAllListeners(this);
    }

    @api
    getProdInfo(sNo) {
        getProductInformation({ serialNo: sNo })
            .then(result => {
                this.prodInfoData = result;
                this.prodInfo = true;
                if (result.prodContractNo != undefined && result.prodContractNo != '-') {
                    //alert('yes')
                    this.contractUrl = this.hostURL + 'contract-details?contractno=' + result.prodContractNo;
                } else {
                    //alert('no')
                    this.showContract = false;
                    this.contractUrl = "javascript:void(0)";
                }
                this.msCode = this.prodInfoData.msCode;
                this.servReqURL = this.hostURL + 'service-request-and-inquiries?mscode=' + this.prodInfoData.msCode;
                fireEvent(this.pageRef, 'prodHisName', result);
                fireEvent(this.pageRef, 'prodHisBackButton', result);
            })
            .then(()=>{
                getSuffixCodes({ msCode: this.msCode })
                    .then(result => {
                        this.orderAvailabilty = result.orderAvailabilty;
                    }).catch(error => {
                        this.isLoading = false;
                        console.log('msCode Err::' + JSON.stringify(error.message));
                    })
            })
            .catch(error => {
                this.error = error;
                console.log('prodInfoDataError: ' + JSON.stringify(this.error));
            });
    }
}