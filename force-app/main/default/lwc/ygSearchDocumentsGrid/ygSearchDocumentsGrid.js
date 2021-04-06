import { LightningElement, track, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import YG_CustomerPortal from "@salesforce/resourceUrl/YG_CustomerPortal";
import { loadStyle, loadScript } from "lightning/platformResourceLoader";
import getCategoryLevel1 from "@salesforce/apex/YG_DocumentSearchController.getCategoryLevel1";
import getCategoryHierarchy from "@salesforce/apex/YG_DocumentSearchController.getCategoryHierarchy";
import getSearchDocument from "@salesforce/apex/YG_DocumentSearchAPIHandler.searchDocument";
import getCustomConfig from '@salesforce/apex/YG_Utility.getCustomConfig';
import showLbl from '@salesforce/label/c.YG_Show';
import moreLbl from '@salesforce/label/c.YG_MoreProducts';

export default class YgSearchDocumentsGrid extends LightningElement {

    @wire(CurrentPageReference) pageRef;
    searchIcon = YG_CustomerPortal + '/YG_Images/icons/search-32x32.svg';
    categoryLevel1 = [];
    @track docSearchData = [];
    @track chkLength = false;
    @track loadExternal = false;
    @track isLoading = true;
    @track mapData = [];
    @track showLoadMore = false;
    @track downloadID;
    @track downloadURL = '';
    @track totalCnt = 0;
    startRecord = 0;
    loadedRecord = 0;
    remainRecords = 0;
    recordLoadLimit = 0;
    error;
    label = {
        showLbl, moreLbl
    };
    keyword = ''; modelTxt = ''; categoryVal = ''; modelValue = ''; documentType = ''; idp = '';

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

    renderedCallback() { // invoke the method when component rendered or loaded

        Promise.all([
            loadScript(this, YG_CustomerPortal + '/YG_JS/zip/zip.js'),
            loadScript(this, YG_CustomerPortal + '/YG_JS/zip/inflate.js'),
            loadScript(this, YG_CustomerPortal + '/YG_JS/zip/deflate.js'),
        ]).then(() => {
            this.error = undefined; // scripts loaded successfully
        }).catch(error => this.handleError(error))
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
                                    $('input[name=modelTxt]', searchEle).prop('disabled', true)
                                } else {
                                    $('input[name=modelTxt]', searchEle).prop('disabled', false)
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
                loadScript(this, YG_CustomerPortal + '/YG_JS/file-size.js').then(() => {

                    let dataTable, gridChkbox, totalSize;
                    const table = this.template.querySelector('.docSearch-dtTable');
                    let selAllChkbox = '<div class="form-check form-check-inline custom-chkbox mr-0">';
                    selAllChkbox += '<input class="form-check-input" type="checkbox" name="selectAll" id="selectAll">';
                    selAllChkbox += '<label class="form-check-label d-inline-block" for="selectAll"></label></div>';

                    const columnHeaders = [selAllChkbox, 'Document Name', 'Product', 'Type', 'Published on', 'Size'];
                    //const columnHeaders = ['Document Name', 'Product', 'Type', 'Published on', 'Size'];
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
                        "order": [1, 'asc'],
                        "columnDefs": [{
                            orderable: false,
                            targets: 0
                        },
                        { type: 'file-size', targets: 5 }
                        ],
                        "language": {
                            "emptyTable": "No results found. Please try another search."
                        },
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

                    this.docSearchData.forEach(function (list, index) {

                        gridChkbox = '';
                        gridChkbox += '<div class="form-check form-check-inline custom-chkbox mr-0">';
                        gridChkbox += '<input data-rawsize="' + list.Rawfilesize + '" data-filerev="' + list.FileRevNo + '" data-lang="' + list.LanguageID + '" class="form-check-input" type="checkbox" name="downloadID" id="downloadID-' + index + '" value="' + list.EntryNo + '">';
                        gridChkbox += '<label class="form-check-label d-inline-block" for="downloadID-' + index + '"></label></div>';
                        dataTable.row.add([
                            gridChkbox,
                            '<a class="text-hover-color" href="https://' + list.DownloadURL + '" target="_blank"><ins>' + list.docName + '</ins></a><span class="d-block pt-3">' + list.docNo + ' ' + 'Revison ' + list.DocRevNo + '</span>',
                            list.Model,
                            list.DocType,
                            '<span class="d-none">' + list.Rawdate + '</span>' + list.AreaOpenDate,
                            list.FileSize,
                        ]);
                    })
                    dataTable.draw();

                    const sectionEle = this.template.querySelector('.section');
                    const gridTable = this.template.querySelector('.table-responsive');
                    const triggerPopup = this.template.querySelector(".triggerPopup");

                    $('thead', gridTable).on('change', 'th input[name="selectAll"]', function () {
                        if ($(this).is(':checked')) {
                            $('input[name="downloadID"]', gridTable).prop('checked', true);
                        } else {
                            $('input[name="downloadID"]', gridTable).prop('checked', false);
                        }

                        if ($('input[name="downloadID"]:checked', gridTable).length > 0) {
                            totalSize = 0;
                            $('.download-btn button', sectionEle).removeClass('disabled');
                        } else {
                            $('.download-btn button', sectionEle).addClass('disabled');
                        }
                    });

                    $('tbody', gridTable).on('change', 'td input[name="downloadID"]', function () {
                        if ($('input[name="downloadID"]:checked', gridTable).length > 0) {
                            totalSize = 0;
                            $('.download-btn button', sectionEle).removeClass('disabled');
                        } else {
                            $('.download-btn button', sectionEle).addClass('disabled');
                        }
                    });
                })
            })
        })
    }

    handleModelChange(event) {

        let searchModel = event.target.value;
        let targetField = event.currentTarget.name;
        const selectpicker = this.template.querySelector(".selectpicker");
        const formSection = this.template.querySelector(".dc-search");

        if (searchModel.length > 0) {
            $(selectpicker).prop('disabled', true).trigger("chosen:updated");
            $("input[name=" + targetField + "]", formSection).next('.dc-search-icon').addClass('active');
        } else {
            $(selectpicker).prop('disabled', false).trigger("chosen:updated");
            $("input[name=" + targetField + "]", formSection).next('.dc-search-icon').removeClass('active');

        }
    }

    handleChkChange(event) {

        let chkValue = event.target.value;
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

    searchDocument(event) {

        const searchEle = this.template.querySelector(".section");
        $(".grid-loading", searchEle).removeClass("d-none");
        $(".clear-link", searchEle).removeClass("invisible");
        $(".docSearch-dtTable, .load-more, .download-btn", searchEle).addClass("d-none");

        const scrollTarget = this.template.querySelector('.clear-link');
        $('html, body').animate({
            scrollTop: $(scrollTarget).offset().top + 100
        }, 1000);

        this.keyword = $("input[name=keyword]", searchEle).val();
        //alert('keyword ==> ' + keyword)

        //let model = $("input[name=modelTxt]", searchEle).val() + "*";
        this.modelTxt = ($("input[name=modelTxt]", searchEle).val()) ? $("input[name=modelTxt]", searchEle).val() + "*" : '';
        //alert('model ==> ' + model)

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
        $('input[name="documentType"]:checked', searchEle).each(function () {
            chkedVal.push($(this).val());
        });

        this.documentType = chkedVal.join();
        //alert('documentType ==> ' + documentType)

        //this.idp = $('input[name="idp"]').is(":checked") ? 1 : 0;

        if ($("input[name='idp']", searchEle).prop('checked') == true) {
            this.idp = 1;
        } else {
            this.idp = 0;
        }
        //alert('idp ==> ' + this.idp)

        this.showLoadMore = false;
        this.startRecord = 1;
        getSearchDocument({ searchKeyword: this.keyword, modelKeyword: this.modelTxt, categoryCode: this.categoryVal, modelCode: this.modelValue, docType: this.documentType, getIncludeProduct: this.idp, start: this.startRecord, loadLimit: this.recordLoadLimit })
            .then(result => {
                console.log('result ==> ' + JSON.stringify(result));

                if (result.success === true) {

                    console.log('result.totalCnt ==> ' + JSON.stringify(result.totalCnt));
                    //this.totalCnt = result.documentAPIResponseList[0].Count;
                    this.totalCnt = result.totalCnt;
                    this.docSearchData = result.documentAPIResponseList;
                    this.loadedRecord = result.documentAPIResponseList.length;
                    this.remainRecords = result.totalCnt - this.loadedRecord;
                } else {
                    this.docSearchData = [];
                    this.totalCnt = 0;
                    this.loadedRecord = 0;
                    this.remainRecords = 0;
                }
            }).then(() => {
                if (this.loadExternal === true) {
                    const table = this.template.querySelector('.docSearch-dtTable');
                    $(table).DataTable().destroy();
                }
            }).then(() => {
                this.loadExternalLibraries();
            }).then(() => {
                $(".grid-loading", searchEle).addClass("d-none");
                $(".download-btn button", searchEle).addClass("disabled");
                $(".docSearch-dtTable, .load-more, .download-btn, .totResult-sec", searchEle).removeClass("d-none");
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

        this.showLoadMore = false;

        const searchEle = this.template.querySelector(".section");
        $(".clear-link", searchEle).addClass("invisible");
        $(".docSearch-dtTable, .load-more, .download-btn, .totResult-sec", searchEle).addClass("d-none");

        $("input[name=keyword]", searchEle).val('').next('.dc-search-icon').removeClass('active');
        $("input[name=modelTxt]", searchEle).val('').attr('disabled', false).next('.dc-search-icon').removeClass('active');
        $(".service-request > .form-group", searchEle).not(":first").remove();
        const selBox = this.template.querySelector(".selectpicker");
        $(selBox).val(0).prop('disabled', false).trigger("chosen:updated");
        $('input[name="documentType"]', searchEle).prop('checked', false).eq(0).prop("checked", true);
        $('input[name="idp"]', searchEle).prop('checked', false);
    }

    downloadDoc(event) {

        const gridTable = this.template.querySelector('.table-responsive');
        const downloadBtn = this.template.querySelector('.download-btn');
        $('.btn.bg-white.btn-primary', downloadBtn).addClass('disabled').prepend('<div class="spinner-border spinner-border-sm blue-primary mr-2" role="status"><span class="sr-only">Loading...</span></div>');

        let chkedArr = [], makeObj = {};

        $('input[name="downloadID"]:checked', gridTable).each(function () {
            chkedArr.push({
                EntryNo: $(this).val(),
                FileRevNo: $(this).data('filerev'),
                LanguageID: $(this).data('lang')
            });
        });
        //alert("chkedArr ---- " + chkedArr);
        //alert("chkedArr" + JSON.stringify(chkedArr));
        makeObj = { SystemID: "F5cJnZkn", RequestData: chkedArr };
        let requestData = JSON.stringify(makeObj);

        var requestOptions = {
            method: 'POST',
            headers: {
                "Content-Type": "application/json",
                "Content-Length": requestData.length,
                "Accept-Encoding": "gzip, deflate, br"
            },
            body: requestData,
            redirect: 'follow'
        };

        fetch("https://library.yokogawa.com/document/zipdownload", requestOptions)
            .then(response => response.blob())
            .then(function (result) {
                const a = document.createElement("a")
                a.href = URL.createObjectURL(result);
                //a.download = `ZipDownload-${new Date().getTime()}.zip`
                a.download = `ZipDownload.zip`;
                a.click();
            }).then(() => {
                setTimeout(() => {
                    const downloadBtn = this.template.querySelector('.download-btn');
                    $('button', downloadBtn).removeClass('disabled');
                    $('.spinner-border', downloadBtn).remove();
                }, 1000);

            }).catch(error => console.log('error', error));

        /*
        getDocumentDownloadAPI({ selectedDocs: JSON.stringify(chkedArr) })
            .then(result => {

                //alert("result ==> " + JSON.stringify(result));
                this.downloadID = result.ContVerId;
                this.downloadURL = result.downloadURLPath;

            }).then(() => {
                const downClick = this.template.querySelector(".downloadClick");
                downClick.click();

            }).catch(error => {
                this.error = error;
                console.log('Error: ' + JSON.stringify(this.error));
            });*/
    }

    loadmore() {

        const searchEle = this.template.querySelector(".section");
        $(".grid-loading", searchEle).removeClass("d-none");
        //alert('this.startRecord' + this.startRecord);
        //alert('this.loadedRecord' + this.loadedRecord);
        this.startRecord = this.loadedRecord + this.startRecord;
        //this.loadedRecord = this.recordLoadLimit + this.loadedRecord;
        //alert('this.startRecord::' + this.startRecord)
        let docData = [];
        //this.categoryVal
        //getSearchDocument({ searchKeyword: 'EJXC40A', modelKeyword: '', categoryCode: '', docType: 'Bull,GS,IM,TI,SD', getIncludeProduct: 0, start: this.startRecord, loadLimit: this.recordLoadLimit })
        getSearchDocument({ searchKeyword: this.keyword, modelKeyword: this.modelTxt, categoryCode: this.categoryVal, modelCode: this.modelValue, docType: this.documentType, getIncludeProduct: this.idp, start: this.startRecord, loadLimit: this.recordLoadLimit })
            .then(result => {
                console.log('result ==> ' + JSON.stringify(result));
                docData = result.documentAPIResponseList;
                //this.loadedRecord = result.documentAPIResponseList.length;
                //alert('this.loadedRecord::' + this.loadedRecord);
                //alert(result.totalCnt);
                this.remainRecords = result.totalCnt - (this.loadedRecord + (this.startRecord - 1));
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

                let dataTable, gridChkbox, sRecord = this.startRecord - 1;
                const table = this.template.querySelector('.docSearch-dtTable');
                $.fn.dataTableExt.sErrMode = 'none';
                dataTable = $(table).DataTable({
                    "paging": false,
                    "searching": false, // false to disable search (or any other option)
                    "info": false,
                    "order": [],
                    "columnDefs": [{
                        orderable: false,
                        targets: 0
                    }]
                });

                docData.forEach(function (list) {

                    gridChkbox = '';
                    gridChkbox += '<div class="form-check form-check-inline custom-chkbox mr-0">';
                    gridChkbox += '<input data-rawsize="' + list.Rawfilesize + '" data-filerev="' + list.FileRevNo + '" data-lang="' + list.LanguageID + '" class="form-check-input" type="checkbox" name="downloadID" id="downloadID-' + sRecord + '" value="' + list.EntryNo + '">';
                    gridChkbox += '<label class="form-check-label d-inline-block" for="downloadID-' + sRecord + '"></label></div>';
                    dataTable.row.add([
                        gridChkbox,
                        '<a class="text-hover-color" href="https://' + list.DownloadURL + '" target="_blank"><ins>' + list.docName + '</ins></a><span class="d-block pt-3">' + list.docNo + ' ' + 'Revison ' + list.DocRevNo + '</span>',
                        list.Model,
                        list.DocType,
                        '<span class="d-none">' + list.Rawdate + '</span>' + list.AreaOpenDate,
                        list.FileSize,
                    ]).draw(false);

                    sRecord++;
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
            this.searchDocument();
        }
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