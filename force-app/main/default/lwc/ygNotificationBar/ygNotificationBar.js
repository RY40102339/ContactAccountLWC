import { LightningElement, wire, api } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import getNotificationBarData from '@salesforce/apex/YG_NotificationBarController.getNotificationBarData';
//import getStatNotifications from '@salesforce/apex/YG_ViewStationDetailsController.getStatNotifications';
import getCustomerPortalLMLink from '@salesforce/apex/YG_Utility.getCustomerPortalLMLink';
import getCustomerPortalCSLink from '@salesforce/apex/YG_Utility.getCustomerPortalCSLink';
import getCommunityURL from '@salesforce/apex/YG_Utility.getCommunityURL';
import { fireEvent, registerListener, unregisterAllListeners } from 'c/pubSub';
import { loadScript } from 'lightning/platformResourceLoader';
import YG_CustomerPortal from '@salesforce/resourceUrl/YG_CustomerPortal';
import notificationLbl from '@salesforce/label/c.YG_Notification';
import calibrationRecLbl from '@salesforce/label/c.YG_Calibration_recommended1';
import learnMoreLbl from '@salesforce/label/c.YG_Learn_more';
import firmwareUptAvailLbl from '@salesforce/label/c.YG_Firmware_updates_available1';
import downloadsLbl from '@salesforce/label/c.YG_Downloads';
import modelRecalledLbl from '@salesforce/label/c.YG_Model_Recalled';
import contactSupportLbl from '@salesforce/label/c.YG_Contact_support';
import modelDiscontinueLbl from '@salesforce/label/c.YG_Model_Discontinued';
import viewGenerationModelLbl from '@salesforce/label/c.YG_View_Generation_Model';
import requestForCalibrationLbl from '@salesforce/label/c.YG_Request_for_calibration';
import partrolInspectschedulteLbl from '@salesforce/label/c.YG_PatrolInspectionscheduledon';
import thisLCALbl from '@salesforce/label/c.YG_ThisLCAExpiringIn';
import thisBCPLbl from '@salesforce/label/c.YG_ThisBCPExpiringIn';
import thisContractLbl from '@salesforce/label/c.YG_ThisContractExpiringIn';
import renewcontractLbl from '@salesforce/label/c.YG_Renew_contract';
import notspecifythesiteLbl from '@salesforce/label/c.Yg_not_specify_the_site';
import specifyasiteLbl from '@salesforce/label/c.YG_Specify_a_site';
import notregisteredanyproductLbl from '@salesforce/label/c.YG_not_registered_any_product';
import registeryourproductsLbl from '@salesforce/label/c.YG_Register_your_products';

export default class YgNotificationBar extends LightningElement {

    @wire(CurrentPageReference) pageRef;
    @api serialNumber;

    label = {
        notificationLbl, calibrationRecLbl, learnMoreLbl, firmwareUptAvailLbl, downloadsLbl, modelRecalledLbl,
        contactSupportLbl, modelDiscontinueLbl, viewGenerationModelLbl, requestForCalibrationLbl, partrolInspectschedulteLbl, thisLCALbl, renewcontractLbl,
        thisBCPLbl, thisContractLbl, notspecifythesiteLbl, specifyasiteLbl, notregisteredanyproductLbl, registeryourproductsLbl
    };
    communityURL;
    productRegURL;
    prodDet = false;
    prodHistory = false;
    prodHisNotiBar;
    prodDetailsNotiBar;
    //softwareDetails = false;
    statDetails = false;
    prodDetails = false;
    //swNotiCount = 0; 
    statDetNotiSize = 0;
    //softwareNotification = [];
    statDetNotiBar = [];
    stationName;
    showNoti = false;
    supportLink;
    learnMoreLink;
    //hardwareNotification = [];
    //hardwareDetails = false;
    //hwNotiCount = 0;
    pageName;
    plant_Code = '';
    systemId = '';
    modelCodes; serial;
    serviceNotifications = true;
    contractDetails = false; contractLabelNotiBar; overviewRequest = false;
    showNotiBarContDet = false; contractNotiCnt; showContractExpiryDate = false; contractExpiryDate; showSheduleDtNoti = false; scheduleDtate; renewURL;
    sysflag = false;
    prodflag = false;
    noticount = 0;

