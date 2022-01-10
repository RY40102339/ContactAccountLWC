declare module "@salesforce/apex/YG_AllServiceContractsController.getAllServiceContracts" {
  export default function getAllServiceContracts(param: {plantCode: any, filterdByStatus: any, filteredByIndustry: any, servContractFilterIdList: any, loadLimit: any, offset: any}): Promise<any>;
}
declare module "@salesforce/apex/YG_AllServiceContractsController.getServContWithoutSOP" {
  export default function getServContWithoutSOP(param: {accid: any}): Promise<any>;
}
declare module "@salesforce/apex/YG_AllServiceContractsController.getTotalContractSize" {
  export default function getTotalContractSize(param: {plantCode: any}): Promise<any>;
}
declare module "@salesforce/apex/YG_AllServiceContractsController.getContractInfo" {
  export default function getContractInfo(param: {contractNumber: any}): Promise<any>;
}
declare module "@salesforce/apex/YG_AllServiceContractsController.getServiceMenuList" {
  export default function getServiceMenuList(param: {contractNum: any}): Promise<any>;
}
declare module "@salesforce/apex/YG_AllServiceContractsController.getNotificationBarData" {
  export default function getNotificationBarData(param: {endDt: any, entitlementListID: any, servContractId: any}): Promise<any>;
}
declare module "@salesforce/apex/YG_AllServiceContractsController.getServiceMenuTimeLine" {
  export default function getServiceMenuTimeLine(param: {contractNum: any, selectEntitlementId: any}): Promise<any>;
}
declare module "@salesforce/apex/YG_AllServiceContractsController.getServiceMenuDropdown" {
  export default function getServiceMenuDropdown(param: {contractNum: any}): Promise<any>;
}
declare module "@salesforce/apex/YG_AllServiceContractsController.getContract" {
  export default function getContract(param: {contractNo: any}): Promise<any>;
}
declare module "@salesforce/apex/YG_AllServiceContractsController.getContractCaseSubmitThankYouPageDetails" {
  export default function getContractCaseSubmitThankYouPageDetails(param: {caseid: any}): Promise<any>;
}
