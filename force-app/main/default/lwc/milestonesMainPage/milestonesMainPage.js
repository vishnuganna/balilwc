import { LightningElement, api, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import AddNewMilestone from "@salesforce/label/c.AddNewFoP";
import ErrorMax32kCharacters from "@salesforce/label/c.maxLimitError";
import save from "@salesforce/label/c.save";
import cancel from "@salesforce/label/c.cancel";
import checkAccess from "@salesforce/apex/Milestones.getMilestonesAccess";
import upsertMilestone from "@salesforce/apex/Milestones.upsertMilestone";
import getMilestoneRecords from "@salesforce/apex/Milestones.getMilestoneRecords";
import getStrategicPlayerLookup from "@salesforce/apex/Milestones.getStrategicPlayerName";
import Required_Field_Missing from "@salesforce/label/c.Required_Field_Missing";
import error_header from "@salesforce/label/c.error_header";
import success_header from "@salesforce/label/c.success_header";
import Record_error_message from "@salesforce/label/c.Record_error_message";
import Record_success_message from "@salesforce/label/c.Record_success_message";
import meetingDateFieldLabel from "@salesforce/label/c.MeetingDateField";
import meetingNotesFieldLabel from "@salesforce/label/c.MeetingNotesField";
import addStrategicPlayerLabel from "@salesforce/label/c.AddStrategicPlayer";
import DateFieldErrorMessage from "@salesforce/label/c.DateFieldErrorMessage";
import StrategicPlayer from "@salesforce/label/c.StrategicPlayer";
import ShowStrategicPlayers from "@salesforce/label/c.ShowStrategicPlayers";
import HideStrategicPlayers from "@salesforce/label/c.HideStrategicPlayers";
import Remove from "@salesforce/label/c.Remove";
import Name from "@salesforce/label/c.Name";
import Title from "@salesforce/label/c.Title";
import Role from "@salesforce/label/c.Role";
import close from "@salesforce/label/c.close";
import LOCALE from "@salesforce/i18n/locale";

export default class MilestonesMainPage extends LightningElement {
    @api getIdFromParent;
    @track saveDisableFlag = false;
    @track goldSheet = "";
    @track meetingDate = "";
    @track meetingNotes = "";
    @api milestoneNumber = "";
    // @api isButtonDisable;
    @track _isButtonDisable;

    @api
    get isButtonDisable() {
        return this._isButtonDisable;
    }

    set isButtonDisable(value) {
        this._isButtonDisable = value;
    }

    @track strategicPlayers = [];
    @track newRecordScreenFlag = false;
    @track showMaxLimitError = false;
    @api milestoneHeaderLabel;
    @api milestoneHeaderNavURL;
    @api isEditDataDisabled = false;
    @api isDeleteDataDisabled = false;
    @api isstrategicPlayer = false;
    @track isCreateable = false;
    @track isUpdateable = false;
    @track isDeletable = false;
    @api recordId;
    @track checkNoDataAndReadOnlyAccess = false;
    @track milestonesData1 = "";
    @track milestonesData2 = "";
    @track milestonesData3 = "";
    @track milestonesData4 = "";
    @track milestonesData5 = "";
    @track milestonesData = "";
    @track milestoneId = "";
    @track readView = false;

    selectedconname = false;
    newRecordModalFlag = false;
    isStratPlayertable = false;
    @track stratplayerID = "";
    @track objectForLookup;
    @track lookuptargetField;
    keyIndex = 0;
    @track itemList = [];
    @track strategicPlayerName;
    @track selectedRecordTitle;
    @track selectedRecordRole;
    @track strategicPlayerRecordId;
    @track isSaveDisabled = true;
    @api currentGoldSheet;
    //var newItem;

    allLabels = {
        AddNewMilestone,
        ErrorMax32kCharacters,
        save,
        cancel,
        Required_Field_Missing,
        error_header,
        success_header,
        Record_error_message,
        Record_success_message,
        meetingDateFieldLabel,
        meetingNotesFieldLabel,
        addStrategicPlayerLabel,
        DateFieldErrorMessage,
        StrategicPlayer,
        ShowStrategicPlayers,
        HideStrategicPlayers,
        Name,
        Title,
        Role,
        Remove,
        close
    };

    initializeVariables() {
        this.goldSheet = "";
        this.meetingDate = "";
        this.meetingNotes = "";
        this.strategicPlayers = [];
        this.milestoneId = "";
        this.itemList = [];
    }

    connectedCallback() {
        this.currentGoldSheet = this.getIdFromParent;
        this.initializeVariables();
        //this.getDataFromBackend();
        //  this.accountIdVar = this.currentRecordItem.accountId;
        getStrategicPlayerLookup().then(result => {
            this.objectForLookup = result.lookupOnObject;
            this.lookuptargetField = result.targetField;
            this.getDataFromBackend();
        });
    }

    handlebutton() {
        if (this.isButtonDisable) {
            this.newRecordScreenFlag = true;
        } else {
            this.newRecordScreenFlag = false;
        }
    }

    handleCreateNewRec() {
        this.newRecordScreenFlag = true;
        this.isStratPlayertable = false;
        this.saveDisableFlag = true;
        this.showMaxLimitError = false;
        this.initializeVariables();
        //  this.template.querySelector('c-milestones-data-page').handleEditDelete();
        this.dispatchingEvent(true);
        this.isEditDataDisabled = true;
        this.isDeleteDataDisabled = true;
    }

    dispatchingEvent(value) {
        const NewRecordEvent = new CustomEvent("buttonclicked", {
            detail: {
                buttonclicked: value
            }
        });
        this.dispatchEvent(NewRecordEvent);
    }

    handleEditbutton(event) {
        this.dispatchingEvent(event.detail.buttonclicked);
    }

    handleCancelClick() {
        this.newRecordScreenFlag = false;
        this.showMaxLimitError = false;
        this.saveDisableFlag = false;
        this.itemList = [];
        this.isEditDataDisabled = false;
        this.isDeleteDataDisabled = false;
        this.dispatchingEvent(false);
    }

    handleCancelSave() {
        this.newRecordModalFlag = false;
    }

    handleMaxLimitError(event) {
        var notesLimit = event.target.value;
        if (notesLimit.length === 32000) {
            this.showMaxLimitError = true;
        } else {
            this.showMaxLimitError = false;
        }
    }

    handleSaveClick() {
        this.dispatchingEvent(false);

        this.newRecordScreenFlag = false;
        let milestoneDataToSave = {
            id: this.milestoneId,
            msDate: this.meetingDate,
            msNotes: this.meetingNotes,
            msNumber: this.milestoneNumber,
            msPlayer: this.strategicPlayers,
            goldSheet: this.getIdFromParent
        };

        upsertMilestone({ jsonString: JSON.stringify(milestoneDataToSave) })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.allLabels.success_header,
                        message: this.allLabels.Record_success_message,
                        variant: this.allLabels.success_header
                    })
                );
                this.handleRefresh();
                this.meetingDate = "";
                this.meetingNotes = "";
                //  this.milestoneNumber = "";
                this.strategicPlayers = [];
                this.saveDisableFlag = false;
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.allLabels.Record_error_message,
                        message: error.body.message,
                        variant: this.allLabels.error_header
                    })
                );
            });
    }

    handleNotesChange(event) {
        this.meetingNotes = event.target.value;
    }

    handleDateChange(event) {
        this.meetingDate = event.target.value;
        if (
            this.meetingDate == null ||
            this.meetingDate === "" ||
            this.meetingDate === "undefined" ||
            this.meetingDate === " "
        ) {
            /*const evt = new ShowToastEvent({
                title: this.allLabels.Required_Field_Missing,
                message: this.allLabels.DateFieldErrorMessage,
                variant: this.allLabels.error_header
            });
            this.dispatchEvent(evt);*/
            this.saveDisableFlag = true;
        } else {
            this.saveDisableFlag = false;
        }
    }

    getDataFromBackend() {
        this.readView = false;
        getMilestoneRecords({ goldSheetId: this.getIdFromParent })
            .then(result => {
                this.milestonesData1 = result.Milestone1;
                this.milestonesData2 = result.Milestone2;
                this.milestonesData3 = result.Milestone3;
                this.milestonesData4 = result.Milestone4;
                this.milestonesData5 = result.Milestone5;

                if (
                    this.milestonesData1.length &&
                    this.milestonesData1 !== "" &&
                    this.milestoneNumber === "Milestone 1"
                ) {
                    this.milestonesData = this.milestonesData1;
                    this.milestonesData.forEach(function(msRecord) {
                        msRecord.msDate = new Intl.DateTimeFormat(LOCALE).format(new Date(msRecord.msDate));
                    });
                    this.readView = true;
                } else if (
                    this.milestonesData2.length &&
                    this.milestonesData2 !== "" &&
                    this.milestoneNumber === "Milestone 2"
                ) {
                    this.milestonesData = this.milestonesData2;
                    this.milestonesData.forEach(function(msRecord) {
                        msRecord.msDate = new Intl.DateTimeFormat(LOCALE).format(new Date(msRecord.msDate));
                    });
                    this.readView = true;
                } else if (
                    this.milestonesData3.length &&
                    this.milestonesData3 !== "" &&
                    this.milestoneNumber === "Milestone 3"
                ) {
                    this.milestonesData = this.milestonesData3;
                    this.milestonesData.forEach(function(msRecord) {
                        msRecord.msDate = new Intl.DateTimeFormat(LOCALE).format(new Date(msRecord.msDate));
                    });
                    this.readView = true;
                } else if (
                    this.milestonesData4.length &&
                    this.milestonesData4 !== "" &&
                    this.milestoneNumber === "Milestone 4"
                ) {
                    this.milestonesData = this.milestonesData4;
                    this.milestonesData.forEach(function(msRecord) {
                        msRecord.msDate = new Intl.DateTimeFormat(LOCALE).format(new Date(msRecord.msDate));
                    });
                    this.readView = true;
                } else if (
                    this.milestonesData5.length &&
                    this.milestonesData5 !== "" &&
                    this.milestoneNumber === "Milestone 5"
                ) {
                    this.milestonesData = this.milestonesData5;
                    this.milestonesData.forEach(function(msRecord) {
                        msRecord.msDate = new Intl.DateTimeFormat(LOCALE).format(new Date(msRecord.msDate));
                    });
                    this.readView = true;
                }
                checkAccess().then(res => {
                    this.isCreateable = res.isCreateable;
                    this.isUpdateable = result.isUpdateable;
                    this.isDeletable = result.isDeletable;
                    if (!this.milestonesData1.length && !this.isCreateable && this.milestoneNumber === "Milestone 1") {
                        this.checkNoDataAndReadOnlyAccess = true;
                    }
                    if (!this.milestonesData2.length && !this.isCreateable && this.milestoneNumber === "Milestone 2") {
                        this.checkNoDataAndReadOnlyAccess = true;
                    }
                    if (!this.milestonesData3.length && !this.isCreateable && this.milestoneNumber === "Milestone 3") {
                        this.checkNoDataAndReadOnlyAccess = true;
                    }
                    if (!this.milestonesData4.length && !this.isCreateable && this.milestoneNumber === "Milestone 4") {
                        this.checkNoDataAndReadOnlyAccess = true;
                    }
                    if (!this.milestonesData5.length && !this.isCreateable && this.milestoneNumber === "Milestone 5") {
                        this.checkNoDataAndReadOnlyAccess = true;
                    }
                });
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.allLabels.error_header,
                        message: error.body.message,
                        variant: this.allLabels.error_header
                    })
                );
            });
    }

    handleRefresh() {
        this.getDataFromBackend();
    }

    handleStrategicPlayer() {
        this.isSaveDisabled = true;
        this.newRecordModalFlag = true;
    }

    handleValueSelcted(event) {
        this.stratplayerID = event.detail;
    }

    handleSave() {
        //Save in lookup
        var newItem;
        this.keyIndex = this.strategicPlayerRecordId;
        newItem = [
            {
                id: this.keyIndex,
                strategicPlayerName: this.strategicPlayerName,
                selectedRecordTitle: this.selectedRecordTitle,
                selectedRecordRole: this.selectedRecordRole
            }
        ];
        this.itemList = this.itemList.concat(newItem);
        this.strategicPlayers.push(this.strategicPlayerRecordId);
        this.newRecordModalFlag = false;
        this.isStratPlayertable = true;
    }

    removeRow(event) {
        this.itemList = this.itemList.filter(function(element) {
            return element.id !== event.target.accessKey;
        });
        this.strategicPlayers = this.strategicPlayers.filter(function(element) {
            return element !== event.target.accessKey;
        });
    }

    onAccountSelection(event) {
        this.isSaveDisabled = false;
        this.strategicPlayerName = event.detail.selectedValue;
        this.selectedRecordTitle = event.detail.selectedRecordTitle;
        this.selectedRecordRole = event.detail.selectedRecordRole;
        this.strategicPlayerRecordId = event.detail.selectedRecordId;
    }
}