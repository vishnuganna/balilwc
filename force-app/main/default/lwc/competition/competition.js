import { LightningElement, api, track, wire } from "lwc";
import getCurrentCompetitorData from "@salesforce/apex/Competition.getCompetition";
import saveCompetitionData from "@salesforce/apex/Competition.saveCompetition";
import objectForLookup from "@salesforce/apex/Competition.getObjectName";
import addCompetitior from "@salesforce/label/c.addCompetitior";
import buyingFromSomeOneElse from "@salesforce/label/c.buyingFromSomeOneElse";
import close from "@salesforce/label/c.close";
import competitionLabel from "@salesforce/label/c.competition";
import competitionTypeLabel from "@salesforce/label/c.competitionType";
import competitior from "@salesforce/label/c.competitior";
import competitiveDetail from "@salesforce/label/c.competitiveDetail";
import competitiveDetails from "@salesforce/label/c.competitiveDetails";
import deleteCompetition from "@salesforce/label/c.deleteCompetition";
import deleteCompetitionMessage from "@salesforce/label/c.deleteCompetitionMessage";
import doingNothing from "@salesforce/label/c.doingNothing";
import frontRunner from "@salesforce/label/c.frontRunner";
import myPositionvsCompetitior from "@salesforce/label/c.myPositionvsCompetitior";
import no from "@salesforce/label/c.no";
import onlyAlternative from "@salesforce/label/c.onlyAlternative";
import searchCompetitior from "@salesforce/label/c.searchCompetitior";
import shared from "@salesforce/label/c.shared";
import showLess from "@salesforce/label/c.showLess";
import showMore from "@salesforce/label/c.showMore";
import usingBudgetforSomething from "@salesforce/label/c.usingBudgetforSomething";
import usingInternalResource from "@salesforce/label/c.usingInternalResource";
import yes from "@salesforce/label/c.yes";
import zero from "@salesforce/label/c.zero";
import cancel from "@salesforce/label/c.cancel";
import save from "@salesforce/label/c.save";
import nameSpaceLabel from "@salesforce/label/c.nameSpace";
import successheader from "@salesforce/label/c.success_header";
import errorheader from "@salesforce/label/c.error_header";
import errormsg from "@salesforce/label/c.Record_error_message";
import successmsg from "@salesforce/label/c.Record_success_message";
import CompetitionHeaderURL from "@salesforce/label/c.CompetitionHeaderURL";
import myPosVsCompetitionURL from "@salesforce/label/c.myPosVsCompetitionURL";
import maxLimitErrorLabel from "@salesforce/label/c.maxLimitError";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import checkAccess from "@salesforce/apex/Competition.getCompetitionAccess";
import getOppId from "@salesforce/apex/StrategyEngine.getOppId";
import pubsub from "c/pubSub";
import { CurrentPageReference } from "lightning/navigation";
import categoryCompetitor from "@salesforce/label/c.CategoryCompetitor";
import checkCompetitivePreference from "@salesforce/apex/GuidedLearningModuleProgress.checkCompetitivePreference";
import checkMyPositionVsCompetitor from "@salesforce/apex/GuidedLearningModuleProgress.checkMyPositionVsCompetitor";
import { registerListener } from "c/eventForBlueSheetProgress";

export default class competition extends LightningElement {
    // @api getIdFromParent;
    @api objectApiName;
    @track _getIdFromParent;
    @api
    get getIdFromParent() {
        return this._getIdFromParent;
    }

    set getIdFromParent(value) {
        this._getIdFromParent = value;
        getOppId({ blueSheetId: this.getIdFromParent }).then(result => {
            this.optyId = result;
            this.checkAccessAndGetCompetitionData();
        });
    }

    @track isLoading = false;
    @track showSaveButton = true;
    @track accountId;
    @track competitorName = null;
    @track competitionType = null;
    @track positionVsCompetitior = null;
    @track competitiveDetail = null;
    @track showCreateView = false;
    @track hasCompetitorData = false;
    @track result;

    @api recordId;
    @track competitorData;
    @track hasEditAccess = true;

    @track disableAddButton;
    @track showLookUp = true;
    @track lookupObject;
    @track lookuptargetField;
    @track showMaxLimitError = false;

    @track showAccountError = false;

    @track isredflagTrue = true;
    @track isStrengthTrue = true;
    @track noneSelected = true;
    @track bluesheetId = "";
    @track sourceId = "";
    @track rfsMap = {};
    @track rfsComp = {};
    @track checkNoDataAndReadOnlyAccess = false;
    @track optyId = "";
    @api showonbs = false;
    @wire(CurrentPageReference) pageRef;

