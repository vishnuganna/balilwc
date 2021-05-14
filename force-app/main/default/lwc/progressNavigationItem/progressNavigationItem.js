import { LightningElement, api, track } from "lwc";
import { NavigationMixin } from "lightning/navigation"; //230
import Error from "@salesforce/label/c.Error";
import InfoAlt from "@salesforce/label/c.InfoAlt";
import ClickToearn from "@salesforce/label/c.ClickToearn";

export default class ProgressNavigationItem extends NavigationMixin(LightningElement) {
    @track _itemProgress;
    @track _labelItemProgress;

    @track _itemName;
    @track _labelItemName;
    @api showcustomInsights = false;
    @api showonBS = false;
    @track _expandMenu;
    @track utilName;
    @track variantName;
    @track navURL;
    @track itemProgressinfo;
    @api notStartedStatusinfo;
    @api inProgressStatusinfo;
    @api completedStatusinfo;
    @api notStartedNavigationUrl;
    @api inProgressNavigationUrl;
    @api classForAnchor;
    @track _getIdFromParent;
    @track checkProgessIsComplete = false;
    @track _insightcategory;

    allLabels = {
        Error,
        InfoAlt,
        ClickToearn
    };

    @api
    get itemProgress() {
        return this._itemProgress;
    }

    set itemProgress(value) {
        this.setAttribute("itemProgress", value);
        this._itemProgress = value;
        this.progressRender();
    }

    @api
    get labelItemProgress() {
        return this._labelItemProgress;
    }

    set labelItemProgress(value) {
        this.setAttribute("labelItemProgress", value);
        this._labelItemProgress = value;
    }

    @api
    get labelItemName() {
        return this._labelItemName;
    }

    set labelItemName(value) {
        this.setAttribute("labelItemName", value);
        this._labelItemName = value;
    }

    @api
    get expandMenu() {
        return this._expandMenu;
    }

    set expandMenu(value) {
        this.setAttribute("expandMenu", value);
        this._expandMenu = value;
    }

    @api
    get getIdFromParent() {
        return this._getIdFromParent;
    }

    set getIdFromParent(value) {
        this._getIdFromParent = value;
    }

    @api
    get insightCategory() {
        return this._insightcategory;
    }

    set insightCategory(value) {
        this._insightcategory = value;
    }

    connectedCallback() {
        this.progressRender();
    }

    handleClickItem(event) {
        let linkName = event.currentTarget.dataset.class.replace("link", "anchor");
        const selectedEvent = new CustomEvent("scrolltocomponent", {
            detail: linkName
        });
        this.dispatchEvent(selectedEvent);
    }

    progressRender() {
        if (this.itemProgress === "Not Started") {
            this.checkProgessIsComplete = true;
            this.utilName = "utility:ban";
            this.variantName = "error";
            this.itemProgressinfo = this.notStartedStatusinfo;
            this.navURL = this.notStartedNavigationUrl;
            this.checkProgessIsComplete = true;
        } else if (this.itemProgress === "In Progress") {
            this.checkProgessIsComplete = true;
            this.utilName = "utility:success";
            this.variantName = "warning";
            this.itemProgressinfo = this.inProgressStatusinfo;
            this.navURL = this.inProgressNavigationUrl;
            this.checkProgessIsComplete = true;
        } else if (this.itemProgress === "Complete") {
            this.checkProgessIsComplete = false;
            this.utilName = "utility:success";
            this.variantName = "success";
            this.itemProgressinfo = this.completedStatusinfo;
        }
    }

    navigateToWebPageMyposition() {
        this[NavigationMixin.Navigate]({
            type: "standard__webPage",
            attributes: {
                url: this.navURL
            }
        });
    }
}