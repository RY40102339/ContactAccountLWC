import { LightningElement, track, wire, api } from 'lwc';
import { loadScript, loadStyle } from "lightning/platformResourceLoader";
import { CurrentPageReference } from 'lightning/navigation';
import { fireEvent, registerListener, unregisterAllListeners } from 'c/pubSub';
import YG_CustomerPortal from "@salesforce/resourceUrl/YG_CustomerPortal";
import getAllServiceContracts from '@salesforce/apex/YG_AllServiceContractsController.getAllServiceContracts';
import getServiceContractCSV from '@salesforce/apex/YG_ProductDetailsCSV.getServiceContractCSV';
import getCommunityURL from '@salesforce/apex/YG_Utility.getCommunityURL';
import getCustomConfig from '@salesforce/apex/YG_Utility.getCustomConfig';
import showLbl from '@salesforce/label/c.YG_Show';
import moreProductsLbl from '@salesforce/label/c.YG_MoreProducts';
import callDelivAPI from '@salesforce/apex/YG_SystemsController.callDelivAPI';
import getDeliverableNoAndSystemId from "@salesforce/apex/YG_SystemsAPI.getDeliverableNoAndSystemId";
import getSystemDetails from '@salesforce/apex/YG_SystemsAPI.getSystemDetails';


export default class YgAllContractsGrid extends LightningElement {

    @wire(CurrentPageReference) pageRef;
    @track isLoading = true;
    @track isModalOpen = false;
    @track hideLink = false;

    allContractsGridData = [];
    recordLoadLimit = 0;
    error;
    allContractsDetailsURL;
    csvIcon = YG_CustomerPortal + '/YG_Images/icons/csv.svg';
    loadExternal = true;
    @track plant_Code;
    filterByButton;
    communityURL;
    @track mapData = [];
    radioBtnFilter;
    searchfilterIdList = [];
    setCSVData = [];
    contractCsvData;
    showLoadMore = false;

