import { LightningElement, api, track } from "lwc";
import getsearchResult from "@salesforce/apex/GoldsheetSSOController.getSearchResult";
import getSearchResultOnLoad from "@salesforce/apex/GoldsheetSSOController.getSearchResultOnLoad";
import getGoldSheetSSOCsvExportData from "@salesforce/apex/GoldsheetSSOController.getGoldSheetSSOCsvExportData";
import getGoldSheetSSOData from "@salesforce/apex/GoldsheetSSOController.getGoldSheetSSOData";
import removeGoldSheetSSO from "@salesforce/apex/GoldsheetSSOController.removeGoldSheetSSO";
import getObjectPermission from "@salesforce/apex/GoldsheetSSOController.getObjectPermission";
import saveSelectedRecords from "@salesforce/apex/GoldsheetSSOController.saveSelectedRecords";
import AddNew from "@salesforce/label/c.AddNewFoP";
import Save from "@salesforce/label/c.save";
import Delete from "@salesforce/label/c.delete";
import Edit from "@salesforce/label/c.edit";
import Cancel from "@salesforce/label/c.cancel";
import CloseDate from "@salesforce/label/c.CloseDate";
import SingleSalesObjectives from "@salesforce/label/c.SingleSalesObjectives";
import AddSingleSalesObjectives from "@salesforce/label/c.AddSingleSalesObjectives";
import SearchAcrossAccounts from "@salesforce/label/c.SearchAcrossAccounts";
import OpportunityName from "@salesforce/label/c.OpportunityName";
import Account from "@salesforce/label/c.Account";
import Stage from "@salesforce/label/c.Stage";
import ExpectedRevenue from "@salesforce/label/c.ExpectedRevenue";
import TotalExpected from "@salesforce/label/c.TotalExpected";
import SingleSalesObjectiveLink from "@salesforce/label/c.SingleSalesObjectiveLink";
import NoResults from "@salesforce/label/c.NoResults";
import SearchByKey from "@salesforce/label/c.SearchByKey";
import successheader from "@salesforce/label/c.success_header";
import successmsg from "@salesforce/label/c.Record_success_message";
import Export from "@salesforce/label/c.Export";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { exportDataAsCsv } from "c/exportCSV";
import { loadStyle } from "lightning/platformResourceLoader";
import styles from "@salesforce/resourceUrl/cssLibrary";
import LOCALE from "@salesforce/i18n/locale";
import TotalExpectedRevenue from "@salesforce/label/c.TotalExpectedRevenue";

const actions = [{ label: "Remove", name: "delete" }];

