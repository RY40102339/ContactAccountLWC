import { LightningElement, track, wire } from 'lwc';
import getProductDetails from '@salesforce/apex/YG_GridController.getProductDetails';
import getCommunityURL from '@salesforce/apex/YG_Utility.getCommunityURL';
import getCustomConfig from '@salesforce/apex/YG_Utility.getCustomConfig';
import { CurrentPageReference } from 'lightning/navigation';
import { fireEvent, registerListener, unregisterAllListeners } from 'c/pubSub';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import getCsvData from '@salesforce/apex/YG_ProductDetailsCSV.getCsvData';
import YG_CustomerPortal from '@salesforce/resourceUrl/YG_CustomerPortal';
import productsLbl from '@salesforce/label/c.YG_Products';
import instrumentLbl from '@salesforce/label/c.YG_Instrument';
import spareLbl from '@salesforce/label/c.YG_Spare';
import installedLbl from '@salesforce/label/c.YG_Installed';
import notificationLbl from '@salesforce/label/c.YG_Notification';
import showLbl from '@salesforce/label/c.YG_Show';
import moreProductsLbl from '@salesforce/label/c.YG_MoreProducts';
import regProductLbl from '@salesforce/label/c.YG_Register_your_products';

export default class YgGridData extends LightningElement {

    @wire(CurrentPageReference) pageRef;
    label = {
        productsLbl, instrumentLbl, spareLbl, installedLbl, notificationLbl, showLbl, moreProductsLbl, regProductLbl
    };

    csvIcon = YG_CustomerPortal + '/YG_Images/icons/csv.svg';

    @track isLoading = true;
    @track mapData = [];
    products = false;
    pageName;
    productGridData = [];
    productSize;
    prodCatName = '';
    productColName = [];
    error;
    hostURL;
    showLoadMore = false;
    recordLoadLimit = 0;
    offset = 0;
    loadedRecord = 0;
    remainRecords = 0;
    loadExternal = true;
    productregURL;

    //Boolean tracked variable to indicate if modal is open or not default value is false as modal is closed when page is loaded 
    //@track isModalOpen = false;
    @track errorMsg = '';
    @track successMsg = '';
    @track downloadLink = "Download full product list";
    productgridCsvData;
    totalCsvProductCnt = 0;
    responseData;
    setCSVData = [];
    btnfilter = '';
    btnfilterProdSize = 0;
    searchfilterIdList = [];
    btnSelect = false;
    @track isgridLoading = false;


