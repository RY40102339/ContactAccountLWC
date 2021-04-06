import { LightningElement, track, wire } from 'lwc';
import getManageColleaguesDetails from '@salesforce/apex/YG_ManageColleaguesController.getManageColleaguesGridDetails';
import getSelectedUserDetails from '@salesforce/apex/YG_ManageColleaguesController.getSelectedUserDetail';
import getUpdatePlants from '@salesforce/apex/YG_ManageColleaguesController.getUpdatePlant';
import getUserDeactives from '@salesforce/apex/YG_ManageColleaguesController.getUserDeactive';
import getUserAdmins from '@salesforce/apex/YG_ManageColleaguesController.getUserAdmin';
import getUserRole from '@salesforce/apex/YG_LoggedUserRoleController.getNotifyUserRole';
import getApprovePlants from '@salesforce/apex/YG_ManageColleaguesController.getApprovePlant';
import getDeclinePlants from '@salesforce/apex/YG_ManageColleaguesController.getDeclinePlant';
import { loadScript, loadStyle } from "lightning/platformResourceLoader";
import YG_CustomerPortal from "@salesforce/resourceUrl/YG_CustomerPortal";
import { CurrentPageReference } from 'lightning/navigation';
import { fireEvent, registerListener, unregisterAllListeners } from 'c/pubSub';
import popupmsg from '@salesforce/label/c.YG_Manage_Colleague_popup_msg';
import admin from '@salesforce/label/c.YG_Admin';
import save from '@salesforce/label/c.YG_Save';
import msg1 from '@salesforce/label/c.YG_Manage_Colleague_popup_msg1';
import msg2 from '@salesforce/label/c.YG_Manage_Colleague_popup_msg2';
import msg3 from '@salesforce/label/c.YG_Manage_Colleague_popup_msg3';
import noSite from '@salesforce/label/c.YG_No_Site_msg';
import requestSite from '@salesforce/label/c.YG_Site_Access_msg';
import cancelbl from '@salesforce/label/c.YG_Cancel';
import closeLbl from '@salesforce/label/c.YG_Close';
import deactivateUserConfirmationLbl from '@salesforce/label/c.YG_Deactivate_user_confirmation';
import deactivateUserConfirmationMsgLbl from '@salesforce/label/c.YG_Deactivate_user_confirmation_msg';

let selectedUser;
let selectedPlantList = [];
let requestedPlantList = [];
let profImgUrl = '';
let profImgUrl_1 = '';
let profBigImgUrl = '';
let nosites = '';
let requestsite = '';
let flag_val = false;
export default class YgManageColleagues extends LightningElement {
    @wire(CurrentPageReference) pageRef;
    @track isLoading = false;
    @track isModalOpen = false;
    @track hideLink = false;
    @track name;
    @track showPlants = true;
    gridData = [];
    plantList = [];
    totalcon = '';
    notifyCount = '';
    loadExternal = true;
    isAdmin = false;
    isLogUser = false;
    isAdminLbl = '';
    selectedUserId = '';
    userName = '';
    userEmail = '';
    userPhone = '';
    userRole = '';
    deactive = false;
    role = '';
    roleFlag = false;
    chkbId = 0;
    superadminflag = false;
    //profileLogo = YG_CustomerPortal + '/YG_Images/default-contactprofile-image.svg';
    profUserImgUrl = YG_CustomerPortal + '/YG_Images/default-contactprofile-image-big.svg';
    label = {
        popupmsg, admin, save, msg1, msg2, msg3, noSite, requestSite, cancelbl, closeLbl,
        deactivateUserConfirmationLbl, deactivateUserConfirmationMsgLbl
    };

    constructor() {
        super();

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

        this.loadExternalLibraries();
        this.getLoadGridData();
    }

