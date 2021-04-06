import { LightningElement, track } from 'lwc';
import getUpdatePassword from '@salesforce/apex/YG_UpdatePasswordCDCAPI.getUpdatePassword';

export default class YgUpdatePassword extends LightningElement {

    @track cerrorMsg = '';
    @track nerrorMsg = '';
    @track cnerrorMsg = '';
    @track successMsg = '';

    togglePwd(event){
        event.preventDefault();
        const ptype = this.template.querySelector('.'+event.currentTarget.dataset.name);
        if(ptype.type === "password"){
            $(ptype).attr('type', 'text'); 
        }else{
            $(ptype).attr('type', 'password'); 
        }
    }
    cpKeyup(){
        this.cerrorMsg = '';
        this.nerrorMsg = '';
        this.successMsg = '';
        const cPassword = this.template.querySelector('.cPassword');
        let currentPassword = cPassword.value.trim();
        if (currentPassword.length > 0) {
            cPassword.classList.remove('alert-border');
        }
    }
    npKeyup(){
        let nPassFlag = false;
        this.nerrorMsg = '';
        const cPassword = this.template.querySelector('.cPassword');
        let currentPassword = cPassword.value.trim();
        const nPassword = this.template.querySelector('.nPassword');
        let newPassword = nPassword.value.trim();
        if (newPassword.length > 0) {
            nPassword.classList.remove('alert-border');
            if(currentPassword === newPassword){
                nPassFlag = true;
                nPassword.classList.add('alert-border');
                this.nerrorMsg = 'New Password cannot be the same as Current Password';
            }else{
                nPassword.classList.remove('alert-border');
            }
        }
        if (newPassword.length < 6) {
            this.nerrorMsg = 'Password does not meet complexity requirements';
            nPassword.classList.add('alert-border');
        }else{
            if(!nPassFlag){
                nPassword.classList.remove('alert-border');
            }
            
        }
    }
    cnpKeyup(){
        this.cnerrorMsg = '';
        const nPassword = this.template.querySelector('.nPassword');
        let newPassword = nPassword.value.trim();
        const cnPassword = this.template.querySelector('.cnPassword');
        let confirmnewPassword = cnPassword.value.trim();
        if (confirmnewPassword.length > 0) {
            cnPassword.classList.remove('alert-border');
        }
        if(newPassword !== confirmnewPassword){
            if (confirmnewPassword.length > 0) {
             this.cnerrorMsg = 'Passwords do not match';
             cnPassword.classList.add('alert-border');
            }else{
                cnPassword.classList.remove('alert-border');
            }
        }
    }
    updatedPassword(){
        
        const cPassword = this.template.querySelector('.cPassword');
        let currentPassword = cPassword.value.trim();

        const nPassword = this.template.querySelector('.nPassword');
        let newPassword = nPassword.value.trim();

        const cnPassword = this.template.querySelector('.cnPassword');
        let confirmnewPassword = cnPassword.value.trim();
        if(currentPassword.length == 0){
            cPassword.classList.add('alert-border');
            this.cerrorMsg = 'Please enter the Current Password';
            return false;
        }
        if(newPassword.length == 0){
            nPassword.classList.add('alert-border');
            this.nerrorMsg = 'Please enter the New Password';
            return false;
        }
        if(currentPassword === newPassword){
            this.nerrorMsg = 'New Password cannot be the same as Current Password';
            nPassword.classList.add('alert-border');
            return false;
        }
        if (newPassword.length < 6) {
            this.nerrorMsg = 'Password does not meet complexity requirements';
            return false;
        }
        if(confirmnewPassword.length == 0){
            cnPassword.classList.add('alert-border');
            this.cnerrorMsg = 'Please enter the Confirm new Password';
            return false;
        }
        if(newPassword !== confirmnewPassword){
            this.cnerrorMsg = 'Passwords do not match';
            cnPassword.classList.add('alert-border');
            return false;
        }
        if((currentPassword.length > 0) && (newPassword.length > 0) && (confirmnewPassword.length > 0)){
            getUpdatePassword({ currentpassword: currentPassword, newpassword: newPassword})
            .then(result => {

                if(result == true){
                    this.successMsg = 'Your password has been changed successfully';
                    cPassword.value = '';
                    nPassword.value = '';
                    cnPassword.value = '';
                }
                else{
                    this.successMsg = 'Invalid Current Password';
                }
            
            })
            .catch(error => {
                this.error = error;
                console.log('accountLogoError: ' + JSON.stringify(this.error.status));
            });
        }
    }

}