import { LightningElement, track, wire, api } from "lwc";
//import { getRecord, getFieldValue } from "lightning/uiRecordApi";
//import OWNER_NAME from "@salesforce/schema/Opportunity.Owner.Id";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
//import getBlueSheetId from "@salesforce/apex/actionPlan.getBlueSheetId";
import getContactFieldName from "@salesforce/apex/ActionPlan.getContactFieldName";
import getAssignedToFieldName from "@salesforce/apex/ActionPlan.getAssignedToFieldName";
import getActionPlan from "@salesforce/apex/ActionPlan.getActionPlan";
import insertActionPlan from "@salesforce/apex/ActionPlan.insertActionPlan";
import insertActionPlans from "@salesforce/apex/ActionPlan.insertActionPlans";
import checkAccess from "@salesforce/apex/ActionPlan.getActionPlanAccess";
import actionPlan from "@salesforce/label/c.actionPlan";
import Assigned_To from "@salesforce/label/c.Assigned_To";
import NewPossibleAction from "@salesforce/label/c.NewPossibleAction";
import Summary from "@salesforce/label/c.Summary";
import addFromList from "@salesforce/label/c.AddFromList";
import AddSummary from "@salesforce/label/c.AddSummary";
import Description from "@salesforce/label/c.Description";
import AddDescription from "@salesforce/label/c.AddDescription";
import ActionType from "@salesforce/label/c.ActionType";
import Status from "@salesforce/label/c.Status";
import Start_Date from "@salesforce/label/c.Start_Date";
import Due_Date from "@salesforce/label/c.Due_Date";
import Priority from "@salesforce/label/c.Priority";
import Is_a_Best_Action from "@salesforce/label/c.Is_a_Best_Action";
import cancel from "@salesforce/label/c.cancel";
import save from "@salesforce/label/c.save";
import Contact from "@salesforce/label/c.Contact";
import AddNewPossibleAction from "@salesforce/label/c.AddNewPossibleAction";
import Summary_cannot_exceed_256_characters from "@salesforce/label/c.Summary_cannot_exceed_256_characters";
import ErrorDueDateBeforeStart from "@salesforce/label/c.ErrorDueDateBeforeStart";
import ErrorDescriptionTooLong from "@salesforce/label/c.ErrorDescriptionTooLong";
import Required_Field_Missing from "@salesforce/label/c.Required_Field_Missing";
import Please_fill_the_Summary_Field from "@salesforce/label/c.Please_fill_the_Summary_Field";
import Review_Error from "@salesforce/label/c.Review_Error";
import error_header from "@salesforce/label/c.error_header";
import success_header from "@salesforce/label/c.success_header";
import Record_error_message from "@salesforce/label/c.Record_error_message";
import Record_success_message from "@salesforce/label/c.Record_success_message";
import ActionPlanHeaderURL from "@salesforce/label/c.ActionPlanHeaderURL";
import newPossibleAction from "@salesforce/label/c.NewPossibleAction";
import possibleactionURL from "@salesforce/label/c.possibleactionURL";
import bestActionURL from "@salesforce/label/c.bestActionURL";
import providingPerspectiveURL from "@salesforce/label/c.providingPerspectiveURL"; //KFS 250
import WillYouBeProvidePerspective from "@salesforce/label/c.WillYouBeProvidePerspective"; //KFS 250
import HowWillYouProvidePerspective from "@salesforce/label/c.HowWillYouProvidePerspective"; //KFS 250
import getActionTypePicklistValues from "@salesforce/apex/ActionPlan.getActionTypePicklistValues";
import getStatusPicklistValues from "@salesforce/apex/ActionPlan.getStatusPicklistValues";
import getPriorityPicklistValues from "@salesforce/apex/ActionPlan.getPriorityPicklistValues";
import { loadStyle } from "lightning/platformResourceLoader";
import styles from "@salesforce/resourceUrl/cssLibrary";
import getOppId from "@salesforce/apex/StrategyEngine.getOppId";
import getOppOwner from "@salesforce/apex/ActionPlan.getOppOwner";
import pubsub from "c/pubSub";
import Task from "@salesforce/label/c.Task";
import WasCreated from "@salesforce/label/c.WasCreated";
import yes from "@salesforce/label/c.yes";
import no from "@salesforce/label/c.no";
import categoryPerspective from "@salesforce/label/c.CategoryPerspective";
import getActionPlanData from "@salesforce/apex/GuidedLearningModuleProgress.getActionPlan";
import { registerListener } from "c/eventForBlueSheetProgress";
import { CurrentPageReference } from "lightning/navigation";

