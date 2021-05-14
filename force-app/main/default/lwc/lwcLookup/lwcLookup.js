import { LightningElement, track, api } from "lwc";
import findStrategicPlayerRecords from "@salesforce/apex/CustomLookupController.findStrategicPlayerRecords";
import Record from "@salesforce/label/c.Record";
import SelectOption from "@salesforce/label/c.SelectOption";
import RemoveSelectedOption from "@salesforce/label/c.RemoveSelectedOption";
import RemoveSelectedRecord from "@salesforce/label/c.RemoveSelectedRecord";
import Search from "@salesforce/label/c.Search";

export default class LwcLookup extends LightningElement {
    @track recordsList;
    @track searchKey = "";
    @api selectedValue;
    @api selectedRecordId;
    @api goldSheet;
    @api searchId;
    @api iconName;
    @api lookupLabel;
    @track message;
    @api selectedRecordName;
    @api selectedRecordTitle;
    @api selectedRecordRole;
    // @api selecteItems;
    @api selectedList = [];
    @track namespaceVar;

    label = {
        Record,
        SelectOption,
        RemoveSelectedOption,
        RemoveSelectedRecord,
        Search
    };

    onLeave() {
        //eslint-disable-next-line
        setTimeout(() => {
            this.searchKey = "";
            this.recordsList = null;
        }, 300);
    }

    onRecordSelection(event) {
        this.selectedRecordId = event.target.dataset.key;
        this.selectedValue = event.target.dataset.name;

        this.selectedRecord = this.recordsList.find(record => record.id === this.selectedRecordId);
        this.selectedRecordName = this.selectedRecord.strategicPlayerName;
        this.selectedRecordTitle = this.selectedRecord.strategicPlayerTitle;
        this.selectedRecordRole = this.selectedRecord.role;
        this.searchKey = "";
        this.onSeletedRecordUpdate();
    }

    handleKeyChange(event) {
        const searchKey = event.target.value;
        this.searchKey = searchKey;
        this.getLookupResult();
    }

    removeRecordOnLookup() {
        this.searchKey = "";
        this.selectedValue = null;
        this.selectedRecordId = null;
        this.recordsList = null;
        this.onSeletedRecordUpdate();
    }

    getLookupResult() {
        // findRecords({ searchKey: this.searchKey, objectName : this.objectApiName, goldSheetId : this.goldSheet })
        if (!this.searchKey) {
            this.recordsList = null;
            return;
        }
        findStrategicPlayerRecords({ searchKey: this.searchKey, goldSheetId: this.goldSheet })
            .then(result => {
                if (result.length === 0) {
                    this.recordsList = [];
                    this.message = "No Records Found";
                } else {
                    let tempList = [];
                    result.forEach(record => {
                        if (!this.selectedList || !this.selectedList.includes(record.id)) {
                            tempList.push(record);
                        }
                    });
                    this.recordsList = tempList.length > 0 ? tempList : null;
                    this.message = "";
                }
                this.error = undefined;
            })
            .catch(error => {
                this.error = error;
                this.recordsList = undefined;
            });
    }

    onSeletedRecordUpdate() {
        const passEventr = new CustomEvent("recordselection", {
            detail: {
                selectedRecordId: this.selectedRecordId,
                selectedValue: this.selectedValue,
                selectedRecordTitle: this.selectedRecordTitle,
                selectedRecordRole: this.selectedRecordRole
            }
        });
        this.dispatchEvent(passEventr);
    }
}