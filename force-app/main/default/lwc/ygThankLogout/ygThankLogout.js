import { LightningElement } from 'lwc';
import YG_CustomerPortal from '@salesforce/resourceUrl/YG_CustomerPortal';
import { loadStyle } from 'lightning/platformResourceLoader';
import successfullyLoggedLbl from '@salesforce/label/c.YG_You_have_successfully_logged_out';
import thankLogoutLbl from '@salesforce/label/c.YG_ThankLogout_Msg';
import signInLbl from '@salesforce/label/c.YG_Sign_in_again';


export default class YgThankLogout extends LightningElement {


    yoklogo = YG_CustomerPortal + '/YG_Images/yok-logo.svg';
    macbook = YG_CustomerPortal + '/YG_Images/macbook.svg';
    iphone = YG_CustomerPortal + '/YG_Images/iphone.svg';
    loginURL = '';

    label = {
        successfullyLoggedLbl, thankLogoutLbl, signInLbl
    };

    constructor() {
        super();

        //let fullStr = window.location.hostname;
        this.loginURL = 'overview';
    }
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