//const FIELDS = [OWNER_NAME];

export default class ActionPlanForm extends LightningElement {
    @wire(CurrentPageReference) pageRef;
    @track optyId = "";
    @track actionTypePicklist = [];
    @track priorityPicklist = [];
    @track statusPicklist = [];
    @track checkNoDataAndReadOnlyAccess = false;
    @track saveDisableFlag = true;
    @wire(getActionTypePicklistValues)
    actionTypepicklistResult({ data }) {
        if (data) {
            const result = JSON.parse(data);
            for (let key in result) {
                if (result.hasOwnProperty(key)) {
                    this.actionTypePicklist.push({ label: key, value: result[key] }); //Here we are creating the array to show on UI.
                }
            }
        }
    }
    @wire(getStatusPicklistValues)
    StatuspicklistResult({ data }) {
        if (data) {
            const result = JSON.parse(data);
            for (let key in result) {
                if (result.hasOwnProperty(key)) {
                    this.statusPicklist.push({ label: key, value: result[key] }); //Here we are creating the array to show on UI.
                }
            }
        }
    }
    @wire(getPriorityPicklistValues)
    prioritypicklistResult({ data }) {
        if (data) {
            const result = JSON.parse(data);
            for (let key in result) {
                if (result.hasOwnProperty(key)) {
                    this.priorityPicklist.push({ label: key, value: result[key] }); //Here we are creating the array to show on UI.
                }
            }
        }
    }

    @track boolVisible = false;
    @track btnflag = false;
    @api recordId;
    @track openAddFromListModal;
    @track actionTypeValue;
    @track statusValue;
    @track priorityValue;
    @track summary;
    @track Description;
    @track dueDate;
    @track bestAction = false;
    @track startDate;
    @track blueSheetId;
    @api objectApiName;
    @api showonbs = false;

    @track _getIdFromParent;
    @api
    get getIdFromParent() {
        return this._getIdFromParent;
    }

    set getIdFromParent(value) {
        this._getIdFromParent = value;
        this.getBluesheetIdAndActionPlanData();
    }

    @track opportunityId;
    @track actionPlansData = [];
    @track actionPlansDataForPerspective = [];
    @track assignedTo;
    @track spinnerFlag = false;
    @track selectedRecordId;
    @track checkFlag = false; // 146
    @track oppDetails;
    @api item;
    @track validationcheck = false;
    @track actionListValues = [];
    @track contactFieldName;
    @track assignedToFieldName;
    @track objectForLookup;
    @track providingPerspective = false; //KFS-255
    @track howWillYouProvidePerspective; //KFS-255
    @track yesCss = "slds-button slds-button_neutral slds-m-left_x-small"; //KFS-255
    @track noCss = "slds-button slds-button_neutral slds-m-left_x-small"; //KFS-255
    @track yesSelected = "false"; //KFS-255
    @track noSelected = "false"; //KFS-255
    @track perspective; //KFS-255
    @track showActionInsight = false;
    @track showRequired = true;
    oppOwnerSetOnLoad = true;

    initializeVariables() {
        this.yesCss = "slds-button slds-button_neutral slds-m-left_x-small";
        this.yesSelected = "false";
        this.noCss = "slds-button slds-button_neutral slds-m-left_x-small";
        this.noSelected = "false";
    } //KFS-255 -Ends
    @track defaultStartDateValue; // KFS-686
    @track isCreateable = false;

    //code to show hide the daata on self guided journey tootip
    @track moduleLearningCompleted = false;
    @track _moduleData;
    @track moduleSection;
    @track actionPlanCount = 0;
    @track resultActionPlan;

    @api get moduleData() {
        return this._moduleData;
    }
    set moduleData(value) {
        this._moduleData = value;
        this.ProcessModuleData();
    }

    ProcessModuleData() {
        if (this._moduleData) {
            if (this._moduleData.moduleNameId === "Lesson_9_Module_1") {
                this.moduleSection = "ActionPlan";
                if (this._moduleData.moduleBluesheetProgress === "Completed") {
                    this.moduleLearningCompleted = true;
                } else {
                    this.countActionPlan();
                }
            } else if (this._moduleData.moduleNameId === "Lesson_9_Module_3") {
                this.moduleSection = "ActionPlanStrategicAnalysis";
                if (this._moduleData.moduleBluesheetProgress === "Completed") {
                    this.moduleLearningCompleted = true;
                } else {
                    getActionPlanData().then(backendResult => {
                        if (backendResult !== null && backendResult.length >= 1) {
                            this.actionPlanCount = backendResult.length;
                            this.moduleLearningCompleted = false;
                        }
                    });
                }
            }
        }
    }

