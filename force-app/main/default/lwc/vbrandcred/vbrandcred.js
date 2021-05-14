import { LightningElement, track, api } from "lwc";
import validbusinessheader from "@salesforce/label/c.validbusinessheader";
import vbrurl from "@salesforce/label/c.vbrurl";
import crediblityheader from "@salesforce/label/c.crediblityheader";
import crediblityurl from "@salesforce/label/c.crediblityurl";
import createvbrandcred from "@salesforce/apex/GreenSheetVBR.upsertVBR";
import fetchvbrandcred from "@salesforce/apex/GreenSheetVBR.getGreenSheetVBR";
import Error_Header from "@salesforce/label/c.error_header";
import crediblityError from "@salesforce/label/c.crediblityError";
import deletevbrcred from "@salesforce/apex/GreenSheetVBR.deleteVBR";
import checkAccess from "@salesforce/apex/GreenSheetVBR.getGreenSheetAccess";
import addcredvbrbtn from "@salesforce/label/c.addcredvbrbtn";
import reasonLabel from "@salesforce/label/c.reasonLabel";
import credibilityLabel from "@salesforce/label/c.credibilityLabel";
import reasonplaceholder from "@salesforce/label/c.reasonplaceholder";
import EstablishedLabel from "@salesforce/label/c.EstablishedLabel";
import NotYetEstablishedLabel from "@salesforce/label/c.NotYetEstablishedLabel";
import credLabel from "@salesforce/label/c.credLabel";
import credPlaceholder from "@salesforce/label/c.credPlaceholder";
import cancel from "@salesforce/label/c.cancel";
import save from "@salesforce/label/c.save";
import edit from "@salesforce/label/c.edit";
import yes from "@salesforce/label/c.yes";
import deletevbrtitle from "@salesforce/label/c.deletevbrtitle";
import deletevbrmsg from "@salesforce/label/c.deletevbrmsg";
import Delete from "@salesforce/label/c.delete";
import close from "@salesforce/label/c.close";
import Description_cannot_exceed_32k_characters from "@salesforce/label/c.maxLimitError";

export default class Vbrandcred extends LightningElement {
    @api isExpandableView = false;
    @track maincontainer = "slds-card slds-card_boundary";
    label = { validbusinessheader, crediblityheader, crediblityurl, vbrurl };

    handleToggleSection() {
        this.isExpandableView = !this.isExpandableView;
    }

    @track noDataAdded = false;
    @track showbutton = false;
    @track showsavedstate = false;
    @track editform = false;
    @track iseditclicked = false;
    @track isReasonvalue = false;
    @track isincreasecredvalue = false;
    @track isCredibilitySelected = false;

    formData = {};

    @track rfsDetails = this.getNewRfsDetails();
    @track isbuttonDisabled = true;

    // @track unselectedButtonCss = "slds-button slds-button_neutral";
    // @track selectedButtonCss = "slds-button selectedbutton";
    @track establishedCss = "slds-button slds-button_neutral";
    @track notEstablishedCss = "slds-button slds-button_neutral";
    @track establishedSelected = "false";
    @track notEstablishedSelected = "false";
    @track showerror = false;

    @track credibilitySelected = "";
    @track credtype = "";

    @track credibility = "";
    @track increasecred = "";
    @track reasonvalue = "";
    @track showestablishedsvg = false;

    @track isCreateable = false;
    @track isUpdateable = false;
    @track isDeletable = false;

    @track ShowModal = false;
    @track showMaxLimitError = false;
    @track showMaxLimitErrorForIncreasecred = false;

    parentId;

    @api
    get getIdFromParent() {
        return this.parentId;
    }

    set getIdFromParent(value) {
        this.parentId = value;
        this.checkAccessOfUser();
    }

    allLabels = {
        Error_Header,
        crediblityError,
        addcredvbrbtn,
        reasonLabel,
        credibilityLabel,
        reasonplaceholder,
        EstablishedLabel,
        NotYetEstablishedLabel,
        credLabel,
        credPlaceholder,
        cancel,
        save,
        edit,
        yes,
        deletevbrtitle,
        deletevbrmsg,
        Delete,
        close,
        Description_cannot_exceed_32k_characters
    };

    getNewRfsDetails() {
        return {
            ReasonVBR: {
                redFlagSelected: false,
                strengthSelected: false,
                noneSelected: true,
                fieldApiName: "ReasonVBR"
            },
            CredibilityVBR: {
                redFlagSelected: false,
                strengthSelected: false,
                noneSelected: true,
                fieldApiName: "CredibilityVBR"
            }
        };
    }

    handlereason(event) {
        this.reasonvalue = event.target.value;
        this.isReasonvalue = event.target.value.length !== 0 ? true : false;
        this.isbuttonDisabled = false;
        if (this.reasonvalue && this.reasonvalue.length === 32000) {
            this.showMaxLimitError = true;
        } else {
            this.showMaxLimitError = false;
        }
        this.checkblankvalues();
    }

    handleincreasecred(event) {
        this.increasecred = event.target.value;
        this.isincreasecredvalue = event.target.value.length !== 0 ? true : false;
        this.isbuttonDisabled = false;
        if (this.increasecred && this.increasecred.length === 32000) {
            this.showMaxLimitErrorForIncreasecred = true;
        } else {
            this.showMaxLimitErrorForIncreasecred = false;
        }
        this.checkblankvalues();
    }

    addeditvbrandcred() {
        this.showbutton = false;
        this.editform = true;
        this.showsavedstate = false;
        this.isbuttonDisabled = true;
        this.handlevalues(this.formData);
    }

