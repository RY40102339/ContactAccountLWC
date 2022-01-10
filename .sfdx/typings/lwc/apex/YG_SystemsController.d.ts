declare module "@salesforce/apex/YG_SystemsController.callDelivAPI" {
  export default function callDelivAPI(param: {plantCode: any}): Promise<any>;
}
declare module "@salesforce/apex/YG_SystemsController.getAllSystemsDetails" {
  export default function getAllSystemsDetails(param: {plantCode: any, projectCode: any}): Promise<any>;
}
declare module "@salesforce/apex/YG_SystemsController.getAllStationDetails" {
  export default function getAllStationDetails(param: {plantCode: any, projectCode: any, filterValue: any}): Promise<any>;
}
declare module "@salesforce/apex/YG_SystemsController.getPhaseDetails" {
  export default function getPhaseDetails(param: {mtnPhase: any}): Promise<any>;
}
declare module "@salesforce/apex/YG_SystemsController.getPhaseEndsIn" {
  export default function getPhaseEndsIn(param: {endDate: any}): Promise<any>;
}
declare module "@salesforce/apex/YG_SystemsController.getContractDetails" {
  export default function getContractDetails(param: {plantId: any, projectCode: any, langCode: any}): Promise<any>;
}
