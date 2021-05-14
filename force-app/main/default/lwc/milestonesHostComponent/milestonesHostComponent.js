import { LightningElement, api, track } from "lwc";
import milestone1TitleLabel from "@salesforce/label/c.Milestone1Title";
import milestone2TitleLabel from "@salesforce/label/c.Milestone2Title";
import milestone3TitleLabel from "@salesforce/label/c.Milestone3Title";
import milestone4TitleLabel from "@salesforce/label/c.Milestone4Title";
import milestone5TitleLabel from "@salesforce/label/c.Milestone5Title";
import milestonesTitleLabel from "@salesforce/label/c.MilestonesTitle";
import Milestone1_URL from "@salesforce/label/c.Milestone1_URL";
import Milestone2_URL from "@salesforce/label/c.Milestone2_URL";
import Milestone3_URL from "@salesforce/label/c.Milestone3_URL";
import Milestone4_URL from "@salesforce/label/c.Milestone4_URL";
import Milestone5_URL from "@salesforce/label/c.Milestone5_URL";
import sumPositionHeaderURL from "@salesforce/label/c.sumPositionHeaderURL";

export default class MilestonesHostComponent extends LightningElement {
    @api getIdFromParent;
    @track isbuttondisable = false;
    @track isEditDataDisabled = false;
    @track isDeleteDataDisabled = false;
    @api isstrategicPlayerMile = false;

    allLabel = {
        milestone1TitleLabel,
        milestone2TitleLabel,
        milestone3TitleLabel,
        milestone4TitleLabel,
        milestone5TitleLabel,
        milestonesTitleLabel,
        Milestone1_URL,
        Milestone2_URL,
        Milestone3_URL,
        Milestone4_URL,
        Milestone5_URL,
        sumPositionHeaderURL
    };

    connectedCallback() {
        this.isstrategicPlayerMile = true;
    }

    hanldleclick(event) {
        this.isbuttondisable = event.detail.buttonclicked;
        this.isEditDataDisabled = event.detail.buttonclicked;
        this.isDeleteDataDisabled = event.detail.buttonclicked;
    }
}