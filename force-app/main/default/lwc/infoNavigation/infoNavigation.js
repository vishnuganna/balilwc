import { LightningElement, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import InfoAlt from "@salesforce/label/c.InfoAlt";
import ClickToearn from "@salesforce/label/c.ClickToearn";

export default class InfoNavigation extends NavigationMixin(LightningElement) {
    @api navUrl;

    label = {
        InfoAlt,
        ClickToearn
    };

    navigateToWebPage() {
        this[NavigationMixin.Navigate]({
            type: "standard__webPage",
            attributes: {
                url: this.navUrl
            }
        });
    }
}