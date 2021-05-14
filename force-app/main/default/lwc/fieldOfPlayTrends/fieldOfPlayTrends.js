import { LightningElement, track, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import createFoPTrendRec from "@salesforce/apex/FieldOfPlayTrend.createFoPTrendRec";
import getTrendsRecords from "@salesforce/apex/FieldOfPlayTrend.getTrendsRecords";
import updateFoPTrendRecord from "@salesforce/apex/FieldOfPlayTrend.updateFoPTrendRecord";
import getTrendsList from "@salesforce/apex/FieldOfPlayTrend.getTrendsList";
import deleteFoPTrendRecords from "@salesforce/apex/FieldOfPlayTrend.deleteFoPTrendRecord";
import checkAccess from "@salesforce/apex/FieldOfPlayTrend.getFoPTrendAccess";
import FieldOfPlayTrend from "@salesforce/label/c.FieldOfPlayTrend";
import FieldOfPlayTrendPlural from "@salesforce/label/c.FieldOfPlayTrendPlural";
import FieldOfPlayTrendURL from "@salesforce/label/c.FieldOfPlayTrendURL";
import AddNewFoPTrend from "@salesforce/label/c.AddNewFoP";
import Trend from "@salesforce/label/c.TrendTitle";
import Required_Field_Missing from "@salesforce/label/c.Required_Field_Missing";
import Please_fill_the_TrendTitle_Field from "@salesforce/label/c.Please_fill_the_TrendTitle_Field";
import Trend_cannot_exceed_80_characters from "@salesforce/label/c.Trend_cannot_exceed_80_characters";
import TrendDescription from "@salesforce/label/c.Description";
import Description_cannot_exceed_32k_characters from "@salesforce/label/c.maxLimitError";
import Save from "@salesforce/label/c.save";
import Cancel from "@salesforce/label/c.cancel";
import Yes from "@salesforce/label/c.yes";
import Error_Header from "@salesforce/label/c.error_header";
import Success_header from "@salesforce/label/c.success_header";
import Record_Error_Message from "@salesforce/label/c.Record_error_message";
import Trend_Error_Message from "@salesforce/label/c.Scorecard_Template_Required_Error";
import Record_Success_Message from "@salesforce/label/c.Record_success_message";
import RecordDeleted from "@salesforce/label/c.RecordDeleted";
import Delete from "@salesforce/label/c.delete";
import DeleteFoPTrendMessage from "@salesforce/label/c.deleteFoPTrendMessage";
import DeleteFoPTrend from "@salesforce/label/c.DeleteFoPTrend";
import ErrorDeleteFailed from "@salesforce/label/c.ErrorDeleteFailed";
import { loadStyle } from "lightning/platformResourceLoader";
import styles from "@salesforce/resourceUrl/cssLibrary";
import edit from "@salesforce/label/c.edit";
import close from "@salesforce/label/c.close";

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
            fieldApiName: "TrendTitle",
            isRedFlagStrength: true
        }
    },
    {
        label: "Trend",
        fieldName: "trendTitle",
        hideDefaultActions: "true",
        type: "customRecordDisplayType",
        cellAttributes: { class: "text-position-top customCSSClass" },
        typeAttributes: {
            showMoreShowLess: false
        }
    },
    {
        label: "Description",
        fieldName: "trendDescription",
        hideDefaultActions: "true",
        type: "customRecordDisplayType",
        cellAttributes: { class: "text-position-top" },
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
// cellAttributes: { class: "action-buttion-position text-position-top cssClassforReadOnlyUsers" }
export default class FieldOfPlayTrends extends LightningElement {
    @api getIdFromParent;
    @track showEditView = false;
    @track showSummaryView = true;
    @track showDeleteModal = false;
    @track error;
    @track data;
    @track columns = columns;
    @track rowOffset = 0;
    @track _records = [];
    @track showMaxLimitErrorTitle = false;
    @track recId;
    @track foPTrend = [];
    @track noDataPresentFlag = true;
    @track trendTitle;
    @track trendDescription;
    @track currentRecordItem;
    @track isSaveDisabled = false;
    @track isCreateable = false;
    @track isUpdateable = false;
    @track isDeletable = false;
    @track newRecordModalFlag = false;
    @track showMaxLimitError = false;
    @track rfsDetails = this.getNewRfsDetails();
    @track rfsMap = {};
    @track rfsMarker;
    queryOffset;
    queryLimit;
    totalRecordCount;
    deleteRecordItem;
    @track trendIncompleteError = false;
    trendTitle = "";
    trendDescription = "";

    allLabels = {
        FieldOfPlayTrendPlural,
        FieldOfPlayTrend,
        TrendDescription,
        Trend,
        Save,
        Yes,
        Cancel,
        Delete,
        AddNewFoPTrend,
        Required_Field_Missing,
        Error_Header,
        ErrorDeleteFailed,
        RecordDeleted,
        DeleteFoPTrendMessage,
        DeleteFoPTrend,
        Trend_Error_Message,
        FieldOfPlayTrendURL,
        Success_header,
        Record_Error_Message,
        Record_Success_Message,
        Trend_cannot_exceed_80_characters,
        Please_fill_the_TrendTitle_Field,
        Description_cannot_exceed_32k_characters,
        close
    };

    initializeVariables() {
        this.trendDescription = "";
        this.trendTitle = "";
        this.queryOffset = 0;
        this.queryLimit = 5;
    }

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
    renderedCallback() {
        loadStyle(this, styles);
    }

    getDataFromBackend() {
        getTrendsRecords({
            goldSheetId: this.getIdFromParent,
            queryLimit: this.queryLimit,
            queryOffset: this.queryOffset
        })
            .then(res => {
                this.foPTrend = res;
                if (!this.foPTrend.length) {
                    this.noDataPresentFlag = true;
                } else {
                    this.noDataPresentFlag = false;
                }
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.allLabels.Error_Header,
                        message: error.body.message,
                        variant: this.allLabels.Error_Header
                    })
                );
            });
    }

    getNewRfsDetails() {
        return {
            TrendTitle: {
                redFlagSelected: false,
                strengthSelected: false,
                noneSelected: true,
                fieldApiName: "TrendTitle"
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

    handleAddNew() {
        this.newRecordModalFlag = true;
        this.showMaxLimitErrorTitle = false;
        this.showMaxLimitError = false;
        this.isSaveDisabled = true;
        this.initializeVariables();
        this.rfsDetails = {
            TrendTitle: {
                redFlagSelected: false,
                strengthSelected: false,
                noneSelected: true,
                fieldApiName: "TrendTitle"
            }
        };
    }

    toggleSave(event) {
        this.trendTitle = event.target.value;
        if (this.trendTitle === null || this.trendTitle === "" || this.trendTitle === " ") {
            this.isSaveDisabled = true;
        } else {
            this.isSaveDisabled = false;
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

    validateInputs(event) {
        var allValid = true;
        var targetElement = event.target;
        if (event.target.name === "trendTitle") {
            this.title = targetElement.value;
            this.trendTitle = targetElement.value;
            if (this.title !== "") {
                this.isSaveDisabled = false;
            } else if (this.title === "") {
                this.isSaveDisabled = true;
            }
            if (targetElement.value.length > 80) {
                this.isSaveDisabled = true;
                targetElement.setCustomValidity("Trend Title Max Length Should Be 80");
            } else {
                this.isSaveDisabled = false;
                targetElement.setCustomValidity("");
            }
            targetElement.reportValidity();
        }
        if (event.target.name === "Description") {
            if (targetElement.value.length > 32000) {
                this.isSaveDisabled = true;
                this.saveEnableFlag = true;
                this.showMaxLimitError = true;
            } else {
                this.showMaxLimitError = false;
                this.isSaveDisabled = false;
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

    handleSave() {
        this.isSaveDisabled = true;
        if (
            this.trendTitle.trim() == null ||
            this.trendTitle.trim() === "" ||
            this.trendTitle.trim() === "undefined" ||
            this.trendTitle.trim() === " "
        ) {
            const evt = new ShowToastEvent({
                title: this.allLabels.Required_Field_Missing,
                message: this.allLabels.Please_fill_the_TrendTitle_Field,
                variant: this.allLabels.Error_Header
            });
            this.dispatchEvent(evt);
            this.isSaveDisabled = false;
        } else {
            let trendDataToSave = {
                trendTitle: this.trendTitle,
                trendDescription: this.trendDescription
            };
            this.newRecordModalFlag = false;
            createFoPTrendRec({ foPTrend: trendDataToSave, accId: this.getIdFromParent, rfsMap: this.rfsDetails })
                .then(() => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: this.allLabels.Success_header,
                            message: this.allLabels.Record_Success_Message,
                            variant: this.allLabels.Success_header
                        })
                    );
                    this.trendDescription = "";
                    this.trendTitle = "";
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

    handleTrendTitle(event) {
        this.trendTitle = event.target.value;
        if (
            this.trendTitle.trim() == null ||
            this.trendTitle.trim() === "" ||
            this.trendTitle.trim() === "undefined" ||
            this.trendTitle.trim() === " "
        ) {
            this.trendIncompleteError = true;
        } else {
            this.trendIncompleteError = false;
        }

        let descriptionLimit = event.target.value;

        if (descriptionLimit.length === 80) {
            this.showMaxLimitErrorTitle = true;
        } else {
            this.showMaxLimitErrorTitle = false;
        }
    }

    handleTrendDescription(event) {
        this.trendDescription = event.target.value;
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

    loadMoreData() {
        if (this.totalRecordCount > this.queryOffset) {
            this.queryOffset = this.queryOffset + 5;
            this.loadRecords();
        }
    }

    loadRecords() {
        let flatData;
        let trendList;
        return getTrendsList({
            goldSheetId: this.getIdFromParent,
            queryLimit: this.queryLimit,
            queryOffset: this.queryOffset
        })
            .then(result => {
                this.totalRecordCount = result.totalRecordCount;
                trendList = result.fopTrendsRecords;
                if (!this.totalRecordCount) {
                    this.noDataPresentFlag = true;
                } else {
                    trendList.forEach(element => {
                        element.rfsMarkerWrapper = this.convertMarkerMap(element.rfsMarkerWrapper);
                    });
                }
                flatData = JSON.parse(JSON.stringify(result.fopTrendsRecords));
                let updatedRecords = [...this._records, ...flatData];
                this._records = updatedRecords;
                this.error = undefined;
            })
            .catch(error => {
                this.error = error;
            });
    }

    get records() {
        return this._records.length ? this._records : null;
    }

    clickDelete(event) {
        const row = event.detail.row;
        this.deleteRecordItem = JSON.parse(JSON.stringify(row));
        this.deleteId = this.deleteRecordItem.id;
    }

    handleDelete() {
        this.recordToDelete = this.deleteId;
        deleteFoPTrendRecords({ recordId: this.recordToDelete })
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
        this.trendIncompleteError = false;
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
        this.trendIncompleteError = false;
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

    handleEdit(event) {
        const row = event.detail.row;
        this.currentRecordItem = JSON.parse(JSON.stringify(row));
        this.recId = this.currentRecordItem.id;
        this.trendTitle = this.currentRecordItem.trendTitle;
        this.trendDescription = this.currentRecordItem.trendDescription;
        this.rfsDetails = this.currentRecordItem.rfsMarkerWrapper;
        this.showMaxLimitErrorTitle = false;
        this.showMaxLimitError = false;
    }

    handleEditSave() {
        if (
            this.trendTitle.trim() == null ||
            this.trendTitle.trim() === "" ||
            this.trendTitle.trim() === "undefined" ||
            this.trendTitle.trim() === " "
        ) {
            const evt = new ShowToastEvent({
                title: this.allLabels.Required_Field_Missing,
                message: this.allLabels.Please_fill_the_TrendTitle_Field,
                variant: this.allLabels.Error_Header
            });
            this.dispatchEvent(evt);
            this.isSaveDisabled = false;
        } else {
            let trendDataToSave = {
                recId: this.recId,
                trendTitle: this.trendTitle,
                trendDescription: this.trendDescription
            };

            updateFoPTrendRecord({
                foPTrend: trendDataToSave,
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
                        this.trendDescription = "";
                        this.trendTitle = "";
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

    handleRefresh() {
        this._records = [];
        this.queryOffset = 0;
        this.queryLimit = 5;
        this.getDataFromBackend();
        this.loadRecords();

        if (this._records.length > 5) {
            this.template.querySelector("fopDatatableClass").addClass("applyScrollToDataTable");
        }
    }
}