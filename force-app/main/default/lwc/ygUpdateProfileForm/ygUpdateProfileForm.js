import { LightningElement, wire, track } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import YG_CustomerPortal from '@salesforce/resourceUrl/YG_CustomerPortal';
import getContactDetails from '@salesforce/apex/YG_UpdateProfileController.getContactDetails';
import updateContactData from '@salesforce/apex/YG_UpdateProfileController.updateContactData';
import emailValidate from '@salesforce/apex/YG_UpdateProfileController.emailValidate';
import getUserRole from '@salesforce/apex/YG_LoggedUserRoleController.getNotifyUserRole';
import { fireEvent } from 'c/pubSub';
import UploadImageFormatErrorLbl from '@salesforce/label/c.YG_UploadImageFormatError_Msg';
import UploadImageSizeErrorLbl from '@salesforce/label/c.YG_UploadImageSizeError_Msg';
import closeLbl from '@salesforce/label/c.YG_Close';

const columns = [
  { label: 'Title', fieldName: 'Title' }
];

export default class YgUpdateProfileForm extends LightningElement {

  @wire(CurrentPageReference) pageRef;
  @track isModalOpen = false;
  plantInfoarray = [];
  firstPlantval;
  initialplant = true;
  updateContact = {};
  saveBtn = "SAVE";
  prePopContact = {};
  userRole = "";
  userRoleFlag = false;
  @track columns = columns;
  @track data;
  @track UploadFile = 'Upload File';
  @track isTrue = false;
  selectedRecords;
  filesUploaded = [];
  file;
  fileContents;
  fileReader;
  content;
  MAX_FILE_SIZE = 2621440;//allow upto 2.5MB
  @track profileImg;
  @track proceed;
  @track existEmail;
  @track newEmail;
  @track confirmModalOpen = false;
  @track emailText;

  label = {
    closeLbl, UploadImageFormatErrorLbl, UploadImageSizeErrorLbl
  };


  constructor() {

    super();
    getUserRole().then(result => {

      console.log("getUserRole ==> " + JSON.stringify(result));

      if (result.role == 'Customer Admin') {
        this.userRoleFlag = true;
        this.userRole = "Admin";
      } else if (result.role == 'Super Admin') {
        this.userRoleFlag = true;
        this.userRole = "Super Admin";
      } else {
        this.userRoleFlag = false;
      }
    }).then(() => {
      this.getProfileDetails();
    }).catch(error => {
      console.log('Error: ' + JSON.stringify(error));
    });
  }

  renderedCallback() {
    if (this.userRoleFlag === false) {
      const updateElement = this.template.querySelector(".section-update-profile");
      $('.profile-image__content', updateElement).removeClass('profile-image__content').addClass('profile-image__nocontent');
    }
  }

  triggerFile(event) {
    const updateElement = this.template.querySelector(".section-update-profile");
    $('.fileUpload', updateElement).click();
  }

  getProfileDetails() {
    getContactDetails()
      .then(result => {

        fireEvent(this.pageRef, 'updateProfile', '');

        console.log("getContactDetails ==> " + JSON.stringify(result));
        if (result.Profile_Image__c != "") {
          this.profileImg = result.Profile_Image__c;
        } else {
          this.profileImg = YG_CustomerPortal + '/YG_Images/icons/profile.svg';
        }
        this.prePopContact = result;
      })
      .catch(error => {
        console.log('error getContactDetails :: ' + JSON.stringify(error.message));
      })
  }

  getProfileInfo(event) {
    let fieldName = event.target.dataset.id;
    let fieldValue;

    if (fieldName == "FirstName" || fieldName == "LastName" || fieldName == "Phone" || fieldName == "Email") {
      fieldValue = event.target.value;
    } else {
      fieldValue = event.target.checked;
    }

    this.updateContact["Id"] = this.prePopContact.Id;
    this.updateContact[fieldName] = fieldValue;
  }

