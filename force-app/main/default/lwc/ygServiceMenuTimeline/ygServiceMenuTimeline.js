import { LightningElement, track, wire } from 'lwc';
import { loadScript, loadStyle } from "lightning/platformResourceLoader";
import YG_CustomerPortal from "@salesforce/resourceUrl/YG_CustomerPortal";
import { CurrentPageReference } from 'lightning/navigation';
import getServiceMenuTimeLine from '@salesforce/apex/YG_AllServiceContractsController.getServiceMenuTimeLine';
import getServiceMenuDropdown from '@salesforce/apex/YG_AllServiceContractsController.getServiceMenuDropdown';
import getServiceReqInfo from '@salesforce/apex/YG_AllServiceRequestController.getServiceReqInfo';
import getCaseHistory from '@salesforce/apex/YG_AllServiceRequestController.getCaseHistory';
import getYourDetails from '@salesforce/apex/YG_ServiceRequestAndInquiries.getYourDetails';
import yourDetailsLbl from '@salesforce/label/c.YG_Your_Details';
import nameLbl from '@salesforce/label/c.YG_Name';
import titleLbl from '@salesforce/label/c.YG_Title';
import conNoLbl from '@salesforce/label/c.YG_Contact_No';
import plantLbl from '@salesforce/label/c.YG_Plant';
import addressLbl from '@salesforce/label/c.YG_Address';
import subject from '@salesforce/label/c.YG_Subject';
import submitdate from '@salesforce/label/c.YG_Submit_Date';
import products from '@salesforce/label/c.YG_Products';
import servicetype from '@salesforce/label/c.YG_Service_Type';
import progress from '@salesforce/label/c.YG_Progress';
import reason from '@salesforce/label/c.YG_Type';
import showLbl from '@salesforce/label/c.YG_Show';
import moreLbl from '@salesforce/label/c.YG_More';
import statusLbl from '@salesforce/label/c.YG_Status';
import serviceMenuTimelineLbl from '@salesforce/label/c.YG_Service_Menu_Timeline';
import inprogressLbl from '@salesforce/label/c.YG_In_Progress';
import ygProductModuleLbl from '@salesforce/label/c.YG_Product_Module';
import ygViewDetailsLbl from '@salesforce/label/c.YG_View_details';
import ygCasenumberLbl from '@salesforce/label/c.YG_Case_Number';
import serialNumLbl from '@salesforce/label/c.YG_Serial_number';
import serviceTypeLbl from '@salesforce/label/c.YG_Service_Type';
import contractLbl from '@salesforce/label/c.YG_Contract';
import warrentyLbl from '@salesforce/label/c.YG_Warranty';
import dateSubmittedLbl from '@salesforce/label/c.YG_DateSubmitted';
import serviceLocationLbl from '@salesforce/label/c.YG_Service_location';
import preferredpickupLbl from '@salesforce/label/c.YG_Preferred_pick_up_date';
import preferredtimeLbl from '@salesforce/label/c.YG_Preferred_pick_up_time';
import submittedbyLbl from '@salesforce/label/c.YG_Submitted_by';
import assignedtoLbl from '@salesforce/label/c.YG_Assigned_to';
import notesLbl from '@salesforce/label/c.YG_Notes';
import editnotesLbl from '@salesforce/label/c.YG_Edit_notes';
import updateLbl from '@salesforce/label/c.YG_Update';

export default class YgServiceMenuTimeline extends LightningElement {

  @wire(CurrentPageReference) pageRef;
  @track isLoading = true;
  @track selectedOption;
  serviceMenuData = [];
  timelineHtml = '';
  loadExternal = true;
  contractNum;
  plant_Code;
  serviceMenuArray = [];
  showDropdown = true;
  hideTimeline = false;
  selectId;
  caseDetails = {};
  showContractType = false;
  @track hideLink = false;
  viewDetURL = '';

  //Boolean tracked variable to indicate if modal is open or not default value is false as modal is closed when page is loaded 
  @track isModalOpen = false;
  caseInfo; productName; modelCode; assetName; lca; subType; caseCreatedDate; caseCreatedBy; Description; caseNo;

