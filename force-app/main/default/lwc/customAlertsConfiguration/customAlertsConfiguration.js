import { LightningElement, track, api } from "lwc";
import SellerEmailConfiguration from "@salesforce/label/c.SellerEmailConfiguration";
import RulescheckError from "@salesforce/label/c.RulescheckError";
import AlertEnabled from "@salesforce/label/c.AlertEnabled";
import OverrideText from "@salesforce/label/c.OverrideText";
import CustomText from "@salesforce/label/c.CustomText";
import DefaultText from "@salesforce/label/c.DefaultText";
import Header from "@salesforce/label/c.Header";
import HeaderCustomeMaxError from "@salesforce/label/c.HeaderCustomeMaxError";
import RequiredFieldError from "@salesforce/label/c.RequiredFieldError";
import ManagerEmailConfiguration from "@salesforce/label/c.ManagerEmailConfiguration";
import ActionAlertConfiguration from "@salesforce/label/c.ActionAlertConfiguration";

export default class CustomAlertsConfiguration extends LightningElement {
    // Action Alert variables
    @track categoryActAlert;
    @track viewCategoryActionAlert = true;
    @track isAlertEnabledAction = true;
    @track disableOverrideTextAction;
    @track isHeaderOverrideEnabledAction = false;
    @track isAlertOverrideEnabledAction = false;
    @track alertCustomTextAction;
    @track headerCustomTextAction;
    @track disableActionAlert;
    @track disableActionAlertCustomText;
    @track disableSellerAlertCustomText;
    @track disableMngrAlertCustomText;
    @track showMaxLimitErrorHeaderAction;
    @track showMaxLimitErrorAlertAction;
    @api defaultAlertHeaderAction;
    @api defaultAlertMessageAction;
    @track requiredBoolAction = false;

    // Manager variables
    @track categoryMngrAlert;
    @track viewCategoryMngrAlert = true;
    @track isAlertEnabledMngr = true;
    @track disableOverrideTextMngr;
    @track isHeaderOverrideEnabledMngr = false;
    @track isAlertOverrideEnabledMngr = false;
    @track alertCustomTextMngr;
    @track headerCustomTextMngr;
    @track disableMngrAlert;
    @track showMaxLimitErrorHeaderMngr;
    @track showMaxLimitErrorAlertMngr;
    @api defaultAlertHeaderMngr;
    @api defaultAlertMessageMngr;
    @track requiredBoolMngr = false;

    // Seller variables
    @track categorySellerAlert;
    @track viewCategorySellerAlert = true;
    @track isAlertEnabledSeller = true;
    @track disableOverrideTextSeller;
    @track isHeaderOverrideEnabledSeller = false;
    @track isAlertOverrideEnabledSeller = false;
    @track alertCustomTextSeller;
    @track headerCustomTextSeller;
    @track disableSellerAlert;
    @track showMaxLimitErrorHeaderSeller;
    @track showMaxLimitErrorAlertSeller;
    @api defaultAlertHeaderSeller;
    @api defaultAlertMessageSeller;
    @track requiredBoolSeller = false;

