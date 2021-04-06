import { LightningElement } from 'lwc';
import YG_CustomerPortal from '@salesforce/resourceUrl/YG_CustomerPortal';
import { loadStyle } from 'lightning/platformResourceLoader';

export default class YgRequestAccount extends LightningElement {
    yoklogo = YG_CustomerPortal + '/YG_Images/yok-logo.svg';
    macbook = YG_CustomerPortal + '/YG_Images/macbook.svg';
    iphone = YG_CustomerPortal + '/YG_Images/iphone.svg';

    connectedCallback() {
        Promise.all([
            loadStyle(this, YG_CustomerPortal + '/YG_CSS/common.css'),
            loadStyle(this, YG_CustomerPortal + '/YG_CSS/style.css'),
        ])
    }

    renderedCallback() {
        document.getElementsByTagName("BODY")[0].classList.add('pt-0', 'full-width');
    }
}