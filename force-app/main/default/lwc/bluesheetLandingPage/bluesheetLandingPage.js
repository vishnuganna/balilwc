import { LightningElement, api, track, wire } from "lwc";
import singleSalesObjective from "@salesforce/label/c.singleSalesObjective";
import strategicAnalysis from "@salesforce/label/c.strategicAnalysis";
import blueSheetInBraces from "@salesforce/label/c.blueSheetInBraces";
import currentPosition from "@salesforce/label/c.currentPosition";
import strategicSellingScorecard from "@salesforce/label/c.strategicSellingScorecard";
import buyingInfluence from "@salesforce/label/c.buyingInfluence";
import competition from "@salesforce/label/c.competition";
import summaryOfMyPositionToday from "@salesforce/label/c.summaryOfMyPositionToday";
import Show_Insights from "@salesforce/label/c.Show_Insights";
import Hide_Insights from "@salesforce/label/c.Hide_Insights";
//import { getRecord, getFieldValue } from "lightning/uiRecordApi";
//-- 230
//--Summary of My position
//--Summary of My position
import summaryofMyPositionNotStarted from "@salesforce/label/c.summaryofMyPositionNotStarted";
import summaryofMyPositionInProgress from "@salesforce/label/c.summaryofMyPositionInProgress";
import summaryofMyPositionCompleted from "@salesforce/label/c.summaryofMyPositionCompleted";
import summaryofMyPositionNotStartedURL from "@salesforce/label/c.summaryofMyPositionNotStartedURL";
import summaryofMyPositionInProgressURL from "@salesforce/label/c.summaryofMyPositionInProgressURL";
//--Action Plan
import actionPlanNotStarted from "@salesforce/label/c.actionPlanNotStarted";
import actionPlanInProgress from "@salesforce/label/c.actionPlanInProgress";
import actionPlanCompleted from "@salesforce/label/c.actionPlanCompleted";
import actionPlanInProgressURL from "@salesforce/label/c.actionPlanInProgressURL";
import actionPlanNoStartedURL from "@salesforce/label/c.actionPlanNoStartedURL";
import actionPlan from "@salesforce/label/c.actionPlan";
// import createBlueSheet from "@salesforce/apex/strategyEngine.createBlueSheet";
import getOppId from "@salesforce/apex/StrategyEngine.getOppId";
import buyingInfluenceNotStarted from "@salesforce/label/c.buyingInfluenceNotStarted";
import buyingInfluenceNotStartedURL from "@salesforce/label/c.buyingInfluenceNotStartedURL";
import buyingInfluenceInProgressURL from "@salesforce/label/c.buyingInfluenceInProgressURL";
import buyingInfluenceInProgress from "@salesforce/label/c.buyingInfluenceInProgress";
import buyingInfluenceCompleted from "@salesforce/label/c.buyingInfluenceCompleted";
//
import currentpositionNotStarted from "@salesforce/label/c.currentpositionNotStarted";
import currentpositionInProgress from "@salesforce/label/c.currentpositionInProgress";
import currentpositionCompleted from "@salesforce/label/c.currentpositionCompleted";
import currentpositionNotStartedURL from "@salesforce/label/c.currentpositionNotStartedURL";
import singlesalesobjectiveNotStarted from "@salesforce/label/c.singlesalesobjectiveNotStarted";
import singlesalesobjectiveInProgress from "@salesforce/label/c.singlesalesobjectiveInProgress";
import singlesalesobjectiveCompleted from "@salesforce/label/c.singlesalesobjectiveCompleted";
import singlesalesobjectiveNotStartedURL from "@salesforce/label/c.singlesalesobjectiveNotStartedURL";
import singlesalesobjectiveInProgressURL from "@salesforce/label/c.singlesalesobjectiveInProgressURL";

import scorecardNotStarted from "@salesforce/label/c.scorecardNotStarted";
import scorecardInProgress from "@salesforce/label/c.scorecardInProgress";
import scorecardCompleted from "@salesforce/label/c.scorecardCompleted";
import scorecardNotStartedURL from "@salesforce/label/c.scorecardNotStartedURL";
import getBlueSheetActionInprogress from "@salesforce/apex/BlueSheetStatus.getBlueSheetActionInprogress"; //230
import competitionNotStarted from "@salesforce/label/c.competitionNotStarted";