    getLoadGridData() {
        getManageColleaguesDetails({ clgIdList: null })
            .then((result) => {
                this.gridData = result.manageColleaguesDataList;
                this.totalcon = result.totalcontact;
                this.notifyCount = result.notificationCount;
                console.log('ManageColleagues gridData: ' + JSON.stringify(this.gridData));
                console.log('total contacts : ' + JSON.stringify(this.totalcon));
                console.log('notificationCount  : ' + JSON.stringify(this.notifyCount));
                fireEvent(this.pageRef, 'totContactsCount', result);
                fireEvent(this.pageRef, 'plantnotificationCount', result);
                fireEvent(this.pageRef, 'manageColleaguesNotiCount', result);

                if (this.loadExternal === true) {
                    const table = this.template.querySelector('.manageColleagues-dtTable');
                    $(table).DataTable().destroy();
                }

            }).then(() => {
                if (this.loadExternal === true) {
                    this.loadExternalLibraries();
                }
                this.loadExternal = false;
                this.isLoading = false;
            }).catch((error) => {
                this.isLoading = false;
                this.error = error.message;
            });
    }

    connectedCallback() {
        registerListener('filterRecords', this.getFilteredManageColleagues, this);
    }

    disconnectedCallback() {
        unregisterAllListeners(this);
    }

