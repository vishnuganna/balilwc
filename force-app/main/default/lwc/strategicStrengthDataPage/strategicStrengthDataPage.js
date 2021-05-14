import { LightningElement, track, api } from "lwc";
import createFoPSSRec from "@salesforce/apex/StrategicStrength.createFoPSSRec";
import getStrategicStrengthList from "@salesforce/apex/StrategicStrength.getStrategicStrengthList";
import getStrategicStrengthRecords from "@salesforce/apex/StrategicStrength.getStrategicStrengthRecords";
import updateFoPStrategicStrengthRecord from "@salesforce/apex/StrategicStrength.updateFoPStrategicStrengthRecord";
import checkAccess from "@salesforce/apex/StrategicStrength.getFoPSSAccess";
import deleteFoPSSRecord from "@salesforce/apex/StrategicStrength.deleteFoPSSRecord";
import { loadStyle } from "lightning/platformResourceLoader";
import styles from "@salesforce/resourceUrl/cssLibrary";
import StrategicStrengthsheader from "@salesforce/label/c.StrategicStrengthsheader";
import StrategicStrengthslistheaderdesc from "@salesforce/label/c.StrategicStrengthslistheaderdesc";
import StrategicStrengthslistheader from "@salesforce/label/c.StrategicStrengthslistheader";
import StrategicStrengthsTitle from "@salesforce/label/c.StrategicStrengthsTitle";
import deleteFoPStrategic_StrengthMessage from "@salesforce/label/c.deleteFoPStrategic_StrengthMessage";
import FieldOfPlayStrategicStrengthURL from "@salesforce/label/c.FieldOfPlayStrategicStrengthURL";
import DeleteFoPStrategic_Strength from "@salesforce/label/c.DeleteFoPStrategic_Strength";
import SS_cannot_exceed_80_characters from "@salesforce/label/c.Strategic_Strength_cannot_exceed_80_characters";
import Description_cannot_exceed_32k_characters from "@salesforce/label/c.maxLimitError";
import FieldOfPlayStrategicStrengthPlural from "@salesforce/label/c.FieldOfPlayStrategicStrengthPlural";

import Save from "@salesforce/label/c.save";
import Cancel from "@salesforce/label/c.cancel";
import Yes from "@salesforce/label/c.yes";
import Delete from "@salesforce/label/c.delete";
import Required_Field_Missing from "@salesforce/label/c.Required_Field_Missing";
import Error_Header from "@salesforce/label/c.error_header";
import Success_header from "@salesforce/label/c.success_header";
import Record_Error_Message from "@salesforce/label/c.Record_error_message";
import Record_Success_Message from "@salesforce/label/c.Record_success_message";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import edit from "@salesforce/label/c.edit"; //KFS-2766
import close from "@salesforce/label/c.close";
import AddNewFoP from "@salesforce/label/c.AddNewFoP";
import RecordDeleted from "@salesforce/label/c.Record_delete_message";

const actions = [
    { label: edit, name: "edit" }, //KFS-2766
    { label: Delete, name: "delete" } //KFS-2766
];

