import { LightningElement, track, api } from "lwc";
import createFoPORec from "@salesforce/apex/FieldOfPlayOppController.createFoPORec";
import getFOPORec from "@salesforce/apex/FieldOfPlayOppController.getFOPORec";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import objectForLookup from "@salesforce/apex/FieldOfPlayOppController.getObjectName";

import checkAccess from "@salesforce/apex/FieldOfPlayOppController.getFoPOpportunityAccess";
import Success_header from "@salesforce/label/c.success_header";
import Record_Success_Message from "@salesforce/label/c.Record_success_message";
import Description_cannot_exceed_32k_characters from "@salesforce/label/c.maxLimitError";
import AddNewFoP from "@salesforce/label/c.AddNewFoP";
import description from "@salesforce/label/c.Description";
import addDescription from "@salesforce/label/c.Description";
import cancel from "@salesforce/label/c.cancel";
import saveLabel from "@salesforce/label/c.save";
import fieldOfPlayOpportunities from "@salesforce/label/c.fieldOfPlayOpportunities";
import FieldOfPlayOpportunityHeader from "@salesforce/label/c.FieldOfPlayOpportunityHeader";
import fopOpportunityTitle from "@salesforce/label/c.fopOpportunityTitle";
import fopOpportunitykpi from "@salesforce/label/c.fopOpportunitykpi";
import fopOpportunityOwner from "@salesforce/label/c.fopOpportunityOwner";
import fopOpportunityUrl from "@salesforce/label/c.fopOpportunityUrl";
import Record_Error_Message from "@salesforce/label/c.Record_error_message";
import unexpectederrormsg from "@salesforce/label/c.unexpectederrormsg";
import Error_Header from "@salesforce/label/c.error_header";
import { loadStyle } from "lightning/platformResourceLoader";
import styles from "@salesforce/resourceUrl/cssLibrary";
import close from "@salesforce/label/c.close";

export default class fopOpportunitiesMainPage extends LightningElement {
    allLabels = {
        Success_header,
        Record_Success_Message,
        Record_Error_Message,
        unexpectederrormsg,
        Description_cannot_exceed_32k_characters,
        AddNewFoP,
        fieldOfPlayOpportunities,
        cancel,
        saveLabel,
        description,
        addDescription,
        fopOpportunityTitle,
        fopOpportunitykpi,
        fopOpportunityOwner,
        fopOpportunityUrl,
        Error_Header,
        FieldOfPlayOpportunityHeader,
        close
    };

    @track selectedContactId = "";
    @track saveEnableFlag = true;
    @track title = "";
    @track kpi = "";
    @track description = "";
    @api recordId;
    @track fopoRecListFromBE;
    @track showMaxLimitError = false;
    @track showNoData = false;
    @track showModal = false;
    @track isCreateable = false;

    @track objectForLookupField;
    @track lookuptargetField;

    rfsDetails = this.getNewRfsDetails();

    getNewRfsDetails() {
        return {
            oppTitle: {
                redFlagSelected: false,
                strengthSelected: false,
                noneSelected: true,
                fieldApiName: "oppTitle"
            },
            kpi: {
                redFlagSelected: false,
                strengthSelected: false,
                noneSelected: true,
                fieldApiName: "kpi"
            },
            description: {
                redFlagSelected: false,
                strengthSelected: false,
                noneSelected: true,
                fieldApiName: "description"
            },
            strategicPlayer: {
                redFlagSelected: false,
                strengthSelected: false,
                noneSelected: true,
                fieldApiName: "strategicPlayer"
            }
        };
    }

    connectedCallback() {
        objectForLookup().then(result => {
            this.objectForLookupField = result.lookupOnObject;
            this.lookuptargetField = result.targetField;
        });

        this.getRecordFromBackend();
        checkAccess().then(result => {
            this.isCreateable = result.isCreateable;
        });
    }

    renderedCallback() {
        loadStyle(this, styles);
    }

    convertMarkerMap(rfsMarkerWrapper) {
        //Convert array of objects into Map of competitor flag and competitive details flag values
        const markers = rfsMarkerWrapper;
        const markersMap = this.getNewRfsDetails();
        markers.forEach(marker => {
            markersMap[marker.fieldApiName] = marker;
        });
        return markersMap;
    }