  updateContactData(event) {
    const updateElement = this.template.querySelector(".section-update-profile");
    $('.btn.btn-primary', updateElement).html('<div class="spinner-border spinner-border-sm text-white" role="status"><span class="sr-only">Loading...</span></div>');

    if ($("input[name=fName]", updateElement).val() == "") {
      $(".fname-err", updateElement).addClass('has-error').html('First name field is required.');
      $("input[name=fName]", updateElement).addClass('alert-border');
    } else {
      $(".fname-err", updateElement).removeClass('has-error').html('');
      $("input[name=fName]", updateElement).removeClass('alert-border');
    }

    if ($("input[name=lName]", updateElement).val() == "") {
      $(".lname-err", updateElement).addClass('has-error').html('Last name field is required.');
      $("input[name=lName]", updateElement).addClass('alert-border');
    } else {
      $(".lname-err", updateElement).removeClass('has-error').html('');
      $("input[name=lName]", updateElement).removeClass('alert-border');
    }

    let regxEmail = /^([A-Za-z0-9_\-\.])+\@([A-Za-z0-9_\-\.])+\.([A-Za-z]{2,4})$/;
    if ($("input[name=wEmail]", updateElement).val() == "") {
      $(".wemail-err", updateElement).addClass('has-error').html('Work email field is required.');
      $("input[name=wEmail]", updateElement).addClass('alert-border');
    } else if (regxEmail.test($("input[name=wEmail]", updateElement).val()) == false) {
      $(".wemail-err", updateElement).addClass('has-error').html('Work email address is not valid.');
      $("input[name=wEmail]", updateElement).addClass('alert-border');
    } else {

      if ($("input[name=wEmail]", updateElement).val() != "") {

        emailValidate({ email: $("input[name=wEmail]", updateElement).val() })
          .then(result => {

            this.existEmail = result.exist;
            this.newEmail = result.newemail;
            this.emailText = result.newemailid;

            console.log('emailValidate:: ' + JSON.stringify(result));
            //Check already email id exist

            if (result.exist === true) {
              $(".wemail-err", updateElement).addClass('has-error').html('Email already exists');
              $("input[name=wEmail]", updateElement).addClass('alert-border');
              this.proceed = false;
            } else {
              $(".wemail-err", updateElement).removeClass('has-error').html('');
              $("input[name=wEmail]", updateElement).removeClass('alert-border');
              this.proceed = true;
            }
          }).catch(error => {
            console.log('error:: ' + JSON.stringify(error));
          })
      }
    }

    let regxNumber = /^\d+$/;
    if ($("input[name=phoneNo]", updateElement).val() == "") {
      $(".phone-err", updateElement).addClass('has-error').html('Phone no field is required.');
      $("input[name=phoneNo]", updateElement).addClass('alert-border');
    } else if (regxNumber.test($("input[name=phoneNo]", updateElement).val()) == false) {
      //display error message
      $(".phone-err", updateElement).addClass('has-error').html('Digits only allowed.');
      $("input[name=phoneNo]", updateElement).addClass('alert-border');
    } else {
      $(".phone-err", updateElement).removeClass('has-error').html('');
      $("input[name=phoneNo]", updateElement).removeClass('alert-border');
    }

    //const alertElement = this.template.querySelectorAll('.alert-orange');
    if ($('.alert-orange', updateElement).hasClass("has-error")) {
      $('.btn.btn-primary', updateElement).html('SAVE');
      const errorElement = this.template.querySelector('.has-error');
      $('input.alert-border', updateElement).eq(0).focus();
      $('html, body').animate({
        scrollTop: $(errorElement).first().offset().top - 100
      }, 1000);
    } else {

      setTimeout(() => {
        if (this.existEmail === false && this.newEmail === true) {
          //popup
          this.confirmModalOpen = true;
        }
        if (this.filesUploaded.length > 0) {
          this.uploadHelper();
        } else {
          if (this.proceed === true) {

            console.log('this.updateContact' + JSON.stringify(this.updateContact))
            updateContactData({ cont: this.updateContact, strFileName: null, base64Data: null })
              .then(result => {

                console.log('updateContactData:: ' + result);
                setTimeout(() => {
                  this.getProfileDetails();
                }, 5000);
                //this.saveBtn = "SAVED";           

              }).then(() => {
                let svgImage = '<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">';
                svgImage += '<path d="M6 12L10.5 15L16.5 6" stroke="white" stroke-width="2"/></svg>';

                $('.btn.btn-primary', updateElement).attr('disabled', 'disabled').html(svgImage + "SAVED");
                setTimeout(() => {
                  $('.btn.btn-primary', updateElement).attr('disabled', false).html("SAVE");
                }, 5000);

              }).catch(error => {
                console.log('error:: ' + JSON.stringify(error));
              })
          } else {
            $('.btn.btn-primary', updateElement).attr('disabled', false).html("SAVE");
          }
        }
      }, 1000);
    }
  }

