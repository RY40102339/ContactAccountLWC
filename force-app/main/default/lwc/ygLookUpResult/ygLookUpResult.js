import { LightningElement, api } from 'lwc';

export default class YgLookUpResult extends LightningElement {

    @api record;
    @api selectedRecord;
    @api pageName;
    showName = false;
    showSerialNumber = false;

    renderedCallback(){
        if(this.pageName != 'all-systems' ){
            this.showName = false;
            if(this.pageName === 'software-details')
            {
                this.showSerialNumber = true;
            }
        }
        if(this.pageName === 'all-systems'){
            if(this.record.Name == undefined){
                this.showName = true;
            }else{
                this.showName = false;
            }
        }
    }   

    handleSelect(event){

        this.selectedRecord = event.currentTarget.innerHTML;
       
        const sendSelectedRecord = new CustomEvent("select",{
            detail : this.record
        });
        this.dispatchEvent(sendSelectedRecord);
    }

}