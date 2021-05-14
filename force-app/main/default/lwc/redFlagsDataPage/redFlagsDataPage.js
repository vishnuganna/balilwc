import { LightningElement, api, track } from "lwc";
import deleteSOMPRecord from "@salesforce/apex/MyPositionController.deleteSOMPRecord";
import updateSOMPRecord from "@salesforce/apex/MyPositionController.updateSOMPRecord";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import edit from "@salesforce/label/c.edit";
import showMore from "@salesforce/label/c.showMore";
import showLess from "@salesforce/label/c.showLess";
import Description from "@salesforce/label/c.Description";
import Summary from "@salesforce/label/c.Summary";
import DeleteRedFlag from "@salesforce/label/c.DeleteRedFlag";
import deleteRedFlagMessage from "@salesforce/label/c.deleteRedFlagMessage";
import ErrorMax32kCharacters from "@salesforce/label/c.maxLimitError";
import yes from "@salesforce/label/c.yes";
import no from "@salesforce/label/c.no";
import save from "@salesforce/label/c.save";
import cancel from "@salesforce/label/c.cancel";
import checkAccess from "@salesforce/apex/MyPositionController.getMypositionAccess";
import Required_Field_Missing from "@salesforce/label/c.Required_Field_Missing";
import Please_fill_the_Summary_Field from "@salesforce/label/c.Please_fill_the_Summary_Field";
import error_header from "@salesforce/label/c.error_header";
import success_header from "@salesforce/label/c.success_header";
import Record_error_message from "@salesforce/label/c.Record_error_message";
import RecordDeleted from "@salesforce/label/c.RecordDeleted";
import ErrorDeleteFailed from "@salesforce/label/c.ErrorDeleteFailed";
import Update_Success from "@salesforce/label/c.Update_Success";
import Summary_cannot_exceed_256_characters from "@salesforce/label/c.Summary_cannot_exceed_256_characters";
import Delete from "@salesforce/label/c.delete";
import DeleteRecord from "@salesforce/label/c.DeleteRecord";
import EditRecord from "@salesforce/label/c.EditRecord";
import close from "@salesforce/label/c.close";

export default class RedFlagsDataPage extends LightningElement {
    @api item;
    showEditView = false;
    ShowModal = false;
    description = "";
    summary = "";
    ShowMoreText = false;
    ShowLessText = false;
    showText = false;
    shortText = "";
    longText = "";
    showMaxLimitError = false;
    @track isCreateable = false;
    @track isUpdateable = false;
    @track isDeletable = false;
    @track saveDisableFlag = false;

    allLabel = {
        edit,
        Please_fill_the_Summary_Field,
        showMore,
        showLess,
        Record_error_message,
        Description,
        DeleteRedFlag,
        deleteRedFlagMessage,
        ErrorMax32kCharacters,
        Summary,
        Required_Field_Missing,
        yes,
        Update_Success,
        no,
        save,
        cancel,
        success_header,
        RecordDeleted,
        ErrorDeleteFailed,
        error_header,
        Summary_cannot_exceed_256_characters,
        Delete,
        DeleteRecord,
        EditRecord,
        close
    };

    connectedCallback() {
        this.description = this.item.description;
        this.handleshowMoreless();
        // -----10 June 20
        checkAccess().then(result => {
            this.isCreateable = result.isCreateable;
            this.isUpdateable = result.isUpdateable;
            this.isDeletable = result.isDeletable;
        });
        // -----10 June 20
    }

    handleDeleteRec() {
        this.ShowModal = false;
        deleteSOMPRecord({ recordId: this.item.psId })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.allLabel.success_header,
                        message: this.allLabel.RecordDeleted,
                        variant: this.allLabel.success_header
                    })
                );
                const selectedEvent = new CustomEvent("refreshscreen", {
                    detail: true
                });
                // Dispatches the event.
                this.dispatchEvent(selectedEvent);
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.allLabel.ErrorDeleteFailed,
                        message: error.body.message,
                        variant: this.allLabel.error_header
                    })
                );
            });
    }

    handleDeleteModal() {
        this.ShowModal = true;
    }

    closeModal() {
        this.ShowModal = false;
    }

    handleEdit() {
        this.showEditView = true;
        this.summary = this.item.summary;
        this.description = this.item.description;
    }

    handleDescChange(event) {
        this.description = event.target.value;
    }

    handleSummaryChange(event) {
        this.summary = event.target.value;
        const targetElement = event.target;
        if (event.target.name === "summary") {
            if (targetElement.value.length === 256) {
                targetElement.setCustomValidity(Summary_cannot_exceed_256_characters);
            } else {
                targetElement.setCustomValidity("");
            }
            if (this.summary && this.summary.length > 0) {
                this.saveDisableFlag = false;
            } else {
                this.saveDisableFlag = true;
            }
            targetElement.reportValidity();
        }
    }

    handleCancelClick() {
        this.showEditView = false;
        this.showMaxLimitError = false;
    }

    handleSaveClick() {
        if (this.summary.trim() == null || this.summary.trim() === "" || this.summary.trim() === "undefined") {
            this.saveDisableFlag = true;
        } else {
            this.saveDisableFlag = false;
            let redFlagDataToSave = {
                summary: this.summary,
                description: this.description,
                redFlag: "true",
                recId: this.item.psId
            };
            this.showEditView = false;
            updateSOMPRecord({ sompRec: redFlagDataToSave })
                .then(() => {
                    this.saveDisableFlag = false;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: this.allLabel.success_header,
                            message: this.allLabel.Update_Success,
                            variant: this.allLabel.success_header
                        })
                    );
                    this.handleshowMoreless();
                    const selectedEvent = new CustomEvent("refreshscreen", {
                        detail: true
                    });
                    this.dispatchEvent(selectedEvent);
                })
                .catch(error => {
                    this.saveDisableFlag = false;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: this.allLabel.Record_error_message,
                            message: error.body.message,
                            variant: this.allLabel.error_header
                        })
                    );
                });
        }
    }

    handleShowMore() {
        this.showText = true;
        this.ShowMoreText = false;
        this.ShowLessText = true;
    }

    handleShowLess() {
        this.showText = false;
        this.ShowLessText = false;
        this.ShowMoreText = true;
    }

    handleshowMoreless() {
        var description = this.description;
        if (description) {
            if (description.length > 200) {
                this.shortText = "";
                this.longText = "";
                this.shortText = description.substr(0, 200);
                this.longText = description.substr(200, description.length);
                this.ShowMoreText = true;
                this.showText = false;
                this.ShowLessText = false;
            } else {
                this.shortText = description;
                this.longText = "";
                this.ShowMoreText = false;
                this.ShowLessText = false;
            }
        }
    }

    handleMaxLimitError(event) {
        var descriptionLimit = event.target.value;
        if (descriptionLimit.length === 32000) {
            this.showMaxLimitError = true;
        } else {
            this.showMaxLimitError = false;
        }
    }

    //KFS-814
    @api closeEditModal() {
        this.showEditView = false;
    }
}