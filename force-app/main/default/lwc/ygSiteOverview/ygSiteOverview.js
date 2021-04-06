import { LightningElement, track, wire } from 'lwc';
import getOverviewPlantDetails from '@salesforce/apex/YG_OverviewPlantDetails.getOverviewPlantDetails';
import { loadScript, loadStyle } from "lightning/platformResourceLoader";
import YG_CustomerPortal from "@salesforce/resourceUrl/YG_CustomerPortal";
import { CurrentPageReference } from 'lightning/navigation';
import { fireEvent, registerListener, unregisterAllListeners } from 'c/pubSub';
import siteName from '@salesforce/label/c.YG_Site_name';
import siteNumber from '@salesforce/label/c.YG_Site_number';
import endUser from '@salesforce/label/c.YG_End_user';
import shortName from '@salesforce/label/c.YG_Short_name';
import country from '@salesforce/label/c.YG_Country';
import location from '@salesforce/label/c.YG_Site_location';
import phone from '@salesforce/label/c.YG_Telephone_number';
import fax from '@salesforce/label/c.YG_Fax_number';


export default class YgSiteOverview extends LightningElement {
    @wire(CurrentPageReference) pageRef;
    @track isLoading = false;
    @track isModalOpen = false;
    @track hideLink = false;
    plant_Code = '';
    name;
    sitenumber;
    accname;
    shortname;
    country;
    location;
    phone;
    fax;
    displaySiteInfo = false;
    label = { siteName, siteNumber, endUser, shortName, country, location, phone, fax };

    constructor() {
        super();
        // this.getFilteredOverviewPlant(this.plant_Code);
    }

    connectedCallback() {
        registerListener("plantFilter", this.getFilteredOverviewPlant, this);
        registerListener('selfRegister', this.checkSelfReg, this);
    }

    disconnectedCallback() {
        unregisterAllListeners(this);
    }

    checkSelfReg(param) {

        if (param === true) {
            this.template.querySelector(".row").classList.add('d-none');
        }
    }

    getFilteredOverviewPlant(plantCode) {
        this.plant_Code = plantCode;

        getOverviewPlantDetails({ plantCode: this.plant_Code })
            .then((result) => {
                this.name = result.name || '-';
                this.sitenumber = result.sitenumber || '-';
                this.accname = result.accname || '-';
                this.shortname = result.shortname || '-';
                this.country = result.country || '-';
                this.location = result.location || '-';
                this.phone = result.phone || '-';
                this.fax = result.fax || '-';
                console.log('siteData: ' + JSON.stringify(this.name));

            }).catch((error) => {
                this.isLoading = false;
                this.error = error.message;
            });
    }
    toggleSiteInfo() {
        this.displaySiteInfo = !this.displaySiteInfo;
        const site_info_box = this.template.querySelector('.site_info_box');
        $(site_info_box).slideToggle('slow', function () {
            $(this).toggleClass('active', $(this).is(':visible'));
        });
        fireEvent(this.pageRef, 'setAutoHeight', this.displaySiteInfo);
    }
}