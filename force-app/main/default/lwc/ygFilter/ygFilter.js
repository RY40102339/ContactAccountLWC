import { LightningElement, wire, track } from 'lwc';
import YG_CustomerPortal from '@salesforce/resourceUrl/YG_CustomerPortal';
import { CurrentPageReference } from 'lightning/navigation';
import { registerListener, unregisterAllListeners } from 'c/pubSub';
import getUserRole from '@salesforce/apex/YG_LoggedUserRoleController.getNotifyUserRole';
import inviteColleaguesLbl from '@salesforce/label/c.YG_Invite_Colleagues';
import inviteColleaguesUrlLbl from '@salesforce/label/c.YG_Invite_colleague_URL';

export default class YgFilter extends LightningElement {
    @wire(CurrentPageReference) pageRef;

    label = { inviteColleaguesLbl, inviteColleaguesUrlLbl };

    products = false;
    productDetail = false;
    systems = false;
    prodCategory = false;
    stationDetails = false;
    pgeName;
    placeholder;
    prodCatName; statName; modelCode;
    systemId = '';
    filterIcon = YG_CustomerPortal + '/YG_Images/icons/filter.svg';
    allServiceRequest = false;
    allContracts = false;
    manageColleagues = false;
    softwareLicenses = false;
    role = '';
    roleFlag = false;

    constructor() {
        super();
        let pageURL = window.location.href;
        let pagePath = window.location.pathname;
        let pageName = pagePath.substr(3);
        console.log('pageName::' + pageName);

        let fullStr = window.location.search.substring(1);
        let splitStr = fullStr.split("&");
        let prodCat = '', sysid = '';
        for (var i = 0; i < splitStr.length; i++) {
            var pair = splitStr[i].split("=");
            if (pair[0] == 'type') {
                prodCat = decodeURIComponent(pair[1]);
            }
            if (pair[0] == 'modcode') {
                prodCat = pair[1];
            }
            if (pair[0] == 'modelCode') {
                prodCat = pair[1];
            }
            if (pair[0] == 'sysid') {
                sysid = pair[1];
            }
        }
        console.log('prodCat::' + prodCat);

        if (pageName === 'all-products' && prodCat === '') {
            this.products = true;
            this.pgeName = pageName;
            this.placeholder = 'Filter by product category/name/model';
        }
        if (pageName === 'all-products' && prodCat != '') {
            this.prodCategory = true;
            this.pgeName = pageName;
            this.placeholder = 'Filter by product category/name/model';
            this.prodCatName = prodCat;
        }
        if (pageName === 'product-details') {
            this.productDetail = true;
            this.pgeName = pageName;
            this.placeholder = 'Filter by MS code or serial number';
            this.modelCode = prodCat;
        }
        if (pageName === 'all-systems') {
            this.systems = true;
            this.pgeName = pageName;
            this.placeholder = 'Filter by station or module name';
        }
        if (pageName === 'station-details') {
            this.stationDetails = true;
            this.pgeName = pageName;
            this.placeholder = 'Filter by serial number';
            this.statName = prodCat;
            this.systemId = sysid;
        }
        if (pageName === 'allservicerequest') {
            this.allServiceRequest = true;
            this.pgeName = pageName;
            this.placeholder = 'Filter by service type or product name';
        }
        if (pageName === 'all-contracts') {
            this.allContracts = true;
            this.pgeName = pageName;
            this.placeholder = 'Filter by Contract No. or Contract Name';
        }
        if (pageName === 'manage-colleagues') {
            this.manageColleagues = true;
            this.pgeName = pageName;
            this.placeholder = 'Filter by name';
        }
        if (pageName === 'software-licenses') {
            this.softwareLicenses = true;
            this.pgeName = pageName;
            this.placeholder = 'Filter by name';
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

    }

    renderedCallback() {

        if (
            this.stationDetails === true || this.manageColleagues === true ||
            this.systems === true || this.softwareLicenses === true || this.productDetail === true) {
            this.template.querySelector(".row").classList.add('mVisible', 'm-pt-56');
        }
    }
    inviteYourColleagues(){
        let url = this.label.inviteColleaguesUrlLbl;
        window.open(url, '_blank');
    }
}