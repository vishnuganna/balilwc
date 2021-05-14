import { LightningElement, track, api } from "lwc";
import getFoPRecords from "@salesforce/apex/LandingFOPKFSActions.getFoPRecords";
import getFoPRecordData from "@salesforce/apex/LandingFOPKFSActions.getFoPRecordData";
import FOP_Name from "@salesforce/label/c.FOP_Name";
import KFSellActionsFieldOfPlay from "@salesforce/label/c.KFSellActionsFieldOfPlay";
import ActionsTitle from "@salesforce/label/c.ActionsTitle";
import AccountOwner from "@salesforce/label/c.AccountOwner";
import LastUpdated from "@salesforce/label/c.LastUpdated";
import { loadStyle } from "lightning/platformResourceLoader";
import styles from "@salesforce/resourceUrl/cssLibrary";
import View_Report from "@salesforce/label/c.View_Report";

const columns = [
    { label: ActionsTitle, fieldName: "actionTitle", type: "text", sortable: true, hideDefaultActions: true },
    {
        label: FOP_Name,
        fieldName: "fopLink",
        type: "url",
        sortable: true,
        hideDefaultActions: true,
        typeAttributes: {
            label: { fieldName: "fopName" },
            target: "_self",
            tooltip: "Open Field of Play/Gold Sheet"
        }
    },
    { label: AccountOwner, fieldName: "Owner", type: "text", sortable: true, hideDefaultActions: true },
    { label: LastUpdated, fieldName: "fopLastUpdated", type: "text", sortable: true, hideDefaultActions: true }
];
const columnsWithoutOwner = [
    { label: ActionsTitle, fieldName: "actionTitle", type: "text", sortable: true, hideDefaultActions: true },
    {
        label: FOP_Name,
        fieldName: "fopLink",
        type: "url",
        sortable: true,
        hideDefaultActions: true,
        typeAttributes: {
            label: { fieldName: "fopName" },
            target: "_self",
            tooltip: "Open Field of Play/Gold Sheet"
        }
    },
    { label: LastUpdated, fieldName: "fopLastUpdated", type: "text", sortable: true, hideDefaultActions: true }
];

export default class landingFopKFSActions extends LightningElement {
    // reactive variable
    @track data = [];
    @track columns = columns;
    @track sortBy;
    @track sortDirection;
    @track fopList = [];
    @track reportUrl;
    @api reporteeList;
    @api isUserManager;
    @api reportList;
    @track rowOffset = 0;
    queryOffset;
    queryLimit;
    totalRecordCount;

    allLabels = { KFSellActionsFieldOfPlay, LastUpdated, ActionsTitle, FOP_Name, AccountOwner, View_Report };

    get data() {
        return this.data.length ? this.data : null;
    }

    initializeVariables() {
        this.queryOffset = 0;
        this.queryLimit = 10;
    }
    connectedCallback() {
        this.initializeVariables();
        this.getFoPRecords();
        this.loadrecords();
        this.getreportLink();
    }

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

    getFoPRecords() {
        getFoPRecordData({
            userIdSet: this.reporteeList,
            queryLimit: this.queryLimit,
            queryOffset: this.queryOffset
        })
            .then(result => {
                this.fopList = result;
                if (this.fopList.length > 10) {
                    this.template.querySelector("KFSellDashBoardDatatableClass").addClass("applyScrollToDataTable");
                }
                this.error = undefined;
            })
            .catch(result => {
                this.error = result.error;
                this.data = undefined;
            });
    }

    renderedCallback() {
        loadStyle(this, styles);
    }

    getreportLink() {
        if (this.isUserManager === "Not Manager") {
            this.columns = columnsWithoutOwner;
        }
        let reportName = this.reportList;
        let result;
        for (let key in reportName) {
            if (reportName[key] === "KFS Landing - KFS Actions Field Of Play") {
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
        return getFoPRecords({
            userIdSet: this.reporteeList,
            queryLimit: this.queryLimit,
            queryOffset: this.queryOffset
        }).then(result => {
            this.fopList = JSON.parse(JSON.stringify(result.fOPKFSRecords));
            this.totalRecordCount = result.totalRecordCount;
            let flatCols = [];
            this.fopList.forEach(fopRec => {
                let flatCol = {};
                flatCol.fopName = fopRec.fopName; // check for it
                flatCol.fopLink = "/lightning/r/Gold_Sheet__c/" + fopRec.fopId + "/view";
                flatCol.AccountName = fopRec.accName;
                flatCol.fopLastUpdated = fopRec.fopLastUpdated;
                flatCol.actionTitle = fopRec.actionTitle;
                flatCol.Owner = fopRec.accOwnerName;
                flatCols.push(flatCol);
            });
            let updatedRecords = [...this.data, ...flatCols];
            this.data = updatedRecords;
            this.error = undefined;
        });
    }
}