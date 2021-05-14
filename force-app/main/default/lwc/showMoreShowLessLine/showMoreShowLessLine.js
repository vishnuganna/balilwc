import { LightningElement, track, api } from "lwc";
import showLess from "@salesforce/label/c.showLess";
import showMore from "@salesforce/label/c.showMore";

export default class ShowMoreShowLessLine extends LightningElement {
    @track isShowMoreExist = false;
    @api description;
    @api noOfLines;
    descriptionField;

    label = {
        showLess,
        showMore
    };

    renderedCallback() {
        this.descriptionField = this.template.querySelector(".showdesc");
        if (this.descriptionField) {
            const divHeight = this.descriptionField.offsetHeight;
            const style = window.getComputedStyle(this.descriptionField);
            const lineHeight = parseInt(style.getPropertyValue("line-height"), 10);

            const existingNoOfLines = divHeight / lineHeight;

            //hanlde undefined scenario
            this.noOfLines = this.noOfLines ? this.noOfLines : 5;

            if (existingNoOfLines < this.noOfLines) {
                this.isShowMoreExist = false;
            } else {
                this.isShowMoreExist = true;
                this.descriptionField.style.webkitLineClamp = this.noOfLines;
            }
        }
    }

    handleshowmoreless() {
        let clickedItem = this.template.querySelector(".showmore");

        if (clickedItem.innerText === this.label.showMore) {
            clickedItem.innerText = this.label.showLess;
            this.descriptionField.style.webkitLineClamp = "unset";
        } else {
            clickedItem.innerText = this.label.showMore;
            this.descriptionField.style.webkitLineClamp = this.noOfLines;
            if (this.template.querySelector(".showMoreScroll") != null) {
                this.template
                    .querySelector(".showMoreScroll")
                    .scrollIntoView({ behavior: "auto", block: "start", inline: "start" });
                // now account for fixed header
                let scrolledY = window.scrollY;

                if (scrolledY) {
                    window.scroll(0, scrolledY - 300);
                }
            }
        }
    }
}