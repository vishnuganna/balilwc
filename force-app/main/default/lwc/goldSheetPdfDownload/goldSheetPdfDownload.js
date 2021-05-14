import { LightningElement, track } from "lwc";
import getNamespaceWithUnderScores from "@salesforce/apex/Util.getNamespaceWithUnderScores";

export default class GoldSheetPdfDownload extends LightningElement {
    @track goldSheedId;
    @track downloadUrl;
    namespaceVar = "goldsheetA4";

    connectedCallback() {
        if (window.location.pathname.split("/")[1] !== "s") {
            //When not in community
            this.goldSheedId = window.location.pathname.split("/")[4];
        } else {
            this.goldSheedId = window.location.pathname.split("/")[3];
        }
        let actionStatus = localStorage.getItem("action");
        let informationNeeded = localStorage.getItem("informationNeeded");
        let investmentPrograms = localStorage.getItem("investmentPrograms");

        getNamespaceWithUnderScores()
            .then(result => {
                if (result !== "") {
                    this.namespaceVar = result + this.namespaceVar;
                }

                let pdfUrl =
                    "/apex/" +
                    this.namespaceVar +
                    "?id=" +
                    this.goldSheedId +
                    "&actionStatus=" +
                    actionStatus +
                    "&informationNeeded=" +
                    informationNeeded +
                    "&investmentPrograms=" +
                    investmentPrograms +
                    "&download=true";

                let downloadElement = document.createElement("a");
                // This  encodeURI encodes special characters, except: , / ? : @ & = + $ # (Use encodeURIComponent() to encode these characters).
                downloadElement.href = encodeURI(pdfUrl);
                downloadElement.target = "_self";
                // CSV File Name
                downloadElement.download = "pdftest.pdf";
                // below statement is required if you are using firefox browser
                document.body.appendChild(downloadElement);
                // click() Javascript function to download CSV file
                downloadElement.click();
                const value = "closeModal";
                const closeEvent = new CustomEvent("closequickaction", {
                    detail: { value }
                });
                // Fire the custom event
                this.dispatchEvent(closeEvent);
            })
            .catch(error => {
                // eslint-disable-next-line no-console
                console.log(JSON.stringify(error));
            });
    }

    downloadPDFFile() {
        window.open(window.location.host + "/apex/goldsheetA4?id=" + this.goldSheedId, "");
    }
}