import competitionInProgress from "@salesforce/label/c.competitionInProgress";
import competitionCompleted from "@salesforce/label/c.competitionCompleted";
import competitionInProgressURL from "@salesforce/label/c.competitionInProgressURL";
import competitionNotStartedURL from "@salesforce/label/c.competitionNotStartedURL";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { CurrentPageReference } from "lightning/navigation";
import { fireEvent } from "c/eventForBlueSheetProgress";
import pubsub from "c/pubSub";
import BlueSheetErrorGet from "@salesforce/label/c.BlueSheetErrorGet";
import BlueSheetErrorLoad from "@salesforce/label/c.BlueSheetErrorLoad";
import getNamespaceWithUnderScores from "@salesforce/apex/Util.getNamespaceWithUnderScores";
import categoryCompetitor from "@salesforce/label/c.CategoryCompetitor";
import categoryPerspective from "@salesforce/label/c.CategoryPerspective";
// import { registerListener} from 'c/eventForGuidedJourneyAndBluesheet';

export default class BluesheetLandingPage extends LightningElement {
    @api recordId;
    @api objectApiName;
    //230 starts
    @track opportunityId = "";
    @track expandMenu = true;
    @track showsustomInsights = true;
    @track utilMenu = "utility:chevrondown";
    @api showcustomInsights = false;

    @track summaryofmyPosProgress = "";
    @track scorecardProgress = "";
    @track ssoProgress = "";
    @track currentPosProgress = "";
    @track biProgress = "";
    @track actionPlanProgress = "";
    @track ssoProgress = "";
    @track competitionProgress = "";
    @track showInsightslink = "";
    @track lblbuyingInfluenceProgressStatus = "";
    @track lblcompetitionProgressStatus = "";
    @track lblscorecardProgressStatus = "";
    @track lblcurrentpositionProgressStatus = "";
    @track lblsinglesalesobjProgressStatus = "";
    @track lblactionplanProgressStatus = "";
    @track lblsummaryofMyPosProgressStatus = "";
    @wire(CurrentPageReference) pageRef;
    @api propertyValue;
    @track moduleDetail;
    @track summaryOfMPGuidedJourney;
    @track ssoGuidedJourney;
    @track cpGuidedJourney;
    @track biGuidedJourney;
    @track scrcardGuidedJourney;
    @track competitionGuidedJourney;
    @track actionPlanGuidedJourney;
    @track ssoBsGuidedJourney;

    namespaceVar = "propertyValue";

    label = {
        singleSalesObjective,
        strategicAnalysis,
        blueSheetInBraces,
        currentPosition,
        strategicSellingScorecard,
        buyingInfluence,
        competition,
        summaryOfMyPositionToday,
        actionPlan,
        //--230
        actionPlanNotStarted,
        actionPlanInProgress,
        actionPlanCompleted,
        actionPlanNoStartedURL,
        actionPlanInProgressURL,
        summaryofMyPositionNotStarted,
        summaryofMyPositionInProgress,
        summaryofMyPositionCompleted,
        summaryofMyPositionNotStartedURL,

        //--230
        summaryofMyPositionInProgressURL,
        competitionNotStarted,
        competitionInProgress,
        competitionCompleted,
        competitionNotStartedURL,
        competitionInProgressURL,

        buyingInfluenceNotStarted,
        buyingInfluenceInProgress,
        buyingInfluenceCompleted,
        buyingInfluenceNotStartedURL,
        buyingInfluenceInProgressURL,
        scorecardNotStarted,
        scorecardInProgress,
        scorecardCompleted,
        scorecardNotStartedURL,
        currentpositionNotStarted,
        currentpositionInProgress,
        currentpositionCompleted,
        currentpositionNotStartedURL,
        singlesalesobjectiveNotStarted,
        singlesalesobjectiveInProgress,
        singlesalesobjectiveCompleted,
        singlesalesobjectiveNotStartedURL,
        singlesalesobjectiveInProgressURL,
        Show_Insights,
        Hide_Insights,
        //--230
        BlueSheetErrorGet, //KFS-2766
        BlueSheetErrorLoad, //KFS-2766
        categoryCompetitor,
        categoryPerspective
    };

