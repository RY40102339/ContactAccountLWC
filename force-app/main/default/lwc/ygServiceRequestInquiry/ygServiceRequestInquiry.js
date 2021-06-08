import { LightningElement, wire, track } from "lwc";
import YG_CustomerPortal from "@salesforce/resourceUrl/YG_CustomerPortal";
import { loadStyle, loadScript } from "lightning/platformResourceLoader";
import { CurrentPageReference } from "lightning/navigation";
import { fireEvent } from "c/pubSub";
import createInquiries from "@salesforce/apex/YG_ServiceRequestAndInquiries.createInquiries";
import createServiceReq from "@salesforce/apex/YG_ServiceRequestAndInquiries.createServiceReq";
import getLookUpData from "@salesforce/apex/YG_ServiceRequestAndInquiries.getLookUpData";
import getTopCategoryName from "@salesforce/apex/YG_ServiceRequestAndInquiries.getTopCategoryName";
import getServiceType from "@salesforce/apex/YG_ServiceRequestAndInquiries.getServiceType";
import getOfficeDetails from "@salesforce/apex/YG_ServiceRequestAndInquiries.getOfficeDetails";
import getProductData from "@salesforce/apex/YG_ServiceRequestAndInquiries.getProductData";
import getContract from "@salesforce/apex/YG_AllServiceContractsController.getContract";
import getCommunityURL from "@salesforce/apex/YG_Utility.getCommunityURL";
import reqMainServLbl from "@salesforce/label/c.YG_Request_For_Maintenance_Service";
import subInqLbl from "@salesforce/label/c.YG_Submit_An_Inquiry";
import salesQtoLbl from "@salesforce/label/c.YG_Sales_and_Quote";
import techSupLbl from "@salesforce/label/c.YG_Technical_Support";
import otherLbl from "@salesforce/label/c.YG_Others";
import optionalLbl from "@salesforce/label/c.YG_Optional";
import tellInqLbl from "@salesforce/label/c.YG_Tell_us_about_your_inquiry";
import descLbl from "@salesforce/label/c.YG_Short_Description";
import attachLbl from "@salesforce/label/c.YG_Attach_related_file";
import selectInqLbl from "@salesforce/label/c.YG_Please_select_inquiry_type";
import enterDescLbl from "@salesforce/label/c.YG_Please_enter_description";
import servReqLbl from "@salesforce/label/c.YG_Service_you_require";
import sltMtnServLbl from "@salesforce/label/c.YG_Select_a_maintenance_service";
import sevProdLbl from "@salesforce/label/c.YG_Product_to_service";
import etrProdNameLbl from "@salesforce/label/c.YG_Enter_product_name_model_or_serial_number";
import prodCondLbl from "@salesforce/label/c.YG_Condition_of_the_product_or_any_other_notes";
import fileUploadLbl from "@salesforce/label/c.YG_Cancel_file_upload_and_submit_request";
import sltServCatLbl from "@salesforce/label/c.YG_Please_Select_Service_Category";
import etrRltProdLbl from "@salesforce/label/c.YG_Please_Enter_Related_Products";
import contLbl from "@salesforce/label/c.YG_Contact";
import addressLbl from "@salesforce/label/c.YG_Address";
import noDataLbl from "@salesforce/label/c.YG_No_results_found";
import loadingLbl from "@salesforce/label/c.YG_Loading";
import ygContactLbl from "@salesforce/label/c.YG_Yokogawa_Contact";
import otrLbl from "@salesforce/label/c.YG_Other";
import shortDescLbl from "@salesforce/label/c.YG_Short_Description";
import submitServReqLbl from "@salesforce/label/c.YG_Submit_request_for_Service";
import inqTypeLbl from "@salesforce/label/c.YG_Inquiry_Type";
import inqAboutLbl from "@salesforce/label/c.YG_What_are_you_inquiring_about";
import inqPlaceHolderLbl from "@salesforce/label/c.YG_Inquiry_Placeholder";
import submitInqLbl from "@salesforce/label/c.YG_SUBMIT_INQUIRY";
import fileplaceholderLbl from "@salesforce/label/c.YG_File_Upload";
import otherInqLbl from "@salesforce/label/c.YG_Inquiry_for_Others";
import inqforLbl from "@salesforce/label/c.YG_Inquiry_for";
import renewalforLbl from "@salesforce/label/c.YG_Renewal_for";
import CaseDocumentAPI from "@salesforce/apex/YG_CaseDocumentAPI.CaseDocumentAPI";

