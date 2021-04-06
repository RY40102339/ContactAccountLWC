import { LightningElement, track } from 'lwc';
import YG_CustomerPortal from "@salesforce/resourceUrl/YG_CustomerPortal";
import { loadStyle, loadScript } from "lightning/platformResourceLoader";
import getCategoryLevel1 from "@salesforce/apex/YG_DocumentSearchController.getCategoryLevel1";
import getCategoryHierarchy from "@salesforce/apex/YG_DocumentSearchController.getCategoryHierarchy";
import getCustomConfig from '@salesforce/apex/YG_Utility.getCustomConfig';
import getSearchCertificate from "@salesforce/apex/YG_CertificateSearchAPIHandler.searchCertificate";
import getDirectiveSearch from "@salesforce/apex/YG_CertificateSearchAPIHandler.getDirectiveSearch";
import showLbl from '@salesforce/label/c.YG_Show';
import moreLbl from '@salesforce/label/c.YG_MoreProducts';

export default class YgSearchCertificatesGrid extends LightningElement {

    searchIcon = YG_CustomerPortal + '/YG_Images/icons/search-32x32.svg';
    categoryLevel1 = [];
    error;
    @track certAllDirectiveData;
    @track certDirectiveData = [];
    @track certSearchData = [];
    @track mapData = [];
    @track isLoading = true;
    @track showLoadMore = false;
    startRecord = 0;
    loadedRecord = 0;
    remainRecords = 0;
    recordLoadLimit = 0;
    keyword = '';
    modelTxt = '';
    msCode = '';
    certNumber = '';
    categoryVal = '';
    modelValue = '';
    certificateType = '';
    totalCnt = 0;
    label = {
        showLbl, moreLbl
    };

    constructor() {
        super();

        getCategoryLevel1({})
            .then((result) => {
                console.log('Result ===> ' + JSON.stringify(result))
                let tempArr = [];
                for (let key in result) {
                    // Preventing unexcepted data
                    if (result.hasOwnProperty(key)) { // Filtering the data in the loop
                        tempArr.push({ key: result[key], value: key });
                    }
                }
                console.log('tempArr ===> ' + JSON.stringify(tempArr))
                this.categoryLevel1 = tempArr;
            }).then(() => {
                getDirectiveSearch()
                    .then(result => {
                        console.log('Rewsult getDirectiveSearch: ' + JSON.stringify(result));
                        this.certAllDirectiveData = result.allDerivativeCode;
                        this.certDirectiveData = result.ResponseData;
                        console.log('Rewsult getDirectiveSearch: ' + JSON.stringify(result.ResponseData));
                    }).catch(error => {
                        this.error = error.message;
                        console.log('getDirectiveSearch: ' + JSON.stringify(this.error));
                    });
            }).then(() => {
                this.loadChoosenLibraries();
            }).then(() => {
                getCustomConfig()
                    .then(result => {
                        var conts = result;
                        for (var key in conts) {
                            this.mapData.push({ value: conts[key], key: key });
                            if (key == "Search API Load Record Limit") {
                                let val = conts[key];
                                this.recordLoadLimit = parseInt(val.Text_1__c);
                            }
                        }
                        console.log('this.recordLoadLimit==>' + this.recordLoadLimit);
                    })
                    .catch(error => {
                        this.error = error.message;
                        console.log('communityURL: ' + JSON.stringify(this.error));
                    });
            }).catch((error) => {
                this.error = error;
                console.log("Error: " + JSON.stringify(this.error));
            });
    }

