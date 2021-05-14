import { LightningElement, api, track, wire } from "lwc";
import getAllScoreCard from "@salesforce/apex/ScoreCard.getAllScoreCard";
import getScoreCardTemplateCriteria from "@salesforce/apex/ScoreCard.getScoreCardTemplateCriteria";
import saveScoreCardData from "@salesforce/apex/ScoreCard.saveScoreCardData";
import getScoreCardForOppty from "@salesforce/apex/ScoreCard.getScoreCardForOppty";
import deleteScoreCard from "@salesforce/apex/ScoreCard.deleteScoreCard";
import getOpptyName from "@salesforce/apex/ScoreCard.getOpptyName";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import yes from "@salesforce/label/c.yes";
import no from "@salesforce/label/c.no";
import cancel from "@salesforce/label/c.cancel";
import save from "@salesforce/label/c.save";
import edit from "@salesforce/label/c.edit";
import deleteLabel from "@salesforce/label/c.delete";
import successheader from "@salesforce/label/c.success_header";
import errorheader from "@salesforce/label/c.error_header";
import deletemsg from "@salesforce/label/c.Record_delete_message";
import errormsg from "@salesforce/label/c.Record_error_message";
import successmsg from "@salesforce/label/c.Record_success_message";
import businessCriteria from "@salesforce/label/c.businessCriteria";
import businessScore from "@salesforce/label/c.businessScore";
import opportunityCriteria from "@salesforce/label/c.opportunityCriteria";
import opportunityScore from "@salesforce/label/c.opportunityScore";
import potentialScore from "@salesforce/label/c.potentialScore";
import Scorecard from "@salesforce/label/c.Scorecard";
import scorecardTotal from "@salesforce/label/c.scorecardTotal";
import unknown from "@salesforce/label/c.unknown";
import deleteScoreCardMessage from "@salesforce/label/c.deleteScoreCardMessage";
import totalScores from "@salesforce/label/c.totalScores";
import deleteScoreMsg from "@salesforce/label/c.deleteScoreCard";
import addScoreCard from "@salesforce/label/c.addScoreCard";
import singleSalesObjective from "@salesforce/label/c.singleSalesObjective";
import ScorecardHeaderURL from "@salesforce/label/c.ScorecardHeaderURL";
import getOppId from "@salesforce/apex/StrategyEngine.getOppId";
import pubsub from "c/pubSub";
import exportToPdf from "@salesforce/label/c.exportToPdf";
import getNamespaceWithUnderScores from "@salesforce/apex/Util.getNamespaceWithUnderScores";
import close from "@salesforce/label/c.close";
import checkScoreCardForDecision from "@salesforce/apex/GuidedLearningModuleProgress.checkScoreCardForDecision";
import { registerListener } from "c/eventForBlueSheetProgress";
import { CurrentPageReference } from "lightning/navigation";

export default class ScoreCard extends LightningElement {
    // @api getIdFromParent;
    @track _getIdFromParent;
    @api
    get getIdFromParent() {
        return this._getIdFromParent;
    }

    set getIdFromParent(value) {
        this._getIdFromParent = value;
        getNamespaceWithUnderScores()
            .then(result => {
                if (result !== "") {
                    this.namespaceVar = result + this.namespaceVar;
                }
            })
            .catch(error => {
                // eslint-disable-next-line no-console
                console.log(JSON.stringify(error));
            });

        getOppId({ blueSheetId: this.getIdFromParent }).then(result => {
            this.optyId = result;
            this.getScorecardDetails();
            this.getOpptyName();
        });
    }

    namespaceVar = "ScorecardA4";

    @track hasEditAccess = false;
    @track showCreateView = false;
    @track showEditView = false;
    @track showButtons = true;
    @track showCreateEditView = false;
    @track allAdminScoreCards;
    @track selectOptions = [];
    @track selectedScoreCard;
    @track scoreCardCriterias = [];
    @track scoreCardData;
    @track opptyName;
    @track disableSave = false;
    @track disableCancel = false;
    @track showDefault = true;
    @track ShowModal = false;
    @track disableEdit = true;
    @track showDelete = true;
    @track showEditClicked = false;
    @track totalScore = 0;
    @track opptyScore = 0;
    @track scorecardName;
    @track potentialScore = 100;
    @track businessScore = 0;
    renderData = true;
    @track optyId = "";

    //code to show hide the daata on self guided journey tootip
    @track moduleLearningCompleted = false;
    @track _moduleData;
    @track moduleSection;
    @wire(CurrentPageReference) pageRef;

