import { LightningElement, wire, track } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { fireEvent, registerListener, unregisterAllListeners } from 'c/pubSub';
import YG_CustomerPortal from '@salesforce/resourceUrl/YG_CustomerPortal';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import getCommunityURL from '@salesforce/apex/YG_Utility.getCommunityURL';
import overviewLbl from '@salesforce/label/c.YG_Overview';
import systemsLbl from '@salesforce/label/c.YG_Systems';
import productsLbl from '@salesforce/label/c.YG_Products';
import servReqInqLbl from '@salesforce/label/c.YG_Service_Request_and_Inquiries';
import getMenuInfo from '@salesforce/apex/YG_CommonController.getMenuInfo';


export default class YgMenu extends LightningElement {

    @wire(CurrentPageReference) pageRef;
    label = {
        overviewLbl, systemsLbl, productsLbl, servReqInqLbl
    };
    overview = false;
    systems = false;
    products = false;
    productDetails = false;
    error;
    communityURL;
    overviewURL;
    systemURL;
    productURL;
    serviceURL;
    contractUrl;
    @track isLoading = true;
    maintenancePhase = false;
    dcSearch = false;
    serviceRequest = false;
    contracts = false;
    selfRegflag = true;
    prodflag = true;

    logo = YG_CustomerPortal + '/YG_Images/yg_logo.png';
    overviewActive = YG_CustomerPortal + '/YG_Images/menu/overview-active.svg';
    overviewInactive = YG_CustomerPortal + '/YG_Images/menu/overview-inactive.svg';
    systemActive = YG_CustomerPortal + '/YG_Images/menu/systems-active.svg';
    systemInactive = YG_CustomerPortal + '/YG_Images/menu/systems-inactive.svg';
    productActive = YG_CustomerPortal + '/YG_Images/menu/products-active.svg';
    productInactive = YG_CustomerPortal + '/YG_Images/menu/products-inactive.svg';
    contractActive = YG_CustomerPortal + '/YG_Images/menu/contracts-active.svg';
    contractInactive = YG_CustomerPortal + '/YG_Images/menu/contracts-inactive.svg';
    dcActive = YG_CustomerPortal + '/YG_Images/menu/dc-active.svg';
    dcInactive = YG_CustomerPortal + '/YG_Images/menu/dc-inactive.svg';
    serviceActive = YG_CustomerPortal + '/YG_Images/menu/service-enq-active.svg';
    serviceInactive = YG_CustomerPortal + '/YG_Images/menu/service-enq-inactive.svg';

