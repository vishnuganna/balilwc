import { api, LightningElement, track } from "lwc";
import getGettingInformationRecords from "@salesforce/apex/GettingInformation.getGIQuestions";
import checkAccess from "@salesforce/apex/GettingInformation.getInfoQuestionsAccess";
import removeGettingInformationRecords from "@salesforce/apex/GettingInformation.removeGreenGIQuestions";
import upsertGettingInformationRecords from "@salesforce/apex/GettingInformation.upsertGIQuestions";
import gettingInformation from "@salesforce/label/c.gettingInformation";
import gettingInformationHeaderURL from "@salesforce/label/c.gettingInformationHeaderURL";
import gettingInformationAddQuestion from "@salesforce/label/c.gettingInformationAddQuestion";
import questionType from "@salesforce/label/c.questionType";
import newInformation from "@salesforce/label/c.newInformation";
import attitude from "@salesforce/label/c.attitude";
import confirmation from "@salesforce/label/c.confirmation";
import newAttitudeQuestion from "@salesforce/label/c.newAttitudeQuestion";
import newAttitudeQuestionsleftLabel from "@salesforce/label/c.newAttitudeQuestionsleftLabel";
import useWhen from "@salesforce/label/c.useWhen";
import keyWords from "@salesforce/label/c.keyWords";
import save from "@salesforce/label/c.save";
import cancel from "@salesforce/label/c.cancel";
import Close from "@salesforce/label/c.close";
import editLabel from "@salesforce/label/c.edit";
import deleteLabel from "@salesforce/label/c.delete";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import deleteGettingInfomationQuestionLabel from "@salesforce/label/c.DeleteGettingInfomationQuestionLabel";
import deleteGettingInfomationQuestionMessage from "@salesforce/label/c.DeleteGettingInfomationQuestionMessage";
import ErrorDeleteFailed from "@salesforce/label/c.ErrorDeleteFailed";
import Record_delete_message from "@salesforce/label/c.Record_delete_message";
import Yes from "@salesforce/label/c.yes";
import Record_Error_Message from "@salesforce/label/c.Record_error_message";
import Error_Header from "@salesforce/label/c.error_header";
import Success_header from "@salesforce/label/c.success_header";
import Record_Success_Message from "@salesforce/label/c.Record_success_message";
import goldenEarColor from "@salesforce/resourceUrl/golden_Ear_color";
import goldenEarColorFill from "@salesforce/resourceUrl/golden_Ear_color_fill";
import Description_cannot_exceed_32k_characters from "@salesforce/label/c.maxLimitError";
import newInformationQuestion from "@salesforce/label/c.newInformationQuestion";
import newInformationQuestionsleftLabel from "@salesforce/label/c.newInformationQuestionsleftLabel";
import newConfirmationQuestion from "@salesforce/label/c.newConfirmationQuestion";
import confirmationQuestionsleftLabel from "@salesforce/label/c.confirmationQuestionsleftLabel";
import newInformationQuestionPlaceholder from "@salesforce/label/c.newInformationQuestionPlaceholder";
import newInformationQuestionBullet1 from "@salesforce/label/c.newInformationQuestionBullet1";
import newInformationQuestionBullet2 from "@salesforce/label/c.newInformationQuestionBullet2";
import newInformationQuestionKeywords from "@salesforce/label/c.newInformationQuestionKeywords";
import newConfirmationQuestionUseWhenLabel from "@salesforce/label/c.newConfirmationQuestionUseWhenLabel";
import newConfirmationQuestionPlaceholder from "@salesforce/label/c.newConfirmationQuestionPlaceholder";
import newConfirmationQuestionBullet1 from "@salesforce/label/c.newConfirmationQuestionBullet1";
import newConfirmationQuestionBullet2 from "@salesforce/label/c.newConfirmationQuestionBullet2";
import newConfirmationQuestionKeywords from "@salesforce/label/c.newConfirmationQuestionKeywords";
import newAttitudeQuestionPlaceholder from "@salesforce/label/c.newAttitudeQuestionPlaceholder";
import newAttitudeQuestionBullet1 from "@salesforce/label/c.newAttitudeQuestionBullet1";
import newAttitudeQuestionBullet2 from "@salesforce/label/c.newAttitudeQuestionBullet2";
import newAttitudeQuestionKeywords from "@salesforce/label/c.newAttitudeQuestionKeywords";