    constructor() {
        super();

        let pageURL = window.location.href;
        let pagePath = window.location.pathname;
        let pageName = pagePath.substr(3);
        console.log('pageName::' + pageName);

        if (pageName === 'product-history') {
            this.prodHistory = true;
            this.pageName = 'product-history';
        }

        if (pageName === 'station-details') {
            this.statDetails = true;
            this.pageName = pageName;
        }
        if (pageName === 'product-details') {
            this.prodDetails = true;
            this.pageName = 'product-details';
        }

        if (pageName === 'contract-details') {
            this.contractDetails = true;
            this.pageName = 'contract-details';
        }
        if (pageName === 'overview') {
            this.serviceNotifications = false;
            this.pageName = 'overview';
        }
        if (pageName === 'overview-request') {
            this.overviewRequest = true;
            this.pageName = 'overview-request';
        }
        let fullStr = window.location.search.substring(1);
        let splitStr = fullStr.split("&");
        let srlno = '';
        let modelCodeNo = '';
        let statName = '';
        for (var i = 0; i < splitStr.length; i++) {
            var pair = splitStr[i].split("=");
            if (pair[0] == 'serialno') {
                srlno = pair[1];
                this.serial = pair[1];
            }
            if (pair[0] == 'modcode') {
                modelCodeNo = pair[1];
                this.modelCodes = pair[1];
            }
            if (pair[0] == 'type') {
                statName = pair[1];
                this.stationName = pair[1];
            }
            if (pair[0] == 'sysid') {
                this.systemId = pair[1];
            }
            if (pair[0] == 'pc') {
                this.plant_Code = pair[1];
            }

        }

        console.log('statName::' + statName);

        getCommunityURL({})
            .then(result => {
                this.communityURL = result;
                this.productRegURL = this.communityURL + 'product-registration';
                console.log('this.productRegURL' + this.productRegURL);
            }).catch(error => {
                this.error = error;
                console.log('Error: ' + JSON.stringify(this.error));
            });

        getCustomerPortalLMLink({})
            .then(result => {
                this.learnMoreLink = result;
                console.log('learnMoreLink::' + JSON.stringify(this.learnMoreLink));
            })
            .catch(error => {
                this.error = error.body;
                console.log('learnMoreLinkError:: ' + JSON.stringify(this.error));
            })

        getCustomerPortalCSLink({})
            .then(result => {
                this.supportLink = result;
                console.log('supportLink::' + JSON.stringify(this.supportLink));
            })
            .catch(error => {
                this.error = error.body;
                console.log('supportLinkError:: ' + JSON.stringify(this.error));
            })

        this.getStatFilterPltNoti(this.plant_Code);
    }

    connectedCallback() {
        registerListener('getContractDetailsNotificationBar', this.getContractDetailsNotificationBar, this);
        registerListener('notiBarContractDetails', this.getContractNotification, this);
        registerListener("plantFilter", this.getProductDetailsNotiPlant, this);
        this.getNotification(this.serialNumber);
        registerListener("hideNotify", this.gethideNotify, this);
    }

    disconnectedCallback() {
        unregisterAllListeners(this);
    }

    renderedCallback() {
        if (this.serviceNotifications === false) {
            this.template.querySelector(".row").classList.add('d-none')
        }
    }

    gethideNotify(res) {

        if (res.systemCount == 0) {
            this.sysflag = true;
            console.log('gethideSystem**');
        }

        if (res.productCount == 0) {
            this.prodflag = true;
            console.log('gethideProduct**');
        }

        this.noticount = res.notify;
    }

    @api
    getNotification(sNo) {
        if (sNo != undefined) {
            getNotificationBarData({ serialno: sNo, modelCode: '' })
                .then(result => {

                    if (result.notificationCnt > 0) {
                        this.prodHisNotiBar = result;
                        console.log('prodHistorynotiBar::' + JSON.stringify(this.prodHisNotiBar));
                    } else {
                        this.template.querySelector('.row').classList.add('d-none');
                    }
                })
                .catch(error => {
                    this.error = error.body;
                    console.log('errornotiBar:: ' + JSON.stringify(this.error));
                })
        }
    }

    getContractNotification(result) {
        //alert('Noti Bar result::' + JSON.stringify(result.contractExpiryDate));
        //alert('firstInspectionDate::' + JSON.stringify(result.secondInspectionDate));
        //alert('secondInspectionDate::' + JSON.stringify(result.secondInspectionDate));
        //alert('result.notificationCount::' + JSON.stringify(result.notificationCount));
        //alert('result.contractType::' + JSON.stringify(result.contractType));

        this.renewURL = this.communityURL + 'service-request-and-inquiries' + '?pc=' + this.plant_Code + '&contractno=' + result.contractNum;
        //alert('this.renewURL::' + this.renewURL);
        if (result.notificationCount === 0) {
            this.showNotiBarContDet = false;
        }
        else {
            this.showNotiBarContDet = true;
            this.contractNotiCnt = result.notificationCount;
        }
        //alert('this.showNotiBarContDet::' + this.showNotiBarContDet);
        if (result.contractType === 'LCA') {
            this.contractLabelNotiBar = this.label.thisLCALbl;
        } else if (result.contractType === 'BCP') {
            this.contractLabelNotiBar = this.label.thisBCPLbl
        } else {
            this.contractLabelNotiBar = this.label.thisContractLbl
        }
        //alert('this.contractLabelNotiBar::' + this.contractLabelNotiBar);
        //Show the contract expiry in noti bar
        if (result.contractExpiryDate === undefined) {
            this.showContractExpiryDate = false;
        } else {
            this.showContractExpiryDate = true;
            this.contractExpDate = result.contractExpiryDate;
        }

        console.log('this.result ' + JSON.stringify(result));
        //Show the inspection date in noti bar
        if (result.inspecDates.length == 0) {
            this.showSheduleDtNoti = false;
        } else {
            this.showSheduleDtNoti = true;

            if (result.inspecDates.length > 1) {
                let inspDates = result.inspecDates.join(", ");
                console.log('inspDates.x ' + JSON.stringify(inspDates));
                var replaceLast = inspDates.replace(/,(?=[^,]*$)/, ' and');
                console.log('replaceLast ' + replaceLast);

                this.scheduleDtate = replaceLast;
            } else {
                this.scheduleDtate = result.inspecDates[0]
            }
        }
    }

