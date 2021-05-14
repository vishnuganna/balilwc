import { LightningElement, api, track } from "lwc";
import selfGuidedJourneyViewed from "@salesforce/resourceUrl/selfGuidedJourneyViewed";
import selfGuidedJourneyBegin from "@salesforce/resourceUrl/selfGuidedJourneyBeginDisabled";
import selfGuidedJourneyResume from "@salesforce/resourceUrl/selfGuidedJourneyResume";
import selfGuidedJourneyBeginEnabled from "@salesforce/resourceUrl/selfGuidedJourneyBeginEnabled";
import isPrevLessonCompleted from "@salesforce/apex/SelfGuidedLearning.checkIfUserHasCompletedPrevLesson";
import SGJResume from "@salesforce/label/c.SGJResume";
import SGJBegin from "@salesforce/label/c.SGJBegin";
import SGJViewed from "@salesforce/label/c.SGJViewed";
import getLessonRecordData from "@salesforce/apex/SelfGuidedLearning.getLessonRecordData";

export default class LearningComponents extends LightningElement {
    @track lessonStatus;
    @track _lessonObject;
    @track lessonDesc;
    @track yetToStart = false;
    @track lessonTime;
    @track toResume = false;
    @track isCompleted = false;
    @track utilName;
    @track variantName;
    @track lessonStatus;
    @track lessonMap = [];

    @track showPopup;
    // @api lessonObject;
    @track lessonTitle;
    @track prevLessonIncomplete;

    label = {
        SGJBegin,
        SGJResume,
        SGJViewed
    };
    @api
    get lessonObject() {
        return this._lessonObject;
    }

    set lessonObject(value) {
        this.setAttribute("lessonObject", value);
        this._lessonObject = value;
        this.lessonDesc = this.lessonObject.lessonShortDesc;
        this.lessonStatus = this.lessonObject.lessonStatus;
        this.lessonTime = this.lessonObject.lessonTime;
        this.lessonTitle = this.lessonObject.lessonTitle;
        this.showPopup = this.lessonObject.showPopup;
        isPrevLessonCompleted({
            currentLessonNameId: this.lessonObject.lessonNameId,
            sgjId: this.lessonObject.sgjId
        }).then(res => {
            this.prevLessonIncomplete = res;
            if (!this.prevLessonIncomplete) {
                this.template.querySelector(".disableDiv").classList.add("greyDiv");
                this.template.querySelector(".noanchor").classList.add("disabled");
            } else {
                this.template.querySelector(".disableDiv").classList.remove("greyDiv");
                this.template.querySelector(".noanchor").classList.remove("disabled");
            }
            this.progressRender(this.prevLessonIncomplete);
        });
    }
    connectedCallback() {
        if (this.showPopup === true) {
            this.lessonMap = this.lessonObject;
        }
    }

    progressRender(bool) {
        if (this.lessonStatus === SGJBegin) {
            if (bool) {
                this.utilName = selfGuidedJourneyBeginEnabled;
            } else {
                this.utilName = selfGuidedJourneyBegin;
            }
        } else if (this.lessonStatus === SGJResume) {
            this.utilName = selfGuidedJourneyResume;
        } else if (this.lessonStatus === SGJViewed) {
            this.utilName = selfGuidedJourneyViewed;
        }
    }

    //KFS-3512 changes
    handleLessonClick() {
        getLessonRecordData({ lessonId: this.lessonObject.lessonRecordId }).then(result => {
            if (result) {
                this.lessonObject = result;
                this.lessonObject.showPopup = true;
                this.lessonMap = this.lessonObject;
                this.showPopup = this.lessonObject.showPopup;
            }
        });
    }
    hideIntrodcutionsection(event) {
        this.showPopup = false;
        this.lessonStatus = event.detail.lessonStatus;
        this.progressRender(true);
        if (this.lessonStatus === SGJViewed) {
            const selectedEvent = new CustomEvent("reloadmenu");
            // Dispatches the event.
            this.dispatchEvent(selectedEvent);
        }
    }
    hideLessonAndMat(event) {
        this.showPopup = false;
        const selectedEvent = new CustomEvent("closewelcomemat", {
            detail: event.detail
        });
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
    }
}