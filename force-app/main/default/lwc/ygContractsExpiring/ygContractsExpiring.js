import { LightningElement, track, wire } from 'lwc';
import getOverviewContract from '@salesforce/apex/YG_OverviewContractGrid.getOverviewContractGrid';
import getCustomConfig from '@salesforce/apex/YG_Utility.getCustomConfig';
import getCommunityURL from '@salesforce/apex/YG_Utility.getCommunityURL';
import callDelivAPI from '@salesforce/apex/YG_SystemsController.callDelivAPI';
import getDeliverableNoAndSystemId from "@salesforce/apex/YG_SystemsAPI.getDeliverableNoAndSystemId";
import getSystemDetails from '@salesforce/apex/YG_SystemsAPI.getSystemDetails';
import { CurrentPageReference } from 'lightning/navigation';
import { fireEvent, registerListener, unregisterAllListeners } from 'c/pubSub';
import { loadScript, loadStyle } from "lightning/platformResourceLoader";
import YG_CustomerPortal from "@salesforce/resourceUrl/YG_CustomerPortal";
import showLbl from '@salesforce/label/c.YG_Show';
import moreLbl from '@salesforce/label/c.YG_More';
import contractHeaderLbl from '@salesforce/label/c.YG_Contract_Header_Msg';
import viewContractLbl from '@salesforce/label/c.YG_View_All_Contract';
import serviceContractLbl from '@salesforce/label/c.YG_Service_contract';
import salesManagerLbl from '@salesforce/label/c.YG_Yokogawa_Sales_Manager';
import notificationLbl from '@salesforce/label/c.YG_Notification';
import contractNameLbl from '@salesforce/label/c.YG_Contract_name';
import contractDescLbl from '@salesforce/label/c.YG_Contract_description';
import productNameLbl from '@salesforce/label/c.YG_Product_name';
import renewNowLbl from '@salesforce/label/c.YG_renew_now';


let profImgUrl = '', contractname = '', contractdesc = '', productname = '', detailContractURL = '', renewNow;

export default class YgContractsExpiring extends LightningElement {
    @wire(CurrentPageReference) pageRef;
    @track isLoading = false;
    @track isModalOpen = false;
    @track hideLink = false;
    @track mapData = [];
    recordLoadLimit = 0;
    plant_Code = '';
    showLoadMore = false;
    showLess = false;
    offset = 0;
    loadExternal = true;
    contractGridData = [];
    error;
    allContractsDetailsURL;
    csvIcon = YG_CustomerPortal + '/YG_Images/icons/csv.svg';
    loadedRecord = 0;
    remainRecords = 0;
    recordCount = 0;
    allContractURL;
    className = 'ht-collapse';
    label = {
        showLbl, moreLbl, contractHeaderLbl, viewContractLbl, serviceContractLbl, salesManagerLbl, notificationLbl, contractNameLbl, contractDescLbl, productNameLbl, renewNowLbl
    };

    constructor() {
        super();

        getCustomConfig()
            .then(result => {
                var conts = result;
                for (var key in conts) {
                    this.mapData.push({ value: conts[key], key: key });
                    if (key == "Load More Record Limit") {
                        let val = conts[key];
                        this.recordLoadLimit = parseInt(val.Text_1__c);
                    }
                }
                console.log('this.recordLoadLimit==>' + this.recordLoadLimit);
            })
            .catch(error => {
                this.error = error.message;
                console.log('communityURL: ' + JSON.stringify(this.error));
            });

        getCommunityURL({})
            .then(result => {
                this.communityURL = result;
                window.console.log("communityURL::" + JSON.stringify(this.communityURL));
                this.allContractURL = this.communityURL + 'all-contracts';
                detailContractURL = this.communityURL + 'contract-details';
            }).catch(error => {
                this.error = error;
                console.log('Error: ' + JSON.stringify(this.error));
            });

        this.loadExternalLibraries(this.plant_Code);
    }

    connectedCallback() {
        registerListener("plantFilter", this.checkAPICall, this);
        registerListener("setAutoHeight", this.getAutoHeightFromSiteInfo, this);
        registerListener('selfRegister', this.checkSelfReg, this);
    }

