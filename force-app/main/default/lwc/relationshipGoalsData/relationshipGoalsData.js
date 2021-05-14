import { LightningElement, api, track, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import upsertRelationshipGoal from "@salesforce/apex/RelationshipGoals.upsertRelationshipGoal";
import relatedRecord from "@salesforce/apex/RelationshipGoals.getRelatedRecords";
import deleteRelationshipGoal from "@salesforce/apex/RelationshipGoals.deleteRelationshipGoal";
import editLabel from "@salesforce/label/c.edit";
import deleteLabel from "@salesforce/label/c.delete";
import showLess from "@salesforce/label/c.showLess";
import showMore from "@salesforce/label/c.showMore";
import no from "@salesforce/label/c.no";
import yes from "@salesforce/label/c.yes";
import GoalName from "@salesforce/label/c.GoalName";
import GoalStatus from "@salesforce/label/c.GoalStatus";
import AddGoal from "@salesforce/label/c.AddGoal";
import AreYouSureYouWantToDelete from "@salesforce/label/c.AreYouSureYouWantToDelete";
import close from "@salesforce/label/c.close";
import Description from "@salesforce/label/c.Description";
import DeleteRelationshipGoal from "@salesforce/label/c.DeleteRelationshipGoal";
import cancel from "@salesforce/label/c.cancel";
import save from "@salesforce/label/c.save";
import GoalNameCannotExceed80Characters from "@salesforce/label/c.GoalNameCannotExceed80Characters";
import ErrorDescriptionTooLong from "@salesforce/label/c.ErrorDescriptionTooLong";
import Required_Field_Missing from "@salesforce/label/c.Required_Field_Missing";
import PleaseFillTheGoalNameField from "@salesforce/label/c.PleaseFillTheGoalNameField";
import Review_Error from "@salesforce/label/c.Review_Error";
import error_header from "@salesforce/label/c.error_header";
import success_header from "@salesforce/label/c.success_header";
import Record_error_message from "@salesforce/label/c.Record_error_message";
import Record_success_message from "@salesforce/label/c.Record_success_message";
import RecordDeleted from "@salesforce/label/c.Record_delete_message";
import RecordUpdated from "@salesforce/label/c.Record_Update_message";
import checkAccess from "@salesforce/apex/RelationshipGoals.getRelationshipGoalAccess";
import getGoalStatusPicklistValues from "@salesforce/apex/RelationshipGoals.getGoalStatusPicklistValues";
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
import getRelationshipGoal from "@salesforce/apex/RelationshipGoals.getRelationshipGoal";
import Success from "@salesforce/label/c.Success";
import DefaultStyle from "@salesforce/label/c.DefaultStyle";
import DeleteRecord from "@salesforce/label/c.DeleteRecord";
import EditRecord from "@salesforce/label/c.EditRecord";
import foInvAmount from "@salesforce/label/c.foInvAmount";
import InvestmentProgramDueDate from "@salesforce/label/c.InvestmentProgramDueDate";
import AddGoalName from "@salesforce/label/c.AddGoalName";
import AddDescription from "@salesforce/label/c.AddDescription";
import ActionStatus from "@salesforce/label/c.ActionStatus";
import Remove from "@salesforce/label/c.Remove";

const columns = [{ label: "", fieldName: "Name", wrapText: true }];
export default class RelationshipGoalData extends LightningElement {
    data = [];
    @api selectedActivities = [];
    @track currentActivities = [];
    columns = columns;
    @track actvityName = "";
    clickeditems = [];
    @track goalStatusPicklist = [];
    @track objectForLookup;
    @track isExpandableView = true;
    @track sortFilter;
    @track relationshipGoalsDataChild;

    handleToggleSection() {
        this.isExpandableView = !this.isExpandableView;
    }

    @wire(getGoalStatusPicklistValues)
    goalStatusPicklistResult({ data }) {
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
    @api item;
    @track showEditView = false;
    @track currentRecordItem = [];
    @track ShowModal = false;
    @track ShowMoreText = false;
    @track showText = false;
    @track checkFlag = false;
    @track isUpdateable = false;
    @track isDeletable = false;
    @track validationcheck = false;
    @track variantRAColor;
    @track variantColor = "Success";
    @track utilitysetting = "utility:ban";
    @track isCreateable = false;
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
    @api parentid;
    @track isSaveDisabled = true;
    @track isValidate = false;
    @track isButtonDisabled = true;
    @track displayedActivityWrappers = [];
    @track displayedActivityWrappersTmp = [];
    @track goldsheetId;
    @track hasDatatableRecords = false;

    label = {
        editLabel,
        deleteLabel,
        showLess,
        showMore,
        GoalName,
        GoalStatus,
        AddGoal,
        RecordDeleted,
        RecordUpdated,
        Description,
        cancel,
        save,
        close,
        DeleteRelationshipGoal,
        AreYouSureYouWantToDelete,
        yes,
        no,
        GoalNameCannotExceed80Characters,
        ErrorDescriptionTooLong,
        Required_Field_Missing,
        PleaseFillTheGoalNameField,
        Review_Error,
        error_header,
        success_header,
        Record_error_message,
        Record_success_message,
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
        Success,
        DefaultStyle,
        DeleteRecord,
        EditRecord,
        foInvAmount,
        InvestmentProgramDueDate,
        AddGoalName,
        AddDescription,
        ActionStatus,
        Remove
    };

    get goalStatusPicklistValues() {
        return this.goalStatusPicklist;
    }

    connectedCallback() {
        if (this.item.goalStatus === "Complete") {
            this.utilitysetting = "utility:success";
            this.variantColor = "Success";
        } else {
            this.utilitysetting = "utility:ban";
            this.variantColor = "warning";
        }

        this.displayedActivityWrappers = this.item.relatedActivitiesWrapper;
        this.currentActivities = this.displayedActivityWrappers;
        this.description = this.item.description;
        this.goalName = this.item.goalName;
        this.goalStatusValue = this.item.goalStatus;
        checkAccess().then(result => {
            this.isUpdateable = result.isUpdateable;
            this.isDeletable = result.isDeletable;
            this.isCreateable = result.isCreateable;
        });
    }
    renderedCallback() {
        if (this.item.goalStatus === "Complete") {
            this.utilitysetting = "utility:success";
            this.variantColor = "Success";
        } else {
            this.utilitysetting = "utility:ban";
            this.variantColor = "warning";
        }
    }

    handleContactChange(event) {
        this.selectedContactId = event.detail;
    }
    handleUserChange(event) {
        this.selectedRecordId = event.detail;
    }

    removeActivity = event => {
        this.displayedActivityWrappers = this.displayedActivityWrappers.filter(
            e => e.activityId !== event.target.dataset.id
        );
        this.currentActivities = [...this.displayedActivityWrappers];
        this.isButtonDisabled = false;
    };

    handleEdit() {
        this.showEditView = true;
        this.isButtonDisabled = false;
    }
    handleCancel() {
        this.displayedActivityWrappers = this.item.relatedActivitiesWrapper;
        this.currentActivities = this.displayedActivityWrappers;
        this.description = this.item.description;
        this.goalName = this.item.goalName;
        this.goalStatusValue = this.item.goalStatus;
        this.showEditView = false;
        this.validationcheck = false;
        this.isExpandableView = true;
    }
    handleDelete() {
        this.ShowModal = true;
    }
    fetchInputValues() {
        const inp = this.template.querySelectorAll("lightning-input");

        inp.forEach(function(element) {
            if (element.name === "goalName") this.goalName = element.value;
        }, this);

        const des = this.template.querySelectorAll("lightning-textarea");

        des.forEach(function(element) {
            if (element.name === "Description") this.description = element.value;
        }, this);

        const picklistValues = this.template.querySelectorAll("lightning-combobox");
        picklistValues.forEach(function(element) {
            if (element.name === "goalStatus") {
                this.goalStatusValue = element.value;
            }
        }, this);
    }

    validateInputs(event) {
        var allValid = true;
        var targetElement = event.target;
        if (event.target.name === "goalName") {
            let title = targetElement.value;
            /*if (this.title !== "") {
                this.isButtonDisabled = false;
            } else if (this.title === "") {
                this.isButtonDisabled = true;
            }*/
            if (title.length > 80) {
                this.isButtonDisabled = true;
                targetElement.setCustomValidity(GoalNameCannotExceed80Characters);
            } else {
                this.isButtonDisabled = false;
                targetElement.setCustomValidity("");
            }
            targetElement.reportValidity();
            if (this.description.length > 32000 || title === "") {
                this.isButtonDisabled = true;
            }
        }

        if (event.target.name === "Description") {
            this.description = targetElement.value;
            if (this.description.length > 32000) {
                this.isButtonDisabled = true;
                targetElement.setCustomValidity(ErrorDescriptionTooLong);
            } else {
                this.isButtonDisabled = false;
                targetElement.setCustomValidity("");
            }
            targetElement.reportValidity();
            if (!this.goalName || this.goalName.length > 80) {
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
        return allValid;
    }

    handleGoalStatusPicklistValue(event) {
        this.goalStatusValue = event.target.value;
    }
    handleonChange(event) {
        this.checkFlag = event.target.checked;
    }

    updateRelationshipGoal(event) {
        this.goldsheetId = this.parentid;
        this.fetchInputValues(event);
        this.showText = false;
        this.ShowLessText = false;
        this.ShowMoreText = false;
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
                goalName: this.goalName,
                goalStatus: this.goalStatusValue,
                Description: this.description,
                Id: this.item.Id,
                goldsheetId: this.parentid
            };

            upsertRelationshipGoal({
                relationshipGoalObject: JSON.stringify(relationshipGoalData),
                relatedActivityObject: JSON.stringify(this.displayedActivityWrappers)
            })
                .then(() => {
                    getRelationshipGoal({ goldsheetId: this.goldsheetId, sortFilter: this.sortFilter }).then(res => {
                        this.relationshipGoalsDataChild = res;
                        this.relationshipGoalsDataChild.forEach(element => {
                            if (element.Id === this.item.Id) {
                                this.displayedActivityWrappers = element.relatedActivitiesWrapper;
                            }
                        });
                    });

                    // Show success messsage
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: success_header,
                            message: RecordUpdated,
                            variant: success_header
                        })
                    );

                    const selectedEvent = new CustomEvent("refreshscreen", {
                        detail: true
                    });

                    // Dispatches the event.
                    this.dispatchEvent(selectedEvent);
                    // if (result && result.goalStatus === "Complete") {
                    //  this.variantColor = "Success";
                    //  } else {
                    //   this.variantColor = "warning";
                    //  }
                    // this.connectedCallback();
                })
                .catch(error => {
                    if (error) {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: error_header,
                                message: Record_error_message,
                                variant: error_header
                            })
                        );
                    }
                });

            this.boolVisible = false;
            this.btnflag = false;
            this.showEditView = false;
            this.validationcheck = false;
            this.isExpandableView = true;
            this.isButtonDisabled = true;
        }
    }

    validateForm(valueEvent) {
        if (valueEvent && valueEvent.target.value.length > 0) {
            this.isButtonDisabled = false;
        } else {
            this.isButtonDisabled = true;
        }
    }
    deleteModal() {
        this.ShowModal = false;
        deleteRelationshipGoal({ recordId: this.item.Id }).then(() => {
            // Show success messsage
            this.dispatchEvent(
                new ShowToastEvent({
                    title: this.label.success_header, //KFS-2766
                    message: this.label.RecordDeleted, //KFS-2766
                    variant: "success"
                })
            );

            const selectedEvent = new CustomEvent("refreshscreen", {
                detail: true
            });

            this.dispatchEvent(selectedEvent);
        });
    }
    closeModal() {
        this.ShowModal = false;
    }

    handleShowMore() {
        this.showText = true;
        this.ShowMoreText = false;
        this.ShowLessText = true;
    }

    handleShowLess() {
        this.showText = false;
        this.ShowLessText = false;
        this.ShowMoreText = true;
        if (this.template.querySelector(".divClass") != null) {
            this.template.querySelector(".divClass").scrollIntoView(true);
        }
    }

    handleLinkedPopOpen() {
        this.isModalOpen = true;
        this.clickeditems = [];
        this.isSaveDisabled = true;
        this.hasDatatableRecords = false;
    }

    handleLinkedPopClose() {
        this.isModalOpen = false;
        this.clickeditems = [];
        this.data = [];
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
        /*if (this.clickeditems.length === 0) {
            this.isSaveDisabled = true;
        } else {
            this.isSaveDisabled = false;
        }*/

        relatedRecord({
            goldsheetId: this.parentid,
            isSelect: isSelected,
            activities: this.clickeditems
        })
            .then(res => {
                this.data = res;
                this.hasDatatableRecords = true;
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

    get datatableRecords() {
        if (this.actvityName) {
            /*const focusinvestmentTable = this.data.filter(obj => obj.objectLabel === "Focus Investment");
            const stopinvestmentTable = this.data.filter(obj => obj.objectLabel === "Stop Investment");
            const actionsTable = this.data.filter(obj => obj.objectLabel === "Action");
            const investmentTable = this.data.filter(obj => obj.objectLabel === "Investment Program");
            const informationeededTable = this.data.filter(obj => obj.objectLabel === "Information Needed");
            this.data = [
                ...focusinvestmentTable,
                ...stopinvestmentTable,
                ...actionsTable,
                ...investmentTable,
                ...informationeededTable
            ];*/
            return this.data.filter(record => {
                const { Name } = record;
                return Name.toLowerCase().includes(this.actvityName);
            });
        }
        return this.data;
    }

    handleOnSearchChange(event) {
        const isEnterKey = event.keyCode === 13;
        this.actvityName = event.target.value;
        if (this.clickeditems.length === 0 && this.actvityName >= 3 && isEnterKey) {
            this.isValidate = true;
        } else {
            this.isValidate = false;
        }
    }
    getRowData(event) {
        let selectedRowstoStore = event.detail.selectedRows;
        if (selectedRowstoStore.length) {
            this.isSaveDisabled = false;
        } else {
            this.isSaveDisabled = true;
        }
    }

    handleRelatedActivitiesSave() {
        this.isModalOpen = false;

        let selectedRecords = this.template.querySelector("c-custom-lightining-data-table").getSelectedRows();

        if (this.displayedActivityWrappers === undefined) {
            this.displayedActivityWrappers = [];
        }
        if (this.displayedActivityWrappers.length > 0) {
            let uniqueIds = new Set(this.displayedActivityWrappers.map(({ activityId }) => activityId));
            selectedRecords = selectedRecords.filter(({ activityId }) => !uniqueIds.has(activityId));
        }

        let allRows = [...selectedRecords, ...this.displayedActivityWrappers];

        const focusinvestmentList = allRows.filter(obj => obj.objectLabel === "Focus Investment");
        const stopinvestmentList = allRows.filter(obj => obj.objectLabel === "Stop Investment");
        const actionsList = allRows.filter(obj => obj.objectLabel === "Action");
        const investmentList = allRows.filter(obj => obj.objectLabel === "Investment Program");
        const informationeededList = allRows.filter(obj => obj.objectLabel === "Information Needed");
        //...this.displayedActivityWrappers,
        this.displayedActivityWrappers = [
            ...focusinvestmentList,
            ...stopinvestmentList,
            ...actionsList,
            ...informationeededList,
            ...investmentList
        ];
        this.displayedActivityWrappers.forEach(element => {
            if (element.raStatus === "Complete") {
                element.variantRAColor = "success";
            } else {
                element.variantRAColor = "warning";
            }
        });
        //this.displayedActivityWrappers = [...this.currentActivities, ...this.displayedActivityWrappers];
        this.data = [];
    }
}