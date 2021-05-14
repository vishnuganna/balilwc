import { LightningElement, api, track } from "lwc";
import showLess from "@salesforce/label/c.showLess";
import showMore from "@salesforce/label/c.showMore";

export default class ShowMoreShowLess extends LightningElement {
    // putting getters and setters in place for tracking parent value changes,
    @api
    get textDisplay() {
        return this._textDisplay;
    }

    set textDisplay(value) {
        this.setAttribute("textDisplay", value);
        this._textDisplay = value;
        this.handleshowMoreless();
    }

    @track _textDisplay;

    @track showLessTextDisplay = "";
    @track showMoreTextDisplay = "";

    @track ShowMoreText = false;
    @track showText = false;

    label = {
        showLess,
        showMore
    };

    connectedCallback() {
        this.handleshowMoreless();
    }

    handleShowMore() {
        this.showText = true;
        this.ShowMoreText = false;
        this.ShowLessText = true;
    }

    handleShowLess() {
        this.showText = false;
        this.ShowLessText = false;
        this.ShowMoreText = true;
        if (this.template.querySelector(".scrollPosition") != null) {
            this.template
                .querySelector(".scrollPosition")
                .scrollIntoView({ behavior: "auto", block: "start", inline: "start" });
            // now account for fixed header
            let scrolledY = window.scrollY;

            if (scrolledY) {
                window.scroll(0, scrolledY - 300);
            }
        }
    }

    handleshowMoreless() {
        if (this.textDisplay) {
            if (this.textDisplay.length > 100) {
                this.showLessTextDisplay = "";
                this.showMoreTextDisplay = "";
                this.showLessTextDisplay = this.textDisplay.substr(0, 100);
                this.showMoreTextDisplay = this.textDisplay.substr(100, this.textDisplay.length);
                this.ShowMoreText = true;
            } else {
                this.showLessTextDisplay = this.textDisplay;
                this.showMoreTextDisplay = "";
                this.ShowMoreText = false;
                this.ShowLessText = false;
            }
        }
    }
}