    async loadChoosenLibraries() {
        loadStyle(this, YG_CustomerPortal + "/YG_CSS/chosen.css").then(() => {
            loadScript(this, YG_CustomerPortal + "/YG_JS/chosen.jquery.js").then(() => {
                loadStyle(this, YG_CustomerPortal + "/YG_CSS/jBox.all.min.css").then(() => {
                    loadScript(this, YG_CustomerPortal + "/YG_JS/jBox.all.min.js").then(() => {
                        const selectpicker = this.template.querySelector(".selectpicker");
                        const tooltip = this.template.querySelectorAll(".jbox-tooltip");
                        const searchEle = this.template.querySelector(".dc-search");
                        const triggerClick = this.template.querySelector(".triggerClick");

                        $(searchEle).find('.dc-type .form-check-input').eq(0).prop("checked", true);

                        $(selectpicker)
                            .chosen({
                                disable_search: true
                            })
                            .change(function (e) {

                                $(".service-request", searchEle).find(".form-group").not(":first").remove();
                                $(selectpicker).val($(this).val()).trigger("chosen:updated");
                                if ($(this).val() != 0) {
                                    $('input[name=modelTxt], input[name=msCode]', searchEle).prop('disabled', true)
                                } else {
                                    $('input[name=modelTxt], input[name=msCode]', searchEle).prop('disabled', false)
                                }
                                $('input[name=hiddenLevel]', searchEle).val($(this).val());
                                if ($(this).val() != 0) {
                                    triggerClick.click();
                                }
                            });

                        const isMobile = /iPad|iPhone|iPod|Android|webOS|BlackBerry|Windows Phone/.test(navigator.userAgent) && !window.MSStream;
                        let chkMobile = isMobile ? 'touchstart' : 'mouseenter';

                        new jBox('Tooltip', {
                            attach: tooltip,
                            width: 440,
                            theme: "TooltipBorder",
                            trigger: chkMobile,
                            closeOnMouseleave: !0,
                            adjustTracker: !0,
                            closeOnClick: false,
                            closeButton: "box",
                            animation: "move",
                            pointer: "right:20",
                            offset: { x: 0 },
                            onCreated: function () {
                                let svgImg = '<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">';
                                svgImg += '<circle cx="12" cy="12" r="12" fill="#CCDCE8"></circle>';
                                svgImg += '<path d="M8.21191 8.28772L15.6365 15.7123" stroke="#004F9B" stroke-width="2" stroke-linecap="round"/>';
                                svgImg += '<path d="M15.6367 8.28796L8.2121 15.7126" stroke="#004F9B" stroke-width="2" stroke-linecap="round"/>';
                                svgImg += '</svg>';
                                this.wrapper.find('.jBox-closeButton').html(svgImg);
                            },
                            onOpen: function () {
                                $(tooltip).removeClass("active")
                                this.source.addClass("active")
                            },
                            onClose: function () {
                                this.source.removeClass("active")
                            }
                        });
                    }).then(() => {
                        //setTimeout(() => {
                        this.isLoading = false;
                        // }, 2000);
                    });
                });
            });
        });
    }