const columns = [
    {
        label: "Opportunity Name",
        fieldName: "opportunityName",
        type: "text",
        cellAttributes: { alignment: "left" },
        hideDefaultActions: true
    },
    {
        label: "Account",
        fieldName: "accountName",
        type: "text",
        cellAttributes: { alignment: "left" },
        hideDefaultActions: true
    },
    {
        label: "Stage",
        fieldName: "stageName",
        type: "text",
        cellAttributes: { alignment: "left" },
        hideDefaultActions: true
    },
    {
        label: "Close Date",
        fieldName: "closeDate",
        type: "Date",
        cellAttributes: { alignment: "left" },
        hideDefaultActions: true
    },
    {
        label: "Expected Revenue",
        fieldName: "expectedRevenue",
        type: "currency",
        cellAttributes: { alignment: "left" },
        hideDefaultActions: true
    }
];
const savedColumns = [
    {
        label: OpportunityName,
        fieldName: "opptyLinkName",
        sortable: true,
        type: "url",
        cellAttributes: { alignment: "left" },
        typeAttributes: { label: { fieldName: "opportunityName" }, target: "_blank" },
        hideDefaultActions: true
    },
    {
        label: Account,
        fieldName: "acctLinkName",
        sortable: true,
        type: "url",
        cellAttributes: { alignment: "left" },
        typeAttributes: { label: { fieldName: "accountName" }, target: "_blank" },
        hideDefaultActions: true
    },
    {
        label: Stage,
        fieldName: "stageName",
        sortable: true,
        type: "text",
        cellAttributes: { alignment: "left" },
        hideDefaultActions: true
    },
    {
        label: CloseDate,
        fieldName: "closeDate",
        type: "Date",
        sortable: true,
        cellAttributes: { alignment: "left" },
        hideDefaultActions: true
    },
    {
        label: ExpectedRevenue,
        fieldName: "expectedRevenue",
        type: "currency",
        sortable: true,
        cellAttributes: { alignment: "left" },
        hideDefaultActions: true
    },
    {
        type: "action",
        typeAttributes: { rowActions: actions },
        cellAttributes: {
            class: { fieldName: "cssClassforReadOnlyUsers" }
        },
        hideDefaultActions: true
    }
];
export default class SingleSalesObjectiveGoldSheet extends LightningElement {
    @api getIdFromParent;
    @track hasCreateAccess = false;
    @track hasGoldSheetSSoData = false;
    @track showCreateView = false;
    @track searchText;
    @track hasSearchResult = false;
    @track hasSearchResultOnLoad = false;
    @track searchResultData = [];
    @track searchResultDataOnLoad = [];
    @track defaultSortDirection = "asc";
    @track sortDirection = "asc";
    @track sortedBy;
    @track columns = columns;
    @track savedColumns = savedColumns;
    @track goldSheetSSOData;
    @track totalExpectedRevenue = 0;
    @track selectedRowstoStore;
    @track hasAllAccountsChecked = false;
    @track isSaveDisabled = true;
    allLabels = {
        AddNew,
        Save,
        Cancel,
        Delete,
        Edit,
        CloseDate,
        TotalExpected,
        ExpectedRevenue,
        Stage,
        Account,
        OpportunityName,
        SearchAcrossAccounts,
        AddSingleSalesObjectives,
        SingleSalesObjectives,
        SingleSalesObjectiveLink,
        NoResults,
        SearchByKey,
        successheader,
        successmsg,
        Export,
        TotalExpectedRevenue
    };

    connectedCallback() {
        this.getDataFromBackend();
        this.getObjectPermission();
    }

    getDataFromBackend() {
        getGoldSheetSSOData({ goldsheetId: this.getIdFromParent })
            .then(result => {
                if (result.length) {
                    this.goldSheetSSOData = result;
                    this.goldSheetSSOData.forEach(function(goldSheetSSORecord) {
                        goldSheetSSORecord.closeDate = new Intl.DateTimeFormat(LOCALE).format(
                            new Date(goldSheetSSORecord.closeDate)
                        );
                    });
                    this.hasGoldSheetSSoData = true;
                    let calculateTotalRevenue = 0.0;
                    for (let i = 0; i < result.length; i++) {
                        if (result[i].expectedRevenue) {
                            calculateTotalRevenue += Number(result[i].expectedRevenue);
                        }
                        this.totalExpectedRevenue = calculateTotalRevenue;
                    }
                } else {
                    this.hasGoldSheetSSoData = false;
                    this.goldSheetSSOData = null;
                }
            })
            .catch(() => {
                this.Result = undefined;
            });
    }
    renderedCallback() {
        loadStyle(this, styles);
        let resultOnRender = this.goldSheetSSOData;
        if (resultOnRender && resultOnRender.length > 6) {
            this.template.querySelectorAll(".SavedStateDataTable").forEach(function(el) {
                el.classList.add("scrollableUI");
            });
        } else {
            this.template.querySelectorAll(".SavedStateDataTable").forEach(function(el) {
                el.classList.remove("scrollableUI");
            });
        }
    }
    getDataFromBackendForSearchResult() {
        getSearchResultOnLoad({ goldsheetId: this.getIdFromParent })
            .then(result => {
                if (result.length) {
                    this.searchResultDataOnLoad = result;
                    this.searchResultDataOnLoad.forEach(function(searchResultRecordOnLoad) {
                        searchResultRecordOnLoad.closeDate = new Intl.DateTimeFormat(LOCALE).format(
                            new Date(searchResultRecordOnLoad.closeDate)
                        );
                    });
                    this.hasSearchResultOnLoad = true;
                } else {
                    this.hasSearchResultOnLoad = false;
                }
            })
            .catch(() => {
                this.Result = undefined;
            });
    }

