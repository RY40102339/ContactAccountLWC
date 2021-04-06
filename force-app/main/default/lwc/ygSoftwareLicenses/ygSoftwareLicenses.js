import { LightningElement, track, wire } from 'lwc';
import { loadScript, loadStyle } from "lightning/platformResourceLoader";
import { CurrentPageReference } from 'lightning/navigation';
import { fireEvent, registerListener, unregisterAllListeners } from 'c/pubSub';
import YG_CustomerPortal from "@salesforce/resourceUrl/YG_CustomerPortal";
import getSoftwareLicenseDetails from '@salesforce/apex/YG_SoftwareLicensesController.getSoftwareLicenseDetails';
import callDelivAPI from '@salesforce/apex/YG_SystemsController.callDelivAPI';
import getDeliverableNoAndSystemId from "@salesforce/apex/YG_SystemsAPI.getDeliverableNoAndSystemId";
import getSystemDetails from '@salesforce/apex/YG_SystemsAPI.getSystemDetails';
import getCustomConfig from '@salesforce/apex/YG_Utility.getCustomConfig';
import loading from '@salesforce/label/c.YG_Loading';
import show from '@salesforce/label/c.YG_Show';
import moreRecords from '@salesforce/label/c.YG_More_records';
import name from '@salesforce/label/c.YG_Name';
import model from '@salesforce/label/c.YG_Model';
import sftRevNo from '@salesforce/label/c.YG_Software_revision_no';
import notification from '@salesforce/label/c.YG_Notification';
import inqUpgrade from '@salesforce/label/c.YG_Inquire_upgrade';
import modelCode from '@salesforce/label/c.YG_Model_code';

export default class YgSoftwareLicenses extends LightningElement {

    @wire(CurrentPageReference) pageRef;

    label = { loading, show, moreRecords, name, model, sftRevNo, notification, inqUpgrade, modelCode };

    softwareLicensesGridData = [];
    plantCode = '';
    loadExternal = true;
    communityURL = '';
    @track mapData = [];
    showLoadMore = false;
    recordLoadLimit = 0;
    offset = 0;
    loadedRecords = 0;
    totalRecords = 0;
    remainingRecords = 0;
    displayGrid = false;
    infiniteScroll = false;

