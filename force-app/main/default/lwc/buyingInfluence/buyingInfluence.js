import { LightningElement, track, api, wire } from "lwc";
import getBuyingInfluence from "@salesforce/apex/BuyingInfluenceDetails.getBuyingInfluence";
//import getBlueSheetId from "@salesforce/apex/BuyingInfluenceDetails.getBlueSheetId";
import saveRecord from "@salesforce/apex/BuyingInfluenceDetails.saveRecord";
import deleteRecord from "@salesforce/apex/BuyingInfluenceDetails.deleteRecord";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import objectForLookup from "@salesforce/apex/BuyingInfluenceDetails.getObjectName";
import checkAccess from "@salesforce/apex/BuyingInfluenceDetails.getBuyingInfluenceAccess";
import error_header from "@salesforce/label/c.error_header";
import Please_fill_the_Contact_Field from "@salesforce/label/c.Please_fill_the_Contact_Field";
import competitivePreferenceLabel from "@salesforce/label/c.competitivePreference";
import buyingFromSomeOneElseLabel from "@salesforce/label/c.buyingFromSomeOneElse";
import usingBudgetforSomethingLabel from "@salesforce/label/c.usingBudgetforSomething";
import usingInternalResourceLabel from "@salesforce/label/c.usingInternalResource";
import doingNothingLabel from "@salesforce/label/c.doingNothing";
import buyfromusLabel from "@salesforce/label/c.buyfromus";
import buyingInfluenceRoleLabel from "@salesforce/label/c.buyingInfluenceRole";
import technicalLabel from "@salesforce/label/c.technical";
import userLabel from "@salesforce/label/c.user";
import economicLabel from "@salesforce/label/c.economic";
import coachLabel from "@salesforce/label/c.coach";
import degreeofInfluenceLabel from "@salesforce/label/c.degreeofInfluence";
import highLabel from "@salesforce/label/c.high";
import lowLabel from "@salesforce/label/c.low";
import mediumLabel from "@salesforce/label/c.medium";
import buyingModeLabel from "@salesforce/label/c.buyingMode";
import growthLabel from "@salesforce/label/c.growth";
import evenKeelLabel from "@salesforce/label/c.evenKeel";
import overConfidentLabel from "@salesforce/label/c.overConfident";
import troubleLabel from "@salesforce/label/c.Trouble";
import personalWinsLabel from "@salesforce/label/c.personalWins";
import businessResultsLabel from "@salesforce/label/c.businessResults";
import ratingLabel from "@salesforce/label/c.rating";
import ratingEvidenceLabel from "@salesforce/label/c.ratingEvidence";
import buyingInfluenceRolesLabel from "@salesforce/label/c.buyingInfluenceRoles";
import buyingInfluenceLabel from "@salesforce/label/c.buyingInfluence";
import addBuyingInfluenceLabel from "@salesforce/label/c.addBuyingInfluence";
import showMoreLabel from "@salesforce/label/c.showMore";
import showLessLabel from "@salesforce/label/c.showLess";
import deleteBuyingInfluenceLabel from "@salesforce/label/c.deleteBuyingInfluence";
import yesLabel from "@salesforce/label/c.yes";
import noLabel from "@salesforce/label/c.no";
import cancelLabel from "@salesforce/label/c.cancel";
import saveLabel from "@salesforce/label/c.save";
import editLabel from "@salesforce/label/c.edit";
import deleteLabel from "@salesforce/label/c.delete";
import closeLabel from "@salesforce/label/c.close";
import deleteBuyingInfluenceMessage from "@salesforce/label/c.deleteBuyingInfluenceMessage";
import nfivemsgLabel from "@salesforce/label/c.nfivemsg";
import nfourmsgLabel from "@salesforce/label/c.nfourmsg";
import nthreemsgLabel from "@salesforce/label/c.nthreemsg";
import ntwomsgLabel from "@salesforce/label/c.ntwomsg";
import nonemsgLabel from "@salesforce/label/c.nonemsg";
import ponemsgLabel from "@salesforce/label/c.ponemsg";
import ptwomsgLabel from "@salesforce/label/c.ptwomsg";
import pthreemsgLabel from "@salesforce/label/c.pthreemsg";
import pfourmsgLabel from "@salesforce/label/c.pfourmsg";
import pfivemsgLabel from "@salesforce/label/c.pfivemsg";
import brPlaceholderLabel from "@salesforce/label/c.brPlaceholder";
import pwPlaceholderLabel from "@salesforce/label/c.pwPlaceholder";
import rePlaceholderLabel from "@salesforce/label/c.rePlaceholder";
//KFS-6
import EditContactInfoLabel from "@salesforce/label/c.EditContactInfo";
import AddeNewContactLabel from "@salesforce/label/c.AddeNewContact";
import MailingCountryLabel from "@salesforce/label/c.MailingCountry";
import MailingZipPostalCodeLabel from "@salesforce/label/c.MailingZipPostalCode";
import MailingCityLabel from "@salesforce/label/c.MailingCity";
import MailingStreetLabel from "@salesforce/label/c.MailingStreet";
import AddressInformationLabel from "@salesforce/label/c.AddressInformation";
import StateProvinceLabel from "@salesforce/label/c.StateProvince";
import DepartmentLabel from "@salesforce/label/c.Department";
import MailingStateProvinceLabel from "@salesforce/label/c.MailingStateProvince";
import EmailLabel from "@salesforce/label/c.Email";
import MobilePhoneLabel from "@salesforce/label/c.MobilePhone";
import BusinessPhoneLabel from "@salesforce/label/c.BusinessPhone";
import AccountIDLabel from "@salesforce/label/c.AccountID";
import LastNameLabel from "@salesforce/label/c.LastName";
import FirstNameLabel from "@salesforce/label/c.FirstName";
import SalutationLabel from "@salesforce/label/c.Salutation";
import FullNameLabel from "@salesforce/label/c.FullName";
import OwnerIDLabel from "@salesforce/label/c.OwnerID";
import ContactInformationLabel from "@salesforce/label/c.ContactInformation";
import EditContactLabel from "@salesforce/label/c.EditContact";
import LocationLabel from "@salesforce/label/c.Location";
import TitleLabel from "@salesforce/label/c.Title";
import NameLabel from "@salesforce/label/c.Name";
import OtherPhoneLabel from "@salesforce/label/c.OtherPhone";
import RecordDeletedLabel from "@salesforce/label/c.RecordDeleted";
import RecordSaveLabel from "@salesforce/label/c.RecordSave";
import SuccessLabel from "@salesforce/label/c.Success";
import ErrorLabel from "@salesforce/label/c.Error";
import buying_InfluenceHeaderURL from "@salesforce/label/c.buying_InfluenceHeaderURL";
import buying_InfluenceRoleURL from "@salesforce/label/c.buying_InfluenceRoleURL";
import degreeofInfluenceURL from "@salesforce/label/c.degreeofInfluenceURL";
import buyingModeURL from "@salesforce/label/c.buyingModeURL";
import competitivePrefURL from "@salesforce/label/c.competitivePrefURL";
import personalWinURL from "@salesforce/label/c.personalWinURL";
import ratingURL from "@salesforce/label/c.ratingURL";
import evidenceURL from "@salesforce/label/c.evidenceURL";
import myPosVsCompetitionURL from "@salesforce/label/c.myPosVsCompetitionURL";
import MaxTextLimitError from "@salesforce/label/c.maxLimitError";
import getOppId from "@salesforce/apex/StrategyEngine.getOppId";
import pubsub from "c/pubSub";
import Scorecard_Template_Title_Column from "@salesforce/label/c.Scorecard_Template_Title_Column";
import Country from "@salesforce/label/c.Country";
import searchCompetitior from "@salesforce/label/c.searchCompetitior";
import Loading from "@salesforce/label/c.Loading";
import SuccessHeader from "@salesforce/label/c.success_header";
import getBuyingInfluenceData from "@salesforce/apex/GuidedLearningModuleProgress.getBuyingInfluenceData";
import checkBIforCoach from "@salesforce/apex/GuidedLearningModuleProgress.checkBIforCoach";
import checkBIforDegrees from "@salesforce/apex/GuidedLearningModuleProgress.checkBIforDegrees";
import checkBIforModes from "@salesforce/apex/GuidedLearningModuleProgress.checkBIforModes";
import checkBIforRatings from "@salesforce/apex/GuidedLearningModuleProgress.checkBIforRatings";
import checkBIforWinOrResults from "@salesforce/apex/GuidedLearningModuleProgress.checkBIforWinOrResults";
import { registerListener } from "c/eventForBlueSheetProgress";
import { CurrentPageReference } from "lightning/navigation";