export default class YgRequestForm extends LightningElement {

  @wire(CurrentPageReference) pageRef;

  calendarIcon = YG_CustomerPortal + "/YG_Images/icons/calendar.svg";
  label = {
    reqMainServLbl, subInqLbl, salesQtoLbl, techSupLbl, otherLbl, optionalLbl, tellInqLbl, descLbl,
    attachLbl, selectInqLbl, enterDescLbl, servReqLbl, sltMtnServLbl, sevProdLbl, etrProdNameLbl,
    prodCondLbl, fileUploadLbl, sltServCatLbl, etrRltProdLbl, contLbl, addressLbl, noDataLbl, loadingLbl,
    ygContactLbl, otrLbl, shortDescLbl, submitServReqLbl, inqTypeLbl, inqAboutLbl, inqPlaceHolderLbl, submitInqLbl,
    fileplaceholderLbl, otherInqLbl, inqforLbl, renewalforLbl
  };

  salesOfficeDet = [];
  serviceCenterDet = [];
  inquiryData = {};
  serviceData = {};
  reason = false;
  subject = false;
  description = false;
  serviceReq = false;
  productService = false;
  selectedServType;
  error;
  recordId = "";
  communityURL = "";
  searchKey = "";
  recordsExist = true;
  records;
  @track selectedRecordList = [];
  @track excludeRecordList = [];
  @track selectedRecord = "";
  thankyouURL;
  outsideClick = false;
  categoryCode = "";
  @track onkeydown = -1;
  contractNum = "";
  @track contract = false;
  contractName;
  @track softwareLicenses = false;
  productModel = '';
  @track productDetails = false;
  msCode = '';
  @track isLoading = true;

  constructor() {
    super();

    getCommunityURL({})
      .then((result) => {
        this.communityURL = result;
      })
      .then(() => {
        this.loadChoosenLibraries();
      })
      .then(() => {
        getOfficeDetails({})
          .then((result) => {
            var conts = result;
            for (var key in conts) {
              if (key == "Sales Office") {
                this.salesOfficeDet.push({ value: conts[key], key: key });
              }
              if (key == "Service Center") {
                this.serviceCenterDet.push({ value: conts[key], key: key });
              }
            }
          })
          .catch((error) => {
            this.error = error;
            console.log("commUrl: " + JSON.stringify(this.error));
          });
      }).then(() => {
        let fullStr = window.location.search.substring(1);
        let splitStr = fullStr.split("&");
        let contractNo = '';
        for (var i = 0; i < splitStr.length; i++) {
          var pair = splitStr[i].split("=");

          if (pair[0] == 'contractno') {
            this.contract = true;
            contractNo = pair[1];
            this.contractNum = pair[1];
            getContract({ contractNo: this.contractNum })
              .then((result) => {
                this.contractName = result;
              })
              .catch((error) => {
                this.error = error;
                console.log("commUrl: " + JSON.stringify(this.error));
              });
            this.selectedRecordList.push({
              Id: "0",
              Name: "Others"
            });
          }

          if (pair[0] == 'prodId') {
            this.softwareLicenses = true;
            getProductData({ value: pair[1] })
              .then((result) => {
                this.selectedRecordList.push({
                  Id: result.Product2.Id,
                  Name: result.Product2.Name
                });
              })
              .catch((error) => {
                this.error = error;
                console.log("prodId Err: " + JSON.stringify(this.error));
              });
          }

          if (pair[0] == 'mscode') {
            this.productDetails = true;
            this.msCode = decodeURIComponent(pair[1]).replace(/\+/g, " ");
            getProductData({ value: this.msCode })
              .then((result) => {
                this.selectedRecordList.push({
                  Id: result.Product2.Id,
                  Name: result.Product2.Name
                });
              })
              .catch((error) => {
                this.error = error;
                console.log("prodId Err: " + JSON.stringify(this.error));
              });
          }

        }
      }).then(() => {
        this.renderedCallback();
      })
      .then(() => {
        setTimeout(() => {
          this.isLoading = false;
        }, 1000);
      })
      .catch((error) => {
        this.error = error;
        console.log("commURL::" + JSON.stringify(error));
      });

  }