    getStatFilterPltNoti(plantCode) {

        this.plant_Code = plantCode;
/*
        if (this.pageName === 'station-details') {
            getStatNotifications({ projectCode: this.systemId, statName: this.stationName, plantCode: plantCode })
                .then(result => {
                    if (result.length > 0) {
                        this.statDetNotiSize = result.length;

                        if (this.statDetNotiSize > 3) {
                            this.showNoti = true;
                            let temparr = [];
                            //temparr = result.slice(3, this.statDetNotiSize);
                            temparr = result.slice(0, 3);
                            console.log('temparr::' + JSON.stringify(temparr));
                            this.statDetNotiBar = temparr;
                        } else {
                            this.statDetNotiBar = result;
                            this.showNoti = false;
                        }
                    } else {
                        this.template.querySelector('.row').classList.add('d-none');
                    }

                    console.log('statDetNotiBar::' + JSON.stringify(this.statDetNotiBar));
                })
                .catch(error => {
                    this.error = error.message;
                    console.log('statDetNotiBarError:: ' + JSON.stringify(this.error));
                })
        }*/
    }

    getProductDetailsNotiPlant(plantCode) {
        //alert('notibar::' + plantCode);
        //this.plant_Code = plantCode;
        console.log('plant_Code plant_Code: ' + this.plant_Code);
        console.log('modelCodeNo plant_Code: ' + this.modelCodes);
        if (this.pageName === 'product-details') {
            console.log('inside product details notification bar::'); // plantCode: this.plant_Code
            getNotificationBarData({ serialno: '', modelCode: this.modelCodes })
                .then(result => {
                    console.log('NotiBar result::' + JSON.stringify(result));
                    //console.log('NotiBar result length::' + result.length);
                    if (result.notificationCnt > 0) {
                        this.prodDetailsNotiBar = result;
                        //console.log('prodDetailsNotiBar::' + JSON.stringify(this.prodDetailsNotiBar));
                    } else {
                        this.template.querySelector('.row').classList.add('d-none');
                    }
                })
                .catch(error => {
                    this.error = error.body;
                    console.log('errornotiBar:: ' + JSON.stringify(this.error));
                })
        }
        if (this.pageName === 'product-history') {
            getNotificationBarData({ serialno: this.serial, modelCode: '' })
                .then(result => {

                    if (result.notificationCnt > 0) {
                        this.prodHisNotiBar = result;
                        console.log('prodHistorynotiBar::' + JSON.stringify(this.prodHisNotiBar));
                    } else {
                        this.template.querySelector('.row').classList.add('d-none');
                    }
                })
                .catch(error => {
                    this.error = error.body;
                    console.log('errornotiBar:: ' + JSON.stringify(this.error));
                })
        }
    }

    showallNoti() {
        /*
        if (this.statDetails) {

            getStatNotifications({ projectCode: this.systemId, statName: this.stationName, plantCode: this.plant_Code })
                .then(result => {
                    this.statDetNotiSize = result.length;
                    this.statDetNotiBar = result;
                    this.showNoti = false;
                    console.log('statDetNotiBar::' + JSON.stringify(this.statDetNotiBar));
                })
                .catch(error => {
                    this.error = error.body;
                    console.log('statDetNotiBarError:: ' + JSON.stringify(this.error));
                })
        }*/

    }

    getContractDetailsNotificationBar(notificationList) {
        console.log('Inside getContractDetailsNotificationBar ::: notificationList :::' + notificationList);
        this.contracteDetails = false;

    }

    toggleFilter() {

        const filter_box = this.template.querySelector('.filter_box');
        const filter_toggle = this.template.querySelector('.filter_toggle');

        $(filter_box).slideToggle('slow', function () {
            $(this).toggleClass('active', $(this).is(':visible'));
            $(filter_toggle).toggleClass('active', $(this).is(':visible'));
        });
    }

    requestPlant() {
        fireEvent(this.pageRef, 'requestPlant', null);
    }
}