    countActionPlan() {
        getActionPlanData().then(backendResult => {
            let apData = backendResult;
            if (apData !== null && apData.length >= 1) {
                this.moduleLearningCompleted = true;
            } else {
                this.moduleLearningCompleted = false;
            }
        });
    }

    showModuleDependentData() {
        if (this.moduleLearningCompleted !== true) {
            if (this.moduleData && this.moduleData.moduleBluesheetProgress === "Completed") {
                this.moduleLearningCompleted = true;
            } else {
                if (this.moduleData && this.moduleData.moduleNameId === "Lesson_9_Module_1") {
                    this.countActionPlan();
                } else if (this.moduleData && this.moduleData.moduleNameId === "Lesson_9_Module_3") {
                    getActionPlanData().then(backendResult => {
                        let apResult = backendResult;
                        if (apResult !== null && apResult.length >= 1) {
                            let apCounts = apResult.length;
                            if (apCounts > this.actionPlanCount) {
                                this.moduleLearningCompleted = true;
                            } else {
                                this.moduleLearningCompleted = false;
                            }
                        } else {
                            this.moduleLearningCompleted = false;
                        }
                    });
                }
            }
        } else {
            this.moduleLearningCompleted = true;
        }
        if (this.template.querySelector("c-go-to-bluesheet-prompts")) {
            this.template.querySelector("c-go-to-bluesheet-prompts").reloadPrompt();
        }
    }

    label = {
        Record_success_message,
        Please_fill_the_Summary_Field,
        Required_Field_Missing,
        Review_Error,
        success_header,
        Record_error_message,
        actionPlan,
        error_header,
        NewPossibleAction,
        Summary,
        Assigned_To,
        addFromList,
        AddSummary,
        Description,
        AddDescription,
        ActionType,
        Status,
        Start_Date,
        Due_Date,
        Priority,
        Is_a_Best_Action,
        cancel,
        Contact,
        save,
        AddNewPossibleAction,
        Summary_cannot_exceed_256_characters,
        ErrorDescriptionTooLong,
        ErrorDueDateBeforeStart,
        ActionPlanHeaderURL,
        newPossibleAction,
        possibleactionURL,
        providingPerspectiveURL, //KFS 255
        WillYouBeProvidePerspective, //KFS 255
        HowWillYouProvidePerspective, //KFS 255
        bestActionURL,
        Task,
        WasCreated,
        yes,
        no,
        categoryPerspective
    };

    get ActionTypePicklistValues() {
        return this.actionTypePicklist;
    }

    get StatusPicklistValues() {
        return this.statusPicklist;
    }

    get PriorityPicklistValues() {
        return this.priorityPicklist;
    }

    /*@wire(getRecord, { recordId: "$getIdFromParent", fields: FIELDS })
    Opportunity;
    @wire(getRecord, { recordId: this.opportunityId, fields: FIELDS })
    Opportunity;
    get ownerName() {
        var oppId = getFieldValue(this.Opportunity.data, OWNER_NAME);
        this.selectedRecordId = oppId;
        return oppId;
    }*/

    get ownerName() {
        //this.selectedRecordId = this.opportunityOwner;
        return this.opportunityOwner;
    }

    renderedCallback() {
        loadStyle(this, styles); //specified filename
    }

    getOpportunityId() {}

    getBluesheetIdAndActionPlanData() {
        this.blueSheetId = this.getIdFromParent;
        getOppId({ blueSheetId: this.getIdFromParent }).then(result => {
            this.opportunityId = result;
            this.fetchOppOwner();
            checkAccess().then(res => {
                this.isCreateable = res.isCreateable;
                this.getActionPlanFromBackend();
            });
        });
    }

    connectedCallback() {
        // KFS-686-Start
        let today = new Date();
        let month = ("0" + (today.getMonth() + 1)).slice(-2);
        let todayDate = ("0" + today.getDate()).slice(-2);
        let date = today.getFullYear() + "-" + month + "-" + todayDate;
        this.defaultStartDateValue = date;
        this.showonbs = true;
        // KFS-686-End
        getContactFieldName().then(result => {
            this.objectForLookup = result.lookupOnObject;
            this.contactFieldName = result.targetField;
        });
        getAssignedToFieldName().then(result => {
            this.assignedToFieldName = result.targetField;
        });
        registerListener("ModuleDataActionPlan", this.reloadModuleData, this);
    }

