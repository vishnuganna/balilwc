import { LightningElement, track, api } from "lwc";
import findRecords from "@salesforce/apex/CustomLookupController.findRecords";
import { NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import AddeNewContactLabel from "@salesforce/label/c.AddeNewContact";
import NewContactLabel from "@salesforce/label/c.NewContact";
import ContactInformationLabel from "@salesforce/label/c.ContactInformation";
import OwnerLabel from "@salesforce/label/c.Owner";
import AddressInformationLabel from "@salesforce/label/c.AddressInformation";
import cancelLabel from "@salesforce/label/c.cancel";
import saveLabel from "@salesforce/label/c.save";
import RemoveSelectedOptionLabel from "@salesforce/label/c.RemoveSelectedOption";
import SelectOptionLabel from "@salesforce/label/c.SelectOption";
import Required_Field_Missing from "@salesforce/label/c.Required_Field_Missing";
import FillLastName from "@salesforce/label/c.FillLastName";
import Account from "@salesforce/label/c.Account";
import close from "@salesforce/label/c.close";

export default class CustomLookup extends NavigationMixin(LightningElement) {
    @track records;
    @track error;
    @api recordId;
    @api selectedRecordName;
    @api selectedRecordTitle;
    @api selectedRecordMState;
    @api selectedRecordMCountry;
    @track selectedRecord;
    @api selectedconname = false;
    @api index;
    @api selectedname;
    @api selectedtitle;
    @api selectedState;
    @api selectedCountry;
    @api relationshipfield;
    @api title;
    @api iconname = "standard:contact";
    @api objectName = "Contact";
    @api searchfield = "Name";
    @api staticval = "This is Static Value";
    @api newconform = false;
    @api hidenewconbutton = false;
    @api showcustomlookup = false;
    @api conname = "";
    @api conname1;
    @api confname = "";
    @api contactTitle = "Title";
    @api contactId = "";
    @track contactLocation = "Country";
    @track contactStateProvince = " State ";
    @api accountid;
    //KFS-2057 fix
    @api backdrophide = false;

    label = {
        AddeNewContactLabel,
        NewContactLabel,
        ContactInformationLabel,
        OwnerLabel,
        AddressInformationLabel,
        cancelLabel,
        saveLabel,
        RemoveSelectedOptionLabel,
        SelectOptionLabel,
        Required_Field_Missing, //KFS-2766
        FillLastName, //KFS-2766
        Account,
        close
    };

    /*constructor(){
        super();
        this.iconname = "standard:account";
        this.objectName = 'Account';
        this.searchField = 'Name';
    }*/

    navigateToNewContact() {
        this.newconform = true;

        //   this.newconform = false;
    }

    handleSubmit(event) {
        const confields = event.detail.fields;
        this.conTitle = confields.Title;
        this.conLocation = confields.MailingCountry;
        this.conStateProvince = confields.MailingState;
        if (confields.FirstName) {
            this.conname = confields.FirstName + " " + confields.LastName;
        } else {
            this.conname = " " + confields.LastName;
        }
        this.selectedconname = true;
        if (!confields.LastName) {
            const evt = new ShowToastEvent({
                title: this.label.Required_Field_Missing, //KFS-2766
                message: this.label.FillLastName, //KFS-2766
                variant: "error"
            });
            this.dispatchEvent(evt);
        }
        this.selectedRecord = undefined;
        //this.records = undefined;
        this.hidenewconbutton = true;
    }
    handleSuccess(event) {
        const NewRecordEvent = new CustomEvent("newrec", {
            detail: {
                recordId: event.detail.id,
                selectedtitle: this.conTitle,
                selectedState: this.conStateProvince,
                selectedCountry: this.conLocation,
                selectedname: this.conname
            }
        });
        this.dispatchEvent(NewRecordEvent);
        this.newconform = false;
        this.selectedRecord = true;
    }

    @api
    validateFields() {
        this.template.querySelectorAll("c-search-component").forEach(element => {
            element.checkValidity();
        });
    }

    handleOnchange(event) {
        const searchkeyStr = event.detail.value;
        this.hidenewconbutton = false;
        if (searchkeyStr.length === 0) {
            // records = undefined;
        }
        if (searchkeyStr.length > 2) {
            /* Call the Salesforce Apex class method to find the Records */
            this.findRecordslist(searchkeyStr);
        } else {
            /* Call the Salesforce Apex class method to find the Records */
            this.findRecordslist(undefined);
        }
    }

    findRecordslist(searchkeyrecordlist) {
        /* Call the Salesforce Apex class method to find the Records */
        findRecords({
            searchKey: searchkeyrecordlist,
            accountId: this.accountid
        })
            .then(result => {
                this.records = result;
                for (let i = 0; i < this.records.length; i++) {
                    const rec = this.records[i];
                    this.records[i].Name = rec[this.searchfield];
                }
                this.error = undefined;
            })
            .catch(error => {
                this.error = error;
                this.records = undefined;
            });
    }
    //}

    handleSelect(event) {
        this.selectedconname = true;
        const selectedRecordId = event.detail;
        this.hidenewconbutton = true;
        /* eslint-disable no-console*/
        this.selectedRecord = this.records.find(record => record.Id === selectedRecordId);

        this.selectedRecordTitle = this.selectedRecord.Title;
        this.selectedRecordMState = this.selectedRecord.MailingState;
        this.selectedRecordMCountry = this.selectedRecord.MailingCountry;
        this.selectedRecordName = this.selectedRecord.Name;
        this.conname = this.selectedRecord.Name;

        /* fire the event with the value of RecordId for the Selected RecordId */
        const selectedRecordEvent = new CustomEvent("selectedrec", {
            detail: {
                recordId: selectedRecordId,
                selectedtitle: this.selectedRecordTitle,
                selectedState: this.selectedRecordMState,
                selectedCountry: this.selectedRecordMCountry,
                selectedname: this.selectedRecordName,
                index: this.index,
                relationshipfield: this.relationshipfield
            }
        });
        this.dispatchEvent(selectedRecordEvent);
    }

    handleRemove(event) {
        event.preventDefault();
        this.selectedRecord = undefined;
        this.selectedconname = false;
        this.records = undefined;
        this.error = undefined;
        /* fire the event with the value of undefined for the Selected RecordId */
        const selectedRecordEvent = new CustomEvent("selectedrec", {
            detail: {
                recordId: undefined,
                index: this.index,
                relationshipfield: this.relationshipfield
            }
        });
        this.dispatchEvent(selectedRecordEvent);
    }

    handleReset() {
        this.newconform = false;
        this.bShowEditCon = false;
        this.selectedRecord = undefined;
        //this.conname = undefined;
        this.selectedconname = false;
        this.records = undefined;
        this.error = undefined;
        /* fire the event with the value of undefined for the Selected RecordId */
        const selectedRecordEvent = new CustomEvent("selectedrec", {
            detail: {
                recordId: undefined,
                index: this.index,
                relationshipfield: this.relationshipfield
            }
        });
        this.dispatchEvent(selectedRecordEvent);
    }
}