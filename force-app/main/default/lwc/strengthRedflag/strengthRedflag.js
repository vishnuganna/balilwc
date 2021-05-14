import { LightningElement, api, track } from "lwc";

export default class StrengthRedflag extends LightningElement {
    isredflagFalse = true;
    isStrengthFalse = true;
    isredflagTrue = false;
    isStrengthTrue = false;

    // putting getters and setters in place for tracking parent value changes,
    @api
    get rfsData() {
        return this._rfsData;
    }

    set rfsData(value) {
        this.setAttribute("rfsData", value);
        this._rfsData = value;
        this.setUp();
    }

    @track _rfsData;

    fieldApiName;
    @api readOnlyView = false;

    connectedCallback() {
        this.setUp();
    }

    setUp() {
        const currentRfsData = this.rfsData;
        if (this.rfsData) {
            this.isredflagTrue = currentRfsData.redFlagSelected;
            this.isStrengthTrue = currentRfsData.strengthSelected;
            this.isredflagFalse = !this.isredflagTrue;
            this.isStrengthFalse = !this.isStrengthTrue;
            this.fieldApiName = currentRfsData.fieldApiName;
        }
    }

    @api showRedFlag() {
        this.isredflagTrue = true;
        this.isStrengthFalse = true;
        this.isredflagFalse = false;
        this.isStrengthTrue = false;
        this.dispatchEventToParent();
    }

    @api hideRedFlag() {
        this.isredflagFalse = true;
        this.isredflagTrue = false;
        this.isStrengthTrue = false;
        this.isStrengthFalse = true;
        this.dispatchEventToParent();
    }

    @api showBarbell() {
        this.isStrengthTrue = true;
        this.isredflagTrue = false;
        this.isredflagFalse = true;
        this.isStrengthFalse = false;
        this.dispatchEventToParent();
    }

    @api hideBarbell() {
        this.isStrengthFalse = true;
        this.isStrengthTrue = false;
        this.isredflagFalse = true;
        this.isredflagTrue = false;
        this.dispatchEventToParent();
    }

    dispatchEventToParent() {
        const selectedEvent = new CustomEvent("valueselected", {
            detail: {
                redFlagSelected: this.isredflagTrue,
                strengthSelected: this.isStrengthTrue,
                noneSelected: !this.isredflagTrue && !this.isStrengthTrue,
                fieldApiName: this.fieldApiName
            }
        });
        this.dispatchEvent(selectedEvent);
    }
}