import { LightningElement, track, wire, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import relatedRecord from "@salesforce/apex/RelationshipGoals.getRelatedRecords";
import getRelationshipGoal from "@salesforce/apex/RelationshipGoals.getRelationshipGoal";
import upsertRelationshipGoal from "@salesforce/apex/RelationshipGoals.upsertRelationshipGoal";
import insertRelationshipGoals from "@salesforce/apex/RelationshipGoals.insertRelationshipGoals";
import checkAccess from "@salesforce/apex/RelationshipGoals.getRelationshipGoalAccess";
import RelationshipGoals from "@salesforce/label/c.RelationshipGoals";
import RelationshipGoalsURL from "@salesforce/label/c.RelationshipGoalsURL";
import GoalName from "@salesforce/label/c.GoalName";
import Description from "@salesforce/label/c.Description";
import AddDescription from "@salesforce/label/c.AddDescription";
import GoalStatus from "@salesforce/label/c.GoalStatus";
import cancel from "@salesforce/label/c.cancel";
import save from "@salesforce/label/c.save";
import AddGoal from "@salesforce/label/c.AddGoal";
import GoalNameCannotExceed80Characters from "@salesforce/label/c.GoalNameCannotExceed80Characters";
import ErrorDescriptionTooLong from "@salesforce/label/c.ErrorDescriptionTooLong";
import Required_Field_Missing from "@salesforce/label/c.Required_Field_Missing";
import PleaseFillTheGoalNameField from "@salesforce/label/c.PleaseFillTheGoalNameField";
import Review_Error from "@salesforce/label/c.Review_Error";
import error_header from "@salesforce/label/c.error_header";
import success_header from "@salesforce/label/c.success_header";
import sort_by from "@salesforce/label/c.sort_by";
import Record_error_message from "@salesforce/label/c.Record_error_message";
import Record_success_message from "@salesforce/label/c.Record_success_message";
import getGoalStatusPicklistValues from "@salesforce/apex/RelationshipGoals.getGoalStatusPicklistValues";
import { loadStyle } from "lightning/platformResourceLoader";
import styles from "@salesforce/resourceUrl/cssLibrary";
import FocusInvestment from "@salesforce/label/c.FocusInvestment";
import StopInvestmentHeader from "@salesforce/label/c.StopInvestmentHeader";
import ActionHeader from "@salesforce/label/c.ActionHeader";
import InformationNeededDisplay from "@salesforce/label/c.InformationNeededDisplay";
import InvestmentProgram from "@salesforce/label/c.InvestmentProgram";
import Amount from "@salesforce/label/c.Amount";
import Status from "@salesforce/label/c.Status";
import Source from "@salesforce/label/c.Source";
import Who from "@salesforce/label/c.Who";
import DateDue from "@salesforce/label/c.DateDue";
import FilterByKeyword from "@salesforce/label/c.FilterByKeyword";
import SelectActivityType from "@salesforce/label/c.SelectActivityType";
import LinkRelatedActivity from "@salesforce/label/c.LinkRelatedActivity";
import RelatedActivities from "@salesforce/label/c.RelatedActivities";
import LinkRelatedActivities from "@salesforce/label/c.LinkRelatedActivities";
import SelectOneOrMoreActivityTypes from "@salesforce/label/c.SelectOneOrMoreActivityTypes";
import foInvDate_Created from "@salesforce/label/c.foInvDate_Created";
import foInvStatusIncomplete from "@salesforce/label/c.foInvStatusIncomplete";
import foInvStatusComplete from "@salesforce/label/c.foInvStatusComplete";
import foInvAmount from "@salesforce/label/c.foInvAmount";
import InvestmentProgramDueDate from "@salesforce/label/c.InvestmentProgramDueDate";
import Success from "@salesforce/label/c.Success";
import DefaultStyle from "@salesforce/label/c.DefaultStyle";
import Remove from "@salesforce/label/c.Remove";

const columns = [{ label: "", fieldName: "Name", wrapText: true }];
export default class RelationshipGoalForm extends LightningElement {
    data = [];
    clickeditems = [];
    tempArray = [];
    @api selectedRows;
    @api selectedActivities = [];
    @track actvityName = "";
    columns = columns;
    @track goalStatusPicklist = [];
    @track checkNoDataAndReadOnlyAccess = false;
    @wire(getGoalStatusPicklistValues)
    goalStatuspicklistResult({ data }) {
        if (data) {
            const result = JSON.parse(data);
            for (let key in result) {
                if (result.hasOwnProperty(key)) {
                    this.goalStatusPicklist.push({ label: key, value: result[key] }); //Here we are creating the array to show on UI.
                }
            }
            this.goalStatusPicklist.reverse();
        }
    }

    @track boolVisible = false;
    @track btnflag = false;
    @api recordId;
    @track goalStatusValue = "Incomplete";
    @track goalName;
    @track Description;
    @track goldsheetId;
    @api getIdFromParent;
    @api objectApiName;
    @track relationshipGoalsData;
    @track selectedRecordId;
    @api item;
    @track validationcheck = false;
    @track relationshipGoalValues = [];
    @track isCreateable = false;
    @track isDeletable = false;
    @track isUpdatable = false;
    @track sortFilter;
    @track isModalOpen = false;
    @track focusCss = "slds-button slds-button_neutral slds-m-left_x-small";
    @track stopCss = "slds-button slds-button_neutral slds-m-left_x-small";
    @track actionCss = "slds-button slds-button_neutral slds-m-left_x-small";
    @track informationCss = "slds-button slds-button_neutral slds-m-left_x-small";
    @track investmentCss = "slds-button slds-button_neutral slds-m-left_x-small";
    @track focusSelected = false;
    @track stopSelected = false;
    @track actionSelected = false;
    @track infoSelected = false;
    @track investSelected = false;
    @track isSaveDisabled = true;
    @track isValidate = false;
    @track isButtonDisabled = true;

    label = {
        Record_success_message,
        PleaseFillTheGoalNameField,
        Required_Field_Missing,
        Review_Error,
        success_header,
        Record_error_message,
        RelationshipGoals,
        RelationshipGoalsURL,
        error_header,
        GoalName,
        Description,
        AddDescription,
        GoalStatus,
        cancel,
        save,
        sort_by,
        AddGoal,
        GoalNameCannotExceed80Characters,
        ErrorDescriptionTooLong,
        StopInvestmentHeader,
        FocusInvestment,
        ActionHeader,
        InvestmentProgram,
        LinkRelatedActivities,
        RelatedActivities,
        LinkRelatedActivity,
        SelectActivityType,
        FilterByKeyword,
        DateDue,
        Who,
        Source,
        Status,
        Amount,
        InformationNeededDisplay,
        SelectOneOrMoreActivityTypes,
        foInvDate_Created, //KFS-2766
        foInvStatusIncomplete, //KFS-2766
        foInvStatusComplete, //KFS-2766
        foInvAmount,
        InvestmentProgramDueDate,
        Success,
        DefaultStyle,
        Remove
    };

    get goalStatusPicklistValues() {
        return this.goalStatusPicklist;
    }
    get options() {
        return [
            { label: this.label.foInvDate_Created, value: "DateCreated" }, //KFS-2766
            { label: this.label.foInvStatusIncomplete, value: "Incomplete" }, //KFS-2766
            { label: this.label.foInvStatusComplete, value: "Complete" } //KFS-2766
        ];
    }

    renderedCallback() {
        loadStyle(this, styles); //specified filename
    }

    filterTableValues(event) {
        this.sortFilter = event.detail.value;
        this.handleRefresh();
    }

    connectedCallback() {
        this.goldsheetId = this.getIdFromParent;

        checkAccess().then(result => {
            this.isCreateable = result.isCreateable;
            this.isUpdateable = result.isUpdateable;
            this.isDeletable = result.isDeletable;
        });

        this.getRelationshipGoalFromBackend();
    }

    getRelationshipGoalFromBackend() {
        getRelationshipGoal({ goldsheetId: this.goldsheetId, sortFilter: this.sortFilter }).then(res => {
            this.relationshipGoalsData = res;
            checkAccess().then(result => {
                this.isCreateable = result.isCreateable;
                if (!this.relationshipGoalsData.length && !this.isCreateable) {
                    this.checkNoDataAndReadOnlyAccess = true;
                }
            });
        });
    }

    handleRefresh() {
        this.getRelationshipGoalFromBackend();
        this.handleProgress();
    }

    handleProgress() {
        const selectedEvent = new CustomEvent("updateprogressfromchild", {
            detail: true
        });
        this.dispatchEvent(selectedEvent);
    }

    getContactId(event) {
        this.selectedContactId = event.detail;
    }

    handleClick() {
        // this.selectedRows = [];
        this.boolVisible = true;
        this.btnflag = true;
        this.goalStatusValue = "";
        this.goalName = "";
        this.Description = "";
        this.selectedRecordId = "";
        this.selectedRows = "";
    }
    openAddListlookup() {
        this.openAddFromListModal = true;
    }

    isBestActionSelected(event) {
        this.isPerspectiveVisible = event.target.checked;
    }

    handleCancel() {
        // this.selectedRows = [];
        this.boolVisible = false;
        this.btnflag = false;
        this.goalStatusValue = "";
        this.goalName = "";
        this.Description = "";
        this.selectedRecordId = "";
        this.validationcheck = false;
    }

    getSelectedActionList(event) {
        this.relationshipGoalValues = event.detail.checkedValues;

        if (this.relationshipGoalValues.length === 1) {
            const element = this.template.querySelector('[data-id="action-goalName"]');
            if (element) {
                this.template.querySelector('[data-id="action-goalName"]').value = this.relationshipGoalValues[0].label;
            }
        }

        if (this.relationshipGoalValues.length > 1) {
            let relationshipGoals = [];
            this.relationshipGoalValues.forEach(item => {
                let relationshipGoalData = {
                    goldsheetId: this.getIdFromParent,
                    goalName: item.label
                };
                relationshipGoals.push(relationshipGoalData);
            });
            insertRelationshipGoals({ relationshipGoalObjects: JSON.stringify(relationshipGoals) })
                .then(() => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: success_header,
                            message: Record_success_message,
                            variant: success_header
                        })
                    );
                    this.handleProgress();
                    this.getRelationshipGoalFromBackend();
                })
                .catch(() => {
                    // raise error to user
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: error_header,
                            message: Record_error_message,
                            variant: error_header
                        })
                    );
                });

            // close add module
            this.boolVisible = false;
            this.btnflag = false;
            this.validationcheck = false;
        }
    }

    handleGoalStatusPicklistValue(event) {
        this.goalStatusValue = event.target.value;
    }

    fetchInputValues() {
        const inp = this.template.querySelectorAll("lightning-input");

        inp.forEach(function(element) {
            if (element.name === "goalName") this.goalName = element.value;
        }, this);
        const des = this.template.querySelectorAll("lightning-textarea");

        des.forEach(function(element) {
            if (element.name === "Description") this.Description = element.value;
        }, this);
    }

    validateInputs(event) {
        var allValid = true;
        var targetElement = event.target;
        if (event.target.name === "goalName") {
            this.title = targetElement.value;
            /*  if (this.title !== "") {
                this.isButtonDisabled = false;
            } else if (this.title === "") {
                this.isButtonDisabled = true;
            }*/
            if (targetElement.value.length > 80) {
                this.isButtonDisabled = true;
                targetElement.setCustomValidity(GoalNameCannotExceed80Characters);
            } else {
                this.isButtonDisabled = false;
                targetElement.setCustomValidity("");
            }
            targetElement.reportValidity();
            if (this.Description.length > 32000 || this.title === "") {
                this.isButtonDisabled = true;
            }
        }

        if (event.target.name === "Description") {
            this.Description = targetElement.value;
            if (targetElement.value.length > 32000) {
                this.isButtonDisabled = true;
                targetElement.setCustomValidity(ErrorDescriptionTooLong);
            } else {
                this.isButtonDisabled = false;
                targetElement.setCustomValidity("");
            }
            targetElement.reportValidity();
            if (!this.title || this.title.length > 80) {
                this.isButtonDisabled = true;
            }
        }
        const inputs = this.template.querySelectorAll("lightning-input", "lightning-textarea");
        inputs.forEach(input => {
            if (!input.checkValidity()) {
                input.reportValidity();
                allValid = false;
            }
        });
        //this.validateForm(event);
        return allValid;
    }

    createRelationshipGoal(event) {
        this.fetchInputValues(event);
        let ifValid = true;
        if (!ifValid) {
            const evt = new ShowToastEvent({
                title: error_header,
                message: Review_Error,
                variant: error_header
            });
            this.dispatchEvent(evt);
        } else if (this.validationcheck === true) {
            const evt = new ShowToastEvent({
                title: error_header,
                message: Review_Error,
                variant: error_header
            });
            this.dispatchEvent(evt);
        } else {
            this.fetchInputValues(event);
            let relationshipGoalData = {
                goldsheetId: this.getIdFromParent,
                goalName: this.goalName,
                goalStatus: this.goalStatusValue ? this.goalStatusValue : "Incomplete",
                Description: this.Description
            };
            let relatedActivities = [];
            if (this.selectedRows && this.selectedRows.length > 0) {
                this.selectedRows.forEach(item => {
                    let relatedActivitiesData = {
                        objectName: item.objectName,
                        activityId: item.activityId
                    };
                    relatedActivities.push(relatedActivitiesData);
                });
            }
            upsertRelationshipGoal({
                relationshipGoalObject: JSON.stringify(relationshipGoalData),
                relatedActivityObject: JSON.stringify(relatedActivities)
            })
                .then(() => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: success_header,
                            message: Record_success_message,
                            variant: success_header
                        })
                    );
                    this.handleProgress();
                    this.getRelationshipGoalFromBackend();
                })
                .catch(error => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: error_header,
                            message: error.body.message,
                            variant: error_header
                        })
                    );
                });

            this.boolVisible = false;
            this.btnflag = false;
            this.validationcheck = false;
            this.isButtonDisabled = true;
        }
    }

    validateForm(valueEvent) {
        if (valueEvent.target.value && valueEvent.target.value.length > 0) {
            this.isButtonDisabled = false;
        } else {
            this.isButtonDisabled = true;
        }
    }

    handleValueSelcted(event) {
        this.selectedRecordId = event.detail;
    }
    handleContactSelcted(event) {
        this.selectedContactId = event.detail;
    }
    handleLinkedPopOpen() {
        this.isModalOpen = true;
        this.clickeditems = [];
        this.isValidate = false;
    }

    handleLinkedPopClose() {
        this.isModalOpen = false;
        this.clickeditems = [];
        this.data = [];
        this.actvityName = "";
    }

    handleRelatedActivitiesButtonClick(event) {
        let targetId = event.currentTarget.dataset.targetId;
        let isSelected = this.template
            .querySelector(`[data-target-id="${targetId}"]`)
            .getAttribute("data-target-selected");
        if (isSelected === "false") {
            this.clickeditems.push(targetId);
        } else {
            let index = this.clickeditems.indexOf(targetId);
            this.clickeditems.splice(index, 1);
        }
        if (isSelected === "false") {
            this.template.querySelector(`[data-target-id="${targetId}"]`).setAttribute("data-target-selected", "true");
            this.template
                .querySelector(`[data-target-id="${targetId}"]`)
                .setAttribute("class", "slds-button selectedbutton slds-m-left_x-small");
        } else {
            this.template.querySelector(`[data-target-id="${targetId}"]`).setAttribute("data-target-selected", "false");
            this.template
                .querySelector(`[data-target-id="${targetId}"]`)
                .setAttribute("class", "slds-button slds-button_neutral slds-m-left_x-small");
        }

        relatedRecord({ goldsheetId: this.getIdFromParent, isSelect: isSelected, activities: this.clickeditems })
            .then(res => {
                this.data = res;
                this.tempArray = res;
            })
            .catch(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: error_header,
                        message: Record_error_message,
                        variant: error_header
                    })
                );
            });
    }
    getRowData(event) {
        let selectedRowstoStore = event.detail.selectedRows;
        if (selectedRowstoStore.length) {
            this.isSaveDisabled = false;
        } else {
            this.isSaveDisabled = true;
        }
    }

    get datatableRecords() {
        if (this.actvityName) {
            return this.data.filter(record => {
                const { Name } = record;
                return Name.toLowerCase().includes(this.actvityName);
            });
        }
        return this.data;
    }

    handleOnSearchChange(event) {
        this.actvityName = event.target.value;
        if (this.clickeditems.length === 0 && this.actvityName !== "") {
            this.isValidate = true;
        } else {
            this.isValidate = false;
        }
    }

    removeActivity = event => {
        this.selectedRows = this.selectedRows.filter(e => e.activityId !== event.target.dataset.id);
        this.isButtonDisabled = false;
    };

    handleRelatedActivitiesSave() {
        this.isModalOpen = false;
        let selectedRecords = this.template.querySelector("c-custom-lightining-data-table").getSelectedRows();
        // this.selectedRows.push(selectedRecords);

        // const finalarray=this.selectedRows[0];
        if (!this.selectedRows && selectedRecords.length > 0) {
            this.selectedRows = [];
        }
        if (selectedRecords !== undefined && selectedRecords.length > 0) {
            let uniqueIds = new Set(this.selectedRows.map(({ activityId }) => activityId));
            selectedRecords = selectedRecords.filter(({ activityId }) => !uniqueIds.has(activityId));
        }

        let tempSelectedAllRows = [...selectedRecords, ...this.selectedRows];
        const focusinvestmentList = tempSelectedAllRows.filter(obj => obj.objectLabel === "Focus Investment");
        const stopinvestmentList = tempSelectedAllRows.filter(obj => obj.objectLabel === "Stop Investment");
        const actionsList = tempSelectedAllRows.filter(obj => obj.objectLabel === "Action");
        const investmentList = tempSelectedAllRows.filter(obj => obj.objectLabel === "Investment Program");
        const informationeededList = tempSelectedAllRows.filter(obj => obj.objectLabel === "Information Needed");

        let tempSelecteRows = [];

        tempSelecteRows = [
            ...focusinvestmentList,
            ...stopinvestmentList,
            ...actionsList,
            ...informationeededList,
            ...investmentList
        ];

        this.selectedRows = [...tempSelecteRows];

        this.isModalOpen = false;
        this.actvityName = "";
        this.data = [];
    }
}