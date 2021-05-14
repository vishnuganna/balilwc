import { LightningElement, api } from "lwc";
import searchCompetitior from "@salesforce/label/c.searchCompetitior";

export default class lookupComponent extends LightningElement {
    @api childObjectApiName; //= 'Account'; //Contact is the default value
    @api targetFieldApiName; //= 'Name'; //AccountId is the default value
    @api fieldLabel;

    @api disabled = false;
    @api value;
    @api required = false;
    @api showRequiredStar;

    label = {
        searchCompetitior
    };

    handleChange(event) {
        // Creates the event
        const selectedEvent = new CustomEvent("valueselected", {
            detail: event.target.value
        });
        //dispatching the custom event
        this.dispatchEvent(selectedEvent);
    }

    @api isValid() {
        if (this.required) {
            this.template.querySelector("lightning-input-field").reportValidity();
        }
    }
}