    reloadModuleData(moduleData) {
        this._moduleData = moduleData;
        this.ProcessModuleData();
    }

    fetchOppOwner() {
        getOppOwner({ opptId: this.opportunityId }).then(result => {
            this.opportunityOwner = result.ownerid;
        });
    }

    getActionPlanFromBackend() {
        getActionPlan({ oppId: this.opportunityId })
            .then(res => {
                this.actionPlansData = res;
                this.actionPlansDataForPerspective = res;
                this.handleProgress();
                if (!this.actionPlansData.length && !this.isCreateable) {
                    this.checkNoDataAndReadOnlyAccess = true;
                }
            })
            .catch(() => {
                // eslint-disable-next-line no-console
            });
    }

    @api
    handleRefresh() {
        this.getActionPlanFromBackend();
    }

    handleProgress() {
        if (this.actionPlansDataForPerspective.length > 0) {
            this.showActionInsight = true;
        } else {
            this.showActionInsight = false;
        }
        let data = {
            type: "refreshActionPlanInsights",
            showActionInsight: this.showActionInsight
        };
        const selectedEvent = new CustomEvent("updateprogressfromchild", {
            detail: data
        });
        this.dispatchEvent(selectedEvent);
    }

    getContactId(event) {
        this.selectedContactId = event.detail;
    }

    handleClick() {
        this.boolVisible = true;
        //KFS-814
        this.template.querySelectorAll("c-action-plan-data").forEach(item => {
            item.closeEditModal();
        });
        this.btnflag = true;
        this.actionTypeValue = "";
        this.priorityValue = "";
        this.statusValue = "";
        this.summary = "";
        this.Description = "";
        this.selectedContactId = "";
        this.startDate = "";
        this.dueDate = "";
        this.selectedRecordId = this.opportunityOwner;
        this.bestAction = false; //146
        this.providingPerspective = false; //KFS-255
        this.howWillYouProvidePerspective = ""; //KFS-255
        this.evaluateSaveBtn();
    }
    evaluateSaveBtn() {
        const inp = this.template.querySelectorAll("lightning-input");
        let summaryTmp = "";
        inp.forEach(function(element) {
            if (element.name === "summary") summaryTmp = element.value;
        }, this);

        if (this.selectedRecordId && this.selectedRecordId.length > 0 && summaryTmp && summaryTmp.length > 0) {
            //has value, valid case
            this.saveDisableFlag = false;
        } else {
            this.saveDisableFlag = true;
        }
    }
    openAddListlookup() {
        this.openAddFromListModal = true;
    }

    isBestActionSelected(event) {
        this.isPerspectiveVisible = event.target.checked;
    }

    handleCancel() {
        this.boolVisible = false;
        this.btnflag = false;
        this.actionTypeValue = "";
        this.priorityValue = "";
        this.statusValue = "";
        this.summary = "";
        this.Description = "";
        //this.ownerName='';
        this.selectedContactId = "";
        this.startDate = "";
        this.dueDate = "";
        this.selectedRecordId = "";
        this.bestAction = false; //146
        this.validationcheck = false;
        this.providingPerspective = false; //KFS-255
        this.howWillYouProvidePerspective = ""; //KFS-255
    }

