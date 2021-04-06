import { LightningElement, wire, track } from 'lwc';
import getCaseOverviewDetails from '@salesforce/apex/YG_OverviewGridController.getCaseOverviewDetails';
import getCustomConfig from '@salesforce/apex/YG_Utility.getCustomConfig';
import getCommunityURL from '@salesforce/apex/YG_Utility.getCommunityURL';
import getServiceReqInfo from '@salesforce/apex/YG_AllServiceRequestController.getServiceReqInfo';
import getCaseHistory from '@salesforce/apex/YG_AllServiceRequestController.getCaseHistory';
import getYourDetails from '@salesforce/apex/YG_ServiceRequestAndInquiries.getYourDetails';
import { CurrentPageReference } from 'lightning/navigation';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import { registerListener, unregisterAllListeners } from 'c/pubSub';
import YG_CustomerPortal from '@salesforce/resourceUrl/YG_CustomerPortal';
import yourDetailsLbl from '@salesforce/label/c.YG_Your_Details';
import nameLbl from '@salesforce/label/c.YG_Name';
import titleLbl from '@salesforce/label/c.YG_Title';
import conNoLbl from '@salesforce/label/c.YG_Contact_No';
import plantLbl from '@salesforce/label/c.YG_Plant';
import addressLbl from '@salesforce/label/c.YG_Address';
import subject from '@salesforce/label/c.YG_Subject';
import submitdate from '@salesforce/label/c.YG_Submit_Date';
import products from '@salesforce/label/c.YG_Products';
import servicetype from '@salesforce/label/c.YG_Service_Type';
import progress from '@salesforce/label/c.YG_Progress';
import reason from '@salesforce/label/c.YG_Type';
import showLbl from '@salesforce/label/c.YG_Show';
import moreLbl from '@salesforce/label/c.YG_More';
import statusLbl from '@salesforce/label/c.YG_Status';
import loadingLbl from '@salesforce/label/c.YG_Loading';
import activeReqLbl from '@salesforce/label/c.YG_Active_Service_Requests_and_Inquiries';
import reqHisLbl from '@salesforce/label/c.YG_View_All_Request_History';
import productsLbl from '@salesforce/label/c.YG_Products';
import systemsLbl from '@salesforce/label/c.YG_Systems';
import inquiriesLbl from '@salesforce/label/c.YG_Inquiries';
import newReqLbl from '@salesforce/label/c.YG_Submit_New_Request';
import inProgLbl from '@salesforce/label/c.YG_In_Progress';
import prodModLbl from '@salesforce/label/c.YG_Product_Module';
import viewDetLbl from '@salesforce/label/c.YG_View_details';
import caseNumLbl from '@salesforce/label/c.YG_Case_Number';
import serialNoLbl from '@salesforce/label/c.YG_Serial_number';
import servTypeLbl from '@salesforce/label/c.YG_Service_Type';
import lcaLbl from '@salesforce/label/c.YG_LCA';
import dateSubLbl from '@salesforce/label/c.YG_DateSubmitted';
import subByLbl from '@salesforce/label/c.YG_Submitted_by';
import notesLbl from '@salesforce/label/c.YG_Notes';
import editNoteLbl from '@salesforce/label/c.YG_Edit_notes';
import updateLbl from '@salesforce/label/c.YG_Update';
import typeStatLbl from '@salesforce/label/c.YG_Type_Status';
import assigToLbl from '@salesforce/label/c.YG_Assigned_to';
import contractLbl from '@salesforce/label/c.YG_Contract';

export default class ygOverviewGrid extends LightningElement {

	@wire(CurrentPageReference) pageRef;
	@track isLoading = true;
	@track mapData = [];
	@track screenWidth;
	allservicerequestURL;
	serandinqURL;
	gridData = [];
	chartData = [];
	showServReqInqData = false;
	showLoadMore = false;
	showLess = false;
	btnactive = '';
	selectedBtn = '';
	totalCaseCnt = 0;
	totalproductCnt = 0; productBtn = false;
	totalSystemCnt = 0; systemBtn = false;
	totalInqCnt = 0; inquiryBtn = false;
	loadExternal = false;
	remainRecords = 0;
	recordLoadLimit = 0;
	offset = 0;
	loadedRecord = 0;
	error;
	totalrecsize = 0;
	showContractType = false;