    constructor() {
        super();
        let pagePath = window.location.pathname;
        let pageName = pagePath.substr(3);
        let communityURL;

        let fullStr = window.location.search.substring(1);
        let splitStr = fullStr.split("&");
        let prodCat = '';
        for (var i = 0; i < splitStr.length; i++) {
            var pair = splitStr[i].split("=");
            if (pair[0] == 'type') {
                prodCat = pair[1];
                this.prodCatName = decodeURIComponent(pair[1]);
            }
            if (pair[0] == 'select') {
                this.btnSelect = true;
            }
        }

        this.pageName = pageName;

        if (pageName === 'all-products' || pageName === '') {
            this.products = true;
        }

        getCommunityURL()
            .then(result => {
                communityURL = result;
                this.hostURL = result;
                this.productregURL = this.hostURL + 'product-registration';
            })
            .then(() => {
                this.loadExternalLibraries(communityURL);
            })
            .catch(error => {
                this.error = error;
            });

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
            })
            .then(() => {
                this.getProductData();
            })
            .catch(error => {
                this.error = error.message;
            });

    }

    connectedCallback() {
        registerListener('allProdFilterBtn', this.getallProdFilterBtn, this);
        registerListener('filterRecords', this.getFilteredProd, this);
    }

    disconnectedCallback() {
        unregisterAllListeners(this);
    }

    //To get the data's for all products CSV
    async loadExternalLibraries(communityURL) {

        loadScript(this, YG_CustomerPortal + '/YG_JS/jquery.min.js').then(() => {
            loadStyle(this, YG_CustomerPortal + '/YG_CSS/dataTables.css').then(() => {
                loadScript(this, YG_CustomerPortal + '/YG_JS/jquery.dataTables.min.js').then(() => {


                    let dataTable, notiHtml = '', notiBell = '', className, link, mobilelink, checkYellowbell = 0, mobileclass;

                    const table = this.template.querySelector('.all-prod-dtTable');

                    //const columnHeaders = [''+this.label.productsLbl+'', ''+this.label.instrumentLbl+'', ''+this.label.installedLbl+'', ''+this.label.spareLbl+'',''+this.label.notificationLbl+''];

                    const columnHeaders = this.productColName;
                    let colCnt = columnHeaders.length - 1;

                    let columnHeaderHtml = '<thead><tr>';
                    columnHeaders.forEach(function (header, index) {
                        if (index === 0) {
                            columnHeaderHtml += '<th><span class="font-weight-normal mHidden">' + header + '</span><span class="font-weight-normal d-sm-none">' + columnHeaders[1] + '</span></th>';
                        } else if (index === colCnt) {
                            columnHeaderHtml += '<th><span class="font-weight-normal d-sm-none grey-bell-icon"></span><span class="font-weight-normal d-none d-sm-inline-block">' + header + '</span></th>';
                        } else {
                            columnHeaderHtml += '<th><span class="font-weight-normal">' + header + '</span></th>';
                        }
                    });
                    columnHeaderHtml += '</tr></thead>';
                    table.innerHTML = columnHeaderHtml;

                    dataTable = $(table).DataTable({
                        "order": [],
                        "paging": false,
                        "searching": true, // false to disable search (or any other option)
                        "info": false,
                        "columnDefs": [{
                            orderable: false,
                            targets: 3
                        }]
                    });

                    console.log('Inside loadExternalLibraries ::: this.productGridData ' +
                        JSON.stringify(this.productGridData));

                    this.productGridData.forEach(function (list) {
                        console.log('Inside For each ::: List ::: ' + JSON.stringify(list));

                        notiHtml = '';
                        notiBell = '';
                        link = '';
                        mobilelink = '';
                        checkYellowbell = 0;
                        if (typeof list.notifications != 'undefined' && list.notifications != null
                            && list.notifications.length > 0) {
                            list.notifications.forEach(function (noti) {
                                console.log('Inside For each ::: noti ::: ' + JSON.stringify(noti));

                                if (noti.indexOf('Calibration') > -1) {
                                    className = 'fa-bell-yellow';
                                    checkYellowbell = 1;
                                } else {
                                    className = 'fa-bell-gray';
                                }

                                notiBell += '<i class="fas ' + className + ' pr-3 pb-3 f11">&nbsp;</i>' + noti + '<br />';
                            })


                            if (checkYellowbell == 1) {
                                mobileclass = 'fa-bell-yellow';
                            } else {
                                mobileclass = 'fa-bell-gray';
                            }

                            notiHtml += '<span class="d-none d-sm-block">' + notiBell + '</span>';
                            if (list.notificationCount != undefined) {
                                notiHtml += '<span class="font-weight-normal d-sm-none"><i class="fas ' + mobileclass + ' pr-3 pb-3">&nbsp;</i>' + list.notificationCount + '</span>';
                            }
                        } else {
                            notiHtml += "-";
                        }

                        link = '<div class="font-weight-normal d-none d-sm-block"><a class="text-hover-color" href="' + communityURL + 'product-details?modcode=' + list.modelCode + '"><ins>' + list.productNameAndCode + '</ins></a></div>';
                        mobilelink = list.products + '<br /><div class="d-sm-none"><div class="pt-2"><a class="text-hover-color" href="' + communityURL + 'product-details?modcode=' + list.modelCode + '"><ins>' + list.productNameAndCode + '</ins></a></div></div>';

                        dataTable.row.add([
                            mobilelink,
                            link,
                            list.qty,
                            notiHtml
                        ]);
                    })
                    dataTable.draw();
                })
            })
        })
    }


    getallProdFilterBtn(param) {

        this.setCSVData = [];
        this.btnfilter = param;
        this.showLoadMore = false;
        this.offset = 0;
        this.loadExternal = true;
        this.productGridData = [];
        this.productSize = 0;

        let filterSearchId;
        if (this.searchfilterIdList.length > 0) {
            filterSearchId = this.searchfilterIdList;
        }
        else {
            filterSearchId = null;
        }

        if (this.btnfilter == '') {
            this.downloadLink = "Download full product list";
        } else {
            this.downloadLink = "Download filtered product list";
        }


        if (this.prodCatName === '') {
            getProductDetails({ prodIdList: filterSearchId, prodCat: '', loadLimit: this.recordLoadLimit, offset: this.offset, btnValue: this.btnfilter })
                .then(result => {
                    this.isLoading = false;
                    if (result.prodDet.length == 0) {
                        let url = this.hostURL + 'overview';
                        window.location.href = url;
                    } else {
                        this.productGridData = result.prodDet;
                        this.productColName = result.colDet;
                        this.productSize = result.productSize;
                        this.loadedRecord = result.prodDet.length;
                        this.remainRecords = this.productSize - this.loadedRecord;

                        if (this.loadedRecord < this.productSize) {

                            if (this.remainRecords < this.recordLoadLimit) {
                                this.remainRecords = this.remainRecords;
                            } else {
                                this.remainRecords = this.recordLoadLimit;
                            }
                            this.showLoadMore = true;
                        } else {
                            this.showLoadMore = false;
                        }

                    }

                    if (this.loadExternal === true) {
                        const table = this.template.querySelector('.all-prod-dtTable');
                        $(table).DataTable().destroy();
                    }

                }).then(() => {
                    if (this.loadExternal === true) {
                        this.loadExternalLibraries(this.hostURL);
                    }
                    this.loadExternal = false;
                }).then(() => {
                    this.isgridLoading = false;
                }).catch(error => {
                    this.error = error.body;
                    this.isLoading = false;
                })

            //To get the Download CSV data
            this.setCSVData = [];
            let csvtempArr = [];
            getCsvData({ prodIdList: filterSearchId, prodCat: '', btnValue: this.btnfilter })
                .then(result => {
                    this.productgridCsvData = '';
                    var prodData = result.csvData;
                    prodData.forEach(function (prod) {
                        csvtempArr.push({
                            Product_Categories: prod.productCategories,
                            ProductNameAndModelCode: prod.productNameAndCode,
                            Serial_Number: prod.serialNos,
                            Notifications: prod.notifications
                        });
                    })
                    this.setCSVData = csvtempArr;
                }).catch(error => {
                    this.error = error;
                });

        }


        if (this.prodCatName != '') {
            getProductDetails({ prodIdList: filterSearchId, prodCat: this.prodCatName, loadLimit: this.recordLoadLimit, offset: this.offset, btnValue: this.btnfilter })
                .then(result => {
                    this.isLoading = false;
                    if (result.prodDet.length == 0) {
                        let url = this.hostURL + 'all-products';
                        window.location.href = url;
                    } else {
                        this.productGridData = result.prodDet;
                        this.productColName = result.colDet;
                        this.productSize = result.productSize;
                        this.loadedRecord = result.prodDet.length;
                        this.remainRecords = this.productSize - this.loadedRecord;
                        if (this.loadedRecord < this.productSize) {
                            if (this.remainRecords < this.recordLoadLimit) {
                                this.remainRecords = this.remainRecords;
                            } else {
                                this.remainRecords = this.recordLoadLimit;
                            }
                            this.showLoadMore = true;
                        } else {
                            this.showLoadMore = false;
                        }
                    }

                    //other browser specific code goes here
                    if (this.loadExternal === true) {
                        const table = this.template.querySelector('.all-prod-dtTable');
                        $(table).DataTable().destroy();
                    }

                }).then(() => {
                    if (this.loadExternal === true) {
                        this.loadExternalLibraries(this.hostURL);
                    }
                    this.loadExternal = false;
                }).then(() => {
                    this.isgridLoading = false;
                })
                .catch(error => {
                    this.error = error;
                    this.isLoading = false;
                })


            //To get the Download CSV data
            this.setCSVData = [];
            let csvtempArr = [];
            getCsvData({ prodIdList: filterSearchId, prodCat: this.prodCatName, btnValue: '' })
                .then(result => {
                    this.productgridCsvData = '';
                    console.log('productgridCsvDatathis.result1.2::' + JSON.stringify(result));
                    var prodData = result.csvData;
                    prodData.forEach(function (prod) {
                        csvtempArr.push({
                            Product_Categories: prod.productCategories,
                            ProductNameAndModelCode: prod.productNameAndCode,
                            Serial_Number: prod.serialNos,
                            Notifications: prod.notifications
                        });
                    })
                    this.setCSVData = csvtempArr;
                }).catch(error => {
                    this.error = error;
                });

        }
    }

    getProductData() {


        this.downloadLink = "Download full product list";
        this.productGridData = [];
        this.showLoadMore = false;
        this.offset = 0;
        this.loadExternal = true;
        this.setCSVData = [];

        this.productregURL = this.hostURL + 'product-registration';

        if (this.prodCatName === '') {
            getProductDetails({ prodIdList: null, prodCat: '', loadLimit: this.recordLoadLimit, offset: this.offset, btnValue: '' })
                .then(result => {
                    this.isLoading = false;
                    if (result.prodDet.length == 0) {
                        let url = this.hostURL + 'overview';
                        window.location.href = url;
                    } else {
                        this.productGridData = result.prodDet;
                        this.productColName = result.colDet;
                        this.productSize = result.productSize;
                        this.loadedRecord = result.prodDet.length;
                        this.remainRecords = this.productSize - this.loadedRecord;

                        if (this.loadedRecord < this.productSize) {

                            if (this.remainRecords < this.recordLoadLimit) {
                                this.remainRecords = this.remainRecords;
                            } else {
                                this.remainRecords = this.recordLoadLimit;
                            }
                            this.showLoadMore = true;
                        } else {
                            this.showLoadMore = false;
                        }

                        fireEvent(this.pageRef, 'btnNotiCount', result);
                    }

                    if (this.loadExternal === true) {
                        const table = this.template.querySelector('.all-prod-dtTable');
                        $(table).DataTable().destroy();
                    }

                }).then(() => {
                    if (this.loadExternal === true) {
                        this.loadExternalLibraries(this.hostURL);
                    }
                    this.loadExternal = false;
                }).then(() => {
                    this.isgridLoading = false;
                }).catch(error => {
                    this.error = error.body;
                    this.isLoading = false;
                })

            //To get the Download CSV data
            this.setCSVData = [];
            let csvtempArr = [];
            getCsvData({ prodIdList: null, prodCat: '', btnValue: '' })
                .then(result => {
                    this.productgridCsvData = '';
                    var prodData = result.csvData;
                    prodData.forEach(function (prod) {
                        csvtempArr.push({
                            Product_Categories: prod.productCategories,
                            ProductNameAndModelCode: prod.productNameAndCode,
                            Serial_Number: prod.serialNos,
                            Notifications: prod.notifications
                        });
                    })
                    this.setCSVData = csvtempArr;
                }).catch(error => {
                    this.error = error;
                });

        }

        if (this.prodCatName != '') {
            getProductDetails({ prodIdList: null, prodCat: this.prodCatName, loadLimit: this.recordLoadLimit, offset: this.offset, btnValue: '' })
                .then(result => {
                    this.isLoading = false;
                    if (result.prodDet.length == 0) {
                        let url = this.hostURL + 'overview';
                        window.location.href = url;
                    } else {
                        this.productGridData = result.prodDet;
                        this.productColName = result.colDet;
                        this.productSize = result.productSize;
                        this.loadedRecord = result.prodDet.length;
                        this.remainRecords = this.productSize - this.loadedRecord;
                        if (this.loadedRecord < this.productSize) {
                            if (this.remainRecords < this.recordLoadLimit) {
                                this.remainRecords = this.remainRecords;
                            } else {
                                this.remainRecords = this.recordLoadLimit;
                            }
                            this.showLoadMore = true;
                        } else {
                            this.showLoadMore = false;
                        }
                        fireEvent(this.pageRef, 'btnNotiCount', result);
                    }

                    //other browser specific code goes here
                    if (this.loadExternal === true) {
                        const table = this.template.querySelector('.all-prod-dtTable');
                        $(table).DataTable().destroy();
                    }

                }).then(() => {
                    if (this.loadExternal === true) {
                        this.loadExternalLibraries(this.hostURL);
                    }
                    this.loadExternal = false;
                }).then(() => {
                    this.isgridLoading = false;
                })
                .catch(error => {
                    this.error = error;
                    this.isLoading = false;
                })


            //To get the Download CSV data
            this.setCSVData = [];
            let csvtempArr = [];
            getCsvData({ prodIdList: null, prodCat: this.prodCatName, btnValue: '' })
                .then(result => {
                    this.productgridCsvData = '';
                    console.log('productgridCsvDatathis.result1.2::' + JSON.stringify(result));
                    var prodData = result.csvData;
                    prodData.forEach(function (prod) {
                        csvtempArr.push({
                            Product_Categories: prod.productCategories,
                            ProductNameAndModelCode: prod.productNameAndCode,
                            Serial_Number: prod.serialNos,
                            Notifications: prod.notifications
                        });
                    })
                    this.setCSVData = csvtempArr;
                }).catch(error => {
                    this.error = error;
                });

        }

    }


    getFilteredProd(prodList) {


        let prodId = prodList;
        let id = [];
        this.showLoadMore = false;
        this.offset = 0;

        prodId.forEach(function (list) {
            id.push(list.Id);
        })

        this.searchfilterIdList = id;

        if (this.prodCatName == undefined) {
            this.prodCatName = '';
        }

        if (prodId.length > 0) {
            this.downloadLink = "Download filtered product list";
            getProductDetails({ prodIdList: id, prodCat: this.prodCatName, loadLimit: 0, offset: this.offset, btnValue: this.btnfilter })
                .then(result => {

                    this.productGridData = result.prodDet;
                    this.productColName = result.colDet;
                    this.showLoadMore = false;

                    if (this.loadExternal === false) {
                        const table = this.template.querySelector('.all-prod-dtTable');
                        $(table).DataTable().destroy();
                    }
                    fireEvent(this.pageRef, 'btnNotiCount', result);

                }).then(() => {
                    if (this.loadExternal === false) {
                        this.loadExternalLibraries(this.hostURL);
                    }
                })
                .catch(error => {
                    this.error = error.body;
                })

            //To get the Download CSV data
            this.setCSVData = [];
            let csvtempArr = [];
            getCsvData({ prodIdList: id, prodCat: this.prodCatName, btnValue: this.btnfilter })
                .then(result => {
                    this.productgridCsvData = '';
                    var prodData = result.csvData;
                    prodData.forEach(function (prod) {
                        csvtempArr.push({
                            Product_Categories: prod.productCategories,
                            ProductNameAndModelCode: prod.productNameAndCode,
                            Serial_Number: prod.serialNos,
                            Notifications: prod.notifications
                        });
                    })
                    this.setCSVData = csvtempArr;
                }).catch(error => {
                    this.error = error;
                });

        } else {
            this.downloadLink = "Download full product list";
            getProductDetails({ prodIdList: null, prodCat: this.prodCatName, loadLimit: this.recordLoadLimit, offset: this.offset, btnValue: '' })
                .then(result => {

                    //other browser specific code goes here
                    if (this.loadExternal === false) {
                        const table = this.template.querySelector('.all-prod-dtTable');
                        $(table).DataTable().destroy();
                    }
                    this.productSize = result.productSize;
                    this.productGridData = result.prodDet;
                    this.productColName = result.colDet;
                    this.loadedRecord = result.prodDet.length;
                    this.remainRecords = this.productSize - this.loadedRecord;

                    if (this.loadedRecord < this.productSize) {

                        if (this.remainRecords < this.recordLoadLimit) {
                            this.remainRecords = this.remainRecords;
                        } else {
                            this.remainRecords = this.recordLoadLimit;
                        }
                        this.showLoadMore = true;
                    } else {
                        this.showLoadMore = false;
                    }
                    fireEvent(this.pageRef, 'btnNotiCount', result);

                    this.isLoading = false;
                }).then(() => {
                    if (this.loadExternal === false) {
                        this.loadExternalLibraries(this.hostURL, this.prodCatName, this.plantCode);
                    }
                })
                .catch(error => {
                    this.error = error;
                    this.isLoading = false;
                    console.log('error:: ' + JSON.stringify(this.error.body));
                })

            //To get the Download CSV data
            this.setCSVData = [];
            let csvtempArr = [];
            getCsvData({ prodIdList: null, prodCat: this.prodCatName, plantCode: this.plantCode, btnValue: this.btnfilter })
                .then(result => {
                    this.productgridCsvData = '';
                    var prodData = result.csvData;
                    prodData.forEach(function (prod) {
                        csvtempArr.push({
                            Product_Categories: prod.productCategories,
                            ProductNameAndModelCode: prod.productNameAndCode,
                            Serial_Number: prod.serialNos,
                            Notifications: prod.notifications
                        });
                    })
                    this.setCSVData = csvtempArr;
                }).catch(error => {
                    this.error = error;
                });

        }
    }


    loadmore() {

        this.template.querySelector('.loading-icon').classList.remove('d-none');
        this.offset = this.offset + this.recordLoadLimit;
        let loadData = [];
        let commUrl = this.hostURL;
        let param = '';

        if (this.btnfilter != '') {
            param = this.btnfilter;
        } else {
            param = '';
        }


        if (this.prodCatName === '') {
            getProductDetails({ prodIdList: null, prodCat: '', loadLimit: this.recordLoadLimit, offset: this.offset, btnValue: param })
                .then(result => {
                    this.isLoading = false;
                    loadData = result.prodDet;
                    if (param != '') {
                        this.productSize = this.btnfilterProdSize;
                    } else {
                        this.productSize = result.productSize;
                    }
                    this.loadedRecord = this.loadedRecord + result.prodDet.length;
                    this.remainRecords = this.productSize - this.loadedRecord;
                    if (this.loadedRecord < this.productSize) {
                        if (this.remainRecords < this.recordLoadLimit) {
                            this.remainRecords = this.remainRecords;
                        } else {
                            this.remainRecords = this.recordLoadLimit;
                        }
                        this.showLoadMore = true;
                    } else {
                        this.showLoadMore = false;
                    }

                    const table = this.template.querySelector('.all-prod-dtTable');
                    let dataTable, notiHtml = '', notiBell = '', mobilelink, className, link, checkYellowbell = 0, mobileclass;
                    $.fn.dataTableExt.sErrMode = 'none';
                    dataTable = $(table).DataTable({
                        "order": [],
                        "paging": false,
                        "searching": true, // false to disable search (or any other option)
                        "info": false,
                        "columnDefs": [{
                            orderable: false,
                            targets: 3
                        }]
                    });

                    loadData.forEach(function (list) {

                        notiHtml = '';
                        notiBell = '';
                        link = '';
                        mobilelink = '';
                        checkYellowbell = 0;
                        if (list.notifications.length > 0) {
                            list.notifications.forEach(function (noti) {
                                if (noti.indexOf('Calibration') > -1) {
                                    className = 'fa-bell-yellow';
                                    checkYellowbell = 1;
                                } else {
                                    className = 'fa-bell-gray';
                                }

                                notiBell += '<i class="fas ' + className + ' pr-3 pb-3 f11">&nbsp;</i>' + noti + '<br />';
                            })

                            if (checkYellowbell == 1) {
                                mobileclass = 'fa-bell-yellow';
                            } else {
                                mobileclass = 'fa-bell-gray';
                            }

                            notiHtml += '<span class="d-none d-sm-block">' + notiBell + '</span>';

                            if (list.notificationCount != undefined) {
                                notiHtml += '<span class="font-weight-normal d-sm-none"><i class="fas ' + mobileclass + ' pr-3 pb-3">&nbsp;</i>' + list.notificationCount + '</span>';
                            }
                        } else {
                            notiHtml += "-";
                        }
                        link = '<div class="font-weight-normal d-none d-sm-block"><a class="text-hover-color" href="' + commUrl + 'product-details?modcode=' + list.modelCode + '"><ins>' + list.productNameAndCode + '</ins></a></div>';
                        mobilelink = list.products + '<br /><div class="d-sm-none"><div class="pt-2"><a class="text-hover-color" href="' + commUrl + 'product-details?modcode=' + list.modelCode + '"><ins>' + list.productNameAndCode + '</ins></a></div></div>';
                        dataTable.row.add([
                            mobilelink,
                            link,
                            list.qty,
                            notiHtml
                        ]).draw(false);
                    })

                }).then(() => {
                    this.template.querySelector('.loading-icon').classList.add('d-none');
                    this.template.querySelector('.load-more').classList.remove('d-none');
                })
                .catch(error => {
                    this.error = error.message;
                    this.isLoading = false;
                })
        }


        if (this.prodCatName != '') {
            this.products = true;
            getProductDetails({ prodIdList: null, prodCat: this.prodCatName, loadLimit: this.recordLoadLimit, offset: this.offset, btnValue: param })
                .then(result => {
                    this.isLoading = false;
                    loadData = result.prodDet;
                    if (param != '') {
                        this.productSize = this.btnfilterProdSize;
                    } else {
                        this.productSize = result.productSize;
                    }
                    this.loadedRecord = this.loadedRecord + result.prodDet.length;
                    this.remainRecords = this.productSize - this.loadedRecord;
                    if (this.loadedRecord < this.productSize) {
                        if (this.remainRecords < this.recordLoadLimit) {
                            this.remainRecords = this.remainRecords;
                        } else {
                            this.remainRecords = this.recordLoadLimit;
                        }
                        this.showLoadMore = true;
                    } else {
                        this.showLoadMore = false;
                    }

                    const table = this.template.querySelector('.all-prod-dtTable');
                    let dataTable, notiHtml = '', notiBell = '', className, mobilelink, link, checkYellowbell = 0, mobileclass;
                    $.fn.dataTableExt.sErrMode = 'none';
                    dataTable = $(table).DataTable({
                        "order": [],
                        "paging": false,
                        "searching": true, // false to disable search (or any other option)
                        "info": false,
                        "columnDefs": [{
                            orderable: false,
                            targets: 3
                        }]
                    });
                    loadData.forEach(function (list) {

                        notiHtml = '';
                        notiBell = '';
                        link = '';
                        mobilelink = '';
                        checkYellowbell = 0;
                        if (list.notifications.length > 0) {
                            list.notifications.forEach(function (noti) {
                                if (noti.indexOf('Calibration') > -1) {
                                    className = 'fa-bell-yellow';
                                    checkYellowbell = 1;
                                } else {
                                    className = 'fa-bell-gray';
                                }

                                notiBell += '<i class="fas ' + className + ' pr-3 pb-3 f11">&nbsp;</i>' + noti + '<br />';
                            })

                            if (checkYellowbell == 1) {
                                mobileclass = 'fa-bell-yellow';
                            } else {
                                mobileclass = 'fa-bell-gray';
                            }

                            notiHtml += '<span class="d-none d-sm-block">' + notiBell + '</span>';

                            if (list.notificationCount != undefined) {
                                notiHtml += '<span class="font-weight-normal d-sm-none"><i class="fas ' + mobileclass + ' pr-3 pb-3">&nbsp;</i>' + list.notificationCount + '</span>';
                            }
                        } else {
                            notiHtml += "-";
                        }

                        link = '<div class="font-weight-normal d-none d-sm-block"><a class="text-hover-color" href="' + commUrl + 'product-details?modcode=' + list.modelCode + '"><ins>' + list.productNameAndCode + '</ins></a></div>';
                        mobilelink = list.products + '<br /><div class="d-sm-none"><div class="pt-2"><a class="text-hover-color" href="' + commUrl + 'product-details?modcode=' + list.modelCode + '"><ins>' + list.productNameAndCode + '</ins></a></div></div>';

                        dataTable.row.add([
                            mobilelink,
                            link,
                            list.qty,
                            notiHtml
                        ]).draw(false);
                    })
                }).then(() => {
                    this.template.querySelector('.loading-icon').classList.add('d-none');
                    this.template.querySelector('.load-more').classList.remove('d-none');
                })
                .catch(error => {
                    this.error = error;
                    this.isLoading = false;
                })
        }

    }

    // this method validates the data and creates the csv file to download
    downloadCSVFile(event) {

        //console.log('this.productGridData downloadCSVFile::' + JSON.stringify(this.productGridData));
        let rowEnd = '\n';
        let csvString = '';

        // this set elminates the duplicates if have any duplicate keys
        let rowData = new Set();
        // getting keys from data   headerCol
        this.setCSVData.forEach(function (record) {
            Object.keys(record).forEach(function (key) {
                if (key != 'modelCode' & key != 'notificationCount')
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

            var fileName = "All Products.csv";
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
            downloadElement.download = 'All Products.csv';
            // below statement is required if you are using firefox browser
            document.body.appendChild(downloadElement);
            // click() Javascript function to download CSV file
            downloadElement.click();
            document.body.removeChild(downloadElement);
        }

    }
}