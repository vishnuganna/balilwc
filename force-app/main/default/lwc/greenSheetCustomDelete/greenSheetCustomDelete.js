import { LightningElement, api, track } from "lwc";
import Cancel from "@salesforce/label/c.cancel";
import Delete from "@salesforce/label/c.delete";
import DeleteGreenSheet from "@salesforce/label/c.DeleteGreenSheet";
import DeleteGreenSheetMessage from "@salesforce/label/c.DeleteGreenSheetMessage";
import Success_header from "@salesforce/label/c.success_header";
import RecordDeleted from "@salesforce/label/c.RecordDeleted";
import ErrorDeleteFailed from "@salesforce/label/c.ErrorDeleteFailed";
import Error_Header from "@salesforce/label/c.error_header";
import Error_GS_Delete from "@salesforce/label/c.NoPermissionToDeleteGS";
import { NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import greensheetDelete from "@salesforce/apex/GreenSheet.greensheetDelete";
import checkAccess from "@salesforce/apex/GreenSheet.getGreensheetAccess";

export default class GreenSheetCustomDelete extends NavigationMixin(LightningElement) {
    @api recordId;
    @track isCreateable = false;
    @track isUpdateable = false;
    @track isDeletable = false;

    allLabels = {
        Cancel,
        Delete,
        DeleteGreenSheet,
        DeleteGreenSheetMessage,
        Success_header,
        RecordDeleted,
        ErrorDeleteFailed,
        Error_Header,
        Error_GS_Delete
    };

    connectedCallback() {
        checkAccess().then(result => {
            this.isCreateable = result.isCreateable;
            this.isUpdateable = result.isUpdateable;
            this.isDeletable = result.isDeletable;
        });
    }

    closeModal() {
        this.dispatchEvent(new CustomEvent("close"));
    }

    deleteModal() {
        if (this.isDeletable === true) {
            this.deleteGS();
        } else {
            this.closeModal();
            this.dispatchEvent(
                new ShowToastEvent({
                    title: this.allLabels.ErrorDeleteFailed,
                    message: this.allLabels.Error_GS_Delete,
                    variant: this.allLabels.Error_Header
                })
            );
        }
    }

    deleteGS() {
        greensheetDelete({ greensheetId: this.recordId })
            .then(result => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.allLabels.Success_header,
                        message: this.allLabels.RecordDeleted,
                        variant: this.allLabels.Success_header
                    })
                );
                this.navigateToViewTaskPage(result);
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.allLabels.ErrorDeleteFailed,
                        message: error.body.message,
                        variant: this.allLabels.Error_Header
                    })
                );
            });
    }

    navigateToViewTaskPage(taskId) {
        this[NavigationMixin.Navigate]({
            type: "standard__recordPage",
            attributes: {
                recordId: taskId,
                objectApiName: "Task",
                actionName: "view"
            }
        });
    }
}