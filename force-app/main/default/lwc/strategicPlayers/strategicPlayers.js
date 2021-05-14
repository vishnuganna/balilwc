import { LightningElement, api, track, wire } from "lwc";
import getStrategicPlayerData from "@salesforce/apex/StrategicPlayerController.getStrategicPlayerData";
import getObjectPermission from "@salesforce/apex/StrategicPlayerController.getObjectPermission";
import getPlayersList from "@salesforce/apex/StrategicPlayerController.getPlayersList";
import getUserTitle from "@salesforce/apex/ApexCommonUtil.getUserTitle";
import removeStrategicPlayer from "@salesforce/apex/StrategicPlayerController.removeStrategicPlayer";
import getAccountOwnerTitle from "@salesforce/apex/StrategicPlayerController.getAccountOwnerTitle";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getLookupObjects from "@salesforce/apex/StrategicPlayerController.getLookupObjects";
import getbuySellPicklistValues from "@salesforce/apex/StrategicPlayerController.getBuySellPicklistValues";
import getRolePicklistValues from "@salesforce/apex/StrategicPlayerController.getRolePicklistValues";
import saveStrategicPlayerData from "@salesforce/apex/StrategicPlayerController.saveStrategicPlayerData";
import AddNewStrategicPlayer from "@salesforce/label/c.AddNewFoP";
import StrategicPlayerMain from "@salesforce/label/c.StrategicPlayers";
import StrategicPlayer from "@salesforce/label/c.StrategicPlayer";
import StrategicPlayerURL from "@salesforce/label/c.StrategicPlayerURL";
import RoleStrategicPlayerURL from "@salesforce/label/c.RoleStrategicPlayerURL";
import BuySellStrategicPlayerURL from "@salesforce/label/c.BuySellStrategicPlayerURL";
import Role from "@salesforce/label/c.Role";
import OurTeamMember from "@salesforce/label/c.OurTeamMember";
import BuySellPositionNow from "@salesforce/label/c.BuySellPositionNow";
import DeleteStrategicPlayerMessage from "@salesforce/label/c.DeleteStrategicPlayerMessage";
import DeleteStrategicPlayerLabel from "@salesforce/label/c.DeleteStrategicPlayerLabel";
import SelectRole from "@salesforce/label/c.SelectRole";
import SelectLevel from "@salesforce/label/c.SelectLevel";
import Save from "@salesforce/label/c.save";
import Delete from "@salesforce/label/c.delete";
import Edit from "@salesforce/label/c.edit";
import Cancel from "@salesforce/label/c.cancel";
import Close from "@salesforce/label/c.close";
import Yes from "@salesforce/label/c.yes";
import Error_Header from "@salesforce/label/c.error_header";
import Success_header from "@salesforce/label/c.success_header";
import Record_Error_Message from "@salesforce/label/c.Record_error_message";
import Record_Success_Message from "@salesforce/label/c.Record_success_message";
import RecordDeleted from "@salesforce/label/c.RecordDeleted";
import ErrorDeleteFailed from "@salesforce/label/c.ErrorDeleteFailed";
import StrategicPlayerEditContactInfoLabel from "@salesforce/label/c.EditContactInfo";
import AddressInformationLabel from "@salesforce/label/c.AddressInformation";
import ContactInformationLabel from "@salesforce/label/c.ContactInformation";
import EditContactLabel from "@salesforce/label/c.EditContact";
import TitleLabel from "@salesforce/label/c.Title";
import Name from "@salesforce/label/c.Name";
import { loadStyle } from "lightning/platformResourceLoader";
import styles from "@salesforce/resourceUrl/cssLibrary";

const actions = [
    { label: Edit, name: "edit" },
    { label: Delete, name: "delete" }
];

const columns = [
    { label: Name, fieldName: "strategicPlayerName", hideDefaultActions: "true" },
    { label: TitleLabel, fieldName: "strategicPlayerTitle", hideDefaultActions: "true" },
    {
        label: "",
        hideDefaultActions: "true",
        type: "customRecordDisplayType",
        fixedWidth: 21,
        cellAttributes: { alignment: "right" },
        typeAttributes: {
            redFlagStrengthObject: { fieldName: "rfsMarkerWrapper" },
            fieldApiName: "role",
            isRedFlagStrength: true
        }
    },
    {
        label: Role,
        fieldName: "role",
        hideDefaultActions: "true",
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
        cellAttributes: { alignment: "right" },
        typeAttributes: {
            redFlagStrengthObject: { fieldName: "rfsMarkerWrapper" },
            fieldApiName: "buySellPosition",
            isRedFlagStrength: true
        }
    },
    {
        label: BuySellPositionNow,
        fieldName: "buySellPosition",
        hideDefaultActions: "true",
        type: "customRecordDisplayType",
        typeAttributes: {
            showMoreShowLess: false
        }
    },
    { label: OurTeamMember, fieldName: "ourTeamMemberName", hideDefaultActions: "true" },
    { label: TitleLabel, fieldName: "ourTeamMemberTitle", hideDefaultActions: "true" },
    {
        type: "action",
        typeAttributes: { rowActions: actions },
        cellAttributes: {
            class: { fieldName: "cssClassforReadOnlyUsers" }
        } /*cellAttributes: { class: "cssAccessCheck"}  */
    }
];

