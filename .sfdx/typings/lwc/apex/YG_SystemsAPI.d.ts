declare module "@salesforce/apex/YG_SystemsAPI.getCustomerPlantDetails" {
  export default function getCustomerPlantDetails(): Promise<any>;
}
declare module "@salesforce/apex/YG_SystemsAPI.getDeliverableNoAndSystemId" {
  export default function getDeliverableNoAndSystemId(param: {plantCodeList: any}): Promise<any>;
}
declare module "@salesforce/apex/YG_SystemsAPI.getSystemDetails" {
  export default function getSystemDetails(param: {plantCodeList: any}): Promise<any>;
}
declare module "@salesforce/apex/YG_SystemsAPI.getDeliverableAssetDetails" {
  export default function getDeliverableAssetDetails(param: {plantdeliverableNoMap: any, plantMap: any, deiverableNoSystemMap: any, projList: any, ifAcc: any}): Promise<any>;
}
declare module "@salesforce/apex/YG_SystemsAPI.getStationDetailsList" {
  export default function getStationDetailsList(param: {statId: any, gissSystemId: any, stationType: any, dnsn: any}): Promise<any>;
}
