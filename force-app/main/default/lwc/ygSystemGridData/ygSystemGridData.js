import { LightningElement, wire, track } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { fireEvent, registerListener, unregisterAllListeners } from 'c/pubSub';
import getAllSystemsDetails from '@salesforce/apex/YG_SystemsController.getAllSystemsDetails';
import getAllStationDetails from '@salesforce/apex/YG_SystemsController.getAllStationDetails';
import callDelivAPI from '@salesforce/apex/YG_SystemsController.callDelivAPI';
import getDeliverableNoAndSystemId from "@salesforce/apex/YG_SystemsAPI.getDeliverableNoAndSystemId";
import getSystemDetails from '@salesforce/apex/YG_SystemsAPI.getSystemDetails';
import getStationDetailsList from '@salesforce/apex/YG_SystemsAPI.getStationDetailsList';
import getCommunityURL from '@salesforce/apex/YG_Utility.getCommunityURL';
import YG_CustomerPortal from '@salesforce/resourceUrl/YG_CustomerPortal';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import viewStationDetLbl from '@salesforce/label/c.YG_View_station_details';
import loading from '@salesforce/label/c.YG_Loading';
import jumptoDomain from '@salesforce/label/c.YG_Jump_to_domain';
import selectDomain from '@salesforce/label/c.YG_Select_a_domain';
import relatedDoc from '@salesforce/label/c.YG_Related_documents';
import domain from '@salesforce/label/c.YG_Domain';
import station from '@salesforce/label/c.YG_Station';
import modelCode from '@salesforce/label/c.YG_Model_code';
import revisionNo from '@salesforce/label/c.YG_Revision_no';
import mtnPhase from '@salesforce/label/c.YG_Sys_Maintenance_phase';
import notification from '@salesforce/label/c.YG_Notification';
import systemOverview from '@salesforce/label/c.YG_System_Overview';
import dwlfullStatList from '@salesforce/label/c.YG_Download_full_station_list';
import dwlfltrStatList from '@salesforce/label/c.YG_Download_filtered_station_list';

export default class YgSystemGridData extends LightningElement {

    @wire(CurrentPageReference) pageRef;

    label = {
        viewStationDetLbl, loading, jumptoDomain, selectDomain, relatedDoc, domain, station, modelCode,
        revisionNo, mtnPhase, notification, systemOverview, dwlfullStatList, dwlfltrStatList
    };
    plantCode = '';
    setCSVData = [];
    exStatName = [];
    filterData = [];
    statLink = '';
    commUrl = '';
    error;
    @track downloadLink = this.label.dwlfullStatList;
    @track isLoading = true;
    csvIcon = YG_CustomerPortal + '/YG_Images/icons/csv.svg';
    plusIcon = YG_CustomerPortal + '/YG_Images/icons/plus.svg';
    minusIcon = YG_CustomerPortal + '/YG_Images/icons/minus.svg';
    @track isgridLoading = false;
    @track jumpProj = false;
    @track isStatWrap = false;
    //new 
    domainList = [];
    statWrap = [];
    stationGridData = [];
    statModCode = '';
    osName = '';
    projectCode = '';

    constructor() {
        super();

        getCommunityURL({})
            .then(result => {
                this.commUrl = result;
            })
            .catch(error => {
                this.error = error;
                console.log('DataError: ' + JSON.stringify(this.error));
            });

        this.loadExternalLibraries(this.stationGridData);
    }

    connectedCallback() {
        registerListener('plantFilter', this.checkAPICall, this);
        registerListener('filterRecords', this.getFilteredStations, this);
        registerListener('selectedSystem', this.getButtonFilteredStations, this);
    }

    disconnectedCallback() {
        unregisterAllListeners(this);
    }

    renderedCallback() {
        /*
        //Hide Jump to Project
        if(this.jumpProj === false){
            this.template.querySelector('.proj-list').classList.add('invisible', 'd-block');
        }

        if(this.jumpProj === true){
            this.template.querySelector('.proj-list').classList.remove('invisible', 'd-block');
        }*/
    }

