import { LightningElement, wire, track, api } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import getProductDetailMsCode from '@salesforce/apex/YG_ProductDetailGrid.getProductDetailMsCodeGrid';
import getProductDetailSerial from '@salesforce/apex/YG_ProductDetailGrid.getProductDetailSerialGrid';
import getProductDetailCSV from '@salesforce/apex/YG_ProductDetailGrid.getProductDetailCSV';
import getCommunityURL from '@salesforce/apex/YG_Utility.getCommunityURL';
import YG_CustomerPortal from '@salesforce/resourceUrl/YG_CustomerPortal';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import { fireEvent, registerListener, unregisterAllListeners } from 'c/pubSub';
import productdetail from '@salesforce/label/c.YG_Productdetail';
import dwlfullProdList from '@salesforce/label/c.YG_Download_product_list';
import dwlfltrProdList from '@salesforce/label/c.YG_Download_filtered_product_list';

export default class YgProductDetailsGrid extends LightningElement {
    @wire(CurrentPageReference) pageRef;
    @track serialNo;
    @track serialIndx;

    label = {
        productdetail, dwlfullProdList, dwlfltrProdList
    };

    setCSVData = [];
    msCode = '';
    productName = '';
    msCodeIndex = '';
    exStatName = [];
    filterData = [];
    statLink = '';
    commUrl = '';
    error;
    msCodeDataLists = [];
    isMSCodeAscending = true;
    isQtyAscending = true;
    isMSCodeClass = "sorting pl-2";
    isQtyClass = "sorting";
    //Boolean tracked variable to indicate if modal is open or not default value is false as modal is closed when page is loaded 
    @track isModalOpen = false;
    @track isMSCodeModalOpen = false;
    @track isLoading = false;
    @track downloadLink = this.label.dwlfullProdList;
    csvIcon = YG_CustomerPortal + '/YG_Images/icons/csv.svg';
    plusIcon = YG_CustomerPortal + '/YG_Images/icons/plus.svg';
    minusIcon = YG_CustomerPortal + '/YG_Images/icons/minus.svg';
    isgridLoading = false;
    //new 
    @track productMscode = false;
    prodWrap = [];
    stationGridData = [];
    statModCode = '';
    projectCode = '';
    topLevel;



    constructor() {
        super();

        let fullStr = window.location.search.substring(1);
        let splitStr = fullStr.split("&");
        let modno = '';
        for (var i = 0; i < splitStr.length; i++) {
            var pair = splitStr[i].split("=");
            if (pair[0] == 'modcode') {
                modno = pair[1];
                this.modCode = pair[1];
            }
            if (pair[0] == 'serialno') {
                this.serialNo = pair[1];
            }
        }

        getCommunityURL({})
            .then(result => {
                this.commUrl = result;
            }).then(() => {
                this.autoPopup(this.serialNo);
            }).catch(error => {
                this.error = error;
                console.log('DataError: ' + JSON.stringify(this.error));
            });
        this.loadExternalLibraries(this.stationGridData);
        this.getLoadGridData();
    }

    autoPopup(sNo) {
        if (sNo != undefined) {
            this.serialIndx = -1;
            this.stationGridData = [];
            this.isModalOpen = true;
        }
    }

    connectedCallback() {
        registerListener('filterRecords', this.getFilteredProducts, this);
        registerListener('isMSCodeModalOpen', this.getisMSCodeModalOpen, this);
        registerListener('level2BreadCrumb', this.getLevel2Category, this);
    }

    disconnectedCallback() {
        unregisterAllListeners(this);
    }

    getisMSCodeModalOpen(status) {
        this.isMSCodeModalOpen = status;
        this.isModalOpen = status;
    }

