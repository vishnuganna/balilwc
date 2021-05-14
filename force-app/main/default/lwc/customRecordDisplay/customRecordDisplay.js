import { LightningElement, api } from "lwc";
import Error from "@salesforce/label/c.Error";
import UseFullDomainName from "@salesforce/label/c.UseFullDomainName";

export default class CustomRecordDisplay extends LightningElement {
    @api isRedFlagSelected = false;
    @api redFlagStrengthObject;
    @api fieldApiName;
    @api isStrengthSelected = false;
    @api noneSelected = false;
    @api showMoreShowLess = false;
    @api isSource = false;
    @api fieldDescription;
    @api status;
    @api sourceUrl = false;
    @api sourceText = false;
    @api isRedFlagStrength = false;

    label = {
        Error,
        UseFullDomainName
    };

    connectedCallback() {
        // manipulate data if required
        if (this.redFlagStrengthObject && this.fieldApiName) {
            this.isRedFlagSelected = this.redFlagStrengthObject[this.fieldApiName].redFlagSelected;
            this.isStrengthSelected = this.redFlagStrengthObject[this.fieldApiName].strengthSelected;
            if (!this.isRedFlagSelected && !this.isStrengthSelected) {
                this.noneSelected = true;
            }
        }
        if (this.status) {
            if (this.status === "Complete") {
                this.completedStatus = true;
            } else {
                this.inProgressStatus = true;
            }
        }
        if (this.fieldDescription && this.isSource) {
            this.getSourceURL();
        }
    }
    getSourceURL() {
        var strsource = this.fieldDescription;
        var lstrsource = strsource.toLowerCase();
        if (lstrsource.startsWith("http") || lstrsource.startsWith("www.") || lstrsource.startsWith("ftp:")) {
            this.sourceUrl = true;
            this.sourceText = false;
        } else {
            this.sourceText = true;
            this.sourceUrl = false;
        }
    }
}