export default class BuyingInfluence extends LightningElement {
    @track optyId = "";
    @api recordId;
    @track disableSaveButton = true;
    // @api getIdFromParent;
    @track _getIdFromParent;
    @api
    get getIdFromParent() {
        return this._getIdFromParent;
    }

    set getIdFromParent(value) {
        this._getIdFromParent = value;
        getOppId({ blueSheetId: this.getIdFromParent }).then(result => {
            this.optyId = result;
            this.recordId = result;
            this.getBIData();
        });
    }
    @api objectApiName;
    @wire(CurrentPageReference) pageRef;
    @track createNewRecord = false;
    @track showNewRecordButton = true;
    @track showeditbutton = false;
    @track biObject;
    @track blueSheetId;
    @track biId;
    @track biName;
    @track highCheck;
    @track mediumCheck;
    @track lowCheck;
    @track currentBiId;
    @track biList = [];
    @track currBusinessResult;
    @track currRatingEvidence;
    @track currPersonalWins;
    @track currDegree;
    @track recordToDelete;
    @track btnflag = false;
    @track showBrText = false;
    @track currentRecId;
    @track biRecordForSave;
    isDisplay = false;
    @track ratingText = "";
    @track rating;
    @track degreeOfInfluence;
    @track buyingMode;
    @track competitivePreference;
    @track selectedCompId;
    @track selectedContact;

    @track biRoleMap = {};

    @track highCss = "slds-button slds-button_neutral slds-m-left_x-small";
    @track highSelected = "false";
    @track mediumCss = "slds-button slds-button_neutral slds-m-left_x-small";
    @track mediumSelected = "false";
    @track lowCss = "slds-button slds-button_neutral slds-m-left_x-small";
    @track lowSelected = "false";

    @track buyfromusCss = "slds-button slds-button_neutral slds-m-left_x-small";
    @track buyfromusSelected = "false";
    @track nothingCss = "slds-button slds-button_neutral slds-m-left_x-small";
    @track nothingSelected = "false";
    @track buyfromelseCss = "slds-button slds-button_neutral slds-m-left_x-small";
    @track buyfromelseSelected = "false";
    @track usingbudgetCss = "slds-button slds-button_neutral slds-m-left_x-small";
    @track usingbudgetSelected = "false";
    @track internalresourceCss = "slds-button slds-button_neutral slds-m-left_x-small";
    @track internalresourceSelected = "false";

    @track technicalCss = "slds-button slds-button_neutral slds-m-left_x-small";
    @track technicalSelected = "false";
    @track economicCss = "slds-button slds-button_neutral slds-m-left_x-small";
    @track economicSelected = "false";
    @track userCss = "slds-button slds-button_neutral slds-m-left_x-small";
    @track userSelected = "false";
    @track coachCss = "slds-button slds-button_neutral slds-m-left_x-small";
    @track coachSelected = "false";

    @track growthCss = "slds-button slds-button_neutral slds-m-left_x-small";
    @track growthSelected = "false";
    @track troubleCss = "slds-button slds-button_neutral slds-m-left_x-small";
    @track troubleSelected = "false";
    @track evenkeelCss = "slds-button slds-button_neutral slds-m-left_x-small";
    @track evenkeelSelected = "false";
    @track overconfidentCss = "slds-button slds-button_neutral slds-m-left_x-small";
    @track overconfidentSelected = "false";

    //rating
    @track moneCss = "slds-p-top_x-small midnum";
    @track moneSelected = "false";
    @track mtwoCss = "slds-p-top_x-small midnum";
    @track mtwoSelected = "false";
    @track mthreeCss = "slds-p-top_x-small midnum";
    @track mthreeSelected = "false";
    @track mfourCss = "slds-p-top_x-small midnum";
    @track mfourSelected = "false";
    @track mfiveCss = "slds-p-top_x-small midnum";
    @track mfiveSelected = "false";
    @track poneCss = "slds-p-top_x-small midnum";
    @track poneSelected = "false";
    @track ptwoCss = "slds-p-top_x-small midnum";
    @track ptwoSelected = "false";
    @track pthreeCss = "slds-p-top_x-small midnum";
    @track pthreeSelected = "false";
    @track pfourCss = "slds-p-top_x-small midnum";
    @track pfourSelected = "false";
    @track pfiveCss = "slds-p-top_x-small midnum";
    @track pfiveSelected = "false";

    @track businessResults = "";

    //delete modal
    @track isOpenModal = false;
    @track bShowSpinner = false;

    @api contactName = "";
    @track contactFname = "";
    @track contactLname = "";
    @track conTitle = "";
    @track conMailingState = "";
    @track conMailingCountry = "";

