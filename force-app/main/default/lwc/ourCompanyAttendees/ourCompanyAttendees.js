import { LightningElement, track, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getLookupObjects from "@salesforce/apex/OurCompanyAttendees.getLookupObjects";
import getCompanyAttendeeInfo from "@salesforce/apex/OurCompanyAttendees.getCompanyAttendeeInfo";
import removeCompanyAttendee from "@salesforce/apex/OurCompanyAttendees.removeCompanyAttendee";
import saveCompanyAttendee from "@salesforce/apex/OurCompanyAttendees.saveCompanyAttendee";
import getUserTitle from "@salesforce/apex/ApexCommonUtil.getUserTitle";
import checkAccess from "@salesforce/apex/OurCompanyAttendees.getCompanyAccess";
import Save from "@salesforce/label/c.save";
import Cancel from "@salesforce/label/c.cancel";
import Yes from "@salesforce/label/c.yes";
import Success_header from "@salesforce/label/c.success_header";
import Record_Error_Message from "@salesforce/label/c.Record_error_message";
import Record_Success_Message from "@salesforce/label/c.Record_success_message";
import { loadStyle } from "lightning/platformResourceLoader";
import styles from "@salesforce/resourceUrl/cssLibrary";
import NameLabel from "@salesforce/label/c.Name";
import TitleLabel from "@salesforce/label/c.Title";
import CompanyAttendee from "@salesforce/label/c.CompanyAttendee";
import Remove from "@salesforce/label/c.Remove";
import close from "@salesforce/label/c.close";
import ViewUser from "@salesforce/label/c.ViewUser";
import error_header from "@salesforce/label/c.error_header";
import error_message from "@salesforce/label/c.Error";

const actions = [{ label: Remove, name: "delete" }];

const columns = [
    {
        label: NameLabel,
        fieldName: "userLinkName",
        hideDefaultActions: "true",
        typeAttributes: { label: { fieldName: "name" }, target: "_blank", tooltip: ViewUser },
        type: "url"
    },
    {
        label: TitleLabel,
        fieldName: "title",
        hideDefaultActions: "true",
        type: "text"
    },
    {
        type: "action",
        typeAttributes: { rowActions: actions },
        cellAttributes: {
            class: { fieldName: "cssClassforReadOnlyUsers" }
        }
    }
];

export default class OurCompanyAttendees extends LightningElement {
    @track noDataPresentFlag = false;
    @track isSaveDisabled = false;
    @track isCreateable = false;
    @track isUpdateable = false;
    @track isDeletable = false;
    @api newrecordFlag = false;
    @track objectForLookup;
    @track lookuptargetField;
    @track companyName = "";
    @track companyTitle = "";
    @track companyList = [];
    @track userTitle = "";
    @track deleteRecordId;
    @track columns = columns;

    @track _getIdFromParent;
    @api
    get getIdFromParent() {
        return this._getIdFromParent;
    }

    set getIdFromParent(value) {
        this._getIdFromParent = value;
        this.getCompanyData();
    }

    allLabels = {
        Save,
        Yes,
        Cancel,
        Success_header,
        Record_Error_Message,
        Record_Success_Message,
        NameLabel,
        TitleLabel,
        CompanyAttendee,
        Remove,
        close,
        error_header,
        error_message
    };

    connectedCallback() {
        this.initializeVariables();
        this.getLookupObjects();
        // this.getCompanyData();
    }
    renderedCallback() {
        loadStyle(this, styles);
        let resultOnRender = this.companyList;
        if (resultOnRender && resultOnRender.length > 10) {
            this.template.querySelectorAll(".SavedStateDataTable").forEach(function(el) {
                el.classList.add("scrollableUI");
            });
        } else {
            this.template.querySelectorAll(".SavedStateDataTable").forEach(function(el) {
                el.classList.remove("scrollableUI");
            });
        }
    }

    initializeVariables() {
        this.companyName = "";
        this.userTitle = "";
    }

    @api handleAddNew() {
        this.newrecordFlag = true;
        this.isSaveDisabled = true;
        this.initializeVariables();
    }
    getLookupObjects() {
        getLookupObjects().then(result => {
            if (result) {
                this.objectForLookup = result.lookupOnObject;
                this.lookuptargetField = result.targetField;
            }
        });
    }

    getCompanyData() {
        checkAccess().then(result => {
            this.isCreateable = result.isCreateable;
            this.isUpdateable = result.isUpdateable;
            this.isDeletable = result.isDeletable;
        });
        getCompanyAttendeeInfo({ greenSheetId: this.getIdFromParent }).then(result => {
            this.companyList = result;
            if (!this.companyList.length) {
                this.noDataPresentFlag = true;
            } else {
                this.noDataPresentFlag = false;
            }
        });
    }

    handleNameSelected(event) {
        this.companyName = event.detail;
        this.isSaveDisabled = false;
        this.userTitle = " ";
        getUserTitle({ recordId: this.companyName }).then(result => {
            if (result) {
                this.userTitle = result;
            }
        });
        if (!this.companyName) {
            this.companyName = null;
            this.isSaveDisabled = true;
        }
    }

    handleCancelSave() {
        this.isSaveDisabled = false;
        this.newrecordFlag = false;
    }

    handleRowAction(event) {
        const action = event.detail.action;
        switch (action.name) {
            case "delete":
                this.handleDelete(event);
                break;
            default:
                break;
        }
    }
    handleDelete(event) {
        this.deleteRecordId = event.detail.row.id;
        removeCompanyAttendee({ companyId: this.deleteRecordId }).then(() => {
            this.getCompanyData();
        });
    }

    handleSave() {
        saveCompanyAttendee({ userId: this.companyName, greenSheetId: this.getIdFromParent })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.allLabels.Success_header,
                        message: this.allLabels.Record_Success_Message,
                        variant: "success"
                    })
                );
                this.newrecordFlag = false;
                this.getCompanyData();
            })
            .catch(error => {
                this.newrecordFlag = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.allLabels.error_message,
                        message: error.body.message,
                        variant: this.allLabels.error_header
                    })
                );
            });
        this.initializeVariables();
    }
}