import { LightningElement, track, api, wire } from "lwc";
import createSSORecord from "@salesforce/apex/SingleSalesObjectiveController.createSSORecord";
import getSSORecords from "@salesforce/apex/SingleSalesObjectiveController.getSSORecords";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import checkAccess from "@salesforce/apex/SingleSalesObjectiveController.getSSOAccess";
import editLabel from "@salesforce/label/c.edit";
import deleteLabel from "@salesforce/label/c.delete";
import singleSalesObjective from "@salesforce/label/c.singleSalesObjective";
import Customer_Timing_for_Priorities from "@salesforce/label/c.Customer_Timing_for_Priorities";
import Urgent from "@salesforce/label/c.Urgent";
import Active from "@salesforce/label/c.Active";
import Work_It_In from "@salesforce/label/c.Work_It_In";
import Later from "@salesforce/label/c.Later";
import Customer_Stated_Objective from "@salesforce/label/c.Customer_Stated_Objective";
import CustomerStatedObjective_PlaceHolder from "@salesforce/label/c.CustomerStatedObjective_PlaceHolder";
import Evaluation_of_Objective_PlaceHolder from "@salesforce/label/c.Evaluation_of_Objective_PlaceHolder";
import maxLimitError from "@salesforce/label/c.maxLimitError";
import Evaluation_of_Objective from "@salesforce/label/c.Evaluation_of_Objective";
import Complete_Single_Sales_Objective from "@salesforce/label/c.Complete_Single_Sales_Objective";
import cancel from "@salesforce/label/c.cancel";
import save from "@salesforce/label/c.save";
import error_header from "@salesforce/label/c.error_header";
import Record_error_message from "@salesforce/label/c.Record_error_message";
import success_header from "@salesforce/label/c.success_header";
import Record_Created_Successfully from "@salesforce/label/c.Record_Created_Successfully";
import sSoHeaderURL from "@salesforce/label/c.sSoHeaderURL";
import sSoCustomerStatedURL from "@salesforce/label/c.sSoCustomerStatedURL";
import sSoCustTimingPriorities from "@salesforce/label/c.sSoCustTimingPriorities";
import getOppId from "@salesforce/apex/StrategyEngine.getOppId";
import DeleteRecord from "@salesforce/label/c.DeleteRecord";
import EditRecord from "@salesforce/label/c.EditRecord";
import getSingleSalesObjectData from "@salesforce/apex/GuidedLearningModuleProgress.getSingleSalesObjectData";
import { registerListener } from "c/eventForBlueSheetProgress";
import { CurrentPageReference } from "lightning/navigation";

export default class SsoMainPage extends LightningElement {
    @track createNewRecord = false;
    @track checkboxValue = "";
    @track laterCheck = false;
    @track workCheck = false;
    @track activeCheck = false;
    @track urgentCheck = false;
    @track createNewBtnFlag = false;
    @track showMaxLimitErrorCSO = false;
    @track showMaxLimitErrorEOF = false;
    @track CustomerStatedObjective = "";
    @track EvaluationofObjective = "";
    @track ssoDataFrmBackend;
    // @api getIdFromParent;
    @track _getIdFromParent;
    @wire(CurrentPageReference) pageRef;
    @api
    get getIdFromParent() {
        return this._getIdFromParent;
    }

    set getIdFromParent(value) {
        this._getIdFromParent = value;
        getOppId({ blueSheetId: this.getIdFromParent }).then(result => {
            this.optyId = result;
            this.getssoDataFromBackend();
        });
        this.ShowModuleDependentData();
    }

    childBtnFlag = false;
    disableEdit = false;
    @track optyId = "";
    @api recordId;
    //code to show hide the daata on self guided journey tootip
    @track moduleLearningCompleted = false;
    @track _moduleData;
    @track moduleSection;