    editvbrandcred() {
        this.iseditclicked = true;
        this.showbutton = false;
        this.editform = true;
        this.showsavedstate = false;
        this.handlevalues(this.formData);
    }

    handledeletebutton() {
        this.ShowModal = true;
    }

    closeModal() {
        this.ShowModal = false;
    }

    deleteModal() {
        this.ShowModal = false;
        deletevbrcred({ greenSheetId: this.getIdFromParent }).then(res => {
            this.formData = res == null ? {} : res;
            this.handleform(this.formData);
        });
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

    checkAccessOfUser() {
        checkAccess().then(result => {
            this.isCreateable = result.isCreateable;
            this.isUpdateable = result.isUpdateable;
            this.isDeletable = result.isDeletable;
            this.fetchdata();
        });
    }

    handlecancel() {
        this.handleform(this.formData);
        this.showMaxLimitError = false;
        this.showMaxLimitErrorForIncreasecred = false;
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

    checkblankvalues() {
        if (
            this.isReasonvalue === false &&
            this.isincreasecredvalue === false &&
            this.isCredibilitySelected === false
        ) {
            this.isbuttonDisabled = true;
        } else {
            this.isbuttonDisabled = false;
        }
    }

    handlevalues(formdata) {
        this.notEstablishedCss = "slds-button slds-button_neutral";
        this.establishedCss = "slds-button slds-button_neutral";
        this.establishedSelected = "false";
        this.notEstablishedSelected = "false";
        this.showerror = false;
        this.reasonvalue = formdata.reason;
        this.increasecred = formdata.toIncreaseCredibility;
        this.credibility = formdata.credibility;

        if (this.credibility === "Established") {
            this.establishedSelected = "true";
            this.establishedCss = "slds-button selectedbutton";
            this.showestablishedsvg = true;
        }
        if (this.credibility === "Not Yet Established") {
            this.notEstablishedSelected = "true";
            this.notEstablishedCss = "slds-button selectedbutton";
            this.showestablishedsvg = false;
        }

        if (formdata.rfsMarkerWrapper && formdata.rfsMarkerWrapper.length > 0) {
            this.rfsDetails = this.convertMarkerMap(formdata.rfsMarkerWrapper);
        } else {
            this.rfsDetails = this.getNewRfsDetails();
        }
    }

    handleSave() {
        this.showMaxLimitError = false;
        this.showMaxLimitErrorForIncreasecred = false;
        if (this.credibility === "" || this.credibility === null || this.credibility === undefined) {
            this.showerror = true;
            this.isbuttonDisabled = true;
        } else {
            this.isbuttonDisabled = false;
            this.showerror = false;

            const obj = {
                id: this.getIdFromParent,
                reason: this.reasonvalue,
                credibility: this.credibility,
                toIncreaseCredibility: this.increasecred
            };

            createvbrandcred({ jsonString: JSON.stringify(obj), rfsMap: this.rfsDetails })
                .then(() => {
                    this.isbuttonDisabled = false;
                    this.editform = false;
                    this.showsavedstate = true;
                    this.fetchdata();
                })
                .catch(() => {
                    this.isbuttonDisabled = false;
                });
        }
    }

    fetchdata() {
        fetchvbrandcred({ greenSheetId: this.getIdFromParent }).then(res => {
            this.formData = res[0];
            this.handleform(this.formData);
        });
    }

    handleform(formdata) {
        this.iseditclicked = false;
        if (formdata.credibility || formdata.reason || formdata.toIncreaseCredibility) {
            this.handlevalues(formdata);
            this.showbutton = false;
            this.showsavedstate = true;
            this.editform = false;
            this.noDataAdded = false;
        } else {
            if (this.isUpdateable) {
                this.noDataAdded = false;
            } else {
                this.noDataAdded = true;
            }

            this.rfsDetails = this.getNewRfsDetails();
            this.showbutton = true;
            this.showsavedstate = false;
            this.editform = false;
        }
    }

    handleCredibilityButtonClick(event) {
        this.showerror = false;

        let targetId = event.currentTarget.dataset.targetId;
        let isSelected = this.template
            .querySelector(`[data-target-id="${targetId}"]`)
            .getAttribute("data-target-selected");
        let buttonvalue = this.template
            .querySelector(`[data-target-id="${targetId}"]`)
            .getAttribute("data-target-value");
        this.credibilitySelected = "";
        this.credibility = "";
        if (isSelected === "false") {
            this.template.querySelector(`[data-target-id="${targetId}"]`).setAttribute("data-target-selected", "true");
            this.template
                .querySelector(`[data-target-id="${targetId}"]`)
                .setAttribute("class", "slds-button selectedbutton");
            this.credibilitySelected = buttonvalue;
            this.isCredibilitySelected = true;
        } else {
            this.isCredibilitySelected = false;
            this.template.querySelector(`[data-target-id="${targetId}"]`).setAttribute("data-target-selected", "false");
            this.template
                .querySelector(`[data-target-id="${targetId}"]`)
                .setAttribute("class", "slds-button slds-button_neutral");
        }
        this.template.querySelectorAll("button[data-target-class=CredibilityButtons]").forEach(element => {
            if (element.getAttribute("data-target-id") !== targetId) {
                element.setAttribute("class", "slds-button slds-button_neutral");
                element.setAttribute("data-target-selected", "false");
            }
        });

        if (this.credibilitySelected === "Established") {
            this.credibility = "Established";
        } else if (this.credibilitySelected === "NotEstablished") {
            this.credibility = "Not Yet Established";
        } else {
            this.credibility = "";
        }
        this.isbuttonDisabled = false;
        this.checkblankvalues();
    }
}