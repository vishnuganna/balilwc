import { LightningElement, track } from "lwc";
import getSetOfReportees from "@salesforce/apex/Landing.getSetOfReportees";
import checkIfLoggedUserIsManager from "@salesforce/apex/Landing.checkIfLoggedUserIsManager";
import getreportLinkMap from "@salesforce/apex/Landing.getreportLinkMap";
import FOP_Gold_Sheet from "@salesforce/label/c.FOP_Gold_Sheet";

export default class KFSellLanding extends LightningElement {
    @track reporteeList;
    @track showUI = false;
    @track isUserManager;
    @track reportName;
    @track reportList;
    allLabels = {
        FOP_Gold_Sheet
    };
    connectedCallback() {
        getSetOfReportees().then(result => {
            this.reporteeList = result;
        });
        checkIfLoggedUserIsManager()
            .then(result => {
                this.isUserManager = result;
                if (this.isUserManager === "Manager") {
                    this.reportName = "KFS_Landing_Owner";
                } else {
                    this.reportName = "KFS_Landing_NoOwner";
                }
            })
            .then(() => {
                getreportLinkMap({ reportName: this.reportName }).then(result => {
                    this.reportList = result;
                    this.showUI = true;
                });
            });
    }
}