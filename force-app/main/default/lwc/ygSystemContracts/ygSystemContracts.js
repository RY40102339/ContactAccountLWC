import { LightningElement, wire, track } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { registerListener, unregisterAllListeners } from 'c/pubSub';
import YG_CustomerPortal from '@salesforce/resourceUrl/YG_CustomerPortal';
import { loadScript } from 'lightning/platformResourceLoader';
import lastSysInfo from '@salesforce/label/c.YG_Sys_Info_Update';
import lastUpdData from '@salesforce/label/c.YG_Last_System_Info';
import system from '@salesforce/label/c.YG_System';
import revision from '@salesforce/label/c.YG_Revision';
import mtnPhase from '@salesforce/label/c.YG_Sys_Maintenance_phase';
import contNo from '@salesforce/label/c.YG_Sys_Contract_no';
import startDate from '@salesforce/label/c.YG_LCA_start_date';
import endDate from '@salesforce/label/c.YG_LCA_end_date';
import action from '@salesforce/label/c.YG_Action';

export default class YgSystemContracts extends LightningElement {

    @wire(CurrentPageReference) pageRef;

    label = { lastSysInfo, lastUpdData, system, revision, mtnPhase, contNo, startDate, endDate, action };

    contractList = [];
    systemDetails = [];
    @track isProjDet = false;
    lastSysUpdateDate = '';
    commURL = '';
    servReqURL = '';
    contractDetURL = '';

    constructor() {
        super();
        loadScript(this, YG_CustomerPortal + '/YG_JS/jquery.min.js')
    }

    connectedCallback() {
        registerListener('systemDetails', this.getSystemDetails, this);
        registerListener('communityURL', this.getCommunityURL, this);
    }

    disconnectedCallback() {
        unregisterAllListeners(this);
    }

    getCommunityURL(commURL) {
        this.commURL = commURL;
    }

    getSystemDetails(result) {

        this.isProjDet = result.projWrap.isProjDet;
        this.contractList = [];
        this.systemDetails = [];
        this.lastSysUpdateDate = '';

        if (result.projWrap.isProjDet === true) {

            let tempArr = [];
            result.projWrap.projDetWrap.forEach(function (list) {
                tempArr.push({
                    lastSysUpdateDate: list.lastSysUpdateDate,
                    projectCode: list.projectCode,
                    projectName: list.projectName,
                    sysColorClassName: "phase-hypen " + list.sysColorClassName,
                    sysMtnPhase: list.sysMtnPhase,
                    sysRevNo: list.sysRevNo
                });
            })
            //this.isProjDet = true;
            this.systemDetails = tempArr;
            this.lastSysUpdateDate = result.projWrap.projDetWrap[0].lastSysUpdateDate;

            //Contract Details
            let commURL = this.commURL;
            let tempArr1 = [];

            //let plantCode = result.plantCode;
            //this.servReqURL = commURL + 'service-request-and-inquiries?pc=' + plantCode;

            result.servConWrap.forEach(function (contract) {
                tempArr1.push({
                    contractName: contract.contractName,
                    contractNo: contract.contractNo,
                    contractStartDt: contract.contractStartDt,
                    contractEndDt: contract.contractEndDt,
                    contractExpsIn: contract.contractExpsIn,
                    contractAction: contract.contractAction,
                    contractDetURL: commURL + 'contract-details?contractno=' + contract.contractNo,
                    serviceReqURL: commURL + 'service-request-and-inquiries?contractno=' + contract.contractNo
                });
            })

            this.contractList = tempArr1;
        }
    }

}