	label = {
		subject, submitdate, products, servicetype, progress, reason, showLbl, moreLbl, yourDetailsLbl, nameLbl, titleLbl,
		conNoLbl, plantLbl, addressLbl, statusLbl, loadingLbl, activeReqLbl, reqHisLbl, productsLbl, systemsLbl, inquiriesLbl,
		newReqLbl, inProgLbl, prodModLbl, viewDetLbl, caseNumLbl, serialNoLbl, servTypeLbl, contractLbl,
		lcaLbl, dateSubLbl, subByLbl, notesLbl, editNoteLbl, updateLbl, typeStatLbl, assigToLbl
	};

	//Boolean tracked variable to indicate if modal is open or not default value is false as modal is closed when page is loaded 
	@track isModalOpen = false;
	@track hideLink = false;
	caseDetails = {}; yourData = {};
	caseHisData = [];
	viewDetURL = '';
	plantCode = '';


	constructor() {
		super();
		this.screenWidth = window.innerWidth;

		//this.loadExternalLibraries();

		getCustomConfig()
			.then(result => {
				var conts = result;
				for (var key in conts) {
					this.mapData.push({ value: conts[key], key: key });
					if (key == "Overview Load More Record Limit") {
						let val = conts[key];
						this.recordLoadLimit = parseInt(val.Text_1__c);
					}
				}
				console.log('this.recordLoadLimit==>' + this.recordLoadLimit);
			}).then(() => {
				getCommunityURL({})
					.then(result => {
						this.communityURL = result;
						window.console.log("communityURL::" + JSON.stringify(this.communityURL));
						this.allservicerequestURL = this.communityURL + 'allservicerequest';
						this.serandinqURL = this.communityURL + 'service-request-and-inquiries';

					}).catch(error => {
						this.error = error;
						console.log('Error: ' + JSON.stringify(this.error));
					});
			}).then(() => {
				this.getOverviewCaseData('');
			}).catch(error => {
				this.error = error.message;
				console.log('communityURL: ' + JSON.stringify(this.error));
			});
	}

	connectedCallback() {
		//registerListener("plantFilter", this.getOverviewCaseData, this);
		registerListener('selfRegister', this.checkSelfReg, this);
	}

	disconnectedCallback() {
		unregisterAllListeners(this);
	}

	checkSelfReg(param) {

		if (param === true) {

			//this.showServReqInqData = false;
			//this.isLoading = false;
			setTimeout(() => {
				this.template.querySelector('.row.mt-14-lt').style.marginTop = "15.5rem";
			}, 2000);
		}
	}