    getFilteredProducts(model) {

        console.log('model: ' + JSON.stringify(model));
        let modelListData = model;
        let modelCodeparam = [];
        this.setCSVData = [];
        let csvtempArr = [];

        if (modelListData.length > 0) {
            this.downloadLink = this.label.dwlfltrProdList;
        } else {
            this.downloadLink = this.label.dwlfullProdList;
        }

        modelListData.forEach(function (list) {
            modelCodeparam.push(list.Name);
            console.log('modelCodeparam :: ' + JSON.stringify(modelCodeparam));
        })

        /*
        const triggerClick = this.template.querySelector('.active .minus');
        if (triggerClick != null) {
            triggerClick.click();
        }*/

        console.log('this.prodWrap**** ' + JSON.stringify(this.prodWrap));

        this.productMscode = true;
        this.prodWrap = [];
        let tempArr = [];
        this.exStatName = [];

        getProductDetailMsCode({ modelcode: this.modCode, filterValue: modelCodeparam }).then(result => {
            console.log('RESULT****' + JSON.stringify(result));
            this.productName = result.productName;
            this.msCodeDataLists = result.msCodeDataLists;
            result.msCodeDataLists.forEach(function (stat, index) {
                tempArr.push({
                    ind: index,
                    key: stat.key,
                    msCode: stat.msCode,
                    msCodeNotification: stat.msCodeNotification,
                    qty: stat.qty
                });

            })

            this.prodWrap = tempArr;
        }).then(() => {

            getProductDetailCSV({ modelcode: this.modCode, filterValue: modelCodeparam }).then(result => {
                console.log('getProductDetailCSV****' + JSON.stringify(result));

                let catgy = this.topLevel;

                //Set CSV Data
                result.csvDataLists.forEach(function (prd) {
                    if (catgy == "Field Instruments" || catgy == "Process Analyzers") {
                        csvtempArr.push({
                            MS_Code: prd.mscode,
                            Serial_Number: prd.serialNo,
                            Tag_Number: prd.tagNo,
                            Production_Date: prd.prodDate,
                            MS_Code_Notification: prd.mscodeNotfy,
                            Serial_Number_Notification: prd.serialNoNotfy
                        });
                    }
                    else {
                        csvtempArr.push({
                            MS_Code: prd.mscode,
                            Serial_Number: prd.serialNo,
                            Production_Date: prd.prodDate,
                            MS_Code_Notification: prd.mscodeNotfy,
                            Serial_Number_Notification: prd.serialNoNotfy
                        });
                    }
                })

                console.log('csvtempArr****' + JSON.stringify(csvtempArr));
                this.setCSVData = csvtempArr;


            }).catch(error => {
                this.isLoading = false;
                this.error = error;
                console.log('System Error catch  ::' + this.error.message);
            })

        }).catch(error => {
            this.isLoading = false;
            this.error = error;
            console.log('System Error catch  ::' + this.error.message);
        })

    }

    getLoadGridData() {

        this.productMscode = true;

        const triggerClick = this.template.querySelector('.active .minus');
        if (triggerClick != null) {
            triggerClick.click();
        }

        this.prodWrap = [];
        let tempArr = [];
        this.exStatName = [];
        this.setCSVData = [];
        let csvtempArr = [];

        getProductDetailMsCode({ modelcode: this.modCode, filterValue: null }).then(result => {
            console.log('RESULT****' + JSON.stringify(result));
            console.log('productName****' + JSON.stringify(result.productName));
            console.log('topCategoryName****' + JSON.stringify(result.topCategoryName));
            this.productName = result.productName;
            this.msCodeDataLists = result.msCodeDataLists;
            fireEvent(this.pageRef, 'totProductCount', result.totalcount);
            fireEvent(this.pageRef, 'level2BreadCrumb', result);
            fireEvent(this.pageRef, 'prodDetailHead', result);

            result.msCodeDataLists.forEach(function (stat, index) {
                tempArr.push({
                    ind: index,
                    key: stat.key,
                    msCode: stat.msCode,
                    msCodeNotification: stat.msCodeNotification,
                    qty: stat.qty
                });

            })

            this.prodWrap = tempArr;
        }).then(() => {
            console.log('getProductDetailCSV****');
            getProductDetailCSV({ modelcode: this.modCode, filterValue: null }).then(result => {
                console.log('getProductDetailCSV****' + JSON.stringify(result));

                let catgy = this.topLevel;

                //Set CSV Data
                result.csvDataLists.forEach(function (prd) {
                    if (catgy == "Field Instruments" || catgy == "Process Analyzers") {
                        csvtempArr.push({
                            MS_Code: prd.mscode,
                            Serial_Number: prd.serialNo,
                            Tag_Number: prd.tagNo,
                            Production_Date: prd.prodDate,
                            MS_Code_Notification: prd.mscodeNotfy,
                            Serial_Number_Notification: prd.serialNoNotfy
                        });
                    }
                    else {
                        csvtempArr.push({
                            MS_Code: prd.mscode,
                            Serial_Number: prd.serialNo,
                            Production_Date: prd.prodDate,
                            MS_Code_Notification: prd.mscodeNotfy,
                            Serial_Number_Notification: prd.serialNoNotfy
                        });
                    }
                })

                console.log('csvtempArr****' + JSON.stringify(csvtempArr));
                this.setCSVData = csvtempArr;

            }).catch(error => {
                this.isLoading = false;
                this.error = error;
                console.log('System Error catch  ::' + this.error.message);
            })

        }).catch(error => {
            this.isLoading = false;
            this.error = error;
            console.log('System Error catch  ::' + this.error.message);
        })


    }

