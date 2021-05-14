import { LightningElement, api, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import edit from "@salesforce/label/c.edit";
import showMore from "@salesforce/label/c.showMore";
import showLess from "@salesforce/label/c.showLess";
import ErrorMax32kCharacters from "@salesforce/label/c.maxLimitError";
import save from "@salesforce/label/c.save";
import cancel from "@salesforce/label/c.cancel";
import Yes from "@salesforce/label/c.yes";
import Required_Field_Missing from "@salesforce/label/c.Required_Field_Missing";
import error_header from "@salesforce/label/c.error_header";
import success_header from "@salesforce/label/c.success_header";
import Record_error_message from "@salesforce/label/c.Record_error_message";
import Record_success_message from "@salesforce/label/c.Record_success_message";
import getGettingCommitmentData from "@salesforce/apex/GettingCommitment.getGettingCommitmentData";
import upsertCommitmentQuestion from "@salesforce/apex/GettingCommitment.upsertCommitmentQuestion";
import upsertBestActionCommitment from "@salesforce/apex/GettingCommitment.upsertBestActionCommitment";
import upsertMinimumActionCommitment from "@salesforce/apex/GettingCommitment.upsertMinimumActionCommitment";
import deleteCommitmentQuestion from "@salesforce/apex/GettingCommitment.deleteCommitmentQuestion";
import deleteBestActionCommitment from "@salesforce/apex/GettingCommitment.deleteBestActionCommitment";
import deleteMinimumActionCommitment from "@salesforce/apex/GettingCommitment.deleteMinimumActionCommitment";
import checkAccessGetCommACT from "@salesforce/apex/GettingCommitment.getGettingCommitmentAccess";
import deleteBuyingInfluence from "@salesforce/label/c.deleteBuyingInfluence";
import deleteBuyingInfluenceMessage from "@salesforce/label/c.deleteBuyingInfluenceMessage";
import RecordDeleted from "@salesforce/label/c.RecordDeleted";
import GSGetting_CommitmentURL from "@salesforce/label/c.GSGetting_CommitmentURL";
import GSBestActionURL from "@salesforce/label/c.GSBestActionURL";
import GSMinimum_Acceptance_Comm_URL from "@salesforce/label/c.GSMinimum_Acceptance_Comm_URL";
import GSGetting_Commitment from "@salesforce/label/c.GSGetting_Commitment";
import GSBest_Action_Commitment from "@salesforce/label/c.GSBest_Action_Commitment";
import GSMinimum_Acceptance_Comm from "@salesforce/label/c.GSMinimum_Acceptance_Comm";
import GSCommitment_Question from "@salesforce/label/c.GSCommitment_Question";
import GSAdd_Comm_Quest from "@salesforce/label/c.GSAdd_Comm_Quest";
import GSCommitment from "@salesforce/label/c.GSCommitment";
import GSQuestion from "@salesforce/label/c.GSQuestion";
import GSDelete_Commitment from "@salesforce/label/c.GSDelete_Commitment";
import GSDelete_Commitment_Prompt from "@salesforce/label/c.GSDelete_Commitment_Prompt";
import Create from "@salesforce/label/c.Create";
import Delete from "@salesforce/label/c.delete";
import Success from "@salesforce/label/c.Success";
import DefaultStyle from "@salesforce/label/c.DefaultStyle";
import NodataAdded from "@salesforce/label/c.NodataAdded";
import close from "@salesforce/label/c.close";
import GSBestACTPromptText from "@salesforce/label/c.GSBestACTPromptText";
import GSMiniQuestPromptText from "@salesforce/label/c.GSMiniQuestPromptText";
import GSCommitQuestPromptText from "@salesforce/label/c.GSCommitQuestPromptText";

export default class GettingCommitment extends LightningElement {
    @api getIdFromParent;
    showEditView = false;
    ShowModal = false;
    ShowMoreText = false;
    ShowLessText = false;
    showText = false;
    @track isCreateable = false;
    @track isUpdateable = false;
    @track isDeletable = false;
    @track disableAddButton = false;
    @track showMaxLimitError = false;
    @track newRecordScreenFlag = false;
    @track saveDisableFlag = true;
    @track greenGettingCommList = [];
    @track greenMinActCommList = [];
    @track saveDisableBestACTFlag = true;
    @track newRecordScreenBestACTFlag = false;
    @track newRecordScreenMinACTFlag = false;
    @track minimumActCommitment = false;
    @track saveDisableMinACTFlag = true;
    @track saveDisableCommQuestFlag = false;
    @track newRecordScreenCommQuestFlag = false;
    @track createDisableBestACTFlag = false;
    @track createDisableMinACTFlag = false;
    @track addDisableCommQuestFlag = false;
    @track noDataPresentFlag = false;
    @track ShowDeleteModal = false;
    @track ShowDeleteMinActModal = false;
    @track deleteRecordId;
    @track bestActCommitment;
    @track minimumActCommitment;
    @track commitmentQuest;
    @track getCommId = null;
    @track bestActEditDeleteFlag = false;
    @track minActEditDeleteFlag = false;
    @track noBestActDataFlag = false;
    @track noMinActDataFlag = false;
    @track showUI = false;
    @track rfsDetails = this.getNewRfsDetails();
    @track question;
    @track questionId;
    @track commitmentId;
    @track ShowQuestionDeleteModal = false;
    @track deleteQuestId;
    @track temparray = [];
    @track bestactiondescriptionvalue = "";
    @track minactiondescriptionvalue = "";

    allLabel = {
        edit,
        showMore,
        showLess,
        Record_error_message,
        Record_success_message,
        ErrorMax32kCharacters,
        Required_Field_Missing,
        save,
        cancel,
        success_header,
        deleteBuyingInfluence,
        deleteBuyingInfluenceMessage,
        error_header,
        Yes,
        RecordDeleted,
        GSGetting_CommitmentURL,
        GSBestActionURL,
        GSMinimum_Acceptance_Comm_URL,
        GSGetting_Commitment,
        GSBest_Action_Commitment,
        GSMinimum_Acceptance_Comm,
        GSCommitment_Question,
        GSAdd_Comm_Quest,
        GSCommitment,
        GSQuestion,
        GSDelete_Commitment,
        GSDelete_Commitment_Prompt,
        Create,
        Delete,
        Success,
        DefaultStyle,
        NodataAdded,
        close,
        GSBestACTPromptText,
        GSMiniQuestPromptText,
        GSCommitQuestPromptText
    };

    handleMaxLimitError() {}
    handleQuestionChange(event) {
        this.question = event.target.value;

        if (this.question && this.question.length === 32000) {
            this.showMaxLimitError = true;
        } else {
            this.showMaxLimitError = false;
        }
        if (this.question && this.question.length > 0) {
            this.saveDisableFlag = false;
        } else {
            this.saveDisableFlag = true;
        }
    }

    handleBestACTDesc(event) {
        this.bestActCommitment = event.target.value;
        let bestActCommitmentLimit = event.target.value;
        if (bestActCommitmentLimit.length > 32000) {
            this.saveDisableBestACTFlag = true;
        } else {
            this.saveDisableBestACTFlag = false;
        }

        if (!bestActCommitmentLimit || bestActCommitmentLimit.length < 1) {
            this.saveDisableBestACTFlag = true;
        }
    }

    handleMinComitDesc(event) {
        this.minimumActCommitment = event.target.value;
        let minimumActCommitmentLimit = event.target.value;
        if (minimumActCommitmentLimit.length > 32000) {
            this.saveDisableMinACTFlag = true;
        } else {
            this.saveDisableMinACTFlag = false;
        }

        if (!minimumActCommitmentLimit || minimumActCommitmentLimit.length < 1) {
            this.saveDisableMinACTFlag = true;
        }
    }
    handlecommitQuestDesc(event) {
        this.question = event.target.value;
        let questionLimit = event.target.value;
        if (questionLimit.length > 32000) {
            this.saveDisableFlag = true;
        } else {
            this.saveDisableFlag = false;
        }

        if (!questionLimit || questionLimit.length < 1) {
            this.saveDisableFlag = true;
        }
    }

    connectedCallback() {
        this.getBestActData();
        this.getCommitmentData();
    }

    getBestActData() {
        checkAccessGetCommACT().then(result => {
            this.isCreateable = result.isCreateable;
            this.isUpdateable = result.isUpdateable;
            this.isDeletable = result.isDeletable;
        });
        getGettingCommitmentData({ greenSheetId: this.getIdFromParent }).then(result => {
            this.greenGettingCommList = result;

            this.greenGettingCommList.forEach(bi => {
                bi.rfsMarkerWrapper = this.convertMarkerMap(bi.rfsMarkerWrapper);

                if (bi.bestActionCommitment === undefined) {
                    this.bestActEditDeleteFlag = false;
                    this.noBestActDataFlag = true;
                } else {
                    this.bestActEditDeleteFlag = true;
                    this.noBestActDataFlag = false;
                }

                if (bi.acceptableActionCommitment === undefined) {
                    this.minActEditDeleteFlag = false;
                    this.noMinActDataFlag = true;
                } else {
                    this.minActEditDeleteFlag = true;
                    this.noMinActDataFlag = false;
                }
            });
        });
    }

    handlescroll1(a) {
        if (this.temparray.length >= 3) {
            if (a) {
                let articale = this.template.querySelector(".BestActHeight");
                let articale1 = this.template.querySelector(".BestActHeight1");
                let articale2 = this.template.querySelector(".heightCount");
                a.classList.add("scroll1");
                a.style.maxHeight = articale.clientHeight + articale1.clientHeight + articale2.clientHeight - 1 + "px";
            }
        } else {
            a.classList.remove("scroll1");
            a.style.maxHeight = "auto";
        }
    }

    renderedCallback() {
        this.scrollcontainer = this.template.querySelector(".scroll");

        // eslint-disable-next-line
        setTimeout(() => {
            this.handlescroll1(this.scrollcontainer);
        }, 0);
        // eslint-enable-next-line
    }

    handleBestACTChange(event) {
        this.bestActCommitment = event.target.value;
        if (this.bestActCommitment && this.bestActCommitment.length === 32000) {
            this.showMaxLimitError = true;
        } else {
            this.showMaxLimitError = false;
        }
        if (this.bestActCommitment && this.bestActCommitment.length > 0) {
            this.saveDisableBestACTFlag = false;
        } else {
            this.saveDisableBestACTFlag = true;
        }
    }

    handleMinACTChange(event) {
        this.minimumActCommitment = event.target.value;

        if (this.minimumActCommitment && this.minimumActCommitment.length === 32000) {
            this.showMaxLimitError = true;
        } else {
            this.showMaxLimitError = false;
        }
        if (this.minimumActCommitment && this.minimumActCommitment.length > 0) {
            this.saveDisableMinACTFlag = false;
        } else {
            this.saveDisableMinACTFlag = true;
        }
    }

    handleCancelMinACTClick() {
        this.showMaxLimitError = false;
        this.newRecordScreenMinACTFlag = false;
        this.createDisableMinACTFlag = false;
        this.addDisableCommQuestFlag = false;
        //
        this.createDisableBestACTFlag = false;
        this.editDisableBestACTFlag = false;
        this.deleteDisableBestACTFlag = false;
        this.editDisableCommQuestFlag = false;
        this.deleteDisableCommQuestFlag = false;
        //
        this.handleRefresh();
    }

    getNewRfsDetails() {
        return {
            bestActionCommitment: {
                redFlagSelected: false,
                strengthSelected: false,
                noneSelected: true,
                fieldApiName: "bestActionCommitment"
            },
            minimumActionCommitment: {
                redFlagSelected: false,
                strengthSelected: false,
                noneSelected: true,
                fieldApiName: "minimumActionCommitment"
            },
            commitmentQuestions: {
                redFlagSelected: false,
                strengthSelected: false,
                noneSelected: true,
                fieldApiName: "commitmentQuestions"
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
        const markers = rfsMarkerWrapper;
        const markersMap = this.getNewRfsDetails();
        markers.forEach(marker => {
            markersMap[marker.fieldApiName] = marker;
        });
        return markersMap;
    }

    handleDeleteModal(event) {
        this.showMaxLimitError = false;

        this.ShowDeleteModal = true;
        this.deleteRecordId = event.currentTarget.value;
    }

    handleDeleteMinActModal(event) {
        this.showMaxLimitError = false;

        this.ShowDeleteMinActModal = true;
        this.deleteRecordId = event.currentTarget.value;
    }

    closeModal() {
        this.ShowDeleteModal = false;
    }

    closeMinActModal() {
        this.ShowDeleteMinActModal = false;
    }

    closeQuestionDeleteModal() {
        this.ShowQuestionDeleteModal = false;
    }

    handlebestActDelete() {
        deleteBestActionCommitment({ greenSheetId: this.getIdFromParent })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.allLabel.success_header,
                        message: this.allLabel.RecordDeleted,
                        variant: this.allLabel.success_header
                    })
                );
                this.bestactiondescriptionvalue = "";

                this.ShowDeleteModal = false;
                this.handleRefresh();
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.allLabel.ErrorDeleteFailed,
                        message: error.body.message,
                        variant: this.allLabel.Error_Header
                    })
                );
            });
    }

    handleMinActDelete() {
        deleteMinimumActionCommitment({ greenSheetId: this.getIdFromParent })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.allLabel.success_header,
                        message: this.allLabel.RecordDeleted,
                        variant: this.allLabel.success_header
                    })
                );
                this.minactiondescriptionvalue = "";

                this.ShowDeleteMinActModal = false;

                this.handleRefresh();
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.allLabel.ErrorDeleteFailed,
                        message: error.body.message,
                        variant: this.allLabel.Error_Header
                    })
                );
            });
    }

    handleCancelBestACTClick() {
        this.showMaxLimitError = false;
        this.newRecordScreenBestACTFlag = false;
        this.createDisableBestACTFlag = false;
        this.addDisableCommQuestFlag = false;
        this.createDisableMinACTFlag = false;
        this.editDisableMinACTFlag = false;
        this.deleteDisableMinACTFlag = false;
        this.editDisableCommQuestFlag = false;
        this.deleteDisableCommQuestFlag = false;
        this.handleRefresh();
    }

    handleSaveBestACTClick() {
        this.showMaxLimitError = false;

        let bestcommitmentDataToSave = {
            id: this.getCommId,
            bestActionCommitment: this.bestActCommitment,
            greenSheet: this.getIdFromParent
        };

        upsertBestActionCommitment({ jsonString: JSON.stringify(bestcommitmentDataToSave), rfsMap: this.rfsDetails })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.allLabel.success_header,
                        message: this.allLabel.Record_success_message,
                        variant: this.allLabel.success_header
                    })
                );
                this.handleRefresh();
                this.getCommId = "";
                this.bestActCommitment = "";
                this.newRecordScreenBestACTFlag = false;
                this.createDisableBestACTFlag = false;
                this.saveDisableBestACTFlag = false;
                this.addDisableCommQuestFlag = false;
                this.createDisableMinACTFlag = false;
                this.editDisableMinACTFlag = false;
                this.deleteDisableMinACTFlag = false;
                this.editDisableCommQuestFlag = false;
                this.deleteDisableCommQuestFlag = false;
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.allLabel.Record_error_message,
                        message: error.body.message,
                        variant: this.allLabel.error_header
                    })
                );
            });
    }

    handleEditQuestion(event) {
        this.newRecordScreenCommQuestFlag = true;
        this.disableSaveButton = false;
        let currentRow = event.currentTarget.value;
        this.addDisableCommQuestFlag = true;
        this.saveDisableFlag = false;
        this.createDisableBestACTFlag = true;
        this.editDisableBestACTFlag = true;
        this.deleteDisableBestACTFlag = true;
        this.createDisableMinACTFlag = true;
        this.editDisableMinACTFlag = true;
        this.deleteDisableMinACTFlag = true;
        this.editDisableCommQuestFlag = true;
        this.deleteDisableCommQuestFlag = true;
        this.questionId = currentRow.id;
        this.question = currentRow.commitmentQuestion;
        this.greenGettingCommList[0].questionWrapperList = this.greenGettingCommList[0].questionWrapperList.filter(
            ele => {
                return ele.id !== this.questionId;
            }
        );

        this.temparray = [];
        this.greenGettingCommList[0].questionWrapperList.forEach(bi => {
            const obj = { ...bi };
            obj.rfsMarkerWrapper = this.convertMarkerMap(bi.rfsMarkerWrapper);
            this.temparray.push(obj);
        });
    }

    handleBestActEdit(event) {
        this.newRecordScreenBestACTFlag = true;
        this.disableSaveButton = false;
        this.addDisableCommQuestFlag = true;
        this.saveDisableBestACTFlag = false;
        this.createDisableMinACTFlag = true;
        this.editDisableMinACTFlag = true;
        this.deleteDisableMinACTFlag = true;
        this.editDisableCommQuestFlag = true;
        this.deleteDisableCommQuestFlag = true;

        let currentRow = event.currentTarget.value;
        let currentRowStringified = JSON.parse(JSON.stringify(currentRow));

        this.rfsDetails = currentRowStringified.rfsMarkerWrapper;
        this.getCommId = currentRow.id;

        this.greenGettingCommList = this.greenGettingCommList.filter(ele => {
            return ele.id !== this.getCommId;
        });

        this.bestActCommitment = currentRow.bestActionCommitment;
        // eslint-disable-next-line
        setTimeout(() => {
            this.handleScroll();
        }, 200);
        // eslint-enable-next-line
    }

    handleMinActEdit(event) {
        this.newRecordScreenMinACTFlag = true;
        this.saveDisableMinACTFlag = false;
        this.addDisableCommQuestFlag = true;
        this.createDisableBestACTFlag = true;
        this.editDisableBestACTFlag = true;
        this.deleteDisableBestACTFlag = true;
        this.editDisableCommQuestFlag = true;
        this.deleteDisableCommQuestFlag = true;
        let currentRow = event.currentTarget.value;
        let currentRowStringified = JSON.parse(JSON.stringify(currentRow));
        this.rfsDetails = currentRowStringified.rfsMarkerWrapper;
        this.getCommId = currentRow.id;
        this.greenGettingCommList = this.greenGettingCommList.filter(ele => {
            return ele.id !== this.getCommId;
        });

        this.minimumActCommitment = currentRow.acceptableActionCommitment;
        // eslint-disable-next-line
        setTimeout(() => {
            this.handleScroll();
        }, 200);
        // eslint-enable-next-line
    }

    handleSaveMinACTClick() {
        this.showMaxLimitError = false;

        let mincommitmentDataToSave = {
            id: this.getCommId,
            acceptableActionCommitment: this.minimumActCommitment,
            greenSheet: this.getIdFromParent
        };

        upsertMinimumActionCommitment({ jsonString: JSON.stringify(mincommitmentDataToSave), rfsMap: this.rfsDetails })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.allLabel.success_header,
                        message: this.allLabel.Record_success_message,
                        variant: this.allLabel.success_header
                    })
                );
                this.handleRefresh();
                this.getCommId = "";
                this.minimumActCommitment = "";
                this.newRecordScreenMinACTFlag = false;
                this.createDisableMinACTFlag = false;
                this.saveDisableMinACTFlag = false;
                this.addDisableCommQuestFlag = false;
                this.createDisableBestACTFlag = false;
                this.editDisableBestACTFlag = false;
                this.deleteDisableBestACTFlag = false;
                this.editDisableCommQuestFlag = false;
                this.deleteDisableCommQuestFlag = false;
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.allLabel.Record_error_message,
                        message: error.body.message,
                        variant: this.allLabel.error_header
                    })
                );
            });
    }

    handleScroll() {
        if (this.template.querySelector(".createRecord")) {
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

    handleRefresh() {
        this.getBestActData();
        this.getCommitmentData();
    }

    handleAddNewBestACT() {
        this.newRecordScreenBestACTFlag = true;
        this.createDisableBestACTFlag = true;
        this.noBestActDataFlag = false;
        this.saveDisableBestACTFlag = true;
        this.addDisableCommQuestFlag = true;
        this.createDisableMinACTFlag = true;
        this.editDisableMinACTFlag = true;
        this.deleteDisableMinACTFlag = true;
        this.editDisableCommQuestFlag = true;
        this.deleteDisableCommQuestFlag = true;
        if (this.greenGettingCommList[0]) {
            this.rfsDetails = this.greenGettingCommList[0].rfsMarkerWrapper;
        }
        this.bestActCommitment = "";
    }

    handleAddNewMinACT() {
        this.newRecordScreenMinACTFlag = true;
        this.createDisableMinACTFlag = true;
        this.noMinActDataFlag = false;
        this.saveDisableMinACTFlag = true;
        this.addDisableCommQuestFlag = true;
        this.createDisableBestACTFlag = true;
        this.editDisableBestACTFlag = true;
        this.deleteDisableBestACTFlag = true;
        this.editDisableCommQuestFlag = true;
        this.deleteDisableCommQuestFlag = true;
        this.minimumActCommitment = "";
        if (this.greenGettingCommList[0]) {
            this.rfsDetails = this.greenGettingCommList[0].rfsMarkerWrapper;
        }
    }

    handleCancelCommQuestClick() {
        this.showMaxLimitError = false;

        this.newRecordScreenCommQuestFlag = false;
        this.addDisableCommQuestFlag = false;
        this.createDisableBestACTFlag = false;
        this.editDisableBestACTFlag = false;
        this.deleteDisableBestACTFlag = false;
        this.createDisableMinACTFlag = false;
        this.editDisableMinACTFlag = false;
        this.deleteDisableMinACTFlag = false;
        this.addDisableCommQuestFlag = false;
        this.editDisableCommQuestFlag = false;
        this.deleteDisableCommQuestFlag = false;
        this.handleRefresh();
    }
    handleAddNewCommQuest() {
        this.newRecordScreenCommQuestFlag = true;
        this.addDisableCommQuestFlag = true;
        this.saveDisableFlag = true;
        this.createDisableBestACTFlag = true;
        this.editDisableBestACTFlag = true;
        this.deleteDisableBestACTFlag = true;
        this.createDisableMinACTFlag = true;
        this.editDisableMinACTFlag = true;
        this.deleteDisableMinACTFlag = true;
        this.addDisableCommQuestFlag = true;
        this.editDisableCommQuestFlag = true;
        this.deleteDisableCommQuestFlag = true;
        this.questionId = "";
        this.question = "";
        this.rfsDetails = this.getNewRfsDetails();
    }

    handleSaveCommQuestClick() {
        this.showMaxLimitError = false;
        this.saveDisableFlag = false;

        this.addDisableCommQuestFlag = false;
        this.newRecordScreenCommQuestFlag = false;

        let questionDataToSave = {
            commitmentQuestion: this.question,
            gettingCommitment: this.commitmentId,
            id: this.questionId
        };
        upsertCommitmentQuestion({
            jsonString: JSON.stringify(questionDataToSave),
            greenSheetId: this.getIdFromParent,
            rfsMap: this.rfsDetails
        })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.allLabel.success_header,
                        message: this.allLabel.Record_Success_Message,
                        variant: this.allLabel.success_header
                    })
                );
                this.handleRefresh();
                this.createDisableBestACTFlag = false;
                this.editDisableBestACTFlag = false;
                this.deleteDisableBestACTFlag = false;
                this.createDisableMinACTFlag = false;
                this.editDisableMinACTFlag = false;
                this.deleteDisableMinACTFlag = false;
                this.addDisableCommQuestFlag = false;
                this.editDisableCommQuestFlag = false;
                this.deleteDisableCommQuestFlag = false;
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.allLabel.Record_error_message,
                        message: error.body.message,
                        variant: this.allLabel.Error_Header
                    })
                );
            });
    }

    getCommitmentData() {
        getGettingCommitmentData({ greenSheetId: this.getIdFromParent }).then(result => {
            this.temparray = [];
            this.greenGettingCommList = result;

            if (!this.greenGettingCommList.length) {
                this.noDataPresentFlag = true;
                this.commitmentId = "";
            } else {
                this.noDataPresentFlag = false;
                this.commitmentId = result.id;

                this.bestactiondescriptionvalue = this.greenGettingCommList[0].bestActionCommitment;
                this.minactiondescriptionvalue = this.greenGettingCommList[0].acceptableActionCommitment;

                this.greenGettingCommList.forEach(bi => {
                    bi.rfsMarkerWrapper = this.convertMarkerMap(bi.rfsMarkerWrapper);
                });

                this.greenGettingCommList[0].questionWrapperList.forEach(bi => {
                    const obj = { ...bi };
                    obj.rfsMarkerWrapper = this.convertMarkerMap(bi.rfsMarkerWrapper);
                    this.temparray.push(obj);
                });
            }
        });
    }
    handleDeleteQuestion(event) {
        this.ShowQuestionDeleteModal = true;
        this.deleteQuestId = event.currentTarget.value;
    }

    deleteQuestion() {
        deleteCommitmentQuestion({ recordId: this.deleteQuestId })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.allLabel.success_header,
                        message: this.allLabel.RecordDeleted,
                        variant: this.allLabel.success_header
                    })
                );
                this.ShowQuestionDeleteModal = false;
                this.handleRefresh();
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.allLabel.ErrorDeleteFailed,
                        message: error.body.message,
                        variant: this.allLabel.Error_Header
                    })
                );
            });
    }
}