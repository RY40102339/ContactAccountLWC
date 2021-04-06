import { LightningElement, track, wire, api } from 'lwc';
import getAssetDetail from '@salesforce/apex/YG_CombinationProduct.getAssetDetails';
import getCommunityURL from '@salesforce/apex/YG_Utility.getCommunityURL';
import { CurrentPageReference } from 'lightning/navigation';
import combinationProductLbl from '@salesforce/label/c.YG_Combination_Product';

export default class YgCombinationProduct extends LightningElement {
    @wire(CurrentPageReference) pageRef;
    @track isLoading = true;
    @api serialNumber;
    parentrec = '';
    parentrecSerailNo = '';
    childData = [];
    childList = [];
    serialNum; modcode = '';
    error;
    parentSerialNoURL;
    childFlag = false;
   

    label = {
        combinationProductLbl
    };

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
            if (pair[0] == 'modcode') {
                this.modcode = pair[1];
            }
        }
        console.log('this.serialNum::' + this.serialNum);

        getCommunityURL({})
            .then(result => {
                this.communityURL = result;
                window.console.log("communityURL::" + JSON.stringify(this.communityURL));
            }).catch(error => {
                this.error = error;
                console.log('Error: ' + JSON.stringify(this.error));
            });
/*
        getAssetDetail({ assetIds: this.serialNum })
            .then(result => {
                this.isLoading = false;
                this.parentrec = result.parent;
                this.childData = result.childDataList;
                this.parentrecSerailNo = result.parentSerialNo;
                if(result.childFlag == true){
                    this.childFlag = true;
                }
            }).then(() => {
                this.getchildList(this.communityURL);
            }).catch(error => {
                this.isLoading = false;
                this.error = error;
                console.log('Error: ' + JSON.stringify(this.error));
            });*/

    }

    connectedCallback() {
        //registerListener("plantFilter", this.getFilteredProductInfomationPlant, this);
        this.getCombinationInfo(this.serialNumber)
    }

    @api
    getCombinationInfo(sNo) {

        if (sNo != undefined) {

            this.serialNum = sNo;

            getAssetDetail({ assetIds: sNo })
                .then(result => {
                    this.isLoading = false;
                    this.parentrec = result.parent;
                    this.childData = result.childDataList;
                    this.parentrecSerailNo = result.parentSerialNo;
                    if(result.childFlag == true){
                        this.childFlag = true;
                    }
                }).then(() => {
                    this.getchildList(this.communityURL);
                }).catch(error => {
                    this.isLoading = false;
                    this.error = error;
                    console.log('Error: ' + JSON.stringify(this.error));
                });
        }
    }

    getchildList(comURL) {

        let parentURL, temparr = [], serialNo = this.serialNum, linkURL, className = '', modcode = this.modcode;
        const parentElement = this.template.querySelector(".parentRecord");
        if (this.serialNum == this.parentrecSerailNo) {
            $(parentElement).html('<strong>' + this.parentrecSerailNo + '</strong>');
        }
        else {
            parentURL = comURL + 'product-details?modcode='+modcode+'&serialno=' + this.parentrecSerailNo;
            $(parentElement).html('<a class="blue-primary text-hover-underline" href=' + parentURL + '>' + this.parentrecSerailNo + '</a>');
        }

        this.childData.forEach(function (list) {

            linkURL = '';
            className = '';
            if (serialNo == list.childSerialNo) {
                linkURL = '#';
                className = 'text-decoration-none fbold grey-darkest disabled';
            }
            else {
                linkURL = comURL + 'product-details?modcode='+modcode+'&serialno=' + list.childSerialNo;
                className = 'blue-primary text-hover-underline';
            }

            temparr.push({ child: list.child, childserial: list.childSerialNo, linkURL: linkURL, className: className });
        });

        this.childList = temparr;
    }

}