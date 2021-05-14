import { LightningElement, track, api, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getHideWelcomeMat from "@salesforce/apex/WelcomeMatController.getHideWelcomeMat";
import updateWelcomeMatSetting from "@salesforce/apex/WelcomeMatController.updateWelcomeMatSetting";
import welcome_mat_bg from "@salesforce/resourceUrl/welcome_mat_bg";
import getKFLearnUrl from "@salesforce/apex/ExternalLinks.getKFLearnUrl";
import kf_sell_logo from "@salesforce/resourceUrl/kf_sell_logo";
import selfGuidedJourneyKFLogo from "@salesforce/resourceUrl/selfGuidedJourneyKFLogo";
import kf_learn_logo from "@salesforce/resourceUrl/kf_learn_logo";
import icon_question_mark from "@salesforce/resourceUrl/icon_question_mark";
import wmLinkOne from "@salesforce/label/c.WMLinkOne";
import wmLinkTwo from "@salesforce/label/c.WMLinkTwo";
import wmLinkThree from "@salesforce/label/c.WMLinkThree";
import ErrorSavingUserPref from "@salesforce/label/c.ErrorSavingUserPref";
import WelcomeMatUserConfig from "@salesforce/label/c.WelcomeMatUserConfig";
import KFLearnError from "@salesforce/label/c.KFLearnError";
import KFLearnConfiguration from "@salesforce/label/c.KFLearnConfiguration";
import WelcomeKF from "@salesforce/label/c.WelcomeKF";
import SGJWelcomeKF from "@salesforce/label/c.SGJWelcomeKF";
import KFSellingTime from "@salesforce/label/c.KFSellingTime";
import KFSellAcquainted from "@salesforce/label/c.KFSellAcquainted";
import OpportunityLayout from "@salesforce/label/c.OpportunityLayout";
import StrategicPlan from "@salesforce/label/c.StrategicPlan";
import KFSellDashboards from "@salesforce/label/c.KFSellDashboards";
import KFSellStrategicSelling from "@salesforce/label/c.KFSellStrategicSelling";
import ClickToOpenKFLearn from "@salesforce/label/c.ClickToOpenKFLearn";
import KFDigitalLearning from "@salesforce/label/c.KFDigitalLearning";
import QuestionsOrConcerns from "@salesforce/label/c.QuestionsOrConcerns";
import SGJLandingContentL1 from "@salesforce/label/c.SGJLandingContentL1";
import SGJLandingContentL2 from "@salesforce/label/c.SGJLandingContentL2";
import SGJLandingHeader from "@salesforce/label/c.SGJLandingHeader";
import DoNotShowIfCompleted from "@salesforce/label/c.DoNotShowIfCompleted";
import Continue from "@salesforce/label/c.Continue";
import DoNotshow from "@salesforce/label/c.DoNotshow";
import selfGuidedJourneyRec from "@salesforce/apex/SelfGuidedLearning.createOrGetSelfGuidedJourneyDetails";
import getObjectAccess from "@salesforce/apex/ApexCommonUtil.getObjectAccess";
import closeLabel from "@salesforce/label/c.close";
import { registerListener } from "c/eventForBlueSheetProgress";
import { CurrentPageReference } from "lightning/navigation";
import checkIfSelfGuidedLearningDisabled from "@salesforce/apex/SelfGuidedLearning.checkIfSelfGuidedLearningDisabled";
//import getLessonRecordData from "@salesforce/apex/SelfGuidedLearning.getLessonRecordData";
import pubsub from "c/pubSub";

export default class WelcomeMat extends LightningElement {
    @api welcome_mat_bg = welcome_mat_bg;
    @api kf_sell_logo = kf_sell_logo;
    @api selfGuidedJourneyKFLogo = selfGuidedJourneyKFLogo;
    @api kf_learn_logo = kf_learn_logo;
    @api icon_question_mark = icon_question_mark;
    @track showWelcomeMat;
    @track showWelcomeMatChecked;
    @track openguide;
    @track sgj;
    //
    @track lessonStatus;
    @track _lessonRec;
    @track hasEditAccess;
    @track moduleRecordFiringEvent;
    @track _lessonId;
    @track _openRelatedLesson;
    //code to show welcome mat popup
    @track lessonRecordId;
    @track reloadedLessonData;
    @wire(CurrentPageReference) pageRef;

    @api get lessonRec() {
        return this._lessonRec;
    }
    set lessonRec(value) {
        this._lessonRec = value;
    }

    @api
    get openRelatedLesson() {
        return this._openRelatedLesson;
    }

    set openRelatedLesson(value) {
        this._openRelatedLesson = value;
    }

    label = {
        wmLinkOne,
        wmLinkTwo,
        wmLinkThree,
        WelcomeKF,
        SGJWelcomeKF,
        KFSellingTime,
        ErrorSavingUserPref, //KFS-2766
        WelcomeMatUserConfig, //KFS-2766
        KFLearnError, //KFS-2766
        KFLearnConfiguration, //KFS-2766
        QuestionsOrConcerns,
        KFDigitalLearning,
        ClickToOpenKFLearn,
        KFSellStrategicSelling,
        KFSellDashboards,
        StrategicPlan,
        OpportunityLayout,
        DoNotshow,
        Continue,
        KFSellAcquainted,
        DoNotShowIfCompleted,
        SGJLandingHeader,
        SGJLandingContentL1,
        SGJLandingContentL2,
        closeLabel
    };

    @api
    get sgj() {
        return this.sgj;
    }

    /**
     * @param {any} value
     */
    set sgj(value) {
        this.sgj = value;
    }

    // init data
    connectedCallback() {
        this.checkIfSelfGuidedLearningData();
        this.register();
    }

    checkIfSelfGuidedLearningData() {
        checkIfSelfGuidedLearningDisabled().then(resp => {
            if (!resp) {
                getObjectAccess({ objApiName: "Blue_Sheet__c" }).then(result => {
                    this.hasEditAccess = result.isUpdateable;
                    if (this.hasEditAccess === true) {
                        this.loadData();
                    }
                    getHideWelcomeMat().then(res => {
                        this.showWelcomeMat = !res;
                    });
                });
                registerListener("backToModule", this.reloadWelcomeMat, this);
            } else {
                this.hasEditAccess = false;
                getHideWelcomeMat().then(res => {
                    this.showWelcomeMat = !res;
                });
            }
        });
    }
    register() {
        pubsub.register("returnToLearning", this.handleEvent.bind(this));
    }

    handleEvent(messageFromEvt) {
        if (messageFromEvt) {
            this.showWelcomeMatChecked = false;
            this.updateWelcomeMat()
                .then(() => {
                    this.checkIfSelfGuidedLearningData();
                })
                .catch(() => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: this.label.ErrorSavingUserPref, //KFS-2766
                            message: this.label.WelcomeMatUserConfig, //KFS-2766
                            variant: "error"
                        })
                    );
                });
        }
    }

    async refreshScreen() {
        return true;
    }

    loadData() {
        selfGuidedJourneyRec()
            .then(result => {
                if (!this.reloadedLessonData) {
                    this.sgj = result.lessons;
                } else {
                    this.sgj = this.reloadedLessonData;
                }
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.label.kfIntroductionTitle, //KFS-2766
                        message: error.body.message,
                        variant: "error"
                    })
                );
            });
    }

    reloadMat() {
        this.reloadedLessonData = "";
        this.loadData();
    }

    closeWelcomeMat() {
        this.showWelcomeMat = false;
        // default value
        if (undefined === this.showWelcomeMatChecked || null === this.showWelcomeMatChecked) {
            this.showWelcomeMatChecked = false;
        }
        this.updateWelcomeMat().catch(() => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: this.label.ErrorSavingUserPref, //KFS-2766
                    message: this.label.WelcomeMatUserConfig, //KFS-2766
                    variant: "error"
                })
            );
        });
    }

    handleCheckBoxEvent(event) {
        this.showWelcomeMatChecked = event.target.checked;
    }

    updateWelcomeMat() {
        // noinspection JSUnusedLocalSymbols
        return updateWelcomeMatSetting({ hideWelcomeMat: this.showWelcomeMatChecked });
    }

    handleMouseOver() {
        // change box color
        const div = this.template.querySelector('[data-id="continue_btn_id"]');
        if (div) {
            this.template.querySelector('[data-id="continue_btn_id"]').className = "continue_btn_sub_over";
        }
        // change text color
        const txt = this.template.querySelector('[data-id="continue_btn_txt"]');
        if (txt) {
            this.template.querySelector('[data-id="continue_btn_txt"]').className = "continue_btn_text";
        }
    }

    handleMouseOut() {
        // change box color
        const div = this.template.querySelector('[data-id="continue_btn_id"]');
        if (div) {
            this.template.querySelector('[data-id="continue_btn_id"]').className = "continue_btn_sub";
        }
        // change text color
        const txt = this.template.querySelector('[data-id="continue_btn_txt"]');
        if (txt) {
            this.template.querySelector('[data-id="continue_btn_txt"]').className = "continue_btn_text";
        }
    }

    handleMouseDown() {
        // change box color
        const div = this.template.querySelector('[data-id="continue_btn_id"]');
        if (div) {
            this.template.querySelector('[data-id="continue_btn_id"]').className = "continue_btn_sub_down";
        }
        // change text color
        const txt = this.template.querySelector('[data-id="continue_btn_txt"]');
        if (txt) {
            this.template.querySelector('[data-id="continue_btn_txt"]').className = "continue_btn_text_down";
        }
    }
    renderedCallback() {
        this.scrollcontainer = this.template.querySelector(".abc");

        // eslint-disable-next-line
        setTimeout(() => {
            this.handlescroll(this.scrollcontainer);
        }, 0);
        // eslint-enable-next-line
    }

    handlescroll(a) {
        if (a) {
            a.classList.add("scroll");
            a.style.maxHeight = a.clientHeight + "px";
        }
    }

    openKFLearn() {
        getKFLearnUrl().then(result => {
            const url = result.toString();
            if (url === "none") {
                // show kf learn error
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.label.KFLearnError, //KFS-2766
                        message: this.label.KFLearnConfiguration, //KFS-2766
                        variant: "error",
                        mode: "sticky"
                    })
                );
            } else {
                // open kf learn in new window
                window.open(url);
            }
        });
    }

    handleTutorialLink(event) {
        let linkType = event.target.getAttribute("data-link-type");
        switch (linkType) {
            case "wm-link-1":
                window.open(this.label.wmLinkOne);
                break;
            case "wm-link-2":
                window.open(this.label.wmLinkTwo);
                break;
            case "wm-link-3":
                window.open(this.label.wmLinkThree);
                break;
            default:
                break;
        }
    }

    closeModal(event) {
        this.closeWelcomeMat();
        if (event.detail) {
            this.moduleRecordFiringEvent = event.detail;
            const selectedEvent = new CustomEvent("closemat", {
                detail: this.moduleRecordFiringEvent
            });
            this.dispatchEvent(selectedEvent);
        }
    }

    reloadWelcomeMat(lessonId) {
        this.showWelcomeMat = true;
        this.lessonRecordId = lessonId;
        this.sgj = [];
        selfGuidedJourneyRec()
            .then(result => {
                let lessondata = result.lessons;
                for (let i = 0; i < lessondata.length; i++) {
                    if (lessondata[i].lessonRecordId === lessonId) {
                        lessondata[i].showPopup = true;
                    }
                }
                this.sgj = lessondata;
                this.reloadedLessonData = lessondata;
                this.connectedCallback();
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.label.kfIntroductionTitle,
                        message: error.body.message,
                        variant: "error"
                    })
                );
            });
    }
}