const columns = [
    {
        label: "",
        hideDefaultActions: "true",
        type: "customRecordDisplayType",
        fixedWidth: 21,
        cellAttributes: { alignment: "right", class: "text-position-top" },
        typeAttributes: {
            redFlagStrengthObject: { fieldName: "rfsMarkerWrapper" },
            fieldApiName: "StrategicStrength",
            isRedFlagStrength: true
        }
    },
    {
        label: "Strategic Strength",
        fieldName: "strategicStrength",
        hideDefaultActions: "true",
        cellAttributes: { class: "text-position-top" },
        type: "customRecordDisplayType",
        typeAttributes: {
            showMoreShowLess: false
        }
    },
    {
        label: "Description",
        fieldName: "ssDescription",
        hideDefaultActions: "true",
        wrapText: true,
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

export default class StrategicStrengthDataPage extends LightningElement {
    @api recordId;
    @api item;
    @api getIdFromParent;
    @track currentSSId;
    @track showEditView = false;
    @track showSummaryView = true;
    @track error;
    @track data;
    @track columns = columns;
    @track rowOffset = 0;
    @track _records = [];
    @track foPSS = [];
    @track ssIncompleteError = false;
    queryOffset;
    queryLimit;
    totalRecordCount;
    deleteRecordItem;
    @track isSaveDisabled = false;
    @track showMaxLimitErrorTitle = false;
    @track noDataFlagPresent = false;
    @track newRecordModalFlag = false;
    @track showDeleteModal = false;
    @track noDataPresentFlag = true;
    @track isCreateable = false;
    @track isUpdateable = false;
    @track isDeletable = false;
    @track StrategicStrengthsTitle;
    @track ssDescription;
    @track rfsMarker;
    @track currentRecordItem;
    @track rfsDetails = this.getNewRfsDetails();

    allLabels = {
        StrategicStrengthsheader,
        StrategicStrengthslistheaderdesc,
        StrategicStrengthslistheader,
        StrategicStrengthsTitle,
        deleteFoPStrategic_StrengthMessage,
        DeleteFoPStrategic_Strength,
        FieldOfPlayStrategicStrengthURL,
        FieldOfPlayStrategicStrengthPlural,
        Save,
        Cancel,
        Yes,
        Delete,
        Required_Field_Missing,
        Error_Header,
        Success_header,
        Record_Error_Message,
        Record_Success_Message,
        Description_cannot_exceed_32k_characters,
        SS_cannot_exceed_80_characters,
        close,
        AddNewFoP,
        RecordDeleted
    };

    connectedCallback() {
        this.initializeVariables();
        this.getDataFromBackend();
        this.loadRecords();

        checkAccess().then(result => {
            this.isCreateable = result.isCreateable;
            this.isUpdateable = result.isUpdateable;
            this.isDeletable = result.isDeletable;
        });
    }

    getDataFromBackend() {
        getStrategicStrengthRecords({
            goldSheetId: this.getIdFromParent,
            queryLimit: this.queryLimit,
            queryOffset: this.queryOffset
        }).then(res => {
            this.foPSS = res;

            if (!this.foPSS.length) {
                this.noDataPresentFlag = true;
            } else {
                this.noDataPresentFlag = false;
            }
        });
    }

    getNewRfsDetails() {
        return {
            StrategicStrength: {
                redFlagSelected: false,
                strengthSelected: false,
                noneSelected: true,
                fieldApiName: "StrategicStrength"
            }
        };
    }

    //If marker updated then updated
    handleMarkerChange(event) {
        const eventChangedMarker = event.detail;
        const rfsDetailsUpdate = this.rfsDetails[eventChangedMarker.fieldApiName];
        Object.keys(rfsDetailsUpdate).forEach(key => {
            if (eventChangedMarker[key] !== undefined && eventChangedMarker[key] != null) {
                rfsDetailsUpdate[key] = eventChangedMarker[key];
            }
        });
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

    handleRowAction(event) {
        const action = event.detail.action;
        switch (action.name) {
            case "edit":
                this.showEditView = true;
                this.handleEdit(event);
                break;
            case "delete":
                this.clickDelete(event);
                this.showDeleteModal = true;
                break;
            default:
                break;
        }
    }

    renderedCallback() {
        loadStyle(this, styles); //specified filename
    }

    loadRecords() {
        let flatData;
        let sSList;
        return (
            getStrategicStrengthList({
                goldSheetId: this.getIdFromParent,
                queryLimit: this.queryLimit,
                queryOffset: this.queryOffset
            })
                //return getTrendsList({goldSheetId: "a0R1F000001dxgwUAA", queryLimit: this.queryLimit, queryOffset: this.queryOffset})
                .then(result => {
                    this.totalRecordCount = result.totalRecordCount;
                    sSList = result.fopStrategicStrengthRecords;
                    if (!this.totalRecordCount) {
                        this.noDataPresentFlag = true;
                    } else {
                        sSList.forEach(element => {
                            element.rfsMarkerWrapper = this.convertMarkerMap(element.rfsMarkerWrapper);
                        });
                    }

                    flatData = JSON.parse(JSON.stringify(result.fopStrategicStrengthRecords));
                    let updatedRecords = [...this._records, ...flatData];
                    this._records = updatedRecords;
                    this.error = undefined;
                })
                .catch(error => {
                    this.error = error;
                })
        );
    }

    get records() {
        return this._records.length ? this._records : null;
    }

    initializeVariables() {
        this.ssDescription = "";
        this.StrategicStrengthTitle = "";
        this.queryOffset = 0;
        this.queryLimit = 5;
    }

    handleAddNew() {
        this.newRecordModalFlag = true;
        this.isSaveDisabled = true;
        this.initializeVariables();
        this.rfsDetails = {
            StrategicStrength: {
                redFlagSelected: false,
                strengthSelected: false,
                noneSelected: true,
                fieldApiName: "StrategicStrength"
            }
        };
    }

    toggleSave(event) {
        this.StrategicStrengthTitle = event.target.value;
        if (
            this.StrategicStrengthTitle === null ||
            this.StrategicStrengthTitle === "" ||
            this.StrategicStrengthTitle === " "
        ) {
            this.isSaveDisabled = true;
        } else {
            this.isSaveDisabled = false;
        }
    }

    handleSave() {
        this.isSaveDisabled = true;
        if (
            this.StrategicStrengthTitle.trim() == null ||
            this.StrategicStrengthTitle.trim() === "" ||
            this.StrategicStrengthTitle.trim() === "undefined" ||
            this.StrategicStrengthTitle.trim() === " " ||
            this.showMaxLimitErrorTitle ||
            this.showMaxLimitError
        ) {
            if (!this.showMaxLimitErrorTitle && !this.showMaxLimitError) {
                const evt = new ShowToastEvent({
                    title: this.allLabels.Required_Field_Missing,
                    message: this.allLabels.Required_Field_Missing,
                    variant: this.allLabels.Error_Header
                });
                this.dispatchEvent(evt);
            }
            this.isSaveDisabled = false;
        } else {
            let ssDataToSave = {
                recId: this.recId,
                StrategicStrengthTitle: this.StrategicStrengthTitle,
                ssDescription: this.ssDescription
            };
            this.newRecordModalFlag = false;
            createFoPSSRec({ foPSS: ssDataToSave, accId: this.getIdFromParent, rfsMap: this.rfsDetails })
                .then(() => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: this.allLabels.Success_header,
                            message: this.allLabels.Record_Success_Message,
                            variant: this.allLabels.Success_header
                        })
                    );
                    this.ssDescription = "";
                    this.StrategicStrengthTitle = "";
                    this.noDataPresentFlag = false;
                    this.handleRefresh();
                    this.isSaveDisabled = false;
                })
                .catch(error => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: this.allLabels.Record_Error_Message,
                            message: error.body.message,
                            variant: this.allLabels.Error_Header
                        })
                    );
                });
        }
    }

    handleRefresh() {
        this._records = [];
        this.queryOffset = 0;
        this.queryLimit = 5;
        this.getDataFromBackend();
        this.loadRecords();
    }

    loadMoreData() {
        if (this.totalRecordCount > this.queryOffset) {
            this.queryOffset = this.queryOffset + 5;
            this.loadRecords();
        }
    }

    handleSSTitle(event) {
        this.StrategicStrengthTitle = event.target.value;
        if (
            this.StrategicStrengthTitle.trim() == null ||
            this.StrategicStrengthTitle.trim() === "" ||
            this.StrategicStrengthTitle.trim() === "undefined" ||
            this.StrategicStrengthTitle.trim() === " "
        ) {
            this.ssIncompleteError = true;
        } else {
            this.ssIncompleteError = false;
        }

        let descriptionLimit = event.target.value;

        if (descriptionLimit.length >= 80) {
            this.showMaxLimitErrorTitle = true;
        } else {
            this.showMaxLimitErrorTitle = false;
        }
    }

    handleSSDescription(event) {
        this.ssDescription = event.target.value;
        if (this.ssDescription.length >= 32000) {
            this.showMaxLimitError = true;
        } else {
            this.showMaxLimitError = false;
        }
    }

    handleEdit(event) {
        const row = event.detail.row;
        this.currentRecordItem = JSON.parse(JSON.stringify(row));
        this.recId = this.currentRecordItem.id;
        this.StrategicStrengthTitle = this.currentRecordItem.strategicStrength;
        this.ssDescription = this.currentRecordItem.ssDescription;
        this.rfsDetails = this.currentRecordItem.rfsMarkerWrapper;
    }

    clickDelete(event) {
        const row = event.detail.row;
        this.deleteRecordItem = JSON.parse(JSON.stringify(row));
        this.deleteId = this.deleteRecordItem.id;
    }

    handleDelete() {
        this.recordToDelete = this.deleteId;
        deleteFoPSSRecord({ recordId: this.recordToDelete })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.allLabels.Success_header,
                        message: this.allLabels.RecordDeleted,
                        variant: this.allLabels.Success_header
                    })
                );
                // Dispatches the event.
                this.handleRefresh();
                this.showDeleteModal = false;
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

    handleCancelSave() {
        this.showSummaryView = true;
        this.showEditView = false;
        this.isSaveDisabled = false;
        this.showDeleteModal = false;
        this.newRecordModalFlag = false;
        this.ssIncompleteError = false;
        this.showMaxLimitErrorTitle = false;
        this.showMaxLimitError = false;
        this.rfsDetails = this.getNewRfsDetails();
    }

    handleCancelEdit() {
        this.showSummaryView = true;
        this.showEditView = false;
        this.isSaveDisabled = false;
        this.showDeleteModal = false;
        this.newRecordModalFlag = false;
        this.ssIncompleteError = false;
        this.showMaxLimitErrorTitle = false;
        this.showMaxLimitError = false;
    }
    closeModal() {
        this.showSummaryView = true;
        this.showEditView = false;
        this.isSaveDisabled = false;
        this.showDeleteModal = false;
        this.newRecordModalFlag = false;
    }

    handleEditSave() {
        if (
            this.StrategicStrengthTitle.trim() == null ||
            this.StrategicStrengthTitle.trim() === "" ||
            this.StrategicStrengthTitle.trim() === "undefined" ||
            this.StrategicStrengthTitle.trim() === " " ||
            this.showMaxLimitErrorTitle ||
            this.showMaxLimitError
        ) {
            if (!this.showMaxLimitErrorTitle && !this.showMaxLimitError) {
                const evt = new ShowToastEvent({
                    title: this.allLabels.Required_Field_Missing,
                    message: this.allLabels.Required_Field_Missing,
                    variant: this.allLabels.Error_Header
                });
                this.dispatchEvent(evt);
            }
            this.isSaveDisabled = false;
        } else {
            let ssDataToSave = {
                recId: this.recId,
                StrategicStrengthTitle: this.StrategicStrengthTitle,
                ssDescription: this.ssDescription
            };
            updateFoPStrategicStrengthRecord({
                fopSS: ssDataToSave,
                rfsData: this.rfsDetails,
                goldSheetId: this.getIdFromParent
            })
                .then(result => {
                    if (result.status === "Success") {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: this.allLabels.Success_header,
                                message: this.allLabels.Record_Success_Message,
                                variant: this.allLabels.Success_header
                            })
                        );
                        this.ssDescription = "";
                        this.StrategicStrengthTitle = "";
                        this.handleRefresh();
                        this.showSummaryView = true;
                        this.showEditView = false;
                    } else {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: this.allLabels.Record_Error_Message,
                                message: result.msg,
                                variant: "error"
                            })
                        );
                    }
                })
                .catch(error => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: this.allLabels.Record_Error_Message,
                            message: error.body.message,
                            variant: this.allLabels.Error_Header
                        })
                    );
                });
        }
    }
}