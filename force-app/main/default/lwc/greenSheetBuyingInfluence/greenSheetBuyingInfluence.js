import { LightningElement, track, api } from "lwc";
import getGreenBuyingInfluenceRecords from "@salesforce/apex/GreenSheetBuyingInfluence.getGreenBuyingInfluenceRecords";
import checkAccess from "@salesforce/apex/GreenSheetBuyingInfluence.getGreenBuyingInfluenceAccess";
import removeGreenBuyingInfluence from "@salesforce/apex/GreenSheetBuyingInfluence.removeGreenBuyingInfluence";
import createGSBIRec from "@salesforce/apex/GreenSheetBuyingInfluence.createGSBIRec";
import addBuyingInfluence from "@salesforce/label/c.addBuyingInfluence";
import EditContactInfoLabel from "@salesforce/label/c.EditContactInfo";
import TitleLabel from "@salesforce/label/c.Title";
import ConceptURL from "@salesforce/label/c.ConceptURL";
import GSbuying_InfluenceHeaderURL from "@salesforce/label/c.GSbuying_InfluenceHeaderURL";
import buying_InfluenceRoleURL from "@salesforce/label/c.buying_InfluenceRoleURL";
import Concept from "@salesforce/label/c.Concept";
import NameLabel from "@salesforce/label/c.Name";
import LocationLabel from "@salesforce/label/c.Location";
import StateProvinceLabel from "@salesforce/label/c.StateProvince";
import buyingInfluenceRoleLabel from "@salesforce/label/c.buyingInfluenceRole";
import technicalLabel from "@salesforce/label/c.technical";
import userLabel from "@salesforce/label/c.user";
import economicLabel from "@salesforce/label/c.economic";
import coachLabel from "@salesforce/label/c.coach";
import MaxTextLimitError from "@salesforce/label/c.maxLimitError";
import cancelLabel from "@salesforce/label/c.cancel";
import saveLabel from "@salesforce/label/c.save";
import editLabel from "@salesforce/label/c.edit";
import deleteLabel from "@salesforce/label/c.delete";
import closeLabel from "@salesforce/label/c.close";
import Record_Error_Message from "@salesforce/label/c.Record_error_message";
import Error_Header from "@salesforce/label/c.error_header";
import Success_header from "@salesforce/label/c.success_header";
import Record_Success_Message from "@salesforce/label/c.Record_success_message";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import GSBIRoleURL from "@salesforce/label/c.GSBIRoleURL";
import buyingInfluenceRolesLabel from "@salesforce/label/c.buyingInfluenceRole";
import deleteBuyingInfluence from "@salesforce/label/c.deleteBuyingInfluence";
import deleteBuyingInfluenceMessage from "@salesforce/label/c.deleteBuyingInfluenceMessage";
import Yes from "@salesforce/label/c.yes";
import ConceptHolder from "@salesforce/label/c.ConceptHolder";
import Scorecard_Template_Title_Column from "@salesforce/label/c.Scorecard_Template_Title_Column";
import Country from "@salesforce/label/c.Country";
import ContactOwner from "@salesforce/label/c.ContactOwner";

export default class GreenSheetBuyingInfluence extends LightningElement {
    @api recordId;
    @api getIdFromParent;
    @track greenBiList = [];
    @track showCreateView = false;
    @track checkNoDataAndReadOnlyAccess = false;
    @track showSavedState = false;
    @track contactTitle = "Title";
    @track contactId = "";
    @track contactLocation = "Country";
    @track contactStateProvince = " State ";
    @track concept = "";
    @track buyingInfluenceRole = "";
    @track editconform = false;
    @track bShowSpinner = false;
    @track isCreateable = false;
    @track isUpdateable = false;
    @track isDeletable = false;
    @track biRecordForSave;
    @track technicalCss = "slds-button slds-button_neutral slds-m-left_x-small";
    @track technicalSelected = "false";
    @track economicCss = "slds-button slds-button_neutral slds-m-left_x-small";
    @track economicSelected = "false";
    @track userCss = "slds-button slds-button_neutral slds-m-left_x-small";
    @track userSelected = "false";
    @track coachCss = "slds-button slds-button_neutral slds-m-left_x-small";
    @track coachSelected = "false";
    @track ShowDeleteModal = false;
    @track deleteRecordId;
    @track concept;
    @track rfsDetails = this.getNewRfsDetails();
    @track biRoleMap = [];
    @track createNewRecord = false;
    @track biId = null;
    @track nogreenBIData = false;
    @track disableSaveButton = true;
    @track showMaxLimitError = false;
    scrollcontainer;
    rolesArry = {};

