import { LightningElement, track, api, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { fireEvent, registerListener, unregisterAllListeners } from 'c/pubSub';
import getCommunityURL from '@salesforce/apex/YG_Utility.getCommunityURL';

export default class YgProdHistoryPopup extends LightningElement {

    @wire(CurrentPageReference) pageRef;
    @track isModalOpen = false;
    @api serialIndex;
    @api serialNo;
    @api serialList;
    @track serialNumber;
    @track serialIndx;
    serialnum; prodHisName; prodHisCat;

    prevBtn = true;
    nextBtn = true;
    prevIndex = 0;
    nextIndex = 0;
    commUrl = '';

    constructor() {
        super();

        getCommunityURL({})
            .then(result => {
                this.commUrl = result;
            })
            .catch(error => {
                this.error = error;
                console.log('DataError: ' + JSON.stringify(this.error));
            });
    }

    connectedCallback() {
        registerListener('communityURL', this.getcommunityURL, this);
        registerListener('prodHisName', this.getProdHis, this);
        registerListener('navigationSerial', this.getSerialNo, this);
        this.prodinfo(this.serialNo);
        this.popupNav(this.serialIndex, this.serialList);
    }

    disconnectedCallback() {
        unregisterAllListeners(this);
    }

    prodinfo(sNo) {

        if (sNo != undefined) {
            let query = this.getQueryParams(document.location.search);
            let qsModel = query.modcode;
            window.history.pushState(null, null, this.commUrl + "product-details?modcode=" + qsModel + "&serialno=" + sNo);
            this.serialNumber = sNo;
        }
    }

    popupNav(serialIndx, serialList) {

        if (parseInt(serialIndx) === -1) {
            this.prevBtn = false;
            this.nextBtn = false;
        } else {

            let serialSize = serialList.serialNoDataLists.length;
            if (serialSize > 0) {
                if (serialSize == 1) {
                    this.prevBtn = false;
                    this.nextBtn = false;
                } else {
                    if (parseInt(serialIndx) === 0) {
                        this.prevBtn = false;
                        this.nextBtn = true;
                        this.nextIndex = parseInt(serialIndx);
                    } else {
                        if (parseInt(serialIndx) % parseInt(serialSize - 1) === 0) {
                            this.prevBtn = true;
                            this.nextBtn = false;
                            this.prevIndex = parseInt(serialIndx);
                        } else {
                            this.prevBtn = true;
                            this.nextBtn = true;
                            this.prevIndex = parseInt(serialIndx);
                            this.nextIndex = parseInt(serialIndx);
                        }
                    }
                }
            }
        }
    }

    prevItem() {

        //alert('prevItem' + JSON.stringify(this.serialList));
        let serialSize = this.serialList.serialNoDataLists.length;
        this.prevIndex = parseInt(this.prevIndex) - 1; // so put it at the other end of the array
        if (parseInt(this.prevIndex) === 0) {
            this.prevBtn = false;
            this.nextBtn = true;
            this.nextIndex = 0;

            let sNumber = this.serialList.serialNoDataLists[this.prevIndex].serialNo;
            this.prodinfo(this.serialNo)
            this.template.querySelector('c-yg-prod-history-info').getProdInfo(sNumber);
            this.template.querySelector('c-yg-combination-product').getCombinationInfo(sNumber);
            this.template.querySelector('c-yg-ordering-instructions').getProdExtension(sNumber);
            this.template.querySelector('c-yg-product-history').getProdHistory(sNumber);
            this.template.querySelector('c-yg-notification-bar').getNotification(sNumber);
            this.template.querySelector('c-yg-documents').getProdHistoryDoc(sNumber);
        } else {
            let sNumber = this.serialList.serialNoDataLists[this.prevIndex].serialNo;
            this.prodinfo(this.serialNo)
            this.template.querySelector('c-yg-prod-history-info').getProdInfo(sNumber);
            this.template.querySelector('c-yg-combination-product').getCombinationInfo(sNumber);
            this.template.querySelector('c-yg-ordering-instructions').getProdExtension(sNumber);
            this.template.querySelector('c-yg-product-history').getProdHistory(sNumber);
            this.template.querySelector('c-yg-notification-bar').getNotification(sNumber);
            this.template.querySelector('c-yg-documents').getProdHistoryDoc(sNumber);
        }
    }

    nextItem() {

        let serialSize = this.serialList.serialNoDataLists.length;
        this.nextIndex = parseInt(this.nextIndex) + 1; // so put it at the other end of the array
        this.prevIndex = this.nextIndex;
        if (parseInt(this.nextIndex) > 0) {
            this.prevBtn = true;
        }

        if (parseInt(this.nextIndex) === serialSize - 1) {
            this.nextBtn = false;
            let sNumber = this.serialList.serialNoDataLists[this.nextIndex].serialNo;
            this.prodinfo(sNumber)
            //window.history.pushState(null, null, "&serialno="+sNumber);
            this.template.querySelector('c-yg-prod-history-info').getProdInfo(sNumber);
            this.template.querySelector('c-yg-combination-product').getCombinationInfo(sNumber);
            this.template.querySelector('c-yg-ordering-instructions').getProdExtension(sNumber);
            this.template.querySelector('c-yg-product-history').getProdHistory(sNumber);
            this.template.querySelector('c-yg-notification-bar').getNotification(sNumber);
            this.template.querySelector('c-yg-documents').getProdHistoryDoc(sNumber);
        } else {
            let sNumber = this.serialList.serialNoDataLists[this.nextIndex].serialNo;
            this.prodinfo(sNumber)
            //window.history.pushState(null, null, "&serialno="+sNumber);
            this.template.querySelector('c-yg-prod-history-info').getProdInfo(sNumber);
            this.template.querySelector('c-yg-combination-product').getCombinationInfo(sNumber);
            this.template.querySelector('c-yg-ordering-instructions').getProdExtension(sNumber);
            this.template.querySelector('c-yg-product-history').getProdHistory(sNumber);
            this.template.querySelector('c-yg-notification-bar').getNotification(sNumber);
            this.template.querySelector('c-yg-documents').getProdHistoryDoc(sNumber);
        }
    }

    getQueryParams(qs) {

        qs = qs.split('+').join(' ');
        var params = {},
            tokens,
            re = /[?&]?([^=]+)=([^&]*)/g;

        while (tokens = re.exec(qs)) {
            params[decodeURIComponent(tokens[1])] = decodeURIComponent(tokens[2]);
        }

        return params;
    }

    getProdHis(result) {
        this.prodHisName = result.prodName;
        this.serialnum = result.serialNoCode;
        this.prodHisCat = result.prodCatName;
    }

    //To close the pop window
    closeModal() {

        let query = this.getQueryParams(document.location.search);
        let qsModel = query.modcode;
        window.history.pushState(null, null, this.commUrl + "product-details?modcode=" + qsModel);
        // to close modal set isModalOpen track value as false
        fireEvent(this.pageRef, 'isMSCodeModalOpen', false);
    }
}