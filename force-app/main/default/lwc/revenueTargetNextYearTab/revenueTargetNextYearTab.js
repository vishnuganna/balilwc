import { LightningElement, track, api } from "lwc";
import RevenueTargetNYHeader from "@salesforce/label/c.RevenueTargetNYHeader";
import LowTarget from "@salesforce/label/c.LowTarget";
import HighTarget from "@salesforce/label/c.HighTarget";
import RealisticTarget from "@salesforce/label/c.RealisticTarget";
import RecurringRevenue from "@salesforce/label/c.RecurringRevenue";
import LostRevenue from "@salesforce/label/c.LostRevenue";
import NewRevenue from "@salesforce/label/c.NewRevenue";
import Calculate from "@salesforce/label/c.Calculate";
import Assumptions from "@salesforce/label/c.Assumptions";
import ErrorDescriptionTooLong from "@salesforce/label/c.ErrorDescriptionTooLong";
import RevenueTargetTabLink from "@salesforce/label/c.RevenueTargetTabLink";

export default class RevenueTargetInlineTab extends LightningElement {
    @api item;
    @track currentYearAssumption;

    @track lowTargetRecurringRev = null;
    @track lowTargetLostRev = null;
    @track lowTargetNewRev = null;
    @track realisticTargetRecurringRev = null;
    @track realisticTargetLostRev = null;
    @track realisticTargetNewRev = null;
    @track hightTargetRecurringRev = null;
    @track hightTargetLostRev = null;
    @track highTargetNewRev = null;
    @track tabName = "Next Year";
    @track lowTarget = null;
    @track realisticTarget = null;
    @track highTarget = null;
    @track detailId;
    @track currentRecordItem = [];
    @track showAssumptionError = false;
    allLabels = {
        RevenueTargetNYHeader,
        LowTarget,
        HighTarget,
        RealisticTarget,
        RecurringRevenue,
        LostRevenue,
        NewRevenue,
        Calculate,
        Assumptions,
        ErrorDescriptionTooLong,
        RevenueTargetTabLink
    };

    connectedCallback() {
        if (this.item) {
            this.currentRecordItem = JSON.parse(JSON.stringify(this.item));
            this.detailId = this.currentRecordItem.recordId;
            this.lowTargetRecurringRev = this.currentRecordItem.cyLTRecurringRevenue;
            this.lowTargetLostRev = this.currentRecordItem.cyLTLostRevenue;
            this.lowTargetNewRev = this.currentRecordItem.cyLTNewRevenue;
            this.lowTarget = this.currentRecordItem.cyLowTarget;
            this.realisticTargetRecurringRev = this.currentRecordItem.cyRTRecurringRevenue;
            this.realisticTargetLostRev = this.currentRecordItem.cyRTLostRevenue;
            this.realisticTargetNewRev = this.currentRecordItem.cyRTNewRevenue;
            this.realisticTarget = this.currentRecordItem.cyRealisticTarget;
            this.hightTargetRecurringRev = this.currentRecordItem.cyHTRecurringRevenue;
            this.hightTargetLostRev = this.currentRecordItem.cyHTLostRevenue;
            this.highTargetNewRev = this.currentRecordItem.cyHTNewRevenue;
            this.highTarget = this.currentRecordItem.cyHighTarget;
            this.currentYearAssumption = this.currentRecordItem.cyAssumptions;
            if (this.currentRecordItem.tabType) {
                this.tabName = this.currentRecordItem.tabType;
            }
        }
    }
    updateRevenue(event, string) {
        let revenueValue = event;
        if (!revenueValue) {
            revenueValue = null;
        } else {
            this.template.querySelectorAll(string).forEach(function(el) {
                el.setCustomValidity("");
                el.reportValidity();
            });
        }
        if (!this.hasThePageBeenEdited) {
            this.hasThePageBeenEdited = true;
        }
        return revenueValue;
    }
    calculate(recurringRev, lostRev, newRev, string) {
        let targetCalculate = null;
        if (!recurringRev && !lostRev && !newRev) {
            this.template.querySelectorAll(string).forEach(function(el) {
                el.setCustomValidity(" ");
                el.reportValidity();
            });
        } else {
            this.template.querySelectorAll(string).forEach(function(el) {
                el.setCustomValidity("");
                el.reportValidity();
            });

            if (!recurringRev) {
                recurringRev = 0;
            }
            if (!lostRev) {
                lostRev = 0;
            }
            if (!newRev) {
                newRev = 0;
            }

            targetCalculate = Number(recurringRev) - Number(lostRev) + Number(newRev);
        }
        return targetCalculate;
    }

