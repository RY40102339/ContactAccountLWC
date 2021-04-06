import { LightningElement, track, api, wire } from 'lwc';
import getLookUpValues from '@salesforce/apex/YG_SearchController.getLookUpValues';
import { fireEvent, registerListener, unregisterAllListeners } from 'c/pubSub';
import { CurrentPageReference } from 'lightning/navigation';
import { loadScript } from "lightning/platformResourceLoader";
import YG_CustomerPortal from '@salesforce/resourceUrl/YG_CustomerPortal';

export default class YgLookUp extends LightningElement {

    @wire(CurrentPageReference) pageRef;

    @track searchKey;
    @api records;
    @api pageName;
    @api placeHolder;
    @api isTrue;
    @api catName;
    @api modelCode;
    @api systemId;
    selectedRecord;
    selectedRecordList = [];
    excludeRecordList = [];
    recordsExist = false;
    @track customSearchbox = false;
    @track showModPill = false;
    @track showAllPill = false;
    plantCode = '';
    onkeydown = false;
    test = [];

    constructor() {
        super();

        let fullStr = window.location.search.substring(1);
        let splitStr = fullStr.split("&");
        for (var i = 0; i < splitStr.length; i++) {
            var pair = splitStr[i].split("=");
            if (pair[0] == 'pc') {
                this.plantCode = pair[1];
            }
        }

        this.loadExternalLibraries();
    }

    connectedCallback() {
        console.log("In connectedCallback ::: ");
        registerListener("plantAutoFilter", this.removeSelectedValue, this);
        registerListener('plantFilter', this.getPlantCode, this);
        registerListener('selectedSystem',this.getSystemId,this);
        registerListener('defaultSystem',this.getSystemId,this);
    }

    disconnectedCallback() {
        console.log("this disconnectedCallback");
        unregisterAllListeners(this);
    }

    getPlantCode(plantCode) {

        this.plantCode = plantCode;
    }

    getSystemId(result){
        this.systemId = result;
    }

    removeSelectedValue(plantCode) {
        // alert('here');
        //this.clearAll();        
        this.selectedRecordList = [];
        this.excludeRecordList = [];
        this.searchKey = '';
        this.customSearchbox = false;
        //fireEvent(this.pageRef, 'filterRecords', this.selectedRecordList);
    }

    async loadExternalLibraries() {
        loadScript(this, YG_CustomerPortal + '/YG_JS/jquery.min.js').then(() => {

            let sldsLookup = this.template.querySelector(".slds-lookup");
            let lookupInput = this.template.querySelector(".filterInput");
            sldsLookup = $(sldsLookup);

            $("body").on("click", function () {
                $('.searchRes', sldsLookup).addClass("slds-hide");
                lookupInput.value = '';
            });

            sldsLookup.on("click", function (event) {
                event.stopPropagation();
            });
        });
    }

    renderedCallback() {

        if (this.customSearchbox === true) {
            this.template.querySelector('.customTxtbox').focus();
        }

        if (this.onkeydown === true) {

            const plantDD = this.template.querySelector('.filterInput');
            const liplant = this.template.querySelectorAll('li.filterLi');
            let li = $(liplant);
            let liSelected;
            let next;

            $(plantDD).keydown(function (e) {

                if (e.which === 13) {
                    e.preventDefault();

                    li.each(function () {
                        if ($(this).hasClass("selected")) {
                            if ($(this).html() != "") {
                                //$(this).trigger('click'); 
                                console.log("$(this).html()" + $(this).html())
                                //$(this).trigger('click', [false]);
                                $(this).click();
                                //return false;
                            }
                        }
                    });
                }

                li.removeClass('selected');
                if (e.which === 40) {
                    e.preventDefault();
                    if (liSelected) {
                        //liSelected.removeClass('selected');
                        next = liSelected.next();
                        if (next.length > 0) {
                            liSelected = next.addClass('selected');

                        } else {
                            liSelected = li.eq(0).addClass('selected');
                        }
                    } else {
                        liSelected = li.eq(0).addClass('selected');
                    }
                } else if (e.which === 38) {
                    e.preventDefault();
                    if (liSelected) {
                        //liSelected.removeClass('selected');
                        next = liSelected.prev();
                        if (next.length > 0) {
                            liSelected = next.addClass('selected');
                        } else {
                            liSelected = li.last().addClass('selected');
                        }
                    } else {
                        liSelected = li.last().addClass('selected');
                    }
                }
            });
            //this.onkeydown = false;
        }

    }