    async loadExternalLibraries() {
        loadScript(this, YG_CustomerPortal + '/YG_JS/jquery.min.js').then(() => {
            loadStyle(this, YG_CustomerPortal + '/YG_CSS/dataTables.css').then(() => {
                loadScript(this, YG_CustomerPortal + '/YG_JS/jquery.dataTables.min.js').then(() => {
                    let dataTable, notiHtml = '', siteTxt, tickTxt, imgLink;

                    const table = this.template.querySelector('.manageColleagues-dtTable');
                    const columnHeaders = ['Name', 'Site', 'Notifications'];
                    let columnHeaderHtml = '<thead><tr>';
                    columnHeaders.forEach(function (header) {
                        columnHeaderHtml += '<th><span class="font-weight-normal">' + header + '</span></th>';
                    });
                    columnHeaderHtml += '</tr></thead>';
                    table.innerHTML = columnHeaderHtml;

                    dataTable = $(table).DataTable({
                        "paging": false,
                        "searching": true, // false to disable search (or any other option)
                        "info": false,
                        "oSearch": { "bSmart": false },
                        "columnDefs": [{ "width": "30%", "targets": 0 },
                        { "width": "35%", "targets": 1 },
                        { "width": "35%", "targets": 2 },
                        {
                            orderable: false,
                            targets: [1, 2]
                        }],
                        // Per-row function to iterate cells
                        "createdRow": function (row, data, rowIndex) {
                            // Per-cell function to do whatever needed with cells
                            $.each($('td', row), function (colIndex) {
                                // For example, adding data-* attributes to the cell
                                $(this).attr('data-title', columnHeaders[colIndex]);
                            });
                        }
                    });

                    nosites = this.label.noSite;
                    requestsite = this.label.requestSite;
                    this.gridData.forEach(function (list) {
                        notiHtml = '';
                        siteTxt = '';
                        tickTxt = '';
                        imgLink = '';
                        let a = list.name;
                        let flagVal = false;
                        console.log('NAME:":' + a);

                        //this condition is used to get the user names
                        if (list.sites != undefined && list.sites[a] != undefined) {
                            tickTxt += (list.sites[a].length > 1) ? list.sites[a].length + " Sites" : list.sites[a].length + " Site";
                            siteTxt = '<div class="site-name-with-icon mt-2"><i class="fas fa-tick-icon pr-3 mt-1 f14">&nbsp;</i><label class="noto-font f14 grey-darkest"><span class="f14 font-weight-normal text-wrap"><span>' + tickTxt + '</span></span></label></div>'
                            /*
                        (list.sites[a] || []).forEach(function(obj){
                            className = 'fa-tick-icon';
                            notiHtml += '<div class="site-name-with-icon"><i class="fas ' + className + ' pr-3 pb-3 mt-1 f14">&nbsp;</i><span class="text-wrap">' + obj + '</span></div>';
                        })*/
                        }
                        else {
                            siteTxt = '<div class="site-name-with-icon mt-2"><i class="fas fa-warning-icon pr-3 pb-3 mt-1 f14">&nbsp;</i><label class="noto-font f14 grey-darkest"><span class="f14 font-weight-normal text-wrap"><span>' + nosites + '</span></span></label></div>'
                        }

                        //this condition is to display the notification msg
                        if ((list.notifications['Request site access'] || []).length > 0) {
                            flagVal = true;
                            notiHtml += '<span class="noto-font f14 grey-darkest font-weight-normal"><div class="site-name-with-icon"><i class="fas fa-bell-orange pr-3 pb-3 mt-1 f14">&nbsp;</i><span class="text-wrap">' + requestsite + '</span></div></span>';
                        }
                        else {
                            flagVal = false;
                            notiHtml += '<span>&nbsp;</span>';
                        }

                        //this condition is to check the user profile image 
                        if ((list.profileImage || '') != '') {
                            profImgUrl = list.profileImage;
                            profImgUrl_1 = list.profileImage;
                        } else {
                            profImgUrl = YG_CustomerPortal + '/YG_Images/default-contactprofile-image.svg';
                            profImgUrl_1 = YG_CustomerPortal + '/YG_Images/default-contactprofile-image-big.svg';
                        }

                        if ((list.role == 'Super Admin') || (list.role == 'Customer Admin')) {
                            imgLink += '<a class="text-hover-color" data-id=' + list.Id + ' data-flag=' + flagVal + ' data-image=' + profImgUrl_1 + ' href="javascript:void(0)"><ins>' + list.name + '</ins></a><span style="position: absolute; left:40px; top:22px" class="blue-primary f10 fbold is-admin-bg">Admin</span>'
                        } else {
                            imgLink += '<a class="text-hover-color" data-id=' + list.Id + ' data-flag=' + flagVal + ' data-image=' + profImgUrl_1 + ' href="javascript:void(0)"><ins>' + list.name + '</ins></a>'
                        }

                        dataTable.row.add([
                            '<div class="position-relative"><span class="pr-2"><img src=' + profImgUrl + ' class="rounded-circle img32" alt="user-image" height="32" width="32"></img></span>' + imgLink + '</div>',
                            siteTxt,
                            notiHtml
                        ]);
                    })

                    dataTable.draw();
                    const tableField = this.template.querySelector('.table-responsive');
                    const triggerClick = this.template.querySelector('.triggerClick');
                    $('tbody', table).on('click', 'td a', function () {
                        selectedUser = $(this).attr('data-id');
                        profBigImgUrl = $(this).attr('data-image');
                        flag_val = $(this).attr('data-flag');
                        $('input[name=hiddenSelect]', tableField).val($(this).attr('data-id'));
                        triggerClick.click();
                    });
                })
            })
        })
    }

