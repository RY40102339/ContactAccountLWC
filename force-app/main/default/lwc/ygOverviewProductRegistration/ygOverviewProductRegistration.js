import { LightningElement } from 'lwc';
import getCommunityURL from '@salesforce/apex/YG_Utility.getCommunityURL';
import productRegLbl from '@salesforce/label/c.YG_Product_Registration';
import productRegMsgLbl from '@salesforce/label/c.YG_Product_Registration_Msg1';
import productRegMsg2Lbl from '@salesforce/label/c.YG_Product_Registration_Msg2';
import productAlertLbl from '@salesforce/label/c.YG_Product_support_alerts';
import regProductLbl from '@salesforce/label/c.YG_Register_your_products';

export default class YgOverviewProductRegistration extends LightningElement {
    productRegURL;
    label ={
        productRegLbl, productRegMsgLbl, productRegMsg2Lbl, productAlertLbl, regProductLbl
    }

    constructor(){
        super();
        getCommunityURL({})
		.then(result => {
			this.communityURL = result;
            window.console.log("communityURL::" + JSON.stringify(this.communityURL));
            this.productRegURL = this.communityURL + 'product-registration';
		}).catch(error => {
			this.error = error;
			console.log('Error: ' + JSON.stringify(this.error));
		});
  
    }
}