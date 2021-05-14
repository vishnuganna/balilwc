import { LightningElement, api, track } from "lwc";

export default class RecordList extends LightningElement {
    @api record;
    @api fieldname;
    @api iconname;
    @track accountName;
    @track spanclass = "";

    connectedCallback() {
        if (this.record.Account === undefined) {
            this.accountName = " ";
            this.spanclass = "slds-media__figure slds-listbox__option-icon";
        } else {
            this.accountName = this.record.Account.Name;
            this.spanclass = "slds-media__figure slds-listbox__option-icon slds-p-top_small";
        }
    }

    handleSelect(event) {
        event.preventDefault();
        const selectedRecord = new CustomEvent("select", {
            detail: this.record.Id
        });
        /* eslint-disable no-console */
        // console.log(this.record.Id);
        /* fire the event to be handled on the Parent Component */
        this.dispatchEvent(selectedRecord);
    }
}