	getOverviewCaseData(plantCode) {

		this.plantCode = plantCode;
		this.gridData = [];
		this.chartData = [];
		this.showServReqInqData = true;
		this.offset = 0;
		this.totalrecsize = 0;
		this.showLoadMore = false;
		this.showLess = false;

		getCaseOverviewDetails({ plantCode: this.plantCode, catType: '', recordLimit: this.recordLoadLimit, offset: 0 })
			.then(result => {

				this.totalCaseCnt = result.totalCaseCnt;
				this.totalproductCnt = result.prodCaseCnt;
				this.totalSystemCnt = result.sysCaseCnt;
				this.totalInqCnt = result.inqCaseCnt;

				if (result.totalCaseCnt > 0) {
					this.showServReqInqData = true;
				} else {
					this.template.querySelector(".chart-section").classList.add('d-none');
				}

				if (result.prodCaseCnt > 0) {
					this.productBtn = true;
				}
				if (result.sysCaseCnt > 0) {
					this.systemBtn = true;
				}
				if (result.inqCaseCnt > 0) {
					this.inquiryBtn = true;
				}
				this.totalrecsize = result.activeBtnSize;
				this.selectedBtn = result.activeBtn;
				this.btnactive = result.activeBtn;
				this.gridData = result.caseDataList;
				this.chartData = result.caseChartList;

				this.loadedRecord = result.caseDataList.length;
				this.remainRecords = this.totalrecsize - this.loadedRecord;
				if (this.loadedRecord < this.totalrecsize) {
					this.showLoadMore = true;
					if (this.remainRecords < this.recordLoadLimit) {
						this.remainRecords = this.remainRecords;
					} else {
						this.remainRecords = this.recordLoadLimit;
					}
				} else {
					this.showLoadMore = false;
				}

				if (this.loadExternal === true) {
					const table = this.template.querySelector('.overview-dtTable');
					$(table).DataTable().destroy();
				}

			}).then(() => {
				this.loadPiechart();
			})
			.then(() => {
				this.loadExternalLibraries();
				this.loadExternal = true;
				this.isLoading = false;
			})
			.then(() => {
				this.highlightBtn();
			})
			.catch(error => {
				this.isLoading = false;
				this.error = error;
				console.log('Error: ' + JSON.stringify(error));
			});
	}

	highlightBtn() {
		setTimeout(() => {
			const btnSection = this.template.querySelector('.section-overview-buttons');
			$('button', btnSection).removeClass('active').attr('aria-pressed', false);
			$('button', btnSection).eq(0).addClass('active').attr('aria-pressed', true);
		}, 500);
	}

