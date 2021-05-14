import { LightningElement, api } from "lwc";

export default class LookUpBi extends LightningElement {
    @api childObjectApiName; //= 'Account'; //Contact is the default value
    @api targetFieldApiName; //= 'Name'; //AccountId is the default value
    //@api fieldLabel = 'Name';

    @api childObject = "Account"; //Contact is the default value
    @api targetField = "Name"; //AccountId is the default value

    @api disabled = false;
    @api value;
    @api required = false;

    connectedCallback() {
        // alert(this.childObject);
        // alert(this.targetField);
    }

    handleChange(event) {
        // Creates the event
        //alert('event.detail.value----'+event.target.value);
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