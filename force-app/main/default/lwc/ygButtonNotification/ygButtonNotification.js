import { LightningElement, track, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { fireEvent, registerListener, unregisterAllListeners } from 'c/pubSub';
import { loadScript } from "lightning/platformResourceLoader";
import YG_CustomerPortal from "@salesforce/resourceUrl/YG_CustomerPortal";
import notiInTotalLbl from '@salesforce/label/c.YG_Notifications_in_total';
import sftLicenseExpLbl from '@salesforce/label/c.YG_Sw_licenses_expiring_soon';
import sftUptLbl from '@salesforce/label/c.YG_Software_updates';
import firmUptLbl from '@salesforce/label/c.YG_Firmware_updates';
import batteryRelaceLbl from '@salesforce/label/c.YG_Battery_replacement';
import calibrationRecomLbl from '@salesforce/label/c.YG_Calibration_recommended';
import discontinueProdLbl from '@salesforce/label/c.YG_Discontinued_products';
import recalledProdLbl from '@salesforce/label/c.YG_Recalled_products';
import warrentyExpsoonLbl from '@salesforce/label/c.YG_Warranty_expiring_soon';
import regulationChangeLbl from '@salesforce/label/c.YG_Regulation_changes';
import viewAll from '@salesforce/label/c.YG_View_all';
import viewAllProd from '@salesforce/label/c.YG_View_all_products';
import productSmall from '@salesforce/label/c.YG_Products_Small';
import allSystems from '@salesforce/label/c.YG_All_Systems';
import viewSystem from '@salesforce/label/c.YG_View_system_details';
import systemId from '@salesforce/label/c.YG_System_ID';

export default class YgButtonNotification extends LightningElement {

    @wire(CurrentPageReference) pageRef;

    label = {
        notiInTotalLbl, sftLicenseExpLbl, sftUptLbl, firmUptLbl, batteryRelaceLbl, calibrationRecomLbl,
        discontinueProdLbl, recalledProdLbl, warrentyExpsoonLbl, regulationChangeLbl, viewAll, viewAllProd,
        productSmall, allSystems, viewSystem, systemId
    };
    products = false;
    //productDetail = false;
    totalCount = 0; contractCount = 0; calibCount = 0; recallCount = 0; firmwareCount = 0; sftExpCount = 0;
    //warrantyCount = 0;
    sftUpdCount = 0; btryReplCount = 0; discontinuedCount = 0; regulationCount = 0;
    productCat;
    btnSelect = false;
    btnSelectval;
    allServiceRequest = false;
    allContracts = false; systems = false;
    totalPhases; phase1Cnt; phase2Cnt; extendedPhase; salesPhaseCnt;
    criticalCnt; productRelatedServCnt; sysAndSoftCnt; inquiryCnt;
    expiryinsixMon; activeContract; futureContract; expiredContract;
    projCodeList = [];
    isViewSystems = false;


    constructor() {
        super();
        let pagePath = window.location.pathname;
        let pageName = pagePath.substr(3);

        let fullStr = window.location.search.substring(1);
        let splitStr = fullStr.split("&");
        for (var i = 0; i < splitStr.length; i++) {
            var pair = splitStr[i].split("=");
            if (pair[0] == 'type') {
                this.productCat = decodeURIComponent(pair[1]).replace(/\+/g, " ");
            }
            if (pair[0] == 'select') {
                this.btnSelect = true;
                this.btnSelectval = decodeURIComponent(pair[1]).replace(/\+/g, " ");
            }
        }
        console.log('productCat::' + this.productCat);
        console.log('btnSelect::' + this.btnSelect);

        if (pageName === 'all-products' || pageName === '') {
            this.products = true;
        }
        /* if (pageName === 'product-details') {
             this.productDetail = true;
         }*/
        if (pageName === 'allservicerequest') {
            this.allServiceRequest = true;
        }
        if (pageName === 'all-contracts') {
            this.allContracts = true;
        }
        if (pageName === 'all-systems') {
            this.systems = true;
        }
        this.loadExternalLibraries();
    }

    async loadExternalLibraries() {
        loadScript(this, YG_CustomerPortal + '/YG_JS/jquery.min.js').then(() => {
        });
    }

    renderedCallback() {

        if (this.products === true) {
            //const noti = this.template.querySelector('.noti span');
            const firm = this.template.querySelector('.firm span');
            const calib = this.template.querySelector('.calib span');
            const discon = this.template.querySelector('.discon span');
            const reCall = this.template.querySelector('.reCall span');
            //const warrty = this.template.querySelector('.warrty span');
            const regulation = this.template.querySelector('.regulation span');

            //noti.innerHTML = this.label.notiInTotalLbl;
            firm.innerHTML = this.label.firmUptLbl;
            calib.innerHTML = this.label.calibrationRecomLbl;
            reCall.innerHTML = this.label.recalledProdLbl;
            discon.innerHTML = this.label.discontinueProdLbl;
            // warrty.innerHTML = this.label.warrentyExpsoonLbl;
            regulation.innerHTML = this.label.regulationChangeLbl;
        }

        if (this.systems === true) {
            this.template.querySelector(".row").classList.add('mVisible');
        }

        /*if (this.systems === true) {
            const noti = this.template.querySelector('.noti span');
            const firm = this.template.querySelector('.firm span');
            const swLic = this.template.querySelector('.swLic span');
            const swUpt = this.template.querySelector('.swUpt span');
            const battery = this.template.querySelector('.battery span');

            noti.innerHTML = this.label.allSystems;
            firm.innerHTML = this.label.firmUptLbl;
            swLic.innerHTML = this.label.sftLicenseExpLbl;
            swUpt.innerHTML = this.label.sftUptLbl;
            battery.innerHTML = this.label.batteryRelaceLbl;
        }
        if (this.productDetail === true) {
            const noti = this.template.querySelector('.noti span');
            const calib = this.template.querySelector('.calib span');
            const warrty = this.template.querySelector('.warrty span');

            noti.innerHTML = this.label.notiInTotalLbl;
            calib.innerHTML = this.label.calibrationRecomLbl;
            warrty.innerHTML = this.label.warrentyExpsoonLbl;
        }*/
        if (this.btnSelect === true) {
            console.log("this.btnSelectval ====> " + this.btnSelectval);
            this.template.querySelector('.noti').classList.remove('active');
            let btn = this.template.querySelector('.' + this.btnSelectval);
            btn.classList.add('active');
            console.log("btn.value " + btn.value);
            fireEvent(this.pageRef, 'systemFilterBtn', btn.value);
            setTimeout(() => {
                fireEvent(this.pageRef, 'allProdFilterBtn', btn.value);
            }, 1000);

        }


    }

    connectedCallback() {
        registerListener('btnNotiCount', this.getBtnNotiCount, this);
        registerListener('prodDetBtnNotiCount', this.getProdDetBtnNotiCount, this);
        registerListener('subMenuLabel', this.getsubMenuLabel, this); //fired from ygSubMenu component
        registerListener('serviceRequestBtnNoti', this.getServReqBtnNotiCount, this);
        registerListener('clearBtnFilter', this.clearBtnFilter, this);
        registerListener('serviceContractBtnNoti', this.getContractBtnNoti, this); //fired from ygAllContractsGrid
        registerListener('systemBtnDetails', this.getsystemBtn, this);
    }

    disconnectedCallback() {
        unregisterAllListeners(this);
    }

    handleChange(event) {

        let radioValue = event.currentTarget.value;

        if (radioValue != undefined) {
            this.template.querySelector('.systemId').innerHTML = radioValue;
            fireEvent(this.pageRef, 'selectedSystem', radioValue);
        }
    }

    getsystemBtn(result) {

        let tempArr = [];
        this.isViewSystems = result.isViewSystems;
        if (result.projCodeList.length > 0) {

            if (result.projCodeList.length == 1) {
                tempArr.push({
                    id: 'sys1',
                    systemId: result.projCodeList[0]
                });
            }

            if (result.projCodeList.length > 1) {

                let i = 1;
                result.projCodeList.forEach(function (proj) {
                    tempArr.push({
                        id: 'sys' + i,
                        systemId: proj
                    });
                    i++;
                })

                const radioBtnEle = this.template.querySelector('.radio-btn');
                setTimeout(() => {
                    //$('div.newradio--inline label', radioBtnEle).first().trigger("click");
                    $('div.newradio--inline input', radioBtnEle).first().prop("checked", true);
                }, 500);
            }

            this.template.querySelector('.systemId').innerHTML = tempArr[0].systemId;
            fireEvent(this.pageRef, 'defaultSystem', tempArr[0].systemId);
            this.projCodeList = tempArr;
        } else {
            this.template.querySelector('.systemId').innerHTML = "";
        }
    }

    getBtnNotiCount(result) {

        if (result.contractSize === 0) {
            this.template.querySelector('.contract').classList.add('d-none');
        } else {
            this.template.querySelector('.contract').classList.remove('d-none');
            this.contractCount = result.contractSize;
        }

        this.template.querySelector('.firm').classList.add('d-none');       
        this.template.querySelector('.calib').classList.add('d-none');
        this.template.querySelector('.regulation').classList.add('d-none');
        this.template.querySelector('.reCall').classList.add('d-none');
        this.template.querySelector('.discon').classList.add('d-none');
        /*
        if (result.totalNot === 0) {
            this.template.querySelector('.noti').classList.add('d-none');
        } else {
            this.template.querySelector('.noti').classList.remove('d-none');
            this.totalCount = result.totalNot;
        }
        if (result.firmwareCount === 0) {
            this.template.querySelector('.firm').classList.add('d-none');
        } else {
            this.template.querySelector('.firm').classList.remove('d-none');
            this.firmwareCount = result.firmwareCount;
        }
        if (result.calibCount === 0) {
            this.template.querySelector('.calib').classList.add('d-none');
        } else {
            this.template.querySelector('.calib').classList.remove('d-none');
            this.calibCount = result.calibCount;
        }
        if (result.discontinuedProdCount === 0) {
            this.template.querySelector('.discon').classList.add('d-none');
        }
        else {
            this.template.querySelector('.discon').classList.remove('d-none');
            this.discontinuedCount = result.discontinuedProdCount;
        }
        if (result.recallCount === 0) {
            this.template.querySelector('.reCall').classList.add('d-none');
        }
        else {
            this.template.querySelector('.reCall').classList.remove('d-none');
            this.recallCount = result.recallCount;
        }
        /*if (result.warrantyCount === 0) {
            this.template.querySelector('.warrty').classList.add('d-none');
        }
        else {
            this.template.querySelector('.warrty').classList.remove('d-none');
            this.warrantyCount = result.warrantyCount;
        }
        if (result.regulationCount === 0) {
            this.template.querySelector('.regulation').classList.add('d-none');
        }
        else {
            this.template.querySelector('.regulation').classList.remove('d-none');
            this.regulationCount = result.regulationCount;
        }*/

    }

    getProdDetBtnNotiCount(result) {
        console.log('serial::' + JSON.stringify(result))
        if (result.notiTotalCount === 0) {
            this.template.querySelector('.noti').classList.add('d-none');
        } else {
            this.template.querySelector('.noti').classList.remove('d-none');
            this.totalCount = result.notiTotalCount;
        }
        if (result.calibrationCount === 0) {
            this.template.querySelector('.calib').classList.add('d-none');
        } else {
            this.template.querySelector('.calib').classList.remove('d-none');
            this.calibCount = result.calibrationCount;
        }
        /*if (result.warrantyCount === 0) {
            this.template.querySelector('.warrty').classList.add('d-none');
        } else {
            this.template.querySelector('.warrty').classList.remove('d-none');
            this.sftExpCount = result.warrantyCount;
        }*/
    }

    getContractBtnNoti(result) {
        //alert(JSON.stringify(result.expirySixMonths));
        if (result.expirySixMonths === 0) {
            this.template.querySelector('.expiresSixMon').classList.add('d-none');
        } else {
            this.template.querySelector('.expiresSixMon').classList.remove('d-none');
            this.expiryinsixMon = result.expirySixMonths;
        }
        if (result.activeContract === 0) {
            this.template.querySelector('.activeCon').classList.add('d-none');
        } else {
            this.template.querySelector('.activeCon').classList.remove('d-none');
            this.activeContract = result.activeContract;
        }
        if (result.futureContract === 0) {
            this.template.querySelector('.futureCon').classList.add('d-none');
        } else {
            this.template.querySelector('.futureCon').classList.remove('d-none');
            this.futureContract = result.futureContract;
        }
        if (result.expiredContract === 0) {
            this.template.querySelector('.expiredCon').classList.add('d-none');
        } else {
            this.template.querySelector('.expiredCon').classList.remove('d-none');
            this.expiredContract = result.expiredContract;
        }
    }

    getServReqBtnNotiCount(result) {

        if (result.prodCaseCnt === 0) {
            this.template.querySelector('.product').classList.add('d-none');
        }
        else {
            this.template.querySelector('.product').classList.remove('d-none');
            this.productRelatedServCnt = result.prodCaseCnt;
        }
        if (result.sysCaseCnt === 0) {
            this.template.querySelector('.systemAndSoftware').classList.add('d-none');
        }
        else {
            this.template.querySelector('.systemAndSoftware').classList.remove('d-none');
            this.sysAndSoftCnt = result.sysCaseCnt;
        }
        if (result.inqCaseCnt === 0) {
            this.template.querySelector('.inquires').classList.add('d-none');
        }
        else {
            this.template.querySelector('.inquires').classList.remove('d-none');
            this.inquiryCnt = result.inqCaseCnt;
        }
    }

    getsubMenuLabel(result) {

        let catLabel;
        let productCat = this.productCat;
        result.forEach(function (list) {
            if (productCat == list.label) {
                catLabel = list.label
            }
        })

        if (productCat == 'Test and Measurement') {
            this.template.querySelector('.noti span').innerHTML = this.label.viewAll + ' ' + catLabel + ' ' + this.label.productSmall;
        } else if (productCat == undefined) {
            this.template.querySelector('.noti span').innerHTML = this.label.viewAllProd;
        } else {
            this.template.querySelector('.noti span').innerHTML = this.label.viewAll + ' ' + catLabel;
        }

    }

    filterGrid(event) {



        const btnSection = this.template.querySelector('.section-buttons');
        $('button', btnSection).removeClass('active').attr('aria-pressed', false);

        //this.template.querySelector('.noti').classList.remove('active');
        /*
        if (this.systems === true) {
            this.template.querySelector('.swLic').classList.remove('active');
            this.template.querySelector('.swUpt').classList.remove('active');
            this.template.querySelector('.firm').classList.remove('active');
            this.template.querySelector('.battery').classList.remove('active');
        }
        if (this.products === true) {
            this.template.querySelector('.firm').classList.remove('active');
            this.template.querySelector('.calib').classList.remove('active');
            this.template.querySelector('.discon').classList.remove('active');
            this.template.querySelector('.reCall').classList.remove('active');
            this.template.querySelector('.warrty').classList.remove('active');
            this.template.querySelector('.regulation').classList.remove('active');
        }
        if (this.productDetail === true) {
            this.template.querySelector('.calib').classList.remove('active');
            this.template.querySelector('.warrty').classList.remove('active');
        }
        if (this.software === true) {
            this.template.querySelector('.swLic').classList.remove('active');
            this.template.querySelector('.swUpt').classList.remove('active');
        }
        if (this.hardware === true) {
            this.template.querySelector('.firm').classList.remove('active');
            this.template.querySelector('.battery').classList.remove('active');
        }*/

        //alert(event.currentTarget.dataset.count)

        event.currentTarget.classList.add('active');
        $('button.active', btnSection).attr('aria-pressed', true);
        fireEvent(this.pageRef, 'prodFilterBtn', event.currentTarget.value);
        fireEvent(this.pageRef, 'allProdFilterBtn', event.currentTarget.value);
        fireEvent(this.pageRef, 'systemFilterBtn', event.currentTarget.value);
        fireEvent(this.pageRef, 'softwareFilterBtn', event.currentTarget.value);
        fireEvent(this.pageRef, 'hardwareFilterBtn', event.currentTarget.value);
        fireEvent(this.pageRef, 'serviceReqBtnFilter', event.currentTarget.value);
        fireEvent(this.pageRef, 'serviceContractBtnFilter', event.currentTarget.value);

        if (event.currentTarget.dataset.count != undefined) {
            //fireEvent(this.pageRef, 'allProdFilterCnt', event.currentTarget.dataset.count);
        }

    }

    filterPhase(event) {

        fireEvent(this.pageRef, 'mainPhaseFilter', event.currentTarget.value);
    }

    filterServiceGrid(event) {
        //alert(event.currentTarget.value);
        fireEvent(this.pageRef, 'serviceReqBtnFilter', event.currentTarget.value);
    }
    clearBtnFilter() {
        /*
        this.template.querySelector('.noti').classList.add('active');
        if (this.systems === true) {
            this.template.querySelector('.swLic').classList.remove('active');
            this.template.querySelector('.swUpt').classList.remove('active');
            this.template.querySelector('.firm').classList.remove('active');
            this.template.querySelector('.battery').classList.remove('active');
        }
        if (this.products === true) {
            this.template.querySelector('.firm').classList.remove('active');
            this.template.querySelector('.calib').classList.remove('active');
            this.template.querySelector('.discon').classList.remove('active');
            this.template.querySelector('.reCall').classList.remove('active');
            this.template.querySelector('.warrty').classList.remove('active');
            this.template.querySelector('.regulation').classList.remove('active');
        }
        if (this.productDetail === true) {
            this.template.querySelector('.calib').classList.remove('active');
            this.template.querySelector('.warrty').classList.remove('active');
        }
        if (this.software === true) {
            this.template.querySelector('.swLic').classList.remove('active');
            this.template.querySelector('.swUpt').classList.remove('active');
        }
        if (this.hardware === true) {
            this.template.querySelector('.firm').classList.remove('active');
            this.template.querySelector('.battery').classList.remove('active');
        }

        if(this.allServiceRequest === true){*/
        const btnSection = this.template.querySelector('.section-buttons');
        $('button', btnSection).removeClass('active').attr('aria-pressed', false);
        this.template.querySelector('.noti').classList.add('active');
        //}
    }

}