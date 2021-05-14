import { LightningElement, track, api, wire } from "lwc";
import SingleSalesObjectives from "@salesforce/label/c.SingleSalesObjectives";
import SSOBlueSheetURL from "@salesforce/label/c.SSOBlueSheetURL";
import SSOBlueSheetInstruction from "@salesforce/label/c.SSOBlueSheetInstruction";
import SSOBlueSheetAddButton from "@salesforce/label/c.SSOBlueSheetAddButton";
import maxLimitError from "@salesforce/label/c.maxLimitError";
import getSingleSalesObjectiveAccess from "@salesforce/apex/SingleSalesObjectiveBlueSheet.getSingleSalesObjectiveAccess";
import getSingleSalesObjective from "@salesforce/apex/SingleSalesObjectiveBlueSheet.getSingleSalesObjective";
import saveSingleSalesObjective from "@salesforce/apex/SingleSalesObjectiveBlueSheet.saveSingleSalesObjective";
import cancel from "@salesforce/label/c.cancel";
import save from "@salesforce/label/c.save";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import successheader from "@salesforce/label/c.success_header";
import errorheader from "@salesforce/label/c.error_header";
import errormsg from "@salesforce/label/c.Record_error_message";
import successmsg from "@salesforce/label/c.Record_success_message";
import Loading from "@salesforce/label/c.Loading";
import edit from "@salesforce/label/c.edit";
import { registerListener } from "c/eventForBlueSheetProgress";
import { CurrentPageReference } from "lightning/navigation";

export default class SingleSalesObjectiveBlueSheet extends LightningElement {
    @track checkNoDataAndReadOnlyAccess = false;
    @track isCreateable = false;
    @track IsAddButtonDisabled = false;
    @track showCreateView = false;
    @track showMaxLimitError = false;
    @track disabledSaveButton = false;
    @track isSingleSalesObjectiveEmpty = false;
    @track SSOBSData;
    @track SSOBSSavedData;
    @track SSOMasterData;
    @track showSavedState = false;
    @track isCreateVisible = true;
    @track isUpdatable = false;
    @track _getIdFromParent;
    @api
    get getIdFromParent() {
        return this._getIdFromParent;
    }

    set getIdFromParent(value) {
        this._getIdFromParent = value;
        this.checkAccessOfUser();
        this.getsingleSalesObjectiveBlueSheet();
    }
    //code to show hide the daata on self guided journey tootip
    @wire(CurrentPageReference) pageRef;
    @track moduleLearningCompleted = false;
    @track _moduleData;
    @track moduleSection;

    @api get moduleData() {
        return this._moduleData;
    }
    set moduleData(value) {
        this._moduleData = value;
        this.ProcessModuleData();
    }
    ProcessModuleData() {
        if (this._moduleData) {
            this.ShowModuleDependentData();
            if (this._moduleData.moduleNameId === "Lesson_3_Module_3") {
                this.moduleSection = "SingleSalesObjective";
            }
            if (this.moduleData && this.moduleData.moduleBluesheetProgress === "Completed") {
                this.moduleLearningCompleted = true;
            }
        }
    }
    ShowModuleDependentData() {
        this.moduleLearningCompleted = true;
        if (this.template.querySelector("c-go-to-bluesheet-prompts")) {
            this.template.querySelector("c-go-to-bluesheet-prompts").reloadPrompt();
        }
    }
    connectedCallback() {
        registerListener("ModuleDataSSOBluesheet", this.reloadModuleData, this);
    }
    reloadModuleData(moduleData) {
        this._moduleData = moduleData;
        this.ProcessModuleData();
    }
    //end of code

    label = {
        edit,
        Loading,
        successmsg,
        errormsg,
        errorheader,
        successheader,
        SingleSalesObjectives,
        SSOBlueSheetURL,
        SSOBlueSheetInstruction,
        SSOBlueSheetAddButton,
        cancel,
        save,
        maxLimitError
    };

    @track rfsDetails = this.getNewRfsDetails();

    getNewRfsDetails() {
        return {
            singleSalesObjectiveBlueSheet: {
                redFlagSelected: false,
                strengthSelected: false,
                noneSelected: true,
                fieldApiName: "singleSalesObjectiveBlueSheet"
            }
        };
    }

    checkAccessOfUser() {
        getSingleSalesObjectiveAccess().then(result => {
            this.isCreateable = result.isCreateable;
            this.isUpdatable = result.isUpdateable;
        });
    }

