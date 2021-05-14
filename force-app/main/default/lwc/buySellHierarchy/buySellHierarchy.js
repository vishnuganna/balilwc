import { LightningElement, api, track, wire } from "lwc";
import getBusinessHierarchyData from "@salesforce/apex/BuySellHierarchyController.getBusinessHierarchyData";
import saveBuySellHierarchyData from "@salesforce/apex/BuySellHierarchyController.saveBuySellHierarchyData";
import getObjectPermission from "@salesforce/apex/BuySellHierarchyController.getObjectPermission";
import getPicklistValues from "@salesforce/apex/BuySellHierarchyController.getPicklistValues";
import SelectLevel from "@salesforce/label/c.SelectLevel";
import FieldOfPlay from "@salesforce/label/c.FieldOfPlay";
import BuySellStrategicPlayerURL from "@salesforce/label/c.BuySellStrategicPlayerURL";
import BuySellHierarchyLabel from "@salesforce/label/c.BuySellHierarchy";
import AddBuySellHierarchy from "@salesforce/label/c.AddBuySellHierarchy";
import BuySellHierarchyLastYear from "@salesforce/label/c.BuySellHierarchyLastYear";
import BuySellHierarchyUs from "@salesforce/label/c.BuySellHierarchyUs";
import BuySellHierarchyThisYear from "@salesforce/label/c.BuySellHierarchyThisYear";
import BuySellHierarchyNextYear from "@salesforce/label/c.BuySellHierarchyNextYear";
import BuySellHierarchyView from "@salesforce/label/c.BuySellHierarchyView";
import BuySellHierarchyCustomDateError from "@salesforce/label/c.BuySellHierarchyCustomDateError";
import Save from "@salesforce/label/c.save";
import Delete from "@salesforce/label/c.delete";
import Edit from "@salesforce/label/c.edit";
import Cancel from "@salesforce/label/c.cancel";
import Close from "@salesforce/label/c.close";
import Yes from "@salesforce/label/c.yes";
import successheader from "@salesforce/label/c.success_header";
import errorheader from "@salesforce/label/c.error_header";
import errormsg from "@salesforce/label/c.Record_error_message";
import successmsg from "@salesforce/label/c.Record_success_message";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import BuySellHierarchyCustomYear from "@salesforce/label/c.BuySellHierarchyCustomYear";
import FieldOfPlayBR from "@salesforce/label/c.FieldOfPlayBR";

export default class BuySellHierarchy extends LightningElement {
    @api getIdFromParent;
    @track buySellHierarchyData = [];
    @track hasBuySellHierarchyData = false;
    @track hasEditAccess;
    @track showEditButton = false;
    @track showCreateEditState = false;
    @track showCreateButton = false;
    @track showSavedState = false;
    @track picklistOptions = [];
    @track customDate;
    @track fOPLastYear = "";
    @track fOPCustomYear = "";
    @track fOPThisYear = "";
    @track fOPNextYear = "";
    @track usLastYear = "";
    @track usCustomYear = "";
    @track usThisYear = "";
    @track usNextYear = "";
    @track dateRequired = false;
    @track rfsDetails = this.getNewRfsDetails();
    @track rfsInitialDetails;
    @track rfsMap = {};
    @track rfsMarker;
    allLabels = {
        Save,
        Delete,
        Edit,
        Cancel,
        Close,
        Yes,
        successheader,
        errorheader,
        errormsg,
        successmsg,
        SelectLevel,
        FieldOfPlay,
        BuySellStrategicPlayerURL,
        AddBuySellHierarchy,
        BuySellHierarchyLabel,
        BuySellHierarchyLastYear,
        BuySellHierarchyUs,
        BuySellHierarchyNextYear,
        BuySellHierarchyThisYear,
        BuySellHierarchyView,
        BuySellHierarchyCustomDateError,
        BuySellHierarchyCustomYear,
        FieldOfPlayBR
    };

    getNewRfsDetails() {
        return {
            fieldOfPlayLastYear: {
                redFlagSelected: false,
                strengthSelected: false,
                noneSelected: true,
                fieldApiName: "fieldOfPlayLastYear"
            },
            fieldOfPlayThisYear: {
                redFlagSelected: false,
                strengthSelected: false,
                noneSelected: true,
                fieldApiName: "fieldOfPlayThisYear"
            },
            fieldOfPlayNextYear: {
                redFlagSelected: false,
                strengthSelected: false,
                noneSelected: true,
                fieldApiName: "fieldOfPlayNextYear"
            },
            fieldOfPlayCustomYear: {
                redFlagSelected: false,
                strengthSelected: false,
                noneSelected: true,
                fieldApiName: "fieldOfPlayCustomYear"
            },
            usNextYear: {
                redFlagSelected: false,
                strengthSelected: false,
                noneSelected: true,
                fieldApiName: "usNextYear"
            },
            usLastYear: {
                redFlagSelected: false,
                strengthSelected: false,
                noneSelected: true,
                fieldApiName: "usLastYear"
            },
            usThisYear: {
                redFlagSelected: false,
                strengthSelected: false,
                noneSelected: true,
                fieldApiName: "usThisYear"
            },
            usCustomYear: {
                redFlagSelected: false,
                strengthSelected: false,
                noneSelected: true,
                fieldApiName: "usCustomYear"
            }
        };
    }

