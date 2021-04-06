import { LightningElement, track, wire } from 'lwc';
import { loadScript, loadStyle } from "lightning/platformResourceLoader";
import YG_CustomerPortal from "@salesforce/resourceUrl/YG_CustomerPortal";
import { CurrentPageReference } from 'lightning/navigation';
import { fireEvent, registerListener, unregisterAllListeners } from 'c/pubSub';
import getServiceMenuList from '@salesforce/apex/YG_AllServiceContractsController.getServiceMenuList';
import getContractInfo from '@salesforce/apex/YG_AllServiceContractsController.getContractInfo';
import getContractServMenu from '@salesforce/apex/YG_ContractAPIHandler.getContractServMenu';
import getInspectionDetails from '@salesforce/apex/YG_ContractAPIHandler.getInspectionDetails';
import serviceMenuHeadingLbl from '@salesforce/label/c.YG_ServiceMenuHeading';
import serviceMenuGridLbl from '@salesforce/label/c.YG_ServicemenuGridcolumn';
import entitlementTypeLbl from '@salesforce/label/c.YG_Entitlement_type';
import perLbl from '@salesforce/label/c.YG_Per';
import entitlementQtyLbl from '@salesforce/label/c.YG_Entitlement_quantity';
import EntitlementBalanceLbl from '@salesforce/label/c.YG_Entitlement_balance';
import contractForLbl from '@salesforce/label/c.YG_ContractFor';

export default class YgAllContractsGrid extends LightningElement {

    @wire(CurrentPageReference) pageRef;

    label = {
        serviceMenuHeadingLbl, serviceMenuGridLbl, entitlementTypeLbl, perLbl, entitlementQtyLbl, EntitlementBalanceLbl,
        contractForLbl
    };
    @track isLoading = true;
    error;
    loadExternal = true;
    serviceMenuGridData = [];
    contractNum;
    serviceMenuGridHeader;
    contractServMenu = new Map();

    constructor() {

        super();
        let pageURL = window.location.href;
        let pagePath = window.location.pathname;
        let pageName = pagePath.substr(3);


        let fullStr = window.location.search.substring(1);
        let splitStr = fullStr.split("&");
        let modno = '';
        for (var i = 0; i < splitStr.length; i++) {
            var pair = splitStr[i].split("=");
            if (pair[0] == 'contractno') {
                modno = pair[1];
                this.contractNum = pair[1];
            }
        }

        getContractServMenu({ lcaNo: this.contractNum })
            .then(result => {
                if (result != null) {
                    this.contractServMenu = result;

                    console.log('getContractServMenu::' + JSON.stringify(result));
                    return result; // Map - Key: plant code and Value: plant id
                }
            })
            .then(result => {
                if (result != null) {
                    //get the deliverable no and system details based on customer plant
                    getInspectionDetails({ result: this.contractServMenu })
                        .then(result => {
                            console.log('getInspectionDetails::' + JSON.stringify(result));
                            return result; // List - deliverablesNo and plantCode and systemIdCrm

                        })
                        .then(result => {
                            if (result != null) {
                                //call station list api based in system details
                                getServiceMenuList({ contractNum: this.contractNum })
                                    .then(result => {
                                        console.log('this.result: ' + JSON.stringify(result));
                                        this.serviceMenuGridData = result.servMenuList;
                                        console.log('this.serviceMenuGridData: ' + JSON.stringify(this.serviceMenuGridData));
                                        fireEvent(this.pageRef, 'notiBarContractDetails', result);
                                        if (result.contractType === 'LCA') {
                                            this.serviceMenuGridHeader = this.label.serviceMenuHeadingLbl;
                                        } else {
                                            this.serviceMenuGridHeader = this.label.contractForLbl + ' ' + result.productName;
                                        }
                                    }).then(() => {
                                        this.loadExternalLibraries();
                                    }).then(() => {
                                        console.log('isLoading 0::');

                                        this.isLoading = false;
                                    }).catch(error => {
                                        this.error = error;
                                        console.log('serviceMenuGridDataError: ' + JSON.stringify(this.error));
                                    });
                            }
                        })
                }
            })
            .catch(error => {
                console.log('Plant Details Error: ' + JSON.stringify(error.message));
            })
        //this.getallServiceMenu();
        /*getServiceMenuList({ contractNum: this.contractNum })
            .then(result => {
                console.log('this.result: ' + JSON.stringify(result));
                this.serviceMenuGridData = result.servMenuList;
                console.log('this.serviceMenuGridData: ' + JSON.stringify(this.serviceMenuGridData));
                fireEvent(this.pageRef, 'notiBarContractDetails', result);
                if (result.contractType === 'LCA') {
                    this.serviceMenuGridHeader = this.label.serviceMenuHeadingLbl;
                } else {
                    this.serviceMenuGridHeader = this.label.contractForLbl + ' ' + result.productName;
                }
            }).then(() => {
                this.loadExternalLibraries();
            }).catch(error => {
                this.error = error;
                console.log('serviceMenuGridDataError: ' + JSON.stringify(this.error));
            });*/

    }


    async loadExternalLibraries() {
        loadScript(this, YG_CustomerPortal + '/YG_JS/jquery.min.js').then(() => {
            loadStyle(this, YG_CustomerPortal + '/YG_CSS/dataTables.css').then(() => {
                loadScript(this, YG_CustomerPortal + '/YG_JS/jquery.dataTables.min.js').then(() => {

                    let dataTable;

                    const table = this.template.querySelector('.ContractDetails-dtTable');
                    const columnHeaders = [this.label.serviceMenuGridLbl, this.label.entitlementTypeLbl, this.label.perLbl, this.label.entitlementQtyLbl, this.label.EntitlementBalanceLbl];

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
                        // Per-row function to iterate cells
                        "createdRow": function (row, data, rowIndex) {
                            // Per-cell function to do whatever needed with cells
                            $.each($('td', row), function (colIndex) {
                                // For example, adding data-* attributes to the cell
                                $(this).attr('data-title', columnHeaders[colIndex]);
                            });
                        }
                    });

                    this.serviceMenuGridData.forEach(function (list) {

                        dataTable.row.add([
                            list.serviceMenu,
                            list.entitlementType,
                            list.per,
                            list.entitlementQuantity,
                            list.entitlementBalance
                        ]);
                    })
                    dataTable.draw();
                })
            })
        })
    }
}