	async loadExternalLibraries() {

		loadScript(this, YG_CustomerPortal + '/YG_JS/jquery.min.js').then(() => {
			loadStyle(this, YG_CustomerPortal + '/YG_CSS/dataTables.css').then(() => {
				loadScript(this, YG_CustomerPortal + '/YG_JS/jquery.dataTables.min.js').then(() => {
					const table = this.template.querySelector('.overview-dtTable');
					if (this.selectedBtn === 'Inquiry' || this.btnactive === 'Inquiry') {
						let dataTable;
						//const table = this.template.querySelector('.overview-dtTable');
						const columnHeaders = ['' + this.label.submitdate + '/' + this.label.subject + '', '' + 'Type' + '/' + this.label.statusLbl + ''];
						let columnHeaderHtml = '<thead><tr>';
						columnHeaders.forEach(function (header) {
							columnHeaderHtml += '<th><span class="font-weight-normal">' + header + '</span></th>';
						});
						columnHeaderHtml += '</tr></thead>';
						table.innerHTML = columnHeaderHtml;
						dataTable = $(table).DataTable({
							"paging": false,
							"searching": true, // false to disable search (or any other option)
							"info": false,
							"order": [0, 'desc'],
							"oSearch": {
								"bSmart": false
							},
							"columnDefs": [{
								orderable: false,
								targets: []
							}],
							"language": {
								"emptyTable": "No active request and inquires."
							},
							// Per-row function to iterate cells
							"createdRow": function (row, data, rowIndex) {
								// Per-cell function to do whatever needed with cells
								$.each($('td', row), function (colIndex) {
									// For example, adding data-* attributes to the cell
									if (columnHeaders[colIndex] === "Status") {
										$(this).addClass("mHidden");
									}
									$(this).attr('data-title', columnHeaders[colIndex]);
								});
							}
						});
						let prod;
						this.gridData.forEach(function (list) {

							prod = '';
							if (list.product == '') {
								prod = list.subject;
							} else {
								prod = list.product;
							}

							dataTable.row.add([
								'<strong>' + list.submitDate + '</strong>' + '<div class="pdf-doc f14">' + prod + '</div>',
								'<strong>' + list.reason + '</strong>' + '<a class="d-block text-hover-color" data-id=' + list.caseId + ' href="javascript:void(0)"><ins>' + list.progress + '</ins></a>'
							]);
						})
						dataTable.draw();
					} else {
						let dataTable;
						let typeStatLbl = this.label.typeStatLbl;
						const columnHeaders = ['' + this.label.submitdate + '/' + this.label.products + '', '' + this.label.servicetype + '', this.label.statusLbl];
						let columnHeaderHtml = '<thead><tr>';
						columnHeaders.forEach(function (header, index) {
							if (index === 0) {
								columnHeaderHtml += '<th><span class="font-weight-normal">' + header + '</span></th>';
							} else if (index === 1) {
								columnHeaderHtml += '<th><span class="font-weight-normal mHidden">' + header + '</span><span class="font-weight-normal d-sm-none">' + typeStatLbl + '</span></th>';
							} else {
								columnHeaderHtml += '<th><span class="font-weight-normal mHidden">' + header + '</span></th>';
							}
							//columnHeaderHtml += '<th><span class="font-weight-normal mHidden">' + header + '</span></th>';
						});
						columnHeaderHtml += '</tr></thead>';
						table.innerHTML = columnHeaderHtml;
						dataTable = $(table).DataTable({
							"paging": false,
							"searching": true, // false to disable search (or any other option)
							"info": false,
							"order": [0, 'desc'],
							"oSearch": {
								"bSmart": false
							},
							"columnDefs": [{
								orderable: false,
								targets: 2
							}],
							"language": {
								"emptyTable": "No active request and inquires."
							},
							// Per-row function to iterate cells
							"createdRow": function (row, data, rowIndex) {
								// Per-cell function to do whatever needed with cells
								$.each($('td', row), function (colIndex) {
									// For example, adding data-* attributes to the cell
									if (columnHeaders[colIndex] === "Status") {
										$(this).addClass("mHidden");
									}
									$(this).attr('data-title', columnHeaders[colIndex]);
								});
							}
						});
						let progress, prod;
						this.gridData.forEach(function (list) {
							progress = '';
							if (list.progress == '-') {
								progress = '<span class="d-none d-sm-block">-</span>';
							} else {
								progress = '<a class="text-hover-color" data-id=' + list.caseId + ' href="javascript:void(0)"><ins>' + list.progress + '</ins></a>';
							}

							prod = '';
							if (list.product == '') {
								prod = list.subject;
							} else {
								prod = list.product;
							}

							dataTable.row.add([
								'<div class="font-weight-normal d-none d-sm-block"><strong>' + list.submitDate + '</strong><br>' + prod + '</div><div class="d-sm-none"><strong>' + list.submitDate + '</strong><br>' + prod + '</div>',
								'<div class="font-weight-normal d-none d-sm-block">' + list.serviceType + '</div><div class="d-sm-none"><strong>' + list.serviceType + '</strong><br>' + progress + '</div>',
								'<span class="d-none d-sm-block">' + progress + '</span>'
							]);
						})
						dataTable.draw();
					}

					const tableField = this.template.querySelector('.table-responsive');
					const triggerClick = this.template.querySelector('.triggerClick');
					$('tbody', table).on('click', 'td a', function () {
						$('input[name=hiddenSelect]', tableField).val($(this).attr('data-id'));
						triggerClick.click();
					});

				})
			})
		})
	}

	//To trigger the pop window
	triggetSelect() {
		this.openModal();
	}

	filterGrid(event) {
		const btnSection = this.template.querySelector('.section-overview-buttons');
		$('button', btnSection).removeClass('active').attr('aria-pressed', false);
		event.currentTarget.classList.add('active');
		$('button.active', btnSection).attr('aria-pressed', true);
		this.selectedBtn = event.currentTarget.value;
		this.getActiveButtonData();
	}

	//To display the Chart
	async loadPiechart() {
		loadScript(this, YG_CustomerPortal + '/YG_JS/d3.min.js').then(() => {
			loadScript(this, YG_CustomerPortal + '/YG_JS/d3pie.min.js').then(() => {
				//Call the charting method when all the dependent javascript libraries are loaded.
				this.drawChart();
			});
		});
	}

