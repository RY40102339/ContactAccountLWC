import { LightningElement, wire } from 'lwc';
import getYourDetails from '@salesforce/apex/YG_ServiceRequestAndInquiries.getYourDetails';
import yourDetailsLbl from '@salesforce/label/c.YG_Your_Details';
import nameLbl from '@salesforce/label/c.YG_Name';
import titleLbl from '@salesforce/label/c.YG_Title';

export default class YgYourDetails extends LightningElement {


    label = { yourDetailsLbl, nameLbl, titleLbl };

    name = '-'; title = '-';

    constructor() {
        super();

        getYourDetails()
            .then(result => {
                this.name = result.Name;
                this.title = result.Title;
            }).catch(error => {
                console.log('Your Details Err::' + JSON.stringify(error));
            });
    }

}