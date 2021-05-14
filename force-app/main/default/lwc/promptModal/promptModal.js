import { LightningElement, api } from "lwc";
import close from "@salesforce/label/c.close";

export default class PromptModal extends LightningElement {
    @api headerLabel;
    @api bodyMsg;
    @api positiveResponseButton;
    @api negativeResponseButton;
    @api closeLabel;

    allLabels = {
        close
    };

    handlePositiveResponse() {
        const selectedEvent = new CustomEvent("positiveresponse", {
            detail: true
        });

        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
    }
    handleNegativeResponse() {
        const selectedEvent = new CustomEvent("negativeresponse", {
            detail: true
        });

        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
    }
    closeModal() {
        const selectedEvent = new CustomEvent("negativeresponse", {
            detail: true
        });

        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
    }
}