    disconnectedCallback() {
        unregisterAllListeners(this);
    }

    checkSelfReg(param) {

        if (param === true) {
            this.template.querySelector(".row").classList.add('d-none');
            this.template.querySelector(".mHidden").classList.add('d-none');
        }
    }

    checkAPICall(plantCode) { //checkAPICall

        let plt = plantCode;
        this.template.querySelector('.loading-grid').classList.remove('d-none');
        this.template.querySelector('.contractsExpiring-dtTable').classList.add('d-none');

        callDelivAPI({ plantCode: plt })
            .then(result => {
                console.log('Call Deliv API : ' + result);
                if (result) {
                    this.callSystemAPI(plt);
                } else {
                    this.getOverviewContractPlant(plt);
                }
            }).catch(error => {
                console.log('Call Deliverable API Error' + JSON.stringify(error.message));
            })
    }

    getAutoHeightFromSiteInfo(status) {
        const hiddenDiv = this.template.querySelector('.mHidden');
        if (status) {
            $(hiddenDiv).animate({ marginTop: '28.85rem' }, 600);
        } else {
            $(hiddenDiv).animate({ marginTop: '17.55rem' }, 600);
        }
    }

    getOverviewContractPlant(plantCode) {
        this.plant_Code = plantCode;
        this.showLoadMore = false;
        this.showLess = false;
        this.offset = 0;
        this.loadExternal = true;
        console.log('plant_Code contractGridData: ' + JSON.stringify(this.plant_Code));

        this.allContractURL = this.communityURL + 'all-contracts?pc=' + this.plant_Code;
        detailContractURL = this.communityURL + 'contract-details?pc=' + this.plant_Code + '&contractno=';

        getOverviewContract({ plantCode: this.plant_Code, loadLimit: this.recordLoadLimit, offset: this.offset })
            .then((result) => {

                this.isLoading = false;

                if (result.totalrecsize > 0) {
                    this.contractGridData = result.overviewContractDataList;
                    this.recordCount = result.totalrecsize;
                    console.log('overview contractGridData RESULT: ' + JSON.stringify(result));
                    console.log('overview contractGridData: ' + JSON.stringify(this.contractGridData));

                    this.loadedRecord = result.overviewContractDataList.length;
                    this.remainRecords = result.totalrecsize - this.loadedRecord;

                    console.log('loadedRecord=> ' + JSON.stringify(this.loadedRecord));
                    console.log('remainRecords=> ' + JSON.stringify(this.remainRecords));

                    if (this.loadedRecord < result.totalrecsize) {
                        this.showLoadMore = true;
                        if (this.remainRecords < this.recordLoadLimit) {
                            this.remainRecords = this.remainRecords;
                        } else {
                            this.remainRecords = this.recordLoadLimit;
                        }
                    } else {
                        this.showLoadMore = false;
                    }
                }
                else {
                    this.contractGridData = [];
                    this.recordCount = result.totalrecsize;
                }

                if (this.loadExternal === true) {
                    const table = this.template.querySelector('.contractsExpiring-dtTable');
                    $(table).DataTable().destroy();
                }

            }).then(() => {
                if (this.loadExternal === true) {
                    this.loadExternalLibraries(this.plant_Code);
                }
                this.loadExternal = false;
                this.template.querySelector('.loading-grid').classList.add('d-none');
                this.template.querySelector('.contractsExpiring-dtTable').classList.remove('d-none');
            }).catch((error) => {
                this.isLoading = false;
                this.error = error.message;
            });
    }