    triggetSelect() {
        this.profUserImgUrl = profBigImgUrl;
        console.log('selectedUser***' + selectedUser);
        this.superadminflag = false;

        getSelectedUserDetails({ conId: selectedUser }).then(result => {

            this.plantList = result.logAccPlantLists;
            this.userName = result.name;
            this.userEmail = result.email;
            this.userPhone = result.phone;
            this.userRole = result.role;
            if ((this.userRole == 'Customer Admin') || (this.userRole == 'Customer')) {
                this.superadminflag = true;
            }
            if ((this.userRole == 'Super Admin') || (this.userRole == 'Customer Admin')) {
                this.isAdmin = true;
                this.isLogUser = false;
            }
            else {
                this.isAdmin = false;
                this.isLogUser = false;
            }
            if (this.userRole == 'LoggedUser') {
                this.isLogUser = true;
            }
            const mcSec = this.template.querySelector(".mc-sec");
            $('.mc-approve', mcSec).hide();
            $('.mc-plant', mcSec).hide();
            $('.mc-with-no-site', mcSec).hide();
            $('.accessible-sites', mcSec).hide();
            $('.no-accessible-sites', mcSec).show();
            $('.mc-approve', mcSec).hide();
            $('.mc-approved', mcSec).hide();
            $('.mc-declined', mcSec).hide();
            const srElement = this.template.querySelector(".plant-list-form");
            const stElement = this.template.querySelector(".site-plant-list");
            const arElement = this.template.querySelector(".approve-site-list");
            srElement.innerHTML = '';
            stElement.innerHTML = '';
            arElement.innerHTML = '';
            let plantHtml = '';
            let siteHtml = '';
            requestedPlantList = [];
            console.log('plantList***' + this.plantList);
            this.plantList.forEach(function (list) {
                let chkboxHtml = '';
                console.log('Requested Plant List***' + result.popupplantLists[0]['plantcodes']);

                //this condition is to disable the checkbox when the plant is approved 
                if ((result.approvedSites['ApprovedSite'] || []).includes(list.plant)) {
                    chkboxHtml += '<input type="checkbox" name="plantName" checked id="' + list.plantcode + '" value="' + list.plantcode + '" data-plant="' + list.plant + '">';
                    plantHtml += '<div class="col-lg-6 manage-colleague-checkbox text-left mb-2">' + chkboxHtml + '<label for="' + list.plantcode + '" class="checkbox-inline noto-font f14 grey-darkest font-weight-normal mt-2"><span>' + list.plant + '</span></label></div>';
                    siteHtml += '<div class="col-lg-6 text-left"><div class="site-name-with-icon mb-4 ml-3" style="display: flex;"><i class="fas fa-tick-icon pr-3 mt-1 f14">&nbsp;</i><label class="noto-font f14 grey-darkest"><span class="f14 font-weight-normal text-wrap"><span>' + list.plant + '</span></span></label></div></div>';
                    $('.accessible-sites', mcSec).show();
                    $('.no-accessible-sites', mcSec).hide();
                }
                //this condition is to check the checkbox when the plant is requested
                else if ((result.popupplantLists[0]['plantcodes'] || []).includes(list.plantcode)) {
                    selectedPlantList.push(list.plant);
                    requestedPlantList.push(list.plantcode);
                    chkboxHtml += '<input type="checkbox" name="plantName" id="' + list.plantcode + '" value="' + list.plantcode + '" data-plant="' + list.plant + '">';
                    plantHtml += '<div class="col-lg-6 manage-colleague-checkbox text-left mb-2 submit-data">' + chkboxHtml + '<label for="' + list.plantcode + '" class="checkbox-inline noto-font f14 grey-darkest fbold mt-2"><span>' + list.plant + '</span></label></div>';
                } else {
                    chkboxHtml += '<input type="checkbox" name="plantName" id="' + list.plantcode + '" value="' + list.plantcode + '" data-plant="' + list.plant + '">';
                    plantHtml += '<div class="col-lg-6 manage-colleague-checkbox text-left mb-2">' + chkboxHtml + '<label for="' + list.plantcode + '" class="checkbox-inline noto-font f14 grey-darkest font-weight-normal mt-2"><span>' + list.plant + '</span></label></div>';
                }
                stElement.innerHTML = '<span class="f14 fbold"><span>' + selectedPlantList.join(", ") + '</span></span>';
            });
            srElement.innerHTML = '<div class="row">' + plantHtml + '</div>';
            arElement.innerHTML = '<div class="row pt-4">' + siteHtml + '</div>';
            if (flag_val == 'true') {
                $('.mc-with-no-site', mcSec).show();
                $('.mc-approve', mcSec).show();
            }
        }).catch(error => {
            this.error = error;
            console.log('error:: 1' + JSON.stringify(this.error));
        })
        this.openModal();
    }

