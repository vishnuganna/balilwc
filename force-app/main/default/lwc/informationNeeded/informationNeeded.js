import { LightningElement, track, wire, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import checkAccess from "@salesforce/apex/InformationNeeded.getInformationNeededAccess";
import getInformationNeededRecords from "@salesforce/apex/InformationNeeded.getInformationNeededRecords";
import getLookupObjects from "@salesforce/apex/InformationNeeded.getLookupObjects";
import getInformationNeededList from "@salesforce/apex/InformationNeeded.getInformationNeededList";
import countInformationneededRecords from "@salesforce/apex/InformationNeeded.countInformationneededRecords";
import createInformationNeededRec from "@salesforce/apex/InformationNeeded.createInformationNeededRec";
import InformationNeededURL from "@salesforce/label/c.InformationNeededURL";
import deleteInformationNeededRecord from "@salesforce/apex/InformationNeeded.deleteInformationNeededRecord";
import ErrorDeleteFailed from "@salesforce/label/c.ErrorDeleteFailed";
import Error_Header from "@salesforce/label/c.error_header";
import RecordDeleted from "@salesforce/label/c.RecordDeleted";
import InformationNeededDisplay from "@salesforce/label/c.InformationNeededDisplay";
import InformationNeededTitle from "@salesforce/label/c.InformationNeededTitle";
import Assigned_To from "@salesforce/label/c.Assigned_To";
import DeleteInformationNeeded from "@salesforce/label/c.DeleteInformationNeeded";
import DeleteInformationNeededPrompt from "@salesforce/label/c.DeleteInformationNeededPrompt";
import Description from "@salesforce/label/c.Description";
import Due_Date from "@salesforce/label/c.Due_Date";
import Status from "@salesforce/label/c.Status";
import sort_by from "@salesforce/label/c.sort_by";
import Add_New from "@salesforce/label/c.AddNewFoP";
import Description_cannot_exceed_32k_characters from "@salesforce/label/c.maxLimitError";
import Source_cannot_exceed_256_characters from "@salesforce/label/c.Source_cannot_exceed_256_characters";
import Error_Title_Exceeds_80_char from "@salesforce/label/c.Trend_cannot_exceed_80_characters";
import getStatusPicklistValues from "@salesforce/apex/InformationNeeded.getStatusPicklistValues";
import Record_Error_Message from "@salesforce/label/c.Record_error_message";
import Required_Field_Missing from "@salesforce/label/c.Required_Field_Missing";
import Please_fill_the_InformationNeededTitle_Field from "@salesforce/label/c.Please_fill_the_Title_Field";
import Success_header from "@salesforce/label/c.success_header";
import Record_Success_Message from "@salesforce/label/c.Record_success_message";
import informationNeededDate_Created from "@salesforce/label/c.foInvDate_Created";
import InformationNeededStatusComplete from "@salesforce/label/c.foInvStatusComplete";
import InformationNeededStatusIncomplete from "@salesforce/label/c.foInvStatusIncomplete";
import Edit from "@salesforce/label/c.edit";
import Delete from "@salesforce/label/c.delete";
import Save from "@salesforce/label/c.save";
import Cancel from "@salesforce/label/c.cancel";
import Yes from "@salesforce/label/c.yes";
import close from "@salesforce/label/c.close";
import Source from "@salesforce/label/c.Source";
import { loadStyle } from "lightning/platformResourceLoader";
import styles from "@salesforce/resourceUrl/cssLibrary";
import LOCALE from "@salesforce/i18n/locale";

const informationNeeds = [
    { label: Edit, name: "edit" },
    { label: Delete, name: "delete" }
];

const columns = [
    {
        label: InformationNeededDisplay,
        fieldName: "gsInformationNeededTitle",
        hideDefaultActions: "true" //,
        //fixedWidth: 150
    },
    {
        label: Description,
        fieldName: "gsInformationNeededDescription",
        hideDefaultActions: "true",
        type: "customRecordDisplayType",
        typeAttributes: {
            showMoreShowLess: true
        },
        fixedWidth: 400
    },
    {
        label: Source,
        fieldName: "gsInformationNeededSource",
        hideDefaultActions: "true",
        type: "customRecordDisplayType",
        typeAttributes: {
            isSource: true,
            showMoreShowLess: true
        },
        fixedWidth: 250,
        wrapText: true
    },
    {
        label: Assigned_To,
        fieldName: "gsInformationNeededAssignedToName",
        hideDefaultActions: "true",
        type: "customRecordDisplayType",
        typeAttributes: {
            showMoreShowLess: false
        }
    },
    {
        label: Due_Date,
        fieldName: "gsInformationNeededDueDateString",
        hideDefaultActions: "true",
        type: "customRecordDisplayType",
        typeAttributes: {
            showMoreShowLess: false
        },
        cellAttributes: { alignment: "left" }
    },
    {
        label: Status,
        fieldName: "gsInformationNeededStatus",
        hideDefaultActions: "true",
        type: "customRecordDisplayType",
        typeAttributes: {
            status: { fieldName: "gsInformationNeededStatus" }
        }
    },
    {
        type: "action",
        typeAttributes: { rowActions: informationNeeds },
        cellAttributes: {
            class: { fieldName: "cssClassforReadOnlyUsers" }
        }
    }
];

export default class InformationNeeded extends LightningElement {
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
    @track showMaxLimitErrorSource = false;
    @track showMaxLimitError = false;
    @track objectForLookup;
    @track lookuptargetField;
    @api totalRecordCount = countInformationneededRecords();
    @track focusInvest = [];
    @track gsInformationNeededTitle;
    @track gsInformationNeededDescription;
    @track gsInformationNeededSource;
    @track informationNeededDueDate = null;
    @track gsInformationNeededStatus = "Incomplete";
    @track gsInformationNeededAssignedTo;
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
        sort_by,
        Add_New,
        InformationNeededDisplay,
        InformationNeededTitle,
        Assigned_To,
        DeleteInformationNeeded,
        DeleteInformationNeededPrompt,
        Description,
        Due_Date,
        Status,
        Source,
        informationNeededDate_Created,
        InformationNeededStatusComplete,
        InformationNeededStatusIncomplete,
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
        InformationNeededURL,
        Required_Field_Missing,
        Please_fill_the_InformationNeededTitle_Field,
        Source_cannot_exceed_256_characters
    };

    get options() {
        return [
            { label: this.allLabels.informationNeededDate_Created, value: "DateCreated" },
            { label: this.allLabels.InformationNeededStatusIncomplete, value: "Incomplete" },
            { label: this.allLabels.InformationNeededStatusComplete, value: "Complete" }
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
        localStorage.setItem("informationNeeded", this.sortFilter);
        this.handleRefresh();
    }

    handleRowInformationNeeded(event) {
        const action = event.detail.action;
        switch (action.name) {
            case "edit":
                this.newRecordModalFlag = true;
                this.showMaxLimitErrorSource = false;
                this.showMaxLimitErrorTitle = false;
                this.showMaxLimitError = false;
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
        this.gsInformationNeededStatus = event.detail.value;
    }
    handleAssignedToSelected(event) {
        if (event.detail) {
            this.informationNeededAssignedTo = event.detail;
        } else {
            this.informationNeededAssignedTo = null;
        }
    }
    handleDueDateSelected(event) {
        if (event.detail.value) {
            this.informationNeededDueDate = event.detail.value;
        } else {
            this.informationNeededDueDate = null;
        }
    }

    toggleSave(event) {
        this.gsInformationNeededTitle = event.target.value;
        if (!this.gsInformationNeededTitle || this.gsInformationNeededTitle === " ") {
            this.isSaveDisabled = true;
        } else {
            this.isSaveDisabled = false;
        }
    }

    handleEdit(event) {
        const row = event.detail.row;
        this.currentRecordItem = JSON.parse(JSON.stringify(row));
        this.recId = this.currentRecordItem.id;
        this.informationNeededDueDate = this.currentRecordItem.gsInformationNeededDueDate;
        this.gsInformationNeededDescription = this.currentRecordItem.gsInformationNeededDescription;
        this.gsInformationNeededSource = this.currentRecordItem.gsInformationNeededSource;
        this.gsInformationNeededTitle = this.currentRecordItem.gsInformationNeededTitle;
        this.gsInformationNeededStatus = this.currentRecordItem.gsInformationNeededStatus;
        this.informationNeededAssignedTo = this.currentRecordItem.gsInformationNeededAssignedTo;
        this.isSaveDisabled = false;
    }

    handleAddNew() {
        this.newRecordModalFlag = true;
        this.isSaveDisabled = true;
        this.showMaxLimitErrorSource = false;
        this.showMaxLimitError = false;
        this.showMaxLimitErrorTitle = false;
        this.initializeVariables();
    }

    getDataFromBackend() {
        getInformationNeededRecords({
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
        this.gsInformationNeededTitle = "";
        this.gsInformationNeededDescription = "";
        this.gsInformationNeededSource = "";
        this.informationNeededDueDate = null;
        this.queryOffset = 0;
        this.queryLimit = 5;
        this.recId = null;
        this.gsInformationNeededStatus = "Incomplete";
        this.informationNeededAssignedTo = null;
    }

    handleInformationNeededTitle(event) {
        this.gsInformationNeededTitle = event.target.value;
        let titleLimit = event.target.value;

        if (titleLimit.length === 80) {
            this.showMaxLimitErrorTitle = true;
        } else {
            this.showMaxLimitErrorTitle = false;
        }
    }

    handleDescription(event) {
        this.gsInformationNeededDescription = event.target.value;
        let descriptionLimit = event.target.value;
        if (descriptionLimit.length === 32000) {
            this.showMaxLimitError = true;
            // this.isSaveDisabled = true;
        } else {
            this.showMaxLimitError = false;
            // this.isSaveDisabled = false;
        }
    }
    handleSource(event) {
        this.gsInformationNeededSource = event.target.value;
        let descriptionLimit = event.target.value;
        if (descriptionLimit.length === 256) {
            this.showMaxLimitErrorSource = true;
            // this.isSaveDisabled = true;
        } else {
            this.showMaxLimitErrorSource = false;
            // this.isSaveDisabled = true;
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
        let informationNeededList;
        return getInformationNeededList({
            goldSheetId: this.getIdFromParent,
            queryLimit: this.queryLimit,
            queryOffset: this.queryOffset,
            sortFilter: this.sortFilter
        })
            .then(result => {
                this.totalRecordCount = result.totalRecordCount;
                informationNeededList = result.inInformationNeededRecords;
                if (!this.totalRecordCount) {
                    this.noDataPresentFlag = true;
                    this.borderstyle = "slds-m-left-xx_small";
                } else {
                    this.noDataPresentFlag = false;
                    this.borderstyle = "slds-border_left slds-m-left-xx_small";
                }
                flatData = JSON.parse(JSON.stringify(informationNeededList));
                let updatedRecords = [...this._records, ...flatData];
                this._records = updatedRecords;
                this._records.forEach(function(gsInfoNeededRecord) {
                    gsInfoNeededRecord.gsInformationNeededDueDateString = new Intl.DateTimeFormat(LOCALE).format(
                        new Date(gsInfoNeededRecord.gsInformationNeededDueDateString)
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
        this.showMaxLimitErrorSource = false;
        this.focInvIncompleteError = false;
    }

    handleSave() {
        this.isSaveDisabled = true;

        if (!this.gsInformationNeededTitle.trim() || this.gsInformationNeededTitle.trim() === " ") {
            const evt = new ShowToastEvent({
                title: this.allLabels.Required_Field_Missing,
                message: this.allLabels.Please_fill_the_InformationNeededTitle_Field,
                variant: this.allLabels.Error_Header
            });
            this.dispatchEvent(evt);
            this.isSaveDisabled = false;
        } else {
            let focusInvestDataToSave = {
                gsInformationNeededTitle: this.gsInformationNeededTitle,
                gsInformationNeededDueDate: this.informationNeededDueDate,
                gsInformationNeededStatus: this.gsInformationNeededStatus,
                gsInformationNeededDescription: this.gsInformationNeededDescription,
                gsInformationNeededSource: this.gsInformationNeededSource,
                gsInformationNeededAssignedTo: this.informationNeededAssignedTo,
                goldSheet: this.getIdFromParent,
                id: this.recId
            };
            this.newRecordModalFlag = false;
            createInformationNeededRec({ informationNeededDataString: JSON.stringify(focusInvestDataToSave) })
                .then(() => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: this.allLabels.Success_header,
                            message: this.allLabels.Record_Success_Message,
                            variant: this.allLabels.Success_header
                        })
                    );
                    this.gsInformationNeededDescription = "";
                    this.gsInformationNeededSource = "";
                    this.gsInformationNeededTitle = "";
                    this.informationNeededDueDate = null;
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
        deleteInformationNeededRecord({ recordId: this.deleteId })
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