    @api get moduleData() {
        return this._moduleData;
    }
    set moduleData(value) {
        this._moduleData = value;
        this.ProcessModuleData();
    }
    ProcessModuleData() {
        if (this._moduleData) {
            this.showModuleDependentData();
            if (this._moduleData.moduleNameId === "Lesson_5_Module_5") {
                this.moduleSection = "Scorecard";
                if (this._moduleData.moduleBluesheetProgress === "Completed") {
                    this.moduleLearningCompleted = true;
                } else {
                    this.checkScorecard();
                }
            }
        }
    }

    checkScorecard() {
        checkScoreCardForDecision().then(backendResult => {
            let result = backendResult;
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
                this.checkScorecard();
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
        no,
        yes,
        cancel,
        save,
        edit,
        deleteLabel,
        successheader,
        errorheader,
        deletemsg,
        errormsg,
        successmsg,
        businessCriteria,
        businessScore,
        opportunityCriteria,
        opportunityScore,
        potentialScore,
        Scorecard,
        scorecardTotal,
        unknown,
        deleteScoreCardMessage,
        totalScores,
        deleteScoreMsg,
        addScoreCard,
        singleSalesObjective,
        ScorecardHeaderURL,
        exportToPdf,
        close
    };

    connectedCallback() {
        getAllScoreCard().then(result => {
            this.allAdminScoreCards = result;
            if (this.allAdminScoreCards) {
                this.hasEditAccess = this.allAdminScoreCards[0].hasEditAccess;
                for (const list of this.allAdminScoreCards) {
                    const option = {
                        label: list.name,
                        value: list.templateId
                    };
                    // this.selectOptions.push(option);
                    this.selectOptions = [...this.selectOptions, option];
                    this.selectedScoreCard = this.selectOptions[0].value;
                }
            }
        });
        registerListener("ModuleDataScoreCard", this.reloadModuleData, this);
    }
    reloadModuleData(moduleData) {
        this._moduleData = moduleData;
        this.ProcessModuleData();
    }

    getOpptyName() {
        getOpptyName({ opptyId: this.optyId }).then(result => {
            this.opptyName = result;
        });
    }

    getScorecardDetails() {
        getScoreCardForOppty({ opptyId: this.optyId }).then(result => {
            if (result) {
                this.scoreCardData = result;
                this.scoreCardCriterias = this.scoreCardData;
                if (this.scoreCardData) {
                    //this.scoreCardCriterias.templateCriteria = this.scoreCardData.templateCriteria;
                    this.opptyScore = this.scoreCardData.opportunityScore;
                    this.potentialScore = this.scoreCardData.potentialScore;
                    this.businessScore = this.scoreCardData.businessScore;
                    this.totalScore = this.scoreCardData.totalPoints;
                    this.scorecardName = this.scoreCardData.name;
                    this.hasEditAccess = this.scoreCardData.hasEditAccess;
                    //this.totalScore = this.scoreCardData.
                }

                if (this.scoreCardData) {
                    this.showDefault = false;
                    this.disableEdit = false;
                    this.showButtons = false;
                    if (this.showEditClicked) {
                        this.showButtons = true;
                        this.showEditClicked = false;
                    }
                    for (const list of this.scoreCardData.templateCriteria) {
                        if (this.scoreValue === "Yes") {
                            list.classList.add("btnClickedYes");
                        } else if (this.scoreValue === "No") {
                            list.classList.add("btnClickedNo");
                        } else if (this.scoreValue === "Unknown") {
                            list.classList.add("btnClickedUnknown");
                        }
                    }
                } else {
                    this.disableEdit = true;
                }
            }
            this.renderData = true;
        });
    }

    renderedCallback() {
        if (this.renderData) {
            if (this.scoreCardData && this.scoreCardData.templateCriteria) {
                for (const list of this.scoreCardData.templateCriteria) {
                    for (const el of this.template.querySelectorAll(".yesButton")) {
                        if (
                            (list.templateCriteriaId && list.templateCriteriaId === el.value) ||
                            (list.id && list.id === el.value)
                        ) {
                            if (list.scoreValue === "Yes") {
                                el.classList.add("btnClickedYes");
                            }
                        }
                    }
                    for (const el of this.template.querySelectorAll(".unknownButton")) {
                        if (
                            (list.templateCriteriaId && list.templateCriteriaId === el.value) ||
                            (list.id && list.id === el.value)
                        ) {
                            if (list.scoreValue === "Unknown") {
                                el.classList.add("btnClickedUnknown");
                            }
                        }
                    }
                    for (const el of this.template.querySelectorAll(".noButton")) {
                        if (
                            (list.templateCriteriaId && list.templateCriteriaId === el.value) ||
                            (list.id && list.id === el.value)
                        ) {
                            if (list.scoreValue === "No") {
                                el.classList.add("btnClickedNo");
                            }
                        }
                    }
                }
            }
        }
    }

    handleCreateNew() {
        if (this.selectedScoreCard) {
            this.getScorecardDetails();
            this.showCreateView = true;
            this.showEditView = false;
            this.showButtons = true;
            this.showCreateEditView = true;
            this.scorecardName = null;
            this.opptyScore = 0;
            this.potentialScore = 100;
            this.businessScore = 0;
            this.totalScore = 0;
            this.handleGetScoreCardCriteria();
        }
    }

    handleGetScoreCardCriteria() {
        getScoreCardTemplateCriteria({ scoreCardId: this.selectedScoreCard }).then(result => {
            this.scoreCardCriterias = result;
            this.tempScoreCardCriterias = JSON.parse(JSON.stringify(this.scoreCardCriterias));
            for (const list of this.tempScoreCardCriterias.templateCriteria) {
                list.currentScore = 0;
                if (list.section === "Opportunity") {
                    list.isOpptySection = true;
                } else {
                    list.isOpptySection = false;
                }
            }
            this.scoreCardCriterias = this.tempScoreCardCriterias;
        });
    }

    handleDelete() {
        this.ShowModal = true;
    }
    deleteModal() {
        this.ShowModal = false;
        this.showButtons = true;

        deleteScoreCard({ scoreCardId: this.scoreCardData.id })
            .then(() => {
                this.showDefault = true;
                this.scoreCardData = null;

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.label.successheader,
                        message: this.label.deletemsg,
                        variant: "success"
                    })
                );
                this.dispatchEventToParent();
                pubsub.fire("refreshBestActionGrid", "");
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
    }
    closeModal() {
        this.ShowModal = false;
    }

    handleChangeScoreCard(event) {
        this.value = event.detail.value;
        this.selectedScoreCard = event.detail.value;
    }
    selectYes(event) {
        this.scoreTitle = event.target.value;

        if (this.scoreCardData) {
            this.tempScoreCardCriterias = JSON.parse(JSON.stringify(this.scoreCardData));
        } else {
            this.tempScoreCardCriterias = JSON.parse(JSON.stringify(this.scoreCardCriterias));
        }
        for (const list of this.tempScoreCardCriterias.templateCriteria) {
            if (
                (list.templateCriteriaId && this.scoreTitle === list.templateCriteriaId) ||
                (list.id && this.scoreTitle === list.id)
            ) {
                if (list.scoreValue === "No" && this.potentialScore !== 100) {
                    this.potentialScore = this.potentialScore + list.pointValue;
                }
                if (list.currentScore !== list.pointValue) {
                    this.totalScore = this.totalScore + list.pointValue;
                    if (list.isOpptySection) {
                        this.opptyScore = this.opptyScore + list.pointValue;
                    } else {
                        this.businessScore = this.businessScore + list.pointValue;
                    }
                    list.currentScore = list.pointValue;
                }
                list.scoreValue = "Yes";
            }
        }
        for (const el of this.template.querySelectorAll(".scoreButtons")) {
            if (this.scoreTitle === el.value) {
                el.classList.remove("btnClickedUnknown");
                el.classList.remove("btnClickedNo");
            }
        }
        const evt = event.currentTarget;
        evt.classList.toggle("btnClickedYes");

        this.scoreCardCriterias = this.tempScoreCardCriterias;
        this.scoreCardData = this.tempScoreCardCriterias;
    }
    selectUnknown(event) {
        this.scoreTitle = event.target.value;
        if (this.scoreCardData) {
            this.tempScoreCardCriterias = JSON.parse(JSON.stringify(this.scoreCardData));
        } else {
            this.tempScoreCardCriterias = JSON.parse(JSON.stringify(this.scoreCardCriterias));
        }
        for (const list of this.tempScoreCardCriterias.templateCriteria) {
            if (
                (list.templateCriteriaId && this.scoreTitle === list.templateCriteriaId) ||
                (list.id && this.scoreTitle === list.id)
            ) {
                if (list.scoreValue === "No" && this.potentialScore !== 100) {
                    this.potentialScore = this.potentialScore + list.pointValue;
                }
                if (list.currentScore !== 0) {
                    this.totalScore = this.totalScore - list.pointValue;
                    if (list.isOpptySection) {
                        this.opptyScore = this.opptyScore - list.pointValue;
                    } else {
                        this.businessScore = this.businessScore - list.pointValue;
                    }
                    list.currentScore = 0;
                } else {
                    this.totalScore = this.totalScore + 0;
                    if (list.isOpptySection) {
                        this.opptyScore = this.opptyScore + 0;
                    } else {
                        this.businessScore = this.businessScore + 0;
                    }
                    list.currentScore = 0;
                }

                list.scoreValue = "Unknown";
            }
        }
        for (const el of this.template.querySelectorAll(".scoreButtons")) {
            if (this.scoreTitle === el.value) {
                el.classList.remove("btnClickedYes");
                el.classList.remove("btnClickedNo");
            }
        }
        const evt = event.currentTarget;
        evt.classList.toggle("btnClickedUnknown");

        this.scoreCardCriterias = this.tempScoreCardCriterias;
        this.scoreCardData = this.tempScoreCardCriterias;
    }
    selectNo(event) {
        this.scoreTitle = event.target.value;
        if (this.scoreCardData) {
            this.tempScoreCardCriterias = JSON.parse(JSON.stringify(this.scoreCardData));
        } else {
            this.tempScoreCardCriterias = JSON.parse(JSON.stringify(this.scoreCardCriterias));
        }
        for (const list of this.tempScoreCardCriterias.templateCriteria) {
            if (
                (list.templateCriteriaId && this.scoreTitle === list.templateCriteriaId) ||
                (list.id && this.scoreTitle === list.id)
            ) {
                if (list.scoreValue !== "No") {
                    this.potentialScore = this.potentialScore - list.pointValue;
                }
                if (list.currentScore !== 0) {
                    this.totalScore = this.totalScore - list.pointValue;

                    if (list.isOpptySection) {
                        this.opptyScore = this.opptyScore - list.pointValue;
                    } else {
                        this.businessScore = this.businessScore - list.pointValue;
                    }
                    list.currentScore = 0;
                } else {
                    this.totalScore = this.totalScore + 0;
                    if (list.isOpptySection) {
                        this.opptyScore = this.opptyScore + 0;
                    } else {
                        this.businessScore = this.businessScore + 0;
                    }
                    list.currentScore = 0;
                }

                list.scoreValue = "No";
            }
        }
        for (const el of this.template.querySelectorAll(".scoreButtons")) {
            if (this.scoreTitle === el.value) {
                el.classList.remove("btnClickedUnknown");
                el.classList.remove("btnClickedYes");
            }
        }
        const evt = event.currentTarget;
        evt.classList.toggle("btnClickedNo");
        this.scoreCardCriterias = this.tempScoreCardCriterias;
        this.scoreCardData = this.tempScoreCardCriterias;
    }
    handleSave() {
        this.disableSave = true;
        saveScoreCardData({
            inputString: JSON.stringify(this.tempScoreCardCriterias),
            oppId: this.optyId,
            potentialScore: this.potentialScore
        }).then(() => {
            this.getScorecardDetails();
            //this.showCreateView=false;
            this.showDefault = false;
            //this.showEditView = false;
            this.showCreateEditView = false;
            this.disableSave = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: successheader,
                    message: successmsg,
                    variant: successheader
                })
            );
            this.dispatchEventToParent();
            pubsub.fire("refreshBestActionGrid", "");
            this.showModuleDependentData();
        });
    }
    handleEdit() {
        this.getScorecardDetails();
        this.showCreateView = false;
        this.showEditView = true;
        this.showButtons = true;
        this.showDefault = false;
        this.showCreateEditView = true;
        this.showEditClicked = true;
    }

    dispatchEventToParent() {
        const selectedEvent = new CustomEvent("updateprogressfromchild", {
            detail: true
        });
        this.dispatchEvent(selectedEvent);
    }

    handleCancel() {
        this.showCreateEditView = false;
        this.renderData = false;
        if (this.showCreateView) {
            this.showDefault = true;
            this.scoreCardData = null;
            this.showButtons = true;
        } else {
            this.showDefault = false;
            this.scoreCardData = null;
            this.disableEdit = false;
            this.showEditClicked = false;
            this.showButtons = false;
            this.getScorecardDetails();
        }
        this.scoreCardCriterias = null;
        this.handleGetScoreCardCriteria();
    }

    exportScorecardPdf() {
        let pdfUrl = "/apex/" + this.namespaceVar + "?id=" + this.getIdFromParent + "&download=true";

        let downloadElement = document.createElement("a");
        // This  encodeURI encodes special characters, except: , / ? : @ & = + $ # (Use encodeURIComponent() to encode these characters).
        downloadElement.href = pdfUrl;
        downloadElement.target = "_self";
        // CSV File Name
        downloadElement.download = "scorecard.csv";
        // below statement is required if you are using firefox browser
        document.body.appendChild(downloadElement);
        // click() Javascript function to download CSV file
        downloadElement.click();
    }
}