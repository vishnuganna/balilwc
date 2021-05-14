import { LightningElement, track, api, wire } from "lwc";
import CustomizeAlerts from "@salesforce/label/c.CustomizeAlerts";
import AlertText from "@salesforce/label/c.AlertText";
import Insights from "@salesforce/label/c.Insights";
import InsightsLink from "@salesforce/label/c.InsightsLink";
import InsightsDisplayLinkAs from "@salesforce/label/c.InsightsDisplayLinkAs";
import InsightsIndustry from "@salesforce/label/c.InsightsIndustry";
import InsightsIndustrySelectToolTip from "@salesforce/label/c.InsightsIndustrySelectToolTip";
import InsightsOpportunityType from "@salesforce/label/c.InsightsOpportunityType";
import InsightsOpportunityTypeSelectToolTip from "@salesforce/label/c.InsightsOpportunityTypeSelectToolTip";
import getIndustryPicklistValues from "@salesforce/apex/BusinessRules.getIndustryPicklistValues";
import getOptyTypePicklistValues from "@salesforce/apex/BusinessRules.getOptyTypePicklistValues";
import Scorecard_Template_Name_Max_Char_Limit from "@salesforce/label/c.Scorecard_Template_Name_Max_Char_Limit";

export default class BSCreatePerspective extends LightningElement {
    @track categoryPersp;
    @api isExpandableViewPerspective;
    @track isPerspectiveInputRequired = false;
    @track insightsAlertTextPersp;
    @track insightsLinkTextPersp;
    @track isDisplayLinkAsRequired = false;
    @track insightsDisplayLinkASText;
    @track industryPicklistValues = [];
    @track hasValuesinOptyTypeField = false;
    @track selectedOptyTypeField;
    @track opportunityTypePicklistValues = [];
    @track hasValuesinIndustryField = false;
    @track insightId;
    @track showMaxLimitErrorInsightsDisplayLinkAs = false;
    @track showMaxLimitErrorInsightsLinkTextPersp = false;
    @track showMaxLimitErrorInsightsAlertTextPersp = false;

    @api active;
    @api categoryPersp;

    label = {
        InsightsOpportunityTypeSelectToolTip,
        InsightsOpportunityType,
        InsightsIndustrySelectToolTip,
        InsightsIndustry,
        InsightsDisplayLinkAs,
        CustomizeAlerts,
        AlertText,
        Insights,
        InsightsLink,
        Scorecard_Template_Name_Max_Char_Limit
    };

    handleOptyTypeFieldChange(event) {
        this.selectedOptyTypeField = event.target.value;
    }

    handleIndustryFieldChange(event) {
        this.selectedIndustryField = event.target.value;
    }

    handleInsightsDisplayLinkAs(event) {
        this.insightsDisplayLinkASText = event.target.value;
        if (this.insightsDisplayLinkASText && this.insightsDisplayLinkASText.length === 256) {
            this.showMaxLimitErrorInsightsDisplayLinkAs = true;
        } else {
            this.showMaxLimitErrorInsightsDisplayLinkAs = false;
        }

        this.validationForCustomAlert();
        this.validationForLinkAsDisplay();
    }
    handleInsightsLinkTextPersp(event) {
        this.insightsLinkTextPersp = event.target.value;
        if (this.insightsLinkTextPersp && this.insightsLinkTextPersp.length === 256) {
            this.showMaxLimitErrorInsightsLinkTextPersp = true;
        } else {
            this.showMaxLimitErrorInsightsLinkTextPersp = false;
        }

        this.validationForCustomAlert();
        this.validationForLinkAsDisplay();
    }
    handleInsightsTextPersp(event) {
        this.insightsAlertTextPersp = event.target.value;
        if (this.insightsAlertTextPersp && this.insightsAlertTextPersp.length === 256) {
            this.showMaxLimitErrorInsightsAlertTextPersp = true;
        } else {
            this.showMaxLimitErrorInsightsAlertTextPersp = false;
        }

        this.validationForCustomAlert();
    }

    validationForCustomAlert() {
        if (this.active && this.categoryPersp && !this.insightsAlertTextPersp) {
            this.isPerspectiveInputRequired = true;
            this.isSaveDisabled = true;
            this.fireEventValidation(true);
        } else {
            this.isSaveDisabled = false;
            this.isPerspectiveInputRequired = false;
            this.fireEventValidation(false);
        }
    }

    validationForLinkAsDisplay() {
        if (this.insightsLinkTextPersp && !this.insightsDisplayLinkASText) {
            this.isSaveDisabled = true;
            this.isDisplayLinkAsRequired = true;
            this.fireEventValidation(true);
        } else {
            this.isSaveDisabled = false;
            this.isDisplayLinkAsRequired = false;
            this.fireEventValidation(false);
        }
    }

    @wire(getIndustryPicklistValues)
    industryPicklistValues({ data }) {
        if (data) {
            const result = JSON.parse(data);
            for (let key in result) {
                if (result.hasOwnProperty(key)) {
                    this.industryPicklistValues.push({ label: key, value: key }); //Here we are creating the array to show on UI.
                }
            }
            this.hasValuesinIndustryField = true;
        }
    }

    fireEventValidation(isActivate) {
        const selectedEvent = new CustomEvent("refreshscreen", {
            detail: isActivate
        });
        this.dispatchEvent(selectedEvent);
    }

    @wire(getOptyTypePicklistValues)
    optyTypePicklistValues({ data }) {
        if (data) {
            const result = JSON.parse(data);
            for (let key in result) {
                if (result.hasOwnProperty(key)) {
                    this.opportunityTypePicklistValues.push({ label: key, value: key }); //Here we are creating the array to show on UI.
                }
            }
            this.hasValuesinOptyTypeField = true;
        }
    }

    @api
    getData() {
        this.passDataToParent();
    }
    @api
    setData(data) {
        this.insightsAlertTextPersp = data.alertText;
        this.insightsLinkTextPersp = data.alertLink;
        this.insightsDisplayLinkASText = data.linkdisplayAs;
        this.selectedIndustryField = data.industry;
        this.selectedOptyTypeField = data.optyType;
        this.insightId = data.id;
    }
    passDataToParent() {
        const selectedEvent = new CustomEvent("passeventdata", {
            detail: {
                alertText: this.insightsAlertTextPersp,
                alertLink: this.insightsLinkTextPersp,
                linkdisplayAs: this.insightsDisplayLinkASText,
                industry: this.selectedIndustryField,
                optyType: this.selectedOptyTypeField,
                id: this.insightId
            }
        });
        this.dispatchEvent(selectedEvent);
    }
    handleTogglePerspective() {
        this.isExpandableViewPerspective = !this.isExpandableViewPerspective;
    }
}