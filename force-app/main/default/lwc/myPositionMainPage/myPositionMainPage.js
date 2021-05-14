import { LightningElement, api, track, wire } from "lwc";
import Summary_of_My_Position from "@salesforce/label/c.Summary_of_My_Position";
import sumPositionHeaderURL from "@salesforce/label/c.sumPositionHeaderURL";
import getSummaryOfMPData from "@salesforce/apex/GuidedLearningModuleProgress.getSummaryOfMPData";
import { registerListener } from "c/eventForBlueSheetProgress";
import { CurrentPageReference } from "lightning/navigation";
export default class MyPositionMainPage extends LightningElement {
    @api getIdFromParent;
    @track checkNoDataAndReadOnlyAccess = false;
    //code to show hide the daata on self guided journey tootip
    @track moduleLearningCompleted = false;
    @track _moduleData;
    @track moduleSection;
    @wire(CurrentPageReference) pageRef;

    @api get moduleData() {
        return this._moduleData;
    }
    set moduleData(value) {
        // this.setAttribute('moduleData', value);
        this._moduleData = value;
        this.ProcessModuleData();
    }

    ProcessModuleData() {
        if (this._moduleData) {
            if (this._moduleData.moduleNameId === "Lesson_3_Module_1") {
                this.moduleSection = "SummaryOfMyPosition";
            } else if (this._moduleData.moduleNameId === "Lesson_7_Module_4") {
                this.moduleSection = "StrengthRedFlag";
            }
            this.ShowModuleDependentData();
            if (this.moduleData && this.moduleData.moduleBluesheetProgress === "Completed") {
                this.moduleLearningCompleted = true;
            }
        }
    }

    ShowModuleDependentData() {
        if (this.moduleLearningCompleted !== true) {
            if (this.moduleData && this.moduleData.moduleBluesheetProgress === "Completed") {
                this.moduleLearningCompleted = true;
            } else {
                if (this.moduleData !== undefined) {
                    getSummaryOfMPData().then(backendResult => {
                        let result = backendResult;
                        if (this.moduleData.moduleNameId === "Lesson_3_Module_1") {
                            let countStrength = 0;
                            let countRedFlag = 0;

                            result.forEach(element => {
                                if (element.strenghtFlag) {
                                    countStrength++;
                                }
                                if (element.redFlag) {
                                    countRedFlag++;
                                }
                            });
                            if (countStrength > 0 && countRedFlag > 2) {
                                this.moduleLearningCompleted = true;
                            } else {
                                this.moduleLearningCompleted = false;
                            }
                        } else if (this.moduleData.moduleNameId === "Lesson_7_Module_4") {
                            let strengthCount = 0;
                            let redFlagCount = 0;

                            result.forEach(element => {
                                if (element.strenghtFlag) {
                                    strengthCount++;
                                }
                                if (element.redFlag) {
                                    redFlagCount++;
                                }
                            });
                            if (strengthCount > 0 && redFlagCount > 0) {
                                this.moduleLearningCompleted = true;
                            } else {
                                this.moduleLearningCompleted = false;
                            }
                        }
                    });
                }
            }
        } else {
            this.moduleLearningCompleted = true;
        }
        if (this.template.querySelector("c-go-to-bluesheet-prompts")) {
            this.template.querySelector("c-go-to-bluesheet-prompts").reloadPrompt();
        }
    }
    //end of tooltip code
    allLabel = {
        Summary_of_My_Position,
        sumPositionHeaderURL
    };

    handleProgress() {
        const selectedEvent = new CustomEvent("updateprogressfromchild", {
            detail: true
        });
        this.dispatchEvent(selectedEvent);
    }

    handleFetchData() {
        this.checkNoDataAndReadOnlyAccess = true;
    }
    connectedCallback() {
        registerListener("ModuleDataSOMP", this.reloadModuleData, this);
    }
    reloadModuleData(moduleData) {
        this._moduleData = moduleData;
        this.ProcessModuleData();
    }
}