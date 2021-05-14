import { LightningElement, api, track } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import createGreenSheet from "@salesforce/apex/GreenSheetNavigate.createGreenSheet";
import ProgressNavigationWidgetMessageGreen from "@salesforce/label/c.Progress_Navigation_Widget_Message_Green";
import GreensheetSheetErrorCreate from "@salesforce/label/c.GreensheetSheetErrorCreate";
import GreenSheetNoAccessErrorMsg from "@salesforce/label/c.GreenSheetNoAccessErrorMsg";

export default class GreenSheetNavigate extends NavigationMixin(LightningElement) {
    @api recordId;
    @api objectApiName;
    @api greensheetId;
    @track isGSCreatePermission = false;
    @track isGSAccessError = false;

    label = {
        ProgressNavigationWidgetMessageGreen,
        GreenSheetNoAccessErrorMsg,
        GreensheetSheetErrorCreate //KFS-2766
    };

    connectedCallback() {
        createGreenSheet({ taskId: this.recordId })
            .then(result => {
                if (result === null) {
                    this.isGSCreatePermission = true;
                } else {
                    if (result === "NoGSAccess") {
                        this.isGSAccessError = true;
                    } else {
                        this.greensheetId = result;
                        this.navigateToViewGSPage();
                    }
                }
            })
            .catch(error => {
                let errorAccess = error.body.message;
                if (errorAccess.includes("You do not have access to the Apex class named")) {
                    this.isGSAccessError = true;
                } else {
                    this.isGSAccessError = false;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: this.label.GreensheetSheetErrorCreate, //KFS-2766
                            message: error.body.message,
                            variant: "error"
                        })
                    );
                }
            });
    }

    navigateToViewGSPage() {
        this[NavigationMixin.Navigate]({
            type: "standard__recordPage",
            attributes: {
                recordId: this.greensheetId,
                objectApiName: "Green_Sheet__c",
                actionName: "view"
            }
        });
    }
}