    getLevel2Category(result) {

        this.topLevel = result.topCategoryName;
    }

    async loadExternalLibraries(statData, statKey, topLevel) {

        loadScript(this, YG_CustomerPortal + '/YG_JS/jquery.min.js').then(() => {
            loadStyle(this, YG_CustomerPortal + '/YG_CSS/dataTables.css').then(() => {
                loadScript(this, YG_CustomerPortal + '/YG_JS/jquery.dataTables.min.js').then(() => {

                    let dataTable;
                    let removeTag = 0;
                    const table = this.template.querySelector('.' + statKey + ' .mscode-dtTable');
                    const columnHeaders = ['Serial no.', 'Tag no.', 'Production date', 'Notifications'];

                    if (topLevel != "Field Instruments") {
                        if (topLevel != "Process Analyzers") {
                            columnHeaders.splice(1, 1);
                            removeTag = 1;
                        }
                    }

                    let columnHeaderHtml = '<thead><tr>';
                    columnHeaders.forEach(function (header, index) {
                        columnHeaderHtml += '<th><span class="font-weight-normal">' + header + '</span></th>';
                    });
                    columnHeaderHtml += '</tr></thead>';
                    table.innerHTML = columnHeaderHtml;

                    dataTable = $(table).DataTable({
                        "order": [],
                        "paging": false,
                        "searching": false, // false to disable search (or any other option)
                        "info": false,
                        "columnDefs": [{
                            orderable: false,
                            targets: columnHeaders.length - 1
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

                    if (removeTag === 1) {
                        statData.serialNoDataLists.forEach(function (list, index) {
                            dataTable.row.add([
                                '<a data-id=' + list.serialNo + ' data-index=' + index + ' href="javascript:void(0)" class="noto-font f14 grey-dark-1 font-weight-normal text-hover-color"><ins>' + list.serialNo + '</ins></a>',
                                list.prodDate,
                                list.serialNoNotification
                            ]);
                        })
                    } else {
                        statData.serialNoDataLists.forEach(function (list, index) {
                            dataTable.row.add([
                                '<a data-id=' + list.serialNo + ' data-index=' + index + ' href="javascript:void(0)" class="noto-font f14 grey-dark-1 font-weight-normal text-hover-color"><ins>' + list.serialNo + '</ins></a>',
                                list.tagNo,
                                list.prodDate,
                                list.serialNoNotification
                            ]);
                        })
                    }

                    dataTable.draw();

                    const tableField = this.template.querySelector('.mscode-dt');
                    const triggerEvent = this.template.querySelector('.triggerEvent');
                    $('tbody', table).on('click', 'td a', function () {
                        $('input[name=hiddenInput]', tableField).val($(this).attr('data-id'));
                        $('input[name=hiddenIndex]', tableField).val($(this).attr('data-index'));
                        triggerEvent.click();
                    });
                })
            })
        })
    }

    //To trigger the MS Code pop window
    showMSCodePopup(event) {
        event.preventDefault();
        const target = event.currentTarget;
        this.msCode = target.dataset.mscode;
        this.msCodeIndex = target.dataset.index;
        this.isMSCodeModalOpen = true;
    }

    //To trigger the pop window
    triggerEvent(event) {
        //alert('here');
        //let msCode = target.dataset.mscode;
        const tableElement = this.template.querySelector('.mscode-dt');
        let serialNum = $('input[name=hiddenInput]', tableElement).val();
        let serialIndex = $('input[name=hiddenIndex]', tableElement).val();
        //alert("serialNum" + serialNum);
        this.serialNo = serialNum;
        this.serialIndx = serialIndex;
        //fireEvent(this.pageRef, 'navigationSerial', this.serialNo);
        this.isModalOpen = true;
    }

    /*Mobile view Grid*/
    showMobileGrid(event) {

        let target = event.currentTarget;
        let statKey = target.dataset.key;
        let msCode = target.dataset.mscode;
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
                table1 = table.querySelector('.' + list.value + ' .mscode-dtTable');
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


        getProductDetailSerial({ mscode: msCode })
            .then(result => {
                this.stationGridData = result;
                console.log('Serial No Grid' + JSON.stringify(this.stationGridData));
            })
            .then(() => {
                this.loadExternalLibraries(this.stationGridData, statKey, this.topLevel);
            }).then(() => {
                this.isgridLoading = false;
            }).catch(error => {
                this.error = error;
                console.log('Serial No Grid Error ::' + this.error.message);
            })

    }

    showGrid(event) {
        let target = event.currentTarget;
        let msCode = target.dataset.mscode;
        let statKey = target.dataset.key;
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
                table1 = table.querySelector('.' + list.value + ' .mscode-dtTable');
                if (Object.keys(table1).length != 0) {
                    $(table1).DataTable().destroy();
                }
            })
        }

        const statTable = this.template.querySelector('.station-table');

        $('tr.dynamicRow', statTable).remove();
        $('tr.selected', statTable).removeClass('selected');
        $('td.expand-icon', statTable).removeClass('active');
        $('td.gridSection', statTable).addClass('p-0').removeClass('p-2')
        $('td.gridSection > div', statTable).removeClass('d-block');

        target.parentNode.classList.add('active');
        target.parentNode.parentNode.classList.add('selected');
        $('.station-row.selected', statTable).next('tr.station-grid').find('td.gridSection').removeClass('p-0').addClass('p-2');
        $('.station-row.selected', statTable).next('tr.station-grid').find('td.gridSection > div.' + statKey).addClass('d-block');


        getProductDetailSerial({ mscode: msCode })
            .then(result => {
                this.stationGridData = result;
                console.log('Serial No Grid' + JSON.stringify(this.stationGridData));
            })
            .then(() => {
                this.loadExternalLibraries(this.stationGridData, statKey, this.topLevel);
            }).then(() => {
                this.isgridLoading = false;
            }).catch(error => {
                this.error = error;
                console.log('Serial No Grid Error ::' + this.error.message);
            })
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
        //$('.station-row.selected', statTable).next('tr.station-grid').find('td.gridSection').removeClass('p-2').addClass('p-0');
        //$('.station-row.selected', statTable).find('td.gridSection').removeClass('p-2').addClass('p-0');
        $('.station-row.selected', statTable).next('tr.station-grid').find('td.gridSection > div.' + statKey).removeClass('d-block');
        $('tr.selected', statTable).removeClass('selected');
    }

    sortMSCode() {
        this.isQtyClass = "sorting";
        this.isQtyAscending = true;
        if (this.isMSCodeAscending) {
            this.isMSCodeClass = "sorting_asc pl-2";
            this.msCodeDataLists = this.msCodeDataLists.sort((a, b) => (a.msCode > b.msCode) ? 1 : -1);
        } else {
            this.isMSCodeClass = "sorting_desc pl-2";
            this.msCodeDataLists = this.msCodeDataLists.sort((a, b) => (a.msCode > b.msCode) ? -1 : 1);
        }
        this.isMSCodeAscending = !this.isMSCodeAscending;
        const triggerClick = this.template.querySelector('.active .minus');
        if (triggerClick != null) {
            triggerClick.click();
        }
        let tempArr = [];
        this.msCodeDataLists.forEach(function (stat, index) {
            tempArr.push({
                ind: index,
                key: stat.key,
                msCode: stat.msCode,
                msCodeNotification: stat.msCodeNotification,
                qty: stat.qty
            });

        })
        this.prodWrap = tempArr;
    }

    sortQty() {
        this.isMSCodeClass = "sorting pl-2";
        this.isMSCodeAscending = true;
        if (this.isQtyAscending) {
            this.isQtyClass = "sorting_asc";
            this.msCodeDataLists = this.msCodeDataLists.sort((a, b) => (a.qty - b.qty));
        } else {
            this.isQtyClass = "sorting_desc";
            this.msCodeDataLists = this.msCodeDataLists.sort((a, b) => (b.qty - a.qty));
        }
        this.isQtyAscending = !this.isQtyAscending;
        const triggerClick = this.template.querySelector('.active .minus');
        if (triggerClick != null) {
            triggerClick.click();
        }
        let tempArr = [];
        this.msCodeDataLists.forEach(function (stat, index) {
            tempArr.push({
                ind: index,
                key: stat.key,
                msCode: stat.msCode,
                msCodeNotification: stat.msCodeNotification,
                qty: stat.qty
            });

        })
        this.prodWrap = tempArr;
    }

    // this method validates the data and creates the csv file to download
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

            var fileName = this.label.productdetail + ".csv";
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
            downloadElement.download = this.label.productdetail + '.csv';
            // below statement is required if you are using firefox browser
            document.body.appendChild(downloadElement);
            // click() Javascript function to download CSV file
            downloadElement.click();
            document.body.removeChild(downloadElement);
        }

    }
}