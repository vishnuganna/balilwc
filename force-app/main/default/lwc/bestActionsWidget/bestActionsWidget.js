import { LightningElement, api, track } from "lwc";
import getBestActionData from "@salesforce/apex/BestAction.getBestActionList";
//import getExistingBestActionId from "@salesforce/apex/BestAction.getBestActionList";
import best_action_widget_header_bg from "@salesforce/resourceUrl/best_action_widget_header_bg";
import kf_sell_logo from "@salesforce/resourceUrl/kf_sell_logo";
import KFSellActions from "@salesforce/label/c.KFSellActions";
import ActNow from "@salesforce/label/c.ActNow";
import NoPendingActions from "@salesforce/label/c.NoPendingActions";
import { NavigationMixin } from "lightning/navigation";
import getBlueSheetId from "@salesforce/apex/BestAction.getBlueSheetId";
import getNamespaceWithUnderScores from "@salesforce/apex/Util.getNamespaceWithUnderScores";
import pubsub from "c/pubSub";
import createBlueSheet from "@salesforce/apex/StrategyEngine.createBlueSheet";
import accessCheck from "@salesforce/apex/BestAction.getBlueSheetAccess";
import greenSheetAccessCheck from "@salesforce/apex/BestAction.getGreenSheetAccess";
import Warning from "@salesforce/label/c.Warning";
import HereAQuickRefresher from "@salesforce/label/c.HereAQuickRefresher";

export default class BestActionsWidget extends NavigationMixin(LightningElement) {
    label = {
        KFSellActions,
        ActNow,
        NoPendingActions,
        Warning,
        HereAQuickRefresher
    };

    @track showDataFlag = true;
    @track bestActionData;
    @track noDataFlag = false;
    @api best_action_widget_header_bg = best_action_widget_header_bg;
    @api kf_sell_logo = kf_sell_logo;
    @api recordId;
    @api bluesheetId;
    @track namespaceVar;
    @track scrollToCard;
    @track greenSheetId;
    @track isCreateable = false;
    @track isGreenSheetCreateable = false;

    handleToggleSection() {
        this.showDataFlag = !this.showDataFlag;
    }

    connectedCallback() {
        this.regiser();
        getBestActionData({ oppId: this.recordId })
            .then(result => {
                this.bestActionData = result;
                if (result.length === 0) {
                    this.noDataFlag = true;
                }
            })
            .catch(error => {
                // eslint-disable-next-line no-console
                console.log(JSON.stringify(error));
            });

        getNamespaceWithUnderScores()
            .then(result => {
                if (result === "") {
                    this.namespaceVar = "c__propertyValue";
                } else {
                    this.namespaceVar = result + "propertyValue";
                }
            })
            .catch(error => {
                // eslint-disable-next-line no-console
                console.log(JSON.stringify(error));
            });

        accessCheck().then(result => {
            this.isCreateable = result.isCreateable;
        });
        greenSheetAccessCheck().then(result => {
            this.isGreenSheetCreateable = result.isCreateable;
        });
    }
    navigateToGreenSheet(event) {
        let propVar = this.namespaceVar;
        this.greenSheetId = event.target.value;
        this[NavigationMixin.Navigate]({
            type: "standard__recordPage",
            attributes: {
                recordId: this.greenSheetId,
                objectApiName: propVar + "Green_Sheet__c",
                actionName: "view"
            }
        });
    }
    navigateToBss(event) {
        this.scrollToCard = event.target.value;

        if (this.scrollToCard === "") {
            createBlueSheet({ opptyId: this.recordId })
                .then(result => {
                    this.blueSheetId = result;
                    this[NavigationMixin.Navigate]({
                        type: "standard__recordPage",
                        attributes: {
                            recordId: this.blueSheetId,
                            objectApiName: "Blue_Sheet__c",
                            actionName: "view"
                        }
                    });
                })
                .catch(() => {
                    // alert('Error getIsRecordExists' +JSON.stringify(error));
                });
        } else {
            getBlueSheetId({ oppId: this.recordId })
                .then(result => {
                    let propVar = this.namespaceVar;
                    this.blueSheetId = result;
                    this.recordId = result;
                    this[NavigationMixin.Navigate]({
                        type: "standard__webPage",
                        attributes: {
                            url:
                                "/lightning/r/Blue_Sheet__c/" +
                                this.blueSheetId +
                                "/view?" +
                                propVar +
                                "=" +
                                this.scrollToCard
                        }
                    });
                })
                .catch(() => {
                    // alert('Error getIsRecordExists' +JSON.stringify(error));
                });
        }
    }

    regiser() {
        pubsub.register("refreshBestActionGrid", this.handleEvent.bind(this));
    }
    handleEvent(messageFromEvt) {
        this.message = messageFromEvt ? JSON.stringify(messageFromEvt, null, "\t") : "no message payload";
        getBestActionData({ oppId: this.recordId })
            .then(result => {
                this.bestActionData = result;
                if (result.length === 0) {
                    this.noDataFlag = true;
                } else {
                    this.noDataFlag = false;
                }
            })
            .catch(error => {
                // eslint-disable-next-line no-console
                console.log(JSON.stringify(error));
            });
    }
}