    @api get moduleData() {
        return this._moduleData;
    }
    set moduleData(value) {
        this._moduleData = value;
        this.ProcessModuleData();
    }
    ProcessModuleData() {
        if (this._moduleData) {
            this.ShowModuleDependentData();
            if (this._moduleData.moduleNameId === "Lesson_3_Module_2") {
                this.moduleSection = "CustomerStatedObjective";
            }
            if (this.moduleData && this.moduleData.moduleBluesheetProgress === "Completed") {
                this.moduleLearningCompleted = true;
            }
        }
    }
    ShowModuleDependentData() {
        if (this.moduleLearningCompleted !== true) {
            if (this.moduleData && this.moduleData.moduleBluesheetProgress === "Completed") {
                this.moduleLearningCompleted = true;
            } else {
                getSingleSalesObjectData().then(result => {
                    if (result != null) {
                        if (result.customerStatedObjective) {
                            this.moduleLearningCompleted = true;
                        } else {
                            this.moduleLearningCompleted = false;
                        }
                    }
                });
            }
        } else {
            this.moduleLearningCompleted = true;
        }
        if (this.template.querySelector("c-go-to-bluesheet-prompts")) {
            this.template.querySelector("c-go-to-bluesheet-prompts").reloadPrompt();
        }
    }
    //end of code
    label = {
        Evaluation_of_Objective_PlaceHolder,
        CustomerStatedObjective_PlaceHolder,
        success_header,
        editLabel,
        deleteLabel,
        singleSalesObjective,
        Customer_Timing_for_Priorities,
        Urgent,
        Active,
        Work_It_In,
        Later,
        Customer_Stated_Objective,
        maxLimitError,
        Evaluation_of_Objective,
        Complete_Single_Sales_Objective,
        cancel,
        save,
        error_header,
        Record_error_message,
        Record_Created_Successfully,
        sSoHeaderURL,
        sSoCustomerStatedURL,
        sSoCustTimingPriorities,
        DeleteRecord,
        EditRecord
    };

    @track
    rfsDetails = this.getNewRfsDetails();

    @track readOnly = false;
    @track isUpdateable = false;
    @track isCreateable = false;

    getNewRfsDetails() {
        return {
            CustomerTimingforPriorities: {
                redFlagSelected: false,
                strengthSelected: false,
                noneSelected: true,
                fieldApiName: "CustomerTimingforPriorities"
            },
            CustomersStatedObjectives: {
                redFlagSelected: false,
                strengthSelected: false,
                noneSelected: true,
                fieldApiName: "CustomersStatedObjectives"
            },
            EvaluationofObjectives: {
                redFlagSelected: false,
                strengthSelected: false,
                noneSelected: true,
                fieldApiName: "EvaluationofObjectives"
            }
        };
    }

    handleMarkerChange(event) {
        const eventChangedMarker = event.detail;
        const rfsDetailsUpdate = this.rfsDetails[eventChangedMarker.fieldApiName];
        Object.keys(rfsDetailsUpdate).forEach(key => {
            if (eventChangedMarker[key] !== undefined && eventChangedMarker[key] != null) {
                rfsDetailsUpdate[key] = eventChangedMarker[key];
            }
        });
    }

    connectedCallback() {
        checkAccess().then(result => {
            if (result.isCreateable) {
                this.isCreateable = true;
                this.readOnly = false;
            } else {
                this.isCreateable = false;
                this.readOnly = true;
            }
            this.isUpdateable = result.isUpdateable;
        });
        registerListener("ModuleDataSSO", this.reloadModuleData, this);
    }

    reloadModuleData(moduleData) {
        this._moduleData = moduleData;
        this.ProcessModuleData();
    }

    handleProgress() {
        const selectedEvent = new CustomEvent("updateprogressfromchild", {
            detail: true
        });
        this.dispatchEvent(selectedEvent);
    }
    handleRefresh() {
        this.handleProgress();
        this.getssoDataFromBackend();
        this.ShowModuleDependentData();
    }

    getssoDataFromBackend() {
        //alert('Method Call from Callback');
        getSSORecords({ oppId: this.optyId })
            .then(result => {
                this.ssoDataFrmBackend = result;
                //console.log('SSO DATA222'+ this.ssoDataFrmBackend.Customer_Timing_for_Priorities__c);
                if (this.ssoDataFrmBackend.length === 0) {
                    this.createNewBtnFlag = true;
                } else {
                    this.childBtnFlag = true;
                }
            })
            .catch(() => {});
    }

