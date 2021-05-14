import { LightningElement, api, track } from "lwc";
import SellerEmailConfiguration from "@salesforce/label/c.SellerEmailConfiguration";
import RulescheckError from "@salesforce/label/c.RulescheckError";
import AlertEnabled from "@salesforce/label/c.AlertEnabled";
import OverrideText from "@salesforce/label/c.OverrideText";
import CustomText from "@salesforce/label/c.CustomText";
import DefaultText from "@salesforce/label/c.DefaultText";
import Header from "@salesforce/label/c.Header";
import AlertText from "@salesforce/label/c.AlertText";
import HeaderCustomeMaxError from "@salesforce/label/c.HeaderCustomeMaxError";
import RequiredFieldError from "@salesforce/label/c.RequiredFieldError";
import ManagerEmailConfiguration from "@salesforce/label/c.ManagerEmailConfiguration";
import ActionAlertConfiguration from "@salesforce/label/c.ActionAlertConfiguration";
import AlertMaxError from "@salesforce/label/c.AlertMaxError";

export default class CustomAlertTemplate extends LightningElement {
    @track _alertTemplate;
    @track actionAlertRecord = false;
    @track sellerEmailRecord = false;
    @track managerEmailRecord = false;
    @track currentRecordItem;

    //Varibales used on UI
    @track isAlertEnabled;
    @track overrideHeader;
    @track disableActionAlert;
    @track disableOverrideTextAction;
    @track overrideMessage;
    @track _showNotificationError;
    @track showrequiredHeaderError = false;
    @track showrequiredDescError = false;
    @track showMaxLimitErrorHeaderAction;
    @track showMaxLimitErrorAlertAction;

    @api get showNotificationError() {
        return this._showNotificationError;
    }
    set showNotificationError(value) {
        this._showNotificationError = value;
        if (this.showNotificationError) {
            this.disableActionAlert = true;
            this.disableOverrideTextAction = true;
        } else {
            this.disableActionAlert = false;
            this.disableOverrideTextAction = false;
        }
    }

    @api get alertTemplate() {
        return this._alertTemplate;
    }

    set alertTemplate(value) {
        this._alertTemplate = value;
    }

    label = {
        SellerEmailConfiguration,
        RulescheckError,
        AlertEnabled,
        OverrideText,
        CustomText,
        DefaultText,
        Header,
        HeaderCustomeMaxError,
        RequiredFieldError,
        ManagerEmailConfiguration,
        ActionAlertConfiguration,
        AlertText,
        AlertMaxError
    };
    connectedCallback() {
        this.currentRecordItem = JSON.parse(JSON.stringify(this._alertTemplate));
        this.isAlertEnabled = this.currentRecordItem.alertEnabled;
        this.overrideHeader = this.currentRecordItem.overrideHeader;
        this.customAlertHeaderText = this.currentRecordItem.customAlertHeader;
        this.customAlertDescMessage = this.currentRecordItem.customAlertMessage;
        this.overrideMessage = this.currentRecordItem.overrideMessage;
    }
    updateIsAlertEnabled(event) {
        this.currentRecordItem.alertEnabled = event.target.checked;
        this.UpdateRecordArray();
    }
    updatecustomAlertHeaderText(event) {
        this.currentRecordItem.customAlertHeader = event.target.value;
        if (this.currentRecordItem.customAlertHeader && this.currentRecordItem.customAlertHeader.length === 80) {
            this.showMaxLimitErrorHeaderAction = true;
        } else {
            this.showMaxLimitErrorHeaderAction = false;
        }
        this.validateHeaderCheck();
        this.UpdateRecordArray();
    }
    updateOverrideHeaderCheckbox(event) {
        this.currentRecordItem.overrideHeader = event.target.checked;
        this.validateHeaderCheck();
        this.UpdateRecordArray();
    }
    updatecustomAlertDescMessage(event) {
        this.currentRecordItem.customAlertMessage = event.target.value;
        if (this.currentRecordItem.customAlertMessage && this.currentRecordItem.customAlertMessage.length === 256) {
            this.showMaxLimitErrorAlertAction = true;
        } else {
            this.showMaxLimitErrorAlertAction = false;
        }
        this.validateDescCheck();
        this.UpdateRecordArray();
    }
    updateoverrideMessageCheckbox(event) {
        this.currentRecordItem.overrideMessage = event.target.checked;
        this.validateDescCheck();
        this.UpdateRecordArray();
    }

    validateHeaderCheck() {
        if (!this.currentRecordItem.customAlertHeader && this.currentRecordItem.overrideHeader) {
            this.showrequiredHeaderError = true;
            let inputText = this.template.querySelector(".customAlertHeaderText");
            inputText.setCustomValidity(RequiredFieldError);
            inputText.reportValidity();
        } else {
            this.showrequiredHeaderError = false;
            let inputText = this.template.querySelector(".customAlertHeaderText");
            inputText.setCustomValidity("");
            inputText.reportValidity();
        }
    }
    validateDescCheck() {
        if (!this.currentRecordItem.customAlertMessage && this.currentRecordItem.overrideMessage) {
            this.showrequiredDescError = true;
            let inputText = this.template.querySelector(".customAlertDescMessage");
            inputText.setCustomValidity(RequiredFieldError);
            inputText.reportValidity();
        } else {
            this.showrequiredDescError = false;
            let inputText = this.template.querySelector(".customAlertDescMessage");
            inputText.setCustomValidity("");
            inputText.reportValidity();
        }
    }

    UpdateRecordArray() {
        const updateEvent = new CustomEvent("childupdate", {
            detail: this.currentRecordItem
        });
        this.dispatchEvent(updateEvent);
    }
}