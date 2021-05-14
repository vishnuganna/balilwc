import { LightningElement, api, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getBasicIssueRecords from "@salesforce/apex/BasicIssues.getBasicIssueRecords";
import checkAccess from "@salesforce/apex/BasicIssues.getBasicIssueAccess";
import removeBasicIssueRecords from "@salesforce/apex/BasicIssues.removeBasicIssueRecords";
import upsertBasicIssueRecords from "@salesforce/apex/BasicIssues.upsertBasicIssueRecords";
import basicIssueAddQuestion from "@salesforce/label/c.basicIssueAddQuestion";
import basicIssue from "@salesforce/label/c.basicIssue";
import questionType from "@salesforce/label/c.questionType";
import useWhen from "@salesforce/label/c.useWhen";
import keyWords from "@salesforce/label/c.keyWords";
import save from "@salesforce/label/c.save";
import cancel from "@salesforce/label/c.cancel";
import Close from "@salesforce/label/c.close";
import editLabel from "@salesforce/label/c.edit";
import deleteLabel from "@salesforce/label/c.delete";
import deleteBasicIssueLabel from "@salesforce/label/c.deleteBasicIssueLabel";
import deleteBasicIssueMessage from "@salesforce/label/c.deleteBasicIssueMessage";
import ErrorDeleteFailed from "@salesforce/label/c.ErrorDeleteFailed";
import Record_delete_message from "@salesforce/label/c.Record_delete_message";
import Yes from "@salesforce/label/c.yes";
import Record_Error_Message from "@salesforce/label/c.Record_error_message";
import Error_Header from "@salesforce/label/c.error_header";
import Success_header from "@salesforce/label/c.success_header";
import Record_Success_Message from "@salesforce/label/c.Record_success_message";
import Description_cannot_exceed_32k_characters from "@salesforce/label/c.maxLimitError";
import basicIssueQuestion from "@salesforce/label/c.basicIssueQuestion";
import basicIssueQuestionleftLabel from "@salesforce/label/c.basicIssueQuestionleftLabel";
import basicIssueQuestionPlaceholder from "@salesforce/label/c.basicIssueQuestionPlaceholder";
import basicIssuePlaceholder from "@salesforce/label/c.basicIssuePlaceholder";
import basicIssueBullet1 from "@salesforce/label/c.basicIssueBullet1";
import basicIssueBullet2 from "@salesforce/label/c.basicIssueBullet2";
import basicIssueBullet3 from "@salesforce/label/c.basicIssueBullet3";
import basicIssueKeywords from "@salesforce/label/c.basicIssueKeywords";

export default class BasicIssues extends LightningElement {
    @api recordId;
    parentId;
    @api
    get getIdFromParent() {
        return this.parentId;
    }
    set getIdFromParent(value) {
        this.parentId = value;
        this.getBasicIssueAccess();
    }

    @track label = {
        basicIssue,
        basicIssueQuestion,
        basicIssueAddQuestion,
        questionType,
        Success_header,
        Record_Success_Message,
        Record_Error_Message,
        Error_Header,
        useWhen,
        keyWords,
        save,
        cancel,
        Yes,
        Close,
        editLabel,
        deleteLabel,
        deleteBasicIssueLabel,
        deleteBasicIssueMessage,
        Record_delete_message,
        ErrorDeleteFailed,
        Description_cannot_exceed_32k_characters,
        basicIssueQuestionleftLabel,
        basicIssueQuestionPlaceholder,
        basicIssuePlaceholder,
        basicIssueBullet1,
        basicIssueBullet2,
        basicIssueKeywords,
        basicIssueBullet3
    };

    labelData = {
        descriptionHeading: this.label.basicIssue,
        descriptionPlaceholder: this.label.basicIssuePlaceholder,
        leftLabel: this.label.basicIssueQuestionleftLabel,
        useWhen: {
            label: "",
            bulletPoint: [this.label.basicIssueBullet1, this.label.basicIssueBullet2, this.label.basicIssueBullet3]
        },
        keyWords: this.label.basicIssueKeywords
    };

    @track isCreateable;
    @track showSavedState = true;
    @track isUpdateable;
    @track isDeletable;
    @track questionTypeLabel = this.label.basicIssue;
    @track questionTypePlaceholder = this.label.basicIssuePlaceholder;
    @track isAddNewQuestion = false;
    @track showDeleteModal = false;
    @track disableSaveButton = true;
    @track disableAddButton = false;
    @track summarySelectedtypeCss = "icon-for-button";
    @track labelLeftLabel = this.label.basicIssueQuestionleftLabel;
    @track rfsDetails = this.getNewRfsDetails();
    @track questionType = this.label.basicIssue;
    @track basIssQuestionId = null;
    @track basicIssueSelected = "slds-button selectedbutton buttonBorder";
    @track basicIssueQuestSelected = "slds-button selectedbutton buttonBorder";
    @track basicIssueDescription;
    @track showMaxLimitError = false;
    @track isSaveDisabled = true;
    @track basicIssueQList = [];
    @track addingLable = "slds-m-left_none";

    connectedCallback() {
        this.getBasicIssueAccess();
        this.getBasicIssueData();
    }

    getNewRfsDetails() {
        return {
            IssueQuestionType: {
                redFlagSelected: false,
                strengthSelected: false,
                noneSelected: true,
                fieldApiName: "IssueQuestionType"
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

    getBasicIssueAccess() {
        checkAccess().then(result => {
            this.isCreateable = result.isCreateable;
            this.isUpdateable = result.isUpdateable;
            this.isDeletable = result.isDeletable;
        });
    }

    getBasicIssueData() {
        getBasicIssueRecords({ greenSheetId: this.getIdFromParent }).then(res => {
            //console.log("In Get");
            this.basicIssueQList = res;
            if (!this.basicIssueQList.length) {
                this.nobasicIssueQListData = true;
                this.checkNoDataAndReadOnlyAccess = !this.isCreateable;
            } else {
                this.basicIssueQList.forEach(basIss => {
                    basIss.rfsMarkerWrapper = this.convertMarkerMap(basIss.rfsMarkerWrapper);
                });
            }
        });
    }

    AddNewQuestion() {
        this.isAddNewQuestion = true;
        this.showSavedState = false;
        this.disableAddButton = true;
        this.disableSaveButton = true;
        this.showDeleteModal = false;
        this.initializeVariables();
    }

    initializeVariables() {
        this.basicIssueDescription = "";
        this.questionType = this.label.basicIssue;
        this.basIssQuestionId = null;
        this.rfsDetails = this.getNewRfsDetails();
        this.basicIssuebuttonSelected = true;
        this.basicIssueQuestbuttonSelected = false;
        this.basicIssueSelected = "slds-button selectedbutton buttonBorder button-selected";
        this.basicIssueQuestSelected = "slds-button selectedbutton buttonBorder";
    }

    handlescroll1(a) {
        if (this.basicIssueQList.length > 5) {
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

    handleCancelClick() {
        this.isAddNewQuestion = false;
        this.showSavedState = true;
        this.showDeleteModal = false;
        this.disableAddButton = false;
        this.disableSaveButton = true;
        this.setDefaultForm();
    }

    handleSave() {
        this.disableSaveButton = true;
        let basicIssueQuestions = {
            question: this.basicIssueDescription,
            questionType: this.questionType,
            greenSheet: this.getIdFromParent,
            id: this.basIssQuestionId
        };
        upsertBasicIssueRecords({
            basicIssueQuestions: JSON.stringify(basicIssueQuestions),
            rfsMap: this.rfsDetails
        })
            .then(() => {
                this.disableAddButton = false;
                this.showSavedState = true;
                this.isAddNewQuestion = false;
                this.getBasicIssueData();
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.label.Success_header,
                        message: this.label.Record_Success_Message,
                        variant: this.label.Success_header
                    })
                );
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

        this.handleRefresh();
    }

    deleteModal(event) {
        this.deleteRecordId = event.currentTarget.value;
        this.showDeleteModal = true;
    }

    handleDelete() {
        removeBasicIssueRecords({ recordId: this.deleteRecordId })
            .then(() => {
                this.showDeleteModal = false;
                this.showSavedState = true;
                this.getBasicIssueData();
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
                        title: this.label.ErrorDeleteFailed,
                        message: error.body.message,
                        variant: this.label.Error_Header
                    })
                );
            });

        this.handleRefresh();
    }

    closeModal() {
        this.showDeleteModal = false;
    }

    handleQuestionType(event) {
        if (event.currentTarget.dataset.targetId === "BasicIssue") {
            this.labelData.descriptionHeading = this.label.basicIssue;
            this.addingLable = "slds-m-left_none";
            this.basicIssueSelected = "slds-button selectedbutton buttonBorder button-selected";
            this.basicIssueQuestSelected = "slds-button selectedbutton buttonBorder";
            this.labelData.descriptionPlaceholder = this.label.basicIssuePlaceholder;
            this.questionType = this.label.basicIssue;
        } else if (event.currentTarget.dataset.targetId === "BasicIssueQuestion") {
            this.questionType = this.label.basicIssueQuestion;
            this.labelData.descriptionHeading = this.label.basicIssueQuestion;
            this.addingLable = "slds-m-left_none";
            this.basicIssueSelected = "slds-button selectedbutton buttonBorder";
            this.basicIssueQuestSelected = "slds-button selectedbutton buttonBorder button-selected";
            this.labelData.descriptionPlaceholder = this.label.basicIssueQuestionPlaceholder;
        }
    }

    handleEdit(event) {
        let currentRow = event.currentTarget.value;
        this.isAddNewQuestion = true;
        this.showSavedState = false;
        this.disableAddButton = true;
        this.disableSaveButton = false;
        let currentRowStringified = JSON.parse(JSON.stringify(currentRow));
        this.rfsDetails = currentRowStringified.rfsMarkerWrapper;
        this.basIssQuestionId = currentRow.id;
        this.questionType = currentRow.questionType;
        this.basicIssueDescription = currentRow.question;

        if (currentRow.questionType === this.label.basicIssue) {
            this.basicIssuebuttonSelected = "true";
            this.basicIssueSelected = "slds-button selectedbutton buttonBorder button-selected";
            this.basicIssueQuestSelected = "slds-button selectedbutton buttonBorder";
            this.addingLable = "slds-m-left_none";
        } else if (currentRow.questionType === this.label.basicIssueQuestion) {
            this.addingLable = "slds-m-left_none";
            this.basicIssueQuestbuttonSelected = "true";
            this.basicIssueQuestSelected = "slds-button selectedbutton buttonBorder button-selected";
            this.basicIssueSelected = "slds-button selectedbutton buttonBorder";
        }
        // eslint-disable-next-line
        setTimeout(() => {
            this.handlescroll1();
        }, 200);
        // eslint-enable-next-line
    }

    handleDescription(event) {
        this.basicIssueDescription = event.target.value;
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
        this.getBasicIssueAccess();
        this.gettingInfoQList = [];
        this.setDefaultForm();
    }

    setDefaultForm() {
        this.disableAddButton = false;
        this.basicIssueSelected = "slds-button selectedbutton buttonBorder button-selected";
        this.basicIssueQuestSelected = "slds-button selectedbutton buttonBorder";
        this.questionType = this.label.basicIssue;
        this.labelLeftLabel = this.label.basicIssueQuestionleftLabel;
        this.labelData.descriptionHeading = this.label.basicIssue;
        this.labelData.descriptionPlaceholder = this.label.basicIssuePlaceholder;
        this.labelData.leftLabel = this.label.basicIssueQuestionleftLabel;
        this.labelData.useWhen.label = "";
        this.labelData.useWhen.bulletPoint = [
            this.label.basicIssueBullet1,
            this.label.basicIssueBullet2,
            this.label.basicIssueBullet3
        ];
        this.labelData.keyWords = this.label.basicIssueKeywords;
        this.basicIssueDescription = null;
        this.rfsDetails = this.getNewRfsDetails();
    }
}