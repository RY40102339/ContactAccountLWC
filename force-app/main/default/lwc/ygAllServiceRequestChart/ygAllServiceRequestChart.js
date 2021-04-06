import { LightningElement, track } from 'lwc';
import { loadScript } from "lightning/platformResourceLoader";
import YG_CustomerPortal from "@salesforce/resourceUrl/YG_CustomerPortal";
import getChartDetails from '@salesforce/apex/YG_AllServiceRequestController.getServiceRequestChartDetails';

export default class YgAllServiceRequestChart extends LightningElement {

    @track productData = [];
    @track systemData = [];
    @track inquiriesData = [];
    @track screenWidth;
    error;

    constructor() {
        super();
        this.screenWidth = window.innerWidth;

        getChartDetails()
            .then((result) => {
                this.productData = result.prodChartDataList;
                this.systemData = result.sysChartDataList;
                this.inquiriesData = result.inqChartDataList;

            }).then(() => {
                this.loadExternalLibraries();
            }).catch((error) => {
                this.error = error.body;
            });

    }

    async loadExternalLibraries() {

        loadScript(this, YG_CustomerPortal + '/YG_JS/d3.min.js').then(() => {
            loadScript(this, YG_CustomerPortal + '/YG_JS/d3pie.min.js').then(() => {

                this.productData && this.drawProduct();
                this.systemData && this.drawSystem();
                this.inquiriesData && this.drawinquiries();
            });
        });
    }

    drawProduct() {

        let charWidth, chartRadius;

        if (this.screenWidth >= 320 && this.screenWidth <= 400) {
            charWidth = this.screenWidth - 25;
            chartRadius = "35%";
        } else if (this.screenWidth >= 401 && this.screenWidth <= 450) {
            charWidth = this.screenWidth - 25;
            chartRadius = "45%";
        } else {
            charWidth = 400;
            chartRadius = "50%";
        }

        const titleElement = this.template.querySelector(".product");
        const productElement = this.template.querySelector(".product-chart");
        productElement.innerHTML = '';
        if (this.productData.length > 0) {
            productElement.classList.remove('d-none');
            titleElement.classList.remove('d-none');
        } else {
            productElement.classList.add('d-none');
            titleElement.classList.add('d-none');
        }

        var pie = new d3pie(productElement, {
            "size": {
                "canvasHeight": 400,
                "canvasWidth": charWidth,
                "pieInnerRadius": "50%",
                "pieOuterRadius": chartRadius
            },
            "data": {
                "sortOrder": "value-desc",
                "content": this.productData
            },
            "labels": {
                "outer": {
                    "pieDistance": 10
                },
                "inner": {
                    "format": "none"
                },
                "mainLabel": {
                    "color": "#313438",
                    "font": "Noto Sans, sans-serif",
                    "fontSize": 11
                },
                "percentage": {
                    "color": "#ffffff",
                    "decimalPlaces": 0
                },
                "value": {
                    "color": "#adadad",
                    "fontSize": 11
                },
                "lines": {
                    "enabled": true
                },
                "truncation": {
                    "enabled": false
                }
            },
            "effects": {
                "pullOutSegmentOnClick": {
                    "effect": "linear",
                    "speed": 400,
                    "size": 8
                },
                "highlightSegmentOnMouseover": false,
                "highlightLuminosity": -0.5
            },
            "misc": {
                "colors": {
                    "segmentStroke": ""
                },
                "gradient": {
                    "enabled": true,
                    "percentage": 100
                },
                "pieCenterOffset": {
                    "x": 1,
                    "y": -75
                }
            }
        });

    }

