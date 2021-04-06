import { LightningElement, track, wire } from 'lwc';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import { CurrentPageReference } from 'lightning/navigation';
import { fireEvent, registerListener, unregisterAllListeners } from 'c/pubSub';
import YG_CustomerPortal from '@salesforce/resourceUrl/YG_CustomerPortal';
import getSubMenus from '@salesforce/apex/YG_SubMenuController.getSubMenus';
import getCommunityURL from '@salesforce/apex/YG_Utility.getCommunityURL';
import getUserRole from '@salesforce/apex/YG_LoggedUserRoleController.getNotifyUserRole';
import getManageColleaguesDetails from '@salesforce/apex/YG_ManageColleaguesController.getManageColleaguesGridDetails';
import notificationsLbl from '@salesforce/label/c.YG_Notification';
import allStationsLbl from '@salesforce/label/c.YG_All_Stations';
import allProductsLbl from '@salesforce/label/c.YG_All_Products';
import systemsLbl from '@salesforce/label/c.YG_Systems';
import allSystems from '@salesforce/label/c.YG_All_Systems';
import manageColleaguesLbl from '@salesforce/label/c.YG_Manage_Colleague';
import updProfileLbl from '@salesforce/label/c.YG_Update_Profile';
import updPasswordLbl from '@salesforce/label/c.YG_Update_Password';
import systemOverview from '@salesforce/label/c.YG_System_Overview';
import softwareLicense from '@salesforce/label/c.YG_Software_Licenses';

export default class YgSubMenu extends LightningElement {

    @wire(CurrentPageReference) pageRef;

    label = {
        notificationsLbl, allStationsLbl, allProductsLbl, systemOverview, softwareLicense,
        systemsLbl, allSystems, manageColleaguesLbl, updProfileLbl, updPasswordLbl
    };
    systems = false;
    products = false;
    managecolleagues = false;
    updateProfile = false;
    prodCategories = false;
    softwareLicenses = false;
    allProdURL; allProdNotiCount;
    subMenuList;
    error;
    projectCount = 0;
    totalCount = 0;
    systemURL;
    managecolleaguesURL;
    updateProfileURL;
    updatePasswordURL;
    softwareLicensesURL;
    indexVal;
    productCategory;
    pageName;
    productCount;
    allproductCount = 0; softwareLicenseCount = 0;
    selectedTxt = 'All Products';
    role = '';
    roleFlag = false;
    manageColleaguesPlantCount;
    manageColleaguesNotiFlag = true;
    manageColleaguesCount;
    updatePassword = false;
    disableFilter = false;
    systemId;
    isMobile = false;
    docSearch = false;
    certSearch = false;
    docURL;
    certURL;


