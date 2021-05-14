import { LightningElement, api, track, wire } from "lwc";
import CP from "@salesforce/resourceUrl/Currentposition";
import getCurrentPostionData from "@salesforce/apex/CurrentPosition.getCurrentPostion";
import saveurrentPostionData from "@salesforce/apex/CurrentPosition.saveCurrentPosition";
import cpScaleLabel from "@salesforce/label/c.cpScale";
import euphoriaLabel from "@salesforce/label/c.euphoria";
import greatLabel from "@salesforce/label/c.great";
import secureLabel from "@salesforce/label/c.secure";
import comfortLabel from "@salesforce/label/c.comfort";
import okLabel from "@salesforce/label/c.ok";
import discomfortLabel from "@salesforce/label/c.discomfort";
import worryLabel from "@salesforce/label/c.worry";
import fearLabel from "@salesforce/label/c.fear";
import panicLabel from "@salesforce/label/c.panic";
import concernedLabel from "@salesforce/label/c.concerned";
import currentPositionHeaderURL from "@salesforce/label/c.currentPositionHeaderURL";
import currentPositionHeaderLabel from "@salesforce/label/c.currentPositionHeader";
import checkAccess from "@salesforce/apex/CurrentPosition.getCurrentPositionAccess";
import getOppId from "@salesforce/apex/StrategyEngine.getOppId";
import pubsub from "c/pubSub";
import { registerListener } from "c/eventForBlueSheetProgress";
import { CurrentPageReference } from "lightning/navigation";

export default class CurrentPositionProgress extends LightningElement {
    @track progressLst = [];
    @track prevSltdIndex;
    @track label;
    @api imageLink = CP;
    @api recordId;
    @api objectApiName;

    @wire(CurrentPageReference) pageRef;
    @wire(getCurrentPostionData, { oppId: "$getIdFromParent" })
    cposition;
    @api
    get getIdFromParent() {
        return this._getIdFromParent;
    }

    set getIdFromParent(value) {
        this._getIdFromParent = value;
        this.getCurrentPostion();
    }

    @track _getIdFromParent;
    @track currentPosition = "";
    @track isLoading = false;
    @api item;
    @track isPlaceholderDisabled = true;
    @track blueSheetId;
    @track result;

    @track isUpdateable = false;
    @track readOnly = false;
    @track checkReadOnlyAndNoDataAccess = false;
    @track optyId = "";
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
            if (this._moduleData.moduleNameId === "Lesson_3_Module_4") {
                this.moduleSection = "CurrentPosition";
                this.ShowModuleDependentData();
            }
        }
    }
    ShowModuleDependentData() {
        if (this.moduleLearningCompleted !== true && this._moduleData.moduleNameId === "Lesson_3_Module_4") {
            if (this.moduleData && this.moduleData.moduleBluesheetProgress === "Completed") {
                this.moduleLearningCompleted = true;
            } else {
                getCurrentPostionData({ oppId: this.optyId })
                    .then(result => {
                        this.result = result;
                        if (this.result) {
                            this.moduleLearningCompleted = true;
                        } else {
                            this.moduleLearningCompleted = false;
                        }
                    })
                    .catch(() => {
                        this.Result = undefined;
                        //this.error=error    ;
                    });
            }
        } else {
            this.moduleLearningCompleted = true;
        }
        if (this.template.querySelector("c-go-to-bluesheet-prompts")) {
            this.template.querySelector("c-go-to-bluesheet-prompts").reloadPrompt();
        }
    }
    //end
    label = {
        euphoriaLabel,
        greatLabel,
        secureLabel,
        comfortLabel,
        okLabel,
        discomfortLabel,
        worryLabel,
        fearLabel,
        panicLabel,
        concernedLabel
    };

    labels = {
        cpScaleLabel,
        currentPositionHeaderLabel,
        currentPositionHeaderURL
    };

    getCurrentPostion() {
        this.recordId = this.getIdFromParent;
        let progressLst = [];
        let progressBarName = [
            euphoriaLabel,
            greatLabel,
            secureLabel,
            comfortLabel,
            okLabel,
            concernedLabel,
            discomfortLabel,
            worryLabel,
            fearLabel,
            panicLabel
        ];

        progressBarName.forEach(function(element) {
            let progressElement = {};
            progressElement.label = element;
            progressElement.title = element;
            progressElement.cssClass = "slds-progress__item ";
            progressElement.currentPosition = element;
            progressLst.push(progressElement);
        });

        checkAccess().then(result => {
            if (result.isUpdateable) {
                this.isUpdateable = true;
                this.readOnly = false;
            } else {
                this.isUpdateable = false;
                this.readOnly = true;
            }
        });

        getOppId({ blueSheetId: this.getIdFromParent }).then(data => {
            this.optyId = data;
            getCurrentPostionData({ oppId: this.optyId })
                .then(result => {
                    this.result = result;
                    if (this.result === "" || this.result === null) {
                        this.isPlaceholderDisabled = true;
                        this.checkReadOnlyAndNoDataAccess = this.isPlaceholderDisabled && this.readOnly;
                    } else {
                        this.isPlaceholderDisabled = false;
                        let index;
                        let label = this.result;
                        index = progressBarName.indexOf(label);
                        progressLst[index].cssClass = progressLst[index].cssClass + " slds-is-active";
                        this.label = label;
                        this.prevSltdIndex = index;
                    }
                })
                .catch(() => {
                    this.Result = undefined;
                    //this.error=error    ;
                });
        });
        this.progressLst = progressLst;
    }

    buttonClick(event) {
        let index = event.currentTarget.id.split("-")[0];
        let progressLst = this.progressLst;
        if (this.prevSltdIndex !== null && this.prevSltdIndex !== undefined && String(this.prevSltdIndex) !== "") {
            progressLst[this.prevSltdIndex].cssClass = "slds-progress__item ";
        }
        if (index === this.prevSltdIndex) {
            progressLst[this.prevSltdIndex].cssClass = "slds-progress__item ";
            this.label = "";
            this.prevSltdIndex = "";
        } else {
            progressLst[index].cssClass = progressLst[index].cssClass + " slds-is-active";
            this.prevSltdIndex = index;
            this.label = progressLst[index].label;
        }
        this.isPlaceholderDisabled = false;
        let cpWrapper = {};
        cpWrapper.blueSheet = this.blueSheetId;
        cpWrapper.position = this.label;
        cpWrapper.id = "";
        this.cpWrapper = cpWrapper;
        // saveurrentPostionData({currentState:this.label,oppId:this.getIdFromParent })
        saveurrentPostionData({ jsonString: JSON.stringify(this.cpWrapper), oppId: this.optyId })
            .then(() => {
                this.ShowModuleDependentData();
                this.dispatchEventToParent();
                pubsub.fire("refreshBestActionGrid", "");
            })
            .catch(() => {
                this.Result = undefined;
            });
    }

    dispatchEventToParent() {
        const selectedEvent = new CustomEvent("updateprogressfromchild", {
            detail: true
        });
        this.dispatchEvent(selectedEvent);
    }
    connectedCallback() {
        registerListener("ModuleDataCP", this.reloadModuleData, this);
    }
    reloadModuleData(moduleData) {
        this._moduleData = moduleData;
        this.ProcessModuleData();
    }
}