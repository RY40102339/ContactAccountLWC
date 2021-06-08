import { LightningElement, wire, track } from 'lwc';
import getCommunityURL from '@salesforce/apex/YG_Utility.getCommunityURL';
import getAccountLogo from '@salesforce/apex/YG_HeaderController.getAccountData';
//import toGetStationSize from '@salesforce/apex/YG_HelperClass.toGetStationSize';
import getTotalContractSize from '@salesforce/apex/YG_AllServiceContractsController.getTotalContractSize';
import getUserRole from '@salesforce/apex/YG_LoggedUserRoleController.getNotifyUserRole';
import { CurrentPageReference } from 'lightning/navigation';
import { fireEvent, registerListener, unregisterAllListeners } from 'c/pubSub';
import { loadScript } from "lightning/platformResourceLoader";
import YG_CustomerPortal from '@salesforce/resourceUrl/YG_CustomerPortal';
import viewAllLbl from '@salesforce/label/c.YG_View_all';
import viewAllStationsLbl from '@salesforce/label/c.YG_View_all_Stations';
import updProfileLbl from '@salesforce/label/c.YG_Update_Profile';
import manageColleaguesLbl from '@salesforce/label/c.YG_Manage_Colleague';

export default class YgHeader extends LightningElement {

    @wire(CurrentPageReference) pageRef;
    label = {
        viewAllLbl, viewAllStationsLbl, updProfileLbl, manageColleaguesLbl
    };

    shell = YG_CustomerPortal + '/YG_Images/shell.png';
    mLogo = YG_CustomerPortal + '/YG_Images/yg_logo.png';
    searchIcon = YG_CustomerPortal + '/YG_Images/icons/search.svg';
    profileLogo = YG_CustomerPortal + '/YG_Images/image-profile-default.svg';
    //profileLogo;
    backLink = false;
    prodHisPage = false;
    stationDetails = false;
    prodHisBackButton;
    error;
    @track communityURL;   //this variable is used to set the community url
    backButtonName; backButtonUrl;
    prodHisModelCode; backButtonUrlProdHis;
    size; prevLink;
    backButtonProdCnt
    @track proDetSize;
    productSize;
    plantInfoarray = [];
    firstPlantval;
    @track firstPlantName;
    plantNo = '';
    firstSelect = true;
    contractdetails = false;
    contractURL;
    allcontracts = false;
    allcontractsURL;
    profileUrl;
    managecolleaguesURL;
    productregURL;
    overview = true;
    contractTotalSize;
    @track hideSearch = true;
    @track roleFlag = false;
    shortName;
    name;
    email;
    contact;
    company;

