import { LightningElement, track, wire, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import checkAccess from "@salesforce/apex/StopInvestmentController.getStopInvestmentAccess";
import getStopInvestmentRecords from "@salesforce/apex/StopInvestmentController.getStopInvestmentRecords";
import getStopInvList from "@salesforce/apex/StopInvestmentController.getStopInvList";
import createStopInvestmentRec from "@salesforce/apex/StopInvestmentController.createStopInvestmentRec";
import deleteInvestment from "@salesforce/apex/StopInvestmentController.deleteInvestment";
import ErrorDeleteFailed from "@salesforce/label/c.ErrorDeleteFailed";
import Error_Header from "@salesforce/label/c.error_header";
import RecordDeleted from "@salesforce/label/c.RecordDeleted";
import StopInvestmentTitle from "@salesforce/label/c.StopInvestmentTitle";
import StopInvestmentPlural from "@salesforce/label/c.StopInvestmentPlural";
import StopInvestmentURL from "@salesforce/label/c.StopInvestmentURL";
import DeleteStopInvestment from "@salesforce/label/c.DeleteStopInvestment";
import deletePromptStopInvestment from "@salesforce/label/c.deletePromptStopInvestment";
import StopInvestmentHeader from "@salesforce/label/c.StopInvestmentHeader";
import Error_Title_fill from "@salesforce/label/c.Please_fill_the_StopInvestmentTitle_Field";
import focInv_Description from "@salesforce/label/c.focInv_Description";
import foInvAmount from "@salesforce/label/c.foInvAmount";
import foInvStatus from "@salesforce/label/c.foInvStatus";
import sort_by from "@salesforce/label/c.sort_by";
import Add_New from "@salesforce/label/c.AddNewFoP";
import Description_cannot_exceed_32k_characters from "@salesforce/label/c.maxLimitError";
import Error_Title_Exceeds_80_char from "@salesforce/label/c.Stop_Inv_cannot_exceed_80_characters";
import getStatusPicklistValues from "@salesforce/apex/StopInvestmentController.getStatusPicklistValues";
import Record_Error_Message from "@salesforce/label/c.Record_error_message";
import Success_header from "@salesforce/label/c.success_header";
import Record_Success_Message from "@salesforce/label/c.Record_success_message";
import stopInvDate_Created from "@salesforce/label/c.stopInvDate_Created";
import stopInvStatusComplete from "@salesforce/label/c.stopInvStatusComplete";
import stopInvStatusIncomplete from "@salesforce/label/c.stopInvStatusIncomplete";
import Save from "@salesforce/label/c.save";
import Cancel from "@salesforce/label/c.cancel";
import Yes from "@salesforce/label/c.yes";
import close from "@salesforce/label/c.close";
import EnterNumericValue from "@salesforce/label/c.EnterNumericValue";
import { loadStyle } from "lightning/platformResourceLoader";
import styles from "@salesforce/resourceUrl/cssLibrary";
import deleteLabel from "@salesforce/label/c.deleteLabel";
import edit from "@salesforce/label/c.edit";
import stopInv_Description from "@salesforce/label/c.stopInv_Description";
import stopInvAmount from "@salesforce/label/c.stopInvAmount";
import stopInvStatus from "@salesforce/label/c.stopInvStatus";

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
        cellAttributes: { alignment: "right" },
        typeAttributes: {
            redFlagStrengthObject: { fieldName: "rfsMarkerWrapper" },
            fieldApiName: "FoiInvestmentTitle",
            isRedFlagStrength: true
        }
    },
    {
        label: StopInvestmentHeader,
        fieldName: "foiInvestmentTitle",
        hideDefaultActions: "true",
        type: "customRecordDisplayType",
        typeAttributes: {
            showMoreShowLess: false
        }
    },
    {
        label: stopInv_Description,
        fieldName: "foiDescription",
        hideDefaultActions: "true",
        type: "customRecordDisplayType",
        typeAttributes: {
            showMoreShowLess: true
        }
    },
    {
        label: stopInvAmount,
        fieldName: "foiAmount",
        hideDefaultActions: "true",
        type: "currency",
        cellAttributes: { alignment: "left" }
    },
    {
        label: stopInvStatus,
        fieldName: "foiStatus",
        hideDefaultActions: "true",
        type: "customRecordDisplayType",
        typeAttributes: {
            status: { fieldName: "foiStatus" }
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

export default class StopInvestment extends LightningElement {
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
    @track actionTypeValue;
    @track ssDescription;
    @track rfsMarker;
    @track rfsMap = {};
    //@track focusInvest = [];
    @track foiInvestmentTitle;
    @track foiDescription;
    @track foiAmount = null;
    @track foiStatusValue = "Incomplete";
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
    @track rfsDetails = this.getNewRfsDetails();
    @track ShowModal = false;
    @track sortFilter;
    @track focInvIncompleteError = false;
    @track showMaxLimitError = false;
    @track borderstyle;

    allLabels = {
        StopInvestmentPlural,
        StopInvestmentURL,
        StopInvestmentTitle,
        DeleteStopInvestment,
        deletePromptStopInvestment,
        StopInvestmentHeader,
        stopInvDate_Created,
        stopInvStatusComplete,
        stopInvStatusIncomplete,
        Error_Title_fill,
        focInv_Description,
        foInvAmount,
        foInvStatus,
        sort_by,
        Add_New,
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
        EnterNumericValue
    };

    get options() {
        return [
            { label: this.allLabels.stopInvDate_Created, value: "DateCreated" },
            { label: this.allLabels.stopInvStatusIncomplete, value: "Incomplete" },
            { label: this.allLabels.stopInvStatusComplete, value: "Complete" }
        ];
    }

    connectedCallback() {
        this.noDataPresentFlag = false;
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

    filterTableValues(event) {
        this.sortFilter = event.detail.value;
        this.queryLimit = 5;
        this.queryOffset = 0;
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

    getNewRfsDetails() {
        return {
            FoiInvestmentTitle: {
                redFlagSelected: false,
                strengthSelected: false,
                noneSelected: true,
                fieldApiName: "FoiInvestmentTitle"
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

    handleStatusUpdate(event) {
        this.foiStatusValue = event.detail.value;
    }

    handleAmount(event) {
        if (event.detail.value) {
            this.foiAmount = event.detail.value;
        } else {
            this.foiAmount = null;
        }
    }

    handleDescription(event) {
        this.foiDescription = event.target.value;
        if (this.foiDescription.length > 32000) {
            this.showMaxLimitError = true;
            this.isSaveDisabled = true;
        } else {
            this.showMaxLimitError = false;
            this.isSaveDisabled = false;
        }
        if (!this.foiInvestmentTitle || this.foiInvestmentTitle.length > 80) {
            this.isSaveDisabled = true;
        }
    }

    toggleSave(event) {
        this.foiInvestmentTitle = event.target.value;
        if (this.foiInvestmentTitle === null || this.foiInvestmentTitle === "" || this.foiInvestmentTitle === " ") {
            this.isSaveDisabled = true;
        } else {
            this.isSaveDisabled = false;
        }
    }

    handleEdit(event) {
        const row = event.detail.row;
        this.currentRecordItem = JSON.parse(JSON.stringify(row));
        this.recId = this.currentRecordItem.id;
        this.foiAmount = this.currentRecordItem.foiAmount;
        this.foiDescription = this.currentRecordItem.foiDescription;
        this.foiInvestmentTitle = this.currentRecordItem.foiInvestmentTitle;
        this.foiStatusValue = this.currentRecordItem.foiStatus;
        this.rfsDetails = this.currentRecordItem.rfsMarkerWrapper;
        this.isSaveDisabled = false;
        this.showMaxLimitError = false;
        this.showMaxLimitErrorTitle = false;
    }

    handleAddNew() {
        this.newRecordModalFlag = true;
        this.isSaveDisabled = true;
        this.showMaxLimitErrorTitle = false;
        this.showMaxLimitError = false;
        this.initializeVariables();
        this.rfsDetails = {
            FoiInvestmentTitle: {
                redFlagSelected: false,
                strengthSelected: false,
                noneSelected: true,
                fieldApiName: "FoiInvestmentTitle"
            }
        };
    }

    getDataFromBackend() {
        getStopInvestmentRecords({
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
        this.foiInvestmentTitle = "";
        this.foiDescription = "";
        this.foiAmount = null;
        this.queryOffset = 0;
        this.queryLimit = 5;
        this.recId = null;
        this.foiStatusValue = "Incomplete";
    }

    handlefoInvestmentTitle(event) {
        this.foiInvestmentTitle = event.target.value;
        if (
            this.foiInvestmentTitle.trim() == null ||
            this.foiInvestmentTitle.trim() === "" ||
            this.foiInvestmentTitle.trim() === "undefined" ||
            this.foiInvestmentTitle.trim() === " "
        ) {
            this.focInvIncompleteError = true;
        } else {
            this.focInvIncompleteError = false;
        }

        let descriptionLimit = event.target.value;

        if (descriptionLimit.length > 80) {
            this.showMaxLimitErrorTitle = true;
            this.isSaveDisabled = true;
        } else {
            this.showMaxLimitErrorTitle = false;
            this.isSaveDisabled = false;
        }

        if ((this.foiDescription && this.foiDescription.length > 32000) || !descriptionLimit) {
            this.isSaveDisabled = true;
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
        let focInvList;
        return getStopInvList({
            goldSheetId: this.getIdFromParent,
            queryLimit: this.queryLimit,
            queryOffset: this.queryOffset,
            sortFilter: this.sortFilter
        })
            .then(result => {
                this.totalRecordCount = result.totalRecordCount;

                focInvList = result.focInvRecords;

                if (!this.totalRecordCount) {
                    this.noDataPresentFlag = true;
                    this.borderstyle = "slds-m-left-xx_small";
                } else {
                    this.noDataPresentFlag = false;
                    this.borderstyle = "slds-border_left slds-m-left-xx_small";
                    focInvList.forEach(element => {
                        element.rfsMarkerWrapper = this.convertMarkerMap(element.rfsMarkerWrapper);
                    });
                }
                flatData = JSON.parse(JSON.stringify(result.focInvRecords));

                let updatedRecords = [...this._records, ...flatData];
                this._records = updatedRecords;

                this.error = undefined;
            })
            .catch(error => {
                this.error = error;
            });
    }

    handleCancelSave() {
        this.newRecordModalFlag = false;
        this.rfsDetails = this.getNewRfsDetails();
    }

    handleSave() {
        let isValidFieldValue = true;
        const allValidName = [...this.template.querySelectorAll("lightning-input")].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        if (allValidName) {
            isValidFieldValue = true;
        } else {
            isValidFieldValue = false;
        }
        if (isValidFieldValue) {
            this.isSaveDisabled = true;
            let stopInvestDataToSave = {
                foiInvestmentTitle: this.foiInvestmentTitle,
                foiAmount: this.foiAmount,
                foiStatus: this.foiStatusValue,
                foiDescription: this.foiDescription,
                goldSheet: this.getIdFromParent,
                id: this.recId
            };
            this.newRecordModalFlag = false;
            createStopInvestmentRec({ inputString: JSON.stringify(stopInvestDataToSave), rfsMap: this.rfsDetails })
                .then(() => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: this.allLabels.Success_header,
                            message: this.allLabels.Record_Success_Message,
                            variant: this.allLabels.Success_header
                        })
                    );
                    this.foiDescription = "";
                    this.foiInvestmentTitle = "";
                    this.foiAmount = null;
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

    get records() {
        return this._records.length ? this._records : null;
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
        deleteInvestment({ recordId: this.deleteId })
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