import { LightningElement, api, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import edit from "@salesforce/label/c.edit";
import showMore from "@salesforce/label/c.showMore";
import showLess from "@salesforce/label/c.showLess";
import ErrorMax32kCharacters from "@salesforce/label/c.maxLimitError";
import save from "@salesforce/label/c.save";
import cancel from "@salesforce/label/c.cancel";
import Cancel from "@salesforce/label/c.cancel";
import Yes from "@salesforce/label/c.yes";
import checkAccess from "@salesforce/apex/Milestones.getMilestonesAccess";
import upsertMilestone from "@salesforce/apex/Milestones.upsertMilestone";
import deleteMilestoneRecord from "@salesforce/apex/Milestones.deleteMilestone";
import Required_Field_Missing from "@salesforce/label/c.Required_Field_Missing";
import error_header from "@salesforce/label/c.error_header";
import success_header from "@salesforce/label/c.success_header";
import Record_error_message from "@salesforce/label/c.Record_error_message";
import Record_success_message from "@salesforce/label/c.Record_success_message";
import meetingDateFieldLabel from "@salesforce/label/c.MeetingDateField";
import meetingNotesFieldLabel from "@salesforce/label/c.MeetingNotesField";
import addStrategicPlayerLabel from "@salesforce/label/c.AddStrategicPlayer";
import DateFieldErrorMessage from "@salesforce/label/c.DateFieldErrorMessage";
import RecordDeleted from "@salesforce/label/c.RecordDeleted";
import ErrorDeleteFailed from "@salesforce/label/c.ErrorDeleteFailed";
import deletePromptMilestone from "@salesforce/label/c.DeleteMilestonePrompt";
import deleteMilestone from "@salesforce/label/c.DeleteMilestone";
import StrategicPlayer from "@salesforce/label/c.StrategicPlayer";
import StrategicPlayers from "@salesforce/label/c.StrategicPlayers";
import ShowStrategicPlayers from "@salesforce/label/c.ShowStrategicPlayers";
import HideStrategicPlayers from "@salesforce/label/c.HideStrategicPlayers";
import Remove from "@salesforce/label/c.Remove";
import Name from "@salesforce/label/c.Name";
import Title from "@salesforce/label/c.Title";
import Role from "@salesforce/label/c.Role";
import removePlayer from "@salesforce/apex/Milestones.removePlayer";
import getStrategicPlayerLookup from "@salesforce/apex/Milestones.getStrategicPlayerName";
import close from "@salesforce/label/c.close";
import Delete from "@salesforce/label/c.delete";

export default class MilestonesDataPage extends LightningElement {
    @api item;
    showEditView = false;
    ShowModal = false;
    meetingDate = "";
    meetingNotes = "";
    milestoneNumber = "";
    ShowMoreText = false;
    ShowLessText = false;
    showText = false;
    shortText = "";
    longText = "";
    showMaxLimitError = false;
    strategicPlayertextLink = "Show Strategic Player";
    @track isCreateable = false;
    @track isUpdateable = false;
    @track isDeletable = false;
    @track saveDisableFlag = false;
    @track deleteId = "";
    @api isstrategicPlayerlink = false;
    @api isstrategicPlayer = false;
    @api isEditDataDisabled = false;
    @api isDeleteDataDisabled = false;
    @track expandMenu = true;
    @track utilMenu = "utility:chevronright";
    selectedconname = false;
    newRecordModalFlag = false;
    @track stratplayerID;
    @track objectForLookup;
    @track lookuptargetField;
    isStratPlayertable = false;
    @track itemList = [];
    @track selectedRecord;
    @track strategicPlayerName;
    @track strategicPlayerTitle;
    @track role;
    @track strategicPlayerRecordId;
    @track deletePlayerId;
    @track deletePlayers = [];
    @track strategicPlayers = [];
    @api currentGoldSheet;
    @track isSaveDisabled = true;
    @track showPlayerLink = false;

    allLabel = {
        edit,
        showMore,
        showLess,
        Record_error_message,
        Record_success_message,
        ErrorMax32kCharacters,
        Required_Field_Missing,
        save,
        cancel,
        success_header,
        RecordDeleted,
        ErrorDeleteFailed,
        error_header,
        meetingDateFieldLabel,
        meetingNotesFieldLabel,
        addStrategicPlayerLabel,
        DateFieldErrorMessage,
        deleteMilestone,
        deletePromptMilestone,
        Cancel,
        Yes,
        StrategicPlayer,
        StrategicPlayers,
        ShowStrategicPlayers,
        HideStrategicPlayers,
        Name,
        Title,
        Role,
        Remove,
        close,
        Delete
    };

    connectedCallback() {
        if (this.item && this.item.playerWrapperList && this.item.playerWrapperList.length) {
            this.showPlayerLink = true;
        }
        checkAccess().then(result => {
            this.isCreateable = result.isCreateable;
            this.isUpdateable = result.isUpdateable;
            this.isDeletable = result.isDeletable;
        });
        getStrategicPlayerLookup().then(result => {
            this.objectForLookup = result.lookupOnObject;
            this.lookuptargetField = result.targetField;
        });
    }

    deleteModal() {
        deleteMilestoneRecord({ recordId: this.deleteId })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.allLabel.Success_header,
                        message: this.allLabel.RecordDeleted,
                        variant: this.allLabel.success_header
                    })
                );
                this.ShowModal = false;
                this.deleteId = "";
                //this.handleRefresh();
                const selectedEvent = new CustomEvent("refreshscreen", {
                    detail: true
                });
                // Dispatches the event.
                this.dispatchEvent(selectedEvent);
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.allLabel.ErrorDeleteFailed,
                        message: error.body.message,
                        variant: this.allLabel.error_header
                    })
                );
            });
    }

    // @api
    // handleEditDelete(){
    //     console.log("this.isEditDataDisabled" + this.isEditDataDisabled);
    //     this.isEditDataDisabled = true;
    //     this.isDeleteDataDisabled = true;
    // }

    handleDeleteModal() {
        this.ShowModal = true;
        this.deleteId = this.item.id;
    }

    closeModal() {
        this.ShowModal = false;
    }

    handleEdit() {
        this.showEditView = true;
        this.isStratPlayertable = true;
        this.meetingDate = this.item.msDate;
        this.meetingNotes = this.item.msNotes;
        this.milestoneNumber = this.item.msNumber;
        this.milestoneId = this.item.id;
        this.goldSheetId = this.item.goldSheet;
        this.itemList = this.item.playerWrapperList;
        this.strategicPlayers = this.item.msPlayer;
        this.dispatchingEvent(true);
    }

    dispatchingEvent(value) {
        const NewRecordEvent = new CustomEvent("editclicked", {
            detail: {
                buttonclicked: value
            }
        });
        this.dispatchEvent(NewRecordEvent);
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
                title: this.allLabel.Required_Field_Missing,
                message: this.allLabel.DateFieldErrorMessage,
                variant: this.allLabel.error_header
            });
            this.dispatchEvent(evt);*/
            this.saveDisableFlag = true;
        } else {
            this.saveDisableFlag = false;
        }
    }

    handleCancelClick() {
        this.dispatchingEvent(false);
        this.showEditView = false;
        this.showMaxLimitError = false;
        this.saveDisableFlag = false;
        this.newRecordModalFlag = false;
        this.itemList = [];
    }

    handleSaveClick() {
        this.dispatchingEvent(false);
        removePlayer({ deletePlayerId: this.deletePlayers, milestoneId: this.milestoneId })
            .then(() => {})
            .catch(() => {
                //console.log('error in removeRow>>'+error);
            });

        let milestoneDataToSave = {
            id: this.milestoneId,
            msDate: this.meetingDate,
            msNotes: this.meetingNotes,
            msNumber: this.milestoneNumber,
            msPlayer: this.strategicPlayers,
            goldSheet: this.goldSheetId
        };

        upsertMilestone({ jsonString: JSON.stringify(milestoneDataToSave) })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.allLabel.success_header,
                        message: this.allLabel.Record_success_message,
                        variant: this.allLabel.success_header
                    })
                );
                this.milestoneId = "";
                this.meetingDate = "";
                this.meetingNotes = "";
                this.milestoneNumber = "";
                this.strategicPlayers = [];
                this.saveDisableFlag = false;
                this.showEditView = false;
                const selectedEvent = new CustomEvent("refreshscreen", {
                    detail: true
                });
                // Dispatches the event.
                this.dispatchEvent(selectedEvent);
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.allLabel.Record_error_message,
                        message: error.body.message,
                        variant: this.allLabel.error_header
                    })
                );
            });
    }

    handleMaxLimitError(event) {
        var descriptionLimit = event.target.value;
        if (descriptionLimit.length === 32000) {
            this.showMaxLimitError = true;
        } else {
            this.showMaxLimitError = false;
        }
    }

    handleCancelSave() {
        this.newRecordModalFlag = false;
    }

    expandmenuClick() {
        if (this.expandMenu === false) {
            this.utilMenu = "utility:chevronright";
            this.strategicPlayertextLink = this.allLabel.ShowStrategicPlayers;
            this.isStratPlayertable = false;
        } else {
            this.utilMenu = "utility:chevrondown";
            this.strategicPlayertextLink = this.allLabel.HideStrategicPlayers;
            this.isStratPlayertable = true;
        }
        this.expandMenu = !this.expandMenu;
    }

    handleStrategicPlayer() {
        this.isSaveDisabled = true;
        this.newRecordModalFlag = true;
    }

    handleValueSelcted(event) {
        this.stratplayerID = event.detail;
        //let selectedName = event.currentTarget.dataset.name;
    }

    handleSave() {
        //Save in lookup

        var newItem;
        this.keyIndex = this.strategicPlayerRecordId;
        newItem = [
            {
                id: this.keyIndex,
                strategicPlayerName: this.strategicPlayerName,
                strategicPlayerTitle: this.strategicPlayerTitle,
                role: this.role
            }
        ];
        this.itemList = this.itemList.concat(newItem);
        this.strategicPlayers = this.strategicPlayers.concat(this.keyIndex);
        this.newRecordModalFlag = false;
        this.isStratPlayertable = true;
    }

    removeRow(event) {
        this.deletePlayerId = event.target.accessKey;
        this.deletePlayers = this.deletePlayers.concat(this.deletePlayerId);
        this.itemList = this.itemList.filter(function(element) {
            return element.spId !== event.target.accessKey;
        });
    }

    onAccountSelection(event) {
        this.isSaveDisabled = false;
        this.strategicPlayerName = event.detail.selectedValue;
        // this.selectedRecordTitle = event.detail.selectedRecordTitle;
        // this.selectedRecordRole = event.detail.selectedRecordRole;
        this.strategicPlayerTitle = event.detail.selectedRecordTitle;
        this.role = event.detail.selectedRecordRole;
        this.strategicPlayerRecordId = event.detail.selectedRecordId;
    }
}