  renderedCallback() {
    if (this.contract === true && this.contractName != undefined) {
      const srElement = this.template.querySelector(".service-request");
      $('.btn-radio', srElement).eq(0).addClass('disable');
      $('.btn-radio input[name=request-type]', srElement).eq(1).trigger('click');
      $('.newradio--inline input[name=inquiry_about]', srElement).eq(2).prop('checked', true);
      $('textarea[name=tellUS]', srElement).val(this.label.renewalforLbl + ' ' + this.contractName);
      $("input[name=inquiryService]", srElement).hide();
    }

    if (this.softwareLicenses === true) {
      const srElement = this.template.querySelector(".service-request");
      $('.btn-radio', srElement).eq(0).addClass('disable');
      $('.btn-radio input[name=request-type]', srElement).eq(1).trigger('click');
      $('.newradio--inline input[name=inquiry_about]', srElement).eq(0).prop('checked', true);
      $("input[name=inquiryService]", srElement).hide();
    }

    if (this.productDetails === true) {
      const srElement = this.template.querySelector(".service-request");
      $('.btn-radio', srElement).eq(0).addClass('disable');
      $('.btn-radio input[name=request-type]', srElement).eq(1).trigger('click');
      $('.newradio--inline input[name=inquiry_about]', srElement).eq(0).prop('checked', true);
      $("input[name=inquiryService]", srElement).hide();
    }

    if (this.outsideClick == true) {
      let searchRes = this.template.querySelector(".searchRes");
      let inquiryRes = this.template.querySelector(".inquiryRes");
      $("body").click(function () {
        $(searchRes).addClass("slds-hide");
        $(inquiryRes).addClass("slds-hide");
      });
    }
  }

  async loadChoosenLibraries() {
    loadScript(this, YG_CustomerPortal + "/YG_JS/jquery.min.js").then(() => {
      loadStyle(this, YG_CustomerPortal + "/YG_CSS/chosen.css").then(() => {
        loadScript(this, YG_CustomerPortal + "/YG_JS/chosen.jquery.js").then(
          () => {
            const selectpicker = this.template.querySelector(".selectpicker");
            const srElement = this.template.querySelector(".service-request");

            $(selectpicker)
              .chosen({
                disable_search: true
              })
              .change(function (e) {
                $(selectpicker).val($(this).val()).trigger("chosen:updated");
                $(".serviceRequire-err", srElement).html("");
                $(".chosen-container-single .chosen-single", srElement).removeClass('alert-border');
              });
          }).then(() => {
            this.outsideClick = true;
          });

      });
    });
  }

  showRequest(event) {
    //this.radioInit = true;

    const srElement = this.template.querySelector(".service-request");
    let radioValue = event.currentTarget.value;

    let removeValidation = ".chosen-container-single .chosen-single, .service-search, textarea[name=tellUS]";
    $(removeValidation, srElement).removeClass('alert-border');

    $(".btn-radio input[name=request-type]", srElement).closest("label").removeClass("active");
    $(".btn-radio input[name=request-type]:checked", srElement).closest("label").addClass("active");
    if (this.contract === false && this.softwareLicenses === false && this.productDetails === false) {
      this.clearAll();
    }

    if (radioValue == "Request For Service") {
      this.serviceData["Type"] = radioValue;
      $(".maintenance-form", srElement).show();
      $(".inquiry-form", srElement).hide();
      $(".serviceRequire-err, .prodService-err", srElement).html("");
      $("select[name=serviceRequire], input[name=productService], textarea[name=notes]", srElement).val("");
      $(".selectpicker", srElement).prop('disabled', true).val("").trigger("chosen:updated");
    } else {
      this.inquiryData["Type"] = radioValue;
      $(".maintenance-form", srElement).hide();
      $(".inquiry-form", srElement).show();
      $(".inquiry_about-err, .fileUpload-msg, .inquiryService-err, .tellUS-err", srElement).html("");
      $("textarea[name=tellUS], input[name=inquiryService]", srElement).val("");
      $("input[name=inquiry_about]", srElement).prop("checked", false);
    }

  }

