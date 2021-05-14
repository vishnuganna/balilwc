import { LightningElement, track, api } from "lwc";
import RevenueTargetCustomHeader from "@salesforce/label/c.RevenueTargetCustomHeader";
import LowTarget from "@salesforce/label/c.LowTarget";
import HighTarget from "@salesforce/label/c.HighTarget";
import RealisticTarget from "@salesforce/label/c.RealisticTarget";
import RecurringRevenue from "@salesforce/label/c.RecurringRevenue";
import LostRevenue from "@salesforce/label/c.LostRevenue";
import NewRevenue from "@salesforce/label/c.NewRevenue";
import Calculate from "@salesforce/label/c.Calculate";
import Assumptions from "@salesforce/label/c.Assumptions";
import ErrorDescriptionTooLong from "@salesforce/label/c.ErrorDescriptionTooLong";
import RevenueTargetHeaderLink from "@salesforce/label/c.RevenueTargetHeaderLink";
import dateErrorMsg from "@salesforce/label/c.dateErrorMsg";
import noDateError from "@salesforce/label/c.noDateError";
import RevenueTargetTabLink from "@salesforce/label/c.RevenueTargetTabLink";
import CustomDate from "@salesforce/label/c.CustomDate";

export default class RevenueTargetInlineTab extends LightningElement {
    @api item;
    @api customyeardate;
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
    @track customDate = null;
    @track todaysdate = new Date().toISOString();

    @track lowTarget = null;
    @track realisticTarget = null;
    @track highTarget = null;

    @track detailId;
    @track tabName = "Custom Year";
    @track showAssumptionError = false;
    @track currentRecordItem = [];
    allLabels = {
        RevenueTargetCustomHeader,
        LowTarget,
        CustomDate,
        HighTarget,
        RealisticTarget,
        RecurringRevenue,
        LostRevenue,
        NewRevenue,
        Calculate,
        Assumptions,
        ErrorDescriptionTooLong,
        RevenueTargetHeaderLink,
        dateErrorMsg,
        noDateError,
        RevenueTargetTabLink
    };

    @track isDateSelected = false;
    @track isDateValid = true;

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
            // this.customDate = this.currentRecordItem.customDate;
            if (this.currentRecordItem.tabType) {
                this.tabName = this.currentRecordItem.tabType;
            }
            this.customDate = this.customyeardate;
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
    updateCustomDate(event) {
        this.customDate = event.target.value;
    }
    updateLowRecurringRevenue(event) {
        this.lowTargetRecurringRev = this.updateRevenue(event.target.value, ".lowTarget");
        this.blurchange();
    }
    updateLowLostRevenue(event) {
        this.lowTargetLostRev = this.updateRevenue(event.target.value, ".lowTarget");
        this.blurchange();
    }
    updateLowNewRevenue(event) {
        this.lowTargetNewRev = this.updateRevenue(event.target.value, ".lowTarget");
        this.blurchange();
    }
    updateLowTarget(event) {
        this.lowTarget = this.updateLowRealisticHighTarget(event.target.value);
        this.blurchange();
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
        this.blurchange();
    }
    updateRealisticLostRevenue(event) {
        this.realisticTargetLostRev = this.updateRevenue(event.target.value, ".realisticTarget");
        this.blurchange();
    }
    updateRealisticNewRevenue(event) {
        this.realisticTargetNewRev = this.updateRevenue(event.target.value, ".realisticTarget");
        this.blurchange();
    }
    updateRealisticTarget(event) {
        this.realisticTarget = this.updateLowRealisticHighTarget(event.target.value);
        this.blurchange();
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
        this.blurchange();
    }
    updateHighLostRevenue(event) {
        this.hightTargetLostRev = this.updateRevenue(event.target.value, ".highTarget");
        this.blurchange();
    }
    updateHighNewRevenue(event) {
        this.highTargetNewRev = this.updateRevenue(event.target.value, ".highTarget");
        this.blurchange();
    }
    updateHighTarget(event) {
        this.highTarget = this.updateLowRealisticHighTarget(event.target.value);
        this.blurchange();
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
    @api getCustomDate() {
        return this.customDate;
    }
    @api showCancelPopUp() {
        return this.hasThePageBeenEdited;
    }

    blurchange() {
        this.isDateSelected = false;
        this.isDateValid = true;
        const el = this.template.querySelector(".datefield");

        if (el.value !== "") {
            this.isDateSelected = false;
            let d1 = new Date();
            let d2 = new Date(el.value);
            const isValid = d1.getTime() < d2.getTime();
            if (isValid) {
                this.isDateValid = true;
                el.classList.remove("errorstate");
            } else {
                this.isDateValid = false;
                el.classList.add("errorstate");
            }
        } else {
            this.isDateSelected = true;
            el.classList.add("errorstate");
        }
    }
}