import { LightningElement, track, wire, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import checkAccess from "@salesforce/apex/InvestmentProgramController.getInvProgramAccess";
import getInvProgramRecords from "@salesforce/apex/InvestmentProgramController.getInvProgramRecords";
import getLookupObjects from "@salesforce/apex/InvestmentProgramController.getLookupObjects";
import getInvProgramList from "@salesforce/apex/InvestmentProgramController.getInvProgramList";
import countInvProgramRecords from "@salesforce/apex/InvestmentProgramController.countInvProgramRecords";
import createInvProgramsRec from "@salesforce/apex/InvestmentProgramController.createInvProgramsRec";
import deleteInvProgramRecord from "@salesforce/apex/InvestmentProgramController.deleteInvProgramRecord";
import ErrorDeleteFailed from "@salesforce/label/c.ErrorDeleteFailed";
import Error_Header from "@salesforce/label/c.error_header";
import RecordDeleted from "@salesforce/label/c.RecordDeleted";
import DeleteFocusInvestment from "@salesforce/label/c.DeleteFocusInvestment";
import sort_by from "@salesforce/label/c.sort_by";
import Add_New from "@salesforce/label/c.AddNewFoP";
import Description_cannot_exceed_32k_characters from "@salesforce/label/c.maxLimitError";
import Error_Title_Exceeds_80_char from "@salesforce/label/c.Focus_Inv_cannot_exceed_80_characters";
import getStatusPicklistValues from "@salesforce/apex/InvestmentProgramController.getStatusPicklistValues";
import Record_Error_Message from "@salesforce/label/c.Record_error_message";
import Success_header from "@salesforce/label/c.success_header";
import Record_Success_Message from "@salesforce/label/c.Record_success_message";
import foInvDate_Created from "@salesforce/label/c.foInvDate_Created";
import foInvStatusComplete from "@salesforce/label/c.foInvStatusComplete";
import foInvStatusIncomplete from "@salesforce/label/c.foInvStatusIncomplete";
import Assigned_To from "@salesforce/label/c.Assigned_To";
import Save from "@salesforce/label/c.save";
import Cancel from "@salesforce/label/c.cancel";
import Yes from "@salesforce/label/c.yes";
import close from "@salesforce/label/c.close";
import { loadStyle } from "lightning/platformResourceLoader";
import styles from "@salesforce/resourceUrl/cssLibrary";
//

import InvestmentProgramDueDate from "@salesforce/label/c.InvestmentProgramDueDate";
import InvestmentProgramTitle from "@salesforce/label/c.InvestmentProgramTitle";
import InvestmentProgramPlural from "@salesforce/label/c.InvestmentProgramPlural";
import InvestmentProgramURL from "@salesforce/label/c.InvestmentProgramURL";
import InvestmentProgramHeader from "@salesforce/label/c.InvestmentProgram";
import focInv_Description from "@salesforce/label/c.focInv_Description";
import foInvStatus from "@salesforce/label/c.foInvStatus";
import DeleteInvestmentProgram from "@salesforce/label/c.DeleteInvestmentProgram";
import deletePromptInvestmentProgram from "@salesforce/label/c.deletePromptInvestmentProgram";
import LOCALE from "@salesforce/i18n/locale";
import deleteLabel from "@salesforce/label/c.deleteLabel";
import edit from "@salesforce/label/c.edit";
import investmentPrograms from "@salesforce/label/c.investmentPrograms";

const actions = [
    { label: edit, name: "edit" },
    { label: deleteLabel, name: "delete" }
];

const columns = [
    {
        label: investmentPrograms,
        fieldName: "gsInvProgramTitle",
        hideDefaultActions: "true"
        //fixedWidth: 150
    },
    {
        label: focInv_Description,
        fieldName: "gsInvProgramDescription",
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
            showMoreShowLess: false
        }
    },
    {
        label: InvestmentProgramDueDate,
        fieldName: "gsInvProgramDueDateString",
        hideDefaultActions: "true",
        type: "customRecordDisplayType",
        typeAttributes: {
            showMoreShowLess: false
        },
        cellAttributes: { alignment: "left" }
    },

    {
        label: foInvStatus,
        fieldName: "gsInvProgramStatus",
        hideDefaultActions: "true",
        type: "customRecordDisplayType",
        typeAttributes: {
            status: { fieldName: "gsInvProgramStatus" }
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

export default class InvestmentProgram extends LightningElement {
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
    @track showMaxLimitError = false;
    @track objectForLookup;
    @track lookuptargetField;
    @api totalRecordCount = countInvProgramRecords();
    @track focusInvest = [];
    @track gsInvProgramTitle;
    @track gsInvProgramDescription;
    @track gsInvProgramDueDate = null;
    @track gsInvProgramStatus = "Incomplete";
    @track gsInvProgramAssignedTo;
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
    @track borderstyle;
    queryOffset;
    queryLimit;
    totalRecordCount;
    deleteRecordItem;
    @track ShowModal = false;
    @track sortFilter;
    @track focInvIncompleteError = false;

    allLabels = {
        DeleteFocusInvestment,
        sort_by,
        Add_New,
        foInvDate_Created,
        foInvStatusComplete,
        foInvStatusIncomplete,
        Error_Title_Exceeds_80_char,
        Description_cannot_exceed_32k_characters,
        Record_Error_Message,
        Success_header,
        Record_Success_Message,
        ErrorDeleteFailed,
        Error_Header,
        Save,
        Cancel,
        foInvStatus,
        focInv_Description,
        Yes,
        close,
        RecordDeleted,
        Assigned_To,
        deletePromptInvestmentProgram,
        DeleteInvestmentProgram,
        InvestmentProgramHeader,
        InvestmentProgramURL,
        InvestmentProgramPlural,
        InvestmentProgramTitle,
        InvestmentProgramDueDate
    };

    get options() {
        return [
            { label: this.allLabels.foInvDate_Created, value: "DateCreated" },
            { label: this.allLabels.foInvStatusIncomplete, value: "Incomplete" },
            { label: this.allLabels.foInvStatusComplete, value: "Complete" }
        ];
    }

    connectedCallback() {
        this.noDataPresentFlag = false;
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
        localStorage.setItem("investmentPrograms", this.sortFilter);

        this.handleRefresh();
    }

    handleRowInvProgram(event) {
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
        this.gsInvProgramStatus = event.detail.value;
    }
    handleAssignedToSelected(event) {
        if (event.detail) {
            this.gsInvProgramAssignedTo = event.detail;
        } else {
            this.gsInvProgramAssignedTo = null;
        }
    }
    handleDueDateSelected(event) {
        if (event.detail.value) {
            this.gsInvProgramDueDate = event.detail.value;
        } else {
            this.gsInvProgramDueDate = null;
        }
    }

    handleDescription(event) {
        this.gsInvProgramDescription = event.target.value;
        let descriptionLimit = event.target.value;
        if (descriptionLimit.length === 32000) {
            this.showMaxLimitError = true;
        } else {
            this.showMaxLimitError = false;
        }
    }

    toggleSave(event) {
        this.gsInvProgramTitle = event.target.value;
        if (this.gsInvProgramTitle === null || this.gsInvProgramTitle === "" || this.gsInvProgramTitle === " ") {
            this.isSaveDisabled = true;
        } else {
            this.isSaveDisabled = false;
        }
    }

    handleEdit(event) {
        const row = event.detail.row;
        this.currentRecordItem = JSON.parse(JSON.stringify(row));
        this.recId = this.currentRecordItem.id;
        this.gsInvProgramDueDate = this.currentRecordItem.gsInvProgramDueDate;
        this.gsInvProgramDescription = this.currentRecordItem.gsInvProgramDescription;
        this.gsInvProgramTitle = this.currentRecordItem.gsInvProgramTitle;
        this.gsInvProgramStatus = this.currentRecordItem.gsInvProgramStatus;
        this.gsInvProgramAssignedTo = this.currentRecordItem.gsInvProgramAssignedTo;
        this.isSaveDisabled = false;
        this.showMaxLimitError = false;
        this.showMaxLimitErrorTitle = false;
    }

    handleAddNew() {
        this.newRecordModalFlag = true;
        this.isSaveDisabled = true;
        this.showMaxLimitError = false;
        this.showMaxLimitErrorTitle = false;
        this.initializeVariables();
    }

    getDataFromBackend() {
        getInvProgramRecords({
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
        this.gsInvProgramTitle = "";
        this.gsInvProgramDescription = "";
        this.gsInvProgramDueDate = null;
        this.queryOffset = 0;
        this.queryLimit = 5;
        this.recId = null;
        this.gsInvProgramStatus = "Incomplete";
        this.gsInvProgramAssignedTo = null;
    }

    handlefoInvestmentTitle(event) {
        this.gsInvProgramTitle = event.target.value;
        let descriptionLimit = event.target.value;

        if (descriptionLimit.length === 80) {
            this.showMaxLimitErrorTitle = true;
        } else {
            this.showMaxLimitErrorTitle = false;
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
        let invProgList;
        return getInvProgramList({
            goldSheetId: this.getIdFromParent,
            queryLimit: this.queryLimit,
            queryOffset: this.queryOffset,
            sortFilter: this.sortFilter
        })
            .then(result => {
                this.totalRecordCount = result.totalRecordCount;
                invProgList = result.apActionsRecords;
                if (!this.totalRecordCount) {
                    this.noDataPresentFlag = true;
                    this.borderstyle = "slds-m-left-xx_small";
                } else {
                    this.noDataPresentFlag = false;
                    this.borderstyle = "slds-border_left slds-m-left-xx_small";
                }
                flatData = JSON.parse(JSON.stringify(invProgList));
                let updatedRecords = [...this._records, ...flatData];
                this._records = updatedRecords;
                this._records.forEach(function(gsInvProgramRecord) {
                    gsInvProgramRecord.gsInvProgramDueDateString = new Intl.DateTimeFormat(LOCALE).format(
                        new Date(gsInvProgramRecord.gsInvProgramDueDateString)
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

        if (
            this.gsInvProgramTitle.trim() == null ||
            this.gsInvProgramTitle.trim() === "" ||
            this.gsInvProgramTitle.trim() === "undefined" ||
            this.gsInvProgramTitle.trim() === " "
        ) {
            const evt = new ShowToastEvent({
                title: this.allLabels.Required_Field_Missing,
                message: this.allLabels.Please_fill_the_TrendTitle_Field,
                variant: this.allLabels.Error_Header
            });
            this.dispatchEvent(evt);
            this.isSaveDisabled = false;
        } else {
            let focusInvestDataToSave = {
                gsInvProgramTitle: this.gsInvProgramTitle,
                gsInvProgramDueDate: this.gsInvProgramDueDate,
                gsInvProgramStatus: this.gsInvProgramStatus,
                gsInvProgramDescription: this.gsInvProgramDescription,
                gsInvProgramAssignedTo: this.gsInvProgramAssignedTo,
                goldSheet: this.getIdFromParent,
                id: this.recId
            };
            this.newRecordModalFlag = false;
            createInvProgramsRec({ inputString: JSON.stringify(focusInvestDataToSave) })
                .then(() => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: this.allLabels.Success_header,
                            message: this.allLabels.Record_Success_Message,
                            variant: this.allLabels.Success_header
                        })
                    );
                    this.gsInvProgramDescription = "";
                    this.gsInvProgramTitle = "";
                    this.gsInvProgramDueDate = null;
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
        deleteInvProgramRecord({ recordId: this.deleteId })
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