export default class GreenSheetGettingInformation extends LightningElement {
    @api recordId;
    parentId;
    @api
    get getIdFromParent() {
        return this.parentId;
    }
    set getIdFromParent(value) {
        this.parentId = value;
        this.getGIAccess();
    }

    @track label = {
        gettingInformation,
        gettingInformationHeaderURL,
        gettingInformationAddQuestion,
        questionType,
        newInformation,
        attitude,
        confirmation,
        Success_header,
        Record_Success_Message,
        Record_Error_Message,
        Error_Header,
        useWhen,
        keyWords,
        save,
        cancel,
        editLabel,
        deleteLabel,
        deleteGettingInfomationQuestionLabel,
        deleteGettingInfomationQuestionMessage,
        Record_delete_message,
        ErrorDeleteFailed,
        Yes,
        Close,
        Description_cannot_exceed_32k_characters,
        newAttitudeQuestion,
        newAttitudeQuestionsleftLabel,
        newAttitudeQuestionPlaceholder,
        newAttitudeQuestionBullet1,
        newAttitudeQuestionBullet2,
        newAttitudeQuestionKeywords,
        newInformationQuestion,
        newInformationQuestionsleftLabel,
        newInformationQuestionPlaceholder,
        newInformationQuestionBullet1,
        newInformationQuestionBullet2,
        newInformationQuestionKeywords,
        newConfirmationQuestion,
        confirmationQuestionsleftLabel,
        newConfirmationQuestionUseWhenLabel,
        newConfirmationQuestionPlaceholder,
        newConfirmationQuestionBullet1,
        newConfirmationQuestionBullet2,
        newConfirmationQuestionKeywords
    };

    labelData = {
        descriptionHeading: this.label.newInformationQuestion,
        descriptionPlaceholder: this.label.newInformationQuestionPlaceholder,
        leftLabel: this.label.newInformationQuestionsleftLabel,
        useWhen: {
            label: "",
            bulletPoint: [this.label.newInformationQuestionBullet1, this.label.newInformationQuestionBullet2]
        },
        keyWords: this.label.newInformationQuestionKeywords
    };
    @api goldenEar = goldenEarColor;
    @track isGoldenEarselected = false;
    @track isCreateable;
    @track showSavedState = true;
    @track isUpdateable;
    @track isDeletable;
    @track questionTypeLabel = this.label.newInformationQuestion;
    @track questionTypePlaceholder = this.label.newInformationQuestionPlaceholder;
    @track isAddNewQuestion = false;
    @track showDeleteModal = false;
    @track disableSaveButton = true;
    @track disableAddButton = false;
    @track summarySelectedtypeCss = "icon-for-button";

    @track labelLeftLabel = this.label.newInformationQuestionsleftLabel;
    @track rfsDetails = this.getNewRfsDetails();
    @track goldenSilenceSelected = false;
    @track questionType = this.label.newInformation;
    @track giQuestionId = null;
    @track newInformationSelected = "slds-button selectedbutton buttonBorder";
    @track attitudeSelected = "slds-button selectedbutton buttonBorder";
    @track confirmationSelected = "slds-button selectedbutton buttonBorder";
    @track goldeEarClass = "golden-icon-non-selected";
    @track greenSheetGettingInformatioDescription;
    @track showMaxLimitError = false;

    @track isSaveDisabled = true;
    @track gettingInfoQList = [];
    @track addingLable = "slds-m-left_none";

    get goldenEarShow() {
        return goldenEarColor;
    }
    connectedCallback() {
        this.getGIData();
        this.getGIAccess();
    }

