import { LightningElement, track, api, wire } from "lwc";
import returnToTutorialLabel from "@salesforce/label/c.ReturnToTutorial";
import getModulePromptsMessages from "@salesforce/apex/BluesheetPromptsMessages.getModulePromptsMessages";
import updateModules from "@salesforce/apex/ModuleController.updateModules";
import { fireEvent } from "c/eventForBlueSheetProgress";
import { CurrentPageReference } from "lightning/navigation";
import moduleIdNameMap from "@salesforce/apex/ModuleController.moduleIdNameMap";
import moduleStatusMap from "@salesforce/apex/ModuleController.moduleStatusMap";

export default class GoToBluesheetPrompts extends LightningElement {
    @track moduleBluesheetProgress;
    @track _moduleData;
    @track _moduleLearningCompleted;
    @track _moduleSection;
    @track promptMessages;
    @track showPrompts;
    @track showWelcomeMat;
    @track moduleVideoProgress;
    @track lessonRecordId;
    @wire(CurrentPageReference) pageRef;
    @track moduleIdNameMap;
    @track nextModuleToEnable;
    @track moduleStatusMap;
    @api reloadPrompt() {
        this.showPrompts = true;
    }

    @api get moduleData() {
        return this._moduleData;
    }
    set moduleData(value) {
        this._moduleData = value;
        this.showPrompts = true;
        this.getModuleStatus();
    }
    @api get moduleLearningCompleted() {
        return this._moduleLearningCompleted;
    }
    set moduleLearningCompleted(value) {
        this._moduleLearningCompleted = value;
        if (this.moduleLearningCompleted === true) {
            this.updateBlueSheetProgressToDone(this.moduleData);
        }
        this.getModuleIdName();
    }

    @api get moduleSection() {
        return this._moduleSection;
    }
    set moduleSection(value) {
        this._moduleSection = value;
        if (this._moduleSection === "SingleSalesObjective") {
            this.moduleLearningCompleted = true;
        }
        this.showPrompts = true;
        getModulePromptsMessages({ moduleSection: this._moduleSection })
            .then(result => {
                this.promptMessages = result;
            })
            .catch(() => {});
    }

    allLabels = {
        returnToTutorialLabel
    };

    closePrompt() {
        this.showPrompts = false;
    }

    updateBlueSheetProgressToDone(moduleRecord) {
        this.moduleBluesheetProgress = "Completed";
        let inputString = {
            moduleRecordId: moduleRecord.moduleRecordId,
            moduleBluesheetProgress: this.moduleBluesheetProgress,
            availBlueSheetButton: moduleRecord.availBlueSheetButton
        };
        updateModules({ inputData: JSON.stringify(inputString), lessonRecId: moduleRecord.lessonRecId });
    }

    returnToTutorial() {
        this.showPrompts = false;
        this.moduleVideoProgress = "Viewed";
        let inputString = {
            moduleRecordId: this.moduleData.moduleRecordId,
            moduleStatus: this.moduleVideoProgress,
            moduleBluesheetProgress: this.moduleBluesheetProgress
        };
        updateModules({ inputData: JSON.stringify(inputString), lessonRecId: this.moduleData.lessonRecId });

        // Lesson 7 specific logic start
        if (
            this.moduleData.moduleNameId === "Lesson_7_Module_2" ||
            this.moduleData.moduleNameId === "Lesson_7_Module_3"
        ) {
            let moduleName = this.moduleData.moduleNameId;
            let currentModuleNumberString = moduleName.charAt(moduleName.length - 1);
            let currentModuleNumber = Number(currentModuleNumberString);
            let nextModuleNumber = currentModuleNumber + 1;
            let nextModuleName = moduleName.replace(/.$/, nextModuleNumber);

            this.nextModuleToEnable = this.moduleIdNameMap[nextModuleName];
            if (this.moduleStatusMap[nextModuleName] !== "Viewed") {
                let beginStatus = "Begin";
                let inProgressStatus = "In Progress";
                let enableNext = {
                    moduleStatus: beginStatus,
                    moduleRecordId: this.nextModuleToEnable,
                    moduleBluesheetProgress: inProgressStatus
                };
                updateModules({ inputData: JSON.stringify(enableNext), lessonRecId: this.moduleData.lessonRecId });
            }
        }

        if (this.moduleData.moduleNameId === "Lesson_7_Module_4") {
            let firstModuleName = "Lesson_7_Module_1";
            let firstModuleRecId = this.moduleIdNameMap[firstModuleName];
            let completeFirstModule = {
                moduleStatus: this.moduleVideoProgress,
                moduleRecordId: firstModuleRecId,
                moduleBluesheetProgress: this.moduleBluesheetProgress
            };
            updateModules({ inputData: JSON.stringify(completeFirstModule), lessonRecId: this.moduleData.lessonRecId });
        }
        // Lesson 7 specific logic end

        //New code to fire event to reopen the modal for welcome mat and lesson
        this.lessonRecordId = this.moduleData.lessonRecId;
        fireEvent(this.pageRef, "backToModule", this.lessonRecordId);
    }

    getModuleIdName() {
        moduleIdNameMap({ lessonId: this.moduleData.lessonRecId }).then(result => {
            if (result) {
                this.moduleIdNameMap = result;
            }
        });
    }
    getModuleStatus() {
        moduleStatusMap({ lessonId: this.moduleData.lessonRecId }).then(result => {
            if (result) {
                this.moduleStatusMap = result;
            }
        });
    }
}