  submitAnInquiry(event) {
    let buttonID = event.currentTarget.dataset.id;
    const srElement = this.template.querySelector(".service-request");
    const formElement = this.template.querySelector(".all-form");

    if ($("input[name=inquiry_about]:checked", srElement).val() == undefined) {
      this.reason = false;
      $(".inquiry_about-err", srElement).html(this.label.selectInqLbl);
    } else {
      this.reason = true;
      this.inquiryData["Reason"] = $("input[name=inquiry_about]:checked", srElement).val();
    }

    if ($("textarea[name=tellUS]", srElement).val() == "") {
      this.description = false;
      $(".tellUS-err", srElement).html(this.label.enterDescLbl);
      $("textarea[name=tellUS]", srElement).addClass('alert-border');
    } else {
      this.description = true;
      this.inquiryData["Description"] = $("textarea[name=tellUS]", srElement).val();
      $("textarea[name=tellUS]", srElement).removeClass('alert-border');
    }

    if (this.selectedRecordList.length == 0) {
      $(".inquiryService-err", srElement).html(this.label.etrRltProdLbl);
      $(".service-search", srElement).addClass('alert-border');
    } else {
      $(".inquiryService-err", srElement).html("");
      if (this.selectedRecordList[0].Id == 0) {
        this.inquiryData["ProductId"] = null;
        this.inquiryData["Subject"] = this.label.otherInqLbl;
      } else {
        this.inquiryData["ProductId"] = this.selectedRecordList[0].Id;
        this.inquiryData["Subject"] = this.label.inqforLbl + ' ' + this.selectedRecordList[0].Name;
      }
      $(".service-search", srElement).removeClass('alert-border');
    }

    if (this.contract === true) {
      this.inquiryData["Subject"] = this.label.renewalforLbl + ' ' + this.contractName;
    }

    let productName = this.selectedRecordList[0].Name;

    let inqRec = this.inquiryData;

    if (this.reason && this.description && this.selectedRecordList.length > 0) {
      createInquiries({ inquiryData: JSON.stringify(this.inquiryData) })
        .then((result) => {
          this.recordId = result;

          if (buttonID == "skip" && this.recordId != "ERROR") {
            window.location.href = this.communityURL + "thank-you" + "?caseid=" + this.recordId;;
          }

          if (buttonID == "attachment" && this.recordId != "ERROR") {
            this.thankyouURL = this.communityURL + "thank-you" + "?caseid=" + this.recordId;
            fireEvent(this.pageRef, "serviceRequestUploadTxt", productName);
            $(".upload-file", formElement).show();
            $(srElement).hide();
          }
        })
        .catch((error) => {
          this.error = error;
          console.log("createInqErr: " + JSON.stringify(this.error));
        });
    }
  }

