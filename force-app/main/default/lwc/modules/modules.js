import { LightningElement, api, track } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import updateModules from "@salesforce/apex/ModuleController.updateModules";
import moduleViewed from "@salesforce/resourceUrl/selfGuidedJourneyViewed";
import moduleBegin from "@salesforce/resourceUrl/selfGuidedJourneyBegin";
import moduleResume from "@salesforce/resourceUrl/selfGuidedJourneyResume";
import moduleDisabled from "@salesforce/resourceUrl/selfGuidedJourneyBeginDisabled";
import moduleBeginLabel from "@salesforce/label/c.SGJBegin";
import moduleViewedLabel from "@salesforce/label/c.SGJViewed";
import moduleResumeLabel from "@salesforce/label/c.SGJResume";
import moduleStatusMap from "@salesforce/apex/ModuleController.moduleStatusMap";
import moduleIdNameMap from "@salesforce/apex/ModuleController.moduleIdNameMap";

export default class Modules extends NavigationMixin(LightningElement) {
    //@api moduleRecord;
    @track _moduleRecord;
    @track showVideo = false;
    @track moduleViewed = false;
    //@track currentModule = [];
    @track moduleVideoProgress;
    @track moduleCompleted = false;
    @track moduleRecordId;
    @track utilName;
    @track _lessonId;
    @track moduleStatusMap;
    @track moduleDisabled = moduleDisabled;
    @track disableBluesheetButton = true;
    @track moduleIdNameMap;
    @track noHyperlink = false;

    @api get lessonId() {
        return this._lessonId;
    }
    set lessonId(value) {
        this._lessonId = value;
    }
    @api
    get moduleRecord() {
        return this._moduleRecord;
    }
    set moduleRecord(value) {
        this._moduleRecord = value;
        this.moduleVideoProgress = this.moduleRecord.moduleStatus;
        this.checkifModuleCompleted(this.moduleVideoProgress);
        this.moduleRecordId = this.moduleRecord.moduleRecordId;
        let currentModuleName = this.moduleRecord.moduleNameId;
        if (
            currentModuleName === "Lesson_7_Module_2" ||
            currentModuleName === "Lesson_7_Module_3" ||
            currentModuleName === "Lesson_7_Module_4"
        ) {
            this.noHyperlink = true;
        }
        this.moduleBluesheetProgress = this.moduleRecord.moduleBluesheetProgress;
        if (this.moduleRecord.moduleBluesheetProgress) {
            this.disableBluesheetButton = false;
        }
        this.getModuleStatus(currentModuleName);
        this.getModuleIdName();
    }
    checkifModuleCompleted(moduleProgress) {
        if (moduleProgress === moduleBeginLabel) {
            this.utilName = moduleBegin;
        } else if (moduleProgress === moduleViewedLabel) {
            this.utilName = moduleViewed;
        } else if (moduleProgress === moduleResumeLabel) {
            this.utilName = moduleResume;
        }
    }
    showBluesheetButton() {
        if (!this.moduleRecord.moduleBluesheetProgress) {
            this.moduleBluesheetProgress = "In Progress";
            this.moduleVideoProgress = "Begin";
        }
        if (this.moduleRecord.moduleNameId === "Lesson_7_Module_1") {
            this.enableNextModule(this.moduleRecord.moduleNameId);

            let resumeStatus = "Resume";
            let inputString = {
                moduleStatus: resumeStatus,
                moduleRecordId: this.moduleRecordId
            };
            updateModules({ inputData: JSON.stringify(inputString), lessonRecId: this.lessonId }).then(result => {
                if (result) {
                    const selectedEvent = new CustomEvent("reloadlessons", {
                        detail: this.lessonId
                    });
                    this.dispatchEvent(selectedEvent);
                }
            });
        } else {
            if (this.moduleRecord.moduleBluesheetProgress === "Completed" || !this.moduleRecord.availBlueSheetButton) {
                this.moduleVideoProgress = "Viewed";
            }
            let inputString = {
                moduleStatus: this.moduleVideoProgress,
                moduleRecordId: this.moduleRecordId,
                moduleBluesheetProgress: this.moduleBluesheetProgress,
                availBlueSheetButton: this.moduleRecord.availBlueSheetButton
            };
            updateModules({ inputData: JSON.stringify(inputString), lessonRecId: this.lessonId }).then(result => {
                if (result) {
                    const selectedEvent = new CustomEvent("reloadlessons", {
                        detail: this.lessonId
                    });
                    this.dispatchEvent(selectedEvent);
                }
            });
        }
        if (this.moduleRecord.moduleBluesheetProgress) {
            this.disableBluesheetButton = false;
        }
    }

    enableNextModule(moduleName) {
        let modules = this.moduleStatusMap;
        for (let key in modules) {
            if (modules.hasOwnProperty(key)) {
                if (moduleName === "Lesson_7_Module_1" && key === "Lesson_7_Module_1") {
                    let currentModuleNumberString = moduleName.charAt(moduleName.length - 1);
                    let currentModuleNumber = Number(currentModuleNumberString);
                    let nextModuleNumber = currentModuleNumber + 1;
                    let nextModuleName = moduleName.replace(/.$/, nextModuleNumber);

                    this.nextModuleToEnable = this.moduleIdNameMap[nextModuleName];

                    if (modules[nextModuleName] !== "Viewed") {
                        let inputString = {
                            moduleStatus: this.moduleVideoProgress,
                            moduleRecordId: this.nextModuleToEnable,
                            moduleBluesheetProgress: this.moduleBluesheetProgress
                        };
                        updateModules({ inputData: JSON.stringify(inputString), lessonRecId: this.lessonId }).then(
                            result => {
                                if (result) {
                                    const selectedEvent = new CustomEvent("reloadlessons", {
                                        detail: this.lessonId
                                    });
                                    this.dispatchEvent(selectedEvent);
                                }
                            }
                        );
                    }
                }
            }
        }
        if (this.moduleRecord.moduleBluesheetProgress) {
            this.disableBluesheetButton = false;
        }
    }
    getModuleIdName() {
        moduleIdNameMap({ lessonId: this.lessonId }).then(result => {
            if (result) {
                this.moduleIdNameMap = result;
            }
        });
    }
    goToBluesheet() {
        const selectedEvent = new CustomEvent("hidelessonmat", {
            detail: this.moduleRecord
        });
        this.dispatchEvent(selectedEvent);
    }
    getModuleStatus(currentModuleName) {
        moduleStatusMap({ lessonId: this.lessonId }).then(result => {
            if (result) {
                this.moduleStatusMap = result;
                this.checkPreviousModuleStatus(currentModuleName);
            }
        });
    }
    checkPreviousModuleStatus(currentModuleName) {
        if (
            currentModuleName === "Lesson_7_Module_2" &&
            (this.moduleRecord.moduleBluesheetProgress === "In Progress" ||
                this.moduleRecord.moduleBluesheetProgress === "Completed")
        ) {
            this.moduleCompleted = true;
        } else {
            if (currentModuleName.includes("Module_1")) {
                this.moduleCompleted = true;
            } else {
                let currentModuleNumberString = currentModuleName.charAt(currentModuleName.length - 1);
                let currentModuleNumber = Number(currentModuleNumberString);
                let prevModuleNumber = currentModuleNumber - 1;
                let prevModuleName = currentModuleName.replace(/.$/, prevModuleNumber);
                if (this.moduleStatusMap[prevModuleName] === moduleBeginLabel) {
                    this.moduleCompleted = false;
                } else {
                    this.moduleCompleted = true;
                }
            }
        }
    }
}