    handlescroll1(a) {
        if (this.gettingInfoQList.length > 5) {
            if (a) {
                let articale = this.template.querySelectorAll(".heightCount");
                a.classList.add("scroll");
                a.style.maxHeight =
                    articale[0].clientHeight +
                    articale[1].clientHeight +
                    articale[2].clientHeight +
                    articale[3].clientHeight +
                    articale[4].clientHeight +
                    articale[5].clientHeight +
                    "px";
            }
        } else {
            if (a) {
                a.classList.remove("scroll");
                a.style.maxHeight = "auto";
            }
        }
    }

    renderedCallback() {
        this.scrollcontainer = this.template.querySelector(".abc");
        // eslint-disable-next-line
        setTimeout(() => {
            this.handlescroll1(this.scrollcontainer);
        }, 0);
        // eslint-enable-next-line
    }
    getNewRfsDetails() {
        return {
            QuestionType: {
                redFlagSelected: false,
                strengthSelected: false,
                noneSelected: true,
                fieldApiName: "QuestionType"
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

    getGIAccess() {
        checkAccess().then(result => {
            this.isCreateable = result.isCreateable;
            this.isUpdateable = result.isUpdateable;
            this.isDeletable = result.isDeletable;
        });
    }
    getGIData() {
        getGettingInformationRecords({ greenSheetId: this.getIdFromParent }).then(res => {
            //console.log("In Get");
            this.gettingInfoQList = res;

            if (!this.gettingInfoQList.length) {
                this.nogettingInfoQListData = true;
                this.checkNoDataAndReadOnlyAccess = !this.isCreateable;
            } else {
                this.gettingInfoQList.forEach(gi => {
                    this.goldenSilenceSelected = gi.goldenSilence;
                    switch (gi.questionType) {
                        case this.label.newInformation:
                            gi.iconName = "utility:topic";
                            gi.iconClassName = "icon-for-button";
                            break;
                        case this.label.confirmation:
                            gi.iconName = "action:check";
                            gi.iconClassName = "icon-for-button icon-confirmation";
                            break;
                        case this.label.attitude:
                            gi.iconName = "utility:like";
                            gi.iconClassName = "icon-for-button";
                            break;
                        default:
                            break;
                    }
                    gi.rfsMarkerWrapper = this.convertMarkerMap(gi.rfsMarkerWrapper);
                });
            }
        });
    }

    AddNewQuestion() {
        this.isAddNewQuestion = true;
        this.showSavedState = true;
        this.disableAddButton = true;
        this.disableSaveButton = true;
        this.showDeleteModal = false;
        this.initializeVariables();
    }

    initializeVariables() {
        this.isGoldenEarselected = false;
        this.greenSheetGettingInformatioDescription = "";
        this.questionType = this.label.newInformation;
        this.giQuestionId = null;
        this.rfsDetails = this.getNewRfsDetails();
        this.newInformationbuttonSelected = true;
        this.attitudebuttonSelected = false;
        this.confirmationbuttonSelected = false;
        this.newInformationSelected = "slds-button selectedbutton buttonBorder button-selected";
        this.confirmationSelected = "slds-button selectedbutton buttonBorder";
        this.attitudeSelected = "slds-button selectedbutton buttonBorder";
    }

    handleCancelClick() {
        this.isAddNewQuestion = false;
        this.showSavedState = true;
        this.showDeleteModal = false;
        this.disableAddButton = false;
        this.disableSaveButton = true;
        this.handleRefresh();
        this.setDefaultForm();
    }

    handleSave() {
        let infoQuestions = {
            goldenSilence: this.isGoldenEarselected,
            question: this.greenSheetGettingInformatioDescription,
            questionType: this.questionType,
            greenSheet: this.getIdFromParent,
            id: this.giQuestionId
        };
        upsertGettingInformationRecords({
            infoQuestions: JSON.stringify(infoQuestions),
            rfsMap: this.rfsDetails
        })
            .then(() => {
                this.isAddNewQuestion = false;
                this.showSavedState = true;
                this.getGIData();
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
                this.isAddNewQuestion = false;
                this.showSavedState = true;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.label.Record_Error_Message,
                        message: error.body.message,
                        variant: this.label.Error_Header
                    })
                );
            });
    }