    getSelectedActionList(event) {
        this.openAddFromListModal = event.detail.modalStatus;
        this.actionListValues = event.detail.checkedValues;

        // update action summary if only one item is checked
        if (this.actionListValues.length === 1) {
            const element = this.template.querySelector('[data-id="action-summary"]');
            if (element) {
                this.template.querySelector('[data-id="action-summary"]').value = this.actionListValues[0].label;
                if (element.value && element.value.length > 0) {
                    if (element.value.length === 256) {
                        element.setCustomValidity(Summary_cannot_exceed_256_characters);
                    } else {
                        element.setCustomValidity("");
                        this.saveDisableFlag = false;
                    }
                } else {
                    this.saveDisableFlag = true;
                }
                element.reportValidity();

                const inputs = this.template.querySelectorAll("lightning-input", "lightning-textarea");
                inputs.forEach(input => {
                    if (!input.checkValidity()) {
                        input.reportValidity();
                    }
                });
            }
        }

        if (this.actionListValues.length > 1) {
            let actionPlans = [];
            this.actionListValues.forEach(item => {
                let actionPlanData = {
                    BluesheetId: this.blueSheetId,
                    Summary: item.label
                };
                actionPlans.push(actionPlanData);
            });
            insertActionPlans({ actnPlans: JSON.stringify(actionPlans) })
                .then(() => {
                    // show success and refresh action list for main page
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: success_header,
                            message: Record_success_message,
                            variant: success_header
                        })
                    );
                    pubsub.fire("refreshBestActionGrid", "");
                    this.handleProgress();
                    this.getActionPlanFromBackend();
                })
                .catch(error => {
                    let errorMsg = "Unknown error";
                    if (Array.isArray(error.body)) {
                        errorMsg = error.body.map(e => e.message).join(", ");
                    } else if (typeof error.body.message === "string") {
                        errorMsg = error.body.message;
                    }
                    // eslint-disable-next-line no-console
                    console.error("Error saving action list: " + errorMsg);
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

    handleActionTypePicklistValue(event) {
        this.actionTypeValue = event.target.value;
    }
    handleStatusPicklistValue(event) {
        this.statusValue = event.target.value;
    }
    handlePriorityTypePicklistValue(event) {
        this.priorityValue = event.target.value;
    }

    //KFS-146-Start
    handleonChange(event) {
        this.noCss = "slds-button slds-m-left_x-small selectedbutton";
        this.yesCss = "slds-button slds-m-left_x-small unselectedButton";

        this.bestAction = event.target.checked;
        if (this.bestAction === false) {
            this.providingPerspective = false;
        }
    } //KFS-146-End

    //KFS-255-Starts
    perspectiveButtonClick(event) {
        let targetId = event.currentTarget.dataset.targetId;
        let isSelected = this.template
            .querySelector(`[data-target-id="${targetId}"]`)
            .getAttribute("data-target-selected");
        let buttonvalue = this.template
            .querySelector(`[data-target-id="${targetId}"]`)
            .getAttribute("data-target-value");
        this.perspective = "";
        //this.fieldValue=buttonvalue;

        if (isSelected === "false") {
            this.template.querySelector(`[data-target-id="${targetId}"]`).setAttribute("data-target-selected", "true");
            this.template
                .querySelector(`[data-target-id="${targetId}"]`)
                .setAttribute("class", "slds-button selectedbutton  slds-m-left_x-small");
            //this.template.querySelector('lightning-input[data-target-priority=priority]').setAttribute('value',this.fieldValue);
            this.perspective = buttonvalue;
            if (this.perspective === "Yes") {
                this.providingPerspective = true;
            } else {
                this.providingPerspective = false;
            }
        } else {
            this.template.querySelector(`[data-target-id="${targetId}"]`).setAttribute("data-target-selected", "false");
            this.template
                .querySelector(`[data-target-id="${targetId}"]`)
                .setAttribute("class", "slds-button slds-button_neutral  slds-m-left_x-small");
            //this.template.querySelector('lightning-input[data-target-priority=priority]').setAttribute('value','');
        }
        this.template.querySelectorAll("button[data-target-class=InfluenceDegree]").forEach(element => {
            if (element.getAttribute("data-target-id") !== targetId) {
                element.setAttribute("class", "slds-button slds-button_neutral slds-m-left_x-small");
                element.setAttribute("data-target-selected", "false");
            }
        });
    } //KFS-255 Ends

    //KFS-255-Starts
    handleButtonClick(event) {
        let targetId = event.currentTarget.dataset.targetId;
        this.perspective = "";

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

    fetchInputValues() {
        const inp = this.template.querySelectorAll("lightning-input");

        inp.forEach(function(element) {
            if (element.name === "summary") this.summary = element.value;
            else if (element.name === "startDate") this.startDate = element.value;
            else if (element.name === "dueDate") this.dueDate = element.value;
            else if (element.name === "AssignedTo") this.assignedTo = element.value;

            // else if(element.name == "bestAction")
            //   this.bestAction = element.value;
        }, this);

        const des = this.template.querySelectorAll("lightning-textarea");

        des.forEach(function(element) {
            if (element.name === "Description") this.Description = element.value;
            else if (element.name === "Perspective") this.howWillYouProvidePerspective = element.value; //KFS-255
        }, this);
    }

    validateInputs(event) {
        var allValid = true;
        var targetElement = event.target;
        if (event.target.name === "summary") {
            if (targetElement.value.length === 256) {
                targetElement.setCustomValidity(Summary_cannot_exceed_256_characters);
            } else {
                targetElement.setCustomValidity("");
            }
            if (targetElement.value && targetElement.value.length > 0 && this.isAssignedToValid()) {
                this.saveDisableFlag = false;
            } else {
                this.saveDisableFlag = true;
            }
            targetElement.reportValidity();
        }

        if (event.target.name === "dueDate" || event.target.name === "startDate") {
            let startDate;
            let dueDate;
            const inp = this.template.querySelectorAll("lightning-input");
            inp.forEach(function(element) {
                if (element.name === "startDate") startDate = element.value;
                else if (element.name === "dueDate") dueDate = element.value;
            }, this);
            if (dueDate !== "") {
                if (dueDate < startDate) {
                    this.validationcheck = true;
                } else {
                    this.validationcheck = false;
                }
            }
        }

        if (event.target.name === "Description") {
            if (targetElement.value.length === 32000) {
                targetElement.setCustomValidity(ErrorDescriptionTooLong);
            } else {
                targetElement.setCustomValidity("");
            }
            targetElement.reportValidity();
        }

        //KFS-255 Starts
        if (event.target.name === "Perspective") {
            if (targetElement.value.length === 32000) {
                targetElement.setCustomValidity(ErrorDescriptionTooLong);
            } else {
                targetElement.setCustomValidity("");
            }
            targetElement.reportValidity();
        }
        //KFS-255 Ends
        const inputs = this.template.querySelectorAll("lightning-input", "lightning-textarea");
        inputs.forEach(input => {
            if (!input.checkValidity()) {
                input.reportValidity();
                allValid = false;
            }
        });
        return allValid;
    }

    isAssignedToValid() {
        let resReturn = "";
        if (this.selectedRecordId && this.selectedRecordId.length > 0) {
            //value present, return false
            resReturn = true;
        } else {
            //value absent, disbale save btn
            resReturn = false;
        }
        return resReturn;
    }
    createActionPlan(event) {
        this.fetchInputValues(event);
        const ifValid = this.validateInputs(event);

        // FIXME: Anirudh: Is undefined a value or are we checking if object is undefined?
        if (this.summary === "" || this.summary === "undefined" || this.summary == null) {
            this.saveDisableFlag = true;
        } else if (!ifValid) {
            this.saveDisableFlag = false;
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
            this.spinnerFlag = true;
            let actionPlanData = {
                BluesheetId: this.getIdFromParent,
                OppId: this.opportunityId,
                Summary: this.summary,
                ActionType: this.actionTypeValue,
                AssignedTo: this.selectedRecordId,
                Contact: this.selectedContactId,
                Description: this.Description,
                DueDate: this.dueDate,
                Priority: this.priorityValue,
                StartDate: this.startDate,
                Status: this.statusValue,
                bestActionvalue: this.bestAction,
                providingPerspectiveValue: this.providingPerspective, //KFS-255
                howWillYouProvidePerspectiveValue: this.howWillYouProvidePerspective //KFS-255
            };

            insertActionPlan({ actnPlan: JSON.stringify(actionPlanData) })
                .then(result => {
                    this.saveDisableFlag = false;
                    // Clear the user enter values
                    // Show success messsage
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: success_header,
                            message: Record_success_message,
                            variant: success_header
                        })
                    );
                    if (result) {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: success_header,
                                message: Task + " {1} " + WasCreated,
                                messageData: [
                                    "Salesforce",
                                    {
                                        url: "/lightning/r/Task/" + result + "/view",
                                        label: this.summary
                                    }
                                ],
                                variant: success_header
                            })
                        );
                    }
                    this.handleProgress();
                    pubsub.fire("refreshBestActionGrid", "");
                    this.getActionPlanFromBackend();
                    this.showModuleDependentData();
                })
                .catch(() => {
                    this.saveDisableFlag = false;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: error_header,
                            message: Record_error_message,
                            variant: error_header
                        })
                    );
                });

            this.boolVisible = false;
            this.btnflag = false;
            this.validationcheck = false;
        }
    }

    handleValueSelcted(event) {
        const inp = this.template.querySelectorAll("lightning-input");
        let summaryTmp = "";
        inp.forEach(function(element) {
            if (element.name === "summary") summaryTmp = element.value;
        }, this);

        this.selectedRecordId = event.detail;
        if (this.selectedRecordId && this.selectedRecordId.length > 0 && summaryTmp && summaryTmp.length > 0) {
            //has value, valid case
            this.saveDisableFlag = false;
        } else {
            this.saveDisableFlag = true;
        }
    }
    handleContactSelcted(event) {
        this.selectedContactId = event.detail;
    }
}