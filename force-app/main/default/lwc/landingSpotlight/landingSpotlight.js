import { LightningElement, track, api } from "lwc";
import getBlueSheetRecordData from "@salesforce/apex/LandingSpotlight.getBlueSheetRecordData";
import getBlueSheetRecords from "@salesforce/apex/LandingSpotlight.getBlueSheetRecords";
import View_Report from "@salesforce/label/c.View_Report";
import KFSellALandingHeaderOpportunity from "@salesforce/label/c.KFSellALandingHeaderOpportunity";
import KFSellALandingToolTipOpportunity from "@salesforce/label/c.KFSellALandingToolTipOpportunity";
import Opportunity_Spotlight from "@salesforce/label/c.Opportunity_Spotlight";
import KFSellALandingHeaderAmount from "@salesforce/label/c.KFSellALandingHeaderAmount";
import KFSellALandingHeaderCloseDate from "@salesforce/label/c.KFSellALandingHeaderCloseDate";
import KFSellALandingHeaderStage from "@salesforce/label/c.KFSellALandingHeaderStage";
import KFSellALandingHeaderCurrentPosition from "@salesforce/label/c.KFSellALandingHeaderCurrentPosition";
import KFSellALandingHeaderCustomerTiming from "@salesforce/label/c.KFSellALandingHeaderCustomerTiming";
import KFSellALandingHeaderModified from "@salesforce/label/c.KFSellALandingHeaderModified";
import KFSellALandingHeaderScore from "@salesforce/label/c.KFSellALandingHeaderScore";
import KFSellALandingHeaderEBICount from "@salesforce/label/c.KFSellALandingHeaderEBICount";
import KFSellALandingHeaderCoachCount from "@salesforce/label/c.KFSellALandingHeaderCoachCount";
import KFSellALandingHeaderOwner from "@salesforce/label/c.KFSellALandingHeaderOwner";
import { loadStyle } from "lightning/platformResourceLoader";
import styles from "@salesforce/resourceUrl/cssLibrary";

const columns = [
    {
        label: KFSellALandingHeaderOpportunity,
        fieldName: "OppLink",
        type: "url",
        sortable: true,
        hideDefaultActions: true,
        wrapText: true,
        initialWidth: 250,
        typeAttributes: {
            label: { fieldName: "OppName" },
            target: "_self",
            tooltip: KFSellALandingToolTipOpportunity
        }
    },
    {
        label: KFSellALandingHeaderAmount,
        fieldName: "Amount",
        type: "currency",
        sortable: true,
        hideDefaultActions: true
    },
    {
        label: KFSellALandingHeaderCloseDate,
        fieldName: "CloseDate",
        type: "date",
        sortable: true,
        hideDefaultActions: true
    },
    {
        label: KFSellALandingHeaderStage,
        fieldName: "Stage",
        type: "text",
        sortable: true,
        hideDefaultActions: true,
        wrapText: true
    },
    {
        label: KFSellALandingHeaderCurrentPosition,
        fieldName: "CurrentPosition",
        type: "text",
        sortable: true,
        hideDefaultActions: true
    },
    {
        label: KFSellALandingHeaderCustomerTiming,
        fieldName: "TimingforPriorities",
        type: "text",
        sortable: true,
        hideDefaultActions: true
    },
    {
        label: KFSellALandingHeaderModified,
        fieldName: "LastModifiedDate",
        type: "date",
        sortable: true,
        hideDefaultActions: true
    },
    {
        label: KFSellALandingHeaderScore,
        fieldName: "ScorecardTotal",
        type: "number",
        sortable: true,
        hideDefaultActions: true
    },
    {
        label: KFSellALandingHeaderEBICount,
        fieldName: "EBICount",
        type: "number",
        sortable: true,
        hideDefaultActions: true
    },
    {
        label: KFSellALandingHeaderCoachCount,
        fieldName: "CoachCount",
        type: "number",
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
        wrapText: true,
        initialWidth: 250,
        typeAttributes: {
            label: { fieldName: "OppName" },
            target: "_self",
            tooltip: KFSellALandingToolTipOpportunity
        }
    },
    {
        label: KFSellALandingHeaderAmount,
        fieldName: "Amount",
        type: "currency",
        sortable: true,
        hideDefaultActions: true
    },
    {
        label: KFSellALandingHeaderCloseDate,
        fieldName: "CloseDate",
        type: "date",
        sortable: true,
        hideDefaultActions: true
    },
    {
        label: KFSellALandingHeaderStage,
        fieldName: "Stage",
        type: "text",
        sortable: true,
        hideDefaultActions: true,
        wrapText: true
    },
    {
        label: KFSellALandingHeaderCurrentPosition,
        fieldName: "CurrentPosition",
        type: "text",
        sortable: true,
        hideDefaultActions: true
    },
    {
        label: KFSellALandingHeaderCustomerTiming,
        fieldName: "TimingforPriorities",
        type: "text",
        sortable: true,
        hideDefaultActions: true
    },
    {
        label: KFSellALandingHeaderModified,
        fieldName: "LastModifiedDate",
        type: "date",
        sortable: true,
        hideDefaultActions: true
    },
    {
        label: KFSellALandingHeaderScore,
        fieldName: "ScorecardTotal",
        type: "number",
        sortable: true,
        hideDefaultActions: true
    },
    {
        label: KFSellALandingHeaderEBICount,
        fieldName: "EBICount",
        type: "number",
        sortable: true,
        hideDefaultActions: true
    },
    {
        label: KFSellALandingHeaderCoachCount,
        fieldName: "CoachCount",
        type: "number",
        sortable: true,
        hideDefaultActions: true
    }
];