    deleteModal(event) {
        this.deleteRecordId = event.currentTarget.value;
        this.showDeleteModal = true;
    }

    handleDelete() {
        removeGettingInformationRecords({ recordId: this.deleteRecordId })
            .then(() => {
                this.showDeleteModal = false;
                this.showSavedState = true;
                this.getGIData();
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.label.Success_header,
                        message: this.label.Record_delete_message,
                        variant: this.label.Success_header
                    })
                );
            })
            .catch(error => {
                this.showSavedState = true;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.label.Record_Error_Message,
                        message: error.body.message,
                        variant: this.label.Error_Header
                    })
                );
            });
    }

    closeModal() {
        this.showDeleteModal = false;
    }

    handleQuestionType(event) {
        if (event.currentTarget.dataset.targetId === "NewInformation") {
            this.setTextAsQuestionType("New Information");
        } else if (event.currentTarget.dataset.targetId === "attitude") {
            this.setTextAsQuestionType("Attitude");
        } else if (event.currentTarget.dataset.targetId === "confirmation") {
            this.setTextAsQuestionType("Confirmation");
        }
    }

    setTextAsQuestionType(questionTypeName) {
        if (questionTypeName === "New Information") {
            this.addingLable = "slds-m-left_none";
            this.newInformationSelected = "slds-button selectedbutton buttonBorder button-selected";
            this.attitudeSelected = "slds-button selectedbutton buttonBorder";
            this.confirmationSelected = "slds-button selectedbutton buttonBorder";
            this.questionType = this.label.newInformation;
            this.labelLeftLabel = this.label.newInformationQuestionsleftLabel;
            this.labelData.descriptionHeading = this.label.newInformationQuestion;
            this.labelData.descriptionPlaceholder = this.label.newInformationQuestionPlaceholder;
            this.labelData.leftLabel = this.label.newInformationQuestionsleftLabel;
            this.labelData.useWhen.label = "";
            this.labelData.useWhen.bulletPoint = [
                this.label.newInformationQuestionBullet1,
                this.label.newInformationQuestionBullet2
            ];
            this.labelData.keyWords = this.label.newInformationQuestionKeywords;
        } else if (questionTypeName === "Attitude") {
            this.addingLable = "slds-m-left_none";
            this.newInformationSelected = "slds-button selectedbutton buttonBorder";
            this.attitudeSelected = "slds-button selectedbutton buttonBorder button-selected";
            this.confirmationSelected = "slds-button selectedbutton buttonBorder";
            this.questionType = this.label.attitude;
            this.labelLeftLabel = this.label.newAttitudeQuestionsleftLabel;
            this.labelData.descriptionPlaceholder = this.label.newAttitudeQuestionPlaceholder;
            this.labelData.descriptionHeading = this.label.newAttitudeQuestion;
            this.labelData.leftLabel = this.label.newAttitudeQuestionsleftLabel;
            this.labelData.useWhen.label = "";
            this.labelData.useWhen.bulletPoint = [
                this.label.newAttitudeQuestionBullet1,
                this.label.newAttitudeQuestionBullet2
            ];
            this.labelData.keyWords = this.label.newAttitudeQuestionKeywords;
        } else if (questionTypeName === "Confirmation") {
            this.addingLable = "slds-m-left_x-large";
            this.newInformationSelected = "slds-button selectedbutton buttonBorder";
            this.attitudeSelected = "slds-button selectedbutton buttonBorder";
            this.confirmationSelected = "slds-button selectedbutton buttonBorder button-selected";
            this.questionType = this.label.confirmation;
            this.labelLeftLabel = this.label.confirmationQuestionsleftLabel;
            this.labelData.descriptionPlaceholder = this.label.newConfirmationQuestionPlaceholder;
            this.labelData.descriptionHeading = this.label.newConfirmationQuestion;
            this.labelData.leftLabel = this.label.confirmationQuestionsleftLabel;
            this.labelData.useWhen.label = this.label.newConfirmationQuestionUseWhenLabel;
            this.labelData.useWhen.bulletPoint = [
                this.label.newConfirmationQuestionBullet1,
                this.label.newConfirmationQuestionBullet2
            ];
            this.labelData.keyWords = this.label.newConfirmationQuestionKeywords;
        }
    }

    handleEdit(event) {
        let currentRow = event.currentTarget.value;
        this.isAddNewQuestion = true;
        this.showSavedState = true;
        this.disableAddButton = true;
        this.disableSaveButton = false;
        let currentRowStringified = JSON.parse(JSON.stringify(currentRow));
        this.rfsDetails = currentRowStringified.rfsMarkerWrapper;
        this.giQuestionId = currentRow.id;
        this.questionType = currentRow.questionType;
        this.isGoldenEarselected = currentRow.goldenSilence;
        this.setGoldenEarProperty(this.isGoldenEarselected);
        this.greenSheetGettingInformatioDescription = currentRow.question;
        this.gettingInfoQList = this.gettingInfoQList.filter(ele => {
            return ele.id !== this.giQuestionId;
        });
        this.setTextAsQuestionType(currentRow.questionType);
        if (currentRow.questionType === this.label.newInformation) {
            this.newInformationbuttonSelected = "true";
        } else if (currentRow.questionType === this.label.attitude) {
            this.attitudebuttonSelected = "true";
        } else if (currentRow.questionType === this.label.confirmation) {
            this.confirmationbuttonSelected = "true";
        }
        // eslint-disable-next-line
        setTimeout(() => {
            this.handlescroll1();
        }, 200);
        // eslint-enable-next-line
    }

    handleToggleSection() {
        this.isGoldenEarselected = !this.isGoldenEarselected;
        this.setGoldenEarProperty(this.isGoldenEarselected);
    }

    setGoldenEarProperty(isSelected) {
        if (isSelected) {
            this.goldeEarClass = "golden-icon-selected";
            this.goldenEar = goldenEarColorFill;
        } else {
            this.goldenEar = goldenEarColor;
            this.goldeEarClass = "golden-icon-non-selected";
        }
    }

    handleDescription(event) {
        this.greenSheetGettingInformatioDescription = event.target.value;
        let descriptionLimit = event.target.value;
        if (descriptionLimit.length > 32000) {
            this.showMaxLimitError = true;
            this.disableSaveButton = true;
        } else {
            this.showMaxLimitError = false;
            this.disableSaveButton = false;
        }

        if (!descriptionLimit || descriptionLimit.length < 1) {
            this.disableSaveButton = true;
        }
    }
    handleRefresh() {
        this.setDefaultForm();
        this.getGIAccess();
        this.getGIData();
        this.gettingInfoQList = [];
    }

    setDefaultForm() {
        this.disableAddButton = false;
        this.goldenEar = goldenEarColor;
        this.goldeEarClass = "golden-icon-non-selected";

        this.newInformationSelected = "slds-button selectedbutton buttonBorder button-selected";
        this.attitudeSelected = "slds-button selectedbutton buttonBorder";
        this.confirmationSelected = "slds-button selectedbutton buttonBorder";

        this.questionType = this.label.newInformation;
        this.labelLeftLabel = this.label.newInformationQuestionsleftLabel;
        this.labelData.descriptionHeading = this.label.newInformationQuestion;
        this.labelData.descriptionPlaceholder = this.label.newInformationQuestionPlaceholder;
        this.labelData.leftLabel = this.label.newInformationQuestionsleftLabel;
        this.labelData.useWhen.label = "";
        this.labelData.useWhen.bulletPoint = [
            this.label.newInformationQuestionBullet1,
            this.label.newInformationQuestionBullet2
        ];
        this.labelData.keyWords = this.label.newInformationQuestionKeywords;
        this.greenSheetGettingInformatioDescription = null;
        this.rfsDetails = this.getNewRfsDetails();
    }
}