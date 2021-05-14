import { LightningElement, track, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import createSummaryRec from "@salesforce/apex/MyPositionController.createSummaryRec";
import getSOMPRecords from "@salesforce/apex/MyPositionController.getSOMPRecords";
import STRENGTHS from "@salesforce/label/c.STRENGTHS";
import Summary from "@salesforce/label/c.Summary";
import Description from "@salesforce/label/c.Description";
import ErrorMax32kCharacters from "@salesforce/label/c.maxLimitError";
import save from "@salesforce/label/c.save";
import cancel from "@salesforce/label/c.cancel";
import AddNewStrength from "@salesforce/label/c.AddNewStrength";
import Required_Field_Missing from "@salesforce/label/c.Required_Field_Missing";
import Please_fill_the_Summary_Field from "@salesforce/label/c.Please_fill_the_Summary_Field";
import error_header from "@salesforce/label/c.error_header";
import success_header from "@salesforce/label/c.success_header";
import Record_error_message from "@salesforce/label/c.Record_error_message";
import Record_success_message from "@salesforce/label/c.Record_success_message";
import sumPositionStrengthURL from "@salesforce/label/c.sumPositionStrengthURL";
import Summary_cannot_exceed_256_characters from "@salesforce/label/c.Summary_cannot_exceed_256_characters";
import checkAccess from "@salesforce/apex/MyPositionController.getMypositionAccess";
import getOppId from "@salesforce/apex/StrategyEngine.getOppId";

export default class StrengthsMainPage extends LightningElement {
    newRecordScreenFlag = false;
    description = "";
    summary = "";
    showMaxLimitError = false;

    // @api getIdFromParent;
    @track _getIdFromParent;
    @track saveDisableFlag = true;
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

    @track strenghtData = [];
    @track isCreateable = false;
    @track isUpdateable = false;
    @track isDeletable = false;
    @api recordId;
    @track optyId = "";

    allLabel = {
        STRENGTHS,
        Summary,
        Description,
        ErrorMax32kCharacters,
        save,
        cancel,
        AddNewStrength,
        Required_Field_Missing,
        Please_fill_the_Summary_Field,
        error_header,
        success_header,
        Record_error_message,
        Record_success_message,
        sumPositionStrengthURL,
        Summary_cannot_exceed_256_characters
    };

    handleCreateNewRec() {
        this.newRecordScreenFlag = true;
        //KFS-814
        this.template.querySelectorAll("c-strengths-data-page").forEach(item => {
            item.closeEditModal();
        });
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
            let strengthDataToSave = {
                summary: this.summary,
                description: this.description,
                strength: "true"
            };
            this.newRecordScreenFlag = false;
            createSummaryRec({ sumData: strengthDataToSave, oppId: this.optyId })
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

    dispatchDataEventToParent() {
        const selectedEvent = new CustomEvent("fetchdata", {
            detail: this.isCreateable
        });
        if (!this.isCreateable) this.dispatchEvent(selectedEvent);
    }

    getDataFromBackend() {
        getSOMPRecords({ oppId: this.optyId })
            .then(res => {
                checkAccess().then(result => {
                    this.isCreateable = result.isCreateable;
                    this.isUpdateable = result.isUpdateable;
                    this.isDeletable = result.isDeletable;
                    this.strenghtData = [];
                    if (res.length > 0) {
                        for (let i = 0; i < res.length; i++) {
                            if (res[i].strenghtFlag === true) this.strenghtData.push(res[i]);
                        }
                    } else {
                        this.dispatchDataEventToParent();
                    }
                });
                //KFS-3356 - code for lesson - 3
                const selectedEvent = new CustomEvent("checkmoduleprogress");
                this.dispatchEvent(selectedEvent);
                //end
            })
            .catch(() => {
                /* eslint-disable no-console */
                //console.log("Error while fetching summary of my position data " + JSON.stringify(error));
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