import { LightningElement, track, api } from "lwc";
import getRevenueTargetData from "@salesforce/apex/RevenueTargetsController.getRevenueTargetData";
import getObjectPermission from "@salesforce/apex/RevenueTargetsController.getObjectPermission";
import saveRevenueDetails from "@salesforce/apex/RevenueTargetsController.saveRevenueDetails";
import Save from "@salesforce/label/c.save";
import Delete from "@salesforce/label/c.delete";
import Edit from "@salesforce/label/c.edit";
import Cancel from "@salesforce/label/c.cancel";
import Close from "@salesforce/label/c.close";
import Yes from "@salesforce/label/c.yes";
import no from "@salesforce/label/c.no";
import RevenueTargets from "@salesforce/label/c.RevenueTargets";
import CurrentYear from "@salesforce/label/c.CurrentYear";
import NextYear from "@salesforce/label/c.NextYear";
import CustomDate from "@salesforce/label/c.CustomDate";
import Realistic from "@salesforce/label/c.Realistic";
import ShowAssumptions from "@salesforce/label/c.ShowAssumptions";
import HideAssumptions from "@salesforce/label/c.HideAssumptions";
import CalculateRevenueTargets from "@salesforce/label/c.CalculateRevenueTargets";
import CancelRevenueTarget from "@salesforce/label/c.CancelRevenueTarget";
import low from "@salesforce/label/c.low";
import high from "@salesforce/label/c.high";
import successmsg from "@salesforce/label/c.Record_success_message";
import successheader from "@salesforce/label/c.success_header";
import errorheader from "@salesforce/label/c.error_header";
import dateErrorMsg from "@salesforce/label/c.dateErrorMsg";
import RevenueTargetHeaderLink from "@salesforce/label/c.RevenueTargetHeaderLink";
import noValueError from "@salesforce/label/c.NoValueError";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import noDateError from "@salesforce/label/c.noDateError";
import { loadStyle } from "lightning/platformResourceLoader";
import styles from "@salesforce/resourceUrl/cssLibrary";
import LOCALE from "@salesforce/i18n/locale";

export default class RevenueTarget extends LightningElement {
    @track showEditButton = false;
    @track revenueTargetData = [];
    @track showEditView = false;
    @track showSavedState = true;
    @track toogleAccordion = true;
    @track ShowCancelModal;
    @api getIdFromParent;
    @track currentYearData = [];
    @track NextYearData = [];
    @track customYearData = [];
    @track hasRevenueTargetData = false;
    @track disableEdit = false;
    @track customDateValue;

    allLabels = {
        Save,
        Delete,
        Edit,
        Cancel,
        Close,
        Yes,
        no,
        high,
        low,
        CancelRevenueTarget,
        CalculateRevenueTargets,
        HideAssumptions,
        ShowAssumptions,
        Realistic,
        CustomDate,
        NextYear,
        CurrentYear,
        RevenueTargets,
        successheader,
        successmsg,
        RevenueTargetHeaderLink,
        errorheader,
        dateErrorMsg,
        noValueError,
        noDateError
    };

