import { LightningElement, api, track, wire } from "lwc";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import { NavigationMixin } from "lightning/navigation";
import createBlueSheet from "@salesforce/apex/StrategyEngine.createBlueSheet";
//import Complete_Single_Sales_Objective from "@salesforce/label/c.Complete_Single_Sales_Objective";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import Progress_Navigation_Widget_Massage from "@salesforce/label/c.Progress_Navigation_Widget_Massage";
import BlueSheetNoAccessErrorMsg from "@salesforce/label/c.BlueSheetNoAccessErrorMsg";
import BLUESHEET_OBJECT from "@salesforce/schema/Blue_Sheet__c";
import BlueSheetErrorCreate from "@salesforce/label/c.BlueSheetErrorCreate";

export default class BluesheetNavigate extends NavigationMixin(LightningElement) {
    @api recordId;
    @api objectApiName;
    @api bluesheetId;
    @track isBSCreatePermission = false;
    @track isBSAccessError = false;

    @wire(getObjectInfo, { objectApiName: BLUESHEET_OBJECT })
    Function({ error, data }) {
        if (data) {
            createBlueSheet({ opptyId: this.recordId })
                .then(result => {
                    this.opportunityId = this.recordId;
                    if (result === "") {
                        this.isBSCreatePermission = true;
                    } else {
                        if (result === "NoBSAccess") {
                            this.isBSAccessError = true;
                        } else {
                            this.isBSAccessError = false;
                            this.bluesheetId = result;
                            this.navigateToViewBSPage();
                        }
                    }
                })
                .catch(err => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: this.label.BlueSheetErrorCreate,
                            message: err.body.message,
                            variant: "error"
                        })
                    );
                });
            // perform your custom logic here
        } else if (error) {
            if (error.status === 403) {
                this.isBSAccessError = true;
            }
        }
    }

    label = {
        Progress_Navigation_Widget_Massage,
        BlueSheetNoAccessErrorMsg,
        BlueSheetErrorCreate
    };

    connectedCallback() {
        window.addEventListener(
            "popstate",
            function() {
                // The popstate event is fired each time when the current history entry changes.
                window.location.reload();
            },
            false
        );
    }

    // Navigate to View Blue Sheet Page
    navigateToViewBSPage() {
        this[NavigationMixin.Navigate]({
            type: "standard__recordPage",
            attributes: {
                recordId: this.bluesheetId,
                objectApiName: "Blue_Sheet__c",
                actionName: "view"
            }
        });
    }
}