    handleCreate() {
        this.showCreateView = true;
        this.hasSearchResult = false;
        this.isSaveDisabled = true;
        this.hasAllAccountsChecked = false;
        this.getDataFromBackendForSearchResult();
    }
    handleCreateCancel() {
        this.showCreateView = false;
        this.searchText = "";
        this.searchResultData = [];
    }
    handlleSearchAllAccounts(event) {
        this.hasAllAccountsChecked = event.target.checked;
    }
    handleKeyUp(evt) {
        const isEnterKey = evt.keyCode === 13;
        this.searchText = evt.target.value;
        if (isEnterKey && this.searchText.length >= 3) {
            getsearchResult({
                goldSheetId: this.getIdFromParent,
                searchText: this.searchText,
                hasAllAccountsChecked: this.hasAllAccountsChecked
            }).then(result => {
                if (result.length) {
                    this.searchResultData = result;
                    this.searchResultData.forEach(function(searchResultRecord) {
                        searchResultRecord.closeDate = new Intl.DateTimeFormat(LOCALE).format(
                            new Date(searchResultRecord.closeDate)
                        );
                    });
                    this.hasSearchResult = true;
                } else {
                    this.hasSearchResult = false;
                    this.hasSearchResultOnLoad = false;
                }
            });
        } else {
            this.getDataFromBackendForSearchResult();
        }
    }
    reloadDefaultData(event) {
        if (!event.target.value.length) {
            this.hasSearchResult = false;
            this.getDataFromBackendForSearchResult();
        }
    }
    sortBy(field, reverse, primer) {
        const key = primer
            ? function(x) {
                  return primer(x[field]);
              }
            : function(x) {
                  return x[field];
              };

        return function(a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    }

    onHandleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.goldSheetSSOData];

        cloneData.sort(this.sortBy(sortedBy, sortDirection === "asc" ? 1 : -1));
        this.goldSheetSSOData = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }

    getObjectPermission() {
        getObjectPermission().then(result => {
            this.hasCreateAccess = result.isCreateable;
        });
    }

    handleRowAction(event) {
        const action = event.detail.action;
        switch (action.name) {
            case "delete":
                this.handleDelete(event);
                break;
            default:
                break;
        }
    }
    handleDelete(event) {
        this.deleteRecordId = event.detail.row.id;
        removeGoldSheetSSO({ goldSheetSSOId: this.deleteRecordId }).then(() => {
            this.getDataFromBackend();
        });
    }
    getRowData(event) {
        this.selectedRowstoStore = event.detail.selectedRows;
        if (this.selectedRowstoStore.length) {
            this.isSaveDisabled = false;
        } else {
            this.isSaveDisabled = true;
        }
    }
    handleSave() {
        this.isSaveDisabled = true;
        let inputString = JSON.stringify(this.selectedRowstoStore);
        saveSelectedRecords({ inputList: inputString, goldSheetId: this.getIdFromParent }).then(() => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: this.allLabels.successheader,
                    message: this.allLabels.successmsg,
                    variant: "success"
                })
            );
            this.showCreateView = false;
            this.searchText = "";
            this.searchResultData = [];
            this.getDataFromBackend();
        });
    }

    downloadCSVFile() {
        getGoldSheetSSOCsvExportData({ goldsheetId: this.getIdFromParent })
            .then(result => {
                if (result) {
                    const csvGoldSheetSSOData = result.map(function(obj) {
                        return {
                            OpportunityName: obj.opportunityName,
                            Account: obj.accountName,
                            Stage: obj.stageName,
                            CloseDate: new Intl.DateTimeFormat(LOCALE).format(new Date(obj.closeDate)),
                            ExpectedRevenue: obj.expectedRevenue
                        };
                    });
                    const csvString = exportDataAsCsv(csvGoldSheetSSOData);
                    // Creating anchor element to download
                    if (csvString === "") {
                        return;
                    }
                    let downloadElement = document.createElement("a");
                    // This  encodeURI encodes special characters, except: , / ? : @ & = + $ # (Use encodeURIComponent() to encode these characters).
                    downloadElement.href = "data:text/csv;charset=utf-8," + encodeURIComponent(csvString);
                    downloadElement.target = "_self";
                    // CSV File Name
                    downloadElement.download = this.allLabels.SingleSalesObjectives + ".csv";
                    // below statement is required if you are using firefox browser
                    document.body.appendChild(downloadElement);
                    // click() Javascript function to download CSV file
                    downloadElement.click();
                }
            })
            .catch(() => {});
    }
}