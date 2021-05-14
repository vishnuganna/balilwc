import { api, LightningElement, track } from "lwc";
import getSSOListData from "@salesforce/apex/ActionPlan.getSSOListData";
import getBIListData from "@salesforce/apex/ActionPlan.getBIListData";
import getCompetitorListData from "@salesforce/apex/ActionPlan.getCompetitorListData";
import getSOMPListData from "@salesforce/apex/ActionPlan.getSOMPListData";
import getSuggestedActionMetaData from "@salesforce/apex/ActionPlan.getSuggestedActionMetaData";
import isStrength from "@salesforce/resourceUrl/is_strength";
import isRedFlag from "@salesforce/resourceUrl/is_red_flag";
import addNewPossibleAction from "@salesforce/label/c.AddNewPossibleAction";
import sso from "@salesforce/label/c.Customer_Stated_Objective";
import bi from "@salesforce/label/c.buyingInfluence";
import competition from "@salesforce/label/c.competition";
import positionSummary from "@salesforce/label/c.summaryOfMyPositionToday";
import suggested from "@salesforce/label/c.SuggestedPossibleActions";
import save from "@salesforce/label/c.save";
import cancel from "@salesforce/label/c.cancel";

export default class AddFromList extends LightningElement {
    @api isStrength = isStrength;
    @api isRedFlag = isRedFlag;
    @api ifModalClosed;
    @api blueSheetId;
    @track fieldNames;
    @track ssoNames;
    @track biNames;
    @track competitionNames;
    @track sompNames;
    @track suggestedNames;
    @track checkedValues = [];

    label = {
        addNewPossibleAction,
        sso,
        bi,
        competition,
        positionSummary,
        suggested,
        save,
        cancel
    };

    connectedCallback() {
        // get sso names and strength / red flag properties
        getSSOListData({ blueSheetId: this.blueSheetId })
            .then(result => {
                this.ssoNames = JSON.parse(result.toString());
            })
            .catch(error => {
                this.raiseError(error, "SSO");
            });
        getBIListData({ blueSheetId: this.blueSheetId })
            .then(result => {
                this.biNames = JSON.parse(result.toString());
            })
            .catch(error => {
                this.raiseError(error, "BI");
            });
        getCompetitorListData({ blueSheetId: this.blueSheetId })
            .then(result => {
                this.competitionNames = JSON.parse(result.toString());
            })
            .catch(error => {
                this.raiseError(error, "Competition");
            });
        getSOMPListData({ blueSheetId: this.blueSheetId })
            .then(result => {
                this.sompNames = JSON.parse(result.toString());
            })
            .catch(error => {
                this.raiseError(error, "Summary of my position");
            });
        getSuggestedActionMetaData({ blueSheetId: this.blueSheetId })
            .then(result => {
                this.suggestedNames = JSON.parse(result.toString());
            })
            .catch(error => {
                this.raiseError(error, "Suggested action");
            });
    }

    handleSsoChange(event) {
        this.processEvent(event, "SSO");
    }

    handleBiChange(event) {
        this.processEvent(event, "BI");
    }

    handleCompChange(event) {
        this.processEvent(event, "COMP");
    }

    handleSompChange(event) {
        this.processEvent(event, "SOMP");
    }

    handleSugChange(event) {
        this.processEvent(event, "SUG");
    }

    processEvent(event, type) {
        let value;
        if (type === "SSO") {
            value = this.ssoNames.find(({ id }) => id === event.target.value);
        }
        if (type === "BI") {
            value = this.biNames.find(({ id }) => id === event.target.value);
        }
        if (type === "COMP") {
            value = this.competitionNames.find(({ id }) => id === event.target.value);
        }
        if (type === "SOMP") {
            value = this.sompNames.find(({ id }) => id === event.target.value);
        }
        if (type === "SUG") {
            value = this.suggestedNames.find(({ id }) => id === event.target.value);
        }

        // skip, nothing found
        if (value === undefined) {
            return;
        }

        // add or remove from list based on event
        let idx = this.checkedValues.indexOf(value);
        if (event.target.checked) {
            if (idx === -1) {
                this.checkedValues.push(value);
            }
        } else {
            if (idx > -1) {
                this.checkedValues.splice(idx, 1);
            }
        }
    }

    saveActionList() {
        this.ifModalClosed = false;
        const saveEvent = new CustomEvent("modalvaluechange", {
            detail: {
                modalStatus: this.ifModalClosed,
                checkedValues: this.checkedValues
            }
        });
        this.dispatchEvent(saveEvent);
    }

    cancelAddFromListPopup() {
        this.ifModalClosed = false;
        const cancelEvent = new CustomEvent("modalvaluechange", {
            detail: {
                modalStatus: this.ifModalClosed,
                checkedValues: []
            }
        });
        this.dispatchEvent(cancelEvent);
    }

    raiseError(error, type) {
        let errorMsg = "Unknown error";
        if (Array.isArray(error.body)) {
            errorMsg = error.body.map(e => e.message).join(", ");
        } else if (typeof error.body.message === "string") {
            errorMsg = error.body.message;
        }
        // eslint-disable-next-line no-console
        console.error("Error loading " + type + " list: " + errorMsg);
        /*
        AJL: How are we to handle errors here?
        this.dispatchEvent(
            new ShowToastEvent({
                title: "Error Loading SSO List",
                message: errorMsg,
                variant: "error"
            })
        );
        */
    }
}