    //code to show hide the daata on self guided journey tootip
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
            if (this._moduleData.moduleNameId === "Lesson_7_Module_2") {
                this.moduleSection = "CompetitivePreference";
                if (this._moduleData.moduleBluesheetProgress === "Completed") {
                    this.moduleLearningCompleted = true;
                } else {
                    this.checkForCompetitivePreference();
                }
            } else if (this._moduleData.moduleNameId === "Lesson_7_Module_3") {
                this.moduleSection = "MyPositionVsCompetitor";
                if (this._moduleData.moduleBluesheetProgress === "Completed") {
                    this.moduleLearningCompleted = true;
                } else {
                    this.checkForMyPositionVsCompetitor();
                }
            }
        }
    }

    checkForCompetitivePreference() {
        checkCompetitivePreference().then(result => {
            if (result === true) {
                this.moduleLearningCompleted = true;
            } else {
                this.moduleLearningCompleted = false;
            }
        });
    }

    checkForMyPositionVsCompetitor() {
        checkMyPositionVsCompetitor().then(result => {
            if (result === true) {
                this.moduleLearningCompleted = true;
            } else {
                this.moduleLearningCompleted = false;
            }
        });
    }

    showModuleDependentData() {
        if (this.moduleLearningCompleted !== true) {
            if (this.moduleData && this.moduleData.moduleBluesheetProgress === "Completed") {
                this.moduleLearningCompleted = true;
            } else {
                if (this.moduleData && this.moduleData.moduleNameId === "Lesson_7_Module_2") {
                    this.checkForCompetitivePreference();
                } else if (this.moduleData && this.moduleData.moduleNameId === "Lesson_7_Module_3") {
                    this.checkForMyPositionVsCompetitor();
                }
            }
        } else {
            this.moduleLearningCompleted = true;
        }
        if (this.template.querySelector("c-go-to-bluesheet-prompts")) {
            this.template.querySelector("c-go-to-bluesheet-prompts").reloadPrompt();
        }
    }
    //end of code

    label = {
        addCompetitior,
        buyingFromSomeOneElse,
        close,
        competitionLabel,
        competitionTypeLabel,
        competitior,
        competitiveDetail,
        competitiveDetails,
        deleteCompetition,
        deleteCompetitionMessage,
        doingNothing,
        frontRunner,
        myPositionvsCompetitior,
        no,
        onlyAlternative,
        searchCompetitior,
        shared,
        showLess,
        showMore,
        usingBudgetforSomething,
        usingInternalResource,
        yes,
        zero,
        cancel,
        save,
        nameSpaceLabel,
        maxLimitErrorLabel,
        successheader,
        errorheader,
        errormsg,
        successmsg,
        CompetitionHeaderURL,
        myPosVsCompetitionURL,
        categoryCompetitor
    };

    @track
    rfsDetails = this.getNewRfsDetails();
    @track isCreateable = false;

    getNewRfsDetails() {
        return {
            competitor: {
                redFlagSelected: false,
                strengthSelected: false,
                noneSelected: true,
                fieldApiName: "competitor"
            },
            competitiveDetail: {
                redFlagSelected: false,
                strengthSelected: false,
                noneSelected: true,
                fieldApiName: "competitiveDetail"
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

    handleValueSelcted(event) {
        this.accountId = event.detail.selectedRecordId;
        if (this.accountId && this.accountId.length > 0) {
            this.showSaveButton = false;
        } else {
            this.showSaveButton = true;
        }
        if (this.accountId) {
            this.competitionType = "Buying from Someone Else";
            this.showAccountError = false;
            this.competitiorTyepName = "";
            this.template.querySelectorAll(".competitorTypeButtons").forEach(function(el) {
                el.classList.remove("btnClicked");
            });
            this.template.querySelector(`[data-target-id="buyfromelse"]`).classList.toggle("btnClicked");
        } else {
            this.showSaveButton = true;
        }
    }

    connectedCallback() {
        this.showonbs = true;
        objectForLookup().then(result => {
            this.objectForLookup = result.lookupOnObject;
            this.lookuptargetField = result.targetField;
        });
        registerListener("ModuleDataCompetition", this.reloadModuleData, this);
    }

    reloadModuleData(moduleData) {
        this._moduleData = moduleData;
        this.ProcessModuleData();
    }

    checkAccessAndGetCompetitionData() {
        checkAccess().then(result => {
            this.isCreateable = result.isCreateable;
            this.getDataFromBackend();
        });
    }

    getDataFromBackend() {
        this.competitorData = null;
        this.hasCompetitorData = false;
        getCurrentCompetitorData({ oppId: this.optyId })
            .then(result => {
                this.result = result;
                if (!result.length) {
                    this.hasCompetitorData = false;
                    this.checkNoDataAndReadOnlyAccess = !this.isCreateable;
                } else {
                    this.hasCompetitorData = true;
                    this.competitorData = this.result;
                    //this.hasEditAccess = this.result[0].hasEditAccess;
                }
            })
            .catch(() => {
                this.Result = undefined;
            });
    }

    handleCreateNew() {
        this.showCreateView = true;
        this.disableAddButton = true;
        this.competitorName = null;
        this.competitiveDetail = null;
        this.positionVsCompetitior = null;
        this.showLookUp = true;
        this.showSaveButton = true;
        this.showAccountError = false;
        this.showMaxLimitError = false;
        this.accountId = "";
        this.rfsDetails = {
            competitor: {
                redFlagSelected: false,
                strengthSelected: false,
                noneSelected: true,
                fieldApiName: "competitor"
            },
            competitiveDetail: {
                redFlagSelected: false,
                strengthSelected: false,
                noneSelected: true,
                fieldApiName: "competitiveDetail"
            }
        };
    }

    handleCancelClick() {
        this.showCreateView = false;
        this.disableAddButton = false;
        this.showAccountError = false;
        this.showSaveButton = true;
        this.rfsDetails = this.getNewRfsDetails();
    }

    handleProgress() {
        let data = {
            type: "refreshInsights",
            showActionInsight: true
        };
        const selectedEvent = new CustomEvent("updateprogressfromchild", {
            detail: data
        });
        this.dispatchEvent(selectedEvent);
    }

    handleSave() {
        if (
            this.competitionType !== "Buying from Someone Else" ||
            (this.competitionType === "Buying from Someone Else" && this.accountId !== null && this.accountId !== "")
        ) {
            this.showCreateView = false;
            this.disableAddButton = false;

            let IPDetails = {
                name: this.competitorName,
                compType: this.competitionType,
                posVsCmp: this.positionVsCompetitior,
                details: this.competitiveDetail,
                compNameType: this.competitiorTyepName
            };
            saveCompetitionData({
                competitorData: IPDetails,
                oppId: this.optyId,
                account: this.accountId,
                rfsMap: this.rfsDetails
            })
                .then(result => {
                    this.result = result;

                    if (this.result == null) {
                        this.hasCompetitorData = false;
                    } else {
                        this.hasCompetitorData = true;
                        this.competitorData = this.result;
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: this.label.successheader,
                                message: this.label.successmsg,
                                variant: "success"
                            })
                        );
                        pubsub.fire("refreshBestActionGrid", "");
                        this.showModuleDependentData();
                        this.handleProgress();
                    }
                })
                .catch(() => {
                    this.Result = undefined;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: this.label.errorheader,
                            message: this.label.errormsg,
                            variant: "error"
                        })
                    );
                });
            if (this.template.querySelector(".divClass") != null) {
                this.template.querySelector(".divClass").scrollIntoView(true);
            }
        } else {
            this.showAccountError = true;
            this.showSaveButton = true;
            this.template.querySelector(".lookupcomp").classList.add("highlightborder");
        }
    }

    handleCompDetailUpdate(event) {
        this.competitiveDetail = event.target.value;
    }

    handleCompetitiorName() {
        this.accountId = "";
    }

    handleCompetativeType(event) {
        this.competitionType = event.target.value;
        this.competitiorTyepName = event.target.value;
        this.showSaveButton = false;

        if (this.competitionType === "Buying from Someone Else") {
            this.competitiorTyepName = "";

            if (this.accountId === undefined || this.accountId === "") {
                this.showAccountError = true;
                this.showSaveButton = true;
            }
        }
        this.template.querySelectorAll(".competitorTypeButtons").forEach(function(el) {
            el.classList.remove("btnClicked");
        });
        const evt = event.currentTarget;
        evt.classList.toggle("btnClicked");
        if (this.competitionType !== "Buying from Someone Else") {
            this.competitorName = this.competitionType;
            this.showLookUp = false;
            this.accountId = "";
        } else {
            this.showLookUp = true;
            this.competitorName = "";
        }
    }
    handleMyPositionVsCompetitor(event) {
        this.positionVsCompetitior = event.currentTarget.value;

        this.template.querySelectorAll(".competitorpositionButtons").forEach(function(el) {
            el.classList.remove("btnClicked");
        });
        const evt = event.currentTarget;
        evt.classList.toggle("btnClicked");
    }
    handlerefresh() {
        this.getDataFromBackend();
        this.showModuleDependentData();
        this.handleProgress();
        if (this.template.querySelector(".divClass") != null) {
            this.template.querySelector(".divClass").scrollIntoView(true);
        }
    }

    handleEdit() {
        this.disableAddButton = true;
    }
    handleEnableButton() {
        this.disableAddButton = false;
    }
    handleMaxLimitError(event) {
        var checkCompetitionTypeLimit = event.target.value;
        if (checkCompetitionTypeLimit.length === 32000) {
            this.showMaxLimitError = true;
        } else {
            this.showMaxLimitError = false;
        }
    }

    handleRfsValue(event) {
        this.rfsComp = event.detail;
    }
}