    //Common variables
    @track errorCounter = 0;
    @track showCreateEditState = true;
    @track showNotificationError;
    @api categoryActoptions;
    @api isSaveDisabled;

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
        ActionAlertConfiguration
    };

    // Common methods for all alert types
    @api
    errorNotification(chckstatus) {
        if (chckstatus === true) {
            this.errorCounter = this.errorCounter + 1;
        } else {
            this.errorCounter = this.errorCounter - 1;
        }
        if (this.errorCounter <= 1) {
            this.categorySellerAlert = true;
            this.categoryActAlert = true;
            this.categoryMngrAlert = true;

            this.disableActionAlert = false;
            this.disableMngrAlert = false;
            this.disableSellerAlert = false;

            this.disableOverrideTextAction = false;
            this.disableOverrideTextMngr = false;
            this.disableOverrideTextSeller = false;

            this.isAlertEnabledAction = true;
            this.isAlertEnabledMngr = true;
            this.isAlertEnabledSeller = true;

            this.showNotificationError = false;
            if (this.categoryActoptions === true && this.errorCounter === 1) {
                this.categoryActAlert = true;
                this.categoryMngrAlert = true;
                this.categorySellerAlert = true;
            } else {
                this.categoryActAlert = false;
                this.categoryMngrAlert = false;
                this.categorySellerAlert = false;
            }
        } else {
            this.showNotificationError = true;

            this.disableActionAlert = true;
            this.disableMngrAlert = true;
            this.disableSellerAlert = true;

            this.disableOverrideTextAction = true;
            this.disableOverrideTextMngr = true;
            this.disableOverrideTextSeller = true;

            this.intializeAllAlertConfig();
        }
    }

    @api
    errorNotificationOnEditMode(chckstatus) {
        if (chckstatus === true) {
            this.errorCounter = this.errorCounter + 1;
        }
        if (this.errorCounter <= 1) {
            this.categorySellerAlert = true;
            this.categoryActAlert = true;
            this.categoryMngrAlert = true;

            this.disableActionAlert = false;
            this.disableMngrAlert = false;
            this.disableSellerAlert = false;

            this.disableOverrideTextAction = false;
            this.disableOverrideTextMngr = false;
            this.disableOverrideTextSeller = false;

            this.isAlertEnabledAction = true;
            this.isAlertEnabledMngr = true;
            this.isAlertEnabledSeller = true;

            this.showNotificationError = false;
            if (this.categoryActoptions === true && this.errorCounter === 1) {
                this.categoryActAlert = true;
                this.categoryMngrAlert = true;
                this.categorySellerAlert = true;
            } else {
                this.categoryActAlert = false;
                this.categoryMngrAlert = false;
                this.categorySellerAlert = false;
            }
        } else {
            this.showNotificationError = true;

            this.disableActionAlert = true;
            this.disableMngrAlert = true;
            this.disableSellerAlert = true;

            this.disableOverrideTextAction = true;
            this.disableOverrideTextMngr = true;
            this.disableOverrideTextSeller = true;

            this.intializeAllAlertConfig();
        }
    }

    intializeAllAlertConfig() {
        // Action variables
        this.isHeaderOverrideEnabledAction = false;
        this.isAlertOverrideEnabledAction = false;
        this.isAlertEnabledAction = false;
        this.alertCustomTextAction = "";
        this.headerCustomTextAction = "";

        // Seller variables
        this.isHeaderOverrideEnabledSeller = false;
        this.isAlertOverrideEnabledSeller = false;
        this.isAlertEnabledSeller = false;
        this.alertCustomTextSeller = "";
        this.headerCustomTextSeller = "";

        // Manager variables
        this.isHeaderOverrideEnabledMngr = false;
        this.isAlertOverrideEnabledMngr = false;
        this.isAlertEnabledMngr = false;
        this.alertCustomTextMngr = "";
        this.headerCustomTextMngr = "";
    }

    @api
    showEditState(errorCounter) {
        this.errorCounter = errorCounter;
        this.categoryActAlert = true;
        this.categorySellerAlert = true;
        this.categoryMngrAlert = true;
        this.errorCounter = this.errorCounter + 1;
    }

    // Action methods
    handleToggleSectionAction() {
        this.viewCategoryActionAlert = !this.viewCategoryActionAlert;
    }

    handleIsAlertEnabledClickAction(event) {
        if (event.target.checked === false) {
            this.isAlertEnabledAction = false;
            this.isHeaderOverrideEnabledAction = false;
            this.isAlertOverrideEnabledAction = false;
            this.disableOverrideTextAction = true;
            this.disableActionAlertCustomText = true;
        } else {
            this.isAlertEnabledAction = true;
            this.disableOverrideTextAction = false;
            this.disableActionAlertCustomText = false;
        }
        this.validateTextAction();
    }

    handleIsHeaderOverrideClickAction(event) {
        if (event.target.checked === false) {
            this.isHeaderOverrideEnabledAction = false;
        } else {
            this.isHeaderOverrideEnabledAction = true;
        }
        this.validateTextAction();
    }

    handleheaderCustomInputsAction(event) {
        this.headerCustomTextAction = event.target.value;
        if (this.headerCustomTextAction.length === 80) {
            this.showMaxLimitErrorHeaderAction = true;
            this.isSaveDisabled = true;
        } else {
            this.showMaxLimitErrorHeaderAction = false;
            this.isSaveDisabled = false;
        }
        this.validateTextAction();
    }

    handleIsAlertOverrideEnabledClickAction(event) {
        if (event.target.checked === false) {
            this.isAlertOverrideEnabledAction = false;
        } else {
            this.isAlertOverrideEnabledAction = true;
        }
        this.validateTextAction();
    }

    handlealertCustomTextAction(event) {
        this.alertCustomTextAction = event.target.value;
        if (this.alertCustomTextAction.length === 256) {
            this.showMaxLimitErrorAlertAction = true;
            this.isSaveDisabled = true;
        } else {
            this.showMaxLimitErrorAlertAction = false;
            this.isSaveDisabled = false;
        }
        this.validateTextAction();
    }

    @api
    mapActionDataEdit(actionObjEdit) {
        this.isAlertEnabledAction = actionObjEdit.actionAlertEnabled;
        this.isHeaderOverrideEnabledAction = actionObjEdit.actionOverrideHeader;
        this.isAlertOverrideEnabledAction = actionObjEdit.actionOverrideText;
        this.defaultAlertMessageAction = actionObjEdit.actionDefaultText;
        this.defaultAlertHeaderAction = actionObjEdit.actionDefaultHeader;
        this.alertCustomTextAction = actionObjEdit.actionCustomText;
        this.headerCustomTextAction = actionObjEdit.actionCustomHeader;
    }

    validateTextAction() {
        if (this.isHeaderOverrideEnabledAction === true && this.isAlertEnabledAction === true) {
            this.requiredBoolAction = true;
            let inputText = this.template.querySelector(".headerCustomTextAction");
            let headerCustomHeadervalue = inputText.value;

            if (headerCustomHeadervalue === "") {
                this.isSaveDisabled = true;
                inputText.setCustomValidity(RequiredFieldError);
            } else {
                inputText.setCustomValidity("");
                this.isSaveDisabled = false;
            }
            inputText.reportValidity();
        } else {
            if (this.isHeaderOverrideEnabledAction === false && this.isAlertEnabledAction === true) {
                this.isSaveDisabled = false;
            }
            if (this.isAlertOverrideEnabledAction === false && this.isAlertEnabledAction === true) {
                this.isSaveDisabled = false;
            }

            let inputText = this.template.querySelector(".headerCustomTextAction");
            let tempBool = false;
            if (!inputText.value) {
                /* Setting value to Temp to avoid Value Missing error message */
                inputText.value = "Temp";
                tempBool = true;
            }
            inputText.setCustomValidity("");
            inputText.reportValidity();
            this.requiredBoolAction = false;
            if (tempBool) inputText.value = undefined;
        }

        if (this.isAlertEnabledAction === true && this.isAlertOverrideEnabledAction === true) {
            this.requiredBoolAction = true;
            let inputOverrideText = this.template.querySelector(".handlealertCustomTextAction");

            let headerCustomvalue = inputOverrideText.value;
            if (headerCustomvalue === "") {
                this.isSaveDisabled = true;
                inputOverrideText.setCustomValidity(RequiredFieldError);
            } else {
                inputOverrideText.setCustomValidity("");

                this.isSaveDisabled = false;
            }
            inputOverrideText.reportValidity();
        } else {
            let inputOverrideText = this.template.querySelector(".handlealertCustomTextAction");
            let tempBool = false;
            if (!inputOverrideText.value) {
                /* Setting value to Temp to avoid Value Missing error message */
                inputOverrideText.value = "Temp";
                tempBool = true;
            }
            inputOverrideText.setCustomValidity("");
            inputOverrideText.reportValidity();
            this.requiredBoolAction = false;
            if (tempBool) inputOverrideText.value = undefined;
        }

        if (
            this.isAlertEnabledAction === true &&
            this.isHeaderOverrideEnabledAction === true &&
            this.isAlertOverrideEnabledAction === true
        ) {
            let inputOverrideText = this.template.querySelector(".handlealertCustomTextAction");
            let inputText = this.template.querySelector(".headerCustomTextAction");
            let headerCustomHeadervalue = inputText.value;
            let headerCustomvalue = inputOverrideText.value;
            if (headerCustomvalue === "" || headerCustomHeadervalue === "") {
                this.isSaveDisabled = true;
            }
        }

        this.prepareAlertsDataAction();
    }

    prepareAlertsDataAction() {
        const selectedEvent = new CustomEvent("actionevent", {
            detail: {
                saveDisabled: this.isSaveDisabled,
                alertEnabledAction: this.isAlertEnabledAction,
                overrideHeaderAction: this.isHeaderOverrideEnabledAction,
                overrideTextAction: this.isAlertOverrideEnabledAction,
                defaultHeaderAction: this.defaultAlertHeaderAction,
                defaultTextAction: this.defaultAlertMessageAction,
                customHeaderAction: this.headerCustomTextAction,
                customTextAction: this.alertCustomTextAction
            }
        });
        this.dispatchEvent(selectedEvent);
    }

    // Seller methods
    handleToggleSectionSeller() {
        this.viewCategorySellerAlert = !this.viewCategorySellerAlert;
    }

    handleIsAlertEnabledClickSeller(event) {
        if (event.target.checked === false) {
            this.isAlertEnabledSeller = false;
            this.isHeaderOverrideEnabledSeller = false;
            this.isAlertOverrideEnabledSeller = false;
            this.disableOverrideTextSeller = true;
            this.disableSellerAlertCustomText = true;
        } else {
            this.isAlertEnabledSeller = true;
            this.disableOverrideTextSeller = false;
            this.disableSellerAlertCustomText = false;
        }
        this.validateTextSeller();
    }

    handleIsHeaderOverrideClickSeller(event) {
        if (event.target.checked === false) {
            this.isHeaderOverrideEnabledSeller = false;
        } else {
            this.isHeaderOverrideEnabledSeller = true;
        }
        this.validateTextSeller();
    }

    handleheaderCustomInputsSeller(event) {
        this.headerCustomTextSeller = event.target.value;
        if (this.headerCustomTextSeller.length === 80) {
            this.showMaxLimitErrorHeaderSeller = true;
            this.isSaveDisabled = true;
        } else {
            this.showMaxLimitErrorHeaderSeller = false;
            this.isSaveDisabled = false;
        }
        this.validateTextSeller();
    }

    handleIsAlertOverrideEnabledClickSeller(event) {
        if (event.target.checked === false) {
            this.isAlertOverrideEnabledSeller = false;
        } else {
            this.isAlertOverrideEnabledSeller = true;
        }
        this.validateTextSeller();
    }

    handlealertCustomTextSeller(event) {
        this.alertCustomTextSeller = event.target.value;
        if (this.alertCustomTextSeller.length === 256) {
            this.showMaxLimitErrorAlertSeller = true;
            this.isSaveDisabled = true;
        } else {
            this.showMaxLimitErrorAlertSeller = false;
            this.isSaveDisabled = false;
        }
        this.validateTextSeller();
    }

    @api
    mapSellerDataEdit(sellerObjEdit) {
        this.isAlertEnabledSeller = sellerObjEdit.sellerAlertEnabled;
        this.isHeaderOverrideEnabledSeller = sellerObjEdit.sellerOverrideHeader;
        this.isAlertOverrideEnabledSeller = sellerObjEdit.sellerOverrideText;
        this.defaultAlertMessageSeller = sellerObjEdit.sellerDefaultText;
        this.defaultAlertHeaderSeller = sellerObjEdit.sellerDefaultHeader;
        this.alertCustomTextSeller = sellerObjEdit.sellerCustomText;
        this.headerCustomTextSeller = sellerObjEdit.sellerCustomHeader;
    }

    validateTextSeller() {
        if (this.isHeaderOverrideEnabledSeller === true && this.isAlertEnabledSeller === true) {
            this.requiredBoolSeller = true;
            let inputText = this.template.querySelector(".headerCustomTextSeller");
            let headerCustomHeadervalue = inputText.value;

            if (headerCustomHeadervalue === "") {
                this.isSaveDisabled = true;
                inputText.setCustomValidity(RequiredFieldError);
            } else {
                inputText.setCustomValidity("");
                this.isSaveDisabled = false;
            }
            inputText.reportValidity();
        } else {
            if (this.isHeaderOverrideEnabledSeller === false && this.isAlertEnabledSeller === true) {
                this.isSaveDisabled = false;
            }
            if (this.isAlertOverrideEnabledSeller === false && this.isAlertEnabledSeller === true) {
                this.isSaveDisabled = false;
            }

            let inputText = this.template.querySelector(".headerCustomTextSeller");
            let tempBool = false;
            if (!inputText.value) {
                /* Setting value to Temp to avoid Value Missing error message */
                inputText.value = "Temp";
                tempBool = true;
            }
            inputText.setCustomValidity("");
            inputText.reportValidity();
            this.requiredBoolSeller = false;
            if (tempBool) inputText.value = undefined;
        }

        if (this.isAlertEnabledSeller === true && this.isAlertOverrideEnabledSeller === true) {
            this.requiredBoolSeller = true;
            let inputOverrideText = this.template.querySelector(".handlealertCustomTextSeller");

            let headerCustomvalue = inputOverrideText.value;
            if (headerCustomvalue === "") {
                this.isSaveDisabled = true;
                inputOverrideText.setCustomValidity(RequiredFieldError);
            } else {
                inputOverrideText.setCustomValidity("");

                this.isSaveDisabled = false;
            }
            inputOverrideText.reportValidity();
        } else {
            let inputOverrideText = this.template.querySelector(".handlealertCustomTextSeller");
            let tempBool = false;
            if (!inputOverrideText.value) {
                /* Setting value to Temp to avoid Value Missing error message */
                inputOverrideText.value = "Temp";
                tempBool = true;
            }
            inputOverrideText.setCustomValidity("");
            inputOverrideText.reportValidity();
            this.requiredBoolSeller = false;
            if (tempBool) inputOverrideText.value = undefined;
        }

        if (
            this.isAlertEnabledSeller === true &&
            this.isHeaderOverrideEnabledSeller === true &&
            this.isAlertOverrideEnabledSeller === true
        ) {
            let inputOverrideText = this.template.querySelector(".handlealertCustomTextSeller");
            let inputText = this.template.querySelector(".headerCustomTextSeller");
            let headerCustomHeadervalue = inputText.value;
            let headerCustomvalue = inputOverrideText.value;
            if (headerCustomvalue === "" || headerCustomHeadervalue === "") {
                this.isSaveDisabled = true;
            }
        }

        this.prepareAlertsDataSeller();
    }

    prepareAlertsDataSeller() {
        const selectedEvent = new CustomEvent("sellerevent", {
            detail: {
                saveDisabled: this.isSaveDisabled,
                alertEnabledSlr: this.isAlertEnabledSeller,
                overrideHeaderSlr: this.isHeaderOverrideEnabledSeller,
                overrideTextSlr: this.isAlertOverrideEnabledSeller,
                defaultHeaderSlr: this.defaultAlertHeaderSeller,
                defaultTextSlr: this.defaultAlertMessageSeller,
                customHeaderSlr: this.headerCustomTextSeller,
                customTextSlr: this.alertCustomTextSeller
            }
        });
        this.dispatchEvent(selectedEvent);
    }

    // Manager methods
    handleToggleSectionMngr() {
        this.viewCategoryMngrAlert = !this.viewCategoryMngrAlert;
    }

    handleIsAlertEnabledClickMngr(event) {
        if (event.target.checked === false) {
            this.isAlertEnabledMngr = false;
            this.isHeaderOverrideEnabledMngr = false;
            this.isAlertOverrideEnabledMngr = false;
            this.disableOverrideTextMngr = true;
            this.disableMngrAlertCustomText = true;
        } else {
            this.isAlertEnabledMngr = true;
            this.disableOverrideTextMngr = false;
            this.disableMngrAlertCustomText = false;
        }
        this.validateTextMngr();
    }

    handleIsHeaderOverrideClickMngr(event) {
        if (event.target.checked === false) {
            this.isHeaderOverrideEnabledMngr = false;
        } else {
            this.isHeaderOverrideEnabledMngr = true;
        }
        this.validateTextMngr();
    }

    handleheaderCustomInputsMngr(event) {
        this.headerCustomTextMngr = event.target.value;
        if (this.headerCustomTextMngr.length === 80) {
            this.showMaxLimitErrorHeaderMngr = true;
            this.isSaveDisabled = true;
        } else {
            this.showMaxLimitErrorHeaderMngr = false;
            this.isSaveDisabled = false;
        }
        this.validateTextMngr();
    }

    handleIsAlertOverrideEnabledClickMngr(event) {
        if (event.target.checked === false) {
            this.isAlertOverrideEnabledMngr = false;
        } else {
            this.isAlertOverrideEnabledMngr = true;
        }
        this.validateTextMngr();
    }

    handlealertCustomTextMngr(event) {
        this.alertCustomTextMngr = event.target.value;
        if (this.alertCustomTextMngr.length === 256) {
            this.showMaxLimitErrorAlertMngr = true;
            this.isSaveDisabled = true;
        } else {
            this.showMaxLimitErrorAlertMngr = false;
            this.isSaveDisabled = false;
        }
        this.validateTextMngr();
    }

    @api
    mapMngrDataEdit(mngrObjEdit) {
        this.isAlertEnabledMngr = mngrObjEdit.mngrAlertEnabled;
        this.isHeaderOverrideEnabledMngr = mngrObjEdit.mngrOverrideHeader;
        this.isAlertOverrideEnabledMngr = mngrObjEdit.mngrOverrideText;
        this.defaultAlertMessageMngr = mngrObjEdit.mngrDefaultText;
        this.defaultAlertHeaderMngr = mngrObjEdit.mngrDefaultHeader;
        this.alertCustomTextMngr = mngrObjEdit.mngrCustomText;
        this.headerCustomTextMngr = mngrObjEdit.mngrCustomHeader;
    }

    validateTextMngr() {
        if (this.isHeaderOverrideEnabledMngr === true && this.isAlertEnabledMngr === true) {
            this.requiredBoolMngr = true;
            let inputText = this.template.querySelector(".headerCustomTextMngr");
            let headerCustomHeadervalue = inputText.value;

            if (headerCustomHeadervalue === "") {
                this.isSaveDisabled = true;
                inputText.setCustomValidity(RequiredFieldError);
            } else {
                inputText.setCustomValidity("");
                this.isSaveDisabled = false;
            }
            inputText.reportValidity();
        } else {
            if (this.isHeaderOverrideEnabledMngr === false && this.isAlertEnabledMngr === true) {
                this.isSaveDisabled = false;
            }
            if (this.isAlertOverrideEnabledMngr === false && this.isAlertEnabledMngr === true) {
                this.isSaveDisabled = false;
            }

            let inputText = this.template.querySelector(".headerCustomTextMngr");
            let tempBool = false;
            if (!inputText.value) {
                /* Setting value to Temp to avoid Value Missing error message */
                inputText.value = "Temp";
                tempBool = true;
            }
            inputText.setCustomValidity("");
            inputText.reportValidity();
            this.requiredBoolMngr = false;
            if (tempBool) inputText.value = undefined;
        }

        if (this.isAlertEnabledMngr === true && this.isAlertOverrideEnabledMngr === true) {
            this.requiredBoolMngr = true;
            let inputOverrideText = this.template.querySelector(".handlealertCustomTextMngr");

            let headerCustomvalue = inputOverrideText.value;
            if (headerCustomvalue === "") {
                this.isSaveDisabled = true;
                inputOverrideText.setCustomValidity(RequiredFieldError);
            } else {
                inputOverrideText.setCustomValidity("");

                this.isSaveDisabled = false;
            }
            inputOverrideText.reportValidity();
        } else {
            let inputOverrideText = this.template.querySelector(".handlealertCustomTextMngr");
            let tempBool = false;
            if (!inputOverrideText.value) {
                /* Setting value to Temp to avoid Value Missing error message */
                inputOverrideText.value = "Temp";
                tempBool = true;
            }
            inputOverrideText.setCustomValidity("");
            inputOverrideText.reportValidity();
            this.requiredBoolMngr = false;
            if (tempBool) inputOverrideText.value = undefined;
        }

        if (
            this.isAlertEnabledMngr === true &&
            this.isHeaderOverrideEnabledMngr === true &&
            this.isAlertOverrideEnabledMngr === true
        ) {
            let inputOverrideText = this.template.querySelector(".handlealertCustomTextMngr");
            let inputText = this.template.querySelector(".headerCustomTextMngr");
            let headerCustomHeadervalue = inputText.value;
            let headerCustomvalue = inputOverrideText.value;
            if (headerCustomvalue === "" || headerCustomHeadervalue === "") {
                this.isSaveDisabled = true;
            }
        }

        this.prepareAlertsDataMngr();
    }

    prepareAlertsDataMngr() {
        const selectedEvent = new CustomEvent("mngrevent", {
            detail: {
                saveDisabled: this.isSaveDisabled,
                alertEnabledMngr: this.isAlertEnabledMngr,
                overrideHeaderMngr: this.isHeaderOverrideEnabledMngr,
                overrideTextMngr: this.isAlertOverrideEnabledMngr,
                defaultHeaderMngr: this.defaultAlertHeaderMngr,
                defaultTextMngr: this.defaultAlertMessageMngr,
                customHeaderMngr: this.headerCustomTextMngr,
                customTextMngr: this.alertCustomTextMngr
            }
        });
        this.dispatchEvent(selectedEvent);
    }
}