    connectedCallback() {
        this.getObjectPermission();
        this.getDataFromBackEnd();
    }

    @wire(getPicklistValues)
    picklistResult({ error, data }) {
        if (data) {
            const result = JSON.parse(data);
            for (let key in result) {
                if ({}.hasOwnProperty.call(result, key)) {
                    this.picklistOptions.push({ label: key, value: result[key] }); //Here we are creating the array to show on UI.
                }
            }
            this.picklistOptions.push({ label: SelectLevel, value: SelectLevel });
            this.picklistOptions = this.picklistOptions.reverse();
        } else {
            this.error = error;
            //console.log(error);
        }
    }

    getDataFromBackEnd() {
        getBusinessHierarchyData({ goldsheetId: this.getIdFromParent }).then(result => {
            if (result) {
                this.buySellHierarchyData = result;
                this.customDate = result.buySellhierarchyDate;
                this.fOPCustomYear = result.fieldOfPlayCustomYear;
                this.fOPLastYear = result.fieldOfPlayLastYear;
                this.fOPNextYear = result.fieldOfPlayNextYear;
                this.fOPThisYear = result.fieldOfPlayThisYear;
                this.usLastYear = result.usLastYear;
                this.usNextYear = result.usNextYear;
                this.usCustomYear = result.usCustomYear;
                this.usThisYear = result.usThisYear;
                this.rfsDetails = this.convertMarkerMap(result.rfsMarkerWrapper);
                this.rfsInitialDetails = JSON.parse(JSON.stringify(this.rfsDetails));
                if (
                    this.fOPCustomYear ||
                    this.fOPLastYear ||
                    this.fOPNextYear ||
                    this.fOPThisYear ||
                    this.usLastYear ||
                    this.usNextYear ||
                    this.usCustomYear ||
                    this.usThisYear ||
                    this.customDate
                ) {
                    this.showSavedState = true;
                    this.hasBuySellHierarchyData = true;
                } else {
                    this.showSavedState = false;
                    this.hasBuySellHierarchyData = false;
                }
            }
        });
    }
    convertMarkerMap(rfsMarkerWrapper) {
        const markers = rfsMarkerWrapper;
        const markersMap = this.getNewRfsDetails();
        markers.forEach(marker => {
            markersMap[marker.fieldApiName] = marker;
        });
        return markersMap;
    }