    recordLoadLimit = 0;
    loadedRecord = 0;
    remainRecords = 0;
    offset = 0;
    filterBtnTotalRec;
    filterRadioTotCnt;
    label = {
        showLbl, moreProductsLbl
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
                        console.log('this.recordLoadLimit==>' + this.recordLoadLimit);
                    })
                    .catch(error => {
                        this.error = error.message;
                        console.log('getCustomConfig error: ' + JSON.stringify(this.error));
                    });

            }).then(() => {
                this.loadExternalLibraries(this.communityURL, this.plant_Code);
            }).catch(error => {
                this.error = error;
                console.log('Error: ' + JSON.stringify(this.error));
            });
    }

    connectedCallback() {
        registerListener("plantFilter", this.checkAPICall, this);
        registerListener("serviceContractBtnFilter", this.getFilteredBtton, this);
        registerListener("filterRecords", this.getFilteredAllContract, this);
    }

    disconnectedCallback() {
        unregisterAllListeners(this);
    }

    checkAPICall(plantCode) {

        let plt = plantCode;
        this.template.querySelector('.loading-grid').classList.remove('d-none');
        this.template.querySelector('.allContracts-dtTable').classList.add('d-none');

        callDelivAPI({ plantCode: plt })
            .then(result => {
                console.log('Call Deliv API : ' + result);
                if (result) {
                    this.callSystemAPI(plt);
                } else {
                    this.getFilteredPlantContract(plt);
                }
            })
            .catch(error => {
                console.log('Call Deliverable API Error' + JSON.stringify(error.message));
            })
    }

    getFilteredPlantContract(plantCode) {
        //alert(plantCode)
        this.loadExternal = true;
        this.plant_Code = plantCode;
        this.showLoadMore = false;
        this.offset = 0;

        if (this.plant_Code != "") {

            getAllServiceContracts({ plantCode: this.plant_Code, filterdByStatus: null, filteredByIndustry: null, servContractFilterIdList: null, loadLimit: this.recordLoadLimit, offset: this.offset })
                .then(result => {
                    console.log('All contract result::' + JSON.stringify(result));

                    this.allContractsGridData = result.ServiceContractsList;

                    this.loadedRecord = result.ServiceContractsList.length;
                    //alert('this.loadedRecord::' + this.loadedRecord)
                    this.remainRecords = result.totalContractCnt - this.loadedRecord;
                    //alert('this.remainRecords::' + this.remainRecords)
                    if (this.loadedRecord < result.totalContractCnt) {
                        //alert('Inside');
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
                        const table = this.template.querySelector('.allContracts-dtTable');
                        $(table).DataTable().destroy();
                    }
                }).then(() => {
                    if (this.loadExternal === true) {
                        this.loadExternalLibraries(this.communityURL, this.plant_Code);
                    }
                    this.loadExternal = false;
                    this.template.querySelector('.loading-grid').classList.add('d-none');
                    this.template.querySelector('.allContracts-dtTable').classList.remove('d-none');
                }).then(() => {
                    //this.loadExternalLibraries(this.communityURL, this.plant_Code);                
                    //const radioInput = this.template.querySelectorAll('.form-group');
                    //$('div.newradio--inline input:first', radioInput).prop("checked", true);
                    //$('div.newradio--inline input:first', radioInput).trigger("change");
                    const radioBtnEle = this.template.querySelector('.radio-btn');
                    $('div.newradio--inline label', radioBtnEle).first().trigger("click");

                }).then(() => {
                    //This method is for the CSV data download
                    this.setCSVData = [];
                    let csvtempArr = [];
                    getServiceContractCSV({ plantCode: this.plant_Code })
                        .then(result => {

                            console.log('contractCsvData.result1::' + JSON.stringify(result));
                            this.contractCsvData = '';
                            this.contractCsvData = result.ServiceContractsList;
                            //console.log('contractCsvData.result1::' + JSON.stringify(result));
                            var contData = result.ServiceContractsList;
                            //Fire event for button notification count
                            fireEvent(this.pageRef, 'serviceContractBtnNoti', result);
                            //Fire event for Breadcrumb total count 
                            fireEvent(this.pageRef, 'serviceContractTotalCnt', result.totalContractCnt);
                            //
                            contData.forEach(function (cont) {
                                csvtempArr.push({
                                    Contract_Name: cont.contractName,
                                    Contract_No: cont.contractNum,
                                    Contract_Description: cont.contractDescription,
                                    Product_Name: cont.productName,
                                    Serial_No: cont.serialNum,
                                    Yokogawa_SalesManager: cont.ygSalesManager,
                                    Start_Date: cont.startDate,
                                    End_Date: cont.endDate,
                                    Notification: cont.notification

                                });
                            })
                            this.setCSVData = csvtempArr;
                            //this.productgridCsvData = result.prodDet;
                            //console.log('this.contractCsvData::' + JSON.stringify(this.setCSVData));
                        }).then(() => {
                            this.isLoading = false;
                        }).catch(error => {
                            this.error = error;
                            console.log('this.productgridCsvDataError1:: ' + JSON.stringify(this.error));
                        });
                }).catch(error => {
                    this.error = error;
                    console.log('All contract Error:: ' + JSON.stringify(this.error));
                });
        } else {
            this.isLoading = false;
            const radioBtnEle = this.template.querySelector('.radio-btn');
            $('div.newradio--inline label', radioBtnEle).first().trigger("click");
        }
    }

    getFilteredAllContract(contractList) {

        let contractId = contractList;
        let id = [];

        contractId.forEach(function (list) {
            id.push(list.Id);
        })
        this.searchfilterIdList = id;
        if (contractId.length == 0) {
            this.showLoadMore = true;
            //this.remainRecords = this.recordLoadLimit;
        } else {
            this.showLoadMore = false;
        }
        this.loadExternal = true;

        //alert(JSON.stringify(id));
        if (contractId.length > 0) {
            getAllServiceContracts({ plantCode: this.plant_Code, filterdByStatus: null, filteredByIndustry: null, servContractFilterIdList: id, loadLimit: this.recordLoadLimit, offset: this.offset })
                .then(result => {
                    console.log('getFilteredAllContract result::' + JSON.stringify(result));

                    this.allContractsGridData = result.ServiceContractsList;
                    fireEvent(this.pageRef, 'serviceContractBtnNoti', result);
                    if (this.loadExternal === true) {
                        const table = this.template.querySelector('.allContracts-dtTable');
                        $(table).DataTable().destroy();
                    }
                }).then(() => {
                    this.loadExternalLibraries(this.communityURL, this.plant_Code);
                }).then(() => {
                    const radioInput = this.template.querySelectorAll('.form-group');
                    $('div.newradio--inline input:first', radioInput).prop("checked", true);
                    //const radioBtnEle = this.template.querySelector('.radio-btn');
                    //$('div.newradio--inline label', radioBtnEle).first().trigger("click");

                }).catch(error => {
                    this.error = error;
                    console.log('getFilteredAllContract Error:: ' + JSON.stringify(this.error));
                });
        } else {
            this.getFilteredPlantContract(this.plant_Code);
            this.filterByButton = null;
            this.radioBtnFilter = null;
            this.contractId = null;

        }
    }

    getFilteredBtton(param) {
        this.loadExternal = true;
        this.showLoadMore = false;
        this.offset = 0;
        this.filterByButton = param;
        //
        if (this.filterByButton === undefined || this.filterByButton === 'All') {
            this.filterByButton = null;
        }
        let filterSearchId;
        if (this.searchfilterIdList.length > 0) {
            filterSearchId = this.searchfilterIdList;
        }
        else {
            filterSearchId = null;
        }
        //alert(this.recordLoadLimit);
        //alert(this.offset);
        this.filterBtnTotalRec = 0;

        getAllServiceContracts({ plantCode: this.plant_Code, filterdByStatus: this.filterByButton, filteredByIndustry: null, servContractFilterIdList: filterSearchId, loadLimit: this.recordLoadLimit, offset: this.offset })
            .then(result => {
                console.log('All contract getFilteredBtton result::' + JSON.stringify(result));
                this.allContractsGridData = result.ServiceContractsList;
                //alert('getFilteredBtton' + JSON.stringify(this.allContractsGridData))
                if (this.filterByButton === 'Expires') {
                    this.filterBtnTotalRec = result.expirySixMonths;
                }
                if (this.filterByButton === 'Active') {
                    this.filterBtnTotalRec = result.activeContract;
                }
                if (this.filterByButton === 'Inactive') {
                    this.filterBtnTotalRec = result.futureContract;
                }
                if (this.filterByButton === 'Expired') {
                    this.filterBtnTotalRec = result.expiredContract;
                }
                if (this.filterByButton === null) {
                    this.filterBtnTotalRec = result.totalContractCnt;
                }
                //alert('this.filterBtnTotalRec::' + this.filterBtnTotalRec)
                if (filterSearchId === null) {
                    this.isLoading = false;
                    this.loadedRecord = result.ServiceContractsList.length;
                    //alert('this.loadedRecord::' + this.loadedRecord)
                    this.remainRecords = this.filterBtnTotalRec - this.loadedRecord;
                    //alert('this.remainRecords::' + this.remainRecords)
                    if (this.loadedRecord < this.filterBtnTotalRec) {
                        //alert('Inside');
                        this.showLoadMore = true;
                        if (this.remainRecords < this.recordLoadLimit) {
                            this.remainRecords = this.remainRecords;
                        } else {
                            this.remainRecords = this.recordLoadLimit;
                        }
                    } else {
                        this.showLoadMore = false;
                    }
                } else {
                    this.showLoadMore = false;
                }
                if (this.loadExternal === true) {
                    const table = this.template.querySelector('.allContracts-dtTable');
                    $(table).DataTable().destroy();
                }

            }).then(() => {
                if (this.loadExternal === true) {
                    this.loadExternalLibraries(this.communityURL, this.plant_Code);
                }
                this.loadExternal = false;
                //this.loadExternalLibraries(this.communityURL, this.plant_Code);
            }).then(() => {
                const radioBtnEle = this.template.querySelector('.radio-btn');
                //$('div.newradio--inline input:first', radioInput).prop("checked", true);
                //alert($('div.newradio--inline label', radioBtnEle).first().html());
                $('div.newradio--inline label', radioBtnEle).first().trigger("click");

            }).catch(error => {
                this.error = error;
                console.log('All contract getFilteredBtton Error:: ' + JSON.stringify(this.error));
            });

    }

    handleStatus(event) {
        let radioValue = event.currentTarget.value;
        //alert(radioValue)
        if (radioValue === undefined || radioValue === 'All') {
            //if (radioValue != undefined || ) {
            this.radioBtnFilter = null;
        } else {
            this.radioBtnFilter = radioValue;
        }
        //alert(this.radioBtnFilter);
        this.allContractsGridData = [];
        this.showLoadMore = false;

        this.loadExternal = true;
        this.offset = 0;
        this.filterRadioTotCnt = 0; //variable used to get the radio button total cnt
        let filterSearchId;

        if (this.searchfilterIdList.length > 0) {
            filterSearchId = this.searchfilterIdList;
        }
        else {
            filterSearchId = null;
        }

        let buttonFilter;
        if (this.filterByButton === undefined || this.filterByButton === 'All') {
            //if (this.filterByButton != undefined & this.filterByButton != null) {
            buttonFilter = null;
        } else {
            buttonFilter = this.filterByButton;
        }


        //alert('buttonFilter::' + buttonFilter)

        getAllServiceContracts({ plantCode: this.plant_Code, filterdByStatus: buttonFilter, filteredByIndustry: this.radioBtnFilter, servContractFilterIdList: filterSearchId, loadLimit: this.recordLoadLimit, offset: this.offset })
            .then(result => {
                console.log('All contract result handleStatus::' + JSON.stringify(result));
                this.allContractsGridData = result.ServiceContractsList;
                //alert(JSON.stringify(this.allContractsGridData));

                if (this.radioBtnFilter === null) {
                    //alert('a');
                    if (buttonFilter === null) {
                        //alert('b');
                        this.filterRadioTotCnt = result.totalContractCnt;

                    } else {
                        //alert('c');
                        this.filterRadioTotCnt = this.filterBtnTotalRec;
                    }
                } else {
                    //alert('d');
                    this.filterRadioTotCnt = result.radioBtnCnt;
                }
                //alert('filterRadioTotCnt::' + this.filterRadioTotCnt)

                if (filterSearchId === null) {
                    this.isLoading = false;
                    this.loadedRecord = result.ServiceContractsList.length;
                    //alert('this.loadedRecord::' + this.loadedRecord)
                    this.remainRecords = this.filterRadioTotCnt - this.loadedRecord;
                    //alert('this.remainRecords::' + this.remainRecords)
                    if (this.loadedRecord < this.filterRadioTotCnt) {
                        //alert('Inside');
                        this.showLoadMore = true;
                        if (this.remainRecords < this.recordLoadLimit) {
                            this.remainRecords = this.remainRecords;
                        } else {
                            this.remainRecords = this.recordLoadLimit;
                        }
                    } else {
                        this.showLoadMore = false;
                    }
                } else {
                    this.isLoading = false;
                }

                if (this.loadExternal === true) {
                    const table = this.template.querySelector('.allContracts-dtTable');
                    $(table).DataTable().destroy();
                }
            }).then(() => {
                if (this.loadExternal === true) {
                    this.loadExternalLibraries(this.communityURL, this.plant_Code);
                }
                this.loadExternal = false;
                //this.loadExternalLibraries(this.communityURL, this.plant_Code);
            }).then(() => {

            }).catch(error => {
                this.error = error;
                console.log('All contract handleStatus Error:: ' + JSON.stringify(this.error));
            });

    }

    async loadExternalLibraries(commUrl, plt) {
        loadScript(this, YG_CustomerPortal + '/YG_JS/jquery.min.js').then(() => {
            loadStyle(this, YG_CustomerPortal + '/YG_CSS/dataTables.css').then(() => {
                loadScript(this, YG_CustomerPortal + '/YG_JS/jquery.dataTables.min.js').then(() => {

                    let dataTable;

                    const table = this.template.querySelector('.allContracts-dtTable');
                    const columnHeaders = ['Service Contract', 'Yokogawa Sales Manager', 'Start Date', 'End Date', 'Notifications'];

                    let columnHeaderHtml = '<thead><tr>';
                    columnHeaders.forEach(function (header) {
                        columnHeaderHtml += '<th><span class="font-weight-normal">' + header + '</span></th>';
                    });
                    columnHeaderHtml += '</tr></thead>';
                    table.innerHTML = columnHeaderHtml;

                    dataTable = $(table).DataTable({
                        "paging": false,
                        "searching": false, // false to disable search (or any other option)
                        "info": false,
                        "order": [1, 'asc'],
                        "columnDefs": [{
                            orderable: false,
                            targets: [0, 4]
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

                    let contractHtml = '', notiHtml = '', profileImg = '';

                    this.allContractsGridData.forEach(function (list) {
                        contractHtml = '';
                        notiHtml = '';
                        profileImg = '';
                        contractHtml += '<div class="col-12 mb-2 pl-0"><p class="text-left f12 mb-0">Contract no:</p><p class="text-left f12 fbold mb-0">' + list.contractNum + '</p></div>';
                        if (list.industry === 'Life Innovation') {
                            contractHtml += '<div class="col-12 mb-2 pl-0"><p class="text-left f12 mb-0">Contract name:</p><p class="text-left f12 fbold mb-0">';
                            contractHtml += '<a class="text-hover-color" href="' + commUrl + 'contract-details?pc=' + plt + '&contractno=' + list.contractNum + '"><ins>' + list.contractName + '</ins></a>';
                            contractHtml += '</p></div>';

                        } else {
                            contractHtml += '<div class="col-12 mb-2 pl-0"><p class="text-left f12 mb-0">Contract name:</p><p class="text-left f12 fbold mb-0">' + list.contractName + '</p></div>';
                        }

                        if (typeof list.contractDescription != 'undefined') {
                            contractHtml += '<div class="col-12 mb-2 pl-0"><p class="text-left f12 mb-0">Contract description: </p><p class="text-left f12 fbold mb-0">';
                            contractHtml += '<a class="text-hover-color" href="' + commUrl + 'contract-details?pc=' + plt + '&contractno=' + list.contractNum + '"><ins>' + list.contractDescription + '</ins></a>';
                            contractHtml += '</p></div>';
                        } else {
                            if (list.industry === 'Life Innovation') {
                                contractHtml += '<div class="col-12 mb-2 pl-0"><p class="text-left f12 mb-0">Product name:</p><p class="text-left f12 fbold mb-0">' + list.productName + '</p></div>';
                            } else {
                                contractHtml += '<div class="col-12 mb-2 pl-0"><p class="text-left f12 mb-0">Product name:</p><p class="text-left f12 fbold mb-0">'
                                contractHtml += '<a class="text-hover-color" href="' + commUrl + 'contract-details?pc=' + plt + '&contractno=' + list.contractNum + '"><ins>' + list.productName + '</ins></a>';
                                contractHtml += '</p></div>';
                            }

                            contractHtml += '<div class="col-12 mb-2 pl-0"><p class="text-left f12 mb-0">Serial no.:</p><p class="text-left f12 fbold mb-0">' + list.serialNum + '</p></div>';
                        }

                        if (typeof list.notification != 'undefined') {
                            notiHtml += '<i class="fas fa-bell-orange pr-3 pb-3 f14">&nbsp;</i>' + list.notification;
                        } else {
                            notiHtml += '-';
                        }

                        if (typeof list.ygSalesManager != 'undefined' && list.ygSalesManager != null) {
                            profileImg += '<span class="pr-2"><svg width="32" height="32" viewBox="0 0 32 32" fill="none" xmlns="http://www.w3.org/2000/svg"><circle cx="16" cy="16" r="16" fill="#9BACB5"></circle><path fill-rule="evenodd" clip-rule="evenodd" d="M12.3081 13.1975C9.60528 14.6727 7.75 17.7172 7.75 21.2336C7.75 25.2606 10.1832 25.1179 13.536 24.9212C14.3141 24.8756 15.1418 24.827 16 24.827C16.8582 24.827 17.6859 24.8756 18.464 24.9212C21.8168 25.1179 24.25 25.2606 24.25 21.2336C24.25 17.5046 22.1635 14.3062 19.1925 12.9473C18.3025 13.9025 17.0335 14.4998 15.625 14.4998C14.3439 14.4998 13.1781 14.0056 12.3081 13.1975Z" fill="white"></path><circle cx="15.625" cy="9.625" r="3.375" fill="white"></circle></svg></span><a class="align-middle disabled" data-id="" href="javascript:void(0)">' + list.ygSalesManager + '</a>';
                        } else {
                            profileImg += '-';
                        }

                        dataTable.row.add([
                            contractHtml,
                            profileImg,
                            list.startDate,
                            list.endDate,
                            notiHtml
                        ]);
                    })

                    dataTable.draw();
                    /*
                    const tableField = this.template.querySelector('.table-responsive');
                    $('tbody', table).on('click', 'td a', function () {

                        $('input[name=hiddenSelect]', tableField).val($(this).attr('data-id')).trigger('select');
                    });*/
                })
            })
        })
    }

    loadmore() {

        this.template.querySelector('.loading-icon').classList.remove('d-none');

        this.offset = this.offset + this.recordLoadLimit;
        //alert(this.offset)
        let loadData = [];
        let plt = this.plant_Code;
        let commUrl = this.communityURL;
        let param = '';
        let param2 = '';
        let contractSize;

        if (this.filterByButton != null) {
            param = this.filterByButton;
        } else {
            param = null;
        }

        if (this.radioBtnFilter != null) {
            param2 = this.radioBtnFilter;
        } else {
            param2 = null;
        }

        //alert("param" + param)
        //alert("param2" + param2)

        getAllServiceContracts({ plantCode: this.plant_Code, filterdByStatus: param, filteredByIndustry: param2, servContractFilterIdList: null, loadLimit: this.recordLoadLimit, offset: this.offset })
            .then(result => {
                console.log('All contract result::' + JSON.stringify(result));

                this.isLoading = false;
                loadData = result.ServiceContractsList;
                //alert("loadData" + JSON.stringify(loadData))
                //alert("param" + param)
                //To check on click of the button rec
                //alert('result.totalContractCnt::' + result.totalContractCnt)
                if (param2 != undefined & param2 != null) {
                    //alert('inside param2')
                    contractSize = this.filterRadioTotCnt;
                }
                else if (param != undefined & param != null) {
                    //alert('inside param')
                    contractSize = this.filterBtnTotalRec;
                } else {
                    //alert('outside param')
                    contractSize = result.totalContractCnt;
                }


                //alert("loadedRecord" + this.loadedRecord);
                //alert("rererer" + result.totalServiceDetRecords)

                // alert('total contractSize' + contractSize)
                //alert("result.totalServiceDetRecords" + result.totalServiceDetRecords);
                this.loadedRecord = this.loadedRecord + result.ServiceContractsList.length;
                // alert("loadedRecord" + this.loadedRecord);
                //caseSize = result.totalServiceDetRecords - this.loadedRecord;
                this.remainRecords = contractSize - this.loadedRecord;

                //alert("remainRecords == " + this.remainRecords);
                if (this.loadedRecord < contractSize) {
                    if (this.remainRecords < this.recordLoadLimit) {
                        this.remainRecords = this.remainRecords;
                    } else {
                        this.remainRecords = this.recordLoadLimit;
                    }
                    this.showLoadMore = true;
                } else {
                    this.showLoadMore = false;
                }

                let dataTable;
                const table = this.template.querySelector('.allContracts-dtTable');
                $.fn.dataTableExt.sErrMode = 'none';

                dataTable = $(table).DataTable({
                    "paging": false,
                    "searching": false, // false to disable search (or any other option)
                    "info": false,
                    "order": [1, 'asc'],
                    "columnDefs": [{
                        orderable: false,
                        targets: [0, 4]
                    }]
                });
                //alert('above load data')
                let contractHtml = '', notiHtml = '', profileImg = '';
                loadData.forEach(function (list) {

                    contractHtml = '';
                    notiHtml = '';
                    profileImg = '';
                    contractHtml += '<div class="col-12 mb-2 pl-0"><p class="text-left f12 mb-0">Contract no:</p><p class="text-left f12 fbold mb-0">' + list.contractNum + '</p></div>';
                    contractHtml += '<div class="col-12 mb-2 pl-0"><p class="text-left f12 mb-0">Contract name:</p><p class="text-left f12 fbold mb-0">' + list.contractName + '</p></div>';
                    if (typeof list.contractDescription != 'undefined') {
                        contractHtml += '<div class="col-12 mb-2 pl-0"><p class="text-left f12 mb-0">Contract description: </p><p class="text-left f12 fbold mb-0">';
                        contractHtml += '<a class="text-hover-color" href="' + commUrl + 'contract-details?pc=' + plt + '&contractno=' + list.contractNum + '"><ins>' + list.contractDescription + '</ins></a>';
                        contractHtml += '</p></div>';
                    } else {
                        contractHtml += '<div class="col-12 mb-2 pl-0"><p class="text-left f12 mb-0">Product name:</p><p class="text-left f12 fbold mb-0">'
                        contractHtml += '<a class="text-hover-color" href="' + commUrl + 'contract-details?pc=' + plt + '&contractno=' + list.contractNum + '"><ins>' + list.productName + '</ins></a>';
                        contractHtml += '</p></div>';
                        contractHtml += '<div class="col-12 mb-2 pl-0"><p class="text-left f12 mb-0">Serial no.:</p><p class="text-left f12 fbold mb-0">' + list.serialNum + '</p></div>';
                    }

                    if (typeof list.notification != 'undefined') {
                        notiHtml += '<i class="fas fa-bell-orange pr-3 pb-3 f14">&nbsp;</i>' + list.notification;
                    } else {
                        notiHtml += '-';
                    }

                    if (typeof list.ygSalesManager != 'undefined' && list.ygSalesManager != null) {
                        profileImg += '<span class="pr-2"><svg width="32" height="32" viewBox="0 0 32 32" fill="none" xmlns="http://www.w3.org/2000/svg"><circle cx="16" cy="16" r="16" fill="#9BACB5"></circle><path fill-rule="evenodd" clip-rule="evenodd" d="M12.3081 13.1975C9.60528 14.6727 7.75 17.7172 7.75 21.2336C7.75 25.2606 10.1832 25.1179 13.536 24.9212C14.3141 24.8756 15.1418 24.827 16 24.827C16.8582 24.827 17.6859 24.8756 18.464 24.9212C21.8168 25.1179 24.25 25.2606 24.25 21.2336C24.25 17.5046 22.1635 14.3062 19.1925 12.9473C18.3025 13.9025 17.0335 14.4998 15.625 14.4998C14.3439 14.4998 13.1781 14.0056 12.3081 13.1975Z" fill="white"></path><circle cx="15.625" cy="9.625" r="3.375" fill="white"></circle></svg></span><a class="align-middle disabled" data-id="" href="javascript:void(0)">' + list.ygSalesManager + '</a>';
                    } else {
                        profileImg += '-';
                    }

                    dataTable.row.add([
                        contractHtml,
                        profileImg,
                        list.startDate,
                        list.endDate,
                        notiHtml
                    ]).draw(false);
                })

                //dataTable.draw();
            }).then(() => {
                //alert('inside loading')
                //this.isLoading = false;
                //this.isgridLoading = false; 
                this.template.querySelector('.loading-icon').classList.add('d-none');
            }).catch(error => {
                console.log('error:: ' + JSON.stringify(error));
                this.isLoading = false;
                //this.error = error.body.message;

            })


    }

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


        if (/Edge\/\d./i.test(navigator.userAgent)) {

            var fileName = "All Contracts List.csv";
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
            downloadElement.download = 'All Contracts List.csv';
            // below statement is required if you are using firefox browser
            document.body.appendChild(downloadElement);
            // click() Javascript function to download CSV file
            downloadElement.click();
            document.body.removeChild(downloadElement);
        }

    }

    triggetSelect() {

        this.openModal();
    }

    openModal() {

        this.isModalOpen = true;
    }

    closeModal() {
        // to close modal set isModalOpen tarck value as false
        this.isModalOpen = false;
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
                            this.getFilteredPlantContract(plantCode);
                        })
                        .catch(error => {
                            console.log('System API Error:' + JSON.stringify(error.message));
                        })
                } else {
                    console.log('System API Result:' + result);
                    this.getFilteredPlantContract(plantCode);
                }
            }).then(() => {
                this.template.querySelector('.loading-grid').classList.add('d-none');
                this.template.querySelector('.allContracts-dtTable').classList.remove('d-none');
            }).catch(error => {
                console.log('Deliverable API Error:' + JSON.stringify(error.message));
            })
    }
}