export default class StrategicPlayers extends LightningElement {
    @track buySellPicklistOptions = [];
    @track rolePicklistOptions = [];

    @wire(getbuySellPicklistValues)
    buySellPicklistResult({ error, data }) {
        if (data) {
            const result = JSON.parse(data);
            for (let key in result) {
                if ({}.hasOwnProperty.call(result, key)) {
                    this.buySellPicklistOptions.push({ label: key, value: result[key] }); //Here we are creating the array to show on UI.
                }
            }
            this.buySellPicklistOptions.reverse();
        } else {
            this.error = error;
            //console.log(error);
        }
    }

    @wire(getRolePicklistValues)
    rolePicklistResult({ error, data }) {
        if (data) {
            const result = JSON.parse(data);
            for (let key in result) {
                if ({}.hasOwnProperty.call(result, key)) {
                    this.rolePicklistOptions.push({ label: key, value: result[key] }); //Here we are creating the array to show on UI.
                }
            }
            this.rolePicklistOptions.reverse();
        } else {
            this.error = error;
            //console.log(error);
        }
    }

    @api getIdFromParent;
    @track hasStrategicData = false;
    @track StrategicData = [];
    @track rowOffset = 0;
    @track columns = columns;
    @track _records = [];
    @track showEditView = false;
    @track showCreateView = false;
    @track ShowDeleteModal = false;
    @track deleteRecordId;
    @track isSaveDisabled = true;
    @track contactId = "";
    @track contactTitle;
    @track userTitle;
    @track objectForLookup;
    @track lookuptargetField;
    @track isSaveDisabled = true;
    @track buySellPosition;
    @track roleValue;
    @track contactId = "";
    @track teamMemberId;
    @track recordId;
    @track conname = "";
    @track hasEditAccess;
    @track showContactError = false;
    @track currentRow;
    @track accountOwner;
    @track accountOwnerTitle;
    @track accountId;
    @track editContactForm = false;
    queryOffset;
    queryLimit;
    totalRecordCount;

    @track rfsDetails = this.getNewRfsDetails();
    @track rfsMap = {};
    @track rfsMarker;

    allLabels = {
        Save,
        Yes,
        Delete,
        Edit,
        Name,
        Cancel,
        Close,
        AddNewStrategicPlayer,
        EditContactLabel,
        StrategicPlayer,
        StrategicPlayerMain,
        StrategicPlayerURL,
        Role,
        BuySellPositionNow,
        OurTeamMember,
        Error_Header,
        TitleLabel,
        ErrorDeleteFailed,
        RecordDeleted,
        SelectLevel,
        SelectRole,
        Success_header,
        Record_Error_Message,
        Record_Success_Message,
        ContactInformationLabel,
        StrategicPlayerEditContactInfoLabel,
        RoleStrategicPlayerURL,
        BuySellStrategicPlayerURL,
        DeleteStrategicPlayerLabel,
        DeleteStrategicPlayerMessage,
        AddressInformationLabel
    };
    getNewRfsDetails() {
        return {
            role: {
                redFlagSelected: false,
                strengthSelected: false,
                noneSelected: true,
                fieldApiName: "role"
            },
            buySellPosition: {
                redFlagSelected: false,
                strengthSelected: false,
                noneSelected: true,
                fieldApiName: "buySellPosition"
            }
        };
    }

    /*assignMapForRFS(flag) {
        this.rfsDetails.role = {
            redFlagSelected: flag.redFlagSelected,
            strengthSelected: flag.strengthSelected,
            noneSelected: flag.redFlagSelected && flag.strengthSelected,
            fieldApiName: "role"
        };
        this.rfsDetails.buySellPosition = {
            redFlagSelected: flag.redFlagSelected,
            strengthSelected: flag.strengthSelected,
            noneSelected: flag.redFlagSelected && flag.strengthSelected,
            fieldApiName: "buySellPosition"
        };
    }*/

    initializeVariables() {
        this.queryOffset = 0;
        this.queryLimit = 10;
    }