    constructor() {
        super();
        this.isLoading = true;

        let pagePath = window.location.pathname;
        let pageName = pagePath.substr(3);
        if (pageName === 'overview' || pageName === 'allservicerequest' || pageName === 'overview-request') {
            this.overview = true;
        }
        if (pageName === 'all-systems' || pageName === 'station-details' || pageName === 'software-licenses') {
            this.systems = true;
        }
        if (pageName === 'all-products' || pageName === 'product-details') {
            this.products = true;
        }
        if (pageName === 'all-contracts' || pageName === 'contract-details') {
            this.contracts = true;
        }
        if (pageName === 'service-request-and-inquiries' || pageName === 'thank-you') {
            this.serviceRequest = true;
        }
        if (pageName === 'documents' || pageName === 'certificates') {
            this.dcSearch = true;
        }

        getCommunityURL({})
            .then(result => {
                this.communityURL = result;
                this.overviewURL = this.communityURL + 'overview';
                this.systemURL = this.communityURL + 'all-systems';
                this.productURL = this.communityURL + 'all-products';
                this.dcURL = this.communityURL + 'documents';
                this.serviceURL = this.communityURL + 'service-request-and-inquiries';
                this.contractUrl = this.communityURL + 'all-contracts';

            }).then(() => {
                let query = this.getQueryParams(document.location.search);
                let pages = ["product-registration", "documents", "certificates", "service-request-and-inquiries", "update-profile", "update-password", "manage-colleagues", "thank-you", "allservicerequest"];
                //let qs = parse_query_string(query);
                if (query.redirect != 'no') {
                    getMenuInfo({})
                        .then(result => {

                            console.log('getMenuInfo: ' + JSON.stringify(result));

                            if (result.systemCount == 0 && result.productCount == 0) {
                                if (pages.includes(pageName) === false) {
                                    window.location.href = this.communityURL + "overview-request?redirect=no";
                                }
                            }

                            if (result.systemCount == 0 && result.selfRegUser === false) {
                                if ((pageName === 'all-systems') || (pageName === 'overview')) {
                                    window.location.href = this.communityURL + "overview-request?redirect=no";
                                }
                            }

                            if (result.productCount == 0 && result.selfRegUser === false) {
                                if (pageName === 'all-products') {
                                    window.location.href = this.communityURL + "overview-request?redirect=no";
                                }
                            }

                            if (result.productCount == 0 && result.selfRegUser === true) {
                                if (pages.includes(pageName) === false) {
                                    window.location.href = this.communityURL + "overview-request?redirect=no";
                                }
                            }

                        })
                        .catch(error => {
                            this.error = error;
                            console.log('accountLogoError: ' + JSON.stringify(this.error.status));
                        });
                }
            }).then(() => {
                this.getMenuLoad();
            })
            .catch(error => {
                this.error = error;
                console.log('prodInfoDataError: ' + JSON.stringify(this.error));
            });
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


    connectedCallback() {

        Promise.all([
            loadStyle(this, YG_CustomerPortal + '/YG_CSS/common.css'),
            loadStyle(this, YG_CustomerPortal + '/YG_CSS/fa.min.css'),
            loadStyle(this, YG_CustomerPortal + '/YG_CSS/style.css'),
            loadScript(this, YG_CustomerPortal + '/YG_JS/jquery.min.js'),
            //loadScript(this, YG_JS + '/bootstrap.bundle.min.js'),
        ]).then(() => {
            let navInfo = this.template.querySelector(".navbar-nav");
            $('.nav-item[data-img-active]', navInfo).on("mouseover", function () {
                $(this).find('img').attr('src', $(this).attr('data-img-active'));
                $(this).find('span').removeClass('opacity-30').addClass('opacity-90');
            });
            $('.nav-item[data-img-active]', navInfo).on("mouseleave", function () {
                $(this).find('img').attr('src', $(this).attr('data-img-inactive'));
                $(this).find('span').removeClass('opacity-90').addClass('opacity-30');
            });
        }).then(() => {
            this.isLoading = true;
        })
    }

    disconnectedCallback() {
        unregisterAllListeners(this);
    }

    getMenuLoad() {
        getMenuInfo({})
            .then((res) => {

                /*
                if (res.systemCount == 0) {
                    this.selfRegflag = false;
                    console.log('gethideSystem**');
                }*/

                if (res.selfRegUser === false && res.systemCount == 0) {
                    this.selfRegflag = false;
                }

                if (res.selfRegUser === true) {
                    this.selfRegflag = false;
                }

                if (res.productCount == 0) {
                    this.prodflag = false;
                    console.log('gethideProduct**');
                }

                if (res.selfRegUser === true && res.productCount > 0) {
                    fireEvent(this.pageRef, 'selfRegister', true);
                }

            }).then(() => {
                setTimeout(() => {
                    this.isLoading = false;
                }, 500);
            }).catch((error) => {
                this.isLoading = false;
                this.error = error.message;
            });
    }

    showMenu(event) {

        this.template.querySelector('.overlay').classList.add('d-block');
        this.template.querySelector('.accordionSidebar').classList.remove('d-none');
        this.template.querySelector('.accordionSidebar').classList.add('animated--fade-in');
        document.getElementsByTagName("BODY")[0].classList.add('menu_active');
    }
}