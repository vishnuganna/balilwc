import { LightningElement, track, api } from "lwc";
import SearchRecord from "@salesforce/label/c.SearchRecord";
import SearchName from "@salesforce/label/c.SearchName";
import Scorecard_Template_Required_Error from "@salesforce/label/c.Scorecard_Template_Required_Error";

export default class SearchComponent extends LightningElement {
    @track searchKey;

    label = {
        SearchRecord,
        SearchName,
        Scorecard_Template_Required_Error
    };

    handleChange(event) {
        /* eslint-disable no-console */
        //console.log('Search Event Started ');
        const searchKey = event.target.value;
        // console.log("Searchkey in custom" +searchKey);
        // console.log("Searchkeylength in custom" + searchKey.length);
        if (searchKey.length > 2) {
            this.searchStringKey(searchKey);
        }
    }

    searchStringKey(searchstr) {
        // console.log("searchKey is" + searchstr);
        /* eslint-disable no-console */
        //event.preventDefault();
        const searchEvent = new CustomEvent("change1", {
            detail: searchstr
        });
        this.dispatchEvent(searchEvent);
    }

    @api checkValidity() {
        //alert('Inside Search');
        var inputCmp = this.template.querySelector(".inputCmp");
        var value = inputCmp.value;
        //console.log("inputcmp" + inputCmp.value);
        // is input is valid?
        if (!value) {
            inputCmp.setCustomValidity("Complete this field");
        } else {
            inputCmp.setCustomValidity(""); // if there was a custom error before, reset it
        }
        inputCmp.reportValidity(); // Tells lightning-input to show the error right away without needing interaction
    }
}