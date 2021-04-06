import { LightningElement, wire, track } from 'lwc';
import { loadScript, loadStyle } from "lightning/platformResourceLoader";
import YG_CustomerPortal from "@salesforce/resourceUrl/YG_CustomerPortal";
import { CurrentPageReference } from 'lightning/navigation';
import { fireEvent, registerListener, unregisterAllListeners } from 'c/pubSub';
import getCommunityURL from '@salesforce/apex/YG_Utility.getCommunityURL';
import getManageColleaguesDetails from '@salesforce/apex/YG_ManageColleaguesController.getManageColleaguesGridDetails';
import getSelectedUserDetails from '@salesforce/apex/YG_ManageColleaguesController.getSelectedUserDetail';
import getPlantRequests from '@salesforce/apex/YG_ManageColleaguesController.getPlantRequest';
import getUserRole from '@salesforce/apex/YG_LoggedUserRoleController.getNotifyUserRole';
import getUserDeactives from '@salesforce/apex/YG_ManageColleaguesController.getUserDeactive';
import companyandsitesLbl from '@salesforce/label/c.YG_Company_and_sites_information';
import companyLbl from '@salesforce/label/c.YG_Company';
import sitesLbl from '@salesforce/label/c.YG_Sites';
import updateProfileMsg1Lbl from '@salesforce/label/c.YG_Update_Profile_Msg1';
import requestAccessLbl from '@salesforce/label/c.YG_Request_Access_to_Sites';
import updateProfileMsg2Lbl from '@salesforce/label/c.YG_Update_Profile_Msg2';
import submitRequestLbl from '@salesforce/label/c.YG_Submit_request';
import updateProfileMsg3Lbl from '@salesforce/label/c.YG_Update_Profile_Msg3';
import updateProfileMsg4Lbl from '@salesforce/label/c.YG_Update_Profile_Msg4';
import closeLbl from '@salesforce/label/c.YG_Close';
import emailToLbl from '@salesforce/label/c.YG_Email_To_Address';
import are_you_sure_to_deactivateLbl from '@salesforce/label/c.YG_are_you_sure_to_deactivate_acc';
import account_is_deactivated_immediatelyLbl from '@salesforce/label/c.YG_account_is_deactivated_immediately';
import confirmLbl from '@salesforce/label/c.YG_Confirm';
import cancelbl from '@salesforce/label/c.YG_Cancel';
import deactivateLbl from '@salesforce/label/c.YG_Manage_Colleague_popup_msg3';
import request_YOK_to_transer_accLbl from '@salesforce/label/c.YG_Request_YOK_to_transer_acc';
import you_have_toLbl from '@salesforce/label/c.YG_You_have_to';
import assign_admin_rightsLbl from '@salesforce/label/c.YG_assign_admin_rights';
import another_user_before_you_can_deactivate_your_accLbl from '@salesforce/label/c.YG_another_user_before_you_can_deactivate_your_acc';
import company_infoLbl from '@salesforce/label/c.YG_Company_Info';



let selectedPlantList = [];
export default class YgUpdateProfileSites extends LightningElement {
    @wire(CurrentPageReference) pageRef;
    @track isModalOpen = false; @track isDeactivateModalOpen = false;
    @track communityURL;   //this variable is used to set the community url
    @track selfAcc = false;
    isReqToSitesModalOpen = false;
    reqAddSiteModalOpen = false;
    chkbId = 0;
    userAccountName = '';
    userApprovedSites = [];
    approvedSitesList = [];
    requestPlantResult = [];
    roleFlagCust = false;
    roleFlagCA = false;
    roleFlagCACount = false;
    roleFlagSA = false;
    deactive = false;
    managecolleaguesURL;
    deactiveBtnClass = "btn bg-white blue-primary btn-primary text-uppercase f12 noto-font ft-weight-900 disabled pointer-events-visible";

