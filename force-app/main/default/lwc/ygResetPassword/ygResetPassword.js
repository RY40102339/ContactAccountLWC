import { LightningElement } from 'lwc';
import YG_CustomerPortal from '@salesforce/resourceUrl/YG_CustomerPortal';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import getCommunityURL from '@salesforce/apex/YG_Utility.getCommunityURL';
import getResetPassword from '@salesforce/apex/YG_ResetPasswordCDCAPI.getResetPassword'

export default class YgResetPassword extends LightningElement {

    yoklogo = YG_CustomerPortal + '/YG_Images/yok-logo.svg';
    macbook = YG_CustomerPortal + '/YG_Images/macbook.svg';
    iphone = YG_CustomerPortal + '/YG_Images/iphone.svg';
    communityURL;
    resetThankYou;

    constructor() {
        super();
        getCommunityURL({})
            .then(result => {
                this.communityURL = result;
                this.resetThankYou = this.communityURL + 'reset-thank-you';
            }).catch(error => {
                this.error = error;
                console.log('communityURL: ' + JSON.stringify(this.error));
            });
    }

    connectedCallback() {
        Promise.all([
            loadStyle(this, YG_CustomerPortal + '/YG_CSS/common.css'),
            loadStyle(this, YG_CustomerPortal + '/YG_CSS/style.css'),
            loadScript(this, YG_CustomerPortal + '/YG_JS/jquery.min.js')
        ])
    }

    renderedCallback() {
        document.getElementsByTagName("BODY")[0].classList.add('pt-0', 'full-width');
    }

    submitReset(event) {

        const formSection = this.template.querySelector(".form-section");

        if ($("input[name=newPassword]", formSection).val() == "") {
            $("input[name=newPassword]", formSection).addClass('alert-border');
            $(".newPassword-err", formSection).html("New Password field is required.");
        }

        if ($("input[name=confirmPassword]", formSection).val() == "") {
            $("input[name=confirmPassword]", formSection).addClass('alert-border');
            $(".confirmPassword-err", formSection).html("Confirm Password field is required.");
        }

        if ($("input[name=newPassword]", formSection).val() != "" &&
            $("input[name=confirmPassword]", formSection).val() != "") {

            if ($("input[name=newPassword]", formSection).val() !==
                $("input[name=confirmPassword]", formSection).val()) {

                $("input[name=confirmPassword]", formSection).addClass('alert-border');
                $(".confirmPassword-err", formSection).html("Enter the same password as above.");
            }
            else {

                let query = this.getQueryParams(document.location.search);
                getResetPassword({ pswrdResetToken: query.pwrt, newPswrd: $("input[name=newPassword]", formSection).val() })
                    .then(result => {

                        console.log("Reset result ==> " + result);
                        if (result === true) {
                            window.location.href = this.resetThankYou;
                        }
                    }).catch(error => {
                        this.error = error;
                        console.log('Reset Password: ' + JSON.stringify(this.error));
                    });
            }
        }
    }

    hideError(event) {

        let targetField = event.currentTarget.name;
        const formSection = this.template.querySelector(".form-section");

        $("input[name=" + targetField + "]", formSection).removeClass('alert-border').next('.alert-orange').html('');
    }

    getQueryParams(qs) {
        qs = qs.split('+').join(' ');

        var params = {},
            tokens,
            re = /[?&]?([^=]+)=([^&]*)/g;

        while (tokens = re.exec(qs)) {
            params[decodeURIComponent(tokens[1])] = decodeURIComponent(tokens[2]);
        }

        return params;
    }

    handleKeyPress(event) {

        let iKeyCode = (event.which) ? event.which : event.keyCode;
        if (iKeyCode == 13) {
            this.submitReset();
        }
    }
}