	//To draw the Chart
	drawChart() {
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
		const myChart = this.template.querySelector(".pieChart");
		myChart.innerHTML = '';
		if (this.chartData.length > 0) {
			myChart.classList.remove('d-none');
		} else {
			myChart.classList.add('d-none');
		}
		const content = [];
		if (this.chartData !== undefined) {
			this.chartData.map((item, index) => {
				let obj = {};
				obj["label"] = item.serviceType + ": " + item.serviceTypeCount;
				obj["value"] = item.serviceTypeCount;
				obj["color"] = item.colorcode;
				content.push(obj);
			})
		}
		myChart.innerHTML = '';
		var pie = new d3pie(myChart, {
			"size": {
				"canvasHeight": 400,
				"canvasWidth": charWidth,
				"pieInnerRadius": "50%",
				"pieOuterRadius": chartRadius
			},
			"data": {
				"sortOrder": "value-desc",
				content
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

	getActiveButtonData() {

		//this.template.querySelector('.loading-icon').classList.remove('d-none');
		this.gridData = [];
		this.chartData = [];
		this.loadExternal = true;
		this.showServReqInqData = true;
		this.offset = 0;
		this.totalrecsize = 0;
		this.showLoadMore = false;
		this.showLess = false;

		getCaseOverviewDetails({ plantCode: this.plantCode, catType: this.selectedBtn, recordLimit: this.recordLoadLimit, offset: 0 })
			.then((result) => {

				this.gridData = result.caseDataList;
				this.chartData = result.caseChartList;
				this.totalrecsize = result.activeBtnSize;
				this.loadedRecord = result.caseDataList.length;
				this.remainRecords = this.totalrecsize - this.loadedRecord;
				if (this.loadedRecord < this.totalrecsize) {
					this.showLoadMore = true;
					if (this.remainRecords < this.recordLoadLimit) {
						this.remainRecords = this.remainRecords;
					} else {
						this.remainRecords = this.recordLoadLimit;
					}
				} else {
					this.showLoadMore = false;
				}

				if (this.loadExternal === true) {
					const table = this.template.querySelector('.overview-dtTable');
					$(table).DataTable().destroy();
				}

			}).then(() => {
				this.loadPiechart();
			}).then(() => {
				this.drawChart();
			}).then(() => {
				this.loadExternalLibraries();
				this.loadExternal = true;
			}).catch((error) => {
				this.error = error.body;
			});
	}

	//To open the pop window
	openModal() {

		const tableField = this.template.querySelector('.table-responsive');
		this.isModalOpen = true;
		this.hideLink = false;
		this.caseDetails = {};
		this.caseHisData = [];
		this.yourData = {};

		let caseId = $('input[name=hiddenSelect]', tableField).val();
		console.log('caseId:::' + caseId);

		getServiceReqInfo({ caseNo: caseId })
			.then(result => {

				if (result.contractType.length > 0) {
					this.showContractType = true;
					this.caseDetails = result;
				} else {
					this.showContractType = false;
					this.caseDetails = result;
				}
				if (result.modelCode != '') {
					this.hideLink = true;
					this.viewDetURL = this.communityURL + 'product-details?modcode=' + result.modelCode;
				} else {
					this.hideLink = false;
				}

			}).catch(error => {
				this.error = error;
				console.log('modelWindow Error: ' + JSON.stringify(this.error));
			});

		getCaseHistory({ caseNo: caseId })
			.then(result => {
				this.caseHisData = result.hisWrap;
			}).catch(error => {
				this.error = error;
				console.log('caseHistory Error: ' + JSON.stringify(this.error));
			});

		getYourDetails()
			.then(result => {
				this.yourData = result;
			}).catch(error => {
				this.error = error;
				console.log('Your Details Err::' + JSON.stringify(error));
			});

	}

	//To close the pop window
	closeModal() {
		// to close modal set isModalOpen tarck value as false
		this.isModalOpen = false;
		this.showContractType = false;
	}

	//To make action on load more button
	loadmore() {

		this.template.querySelector('.loading-icon').classList.remove('d-none');
		this.offset = this.offset + this.recordLoadLimit;
		let loadData = [];

		getCaseOverviewDetails({ plantCode: this.plantCode, catType: this.selectedBtn, recordLimit: this.recordLoadLimit, offset: this.offset })
			.then(result => {
				this.isLoading = false;
				loadData = result.caseDataList;

				this.loadedRecord = this.loadedRecord + result.caseDataList.length;
				this.remainRecords = this.totalrecsize - this.loadedRecord;

				if (this.loadedRecord < this.totalrecsize) {
					this.showLoadMore = true;
					if (this.remainRecords < this.recordLoadLimit) {
						this.remainRecords = this.remainRecords;
					} else {
						this.remainRecords = this.recordLoadLimit;
					}
				} else {
					this.showLoadMore = false;
					this.showLess = true;
				}

				const table = this.template.querySelector('.overview-dtTable');
				let dataTable;

				$.fn.dataTableExt.sErrMode = 'none';

				let progress, prod;
				if (this.selectedBtn === 'Inquiry') {
					dataTable = $(table).DataTable({
						"paging": false,
						"searching": true, // false to disable search (or any other option)
						"info": false,
						"order": [],
						"oSearch": {
							"bSmart": false
						},
						"columnDefs": [{
							orderable: false,
							targets: []
						}],
						"language": {
							"emptyTable": "No active request and inquires."
						}
					});

					loadData.forEach(function (list) {

						prod = '';
						if (list.product == '') {
							prod = list.subject;
						} else {
							prod = list.product;
						}

						dataTable.row.add([
							'<strong>' + list.submitDate + '</strong>' + '<div class="pdf-doc f14">' + prod + '</div>',
							'<strong>' + list.reason + '</strong>' + '<a class="d-block text-hover-color" data-id=' + list.caseId + ' href="javascript:void(0)"><ins>' + list.progress + '</ins></a>'
						]).draw();
					})
				}
				else {
					dataTable = $(table).DataTable({
						"paging": false,
						"searching": true, // false to disable search (or any other option)
						"info": false,
						"order": [0, 'desc'],
						"oSearch": {
							"bSmart": false
						},
						"columnDefs": [{
							orderable: false,
							targets: 2
						}],
						"language": {
							"emptyTable": "No active request and inquires."
						}
					});

					loadData.forEach(function (list) {
						progress = '';
						if (list.progress == '-') {
							progress = '<span class="d-none d-sm-block">-</span>';
						} else {
							progress = '<a class="text-hover-color" data-id=' + list.caseId + ' href="javascript:void(0)"><ins>' + list.progress + '</ins></a>';
						}

						prod = '';
						if (list.product == '') {
							prod = list.subject;
						} else {
							prod = list.product;
						}

						dataTable.row.add([
							'<div class="font-weight-normal d-none d-sm-block"><strong>' + list.submitDate + '</strong><br>' + prod + '</div><div class="d-sm-none"><strong>' + list.submitDate + '</strong><br>' + prod + '</div>',
							'<div class="font-weight-normal d-none d-sm-block">' + list.serviceType + '</div><div class="d-sm-none"><strong>' + list.serviceType + '</strong><br>' + progress + '</div>',
							'<span class="d-none d-sm-block">' + progress + '</span>'
						]).draw();
					})
				}

			}).then(() => {
				//this.isgridLoading = false; 
				this.template.querySelector('.loading-icon').classList.add('d-none');
			})
			.catch(error => {
				this.isLoading = false;
				this.error = error.body;
				console.log('error:: ' + JSON.stringify(this.error));
			})
	}

	showless() {
		this.loadExternal = true;
		const btnSection = this.template.querySelector('.section-overview-buttons');
		$('button.active', btnSection).click();
	}

}