  label = {
    subject, submitdate, products, servicetype, progress, reason, showLbl, moreLbl, yourDetailsLbl, nameLbl, titleLbl,
    conNoLbl, plantLbl, addressLbl, statusLbl, serviceMenuTimelineLbl, inprogressLbl, ygProductModuleLbl, ygViewDetailsLbl,
    ygCasenumberLbl, serialNumLbl, serviceTypeLbl, contractLbl, warrentyLbl, dateSubmittedLbl, serviceLocationLbl,
    preferredpickupLbl, preferredtimeLbl, submittedbyLbl, assignedtoLbl, notesLbl, editnotesLbl, updateLbl
  };
  name = ''; title = ''; caseHisData;
  menuMap;
  @track mapOfValues = [];
  constructor() {

    super();

    let pageURL = window.location.href;
    let pagePath = window.location.pathname;
    let pageName = pagePath.substr(3);


    let fullStr = window.location.search.substring(1);
    let splitStr = fullStr.split("&");
    let modno = '';
    let plant = '';
    for (var i = 0; i < splitStr.length; i++) {
      var pair = splitStr[i].split("=");
      if (pair[0] == 'contractno') {
        modno = pair[1];
        this.contractNum = pair[1];
      }
      if (pair[0] == 'pc') {
        plant = pair[1];
        this.plant_Code = pair[1];
      }
    }


    getServiceMenuDropdown({ contractNum: this.contractNum })
      .then(result => {
        console.log('serviceMenus:::' + JSON.stringify(result));
        this.isLoading = false;
        for (let key in result) {
          // Preventing unexcepted data
          if (result.hasOwnProperty(key)) { // Filtering the data in the loop
            this.mapOfValues.push({ label: result[key], value: key });
            //this.imgName = key;
            //this.imgURL = result[key];
          }
          /*if (this.imgURL != '' || this.imgName != '') {
            this.show = true;
          }*/
        }
        //this.serviceMenuArray = 
        //this.className = 'actual-img-130';
        console.log('serviceMenus::mapOfValues:' + JSON.stringify(this.mapOfValues));
        //alert('length::' + this.mapOfValues.length)
        if (this.mapOfValues.length === 1) {
          this.showDropdown = false;
        }
        if (this.mapOfValues.length <= 0) {
          this.hideTimeline = true;
        }
      }).catch(error => {
        this.error = error;
        console.log('serviceMenus Error:::: ' + JSON.stringify(this.error));
      });

    getServiceMenuTimeLine({ contractNum: this.contractNum, selectEntitlementId: null })
      .then(result => {
        console.log('this.Time Lineresult: ' + JSON.stringify(result));
        this.isLoading = false;
        this.serviceMenuData = result.hisWrap;

        //alert(JSON.stringify(this.serviceMenuData));
        let buildHtml = '', className = '';
        this.serviceMenuData.forEach(function (list) {

          if (list.prodYear != '') {
            buildHtml += '<li><div class="tldate">' + list.prodYear + '</div></li>';
            //alert(list.servMenuHis.length)
            if (list.servMenuHis.length > 0) {
              list.servMenuHis.forEach(function (list1) {

                if (list1.type == 'Inspection') {
                  buildHtml += '<li class="timeline-inverted">';
                  buildHtml += '<div class="tl-circ"><i class="fas fa-circle yellow"></i></div>';
                  buildHtml += '<div class="timeline-panel">';
                  buildHtml += '<div class="tl-heading">';
                  buildHtml += '<span>' + list1.description + '</span>';
                  buildHtml += '<p class="mb-0"><small class="text-muted gray">' + list1.hisDate + '</small></p>';
                  buildHtml += '</div></div></li>';
                }

                if (list1.type == 'Case') {

                  className = '';

                  if (list1.status == 'Active') {
                    className = 'alert-orange'
                  }
                  if (list1.status == 'Closed') {
                    className = 'grey-darkest'
                  }

                  buildHtml += '<li class="timeline-inverted">';
                  buildHtml += '<div class="tl-expand cursor-pointer"></div>';
                  buildHtml += '<div class="timeline-panel">';
                  buildHtml += '<div class="tl-heading">';
                  buildHtml += '<span class="cursor-pointer text-hover-color"><ins>' + list1.caseSubject + '</ins></span>';
                  buildHtml += '<p class="grey-darkest mt-1 mb-1 f14">Status: <strong class="' + className + '">' + list1.status + '</strong></p>';
                  buildHtml += '<p class="grey-darkest mb-1 f14">Case No: <a data-id=' + list1.caseno + ' class="case-link text-hover-color" href="javascript:void(0)"><ins>' + list1.caseno + '</ins></a></p>';
                  buildHtml += '<p class="mb-0"><small class="text-muted gray">' + list1.caseCreatedDate + '</small></p>';
                  buildHtml += '</div></div>';

                  if (list1.serCaseHis.length > 0) {
                    list1.serCaseHis.forEach(function (list2) {
                      buildHtml += '<ul class="child-list" style="display: none;">';
                      buildHtml += '<li class="timeline-inverted">';
                      buildHtml += '<div class="tl-circ"><i class="fas fa-circle yellow"></i></div>';
                      buildHtml += '<div class="timeline-panel">';
                      buildHtml += '<div class="tl-heading">';
                      buildHtml += '<span>' + list2.progress + '</span>';
                      buildHtml += '<p class="mb-0"><small class="text-muted gray">' + list2.hisDate + '</small></p>';
                      buildHtml += '</div></div></li></ul>';
                    });
                  }
                  buildHtml += '</li>';
                }

              });
            }
          }
        });

        this.timelineHtml = buildHtml + '<li class="pb-5"></li>';

      }).then(() => {
        //this.isLoading = false;
        //alert('thennnn'+ this.timelineHtml)
        this.loadExternalLibraries(this.timelineHtml);
        this.loadChoosenLibraries();
      }).catch(error => {
        this.error = error;
        console.log('this.Time LineError: ' + JSON.stringify(this.error));
      });
    //this.loadExternalLibraries();
    //this.loadChoosenLibraries();
  }


