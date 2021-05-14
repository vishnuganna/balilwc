import { LightningElement, api, track } from "lwc";
import deleteFOPORec from "@salesforce/apex/FieldOfPlayOppController.deleteFOPORec";
import updateFOPORec from "@salesforce/apex/FieldOfPlayOppController.updateFOPORec";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import checkAccess from "@salesforce/apex/FieldOfPlayOppController.getFoPOpportunityAccess";
import Success_header from "@salesforce/label/c.success_header";
import Record_Success_Message from "@salesforce/label/c.Record_success_message";
import Description_cannot_exceed_32k_characters from "@salesforce/label/c.maxLimitError";
import RecordDeleted from "@salesforce/label/c.RecordDeleted";
import objectForLookup from "@salesforce/apex/FieldOfPlayOppController.getObjectName";

import cancel from "@salesforce/label/c.cancel";
import saveLabel from "@salesforce/label/c.save";
import fieldOfPlayOpportunities from "@salesforce/label/c.fieldOfPlayOpportunities";
import fopOpportunityTitle from "@salesforce/label/c.fopOpportunityTitle";
import fopOpportunitykpi from "@salesforce/label/c.fopOpportunitykpi";
import fopOpportunityOwner from "@salesforce/label/c.fopOpportunityOwner";
import description from "@salesforce/label/c.Description";
import addDescription from "@salesforce/label/c.Description";

import fopOpportunityDelete from "@salesforce/label/c.fopOpportunityDelete";
import deleteFopOpportunityMessage from "@salesforce/label/c.deleteFopOpportunityMessage";
import yes from "@salesforce/label/c.yes";
import unexpectederrormsg from "@salesforce/label/c.unexpectederrormsg";
import Error_Header from "@salesforce/label/c.error_header";
import { loadStyle } from "lightning/platformResourceLoader";
import styles from "@salesforce/resourceUrl/cssLibrary";
import deleteLabel from "@salesforce/label/c.deleteLabel";
import edit from "@salesforce/label/c.edit";
import CategoryOpportunity from "@salesforce/label/c.CategoryOpportunity";
import BusinessRuleOwner from "@salesforce/label/c.BusinessRuleOwner";
import ActionDescription from "@salesforce/label/c.ActionDescription";
import close from "@salesforce/label/c.close";

const actions = [
    { label: edit, name: "edit" },
    { label: deleteLabel, name: "delete" }
];

const columns = [
    {
        label: "",
        hideDefaultActions: "true",
        type: "customRecordDisplayType",
        fixedWidth: 21,
        cellAttributes: { class: "text-position-top" },
        typeAttributes: {
            redFlagStrengthObject: { fieldName: "rfsMarkerWrapper" },
            fieldApiName: "oppTitle",
            isRedFlagStrength: true
        }
    },
    {
        label: CategoryOpportunity,
        fieldName: "title",
        hideDefaultActions: "true",
        type: "customRecordDisplayType",
        cellAttributes: { class: "text-position-top" },
        typeAttributes: {
            showMoreShowLess: false
        }
    },
    {
        label: "",
        hideDefaultActions: "true",
        type: "customRecordDisplayType",
        fixedWidth: 21,
        cellAttributes: { alignment: "right", class: "text-position-top" },
        typeAttributes: {
            redFlagStrengthObject: { fieldName: "rfsMarkerWrapper" },
            fieldApiName: "kpi",
            isRedFlagStrength: true
        }
    },
    {
        label: fopOpportunitykpi,
        fieldName: "kpi",
        hideDefaultActions: "true",
        cellAttributes: { class: "text-position-top" },
        type: "customRecordDisplayType",
        typeAttributes: {
            showMoreShowLess: false
        }
    },
    {
        label: "",
        hideDefaultActions: "true",
        type: "customRecordDisplayType",
        fixedWidth: 21,
        cellAttributes: { alignment: "right", class: "text-position-top" },
        typeAttributes: {
            redFlagStrengthObject: { fieldName: "rfsMarkerWrapper" },
            fieldApiName: "strategicPlayer",
            isRedFlagStrength: true
        }
    },
    {
        label: BusinessRuleOwner,
        fieldName: "ownerName",
        hideDefaultActions: "true",
        cellAttributes: { class: "text-position-top" },
        typeAttributes: { label: { fieldName: "ownerName" }, target: "_blank" }
    },
    {
        label: "",
        hideDefaultActions: "true",
        type: "customRecordDisplayType",
        fixedWidth: 21,
        cellAttributes: { alignment: "right", class: "text-position-top" },
        typeAttributes: {
            redFlagStrengthObject: { fieldName: "rfsMarkerWrapper" },
            fieldApiName: "description",
            isRedFlagStrength: true
        }
    },
    {
        label: ActionDescription,
        fieldName: "description",
        hideDefaultActions: "true",
        cellAttributes: { class: "text-position-top" },
        type: "customRecordDisplayType",
        typeAttributes: {
            showMoreShowLess: true
        }
    },
    {
        type: "action",
        typeAttributes: { rowActions: actions },
        cellAttributes: {
            class: { fieldName: "cssClassforReadOnlyUsers" }
        } /*cellAttributes: { class: "cssAccessCheck"}  */
    }
];
export default class fopOpportunitiesDataPage extends LightningElement {
    // @api fopoRecList;
    @track _fopoRecList;