    constructor() {
        super();

        Promise.all([
            loadStyle(this, YG_CustomerPortal + '/YG_CSS/custom.css'),
        ]);

        let pageURL = window.location.href.split('?')[0];
        this.allProdURL = pageURL;
        let pagePath = window.location.pathname;
        let pageName = pagePath.substr(3);
        this.pageName = pageName;

        let fullStr = window.location.search.substring(1);
        let splitStr = fullStr.split("&");
        let prodCat = '';
        for (var i = 0; i < splitStr.length; i++) {
            var pair = splitStr[i].split("=");
            if (pair[0] == 'type') {
                prodCat = pair[1];
                this.productCategory = decodeURIComponent(pair[1]).replace(/\+/g, " ");
            }
            if (pair[0] == 'index') {
                this.indexVal = pair[1];
            }
        }

        if (pageName === 'all-systems') {
            this.systems = true;
            this.disableFilter = true;
        }
        if (pageName === 'documents') {
            this.docSearch = true;
            this.disableFilter = true;
        }
        if (pageName === 'certificates') {
            this.certSearch = true;
            this.disableFilter = true;
        }
        if (pageName === 'all-products') {
            this.products = true;
            this.getAllProductSubMenu(); //all products page submenu list
        }

        if (pageName === 'software-licenses') {
            this.softwareLicenses = true;
            this.disableFilter = true;
        }

        if (pageName === 'manage-colleagues') {
            this.managecolleagues = true;
            this.disableFilter = true;
        }
        if (pageName === 'update-profile') {
            this.updateProfile = true;
            this.disableFilter = true;
        }
        if (pageName === 'update-password') {
            this.updatePassword = true;
            this.disableFilter = true;
        }

        this.loadExternalLibraries();

        getCommunityURL({})
            .then(result => {
                this.communityURL = result;
                window.console.log("communityURL::" + JSON.stringify(this.communityURL));
                this.systemURL = this.communityURL + 'all-systems';
                this.managecolleaguesURL = this.communityURL + 'manage-colleagues';
                this.updateProfileURL = this.communityURL + 'update-profile';
                this.updatePasswordURL = this.communityURL + 'update-password';
                this.softwareLicensesURL = this.communityURL + 'software-licenses';
                this.docURL = this.communityURL + 'documents';
                this.certURL = this.communityURL + 'certificates';
                fireEvent(this.pageRef, 'communityURL', this.communityURL);

            }).catch(error => {
                this.error = error;
            });

        //this method id used to verify the logged user Role
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
        });

        //this method is used to get the notification count of manage colleagues page
        getManageColleaguesDetails({ clgIdList: null })
            .then((result) => {
                this.manageColleaguesCount = result.totalcontact;
                this.manageColleaguesPlantCount = result.notificationCount;
                if (parseInt(result.notificationCount) === 0) {
                    this.manageColleaguesNotiFlag = false;
                }
            }).catch((error) => {
                this.isLoading = false;
                this.error = error.message;
            });

        const chkMobile = /iPad|iPhone|iPod|Android|webOS|BlackBerry|Windows Phone/.test(navigator.userAgent) && !window.MSStream;
        chkMobile ? this.isMobile = true : this.isMobile = false;

        if (navigator.userAgent.includes("Mac") && "ontouchend" in document) {
            this.isMobile = true;
        }
    }

    renderedCallback() {

        if (this.productCategory != undefined) {
            const firstActive = this.template.querySelector('.first-item.active');
            if (firstActive != null) {
                firstActive.classList.remove('active');
            }
        }
        /*
       if (this.softwareLicenses === true || this.systems === true) {
           const chkMobile = /iPad|iPhone|iPod|Android|webOS|BlackBerry|Windows Phone/.test(navigator.userAgent) && !window.MSStream;
           alert(chkMobile)
           chkMobile ? this.isMobile = true : this.isMobile = false;
           alert(this.isMobile)
 
           /*
            const plantElement = this.template.querySelector('.sub-menu-plant.plant-switch');
            if (window.getComputedStyle(plantElement).display === 'block') {
                this.isMobile = true;
            }*//*
}
*/
    }

    async loadExternalLibraries() {
        loadScript(this, YG_CustomerPortal + '/YG_JS/jquery.min.js').then(() => {
        });
    }

    connectedCallback() {
        registerListener('btnNotiCount', this.getBtnNotiCount, this);
        registerListener('manageColleaguesNotiCount', this.getmanageColleaguesNotiCount, this);
        registerListener('softwareLicenseCount', this.getsoftwareLicenseCount, this);
    }

    disconnectedCallback() {
        unregisterAllListeners(this);
    }


    getsoftwareLicenseCount(result) {
        this.softwareLicenseCount = result;
    }

    getAllProductSubMenu() {

        let fullPageURL;
        let productCat = this.productCategory;
        let pageURL = this.allProdURL;

        getSubMenus({})
            .then(result => {
                let temparr = [];
                let className;
                let count = 0;
                let getProdname = '';
                let sumCnt = 0;
                let current = '';
                result.forEach(function (list, index) {
                    count = list.totalNotiCount;
                    className = '';
                    fullPageURL = '';
                    current = '';
                    fullPageURL = pageURL + '?type=' + encodeURIComponent(list.label) + '&index=' + index;

                    if (productCat == list.label) {
                        className = "active";
                        current = "page";
                        getProdname = list.label;
                    }
                    sumCnt = list.catProdCount + sumCnt;
                    temparr.push({ label: list.label, activePage: current, class: className, totalCnt: list.catProdCount, noficationCount: list.noficationCount, pgeURL: fullPageURL });
                })
                this.allProdNotiCount = count;
                this.subMenuList = temparr;

                if (getProdname == '') {
                    this.productCount = sumCnt;
                } else {
                    this.selectedTxt = getProdname;
                }
                this.allproductCount = sumCnt;
                fireEvent(this.pageRef, 'subMenuLabel', this.subMenuList); //listener in ygButtonNotification component
            })
            .catch(error => {
                this.error = error;
            })

    }

    getBtnNotiCount(result) {
        this.totalCount = result.totalNot;
        this.productCount = result.productSize;
        console.log('allProdNoti::' + JSON.stringify(result));
    }

    //this method will fire when the plants get updated 
    getmanageColleaguesNotiCount(result) {
        this.manageColleaguesPlantCount = result.notificationCount;
        if (parseInt(result.notificationCount) === 0) {
            this.manageColleaguesNotiFlag = false;
        } else {
            this.manageColleaguesNotiFlag = true;
        }
    }

    toggleSubmenu() {
        //this.template.querySelector('.dropdown_menu').classList.toggle("active");
        const dropdown_menu = this.template.querySelector('.dropdown_menu');
        const dropdown_list = this.template.querySelector('.dropdown_list');
        $(dropdown_list).slideToggle('slow', function () {
            $(dropdown_menu).toggleClass('active', $(this).is(':visible'));
        });
    }

    toggleFilter() {

        //this.template.querySelector('.filter_main').classList.toggle("active");
        const filterMobile = this.template.querySelector('.filter_main');
        const filter_box = this.template.querySelector('.filter_box');
        const filter_toggle = this.template.querySelector('.filter_toggle');

        /*
        $(filter_box).slideToggle("slow");
        console.log($(filter_box).css('display'))
        setTimeout(() => {
            if($(filter_box).css('display') == 'none'){
                $(filterMobile).removeClass('active');
            }else{
                $(filterMobile).addClass('active');
            }
        }, 1000);
        
        */
        $(filter_box).slideToggle('slow', function () {
            //$(this).toggleClass('active');
            $(this).toggleClass('active', $(this).is(':visible'));
            $(filter_toggle).toggleClass('active', $(this).is(':visible'));
        });
    }

}