import { LightningElement, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { fireEvent, registerListener, unregisterAllListeners } from 'c/pubSub';
import getCommunityURL from '@salesforce/apex/YG_Utility.getCommunityURL';
import getContractInfo from '@salesforce/apex/YG_AllServiceContractsController.getContractInfo';
import contInformationLbl from '@salesforce/label/c.YG_Contract_Information';
import contractNoLbl from '@salesforce/label/c.YG_Contract_no';
import contractNameLbl from '@salesforce/label/c.YG_Contract_name';
import contractSerialNumLbl from '@salesforce/label/c.YG_Serial_num';
import requestedByLbl from '@salesforce/label/c.YG_Requested_by';
import salesManagerLbl from '@salesforce/label/c.YG_Yokogawa_Sales_Manager';
import startDateLbl from '@salesforce/label/c.YG_Start_date';
import endDateLbl from '@salesforce/label/c.YG_End_date';
import contractDescLbl from '@salesforce/label/c.YG_Contract_description';
import prodNameLbl from '@salesforce/label/c.YG_Product_name';
import serialNumLbl from '@salesforce/label/c.YG_Serial_num';

export default class YgContractInformation extends LightningElement {

    @wire(CurrentPageReference) pageRef;
    label = {
        contInformationLbl, contractNoLbl, contractNameLbl, contractSerialNumLbl, requestedByLbl, salesManagerLbl,
        startDateLbl, endDateLbl, contractDescLbl, prodNameLbl, serialNumLbl
    };
    contractdInfoData;
    contType = false;
    // error;
    // plant_Code = '';
    // serial;
    // hostURL;
    contractNum;
    contractHeader = '';
    communityURL;
    productDetailURL;



    constructor() {
        super();

        // let fullStr = window.location.search.substring(1);
        // let splitStr = fullStr.split("&");
        // let srlno = '';
        // let communityURL;
        // for (var i = 0; i < splitStr.length; i++) {
        //     var pair = splitStr[i].split("=");
        //     if (pair[0] == 'serialno') {
        //         srlno = pair[1];
        //         this.serial = pair[1];
        //     }
        // }
        // getCommunityURL()
        //     .then(result => {
        //         communityURL = result;
        //         this.hostURL = result;
        //     })
        //     .catch(error => {
        //         this.error = error;
        //         console.log('communityURL: ' + JSON.stringify(this.error));
        //     });

        // /*getProductInformation({serialNo : srlno})
        // .then(result => {
        //     this.prodInfoData =  result;
        //     fireEvent(this.pageRef,'prodHisName',result);
        //     fireEvent(this.pageRef,'prodHisBackButton',result);
        // }).catch(error => {
        //     this.error = error;
        //     console.log('prodInfoDataError: '+JSON.stringify(this.error));
        // });*/
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

        getCommunityURL({})
            .then(result => {
                this.communityURL = result;

            }).then(() => {
                getContractInfo({ contractNumber: this.contractNum })
                    .then(result => {
                        console.log('this.result: ' + JSON.stringify(result));
                        this.contractdInfoData = result;
                        console.log('this.contractdInfoData: ' + JSON.stringify(this.contractdInfoData));
                        console.log('result.contTypeLCA: ' + JSON.stringify(result.contTypeLCA));
                        console.log('result.serialNum' + JSON.stringify(result.serialNum));
                        this.productDetailURL = this.communityURL + 'product-details?modcode=' + result.modCode + '&serialno=' + result.serialNum;
                        if (result.serialNum === '') {
                            this.contractHeader = result.contractDescription;
                        } else {
                            this.contractHeader = result.contractName;
                        }
                        console.log('this.contractHeader:::' + this.contractHeader);
                        fireEvent(this.pageRef, 'serviceContractDetails', this.contractHeader);

                    }).catch(error => {
                        this.error = error;
                        console.log('contractdInfoDataError: ' + JSON.stringify(this.error));
                    });
            }).catch(error => {
                this.error = error;
                console.log('prodInfoDataError: ' + JSON.stringify(this.error));
            });

    }

    connectedCallback() {
        registerListener("plantFilter", this.getFilteredProductInfomationPlant, this);
    }

    disconnectedCallback() {
        unregisterAllListeners(this);
    }

    getFilteredProductInfomationPlant(plantCode) {
        // this.plant_Code = plantCode;
        // getProductInformation({ serialNo: this.serial, plantCode: this.plant_Code })
        //     .then(result => {
        //         console.log('productInfo' + JSON.stringify(result));
        //         console.log('productInfo serialNoCode' + JSON.stringify(result.serialNoCode));
        //         if (result.serialNoCode === undefined) {
        //             console.log('Inside if >>>> ');
        //             let url = this.hostURL + 'all-products?pc=' + this.plant_Code;
        //             console.log('URL >>>> ' + url);
        //             window.location.href = url;
        //         }
        //         else {
        //             this.prodInfoData = result;
        //             fireEvent(this.pageRef, 'prodHisName', result);
        //             fireEvent(this.pageRef, 'prodHisBackButton', result);
        //         }
        //         this.template.querySelector('.col-lg-10').classList.add('m-l-r-12');
        //     }).catch(error => {
        //         this.error = error;
        //         console.log('prodInfoDataError: ' + JSON.stringify(this.error));
        //     });
    }

}