  async loadExternalLibraries(timelineHtml) {

    let finalHtml = timelineHtml;

    loadScript(this, YG_CustomerPortal + '/YG_JS/jquery.min.js').then(() => {

      const timelineSec = this.template.querySelector('.section');
      const timelineEle = this.template.querySelector('.ptimeline');


      $(timelineEle).html(finalHtml);

      $('.tl-expand', timelineEle).click(function () {
        $(this).parent(".timeline-inverted").find("ul.child-list").slideToggle('slow');
        $(this).toggleClass('expanded');
      });
      $('.tl-heading > span', timelineEle).click(function () {
        $(this).parents(".timeline-inverted").find("ul.child-list").slideToggle('slow');
        $(this).parents(".timeline-inverted").find(".tl-expand").toggleClass('expanded');
      });
      const triggerClick = this.template.querySelector('.triggerClick');
      $('.case-link', timelineEle).click(function () {
        $('input[name=hiddenSelect]', timelineSec).val($(this).attr('data-id'));
        triggerClick.click();
      });

    })
  }

  async loadChoosenLibraries() {
    loadScript(this, YG_CustomerPortal + "/YG_JS/jquery.min.js").then(() => {
      loadStyle(this, YG_CustomerPortal + "/YG_CSS/chosen.css").then(() => {
        loadScript(this, YG_CustomerPortal + "/YG_JS/chosen.jquery.js").then(
          () => {
            const selectpicker = this.template.querySelector(".selectpicker");
            //const srElement = this.template.querySelector(".service-request");
            const triggerChange = this.template.querySelector(".triggerChange");

            $(selectpicker)
              .chosen({
                disable_search: true,
                width: "331px"
              })
              .change(function (e) {
                $(selectpicker).val($(this).val()).trigger("chosen:updated");
                triggerChange.click();
              });
          }
        );
      });
    });
  }

  get options() {
    return this.mapOfValues;
  }