    label = {
        companyandsitesLbl, companyLbl, sitesLbl, updateProfileMsg1Lbl, requestAccessLbl, updateProfileMsg2Lbl,
        submitRequestLbl, updateProfileMsg3Lbl, updateProfileMsg4Lbl, closeLbl, emailToLbl, are_you_sure_to_deactivateLbl,
        account_is_deactivated_immediatelyLbl, confirmLbl, cancelbl, deactivateLbl, request_YOK_to_transer_accLbl,
        you_have_toLbl, assign_admin_rightsLbl, another_user_before_you_can_deactivate_your_accLbl, company_infoLbl
    };

    constructor() {
        super();
        getUserRole().then(result => {
            if (result.role == 'Customer Admin') {
                //[Deactivate Acc]Button is used to display only if only one admin in an account 
                this.roleFlagCA = true;
                if (result.roleCount == 1) {
                    this.roleFlagCACount = true;
                    this.deactiveBtnClass = "btn bg-white blue-primary btn-primary text-uppercase f12 noto-font ft-weight-900 disabled";
                }

            } else if (result.role == 'Super Admin') {
                //[Request YOK to transefer Acc]Button is used to display only for a super admin
                this.roleFlagSA = true;
            } else {
                //[Request Site Access]Button is used to display only for a Customers
                this.roleFlagCust = true;
            }

            if (result.selfAcc === true) {
                this.selfAcc = true;
                this.roleFlagCust = false;
            }

        }).catch(error => {
            this.error = error;
            console.log('Error: ' + JSON.stringify(this.error));
        });
        getCommunityURL({})
            .then(result => {
                this.communityURL = result;
                this.managecolleaguesURL = this.communityURL + 'manage-colleagues';
            }).catch(error => {
                this.error = error;
                console.log('prodInfoDataError: ' + JSON.stringify(this.error));
            });
        getSelectedUserDetails({ conId: null }).then(result => {
            let temparr = [];
            this.userAccountName = result.accountName;
            this.userApprovedSites = result.approvedSites;

            result.approvedSites['ApprovedSite'].forEach(function (item) {
                temparr.push({
                    Sites: item
                });
            });
            this.approvedSitesList = temparr;
            console.log("approvedSitesList  ::: " + JSON.stringify(this.approvedSitesList));
            console.log('userAccountName: ' + JSON.stringify(this.userAccountName));
            console.log('userApprovedSites: ' + JSON.stringify(this.userApprovedSites));
        }).catch(error => {
            this.error = error;
            console.log('error:: ' + JSON.stringify(this.error));
        })
    }

    renderedCallback() {

        const tableField = this.template.querySelector('.plant-list-form');
        const subBtn = this.template.querySelector('.submit-request');

        $('input[name="plantName"]', tableField).change(function () {
            if ($(this).is(':checked')) {
                selectedPlantList.push($(this).attr('data-plant'));
            } else {
                selectedPlantList.splice($.inArray($(this).attr('data-plant'), selectedPlantList), 1);
            }

            let numberOfChecked = $('input[name="plantName"]:checked', tableField).length;

            if (numberOfChecked > 0) {
                $(subBtn).prop('disabled', false);
            } else {
                $(subBtn).prop('disabled', true);
            }

        });
    }

