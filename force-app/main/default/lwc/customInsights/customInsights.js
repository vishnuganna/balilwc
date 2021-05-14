import { LightningElement, api, track } from "lwc";
import Insights from "@salesforce/label/c.Insights";
import Link_to_Document from "@salesforce/label/c.Link_to_Document";
import getInsights from "@salesforce/apex/InsightsAlertRecommendations.getInsights";
import categoryCompetitor from "@salesforce/label/c.CategoryCompetitor";
import categoryPerspective from "@salesforce/label/c.CategoryPerspective";
import pubsub from "c/pubSub";

export default class CustomInsights extends LightningElement {
    @api showonBs = false;
    @track hasInsightAlertData = false;
    @track _getIdFromParent;
    @track _type;
    @track blueSheetId;
    @track insightAlertData = [];
    @api ruleCategory;
    @api categoryComp;
    @api categoryPersp;
    @track showActionInsight;
    @track displayInsight = false;
    @api
    get getIdFromParent() {
        return this._getIdFromParent;
    }

    set getIdFromParent(value) {
        this._getIdFromParent = value;
    }

    @api
    get showActionInsight() {
        return this._showActionInsight;
    }

    set showActionInsight(value) {
        this._showActionInsight = value;
    }

    @api
    get type() {
        return this._type;
    }

    set type(value) {
        this._type = value;
        if (this.type === this.label.categoryCompetitor) {
            this.categoryComp = true;
            this.categoryPersp = false;
        } else if (this.type === this.label.categoryPerspective) {
            this.categoryPersp = true;
            this.categoryComp = false;
        }
    }

    label = {
        Insights,
        Link_to_Document,
        categoryCompetitor,
        categoryPerspective
    };

    connectedCallback() {
        this.register();
        if (this.type === this.label.categoryCompetitor) {
            this.getBSInsightAlerts();
        } else if (this.type === this.label.categoryPerspective) {
            this.getBSInsightAlertsPersPective();
        }
    }

    @api
    handleRefresh() {
        if (this.type === this.label.categoryCompetitor) {
            this.getBSInsightAlerts();
        } else if (this.type === this.label.categoryPerspective) {
            this.getBSInsightAlertsPersPective();
        }
    }

    register() {
        if (this.type === this.label.categoryCompetitor) {
            pubsub.register("refreshCustomInsights", this.handleEvent.bind(this));
        } else if (this.type === this.label.categoryPerspective) {
            pubsub.register("refreshPersCustomInsights", this.handleEvent.bind(this));
        }
    }

    handleEvent(messageFromEvt) {
        this.showActionInsight = messageFromEvt.showActionInsight;
        this.message = messageFromEvt ? JSON.stringify(messageFromEvt, null, "\t") : "no message payload";
        this.handleRefresh();
    }

    getBSInsightAlerts() {
        this.insightAlertData = null;
        getInsights({ bluesheetId: this.getIdFromParent, ruleCategory: this.label.categoryCompetitor })
            .then(result => {
                this.insightAlertData = result;
                if (!this.insightAlertData.length) {
                    this.hasInsightAlertData = false;
                    this.displayInsight = false;
                } else {
                    this.hasInsightAlertData = true;
                    this.displayInsight = true;
                }
            })
            .catch(() => {
                this.Result = undefined;
            });
    }

    getBSInsightAlertsPersPective() {
        this.displayInsight = this.showActionInsight;
        this.getBSInsightAlertsPersPectiveData();
    }

    getBSInsightAlertsPersPectiveData() {
        getInsights({ bluesheetId: this.getIdFromParent, ruleCategory: this.label.categoryPerspective })
            .then(result => {
                this.insightAlertData = result;
                if (this.insightAlertData.length > 0) {
                    this.hasInsightAlertData = true;
                    this.displayInsight = this.showActionInsight ? true : false;
                } else {
                    this.hasInsightAlertData = false;
                    this.displayInsight = false;
                }
            })
            .catch(() => {});
    }
}