    openModal() {
        this.isModalOpen = true;
    }

    closeModal() {
        // to close modal set isModalOpen tarck value as false
        const stElement = this.template.querySelector(".site-plant-list");
        stElement.innerHTML = '';
        selectedPlantList = [];
        this.isModalOpen = false;
        this.loadExternal = true;
        this.isLoading = true;
        setTimeout(() => {
            this.getLoadGridData();
        }, 3000);
        //this.renderedCallback();
    }

    setasAdmin(event) {
        event.preventDefault();
        this.isAdminLbl = event.currentTarget.dataset.id;
        console.log(this.isAdminLbl);
        getUserAdmins({ conId: selectedUser, btnAdmin: this.isAdminLbl }).then(result => {
            this.userRole = result.role;
            if ((this.userRole == 'Super Admin') || (this.userRole == 'Customer Admin')) {
                this.isAdmin = true;
                this.isLogUser = false;
            }
            else {
                this.isAdmin = false;
                this.isLogUser = false;
            }
            if (this.userRole == 'LoggedUser') {
                this.isLogUser = true;
            }
            //this.loadExternalLibraries();
            this.loadExternal = true;
            this.getLoadGridData();
        }).catch(error => {
            this.error = error;
            console.log('error:: 2' + JSON.stringify(this.error));
        })
    }

    confirmDeactive() {
        const modelEle = this.template.querySelector(".slds-modal__content");
        $(".mc-mb-32, .mc-with-no-site, .accessible-sites, .no-accessible-sites, .mc-plant", modelEle).hide();
        $(".deactive-confirm", modelEle).show();
    }

    setasDeactive(event) {

        this.deactive = true;
        getUserDeactives({ contactId: selectedUser, btnDeactive: this.deactive }).then(result => {
            if (result == true) {
                this.loadExternal = true;
                this.getLoadGridData();
                const modelEle = this.template.querySelector(".slds-modal__content");
                $(".deactive-confirm", modelEle).hide();
                $(".deactive-msg", modelEle).show();
            }
        }).catch(error => {
            this.error = error;
            console.log('Error: ' + JSON.stringify(this.error));
        });
    }

    handleEditSiteAccess(event) {
        event.preventDefault();
        const mcSec = this.template.querySelector(".mc-sec");
        if (flag_val == 'true') {
            $('.accessible-sites', mcSec).hide();
            $('.mc-approve', mcSec).hide();
            $('.mc-approved', mcSec).hide();
            $('.mc-declined', mcSec).hide();
            $('.mc-plant', mcSec).show();
            $('.no-accessible-sites', mcSec).hide();
        } else {
            $('.mc-with-no-site', mcSec).hide();
            $('.mc-approve', mcSec).hide();
            $('.accessible-sites', mcSec).hide();
            $('.no-accessible-sites', mcSec).hide();
            $('.mc-plant', mcSec).show();
        }
    }

    getFilteredManageColleagues(colleaguesList) {

        console.log('colleaguesList: ' + JSON.stringify(colleaguesList));
        let colleaguesListData = colleaguesList;
        let clgId = [];


        colleaguesListData.forEach(function (list) {
            clgId.push(list.Id);
            console.log('clgId :: ' + JSON.stringify(clgId));
        })
        this.loadExternal = true;
        getManageColleaguesDetails({ clgIdList: clgId })
            .then(result => {
                this.gridData = result.manageColleaguesDataList;
                this.totalcon = result.totalcontact;

                console.log('gridData***: ' + JSON.stringify(this.gridData));
                console.log('totalcon***: ' + JSON.stringify(this.totalcon));
                if (this.loadExternal === true) {
                    const table = this.template.querySelector('.manageColleagues-dtTable');
                    $(table).DataTable().destroy();
                }
            }).then(() => {
                if (this.loadExternal === true) {
                    this.loadExternalLibraries();
                }
                this.loadExternal = false;
            }).catch(error => {
                this.error = error;
                console.log('error:: 3' + JSON.stringify(this.error));
            })
    }