    label = {
        addBuyingInfluence,
        EditContactInfoLabel,
        TitleLabel,
        NameLabel,
        LocationLabel,
        StateProvinceLabel,
        buyingInfluenceRoleLabel,
        technicalLabel,
        userLabel,
        economicLabel,
        coachLabel,
        MaxTextLimitError,
        cancelLabel,
        saveLabel,
        editLabel,
        deleteLabel,
        closeLabel,
        Success_header,
        Record_Success_Message,
        Record_Error_Message,
        Error_Header,
        buyingInfluenceRolesLabel,
        GSBIRoleURL,
        deleteBuyingInfluence,
        deleteBuyingInfluenceMessage,
        Yes,
        Concept,
        GSbuying_InfluenceHeaderURL,
        ConceptURL,
        ConceptHolder,
        buying_InfluenceRoleURL,
        Scorecard_Template_Title_Column,
        Country,
        ContactOwner
    };

    connectedCallback() {
        this.getBIData();
    }
    getBIData() {
        checkAccess().then(result => {
            this.isCreateable = result.isCreateable;

            this.isUpdateable = result.isUpdateable;
            this.isDeletable = result.isDeletable;
        });

        getGreenBuyingInfluenceRecords({ greenSheetId: this.getIdFromParent }).then(result => {
            this.greenBiList = result;

            this.showSavedState = true;
            this.showCreateView = true;
            this.createNewRecord = false;

            if (!this.greenBiList.length) {
                this.nogreenBIData = true;
                this.checkNoDataAndReadOnlyAccess = !this.isCreateable;
            } else {
                this.greenBiList.forEach(bi => {
                    bi.rfsMarkerWrapper = this.convertMarkerMap(bi.rfsMarkerWrapper);
                });
            }
        });
    }

    handlescroll1(a) {
        if (this.greenBiList.length > 5) {
            if (a) {
                a.classList.add("scroll");
                a.style.maxHeight = a.clientHeight - 1 + "px";
            }
        } else {
            a.classList.remove("scroll");
            a.style.maxHeight = "auto";
        }
    }

    renderedCallback() {
        this.scrollcontainer = this.template.querySelector(".abc");
        // eslint-disable-next-line
        setTimeout(() => {
            if (this.scrollcontainer != null) {
                this.handlescroll1(this.scrollcontainer);
            }
        }, 0);
        // eslint-enable-next-line
    }

    getNewRfsDetails() {
        return {
            BuyingInfluenceRole: {
                redFlagSelected: false,
                strengthSelected: false,
                noneSelected: true,
                fieldApiName: "BuyingInfluenceRole"
            },
            conceptBI: {
                redFlagSelected: false,
                strengthSelected: false,
                noneSelected: true,
                fieldApiName: "conceptBI"
            }
        };
    }

    handleMarkerChange(event) {
        const eventChangedMarker = event.detail;

        const rfsDetailsUpdate = this.rfsDetails[eventChangedMarker.fieldApiName];

        Object.keys(rfsDetailsUpdate).forEach(key => {
            if (eventChangedMarker[key] !== undefined && eventChangedMarker[key] !== null) {
                rfsDetailsUpdate[key] = eventChangedMarker[key];
            }
        });
    }

    convertMarkerMap(rfsMarkerWrapper) {
        //Convert array of objects into Map of competitor flag and competitive details flag values
        const markers = rfsMarkerWrapper;
        const markersMap = this.getNewRfsDetails();
        markers.forEach(marker => {
            markersMap[marker.fieldApiName] = marker;
        });
        return markersMap;
    }

    initializeVariables() {
        this.concept = "";
        this.biRoleMap = [];
        this.contactId = "";
        this.contactLocation = "";
        this.contactStateProvince = "";
        this.contactTitle = "";
        this.contactName = "";
        this.conname = "";
        this.selectedconname = false;
        this.biId = null;

        this.technicalCss = "slds-button slds-button_neutral slds-m-left_x-small";
        this.technicalSelected = "false";
        this.economicCss = "slds-button slds-button_neutral slds-m-left_x-small";
        this.economicSelected = "false";
        this.userCss = "slds-button slds-button_neutral slds-m-left_x-small";
        this.userSelected = "false";
        this.coachCss = "slds-button slds-button_neutral slds-m-left_x-small";
        this.coachSelected = "false";
    }
    handleReset() {
        this.editconform = false;
    }
    handleCreateNew() {
        this.showCreateView = true;
        this.createNewRecord = true;
        this.disableAddButton = true;
        this.disableSaveButton = true;
        this.showSavedState = true;
        this.showMaxLimitError = false;
        this.rfsDetails = this.getNewRfsDetails();

        this.initializeVariables();
    }

