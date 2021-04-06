import { LightningElement } from 'lwc';
import YG_CustomerPortal from '@salesforce/resourceUrl/YG_CustomerPortal';

export default class YgQrCode extends LightningElement {

    mobileQR = YG_CustomerPortal + '/YG_Images/mobileQR.svg';

}