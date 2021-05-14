import { LightningElement, track, api } from "lwc";
import deleteLabel from "@salesforce/label/c.delete";
import edit from "@salesforce/label/c.edit";
import cancelLabel from "@salesforce/label/c.cancel";
import saveLabel from "@salesforce/label/c.save";
import createCharterStatementApi from "@salesforce/apex/CharterStatement.saveCharterStatementData";
import getCharterStatementApi from "@salesforce/apex/CharterStatement.getCharterStatementData";
import showLess from "@salesforce/label/c.showLess";
import showMore from "@salesforce/label/c.showMore";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import successheader from "@salesforce/label/c.success_header";
import errorheader from "@salesforce/label/c.error_header";
import errormsg from "@salesforce/label/c.Record_error_message";
import successmsg from "@salesforce/label/c.Record_success_message";
import yes from "@salesforce/label/c.yes";
import DeleteCharterStatementHeader from "@salesforce/label/c.DeleteCharterStatementHeader";
import AreYouSureYouWantToDeleteCharterStatement from "@salesforce/label/c.AreYouSureYouWantToDeleteCharterStatement";
import checkAccess from "@salesforce/apex/CharterStatement.getGoldSheetAccess";
import no from "@salesforce/label/c.no";
import cancel from "@salesforce/label/c.cancel";
import close from "@salesforce/label/c.close";
import deletemsg from "@salesforce/label/c.Record_delete_message";
import deleteCharterStatement from "@salesforce/apex/CharterStatement.deleteCharterStatement";
import addCharterStatementButton from "@salesforce/label/c.addCharterStatementButton";
import charterStatementTitle from "@salesforce/label/c.charterStatementTitle";
import charterStatementHeaderUrl from "@salesforce/label/c.charterStatementHeaderUrl";
import CharterStatement from "@salesforce/label/c.CharterStatement";
import TemplateExample from "@salesforce/label/c.TemplateExample";
import Description_cannot_exceed_32k_characters from "@salesforce/label/c.maxLimitError";
import QuestionsToConsider from "@salesforce/label/c.QuestionsToConsider";
import WhatBenefitDoWeReceive from "@salesforce/label/c.WhatBenefitDoWeReceive";
import WhatWillWeAsTheSellingOrganizationProvide from "@salesforce/label/c.WhatWillWeAsTheSellingOrganizationProvide";
import ValueForTheFieldOfPlay from "@salesforce/label/c.ValueForTheFieldOfPlay";
import WillThisMoveUsToOurDesiredLevelOnTheBuySellHierarchy from "@salesforce/label/c.WillThisMoveUsToOurDesiredLevelOnTheBuySellHierarchy";
import CharterStatementLabel from "@salesforce/label/c.CharterStatementLabel";
import ErrorOccured from "@salesforce/label/c.ErrorOccured";
import The from "@salesforce/label/c.The";
import Will from "@salesforce/label/c.Will";
import By from "@salesforce/label/c.By";
import AndWeWillReceive from "@salesforce/label/c.AndWeWillReceive";
import FieldOfPlay from "@salesforce/label/c.FieldOfPlay";
import BenefitFieldOfPlay from "@salesforce/label/c.BenefitFieldOfPlay";
import HowWeAddvalue from "@salesforce/label/c.HowWeAddvalue";
import BenefitToUs from "@salesforce/label/c.BenefitToUs";
import Loading from "@salesforce/label/c.Loading";

export default class charterStatement extends LightningElement {
    @api goldsheetId;
    @track showCreateButton = false;
    @track isButtonDisabled = true;
    charterStatement = "";
    charterStatementField;
    noOfLines = 10;
    isShowMoreExist = false;

    @track hasAccess = false;
    @track isEditable = false;
    @track showSavedState = false;
    @track cvShowSpinner = false;

    @track charterStatementDesc = "";
    @track disabledSaveButton = true;

    @track ShowModal = false;
    @track isCreateable = false;
    @track isDeletable = false;
    @track isUpdatable = false;
    @track isViewable = false;
    @track showMaxLimitError = false;
    @track ischarterStatementDescEmpty = true;
    editstateRfs = null;
    @track rfsDetails = this.getNewRfsDetails();
    @track rfsInitialDetails;
    @track hasCharterData = false;
    //editstateRfs = null;

