import { LightningElement, track, wire, api } from "lwc";

import getAccounts from "@salesforce/apex/LookUpController.getContacts";
import Contact from "@salesforce/label/c.Contact";
import SelectOption from "@salesforce/label/c.SelectOption";
import RemoveSelectedOption from "@salesforce/label/c.RemoveSelectedOption";
import close from "@salesforce/label/c.close";
import Approved from "@salesforce/label/c.Approved";
const DELAY = 300;

export default class LookUp extends LightningElement {
    @api conid;

    @track search = "";
    @track error;

    @track selectedContact;
    @track selectedContactId;
    @track showAccountsListFlag = false;

    @wire(getAccounts, { searchText: "$search" })
    accounts;

    label = {
        Contact,
        SelectOption,
        RemoveSelectedOption,
        close,
        Approved
    };

    handleKeyUp(event) {
        if (!this.showAccountsListFlag) {
            this.showAccountsListFlag = true;
            this.template.querySelector(".accounts_list").classList.remove("slds-hide");
        }
        window.clearTimeout(this.delayTimeout);
        const searchKey = event.target.value;
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.delayTimeout = setTimeout(() => {
            this.search = searchKey;
        }, DELAY);
    }

    handleOptionSelect(event) {
        this.selectedContact = event.currentTarget.dataset.name;
        this.selectedContactId = event.currentTarget.dataset.id;
        this.template.querySelector(".selectedOption").classList.remove("slds-hide");
        this.template.querySelector(".accounts_list").classList.add("slds-hide");
        this.template.querySelector(".slds-combobox__form-element").classList.add("slds-input-has-border_padding");

        const contactId = new CustomEvent("conid", {
            detail: this.selectedContactId
        });

        // Dispatches the event.
        this.dispatchEvent(contactId);
    }

    handleRemoveSelectedOption() {
        this.template.querySelector(".selectedOption").classList.add("slds-hide");
        this.template.querySelector(".slds-combobox__form-element").classList.remove("slds-input-has-border_padding");
        this.search = "";
        this.showAccountsListFlag = false;
    }
}