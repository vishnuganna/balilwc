import { LightningElement, api, track, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import updateActionPlan from "@salesforce/apex/ActionPlan.updateActionPlan";
import deleteActionPlan from "@salesforce/apex/ActionPlan.deleteActionPlan";
import getContactFieldName from "@salesforce/apex/ActionPlan.getContactFieldName";
import getAssignedToFieldName from "@salesforce/apex/ActionPlan.getAssignedToFieldName";
import undeleteTask from "@salesforce/apex/ActionPlan.undeleteTask";
import editLabel from "@salesforce/label/c.edit";
import updateIsAction from "@salesforce/apex/ActionPlan.updateIsAction";
import deleteLabel from "@salesforce/label/c.delete";
import showLess from "@salesforce/label/c.showLess";
import showMore from "@salesforce/label/c.showMore";
import Priority from "@salesforce/label/c.Priority";
import Status from "@salesforce/label/c.Status";
import no from "@salesforce/label/c.no";
import yes from "@salesforce/label/c.yes";
import DeleteActionsPrompt from "@salesforce/label/c.DeleteActionsPrompt";
import Summary from "@salesforce/label/c.Summary";
import AddFromList from "@salesforce/label/c.AddFromList";
import close from "@salesforce/label/c.close";
import Description from "@salesforce/label/c.Description";
import DeleteActionPlan from "@salesforce/label/c.DeleteActionPlan";
import ActionType from "@salesforce/label/c.ActionType";
import Start_Date from "@salesforce/label/c.Start_Date";
import Due_Date from "@salesforce/label/c.Due_Date";
import Is_a_Best_Action from "@salesforce/label/c.Is_a_Best_Action";
import cancel from "@salesforce/label/c.cancel";
import save from "@salesforce/label/c.save";
import Contact from "@salesforce/label/c.Contact";
import Assigned_To from "@salesforce/label/c.Assigned_To";
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
import RecordDeleted from "@salesforce/label/c.Record_delete_message";
import RecordUpdated from "@salesforce/label/c.Record_Update_message";
import bestActionURL from "@salesforce/label/c.bestActionURL";
import providingPerspectiveURL from "@salesforce/label/c.providingPerspectiveURL"; //KFS 250
import WillYouBeProvidePerspective from "@salesforce/label/c.WillYouBeProvidePerspective"; //KFS 250
import HowWillYouProvidePerspective from "@salesforce/label/c.HowWillYouProvidePerspective"; //KFS 250
import checkAccess from "@salesforce/apex/ActionPlan.getActionPlanAccess";
import getActionTypePicklistValues from "@salesforce/apex/ActionPlan.getActionTypePicklistValues";
import getStatusPicklistValues from "@salesforce/apex/ActionPlan.getStatusPicklistValues";
import getPriorityPicklistValues from "@salesforce/apex/ActionPlan.getPriorityPicklistValues";
import pubsub from "c/pubSub";
import { NavigationMixin } from "lightning/navigation";
import RecordRestored from "@salesforce/label/c.RecordRestored";
import Task from "@salesforce/label/c.Task";
import WasCreated from "@salesforce/label/c.WasCreated";
import NoPermissionToDeleteTask from "@salesforce/label/c.NoPermissionToDeleteTask";
import Undo from "@salesforce/label/c.Undo";
import WasDeleted from "@salesforce/label/c.WasDeleted";
import Update_Success from "@salesforce/label/c.Update_Success";
import ErrorCreatingRecord from "@salesforce/label/c.ErrorCreatingRecord";
import ToggleBestAction from "@salesforce/label/c.ToggleBestAction";
import DeleteRecord from "@salesforce/label/c.DeleteRecord";
import EditRecord from "@salesforce/label/c.EditRecord";
import AddSummary from "@salesforce/label/c.AddSummary";
import AddDescription from "@salesforce/label/c.AddDescription";
import DescriptionOfIcon from "@salesforce/label/c.DescriptionOfIcon";
import LOCALE from "@salesforce/i18n/locale";

export default class ActionPlanData extends LightningElement {
    @track actionTypePicklist = [];
    @track priorityPicklist = [];
    @track statusPicklist = [];
    @track contactFieldName;
    @track assignedToFieldName;
    @track objectForLookup;
    @track saveDisableFlag = false;

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

    @api item;
    @api item2;
    @track autoCloseTime = 3000;
    @track autoClose = false;
    @track showEditView = false;
    @track currentRecordItem = [];
    @track ShowModal = false;
    @track ShowMoreText = false;
    @track showText = false;
    @track shortActionPlanDetils = "";
    @track longActionPlanDetils = "";
    @track bestActionCheck = false; //146
    @track checkFlag = false;
    @track isUpdateable = false;
    @track isDeletable = false;
    @track validationcheck = false;
    @track isCheck = false; //KFS-255
    @track yesCss = "slds-button slds-button_neutral slds-m-left_x-small"; //KFS-255
    @track noCss = "slds-button slds-button_neutral slds-m-left_x-small"; //KFS-255
    @track yesSelected = "false"; //KFS-255
    @track noSelected = "false"; //KFS-255
    @track perspective; //KFS-255
    @track bestAction = false; //KFS-255
    @track ShowMoreTextProvidePerspective = false; //KFS-255
    @track ShowLessTextProvidePerspective = false; //KFS-255
    @track showTextProvidePerspective = false; //KFS-255
    @track shortActionPlanDetilsProvidePerspective = ""; //KFS-255
    @track longActionPlanDetilsProvidePerspective = ""; //KFS-255
    @track showRequired = true;
    @track undelete = false;
    //KFS-255-Satrts
    initializeVariables() {
        this.yesCss = "slds-button slds-button_neutral slds-m-left_x-small";
        this.yesSelected = "false";
        this.noCss = "slds-button slds-button_neutral slds-m-left_x-small";
        this.noSelected = "false";
    } //KFS-255-Ends

    label = {
        editLabel,
        deleteLabel,
        showLess,
        showMore,
        Priority,
        Status,
        ActionType,
        Contact,
        Assigned_To,
        Start_Date,
        Due_Date,
        Summary,
        RecordDeleted,
        RecordUpdated,
        AddFromList,
        Description,
        Is_a_Best_Action,
        cancel,
        save,
        close,
        DeleteActionPlan,
        DeleteActionsPrompt,
        yes,
        no,
        Summary_cannot_exceed_256_characters,
        ErrorDueDateBeforeStart,
        ErrorDescriptionTooLong,
        Required_Field_Missing,
        Please_fill_the_Summary_Field,
        Review_Error,
        error_header,
        success_header,
        Record_error_message,
        Record_success_message,
        providingPerspectiveURL, //KFS-250
        WillYouBeProvidePerspective, // KFS-250
        HowWillYouProvidePerspective, //KFS-250
        bestActionURL,
        NavigationMixin,
        RecordRestored,
        Task,
        WasCreated,
        NoPermissionToDeleteTask,
        Undo,
        WasDeleted,
        Update_Success, //KFS-2766
        ErrorCreatingRecord, //KFS-2766
        ToggleBestAction, //KFS-2766
        DeleteRecord,
        EditRecord,
        AddSummary,
        AddDescription,
        DescriptionOfIcon
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

    renderedCallback() {
        if (this.item.isShowFlag) {
            let itemtemp = JSON.parse(JSON.stringify(this.item));
            if (this.item.startDate !== undefined) {
                itemtemp.startDate = this.getDateInLocaleFormat(this.item.startDate);
            }
            if (this.item.dueDate !== undefined) {
                itemtemp.dueDate = this.getDateInLocaleFormat(this.item.dueDate);
            }
            this.item = itemtemp;
            this.item.isShowFlag = false;
        }
    }

    getDateInLocaleFormat(dateTmp) {
        return new Intl.DateTimeFormat(LOCALE).format(new Date(dateTmp));
    }

    connectedCallback() {
        this.bestActionCheck = this.item.bestAction; //146a
        this.providingPerspective = this.item.providingPerspective; //KFS-255
        this.isCheck = this.item.providingPerspective; //KFS-255
        this.bestAction = this.item.bestAction; //KFS-255
        this.description = this.item.description;
        this.howWillYouProvidePerspective = this.item.howWillYouProvidePerspective; //KFS-255
        this.handleshowMoreless();
        // Check
        checkAccess().then(result => {
            this.isUpdateable = result.isUpdateable;
            this.isDeletable = result.isDeletable;
        });
        getContactFieldName().then(result => {
            this.objectForLookup = result.lookupOnObject;
            this.contactFieldName = result.targetField;
        });
        getAssignedToFieldName().then(result => {
            this.assignedToFieldName = result.targetField;
        });
    }

    handleContactChange(event) {
        this.selectedContactId = event.detail;
    }
    handleUserChange(event) {
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

    handleEdit() {
        let itemtemp = JSON.parse(JSON.stringify(this.item));
        itemtemp.startDate = this.item2.startDate;
        itemtemp.dueDate = this.item2.dueDate;
        this.item = itemtemp;
        this.saveDisableFlag = false;
        this.selectedRecordId = this.item.assignedTo;
        this.showEditView = true;
        //KFS-255 -Starts
        if (this.providingPerspective === true) {
            this.yesCss = "slds-button selectedbutton slds-m-left_x-small";
            this.noCss = "slds-button slds-button_neutral slds-m-left_x-small";
        } else {
            this.noCss = "slds-button selectedbutton slds-m-left_x-small";
            this.yesCss = "slds-button slds-button_neutral slds-m-left_x-small";
        } //KFS-255-Ends
    }
    handleCancel() {
        let itemtemp = JSON.parse(JSON.stringify(this.item));
        if (this.item.startDate !== undefined) {
            itemtemp.startDate = this.getDateInLocaleFormat(this.item.startDate);
        }
        if (this.item.dueDate !== undefined) {
            itemtemp.dueDate = this.getDateInLocaleFormat(this.item.dueDate);
        }
        this.item = itemtemp;

        this.showEditView = false;
        this.bestActionCheck = this.item.bestAction; //146
        this.providingPerspective = this.item.providingPerspective; //KFS-255
        this.howWillYouProvidePerspective = this.item.howWillYouProvidePerspective; //KFS-255
        this.isCheck = this.item.providingPerspective; //KFS-255
        this.bestAction = this.item.bestAction; //KFS-255
        this.validationcheck = false;
    }
    handleDelete() {
        this.ShowModal = true;
    }
    fetchInputValues() {
        const inp = this.template.querySelectorAll("lightning-input");

        inp.forEach(function(element) {
            if (element.name === "summary") this.summary = element.value;
            else if (element.name === "startDate") this.startDate = element.value;
            else if (element.name === "dueDate") this.dueDate = element.value;
            else if (element.name === "AssignedTo") this.assignedTo = element.value;
        }, this);

        const des = this.template.querySelectorAll("lightning-textarea");

        des.forEach(function(element) {
            if (element.name === "Description") this.Description = element.value;
            else if (element.name === "Perspective") this.howWillYouProvidePerspective = element.value; //KFS-255
        }, this);

        const picklistValues = this.template.querySelectorAll("lightning-combobox");
        picklistValues.forEach(function(element) {
            if (element.name === "ActionType") {
                this.actionTypeValue = element.value;
            }
            if (element.name === "Status") {
                this.statusValue = element.value;
            }
            if (element.name === "Priority") {
                this.priorityValue = element.value;
            }
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
                targetElement.reportValidity();
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
        //KFS-255 -Ends

        const inputs = this.template.querySelectorAll("lightning-input", "lightning-textarea");
        inputs.forEach(input => {
            if (!input.checkValidity()) {
                input.reportValidity();
                allValid = false;
            }
        });
        return allValid;
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
    // KFS-146-Start
    handleonChange(event) {
        this.checkFlag = event.target.checked;
        if (this.checkFlag) {
            this.isCheck = false; //KFS-255
            this.bestAction = true;
            this.bestActionCheck = true;
            this.providingPerspective = false; //KFS-255
            this.noCss = "slds-button selectedbutton slds-m-left_x-small"; //KFS-255
            this.yesCss = "slds-button slds-button_neutral slds-m-left_x-small"; //KFS-255
        } else {
            this.isCheck = false; //KFS-255
            this.howWillYouProvidePerspective = "";
            this.providingPerspective = false; //KFS-255
            this.bestAction = false;
            this.bestActionCheck = false;
        }
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

    //KFS 255 starts
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
                this.isCheck = true;
            } else {
                this.providingPerspective = false;
                this.howWillYouProvidePerspective = "";
                this.isCheck = false;
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
    }
    //KFS-255 -Ends
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
            this.isCheck = true;
        } else {
            this.providingPerspective = false;
            this.noCss = `${value} selectedbutton`;
            this.yesCss = `${value} unselectedButton`;
            this.isCheck = false;
        }

        this.perspective = buttonvalue;
        if (this.perspective === "Yes") {
            this.providingPerspective = true;
            this.isCheck = true;
        } else {
            this.providingPerspective = false;
            this.howWillYouProvidePerspective = "";
            this.isCheck = false;
        }
    }
    greenStar() {
        this.isCheck = false; //KFS-255
        this.howWillYouProvidePerspective = ""; //KFS-255
        this.bestAction = false; //KFS-255
        this.bestActionCheck = false;
        this.providingPerspective = false; //KFS-255
        this.spinnerFlag = true;
        updateIsAction({
            recordId: this.item.Id,
            isActionchecks: this.bestActionCheck
        })
            .then(() => {
                // Show success messsage
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: success_header, //KFS-2766
                        message: Update_Success, //KFS-2766
                        variant: "success"
                    })
                );
                pubsub.fire("refreshBestActionGrid", "");
                const selectedEvent = new CustomEvent("refreshscreen", {
                    detail: true
                });
                this.dispatchEvent(selectedEvent);
                this.handleshowMorelessforEdit();
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: ErrorCreatingRecord, //KFS-2766
                        message: error.body.message,
                        variant: "error"
                    })
                );
            });
    }

    greyStar() {
        this.isCheck = false; //KFS-255
        this.bestAction = true; //KFS-255
        this.bestActionCheck = true;
        this.providingPerspective = false; //KFS-255
        this.howWillYouProvidePerspective = ""; //KFS-255
        this.noCss = "slds-button selectedbutton slds-m-left_x-small"; //KFS-255
        this.yesCss = "slds-button slds-button_neutral slds-m-left_x-small"; //KFS-255
        this.spinnerFlag = true;
        updateIsAction({
            recordId: this.item.Id,
            isActionchecks: this.bestActionCheck
        })
            .then(() => {
                // Show success messsage
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: success_header, //KFS-2766
                        message: this.label.Update_Success, //KFS-2766
                        variant: "success"
                    })
                );
                pubsub.fire("refreshBestActionGrid", "");
                const selectedEvent = new CustomEvent("refreshscreen", {
                    detail: true
                });
                this.dispatchEvent(selectedEvent);
                this.handleshowMorelessforEdit();
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.label.ErrorCreatingRecord, //KFS-2766
                        message: error.body.message,
                        variant: "error"
                    })
                );
            });
    }
    // KFS-146-END
    updateActionPlan(event) {
        this.fetchInputValues(event);
        this.showText = false;
        this.ShowLessText = false;
        this.ShowMoreText = false;
        const ifValid = this.validateInputs(event);
        this.showTextProvidePerspective = false; //KFS-255
        this.ShowLessTextProvidePerspective = false; //KFS-255
        this.ShowMoreTextProvidePerspective = false; //KFS-255
        // FIXME: Anirudh: Is undefined a value or are we checking if object is undefined?
        if (this.summary === "" || this.summary === "undefined" || this.summary === null) {
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
                Summary: this.summary,
                ActionType: this.actionTypeValue,
                AssignedTo: this.selectedRecordId,
                Contact: this.selectedContactId,
                Description: this.Description,
                DueDate: this.dueDate,
                Priority: this.priorityValue,
                StartDate: this.startDate,
                Status: this.statusValue,
                Id: this.item.Id,
                bestActionvalue: this.bestActionCheck,
                providingPerspectiveValue: this.providingPerspective, //KFS-255
                howWillYouProvidePerspectiveValue: this.howWillYouProvidePerspective //KFS-255
            };
            updateActionPlan({ actnPlan: JSON.stringify(actionPlanData) })
                .then(result => {
                    this.saveDisableFlag = false;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: success_header,
                            message: RecordUpdated,
                            variant: success_header
                        })
                    );
                    if (result === "Task Deleted") {
                        this.undelete = true;
                        this.autoClose = true;
                        if (this.autoClose) {
                            // eslint-disable-next-line
                            this.delayTimeout = setTimeout(() => {
                                this.undelete = false;
                            }, this.autoCloseTime);
                            // eslint-enable-next-line
                        }
                    } else if (result !== null && result === "Created") {
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

                    pubsub.fire("refreshBestActionGrid", "");
                    const selectedEvent = new CustomEvent("refreshscreen", {
                        detail: true
                    });

                    // Dispatches the event.
                    this.dispatchEvent(selectedEvent);
                    this.handleshowMorelessforEdit();
                    //this.connectedCallback();
                })
                .catch(error => {
                    this.saveDisableFlag = false;
                    this.handleCancel();
                    if (error) {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: error_header,
                                message: NoPermissionToDeleteTask,
                                variant: error_header
                            })
                        );
                    }
                });

            this.boolVisible = false;
            this.btnflag = false;
            this.showEditView = false;
            this.validationcheck = false;
        }
    }

    closeToast() {
        this.undelete = false;
    }
    undeleteTask() {
        undeleteTask({ recordId: this.item.Id }).then(() => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: success_header,
                    message: RecordRestored,
                    variant: success_header
                })
            );
            const selectedEvent = new CustomEvent("refreshscreen", {
                detail: true
            });
            this.dispatchEvent(selectedEvent);
            /*this.bestAction = this.item.bestAction;
            this.bestActionCheck = this.item.bestAction;*/
            this.bestActionCheck = true;
            this.bestAction = true;
            //this.item.bestAction = true;
            let tempItemVar = JSON.parse(JSON.stringify(this.item));
            tempItemVar.bestAction = true;
            this.item = tempItemVar;
        });
    }
    deleteModal() {
        this.ShowModal = false;
        deleteActionPlan({
            recordId: this.item.Id,
            summary: this.item.summary,
            isBestAction: this.item.bestAction
        })
            .then(() => {
                // Show success messsage
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: success_header,
                        message: RecordDeleted,
                        variant: success_header
                    })
                );
                pubsub.fire("refreshBestActionGrid", "");
                const selectedEvent = new CustomEvent("refreshscreen", {
                    detail: true
                });

                // Dispatches the event.
                this.dispatchEvent(selectedEvent);
            })
            .catch(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: error_header,
                        message: NoPermissionToDeleteTask,
                        variant: error_header
                    })
                );
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

    //KFS-255 -Starts
    handleShowMoreProvidePerspective() {
        this.showTextProvidePerspective = true;
        this.ShowMoreTextProvidePerspective = false;
        this.ShowLessTextProvidePerspective = true;
    }
    handleShowLessProvidePerspective() {
        this.showTextProvidePerspective = false;
        this.ShowLessTextProvidePerspective = false;
        this.ShowMoreTextProvidePerspective = true;
        if (this.template.querySelector(".divClass") != null) {
            this.template.querySelector(".divClass").scrollIntoView(true);
        }
    } //KFS-255-Ends

    handleshowMoreless() {
        var description = this.item.description;
        var howWillYouProvidePerspective = this.howWillYouProvidePerspective; //KFS-255
        if (description) {
            if (description.length > 250) {
                this.shortActionPlanDetils = "";
                this.longActionPlanDetils = "";
                this.shortActionPlanDetils = description.substr(0, 250);
                this.longActionPlanDetils = description.substr(250, description.length);
                this.ShowMoreText = true;
            } else {
                this.shortActionPlanDetils = description;
                this.longActionPlanDetils = "";
                this.ShowMoreText = false;
                this.ShowLessText = false;
            }
        }
        //KFS-255-Starts
        if (howWillYouProvidePerspective) {
            if (howWillYouProvidePerspective.length > 250) {
                this.shortActionPlanDetilsProvidePerspective = "";
                this.longActionPlanDetilsProvidePerspective = "";
                this.shortActionPlanDetilsProvidePerspective = howWillYouProvidePerspective.substr(0, 250);
                this.longActionPlanDetilsProvidePerspective = howWillYouProvidePerspective.substr(
                    250,
                    howWillYouProvidePerspective.length
                );
                this.ShowMoreTextProvidePerspective = true;
            } else {
                this.shortActionPlanDetilsProvidePerspective = howWillYouProvidePerspective;
                this.longActionPlanDetilsProvidePerspective = "";
                this.ShowMoreTextProvidePerspective = false;
                this.ShowLessTextProvidePerspective = false;
            }
        } //KFS-255 Ends
    }

    handleshowMorelessforEdit() {
        var description = this.Description;
        var howWillYouProvidePerspective = this.howWillYouProvidePerspective; //KFS-255
        if (description) {
            if (description.length > 250) {
                this.shortActionPlanDetils = "";
                this.longActionPlanDetils = "";
                this.shortActionPlanDetils = description.substr(0, 250);
                this.longActionPlanDetils = description.substr(250, description.length);
                this.ShowMoreText = true;
            } else {
                this.shortActionPlanDetils = description;
                this.longActionPlanDetils = "";
                this.ShowMoreText = false;
                this.ShowLessText = false;
            }
        }
        //KFS-255-Starts
        if (howWillYouProvidePerspective) {
            if (howWillYouProvidePerspective.length > 250) {
                this.shortActionPlanDetilsProvidePerspective = "";
                this.longActionPlanDetilsProvidePerspective = "";
                this.shortActionPlanDetilsProvidePerspective = howWillYouProvidePerspective.substr(0, 250);
                this.longActionPlanDetilsProvidePerspective = howWillYouProvidePerspective.substr(
                    250,
                    howWillYouProvidePerspective.length
                );
                this.ShowMoreTextProvidePerspective = true;
            } else {
                this.shortActionPlanDetilsProvidePerspective = howWillYouProvidePerspective;
                this.longActionPlanDetilsProvidePerspective = "";
                this.ShowMoreTextProvidePerspective = false;
                this.ShowLessTextProvidePerspective = false;
            }
        } //KFS-255 Ends
    }

    //KFS-814
    @api closeEditModal() {
        this.showEditView = false;
    }
}