    handleConceptChange(event) {
        this.concept = event.target.value;
        this.disableSaveButton = false;
        if (this.concept && this.concept.length === 32000) {
            this.showMaxLimitError = true;
            //this.disableSaveButton = false;
        } else {
            this.showMaxLimitError = false;
            //this.disableSaveButton = false;
        }
        if (this.contactId === "" || this.contactId === undefined) {
            this.disableSaveButton = true;
        }
    }

    handlebuyingInfluenceButtonClick(event) {
        let targetId = event.currentTarget.dataset.targetId;

        let isSelected = this.template
            .querySelector(`[data-target-id="${targetId}"]`)
            .getAttribute("data-target-selected");
        let buttonvalue = this.template
            .querySelector(`[data-target-id="${targetId}"]`)
            .getAttribute("data-target-value");

        let eventName = buttonvalue; //KFS-2561

        if (isSelected === "false") {
            this.template.querySelector(`[data-target-id="${targetId}"]`).setAttribute("data-target-selected", "true");
            this.template
                .querySelector(`[data-target-id="${targetId}"]`)
                .setAttribute("class", "slds-button selectedbutton slds-m-left_x-small");

            this.biRoleMap.push(eventName);
        } else {
            this.template.querySelector(`[data-target-id="${targetId}"]`).setAttribute("data-target-selected", "false");
            this.template
                .querySelector(`[data-target-id="${targetId}"]`)
                .setAttribute("class", "slds-button slds-button_neutral slds-m-left_x-small");
            let index = this.biRoleMap.indexOf(eventName);
            this.biRoleMap.splice(index, 1);
        }
    }

    handletitle(event) {
        //contactName
        this.contactId = event.detail.recordId;
        if (this.contactId === undefined || this.showMaxLimitError) {
            this.disableSaveButton = true;
        } else {
            this.disableSaveButton = false;
        }
        //---Title
        if (event.detail.selectedtitle === undefined) {
            this.contactTitle = " ";
        } else {
            this.contactTitle = event.detail.selectedtitle;
        }

        //----Country
        if (event.detail.selectedCountry === undefined) {
            this.contactLocation = " ";
        } else {
            this.contactLocation = event.detail.selectedCountry;
        }
        //---- State/Province
        if (event.detail.selectedState === undefined) {
            this.contactStateProvince = " ";
        } else {
            this.contactStateProvince = event.detail.selectedState;
        }

        if (event.detail.selectedname === undefined) {
            this.contactName = " ";
        } else {
            this.contactName = event.detail.selectedname;
        }
    }

    handlenewrec(event) {
        this.contactTitle = event.detail.selectedtitle;
        this.contactLocation = event.detail.selectedCountry;
        this.contactStateProvince = event.detail.selectedState;
        this.contactId = event.detail.recordId;
        this.contactName = event.detail.selectedname;
    }

    navigateToEditRecordPage() {
        this.editconform = true;
    }

    handleSubmitEdit(event) {
        const confields = event.detail.fields;
        this.contactTitle = confields.Title;
        this.contactLocation = confields.MailingCountry;
        this.contactStateProvince = confields.MailingState;
        this.newconform = false;
        const confieldsedits = event.detail.fields;
        this.contactTitle = confieldsedits.Title;
        this.contactLocation = confieldsedits.MailingCountry;
        this.contactStateProvince = confieldsedits.MailingState;
        if (confieldsedits.FirstName === "" || confieldsedits.FirstName == null) {
            this.contactName = " " + confieldsedits.LastName;
        } else {
            this.contactName = confieldsedits.FirstName + " " + confieldsedits.LastName;
        }
        this.conname = this.contactName;
    }

    handleSuccessEdit() {
        //this.recordId = this.getIdFromParent;
        // this.recordId = this.optyId;
        this.editconform = false;
    }

    handleCancel() {
        this.showCreateView = false;
        this.disableAddButton = false;
        this.handleRefresh();
    }

    validateSearch() {
        this.template.querySelectorAll("c-custom-lookup").forEach(element => {
            element.validateFields();
        });

        // this.template.querySelector("c-custom-lookup").validateFields();
    }