  hideError(event) {
    let targetField = event.currentTarget.name;
    const updateElement = this.template.querySelector(".section-update-profile");
    $('.btn.btn-primary', updateElement).removeAttr('disabled', 'disabled').html('SAVE');
    $("input[name=" + targetField + "]", updateElement).removeClass('alert-border').next('.has-error').html('');
  }

  // getting file 
  handleFilesChange(event) {
    if (event.target.files.length > 0) {
      const updateElement = this.template.querySelector(".section-update-profile");
      this.filesUploaded = event.target.files;
      this.updateContact["Id"] = this.prePopContact.Id;

      let Extension = event.target.files[0].name.split('.').pop();
      Extension = Extension.toLowerCase();

      let ext = ["png", "jpeg", "jpg"];

      if (ext.includes(Extension) === false) {
        $('.msg', updateElement).html(this.label.UploadImageFormatErrorLbl);
      } else {
        $('.msg', updateElement).html(event.target.files[0].name);
      }
    }
  }

  async uploadHelper() {

    this.file = this.filesUploaded[0];
    let Extension = this.file.name.split('.').pop();
    Extension = Extension.toLowerCase();
    const pageTop = this.template.querySelector('.section-update-profile');

    console.log('Extension!!' + Extension)
    let ext = ["png", "jpeg", "jpg"];

    if (ext.includes(Extension) === false) {
      $('.msg', pageTop).html(this.label.UploadImageFormatErrorLbl);
      $('.btn.btn-primary', pageTop).attr('disabled', false).html("SAVE");
      $('html, body').animate({
        scrollTop: $(pageTop).first().offset().top - 100
      }, 1000);
      return false;
    }

    if (this.file.size > this.MAX_FILE_SIZE) {
      $('.msg', pageTop).html(this.label.UploadImageSizeErrorLbl);
      $('html, body').animate({
        scrollTop: $(pageTop).first().offset().top - 100
      }, 1000);
      $('.btn.btn-primary', pageTop).attr('disabled', false).html("SAVE");
      return false;
    }

    // create a FileReader object 
    this.fileReader = new FileReader();
    // set onload function of FileReader object  
    this.fileReader.onloadend = (() => {
      this.fileContents = this.fileReader.result;
      let base64 = 'base64,';
      this.content = this.fileContents.indexOf(base64) + base64.length;
      this.fileContents = this.fileContents.substring(this.content);

      // call the uploadProcess method 
      this.saveToFile();
    });

    this.fileReader.readAsDataURL(this.file);
  }

  // Calling apex class to insert the file
  saveToFile() {
    const updateElement = this.template.querySelector(".section-update-profile");
    updateContactData({ cont: this.updateContact, strFileName: this.file.name, base64Data: encodeURIComponent(this.fileContents) })
      .then(result => {
        if (result) {
          setTimeout(() => {
            this.getProfileDetails();
          }, 5000);
        }
      }).then(() => {
        $('.msg', updateElement).html('');
        let svgImage = '<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">';
        svgImage += '<path d="M6 12L10.5 15L16.5 6" stroke="white" stroke-width="2"/></svg>';

        $('.btn.btn-primary', updateElement).attr('disabled', 'disabled').html(svgImage + "SAVED");
        setTimeout(() => {
          $('.btn.btn-primary', updateElement).attr('disabled', false).html("SAVE");
        }, 5000);

      }).catch(error => {
        console.log('error saveToFile :: ' + JSON.stringify(error));
      })
  }

  closeModal() {
    this.confirmModalOpen = false;
  }
}