    connectedCallback() {
        this.expandMenu = true;
        this.showcustomInsights = true;
        this.showInsightslink = this.label.Hide_Insights;
        this.utilMenu = "utility:chevrondown";
        let testURL = window.location.href;
        let newURL = new URL(testURL).searchParams;
        getNamespaceWithUnderScores()
            .then(result => {
                if (result !== "") {
                    this.namespaceVar = result + this.namespaceVar;
                    this.propertyValue = newURL.get(this.namespaceVar);
                } else {
                    this.propertyValue = newURL.get("c__propertyValue");
                }
            })
            .catch(error => {
                // eslint-disable-next-line no-console
                console.log(JSON.stringify(error));
            });
        getOppId({ blueSheetId: this.recordId })
            .then(result => {
                this.opportunityId = result;
                this.loadBlueSheetComponentProgress();
                fireEvent(this.pageRef, "fireBlueSheetWidget", "FireEvent");
                pubsub.fire("refreshBestActionGrid", "");
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.label.BlueSheetErrorGet, //KFS-2766
                        message: error.body.message,
                        variant: "error"
                    })
                );
            });

        //this.resisterCommunicationWithSelfGuidedJourney();
    }
    renderedCallback() {
        this.renderCount++;
        if (this.propertyValue !== undefined && this.propertyValue != null) {
            // eslint-disable-next-line
            setTimeout(() => {
                this.scrollPageByName(this.propertyValue);
            }, 5000);
            // eslint-enable-next-line
        }
    }

    loadBlueSheetComponentProgress() {
        getBlueSheetActionInprogress({ opptId: this.opportunityId })
            .then(result => {
                this.blueSheetComponentProgress = result;
                if (this.blueSheetComponentProgress !== null) {
                    this.ssoProgress = this.blueSheetComponentProgress[0].singleSalesObjectiveProgress;
                    this.currentPosProgress = this.blueSheetComponentProgress[0].currentPositionProgress;
                    this.scorecardProgress = this.blueSheetComponentProgress[0].scoreCardProgress;
                    this.competitionProgress = this.blueSheetComponentProgress[0].competitionProgress;
                    this.biProgress = this.blueSheetComponentProgress[0].buyingInfluenceProgress;
                    this.summaryofmyPosProgress = this.blueSheetComponentProgress[0].summaryOfMyPositionProgress;
                    this.actionPlanProgress = this.blueSheetComponentProgress[0].actionPlanProgress;
                }
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.label.BlueSheetErrorLoad, //KFS-2766
                        message: error.body.message,
                        variant: "error"
                    })
                );
            });
    }

    handleClick(event) {
        const linkName = event.detail;
        const anchor = this.template.querySelector("." + linkName);
        anchor.scrollIntoView({ behavior: "smooth", block: "center", inline: "nearest" });
    }

    scrollPageByName(linkName) {
        const anchor = this.template.querySelector("." + linkName);
        anchor.scrollIntoView({ behavior: "smooth", block: "center", inline: "nearest" });
    }

    handleProgress(event) {
        this.loadBlueSheetComponentProgress();
        if (event && event.detail && event.detail.type === "refreshInsights") {
            pubsub.fire("refreshCustomInsights", this.label.categoryCompetitor);
        } else if (event && event.detail && event.detail.type === "refreshActionPlanInsights") {
            let data = {
                type: this.label.categoryPerspective,
                showActionInsight: event.detail.showActionInsight
            };
            pubsub.fire("refreshPersCustomInsights", data);
        }

        fireEvent(this.pageRef, "fireBlueSheetWidget", "FireEvent");
    }

    expandmenuClick() {
        if (this.expandMenu === false) {
            this.utilMenu = "utility:chevrondown";
            this.showInsightslink = this.label.Hide_Insights;
        } else {
            this.utilMenu = "utility:chevronright";
            this.showInsightslink = this.label.Show_Insights;
        }
        this.expandMenu = !this.expandMenu;
        this.template.querySelector("c-action-Plan-Page").handleRefresh();
    }

    handleProgressGuidedJourney(event) {
        this.moduleDetail = event.detail;
        if (
            this.moduleDetail.moduleNameId === "Lesson_3_Module_1" ||
            this.moduleDetail.moduleNameId === "Lesson_7_Module_4"
        ) {
            this.summaryOfMPGuidedJourney = this.moduleDetail;
            fireEvent(this.pageRef, "ModuleDataSOMP", this.summaryOfMPGuidedJourney);
            // eslint-disable-next-line
            setTimeout(() => {
                this.scrollPageByName("anchor_summaryofMypositionDetails");
            }, 3000);
            // eslint-enable-next-line
        }
        if (this.moduleDetail.moduleNameId === "Lesson_3_Module_2") {
            this.ssoGuidedJourney = this.moduleDetail;
            fireEvent(this.pageRef, "ModuleDataSSO", this.ssoGuidedJourney);
            // eslint-disable-next-line
            setTimeout(() => {
                this.scrollPageByName("anchor_ssoCallDetails");
            }, 3000);
            // eslint-enable-next-line
        }
        if (this.moduleDetail.moduleNameId === "Lesson_3_Module_3") {
            this.ssoBsGuidedJourney = this.moduleDetail;
            fireEvent(this.pageRef, "ModuleDataSSOBluesheet", this.ssoBsGuidedJourney);
            // eslint-disable-next-line
            setTimeout(() => {
                this.scrollPageByName("anchor_ssoCallDetails");
            }, 3000);
            // eslint-enable-next-line
        }
        if (this.moduleDetail.moduleNameId === "Lesson_3_Module_4") {
            this.cpGuidedJourney = this.moduleDetail;
            fireEvent(this.pageRef, "ModuleDataCP", this.cpGuidedJourney);
            // eslint-disable-next-line
            setTimeout(() => {
                this.scrollPageByName("anchor_cpCallDetails");
            }, 3000);
            // eslint-enable-next-line
        }
        if (
            this.moduleDetail.moduleNameId === "Lesson_4_Module_1" ||
            this.moduleDetail.moduleNameId === "Lesson_4_Module_2" ||
            this.moduleDetail.moduleNameId === "Lesson_4_Module_4" ||
            this.moduleDetail.moduleNameId === "Lesson_5_Module_1" ||
            this.moduleDetail.moduleNameId === "Lesson_5_Module_3" ||
            this.moduleDetail.moduleNameId === "Lesson_6_Module_1"
        ) {
            this.biGuidedJourney = this.moduleDetail;
            fireEvent(this.pageRef, "ModuleDataBI", this.biGuidedJourney);
            // eslint-disable-next-line
            setTimeout(() => {
                this.scrollPageByName("anchor_buyingInfluenceCallDetails");
            }, 3000);
            // eslint-enable-next-line
        }
        if (this.moduleDetail.moduleNameId === "Lesson_5_Module_5") {
            this.scrcardGuidedJourney = this.moduleDetail;
            fireEvent(this.pageRef, "ModuleDataScoreCard", this.scrcardGuidedJourney);
            // eslint-disable-next-line
            setTimeout(() => {
                this.scrollPageByName("anchor_scoreCardCallDetails");
            }, 3000);
            // eslint-enable-next-line
        }
        if (
            this.moduleDetail.moduleNameId === "Lesson_7_Module_2" ||
            this.moduleDetail.moduleNameId === "Lesson_7_Module_3"
        ) {
            this.competitionGuidedJourney = this.moduleDetail;
            fireEvent(this.pageRef, "ModuleDataCompetition", this.competitionGuidedJourney);
            // eslint-disable-next-line
            setTimeout(() => {
                this.scrollPageByName("anchor_competitionCallDetails");
            }, 3000);
            // eslint-enable-next-line
        }
        if (
            this.moduleDetail.moduleNameId === "Lesson_9_Module_1" ||
            this.moduleDetail.moduleNameId === "Lesson_9_Module_3"
        ) {
            this.actionPlanGuidedJourney = this.moduleDetail;
            fireEvent(this.pageRef, "ModuleDataActionPlan", this.actionPlanGuidedJourney);
            // eslint-disable-next-line
            setTimeout(() => {
                this.scrollPageByName("anchor_actionPlanCallDetails");
            }, 3000);
            // eslint-enable-next-line
        }
    }
}