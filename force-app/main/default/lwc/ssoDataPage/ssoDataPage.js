import { LightningElement, track, api } from "lwc";
import emptySSORecord from "@salesforce/apex/SingleSalesObjectiveController.emptySSORecord";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import Customer_Timing_for_Priorities from "@salesforce/label/c.Customer_Timing_for_Priorities";
import Urgent from "@salesforce/label/c.Urgent";
import Active from "@salesforce/label/c.Active";
import Work_It_In from "@salesforce/label/c.Work_It_In";
import Later from "@salesforce/label/c.Later";
import Customer_Stated_Objective from "@salesforce/label/c.Customer_Stated_Objective";
import maxLimitError from "@salesforce/label/c.maxLimitError";
import Evaluation_of_Objective from "@salesforce/label/c.Evaluation_of_Objective";
import RecordDeleted from "@salesforce/label/c.RecordDeleted";
import cancel from "@salesforce/label/c.cancel";
import save from "@salesforce/label/c.save";
import error_header from "@salesforce/label/c.error_header";
import Record_error_message from "@salesforce/label/c.Record_error_message";
import success_header from "@salesforce/label/c.success_header";
import Update_Success from "@salesforce/label/c.Update_Success";
import close from "@salesforce/label/c.close";
import Delete_SSO from "@salesforce/label/c.Delete_SSO";
import deleteCustomerTimingAndStatedObjectiveMessage from "@salesforce/label/c.deleteCustomerTimingAndStatedObjectiveMessage";
import yes from "@salesforce/label/c.yes";
import no from "@salesforce/label/c.no";
import sSoHeaderURL from "@salesforce/label/c.sSoHeaderURL";
import sSoCustomerStatedURL from "@salesforce/label/c.sSoCustomerStatedURL";
import sSoCustTimingPriorities from "@salesforce/label/c.sSoCustTimingPriorities";
import ErrorCreatingRecord from "@salesforce/label/c.ErrorCreatingRecord";

export default class SsoDataPage extends LightningElement {
    label = {
        RecordDeleted,
        Update_Success,
        success_header,
        Record_error_message,
        error_header,
        Customer_Timing_for_Priorities,
        Customer_Stated_Objective,
        Evaluation_of_Objective,
        Urgent,
        Active,
        Work_It_In,
        Later,
        maxLimitError,
        cancel,
        save,
        close,
        Delete_SSO,
        deleteCustomerTimingAndStatedObjectiveMessage,
        yes,
        no,
        sSoHeaderURL,
        sSoCustomerStatedURL,
        sSoCustTimingPriorities,
        ErrorCreatingRecord //KFS_2766
    };

    @track readOnlyView = true;
    @api item;
    @track customerStatedObjective;
    @track evaluationofObjective;
    @track checkboxValue;
    @track activeCheck = false;
    @track laterCheck = false;
    @track workCheck = false;
    @track urgentCheck = false;
    @track showMaxLimitErrorCSO = false;
    @track showMaxLimitErrorEOF = false;
    @track ShowModal = false;
    @track
    rfsDetails = {};
    @api parentid;
    @api recordId;

    getNewRfsDetails() {
        return {
            CustomerTimingforPriorities: {
                redFlagSelected: false,
                strengthSelected: false,
                noneSelected: true,
                fieldApiName: "CustomerTimingforPriorities"
            },
            CustomersStatedObjectives: {
                redFlagSelected: false,
                strengthSelected: false,
                noneSelected: true,
                fieldApiName: "CustomersStatedObjectives"
            },
            EvaluationofObjectives: {
                redFlagSelected: false,
                strengthSelected: false,
                noneSelected: true,
                fieldApiName: "EvaluationofObjectives"
            }
        };
    }

    connectedCallback() {
        //alert('InCallback'+JSON.stringify(this.item));
        this.customerStatedObjective = this.item.customerStatedObjective;
        this.evaluationofObjective = this.item.evaluationOfObjectives;
        this.rfsDetails = this.convertMarkerMap();
    }

