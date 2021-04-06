import { LightningElement, api } from 'lwc';
import YG_CustomerPortal from '@salesforce/resourceUrl/YG_CustomerPortal';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import getProdExtensionDetails from '@salesforce/apex/YG_ProductInformationController.getProdExtensionDetails';

export default class YgOrderingInstructions extends LightningElement {

    @api serialNumber;
    error;
    serialNum = '';
    orderIns = [];
    showIns = false;
    loadExternal = true;

    constructor() {
        super();

        let fullStr = window.location.search.substring(1);
        let splitStr = fullStr.split("&");
        let srlno = '';
        for (var i = 0; i < splitStr.length; i++) {
            var pair = splitStr[i].split("=");
            if (pair[0] == 'serialno') {
                srlno = pair[1];
                this.serialNum = pair[1];
            }
        }
        console.log('this.serialNum::' + this.serialNum);

        this.loadExternalLibraries(this.orderIns);


/*
        getProdExtensionDetails({ serialNo: srlno, type: 'Ordering Instructions' })
            .then(result => {

                if (result.length > 0) {
                    this.showIns = true;
                    console.log('getProdExtensionDetails: ' + JSON.stringify(result));
                    this.orderIns = result;
                }
            })
            .then(() => {
                
            })
            .catch(error => {
                console.log('prodHisError: ' + JSON.stringify(error));
            });*/

    }

    connectedCallback() {
        this.getProdExtension(this.serialNumber);
    }

    @api
    getProdExtension(sNo) {
        if (sNo != undefined) {  

            this.loadExternal = true;

            getProdExtensionDetails({ serialNo: sNo, type: 'Ordering Instructions' })
                .then(result => {
                    if (result.length > 0) {
                        this.showIns = true;
                    }
                    this.orderIns = result;

                    if(this.loadExternal){
                        const table = this.template.querySelector(' .ordIns-dtTable');
                        $(table).DataTable().destroy();
                    }

                })
                .then(() => {
                    if(this.loadExternal){
                        this.loadExternalLibraries(this.orderIns);
                    }
                    this.loadExternal = false;
                })
                .catch(error => {
                    console.log('prodHisError: ' + JSON.stringify(error));
                });
        }
    }

    async loadExternalLibraries(orderIns) {
        loadScript(this, YG_CustomerPortal + '/YG_JS/jquery.min.js').then(() => {
            loadStyle(this, YG_CustomerPortal + '/YG_CSS/dataTables.css').then(() => {
                loadScript(this, YG_CustomerPortal + '/YG_JS/jquery.dataTables.min.js').then(() => {

                    let dataTable;

                    //alert(JSON.stringify(orderIns));

                    const table = this.template.querySelector(' .ordIns-dtTable');

                    const columnHeaders = ['Code', 'Name', 'Description'];
                    let colCnt = columnHeaders.length - 1;

                    let columnHeaderHtml = '<thead><tr>';
                    columnHeaders.forEach(function (header, index) {
                        if (index === colCnt) {
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
                            targets: 2
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


                    orderIns.forEach(function (list) {
                        dataTable.row.add([
                            list.Order_Code__c,
                            list.Name,
                            list.Description__c
                        ]);
                    })
                    dataTable.draw();
                })
            })
        })
    }
}