    handleClickNew() {
        this.createNewRecord = true;
        this.createNewBtnFlag = false;
    }

    handlePrioritues(event) {
        this.checkboxValue = event.target.value;
        //console.log('VALUE Main Page '+ this.checkboxValue);
        if (
            (this.checkboxValue === this.label.Urgent && this.urgentCheck === true) ||
            (this.checkboxValue === this.label.Active && this.activeCheck === true) ||
            (this.checkboxValue === this.label.Work_It_In && this.workCheck === true) ||
            (this.checkboxValue === this.label.Later && this.laterCheck === true)
        ) {
            this.checkboxValue = "";
            this.urgentCheck = false;
            this.laterCheck = false;
            this.workCheck = false;
            this.activeCheck = false;
        } else {
            if (event.target.value === this.label.Urgent) {
                this.urgentCheck = true;
                this.laterCheck = false;
                this.workCheck = false;
                this.activeCheck = false;
            }
            if (event.target.value === this.label.Active) {
                this.activeCheck = true;
                this.laterCheck = false;
                this.workCheck = false;
                this.urgentCheck = false;
            }
            if (event.target.value === this.label.Work_It_In) {
                this.workCheck = true;
                this.laterCheck = false;
                this.activeCheck = false;
                this.urgentCheck = false;
            }
            if (event.target.value === this.label.Later) {
                this.laterCheck = true;
                this.workCheck = false;
                this.activeCheck = false;
                this.urgentCheck = false;
            }
        }
    }

    handleCancel() {
        this.createNewRecord = false;
        this.createNewBtnFlag = true;
        this.laterCheck = false;
        this.workCheck = false;
        this.activeCheck = false;
        this.urgentCheck = false;
        this.rfsDetails = this.getNewRfsDetails();
    }

    handleCancelFromChild() {
        this.childBtnFlag = true;
        this.disableEdit = false;
    }

    childshowDeleteModal() {
        this.template.querySelector("c-sso-Data-Page").showDeleteModal();
    }

    childhandleEdit() {
        this.childBtnFlag = false;
        this.disableEdit = true;
        this.template.querySelector("c-sso-Data-Page").handleEdit();
    }

    handleMaxLimitErrorCSO(event) {
        var customerStatedObjectiveLimit = event.target.value;
        if (customerStatedObjectiveLimit.length === 32000) {
            this.showMaxLimitErrorCSO = true;
        } else {
            this.showMaxLimitErrorCSO = false;
        }
    }

    handleMaxLimitErrorEOF(event) {
        var customerStatedObjectiveLimit = event.target.value;
        if (customerStatedObjectiveLimit.length === 32000) {
            this.showMaxLimitErrorEOF = true;
        } else {
            this.showMaxLimitErrorEOF = false;
        }
    }

    handleCreateSSO() {
        let ssoWrapper = {};
        ssoWrapper.blueSheet = "";
        ssoWrapper.custTimingPriorities = this.checkboxValue;
        ssoWrapper.customerStatedObjective = this.CustomerStatedObjective;
        ssoWrapper.evaluationOfObjectives = this.EvaluationofObjective;
        ssoWrapper.ssoId = "";
        this.ssoWrapper = ssoWrapper;
        this.createNewBtnFlag = false;
        this.createNewRecord = false;
        this.showMaxLimitErrorCSO = false;
        this.showMaxLimitErrorEOF = false;
        createSSORecord({
            jsonString: JSON.stringify(this.ssoWrapper),
            oppId: this.optyId,
            rfsMap: this.rfsDetails
        })
            .then(result => {
                window.console.log("result ===> " + result);
                // Show success messsage
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.label.success_header,
                        message: this.label.Record_Created_Successfully,
                        variant: this.label.success_header
                    })
                );
                this.handleProgress();
                this.getssoDataFromBackend();
                this.ShowModuleDependentData();
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.label.Record_error_message,
                        message: error.body.message,
                        variant: this.label.error_header
                    })
                );
            });
    }

    handleCSOChange(event) {
        this.CustomerStatedObjective = event.target.value;
    }

    handleEOFChange(event) {
        this.EvaluationofObjective = event.target.value;
    }
}