    //If marker updated then updated
    handleMarkerChange(event) {
        const eventChangedMarker = event.detail;
        const rfsDetailsUpdate = JSON.parse(JSON.stringify(this.rfsDetails[eventChangedMarker.fieldApiName]));
        if (rfsDetailsUpdate != null) {
            Object.keys(rfsDetailsUpdate).forEach(key => {
                if (eventChangedMarker[key] !== undefined && eventChangedMarker[key] !== null) {
                    rfsDetailsUpdate[key] = eventChangedMarker[key];
                }
            });
            this.rfsDetails[eventChangedMarker.fieldApiName] = rfsDetailsUpdate;
        }
    }

    convertMarkerMap() {
        //Convert array of objects into Map of competitor flag and competitive details flag values
        //var x;
        const markers = this.item.rfsMarkerWrapper;
        const markersMap = this.getNewRfsDetails();
        markers.forEach(marker => {
            markersMap[marker.fieldApiName] = marker;
        });
        return markersMap;
    }

    handleDelete() {
        this.ShowModal = false;

        let ssoWrapper = {};
        ssoWrapper.blueSheet = "";
        ssoWrapper.custTimingPriorities = "";
        ssoWrapper.customerStatedObjective = "";
        ssoWrapper.evaluationOfObjectives = "";
        ssoWrapper.ssoId = this.item.ssoId;
        this.ssoWrapper = ssoWrapper;
        this.customerStatedObjective = "";
        this.evaluationofObjective = "";
        this.clearRFSData();
        emptySSORecord({ jsonString: JSON.stringify(this.ssoWrapper), oppId: this.parentid, rfsData: this.rfsDetails })
            .then(() => {
                // Show success messsage
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.label.success_header,
                        message: this.label.RecordDeleted,
                        variant: this.label.success_header
                    })
                );

