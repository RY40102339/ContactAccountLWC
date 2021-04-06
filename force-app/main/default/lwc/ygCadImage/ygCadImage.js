import { LightningElement, track, wire } from 'lwc';
import getImageUrl from '@salesforce/apex/YG_CadImageController.getImageUrl';
import closeLbl from '@salesforce/label/c.YG_Close';
import { CurrentPageReference } from "lightning/navigation";

export default class YgCadImage extends LightningElement {

    @wire(CurrentPageReference) pageRef;
    label = {
        closeLbl
    };
    error;
    firstImg;
    imgName;
    imgURLs = [];
    className;
    //Boolean tracked variable to indicate if modal is open or not default value is false as modal is closed when page is loaded 
    @track isModalOpen = false;
    modelCodes;
    serial; pageName;

    constructor() {
        super();

        let pageURL = window.location.href.split('?')[0];
        this.allProdURL = pageURL;
        let pagePath = window.location.pathname;
        let pageName;
        pageName = pagePath.substr(3);

        let fullStr = window.location.search.substring(1);
        let splitStr = fullStr.split("&");
        let srlNo = '';
        let modCodeNo = '';
        for (var i = 0; i < splitStr.length; i++) {
            var pair = splitStr[i].split("=");
            if (pair[0] == 'serialno') {
                srlNo = pair[1];
                this.serial = pair[1];
                this.pageName = pageName;
            }
            if (pair[0] == 'modcode') {
                modCodeNo = pair[1];
                this.modelCodes = pair[1];
                this.pageName = pageName;
            }
        }

        if (pageName === 'product-details') {
            getImageUrl({ modelCode: modCodeNo, serialNo: '' })
                .then(result => {
                    console.log('res img::' + JSON.stringify(result))

                    if (result.imgUrl.length == 0) {
                        this.template.querySelector('.row').classList.add('mHidden', 'invisible');
                    } else {

                        this.imgName = result.prodName;
                        this.firstImg = result.imgUrl[0];
                        let activeClass;
                        this.className = 'actual-img';

                        for (let key in result.imgUrl) {
                            //alert(result.imgUrl[key]);
                            activeClass = (key == 0) ? 'active' : '';
                            this.imgURLs.push({ value: result.imgUrl[key], key: key, className: activeClass });
                        }
                    }

                }).catch(error => {
                    this.error = error;
                    console.log('Img error: ' + JSON.stringify(this.error));
                });
        }
    }

    swapImage(event) {

        const pageIndicators = this.template.querySelectorAll('.page-carousel-ind li');
        const largeImg = this.template.querySelector('.large-img img');
        $(pageIndicators).removeClass('active');
        event.currentTarget.classList.add('active');
        $(largeImg).attr('src', event.currentTarget.dataset.img);
    }

    swapImageModel(event) {

        const modelIndicators = this.template.querySelectorAll('.page-carousel-modal li');
        const largeImgModel = this.template.querySelector('.large-img-model img');
        $(modelIndicators).removeClass('active');
        event.currentTarget.classList.add('active');
        $(largeImgModel).attr('src', event.currentTarget.dataset.img);
    }

    openModal() {
        // to open modal set isModalOpen tarck value as true
        this.isModalOpen = true;
    }

    closeModal() {
        // to close modal set isModalOpen tarck value as false
        this.isModalOpen = false;
    }
}