    async loadExternalLibraries(statData, statKey) {
        loadScript(this, YG_CustomerPortal + '/YG_JS/jquery.min.js').then(() => {
            loadStyle(this, YG_CustomerPortal + '/YG_CSS/dataTables.css').then(() => {
                loadScript(this, YG_CustomerPortal + '/YG_JS/jquery.dataTables.min.js').then(() => {

                    //alert(statKey);
                    let dataTable;
                    const table = this.template.querySelector('.' + statKey + ' .stat-dtTable');
                    const columnHeaders = statData.colDet;
                    if (columnHeaders.length > 0) {
                        let colCnt = columnHeaders.length - 1;

                        let columnHeaderHtml = '<thead><tr>';
                        columnHeaders.forEach(function (header, index) {
                            if (index === colCnt) {
                                columnHeaderHtml += '<th><span class="font-weight-normal d-sm-none grey-bell-icon"></span><span class="font-weight-normal d-none d-sm-inline-block">' + header + '</span></th>';
                            } else {
                                if (columnHeaders.length == 2) {
                                    if (index === 0) {
                                        columnHeaderHtml += '<th class="first-col"><span class="font-weight-normal">' + header + '</span></th>';

                                    } else {
                                        columnHeaderHtml += '<th><span class="font-weight-normal">' + header + '</span></th>';

                                    }
                                } else {
                                    columnHeaderHtml += '<th><span class="font-weight-normal">' + header + '</span></th>';

                                }
                            }
                        });
                        columnHeaderHtml += '</tr></thead>';
                        table.innerHTML = columnHeaderHtml;

                        dataTable = $(table).DataTable({
                            "order": [],
                            "paging": false,
                            "searching": false, // false to disable search (or any other option)
                            "info": false,
                            "autoWidth": true,
                            "columnDefs": [{
                                orderable: false,
                                targets: colCnt
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

                        let phase;
                        statData.statModData.forEach(function (list) {

                            phase = '-';

                            if (list.column3 != '-') {
                                phase = '<div class="phase-hypen ' + list.column5 + '"></div>' + list.column3;
                            }

                            dataTable.row.add([
                                list.column1,
                                list.column2,
                                phase,
                                list.column4
                            ]);
                        })
                        dataTable.columns.adjust().draw();
                    }
                })
            })
        })
    }

    checkAPICall(plantCode) {

        this.isStatWrap = false;
        let plt = plantCode;

        callDelivAPI({ plantCode: plt })
            .then(result => {
                console.log('Call Deliv API : ' + result);
                if (result) {
                    this.callSystemAPI(plt);
                } else {
                    this.getSystemFilteredPlant(plt);
                }
            })
            .catch(error => {
                console.log('Call Deliverable API Error' + JSON.stringify(error.message));
            })
    }

    getSystemFilteredPlant(plantCode) {

        const triggerClick = this.template.querySelector('.active .minus');
        if (triggerClick != null) {
            triggerClick.click();
        }

        this.plantCode = plantCode;
        this.jumpProj = false;
        this.domainList = [];
        this.isStatWrap = false;
        this.statWrap = [];
        let tempArr = [];
        let tempnotiArr = [];
        this.setCSVData = [];
        let csvtempArr = [];
        this.exStatName = [];

        getAllSystemsDetails({ plantCode: this.plantCode, projectCode: '' })
            .then(result => {
                console.log("getSystemFilteredPlant result ==> " + JSON.stringify(result))

                fireEvent(this.pageRef, 'systemBtnDetails', result);
                fireEvent(this.pageRef, 'systemDetails', result);
                fireEvent(this.pageRef, 'communityURL', this.commUrl);

                if (result.projCodeList != undefined) {
                    //if (result.projCodeList.length > 1) {
                    this.projectCode = result.projCodeList[0];
                    //}

                    this.jumpProj = result.projWrap.isDomain;
                    this.domainList = result.projWrap.domainNo;

                    result.projWrap.statWrap.forEach(function (stat) {

                        tempnotiArr = [];

                        if (stat.statNotiList.length > 0) {
                            stat.statNotiList.forEach(function (noti) {
                                tempnotiArr.push({ notiClass: "fas fa-bell-orange pr-3 mt-1 mr-1", notiTxt: noti })
                            });
                        } else {
                            tempnotiArr.push({ notiClass: "", notiTxt: "-" })
                        }

                        tempArr.push({
                            key: stat.key,
                            dnsn: stat.dnsn,
                            stationRecId: stat.stationRecId,
                            domainNo: stat.domainNo,
                            stationName: stat.stationName,
                            stationModelCode: stat.stationModelCode,
                            stationRevisionNo: stat.stationRevisionNo,
                            colorClassName: "phase-hypen mr-2 mt-10px " + stat.colorClassName,
                            prodMtnPhase: stat.prodMtnPhase,
                            statProdSubType: stat.statProdSubType,
                            tempnotiArr
                        });

                    })

                    this.isStatWrap = result.projWrap.isStatWrap;
                    this.statWrap = tempArr;

                    //Set CSV Data
                    result.projWrap.statWrap.forEach(function (stat) {
                        csvtempArr.push({
                            Domain: stat.domainNo,
                            Station: stat.stationName,
                            Model_Code: stat.stationModelCode,
                            Revision_No: stat.stationRevisionNo,
                            Maintenance_Phase: stat.prodMtnPhase,
                            Notifications: stat.statNotiList
                        });
                    })

                    this.setCSVData = csvtempArr;

                    console.log(JSON.stringify(result));
                }

            }).then(() => {
                if (this.isStatWrap === false) {
                    this.isStatWrap = true;
                }
                this.isLoading = false;
            }).then(() => {
                this.loadChoosenLibraries();
            }).catch(error => {
                this.isLoading = false;
                this.error = error;
                console.log('System Error ::' + this.error.message);
            })
    }

    getButtonFilteredStations(systemId) {

        const triggerClick = this.template.querySelector('.active .minus');
        if (triggerClick != null) {
            triggerClick.click();
        }

        this.projectCode = systemId;
        this.jumpProj = false;
        this.domainList = [];
        this.isStatWrap = false;
        this.statWrap = [];
        let tempArr = [];
        let tempnotiArr = [];
        this.setCSVData = [];
        let csvtempArr = [];
        this.exStatName = [];
        getAllSystemsDetails({ plantCode: this.plantCode, projectCode: systemId })
            .then(result => {

                console.log("getButtonFilteredStations result ==> " + JSON.stringify(result))
                fireEvent(this.pageRef, 'systemDetails', result);
                fireEvent(this.pageRef, 'communityURL', this.commUrl);
                if (result.projWrap.statWrap.length > 0) {

                    this.jumpProj = result.projWrap.isDomain;
                    if (result.projWrap.domainNo != undefined) {
                        this.domainList = result.projWrap.domainNo;
                    }

                    result.projWrap.statWrap.forEach(function (stat) {

                        tempnotiArr = [];

                        if (stat.statNotiList.length > 0) {
                            stat.statNotiList.forEach(function (noti) {
                                tempnotiArr.push({ notiClass: "fas fa-bell-orange pr-3 mt-1 mr-1", notiTxt: noti })
                            });
                        } else {
                            tempnotiArr.push({ notiClass: "", notiTxt: "-" })
                        }

                        tempArr.push({
                            key: stat.key,
                            dnsn: stat.dnsn,
                            stationRecId: stat.stationRecId,
                            domainNo: stat.domainNo,
                            stationName: stat.stationName,
                            stationModelCode: stat.stationModelCode,
                            stationRevisionNo: stat.stationRevisionNo,
                            colorClassName: "phase-hypen mr-2 mt-10px " + stat.colorClassName,
                            prodMtnPhase: stat.prodMtnPhase,
                            statProdSubType: stat.statProdSubType,
                            tempnotiArr
                        });

                    })

                    this.isStatWrap = result.projWrap.isStatWrap;
                    this.statWrap = tempArr;

                    //Set CSV Data
                    result.projWrap.statWrap.forEach(function (stat) {
                        csvtempArr.push({
                            Domain: stat.domainNo,
                            Station: stat.stationName,
                            Model_Code: stat.stationModelCode,
                            Revision_No: stat.stationRevisionNo,
                            Maintenance_Phase: stat.prodMtnPhase,
                            Notifications: stat.statNotiList
                        });
                    })

                    this.setCSVData = csvtempArr;
                    console.log(JSON.stringify(result));
                }

            }).then(() => {
                this.isLoading = false;
            }).then(() => {
                this.loadChoosenLibraries();
            }).catch(error => {
                this.isLoading = false;
                this.error = error;
                console.log('System Error ::' + this.error.message);
            })
    }

    getFilteredStations(statList) {

        const triggerClick = this.template.querySelector('.active .minus');
        if (triggerClick != null) {
            triggerClick.click();
        }

        let statListData = statList;
        let name = [];
        let pltCode = this.plantCode;
        this.exStatName = [];
        this.setCSVData = [];
        let csvtempArr = [];
        let tempArr = [];
        let tempnotiArr = [];
        this.jumpProj = false;

        if (statListData.length > 0) {
            this.downloadLink = this.label.dwlfltrStatList;
        } else {
            this.downloadLink = this.label.dwlfullStatList;
        }

        statListData.forEach(function (list) {
            name.push(list.Name);
        })

        getAllStationDetails({ plantCode: pltCode, projectCode: this.projectCode, filterValue: name })
            .then(result => {

                this.domainList = result.domainNo;

                result.statWrap.forEach(function (stat) {

                    tempnotiArr = [];

                    if (stat.statNotiList.length > 0) {
                        stat.statNotiList.forEach(function (noti) {
                            tempnotiArr.push({ notiClass: "fas fa-bell-orange pr-3 mt-1 mr-1", notiTxt: noti })
                        });
                    } else {
                        tempnotiArr.push({ notiClass: "", notiTxt: "-" })
                    }

                    tempArr.push({
                        key: stat.key,
                        dnsn: stat.dnsn,
                        stationRecId: stat.stationRecId,
                        domainNo: stat.domainNo,
                        stationName: stat.stationName,
                        stationModelCode: stat.stationModelCode,
                        stationRevisionNo: stat.stationRevisionNo,
                        colorClassName: "phase-hypen mr-2 mt-10px " + stat.colorClassName,
                        prodMtnPhase: stat.prodMtnPhase,
                        statProdSubType: stat.statProdSubType,
                        tempnotiArr
                    });
                })

                this.statWrap = tempArr;
                console.log('this.statWrap' + JSON.stringify(this.statWrap))

                //Set CSV Data
                result.statWrap.forEach(function (stat) {
                    csvtempArr.push({
                        Domain: stat.domainNo,
                        Station: stat.stationName,
                        Model_Code: stat.stationModelCode,
                        Revision_No: stat.stationRevisionNo,
                        Maintenance_Phase: stat.prodMtnPhase,
                        Notifications: stat.statNotiList
                    });
                })

                this.setCSVData = csvtempArr;

                //Hide Jump to domain
                if (this.domainList != undefined) {
                    this.jumpProj = true;
                }

                this.setCSVData = csvtempArr;
            })
            .catch(error => {
                this.error = error;
                console.log('System Error ::' + this.error.message);
            })
    }

    /*Mobile view Grid*/
    showMobileGrid(event) {

        let target = event.currentTarget;
        let statID = target.dataset.id;
        let statKey = target.dataset.key;
        let statProdType = target.dataset.name;
        let statName = target.dataset.statname;
        let dnsn = target.dataset.dnsn;

        this.stationGridData = [];

        const triggerClick = this.template.querySelector('.active .minus');
        if (triggerClick != null) {
            triggerClick.click();
        }

        this.isgridLoading = true;

        this.exStatName.push({ value: statKey });
        if (this.exStatName.length > 0) {
            let table = this.template;
            let table1;
            this.exStatName.forEach(function (list) {
                table1 = table.querySelector('.' + list.value + ' .stat-dtTable');
                if (Object.keys(table1).length != 0) {
                    $(table1).DataTable().destroy();
                }
            })
        }

        const statTable = this.template.querySelector('.station-table');

        $('tr.dynamicRow', statTable).remove();
        $('tr.selected', statTable).removeClass('selected');
        $('td.expand-icon', statTable).removeClass('active');
        $('td.gridSection', statTable).removeClass('p-0').addClass('p-2')
        $('td.gridSection > div', statTable).removeClass('d-block');

        target.parentNode.classList.add('active');
        target.parentNode.parentNode.classList.add('selected');
        $('.station-row.selected', statTable).prev('tr.station-grid').find('td.gridSection').addClass('p-0').removeClass('p-2');
        $('.station-row.selected', statTable).next('tr.station-grid').find('td.gridSection > div.' + statKey).addClass('d-block');


        getStationDetailsList({ statId: statID, gissSystemId: this.projectCode, stationType: statProdType, dnsn: dnsn })
            .then(result => {
                this.stationGridData = result;
                this.statModCode = result.statModCode;
                this.osName = result.osName;
                console.log('System Station Grid' + JSON.stringify(this.stationGridData));
            })
            .then(() => {
                if (statProdType != "BCV") {
                    this.loadExternalLibraries(this.stationGridData, statKey);
                }
            }).then(() => {
                this.isgridLoading = false;
            }).catch(error => {
                this.error = error;
                console.log('System Station Grid Error ::' + this.error.message);
            })

        $('html, body').animate({
            scrollTop: $('tr[data-id="' + statID + '"]', statTable).first().offset().top + 300
        }, 1000);

        this.statLink = this.commUrl + 'station-details?type=' + statName + '&sysid=' + this.projectCode + '&pc=' + this.plantCode;

    }

    showGrid(event) {

        let target = event.currentTarget;
        let statID = target.dataset.id;
        let statKey = target.dataset.key;
        let statProdType = target.dataset.name;
        let statName = target.dataset.statname;
        let dnsn = target.dataset.dnsn;

        this.stationGridData = [];

        const triggerClick = this.template.querySelector('.active .minus');
        if (triggerClick != null) {
            triggerClick.click();
        }

        this.isgridLoading = true;

        this.exStatName.push({ value: statKey });
        if (this.exStatName.length > 0) {
            let table = this.template;
            let table1;
            this.exStatName.forEach(function (list) {
                table1 = table.querySelector('.' + list.value + ' .stat-dtTable');
                if (Object.keys(table1).length != 0) {
                    $(table1).DataTable().destroy();
                }
            })
        }

        const statTable = this.template.querySelector('.station-table');

        $('tr.dynamicRow', statTable).remove();
        $('tr.selected', statTable).removeClass('selected');
        $('td.expand-icon', statTable).removeClass('active');
        $('td.gridSection', statTable).addClass('p-0').removeClass('p-2');
        $('td.gridSection > div', statTable).removeClass('d-block');

        let trLen = $('tbody > tr.station-row', statTable).length;

        //alert("trLen" + trLen);
        if (trLen > 1) {

            var selctedRow = $(target).closest('tr').index();
            //alert("selctedRow" + selctedRow)
            var markup = '<tr class="f12 grey-dark-1 dynamicRow">';
            markup += '<th class="font-weight-normal">Domain</th>';
            markup += '<th class="font-weight-normal">Station</th>';
            markup += '<th class="font-weight-normal">Model code</th>';
            markup += '<th class="font-weight-normal">Revision no.</th>';
            markup += '<th class="font-weight-normal">Maintenance phase</th>';
            markup += '<th class="font-weight-normal">Notifications</th>';
            markup += '<th></th>';
            markup += '</tr>';

            //alert("selctedRow" + selctedRow);
            let selctedRow1 = selctedRow - 2;
            if (selctedRow1 != trLen) {
                selctedRow = selctedRow + 1;
                //alert("selctedRow + 1" + selctedRow);
                //let selctedRow1 = selctedRow + 1;
                //alert("selctedRow1" + selctedRow1);

                //alert('selctedRow1 % trLen' + selctedRow % trLen)
                if (selctedRow % trLen != 0) {
                    setTimeout(() => {
                        $('tbody > tr:eq(' + selctedRow + ')', statTable).after(markup);
                    }, 1000);
                }
                /*
                else{
                    $('tbody > tr:eq('+ selctedRow +')', statTable).after(markup);
                }*/
            }
        }

        target.parentNode.classList.add('active');
        target.parentNode.parentNode.classList.add('selected');
        $('.station-row.selected', statTable).next('tr.station-grid').find('td.gridSection').removeClass('p-0').addClass('p-2');
        $('.station-row.selected', statTable).next('tr.station-grid').find('td.gridSection > div.' + statKey).addClass('d-block');


        getStationDetailsList({ statId: statID, gissSystemId: this.projectCode, stationType: statProdType, dnsn: dnsn })
            .then(result => {
                this.stationGridData = result;
                this.statModCode = result.statModCode;
                this.osName = result.osName;
                console.log('System Station Grid' + JSON.stringify(this.stationGridData));
            })
            .then(() => {
                if (statProdType != "BCV") {
                    this.loadExternalLibraries(this.stationGridData, statKey);
                }
            }).then(() => {
                this.isgridLoading = false;
            }).catch(error => {
                this.error = error;
                console.log('System Station Grid Error ::' + this.error.message);
            })

        this.statLink = this.commUrl + 'station-details?type=' + statName + '&sysid=' + this.projectCode + '&pc=' + this.plantCode;

    }

    hideGrid(event) {

        this.isgridLoading = false;
        let target = event.currentTarget;
        let statKey = target.dataset.key;

        const statTable = this.template.querySelector('.station-table');

        $('tr.dynamicRow', statTable).remove();
        $('td.expand-icon', statTable).removeClass('active');
        $('td.gridSection', statTable).addClass('p-0').removeClass('p-2');
        $('td.gridSection > div', statTable).removeClass('d-block');

        let trLen = $('tbody > tr.station-row', statTable).length;

        if (trLen > 1) {
            var selctedRow = $(target).closest('tr').index();
            if (selctedRow == 0) {
                $('thead', statTable).removeClass('invisible');
            }
        } else {
            $('thead', statTable).removeClass('invisible');
        }

        target.parentNode.classList.remove('active');
        target.parentNode.parentNode.classList.remove('selected');

        //this.template.querySelector('.'+ statName).classList.remove('d-block');
        $('.station-row.selected', statTable).next('tr.station-grid').find('td.gridSection > div.' + statKey).removeClass('d-block');
        $('tr.selected', statTable).removeClass('selected');
    }

    downloadCSVFile() {
        let rowEnd = '\n';
        let csvString = '';
        // this set elminates the duplicates if have any duplicate keys
        let rowData = new Set();

        // getting keys from data
        this.setCSVData.forEach(function (record) {
            Object.keys(record).forEach(function (key) {
                rowData.add(key);
            });
        });

        // Array.from() method returns an Array object from any object with a length property or an iterable object.
        rowData = Array.from(rowData);

        // splitting using ','
        csvString += rowData.join(',');
        csvString += rowEnd;

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

        //For IE
        if (/Edge\/\d./i.test(navigator.userAgent)) {

            var fileName = this.label.systemOverview + ".csv";
            var blob = new Blob([csvString], {
                "type": "text/csv;charset=utf8;"
            });
            navigator.msSaveBlob(blob, fileName);
        }
        else {
            // Creating anchor element to download
            let downloadElement = document.createElement('a');

            // This  encodeURI encodes special characters, except: , / ? : @ & = + $ # (Use encodeURIComponent() to encode these characters).
            downloadElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csvString);
            downloadElement.target = '_self';
            downloadElement.rel = 'noreferrer';
            // CSV File Name
            downloadElement.download = this.label.systemOverview + '.csv';
            // below statement is required if you are using firefox browser
            document.body.appendChild(downloadElement);
            // click() Javascript function to download CSV file
            downloadElement.click();
            document.body.removeChild(downloadElement);
        }

    }

    scrollProject(event) {

        let domName = event.currentTarget.dataset.dom;
        const scrollElement = this.template.querySelector('[data-domain="' + domName + '"]');
        $('html, body').animate({
            scrollTop: $(scrollElement).first().offset().top
        }, 1000);
    }

    async loadChoosenLibraries() {
        loadScript(this, YG_CustomerPortal + "/YG_JS/jquery.min.js").then(() => {
            loadStyle(this, YG_CustomerPortal + "/YG_CSS/chosen.css").then(() => {
                loadScript(this, YG_CustomerPortal + "/YG_JS/chosen.jquery.js").then(
                    () => {
                        const selectpicker = this.template.querySelector(".selectpicker");
                        const stationTable = this.template.querySelector(".station-table");

                        $(selectpicker)
                            .chosen({
                                disable_search: true,
                                width: "331px"
                            })
                            .change(function (e) {
                                if ($(this).val() != 0) {
                                    $('html, body').animate({
                                        scrollTop: $('tr[data-domain="' + $(this).val() + '"]', stationTable).first().offset().top - 100
                                    }, 1000);
                                }
                            });
                    }
                );
            });
        });
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
                            this.getSystemFilteredPlant(plantCode);
                        })
                        .catch(error => {
                            console.log('System API Error:' + JSON.stringify(error.message));
                        })
                } else {
                    console.log('System API Result:' + result);
                    this.getSystemFilteredPlant(plantCode);
                }
            })
            .catch(error => {
                console.log('Deliverable API Error:' + JSON.stringify(error.message));
            })


    }

}