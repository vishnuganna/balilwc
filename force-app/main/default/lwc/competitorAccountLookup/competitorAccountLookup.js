import { LightningElement, track, api } from "lwc";
import findAccountRecords from "@salesforce/apex/Competition.findAccountRecords";
import Record from "@salesforce/label/c.Record";
import SelectOption from "@salesforce/label/c.SelectOption";
import RemoveSelectedOption from "@salesforce/label/c.RemoveSelectedOption";
import RemoveSelectedRecord from "@salesforce/label/c.RemoveSelectedRecord";
import Search from "@salesforce/label/c.searchCompetitior";

export default class CompetitorAccountLookup extends LightningElement {
    @track recordsList;
    @track searchKey = "";
    @api selectedvalue = "";
    @api selectedRecordId;
    @api goldSheet;
    @api searchId;
    @api iconName = "standard:account";
    @api lookupLabel;
    @track message;
    @api selectedRecordName;
    // @api selectedRecordTitle;
    // @api selectedRecordRole;
    @api selecteItems;
    @api selectedList = [];
    @track namespaceVar;
    @api searchfield = "Name";

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
        const selectedId = event.detail;
        this.selectedRecord = this.recordsList.find(record => record.Id === selectedId);
        this.selectedRecordName = this.selectedRecord.Name;
        this.selectedvalue = this.selectedRecord.Name;
        this.selectedRecordId = this.selectedRecord.Id;
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
        this.selectedvalue = null;
        this.selectedRecordId = null;
        this.recordsList = null;
        this.onSeletedRecordUpdate();
    }

    getLookupResult() {
        // findRecords({ searchKey: this.searchKey, objectName : this.objectApiName, goldSheetId : this.goldSheet })
        if (!this.searchKey || this.searchKey.length < 3) {
            this.recordsList = null;
            return;
        }

        findAccountRecords({ searchKey: this.searchKey })
            .then(result => {
                this.recordsList = result;
                for (let i = 0; i < this.recordsList.length; i++) {
                    const rec = this.recordsList[i];
                    this.recordsList[i].Name = rec[this.searchfield];
                }
                this.message = "";
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
                selectedvalue: this.selectedvalue
                // selectedRecordTitle: this.selectedRecordTitle,
                // selectedRecordRole: this.selectedRecordRole
            }
        });
        this.dispatchEvent(passEventr);
    }
}