  submitMaintenance(event) {

    const srElement = this.template.querySelector(".service-request");
    $('.btn-radio input[name=request-type]', srElement).eq(0).prop('checked', true);
    let buttonID = event.currentTarget.dataset.id;
    const formElement = this.template.querySelector(".all-form");

    this.serviceData["Type"] = $("input[name=request-type]:checked", srElement).val();
    this.serviceData["Description"] = $("textarea[name=notes]", srElement).val();
    this.selectedServType = $("select[name=serviceRequire] option:selected", srElement).text();

    if ($("select[name=serviceRequire]", srElement).val() === "" ||
      $("select[name=serviceRequire]", srElement).val() === null) {
      this.serviceRequire = false;
      $(".serviceRequire-err", srElement).html(this.label.sltServCatLbl);
      $(".chosen-container-single .chosen-single", srElement).addClass('alert-border');
    } else {
      this.serviceRequire = true;
      this.serviceData["serviceType"] = $("select[name=serviceRequire]", srElement).val();
      $(".chosen-container-single .chosen-single", srElement).removeClass('alert-border');
    }

    if (this.selectedRecordList.length == 0) {
      this.productService = false;
      $(".prodService-err", srElement).html(this.label.etrRltProdLbl);
      $(".service-search", srElement).addClass('alert-border');
    } else {
      this.productService = true;
      $(".prodService-err", srElement).html("");
      this.serviceData["prodSelected"] = this.selectedRecordList;
      $(".service-search", srElement).removeClass('alert-border');
    }


    if (this.serviceRequire && this.productService) {

      console.log('serviceData::' + JSON.stringify(this.serviceData));
      let productNames;
      productNames = this.serviceData.prodSelected[0].Name;

      createServiceReq({ serviceReqData: JSON.stringify(this.serviceData) })
        .then((result) => {
          console.log('result::' + JSON.stringify(this.result));
          this.recordId = result;

          if (buttonID == "skip" && this.recordId != "ERROR") {
            window.location.href = this.communityURL + "thank-you" + "?caseid=" + this.recordId;
            getcaseAttachment({ attach: 'No' }).then(result => {
              console.log('No attachment');
            }).catch(error => {
              this.error = error;
              console.log('error:: 1' + JSON.stringify(this.error));
            })
          }

          if (buttonID == "attachment" && this.recordId != "ERROR") {
            this.thankyouURL = this.communityURL + "thank-you" + "?caseid=" + this.recordId;
            fireEvent(this.pageRef, "serviceRequestUploadTxt", productNames);
            $(".maintenance-upload-file", formElement).show();
            $(srElement).hide();
          }
        })
        .catch((error) => {
          this.error = error;
          console.log("serviceErr: " + JSON.stringify(this.error));
        });
    }
  }

  hideError(event) {
    let targetField = event.currentTarget.name;
    const srElement = this.template.querySelector(".service-request");

    if (targetField == "inquiry_about") {
      $(".inquiry_about-err", srElement).html("");
    }

    if (targetField == "tellUS") {
      $("textarea[name=tellUS]", srElement).removeClass('alert-border')
      $(".tellUS-err", srElement).html("");
    }

  }

  handleUploadFinished(event) {
    const uploadedFiles = event.detail.files;
    const srElement = this.template.querySelector(".service-request");
    if (uploadedFiles.length > 0) {
      window.location.href = this.communityURL + "thank-you" + "?caseid=" + this.recordId;
    }  
    CaseDocumentAPI({ caseId: this.recordId })
      .then((result) => {
        console.log("callCaseDocumentAPIsuccess: " + result);
        })
        .catch((error) => {
          this.error = error;
          console.log("callCaseDocumentAPIerr: " + JSON.stringify(this.error));
        });
    
  }
  handleUploadFinishedInquiry(event) {
    const uploadedFiles = event.detail.files;
    const srElement = this.template.querySelector(".service-request");
    if (uploadedFiles.length > 0) {
      window.location.href = this.communityURL + "thank-you" + "?caseid=" + this.recordId;
    }
    
  }