    handleRefresh() {
        this.getRecordFromBackend();
    }
    getRecordFromBackend() {
        this.fopoRecListFromBE = [];
        getFOPORec({ accId: this.recordId })
            .then(result => {
                let temparray = [];
                if (result.length > 0) {
                    result.forEach(element => {
                        element.rfsMarkerWrapper = this.convertMarkerMap(element.rfsMarkerWrapper);
                        temparray.push(element);
                    });
                }

                this.fopoRecListFromBE = temparray;
                this.handleUi(this.fopoRecListFromBE);
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.allLabels.unexpectederrormsg,
                        message: error.body.message,
                        variant: this.allLabels.Error_Header
                    })
                );
            });
    }

    handleUi(list) {
        if (list.length === 0) {
            this.showNoData = true;
        } else {
            this.showNoData = false;
        }
    }

    handleAddNewRecord() {
        this.handleFlags();
        this.showModal = true;
        this.saveEnableFlag = true;
    }

    handleCancel() {
        this.handleFlags();
        this.showModal = false;
    }

    handleKIPChange(event) {
        this.kpi = event.target.value;
    }

    handleDescChange(event) {
        this.description = event.target.value;
        const targetElement = event.target;

        if (targetElement.value.length > 32000) {
            this.saveEnableFlag = true;
            targetElement.setCustomValidity(Description_cannot_exceed_32k_characters);
        } else {
            this.saveEnableFlag = false;
            targetElement.setCustomValidity("");
        }
        targetElement.reportValidity();

        if (!this.title || this.title.length > 80) {
            this.saveEnableFlag = true;
        }
    }
    handleTitleChange(event) {
        this.title = event.target.value;
        const targetElement = event.target;

        if (targetElement.value.length > 80 || !this.title) {
            this.saveEnableFlag = true;
            targetElement.setCustomValidity("Title Max Length should be 80");
        } else {
            this.saveEnableFlag = false;
            targetElement.setCustomValidity("");
        }
        targetElement.reportValidity();

        if (this.description.length > 32000) {
            this.saveEnableFlag = true;
        }
    }

    handleContactSelcted(event) {
        this.selectedContactId = event.detail;
    }

    fetchInputValues() {
        const inp = this.template.querySelectorAll("lightning-input");

        inp.forEach(function(element) {
            if (element.name === "title") this.title = element.value;
        }, this);

        const des = this.template.querySelectorAll("lightning-textarea");

        des.forEach(function(element) {
            if (element.name === "Description") this.description = element.value;
        }, this);

        const kp = this.template.querySelectorAll("lightning-input");

        kp.forEach(function(element) {
            if (element.name === "KPI") this.kpi = element.value;
        }, this);
    }

    validateInputs(event) {
        var allValid = true;
        var targetElement = event.target;
        if (event.target.name === "title") {
            this.title = targetElement.value;
            if (this.title !== "") {
                this.saveEnableFlag = false;
            } else if (this.title === "") {
                this.saveEnableFlag = true;
            }
            if (targetElement.value.length > 80) {
                this.saveEnableFlag = true;
                targetElement.setCustomValidity("Title Max Length should be 80");
            } else {
                this.saveEnableFlag = false;
                targetElement.setCustomValidity("");
            }
            targetElement.reportValidity();
        }

        if (event.target.name === "KPI") {
            if (targetElement.value.length > 81) {
                this.saveEnableFlag = true;
                targetElement.setCustomValidity("Title Max Length should be 80");
            } else {
                this.saveEnableFlag = false;
                targetElement.setCustomValidity("");
            }
            targetElement.reportValidity();
        }

        if (event.target.name === "Description") {
            if (targetElement.value.length > 32000) {
                this.saveEnableFlag = true;
                targetElement.setCustomValidity(Description_cannot_exceed_32k_characters);
            } else {
                this.saveEnableFlag = false;
                targetElement.setCustomValidity("");
            }
            targetElement.reportValidity();
        }

        const inputs = this.template.querySelectorAll("lightning-input", "lightning-textarea");
        inputs.forEach(input => {
            if (!input.checkValidity()) {
                input.reportValidity();
                allValid = false;
            }
        });
        return allValid;
    }

    handleCreateFOPO(event) {
        this.saveEnableFlag = true;

        this.fetchInputValues(event);
        const ifValid = this.validateInputs(event);
        if (ifValid) {
            let recordData = {
                Title: this.title,
                KPI: this.kpi,
                Owner: this.selectedContactId ? this.selectedContactId : null,
                Description: this.description,
                GoldSheetId: this.recordId
            };

            //rfsDetails  is a object having the strength and red flag values , we need to send while saving
            createFoPORec({ recData: recordData, rfsMap: this.rfsDetails })
                .then(() => {
                    // alert("Success");
                    this.showModal = false;
                    this.saveEnableFlag = false;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: this.allLabels.Success_header,
                            message: this.allLabels.Record_Success_Message,
                            variant: this.allLabels.Success_header
                        })
                    );
                    this.selectedContactId = "";
                    this.title = "";
                    this.kpi = "";
                    this.description = "";
                    this.getRecordFromBackend();
                })
                .catch(error => {
                    this.saveEnableFlag = false;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: this.allLabels.unexpectederrormsg,
                            message: error.body.message,
                            variant: this.allLabels.Error_Header
                        })
                    );
                });
        }
    }

    handleMarkerChange(event) {
        const eventChangedMarker = event.detail;
        const rfsDetailsUpdate = this.rfsDetails[eventChangedMarker.fieldApiName];
        Object.keys(rfsDetailsUpdate).forEach(key => {
            if (eventChangedMarker[key] !== undefined && eventChangedMarker[key] != null) {
                rfsDetailsUpdate[key] = eventChangedMarker[key];
            }
        });
    }

    handleEditeModalCancel() {
        this.handleFlags();
        this.showModal = false;
    }

    handleFlags() {
        this.rfsDetails = this.getNewRfsDetails();
    }
}