    @track contactTitle = "Title";
    @track contactId = "";
    @track contactLocation = "Country";
    @track contactStateProvince = " State ";
    @track conidshow = false;
    @track newconform = false;
    @track editconform = false;
    @track checkNoDataAndReadOnlyAccess = false;
    @api conname1 = "";
    showMaxLimitErrorBR = false;
    showMaxLimitErrorRE = false;
    showMaxLimitErrorPW = false;

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
            // this.showModuleDependentData();
            if (this._moduleData.moduleNameId === "Lesson_4_Module_1") {
                this.moduleSection = "BuyingInfluence";
                if (this._moduleData.moduleBluesheetProgress === "Completed") {
                    this.moduleLearningCompleted = true;
                } else {
                    this.countBI();
                }
            } else if (this._moduleData.moduleNameId === "Lesson_4_Module_2") {
                this.moduleSection = "BuyingInfluenceCoach";
                if (this._moduleData.moduleBluesheetProgress === "Completed") {
                    this.moduleLearningCompleted = true;
                } else {
                    this.checkCoach();
                }
            } else if (this._moduleData.moduleNameId === "Lesson_4_Module_4") {
                this.moduleSection = "BuyingInfluenceDegree";
                if (this._moduleData.moduleBluesheetProgress === "Completed") {
                    this.moduleLearningCompleted = true;
                } else {
                    this.checkDegree();
                }
            } else if (this._moduleData.moduleNameId === "Lesson_5_Module_1") {
                this.moduleSection = "BuyingInfluenceMode";
                if (this._moduleData.moduleBluesheetProgress === "Completed") {
                    this.moduleLearningCompleted = true;
                } else {
                    this.checkModes();
                }
            } else if (this._moduleData.moduleNameId === "Lesson_5_Module_3") {
                this.moduleSection = "BuyingInfluenceRatings";
                if (this._moduleData.moduleBluesheetProgress === "Completed") {
                    this.moduleLearningCompleted = true;
                } else {
                    this.checkRatings();
                }
            } else if (this._moduleData.moduleNameId === "Lesson_6_Module_1") {
                this.moduleSection = "BuyingInfluenceWinsOrResults";
                if (this._moduleData.moduleBluesheetProgress === "Completed") {
                    this.moduleLearningCompleted = true;
                } else {
                    this.checkWinsOrResults();
                }
            }
        }
    }

    countBI() {
        getBuyingInfluenceData().then(backendResult => {
            let result = backendResult;
            if (result != null && result.length >= 1) {
                this.moduleLearningCompleted = true;
            } else {
                this.moduleLearningCompleted = false;
            }
        });
    }

    checkCoach() {
        checkBIforCoach().then(backendResult => {
            let result = backendResult;
            if (result === true) {
                this.moduleLearningCompleted = true;
            } else {
                this.moduleLearningCompleted = false;
            }
        });
    }

    checkDegree() {
        checkBIforDegrees().then(backendResult => {
            let result = backendResult;
            if (result === true) {
                this.moduleLearningCompleted = true;
            } else {
                this.moduleLearningCompleted = false;
            }
        });
    }

    checkRatings() {
        checkBIforRatings().then(backendResult => {
            let result = backendResult;
            if (result === true) {
                this.moduleLearningCompleted = true;
            } else {
                this.moduleLearningCompleted = false;
            }
        });
    }

    checkModes() {
        checkBIforModes().then(backendResult => {
            let result = backendResult;
            if (result === true) {
                this.moduleLearningCompleted = true;
            } else {
                this.moduleLearningCompleted = false;
            }
        });
    }

    checkWinsOrResults() {
        checkBIforWinOrResults().then(backendResult => {
            let result = backendResult;
            if (result === true) {
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
                if (this.moduleData.moduleNameId === "Lesson_4_Module_1") {
                    this.countBI();
                } else if (this.moduleData.moduleNameId === "Lesson_4_Module_2") {
                    this.checkCoach();
                } else if (this.moduleData.moduleNameId === "Lesson_4_Module_4") {
                    this.checkDegree();
                } else if (this.moduleData.moduleNameId === "Lesson_5_Module_1") {
                    this.checkModes();
                } else if (this.moduleData.moduleNameId === "Lesson_5_Module_3") {
                    this.checkRatings();
                } else if (this._moduleData.moduleNameId === "Lesson_6_Module_1") {
                    this.checkWinsOrResults();
                }
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
        competitivePreferenceLabel,
        buyingFromSomeOneElseLabel,
        usingBudgetforSomethingLabel,
        usingInternalResourceLabel,
        doingNothingLabel,
        buyfromusLabel,
        buyingInfluenceRoleLabel,
        technicalLabel,
        userLabel,
        economicLabel,
        coachLabel,
        degreeofInfluenceLabel,
        highLabel,
        lowLabel,
        mediumLabel,
        buyingModeLabel,
        growthLabel,
        evenKeelLabel,
        overConfidentLabel,
        troubleLabel,
        personalWinsLabel,
        businessResultsLabel,
        ratingLabel,
        ratingEvidenceLabel,
        buyingInfluenceRolesLabel,
        buyingInfluenceLabel,
        addBuyingInfluenceLabel,
        showMoreLabel,
        showLessLabel,
        deleteBuyingInfluenceLabel,
        yesLabel,
        noLabel,
        cancelLabel,
        MaxTextLimitError,
        saveLabel,
        editLabel,
        deleteLabel,
        closeLabel,
        deleteBuyingInfluenceMessage,
        nfivemsgLabel,
        nfourmsgLabel,
        nthreemsgLabel,
        ntwomsgLabel,
        nonemsgLabel,
        ponemsgLabel,
        ptwomsgLabel,
        pthreemsgLabel,
        pfourmsgLabel,
        pfivemsgLabel,
        brPlaceholderLabel,
        pwPlaceholderLabel,
        rePlaceholderLabel,
        EditContactInfoLabel,
        AddeNewContactLabel,
        MailingCountryLabel,
        MailingZipPostalCodeLabel,
        MailingCityLabel,
        MailingStreetLabel,
        AddressInformationLabel,
        StateProvinceLabel,
        DepartmentLabel,
        MailingStateProvinceLabel,
        EmailLabel,
        MobilePhoneLabel,
        BusinessPhoneLabel,
        AccountIDLabel,
        LastNameLabel,
        FirstNameLabel,
        SalutationLabel,
        FullNameLabel,
        OwnerIDLabel,
        ContactInformationLabel,
        EditContactLabel,
        LocationLabel,
        TitleLabel,
        NameLabel,
        OtherPhoneLabel,
        RecordSaveLabel,
        RecordDeletedLabel,
        SuccessLabel,
        ErrorLabel,
        buying_InfluenceHeaderURL,
        buying_InfluenceRoleURL,
        degreeofInfluenceURL,
        buyingModeURL,
        competitivePrefURL,
        personalWinURL,
        ratingURL,
        evidenceURL,
        myPosVsCompetitionURL,
        Please_fill_the_Contact_Field,
        error_header,
        Scorecard_Template_Title_Column,
        Country,
        searchCompetitior,
        Loading,
        SuccessHeader
    };

    @track isbuyfromelse = true;

    @track
    rfsDetails = this.getNewRfsDetails();

    @track isCreateable = false;
    @track isUpdateable = false;
    @track isDeletable = false;

    getNewRfsDetails() {
        return {
            BuyingInfluenceRole: {
                redFlagSelected: false,
                strengthSelected: false,
                noneSelected: true,
                fieldApiName: "BuyingInfluenceRole"
            },
            DegreeOfInfluence: {
                redFlagSelected: false,
                strengthSelected: false,
                noneSelected: true,
                fieldApiName: "DegreeOfInfluence"
            },
            BuyingMode: {
                redFlagSelected: false,
                strengthSelected: false,
                noneSelected: true,
                fieldApiName: "BuyingMode"
            },
            CompetitivePreference: {
                redFlagSelected: false,
                strengthSelected: false,
                noneSelected: true,
                fieldApiName: "CompetitivePreference"
            },
            PersonalWins: {
                redFlagSelected: false,
                strengthSelected: false,
                noneSelected: true,
                fieldApiName: "PersonalWins"
            },
            BusinessResults: {
                redFlagSelected: false,
                strengthSelected: false,
                noneSelected: true,
                fieldApiName: "BusinessResults"
            },
            Rating: { redFlagSelected: false, strengthSelected: false, noneSelected: true, fieldApiName: "Rating" },
            RatingEvidence: {
                redFlagSelected: false,
                strengthSelected: false,
                noneSelected: true,
                fieldApiName: "RatingEvidence"
            }
        };
    }

    //If marker updated then updated
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

    getBIData() {
        this.blueSheetId = this.getIdFromParent;
        checkAccess().then(result => {
            this.isCreateable = result.isCreateable;
            this.isUpdateable = result.isUpdateable;
            this.isDeletable = result.isDeletable;

            getBuyingInfluence({ oppId: this.recordId })
                .then(r => {
                    this.biList = r;
                    this.showeditbutton = true;
                    this.showNewRecordButton = true;
                    this.createNewRecord = false;
                    if (!this.biList.length) {
                        this.checkNoDataAndReadOnlyAccess = !this.isCreateable;
                    } else {
                        this.biList.forEach(bi => {
                            bi.rfsMarkerWrapper = this.convertMarkerMap(bi.rfsMarkerWrapper);
                        });
                    }
                })
                .catch(() => {
                    //alert('Error getBIerror' +JSON.stringify(error));
                });
        });
    }

    connectedCallback() {
        //  this.recordId = this.getIdFromParent;
        //alert( 'Opportunity Id:'+ this.recordId);
        objectForLookup().then(result => {
            this.objectForLookup = result.lookupOnObject;
            this.lookuptargetField = result.targetField;
        });
        registerListener("ModuleDataBI", this.reloadModuleData, this);
    }
    reloadModuleData(moduleData) {
        this._moduleData = moduleData;
        this.ProcessModuleData();
    }

    handleClickNew() {
        this.createWrapperObject();
        this.disableSaveButton = true;
        this.showNewRecordButton = true;
        this.showMaxLimitErrorBR = false;
        this.showMaxLimitErrorPW = false;
        this.showMaxLimitErrorRE = false;
        this.btnflag = true;
        this.bShowEditCon = false;
        this.createNewRecord = true;
        this.showeditbutton = true;
        this.initializeVariables();
        this.rfsDetails = {
            BuyingInfluenceRole: {
                redFlagSelected: false,
                strengthSelected: false,
                noneSelected: true,
                fieldApiName: "BuyingInfluenceRole"
            },
            DegreeOfInfluence: {
                redFlagSelected: false,
                strengthSelected: false,
                noneSelected: true,
                fieldApiName: "DegreeOfInfluence"
            },
            BuyingMode: {
                redFlagSelected: false,
                strengthSelected: false,
                noneSelected: true,
                fieldApiName: "BuyingMode"
            },
            CompetitivePreference: {
                redFlagSelected: false,
                strengthSelected: false,
                noneSelected: true,
                fieldApiName: "CompetitivePreference"
            },
            PersonalWins: {
                redFlagSelected: false,
                strengthSelected: false,
                noneSelected: true,
                fieldApiName: "PersonalWins"
            },
            BusinessResults: {
                redFlagSelected: false,
                strengthSelected: false,
                noneSelected: true,
                fieldApiName: "BusinessResults"
            },
            Rating: { redFlagSelected: false, strengthSelected: false, noneSelected: true, fieldApiName: "Rating" },
            RatingEvidence: {
                redFlagSelected: false,
                strengthSelected: false,
                noneSelected: true,
                fieldApiName: "RatingEvidence"
            }
        };

        // eslint-disable-next-line
        setTimeout(() => {
            this.handleScroll();
        }, 200);
        // eslint-enable-next-line
    }

    handleScroll() {
        this.template
            .querySelector(".createRecord")
            .scrollIntoView({ behavior: "auto", block: "start", inline: "start" });
        // now account for fixed header
        const scrolledY = window.scrollY;

        if (scrolledY) {
            window.scroll(0, scrolledY - 200);
        }
    }

    handleChange(event) {
        let eventName = event.target.name;
        let eventValue = event.target.value;
        this.biWrapper[eventName] = eventValue;
    }

    initializeVariables() {
        this.rating = "";
        this.degreeOfInfluence = "";
        this.buyingMode = "";
        this.competitivePreference = "";
        this.biRoleMap = {};
        this.currRatingEvidence = "";
        this.currPersonalWins = "";
        this.currBusinessResult = "";
        this.highCss = "slds-button slds-button_neutral slds-m-left_x-small";
        this.highSelected = "false";
        this.mediumCss = "slds-button slds-button_neutral slds-m-left_x-small";
        this.mediumSelected = "false";
        this.lowCss = "slds-button slds-button_neutral slds-m-left_x-small";
        this.lowSelected = "false";
        this.ratingText = "";
        this.buyfromusCss = "slds-button slds-button_neutral slds-m-left_x-small";
        this.buyfromusSelected = "false";
        this.nothingCss = "slds-button slds-button_neutral slds-m-left_x-small";
        this.nothingSelected = "false";
        this.buyfromelseCss = "slds-button slds-button_neutral slds-m-left_x-small";
        this.buyfromelseSelected = "false";
        this.usingbudgetCss = "slds-button slds-button_neutral slds-m-left_x-small";
        this.usingbudgetSelected = "false";
        this.internalresourceCss = "slds-button slds-button_neutral slds-m-left_x-small";
        this.internalresourceSelected = "false";

        this.technicalCss = "slds-button slds-button_neutral slds-m-left_x-small";
        this.technicalSelected = "false";
        this.economicCss = "slds-button slds-button_neutral slds-m-left_x-small";
        this.economicSelected = "false";
        this.userCss = "slds-button slds-button_neutral slds-m-left_x-small";
        this.userSelected = "false";
        this.coachCss = "slds-button slds-button_neutral slds-m-left_x-small";
        this.coachSelected = "false";

        this.growthCss = "slds-button slds-button_neutral slds-m-left_x-small";
        this.growthSelected = "false";
        this.troubleCss = "slds-button slds-button_neutral slds-m-left_x-small";
        this.troubleSelected = "false";
        this.evenkeelCss = "slds-button slds-button_neutral slds-m-left_x-small";
        this.evenkeelSelected = "false";
        this.overconfidentCss = "slds-button slds-button_neutral slds-m-left_x-small";
        this.overconfidentSelected = "false";

        //rating
        this.moneCss = "slds-p-top_x-small midnum";
        this.moneSelected = "false";
        this.mtwoCss = "slds-p-top_x-small midnum";
        this.mtwoSelected = "false";
        this.mthreeCss = "slds-p-top_x-small midnum";
        this.mthreeSelected = "false";
        this.mfourCss = "slds-p-top_x-small midnum";
        this.mfourSelected = "false";
        this.mfiveCss = "slds-p-top_x-small midnum";
        this.mfiveSelected = "false";
        this.poneCss = "slds-p-top_x-small midnum";
        this.poneSelected = "false";
        this.ptwoCss = "slds-p-top_x-small midnum";
        this.ptwoSelected = "false";
        this.pthreeCss = "slds-p-top_x-small midnum";
        this.pthreeSelected = "false";
        this.pfourCss = "slds-p-top_x-small midnum";
        this.pfourSelected = "false";
        this.pfiveCss = "slds-p-top_x-small midnum";
        this.pfiveSelected = "false";
        this.currentBiId = "";

        this.contactId = "";
        this.contactLocation = "";
        this.contactStateProvince = "";
        this.contactTitle = "";
        this.contactName = "";
        this.conname = "";
        this.selectedconname = false;

        this.selectedCompId = "";
        this.businessResults = "";
    }

    handleEdit(event) {
        this.initializeVariables();
        this.createNewRecord = true;
        this.disableSaveButton = false;
        this.showNewRecordButton = true;
        this.showeditbutton = true;
        this.btnflag = true;
        this.showMaxLimitErrorBR = false;
        this.showMaxLimitErrorPW = false;
        this.showMaxLimitErrorRE = false;
        this.currentBiId = event.currentTarget.value;
        let tempWrapper = JSON.parse(JSON.stringify(this.biList));

        this.biList.forEach(record => {
            if (record.id === this.currentBiId) {
                this.biRecordForSave = record;
            }
        });
        this.biList = this.biList.filter(ele => {
            return ele.id !== this.currentBiId;
        });

        tempWrapper.forEach(record => {
            if (record.id === this.currentBiId) {
                this.createWrapperObject();
                this.biWrapper = record;
                if (this.biWrapper.businessResults === "-") {
                    this.currBusinessResult = "";
                } else {
                    this.currBusinessResult = this.biWrapper.businessResults;
                }

                //this.currPersonalWins=this.biWrapper.personalWins;
                if (this.biWrapper.personalWins === "-") {
                    this.currPersonalWins = "";
                } else {
                    this.currPersonalWins = this.biWrapper.personalWins;
                }

                //this.currRatingEvidence=this.biWrapper.ratingEvidence;
                if (this.biWrapper.ratingEvidence === "-") {
                    this.currRatingEvidence = "";
                } else {
                    this.currRatingEvidence = this.biWrapper.ratingEvidence;
                }

                this.contactFname = this.biWrapper.contactFname;
                this.contactLname = this.biWrapper.contactLname;
                this.conTitle = this.biWrapper.title;
                if (this.biWrapper.MailingState) {
                    this.conMailingState = this.biWrapper.MailingState;
                } else {
                    this.conMailingState = " ";
                }

                if (this.biWrapper.title) {
                    this.conTitle = this.biWrapper.title;
                } else {
                    this.conTitle = " ";
                }

                if (this.biWrapper.MailingCountry) {
                    this.conMailingCountry = this.biWrapper.MailingCountry;
                } else {
                    this.conMailingCountry = " ";
                }

                if (!this.contactFname) {
                    this.conname = " " + this.contactLname;
                } else {
                    this.conname = this.contactFname + " " + this.contactLname;
                }
                this.contactName = this.conname;
                this.contactTitle = this.conTitle;
                this.contactLocation = this.conMailingCountry;
                this.contactStateProvince = this.conMailingState;
                this.selectedconname = true;
                this.contactId = this.biWrapper.contact;

                //degree of influence
                if (this.biWrapper.high) {
                    this.highSelected = "true";
                    this.highCss = "slds-button selectedbutton slds-m-left_x-small";
                    this.degreeOfInfluence = "High";
                    //this.degreeOfInfluence=highLabel;
                }
                if (this.biWrapper.medium) {
                    this.mediumSelected = "true";
                    this.mediumCss = "slds-button selectedbutton slds-m-left_x-small";
                    this.degreeOfInfluence = "Medium";
                    //this.degreeOfInfluence=mediumLabel;
                }
                if (this.biWrapper.low) {
                    this.lowSelected = "true";
                    this.lowCss = "slds-button selectedbutton slds-m-left_x-small";
                    this.degreeOfInfluence = "Low";
                    //this.degreeOfInfluence=lowLabel;
                }

                //buying mode

                if (this.biWrapper.growth) {
                    this.growthSelected = "true";
                    this.growthCss = "slds-button selectedbutton slds-m-left_x-small";
                    this.buyingMode = "Growth";
                }
                if (this.biWrapper.trouble) {
                    this.troubleSelected = "true";
                    this.troubleCss = "slds-button selectedbutton slds-m-left_x-small";
                    this.buyingMode = "Trouble";
                }
                if (this.biWrapper.evenKeel) {
                    this.evenkeelSelected = "true";
                    this.evenkeelCss = "slds-button selectedbutton slds-m-left_x-small";
                    this.buyingMode = "EvenKeel";
                }
                if (this.biWrapper.overConfident) {
                    this.overconfidentSelected = "true";
                    this.overconfidentCss = "slds-button selectedbutton slds-m-left_x-small";
                    this.buyingMode = "OverConfident";
                }

                //role

                Object.keys(this.biRoleMap).forEach(element => {
                    //alert(element);
                    this.biWrapper[element] = this.biRoleMap[element];
                    //alert('role in save '+this.biWrapper[element]);
                });

                this.biRoleMap.technical = this.biWrapper.technical;
                this.biRoleMap.economic = this.biWrapper.economic;
                this.biRoleMap.user = this.biWrapper.user;
                this.biRoleMap.coach = this.biWrapper.coach;

                if (this.biWrapper.technical) {
                    this.technicalSelected = "true";
                    this.technicalCss = "slds-button selectedbutton slds-m-left_x-small";
                }
                if (this.biWrapper.economic) {
                    this.economicSelected = "true";
                    this.economicCss = "slds-button selectedbutton slds-m-left_x-small";
                }
                if (this.biWrapper.user) {
                    this.userSelected = "true";
                    this.userCss = "slds-button selectedbutton slds-m-left_x-small";
                }
                if (this.biWrapper.coach) {
                    this.coachSelected = "true";
                    this.coachCss = "slds-button selectedbutton slds-m-left_x-small";
                }

                //prefernce

                if (this.biWrapper.buyingFromUs) {
                    this.buyfromusSelected = "true";
                    this.buyfromusCss = "slds-button selectedbutton slds-m-left_x-small";
                    this.competitivePreference = "BuyFromUs";
                }
                if (this.biWrapper.internalResources) {
                    this.internalresourceSelected = "true";
                    this.internalresourceCss = "slds-button selectedbutton slds-m-left_x-small";
                    this.competitivePreference = "InternalResource";
                }
                if (this.biWrapper.buyingfromSomeoneElse) {
                    this.buyfromelseSelected = "true";
                    this.buyfromelseCss = "slds-button selectedbutton slds-m-left_x-small";
                    this.competitivePreference = "BuyingFromElse";
                }
                if (this.biWrapper.doingNothing) {
                    this.nothingSelected = "true";
                    this.nothingCss = "slds-button selectedbutton slds-m-left_x-small";
                    this.competitivePreference = "DoingNothing";
                }

                if (this.biWrapper.usingBudget) {
                    this.usingbudgetSelected = "true";
                    this.usingbudgetCss = "slds-button selectedbutton slds-m-left_x-small";
                    this.competitivePreference = "BudgetForElse";
                }

                //rating
                this.rating = this.biWrapper.rating;

                if (this.biWrapper.rating === "-1") {
                    this.moneSelected = "true";
                    this.ratingText = nonemsgLabel;
                    this.moneCss = "slds-p-top_x-small midnumSelected";
                } else if (this.biWrapper.rating === "-2") {
                    this.mtwoSelected = "true";
                    this.ratingText = ntwomsgLabel;
                    this.mtwoCss = "slds-p-top_x-small midnumSelected";
                } else if (this.biWrapper.rating === "-3") {
                    this.mthreeSelected = "true";
                    this.ratingText = nthreemsgLabel;
                    this.mthreeCss = "slds-p-top_x-small midnumSelected";
                } else if (this.biWrapper.rating === "-4") {
                    this.mfourSelected = "true";
                    this.ratingText = nfourmsgLabel;
                    this.mfourCss = "slds-p-top_x-small midnumSelected";
                } else if (this.biWrapper.rating === "-5") {
                    this.mfiveSelected = "true";
                    this.ratingText = nfivemsgLabel;
                    this.mfiveCss = "slds-p-top_x-small midnumSelected";
                } else if (this.biWrapper.rating === "+1") {
                    this.poneSelected = "true";
                    this.ratingText = ponemsgLabel;
                    this.poneCss = "slds-p-top_x-small midnumSelected";
                } else if (this.biWrapper.rating === "+2") {
                    this.ptwoSelected = "true";
                    this.ratingText = ptwomsgLabel;
                    this.ptwoCss = "slds-p-top_x-small midnumSelected";
                } else if (this.biWrapper.rating === "+3") {
                    this.pthreeSelected = "true";
                    this.ratingText = pthreemsgLabel;
                    this.pthreeCss = "slds-p-top_x-small midnumSelected";
                } else if (this.biWrapper.rating === "+4") {
                    this.pfourSelected = "true";
                    this.ratingText = pfourmsgLabel;
                    this.pfourCss = "slds-p-top_x-small midnumSelected";
                } else if (this.biWrapper.rating === "+5") {
                    this.pfiveSelected = "true";
                    this.ratingText = pfivemsgLabel;
                    this.pfiveCss = "slds-p-top_x-small midnumSelected";
                }

                this.selectedCompId = this.biWrapper.searchCompetitor;
                this.rfsDetails = this.biWrapper.rfsMarkerWrapper;
            }
        });
        // eslint-disable-next-line
        setTimeout(() => {
            this.handleScroll();
        }, 200);
        // eslint-enable-next-line
    }

    handleSave() {
        this.validateSearch();
        this.bShowSpinner = true;
        if (
            this.contactName === "" ||
            this.contactName === "undefined" ||
            this.contactName == null ||
            this.contactName === " "
        ) {
            this.disableSaveButton = true;
            const evt = new ShowToastEvent({
                title: error_header,
                message: Please_fill_the_Contact_Field,
                variant: error_header
            });
            this.dispatchEvent(evt);
        } else {
            this.disableSaveButton = false;
            this.biWrapper.blueSheet = this.blueSheetId;
            this.biWrapper.contact = this.contactId;
            if (this.biRecordForSave && this.biRecordForSave.id === this.currentBiId) {
                this.biList.push(this.biRecordForSave);
                this.biRecordForSave = null;
            }

            this.showNewRecordButton = true;
            this.createNewRecord = false;
            this.btnflag = false;
            this.biWrapper.title = this.contactTitle;
            this.biWrapper.MailingState = this.contactStateProvince;
            this.biWrapper.MailingCountry = this.contactLocation;
            this.biWrapper.contactFname = this.contactName;
            this.biWrapper.contactLname = "";
            this.biWrapper.id = this.currentBiId;
            this.biWrapper.biRole = [];
            Object.keys(this.biRoleMap).forEach(element => {
                this.biWrapper[element] = this.biRoleMap[element];
                if (this.biWrapper[element]) {
                    if (element === "technical") {
                        this.biWrapper.biRole.push(technicalLabel);
                    } else if (element === "economic") {
                        //this.biWrapper.biRole.push('Economic');
                        this.biWrapper.biRole.push(economicLabel);
                    } else if (element === "user") {
                        //this.biWrapper.biRole.push('User');
                        this.biWrapper.biRole.push(userLabel);
                    } else if (element === "coach") {
                        //this.biWrapper.biRole.push('Coach');
                        this.biWrapper.biRole.push(coachLabel);
                    }
                }
            });
            if (
                this.biWrapper.economic === false &&
                this.biWrapper.technical === false &&
                this.biWrapper.coach === false &&
                this.biWrapper.user === false
            ) {
                this.biWrapper.biRole.push("-");
            }
            this.biWrapper.biRoleListWithSpaces = this.biWrapper.biRole;
            this.biWrapper.biRoleListWithSpaces = this.biWrapper.biRoleListWithSpaces.join(", ");

            //degree of influence
            this.biWrapper.high = this.degreeOfInfluence === "High" ? true : false;
            this.biWrapper.medium = this.degreeOfInfluence === "Medium" ? true : false;
            this.biWrapper.low = this.degreeOfInfluence === "Low" ? true : false;
            this.biWrapper.degree = this.degreeOfInfluence;

            if (this.biWrapper.high) {
                this.biWrapper.degree = highLabel;
            } else if (this.biWrapper.low) {
                this.biWrapper.degree = lowLabel;
            } else if (this.biWrapper.medium) {
                this.biWrapper.degree = mediumLabel;
            } else {
                this.biWrapper.degree = "-";
            }

            //buying mode
            this.biWrapper.growth = this.buyingMode === "Growth" ? true : false;
            this.biWrapper.trouble = this.buyingMode === "Trouble" ? true : false;
            this.biWrapper.evenKeel = this.buyingMode === "EvenKeel" ? true : false;
            this.biWrapper.overConfident = this.buyingMode === "OverConfident" ? true : false;

            if (this.biWrapper.growth) {
                //this.biWrapper.mode='Growth';
                this.biWrapper.mode = growthLabel;
            } else if (this.biWrapper.trouble) {
                //this.biWrapper.mode='Trouble';
                this.biWrapper.mode = troubleLabel;
            } else if (this.biWrapper.evenKeel) {
                //this.biWrapper.mode='Even Keel';
                this.biWrapper.mode = evenKeelLabel;
            } else if (this.biWrapper.overConfident) {
                //this.biWrapper.mode='Over Confident';
                this.biWrapper.mode = overConfidentLabel;
            } else {
                this.biWrapper.mode = "-";
            }

            this.biWrapper.usingBudget = this.competitivePreference === "BudgetForElse" ? true : false;
            this.biWrapper.internalResources = this.competitivePreference === "InternalResource" ? true : false;
            this.biWrapper.buyingfromSomeoneElse = this.competitivePreference === "BuyingFromElse" ? true : false;
            this.biWrapper.doingNothing = this.competitivePreference === "DoingNothing" ? true : false;
            this.biWrapper.buyingFromUs = this.competitivePreference === "BuyFromUs" ? true : false;

            if (this.biWrapper.usingBudget) {
                //this.biWrapper.compPref='Using Budget for Something Else';
                this.biWrapper.compPref = usingBudgetforSomethingLabel;
            } else if (this.biWrapper.internalResources) {
                //this.biWrapper.compPref='Using Internal Resource';
                this.biWrapper.compPref = usingInternalResourceLabel;
            } else if (this.biWrapper.buyingfromSomeoneElse) {
                //this.biWrapper.compPref='Buying from Someone Else';
                this.biWrapper.compPref = buyingFromSomeOneElseLabel;
                this.isbuyfromelse = false;
            } else if (this.biWrapper.doingNothing) {
                //this.biWrapper.compPref='Doing Nothing';
                this.biWrapper.compPref = doingNothingLabel;
            } else if (this.biWrapper.buyingFromUs) {
                //this.biWrapper.compPref='Buy From Us';
                this.biWrapper.compPref = buyfromusLabel;
            } else {
                this.biWrapper.compPref = "-";
            }

            this.biWrapper.rating = this.rating;
            if (this.rating === "" || this.rating === "-") {
                this.biWrapper.rating = "";
            }

            if (this.biWrapper.businessResults === "") {
                this.biWrapper.businessResults = "";
            }
            /*else{
            this.biWrapper.businessResults=this.businessResults;
        }  */

            this.biWrapper.searchCompetitor = this.selectedCompId;

            if (this.biWrapper.personalWins === "") {
                this.biWrapper.personalWins = "";
            }

            if (this.biWrapper.ratingEvidence === "") {
                this.biWrapper.ratingEvidence = "";
            }

            this.biWrapper.rfsMarkerWrapper = [];
            this.biWrapper.rfsMarkerWrapper.push(this.rfsDetails);

            saveRecord({
                jsonString: JSON.stringify(this.biWrapper),
                blueSheetId: this.blueSheetId,
                rfsMap: this.rfsDetails,
                oppId: this.recordId
            })
                .then(result => {
                    this.disableSaveButton = false;
                    let biUpdate = [];
                    if (result.status === SuccessHeader) {
                        const event = new ShowToastEvent({
                            title: SuccessLabel,
                            //message: 'Record is Saved successfully',
                            message: RecordSaveLabel,
                            variant: "success"
                        });
                        this.dispatchEvent(event);
                        pubsub.fire("refreshBestActionGrid", "");
                        this.showeditbutton = true;
                        //this.showModuleDependentData();
                        if (this.currentBiId !== "") {
                            let index = 0;
                            let selectedIndex = 0;
                            this.biList.forEach(record => {
                                if (record.id === this.currentBiId) {
                                    selectedIndex = index;
                                }
                                biUpdate.push(record);
                                index++;
                            });
                            this.biWrapper.id = this.currentBiId;
                            this.biWrapper.rfsMarkerWrapper = result.rfsWrapperList;
                            biUpdate[selectedIndex] = this.biWrapper;
                        } else {
                            this.biList.forEach(record => {
                                biUpdate.push(record);
                            });
                            this.biWrapper.id = result.recordId;
                            this.currentBiId = this.biWrapper.id;
                            this.biWrapper.rfsMarkerWrapper = result.rfsWrapperList;
                            biUpdate.push(this.biWrapper);
                        }
                        this.biList = [];
                        this.biList = biUpdate;
                        this.biWrapper.rfsMarkerWrapper = result.rfsWrapperList;
                        this.biWrapper.rfsMarkerWrapper = this.convertMarkerMap(this.biWrapper.rfsMarkerWrapper);
                        biUpdate.selectedIndex = this.biWrapper;
                        this.showModuleDependentData();
                    } else {
                        this.biWrapper.id = result.recordId;
                        this.biWrapper.rfsMarkerWrapper = result.rfsWrapperList;
                        this.biWrapper.rfsMarkerWrapper = this.convertMarkerMap(this.biWrapper.rfsMarkerWrapper);
                        biUpdate.push(this.biWrapper);
                    }
                    this.handleProgress();
                })
                .catch(error => {
                    this.disableSaveButton = true;
                    this.error = error;
                });
        }
        this.bShowSpinner = false;
    }

    handleShowMoreBR() {
        this.showBrText = true;
    }

    handleShowLessBR() {
        this.showBrText = false;
        if (this.template.querySelector(".divClass") != null) {
            this.template.querySelector(".divClass").scrollIntoView(true);
        }
    }

    handleOpenModal(event) {
        this.isOpenModal = true;
        this.recordToDelete = event.currentTarget.value;
        //alert('Delete in modal--'+this.recordToDelete);
    }

    handleCloseModal() {
        this.isOpenModal = false;
    }

    handleDelete() {
        this.createNewRecord = false;
        this.showNewRecordButton = true;
        //alert('Delete--'+this.recordToDelete);
        deleteRecord({ recordId: this.recordToDelete })
            .then(result => {
                //alert(JSON.stringify(result));
                //alert(result.status);
                if (result.status === SuccessHeader) {
                    const event = new ShowToastEvent({
                        title: SuccessLabel,
                        //message: 'Record is deleted successfully',
                        message: RecordDeletedLabel,
                        variant: "success"
                    });
                    this.dispatchEvent(event);
                    pubsub.fire("refreshBestActionGrid", "");
                    let biDeleted = [];
                    this.biList.forEach(record => {
                        if (record.id !== this.recordToDelete) {
                            biDeleted.push(record);
                        }
                    });
                    this.biList = [];
                    this.biList = biDeleted;

                    this.isOpenModal = false;
                } else {
                    // const event = new ShowToastEvent({
                    //     title: ErrorLabel,
                    //     message: result.msg,
                    //     variant: "error"
                    // });
                }
                this.handleProgress();
            })
            .catch(() => {
                //alert('Error getBIerror' +JSON.stringify(error));
            });
    }

    createWrapperObject() {
        let biWrapper = {};
        biWrapper.blueSheet = "";
        biWrapper.id = "";
        biWrapper.name = "";
        biWrapper.businessResults = "";
        biWrapper.contact = "";
        biWrapper.contactFname = "";
        biWrapper.contactLname = "";
        biWrapper.MailingState = "";
        biWrapper.MailingCountry = "";
        biWrapper.buyingFromUs = false;
        biWrapper.buyingfromSomeoneElse = false;
        biWrapper.coach = false;
        biWrapper.economic = false;
        biWrapper.doingNothing = false;
        biWrapper.growth = false;
        biWrapper.evenKeel = false;
        biWrapper.high = false;
        biWrapper.low = false;
        biWrapper.medium = false;
        biWrapper.location = "";
        biWrapper.overConfident = false;
        biWrapper.trouble = false;
        biWrapper.user = false;
        biWrapper.usingBudget = false;
        biWrapper.internalResources = false;
        biWrapper.personalWins = "";
        biWrapper.rating = "";
        biWrapper.ratingEvidence = "";
        biWrapper.ratingText = "";
        biWrapper.searchCompetitor = "";
        biWrapper.title = "";
        biWrapper.technical = false;

        biWrapper.businessResults1 = "";
        biWrapper.businessResults2 = "";
        biWrapper.brShowMoreText = false;
        biWrapper.brShowLessText = false;

        //Adding addtional variables Mangesh;
        biWrapper.degree = "";
        biWrapper.mode = "";
        biWrapper.compPref = "";
        biWrapper.biRole = [];
        biWrapper.biRoleListWithSpaces = "";
        biWrapper.rfsMarkerWrapper = [];
        this.biWrapper = biWrapper;
    }

    removeRatingText() {
        let isAnyRatingSelected = false;
        let selectedRating = "";
        this.template.querySelectorAll("div[data-target-class=rating]").forEach(element => {
            let selectedvalue = element.getAttribute("data-target-selected");
            let ratingvalue = element.getAttribute("data-target-id");
            if (selectedvalue === "true") {
                isAnyRatingSelected = true;
                selectedRating = ratingvalue;
                if (selectedRating === "-5") {
                    this.displaynegativefive();
                }
                if (selectedRating === "-4") {
                    this.displaynegativefour();
                }
                if (selectedRating === "-3") {
                    this.displaynegativethree();
                }
                if (selectedRating === "-2") {
                    this.displaynegativetwo();
                }
                if (selectedRating === "-1") {
                    this.displaynegativeone();
                }
                if (selectedRating === "1") {
                    this.displaypositiveone();
                }
                if (selectedRating === "2") {
                    this.displaypositivetwo();
                }
                if (selectedRating === "3") {
                    this.displaypositivethree();
                }
                if (selectedRating === "4") {
                    this.displaypositivefour();
                }
                if (selectedRating === "5") {
                    this.displaypositivefive();
                }
            }
        });
        if (isAnyRatingSelected === false) {
            this.ratingText = "";
        }
    }
    displaynegativefive() {
        //this.message = 'Pro-actively takes action against my solution being selected.';
        this.ratingText = nfivemsgLabel;
    }

    displaynegativefour() {
        //this.message = 'Very negative towards my solution.';
        this.ratingText = nfourmsgLabel;
    }

    displaynegativethree() {
        //this.message = 'Negative towards my solution when asked.';
        this.ratingText = nthreemsgLabel;
    }

    displaynegativetwo() {
        //this.message = 'No interest in my solution but not against it.';
        this.ratingText = ntwomsgLabel;
    }

    displaynegativeone() {
        //this.message = 'Low interest. Won’t resist general opinion.';
        this.ratingText = nonemsgLabel;
    }

    displaypositiveone() {
        //this.message = 'No preference. Will follow general opinion.';
        this.ratingText = ponemsgLabel;
    }

    displaypositivetwo() {
        //this.message = 'Interested in my solution but not yet supportive.';
        this.ratingText = ptwomsgLabel;
    }

    displaypositivethree() {
        //this.message = 'Supportive of my solution when asked.';
        this.ratingText = pthreemsgLabel;
    }

    displaypositivefour() {
        //this.message = 'Strongly supportive of my solution when I am present.';
        this.ratingText = pfourmsgLabel;
    }

    displaypositivefive() {
        //this.message = 'Pro-actively supportive of my solution when I am not present.';
        this.ratingText = pfivemsgLabel;
    }

    handleBuyingInfluence(event) {
        //alert(event.target.value+'>>>>'+event.target.checked);
        let eventName = event.target.value.toLowerCase();
        this.biRoleMap[eventName] = event.target.checked;
    }

    handleDegreeInfluenceButtonClick(event) {
        let targetId = event.currentTarget.dataset.targetId;
        let isSelected = this.template
            .querySelector(`[data-target-id="${targetId}"]`)
            .getAttribute("data-target-selected");
        let buttonvalue = this.template
            .querySelector(`[data-target-id="${targetId}"]`)
            .getAttribute("data-target-value");
        this.degreeOfInfluence = "";
        //this.fieldValue=buttonvalue;
        if (isSelected === "false") {
            this.template.querySelector(`[data-target-id="${targetId}"]`).setAttribute("data-target-selected", "true");
            this.template
                .querySelector(`[data-target-id="${targetId}"]`)
                .setAttribute("class", "slds-button selectedbutton slds-m-left_x-small");
            //this.template.querySelector('lightning-input[data-target-priority=priority]').setAttribute('value',this.fieldValue);
            this.degreeOfInfluence = buttonvalue;
        } else {
            this.template.querySelector(`[data-target-id="${targetId}"]`).setAttribute("data-target-selected", "false");
            this.template
                .querySelector(`[data-target-id="${targetId}"]`)
                .setAttribute("class", "slds-button slds-button_neutral slds-m-left_x-small");
            //this.template.querySelector('lightning-input[data-target-priority=priority]').setAttribute('value','');
        }

        this.template.querySelectorAll("button[data-target-class=InfluenceDegree]").forEach(element => {
            if (element.getAttribute("data-target-id") !== targetId) {
                element.setAttribute("class", "slds-button slds-button_neutral slds-m-left_x-small");
                element.setAttribute("data-target-selected", "false");
            }
        });
    }
    handleCmpPreferenceButtonClick(event) {
        let targetId = event.currentTarget.dataset.targetId;
        //sssalert(targetId);
        //alert(this.template.querySelector('lightning-input[data-target-priority=priority]').getAttribute('value'));
        let isSelected = this.template
            .querySelector(`[data-target-id="${targetId}"]`)
            .getAttribute("data-target-selected");
        let buttonvalue = this.template
            .querySelector(`[data-target-id="${targetId}"]`)
            .getAttribute("data-target-value");
        this.competitivePreference = "";
        if (buttonvalue === "BuyingFromElse") {
            this.isbuyfromelse = false;
        } else {
            this.selectedCompId = "";
            this.isbuyfromelse = true;
        }

        if (isSelected === "false") {
            this.template.querySelector(`[data-target-id="${targetId}"]`).setAttribute("data-target-selected", "true");
            this.template
                .querySelector(`[data-target-id="${targetId}"]`)
                .setAttribute("class", "slds-button selectedbutton slds-m-left_x-small");
            // this.template.querySelector('lightning-input[data-target-priority=priority]').setAttribute('value',this.fieldValue);
            this.competitivePreference = buttonvalue;
        } else {
            this.template.querySelector(`[data-target-id="${targetId}"]`).setAttribute("data-target-selected", "false");
            this.template
                .querySelector(`[data-target-id="${targetId}"]`)
                .setAttribute("class", "slds-button slds-button_neutral slds-m-left_x-small");
            // this.template.querySelector('lightning-input[data-target-priority=priority]').setAttribute('value','');
        }

        this.template.querySelectorAll("button[data-target-class=CompetitivePreference]").forEach(element => {
            if (element.getAttribute("data-target-id") !== targetId) {
                element.setAttribute("class", "slds-button slds-button_neutral slds-m-left_x-small");
                element.setAttribute("data-target-selected", "false");
            }
        });
    }
    handleBuyingModeButtonClick(event) {
        let targetId = event.currentTarget.dataset.targetId;
        //sssalert(targetId);
        //alert(this.template.querySelector('lightning-input[data-target-priority=priority]').getAttribute('value'));
        let isSelected = this.template
            .querySelector(`[data-target-id="${targetId}"]`)
            .getAttribute("data-target-selected");
        let buttonvalue = this.template
            .querySelector(`[data-target-id="${targetId}"]`)
            .getAttribute("data-target-value");
        this.buyingMode = "";

        if (isSelected === "false") {
            this.template.querySelector(`[data-target-id="${targetId}"]`).setAttribute("data-target-selected", "true");
            this.template
                .querySelector(`[data-target-id="${targetId}"]`)
                .setAttribute("class", "slds-button selectedbutton slds-m-left_x-small");
            // this.template.querySelector('lightning-input[data-target-priority=priority]').setAttribute('value',this.fieldValue);
            this.buyingMode = buttonvalue;
        } else {
            this.template.querySelector(`[data-target-id="${targetId}"]`).setAttribute("data-target-selected", "false");
            this.template
                .querySelector(`[data-target-id="${targetId}"]`)
                .setAttribute("class", "slds-button slds-button_neutral slds-m-left_x-small");
            // this.template.querySelector('lightning-input[data-target-priority=priority]').setAttribute('value','');
        }

        this.template.querySelectorAll("button[data-target-class=BuyingMode]").forEach(element => {
            if (element.getAttribute("data-target-id") !== targetId) {
                element.setAttribute("class", "slds-button slds-button_neutral slds-m-left_x-small");
                element.setAttribute("data-target-selected", "false");
            }
        });
    }

    handleRating(event) {
        let targetId = event.currentTarget.dataset.targetId;

        let isSelected = this.template
            .querySelector(`[data-target-id="${targetId}"]`)
            .getAttribute("data-target-selected");
        let buttonvalue = this.template
            .querySelector(`[data-target-id="${targetId}"]`)
            .getAttribute("data-target-value");
        this.rating = "";

        if (isSelected === "false") {
            this.template.querySelector(`[data-target-id="${targetId}"]`).setAttribute("data-target-selected", "true");
            this.template
                .querySelector(`[data-target-id="${targetId}"]`)
                .setAttribute("class", "slds-p-top_x-small midnumSelected");
            this.rating = buttonvalue;
        } else {
            this.template.querySelector(`[data-target-id="${targetId}"]`).setAttribute("data-target-selected", "false");
            this.template
                .querySelector(`[data-target-id="${targetId}"]`)
                .setAttribute("class", "slds-p-top_x-small midnum");
        }

        this.template.querySelectorAll("div[data-target-class=rating]").forEach(element => {
            if (element.getAttribute("data-target-id") !== targetId) {
                element.setAttribute("class", "slds-p-top_x-small midnum");
                element.setAttribute("data-target-selected", "false");
            }
        });
    }

    handlebuyingInfluenceButtonClick(event) {
        let targetId = event.currentTarget.dataset.targetId;

        let isSelected = this.template
            .querySelector(`[data-target-id="${targetId}"]`)
            .getAttribute("data-target-selected");
        let buttonvalue = this.template
            .querySelector(`[data-target-id="${targetId}"]`)
            .getAttribute("data-target-value");

        let eventName = buttonvalue.toLowerCase();

        if (isSelected === "false") {
            this.template.querySelector(`[data-target-id="${targetId}"]`).setAttribute("data-target-selected", "true");
            this.template
                .querySelector(`[data-target-id="${targetId}"]`)
                .setAttribute("class", "slds-button selectedbutton slds-m-left_x-small");
            this.biRoleMap[eventName] = true;
        } else {
            this.template.querySelector(`[data-target-id="${targetId}"]`).setAttribute("data-target-selected", "false");
            this.template
                .querySelector(`[data-target-id="${targetId}"]`)
                .setAttribute("class", "slds-button slds-button_neutral slds-m-left_x-small");
            this.biRoleMap[eventName] = false;
        }
    }

    cancel() {
        this.showNewRecordButton = true;
        this.showeditbutton = true;
        this.btnflag = false;
        this.createNewRecord = false;
        if (this.biRecordForSave && this.biRecordForSave.id === this.currentBiId) {
            this.biList.push(this.biRecordForSave);
            this.biRecordForSave = null;
        }
        this.showMaxLimitErrorBR = false;
        this.showMaxLimitErrorRE = false;
        this.showMaxLimitErrorPW = false;
        this.isAnyRatingSelected = false;
    }

    getContactId(event) {
        this.selectedContactId = event.detail;
    }

    navigateToNewContact() {
        this.newconform = true;
    }

    validateSearch() {
        this.template.querySelectorAll("c-custom-lookup").forEach(element => {
            element.validateFields();
        });

        // this.template.querySelector("c-custom-lookup").validateFields();
    }

    handleSubmit(event) {
        //alert("handleSubmit");
        const confields = event.detail.fields;

        this.contactTitle = confields.Title;
        this.contactLocation = confields.MailingCountry;
        this.contactStateProvince = confields.MailingState;
        this.newconform = false;
    }

    handlenewrec(event) {
        // console.log("recordId new is" + event.detail.recordId);
        this.contactTitle = event.detail.selectedtitle;
        this.contactLocation = event.detail.selectedCountry;
        this.contactStateProvince = event.detail.selectedState;
        this.contactId = event.detail.recordId;
        this.contactName = event.detail.selectedname;
        this.bShowEditCon = true;

        if (this.contactId && this.contactId.length > 0) {
            this.disableSaveButton = false;
        } else {
            this.disableSaveButton = true;
        }
    }

    navigateToEditRecordPage() {
        //this.contactId
        //this.recordId = this.contactId;
        this.editconform = true;
    }

    handleSubmitEdit(event) {
        //alert("SubmitEdit");
        const confields = event.detail.fields;

        this.contactTitle = confields.Title;
        this.contactLocation = confields.MailingCountry;
        this.contactStateProvince = confields.MailingState;
        this.newconform = false;

        /////
        const confieldsedits = event.detail.fields;

        this.contactTitle = confieldsedits.Title;
        this.contactLocation = confieldsedits.MailingCountry;
        this.contactStateProvince = confieldsedits.MailingState;
        if (confieldsedits.FirstName === "" || confieldsedits.FirstName == null) {
            this.contactName = " " + confieldsedits.LastName;
        } else {
            this.contactName = confieldsedits.FirstName + " " + confieldsedits.LastName;
        }

        //this.conname = confieldsedits.FirstName +" "+ confieldsedits.LastName;
        this.conname = this.contactName;
    }

    handleSuccessEdit() {
        //this.recordId = this.getIdFromParent;
        this.recordId = this.optyId;
        this.editconform = false;
    }

    ongetrecdetails() {
        // const conphone = event.detail.Phone;
    }

    openModal() {
        // to open modal window set 'bShowModal' tarck value as true
        this.bShowModal = true;
    }

    closeModal() {
        // to close modal window set 'bShowModal' tarck value as false
        this.bShowModal = false;
    }

    handleReset() {
        //this.recordId = this.getIdFromParent;
        this.recordId = this.optyId;
        this.editconform = false;
        this.bShowEditCon = true;
    }

    handletitle(event) {
        //this.bShowEditCon = true;

        //contactName
        this.contactId = event.detail.recordId;
        //---Title
        if (event.detail.selectedtitle === undefined) {
            this.contactTitle = " ";
            //this.bShowEditCon = false;
        } else {
            this.contactTitle = event.detail.selectedtitle;
            //this.bShowEditCon = true;
        }

        if (this.contactId && this.contactId.length > 0) {
            this.disableSaveButton = false;
        } else {
            this.disableSaveButton = true;
        }

        //----Country
        if (event.detail.selectedCountry === undefined) {
            this.contactLocation = " ";
        } else {
            this.contactLocation = event.detail.selectedCountry;
        }
        //---- State/Province
        if (event.detail.selectedState === undefined) {
            this.contactStateProvince = " ";
        } else {
            this.contactStateProvince = event.detail.selectedState;
        }

        if (event.detail.selectedname === undefined) {
            this.contactName = " ";
            this.bShowEditCon = false;
        } else {
            this.contactName = event.detail.selectedname;
            this.bShowEditCon = true;
        }

        //this.contactStateProvince = event.detail.selectedState;
    }

    handleMaxLimitErrorPersonalWins(event) {
        const customerStatedObjectiveLimit = event.target.value;
        if (customerStatedObjectiveLimit.length === 32000) {
            this.showMaxLimitErrorPW = true;
        } else {
            this.showMaxLimitErrorPW = false;
        }
    }

    handleMaxLimitErrorRatingEvidence(event) {
        const RatingEvidence = event.target.value;
        if (RatingEvidence.length === 32000) {
            this.showMaxLimitErrorRE = true;
        } else {
            this.showMaxLimitErrorRE = false;
        }
    }

    handleMaxLimitErrorBusinessResults(event) {
        const customerStatedObjectiveLimit = event.target.value;
        if (customerStatedObjectiveLimit.length === 32000) {
            this.showMaxLimitErrorBR = true;
        } else {
            this.showMaxLimitErrorBR = false;
        }
    }

    handleValueSelcted(event) {
        this.selectedCompId = event.detail;
        /*if(this.accountId){
            this.competitionType = 'Buying from Someone Else';
            this. showSaveButton = false;
            this.showAccountError= false;
            this.competitiorTyepName='';
        }else{
          this. showSaveButton = true;
        }*/
    }
    handleProgress() {
        const selectedEvent = new CustomEvent("updateprogressfromchild", {
            detail: true
        });
        this.dispatchEvent(selectedEvent);
    }
}