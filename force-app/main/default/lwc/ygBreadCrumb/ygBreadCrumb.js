import { LightningElement, track, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { fireEvent, registerListener, unregisterAllListeners } from 'c/pubSub';
import getProductDetails from '@salesforce/apex/YG_GridController.getProductDetails';
//import getProductInfo from '@salesforce/apex/YG_GridController.getProductInfo';
import getCommunityURL from '@salesforce/apex/YG_Utility.getCommunityURL';
import getUserRole from '@salesforce/apex/YG_LoggedUserRoleController.getNotifyUserRole';
import allStationsLbl from '@salesforce/label/c.YG_All_Stations';
import systemsLbl from '@salesforce/label/c.YG_Systems';
import allProductsLbl from '@salesforce/label/c.YG_All_Products';
import productsLbl from '@salesforce/label/c.YG_Products';
import YG_CustomerPortal from '@salesforce/resourceUrl/YG_CustomerPortal';
import oopsLbl from '@salesforce/label/c.YG_Oops';
import internalServerErrorLbl from '@salesforce/label/c.YG_Internal_Server_error_Please_try_after_sometime';
import homeLbl from '@salesforce/label/c.YG_Home';
import overviewLbl from '@salesforce/label/c.YG_Overview';
import allSystems from '@salesforce/label/c.YG_All_Systems';
import submitservReqInqLbl from '@salesforce/label/c.YG_Submit_Service_Request_and_Inquiry';
import thkyouLbl from '@salesforce/label/c.YG_Thank_you';
import manageColleaguesLbl from '@salesforce/label/c.YG_Manage_Colleague';
import updProfileLbl from '@salesforce/label/c.YG_Update_Profile';
import updPasswordLbl from '@salesforce/label/c.YG_Update_Password';
import attachfileLbl from '@salesforce/label/c.YG_Attach_an_accompanying_file';
import attachfileforLbl from '@salesforce/label/c.YG_Attach_an_accompanying_file_for';

export default class YgBreadCrumb extends LightningElement {

    @wire(CurrentPageReference) pageRef;

    label = {
        allStationsLbl, systemsLbl, allProductsLbl, productsLbl, oopsLbl,
        internalServerErrorLbl, homeLbl, overviewLbl, allSystems, submitservReqInqLbl,
        thkyouLbl, manageColleaguesLbl, updProfileLbl, updPasswordLbl, attachfileLbl, attachfileforLbl
    };
    logo = YG_CustomerPortal + '/YG_Images/yg_logo.png';
    communityURL;
    systems = false;
    products = false;
    productDetails = false;
    productHistory = false
    stationDetails = false;
    prodCategories = false;
    productCount;
    catName; allProdURL;
    statName; statLink;
    productName; productDetCount;
    serialnum; prodHisName; prodHisCat;
    prodDetailName; prodDetailsCount;
    level2; leve2URL; level1; //used in product details page
    modCode; prodHisLevel1URL; prodHisLevel2URL; topCategoryName; prodHisLevel3URL;//used in prodHis page
    isError = false;
    isModalOpen = false;
    errorUrl;
    overview = false;
    serviceRequest = false;
    allServiceRequest = false;
    productRegister = false;
    plant_Code = ''; offset = 0;
    allContracts = false;
    manageColleagues = false;
    updateProfile = false;
    updatePassword = false;
    softwareLicenses = false;
    allServiceReqCnt; softwareLicenseCount = 0;
    overviewURL;
    contractDetails = false;
    contractLink;
    manageColleaguesCount;
    role = '';
    roleFlag = false;
    allContractsCnt;
    contractNum;
    contractHead;
    overviewRequest = false;
    isMobile = false;
    docSearch;
    certSearch;



    constructor() {
        super();
        let pageURL = window.location.href.split('?')[0];
        this.allProdURL = pageURL;
        let pagePath = window.location.pathname;
        let pageName = pagePath.substr(3);

        let fullStr = window.location.search.substring(1);
        let splitStr = fullStr.split("&");
        let prodCat = '';
        let pltCode = '';
        let contractNo = ''
        for (var i = 0; i < splitStr.length; i++) {
            var pair = splitStr[i].split("=");
            if (pair[0] == 'type') {
                prodCat = decodeURIComponent(pair[1]);
            }
            if (pair[0] == 'pc') {
                pltCode = pair[1];
            }
            if (pair[0] == 'contractno') {
                contractNo = pair[1];
                this.contractNum = pair[1];
            }
        }

        getUserRole().then(result => {
            this.role = result.role;
            if ((this.role == 'Super Admin') || (this.role == 'Customer Admin')) {
                this.roleFlag = true;
            }
            else {
                this.roleFlag = false;
            }
        }).catch(error => {
            this.error = error;
            console.log('Error: ' + JSON.stringify(this.error));
        });

        getCommunityURL({})
            .then(result => {
                this.communityURL = result;
                //window.console.log("communityURL::"+JSON.stringify(this.communityURL));
                if (pageName === 'station-details') {
                    this.statLink = this.communityURL + 'all-systems?pc=' + pltCode;
                }
                if (pageName === 'contract-details') {
                    this.contractLink = this.communityURL + 'all-contracts?pc=' + pltCode;
                }

            })
            .catch(error => {
                this.error = error;
                console.log('prodInfoDataError: ' + JSON.stringify(this.error));
            });

        if (pageName === 'all-systems') {
            this.systems = true;
        }
        if (pageName === 'station-details') {
            this.stationDetails = true;
            this.statName = decodeURIComponent(prodCat).replace(/\+/g, " ");
        }
        if ((pageName === 'all-products' || pageName === '') && prodCat == '') {
            this.products = true;
        }
        if (pageName === 'all-products' && prodCat != '') {
            this.prodCategories = true;
            this.catName = decodeURIComponent(prodCat).replace(/\+/g, " ");
        }
        if (pageName === 'product-details') {
            this.productDetails = true;
        }
        if (pageName === 'product-history') {
            this.productHistory = true;
        }
        if (pageName === 'overview') {
            this.overview = true;
        }
        if (pageName === 'service-request-and-inquiries') {
            this.serviceRequest = true;
        }
        if (pageName === 'allservicerequest') {
            this.allServiceRequest = true;
        }
        if (pageName === 'thank-you') {
            this.thankYou = true;
        }
        if (pageName === 'product-registration') {
            this.productRegister = true;
        }
        if (pageName === 'all-contracts') {
            this.allContracts = true;
        }
        if (pageName === 'manage-colleagues') {
            this.manageColleagues = true;
        }
        if (pageName === 'contract-details') {
            this.contractDetails = true;
        }
        if (pageName === 'update-profile') {
            this.updateProfile = true;
        }
        if (pageName === 'update-password') {
            this.updatePassword = true;
        }
        if (pageName === 'software-licenses') {
            this.softwareLicenses = true;
        }
        if (pageName === 'documents') {
            this.docSearch = true;
        }
        if (pageName === 'certificates') {
            this.certSearch = true;
        }
        if (pageName === 'overview-request') {
            this.overviewRequest = true;
        }

        const chkMobile = /iPad|iPhone|iPod|Android|webOS|BlackBerry|Windows Phone/.test(navigator.userAgent) && !window.MSStream;
        chkMobile ? this.isMobile = true : this.isMobile = false;

        if (navigator.userAgent.includes("Mac") && "ontouchend" in document) {
            this.isMobile = true;
        }
    }

    renderedCallback() {

        if (this.overview === true ||
            this.productDetails === true ||
            this.productHistory === true ||
            this.stationDetails === true ||
            this.serviceRequest === true ||
            this.productRegister === true ||
            this.allServiceRequest === true ||
            this.thankYou === true ||
            this.allContracts === true ||
            this.contractDetails === true ||
            this.overviewRequest === true) {
            this.template.querySelector(".row").classList.add('mVisible');
        }

        /*
        if (this.allContracts === true) {
            const plantElement = this.template.querySelector('.section-head.plant-switch');
            if (window.getComputedStyle(plantElement).display === 'block') {
                this.isMobile = true;
            }
        }*/
    }

    connectedCallback() {
        registerListener('btnNotiCount', this.getProductSize, this);
        registerListener('prodDetBtnNotiCount', this.productName, this);
        registerListener('prodHisName', this.getProdHis, this);
        registerListener('level2BreadCrumb', this.getLevel2BreadCrumb, this);
        registerListener('serviceRequestCnt', this.getAllServiceRequestCnt, this);
        registerListener('totContactsCount', this.getManageColleaguesSize, this);
        registerListener('serviceRequestUploadTxt', this.updateServReqTxtChange, this);
        registerListener('serviceContractTotalCnt', this.getAllContractsCnt, this);
        registerListener('serviceContractDetails', this.getContractdetailPgHeader, this);
        registerListener('softwareLicenseCount', this.getsoftwareLicenseCount, this);
        registerListener('totProductCount', this.getproductCount, this);


    }

    disconnectedCallback() {
        unregisterAllListeners(this);

    }

    getproductCount(result) {
        this.prodDetailsCount = result;
    }

    getsoftwareLicenseCount(result) {
        this.softwareLicenseCount = result;
    }

    updateServReqTxtChange(param) {
        attachfileLbl, attachfileforLbl
        //alert(param)
        if (param != '') {
            this.template.querySelector(".serviceRequest").innerHTML = this.label.attachfileforLbl + ' (' + param + ')';

        } else {
            this.template.querySelector(".serviceRequest").innerHTML = this.label.attachfileLbl;
        }
    }

    getProductSize(result) {
        this.productCount = result.productSize;
    }

    getManageColleaguesSize(result) {
        this.manageColleaguesCount = result.totalcontact;
    }

    getAllContractsCnt(result) {
        this.allContractsCnt = result;
    }

    productName(result) {
        this.productName = result.productName;
    }

    getAllServiceRequestCnt(result) {
        //alert('totalServiceDetRecords::' + result);
        this.allServiceReqCnt = result;
        this.overviewURL = this.communityURL + 'overview';
    }

    getContractdetailPgHeader(contHeader) {
        //alert(contHeader);
        this.contractHead = contHeader;
    }

    getProdHis(result) {
        this.prodHisName = result.prodName;
        this.serialnum = result.serialNoCode;
        this.prodHisCat = result.prodCatName;
        this.modCode = result.modelCode;
        this.topCategoryName = result.topCatName;
        this.prodHisLevel1URL = this.communityURL + 'all-products';
        this.prodHisLevel2URL = this.prodHisLevel1URL + '&type=' + encodeURIComponent(this.topCategoryName);
        this.prodHisLevel3URL = this.communityURL + 'product-details?modcode=' + this.modCode /*+ '&pc=' + this.plant_Code*/;
        /*getProductInfo({ prodIdList: null, modelCode: this.modCode, loadLimit: 0, offset: 0 })
            .then(result => {
                fireEvent(this.pageRef, 'ProductSizeCnt', result.totalSerialNos);
            }).catch(error => {
                this.error = error.body.message;
            })*/
    }

    getLevel2BreadCrumb(result) {
        this.prodDetailName = result.productName;
        //this.prodDetailsCount = result.totalSerialNos;
        this.level1 = this.communityURL + 'all-products';
        this.level2 = result.topCategoryName;
        this.leve2URL = this.level1 + '?type=' + encodeURIComponent(this.level2);
        let prodSize;
        getProductDetails({ prodIdList: null, prodCat: this.level2, loadLimit: 0, offset: 0, csvSort: '' })
            .then(result => {
                console.log('result.prodDet::' + result.isError);
                console.log('getLevel2BreadCrumb:: ' + JSON.stringify(result));

                this.isError = result.isError;
                if (this.isError) {
                    // this.isModalOpen = true;
                    //window.location.href = this.communityURL + 'error';
                    //alert(this.communityURL + 'error');
                }
                prodSize = result.productSize;
                console.log('prodSize::' + prodSize);
                fireEvent(this.pageRef, 'ProductSizeCnt', prodSize);
            })
            .catch(error => {
                console.log('error.prodDet::' + JSON.stringify(error.status));
                /* if (error.status === 500) {
                     alert('url::' + this.communityURL + 'all-products');
                     this.isModalOpen = true;
                     this.errorUrl = this.communityURL + 'all-products';
                 }*/
                this.error = error;
                this.isLoading = false;
            })
    }
}