    connectedCallback() {
        this.getObjectPermission();
        this.getDataFromBackEnd();
    }
    renderedCallback() {
        loadStyle(this, styles);
    }
    getDataFromBackEnd() {
        getRevenueTargetData({ goldsheetId: this.getIdFromParent }).then(result => {
            if (result) {
                this.revenueTargetData = result;
                this.hasRevenueTargetData = true;
                this.currentYearData = this.revenueTargetData.currentYearWrapper;
                this.NextYearData = this.revenueTargetData.newYearWrapper;
                this.customYearData = this.revenueTargetData.customDateWrapper;
                //this.customDateValue = this.revenueTargetData.customDate;
                this.customDateValue = new Intl.DateTimeFormat(LOCALE).format(
                    new Date(this.revenueTargetData.customDate)
                );
            }
        });
    }
    getObjectPermission() {
        getObjectPermission().then(result => {
            this.hasEditAccess = result.isUpdateable;
            this.hasCreateAccess = result.isCreateable;
            this.hasDeleteAccess = result.isDeletable;
            if (this.hasEditAccess) {
                this.showEditButton = true;
            }
        });
    }
    handleEdit() {
        this.showEditView = true;
        this.showSavedState = false;
        this.disableEdit = true;
    }
    handleCancel() {
        let showCancelPopUpInline = this.template.querySelector("c-revenue-target-inline-tab").showCancelPopUp();
        let showCancelPopUpNextYear;
        let showCancelPopUpCustomYear;
        if (this.template.querySelector("c-revenue-target-next-year-tab")) {
            showCancelPopUpNextYear = this.template.querySelector("c-revenue-target-next-year-tab").showCancelPopUp();
        }
        if (this.template.querySelector("c-revenue-target-custom-year-tab")) {
            showCancelPopUpCustomYear = this.template
                .querySelector("c-revenue-target-custom-year-tab")
                .showCancelPopUp();
        }
        if (showCancelPopUpInline || showCancelPopUpNextYear || showCancelPopUpCustomYear) {
            this.ShowCancelModal = true;
        } else {
            this.showEditView = false;
            this.showSavedState = true;
            this.disableEdit = false;
        }
    }
    handleConfirmCancel() {
        this.showEditView = false;
        this.ShowCancelModal = false;
        this.showSavedState = true;
        this.disableEdit = false;
    }
    handleDonotCancel() {
        this.ShowCancelModal = false;
    }
    handleToogleAccordion() {
        if (this.toogleAccordion) {
            this.toogleAccordion = false;
        } else {
            this.toogleAccordion = true;
        }
    }
    handleSave() {
        let validNextYearData = this.template.querySelector("c-revenue-target-next-year-tab")
            ? this.template.querySelector("c-revenue-target-next-year-tab").checkInputValues()
            : false;
        let validCurrentyearData = this.template.querySelector("c-revenue-target-inline-tab")
            ? this.template.querySelector("c-revenue-target-inline-tab").checkInputValues()
            : false;
        let validCustomYearData = this.template.querySelector("c-revenue-target-custom-year-tab")
            ? this.template.querySelector("c-revenue-target-custom-year-tab").checkInputValues()
            : false;
        if (validNextYearData || validCurrentyearData || validCustomYearData) {
            let currentYearData;
            currentYearData = this.template.querySelector("c-revenue-target-inline-tab").getCurrentYearInputData();
            let nextYearData;
            let customYearData;
            let customdateField;
            if (this.template.querySelector("c-revenue-target-next-year-tab")) {
                nextYearData = this.template.querySelector("c-revenue-target-next-year-tab").getCurrentYearInputData();
            }
            if (this.template.querySelector("c-revenue-target-custom-year-tab")) {
                customYearData = this.template
                    .querySelector("c-revenue-target-custom-year-tab")
                    .getCurrentYearInputData();
                customdateField = this.template.querySelector("c-revenue-target-custom-year-tab").getCustomDate();
            }
            let currentDate = new Date().toISOString();
            let isValidDate = true;
            if (validCustomYearData) {
                if (customdateField > currentDate) {
                    isValidDate = true;
                } else {
                    isValidDate = false;
                }
            }
            if (isValidDate) {
                let revenueDetailsArray = {
                    goldSheetId: this.getIdFromParent,
                    currentYearWrapper: currentYearData,
                    newYearWrapper: nextYearData,
                    customDateWrapper: customYearData,
                    customDate: customdateField
                };
                saveRevenueDetails({ inputString: JSON.stringify(revenueDetailsArray) }).then(() => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: this.allLabels.successheader,
                            message: this.allLabels.successmsg,
                            variant: "success"
                        })
                    );
                    this.showEditView = false;
                    this.showSavedState = true;
                    this.disableEdit = false;
                    this.getDataFromBackEnd();
                });
            } /*else {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.allLabels.errorheader,
                        message: this.allLabels.dateErrorMsg,
                        variant: "Error"
                    })
                );
            }*/
        } else {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: this.allLabels.errorheader,
                    message: this.allLabels.noValueError,
                    variant: "Error"
                })
            );
        }
    }
}