    handleChange(event) {

        this.searchKey = event.target.value;

        if (this.searchKey.length > 2) {

            if (this.catName === undefined) {
                this.catName = null;
            }
            if (this.modelCode === undefined) {
                this.modelCode = '';
            }
            if (this.plantCode === undefined) {
                this.plantCode = '';
            }
            if (this.systemId === undefined) {
                this.systemId = '';
            }

            getLookUpValues({
                searchKeyWord: this.searchKey, excludedRec: this.excludeRecordList, pageName: this.pageName,
                catName: this.catName, modelCode: this.modelCode, lang: "EN",
                plantCode: this.plantCode, projectCode: this.systemId
            })
                .then(result => {

                    console.log('Inside getLookUpValues this.result;  ::' + JSON.stringify(result));

                    if (result.length === 0) {
                        this.records = 'No data found';
                        console.log(this.records);
                        this.recordsExist = false;
                    } else {
                        this.records = result;
                        let temparr = [];
                        let name;
                        //alert('this.records::' + JSON.stringify(this.records))
                        this.records.forEach(function (list) {

                            if (list.Model_Code__c != undefined) {
                                name = list.Model_Code__c;
                                temparr.push({ Id: list.Id, Name: name });

                            } else if (list.Name != undefined) {
                                name = list.Name;
                                temparr.push({ Id: list.Id, Name: name });

                            } else if (list.Service_you_require__c != undefined) {
                                name = list.Service_you_require__c;
                                temparr.push({ Id: list.Id, Name: name });

                            } else if (list.Reason != undefined) {
                                name = list.Reason;
                                temparr.push({ Id: list.Id, Name: name });

                            } else if (list.MS_Code__c != undefined) {
                                name = list.MS_Code__c;
                                temparr.push({ Id: list.Id, Name: name });

                            } else if (list.Contract_No__c != undefined) {
                                name = list.Contract_No__c;
                                temparr.push({ Id: list.Id, Name: name });

                            } else {

                                name = list.Product2.Product_Categories__c;
                                temparr.push({ Id: list.Product2.Id, Name: name });
                            }

                            /* if (list.Name != undefined) {
                                name = list.Name;
                                id = list.Id;
                            }*/
                            //console.log('Inside');

                            //let temparr1 = [];

                            //temparr.push({ Id: list.Id, Name: name });

                        })

                        this.records = temparr;
                        console.log('result::' + JSON.stringify(result));
                        console.log('this.records::' + JSON.stringify(this.records));
                        this.error = undefined;
                        this.recordsExist = true;
                    }
                }).then(() => {
                    if (this.searchKey.length > 0) {
                        this.template.querySelector('.searchRes').classList.remove('slds-hide');
                    } else {
                        this.template.querySelector('.searchRes').classList.add('slds-hide');
                    }
                }).catch(error => {
                    this.error = error;
                    this.records = undefined;
                })

            this.onkeydown = true;
        } else {
            this.template.querySelector('.searchRes').classList.add('slds-hide');
        }
    }

    handleSelect(event) {

        console.log('handle select');
        this.selectedRecord = $(event.currentTarget).attr('data-id');
        this.searchKey = '';
        this.selectedRecordList.push({ Id: $(event.currentTarget).attr('data-id'), Name: $(event.currentTarget).attr('data-lable') });

        let temparr = [];
        let name;
        this.selectedRecordList.forEach(function (list) {
            if (list.Model_Code__c != undefined) {
                name = list.Model_Code__c;
                temparr.push({ Id: list.Id, Name: name });
            } else if (list.Name != undefined) {
                name = list.Name;
                temparr.push({ Id: list.Id, Name: name });
            } else {
                name = list.Product2.Product_Categories__c;
                temparr.push({ Id: list.Product2.Id, Name: name });
            }
            /*if (list.Model_Code__c != undefined) {
                name = list.Model_Code__c;
            } else {
                name = list.Name;
            }
            temparr.push({ Id: list.Id, Name: name });*/

        })
        //this.selectedRecordList = temparr;
        this.template.querySelector('.searchRes').classList.add('slds-hide');
        //this.excludeRecordList.push({Id : $(event.currentTarget).attr('data-id')});
        this.excludeRecordList = temparr;
        if (this.selectedRecordList.length > 0) {
            this.customSearchbox = true;
            fireEvent(this.pageRef, 'filterRecords', this.selectedRecordList);
            fireEvent(this.pageRef, 'clearBtnFilter', 'clear');
        }

        this.onkeydown = false;
    }

    handleRemove(event) {

        this.searchKey = '';
        this.template.querySelector('.searchRes').classList.add('slds-hide');

        let removedRecord = event.target.label;

        console.log("removedRecord" + removedRecord);

        //this.plantCode = this.plantCode;

        this.selectedRecordList.forEach(function (list, i, object) {
            if (removedRecord === list.Name) {
                object.splice(i, 1);
            }
            if (removedRecord === list.Model_Code__c) {
                object.splice(i, 1);
            }

            /*
            if (removedRecord === list.Product2.Product_Categories__c) {
                object.splice(i, 1);
            }*/
        })
        //alert('this.excludeRecordList::' + JSON.stringify(this.excludeRecordList))
        this.excludeRecordList.forEach(function (list, i, object) {
            if (removedRecord === list.Name) {
                object.splice(i, 1);
            }
            if (removedRecord === list.Model_Code__c) {
                object.splice(i, 1);
            }

            /*
            if (removedRecord === list.Product2.Product_Categories__c) {
                object.splice(i, 1);
            }*/
        })
        console.log("this.selectedRecordList" + JSON.stringify(this.selectedRecordList));
        console.log("this.excludeRecordList" + JSON.stringify(this.excludeRecordList));
        //alert(JSON.stringify(this.excludeRecordList))
        //alert(JSON.stringify(this.selectedRecordList))

        if (this.selectedRecordList.length == 0) {
            this.customSearchbox = false;
            fireEvent(this.pageRef, 'clearBtnFilter', 'clear');
        }
        fireEvent(this.pageRef, 'filterRecords', this.selectedRecordList);
        console.log("event" + JSON.stringify(event));

        getLookUpValues({
            searchKeyWord: this.searchKey, excludedRec: this.excludeRecordList, pageName: this.pageName,
            catName: this.catName, modelCode: this.modelCode, lang: "EN",
            plantCode: this.plantCode
        })
            .then(result => {
                this.records = result;
                this.error = undefined;
            })
            .catch(error => {
                this.error = error;
                this.records = undefined;
            })

        this.onkeydown = false;
    }

    clearAll(event) {

        this.selectedRecordList = [];
        this.excludeRecordList = [];
        this.searchKey = '';
        this.customSearchbox = false;
        fireEvent(this.pageRef, 'filterRecords', this.selectedRecordList);
        fireEvent(this.pageRef, 'clearBtnFilter', 'clear');
    }
}