    updateLowRealisticHighTarget(event) {
        let lowRealisticHigh = event;
        if (!lowRealisticHigh) {
            lowRealisticHigh = null;
        }
        if (!this.hasThePageBeenEdited) {
            this.hasThePageBeenEdited = true;
        }
        return lowRealisticHigh;
    }

    updateLowRecurringRevenue(event) {
        this.lowTargetRecurringRev = this.updateRevenue(event.target.value, ".lowTarget");
    }
    updateLowLostRevenue(event) {
        this.lowTargetLostRev = this.updateRevenue(event.target.value, ".lowTarget");
    }
    updateLowNewRevenue(event) {
        this.lowTargetNewRev = this.updateRevenue(event.target.value, ".lowTarget");
    }
    updateLowTarget(event) {
        this.lowTarget = this.updateLowRealisticHighTarget(event.target.value);
    }
    calculateLowTarget() {
        this.lowTarget = this.calculate(
            this.lowTargetRecurringRev,
            this.lowTargetLostRev,
            this.lowTargetNewRev,
            ".lowTarget"
        );
    }
    updateRealisticRecurringRevenue(event) {
        this.realisticTargetRecurringRev = this.updateRevenue(event.target.value, ".realisticTarget");
    }
    updateRealisticLostRevenue(event) {
        this.realisticTargetLostRev = this.updateRevenue(event.target.value, ".realisticTarget");
    }
    updateRealisticNewRevenue(event) {
        this.realisticTargetNewRev = this.updateRevenue(event.target.value, ".realisticTarget");
    }
    updateRealisticTarget(event) {
        this.realisticTarget = this.updateLowRealisticHighTarget(event.target.value);
    }
    calculateRealisticTarget() {
        this.realisticTarget = this.calculate(
            this.realisticTargetRecurringRev,
            this.realisticTargetLostRev,
            this.realisticTargetNewRev,
            ".realisticTarget"
        );
    }
    updateHighRecurringRevenue(event) {
        this.hightTargetRecurringRev = this.updateRevenue(event.target.value, ".highTarget");
    }
    updateHighLostRevenue(event) {
        this.hightTargetLostRev = this.updateRevenue(event.target.value, ".highTarget");
    }
    updateHighNewRevenue(event) {
        this.highTargetNewRev = this.updateRevenue(event.target.value, ".highTarget");
    }
    updateHighTarget(event) {
        this.highTarget = this.updateLowRealisticHighTarget(event.target.value);
    }
    calculateHighTarget() {
        this.highTarget = this.calculate(
            this.hightTargetRecurringRev,
            this.hightTargetLostRev,
            this.highTargetNewRev,
            ".highTarget"
        );
    }
    updateAssumption(event) {
        this.currentYearAssumption = event.target.value;
        if (this.currentYearAssumption.length >= 32000) {
            this.showAssumptionError = true;
        } else {
            this.showAssumptionError = false;
        }
        if (!this.hasThePageBeenEdited) {
            this.hasThePageBeenEdited = true;
        }
    }
    @api checkInputValues() {
        let isFormUpdated = false;
        [...this.template.querySelectorAll("lightning-input")].forEach(element => {
            if (element.value != null && element.value !== "" && element.value !== "undefined") {
                isFormUpdated = true;
            }
        });
        return isFormUpdated;
    }

    @api getCurrentYearInputData() {
        let currentYearData = {
            recordId: this.detailId,
            cyLTRecurringRevenue: this.lowTargetRecurringRev,
            cyLTLostRevenue: this.lowTargetLostRev,
            cyLTNewRevenue: this.lowTargetNewRev,
            cyLowTarget: this.lowTarget,
            cyRTRecurringRevenue: this.realisticTargetRecurringRev,
            cyRTLostRevenue: this.realisticTargetLostRev,
            cyRTNewRevenue: this.realisticTargetNewRev,
            cyRealisticTarget: this.realisticTarget,
            cyHTRecurringRevenue: this.hightTargetRecurringRev,
            cyHTLostRevenue: this.hightTargetLostRev,
            cyHTNewRevenue: this.highTargetNewRev,
            cyHighTarget: this.highTarget,
            cyAssumptions: this.currentYearAssumption,
            tabType: this.tabName
        };

        return currentYearData;
    }
    @api showCancelPopUp() {
        return this.hasThePageBeenEdited;
    }
}