  //To select on the service menu drop down
  onChange(event) {
    //alert('I am here');
    const srElement = this.template.querySelector(".service-menu");
    let servMenu = $("select[name=serviceMenu]", srElement).val();
    //alert('Value::' + servMenu);
    if (servMenu === 'All') {
      this.selectId = null;
    } else {
      this.selectId = servMenu;
    }

    getServiceMenuTimeLine({ contractNum: this.contractNum, selectEntitlementId: this.selectId })
      .then(result => {
        console.log('this.Time Lineresult: ' + JSON.stringify(result));
        this.isLoading = false;
        this.serviceMenuData = result.hisWrap;

        //alert(JSON.stringify(this.serviceMenuData));
        let buildHtml = '', className = '';
        this.serviceMenuData.forEach(function (list) {

          if (list.prodYear != '') {
            buildHtml += '<li><div class="tldate">' + list.prodYear + '</div></li>';
            //alert(list.servMenuHis.length)
            if (list.servMenuHis.length > 0) {
              list.servMenuHis.forEach(function (list1) {

                if (list1.type == 'Inspection') {
                  buildHtml += '<li class="timeline-inverted">';
                  buildHtml += '<div class="tl-circ"><i class="fas fa-circle yellow"></i></div>';
                  buildHtml += '<div class="timeline-panel">';
                  buildHtml += '<div class="tl-heading">';
                  buildHtml += '<span>' + list1.description + '</span>';
                  buildHtml += '<p class="mb-0"><small class="text-muted gray">' + list1.hisDate + '</small></p>';
                  buildHtml += '</div></div></li>';
                }

                if (list1.type == 'Case') {

                  className = '';

                  if (list1.status == 'Active') {
                    className = 'alert-orange'
                  }
                  if (list1.status == 'Closed') {
                    className = 'grey-darkest'
                  }

                  buildHtml += '<li class="timeline-inverted">';
                  buildHtml += '<div class="tl-expand cursor-pointer"></div>';
                  buildHtml += '<div class="timeline-panel">';
                  buildHtml += '<div class="tl-heading">';
                  buildHtml += '<span class="cursor-pointer text-hover-color"><ins>' + list1.caseSubject + '</ins></span>';
                  buildHtml += '<p class="grey-darkest mt-1 mb-1 f14">Status: <strong class="' + className + '">' + list1.status + '</strong></p>';
                  buildHtml += '<p class="grey-darkest mb-1 f14">Case No: <a data-id=' + list1.caseno + ' class="case-link text-hover-color" href="javascript:void(0)"><ins>' + list1.caseno + '</ins></a></p>';
                  buildHtml += '<p class="mb-0"><small class="text-muted gray">' + list1.caseCreatedDate + '</small></p>';
                  buildHtml += '</div></div>';

                  if (list1.serCaseHis.length > 0) {
                    list1.serCaseHis.forEach(function (list2) {
                      buildHtml += '<ul class="child-list" style="display: none;">';
                      buildHtml += '<li class="timeline-inverted">';
                      buildHtml += '<div class="tl-circ"><i class="fas fa-circle yellow"></i></div>';
                      buildHtml += '<div class="timeline-panel">';
                      buildHtml += '<div class="tl-heading">';
                      buildHtml += '<span>' + list2.progress + '</span>';
                      buildHtml += '<p class="mb-0"><small class="text-muted gray">' + list2.hisDate + '</small></p>';
                      buildHtml += '</div></div></li></ul>';
                    });
                  }
                  buildHtml += '</li>';
                }

              });
            }
          }
        });

        this.timelineHtml = buildHtml + '<li class="pb-5"></li>';

      }).then(() => {
        //alert('thennnn'+ this.timelineHtml)
        this.loadExternalLibraries(this.timelineHtml);
        this.loadChoosenLibraries();
      }).catch(error => {
        this.error = error;
        console.log('this.Time LineError: ' + JSON.stringify(this.error));
      });


  }
  //To trigger the pop window
  triggetSelect() {
    //this.openModal();
    const timelineSec = this.template.querySelector('.section');
    //alert($('input[name=hiddenSelect]', timelineSec).val());
    let caseId = $('input[name=hiddenSelect]', timelineSec).val();
    this.caseDetails = {};
    this.hideLink = false;

    getServiceReqInfo({ caseNo: caseId })
      .then(result => {
        console.log('result::modelWindow::' + JSON.stringify(result));
        if(result.contractType.length > 0){
          this.showContractType = true;
          this.caseDetails = result;
        }else{
            this.showContractType = false;
            this.caseDetails = result;
        }
        if (result.modelCode != '') {
            this.hideLink = true;
            this.viewDetURL = this.communityURL + 'product-details?modcode=' + result.modelCode;
        } else {
            this.hideLink = false;
        }
      }).then(() => {
        getYourDetails()
          .then(result => {
            this.name = result.Name;
            this.title = result.Title;
          }).catch(error => {
            console.log('Your Details Err::' + JSON.stringify(error));
          });

      }).then(() => {


      }).then(() => {
        // to open modal set isModalOpen tarck value as true
        this.isModalOpen = true;
      }).catch(error => {
        this.error = error;
        console.log('modelWindow Error: ' + JSON.stringify(this.error));
      });
    getCaseHistory({ caseNo: caseId })
      .then(result => {
        console.log('result::caseHistory::' + JSON.stringify(result));
        console.log('result::caseHistory::' + JSON.stringify(result.hisWrap));
        this.caseHisData = result.hisWrap;
      }).catch(error => {
        this.error = error;
        console.log('caseHistory Error: ' + JSON.stringify(this.error));
      })

    /*
  getCaseHistory({ caseNo: caseId })
    .then(result => {
      console.log('result::caseHistory::' + JSON.stringify(result));
      console.log('result::caseHistory::' + JSON.stringify(result.hisWrap));
      this.caseHisData = result.hisWrap;
    }).then(() => {
      this.openModal();
    }).catch(error => {
      this.error = error;
      console.log('caseHistory Error: ' + JSON.stringify(this.error));
    });*/
  }

  //To close the pop window
  closeModal() {
    // to close modal set isModalOpen tarck value as false
    this.isModalOpen = false;
  }
}