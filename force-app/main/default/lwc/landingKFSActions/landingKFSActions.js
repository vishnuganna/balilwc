import { LightningElement, track, api } from "lwc";
import getRecommendationRecords from "@salesforce/apex/LandingKFSActions.getRecommendationRecords";
import getRecommendationRecordsData from "@salesforce/apex/LandingKFSActions.getRecommendationRecordsData";
import View_Report from "@salesforce/label/c.View_Report";
import KFSellALandingHeaderOpportunity from "@salesforce/label/c.KFSellALandingHeaderOpportunity";
import KFSellALandingHeaderOwner from "@salesforce/label/c.KFSellALandingHeaderOwner";
import KFSellALandingHeaderActionTitle from "@salesforce/label/c.KFSellALandingHeaderActionTitle";
import KFSellALandingToolTipOpportunity from "@salesforce/label/c.KFSellALandingToolTipOpportunity";
import KFSellActionBlueSheet_report from "@salesforce/label/c.KFSellActionBlueSheet_report";
import { loadStyle } from "lightning/platformResourceLoader";
import styles from "@salesforce/resourceUrl/cssLibrary";

const columns = [
    {
        label: KFSellALandingHeaderOpportunity,
        fieldName: "OppLink",
        type: "url",
        sortable: true,
        hideDefaultActions: true,
        initialWidth: 300,
        typeAttributes: {
            label: { fieldName: "OppName" },
            target: "_self",
            tooltip: KFSellALandingToolTipOpportunity
        }
    },
    {
        label: KFSellALandingHeaderActionTitle,
        fieldName: "ActionTitle",
        type: "text",
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
        initialWidth: 300,
        typeAttributes: {
            label: { fieldName: "OppName" },
            target: "_self",
            tooltip: KFSellALandingToolTipOpportunity
        }
    },
    {
        label: KFSellALandingHeaderActionTitle,
        fieldName: "ActionTitle",
        type: "text",
        sortable: true,
        hideDefaultActions: true
    }
];

export default class landingKFSActions extends LightningElement {
    // reactive variable
    @track data = [];
    @track columns = columns;
    @track sortBy;
    @track sortDirection;
    @track recommLst = [];
    @api reporteeList;
    @api isUserManager;
    @api reportList;
    @track rowOffset = 0;
    queryOffset;
    queryLimit;
    totalRecordCount;

    allLabels = {
        View_Report,
        KFSellActionBlueSheet_report
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
        this.getRecommendations();
        this.getreportLink();
        this.loadrecords();
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
            if (reportName[key] === "KFS Landing - KF Sell Actions Blue Sheet") {
                result = key;
            }
        }
        this.reportUrl = "/lightning/r/Report/" + result + "/view";
    }

    getRecommendations() {
        getRecommendationRecordsData({
            userIdSet: this.reporteeList,
            queryLimit: this.queryLimit,
            queryOffset: this.queryOffset
        })
            .then(result => {
                this.recommLst = result;
                if (this.recommLst.length > 10) {
                    this.template.querySelector("KFSellDashBoardDatatableClass").addClass("applyScrollToDataTable");
                }
            })
            .catch(result => {
                this.error = result.error;
                this.data = undefined;
            });
    }
    loadMoreData() {
        if (this.totalRecordCount > this.queryOffset) {
            this.queryOffset = this.queryOffset + 10;
            this.loadrecords();
        }
    }
    loadrecords() {
        let recommLst;
        getRecommendationRecords({
            userIdSet: this.reporteeList,
            queryLimit: this.queryLimit,
            queryOffset: this.queryOffset
        })
            .then(result => {
                this.totalRecordCount = result.totalRecordCount;
                recommLst = JSON.parse(JSON.stringify(result.recommendationRecords));
                let flatCols = [];
                recommLst.forEach(recommRecord => {
                    let flatCol = {};
                    flatCol.OppName = recommRecord.opportunityName; // check for it
                    flatCol.OppLink = "/lightning/r/Opportunity/" + recommRecord.oppId + "/view";
                    flatCol.ActionTitle = recommRecord.actionTitle;
                    flatCol.Owner =
                        recommRecord.opportunityOwnerFirstName + " " + recommRecord.opportunityOwnerLastName;
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