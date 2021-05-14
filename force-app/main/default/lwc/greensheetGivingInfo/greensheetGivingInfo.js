import { LightningElement, track, api } from "lwc";
import upsertGivingInformationRecords from "@salesforce/apex/GivingInformation.upsertGivingInfo";
import getGivingInformationRecords from "@salesforce/apex/GivingInformation.getGivingInformationRecords";
import removeGivingInformationRecord from "@salesforce/apex/GivingInformation.removeGreenGivingInfo";
import checkAccess from "@salesforce/apex/GivingInformation.getGivingInfoAccess";
import Record_Error_Message from "@salesforce/label/c.Record_error_message";
import Error_Header from "@salesforce/label/c.error_header";
import Success_header from "@salesforce/label/c.success_header";
import Record_Success_Message from "@salesforce/label/c.Record_success_message";
import ErrorDeleteFailed from "@salesforce/label/c.ErrorDeleteFailed";
import Description_cannot_exceed_32k_characters from "@salesforce/label/c.maxLimitError";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import save from "@salesforce/label/c.save";
import cancel from "@salesforce/label/c.cancel";
import Close from "@salesforce/label/c.close";
import editLabel from "@salesforce/label/c.edit";
import deleteLabel from "@salesforce/label/c.delete";
import Trend_cannot_exceed_80_characters from "@salesforce/label/c.Trend_cannot_exceed_80_characters";
import providingPerspectiveURL from "@salesforce/label/c.providingPerspectiveURL";
import giving_Info_Providing_Perspective from "@salesforce/label/c.giving_Info_Providing_Perspective";
import giving_Info_Giving_Information from "@salesforce/label/c.giving_Info_Giving_Information";
import giving_Info_Delete_Label from "@salesforce/label/c.giving_Info_Delete_Label";
import giving_Info_Delete_Label_des from "@salesforce/label/c.giving_Info_Delete_Label_des";
import giving_Info_Perspective from "@salesforce/label/c.giving_Info_Perspective";
import giving_Info_ProveIt from "@salesforce/label/c.giving_Info_ProveIt";
import giving_Info_So_What from "@salesforce/label/c.giving_Info_So_What";
import giving_Info_Description from "@salesforce/label/c.giving_Info_Description";
import giving_Info_Title from "@salesforce/label/c.giving_Info_Title";
import yes from "@salesforce/label/c.yes";
import giving_Info_Des_place_Holder from "@salesforce/label/c.giving_Info_Des_place_Holder";
import CharLimit from "@salesforce/label/c.CharLimit";
import StrengthValid from "@salesforce/label/c.StrengthValid";
import WeAreOne from "@salesforce/label/c.WeAreOne";
import no from "@salesforce/label/c.no";
import HowWillYouProvidePerspective from "@salesforce/label/c.HowWillYouProvidePerspective";
import AddUniqueStrength from "@salesforce/label/c.AddUniqueStrength";

export default class GreensheetGivingInfo extends LightningElement {
    @track noDataAdded = false;
    @track ShowModal = false;
    @track editform = false;
    @track editViewForm = true;
    @track FormValue = "";
    @track istitlevalue = true;
    @track isstrengthDescValue = true;
    @track isshowbuttonclicked = false;
    @api getIdFromParent;
    @track strengthTitleValue = "";
    @track strengthDescValue = "";
    @track soWhatValue = "";
    @track proveItValue = "";
    @track providingperspectivevalue = "";
    @track formdata = {};
    @track providingPerspective = false;
    @track isCreateable;
    @track isUpdateable;
    @track isDeletable;
    @track showEditView = false;
    @track deleteRecordId;
    @track editRecordId = "";

    @track showForm = false;
    @track yesCss = "slds-button slds-button_neutral unselectedButton";
    @track noCss = "slds-button slds-button_neutral selectedbutton ";

    @track apidata = [];
    @track apidata1 = [];

    @track rfsDetails = this.getNewRfsDetails();
    @track showMaxLimitErrorTitle = false;
    @track showMaxLimitError = false;
    @track soWhatValueshowMaxLimitError = false;
    @track proveItValueshowMaxLimitError = false;
    @track providingperspectivevalueshowMaxLimitError = false;

    @track label = {
        giving_Info_Title,
        giving_Info_Delete_Label_des,
        giving_Info_Description,
        giving_Info_So_What,
        giving_Info_ProveIt,
        giving_Info_Perspective,
        giving_Info_Delete_Label,
        giving_Info_Giving_Information,
        giving_Info_Providing_Perspective,
        Record_Success_Message,
        Record_Error_Message,
        Error_Header,
        ErrorDeleteFailed,
        Description_cannot_exceed_32k_characters,
        save,
        cancel,
        Close,
        editLabel,
        deleteLabel,
        Success_header,
        Trend_cannot_exceed_80_characters,
        providingPerspectiveURL,
        yes,
        giving_Info_Des_place_Holder,
        CharLimit,
        StrengthValid,
        WeAreOne,
        no,
        HowWillYouProvidePerspective,
        AddUniqueStrength
    };

