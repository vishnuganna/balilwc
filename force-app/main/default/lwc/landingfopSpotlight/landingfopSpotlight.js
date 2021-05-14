import { LightningElement, track, api } from "lwc";
import getFOpSpotLightRecords from "@salesforce/apex/LandingFOpSpotLight.getFOpSpotLightRecords";
import getFOpSpotLightRecordsData from "@salesforce/apex/LandingFOpSpotLight.getFOpSpotLightRecordsData";
import FieldOfPlay from "@salesforce/label/c.FieldOfPlay";
import AccountOwner from "@salesforce/label/c.AccountOwner";
import FOPSpotlight_Date_Created from "@salesforce/label/c.FOPSpotlight_Date_Created";
import FOPSpotlight_LowRevtarget from "@salesforce/label/c.FOPSpotlight_LowRevtarget";
import FOPSpotlight_RealisticRevtarget from "@salesforce/label/c.FOPSpotlight_RealisticRevtarget";
import FOPSpotlight_HighRevtarget from "@salesforce/label/c.FOPSpotlight_HighRevtarget";
import FOPSpotlight_Account_view from "@salesforce/label/c.FOPSpotlight_Account_view";
import Goals_Completed from "@salesforce/label/c.Goals_Completed";
import Goals_Incomplete from "@salesforce/label/c.Goals_Incomplete";
import New_Opportunities from "@salesforce/label/c.New_Opportunities";
import StrategicPlayer_Sponsor from "@salesforce/label/c.StrategicPlayer_Sponsor";
import StrategicPlayer_Strategic_Coach from "@salesforce/label/c.StrategicPlayer_Strategic_Coach";
import StrategicPlayer_Anti_Sponsor from "@salesforce/label/c.StrategicPlayer_Anti_Sponsor";
import StrategicPlayer_Key_Player from "@salesforce/label/c.StrategicPlayer_Key_Player";
import Field_of_Play_Spotlight from "@salesforce/label/c.Field_of_Play_Spotlight";
import View_Report from "@salesforce/label/c.View_Report";
import FOP_Linked_Opportunities from "@salesforce/label/c.FOP_Linked_Opportunities";
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
        label: FOPSpotlight_Date_Created,
        fieldName: "createdDate",
        type: "date",
        sortable: true,
        hideDefaultActions: true
    },
    {
        label: FOPSpotlight_LowRevtarget,
        fieldName: "lowTarget",
        type: "number",
        sortable: true,
        hideDefaultActions: true,
        wrapText: true
    },
    {
        label: FOPSpotlight_RealisticRevtarget,
        fieldName: "realisticTarget",
        type: "number",
        sortable: true,
        hideDefaultActions: true
    },
    {
        label: FOPSpotlight_HighRevtarget,
        fieldName: "hightTarget",
        type: "number",
        sortable: true,
        hideDefaultActions: true
    },
    {
        label: FOPSpotlight_Account_view,
        fieldName: "fopThisYear",
        type: "text",
        sortable: true,
        hideDefaultActions: true
    },
    { label: Goals_Completed, fieldName: "goalCompleted", type: "number", sortable: true, hideDefaultActions: true },
    {
        label: Goals_Incomplete,
        fieldName: "goalNotCompleted",
        type: "number",
        sortable: true,
        hideDefaultActions: true
    },
    {
        label: FOP_Linked_Opportunities,
        fieldName: "countFOPOpportunity",
        type: "number",
        sortable: true,
        hideDefaultActions: true
    },
    { label: StrategicPlayer_Sponsor, fieldName: "sponsor", type: "number", sortable: true, hideDefaultActions: true },
    {
        label: StrategicPlayer_Strategic_Coach,
        fieldName: "strategicCoach",
        type: "number",
        sortable: true,
        hideDefaultActions: true
    },
    {
        label: StrategicPlayer_Anti_Sponsor,
        fieldName: "antisponsor",
        type: "number",
        sortable: true,
        hideDefaultActions: true
    },
    {
        label: StrategicPlayer_Key_Player,
        fieldName: "keyPlayer",
        type: "number",
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
        label: FOPSpotlight_Date_Created,
        fieldName: "createdDate",
        type: "date",
        sortable: true,
        hideDefaultActions: true
    },
    {
        label: FOPSpotlight_LowRevtarget,
        fieldName: "lowTarget",
        type: "number",
        sortable: true,
        hideDefaultActions: true,
        wrapText: true
    },
    {
        label: FOPSpotlight_RealisticRevtarget,
        fieldName: "realisticTarget",
        type: "number",
        sortable: true,
        hideDefaultActions: true
    },
    {
        label: FOPSpotlight_HighRevtarget,
        fieldName: "hightTarget",
        type: "number",
        sortable: true,
        hideDefaultActions: true
    },
    {
        label: FOPSpotlight_Account_view,
        fieldName: "fopThisYear",
        type: "text",
        sortable: true,
        hideDefaultActions: true
    },
    { label: Goals_Completed, fieldName: "goalCompleted", type: "number", sortable: true, hideDefaultActions: true },
    {
        label: Goals_Incomplete,
        fieldName: "goalNotCompleted",
        type: "number",
        sortable: true,
        hideDefaultActions: true
    },
    {
        label: FOP_Linked_Opportunities,
        fieldName: "countFOPOpportunity",
        type: "number",
        sortable: true,
        hideDefaultActions: true
    },
    { label: StrategicPlayer_Sponsor, fieldName: "sponsor", type: "number", sortable: true, hideDefaultActions: true },
    {
        label: StrategicPlayer_Strategic_Coach,
        fieldName: "strategicCoach",
        type: "number",
        sortable: true,
        hideDefaultActions: true
    },
    {
        label: StrategicPlayer_Anti_Sponsor,
        fieldName: "antisponsor",
        type: "number",
        sortable: true,
        hideDefaultActions: true
    },
    {
        label: StrategicPlayer_Key_Player,
        fieldName: "keyPlayer",
        type: "number",
        sortable: true,
        hideDefaultActions: true
    }
];