    getsingleSalesObjectiveBlueSheet() {
        getSingleSalesObjective({ bluesheetId: this.getIdFromParent })
            .then(res => {
                this.setSingleSalesObjValue(res);
            })
            .catch(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.label.SingleSalesObjectives,
                        message: this.label.ErrorOccured, //KFS-2766
                        variant: "error"
                    })
                );
            });
    }
    handleCreateNewSSO() {
        this.showCreateView = true;
        this.IsAddButtonDisabled = true;
        this.disabledSaveButton = true;
        this.showSavedState = false;
        this.rfsDetails = this.getNewRfsDetails();
    }
    handleMarkerChange(event) {
        const eventChangedMarker = event.detail;
        const rfsDetailsUpdate = this.rfsDetails[eventChangedMarker.fieldApiName];
        Object.keys(rfsDetailsUpdate).forEach(key => {
            if (eventChangedMarker[key] !== undefined && eventChangedMarker[key] != null) {
                rfsDetailsUpdate[key] = eventChangedMarker[key];
            }
        });
    }
    handleEdit() {
        this.showCreateView = true;
        this.IsAddButtonDisabled = true;
        this.disabledSaveButton = false;
        this.showSavedState = false;
        this.SSOBSData = this.SSOBSSavedData;
    }
    handleSave() {
        this.cvShowSpinner = true;
        this.showMaxLimitError = false;
        let SSOBSToSave = {
            singleSalesObjectiveBS: this.SSOBSData,
            blueSheetId: this.getIdFromParent,
            hasEditAccess: this.hasAccess
        };
        saveSingleSalesObjective({ inputString: JSON.stringify(SSOBSToSave), rfsMap: this.rfsDetails })
            .then(res => {
                this.setSingleSalesObjValue(res);
                this.showCreateView = false;
                this.IsAddButtonDisabled = false;
                this.disabledSaveButton = true;
                this.cvShowSpinner = false;
                this.showSavedState = true;
                this.showToast(this.label.successheader, this.label.successmsg, "success");
            })
            .catch(() => {
                this.cvShowSpinner = false;
                this.showToast(this.label.errorheader, this.label.errormsg, "error");
            });
    }
    showToast(header, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: header,
                message: message,
                variant: variant
            })
        );
    }
    handleCancelClick() {
        this.showCreateView = false;
        this.IsAddButtonDisabled = false;
        this.showAccountError = false;
        this.disableAddButton = true;
        this.showSavedState = true;
        this.SSOBSData = "";
        if (this.SSOMasterData && this.SSOMasterData.rfsMarkerWrapper.length > 0) {
            this.setSingleSalesObjValue(this.SSOMasterData);
        } else {
            this.rfsDetails = this.getNewRfsDetails();
        }
    }
    setSingleSalesObjValue(res) {
        this.SSOMasterData = JSON.parse(JSON.stringify(res));
        this.SSOBSSavedData = res.singleSalesObjectiveBS;
        if (this.SSOBSSavedData && this.SSOBSSavedData.length > 0) {
            this.isCreateVisible = false;
            this.showSavedState = true;
            this.isSingleSalesObjectiveEmpty = false;
        } else {
            this.isSingleSalesObjectiveEmpty = true;
        }
        this.isUpdatable = res.hasEditAccess;
        if (res.rfsMarkerWrapper.length > 0) {
            this.rfsDetails = this.convertMarkerMap(res.rfsMarkerWrapper);
            this.rfsInitialDetails = JSON.parse(JSON.stringify(this.rfsDetails));
        }
    }
    convertMarkerMap(rfsMarkerWrapper) {
        const markers = rfsMarkerWrapper;
        const markersMap = this.getNewRfsDetails();
        markers.forEach(marker => {
            markersMap[marker.fieldApiName] = marker;
        });
        return markersMap;
    }
    handleMaxLimitError(event) {
        let checkTypeLimit = event.target.value;
        this.SSOBSData = checkTypeLimit;
        if (this.SSOBSData.length >= 32000) {
            this.showMaxLimitError = true;
            this.disabledSaveButton = true;
        } else {
            this.showMaxLimitError = false;
            this.disabledSaveButton = false;
        }
        if (!this.SSOBSData || this.SSOBSData.trim() === "") {
            this.disabledSaveButton = true;
        }
    }
}