                const selectedEvent = new CustomEvent("refreshscreen", {
                    detail: true
                });
                // Dispatches the event.
                this.dispatchEvent(selectedEvent);
                this.urgentCheck = false;
                this.laterCheck = false;
                this.workCheck = false;
                this.activeCheck = false;
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.label.ErrorCreatingRecord, //KFS_2766
                        message: error.body.message,
                        variant: "error"
                    })
                );
            });
    }

    clearRFSData() {
        if (this.rfsDetails != null) {
            Object.keys(this.rfsDetails).forEach(rfsKey => {
                const rfsKeyDetails = JSON.parse(JSON.stringify(this.rfsDetails[rfsKey]));
                if (rfsKeyDetails) {
                    rfsKeyDetails.redFlagSelected = false;
                    rfsKeyDetails.strengthSelected = false;
                    rfsKeyDetails.noneSelected = true;
                }
                this.rfsDetails[rfsKey] = rfsKeyDetails;
            });
        }
    }

    @api
    handleEdit() {
        this.customerStatedObjective = this.item.customerStatedObjective;
        this.evaluationofObjective = this.item.evaluationOfObjectives;
        this.checkboxValue = this.item.custTimingPriorities;
        this.rfsDetails = this.convertMarkerMap();
        if (this.checkboxValue === this.label.Urgent) {
            this.urgentCheck = true;
            this.laterCheck = false;
            this.workCheck = false;
            this.activeCheck = false;
        } else if (this.checkboxValue === this.label.Active) {
            this.activeCheck = true;
            this.laterCheck = false;
            this.workCheck = false;
            this.urgentCheck = false;
        } else if (this.checkboxValue === this.label.Work_It_In) {
            this.workCheck = true;
            this.laterCheck = false;
            this.activeCheck = false;
            this.urgentCheck = false;
        } else if (this.checkboxValue === this.label.Later) {
            this.laterCheck = true;
            this.workCheck = false;
            this.activeCheck = false;
            this.urgentCheck = false;
        } else {
            this.laterCheck = false;
            this.workCheck = false;
            this.activeCheck = false;
            this.urgentCheck = false;
        }
        this.readOnlyView = false;
    }

    handleCancel() {
        this.readOnlyView = true;
        this.laterCheck = false;
        this.workCheck = false;
        this.activeCheck = false;
        this.urgentCheck = false;
        this.rfsDetails = this.convertMarkerMap();
        this.showMaxLimitErrorCSO = false;
        this.showMaxLimitErrorEOF = false;
        this.customerStatedObjective = this.item.customerStatedObjective;
        this.evaluationofObjective = this.item.evaluationOfObjectives;
        // Creates the event with the data.
        const selectedEvent = new CustomEvent("cancel", {
            showEditButton: true
        });
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
    }

    @api
    showDeleteModal() {
        this.ShowModal = true;
    }

    closeModal() {
        this.ShowModal = false;
    }

    handlePrioritues(event) {
        if (event.target.checked) {
            this.checkboxValue = event.target.value;
            //window.console.log('check priorities ' + this.checkboxValue);
            if (this.checkboxValue === this.label.Urgent) {
                this.urgentCheck = true;
                this.laterCheck = false;
                this.workCheck = false;
                this.activeCheck = false;
            } else if (this.checkboxValue === this.label.Active) {
                this.activeCheck = true;
                this.laterCheck = false;
                this.workCheck = false;
                this.urgentCheck = false;
            } else if (this.checkboxValue === this.label.Work_It_In) {
                this.workCheck = true;
                this.laterCheck = false;
                this.activeCheck = false;
                this.urgentCheck = false;
            } else if (this.checkboxValue === this.label.Later) {
                this.laterCheck = true;
                this.workCheck = false;
                this.activeCheck = false;
                this.urgentCheck = false;
            }
        } else {
            this.checkboxValue = "";
        }
    }

    handleCSOChange(event) {
        this.customerStatedObjective = event.target.value;
    }

    handleEOFChange(event) {
        this.evaluationofObjective = event.target.value;
    }

    handleMaxLimitErrorCSO(event) {
        var customerStatedObjectiveLimit = event.target.value;
        if (customerStatedObjectiveLimit.length === 32000) {
            this.showMaxLimitErrorCSO = true;
        } else {
            this.showMaxLimitErrorCSO = false;
        }
    }

    handleMaxLimitErrorEOF(event) {
        //alert('Error');
        var customerStatedObjectiveLimit = event.target.value;
        if (customerStatedObjectiveLimit.length === 32000) {
            this.showMaxLimitErrorEOF = true;
            //alert('Inside IF')
        } else {
            this.showMaxLimitErrorEOF = false;
        }
    }

    saveEditSSO() {
        let ssoWrapper = {};
        ssoWrapper.blueSheet = "";
        ssoWrapper.custTimingPriorities = this.checkboxValue;
        ssoWrapper.customerStatedObjective = this.customerStatedObjective;
        ssoWrapper.evaluationOfObjectives = this.evaluationofObjective;
        ssoWrapper.ssoId = this.item.ssoId;
        this.ssoWrapper = ssoWrapper;
        this.showMaxLimitErrorCSO = false;
        this.showMaxLimitErrorEOF = false;
        emptySSORecord({ jsonString: JSON.stringify(this.ssoWrapper), oppId: this.parentid, rfsData: this.rfsDetails })
            .then(() => {
                // Show success messsage
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.label.success_header,
                        message: this.label.Update_Success,
                        variant: this.label.success_header
                    })
                );

                const selectedEvent = new CustomEvent("refreshscreen", {
                    detail: true
                });
                // Dispatches the event.
                this.dispatchEvent(selectedEvent);
                this.readOnlyView = true;
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.label.Record_error_message,
                        message: error.body.message,
                        variant: this.label.error_header
                    })
                );
            });
    }
}