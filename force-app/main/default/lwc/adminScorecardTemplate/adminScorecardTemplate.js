import { LightningElement, track, api, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { NavigationMixin } from "lightning/navigation";

import cancel from "@salesforce/label/c.cancel";
import save from "@salesforce/label/c.save";
import successheader from "@salesforce/label/c.success_header";
import errorheader from "@salesforce/label/c.error_header";
import errormsg from "@salesforce/label/c.Record_error_message";
import successmsg from "@salesforce/label/c.Record_success_message";
import Scorecard_Template_Criteria_HelpText from "@salesforce/label/c.Scorecard_Template_Criteria_HelpText";
import Scorecard_Criteria_Header from "@salesforce/label/c.Scorecard_Criteria_Header";
import Scorecard_Name_placeholder from "@salesforce/label/c.Scorecard_Name_placeholder";
import Scorecard_Template_Mark_As_Default from "@salesforce/label/c.Scorecard_Template_Mark_As_Default";
import Scorecard_Template_point_Value_text from "@salesforce/label/c.Scorecard_Template_point_Value_text";
import Scorecard_Template_PointValue_Warning from "@salesforce/label/c.Scorecard_Template_PointValue_Warning";
import Scorecard_Template_OrderNumber_Column from "@salesforce/label/c.Scorecard_Template_OrderNumber_Column";
import Scorecard_Template_Section_Column from "@salesforce/label/c.Scorecard_Template_Section_Column";
import Scorecard_Template_Title_Column from "@salesforce/label/c.Scorecard_Template_Title_Column";
import Scorecard_Template_Criteria_Column from "@salesforce/label/c.Scorecard_Template_Criteria_Column";
import Scorecard_Template_PointValue_Column from "@salesforce/label/c.Scorecard_Template_PointValue_Column";
import Scorecard_Template_Criteria_Type from "@salesforce/label/c.Scorecard_Template_Criteria_Type";
import Scorecard_Template_Criteria_placeholder from "@salesforce/label/c.Scorecard_Template_Criteria_placeholder";
import Scorecard_Template_Add_Criterion_Label from "@salesforce/label/c.Scorecard_Template_Add_Criterion_Label";
import Scorecard_Template_Required_Error from "@salesforce/label/c.Scorecard_Template_Required_Error";
import Scorecard_Template_IsActive_Column from "@salesforce/label/c.Scorecard_Template_IsActive_Column";
import Scorecard_Template_Name_Max_Char_Limit from "@salesforce/label/c.Scorecard_Template_Name_Max_Char_Limit";
import createAdminScoreCardRecord from "@salesforce/apex/ScorecardTemplateController.upsertAdminScoreCardRecord";
import getdata from "@salesforce/apex/ScorecardTemplateController.getData";
import getObjectName from "@salesforce/apex/ScorecardTemplateController.getObjectName";
import maxLimitError from "@salesforce/label/c.maxLimitError";
import orderNumber from "@salesforce/label/c.OrderNumber";
import Business from "@salesforce/label/c.Business";
import CategoryOpportunity from "@salesforce/label/c.CategoryOpportunity";
import Warning from "@salesforce/label/c.Warning";
import WarningLabel from "@salesforce/label/c.WarningLabel";
import getLanguagePicklistValues from "@salesforce/apex/ScorecardTemplateController.getLanguagePicklistValues";
import { getRecord } from "lightning/uiRecordApi";
import USER_ID from "@salesforce/user/Id";
import LANGUAGE_FIELD from "@salesforce/schema/User.LanguageLocaleKey";
import ScoreCardLanguage from "@salesforce/label/c.ScoreCardLanguage";

export default class adminScorecardTemplate extends NavigationMixin(LightningElement) {
    label = {
        cancel,
        save,
        successheader,
        errorheader,
        errormsg,
        successmsg,
        Scorecard_Template_Criteria_HelpText,
        Scorecard_Criteria_Header,
        Scorecard_Name_placeholder,
        Scorecard_Template_Mark_As_Default,
        Scorecard_Template_point_Value_text,
        Scorecard_Template_PointValue_Warning,
        Scorecard_Template_OrderNumber_Column,
        Scorecard_Template_Section_Column,
        Scorecard_Template_Title_Column,
        Scorecard_Template_Criteria_Column,
        Scorecard_Template_PointValue_Column,
        Scorecard_Template_Criteria_Type,
        Scorecard_Template_Criteria_placeholder,
        Scorecard_Template_Add_Criterion_Label,
        Scorecard_Template_Required_Error,
        Scorecard_Template_IsActive_Column,
        Scorecard_Template_Name_Max_Char_Limit,
        maxLimitError,
        orderNumber,
        Business, //KFS-2766
        CategoryOpportunity, //KFS-2766
        Warning,
        WarningLabel,
        ScoreCardLanguage
    };

    @track accRecords = [];

    @track index = 0;

    @api recordId;
    @track isInsert = true;

    @track section = "";
    @track isDefault = false;
    @track scoreCardName;
    @track scorecardLanguagePicklist = [];
    @track isActive = true;
    @track title = "";

    @track objectName;

    @track disableSave = true;

    @track childId;
    @track parentId;

    @track criteriaDef = "";
    @track pointValue;
    @track isActiveCriteria = false;
    @track totalPoint = 0;
    @track invalidPointVal = true;
    @track maxOrderNumber;
    @track maxCharReached = false;
    isOrderNumberValid = false;
    @track hasLanguageValues = false;
    @track defaultlanguage;
    @track languageSelected;

    @wire(getLanguagePicklistValues)
    languagePicklistResult({ data }) {
        if (data) {
            const result = JSON.parse(data);
            for (let key in result) {
                if (result.hasOwnProperty(key)) {
                    this.scorecardLanguagePicklist.push({ label: key, value: result[key] }); //Here we are creating the array to show on UI.
                }
            }
            if (this.scorecardLanguagePicklist.length > 0) {
                this.hasLanguageValues = true;
            }
        }
    }
    @wire(getRecord, {
        recordId: USER_ID,
        fields: [LANGUAGE_FIELD]
    })
    wireuser({ error, data }) {
        if (error) {
            this.error = error;
        } else if (data) {
            if (this.languageSelected === undefined) {
                this.defaultlanguage = data.fields.LanguageLocaleKey.value;
            }
        }
    }

    get options() {
        return [
            { label: this.label.Business, value: "Business" }, //KFS-2766
            { label: this.label.CategoryOpportunity, value: "Opportunity" } //KFS-2766
        ];
    }

    get LanguagePicklistValues() {
        return this.scorecardLanguagePicklist;
    }

    connectedCallback() {
        this.getObjectName();
        if (!this.recordId) {
            this.isInsert = true;
        } else {
            this.isInsert = false;
        }

        this.accountTempRecords();

        if (this.recordId) {
            this.getdataForScorecard();
        }
    }

    getObjectName() {
        getObjectName().then(result => {
            this.objectName = result;
        });
    }

    handleScorecardNameChange(event) {
        let scorecard = event.target.value;
        if (scorecard && scorecard.length > 255) {
            this.maxCharReached = true;
        } else {
            this.maxCharReached = false;
        }
    }

    handleChangeScoreCardLanguage(event) {
        this.defaultlanguage = event.target.value;
    }

    checktotalPoints() {
        if (this.totalPoint !== 100) {
            this.template.querySelector(".totalpoints").classList.add("highlightdiv");
            this.invalidPointVal = true;
            this.disableSave = true;
            if (this.template.querySelector('[data-id="divblock-1"]') !== null) {
                this.template.querySelector('[data-id="divblock-1"]').classList.add("slds-visible");
                this.template.querySelector('[data-id="divblock-1"]').classList.remove("slds-hidden");
            }
            if (this.template.querySelector('[data-id="divblock-2"]') !== null) {
                this.template.querySelector('[data-id="divblock-2"]').classList.remove("slds-hidden");
                this.template.querySelector('[data-id="divblock-2"]').classList.add("slds-visible");
            }
        } else {
            this.template.querySelector(".totalpoints").classList.remove("highlightdiv");
            this.invalidPointVal = false;
            this.disableSave = false;
            if (this.template.querySelector('[data-id="divblock-1"]') !== null) {
                this.template.querySelector('[data-id="divblock-1"]').classList.add("slds-hidden");
                this.template.querySelector('[data-id="divblock-1"]').classList.remove("slds-visible");
            }
            if (this.template.querySelector('[data-id="divblock-2"]') !== null) {
                this.template.querySelector('[data-id="divblock-2"]').classList.remove("slds-visible");
                this.template.querySelector('[data-id="divblock-2"]').classList.add("slds-hidden");
            }
        }
    }

    getdataForScorecard() {
        getdata({ recordId: this.recordId })
            .then(result => {
                let parentData = result;
                this.scoreCardName = parentData.adminScoreCard.adminName;
                this.isDefault = parentData.adminScoreCard.markAsDefault;
                this.languageSelected = parentData.adminScoreCard.language;
                this.isActive = parentData.adminScoreCard.isAct;
                this.totalPoint = parentData.adminScoreCard.totalPoint;
                this.parentId = parentData.adminScoreCard.parentId;
                this.accRecords = parentData.adminScoreCard.adminscorecardCriterias;
                this.accRecords.forEach(element => {
                    var newKey = "key";
                    var newVal = Math.random()
                        .toString(36)
                        .substring(2, 15);
                    element[newKey] = newVal;
                });

                if (this.accRecords != null) {
                    this.accountTempRecords();
                }
                this.error = undefined;
                this.maxOrderNumber = this.accRecords.length;
                this.checktotalPoints();
                if (this.languageSelected !== undefined) {
                    this.defaultlanguage = this.languageSelected;
                }
            })
            .catch(error => {
                this.error = error;
                this.record = undefined;
            });
    }

    handlDefaultUpdate(event) {
        this.isDefault = event.target.checked;
    }

    handlenameChange(event) {
        this.scoreCardName = event.target.value;
    }

    accountTempRecords() {
        if (this.accRecords && this.accRecords.length === 0) {
            this.orderNumber = this.accRecords.length + 1;
            this.maxOrderNumber = this.orderNumber;
            let i = 0;
            for (i = 0; i < 1; i++) {
                this.accRecords.push({
                    section: this.section,
                    title: this.title,
                    criteria: this.criteriaDef,
                    pointValue: this.pointValue,
                    isActiveCriteria: this.isActiveCriteria,
                    orderNumber: this.orderNumber,
                    childId: this.childId,
                    key: Math.random()
                        .toString(36)
                        .substring(2, 15)
                });
            }
        }
    }

    addRow() {
        const len = this.accRecords.length;
        this.orderNumber = len + 1;
        this.maxOrderNumber = this.orderNumber;
        this.accRecords.push({
            section: this.section,
            title: this.title,
            criteriaDef: this.criteriaDef,
            pointValue: this.pointValue,
            isActiveCriteria: this.isActiveCriteria,
            orderNumber: this.orderNumber,
            childId: this.childId,
            key: Math.random()
                .toString(36)
                .substring(2, 15)
        });
    }

    handlecriteriaChange(event) {
        if (this.recordId) {
            let foundelement = this.accRecords.find(ele => ele.childId === event.target.dataset.id);
            foundelement.criteriaDef = event.target.value;
            this.accRecords = [...this.accRecords];
        } else {
            let foundelement = this.accRecords.find(ele => ele.key === event.target.dataset.id);
            foundelement.criteriaDef = event.target.value;
            this.accRecords = [...this.accRecords];
        }
    }

    handleChange(event) {
        if (this.recordId) {
            let foundelement = this.accRecords.find(ele => ele.childId === event.target.dataset.id);
            foundelement.section = event.target.value;
            this.accRecords = [...this.accRecords];
        } else {
            let foundelement = this.accRecords.find(ele => ele.key === event.target.dataset.id);
            foundelement.section = event.target.value;
            this.accRecords = [...this.accRecords];
        }
    }

    handletitleChange(event) {
        if (this.recordId) {
            let foundelement = this.accRecords.find(ele => ele.childId === event.target.dataset.id);
            foundelement.title = event.target.value;
            this.accRecords = [...this.accRecords];
        } else {
            let foundelement = this.accRecords.find(ele => ele.key === event.target.dataset.id);
            foundelement.title = event.target.value;
            this.accRecords = [...this.accRecords];
        }
    }
    handleCriteriaActivation(event) {
        if (this.recordId) {
            let foundelement = this.accRecords.find(ele => ele.childId === event.target.dataset.id);
            foundelement.isActiveCriteria = event.target.checked === true;
            this.accRecords = [...this.accRecords];
        } else {
            let foundelement = this.accRecords.find(ele => ele.key === event.target.dataset.id);
            foundelement.isActiveCriteria = event.target.checked === true;
            this.accRecords = [...this.accRecords];
        }
        this.totalPoint = 0;
        this.accRecords.forEach(element => {
            if (element.pointValue && element.isActiveCriteria) {
                //this.totalPoint = parseInt(this.totalPoint,10) + parseInt(element.pointValue,10);
                this.totalPoint = Number(this.totalPoint) + Number(element.pointValue);
            }
        });
        this.checktotalPoints();
    }

    handlepointupdate(event) {
        if (this.recordId) {
            let foundelement = this.accRecords.find(ele => ele.childId === event.target.dataset.id);
            foundelement.pointValue = event.target.value;
            this.accRecords = [...this.accRecords];
        } else {
            let foundelement = this.accRecords.find(ele => ele.key === event.target.dataset.id);
            foundelement.pointValue = event.target.value;
            this.accRecords = [...this.accRecords];
        }
        this.totalPoint = 0;
        this.accRecords.forEach(element => {
            if (element.pointValue && element.isActiveCriteria) {
                this.totalPoint = Number(this.totalPoint) + Number(element.pointValue);
                //this.totalPoint = parseInt(this.totalPoint,10) + parseInt(element.pointValue,10);
            }
        });
        this.checktotalPoints();
    }

    handleOrderupdate(event) {
        if (this.recordId) {
            let foundelement = this.accRecords.find(ele => ele.childId === event.target.dataset.id);
            foundelement.orderNumber = event.target.value;
            this.accRecords = [...this.accRecords];
        } else {
            let foundelement = this.accRecords.find(ele => ele.key === event.target.dataset.id);
            foundelement.orderNumber = event.target.value;
            this.accRecords = [...this.accRecords];
        }
    }

    handleCancel() {
        this[NavigationMixin.Navigate]({
            type: "standard__objectPage",
            attributes: {
                objectApiName: this.objectName,
                actionName: "list"
            },
            state: {
                filterName: "All"
            }
        });
    }

    handleSave() {
        let isValidInput = true;
        let isValidCombo = true;
        let isValidName = true;

        const allValidName = [...this.template.querySelectorAll("lightning-input")].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        if (allValidName) {
            isValidName = true;
        } else {
            isValidName = false;
        }

        const allValid = [...this.template.querySelectorAll("lightning-textarea")].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        if (allValid) {
            isValidInput = true;
        } else {
            isValidInput = false;
        }

        const allValidCombo = [...this.template.querySelectorAll("lightning-combobox")].reduce(
            (validSoFar, inputCmp) => {
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            },
            true
        );
        if (allValidCombo) {
            isValidCombo = true;
        } else {
            isValidCombo = false;
        }
        let toSaveList = this.accRecords.slice(0);
        toSaveList.forEach((element, index) => {
            let eleType = typeof element.Name;
            if (element.Name === "" || eleType === "object") {
                toSaveList.splice(index);
            }
        });
        this.checkIfOrderNumberisValid();

        if (isValidCombo && isValidInput && isValidName && !this.maxCharReached && this.isOrderNumberValid) {
            this.disableSave = true;
            let parentData = {
                adminName: this.scoreCardName,
                markAsDefault: this.isDefault,
                language: this.defaultlanguage,
                isAct: this.isActive,
                parentId: this.parentId,
                adminscorecardCriterias: toSaveList
            };

            let inputData = {
                adminScoreCard: parentData
            };

            createAdminScoreCardRecord({ inputString: JSON.stringify(inputData) })
                .then(result => {
                    let returnResult = result;
                    let parentId = returnResult.adminScoreCard.parentId;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: this.label.successheader,
                            message: this.label.successmsg,
                            variant: "success"
                        })
                    );
                    this.accountTempRecords();
                    this.error = undefined;
                    this[NavigationMixin.Navigate]({
                        type: "standard__recordPage",
                        attributes: {
                            recordId: parentId,
                            objectApiName: this.objectName,
                            actionName: "view"
                        }
                    });
                    this.disableSave = false;
                })
                .catch(error => {
                    this.error = error;
                    this.record = undefined;
                });
        }
    }

    checkIfOrderNumberisValid() {
        let orderNumberArr = [];
        this.accRecords.forEach(element => {
            orderNumberArr.push(element.orderNumber);
        });
        if (orderNumberArr.length === 1) {
            this.isOrderNumberValid = true;
        } else {
            const isOrderNumberUnique = this.checkIfArrayIsUnique(orderNumberArr);

            if (isOrderNumberUnique) {
                //true means unique,
                this.isOrderNumberValid = true;
            } else {
                //false means dupes
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.label.errorheader,
                        message: this.label.orderNumber,
                        variant: "error"
                    })
                );
                this.isOrderNumberValid = false;
            }
        }
    }

    checkIfArrayIsUnique(myArray) {
        const len = myArray.length;
        for (let i = 0; i < len; i++) {
            for (let j = 0; j < len; j++) {
                // if the elements match, this wouldn't be a unique array
                let x = Number(myArray[i]);
                let y = Number(myArray[j]);
                if (i !== j && x === y) {
                    return false; // duplicate
                }
            }
        }
        return true; // means unique
    }

    handleMaxLimitErrorTitle(event) {
        let divId = event.target.name;
        let titleVaL = event.target.value;
        const divErrBlock = "errordivblocktitle";
        let elementMain = this.getAllDivBlocks(divErrBlock, divId);

        if (titleVaL && titleVaL.length === 32000) {
            elementMain.style.display = "block";
        } else {
            elementMain.style.display = "none";
        }
    }
    handleMaxLimitErrorCriteria(event) {
        let divId = event.target.name;
        let titleVaL = event.target.value;
        const divErrBlock = "errordivblockcriteria";
        let elementMain = this.getAllDivBlocks(divErrBlock, divId);
        if (titleVaL && titleVaL.length === 32000) {
            elementMain.style.display = "block";
        } else {
            elementMain.style.display = "none";
        }
    }

    getAllDivBlocks(errordivblockVar, divId) {
        let elementMain = "";
        const errorDivBlockLst = this.template.querySelectorAll('[data-id="' + errordivblockVar + '"]');
        errorDivBlockLst.forEach(element => {
            const eleTmpId = element.id;
            if (eleTmpId.includes(divId)) {
                elementMain = element;
            }
        });
        return elementMain;
    }
}