    connectedCallback() {
        this.getDataForGivingInformation();
        this.getGIAccess();
    }

    getNewRfsDetails() {
        return {
            strengthTitle: {
                redFlagSelected: false,
                strengthSelected: false,
                noneSelected: true,
                fieldApiName: "strengthTitle"
            }
        };
    }

    addGivingInfo() {
        this.apidata1 = this.apidata;
        this.editform = true;
        this.editViewForm = false;
        this.rfsDetails = this.getNewRfsDetails();
        this.isPerspective = false;
        this.istitlevalue = true;
        this.isshowbuttonclicked = true;
        this.formdata = {};
        this.setdefualtState();
    }

    renderedCallback() {
        let scrollcontainer = this.template.querySelector(".abc");
        // eslint-disable-next-line
        setTimeout(() => {
            this.handlescroll(scrollcontainer);
        }, 0);
        // eslint-enable-next-line
    }
    handlevalues(formdata) {
        this.strengthTitleValue = formdata.title;
        this.strengthDescValue = formdata.desc;
        this.soWhatValue = formdata.soWhat;
        this.proveItValue = formdata.proveIt;
        this.providingperspectivevalue = formdata.providingperspectivevalue;

        if (formdata.rfsMarkerWrapper.length > 0) {
            this.rfsDetails = this.convertMarkerMap(formdata.rfsMarkerWrapper);
        } else {
            this.rfsDetails = this.getNewRfsDetails();
        }
    }

    handlecancel() {
        this.editform = false;
        this.isshowbuttonclicked = false;
        this.editViewForm = true;
        // this.handlevalues(this.formdata);
        this.showEditView = false;
        this.showMaxLimitError = false;
        this.showMaxLimitErrorTitle = false;
        this.soWhatValueshowMaxLimitError = false;
        this.proveItValueshowMaxLimitError = false;
        this.providingperspectivevalueshowMaxLimitError = false;
        this.setdefualtState();
    }