export default class landingSpotlight extends LightningElement {
    // reactive variable
    @track data = [];
    @track columns = columns;
    @track sortBy;
    @track sortDirection;
    @track reportUrl;
    @track blueSheetList = [];
    @api reporteeList;
    @api isUserManager;
    @api reportList;
    @track rowOffset = 0;
    queryOffset;
    queryLimit;
    totalRecordCount;

    labels = { View_Report, Opportunity_Spotlight };

    // Get the Opportunity Spotlight report ID

    get data() {
        return this.data.length ? this.data : null;
    }

    initializeVariables() {
        this.queryOffset = 0;
        this.queryLimit = 10;
    }
    connectedCallback() {
        this.initializeVariables();
        this.getBlueSheetRecords();
        this.getreportLink();
        this.loadrecords();
    }
    getreportLink() {
        if (this.isUserManager === "Not Manager") {
            this.columns = columnsWithoutOwner;
        }
        let reportName = this.reportList;
        let result;
        for (let key in reportName) {
            if (reportName[key] === "KFS Landing - Opportunity Spotlight") {
                result = key;
            }
        }
        this.reportUrl = "/lightning/r/Report/" + result + "/view";
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

    getBlueSheetRecords() {
        getBlueSheetRecordData({
            userIdSet: this.reporteeList,
            queryLimit: this.queryLimit,
            queryOffset: this.queryOffset
        })
            .then(result => {
                this.blueSheetList = result;
                if (this.blueSheetList.length > 10) {
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

    renderedCallback() {
        loadStyle(this, styles);
    }
    loadrecords() {
        return getBlueSheetRecords({
            userIdSet: this.reporteeList,
            queryLimit: this.queryLimit,
            queryOffset: this.queryOffset
        }).then(result => {
            this.blueSheetList = JSON.parse(JSON.stringify(result.blueSheetRecords));
            this.totalRecordCount = result.totalRecordCount;
            let flatCols = [];
            this.blueSheetList.forEach(blueSheetRecord => {
                let flatCol = {};
                flatCol.Name = blueSheetRecord.Name; // check for it
                flatCol.CurrentPosition = blueSheetRecord.currentPosition;
                flatCol.TimingforPriorities = blueSheetRecord.customerTimingforPriorities;
                flatCol.LastModifiedDate = blueSheetRecord.lastModifiedDate;
                flatCol.ScorecardTotal = blueSheetRecord.scorecardTotal;
                flatCol.EBICount = blueSheetRecord.ebiCount;
                flatCol.CoachCount = blueSheetRecord.coachCount;
                flatCol.BITotal = blueSheetRecord.biTotal;
                flatCol.CloseDate = blueSheetRecord.opportunityCloseDate;
                flatCol.Amount = blueSheetRecord.opportunityAmount;
                flatCol.Stage = blueSheetRecord.opportunityStageName;
                flatCol.OppName = blueSheetRecord.opportunityName;
                flatCol.OppLink = "/lightning/r/Opportunity/" + blueSheetRecord.oppId + "/view";
                flatCol.IsClosed = blueSheetRecord.opportunityIsClosed;
                flatCol.Owner =
                    blueSheetRecord.opportunityOwnerFirstName + " " + blueSheetRecord.opportunityOwnerLastName;
                flatCols.push(flatCol);
            });
            let updatedRecords = [...this.data, ...flatCols];
            this.data = updatedRecords;
            this.error = undefined;
        });
    }
}