  handleChange(event) {

    this.searchKey = event.target.value;
    //alert(this.searchKey);
    //alert("handleChange this.excludeRecordList >>> " + JSON.stringify(this.excludeRecordList));
    if (this.searchKey.length > 2) {
      if ([13, 38, 40].indexOf(event.keyCode) === -1) {
        this.onkeydown = -1;

        setTimeout(() => {

          getLookUpData({
            searchKeyWord: this.searchKey,
            excludedRec: this.excludeRecordList
          })
            .then(result => {

              //alert("handleChange result ==> " + JSON.stringify(result));
              if (result.length === 0) {
                this.records = this.label.noDataLbl;
                this.recordsExist = false;
              } else {
                let temparr = [];
                console.log('result!**' + JSON.stringify(result));
                result.forEach(function (list) {
                  if (list.SerialNumber != undefined) {
                    temparr.push({ Id: list.Id, Name: list.SerialNumber });
                  }
                  else if (list.Model_Code__c != undefined) {
                    temparr.push({ Id: list.Id, Name: list.Model_Code__c });
                  }
                  else {
                    temparr.push({ Id: list.Id, Name: list.Name });
                  }
                });
                this.records = temparr;
                this.recordsExist = true;
              }
            })
            .then(() => {
              if (this.searchKey.length > 0) {
                const liplant = this.template.querySelectorAll("li.filterLi");
                const liplantInq = this.template.querySelectorAll("li.filterInqLi");
                let li = $(liplant);
                li.removeClass("selected");
                let liInq = $(liplantInq);
                liInq.removeClass("selected");
                this.template.querySelector(".searchRes").classList.remove("slds-hide");
                this.template.querySelector(".inquiryRes").classList.remove("slds-hide");
              } else {
                this.template.querySelector(".searchRes").classList.add("slds-hide");
                this.template.querySelector(".inquiryRes").classList.add("slds-hide");
              }
            })
            .catch((error) => {
              this.error = error;
              console.log("lookUpDataErr::" + JSON.stringify(error));
            });

        }, 500);
      }
    }
  }

  searchKeyDown(event) {
    if ([13, 38, 40].indexOf(event.keyCode) !== -1) {
      event.preventDefault();
      const liplant = this.template.querySelectorAll("li.filterLi");
      let li = $(liplant);
      if (li.length > 0) {
        this.onkeydown =
          event.which === 40
            ? this.onkeydown === -1 || this.onkeydown === li.length - 1
              ? 0
              : this.onkeydown + 1
            : event.which === 38
              ? this.onkeydown === -1 || this.onkeydown === 0
                ? li.length - 1
                : this.onkeydown - 1
              : this.onkeydown === -1
                ? 0
                : this.onkeydown;
        li.removeClass("selected");
        li.eq(this.onkeydown).addClass("selected");
        if (event.which === 13) {
          li.eq(this.onkeydown).click();
        }
      }
    }
  }

  searchInqKeyDown(event) {
    if ([13, 38, 40].indexOf(event.keyCode) !== -1) {
      event.preventDefault();
      const liplant = this.template.querySelectorAll("li.filterInqLi");
      let li = $(liplant);
      if (li.length > 0) {
        this.onkeydown =
          event.which === 40
            ? this.onkeydown === -1 || this.onkeydown === li.length - 1
              ? 0
              : this.onkeydown + 1
            : event.which === 38
              ? this.onkeydown === -1 || this.onkeydown === 0
                ? li.length - 1
                : this.onkeydown - 1
              : this.onkeydown === -1
                ? 0
                : this.onkeydown;
        li.removeClass("selected");
        li.eq(this.onkeydown).addClass("selected");
        if (event.which === 13) {
          li.eq(this.onkeydown).click();
        }
      }
    }
  }