    handleSave() {
        this.showMaxLimitError = false;
        let isValidFieldValue = true;
        const allValidName = [...this.template.querySelectorAll("lightning-input")].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        if (allValidName) {
            isValidFieldValue = true;
        } else {
            isValidFieldValue = false;
        }
        let biRoleMapString = "";
        if (this.biRoleMap != null && this.biRoleMap.length != null && this.biRoleMap.length > 0) {
            for (let i = 0; i < this.biRoleMap.length; i++) {
                biRoleMapString += this.biRoleMap[i] + ", ";
            }
        }
        biRoleMapString = biRoleMapString.slice(0, -2);
        if (isValidFieldValue) {
            this.isSaveDisabled = true;
            this.biRoleMap = biRoleMapString;
            let gsBIDataToSave = {
                concept: this.concept,
                buyingInfluenceRole: this.biRoleMap,
                contactId: this.contactId,
                greenSheet: this.getIdFromParent,
                id: this.biId
            };

            this.createNewRecord = false;
            this.newRecordModalFlag = false;
            this.showSavedState = true;

            createGSBIRec({
                inputString: JSON.stringify(gsBIDataToSave),
                rfsMap: this.rfsDetails
            })
                .then(() => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: this.label.Success_header,
                            message: this.label.Record_Success_Message,
                            variant: this.label.Success_header
                        })
                    );
                    this.handleRefresh();
                    this.showCreateView = false;
                    this.disableAddButton = false;
                    this.concept = "";
                    this.buyingInfluenceRole = "";
                    this.conname = "";
                    this.contactTitle = "";
                    this.contactStateProvince = "";
                    this.contactLocation = "";
                    this.noDataPresentFlag = false;
                    //this.handleRefresh();
                    this.isSaveDisabled = false;
                    //   this.showCreateView = true;
                    this.showNewRecordButton = true;
                    this.createNewRecord = false;
                })
                .catch(error => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: this.label.Record_Error_Message,
                            message: error.body.message,
                            variant: this.label.Error_Header
                        })
                    );
                });
        }
    }
    closeModal() {
        this.ShowDeleteModal = false;
    }

    DeleteModal(event) {
        this.ShowDeleteModal = true;
        this.deleteRecordId = event.currentTarget.value;
    }

    handleDelete() {
        removeGreenBuyingInfluence({ recordId: this.deleteRecordId })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.label.Success_header,
                        message: this.label.RecordDeleted,
                        variant: this.label.Success_header
                    })
                );
                this.ShowDeleteModal = false;
                this.disableAddButton = false;
                this.handleRefresh();
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.label.ErrorDeleteFailed,
                        message: error.body.message,
                        variant: this.label.Error_Header
                    })
                );
            });
    }

    handleRefresh() {
        this.getBIData();
    }
    handleEdit(event) {
        this.initializeVariables();
        this.showCreateView = true;
        this.createNewRecord = true;
        this.showSavedState = true;
        this.disableAddButton = true;
        this.disableSaveButton = false;
        let currentRow = event.currentTarget.value;
        let currentRowStringified = JSON.parse(JSON.stringify(currentRow));
        this.rfsDetails = currentRowStringified.rfsMarkerWrapper;
        this.biId = currentRow.id;
        this.greenBiList = this.greenBiList.filter(ele => {
            return ele.id !== this.biId;
        });

        this.concept = currentRow.concept;

        this.contactId = currentRow.contactId;
        if (currentRow.buyingInfluenceRole !== undefined) {
            this.rolesArry = currentRow.buyingInfluenceRole.split(", ");
            this.rolesArry.forEach(element => {
                if (element === this.label.economicLabel) {
                    this.economicSelected = "true";
                    this.economicCss = "slds-button selectedbutton slds-m-left_x-small";
                    this.biRoleMap.push(element);
                }
                if (element === this.label.technicalLabel) {
                    this.technicalSelected = "true";
                    this.technicalCss = "slds-button selectedbutton slds-m-left_x-small";
                    this.biRoleMap.push(element);
                }
                if (element === this.label.userLabel) {
                    this.userSelected = "true";
                    this.userCss = "slds-button selectedbutton slds-m-left_x-small";
                    this.biRoleMap.push(element);
                }
                if (element === this.label.coachLabel) {
                    this.coachSelected = "true";
                    this.coachCss = "slds-button selectedbutton slds-m-left_x-small";
                    this.biRoleMap.push(element);
                }
            });
        }
        this.selectedconname = true;
        this.conname = currentRow.contactName;
        this.contactName = this.conname;

        if (currentRow.title) {
            this.contactTitle = currentRow.title;
        } else {
            this.contactTitle = " ";
        }
        this.contactTitle = currentRow.title;
        this.contactLocation = currentRow.country;
        this.contactStateProvince = currentRow.state;

        if (this.contactTitle === undefined) {
            this.contactTitle = this.label.TitleLabel;
        }
        if (this.contactLocation === undefined) {
            this.contactLocation = this.label.Country;
        }
        if (this.contactStateProvince === undefined) {
            this.contactStateProvince = this.label.StateProvinceLabel;
        }

        // eslint-disable-next-line
        setTimeout(() => {
            this.handleScroll();
        }, 200);
        // eslint-enable-next-line
    }

    handleScroll() {
        this.template
            .querySelector(".createRecord")
            .scrollIntoView({ behavior: "auto", block: "start", inline: "start" });
        // now account for fixed header
        const scrolledY = window.scrollY;

        if (scrolledY) {
            window.scroll(0, scrolledY - 200);
        }
    }
}