    constructor() {
        super();
        this.loadExternalLibraries();

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
                this.error = error;
                console.log('record limit err: ' + JSON.stringify(error.message));
            });

    }

    renderedCallback() {
        /*
        if (this.infiniteScroll === true) {
            const loadElement = this.template.querySelector(".load-more");
            let win = $(window);
            let doc = $(document);
            // Each time the user scrolls
            win.scroll(function () {
                // End of the document reached?
                if (doc.height() - win.height() == win.scrollTop()) {
                    $('button', loadElement).click();
                }
            })
        }*/
    }

    connectedCallback() {
        registerListener('plantFilter', this.checkAPICall, this);
        registerListener('filterRecords', this.getFilteredSoftwares, this);
        registerListener('communityURL', this.getcommunityURL, this);
    }

    disconnectedCallback() {
        unregisterAllListeners(this);
    }

    getcommunityURL(commURL) {
        this.communityURL = commURL;
    }

    checkAPICall(plantCode) {

        this.template.querySelector('.loading-grid').classList.remove('d-none');
        this.displayGrid = false;
        let plt = plantCode;

        callDelivAPI({ plantCode: plt })
            .then(result => {
                console.log('Call Deliv API : ' + result);
                if (result) {
                    this.callSystemAPI(plt);
                } else {
                    this.getSoftwareLicensePlant(plt);
                }
            })
            .catch(error => {
                console.log('Call Deliverable API Error' + JSON.stringify(error.message));
            })
    }

    getSoftwareLicensePlant(plantCode) {

        this.softwareLicensesGridData = [];
        this.plantCode = plantCode;
        this.loadExternal = true;
        this.showLoadMore = false;
        this.offset = 0;

        if (this.plantCode != "") {

            getSoftwareLicenseDetails({ plantCode: this.plantCode, filterValue: null, loadLimit: this.recordLoadLimit, offset: this.offset })
                .then(result => {
                    this.softwareLicensesGridData = result.softWrapList;
                    fireEvent(this.pageRef, 'softwareLicenseCount', result.totalSoftwareCount);
                    this.totalRecords = result.totalSoftwareCount;
                    this.loadedRecords = result.softWrapList.length;
                    this.remainingRecords = result.totalSoftwareCount - this.loadedRecords;

                    if (this.loadedRecords < this.totalRecords) {
                        if (this.remainingRecords < this.recordLoadLimit) {
                            this.remainingRecords = this.remainingRecords;
                        } else {
                            this.remainingRecords = this.recordLoadLimit;
                        }
                        this.showLoadMore = true;
                    } else {
                        this.showLoadMore = false;
                    }

                    console.log('SoftwareLicenses Data::' + JSON.stringify(result));
                    if (this.loadExternal == true) {
                        const table = this.template.querySelector('.softwareLicenses-dtTable');
                        $(table).DataTable().destroy();
                    }
                }).then(() => {
                    if (this.loadExternal == true) {
                        this.loadExternalLibraries();
                    }
                    this.loadExternal == false;
                    this.template.querySelector('.loading-grid').classList.add('d-none');
                    this.displayGrid = true;
                }).catch(error => {
                    console.log('SoftwareLicenses Error::' + JSON.stringify(error.message));
                })
        }
    }

    getFilteredSoftwares(software) {

        let filteredSoftwares = software;
        let name = [];
        this.softwareLicensesGridData = [];
        this.showLoadMore = false;

        filteredSoftwares.forEach(function (list) {
            name.push(list.Name);
        })

        getSoftwareLicenseDetails({ plantCode: this.plantCode, filterValue: name, loadLimit: this.recordLoadLimit, offset: 0 })
            .then(result => {
                this.softwareLicensesGridData = result.softWrapList;
                fireEvent(this.pageRef, 'softwareLicenseCount', result.totalSoftwareCount);
                console.log('SoftwareLicenses Filtered Data::' + JSON.stringify(result));

                if (name.length == 0) {
                    this.totalRecords = result.totalSoftwareCount;
                    this.loadedRecords = result.softWrapList.length;
                    this.remainingRecords = result.totalSoftwareCount - this.loadedRecords;

                    if (this.loadedRecords < this.totalRecords) {
                        if (this.remainingRecords < this.recordLoadLimit) {
                            this.remainingRecords = this.remainingRecords;
                        } else {
                            this.remainingRecords = this.recordLoadLimit;
                        }
                        this.showLoadMore = true;
                    } else {
                        this.showLoadMore = false;
                    }
                }

                //if (this.loadExternal == false) {
                const table = this.template.querySelector('.softwareLicenses-dtTable');
                $(table).DataTable().destroy();
                // }
            }).then(() => {
                //if (this.loadExternal == false) {
                this.loadExternalLibraries();
                //}
            }).catch(error => {
                console.log('SoftwareLicenses Filtered Error::' + JSON.stringify(error.message));
            })

    }

    loadmore() {

        this.template.querySelector('.loading-icon').classList.remove('d-none');
        this.offset = this.offset + this.recordLoadLimit;
        let loadData = [];

        getSoftwareLicenseDetails({ plantCode: this.plantCode, filterValue: null, loadLimit: this.recordLoadLimit, offset: this.offset })
            .then(result => {

                loadData = result.softWrapList;
                fireEvent(this.pageRef, 'softwareLicenseCount', result.totalSoftwareCount);

                this.totalRecords = result.totalSoftwareCount;
                this.loadedRecords = this.loadedRecords + result.softWrapList.length;
                this.remainingRecords = this.totalRecords - this.loadedRecords;

                if (this.loadedRecords < this.totalRecords) {
                    if (this.remainingRecords < this.recordLoadLimit) {
                        this.remainingRecords = this.remainingRecords;
                    } else {
                        this.remainingRecords = this.recordLoadLimit;
                    }
                    this.showLoadMore = true;
                } else {
                    this.showLoadMore = false;
                }

                console.log('SoftwareLicenses Data::' + JSON.stringify(result));

                const table = this.template.querySelector('.softwareLicenses-dtTable');
                let dataTable, notiHtml = '', inqUpgrade = this.label.inqUpgrade;
                let commURL = this.communityURL;
                let pltCode = this.plantCode;
                $.fn.dataTableExt.sErrMode = 'none';
                dataTable = $(table).DataTable({
                    "paging": false,
                    "searching": false, // false to disable search (or any other option)
                    "info": false,
                    "order": [0, 'asc'],
                    "columnDefs": [{ "width": "30%", "targets": 0 },
                    { "width": "25%", "targets": 1 },
                    { "width": "15%", "targets": 2 },
                    { "width": "30%", "targets": 3 },
                    {
                        orderable: false,
                        targets: [2, 3]
                    }],
                    // Per-row function to iterate cells
                    "createdRow": function (row, data, rowIndex) {
                        // Per-cell function to do whatever needed with cells
                        $.each($('td', row), function (colIndex) {
                            // For example, adding data-* attributes to the cell
                            if (colIndex === 2) {
                                $(this).attr('data-title', 'Software revision no.');
                            } else {
                                $(this).attr('data-title', columnHeaders[colIndex]);
                            }
                        });
                    }
                });
                loadData.forEach(function (list) {
                    notiHtml = '';

                    if (list.notiList.length > 0) {
                        list.notiList.forEach(function (noti) {
                            notiHtml += '<i class="fas fa-bell-gray pr-3 pb-3 f11">&nbsp;</i>' + noti + '<br />';
                        })
                    }
                    else {
                        notiHtml += '-';
                    }

                    if (list.inquiryReq === true) {
                        notiHtml += '<i class="fas fa-comment-icon pr-3 pb-3">&nbsp;</i><a class="blue-primary text-hover-underline" href="' + commURL + 'service-request-and-inquiries?prodId=' + list.id + '">' + inqUpgrade + '</a>';
                    }

                    dataTable.row.add([
                        '<span class="mb-1 f14 grey-darkest">' + list.name + '</span> <br/><span class="grey-medium-c">System ID: ' + list.systemId + '</span>',
                        '<span class="f14 grey-darkest">' + list.modelCode + '</span>',
                        '<span class="f14 grey-darkest">' + list.revisionNo + '</span>',
                        '<span class="f14 grey-darkest">' + notiHtml + '</span>'
                    ]).draw(false);
                })

            }).then(() => {
                this.template.querySelector('.loading-icon').classList.add('d-none');
            })
            .catch(error => {
                console.log('SoftwareLicenses Error::' + JSON.stringify(error.message));
            })

    }

    async loadExternalLibraries() {
        loadScript(this, YG_CustomerPortal + '/YG_JS/jquery.min.js').then(() => {
            loadStyle(this, YG_CustomerPortal + '/YG_CSS/dataTables.css').then(() => {
                loadScript(this, YG_CustomerPortal + '/YG_JS/jquery.dataTables.min.js').then(() => {

                    //alert('library Data::'+JSON.stringify(this.softwareLicensesGridData));

                    let dataTable;
                    let commURL = this.communityURL;
                    let pltCode = this.plantCode;

                    const table = this.template.querySelector('.softwareLicenses-dtTable');
                    const columnHeaders = [this.label.name, this.label.modelCode, this.label.sftRevNo, this.label.notification];

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
                        "order": [0, 'asc'],
                        "columnDefs": [{ "width": "30%", "targets": 0 },
                        { "width": "25%", "targets": 1 },
                        { "width": "15%", "targets": 2 },
                        { "width": "30%", "targets": 3 },
                        {
                            orderable: false,
                            targets: [2, 3]
                        }],
                        // Per-row function to iterate cells
                        "createdRow": function (row, data, rowIndex) {
                            // Per-cell function to do whatever needed with cells
                            $.each($('td', row), function (colIndex) {
                                // For example, adding data-* attributes to the cell
                                if (colIndex === 2) {
                                    $(this).attr('data-title', 'Software revision no.');
                                } else {
                                    $(this).attr('data-title', columnHeaders[colIndex]);
                                }
                            });
                        }
                    });

                    let notiHtml = '', inqUpgrade = this.label.inqUpgrade;

                    this.softwareLicensesGridData.forEach(function (list) {
                        notiHtml = '';

                        if (list.notiList.length > 0) {
                            list.notiList.forEach(function (noti) {
                                notiHtml += '<i class="fas fa-bell-gray pr-3 pb-3 f11">&nbsp;</i>' + noti + '<br />';
                            })
                        }
                        else {
                            notiHtml += '-';
                        }

                        if (list.inquiryReq === true) {
                            notiHtml += '<i class="fas fa-comment-icon pr-3 pb-3">&nbsp;</i><a class="blue-primary text-hover-underline" href="' + commURL + 'service-request-and-inquiries?prodId=' + list.id + '">' + inqUpgrade + '</a>';
                        }

                        dataTable.row.add([
                            '<span class="mb-1">' + list.name + '</span> <br/><span class="grey-medium-c">System ID: ' + list.systemId + '</span>',
                            '<span class="f14 grey-darkest">' + list.modelCode + '</span>',
                            '<span class="f14 grey-darkest">' + list.revisionNo + '</span>',
                            '<span class="f14 grey-darkest">' + notiHtml + '</span>'
                        ]);
                    })

                    dataTable.draw();
                }).then(() => {
                    this.infiniteScroll = true;
                })
            })
        })
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
                            this.getSoftwareLicensePlant(plantCode);
                        })
                        .catch(error => {
                            console.log('System API Error:' + JSON.stringify(error.message));
                        })
                } else {
                    console.log('System API Result:' + result);
                    this.getSoftwareLicensePlant(plantCode);
                }
            }).then(() => {
                this.template.querySelector('.loading-grid').classList.add('d-none');
            })
            .catch(error => {
                console.log('Deliverable API Error:' + JSON.stringify(error.message));
            })
    }
}