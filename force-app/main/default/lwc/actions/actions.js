import { LightningElement, track, wire, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import checkAccess from "@salesforce/apex/ActionPlanActivitiesActions.getActionAccess";
import getActionRecords from "@salesforce/apex/ActionPlanActivitiesActions.getActionRecords";
import getLookupObjects from "@salesforce/apex/ActionPlanActivitiesActions.getLookupObjects";
import getActionsList from "@salesforce/apex/ActionPlanActivitiesActions.getActionsList";
import countActionsRecords from "@salesforce/apex/ActionPlanActivitiesActions.countActionsRecords";
import createActionsRec from "@salesforce/apex/ActionPlanActivitiesActions.createActionsRec";
import ActionPlanActivitiesActionsURL from "@salesforce/label/c.ActionPlanActivitiesActionsURL";
import deleteActionsRecord from "@salesforce/apex/ActionPlanActivitiesActions.deleteActionsRecord";
import ErrorDeleteFailed from "@salesforce/label/c.ErrorDeleteFailed";
import Error_Header from "@salesforce/label/c.error_header";
import RecordDeleted from "@salesforce/label/c.RecordDeleted";
import ActionsDisplay from "@salesforce/label/c.ActionsDisplay";
import ActionHeader from "@salesforce/label/c.ActionHeader";
import ActionsTitle from "@salesforce/label/c.ActionsTitle";
import Assigned_To from "@salesforce/label/c.Assigned_To";
import DeleteActions from "@salesforce/label/c.DeleteActions";
import DeleteActionsPrompt from "@salesforce/label/c.DeleteActionsPrompt";
import Description from "@salesforce/label/c.Description";
import Due_Date from "@salesforce/label/c.Due_Date";
import Status from "@salesforce/label/c.Status";
import sort_by from "@salesforce/label/c.sort_by";
import Add_New from "@salesforce/label/c.AddNewFoP";
import Description_cannot_exceed_32k_characters from "@salesforce/label/c.maxLimitError";
import Error_Title_Exceeds_80_char from "@salesforce/label/c.Trend_cannot_exceed_80_characters";
import getStatusPicklistValues from "@salesforce/apex/ActionPlanActivitiesActions.getStatusPicklistValues";
import Record_Error_Message from "@salesforce/label/c.Record_error_message";
import Required_Field_Missing from "@salesforce/label/c.Required_Field_Missing";
import Please_fill_the_ActionTitle_Field from "@salesforce/label/c.Please_fill_the_Title_Field";
import Success_header from "@salesforce/label/c.success_header";
import Record_Success_Message from "@salesforce/label/c.Record_success_message";
import actionDate_Created from "@salesforce/label/c.foInvDate_Created";
import actionStatusComplete from "@salesforce/label/c.foInvStatusComplete";
import actionStatusIncomplete from "@salesforce/label/c.foInvStatusIncomplete";
import Edit from "@salesforce/label/c.edit";
import Delete from "@salesforce/label/c.delete";
import Save from "@salesforce/label/c.save";
import Cancel from "@salesforce/label/c.cancel";
import Yes from "@salesforce/label/c.yes";
import close from "@salesforce/label/c.close";
import { loadStyle } from "lightning/platformResourceLoader";
import styles from "@salesforce/resourceUrl/cssLibrary";
import LOCALE from "@salesforce/i18n/locale";

const actions = [
    { label: Edit, name: "edit" },
    { label: Delete, name: "delete" }
];

const columns = [
    {
        label: ActionHeader,
        fieldName: "gsActionTitle",
        hideDefaultActions: "true"
    },
    {
        label: Description,
        fieldName: "gsActionDescription",
        hideDefaultActions: "true",
        type: "customRecordDisplayType",
        typeAttributes: {
            showMoreShowLess: true
        },
        fixedWidth: 650
    },
    {
        label: Assigned_To,
        fieldName: "gsActionAssignedToName",
        hideDefaultActions: "true",
        type: "customRecordDisplayType",
        typeAttributes: {
            showMoreShowLess: true
        }
    },
    {
        label: Due_Date,
        fieldName: "gsActionDueDateString",
        hideDefaultActions: "true",
        type: "customRecordDisplayType",
        typeAttributes: {
            showMoreShowLess: false
        },
        cellAttributes: { alignment: "left" }
    },
    {
        label: Status,
        fieldName: "gsActionStatus",
        hideDefaultActions: "true",
        type: "customRecordDisplayType",
        typeAttributes: {
            status: { fieldName: "gsActionStatus" }
        }
    },
    {
        type: "action",
        typeAttributes: { rowActions: actions },
        cellAttributes: {
            class: { fieldName: "cssClassforReadOnlyUsers" }
        }
    }
];

export default class Actions extends LightningElement {
    @track statusPicklist = [];
    @wire(getStatusPicklistValues)
    statuspicklistResult({ data }) {
        if (data) {
            const result = JSON.parse(data);
            for (let key in result) {
                if (result.hasOwnProperty(key)) {
                    this.statusPicklist.push({ label: key, value: result[key] }); //Here we are creating the array to show on UI.
                }
            }
            this.statusPicklist.reverse();
        }
    }
    @api getIdFromParent;
    @track noDataPresentFlag = true;
    @track newRecordModalFlag = false;
    @track isCreateable = false;
    @track isSaveDisabled = false;
    @track showMaxLimitErrorTitle = false;
    @track objectForLookup;
    @track lookuptargetField;
    @api totalRecordCount = countActionsRecords();
    @track focusInvest = [];
    @track gsActionTitle;
    @track gsActionDescription;
    @track actionDueDate = null;
    @track gsActionStatus = "Incomplete";
    @track gsActionAssignedTo;
    @track borderstyle;
    @track error;
    @track rowOffset = 0;
    @track data;
    @track columns = columns;
    @track ShowModal = false;
    @track recId;
    @track _records = [];
    @track showEditView = false;
    @track showSummaryView = true;
    @track showDeleteModal = false;
    @track statusValue;
    queryOffset;
    queryLimit;
    totalRecordCount;
    deleteRecordItem;
    @track ShowModal = false;
    @track sortFilter;
    @track focInvIncompleteError = false;

    allLabels = {
        sort_by,
        Add_New,
        ActionHeader,
        ActionsDisplay,
        ActionsTitle,
        Assigned_To,
        DeleteActions,
        DeleteActionsPrompt,
        Description,
        Due_Date,
        Status,
        actionDate_Created,
        actionStatusComplete,
        actionStatusIncomplete,
        Error_Title_Exceeds_80_char,
        Description_cannot_exceed_32k_characters,
        Record_Error_Message,
        Success_header,
        Record_Success_Message,
        ErrorDeleteFailed,
        Error_Header,
        Save,
        Cancel,
        Yes,
        close,
        RecordDeleted,
        ActionPlanActivitiesActionsURL,
        Required_Field_Missing,
        Please_fill_the_ActionTitle_Field
    };

    get options() {
        return [
            { label: this.allLabels.actionDate_Created, value: "DateCreated" },
            { label: this.allLabels.actionStatusIncomplete, value: "Incomplete" },
            { label: this.allLabels.actionStatusComplete, value: "Complete" }
        ];
    }

    connectedCallback() {
        this.initializeVariables();
        this.getDataFromBackend();
        this.loadRecords();
        this.getLookupObjects();
        checkAccess().then(result => {
            this.isCreateable = result.isCreateable;
            this.isUpdateable = result.isUpdateable;
            this.isDeletable = result.isDeletable;
        });
    }

    getLookupObjects() {
        getLookupObjects().then(result => {
            if (result) {
                this.objectForLookup = result.lookupOnObject;
                this.lookuptargetField = result.targetField;
            }
        });
    }
    renderedCallback() {
        loadStyle(this, styles);
    }
    filterTableValues(event) {
        this.sortFilter = event.detail.value;
        this.queryLimit = 5;
        this.queryOffset = 0;
        localStorage.setItem("action", this.sortFilter);
        this.handleRefresh();
    }

    handleRowAction(event) {
        const action = event.detail.action;
        switch (action.name) {
            case "edit":
                this.newRecordModalFlag = true;
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

    handleStatusUpdate(event) {
        this.gsActionStatus = event.detail.value;
    }
    handleAssignedToSelected(event) {
        if (event.detail) {
            this.actionAssignedTo = event.detail;
        } else {
            this.actionAssignedTo = null;
        }
    }
    handleDueDateSelected(event) {
        if (event.detail.value) {
            this.actionDueDate = event.detail.value;
        } else {
            this.actionDueDate = null;
        }
    }

    toggleSave(event) {
        this.gsActionTitle = event.target.value;
        if (!this.gsActionTitle || this.gsActionTitle === " ") {
            this.isSaveDisabled = true;
        } else {
            this.isSaveDisabled = false;
        }
    }

    handleEdit(event) {
        const row = event.detail.row;
        this.currentRecordItem = JSON.parse(JSON.stringify(row));
        this.recId = this.currentRecordItem.id;
        this.actionDueDate = this.currentRecordItem.gsActionDueDate;
        this.gsActionDescription = this.currentRecordItem.gsActionDescription;
        this.gsActionTitle = this.currentRecordItem.gsActionTitle;
        this.gsActionStatus = this.currentRecordItem.gsActionStatus;
        this.actionAssignedTo = this.currentRecordItem.gsActionAssignedTo;
        this.isSaveDisabled = false;
    }

    handleAddNew() {
        this.newRecordModalFlag = true;
        this.isSaveDisabled = true;
        this.initializeVariables();
        this.showMaxLimitError = false;
        this.showMaxLimitErrorTitle = false;
    }

    getDataFromBackend() {
        getActionRecords({
            goldSheetId: this.getIdFromParent,
            queryLimit: this.queryLimit,
            queryOffset: this.queryOffset
        })
            .then(res => {
                this.foInvestment = res;
                if (!this.foInvestment.length) {
                    this.noDataPresentFlag = true;
                    this.borderstyle = "slds-m-left-xx_small";
                } else {
                    this.noDataPresentFlag = false;
                    this.borderstyle = "slds-border_left slds-m-left-xx_small";
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

    initializeVariables() {
        this.gsActionTitle = "";
        this.gsActionDescription = "";
        this.actionDueDate = null;
        this.queryOffset = 0;
        this.queryLimit = 5;
        this.recId = null;
        this.gsActionStatus = "Incomplete";
        this.actionAssignedTo = null;
    }

    handleActionsTitle(event) {
        this.gsActionTitle = event.target.value;
        let titleLimit = event.target.value;

        if (titleLimit.length === 80) {
            this.showMaxLimitErrorTitle = true;
        } else {
            this.showMaxLimitErrorTitle = false;
        }
    }

    handleDescription(event) {
        this.gsActionDescription = event.target.value;
        let descriptionLimit = event.target.value;
        if (descriptionLimit.length === 32000) {
            this.showMaxLimitError = true;
        } else {
            this.showMaxLimitError = false;
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
        let actionsList;
        return getActionsList({
            goldSheetId: this.getIdFromParent,
            queryLimit: this.queryLimit,
            queryOffset: this.queryOffset,
            sortFilter: this.sortFilter
        })
            .then(result => {
                this.totalRecordCount = result.totalRecordCount;
                actionsList = result.apActionsRecords;
                if (!this.totalRecordCount) {
                    this.noDataPresentFlag = true;
                    this.borderstyle = "slds-m-left-xx_small";
                } else {
                    this.noDataPresentFlag = false;
                    this.borderstyle = "slds-border_left slds-m-left-xx_small";
                }
                flatData = JSON.parse(JSON.stringify(actionsList));
                let updatedRecords = [...this._records, ...flatData];
                this._records = updatedRecords;
                this._records.forEach(function(gsActionRecord) {
                    gsActionRecord.gsActionDueDateString = new Intl.DateTimeFormat(LOCALE).format(
                        new Date(gsActionRecord.gsActionDueDateString)
                    );
                });
                this.error = undefined;
            })
            .catch(error => {
                this.error = error;
            });
    }

    get records() {
        return this._records.length ? this._records : null;
    }

    handleCancelSave() {
        this.newRecordModalFlag = false;
        this.showMaxLimitError = false;
        this.showMaxLimitErrorTitle = false;
        this.focInvIncompleteError = false;
    }

    handleSave() {
        this.isSaveDisabled = true;

        if (!this.gsActionTitle.trim() || this.gsActionTitle.trim() === " ") {
            const evt = new ShowToastEvent({
                title: this.allLabels.Required_Field_Missing,
                message: this.allLabels.Please_fill_the_ActionTitle_Field,
                variant: this.allLabels.Error_Header
            });
            this.dispatchEvent(evt);
            this.isSaveDisabled = false;
        } else {
            let focusInvestDataToSave = {
                gsActionTitle: this.gsActionTitle,
                gsActionDueDate: this.actionDueDate,
                gsActionStatus: this.gsActionStatus,
                gsActionDescription: this.gsActionDescription,
                gsActionAssignedTo: this.actionAssignedTo,
                goldSheet: this.getIdFromParent,
                id: this.recId
            };
            this.newRecordModalFlag = false;
            createActionsRec({ actionsDataString: JSON.stringify(focusInvestDataToSave) })
                .then(() => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: this.allLabels.Success_header,
                            message: this.allLabels.Record_Success_Message,
                            variant: this.allLabels.Success_header
                        })
                    );
                    this.gsActionDescription = "";
                    this.gsActionTitle = "";
                    this.actionDueDate = null;
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

    clickDelete(event) {
        const row = event.detail.row;
        this.deleteRecordItem = JSON.parse(JSON.stringify(row));
        this.deleteId = this.deleteRecordItem.id;
        this.ShowModal = true;
    }
    closeModal() {
        this.ShowModal = false;
    }

    deleteModal() {
        deleteActionsRecord({ recordId: this.deleteId })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.allLabels.Success_header,
                        message: this.allLabels.RecordDeleted,
                        variant: this.allLabels.Success_header
                    })
                );
                this.ShowModal = false;
                this.handleRefresh();
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
}