import { LightningElement, track, api } from "lwc";
import ActionAlertConfiguration from "@salesforce/label/c.ActionAlertConfiguration";
import ManagerEmailConfiguration from "@salesforce/label/c.ManagerEmailConfiguration";
import SellerAlertConfiguration from "@salesforce/label/c.SellerAlertConfiguration";
import SellerEmailConfiguration from "@salesforce/label/c.SellerEmailConfiguration";
import AlertEnabled from "@salesforce/label/c.AlertEnabled";
import OverrideText from "@salesforce/label/c.OverrideText";
import CustomText from "@salesforce/label/c.CustomText";
import DefaultText from "@salesforce/label/c.DefaultText";
import Header from "@salesforce/label/c.Header";
import AlertText from "@salesforce/label/c.AlertText";
import AlertTextNo from "@salesforce/label/c.AlertTextNo";
import AlertTextYes from "@salesforce/label/c.AlertTextYes";

import getRecommendationsActionByRuleId from "@salesforce/apex/CustomAlertRecommendations.getRecommendationsActionByRuleId";

export default class ViewCustomAlert extends LightningElement {
    @api businessRuleId;
    @track categoryActAlert = true;
    @track customDataAlerId;
    @track customDataAlertEnabled = AlertTextNo;
    @track customDataCustomAlertHeader;
    @track customDataCustomAlertMessage;
    @track customDataDefaultAlertHeader = "";
    @track customDataDefaultAlertMessage;
    @track customDataOverrideHeader = AlertTextNo;
    @track customDataOverrideMessage = AlertTextNo;

    @track customManagerDataAlertEnabled = AlertTextNo;
    @track customManagerDataCustomAlertHeader;
    @track customManagerDataCustomAlertMessage;
    @track customManagerDataDefaultAlertHeader = "";
    @track customManagerDataDefaultAlertMessage;
    @track customManagerDataOverrideHeader = AlertTextNo;
    @track customManagerDataOverrideMessage = AlertTextNo;

    @track customSellerDataAlertEnabled = AlertTextNo;
    @track customSellerDataCustomAlertHeader;
    @track customSellerDataCustomAlertMessage;
    @track customSellerDataDefaultAlertHeader = "";
    @track customSellerDataDefaultAlertMessage;
    @track customSellerDataOverrideHeader = AlertTextNo;
    @track customSellerDataOverrideMessage = AlertTextNo;

    @track viewCategoryActAlert = true;

    label = {
        SellerAlertConfiguration,
        ManagerEmailConfiguration,
        AlertText,
        Header,
        DefaultText,
        CustomText,
        OverrideText,
        AlertEnabled,
        ActionAlertConfiguration,
        SellerEmailConfiguration
    };

    connectedCallback() {
        this.getRecommendationsDataByBSRuleId(this.businessRuleId);
    }

    getRecommendationsDataByBSRuleId(businessRuleId) {
        getRecommendationsActionByRuleId({ bsRuleId: businessRuleId })
            .then(data => {
                this.customDataAlerId = data.action.alerId;
                this.customDataAlertEnabled = data.action.alertEnabled ? AlertTextYes : AlertTextNo;
                this.customDataCustomAlertHeader = data.action.customAlertHeader;
                this.customDataCustomAlertMessage = data.action.customAlertMessage;
                this.customDataDefaultAlertHeader = data.action.defaultAlertHeader;
                this.customDataDefaultAlertMessage = data.action.defaultAlertMessage;
                this.customDataOverrideHeader = data.action.overrideHeader ? AlertTextYes : AlertTextNo;
                this.customDataOverrideMessage = data.action.overrideMessage ? AlertTextYes : AlertTextNo;

                if (data && data.managerEmail) {
                    this.customManagerDataAlerId = data.managerEmail.alerId;
                    this.customManagerDataAlertEnabled = data.managerEmail.alertEnabled ? AlertTextYes : AlertTextNo;
                    this.customManagerDataCustomAlertHeader = data.managerEmail.customAlertHeader;
                    this.customManagerDataCustomAlertMessage = data.managerEmail.customAlertMessage;
                    this.customManagerDataDefaultAlertHeader = data.managerEmail.defaultAlertHeader;
                    this.customManagerDataDefaultAlertMessage = data.managerEmail.defaultAlertMessage;
                    this.customManagerDataOverrideHeader = data.managerEmail.overrideHeader
                        ? AlertTextYes
                        : AlertTextNo;
                    this.customManagerDataOverrideMessage = data.managerEmail.overrideMessage
                        ? AlertTextYes
                        : AlertTextNo;
                }
                if (data && data.sellerEmail) {
                    this.customSellerDataAlerId = data.sellerEmail.alerId;
                    this.customSellerDataAlertEnabled = data.sellerEmail.alertEnabled ? AlertTextYes : AlertTextNo;
                    this.customSellerDataCustomAlertHeader = data.sellerEmail.customAlertHeader;
                    this.customSellerDataCustomAlertMessage = data.sellerEmail.customAlertMessage;
                    this.customSellerDataDefaultAlertHeader = data.sellerEmail.defaultAlertHeader;
                    this.customSellerDataDefaultAlertMessage = data.sellerEmail.defaultAlertMessage;
                    this.customSellerDataOverrideHeader = data.sellerEmail.overrideHeader ? AlertTextYes : AlertTextNo;
                    this.customSellerDataOverrideMessage = data.sellerEmail.overrideMessage
                        ? AlertTextYes
                        : AlertTextNo;
                }
            })
            .catch(error => {
                this.error = error;
            });
    }

    handleToggleSection() {
        this.viewCategoryActAlert = !this.viewCategoryActAlert;
    }
}