    async loadExternalLibraries() {

        loadStyle(this, YG_CustomerPortal + '/YG_CSS/dataTables.css').then(() => {
            loadScript(this, YG_CustomerPortal + '/YG_JS/jquery.dataTables.min.js').then(() => {

                let dataTable;
                const table = this.template.querySelector('.certSearch-dtTable');

                const columnHeaders = ['Type', 'Product', 'No.', 'Supplement', 'Remarks'];
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
                    "order": [0, 'asc'],
                    "language": {
                        "emptyTable": "No results found. Please try another search."
                    },
                    // Per-row function to iterate cells
                    "createdRow": function (row, data, rowIndex) {
                        // Per-cell function to do whatever needed with cells
                        $.each($('td', row), function (colIndex) {
                            // For example, adding data-* attributes to the cell
                            $(this).attr('data-title', columnHeaders[colIndex]);

                        });
                    }
                });

                this.certSearchData.forEach(function (list) {

                    dataTable.row.add([
                        list.DirectiveName,
                        '<a class="text-hover-color" href="https://' + list.DownloadURL + '" target="_blank"><ins>' + list.ModelName + ' ' + list.Model + '</ins></a>',
                        (list.PassedCertNo) ? list.PassedCertNo : '-',
                        (list.AdditionalNotes) ? list.AdditionalNotes : '-',
                        (list.CertSearchMemo) ? list.CertSearchMemo : '-'
                    ]);
                })
                dataTable.draw();
            })
        })
    }

    loadmore() {

        const searchEle = this.template.querySelector(".section");
        $(".grid-loading", searchEle).removeClass("d-none");
        //alert('this.startRecord' + this.startRecord);
        //alert('this.loadedRecord' + this.loadedRecord);
        this.startRecord = this.loadedRecord + this.startRecord;
        //this.loadedRecord = this.recordLoadLimit + this.loadedRecord;
        //alert('this.startRecord::' + this.startRecord)
        let certData = [];
        //this.categoryVal
        getSearchCertificate({ searchKeyword: this.keyword, modelKeyword: this.modelTxt, categoryCode: this.categoryVal, modelCode: this.modelValue, msCode: this.msCode, certType: this.certificateType, certificateNo: this.certNumber, start: this.startRecord, loadLimit: this.recordLoadLimit })
            .then(result => {
                console.log('result ==> ' + JSON.stringify(result));
                certData = result.certificateAPIResponseList;
                //this.loadedRecord = result.documentAPIResponseList.length;
                //alert('this.loadedRecord::' + this.loadedRecord);
                //alert(result.totalCnt);
                this.remainRecords = this.totalCnt - (this.loadedRecord + (this.startRecord - 1));
                //alert('this.remainRecords::' + this.remainRecords);

                if (this.remainRecords > 0) {
                    this.showLoadMore = true;
                    if (this.remainRecords < this.recordLoadLimit) {
                        this.remainRecords = this.remainRecords;
                    } else {
                        this.remainRecords = this.recordLoadLimit;
                    }
                } else {
                    this.showLoadMore = false;
                }
                //alert('this.remainRecords::' + this.remainRecords);
                //alert('this.showLoadMore::' + this.showLoadMore);

                let dataTable;
                const table = this.template.querySelector('.certSearch-dtTable');
                $.fn.dataTableExt.sErrMode = 'none';
                dataTable = $(table).DataTable({
                    "paging": false,
                    "searching": false, // false to disable search (or any other option)
                    "info": false,
                    "order": []
                });

                certData.forEach(function (list) {

                    dataTable.row.add([
                        list.DirectiveName,
                        '<a class="text-hover-color" href="https://' + list.DownloadURL + '" target="_blank"><ins>' + list.ModelName + ' ' + list.Model + '</ins></a>',
                        (list.PassedCertNo) ? list.PassedCertNo : '-',
                        (list.AdditionalNotes) ? list.AdditionalNotes : '-',
                        (list.CertSearchMemo) ? list.CertSearchMemo : '-'
                    ]).draw(false);

                })
            }).then(() => {
                $(".grid-loading", searchEle).addClass("d-none");
            }).catch(error => {
                this.error = error;
                console.log('Error: ' + JSON.stringify(this.error));
            });
    }

    handleKeyPress(event) {

        let iKeyCode = (event.which) ? event.which : event.keyCode;
        if (iKeyCode == 13) {
            this.searchCertificate();
        }
    }

    handleModelChange(event) {

        let searchModel = event.target.value;
        const searchEle = this.template.querySelector(".dc-search");
        let targetField = event.currentTarget.name;

        if (searchModel.length > 0) {
            $(".selectpicker, input[name=msCode]", searchEle).prop('disabled', true).trigger("chosen:updated");
            $("input[name=" + targetField + "]", searchEle).next('.dc-search-icon').addClass('active');

        } else {
            $(".selectpicker, input[name=msCode]", searchEle).prop('disabled', false).trigger("chosen:updated");
            $("input[name=" + targetField + "]", searchEle).next('.dc-search-icon').removeClass('active');
        }
    }

    handleMScodeChange(event) {

        let searchMScode = event.target.value;
        const searchEle = this.template.querySelector(".dc-search");
        let targetField = event.currentTarget.name;


        if (searchMScode.length > 0) {
            $(".selectpicker, input[name=modelTxt]", searchEle).prop('disabled', true).trigger("chosen:updated");
            $("input[name=" + targetField + "]", searchEle).next('.dc-search-icon').addClass('active');
        } else {
            $(".selectpicker, input[name=modelTxt]", searchEle).prop('disabled', false).trigger("chosen:updated");
            $("input[name=" + targetField + "]", searchEle).next('.dc-search-icon').removeClass('active');
        }
    }

    handleChkChange(event) {

        let chkValue = event.currentTarget.dataset.id;
        const searchEle = this.template.querySelector(".dc-search");
        if (chkValue == "all") {
            //alert($(searchEle).find('.dc-type .form-check-input:first').is(':checked'))
            if ($(searchEle).find('.dc-type .form-check-input:first').is(':checked') === true) {
                $(searchEle).find('.dc-type .form-check-input').prop("checked", false).eq(0).prop("checked", true);
            }
        } else {
            $(searchEle).find('.dc-type .form-check-input').eq(0).prop("checked", false);
        }
    }

    triggerSelect(event) {

        const searchEle = this.template.querySelector(".dc-search");
        let lastLevel = $('input[name=hiddenLevel]', searchEle).val();
        let levelHtml = '', selName;

        getCategoryHierarchy({ parentCatCode: lastLevel })
            .then(result => {
                console.log('result::lastLevel::  ' + JSON.stringify(result));
                if (result.childInfo.length > 0 || result.models.length > 0) {
                    let selSize = $(".service-request > .form-group", searchEle).length + 1;
                    let placeHolder, title, options = [];
                    if (result.childInfo.length > 0) {
                        title = selSize + ". Filter by category";
                        placeHolder = "Select a category";
                        selName = "category-" + selSize;
                        result.childInfo.forEach(function (item) {
                            options.push(
                                $("<option/>", {
                                    value: item.categoryID,
                                    text: item.categoryName
                                })
                            );
                        });
                    }
                    if (result.models.length > 0) {
                        title = selSize + ". Filter by model";
                        placeHolder = "Select a model";
                        selName = "model";
                        result.models[0].modelcodes.forEach(function (item) {
                            options.push(
                                $("<option/>", {
                                    value: item,
                                    text: item
                                })
                            );
                        });
                    }

                    levelHtml += '<div class="form-group col-md-4">';
                    levelHtml += '<label for="' + selName + '" class="f14 grey-darkest">' + title + '</label>';
                    levelHtml += '<select class="form-control selectpicker' + selSize + '" name="' + selName + '" id="' + selName + '">';
                    levelHtml += '<option value="0">' + placeHolder + '</option>';
                    levelHtml += '</select></div>';

                    $('.service-request', searchEle).append(levelHtml);
                    const selBox = this.template.querySelector(".selectpicker" + selSize);
                    const triggerClick = this.template.querySelector(".triggerClick");
                    $(selBox).find("option").not(":first").remove();
                    $(selBox).append(options);

                    $(selBox)
                        .chosen({
                            disable_search: true
                        }).change(function (e) {
                            //alert('level 2')

                            $("#" + $(this).attr("id"), searchEle).parent(".form-group").nextAll('.form-group').remove();
                            $(selBox).val($(this).val()).trigger("chosen:updated");
                            $('input[name=hiddenLevel]', searchEle).val($(this).val());
                            if ($(this).val() != 0) {
                                triggerClick.click();
                            }
                        });
                }
            }).catch(error => {
                this.error = error;
                console.log('Error: ' + JSON.stringify(this.error));
            });
    }

    searchCertificate(event) {

        const searchEle = this.template.querySelector(".section");
        $(".grid-loading", searchEle).removeClass("d-none");
        $(".clear-link", searchEle).removeClass("invisible");
        $(".certSearch-dtTable, .load-more, .totResult-sec", searchEle).addClass("d-none");

        const scrollTarget = this.template.querySelector('.clear-link');
        $('html, body').animate({
            scrollTop: $(scrollTarget).offset().top + 100
        }, 1000);

        this.keyword = $("input[name=keyword]", searchEle).val();
        //alert('keyword ==> ' + this.keyword)

        this.modelTxt = ($("input[name=modelTxt]", searchEle).val()) ? $("input[name=modelTxt]", searchEle).val() + "*" : '';
        //alert('modelTxt ==> ' + this.modelTxt)

        this.msCode = $("input[name=msCode]", searchEle).val();
        //alert('msCode ==> ' + this.msCode)

        this.certNumber = $("input[name=certNumber]", searchEle).val();
        //alert('certNumber ==> ' + this.certNumber)

        let selectedVal = [];
        $(".service-request > .form-group > select[name^='category']", searchEle).each(function () {
            if ($(this).val() != 0) {
                selectedVal.push($(this).val())
            }
        });

        this.categoryVal = selectedVal.slice(-1);
        this.categoryVal = (this.categoryVal[0] != undefined) ? this.categoryVal[0] : '';
        //alert('this.categoryVal ==> ' + this.categoryVal)

        let modelVal = $(".service-request > .form-group > select[name='model']", searchEle).val();
        this.modelValue = (modelVal != undefined) ? modelVal : '';
        //alert('modelVal ==> ' + this.modelValue)

        let chkedVal = [];
        $('input[name="certificateType"]:checked', searchEle).each(function () {
            chkedVal.push($(this).val());
        });

        this.certificateType = chkedVal.join();
        //alert('certificateType ==> ' + this.certificateType)

        this.showLoadMore = false;
        this.startRecord = 1;

        getSearchCertificate({ searchKeyword: this.keyword, modelKeyword: this.modelTxt, categoryCode: this.categoryVal, modelCode: this.modelValue, msCode: this.msCode, certType: this.certificateType, certificateNo: this.certNumber, start: this.startRecord, loadLimit: this.recordLoadLimit })
            .then(result => {
                console.log('result ==> ' + JSON.stringify(result));

                if (result.success === true) {
                    //this.template.querySelector(".totResult-sec").classList.remove('d-none');
                    console.log('result.totalCnt ==> ' + result.certificateAPIResponseList[0].Count);
                    this.totalCnt = result.certificateAPIResponseList[0].Count;
                    this.certSearchData = result.certificateAPIResponseList;
                    this.loadedRecord = result.certificateAPIResponseList.length;
                    this.remainRecords = result.certificateAPIResponseList[0].Count - this.loadedRecord;

                    console.log('this.totalCnt ==> ' + this.totalCnt);
                    console.log('this.loadedRecord ==> ' + this.loadedRecord);
                    console.log('remainRecords ==> ' + this.remainRecords);
                } else {
                    this.certSearchData = [];
                    this.totalCnt = 0;
                    this.loadedRecord = 0;
                    this.remainRecords = 0;
                }

            }).then(() => {
                if (this.loadExternal === true) {
                    const table = this.template.querySelector('.certSearch-dtTable');
                    $(table).DataTable().destroy();
                }
            }).then(() => {
                this.loadExternalLibraries();
            }).then(() => {
                $(".grid-loading", searchEle).addClass("d-none");
                $(".certSearch-dtTable, .load-more, .totResult-sec", searchEle).removeClass("d-none");
                if (this.totalCnt == 0) {
                    $(".totResult-sec", searchEle).addClass("d-none");
                }
            }).then(() => {
                setTimeout(() => {
                    if (this.remainRecords > 0) {
                        this.showLoadMore = true;
                        if (this.remainRecords < this.recordLoadLimit) {
                            this.remainRecords = this.remainRecords;
                        } else {
                            this.remainRecords = this.recordLoadLimit;
                        }
                    } else {
                        this.showLoadMore = false;
                    }
                }, 500);

            }).then(() => {
                this.loadExternal = true;
            }).catch(error => {
                this.error = error;
                console.log('Error: ' + JSON.stringify(this.error));
            });
    }

    clearSearch(event) {

        this.keyword = "";
        this.modelTxt = "";
        this.msCode = "";
        this.certNumber = "";
        this.categoryVal = "";
        this.modelValue = "";
        this.certificateType = "";
        this.showLoadMore = false;

        const searchEle = this.template.querySelector(".section");
        $(".clear-link", searchEle).addClass("invisible");
        $(".certSearch-dtTable, .load-more, .totResult-sec", searchEle).addClass("d-none");

        $("input[name=keyword], input[name=certNumber]", searchEle).val('').next('.dc-search-icon').removeClass('active');
        $("input[name=modelTxt], input[name=msCode]", searchEle).val('').attr('disabled', false).next('.dc-search-icon').removeClass('active');
        $(".service-request > .form-group", searchEle).not(":first").remove();
        const selBox = this.template.querySelector(".selectpicker");
        $(selBox).val(0).prop('disabled', false).trigger("chosen:updated");
        $('input[name="certificateType"]', searchEle).prop('checked', false).eq(0).prop("checked", true);
    }

    handleKeyup(event) {

        let targetField = event.currentTarget.name;
        const formSection = this.template.querySelector(".dc-search");

        if (event.currentTarget.value) {
            $("input[name=" + targetField + "]", formSection).next('.dc-search-icon').addClass('active');

        } else {
            $("input[name=" + targetField + "]", formSection).next('.dc-search-icon').removeClass('active');

        }
    }
}