    async loadExternalLibraries(plant_Code) {
        loadScript(this, YG_CustomerPortal + '/YG_JS/jquery.min.js').then(() => {
            loadStyle(this, YG_CustomerPortal + '/YG_CSS/dataTables.css').then(() => {
                loadScript(this, YG_CustomerPortal + '/YG_JS/jquery.dataTables.min.js').then(() => {

                    let dataTable, contractHtml = '';
                    const table = this.template.querySelector('.contractsExpiring-dtTable');
                    const columnHeaders = [this.label.serviceContractLbl, this.label.salesManagerLbl, this.label.notificationLbl];

                    let columnHeaderHtml = '<thead><tr>';
                    columnHeaders.forEach(function (header, index) {
                        if (index === 1) {
                            columnHeaderHtml += '<th><span class="font-weight-normal mHidden">' + header + '</span></th>';
                        } else {
                            columnHeaderHtml += '<th><span class="font-weight-normal">' + header + '</span></th>';
                        }

                    });
                    columnHeaderHtml += '</tr></thead>';
                    table.innerHTML = columnHeaderHtml;

                    dataTable = $(table).DataTable({
                        "paging": false,
                        "searching": false, // false to disable search (or any other option)
                        "info": false,
                        "order": [],
                        "columnDefs": [{
                            orderable: false,
                            targets: 2
                        }]
                    });

                    contractname = this.label.contractNameLbl;
                    contractdesc = this.label.contractDescLbl;
                    productname = this.label.productNameLbl;
                    renewNow = this.label.renewNowLbl;

                    let renewURL = this.communityURL + 'service-request-and-inquiries' + '?pc=' + this.plant_Code + '&contractno=';

                    this.contractGridData.forEach(function (list) {

                        contractHtml = '';
                        let noti = '';

                        //this condition is to display data on ServiceContract column 
                        if (list.contractCategories == 'Life Innovation') {
                            contractHtml += '<div class="col-12 mb-2 pl-0"><p class="text-left f12 grey-darkest mb-0">' + contractname + '</p><p class="text-left f12 grey-darkest fbold mb-0"><a class="text-hover-color" href=' + detailContractURL + list.contractNo + '><ins>' + list.name + '</ins></a></p></div>';
                            contractHtml += '<div class="col-12 mb-2 pl-0"><p class="text-left f12 grey-darkest mb-0">' + contractdesc + '</p><p class="text-left f12 grey-darkest fbold mb-0">' + list.description + '</p></div>';
                        }
                        else {
                            contractHtml += '<div class="col-12 mb-2 pl-0"><p class="text-left f12 grey-darkest mb-0">' + contractname + '</p><p class="text-left f12 grey-darkest fbold mb-0">' + list.name + '</p></div>';
                            if ((list.description || '') != '') {
                                contractHtml += '<div class="col-12 mb-2 pl-0"><p class="text-left f12 grey-darkest mb-0">' + contractdesc + '</p><p class="text-left f12 grey-darkest fbold mb-0"><a class="text-hover-color" href=' + detailContractURL + list.contractNo + '><ins>' + list.description + '</ins></a></p></div>';
                            } else {
                                contractHtml += '<div class="col-12 mb-2 pl-0"><p class="text-left f12 grey-darkest mb-0">' + productname + '</p><p class="text-left f12 grey-darkest fbold mb-0"><a class="text-hover-color" href=' + detailContractURL + list.contractNo + '><ins>' + list.productName + '</ins></a></p></div>';
                            }
                        }

                        //this condition is to display data on SalesManager column
                        if ((list.salesManagerImg || '') != '') {
                            profImgUrl = list.salesManagerImg;
                        } else {
                            profImgUrl = YG_CustomerPortal + '/YG_Images/default-contactprofile-image.svg';
                        }

                        //this condition is to display data on Notification column
                        if (typeof list.notification != 'undefined') {
                            noti += '<i class="fas fa-bell-yellow pr-3 pb-3">&nbsp;</i><a class="text-hover-color" href=' + renewURL + list.contractNo + '><ins>' + list.notification + ', '+ renewNow +' <ins></a>';
                        }

                        if (typeof list.expiredNotification != 'undefined') {
                            noti += '<i class="fas pr-2 pb-3"><svg width="16" height="16" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg"><path fill-rule="evenodd" clip-rule="evenodd" d="M11.2 6.63981V9.48357H12V10.3816H4V9.48357H4.80001V6.63981C4.80001 4.78162 6.05694 3.25301 7.66847 3.0668C7.54572 2.95703 7.46668 2.78814 7.46668 2.59868C7.46668 2.26857 7.70593 2 8.00001 2C8.29409 2 8.53334 2.26857 8.53334 2.59868C8.53334 2.78814 8.45433 2.95703 8.33155 3.0668C9.94308 3.25301 11.2 4.78162 11.2 6.63981ZM8.20337 12.9962C7.5141 12.9962 6.95337 12.3695 6.95337 11.5992H9.45337C9.45337 12.3695 8.89264 12.9962 8.20337 12.9962Z" fill="#7D8E97"/></svg></i><span class="grey-dark">' + list.expiredNotification + '</span>';
                        }

                        if (noti == '') {
                            noti += '-';
                        }

                        dataTable.row.add([
                            contractHtml,
                            '<span class="mHidden"><span class="pr-2"><img alt="user-image" height="32" width="32" src=' + profImgUrl + '></img></span>' + list.salesManager + '</span>',
                            noti
                        ]);
                    })
                    dataTable.draw();
                    // const tableField = this.template.querySelector('.table-responsive');
                    // $('tbody', table).on('click', 'td a', function () {

                    //     $('input[name=hiddenSelect]', tableField).val($(this).attr('data-id')).trigger('select');
                    // });

                })
            })
        })
    }

