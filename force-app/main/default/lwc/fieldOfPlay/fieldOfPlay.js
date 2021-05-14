import { LightningElement, api } from "lwc";
import SituationalAppraisal from "@salesforce/label/c.SituationalAppraisal";
import Strategy from "@salesforce/label/c.Strategy";
import Revenue from "@salesforce/label/c.Revenue";
import actionPlan from "@salesforce/label/c.actionPlan";
import { loadStyle } from "lightning/platformResourceLoader";
import styles from "@salesforce/resourceUrl/cssLibrary";

export default class FieldOfPlay extends LightningElement {
    @api recordId;
    allLabels = {
        SituationalAppraisal,
        Strategy,
        Revenue,
        actionPlan
    };

    connectedCallback() {
        localStorage.removeItem("action");
        localStorage.removeItem("informationNeeded");
        localStorage.removeItem("investmentPrograms");
    }

    renderedCallback() {
        loadStyle(this, styles);
    }
}