    saveSiteInfo(event) {
        event.preventDefault();

        const updateElement = this.template.querySelector(".mc-sec");
        $('.btn.btn-primary', updateElement).html('<div class="spinner-border spinner-border-sm text-white" role="status"><span class="sr-only">Loading...</span></div>');


        const stElement = this.template.querySelector(".site-plant-list");
        stElement.innerHTML = '';
        selectedPlantList = [];
        const tableField = this.template.querySelector('.plant-list-form');
        let plantArr = [];

        $('input[name="plantName"]:checked', tableField).each(function () {
            plantArr.push($(this).val());
        });
        console.log(plantArr);
        this.loadExternal = true;
        getUpdatePlants({ conId: selectedUser, plantIDList: plantArr }).then(() => {
            this.getLoadGridData();
        }).then(() => {
            let svgImage = '<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">';
            svgImage += '<path d="M6 12L10.5 15L16.5 6" stroke="white" stroke-width="2"/></svg>';

            $('.btn.btn-primary', updateElement).attr('disabled', 'disabled').html(svgImage + "SAVED");
            setTimeout(() => {
                $('.btn.btn-primary', updateElement).attr('disabled', false).html("SAVE");
            }, 5000);
        }).catch(error => {
            this.error = error;
            console.log('error:: 4' + JSON.stringify(this.error));
        })
    }
    //this method is used to handle plant approve 
    handleApprove(event) {
        event.preventDefault();
        const mcSec = this.template.querySelector(".mc-sec");
        $('.mc-approve', mcSec).hide();
        $('.no-accessible-sites', mcSec).hide();
        $('.accessible-sites', mcSec).show();
        $('.mc-approved', mcSec).show();
        console.log('Approvelist*****' + requestedPlantList);
        this.loadExternal = true;
        getApprovePlants({ conId: selectedUser, plantIDList: requestedPlantList }).then(() => {
            this.getLoadGridData();

            getSelectedUserDetails({ conId: selectedUser }).then(result => {
                const mcSec = this.template.querySelector(".mc-sec");
                const arElement = this.template.querySelector(".approve-site-list");
                arElement.innerHTML = '';

                let siteHtml = '';

                this.plantList.forEach(function (list) {

                    //this condition is to disable the checkbox when the plant is approved 
                    if ((result.approvedSites['ApprovedSite'] || []).includes(list.plant)) {
                        siteHtml += '<div class="col-lg-6 text-left"><div class="site-name-with-icon mb-4 ml-3"><i class="fas fa-tick-icon pr-3 mt-1 f14">&nbsp;</i><label class="noto-font f14 grey-darkest"><span class="f14 font-weight-normal text-wrap"><span>' + list.plant + '</span></span></label></div></div>';
                    }
                });
                arElement.innerHTML = '<div class="row pt-4">' + siteHtml + '</div>';
            }).catch(error => {
                this.error = error;
                console.log('error:: 5' + JSON.stringify(this.error));
            });

        }).catch(error => {
            this.error = error;
            console.log('error:: 6' + JSON.stringify(this.error));
        })
    }

    handleDeclineUpdate(event) {
        event.preventDefault();
        const mcSec = this.template.querySelector(".mc-sec");
        $('.mc-approve', mcSec).hide();
        $('.mc-declined', mcSec).show();
        console.log('DeclineList*****' + requestedPlantList);
        this.loadExternal = true;
        getDeclinePlants({ conId: selectedUser, plantIDList: requestedPlantList }).then(() => {
            this.getLoadGridData();
        }).catch(error => {
            this.error = error;
            console.log('error:: 7' + JSON.stringify(this.error));
        })
    }
}