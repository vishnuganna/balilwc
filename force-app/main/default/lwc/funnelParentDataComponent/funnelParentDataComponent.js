import { LightningElement, wire } from "lwc";
import getOpportunities from "@salesforce/apex/ChartController.getAllOpportunitiesWithScorecard";
import getOptyStatus from "@salesforce/apex/ChartController.opportunityOpenStatus";
import scorecardscore from "@salesforce/label/c.ScorecardScore";

export default class FunnelParentDataComponent extends LightningElement {
    chartConfiguration;
    dataPerStage = [];
    stageArray = [];
    labels = {
        scorecardscore
    };

    @wire(getOptyStatus)
    getOptyStatus({ data }) {
        if (data) {
            data.forEach(element => {
                this.stageArray.push(element);
            });
        }
    }
    @wire(getOpportunities)
    getOpportunities({ data }) {
        if (data) {
            for (let key in data) {
                if (data.hasOwnProperty(key)) {
                    this.dataPerStage.push({ label: key, value: data[key] }); //Here we are creating the array to show on UI.
                }
            }
            this.chartConfiguration = true;
        }
    }
}