    getObjectPermission() {
        getObjectPermission().then(result => {
            this.hasEditAccess = result.isUpdateable;
            this.hasCreateAccess = result.isCreateable;
            this.hasDeleteAccess = result.isDeletable;
            if (this.hasCreateAccess) {
                this.showCreateButton = true;
            }
            if (this.hasEditAccess) {
                this.showEditButton = true;
            }
        });
    }
    handleCreate() {
        this.showCreateEditState = true;
        this.showCreateButton = false;
        this.showSavedState = false;
        this.fOPCustomYear = "";
        this.fOPLastYear = "";
        this.fOPNextYear = "";
        this.fOPThisYear = "";
        this.usLastYear = "";
        this.usNextYear = "";
        this.usCustomYear = "";
        this.usThisYear = "";
        this.customDate = null;
        this.dateRequired = false;
        this.rfsDetails = this.getNewRfsDetails();
    }
    handleEdit() {
        this.showCreateEditState = true;
        this.showSavedState = false;
        this.editCancelShow = true;
        this.showEditButton = false;
        this.fOPCustomYear = this.buySellHierarchyData.fieldOfPlayCustomYear;
        this.fOPLastYear = this.buySellHierarchyData.fieldOfPlayLastYear;
        this.fOPNextYear = this.buySellHierarchyData.fieldOfPlayNextYear;
        this.fOPThisYear = this.buySellHierarchyData.fieldOfPlayThisYear;
        this.usLastYear = this.buySellHierarchyData.usLastYear;
        this.usNextYear = this.buySellHierarchyData.usNextYear;
        this.usCustomYear = this.buySellHierarchyData.usCustomYear;
        this.usThisYear = this.buySellHierarchyData.usThisYear;
        this.customDate = this.buySellHierarchyData.buySellhierarchyDate;
        this.dateRequired = false;
    }
    handleCancel() {
        this.showCreateEditState = false;
        if (this.hasBuySellHierarchyData) {
            this.showSavedState = true;
            this.showEditButton = true;
        } else {
            this.showSavedState = false;
            this.showCreateButton = true;
        }
        this.rfsDetails = JSON.parse(JSON.stringify(this.rfsInitialDetails));
    }
    handleFOPLastYearSelected(event) {
        this.fOPLastYear = event.detail.value;
        if (this.fOPLastYear === "Select Level") {
            this.fOPLastYear = "";
        }
    }
    handleFOPThisYearSelected(event) {
        this.fOPThisYear = event.detail.value;
        if (this.fOPThisYear === "Select Level") {
            this.fOPThisYear = "";
        }
    }
    handleFOPNextYearSelected(event) {
        this.fOPNextYear = event.detail.value;
        if (this.fOPNextYear === "Select Level") {
            this.fOPNextYear = "";
        }
    }
    handleFOPCustomYearSelected(event) {
        this.fOPCustomYear = event.detail.value;
        if (this.fOPCustomYear === "Select Level") {
            this.fOPCustomYear = "";
            this.dateRequired = false;
        } else {
            if (!this.customDate) {
                this.dateRequired = true;
            }
        }
    }
    handleUSCustomYearSelected(event) {
        this.usCustomYear = event.detail.value;
        if (this.usCustomYear === "Select Level") {
            this.usCustomYear = "";
            this.dateRequired = false;
        } else {
            if (!this.customDate) {
                this.dateRequired = true;
            }
        }
    }
    handleUSLastYearSelected(event) {
        this.usLastYear = event.detail.value;
        if (this.usLastYear === "Select Level") {
            this.usLastYear = "";
        }
    }
    handleUSNextYearSelected(event) {
        this.usNextYear = event.detail.value;
        if (this.usNextYear === "Select Level") {
            this.usNextYear = "";
        }
    }
    handleUSThisYearSelected(event) {
        this.usThisYear = event.detail.value;
        if (this.usThisYear === "Select Level") {
            this.usThisYear = "";
        }
    }
    handleCustomDate(event) {
        this.customDate = event.detail.value;
        this.dateRequired = false;
    }
    handleMarkerChange(event) {
        const eventChangedMarker = event.detail;
        const rfsDetailsUpdate = this.rfsDetails[eventChangedMarker.fieldApiName];
        Object.keys(rfsDetailsUpdate).forEach(key => {
            if (eventChangedMarker[key] !== undefined && eventChangedMarker[key] !== null) {
                rfsDetailsUpdate[key] = eventChangedMarker[key];
            }
        });
    }
    handleSave() {
        let inputArray = {
            fieldOfPlayCustomYear: this.fOPCustomYear,
            fieldOfPlayLastYear: this.fOPLastYear,
            fieldOfPlayNextYear: this.fOPNextYear,
            fieldOfPlayThisYear: this.fOPThisYear,
            usCustomYear: this.usCustomYear,
            usLastYear: this.usLastYear,
            usNextYear: this.usNextYear,
            usThisYear: this.usThisYear,
            buySellhierarchyDate: this.customDate,
            goldSheetId: this.getIdFromParent
        };
        //console.log('JSON.stringify(inputArray)> '+JSON.stringify(inputArray));
        if (
            this.fOPCustomYear ||
            this.fOPLastYear ||
            this.fOPNextYear ||
            this.fOPThisYear ||
            this.usLastYear ||
            this.usNextYear ||
            this.usCustomYear ||
            this.usThisYear ||
            this.customDate
        ) {
            if (
                ((this.fOPCustomYear != null || this.usCustomYear != null) && this.customDate) ||
                ((!this.fOPCustomYear || !this.usCustomYear) && this.customDate) ||
                (!this.fOPCustomYear && !this.usCustomYear && !this.customDate)
            ) {
                saveBuySellHierarchyData({ inputString: JSON.stringify(inputArray), rfsMap: this.rfsDetails })
                    .then(result => {
                        if (result) {
                            //console.log('JSON.stringify(result)::>> '+JSON.stringify(result));
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: successmsg,
                                    message: successmsg,
                                    variant: successheader
                                })
                            );
                        }
                        this.getDataFromBackEnd();
                        this.showSavedState = true;
                        this.showCreateEditState = false;
                        this.showEditButton = true;
                    })
                    .catch(error => {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: errorheader,
                                message: error.body.message,
                                variant: errorheader
                            })
                        );
                    });
            } else {
                this.dateRequired = true;
            }
        }
    }
}