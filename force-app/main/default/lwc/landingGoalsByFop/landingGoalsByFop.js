import { LightningElement } from "lwc";
// import getGoalsByFOPRecords from "@salesforce/apex/LandingGoalsByFOP.getGoalsByFOPRecords";
// import getGoalsByFOPRecordsData from "@salesforce/apex/LandingGoalsByFOP.getGoalsByFOPRecordsData";
// import GoalsByFOP from "@salesforce/label/c.GoalsByFOP";
// import FieldOfPlay from "@salesforce/label/c.FieldOfPlay";
// import AccountOwner from "@salesforce/label/c.AccountOwner";
// import OpenAccount from "@salesforce/label/c.OpenAccount";
// import AccountName from "@salesforce/label/c.AccountName";
// import Goals_Completed from "@salesforce/label/c.Goals_Completed";
// import Goals_Count from "@salesforce/label/c.Goals_Count";
// import View_Report from "@salesforce/label/c.View_Report";
// import OpenFieldOfPlay from "@salesforce/label/c.OpenFieldOfPlay";
// import { loadStyle } from "lightning/platformResourceLoader";
// import styles from "@salesforce/resourceUrl/cssLibrary";

// const columns = [
//     {
//         label: FieldOfPlay,
//         fieldName: "fopLinkName",
//         type: "url",
//         sortable: true,
//         hideDefaultActions: true,
//         wrapText: true,
//         initialWidth: 200,
//         typeAttributes: {
//             label: { fieldName: "fieldOdPlayName" },
//             target: "_self",
//             tooltip: OpenFieldOfPlay
//         }
//     },
//     {
//         label: AccountName,
//         fieldName: "accLinkName",
//         type: "url",
//         sortable: true,
//         hideDefaultActions: true,
//         wrapText: true,
//         initialWidth: 200,
//         typeAttributes: {
//             label: { fieldName: "accName" },
//             target: "_self",
//             tooltip: OpenAccount
//         }
//     },
//     {
//         label: Goals_Count,
//         fieldName: "goalsPresent",
//         type: "number",
//         initialWidth: 100,
//         sortable: true,
//         hideDefaultActions: true
//     },
//     {
//         label: Goals_Completed,
//         fieldName: "goalCompleted",
//         type: "number",
//         initialWidth: 100,
//         sortable: true,
//         hideDefaultActions: true
//     },
//     { label: AccountOwner, fieldName: "owner", type: "text", sortable: true, hideDefaultActions: true }
// ];
// const columnsWithoutOwner = [
//     {
//         label: FieldOfPlay,
//         fieldName: "fopLinkName",
//         type: "url",
//         sortable: true,
//         hideDefaultActions: true,
//         wrapText: true,
//         initialWidth: 200,
//         typeAttributes: {
//             label: { fieldName: "fieldOdPlayName" },
//             target: "_self",
//             tooltip: OpenFieldOfPlay
//         }
//     },
//     {
//         label: AccountName,
//         fieldName: "accLinkName",
//         type: "url",
//         sortable: true,
//         hideDefaultActions: true,
//         wrapText: true,
//         initialWidth: 200,
//         typeAttributes: {
//             label: { fieldName: "accName" },
//             target: "_self",
//             tooltip: OpenAccount
//         }
//     },
//     {
//         label: Goals_Count,
//         fieldName: "goalsPresent",
//         type: "number",
//         initialWidth: 100,
//         sortable: true,
//         hideDefaultActions: true
//     },
//     {
//         label: Goals_Completed,
//         fieldName: "goalCompleted",
//         type: "number",
//         initialWidth: 100,
//         sortable: true,
//         hideDefaultActions: true
//     }
// ];

