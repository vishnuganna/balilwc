import { LightningElement, api } from "lwc";
import SituationalAppraisal from "@salesforce/label/c.SituationalAppraisal";
import Strategy from "@salesforce/label/c.Strategy";
import Revenue from "@salesforce/label/c.Revenue";
import actionPlan from "@salesforce/label/c.actionPlan";
export default class StrategicStrengthMainPage extends LightningElement {
    @api recordId;
    allLabels = {
        SituationalAppraisal,
        Strategy,
        Revenue,
        actionPlan
    };
}