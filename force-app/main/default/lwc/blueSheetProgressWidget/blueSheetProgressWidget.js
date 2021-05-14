import { LightningElement, track, api, wire } from "lwc";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import { NavigationMixin } from "lightning/navigation";

import blueSheetBackgroundImg from "@salesforce/resourceUrl/BlueSheet";
import blueSheetLogo from "@salesforce/resourceUrl/BlueSheetLogo";
import getBlueSheetActionInprogress from "@salesforce/apex/BlueSheetStatus.getBlueSheetActionInprogress";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import singleSalesObjective from "@salesforce/label/c.singleSalesObjective";
import currentPosition from "@salesforce/label/c.currentPosition";
import strategicSellingScorecard from "@salesforce/label/c.strategicSellingScorecard";
import buyingInfluence from "@salesforce/label/c.buyingInfluence";
import competition from "@salesforce/label/c.competition";
import summaryOfMyPositionToday from "@salesforce/label/c.summaryOfMyPositionToday";
import actionPlan from "@salesforce/label/c.actionPlan";
import Progress_Navigation_Widget_Massage from "@salesforce/label/c.Progress_Navigation_Widget_Massage";
import Bluesheet_Progress_Navigation_Label from "@salesforce/label/c.Bluesheet_Progress_Navigation_Label";
import { CurrentPageReference } from "lightning/navigation";
import { registerListener, unregisterAllListeners } from "c/eventForBlueSheetProgress";
import BlueSheetErrorLoad from "@salesforce/label/c.BlueSheetErrorLoad";
import ErrorOccured from "@salesforce/label/c.ErrorOccured";
import Warning from "@salesforce/label/c.Warning";
import Error from "@salesforce/label/c.Error";
import BLUESHEET_OBJECT from "@salesforce/schema/Blue_Sheet__c";

export default class BlueSheetProgressWidget extends NavigationMixin(LightningElement) {
    @api kfBlueSheetBanner = blueSheetBackgroundImg;
    @api blueSheetLogo = blueSheetLogo;
    @api recordId;
    @track toogleAccordion = true;

    @track utilName;
    @track variantName;
    @track itemProgress = "";
    @track BluesheetElements = [];
    @track showNorecordState = false;
    @wire(getObjectInfo, { objectApiName: BLUESHEET_OBJECT })
    Function({ error, data }) {
        if (data) {
            this.loadBlueSheetComponentProgress();
            registerListener("fireBlueSheetWidget", this.fireEventFromLandinPage, this);
            // perform your custom logic here
        } else if (error) {
            if (error.status === 403) {
                this.isNonKFUser = true;
            }
        }
    }

    @wire(CurrentPageReference) pageRef;
    label = {
        singleSalesObjective,
        currentPosition,
        strategicSellingScorecard,
        buyingInfluence,
        competition,
        summaryOfMyPositionToday,
        actionPlan,
        Progress_Navigation_Widget_Massage,
        Bluesheet_Progress_Navigation_Label,
        BlueSheetErrorLoad, //KFS-2766
        ErrorOccured, //KFS-2766
        Warning,
        Error
    };

    connectedCallback() {
        // if(!this.isNonKFUser){
        // }
    }
    disconnectedCallback() {
        if (!this.isNonKFUser) {
            unregisterAllListeners(this);
        }
    }
    fireEventFromLandinPage() {
        this.loadBlueSheetComponentProgress();
    }
    handleToogleAccordion() {
        if (this.toogleAccordion) {
            this.toogleAccordion = false;
        } else {
            this.toogleAccordion = true;
        }
    }
    progressRender(itemProgress, Name) {
        let elementArray = [];
        if (itemProgress === "Not Started") {
            this.utilName = "utility:ban";
            this.variantName = "error";
        } else if (itemProgress === "In Progress") {
            this.utilName = "utility:success";
            this.variantName = "warning";
        } else if (itemProgress === "Complete") {
            this.utilName = "utility:success";
            this.variantName = "success";
        }
        elementArray = {
            Name: Name,
            Status: itemProgress,
            utilIcon: this.utilName,
            varient: this.variantName
        };

        return elementArray;
    }

    loadBlueSheetComponentProgress() {
        getBlueSheetActionInprogress({ opptId: this.recordId })
            .then(result => {
                this.blueSheetComponentProgress = result;
                let progressElementArray = [];
                if (this.blueSheetComponentProgress !== null) {
                    if (this.blueSheetComponentProgress[0]) {
                        this.showNorecordState = false;
                        const SSOelement = this.progressRender(
                            this.blueSheetComponentProgress[0].singleSalesObjectiveProgress,
                            singleSalesObjective
                        );
                        progressElementArray.push(SSOelement);
                        const CurrentPosElement = this.progressRender(
                            this.blueSheetComponentProgress[0].currentPositionProgress,
                            currentPosition
                        );
                        progressElementArray.push(CurrentPosElement);
                        const scoreCardElement = this.progressRender(
                            this.blueSheetComponentProgress[0].scoreCardProgress,
                            strategicSellingScorecard
                        );
                        progressElementArray.push(scoreCardElement);
                        const competitionElement = this.progressRender(
                            this.blueSheetComponentProgress[0].competitionProgress,
                            competition
                        );
                        progressElementArray.push(competitionElement);
                        const buyingInfluenceElement = this.progressRender(
                            this.blueSheetComponentProgress[0].buyingInfluenceProgress,
                            buyingInfluence
                        );
                        progressElementArray.push(buyingInfluenceElement);
                        const summaryOfMyPositionElement = this.progressRender(
                            this.blueSheetComponentProgress[0].summaryOfMyPositionProgress,
                            summaryOfMyPositionToday
                        );
                        progressElementArray.push(summaryOfMyPositionElement);
                        const actionPlanElement = this.progressRender(
                            this.blueSheetComponentProgress[0].actionPlanProgress,
                            actionPlan
                        );
                        progressElementArray.push(actionPlanElement);
                        this.BluesheetElements = progressElementArray;
                    } else {
                        this.showNorecordState = true;
                    }
                }
            })
            .catch(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.label.BlueSheetErrorLoad, //KFS-2766
                        message: this.label.ErrorOccured, //KFS-2766
                        variant: "error"
                    })
                );
            });
    }
}