    //To make action on load more button
    loadmore() {
        this.template.querySelector('.loading-icon').classList.remove('d-none');
        this.offset = this.offset + this.recordLoadLimit;
        let loadData = [];

        getOverviewContract({ plantCode: this.plant_Code, loadLimit: this.recordLoadLimit, offset: this.offset })
            .then(result => {
                this.isLoading = false;
                loadData = result.overviewContractDataList;
                this.loadedRecord = this.loadedRecord + result.overviewContractDataList.length;
                this.remainRecords = result.totalrecsize - this.loadedRecord;

                if (this.loadedRecord < result.totalrecsize) {
                    this.showLoadMore = true;
                    if (this.remainRecords < this.recordLoadLimit) {
                        this.remainRecords = this.remainRecords;
                    } else {
                        this.remainRecords = this.recordLoadLimit;
                    }
                } else {
                    this.showLoadMore = false;
                    this.showLess = true;
                }

                const table = this.template.querySelector('.contractsExpiring-dtTable');
                let dataTable;

                $.fn.dataTableExt.sErrMode = 'none';
                dataTable = $(table).DataTable({
                    "paging": false,
                    "searching": true, // false to disable search (or any other option)
                    "info": false,
                    "oSearch": {
                        "bSmart": false
                    },
                    "columnDefs": [{
                        orderable: false,
                        targets: 1
                    }]
                });
                let renewURL = this.communityURL + 'service-request-and-inquiries' + '?pc=' + this.plant_Code + '&contractno=';
                renewNow = this.label.renewNowLbl;

                loadData.forEach(function (list) {
                    let contractHtml = '';
                    let noti = '';

                    //this condition is to display data on ServiceContract column 
                    if (list.contractCategories == 'Life Innovation') {
                        contractHtml += '<div class="col-12 mb-2 pl-0"><p class="text-left f12 grey-darkest mb-0">' + contractname + '</p><p class="text-left f12 grey-darkest fbold mb-0"><a class="text-hover-color" href=' + detailContractURL + list.contractNo + '><ins>' + list.name + '</ins></a></p></div>';
                        contractHtml += '<div class="col-12 mb-2 pl-0"><p class="text-left f12 grey-darkest mb-0">' + contractdesc + '</p><p class="text-left f12 grey-darkest fbold mb-0">' + list.description + '</p></div>';
                    }
                    else {
                        contractHtml += '<div class="col-12 mb-2 pl-0"><p class="text-left f12 grey-darkest mb-0">' + contractname + '</p><p class="text-left f12 grey-darkest fbold mb-0">' + list.name + '</p></div>';
                        if ((list.description || '') != '') {
                            contractHtml += '<div class="col-12 mb-2 pl-0"><p class="text-left f12 grey-darkest mb-0">' + contractdesc + '</p><p class="text-left f12 fbold mb-0"><a class="text-hover-color" href=' + detailContractURL + list.contractNo + '><ins>' + list.description + '</ins></a></p></div>';
                        } else {
                            contractHtml += '<div class="col-12 mb-2 pl-0"><p class="text-left f12 grey-darkest mb-0">' + productname + '</p><p class="text-left f12 fbold mb-0"><a class="text-hover-color" href=' + detailContractURL + list.contractNo + '><ins>' + list.productName + '</ins></a></p></div>';
                        }
                    }

                    //this condition is to display data on SalesManager column
                    if ((list.salesManagerImg || '') != '') {
                        profImgUrl = list.salesManagerImg;
                    } else {
                        profImgUrl = YG_CustomerPortal + '/YG_Images/default-contactprofile-image.svg';
                    }

                    //this condition is to display data on Notification column
                    if (typeof list.notification != 'undefined') {
                        noti += '<span class="noto-font f14 grey-darkest font-weight-normal"><i class="fas fa-bell-yellow pr-3 pb-3 f14">&nbsp;</i><a class="text-hover-color" href=' + renewURL + list.contractNo + '><ins>' + list.notification + ', '+ renewNow +' <ins></a></span>';
                    }

                    if (typeof list.expiredNotification != 'undefined') {
                        noti += '<i class="fas pr-2 pb-3"><svg width="16" height="16" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg"><path fill-rule="evenodd" clip-rule="evenodd" d="M11.2 6.63981V9.48357H12V10.3816H4V9.48357H4.80001V6.63981C4.80001 4.78162 6.05694 3.25301 7.66847 3.0668C7.54572 2.95703 7.46668 2.78814 7.46668 2.59868C7.46668 2.26857 7.70593 2 8.00001 2C8.29409 2 8.53334 2.26857 8.53334 2.59868C8.53334 2.78814 8.45433 2.95703 8.33155 3.0668C9.94308 3.25301 11.2 4.78162 11.2 6.63981ZM8.20337 12.9962C7.5141 12.9962 6.95337 12.3695 6.95337 11.5992H9.45337C9.45337 12.3695 8.89264 12.9962 8.20337 12.9962Z" fill="#7D8E97"/></svg></i><span class="grey-dark">' + list.expiredNotification + '</span>';
                    }

                    if (noti == '') {
                        noti += '-';
                    }

                    dataTable.row.add([
                        contractHtml,
                        '<span class="mHidden"><span class="pr-2"><img alt="user-image" height="32" width="32" src=' + profImgUrl + '></img></span>' + list.salesManager + '</span>',
                        noti
                    ]).draw();
                })

            }).then(() => {
                //this.isgridLoading = false; 
                this.template.querySelector('.loading-icon').classList.add('d-none');
            })
            .catch(error => {
                this.isLoading = false;
                this.error = error.body.message;
                console.log('error:: ' + JSON.stringify(this.error));
            })
    }

    showless() {

        const pageTop = this.template.querySelector('.section');
        $('html, body').animate({
            scrollTop: $(pageTop).first().offset().top - 100
        }, 1000);

        this.loadExternal = true;
        this.getOverviewContractPlant(this.plant_Code);
    }

    callSystemAPI(plantCode) {

        getDeliverableNoAndSystemId({ plantCodeList: plantCode })
            .then(result => {
                console.log('Delverable API Result:' + result);
                return result;
            })
            .then(result => {
                if (result) {
                    getSystemDetails({ plantCodeList: plantCode })
                        .then(result => {
                            console.log('System API Result:' + result);
                            this.getOverviewContractPlant(plantCode);
                        })
                        .catch(error => {
                            console.log('System API Error:' + JSON.stringify(error.message));
                        })
                } else {
                    console.log('System API Result:' + result);
                    this.getOverviewContractPlant(plantCode);
                }
            }).then(() => {

                this.template.querySelector('.loading-grid').classList.add('d-none');
                this.template.querySelector('.contractsExpiring-dtTable').classList.remove('d-none');
            }).catch(error => {
                console.log('Deliverable API Error:' + JSON.stringify(error.message));
            })
    }

}