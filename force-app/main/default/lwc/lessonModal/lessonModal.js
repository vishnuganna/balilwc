import { LightningElement, track, api } from "lwc";
import markLessonAsComplete from "@salesforce/apex/SelfGuidedLearning.markLessonAsComplete";
import getLessonRecordData from "@salesforce/apex/SelfGuidedLearning.getLessonRecordData";
import moduleBeginLabel from "@salesforce/label/c.SGJBegin";
import completeLesson from "@salesforce/label/c.CompleteLesson";
import backToLesson from "@salesforce/label/c.BackToLesson";

export default class LessonModal extends LightningElement {
    @track isLessonNotComplete = false;
    @track _lessonrecord;
    @track currentLesson;
    @track lessonStatus;
    @track moduleList = [];
    @track currentLessonId;
    @track lessonModules = [];

    @api
    get lessonrecord() {
        return this._lessonrecord;
    }

    set lessonrecord(value) {
        this._lessonrecord = value;
        this.loadData();
    }

    allLabels = {
        completeLesson,
        backToLesson
    };

    loadData() {
        this.moduleList = [];
        this.isLessonNotComplete = false;
        this.currentLessonId = this.lessonrecord.lessonRecordId;
        let modules = this.lessonrecord.lessonModules;
        for (let module in modules) {
            if (modules.hasOwnProperty(module)) {
                this.moduleList.push(modules[module]);
            }
        }
        this.moduleList.forEach(element => {
            if (element.moduleStatus === moduleBeginLabel) {
                this.isLessonNotComplete = true;
            }
        });
    }

    nevigateToComponent() {
        const selectedEvent = new CustomEvent("hidelessons", {
            detail: this.lessonrecord
        });
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
    }

    markLessonasComplete() {
        markLessonAsComplete({ lessonId: this.currentLessonId }).then(result => {
            if (result) {
                this.lessonrecord = result;
                const selectedEvent = new CustomEvent("hidelessons", {
                    detail: this.lessonrecord
                });
                // Dispatches the event.
                this.dispatchEvent(selectedEvent);
            }
        });
    }
    reloadLesson() {
        getLessonRecordData({ lessonId: this.lessonrecord.lessonRecordId }).then(result => {
            if (result) {
                this.lessonrecord = result;
            }
        });
    }
    hideLessonAndWelcomMat(event) {
        const selectedEvent = new CustomEvent("hidelessonandmat", {
            detail: event.detail
        });
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
    }
}