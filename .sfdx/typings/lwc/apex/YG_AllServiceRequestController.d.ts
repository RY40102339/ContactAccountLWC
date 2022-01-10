declare module "@salesforce/apex/YG_AllServiceRequestController.getServiceRequestGridDetails" {
  export default function getServiceRequestGridDetails(param: {filterValue: any, catType: any, caseStatus: any, loadLimit: any, offset: any}): Promise<any>;
}
declare module "@salesforce/apex/YG_AllServiceRequestController.getServiceRequestCSVDetails" {
  export default function getServiceRequestCSVDetails(): Promise<any>;
}
declare module "@salesforce/apex/YG_AllServiceRequestController.getServiceRequestChartDetails" {
  export default function getServiceRequestChartDetails(param: {caseType: any, caseStatus: any}): Promise<any>;
}
declare module "@salesforce/apex/YG_AllServiceRequestController.getServiceReqInfo" {
  export default function getServiceReqInfo(param: {caseNo: any}): Promise<any>;
}
declare module "@salesforce/apex/YG_AllServiceRequestController.toUpdateCaseDescription" {
  export default function toUpdateCaseDescription(param: {caseNo: any, notes: any}): Promise<any>;
}
declare module "@salesforce/apex/YG_AllServiceRequestController.getCaseHistory" {
  export default function getCaseHistory(param: {caseNo: any}): Promise<any>;
}