    setdefualtState() {
        this.rfsDetails = this.getNewRfsDetails();
        this.showEditView = false;
        this.providingPerspective = false;
        this.yesCss = "slds-button slds-button_neutral unselectedButton";
        this.noCss = "slds-button slds-button_neutral selectedbutton ";
        this.strengthTitleValue = "";
        this.providingperspectivevalue = "";
        this.editRecordId = "";
        this.proveItValue = "";
        this.soWhatValue = "";
        this.strengthDescValue = "";
    }
    handleSave() {
        this.showMaxLimitError = false;
        this.showMaxLimitErrorTitle = false;
        this.soWhatValueshowMaxLimitError = false;
        this.proveItValueshowMaxLimitError = false;
        this.providingperspectivevalueshowMaxLimitError = false;
        let givingInformationData = {
            id: this.editRecordId !== "" ? this.editRecordId : null,
            title: this.strengthTitleValue,
            description: this.strengthDescValue,
            soWhat: this.soWhatValue,
            proveIt: this.proveItValue,
            isPerspective: this.providingPerspective,
            perspective: this.providingPerspective === true ? this.providingperspectivevalue : null,
            greenSheet: this.getIdFromParent
        };

        this.isshowbuttonclicked = false;
        this.editform = false;
        this.editViewForm = true;
        this.showEditView = false;
        upsertGivingInformationRecords({
            givingInfo: JSON.stringify(givingInformationData),
            rfsMap: this.rfsDetails
        })
            .then(() => {
                this.setdefualtState();
                // this.isAddNewQuestion = false;
                // this.showSavedState = true;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.label.Success_header,
                        message: this.label.Record_Success_Message,
                        variant: this.label.Success_header
                    })
                );
                this.handleRefresh();
            })
            .catch(error => {
                // this.isAddNewQuestion = false;
                // this.showSavedState = true;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.label.Record_Error_Message,
                        message: error.body.message,
                        variant: this.label.Error_Header
                    })
                );
            });
    }

    getDataForGivingInformation() {
        getGivingInformationRecords({ greenSheetId: this.getIdFromParent }).then(res => {
            this.apidata = res;

            if (this.apidata.length) {
                this.apidata.forEach(basIss => {
                    basIss.rfsMarkerWrapper = this.convertMarkerMap(basIss.rfsMarkerWrapper);
                });
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

    getGIAccess() {
        checkAccess().then(result => {
            this.isCreateable = result.isCreateable;
            this.isUpdateable = result.isUpdateable;
            this.isDeletable = result.isDeletable;
        });
    }

    handleRefresh() {
        this.getDataForGivingInformation();
        this.getGIAccess();
        this.isshowbuttonclicked = false;
        this.apidata = [];
    }

    handleDescription(event) {
        this.strengthDescValue = event.target.value;
        if (this.strengthDescValue.length === 32000) {
            this.showMaxLimitError = true;
        } else {
            this.showMaxLimitError = false;
        }
    }

    handleWhatsfor(event) {
        this.soWhatValue = event.target.value;
        if (this.soWhatValue.length === 32000) {
            this.soWhatValueshowMaxLimitError = true;
        } else {
            this.soWhatValueshowMaxLimitError = false;
        }
    }

    handleProveit(event) {
        this.proveItValue = event.target.value;
        if (this.proveItValue.length === 32000) {
            this.proveItValueshowMaxLimitError = true;
        } else {
            this.proveItValueshowMaxLimitError = false;
        }
    }

    handlePerspective(event) {
        this.providingperspectivevalue = event.target.value;
        this.isPerspective = event.target.value.length === 0 ? false : true;
        if (this.providingperspectivevalue.length === 32000) {
            this.providingperspectivevalueshowMaxLimitError = true;
        } else {
            this.providingperspectivevalueshowMaxLimitError = false;
        }
    }

    handleTitle(event) {
        this.strengthTitleValue = event.target.value;
        this.istitlevalue = event.target.value.length === 0 ? true : false;
        if (event.target.value.length === 80) {
            this.showMaxLimitErrorTitle = true;
        } else {
            this.showMaxLimitErrorTitle = false;
        }
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

    handleButtonClick(event) {
        let targetId = event.currentTarget.dataset.targetId;
        let buttonvalue = this.template
            .querySelector(`[data-target-id="${targetId}"]`)
            .getAttribute("data-target-value");

        let value = "slds-button slds-m-left_x-small";

        if (buttonvalue.toLowerCase() === "yes") {
            this.providingPerspective = true;
            this.yesCss = `${value} selectedbutton`;
            this.noCss = `${value} unselectedButton`;
        } else {
            this.providingPerspective = false;
            this.noCss = `${value} selectedbutton`;
            this.yesCss = `${value} unselectedButton`;
        }
    }

    handleedit(event) {
        this.setdefualtState();
        this.disableAddButton = true;
        this.istitlevalue = false;
        this.isshowbuttonclicked = false;
        let findData = this.apidata.filter(data => data.id === event.currentTarget.dataset.targetId);
        let findData1 = this.apidata.filter(data => data.id !== event.currentTarget.dataset.targetId);
        this.apidata1 = findData1;
        this.strengthTitleValue = findData[0].title;
        this.providingperspectivevalue = findData[0].perspective;
        this.editRecordId = findData[0].id;
        this.proveItValue = findData[0].proveIt;
        this.soWhatValue = findData[0].soWhat;
        this.strengthDescValue = findData[0].description;
        this.rfsDetails.strengthTitle = findData[0].rfsMarkerWrapper;
        this.isPerspective = findData[0].perspective != null && findData[0].perspective.length === 0 ? false : true;
        this.rfsDetails = { ...findData[0].rfsMarkerWrapper };
        if (findData[0].isPerspective) {
            this.providingPerspective = true;
            this.yesCss = `slds-button slds-button_neutral selectedbutton`;
            this.noCss = `slds-button slds-button_neutral unselectedButton`;
        } else {
            this.providingPerspective = false;
            this.noCss = `slds-button slds-button_neutral selectedbutton`;
            this.yesCss = `slds-button slds-button_neutral unselectedButton`;
        }

        this.editform = true;
        this.editViewForm = false;
        this.showMaxLimitError = false;
        this.showMaxLimitErrorTitle = false;
        this.soWhatValueshowMaxLimitError = false;
        this.proveItValueshowMaxLimitError = false;
        this.providingperspectivevalueshowMaxLimitError = false;
    }

    handledelete(event) {
        this.deleteRecordId = event.currentTarget.value;
        this.ShowModal = true;
    }

    closeModal() {
        this.ShowModal = false;
    }

    deleteModal() {
        removeGivingInformationRecord({ recordId: this.deleteRecordId })
            .then(() => {
                this.ShowModal = false;
                // this.showSavedState = true;
                this.handleRefresh();
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.label.Success_header,
                        message: this.label.Record_delete_message,
                        variant: this.label.Success_header
                    })
                );
            })
            .catch(error => {
                // this.showSavedState = true;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.label.Record_Error_Message,
                        message: error.body.message,
                        variant: this.label.Error_Header
                    })
                );
            });
    }

    handlescroll(event) {
        if (this.apidata.length > 5) {
            if (event) {
                let articale = this.template.querySelectorAll(".heightCount");
                event.classList.add("scroll");
                event.style.maxHeight =
                    articale[0].clientHeight +
                    articale[1].clientHeight +
                    articale[2].clientHeight +
                    articale[3].clientHeight +
                    articale[4].clientHeight +
                    articale[5].clientHeight +
                    "px";
            }
        } else {
            event.classList.remove("scroll");
            event.style.maxHeight = "auto";
        }
    }
}