export default class LandingGoalsByFop extends LightningElement {
    // reactive variable
    // @track data = [];
    // @track columns = columns;
    // @track sortBy;
    // @track sortDirection;
    // @track reportUrl;
    // @track goalsByFopResult = [];
    // @api reporteeList;
    // @api isUserManager;
    // @api reportList;
    // @track rowOffset = 0;
    // queryOffset;
    // queryLimit;
    // totalRecordCount;
    // allLabels = {
    //     GoalsByFOP,
    //     FieldOfPlay,
    //     AccountOwner,
    //     AccountName,
    //     Goals_Completed,
    //     View_Report,
    //     Goals_Count,
    //     OpenFieldOfPlay,
    //     OpenAccount
    // };
    // handleSortdata(event) {
    //     /* field name
    //     GoalsByFOP,
    //     Goals_Present,*/
    //     this.sortBy = event.detail.fieldName;
    //     // sort direction
    //     this.sortDirection = event.detail.sortDirection;
    //     // calling sortdata function to sort the data based on direction and selected field
    //     this.sortData(event.detail.fieldName, event.detail.sortDirection);
    // }
    // sortData(fieldname, direction) {
    //     // serialize the data before calling sort function
    //     let parseData = JSON.parse(JSON.stringify(this.data));
    //     // Return the value stored in the field
    //     let keyValue = a => {
    //         return a[fieldname];
    //     };
    //     // cheking reverse direction
    //     let isReverse = direction === "asc" ? 1 : -1;
    //     // sorting data
    //     parseData.sort((x, y) => {
    //         x = keyValue(x) ? keyValue(x) : ""; // handling null values
    //         y = keyValue(y) ? keyValue(y) : "";
    //         // sorting values based on direction
    //         return isReverse * ((x > y) - (y > x));
    //     });
    //     // set the sorted data to data table data
    //     this.data = parseData;
    // }
    // initializeVariables() {
    //     this.queryOffset = 0;
    //     this.queryLimit = 10;
    // }
    // connectedCallback() {
    //     this.initializeVariables();
    //     this.getGoalsByFOPRecordsfromBackend();
    //     this.loadrecords();
    //     this.getreportLink();
    // }
    // renderedCallback() {
    //     loadStyle(this, styles);
    // }
    // get data() {
    //     return this.data.length ? this.data : null;
    // }
    // getreportLink() {
    //     if (this.isUserManager === "Not Manager") {
    //         this.columns = columnsWithoutOwner;
    //     }
    //     let reportName = this.reportList;
    //     let result;
    //     for (let key in reportName) {
    //         if (reportName[key] === "KFS Landing - Goals By Field Of Play") {
    //             result = key;
    //         }
    //     }
    //     this.reportUrl = "/lightning/r/Report/" + result + "/view";
    // }
    // getGoalsByFOPRecordsfromBackend() {
    //     getGoalsByFOPRecordsData({
    //         userIdSet: this.reporteeList,
    //         queryLimit: this.queryLimit,
    //         queryOffset: this.queryOffset
    //     })
    //         .then(result => {
    //             this.goalsByFopResult = result;
    //             if (this.goalsByFopResult.length > 10) {
    //                 this.template.querySelector("KFSellDashBoardDatatableClass").addClass("applyScrollToDataTable");
    //             }
    //         })
    //         .catch(result => {
    //             this.error = result.error;
    //             this.data = undefined;
    //         });
    // }
    // loadMoreData() {
    //     if (this.totalRecordCount > this.queryOffset) {
    //         this.queryOffset = this.queryOffset + 10;
    //         this.loadrecords();
    //     }
    // }
    // loadrecords() {
    //     let fopGoalsResult;
    //     return getGoalsByFOPRecords({
    //         userIdSet: this.reporteeList,
    //         queryLimit: this.queryLimit,
    //         queryOffset: this.queryOffset
    //     })
    //         .then(result => {
    //             this.totalRecordCount = result.totalRecordCount;
    //             fopGoalsResult = JSON.parse(JSON.stringify(result.goalsByFOPRecords));
    //             let flatCols = [];
    //             fopGoalsResult.forEach(goalsRecord => {
    //                 let flatCol = {};
    //                 flatCol.fieldOdPlayName = goalsRecord.fieldOdPlayName;
    //                 flatCol.fopLinkName = goalsRecord.fopLinkName;
    //                 flatCol.owner = goalsRecord.owner;
    //                 flatCol.goalCompleted = goalsRecord.goalCompleted;
    //                 flatCol.goalsPresent = goalsRecord.goalsPresent;
    //                 flatCol.accName = goalsRecord.accName;
    //                 flatCol.accLinkName = goalsRecord.accLinkName;
    //                 flatCols.push(flatCol);
    //             });
    //             let updatedRecords = [...this.data, ...flatCols];
    //             this.data = updatedRecords;
    //         })
    //         .catch(error => {
    //             this.error = error;
    //         });
    // }
}