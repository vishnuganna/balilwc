import LightningDatatable from "lightning/datatable";
import customRecordDisplayControl from "./customRecordDisplayControl.html";

export default class CustomLightiningDataTable extends LightningDatatable {
    static customTypes = {
        customRecordDisplayType: {
            template: customRecordDisplayControl,
            // pass attributes to display flag and show more show less for description in lightning data table records
            typeAttributes: [
                "redFlagStrengthObject",
                "fieldApiName",
                "showMoreShowLess",
                "status",
                "isSource",
                "isRedFlagStrength"
            ]
        }
    };
}