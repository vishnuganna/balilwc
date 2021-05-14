import { LightningElement, track, api } from "lwc";
import getFOpMilestoneRecords from "@salesforce/apex/LandingMilestones.getFOpMilestoneRecords";
import getFOpMilestoneRecordsData from "@salesforce/apex/LandingMilestones.getFOpMilestoneRecordsData";
import View_Report from "@salesforce/label/c.View_Report";
import FieldOfPlay from "@salesforce/label/c.FieldOfPlay";
import AccountOwner from "@salesforce/label/c.AccountOwner";
import MilesStoneName from "@salesforce/label/c.MilesStoneName";
import MilesStoneNumber from "@salesforce/label/c.MilesStoneNumber";
import MeetingDateField from "@salesforce/label/c.MeetingDateField";
import ScheduledMilestones from "@salesforce/label/c.ScheduledMilestones";
import OpenFieldOfPlay from "@salesforce/label/c.OpenFieldOfPlay";
import { loadStyle } from "lightning/platformResourceLoader";
import styles from "@salesforce/resourceUrl/cssLibrary";

const columns = [
    {
        label: FieldOfPlay,
        fieldName: "fopLinkName",
        type: "url",
        sortable: true,
        hideDefaultActions: true,
        wrapText: true,
        initialWidth: 250,
        typeAttributes: {
            label: { fieldName: "fieldOdPlayName" },
            target: "_self",
            tooltip: OpenFieldOfPlay
        }
    },
    { label: AccountOwner, fieldName: "owner", type: "text", sortable: true, hideDefaultActions: true },
    {
        label: MilesStoneNumber,
        fieldName: "milestoneNumber",
        type: "text",
        sortable: true,
        hideDefaultActions: true,
        wrapText: true
    },
    {
        label: MilesStoneName,
        fieldName: "milestoneName",
        type: "text",
        sortable: true,
        hideDefaultActions: true
    },
    {
        label: MeetingDateField,
        fieldName: "scheduledDate",
        type: "date-local",
        sortable: true,
        hideDefaultActions: true
    }
];

const columnsWithoutOwner = [
    {
        label: FieldOfPlay,
        fieldName: "fopLinkName",
        type: "url",
        sortable: true,
        hideDefaultActions: true,
        wrapText: true,
        initialWidth: 250,
        typeAttributes: {
            label: { fieldName: "fieldOdPlayName" },
            target: "_self",
            tooltip: OpenFieldOfPlay
        }
    },
    {
        label: MilesStoneNumber,
        fieldName: "milestoneNumber",
        type: "text",
        sortable: true,
        hideDefaultActions: true,
        wrapText: true
    },
    {
        label: MilesStoneName,
        fieldName: "milestoneName",
        type: "text",
        sortable: true,
        hideDefaultActions: true
    },
    {
        label: MeetingDateField,
        fieldName: "scheduledDate",
        type: "date-local",
        sortable: true,
        hideDefaultActions: true
    }
];

export default class LandingMilestones extends LightningElement {
    @track data = [];
    @track columns = columns;
    @track sortBy;
    @track sortDirection;
    @track reportUrl;
    @track mileStoneSpotLightResult = [];
    @api reporteeList;
    @api isUserManager;
    @api reportList;
    @track rowOffset = 0;
    queryOffset;
    queryLimit;
    totalRecordCount;

    allLabels = {
        FieldOfPlay,
        AccountOwner,
        View_Report,
        MilesStoneName,
        MilesStoneNumber,
        MeetingDateField,
        ScheduledMilestones,
        OpenFieldOfPlay
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
        this.getFOPRecords();
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
            if (reportName[key] === "KFS Landing - Field Of Play Milestone") {
                result = key;
            }
        }
        this.reportUrl = "/lightning/r/Report/" + result + "/view";
    }

    getFOPRecords() {
        getFOpMilestoneRecordsData({
            userIdSet: this.reporteeList,
            queryLimit: this.queryLimit,
            queryOffset: this.queryOffset
        })
            .then(result => {
                this.mileStoneSpotLightResult = result;
                if (this.mileStoneSpotLightResult.length > 10) {
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
        let mileStoneSpotLightResult;
        return getFOpMilestoneRecords({
            userIdSet: this.reporteeList,
            queryLimit: this.queryLimit,
            queryOffset: this.queryOffset
        })
            .then(result => {
                // console.log('the record report'+JSON.stringify(result));
                this.totalRecordCount = result.totalRecordCount;
                mileStoneSpotLightResult = JSON.parse(JSON.stringify(result.milestoneRecords));
                let flatCols = [];
                mileStoneSpotLightResult.forEach(milesStoneSpotLightRecord => {
                    let flatCol = {};
                    flatCol.fieldOdPlayName = milesStoneSpotLightRecord.fieldOdPlayName;
                    flatCol.fopLinkName = milesStoneSpotLightRecord.fopLinkName;
                    flatCol.milestoneName = milesStoneSpotLightRecord.milestoneName;
                    flatCol.milestoneNumber = milesStoneSpotLightRecord.milestoneNumber;
                    flatCol.scheduledDate = milesStoneSpotLightRecord.scheduledDate;
                    flatCol.owner = milesStoneSpotLightRecord.owner;

                    flatCols.push(flatCol);
                });
                let updatedRecords = [...this.data, ...flatCols];
                this.data = updatedRecords;
                //console.log('the data'+JSON.stringify(this.data));
                // console.log('the loadmore'+JSON.stringify(this.data));
            })
            .catch(error => {
                this.error = error;
            });
    }
}