    @api
    get fopoRecList() {
        return this._fopoRecList;
    }

    set fopoRecList(value) {
        this.setAttribute("fopoRecList", value);
        this._fopoRecList = value;
    }

    @track columns = columns;
    @track ShowDeleteModal = false;
    @track showEditModel = false;
    @track recIdForDelete;
    @track editedRecData;
    @track saveEnableFlag = false;
    @track rowOffset = 0;
    @api goldsheetId;
    @track showMaxLimitError = false;
    @track objectForLookupField;
    @track lookuptargetField;
    deleteRecordItem;
    allLabels = {
        Success_header,
        Record_Success_Message,
        RecordDeleted,
        Description_cannot_exceed_32k_characters,
        cancel,
        saveLabel,
        fieldOfPlayOpportunities,
        fopOpportunityTitle,
        fopOpportunitykpi,
        description,
        addDescription,
        fopOpportunityOwner,
        yes,
        fopOpportunityDelete,
        deleteFopOpportunityMessage,
        unexpectederrormsg,
        Error_Header,
        close
    };

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

        checkAccess().then(result => {
            this.isUpdateable = result.isUpdateable;
            this.isDeletable = result.isDeletable;
        });
    }
    renderedCallback() {
        loadStyle(this, styles);
    }

    handleRowAction(event) {
        const action = event.detail.action;
        switch (action.name) {
            case "edit":
                this.showEditModel = true;
                this.saveEnableFlag = false;
                this.editedRecData = JSON.parse(JSON.stringify(event.detail.row));
                this.rfsDetails = JSON.parse(JSON.stringify(this.editedRecData.rfsMarkerWrapper));
                break;
            case "delete":
                this.ShowDeleteModal = true;
                this.clickDelete(event);
                break;
            default:
                break;
        }
    }

    clickDelete(event) {
        const row = event.detail.row;
        this.deleteRecordItem = JSON.parse(JSON.stringify(row));
        this.deleteId = this.deleteRecordItem.id;
    }

    handleDeleteModalYes() {
        this.recIdForDelete = this.deleteId;
        this.ShowDeleteModal = false;
        deleteFOPORec({ recId: this.recIdForDelete })
            .then(() => {
                const selectedEvent = new CustomEvent("refreshscreen", {
                    detail: true
                });
                this.dispatchEvent(selectedEvent);

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.allLabels.Success_header,
                        message: this.allLabels.RecordDeleted,
                        variant: this.allLabels.Success_header
                    })
                );
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

    handleDeleteModalNo() {
        this.ShowDeleteModal = false;
    }

    handleEditModalSave() {
        this.saveEnableFlag = true;
        let recordData = {
            Title: this.editedRecData.title,
            KPI: this.editedRecData.kpi,
            Owner: this.editedRecData.ownerId ? this.editedRecData.ownerId : null,
            Description: this.editedRecData.description,
            Id: this.editedRecData.id
        };
        updateFOPORec({ fopoRecData: recordData, rfsData: this.rfsDetails, goldSheetId: this.goldsheetId })
            .then(() => {
                this.showEditModel = false;
                this.fopoRecList = [];
                this.saveEnableFlag = false;
                this.editedRecData.title = "";
                const selectedEvent = new CustomEvent("refreshscreen", {
                    detail: true
                });
                this.dispatchEvent(selectedEvent);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.allLabels.Success_header,
                        message: this.allLabels.Record_Success_Message,
                        variant: this.allLabels.Success_header
                    })
                );
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

    handleEditeModalCancel() {
        this.showEditModel = false;
    }

    hangleTitleChange(event) {
        this.editedRecData.title = event.target.value;
        /* if (this.editedRecData.title !== "") {
            this.saveEnableFlag = false;
        } else if (this.editedRecData.title === "") {
            this.saveEnableFlag = true;
        }*/
        const targetElement = event.target;

        if (targetElement.value.length > 80 || !this.editedRecData.title) {
            this.saveEnableFlag = true;
            targetElement.setCustomValidity("Title Max Length should be 80");
        } else {
            this.saveEnableFlag = false;
            targetElement.setCustomValidity("");
        }
        targetElement.reportValidity();
        if (this.editedRecData.description && this.editedRecData.description.length > 32000) {
            this.saveEnableFlag = true;
        }
    }

    handleKIPChange(event) {
        this.editedRecData.kpi = event.target.value;
    }

    handleDescChange(event) {
        this.editedRecData.description = event.target.value;
        /* if (event.target.value.length === 32000) {
            this.showMaxLimitError = true;
        } else {
            this.showMaxLimitError = false;
        }*/
        const targetElement = event.target;

        if (targetElement.value.length > 32000) {
            this.saveEnableFlag = true;
            targetElement.setCustomValidity(Description_cannot_exceed_32k_characters);
        } else {
            this.saveEnableFlag = false;
            targetElement.setCustomValidity("");
        }
        targetElement.reportValidity();
        if (!this.editedRecData.title || this.editedRecData.title.length > 80) {
            this.saveEnableFlag = true;
        }
    }

    handleContactSelcted(event) {
        this.editedRecData.ownerId = event.detail;
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

    handleFlags() {
        this.rfsDetails = this.getNewRfsDetails();
    }
}