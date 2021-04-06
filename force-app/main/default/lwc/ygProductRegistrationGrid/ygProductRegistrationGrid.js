import { LightningElement, wire, track } from 'lwc';
import searchSerialNumber from '@salesforce/apex/YG_ProductRegistrationController.searchSerialNumber';
import registerSerialNumber from '@salesforce/apex/YG_ProductRegistrationController.registerSerialNumber';
import getCommunityURL from '@salesforce/apex/YG_Utility.getCommunityURL';
import { CurrentPageReference } from 'lightning/navigation';
import { unregisterAllListeners } from 'c/pubSub';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import YG_CustomerPortal from '@salesforce/resourceUrl/YG_CustomerPortal';
import serialNumber from '@salesforce/label/c.YG_Serial_number';
import products from '@salesforce/label/c.YG_Product_name';
import modelSuffix from '@salesforce/label/c.YG_ModelSuffix';
import productionDate from '@salesforce/label/c.YG_Production_date';
import clickHereLbl from '@salesforce/label/c.YG_Click_here';
import regProductLbl from '@salesforce/label/c.YG_Register_product';
import resultLbl from '@salesforce/label/c.YG_Results';
import clearResultLbl from '@salesforce/label/c.YG_Clear_results';
import registerLbl from '@salesforce/label/c.YG_Register';
import selProductLbl from '@salesforce/label/c.YG_Selected_Products';
import productRegLbl from '@salesforce/label/c.YG_Product_registration_successful';
import productRegMsgLbl from '@salesforce/label/c.YG_Product_Reg_Msg4';
import viewAllProductLbl from '@salesforce/label/c.YG_View_All_Product';
import closeLbl from '@salesforce/label/c.YG_Close';


let productdetailURL = '', clickhere = '';
export default class YgProductRegistrationGrid extends LightningElement {

    @wire(CurrentPageReference) pageRef;
    @track isLoading = true;
    @track mapData = [];
    @track errorMsg = '';
    isModalOpen = false;
    assetgridData = [];
    loadExternal = true;
    responseData;
    responseDataList = [];
    selectedList = [];
    registerCount;
    modelcode;
    allproductURL;
    chkdup = [];
    checkdup = [];
    label = {
        serialNumber, products, modelSuffix, productionDate, clickHereLbl, regProductLbl, resultLbl, clearResultLbl, registerLbl, selProductLbl, productRegLbl, productRegMsgLbl, viewAllProductLbl, closeLbl
    };
    qrCode = YG_CustomerPortal + '/YG_Images/qrCode.svg';
    hostURL = '';
    qrURL = '';
    counter = 0;

    constructor() {
        super();
        this.loadExternalLibraries();
        //this.loadQRLibraries();
        //this.loadHtmlQRLibraries();

        getCommunityURL({})
            .then(result => {
                this.communityURL = result;
                this.hostURL = this.communityURL.substring(0, this.communityURL.length - 3);
                this.qrURL = this.hostURL + "/apex/YG_QRScan";
                window.console.log("communityURL::" + JSON.stringify(this.communityURL));
                this.allproductURL = this.communityURL + 'all-products';
                productdetailURL = this.communityURL + 'product-history?serialno=';
            }).catch(error => {
                this.error = error;
                console.log('Error: ' + JSON.stringify(this.error));
            });
    }

    renderedCallback() {

        let serialTxtBox = this.template.querySelector('.serial-no');
        let qrIframe = this.template.querySelector('.iframe-QR');
        //serialNoTxt.value = '';
        window.onhashchange = function () {
            //code
            var hash = window.location.hash.substring(1); //Puts hash in variable, and removes the # character
            //alert("hash ==> " + hash);
            if (hash != '') {
                if (hash != 'close') {
                    serialTxtBox.value = hash;
                }
                $(qrIframe).attr('src', '').hide();
                //qrIframe.style.display = "none";
            }
        }
    }

