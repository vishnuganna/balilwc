import { LightningElement, track, api } from "lwc";
import getActionPlanRecord from "@salesforce/apex/LandingDueSoon.getActionPlanRecord";
import getActionPlanRecordData from "@salesforce/apex/LandingDueSoon.getActionPlanRecordData";
import View_Report from "@salesforce/label/c.View_Report";
import KFSellALandingHeaderOwner from "@salesforce/label/c.KFSellALandingHeaderOwner";
import KFSellALandingHeaderOpportunity from "@salesforce/label/c.KFSellALandingHeaderOpportunity";
import KFSellALandingHeaderDueDate from "@salesforce/label/c.KFSellALandingHeaderDueDate";
import KFSellALandingHeaderSummary from "@salesforce/label/c.KFSellALandingHeaderSummary";
import KFSellALandingToolTipOpportunity from "@salesforce/label/c.KFSellALandingToolTipOpportunity";
import BestActionsDueSoon from "@salesforce/label/c.BestActionsDueSoon";
import { loadStyle } from "lightning/platformResourceLoader";
import styles from "@salesforce/resourceUrl/cssLibrary";

const columns = [
    {
        label: KFSellALandingHeaderOpportunity,
        fieldName: "OppLink",
        type: "url",
        sortable: true,
        hideDefaultActions: true,
        typeAttributes: {
            label: { fieldName: "OppName" },
            target: "_self",
            tooltip: KFSellALandingToolTipOpportunity
        }
    },
    {
        label: KFSellALandingHeaderSummary,
        fieldName: "Summary",
        type: "text",
        sortable: true,
        hideDefaultActions: true
    },
    {
        label: KFSellALandingHeaderDueDate,
        fieldName: "DueDate",
        type: "date",
        sortable: true,
        hideDefaultActions: true
    },
    { label: KFSellALandingHeaderOwner, fieldName: "Owner", type: "text", sortable: true, hideDefaultActions: true }
];
const columnsWithoutOwner = [
    {
        label: KFSellALandingHeaderOpportunity,
        fieldName: "OppLink",
        type: "url",
        sortable: true,
        hideDefaultActions: true,
        typeAttributes: {
            label: { fieldName: "OppName" },
            target: "_self",
            tooltip: KFSellALandingToolTipOpportunity
        }
    },
    {
        label: KFSellALandingHeaderSummary,
        fieldName: "Summary",
        type: "text",
        sortable: true,
        hideDefaultActions: true
    },
    { label: KFSellALandingHeaderDueDate, fieldName: "DueDate", type: "date", sortable: true, hideDefaultActions: true }
];

export default class landingDueSoon extends LightningElement {
    // reactive variable
    @track data = [];
    @track columns = columns;
    @track sortBy;
    @track sortDirection;
    @track actionPlanList = [];
    @track reportUrl;
    @api reporteeList;
    @api isUserManager;
    @api reportList;
    @track rowOffset = 0;
    queryOffset;
    queryLimit;
    totalRecordCount;

    allLabels = {
        View_Report,
        BestActionsDueSoon
    };
    handleSortdata(event) {
        // field name
        this.sortBy = event.detail.fieldName;

        // sort direction
        this.sortDirection = event.detail.sortDirection;

        // calling sortdata function to sort the data based on direction and selected field
        this.sortData(event.detail.fieldName, event.detail.sortDirection);
    }
    sortData(fieldname, direction) {
        // serialize the data before calling sort function
        let parseData = JSON.parse(JSON.stringify(this.data));

        // Return the value stored in the field
        let keyValue = a => {
            return a[fieldname];
        };

        // cheking reverse direction
        let isReverse = direction === "asc" ? 1 : -1;

        // sorting data
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ""; // handling null values
            y = keyValue(y) ? keyValue(y) : "";

            // sorting values based on direction
            return isReverse * ((x > y) - (y > x));
        });

        // set the sorted data to data table data
        this.data = parseData;
    }
    initializeVariables() {
        this.queryOffset = 0;
        this.queryLimit = 10;
    }
    connectedCallback() {
        this.initializeVariables();
        this.getActionPlan();
        this.getreportLink();
        this.loadrecords();
    }

    getActionPlan() {
        getActionPlanRecordData({
            userIdSet: this.reporteeList,
            queryLimit: this.queryLimit,
            queryOffset: this.queryOffset
        })
            .then(result => {
                this.actionPlanList = result;
                if (this.actionPlanList.length > 10) {
                    this.template.querySelector("KFSellDashBoardDatatableClass").addClass("applyScrollToDataTable");
                }
            })
            .catch(result => {
                this.error = result.error;
                this.data = undefined;
            });
    }

    renderedCallback() {
        loadStyle(this, styles);
    }
    get data() {
        return this.data.length ? this.data : null;
    }
    getreportLink() {
        if (this.isUserManager === "Not Manager") {
            this.columns = columnsWithoutOwner;
        }
        let reportName = this.reportList;
        let result;
        for (let key in reportName) {
            if (reportName[key] === "KFS Landing - Best Action Due Soon") {
                result = key;
            }
        }
        this.reportUrl = "/lightning/r/Report/" + result + "/view";
    }
    loadMoreData() {
        if (this.totalRecordCount > this.queryOffset) {
            this.queryOffset = this.queryOffset + 10;
            this.loadrecords();
        }
    }
    loadrecords() {
        let actionPlanList;
        getActionPlanRecord({
            userIdSet: this.reporteeList,
            queryLimit: this.queryLimit,
            queryOffset: this.queryOffset
        })
            .then(result => {
                this.totalRecordCount = result.totalRecordCount;
                actionPlanList = JSON.parse(JSON.stringify(result.kfsellLandingRecords));
                let flatCols = [];
                actionPlanList.forEach(actionPlanRecord => {
                    let flatCol = {};
                    flatCol.OppName = actionPlanRecord.opportunityName; // check for it
                    flatCol.OppLink = "/lightning/r/Opportunity/" + actionPlanRecord.oppId + "/view";
                    flatCol.Summary = actionPlanRecord.summary;
                    flatCol.DueDate = actionPlanRecord.dueDate;
                    flatCol.Owner =
                        actionPlanRecord.opportunityOwnerFirstName + " " + actionPlanRecord.opportunityOwnerLastName;
                    flatCols.push(flatCol);
                });
                let updatedRecords = [...this.data, ...flatCols];
                this.data = updatedRecords;
            })
            .catch(result => {
                this.error = result.error;
                this.data = undefined;
            });
    }
}