    drawSystem() {

        let charWidth, chartRadius;

        if (this.screenWidth >= 320 && this.screenWidth <= 400) {
            charWidth = this.screenWidth - 25;
            chartRadius = "35%";
        } else if (this.screenWidth >= 401 && this.screenWidth <= 450) {
            charWidth = this.screenWidth - 25;
            chartRadius = "45%";
        } else {
            charWidth = 400;
            chartRadius = "50%";
        }

        const titleElement = this.template.querySelector(".system");
        const systemElement = this.template.querySelector(".system-software-chart");
        systemElement.innerHTML = '';
        if (this.systemData.length > 0) {
            systemElement.classList.remove('d-none');
            titleElement.classList.remove('d-none');
        } else {
            systemElement.classList.add('d-none');
            titleElement.classList.add('d-none');
        }

        var pie = new d3pie(systemElement, {
            "size": {
                "canvasHeight": 400,
                "canvasWidth": charWidth,
                "pieInnerRadius": "50%",
                "pieOuterRadius": chartRadius
            },
            "data": {
                "sortOrder": "value-desc",
                "content": this.systemData
            },
            "labels": {
                "outer": {
                    "pieDistance": 10
                },
                "inner": {
                    "format": "none"
                },
                "mainLabel": {
                    "color": "#313438",
                    "font": "Noto Sans, sans-serif",
                    "fontSize": 11
                },
                "percentage": {
                    "color": "#ffffff",
                    "decimalPlaces": 0
                },
                "value": {
                    "color": "#adadad",
                    "fontSize": 11
                },
                "lines": {
                    "enabled": true
                },
                "truncation": {
                    "enabled": false
                }
            },
            "effects": {
                "pullOutSegmentOnClick": {
                    "effect": "linear",
                    "speed": 400,
                    "size": 8
                },
                "highlightSegmentOnMouseover": false,
                "highlightLuminosity": -0.5
            },
            "misc": {
                "colors": {
                    "segmentStroke": ""
                },
                "gradient": {
                    "enabled": true,
                    "percentage": 100
                },
                "pieCenterOffset": {
                    "x": 1,
                    "y": -75
                }
            }
        });

    }

    drawinquiries() {

        let charWidth, chartRadius;

        if (this.screenWidth >= 320 && this.screenWidth <= 400) {
            charWidth = this.screenWidth - 25;
            chartRadius = "35%";
        } else if (this.screenWidth >= 401 && this.screenWidth <= 450) {
            charWidth = this.screenWidth - 25;
            chartRadius = "45%";
        } else {
            charWidth = 400;
            chartRadius = "50%";
        }

        const titleElement = this.template.querySelector(".inquiry");
        const inquiryElement = this.template.querySelector(".inquiries-chart");
        inquiryElement.innerHTML = '';
        if (this.inquiriesData.length > 0) {
            inquiryElement.classList.remove('d-none');
            titleElement.classList.remove('d-none');
        } else {
            inquiryElement.classList.add('d-none');
            titleElement.classList.add('d-none');
        }


        var pie = new d3pie(inquiryElement, {

            "size": {
                "canvasHeight": 400,
                "canvasWidth": charWidth,
                "pieInnerRadius": "50%",
                "pieOuterRadius": chartRadius
            },
            "data": {
                "sortOrder": "value-desc",
                "content": this.inquiriesData
            },
            "labels": {
                "outer": {
                    "pieDistance": 10
                },
                "inner": {
                    "format": "none"
                },
                "mainLabel": {
                    "color": "#313438",
                    "font": "Noto Sans, sans-serif",
                    "fontSize": 11
                },
                "percentage": {
                    "color": "#ffffff",
                    "decimalPlaces": 0
                },
                "value": {
                    "color": "#adadad",
                    "fontSize": 11
                },
                "lines": {
                    "enabled": true
                },
                "truncation": {
                    "enabled": false
                }
            },
            "effects": {
                "pullOutSegmentOnClick": {
                    "effect": "linear",
                    "speed": 400,
                    "size": 8
                },
                "highlightSegmentOnMouseover": false,
                "highlightLuminosity": -0.5
            },
            "misc": {
                "colors": {
                    "segmentStroke": ""
                },
                "gradient": {
                    "enabled": true,
                    "percentage": 100
                },
                "pieCenterOffset": {
                    "x": 1,
                    "y": -75
                }
            }
        });

    }
}