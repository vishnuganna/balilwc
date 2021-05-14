import { api, LightningElement } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getKFLearnUrl from "@salesforce/apex/ExternalLinks.getKFLearnUrl";
import kf_learn_banner from "@salesforce/resourceUrl/kf_learn_banner";
import KFLearnError from "@salesforce/label/c.KFLearnError";
import KFLearnConfiguration from "@salesforce/label/c.KFLearnConfiguration";
import KFSellLearning from "@salesforce/label/c.KFSellLearning";
import ReviewConcept from "@salesforce/label/c.ReviewConcept";
import OpenKFLearn from "@salesforce/label/c.OpenKFLearn";
import VisitKFLibrary from "@salesforce/label/c.VisitKFLibrary";
import SeeKFPrivacyPolicy from "@salesforce/label/c.SeeKFPrivacyPolicy";
import KornFerryPrivacyPolicy from "@salesforce/label/c.KornFerryPrivacyPolicy";

export default class KfLearn extends LightningElement {
    @api kfLearnBanner = kf_learn_banner;

    label = {
        KFLearnError, //KFS-2766
        KFLearnConfiguration, //KFS-2766
        KFSellLearning,
        ReviewConcept,
        OpenKFLearn,
        VisitKFLibrary,
        SeeKFPrivacyPolicy,
        KornFerryPrivacyPolicy
    };

    openKFLearn() {
        getKFLearnUrl().then(result => {
            const url = result.toString();
            if (url === "none") {
                // show kf learn error
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.label.KFLearnError,
                        message: this.label.KFLearnConfiguration,
                        variant: "error",
                        mode: "sticky"
                    })
                );
            } else {
                // open kf learn in new window
                window.open(url);
            }
        });
    }

    openKfPrivacy() {
        window.open("https://kornferry.com/privacy");
    }
}