    connectedCallback() {
        this.initializeVariables();
        this.getObjectPermission();
        this.getDataFromBackEnd();
        this.getAccountOwnerTitle();
        this.loadRecords();
        this.getLookupObjects();
    }
    renderedCallback() {
        loadStyle(this, styles);
    }
    getLookupObjects() {
        getLookupObjects().then(result => {
            if (result) {
                this.objectForLookup = result.lookupOnObject;
                this.lookuptargetField = result.targetField;
            }
        });
    }
    getObjectPermission() {
        getObjectPermission().then(result => {
            this.hasEditAccess = result.isCreateable;
            // this.hasEditAccess = result;
            /*if(!this.hasEditAccess){
            this.template.querySelector(".cssAccessCheck").classList.add("slds-hide");
        }*/
        });
    }
    getAccountOwnerTitle() {
        getAccountOwnerTitle({ goldsheetId: this.getIdFromParent }).then(result => {
            this.accountOwner = result[0];
            this.accountId = result[1];
            this.accountOwnerTitle = result[2];
        });
    }
    //If marker updated then updated
    handleMarkerChange(event) {
        const eventChangedMarker = event.detail;
        const rfsDetailsUpdate = this.rfsDetails[eventChangedMarker.fieldApiName];
        Object.keys(rfsDetailsUpdate).forEach(key => {
            if (eventChangedMarker[key] !== undefined && eventChangedMarker[key] !== null) {
                rfsDetailsUpdate[key] = eventChangedMarker[key];
            }
        });
    }

    getDataFromBackEnd() {
        getStrategicPlayerData({
            goldsheetId: this.getIdFromParent,
            queryLimit: this.queryLimit,
            queryOffset: this.queryOffset
        }).then(result => {
            if (!result.length) {
                this.hasStrategicData = false;
            } else {
                this.hasStrategicData = true;
                this.StrategicData = result;
                /*if(result.length > 10){
                        this.template.querySelectorAll(".noscrollUI").forEach(function(el) {
                            el.classList.add("scrollableUI");
                        });
                    }else{
                        this.template.querySelectorAll(".noscrollUI").forEach(function(el) {
                            el.classList.remove("scrollableUI");
                        });
                    }*/
            }
        });
    }

    loadMoreData() {
        if (this.totalRecordCount > this.queryOffset) {
            this.queryOffset = this.queryOffset + 10;
            this.loadRecords();
        }
    }

