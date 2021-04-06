import { LightningElement, wire, track } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { fireEvent, registerListener, unregisterAllListeners } from 'c/pubSub';
import getCommunityURL from '@salesforce/apex/YG_Utility.getCommunityURL';
import getMenuInfo from '@salesforce/apex/YG_CommonController.getMenuInfo';
import getPlantRequests from '@salesforce/apex/YG_ManageColleaguesController.getPlantRequest';
import getPlants from '@salesforce/apex/YG_PlantAPIController.callPlantAPI';
import getSelectedUserDetails from '@salesforce/apex/YG_ManageColleaguesController.getSelectedUserDetail';
import { loadScript } from 'lightning/platformResourceLoader';
import YG_CustomerPortal from '@salesforce/resourceUrl/YG_CustomerPortal';
import requestAccessLbl from '@salesforce/label/c.YG_Request_Access_to_Sites';
import updateProfileMsg2Lbl from '@salesforce/label/c.YG_Update_Profile_Msg2';
import submitRequestLbl from '@salesforce/label/c.YG_Submit_request';
import updateProfileMsg3Lbl from '@salesforce/label/c.YG_Update_Profile_Msg3';
import updateProfileMsg4Lbl from '@salesforce/label/c.YG_Update_Profile_Msg4';
import closeLbl from '@salesforce/label/c.YG_Close';

export default class YgOverviewRequest extends LightningElement {

    @wire(CurrentPageReference) pageRef;
    @track isModalOpen = false;
    @track isLoading = true;
    isReqToSitesModalOpen = false;
    reqAddSiteModalOpen = false;
    plantRequest = false;
    productRequest = false;
    plantList = [];
    requestPlantResult = [];
    communityURL;
    overviewURL;
    label = {
        requestAccessLbl, updateProfileMsg2Lbl, submitRequestLbl, updateProfileMsg3Lbl, updateProfileMsg4Lbl, closeLbl
    };

    constructor() {
        super();
        this.isLoading = true;
        getCommunityURL({})
            .then(result => {
                this.communityURL = result;
                this.overviewURL = this.communityURL + 'overview';

            }).then(() => {
                getMenuInfo({})
                    .then(result => {
                        console.log('Result*** ' + JSON.stringify(result));
                        fireEvent(this.pageRef, 'hideNotify', result);

                    }).then(() => {
                        fireEvent(this.pageRef, 'hideMenu', 'yes');
                    })
                    .catch(error => {
                        this.error = error;
                        console.log('accountLogoError: ' + JSON.stringify(this.error.status));
                    });

            }).then(() => {
                this.isLoading = false;
            }).catch(error => {
                this.error = error;
                console.log('prodInfoDataError: ' + JSON.stringify(this.error));
            });
    }

    renderedCallback() {
        if (this.isReqToSitesModalOpen === true) {
            this.template.querySelector('.loading-icon').classList.remove('d-none');
        }
    }
    connectedCallback() {
        registerListener('requestPlant', this.requestPlant, this);
    }

    disconnectedCallback() {
        unregisterAllListeners(this);
    }

    requestPlant() {

        this.isModalOpen = true;
        this.isReqToSitesModalOpen = true;
        this.reqAddSiteModalOpen = false;


        getPlants({}).then(result => {
            console.log(JSON.stringify(result))
            this.plantList = result.plantList;
        }).then(() => {
            getSelectedUserDetails({ conId: null }).then(result => {
                console.log('result:: ' + JSON.stringify(result));
                console.log('result:: ' + JSON.stringify(result.popupplantLists));
                const plantElement = this.template.querySelector('.plant-list');

                result.popupplantLists[0].plantcodes.forEach(function (list) {
                    $("input[data-plant-id=" + list + "]", plantElement).prop("disabled", true);
                    $("input[data-plant-id=" + list + "]", plantElement).parent().find("label").removeClass('grey-darkest').addClass('grey-medium-c').find('span').append(' (requested)');
                });
            }).catch(error => {
                this.error = error;
                console.log('error:: ' + JSON.stringify(this.error));
            })
        }).then(() => {
            this.template.querySelector('.loading-icon').classList.add('d-none');
            //this.template.querySelector('button').classList.remove('d-none');
        }).catch(error => {
            this.error = error;
            console.log('error:: ' + JSON.stringify(this.error));
        })


    }

    submitRequest() {

        this.isReqToSitesModalOpen = false;
        this.reqAddSiteModalOpen = true;

        const plantElement = this.template.querySelector('.plant-list');
        let plantCode = [], plantName = [];

        $('input[name="plantName"]:checked', plantElement).each(function () {
            plantCode.push($(this).val());
            plantName.push(' ' + $(this).attr('data-plant'));
        });
        console.log('plantNameArr' + JSON.stringify(plantName));
        console.log('plantCode' + JSON.stringify(plantCode));

        this.requestPlantResult = plantName;

        //alert(plantCode);

        getPlantRequests({ plantIDList: plantCode }).then(() => {
        }).catch(error => {
            this.error = error;
            console.log('error:: ' + JSON.stringify(this.error));
        })

    }

    validateChk(event) {

        const checkBox = this.template.querySelector('.plant-list');
        const subBtn = this.template.querySelector('.btn-primary');
        let numberOfChecked = $('input[name="plantName"]:checked', checkBox).length;

        if (numberOfChecked > 0) {
            $(subBtn).prop('disabled', false);
        } else {
            $(subBtn).prop('disabled', true);
        }
    }

    closeModal() {
        this.plantList = [];
        this.isModalOpen = false;
        this.isReqToSitesModalOpen = false;
        this.reqAddSiteModalOpen = false;
    }
}