import { LightningElement, track, api } from "lwc";
import createFoPORec from "@salesforce/apex/FieldOfPlayOppController.createFoPORec";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import success_header from "@salesforce/label/c.success_header";
import Update_Success from "@salesforce/label/c.Update_Success";
import FieldOfPlayError from "@salesforce/label/c.FieldOfPlayError";
import ErrorOccured from "@salesforce/label/c.ErrorOccured";
import fieldOfPlayOpportunities from "@salesforce/label/c.fieldOfPlayOpportunities";
import AddNewFoP from "@salesforce/label/c.AddNewFoP";
import fopOpportunityTitle from "@salesforce/label/c.fopOpportunityTitle";
import fopOpportunitykpi from "@salesforce/label/c.fopOpportunitykpi";
import Description from "@salesforce/label/c.Description";
import PlaceholderText from "@salesforce/label/c.PlaceholderText";
import cancel from "@salesforce/label/c.cancel";
import save from "@salesforce/label/c.save";

export default class FOPOMainPage extends LightningElement {
    @track selectedContactId = "";
    @track saveEnableFlag = true;
    @track title = "";
    @track kpi = "";
    @track description = "";
    @api recordId;
    @track headerFlag = true;

    allLabels = {
        success_header, //KFS-2766
        Update_Success, //KFS-2766
        FieldOfPlayError, //KFS-2766
        ErrorOccured, //KFS-2766
        fieldOfPlayOpportunities,
        AddNewFoP,
        fopOpportunityTitle,
        fopOpportunitykpi,
        Description,
        PlaceholderText,
        cancel,
        save
    };

    handleAddNewRecord() {
        this.headerFlag = false;
    }

    handleCancel() {
        this.headerFlag = true;
    }
    hangleTitleChange(event) {
        this.title = event.target.value;
        if (this.title !== "") {
            this.saveEnableFlag = false;
        } else if (this.title === "") {
            this.saveEnableFlag = true;
        }
    }

    handleKIPChange(event) {
        this.kpi = event.target.value;
    }

    handleDescChange(event) {
        this.description = event.target.value;
    }

    handleContactSelcted(event) {
        this.selectedContactId = event.detail;
    }

    handleCreateFOPO() {
        let recordData = {
            Title: this.title,
            KPI: this.kpi,
            Owner: this.selectedContactId,
            Description: this.description
        };
        createFoPORec({ recData: recordData, accId: this.recordId })
            .then(() => {
                const event = new ShowToastEvent({
                    title: this.allLabels.success_header, //KFS-2766
                    message: this.allLabels.Update_Success, //KFS-2766
                    variant: "success",
                    mode: "dismissable"
                });
                this.dispatchEvent(event);
            })
            .catch(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.allLabels.FieldOfPlayError, //KFS-2766
                        message: this.allLabels.ErrorOccured, //KFS-2766
                        variant: "error"
                    })
                );
            });
    }
}