    requestSite() {

        this.isModalOpen = true;
        this.isReqToSitesModalOpen = true;
        this.reqAddSiteModalOpen = false;

        getSelectedUserDetails({ conId: null }).then(result => {
            this.plantList = result.logAccPlantLists;

            console.log('Log Acc Plant List: ' + JSON.stringify(this.plantList));

            const srElement = this.template.querySelector(".plant-list-form");
            srElement.innerHTML = '';
            let plantHtml = '';

            console.log('popupplantLists***' + JSON.stringify(result.popupplantLists));

            this.plantList.forEach(function (list) {
                let chkboxHtml = '';

                console.log('RESULT approvedSites***' + result.approvedSites['ApprovedSite']);
                console.log('RESULT***' + result.popupplantLists[0]['plantcodes']);
                //this condition is to disable the checkbox when the plant is approved 
                if ((result.approvedSites['ApprovedSite'] || []).includes(list.plant)) {
                    plantHtml += '<div class="col-lg-6 text-left mb-2"><div class="site-name-with-icon"><i class="fas fa-tick-icon pr-3 mt-1 f14">&nbsp;</i><label class="noto-font f14 grey-darkest"><span class="f14 font-weight-normal text-wrap ml-2"><span>' + list.plant + '</span></span></label></div></div>';
                }
                //this condition is to disable the checkbox when the plant is requested
                else if ((result.popupplantLists[0]['plantcodes'] || []).includes(list.plantcode)) {
                    selectedPlantList.push(list.plant);
                    chkboxHtml += '<input type="checkbox" name="plantName" disabled id="' + list.plantcode + '" value="' + list.plantcode + '" data-plant="' + list.plant + '">';
                    plantHtml += '<div class="col-lg-6 manage-colleague-checkbox text-left mb-2">' + chkboxHtml + '<label for="' + list.plantcode + '" class="checkbox-inline noto-font f14 font-weight-normal grey-medium-c"><span>' + list.plant + ' (requested)</span></label></div>';
                } else {
                    chkboxHtml += '<input type="checkbox" name="plantName" id="' + list.plantcode + '" value="' + list.plantcode + '" data-plant="' + list.plant + '">';
                    plantHtml += '<div class="col-lg-6 manage-colleague-checkbox text-left mb-2">' + chkboxHtml + '<label for="' + list.plantcode + '" class="checkbox-inline noto-font f14 grey-darkest font-weight-normal"><span>' + list.plant + '</span></label></div>';
                }

            });
            srElement.innerHTML = '<div class="row">' + plantHtml + '</div>';
            this.renderedCallback();
        }).catch(error => {
            this.error = error;
            console.log('error:: ' + JSON.stringify(this.error));
        })
    }

    closeModal() {
        this.isModalOpen = false;
        this.reqAddSiteModalOpen = false;
    }

    submitRequest() {
        this.isReqToSitesModalOpen = false;
        this.reqAddSiteModalOpen = true;

        selectedPlantList = [];
        const tableField = this.template.querySelector('.plant-list-form');

        let plantCodeArr = [], plantNameArr = [];

        $('input[name="plantName"]:checked', tableField).each(function () {
            plantCodeArr.push($(this).val());
            plantNameArr.push($(this).attr('data-plant'));
        });
        console.log('plantNameArr' + JSON.stringify(plantNameArr));
        this.requestPlantResult = plantNameArr;

        getPlantRequests({ plantIDList: plantCodeArr }).then(() => {

            getManageColleaguesDetails({ clgIdList: null })
                .then((result) => {
                    fireEvent(this.pageRef, 'manageColleaguesNotiCount', result);
                }).catch(error => {
                    this.error = error;
                    console.log('error:: ' + JSON.stringify(this.error));
                })

        }).catch(error => {
            this.error = error;
            console.log('error:: ' + JSON.stringify(this.error));
        })

    }
    openDeactivatePopup() {
        this.isDeactivateModalOpen = true;
    }
    deactivateAccount() {
        this.deactive = true;
        getUserDeactives({ contactId: null, btnDeactive: this.deactive }).then(result => {
            if (result == true) {
                window.location.href = "/YG_CDC_Logout";
                //window.location.reload();
                //this.logout();
                //window.location.href = "/s/login";

            }
        }).catch(error => {
            this.error = error;
            console.log('Error: ' + JSON.stringify(this.error));
        });
    }
    logout() {

        console.log('URL::' + this.communityURL);
        var str = this.communityURL;
        str = str.substring(0, str.length - 3);

        window.location.replace(str + '/secur/logout.jsp?');
        window.location.href = "/YG_CDC_Logout";

    }
    closeDeactivateModal() {
        this.isDeactivateModalOpen = false;
    }
    transferAccount() {
        window.location.href = "mailto:" + emailToLbl;
    }
}