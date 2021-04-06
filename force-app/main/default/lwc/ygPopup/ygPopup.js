import { LightningElement, api, track, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import getProductDetailMsCode from '@salesforce/apex/YG_ProductDetailGrid.getProductDetailMsCodeGrid';
import getSuffixCodes from '@salesforce/apex/YG_ProductAvailabilityController.getSuffixCodes';
import { fireEvent, registerListener, unregisterAllListeners } from 'c/pubSub';
import { loadScript, loadStyle } from "lightning/platformResourceLoader";
import YG_CustomerPortal from '@salesforce/resourceUrl/YG_CustomerPortal';
import loadingLbl from "@salesforce/label/c.YG_Loading";
import mscodeLbl from "@salesforce/label/c.YG_MS_code";
import orderAvaiLbl from "@salesforce/label/c.YG_Order_availability";
import reorderLbl from "@salesforce/label/c.YG_Re_order";
import reqQtnLbl from "@salesforce/label/c.YG_Request_for_quotation";
import modelLbl from "@salesforce/label/c.YG_Model";
import availLbl from "@salesforce/label/c.YG_Availability";
import sufcodeLbl from "@salesforce/label/c.YG_Suffix_Code";
import descLbl from "@salesforce/label/c.YG_Sys_Description";


let tempArr = [];
export default class YgPopup extends LightningElement {

    @wire(CurrentPageReference) pageRef;

    label = {
        loadingLbl, mscodeLbl, orderAvaiLbl, reorderLbl, reqQtnLbl, modelLbl, availLbl,
        sufcodeLbl, descLbl
    };

    @track isMSCodeModalOpen = false;
    @api msCode;
    @api productName;
    @api productIndex;
    @track isLoading = true;
    communityURL = '';
    productAviWrap = {};
    suffixCodeList = [];
    loadExternal = true;
    servReqURL = '';
    prevSec = false;
    nextSec = false;
    modCode = '';
    msCodeListCnt = 0;

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
        }
        //this.loadExternalLibraries();
        this.getLoadMSCodes();
    }

    getLoadMSCodes() {
        getProductDetailMsCode({ modelcode: this.modCode, filterValue: null }).then(result => {
            console.log('RESULT****' + JSON.stringify(result));
            tempArr = [];
            result.msCodeDataLists.forEach(function (stat) {
                tempArr.push(stat.msCode);

            })
        }).then(() => {
            if (parseInt(this.productIndex) == 0) {
                this.prevSec = false;
                this.nextSec = true;
            }
            this.msCodeListCnt = parseInt(tempArr.length) - 1;
            if (parseInt(this.productIndex) == this.msCodeListCnt) {
                this.prevSec = true;
                this.nextSec = false;
            }
            if (parseInt(tempArr.length) == 0 || parseInt(tempArr.length) == 1) {
                this.prevSec = false;
                this.nextSec = false;
            }
            if ((parseInt(this.productIndex) > 0) && (parseInt(this.productIndex) < this.msCodeListCnt)) {
                this.prevSec = true;
                this.nextSec = true;
            }
        }).catch(error => {
        })
    }

    connectedCallback() {
        this.getproductAvaiDetails(this.msCode);
        registerListener('communityURL', this.getcommunityURL, this);
    }

    disconnectedCallback() {
        unregisterAllListeners(this);
    }

    getcommunityURL(commURL) {
        this.communityURL = commURL;
    }

    getPrevProductAvaiDetails() {

        this.productIndex = parseInt(this.productIndex) - 1;
        this.loadExternal = true;
        if (this.productIndex == 0) {
            this.prevSec = false;
            this.nextSec = true;
        } else {
            this.prevSec = true;
            this.nextSec = true;
        }
        if (this.loadExternal == true) {
            const table = this.template.querySelector('.suffixCode-dtTable');
            $(table).DataTable().destroy();
        }
        this.getproductAvaiDetails(tempArr[this.productIndex]);
    }

    getNextProductAvaiDetails() {

        this.productIndex = parseInt(this.productIndex) + 1;
        this.loadExternal = true;
        if (this.productIndex == this.msCodeListCnt) {
            this.nextSec = false;
            this.prevSec = true;
        } else {
            this.prevSec = true;
            this.nextSec = true;
        }
        if (this.loadExternal == true) {
            const table = this.template.querySelector('.suffixCode-dtTable');
            $(table).DataTable().destroy();
        }
        this.getproductAvaiDetails(tempArr[this.productIndex]);
    }

    getproductAvaiDetails(msCode) {

        this.productAviWrap = {};
        this.suffixCodeList = [];
        this.isLoading = true;
        getSuffixCodes({ msCode: msCode })
            .then(result => {

                this.productAviWrap = result;
                this.suffixCodeList = result.suffix;
                this.servReqURL = this.communityURL + 'service-request-and-inquiries?mscode=' + this.msCode;
                console.log("suffixCodeList ==> " + JSON.stringify(this.suffixCodeList));

                // if (this.loadExternal == true) {
                //     const table = this.template.querySelector('.suffixCode-dtTable');
                //     $(table).DataTable().destroy();
                // }

            }).then(() => {
                if (this.loadExternal == true) {
                    this.loadExternalLibraries();
                }
                this.loadExternal == false;
            }).then(() => {
                this.isLoading = false;
            }).catch(error => {
                this.isLoading = false;
                console.log('msCode Err::' + JSON.stringify(error.message));
            })

    }

    async loadExternalLibraries() {
        loadScript(this, YG_CustomerPortal + '/YG_JS/jquery.min.js').then(() => {
            loadStyle(this, YG_CustomerPortal + '/YG_CSS/dataTables.css').then(() => {
                loadScript(this, YG_CustomerPortal + '/YG_JS/jquery.dataTables.min.js').then(() => {

                    let dataTable;

                    const table = this.template.querySelector('.suffixCode-dtTable');
                    const columnHeaders = [this.label.sufcodeLbl, '', this.label.descLbl, this.label.availLbl];

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
                        "order": [],
                        "columnDefs": [
                            {
                                orderable: false,
                                targets: [1, 2, 3]
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

                    let notiHtml = '';

                    (this.suffixCodeList || []).forEach(function (list) {

                        notiHtml = '';

                        if (list.suffixSpecDesc != undefined) {

                            if (list.suffixSpecDesc.length > 0) {
                                notiHtml += list.suffixSpecDesc;
                            }
                            else {
                                notiHtml += '-';
                            }

                            dataTable.row.add([
                                list.suffixCode,
                                list.suffixLevelName,
                                notiHtml,
                                list.suffixStatus
                            ]);
                        }
                    })
                    dataTable.draw();
                })
            })
        })
    }
    //To close the pop window
    closeModal() {
        // to close modal set isMSCodeModalOpen track value as false
        //this.isMSCodeModalOpen = false;
        fireEvent(this.pageRef, 'isMSCodeModalOpen', false);
    }

}