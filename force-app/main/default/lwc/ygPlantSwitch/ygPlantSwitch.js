import { LightningElement, wire, track } from 'lwc';
import { loadScript, loadStyle } from "lightning/platformResourceLoader";
import YG_CustomerPortal from "@salesforce/resourceUrl/YG_CustomerPortal";
import { CurrentPageReference } from 'lightning/navigation';
import { fireEvent, registerListener, unregisterAllListeners } from 'c/pubSub';
import getPlantInfo from '@salesforce/apex/YG_CommonController.getPlantInfo';


export default class YgPlantSwitch extends LightningElement {

  @wire(CurrentPageReference) pageRef;
  plantInfoarray = [];
  firstPlantval;
  @track initialplant = true;
  plantNo = '';

  constructor() {

    super();
    let plantInfo = [];
    let firstPlant;

    let fullStr = window.location.search.substring(1);
    let splitStr = fullStr.split("&");
    let pltCode = '';
    for (var i = 0; i < splitStr.length; i++) {
      var pair = splitStr[i].split("=");
      if (pair[0] == 'pc') {
        pltCode = pair[1];
        this.plantNo = pair[1];
      }
    }

    getPlantInfo({ langCode: 'EN' })
      .then(result => {

        result.wrapper.forEach(function (list, index) {

          if (index === 0) {
            firstPlant = list.plantCode;
          }

          plantInfo.push({ label: list.plantName, value: list.plantCode });
        })
        this.plantInfoarray = plantInfo;
        this.firstPlantval = firstPlant;

        console.log('plantinfoResult: ' + JSON.stringify(result));
      })
      .catch(error => {
        this.error = error;
        console.log('accountLogoError: ' + JSON.stringify(this.error.status));
      });

    this.loadChoosenLibraries();
  }

  renderedCallback() {

    let fullStr = window.location.search.substring(1);
    let splitStr = fullStr.split("&");
    let pltCode = '';
    for (var i = 0; i < splitStr.length; i++) {
      var pair = splitStr[i].split("=");
      if (pair[0] == 'pc') {
        pltCode = pair[1];
        this.plantNo = pair[1];
      }
    }

    if (this.initialplant === true && this.firstPlantval != undefined) {

      if (pltCode != '') {
        this.firstPlantval = pltCode;
      }

      setTimeout(() => {
        const selectpicker = this.template.querySelector(".selectpicker");
        let sessionPlant = localStorage.getItem("plantCode");
        if (sessionPlant) {
          $(selectpicker).val(sessionPlant).trigger("chosen:updated");
          fireEvent(this.pageRef, 'plantFilter', sessionPlant);
        } else {
          $(selectpicker).val(this.firstPlantval).trigger("chosen:updated");
          fireEvent(this.pageRef, 'plantFilter', this.firstPlantval);
        }
        this.initialplant = false;
      }, 1000);
    }
  }

  connectedCallback() {
    registerListener('selfRegister', this.checkSelfReg, this);
  }

  disconnectedCallback() {
    unregisterAllListeners(this);
  }

  checkSelfReg(param) {

    if (param === true) {
      this.template.querySelector(".form-group").classList.remove('d-inline-flex');
      this.template.querySelector(".form-group").classList.add('d-none');
    }
  }

  async loadChoosenLibraries() {

    loadScript(this, YG_CustomerPortal + "/YG_JS/jquery.min.js").then(() => {
      loadStyle(this, YG_CustomerPortal + "/YG_CSS/chosen.css").then(() => {
        loadScript(this, YG_CustomerPortal + "/YG_JS/chosen.jquery.js").then(() => {

          const selectpicker = this.template.querySelector(".selectpicker");
          const hideElement = this.template.querySelector(".hiddenItem");
          const triggerClick = this.template.querySelector(".triggerClick");

          $(selectpicker).chosen({
            disable_search: true,
            width: "331px"
          }).change(function (e) {

            // Store
            localStorage.setItem("plantCode", $(this).val());
            $(selectpicker).val($(this).val()).trigger("chosen:updated");
            $('input[name=hiddenSelect]', hideElement).val($(this).val());
            triggerClick.click();
          });
        });
      });
    });
  }

  get options() {
    return this.plantInfoarray;
  }

  triggetSelect() {

    const plantElement = this.template.querySelector(".service-menu");
    let plantVal = $("select[name=plantDD]", plantElement).val();
    fireEvent(this.pageRef, 'plantFilter', plantVal);
    fireEvent(this.pageRef, 'clearBtnFilter', 'clear');
    fireEvent(this.pageRef, 'plantAutoFilter', plantVal);
  }
}