import { LightningElement, wire, track } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { fireEvent, registerListener, unregisterAllListeners } from 'c/pubSub';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import YG_CustomerPortal from '@salesforce/resourceUrl/YG_CustomerPortal';
import getCommunityURL from '@salesforce/apex/YG_Utility.getCommunityURL';
import getServiceRequestGridDetails from '@salesforce/apex/YG_AllServiceRequestController.getServiceRequestGridDetails';
import getServiceReqInfo from '@salesforce/apex/YG_AllServiceRequestController.getServiceReqInfo';
import getCaseHistory from '@salesforce/apex/YG_AllServiceRequestController.getCaseHistory';
import getYourDetails from '@salesforce/apex/YG_ServiceRequestAndInquiries.getYourDetails';
import getServiceRequestCSVDetails from '@salesforce/apex/YG_AllServiceRequestController.getServiceRequestCSVDetails';
import getCustomConfig from '@salesforce/apex/YG_Utility.getCustomConfig';
import products from '@salesforce/label/c.YG_Products';
import module from '@salesforce/label/c.YG_Module';
import servicetype from '@salesforce/label/c.YG_Service_Type';
import yourDetailsLbl from '@salesforce/label/c.YG_Your_Details';
import nameLbl from '@salesforce/label/c.YG_Name';
import titleLbl from '@salesforce/label/c.YG_Title';
import showLbl from '@salesforce/label/c.YG_Show';
import moreLbl from '@salesforce/label/c.YG_MoreProducts';
import dateSubmittedLbl from '@salesforce/label/c.YG_DateSubmitted';
import statusLbl from '@salesforce/label/c.YG_Status';
import loadingLbl from '@salesforce/label/c.YG_Loading';
import showStatusLbl from '@salesforce/label/c.YG_Show_status';
import activeLbl from '@salesforce/label/c.YG_Active_only';
import closedLbl from '@salesforce/label/c.YG_Closed_only';
import allLbl from '@salesforce/label/c.YG_All';
import inProgLbl from '@salesforce/label/c.YG_In_Progress';
import prodModLbl from '@salesforce/label/c.YG_Product_Module';
import viewDetLbl from '@salesforce/label/c.YG_View_details';
import caseNumLbl from '@salesforce/label/c.YG_Case_Number';
import serialNoLbl from '@salesforce/label/c.YG_Serial_number';
import servTypeLbl from '@salesforce/label/c.YG_Service_Type';
import contractLbl from '@salesforce/label/c.YG_Contract';
import subByLbl from '@salesforce/label/c.YG_Submitted_by';
import assignToLbl from '@salesforce/label/c.YG_Assigned_to';
import notesLbl from '@salesforce/label/c.YG_Notes';
import editNoteLbl from '@salesforce/label/c.YG_Edit_notes';
import updateLbl from '@salesforce/label/c.YG_Update';
import dwncsvLbl from '@salesforce/label/c.YG_Download_service_request_list';

export default class YgAllServiceRequestGrid extends LightningElement {

    @wire(CurrentPageReference) pageRef;
    csvIcon = YG_CustomerPortal + '/YG_Images/icons/csv.svg';
    @track isLoading = true;
    @track mapData = [];
    showLoadMore = false;
    loadExternal = true;
    serviceReqGridData = [];
    communityURL;
    recordLoadLimit = 0;
    offset = 0;
    loadedRecord = 0;
    remainRecords = 0;
    statusBtnFilter = 'Active';
    btnfilter = '';
    searchfilterIdList = [];
    radioCall = false;
    showContractType = false;

    @track isModalOpen = false;
    @track hideLink = false;
    caseDetails = {}; yourData = {};
    caseHisData = [];
    viewDetURL = '';
    setCSVData = [];


    label = {
        showLbl, moreLbl, yourDetailsLbl, nameLbl, titleLbl, dateSubmittedLbl, products, module,
        servicetype, statusLbl, loadingLbl, showStatusLbl, activeLbl, closedLbl, allLbl, inProgLbl,
        viewDetLbl, caseNumLbl, serialNoLbl, servTypeLbl, contractLbl, subByLbl, assignToLbl, prodModLbl,
        notesLbl, editNoteLbl, updateLbl, dwncsvLbl
    };

