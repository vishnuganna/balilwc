import { LightningElement, track, api } from "lwc";
import getFoPActivityRecords from "@salesforce/apex/LandingGoldSheetActivitiesPastDue.getFoPActivityRecords";
import getFoPActivityRecordData from "@salesforce/apex/LandingGoldSheetActivitiesPastDue.getFoPActivityRecordData";
import View_Report from "@salesforce/label/c.View_Report";
import FOP_Name from "@salesforce/label/c.FOP_Name";
import AccountOwner from "@salesforce/label/c.AccountOwner";
import Activity_Title from "@salesforce/label/c.Activity_Title";
import GoldSheetActivitiesPastDue from "@salesforce/label/c.GoldSheetActivitiesPastDue";
import Due_Date from "@salesforce/label/c.Due_Date";
import { loadStyle } from "lightning/platformResourceLoader";
import styles from "@salesforce/resourceUrl/cssLibrary";
const columns = [
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
    { label: Activity_Title, fieldName: "activityTitle", type: "text", sortable: true, hideDefaultActions: true },
    { label: Due_Date, fieldName: "activityDueDate", type: "text", sortable: true, hideDefaultActions: true }
];
const columnsWithoutOwner = [
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
    { label: Activity_Title, fieldName: "activityTitle", type: "text", sortable: true, hideDefaultActions: true },
    { label: Due_Date, fieldName: "activityDueDate", type: "text", sortable: true, hideDefaultActions: true }
];
export default class LandingGoldsheetActivitesPastDue extends LightningElement {
    // reactive variable
    @track data = [];
    @track columns = columns;
    @track sortBy;
    @track reportUrl;
    @track sortDirection;
    @track activityList = [];
    @api reporteeList;
    @api isUserManager;
    @api reportList;
    @track rowOffset = 0;
    queryOffset;
    queryLimit;
    totalRecordCount;

    allLabels = { View_Report, GoldSheetActivitiesPastDue, Due_Date, Activity_Title, FOP_Name, AccountOwner };
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
        this.getFoPActivityRecords();
        this.getreportLink();
        this.loadrecords();
    }
    renderedCallback() {
        loadStyle(this, styles);
    }
    get data() {
        return this.data.length ? this.data : null;
    }
    getFoPActivityRecords() {
        getFoPActivityRecordData({
            userIdSet: this.reporteeList,
            queryLimit: this.queryLimit,
            queryOffset: this.queryOffset
        })
            .then(result => {
                this.activityList = result;
                if (this.activityList.length > 10) {
                    this.template.querySelector("KFSellDashBoardDatatableClass").addClass("applyScrollToDataTable");
                }
            })
            .catch(result => {
                this.error = result.error;
                this.data = undefined;
            });
    }

    getreportLink() {
        if (this.isUserManager === "Not Manager") {
            this.columns = columnsWithoutOwner;
        }
        let reportName = this.reportList;
        let result;
        for (let key in reportName) {
            if (reportName[key] === "KFS Landing-GoldSheet Activities PastDue") {
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
        return getFoPActivityRecords({
            userIdSet: this.reporteeList,
            queryLimit: this.queryLimit,
            queryOffset: this.queryOffset
        })
            .then(result => {
                this.totalRecordCount = result.totalRecordCount;
                let activityList = JSON.parse(JSON.stringify(result.activityRecords));
                let flatCols = [];
                activityList.forEach(activityRec => {
                    let flatCol = {};
                    flatCol.fopName = activityRec.fopName; // check for it
                    flatCol.fopLink = "/lightning/r/Gold_Sheet__c/" + activityRec.fopId + "/view";
                    flatCol.activityDueDate = activityRec.activityDueDate;
                    flatCol.activityTitle = activityRec.activityTitle + " - " + activityRec.objName;
                    flatCol.Owner = activityRec.accOwnerName;
                    flatCols.push(flatCol);
                });
                let updatedRecords = [...this.data, ...flatCols];
                this.data = updatedRecords;
            })
            .catch(error => {
                this.error = error;
            });
    }
}