    loadRecords() {
        let flatData;
        let playersList;
        return getPlayersList({
            goldSheetId: this.getIdFromParent,
            queryLimit: this.queryLimit,
            queryOffset: this.queryOffset
        })
            .then(result => {
                this.totalRecordCount = result.totalRecordCount;
                playersList = result.strategicPlayersRecords;
                if (!this.totalRecordCount) {
                    this.hasStrategicData = false;
                } else {
                    playersList.forEach(element => {
                        element.rfsMarkerWrapper = this.convertMarkerMap(element.rfsMarkerWrapper);
                    });
                }
                flatData = JSON.parse(JSON.stringify(result.strategicPlayersRecords));
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

    handleBuySellSelected(event) {
        this.buySellPosition = event.detail.value;
    }
    handleRoleSelected(event) {
        this.roleValue = event.detail.value;
    }
    handleTeamMemberSelected(event) {
        this.teamMemberId = event.detail;
        this.userTitle = " ";
        getUserTitle({ recordId: this.teamMemberId }).then(result => {
            if (result) {
                this.userTitle = result;
            }
        });
        if (!this.teamMemberId) {
            this.teamMemberId = null;
        }
    }

    handleRowAction(event) {
        const action = event.detail.action;
        //  console.log('row>>>'+JSON.stringify(row));
        switch (action.name) {
            case "edit":
                this.showCreateView = true;
                this.handleEdit(event);
                //this.showEditView = true;
                break;
            case "delete":
                this.handleDelete(event);
                break;
            default:
                break;
        }
    }

    handleEdit(event) {
        const row = event.detail.row;
        this.currentRow = JSON.parse(JSON.stringify(row));
        this.roleValue = row.role;
        this.buySellPosition = row.buySellPosition;
        this.conname = row.strategicPlayerLastName;
        if (row.strategicPlayerFirstName) {
            this.conname = row.strategicPlayerFirstName + " " + this.conname;
        }
        this.contactId = row.strategicPlayer;
        if (this.contactId) {
            this.selectedconname = true;
            this.isSaveDisabled = false;
        } else {
            this.selectedconname = false;
            this.isSaveDisabled = true;
        }
        this.teamMemberId = row.ourTeamMember;

        this.userTitle = row.ourTeamMemberTitle;
        //console.log('the user title'+JSON.stringify(this.userTitle));
        if (this.userTitle === undefined) {
            this.userTitle = " ";
        }
        this.contactTitle = row.strategicPlayerTitle;
        if (this.contactTitle === undefined) {
            this.contactTitle = " ";
        }
        this.recordId = row.id;
        this.showContactError = false;
        this.rfsDetails = this.currentRow.rfsMarkerWrapper;
    }

    navigateToEditRecordPage() {
        this.editContactForm = true;
        this.showCreateView = false;
    }
    handleSubmitEdit(event) {
        const confields = event.detail.fields;
        this.contactTitle = confields.Title;
        this.conname = confields.LastName;
        if (confields.FirstName) {
            this.conname = confields.FirstName + " " + this.conname;
        }
    }
    handleSuccessEdit() {
        this.editContactForm = false;
        this.showCreateView = true;
        if (this.conname) {
            this.selectedconname = true;
        } else {
            this.selectedconname = false;
        }
    }
    handleReset() {
        this.editContactForm = false;
        this.selectedconname = true;
        this.ShowEditContactBtn = true;
        this.showCreateView = true;
    }
    convertMarkerMap(rfsMarkerWrapper) {
        const markers = rfsMarkerWrapper;
        const markersMap = this.getNewRfsDetails();
        markers.forEach(marker => {
            markersMap[marker.fieldApiName] = marker;
        });
        return markersMap;
    }

    handleCreate() {
        this.showCreateView = true;
        this.recordId = null;
        this.roleValue = "";
        this.buySellPosition = "";
        this.conname = "";
        this.teamMemberId = null;
        this.userTitle = this.accountOwnerTitle;
        if (this.accountOwnerTitle === undefined) {
            this.userTitle = " ";
        } else {
            this.userTitle = this.accountOwnerTitle;
        }
        this.contactTitle = "";
        this.contactId = "";
        this.selectedconname = false;
        this.isSaveDisabled = true;
        this.showContactError = false;
        this.rfsDetails = {
            role: {
                redFlagSelected: false,
                strengthSelected: false,
                noneSelected: true,
                fieldApiName: "role"
            },
            buySellPosition: {
                redFlagSelected: false,
                strengthSelected: false,
                noneSelected: true,
                fieldApiName: "buySellPosition"
            }
        };
    }
    handleDelete(event) {
        this.ShowDeleteModal = true;
        this.deleteRecordId = event.detail.row.id;
    }

    handleTitle(event) {
        this.contactId = event.detail.recordId;
        if (this.contactId) {
            this.isSaveDisabled = false;
        } else {
            this.isSaveDisabled = true;
        }
        this.conTitle = event.detail.selectedtitle;
        this.conname = event.detail.selectedname;
        if (this.conTitle === undefined) {
            this.contactTitle = " ";
        } else {
            this.contactTitle = this.conTitle;
        }
    }

    handlenewrec(event) {
        this.contactTitle = event.detail.selectedtitle;
        this.contactId = event.detail.recordId;
        this.contactName = event.detail.selectedname;
        if (this.contactId) {
            this.isSaveDisabled = false;
        } else {
            this.isSaveDisabled = true;
        }
    }

    closeDeleteModal() {
        this.ShowDeleteModal = false;
    }
    deleteRecord() {
        removeStrategicPlayer({ recordId: this.deleteRecordId })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.allLabels.Success_header,
                        message: this.allLabels.RecordDeleted,
                        variant: this.allLabels.Success_header
                    })
                );
                this.ShowDeleteModal = false;
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
    handleEditCancel() {
        this.showEditView = false;
    }
    handleCreateCancel() {
        this.showCreateView = false;
        this.roleValue = "";
        this.buySellPosition = "";
        this.conname = "";
        this.teamMemberId = "";
        this.userTitle = "";
        this.contactTitle = "";
        this.isSaveDisabled = false;
        this.recordId = "";
        this.rfsDetails = this.getNewRfsDetails();
    }
    handleSave() {
        if (this.contactId) {
            this.showCreateView = false;

            let inputArray = {
                role: this.roleValue,
                buySellPosition: this.buySellPosition,
                strategicPlayer: this.contactId,
                ourTeamMember: this.teamMemberId,
                goldsheetId: this.getIdFromParent,
                id: this.recordId
            };

            saveStrategicPlayerData({ inputString: JSON.stringify(inputArray), rfsMap: this.rfsDetails })
                .then(result => {
                    if (result) {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: this.allLabels.Success_header,
                                message: this.allLabels.Record_Success_Message,
                                variant: this.allLabels.Success_header
                            })
                        );
                    }
                    this.handleRefresh();
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
        } else {
            //this.showContactError = true;
            // this.isSaveDisabled = false;
        }
    }

    handleRefresh() {
        this.StrategicData = [];
        this._records = [];
        this.queryOffset = 0;
        this.queryLimit = 10;
        this.getDataFromBackEnd();
        this.loadRecords();
    }
}