    constructor() {
        super();


        getCommunityURL({})
            .then(result => {
                this.communityURL = result;
            }).then(() => {
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
                    }).then(() => {
                        this.getAllServiceRequest();
                    })
                    .catch(error => {
                        this.error = error.message;
                        console.log('getCustomConfig error: ' + JSON.stringify(this.error));
                    })

            }).catch(error => {
                this.error = error;
                console.log('Error: ' + JSON.stringify(this.error));
            });
    }

    connectedCallback() {
        registerListener("serviceReqBtnFilter", this.getFilteredAllServiceRequestBtn, this);
        registerListener("filterRecords", this.getFilteredAllService, this);
    }

    disconnectedCallback() {
        unregisterAllListeners(this);
    }

    renderedCallback() {
        /*if (this.radioCall === false) {
            const radioInput = this.template.querySelectorAll('.form-group');
            $('div.newradio--inline input:first', radioInput).prop("checked", true);
        }*/
    }

    getAllServiceRequest() {

        this.showLoadMore = false;
        this.offset = 0;
        this.searchfilterIdList = [];

        getServiceRequestGridDetails({ filterValue: this.searchfilterIdList, catType: this.btnfilter, caseStatus: this.statusBtnFilter, loadLimit: this.recordLoadLimit, offset: this.offset })
            .then((result) => {
                this.isLoading = false;
                //if (result.caseDataList.length === 0) {
                //    let url = this.communityURL + 'overview';
                //    window.location.href = url;
                //} else {
                fireEvent(this.pageRef, 'serviceRequestBtnNoti', result);
                fireEvent(this.pageRef, 'serviceRequestCnt', result.totalCaseCnt);

                this.serviceReqGridData = result.caseDataList;

                this.loadedRecord = result.caseDataList.length;
                this.remainRecords = result.totalCaseCnt - this.loadedRecord;
                if (this.loadedRecord < result.totalCaseCnt) {
                    this.showLoadMore = true;
                    if (this.remainRecords < this.recordLoadLimit) {
                        this.remainRecords = this.remainRecords;
                    } else {
                        this.remainRecords = this.recordLoadLimit;
                    }
                } else {
                    this.showLoadMore = false;
                }

                //}

            }).then(() => {
                getServiceRequestCSVDetails({})
                    .then((result) => {
                        //set CSV data setCSVData
                        let csvtempArr = [], productNameAndModule;
                        result.caseCSVDataList.forEach(function (list) {

                            productNameAndModule = '';
                            if (list.productName != 'Others' && list.productName != undefined && list.productName != '') {
                                productNameAndModule += list.productName + ',' + list.modelCode + list.serialNumber;
                            }
                            else if (list.productName == 'Others') {
                                productNameAndModule += list.productName;
                            }
                            else {
                                productNameAndModule += '-';
                            }

                            csvtempArr.push({
                                Date_Submitted: list.dateSubmitted,
                                Product_Module: productNameAndModule,
                                Service_Type: list.serviceType,
                                Status: list.status,
                            });
                        })

                        this.setCSVData = csvtempArr;
                    })
                    .catch((error) => {
                        this.error = error.body;
                    });
            }).then(() => {
                this.loadExternalLibraries();
            }).then(() => {
                const radioInput = this.template.querySelectorAll('.form-group');
                $('div.newradio--inline input:first', radioInput).prop("checked", true);
                fireEvent(this.pageRef, 'serviceRequestChart', "" + "~" + $('div.newradio--inline input:first', radioInput).val());

            }).catch((error) => {
                this.isLoading = false;
                this.error = error.body;
            });
    }

    handleStatus(event) {

        fireEvent(this.pageRef, 'clearBtnFilter', 'clear');
        let radioValue = event.currentTarget.value;
        fireEvent(this.pageRef, 'serviceRequestChart', "" + "~" + radioValue);
        this.serviceReqGridData = [];
        this.showLoadMore = false;
        this.statusBtnFilter = radioValue;
        this.btnfilter = '';
        this.loadExternal = true;
        this.offset = 0;

        let filterSearchId;
        if (this.searchfilterIdList.length > 0) {
            filterSearchId = this.searchfilterIdList;
        }
        else {
            filterSearchId = [];
        }

        getServiceRequestGridDetails({ filterValue: filterSearchId, catType: this.btnfilter, caseStatus: this.statusBtnFilter, loadLimit: this.recordLoadLimit, offset: this.offset })
            .then((result) => {
                this.isLoading = false;
                let totCaseCount;

                if (this.btnfilter == '') {
                    totCaseCount = result.totalCaseCnt;
                }

                if (this.btnfilter == 'Product') {
                    totCaseCount = result.prodCaseCnt;
                }

                if (this.btnfilter == 'System') {
                    totCaseCount = result.sysCaseCnt;
                }

                if (this.btnfilter == 'Inquiry') {
                    totCaseCount = result.inqCaseCnt;
                }

                fireEvent(this.pageRef, 'serviceRequestBtnNoti', result);
                fireEvent(this.pageRef, 'serviceRequestCnt', result.totalCaseCnt);

                this.serviceReqGridData = result.caseDataList;
                this.loadedRecord = result.caseDataList.length;
                this.remainRecords = totCaseCount - this.loadedRecord;
                if (this.loadedRecord < totCaseCount) {
                    this.showLoadMore = true;
                    if (this.remainRecords < this.recordLoadLimit) {
                        this.remainRecords = this.remainRecords;
                    } else {
                        this.remainRecords = this.recordLoadLimit;
                    }
                } else {
                    this.showLoadMore = false;
                }

                if (this.loadExternal === true) {
                    const table = this.template.querySelector('.allServiceRequests-dtTable');
                    $(table).DataTable().destroy();
                }

            }).then(() => {
                if (this.loadExternal === true) {
                    this.loadExternalLibraries();
                }
                this.loadExternal = false;
            }).catch((error) => {
                this.isLoading = false;
                this.error = error.body.message;
            });
    }

    getFilteredAllServiceRequestBtn(param) {

        this.serviceReqGridData = [];
        this.showLoadMore = false;
        this.btnfilter = param;
        this.loadExternal = true;
        this.offset = 0;

        let filterSearchId;
        if (this.searchfilterIdList.length > 0) {
            filterSearchId = this.searchfilterIdList;
        }
        else {
            filterSearchId = [];
        }

        getServiceRequestGridDetails({ filterValue: filterSearchId, catType: this.btnfilter, caseStatus: this.statusBtnFilter, loadLimit: this.recordLoadLimit, offset: this.offset })
            .then((result) => {
                this.isLoading = false;
                let totCaseCount;

                if (this.btnfilter == '') {
                    totCaseCount = result.totalCaseCnt;
                }

                if (this.btnfilter == 'Product') {
                    totCaseCount = result.prodCaseCnt;
                }

                if (this.btnfilter == 'System') {
                    totCaseCount = result.sysCaseCnt;
                }

                if (this.btnfilter == 'Inquiry') {
                    totCaseCount = result.inqCaseCnt;
                }
                this.serviceReqGridData = result.caseDataList;
                this.loadedRecord = result.caseDataList.length;
                this.remainRecords = totCaseCount - this.loadedRecord;
                if (this.loadedRecord < totCaseCount) {
                    this.showLoadMore = true;
                    if (this.remainRecords < this.recordLoadLimit) {
                        this.remainRecords = this.remainRecords;
                    } else {
                        this.remainRecords = this.recordLoadLimit;
                    }
                } else {
                    this.showLoadMore = false;
                }

                if (this.loadExternal === true) {
                    const table = this.template.querySelector('.allServiceRequests-dtTable');
                    $(table).DataTable().destroy();
                }

            }).then(() => {
                if (this.loadExternal === true) {
                    this.loadExternalLibraries();
                }
                this.loadExternal = false;
            }).then(() => {

                const radioInput = this.template.querySelectorAll('.form-group');
                let chkedVal = $('div.newradio--inline input:checked', radioInput).val();
                fireEvent(this.pageRef, 'showRequestChart', param + '~' + chkedVal);

                /*
                const radioInput = this.template.querySelectorAll('.form-group');
                $('div.newradio--inline input:first', radioInput).prop("checked", true);*/
            }).catch((error) => {
                this.isLoading = false;
                this.error = error.body.message;
            });

    }

    getFilteredAllService(caseList) {

        let caseId = caseList;
        let filterSearchId = [];
        this.offset = 0;
        this.showLoadMore = false;
        this.loadExternal = true;

        if (caseId.length > 0) {
            caseId.forEach(function (list) {
                filterSearchId.push(list.Name);
            })
        } else {
            filterSearchId = [];
        }

        this.searchfilterIdList = filterSearchId;

        getServiceRequestGridDetails({ filterValue: filterSearchId, catType: this.btnfilter, caseStatus: this.statusBtnFilter, loadLimit: this.recordLoadLimit, offset: this.offset })
            .then((result) => {
                this.isLoading = false;
                let totCaseCount;

                if (this.btnfilter == '') {
                    totCaseCount = result.totalCaseCnt;
                }

                if (this.btnfilter == 'Product') {
                    totCaseCount = result.prodCaseCnt;
                }

                if (this.btnfilter == 'System') {
                    totCaseCount = result.sysCaseCnt;
                }

                if (this.btnfilter == 'Inquiry') {
                    totCaseCount = result.inqCaseCnt;
                }

                fireEvent(this.pageRef, 'serviceRequestBtnNoti', result);
                fireEvent(this.pageRef, 'serviceRequestCnt', result.totalCaseCnt);

                this.serviceReqGridData = result.caseDataList;
                this.loadedRecord = result.caseDataList.length;
                this.remainRecords = totCaseCount - this.loadedRecord;
                if (this.loadedRecord < totCaseCount) {
                    this.showLoadMore = true;
                    if (this.remainRecords < this.recordLoadLimit) {
                        this.remainRecords = this.remainRecords;
                    } else {
                        this.remainRecords = this.recordLoadLimit;
                    }
                } else {
                    this.showLoadMore = false;
                }

                if (this.loadExternal === true) {
                    const table = this.template.querySelector('.allServiceRequests-dtTable');
                    $(table).DataTable().destroy();
                }

            }).then(() => {
                if (this.loadExternal === true) {
                    this.loadExternalLibraries();
                }
                this.loadExternal = false;
            }).catch((error) => {
                this.isLoading = false;
                this.error = error.body.message;
            });
    }

    async loadExternalLibraries() {
        loadScript(this, YG_CustomerPortal + '/YG_JS/jquery.min.js').then(() => {
            loadStyle(this, YG_CustomerPortal + '/YG_CSS/dataTables.css').then(() => {
                loadScript(this, YG_CustomerPortal + '/YG_JS/jquery.dataTables.min.js').then(() => {

                    let dataTable, productNameAndModule = '';

                    const table = this.template.querySelector('.allServiceRequests-dtTable');
                    const columnHeaders = ['' + this.label.dateSubmittedLbl + '', '' + this.label.products + '/' + this.label.module + '', '' + this.label.servicetype + '', '' + this.label.statusLbl + ''];
                    let productLabel = this.label.products;
                    let columnHeaderHtml = '<thead><tr>';
                    columnHeaders.forEach(function (header, index) {
                        if (index === 0) {
                            columnHeaderHtml += '<th><span class="font-weight-normal mHidden">' + header + '</span><span class="font-weight-normal d-sm-none">' + columnHeaders[0] + '/' + productLabel + '</span></th>';
                        } else if (index === 1) {
                            columnHeaderHtml += '<th><span class="font-weight-normal mHidden">' + header + '</span><span class="font-weight-normal d-sm-none">Type/Status</span></th>';
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
                        "oSearch": { "bSmart": false },
                        "columnDefs": [{
                            orderable: false,
                            targets: 3
                        }]
                    });

                    this.serviceReqGridData.forEach(function (list) {
                        productNameAndModule = '';
                        if (list.productName != 'Others' && list.productName != undefined && list.productName != '') {
                            productNameAndModule += '<b>' + list.productName + ',<br>' + list.modelCode + '</b> <div class="pdf-doc f14">' + list.serialNumber + '</div>';
                        }
                        else if (list.productName == 'Others') {
                            productNameAndModule += '<b>' + list.productName + '</b>';
                        }
                        else {
                            productNameAndModule += '-';
                        }

                        dataTable.row.add([
                            '<span class="d-none">' + list.rawDate + '</span><div class="font-weight-normal d-none d-sm-block">' + list.dateSubmitted + '</div><div class="d-sm-none"><strong>' + list.dateSubmitted + '</strong><br>' + productNameAndModule + '</div>',
                            '<div class="font-weight-normal d-none d-sm-block">' + productNameAndModule + '</div><div class="d-sm-none"><strong>' + list.serviceType + '</strong><br><a class="text-hover-color" data-id=' + list.caseNumber + ' href="javascript:void(0)"><ins>' + list.status + '</ins></a></div>',
                            list.serviceType,
                            '<span class=d-none>' + list.status + '</span><a class="text-hover-color" data-id=' + list.caseNumber + ' href="javascript:void(0)"><ins>' + list.status + '</ins></a>'
                        ]);
                    })
                    dataTable.draw();

                    const tableField = this.template.querySelector('.table-responsive');
                    const triggerClick = this.template.querySelector('.triggerClick');
                    $('tbody', table).on('click', 'td a', function () {
                        //$('input[name=hiddenSelect]', tableField).val($(this).attr('data-id')).trigger('select');
                        $('input[name=hiddenSelect]', tableField).val($(this).attr('data-id'));
                        triggerClick.click();
                    });
                })
            })
        })
    }

    loadmore() {

        this.template.querySelector('.loading-icon').classList.remove('d-none');

        this.offset = this.offset + this.recordLoadLimit;
        let loadData = [];
        let filterSearchId;
        if (this.searchfilterIdList.length > 0) {
            filterSearchId = this.searchfilterIdList;
        }
        else {
            filterSearchId = [];
        }

        getServiceRequestGridDetails({ filterValue: filterSearchId, catType: this.btnfilter, caseStatus: this.statusBtnFilter, loadLimit: this.recordLoadLimit, offset: this.offset })
            .then((result) => {

                this.isLoading = false;
                let totCaseCount;

                if (this.btnfilter == '') {
                    totCaseCount = result.totalCaseCnt;
                }

                if (this.btnfilter == 'Product') {
                    totCaseCount = result.prodCaseCnt;
                }

                if (this.btnfilter == 'System') {
                    totCaseCount = result.sysCaseCnt;
                }

                if (this.btnfilter == 'Inquiry') {
                    totCaseCount = result.inqCaseCnt;
                }


                loadData = result.caseDataList;
                this.loadedRecord = this.loadedRecord + result.caseDataList.length;
                this.remainRecords = totCaseCount - this.loadedRecord;

                if (this.loadedRecord < totCaseCount) {
                    if (this.remainRecords < this.recordLoadLimit) {
                        this.remainRecords = this.remainRecords;
                    } else {
                        this.remainRecords = this.recordLoadLimit;
                    }
                    this.showLoadMore = true;
                } else {
                    this.showLoadMore = false;
                }

                let dataTable, productNameAndModule = '';
                const table = this.template.querySelector('.allServiceRequests-dtTable');
                $.fn.dataTableExt.sErrMode = 'none';

                dataTable = $(table).DataTable({
                    "paging": false,
                    "searching": false, // false to disable search (or any other option)
                    "info": false,
                    "order": [],
                    "oSearch": { "bSmart": false },
                    "columnDefs": [{
                        orderable: false,
                        targets: 3
                    }]
                });

                loadData.forEach(function (list) {
                    productNameAndModule = '';
                    if (list.productName != 'Others' && list.productName != undefined & list.productName != '') {
                        productNameAndModule += '<b>' + list.productName + ',<br>' + list.modelCode + '</b> <div class="pdf-doc f14">' + list.serialNumber + '</div>';
                    }
                    else if (list.productName == 'Others') {
                        productNameAndModule += '<b>' + list.productName + '</b>';
                    }
                    else {
                        productNameAndModule += '-';
                    }

                    dataTable.row.add([
                        '<span class="d-none">' + list.rawDate + '</span><div class="font-weight-normal d-none d-sm-block">' + list.dateSubmitted + '</div><div class="d-sm-none"><strong>' + list.dateSubmitted + '</strong><br>' + productNameAndModule + '</div>',
                        '<div class="font-weight-normal d-none d-sm-block">' + productNameAndModule + '</div><div class="d-sm-none"><strong>' + list.serviceType + '</strong><br><a class="text-hover-color" data-id=' + list.caseNumber + ' href="javascript:void(0)"><ins>' + list.status + '</ins></a></div>',
                        list.serviceType,
                        '<span class=d-none>' + list.status + '</span><a class="text-hover-color" data-id=' + list.caseNumber + ' href="javascript:void(0)"><ins>' + list.status + '</ins></a>'
                    ]).draw(false);
                })
                //dataTable.draw();
            }).then(() => {
                this.template.querySelector('.loading-icon').classList.add('d-none');
            }).catch(error => {
                this.isLoading = false;
                this.error = error.body;
                console.log('error:: ' + JSON.stringify(this.error));
            })


    }

    triggetSelect() {
        this.openModal();
    }

    openModal() {

        const tableField = this.template.querySelector('.table-responsive');
        this.isModalOpen = true;
        this.hideLink = false;
        this.caseDetails = {};
        this.caseHisData = [];
        this.yourData = {};

        let caseId = $('input[name=hiddenSelect]', tableField).val();
        console.log('caseId:::' + caseId);

        getServiceReqInfo({ caseNo: caseId })
            .then(result => {

                console.log('getServiceReqInfo:: ' + JSON.stringify(result));

                console.log('result.caseAssignedTo::' + result.caseAssignedTo);
                if (result.contractType.length > 0) {
                    this.showContractType = true;
                    this.caseDetails = result;
                } else {
                    this.showContractType = false;
                    this.caseDetails = result;
                }
                if (result.modelCode != '') {
                    this.hideLink = true;
                    this.viewDetURL = this.communityURL + 'product-details?modcode=' + result.modelCode;
                } else {
                    this.hideLink = false;
                }

            }).catch(error => {
                this.error = error;
                console.log('modelWindow Error: ' + JSON.stringify(this.error));
            });

        getCaseHistory({ caseNo: caseId })
            .then(result => {
                this.caseHisData = result.hisWrap;
            }).catch(error => {
                this.error = error;
                console.log('caseHistory Error: ' + JSON.stringify(this.error));
            });

        getYourDetails()
            .then(result => {
                this.yourData = result;
            }).catch(error => {
                this.error = error;
                console.log('Your Details Err::' + JSON.stringify(error));
            });

    }

    closeModal() {
        // to close modal set isModalOpen tarck value as false
        this.isModalOpen = false;
        this.showContractType = false;
    }

    // this method validates the data and creates the csv file to download
    downloadCSVFile() {

        //console.log('this.productGridData downloadCSVFile::' + JSON.stringify(this.productGridData));
        let rowEnd = '\n';
        let csvString = '';

        // this set elminates the duplicates if have any duplicate keys
        let rowData = new Set();
        // getting keys from data   headerCol
        this.setCSVData.forEach(function (record) {
            Object.keys(record).forEach(function (key) {
                //if (key != 'modelCode' & key != 'notificationCount')
                rowData.add(key);
            });
        });


        // Array.from() method returns an Array object from any object with a length property or an iterable object.
        rowData = Array.from(rowData);
        console.log('downloadCSVFile rowData::' + rowData);
        // splitting using ','
        csvString += rowData.join(',');
        csvString += rowEnd;
        console.log('downloadCSVFile csvString::' + csvString);
        // main for loop to get the data based on key value
        for (let i = 0; i < this.setCSVData.length; i++) {
            let colValue = 0;

            // validating keys in data
            for (let key in rowData) {
                if (rowData.hasOwnProperty(key)) {
                    // Key value 
                    // Ex: Id, Name
                    let rowKey = rowData[key];
                    // add , after every value except the first.
                    if (colValue > 0) {
                        csvString += ',';
                    }
                    // If the column is undefined, it as blank in the CSV file.
                    let value = this.setCSVData[i][rowKey] === undefined ? '' : this.setCSVData[i][rowKey];
                    csvString += '"' + value + '"';
                    colValue++;
                }
            }
            csvString += rowEnd;
        }

        //if (navigator.userAgent.search("MSIE") >= 0) {

        if (/Edge\/\d./i.test(navigator.userAgent)) {

            var fileName = "Service Request List.csv";
            var blob = new Blob([csvString], {
                "type": "text/csv;charset=utf8;"
            });
            navigator.msSaveBlob(blob, fileName);
        } else {
            // Creating anchor element to download
            let downloadElement = document.createElement('a');

            // This  encodeURI encodes special characters, except: , / ? : @ & = + $ # (Use encodeURIComponent() to encode these characters).
            downloadElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csvString);
            downloadElement.target = '_self';
            downloadElement.rel = 'noreferrer';
            // CSV File Name
            downloadElement.download = 'Service Request List.csv';
            // below statement is required if you are using firefox browser
            document.body.appendChild(downloadElement);
            // click() Javascript function to download CSV file
            downloadElement.click();
            document.body.removeChild(downloadElement);
        }
    }
}