    label = {
        addCharterStatementButton,
        charterStatementTitle,
        charterStatementHeaderUrl,
        CharterStatement,
        TemplateExample,
        deleteLabel,
        edit,
        saveLabel,
        cancelLabel,
        showLess,
        showMore,
        successheader,
        errorheader,
        errormsg,
        successmsg,
        close,
        yes,
        no,
        cancel,
        deletemsg,
        DeleteCharterStatementHeader,
        Description_cannot_exceed_32k_characters,
        AreYouSureYouWantToDeleteCharterStatement,
        QuestionsToConsider,
        WillThisMoveUsToOurDesiredLevelOnTheBuySellHierarchy,
        ValueForTheFieldOfPlay,
        WhatWillWeAsTheSellingOrganizationProvide,
        WhatBenefitDoWeReceive,
        CharterStatementLabel, //KFS-2766
        ErrorOccured, //KFS-2766
        The,
        Will,
        By,
        AndWeWillReceive,
        FieldOfPlay,
        BenefitFieldOfPlay,
        HowWeAddvalue,
        BenefitToUs,
        Loading
    };

    getNewRfsDetails() {
        return {
            charterStatementRfs: {
                redFlagSelected: false,
                strengthSelected: false,
                noneSelected: true,
                fieldApiName: "charterStatementRfs"
            }
        };
    }

    makeFormEditable() {
        this.isEditable = true;
        this.showSavedState = false;
        this.showCreateButton = false;
    }

    addCharterStatment() {
        this.isEditable = true;
        this.showSavedState = false;
        this.showCreateButton = false;
        this.rfsDetails = this.getNewRfsDetails();
    }

