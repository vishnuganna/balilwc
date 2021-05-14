import { LightningElement, api, track } from "lwc";
import getOppId from "@salesforce/apex/StrategyEngine.getOppId";
import { NavigationMixin } from "lightning/navigation";
import exportToPdf from "@salesforce/label/c.exportToPdf";
import getNamespaceWithUnderScores from "@salesforce/apex/Util.getNamespaceWithUnderScores";
import getBlueSheetAndSelfGuidedJourneyAcess from "@salesforce/apex/BlueSheetStatus.getBlueSheetAndSelfGuidedJourneyAcess";
import Overview from "@salesforce/label/c.Overview";
import BlueSheetLabel from "@salesforce/label/c.BlueSheetLabel";
import ReturntoLearning from "@salesforce/label/c.ReturntoLearning";
import pubsub from "c/pubSub";

export default class BlueSheet extends NavigationMixin(LightningElement) {
    @api recordId;
    @api oppId;
    namespaceVar = "baseA4";
    @track isCreateable = false;
    labels = {
        ReturntoLearning,
        exportToPdf,
        Overview,
        BlueSheetLabel
    };

    connectedCallback() {
        this.checkBSAccess();
        getNamespaceWithUnderScores()
            .then(result => {
                if (result !== "") {
                    this.namespaceVar = result + this.namespaceVar;
                }
            })
            .catch(error => {
                // eslint-disable-next-line no-console
                console.log(JSON.stringify(error));
            });
    }

    navigateToOpp() {
        getOppId({ blueSheetId: this.recordId }).then(result => {
            this.oppId = result;
            this[NavigationMixin.Navigate]({
                type: "standard__recordPage",
                attributes: {
                    recordId: this.oppId,
                    objectApiName: "Opportunity",
                    actionName: "view"
                }
            });
        });
    }

    checkBSAccess() {
        getBlueSheetAndSelfGuidedJourneyAcess().then(result => {
            this.isCreateable = result;
        });
    }
    openLearningPage() {
        pubsub.fire("returnToLearning", "returnToLearning");
    }

    exportToPdf() {
        let pdfUrl = "/apex/" + this.namespaceVar + "?id=" + this.recordId + "&download=true";

        let downloadElement = document.createElement("a");
        // This  encodeURI encodes special characters, except: , / ? : @ & = + $ # (Use encodeURIComponent() to encode these characters).
        downloadElement.href = pdfUrl;
        downloadElement.target = "_self";
        // CSV File Name
        downloadElement.download = "bluesheet.csv";
        // below statement is required if you are using firefox browser
        document.body.appendChild(downloadElement);
        // click() Javascript function to download CSV file
        downloadElement.click();
    }
}