    async loadExternalLibraries() {
        //alert('async');
        loadScript(this, YG_CustomerPortal + '/YG_JS/jquery.min.js').then(() => {
            loadStyle(this, YG_CustomerPortal + '/YG_CSS/dataTables.css').then(() => {
                loadScript(this, YG_CustomerPortal + '/YG_JS/jquery.dataTables.min.js').then(() => {

                    let dataTable, gridChkbox;
                    let selAllChkbox = '<div class="form-check form-check-inline custom-chkbox mr-0">';
                    selAllChkbox += '<input class="form-check-input" type="checkbox" checked name="selectAll" id="selectAll">';
                    selAllChkbox += '<label class="form-check-label d-inline-block" for="selectAll"></label></div>';
                    const table = this.template.querySelector('.productreg-dtTable');
                    const columnHeaders = [selAllChkbox, '', '' + this.label.serialNumber + '', '' + this.label.products + '', '' + this.label.modelSuffix + '', '' + this.label.productionDate + ''];
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
                        "order": [[1, "desc"]],
                        "columnDefs": [{
                            orderable: false,
                            targets: 0
                        }],
                        // Per-row function to iterate cells
                        "createdRow": function (row, data, rowIndex) {
                            // Per-cell function to do whatever needed with cells
                            $.each($('td', row), function (colIndex) {
                                if (colIndex > 0) {
                                    // For example, adding data-* attributes to the cell
                                    $(this).attr('data-title', columnHeaders[colIndex]);
                                } else {
                                    $(this).attr('data-title', '');
                                }
                            });
                        }
                    });
                    this.assetgridData.forEach(function (list) {
                        gridChkbox = '';
                        gridChkbox += '<div class="form-check form-check-inline custom-chkbox mr-0">';
                        gridChkbox += '<input class="form-check-input" type="checkbox" name="serialNo" id="serialNo-' + list.serialNumber + '" value="' + list.serialNumber + '">';
                        gridChkbox += '<label class="form-check-label d-inline-block" for="serialNo-' + list.serialNumber + '"></label></div>';
                        dataTable.row.add([
                            //'<input type="checkbox" checked value="' + list.serialNumber + '" name="serialNo">',
                            gridChkbox,
                            '',
                            list.serialNumber,
                            list.productName,
                            list.msCode,
                            'productionDate'
                        ]);
                    })
                    dataTable.draw();

                    const sectionEle = this.template.querySelector('.section');
                    $('.clear-result', sectionEle).addClass('d-none');

                    const gridTable = this.template.querySelector('.table-responsive');
                    $('input[name="selectAll"]', gridTable).change(function () {
                        if ($(this).is(':checked')) {
                            $('input[name="serialNo"]:not(:disabled)', gridTable).prop('checked', true);
                        } else {
                            $('input[name="serialNo"]', gridTable).prop('checked', false);
                        }
                        if ($('input[name="serialNo"]:checked', gridTable).length > 0) {
                            $('.selectedCnt', sectionEle).html($('input[name="serialNo"]:checked', gridTable).length);
                            $('.clear-result', sectionEle).last().removeClass('d-none');
                        } else {
                            $('.clear-result', sectionEle).last().addClass('d-none');
                        }
                    });

                    $('tbody', gridTable).on('change', 'td input[name="serialNo"]', function () {
                        if ($('input[name="serialNo"]:checked', gridTable).length > 0) {
                            $('.selectedCnt', sectionEle).html($('input[name="serialNo"]:checked', gridTable).length);
                            $('.clear-result', sectionEle).last().removeClass('d-none');
                        } else {
                            $('.clear-result', sectionEle).last().addClass('d-none');
                        }
                    });

                })
            })
        })
    }

    clear() {
        const table = this.template.querySelector('.productreg-dtTable');
        $(table).DataTable().destroy();
        this.assetgridData = [];
        this.responseDataList = [];
        this.checkdup = [];
        this.loadExternalLibraries();
        const secElement = this.template.querySelector('.section');
        $('.clear-result', secElement).addClass('d-none');
        this.clearTxtbox();
    }

    showIcon(event) {

        this.errorMsg = '';
        const serialNoTxt = this.template.querySelector('.serial-no');
        let serialNo = serialNoTxt.value.trim();
        //serialNoTxt.value = serialNo;
        const sectionEle = this.template.querySelector('.section');
        //const closeIcon = this.template.querySelector('.close-icon');

        console.log('serialNo.length' + serialNo.length)

        if (serialNo.length > 0) {
            serialNoTxt.classList.remove('alert-border');
            $('.close-icon', sectionEle).show();
        } else {
            $('.close-icon', sectionEle).hide();
        }
    }

    clearTxtbox(event) {
        let serialNoTxt = this.template.querySelector('.serial-no');
        serialNoTxt.value = '';
        serialNoTxt.classList.remove('alert-border');
        this.showIcon();
    }

    submitSerial() {

        let serialNoTxt = this.template.querySelector('.serial-no');
        let serialNo = serialNoTxt.value.trim();
        serialNoTxt.value = serialNo;
        let minlen = 9;
        let maxlen = 11;
        let chkdup1 = [];
        if (serialNo.length > 0) {

            this.errorMsg = '';
            serialNoTxt.classList.remove('alert-border');

            if (serialNo.length < minlen || serialNo.length > maxlen) {
                serialNoTxt.classList.add('alert-border');
                this.errorMsg = "Please input the serial number between " + minlen + " and " + maxlen + ".";
                return false;
            } else {
                //Do server stuff
                searchSerialNumber({ serialNumber: serialNo })
                    .then(result => {
                        this.assetgridData = result.assetGridList;
                        // productdetailURL = this.communityURL + 'product-history?serialno=';
                        this.modelcode = result.modelCode;
                        productdetailURL = this.communityURL + 'product-details?modcode=' + this.modelcode + '&serialno=';
                        console.log('submitSerial ::assetgridData**' + JSON.stringify(this.assetgridData));
                        console.log('submitSerial :: result**' + JSON.stringify(result));

                        if (result.success === false) {
                            this.errorMsg = 'Serial number not found.';
                            serialNoTxt.classList.add('alert-border');
                        }

                        if (result.serialNumberExist === true) {
                            chkdup1 = this.checkdup;
                            let compareDup = chkdup1.includes(result.assetGridList[0].serialNumber);

                            if (compareDup === false) {
                                this.drawGridOnSearch();
                                this.counter = this.counter + 1;
                            }
                            //this.checkdup.push(serialNo);
                            this.checkdup.push(serialNo.toUpperCase());

                            // this.errorMsg = 'Serial number already exist !';
                            this.errorMsg = '';
                            serialNoTxt.classList.remove('alert-border');
                        }

                    })
                    .catch(error => {
                        this.error = error;
                    })
            }
        } else {
            this.errorMsg = 'Please enter serial number.';
            serialNoTxt.classList.add('alert-border');
        }
    }

    drawGridOnSearch() {

        const secElement = this.template.querySelector('.section');
        $('.clear-result', secElement).removeClass('d-none');

        const table = this.template.querySelector('.productreg-dtTable');
        let dataTable;

        $.fn.dataTableExt.sErrMode = 'none';
        dataTable = $(table).DataTable({
            "paging": false,
            "searching": false, // false to disable search (or any other option)
            "info": false,
            "order": [[1, "desc"]],
            "columnDefs": [{
                orderable: false,
                targets: 0
            }]
        });

        console.log('assetgridData***' + JSON.stringify(this.assetgridData));
        let chkFlag, gridChkbox, chkDisable, addmarginTop, count = this.counter;
        clickhere = this.label.clickHereLbl;
        this.assetgridData.forEach(function (list) {
            chkFlag = '';
            gridChkbox = '';
            chkDisable = (list.flag != undefined && list.flag != '') ? "disabled" : "checked";
            addmarginTop = (list.flag != undefined && list.flag != '') ? "m-mt-45" : "";
            gridChkbox += '<div class="form-check form-check-inline custom-chkbox mr-0 ' + addmarginTop + '">';
            gridChkbox += '<input class="form-check-input" ' + chkDisable + ' type="checkbox" name="serialNo" id="serialNo-' + list.serialNumber + '" value="' + list.serialNumber + '">';
            gridChkbox += '<label class="form-check-label d-inline-block" for="serialNo-' + list.serialNumber + '"></label></div>';
            if (list.flag != undefined && list.flag != '') {
                chkFlag = '<div class="position-absolute f12 alert-orange text-nowrap" style="top: 10px;"><a class="blue-primary text-hover-underline pr-1" href=' + productdetailURL + list.serialNumber + '>' + clickhere + '</a>' + list.flag + '</div>';
                chkFlag += gridChkbox;
                //<input type="checkbox" disabled value="' + list.serialNumber + '" name="serialNo">';
            } else {
                //chkFlag = '<input type="checkbox" checked class="position-relative chkInput" value="' + list.serialNumber + '" name="serialNo">';
                chkFlag = gridChkbox;
            }

            dataTable.row.add([
                chkFlag,
                count,
                list.serialNumber,
                list.productName,
                list.msCode,
                (list.productionDate == null) ? '-' : list.productionDate
            ]).draw();

        })

        $(table).DataTable({
            "order": [1, 'desc']
        });

        const sectionEle = this.template.querySelector('.section');
        const tableField = this.template.querySelector('.table-responsive');
        if ($('input[name="serialNo"]:checked', tableField).length > 0) {
            $('.selectedCnt', sectionEle).html($('input[name="serialNo"]:checked', tableField).length);
            $('.clear-result', sectionEle).last().removeClass('d-none');
        } else {
            $('.clear-result', sectionEle).last().addClass('d-none');
        }
    }

    submitRegister(event) {

        const tableField = this.template.querySelector('.table-responsive');
        let tempArr = [];

        $('input[name="serialNo"]:checked', tableField).each(function () {
            tempArr.push($(this).val());
        });

        console.log('Reg-tempArr' + JSON.stringify(tempArr));
        console.log('Reg-responseDataList' + JSON.stringify(this.responseDataList));

        let result = this.responseDataList;

        console.log('Reg-Result' + JSON.stringify(result));

        result.forEach(function (list, index) {

            if (jQuery.inArray(list.serialNumber, tempArr) != -1) {
            } else {
                result.splice(index, 1);
            }
        });


        let finalCount = tempArr.length;

        registerSerialNumber({ assetToRegisterListAsStr: JSON.stringify(tempArr) })
            .then(resultRegister => {

                console.log('Inside submitRegister ::: result ::: ' + JSON.stringify(resultRegister));

                if (resultRegister.success == true) {
                    //this.openModal();
                    this.isModalOpen = true;
                    this.registerCount = finalCount;
                }

            })
            .catch(error => {
                this.error = error;
                console.log('this.error ::: ' + JSON.stringify(this.error));
            })
    }

    showQR(event) {

        history.replaceState(null, null, ' ');
        const qrIframe = this.template.querySelector('.iframe-QR');
        $(qrIframe).show();
        $(qrIframe).attr('src', this.qrURL)
    }

    closeModal() {
        // to close modal set isModalOpen tarck value as false
        this.isModalOpen = false;
        this.clear();
    }
}