    connectedCallback() {
        getCharterStatementApi({ goldsheetId: this.goldsheetId })
            .then(res => {
                this.hasAccess = res.hasEditAccess;
                this.updateData(res);
                this.handleView(res);
                this.validateForm(res.charterStatement);
                if (res.rfsMarkerWrapper.length > 0) {
                    this.rfsDetails = this.convertMarkerMap(res.rfsMarkerWrapper);
                    this.rfsInitialDetails = JSON.parse(JSON.stringify(this.rfsDetails));
                    // this.editstateRfs = JSON.parse(JSON.stringify(this.rfsDetails));
                }
            })
            .catch(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.label.CharterStatementLabel, //KFS-2766
                        message: this.label.ErrorOccured, //KFS-2766
                        variant: "error"
                    })
                );
            });

        checkAccess().then(result => {
            this.isCreateable = result.isCreateable;
            this.isUpdateable = result.isUpdateable;
            this.isDeletable = result.isDeletable;
            this.showSavedState = result.isViewable;
        });
    }

    /*assignMapForRFS(flag) {
        this.rfsDetails.charterStatementRfs = {
            redFlagSelected: flag.redFlagSelected,
            strengthSelected: flag.strengthSelected,
            noneSelected: flag.redFlagSelected && flag.strengthSelected,
            fieldApiName: "charterStatementRfs"
        };

        this.editstateRfs = JSON.parse(JSON.stringify(this.rfsDetails));
    }*/

    convertMarkerMap(rfsMarkerWrapper) {
        const markers = rfsMarkerWrapper;
        const markersMap = this.getNewRfsDetails();
        markers.forEach(marker => {
            markersMap[marker.fieldApiName] = marker;
        });
        return markersMap;
    }

    updateData(res) {
        this.charterStatementDesc = res.charterStatement ? res.charterStatement : "";
        this.charterStatement = res.charterStatement ? res.charterStatement : "";
        this.ischarterStatementDescEmpty = this.charterStatementDesc === "" ? true : false;
    }

    handleView(response) {
        if (response.charterStatement) {
            this.showSavedState = true;
            this.hasCharterData = true;
        }
        if (response.hasEditAccess) {
            this.showCreateButton = true;
            this.isUpdatable = true;
            this.isDeletable = true;
        } else {
            // this.showSavedState = false;
            this.showCreateButton = false;
            this.isUpdatable = false;
            this.isDeletable = false;
        }
    }

    handleDesc(event) {
        this.charterStatement = event.target.value;
        this.validateForm(this.charterStatement);
        this.handleMaxLimitError(event);
    }

    handleMaxLimitError(event) {
        var charterStatementDesc = event.target.value;
        if (charterStatementDesc.length === 32000) {
            this.showMaxLimitError = true;
        } else {
            this.showMaxLimitError = false;
        }
    }

    validateForm(value) {
        if (value && value.length > 0) {
            this.isButtonDisabled = false;
        } else {
            this.isButtonDisabled = true;
        }
        return this.isButtonDisabled;
    }

    handleSave() {
        this.cvShowSpinner = true;
        this.showMaxLimitError = false;
        let charterStatementRfsToSave = {
            charterStatement: this.charterStatement,
            goldsheetId: this.goldsheetId,
            hasEditAccess: this.hasAccess
        };
        createCharterStatementApi({ inputString: JSON.stringify(charterStatementRfsToSave), rfsMap: this.rfsDetails })
            .then(() => {
                this.isEditable = false;
                this.cvShowSpinner = false;
                this.connectedCallback();
                //this.updateData(res);
                //this.handleView(res);
                /* if (res.rfsMarkerWrapper.length > 0) {
                    this.rfsDetails = this.convertMarkerMap(res.rfsMarkerWrapper);
                    this.editstateRfs = JSON.parse(JSON.stringify(this.rfsDetails));
                }*/

                this.showToast(this.label.successheader, this.label.successmsg, "success");
            })
            .catch(() => {
                this.cvShowSpinner = false;
                this.isUpdatable = false;
                this.showToast(this.label.errorheader, this.label.errormsg, "error");
            });
    }

    cancel() {
        this.isEditable = false;
        this.showMaxLimitError = false;

        if (this.charterStatementDesc !== "") {
            this.showCreateButton = false;
            this.showSavedState = true;
            this.hasCharterData = true;
            this.isUpdatable = true;
            this.isDeletable = true;
        } else {
            this.showCreateButton = true;
            this.showSavedState = false;
            this.hasCharterData = false;
            this.isUpdatable = false;
            this.isDeletable = false;
        }
        this.rfsDetails = JSON.parse(JSON.stringify(this.rfsInitialDetails));
    }

    showToast(header, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: header,
                message: message,
                variant: variant
            })
        );
    }

    handleshowmoreless() {
        let clickedItem = this.template.querySelector(".showmore");

        if (clickedItem.innerText === this.label.showMore) {
            clickedItem.innerText = this.label.showLess;
            this.charterStatementField.style.webkitLineClamp = "unset";
        } else {
            clickedItem.innerText = this.label.showMore;
            this.charterStatementField.style.webkitLineClamp = this.noOfLines;
        }
    }

    renderedCallback() {
        this.charterStatementField = this.template.querySelector(".showdesc");
        if (this.charterStatementField) {
            const divHeight = this.charterStatementField.offsetHeight;
            const style = window.getComputedStyle(this.charterStatementField);
            const lineHeight = parseInt(style.getPropertyValue("line-height"), 10);

            const existingNoOfLines = divHeight / lineHeight;

            if (existingNoOfLines < this.noOfLines) {
                this.isShowMoreExist = false;
            } else {
                this.isShowMoreExist = true;
                this.charterStatementField.style.webkitLineClamp = this.noOfLines;
            }
        }
    }

    deleteCharterStatement() {
        this.ShowModal = true;
    }

    closeModal() {
        this.ShowModal = false;
    }
    deleteModal() {
        this.ShowModal = false;

        deleteCharterStatement({ goldsheetId: this.goldsheetId })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.label.successheader,
                        message: this.label.deletemsg,
                        variant: "success"
                    })
                );

                this.updateData({});
                this.validateForm(this.charterStatement);
                this.showSavedState = false;
                this.hasCharterData = false;
                this.showCreateButton = true;
                this.isDeletable = false;
                this.isUpdatable = false;
            })
            .catch(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.label.errorheader,
                        message: this.label.errormsg,
                        variant: "error"
                    })
                );
            });
    }

    //If marker updated then updated
    handleMarkerChange(event) {
        const eventChangedMarker = event.detail;
        const rfsDetailsUpdate = this.rfsDetails[eventChangedMarker.fieldApiName];
        Object.keys(rfsDetailsUpdate).forEach(key => {
            if (eventChangedMarker[key] !== undefined && eventChangedMarker[key] !== null) {
                rfsDetailsUpdate[key] = eventChangedMarker[key];
            }
        });
    }
}