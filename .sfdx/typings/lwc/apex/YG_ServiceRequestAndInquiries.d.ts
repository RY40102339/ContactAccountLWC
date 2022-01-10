declare module "@salesforce/apex/YG_ServiceRequestAndInquiries.getYourDetails" {
  export default function getYourDetails(): Promise<any>;
}
declare module "@salesforce/apex/YG_ServiceRequestAndInquiries.createInquiries" {
  export default function createInquiries(param: {inquiryData: any}): Promise<any>;
}
declare module "@salesforce/apex/YG_ServiceRequestAndInquiries.getLookUpData" {
  export default function getLookUpData(param: {searchKeyWord: any, excludedRec: any}): Promise<any>;
}
declare module "@salesforce/apex/YG_ServiceRequestAndInquiries.getTopCategoryName" {
  export default function getTopCategoryName(param: {prodAssId: any}): Promise<any>;
}
declare module "@salesforce/apex/YG_ServiceRequestAndInquiries.createServiceReq" {
  export default function createServiceReq(param: {serviceReqData: any}): Promise<any>;
}
declare module "@salesforce/apex/YG_ServiceRequestAndInquiries.getOfficeDetails" {
  export default function getOfficeDetails(): Promise<any>;
}
declare module "@salesforce/apex/YG_ServiceRequestAndInquiries.getServiceType" {
  export default function getServiceType(param: {catCode: any}): Promise<any>;
}
declare module "@salesforce/apex/YG_ServiceRequestAndInquiries.getCaseDetails" {
  export default function getCaseDetails(param: {caseid: any}): Promise<any>;
}
declare module "@salesforce/apex/YG_ServiceRequestAndInquiries.getProductData" {
  export default function getProductData(param: {value: any}): Promise<any>;
}