export default class LandingfopSpotlight extends LightningElement {
    // reactive variable
    @track data = [];
    @track columns = columns;
    @track sortBy;
    @track sortDirection;
    @track reportUrl;
    @track fopSpotLightResult = [];
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
        FOPSpotlight_Date_Created,
        FOPSpotlight_LowRevtarget,
        FOPSpotlight_RealisticRevtarget,
        FOPSpotlight_HighRevtarget,
        FOPSpotlight_Account_view,
        Goals_Completed,
        Goals_Incomplete,
        New_Opportunities,
        StrategicPlayer_Sponsor,
        StrategicPlayer_Strategic_Coach,
        StrategicPlayer_Anti_Sponsor,
        StrategicPlayer_Key_Player,
        View_Report,
        Field_of_Play_Spotlight,
        FOP_Linked_Opportunities,
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
        this.getFOpSpotLightRecords();
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
            if (reportName[key] === "KFS Landing - Field Of Play SpotLight") {
                result = key;
            }
        }
        this.reportUrl = "/lightning/r/Report/" + result + "/view";
    }

    getFOpSpotLightRecords() {
        getFOpSpotLightRecordsData({
            userIdSet: this.reporteeList,
            queryLimit: this.queryLimit,
            queryOffset: this.queryOffset
        })
            .then(result => {
                this.fopSpotLightResult = result;
                if (this.fopSpotLightResult.length > 10) {
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
        let fopSpotLightResult;
        return getFOpSpotLightRecords({
            userIdSet: this.reporteeList,
            queryLimit: this.queryLimit,
            queryOffset: this.queryOffset
        })
            .then(result => {
                this.totalRecordCount = result.totalRecordCount;
                fopSpotLightResult = JSON.parse(JSON.stringify(result.fopSpotLightRecords));
                let flatCols = [];
                fopSpotLightResult.forEach(fopSpotLightRecord => {
                    let flatCol = {};
                    flatCol.fieldOdPlayName = fopSpotLightRecord.fieldOdPlayName;
                    flatCol.fopLinkName = fopSpotLightRecord.fopLinkName;
                    flatCol.fopThisYear = fopSpotLightRecord.fopThisYear;
                    flatCol.owner = fopSpotLightRecord.owner;
                    flatCol.createdDate = fopSpotLightRecord.createdDate;
                    flatCol.goalCompleted = fopSpotLightRecord.goalCompleted;
                    flatCol.goalNotCompleted = fopSpotLightRecord.goalNotCompleted;
                    flatCol.countFOPOpportunity = fopSpotLightRecord.countFOPOpportunity;
                    flatCol.sponsor = fopSpotLightRecord.sponsor;
                    flatCol.antisponsor = fopSpotLightRecord.antisponsor;
                    flatCol.strategicCoach = fopSpotLightRecord.strategicCoach;
                    flatCol.keyPlayer = fopSpotLightRecord.keyPlayer;
                    flatCol.lowTarget = fopSpotLightRecord.lowTarget;
                    flatCol.hightTarget = fopSpotLightRecord.hightTarget;
                    flatCol.realisticTarget = fopSpotLightRecord.realisticTarget;
                    // flatCol.cssforHideColumn = this.cssforHideColumn;

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