  handleSelect(event) {

    this.selectedRecord = $(event.currentTarget).attr("data-id");
    this.searchKey = "";
    this.selectedRecordList.push({
      Id: $(event.currentTarget).attr("data-id"),
      Name: $(event.currentTarget).attr("data-lable")
    });
    this.template.querySelector(".searchRes").classList.add("slds-hide");
    this.template.querySelector(".inquiryRes").classList.add("slds-hide");

    let temparr = [];
    this.selectedRecordList.forEach(function (list) {
      temparr.push({ Id: list.Id, Name: list.Name });
    });

    this.excludeRecordList = temparr;

    console.log("this.selectedRecord::" + JSON.stringify(this.selectedRecord));
    if (this.selectedRecord != 0) {
      //alert('if')
      getTopCategoryName({ prodAssId: this.selectedRecord })
        .then(result => {
          this.categoryCode = result;
          console.log("this.categoryCode::" + JSON.stringify(this.categoryCode));

          getServiceType({ catCode: this.categoryCode })
            .then((result) => {

              console.log("getServiceType::" + JSON.stringify(result));
              let splOpts = result.split(','), serviceOpts = [];

              splOpts.forEach(function (splOpt) {
                //serviceOpts.push({ label: splOpt.split('+')[0], value: splOpt.split('+')[1] });
                serviceOpts.push(
                  $("<option/>", {
                    value: splOpt.split('+')[1],
                    text: splOpt.split('+')[0]
                  })
                );
              });
              return serviceOpts;
            }).then(resOpts => {

              const selectpicker = this.template.querySelector(".selectpicker");
              $(selectpicker).prop('disabled', false).find("option").not(":first").remove();
              $(selectpicker).append(resOpts).val('').trigger("chosen:updated");

            }).catch((error) => {
              this.error = error;
              console.log("lookUpDataErr::" + JSON.stringify(error));
            });

        }).catch((error) => {
          this.error = error;
          console.log("lookUpDataErr::" + JSON.stringify(error));
        });

    } else {

      getServiceType({ catCode: this.selectedRecord })
        .then(result => {
          console.log("getServiceType::" + JSON.stringify(result));
          let splOpts = result.split(','), serviceOpts = [];

          splOpts.forEach(function (splOpt) {
            //serviceOpts.push({ label: splOpt.split('+')[0], value: splOpt.split('+')[1] });
            serviceOpts.push(
              $("<option/>", {
                value: splOpt.split('+')[1],
                text: splOpt.split('+')[0]
              })
            );
          });
          return serviceOpts;
        }).then(resOpts => {

          const selectpicker = this.template.querySelector(".selectpicker");
          $(selectpicker).prop('disabled', false).find("option").not(":first").remove();
          $(selectpicker).append(resOpts).val('').trigger("chosen:updated");
        }).catch((error) => {
          this.error = error;
          console.log("lookUpDataErr::" + JSON.stringify(error));
        });
    }

    const srElement = this.template.querySelector(".service-request");
    console.log("this.selectedRecordList.length::" + this.selectedRecordList.length);
    if (this.selectedRecordList.length > 0) {
      console.log("issss::" + "Testtt");
      $(".prodService-err", srElement).html("");
      $(".inquiryService-err", srElement).html("");
      $(".service-search", srElement).removeClass('alert-border');
      $("input[name=productService]", srElement).hide();
      $("input[name=inquiryService]", srElement).hide();
    } else {
      $("input[name=productService]", srElement).show();
      $("input[name=inquiryService]", srElement).show();
    }

    this.onkeydown = false;
  }

  handleRemove(event) {

    this.softwareLicenses = false;
    this.productDetails = false;
    this.contract = false;

    this.searchKey = "";
    this.template.querySelector(".searchRes").classList.add("slds-hide");
    this.template.querySelector(".inquiryRes").classList.add("slds-hide");

    let removedRecord = event.target.label;

    this.selectedRecordList.forEach(function (list, i, object) {
      if (removedRecord === list.Name) {
        object.splice(i, 1);
      }
    });

    if (this.selectedRecordList.length == 0) {
      const srElement = this.template.querySelector(".service-request");
      $("input[name=productService]", srElement).show();
      $("input[name=inquiryService]", srElement).show();
    }

    this.excludeRecordList = this.selectedRecordList;
    this.records = this.selectedRecordList;

    this.onkeydown = false;
    const selectpicker = this.template.querySelector(".selectpicker");
    $(selectpicker).empty();
    $(selectpicker).val('').trigger("chosen:updated");
  }

  clearAll(event) {

    this.selectedRecordList = [];
    this.excludeRecordList = [];
    this.searchKey = "";
    this.softwareLicenses = false;
    this.productDetails = false;
    this.contract = false;
    this.records = this.selectedRecordList;
    this.recordsExist = true;
    this.selectedRecord = 0;

    const srElement = this.template.querySelector(".service-request");
    $("input[name=productService]", srElement).show();
    $("input[name=inquiryService]", srElement).show();

    this.template.querySelector(".searchRes").classList.add("slds-hide");
    this.template.querySelector(".inquiryRes").classList.add("slds-hide");

    const selectpicker = this.template.querySelector(".selectpicker");
    $(selectpicker).empty();
    $(selectpicker).prop('disabled', true).val('').trigger("chosen:updated");
  }
}