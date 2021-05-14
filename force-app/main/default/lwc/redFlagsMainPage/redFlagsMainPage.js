import { LightningElement, api, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import createSummaryRec from "@salesforce/apex/MyPositionController.createSummaryRec";
import getSOMPRecords from "@salesforce/apex/MyPositionController.getSOMPRecords";

import RED_FLAGS from "@salesforce/label/c.RED_FLAGS";
import Summary from "@salesforce/label/c.Summary";
import Description from "@salesforce/label/c.Description";
import ErrorMax32kCharacters from "@salesforce/label/c.maxLimitError";
import AddNewRedFlag from "@salesforce/label/c.AddNewRedFlag";
import save from "@salesforce/label/c.save";
import cancel from "@salesforce/label/c.cancel";
import Required_Field_Missing from "@salesforce/label/c.Required_Field_Missing";
import Please_fill_the_Summary_Field from "@salesforce/label/c.Please_fill_the_Summary_Field";
import error_header from "@salesforce/label/c.error_header";
import success_header from "@salesforce/label/c.success_header";
import Record_error_message from "@salesforce/label/c.Record_error_message";
import Record_success_message from "@salesforce/label/c.Record_success_message";
import sumPositionRedFlagURL from "@salesforce/label/c.sumPositionRedFlagURL";
import checkAccess from "@salesforce/apex/MyPositionController.getMypositionAccess";
import Summary_cannot_exceed_256_characters from "@salesforce/label/c.Summary_cannot_exceed_256_characters";
import getOppId from "@salesforce/apex/StrategyEngine.getOppId";
import SOMPLabel from "@salesforce/label/c.SOMPLabel";
import ErrorOccured from "@salesforce/label/c.ErrorOccured";

export default class RedFlagsMainPage extends LightningElement {
    newRecordScreenFlag = false;
    description = "";
    summary = "";
    showMaxLimitError = false;

    // @api getIdFromParent;
    @track _getIdFromParent;
    @api
    get getIdFromParent() {
        return this._getIdFromParent;
    }

    set getIdFromParent(value) {
        this._getIdFromParent = value;
        getOppId({ blueSheetId: this.getIdFromParent }).then(result => {
            this.optyId = result;
            this.getDataFromBackend();
        });
    }

    @track redFlagsData = [];
    @track isCreateable = false;
    @track isUpdateable = false;
    @track isDeletable = false;
    @track saveDisableFlag = true;
    @api recordId;
    @track optyId = "";

    allLabel = {
        RED_FLAGS,
        Summary,
        Description,
        ErrorMax32kCharacters,
        save,
        cancel,
        AddNewRedFlag,
        Required_Field_Missing,
        Please_fill_the_Summary_Field,
        error_header,
        success_header,
        Record_error_message,
        Record_success_message,
        sumPositionRedFlagURL,
        Summary_cannot_exceed_256_characters,
        ErrorOccured, //KFS-2766
        SOMPLabel //KFS-2766
    };

    connectedCallback() {
        // -----10 June 20
        checkAccess().then(result => {
            this.isCreateable = result.isCreateable;
            this.isUpdateable = result.isUpdateable;
            this.isDeletable = result.isDeletable;
        });
        // -----10 June 20
    }

    handleCreateNewRec() {
        //KFS-814
        this.template.querySelectorAll("c-red-flags-data-page").forEach(item => {
            item.closeEditModal();
        });
        this.newRecordScreenFlag = true;
        this.initializeVariables();
    }

    handleCancelClick() {
        this.newRecordScreenFlag = false;
        this.showMaxLimitError = false;
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

    initializeVariables() {
        this.description = "";
        this.summary = "";
    }

    handleSaveClick() {
        if (this.summary.trim() == null || this.summary.trim() === "" || this.summary.trim() === "undefined") {
            this.saveDisableFlag = true;
        } else {
            this.saveDisableFlag = false;
            let redFlagDataToSave = {
                summary: this.summary,
                description: this.description,
                redFlag: "true"
            };

            this.newRecordScreenFlag = false;
            createSummaryRec({ sumData: redFlagDataToSave, oppId: this.optyId })
                .then(() => {
                    this.saveDisableFlag = false;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: this.allLabel.success_header,
                            message: this.allLabel.Record_success_message,
                            variant: this.allLabel.success_header
                        })
                    );
                    this.summary = "";
                    this.description = "";
                    this.dispatchEventToParent();
                    this.getDataFromBackend();
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

    dispatchEventToParent() {
        const selectedEvent = new CustomEvent("updateprogressfromchild", {
            detail: true
        });
        this.dispatchEvent(selectedEvent);
    }

    getDataFromBackend() {
        getSOMPRecords({ oppId: this.optyId })
            .then(result => {
                this.redFlagsData = [];
                if (result.length > 0) {
                    for (let i = 0; i < result.length; i++) {
                        if (result[i].redFlag === true) {
                            this.redFlagsData.push(result[i]);
                        }
                    }
                }
                //KFS-3356 - code for lesson - 3
                const selectedEvent = new CustomEvent("checkmoduleprogress");
                this.dispatchEvent(selectedEvent);
                //end
            })
            .catch(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.allLabel.SOMPLabel, //KFS-2766
                        message: this.allLabel.ErrorOccured, //KFS-2766
                        variant: "error"
                    })
                );
            });
    }

    handleRefresh() {
        this.dispatchEventToParent();
        this.getDataFromBackend();
    }

    handleMaxLimitError(event) {
        var descriptionLimit = event.target.value;
        if (descriptionLimit.length === 32000) {
            this.showMaxLimitError = true;
        } else {
            this.showMaxLimitError = false;
        }
    }
}