    constructor() {

        super();
        let pagePath = window.location.pathname;
        let pageName = pagePath.substr(3);
        let plantInfo = [];
        let firstPlant;
        let firstPlantName;

        let fullStr = window.location.search.substring(1);
        let splitStr = fullStr.split("&");
        let pltCode = '';
        for (var i = 0; i < splitStr.length; i++) {
            var pair = splitStr[i].split("=");
            if (pair[0] == 'pc') {
                pltCode = pair[1];
                this.plantNo = pair[1];
            }
        }

        //this method id used to verify the logged user Role
        getUserRole().then(result => {
            this.role = result.role;
            this.shortName = result.fName.charAt(0) + '' + result.lName.charAt(0);
            this.name = result.fName + ' ' + result.lName;
            this.email = result.email;
            this.contact = result.phone;
            this.company = result.company;
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

        getTotalContractSize({ plantCode: this.plantNo })
            .then(result => {
                console.log('this.result getTotalContractSize: ' + JSON.stringify(result));
                this.contractTotalSize = result;
            }).catch(error => {
                this.error = error;
                console.log('serviceMenuGridDataError: ' + JSON.stringify(this.error));
            });

        getCommunityURL({})
            .then(result => {
                this.communityURL = result;
                if (pageName === 'station-details') {
                    this.prevLink = this.communityURL + 'all-systems?pc=' + pltCode;
                }
                if (pageName === 'contract-details') {
                    this.contractURL = this.communityURL + 'all-contracts?pc=' + pltCode;
                }
                if (pageName === 'all-contracts') {
                    this.allcontractsURL = this.communityURL + 'overview?pc=' + pltCode;
                }
                this.profileUrl = this.communityURL + 'update-profile';
                this.managecolleaguesURL = this.communityURL + 'manage-colleagues';
                this.productregURL = this.communityURL + 'product-registration';

            }).catch(error => {
                this.error = error;
                console.log('prodInfoDataError: ' + JSON.stringify(this.error));
            });
        /*if (pageName === 'station-details') {
            toGetStationSize({ plantCode: this.plantNo })
                .then(result => {
                    console.log('Stationsizeresult::' + JSON.stringify(result));
                    this.size = result;
                    console.log('Stationsizeresult::' + JSON.stringify(this.size));
                }).catch(error => {
                    this.error = error.body.message;
                    console.log('error:: ' + JSON.stringify(this.error));
                })
        }*/
        getAccountLogo()
            .then(result => {
                if (result != null) {
                    this.profileLogo = result.Account_Logo__c;
                } else {
                    this.profileLogo = YG_CustomerPortal + '/YG_Images/image-profile-default.svg';
                }

                console.log('accountLogoResult: ' + JSON.stringify(this.profileLogo));
            })
            .catch(error => {
                this.error = error;
                console.log('accountLogoError: ' + JSON.stringify(this.error.status));
            });
        this.loadExternalLibraries();
    }

    async loadExternalLibraries() {
        loadScript(this, YG_CustomerPortal + '/YG_JS/jquery.min.js').then(() => {

            let profileInfo = this.template.querySelector(".profile-info");
            profileInfo = $(profileInfo);
            //let plantDD = this.template.querySelector(".plant-dd");
            //plantDD = $(plantDD);

            $("body").on("click", function () {
                $('.dd-userinfo', profileInfo).removeClass("show").hide();
                //$('.plant-dropdown-menu', plantDD).removeClass("show");
                //$('.plant-dd-toggle', plantDD).removeClass("active");                
            });
            /*
            plantDD.on("click", function (event) {
                event.stopPropagation();
            });
            */
            profileInfo.on("click", function (event) {
                event.stopPropagation();
            });

            let scrollTop = this.template.querySelector(".scroll-to-top");
            // Scroll to top button appear
            $(document).on('scroll', function () {
                //alert('scroll')
                var scrollDistance = $(this).scrollTop();
                if (scrollDistance > 100) {
                    $(scrollTop).fadeIn();
                } else {
                    $(scrollTop).fadeOut();
                }
            });

            // Smooth scrolling using jQuery easing
            $(scrollTop).on('click', function (e) {
                var $anchor = $(this);
                $('html, body').animate({
                    scrollTop: 0
                }, 'slow');
                e.preventDefault();
            });
        });
    }

    renderedCallback() {

        //do something
        let pageURL = window.location.href.split('?')[0];
        let pagePath = window.location.pathname;
        let pageName = pagePath.substr(3);
        let plantName, firstPltCode = this.firstPlantval;


        let fullStr = window.location.search.substring(1);
        let splitStr = fullStr.split("&");
        let prodCat = '';
        let pltCode = '';
        for (var i = 0; i < splitStr.length; i++) {
            var pair = splitStr[i].split("=");
            if (pair[0] == 'size') {
                prodCat = pair[1];
            }
            if (pair[0] == 'pc') {
                pltCode = pair[1];
                this.plantNo = pair[1];
            }
        }

        if (pageName === 'product-details') {
            this.backLink = true;
            this.proDetSize = prodCat;
            this.template.querySelector('.row').classList.add('innerHeader');
        }
        if (pageName === 'product-history') {
            this.prodHisPage = true;
            this.proDetSize = prodCat;
            this.template.querySelector('.row').classList.add('innerHeader');
        }

        if (pageName === 'contract-details') {
            this.contractdetails = true;
            this.template.querySelector('.row').classList.add('innerHeader');
        }
        if (pageName === 'all-contracts') {
            this.allcontracts = true;
            this.template.querySelector('.row').classList.add('innerHeader');
        }
        if (pageName === 'station-details') {
            this.stationDetails = true;
            //this.size = prodCat;
            this.template.querySelector('.row').classList.add('innerHeader');
        }

        if (pageName == 'overview' ||
            pageName == 'service-request-and-inquiries' ||
            pageName == 'allservicerequest' ||
            pageName == 'thank-you' ||
            pageName == 'product-registration') {
            this.template.querySelector('.row').classList.add('innerHeader');
        }

        /*
        if (pageName != 'overview' && pageName != 'software-licenses') {
            //fireEvent(this.pageRef, 'plantFilter', '');
        }*/
    }

    connectedCallback() {
        registerListener('prodHisBackButton', this.getProdHisCat, this);
        registerListener('prodDetailHead', this.getProdDetailsHead, this);
        registerListener('hideMenu', this.doHideSearch, this);
        registerListener('updateProfile', this.getProfileDetails, this);
    }

    disconnectedCallback() {
        unregisterAllListeners(this);
    }

    getProfileDetails(result) {

        getUserRole().then(result => {
            this.role = result.role;
            this.shortName = result.fName.charAt(0) + '' + result.lName.charAt(0);
            this.name = result.fName + ' ' + result.lName;
            this.email = result.email;
            this.contact = result.phone;
            this.company = result.company;
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
    }

    getProdHisCat(result) {
        this.prodHisBackButton = result.prodCatName;
        this.prodHisModelCode = result.modelCode;
        this.backButtonUrlProdHis = this.communityURL + 'product-details?modcode=' + this.prodHisModelCode;
        this.backButtonProdCnt = result.prodCount;
    }

    doHideSearch(flag) {
        if (flag == 'yes') {
            this.hideSearch = true;
        }
    }

    getProdDetailsHead(result) {
        this.backButtonName = result.topCategoryName;
        this.backButtonUrl = this.communityURL + 'all-products?type=' + encodeURIComponent(this.backButtonName);
        this.productSize = result.productIdCount;
    }

    showDropdown(event) {
        const dd_userInfo = this.template.querySelector('.dd-userinfo');
        $(dd_userInfo).slideToggle('slow', function () {
            $(dd_userInfo).toggleClass('show', $(this).is(':visible'));
        });
    }

    hideMenu() {
        document.getElementsByTagName("BODY")[0].classList.remove('menu_active');
    }

    toggleSearch() {
        this.template.querySelector('.searchDropdown').classList.toggle("show");
    }

    removeclass() {
        fireEvent(this.pageRef, 'removeClass', 'remove');
    }

}