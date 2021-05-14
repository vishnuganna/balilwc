import { LightningElement, track, api, wire } from "lwc";
import cancelLabel from "@salesforce/label/c.cancel";
import saveLabel from "@salesforce/label/c.save";
import error_header from "@salesforce/label/c.error_header";
import success_header from "@salesforce/label/c.success_header";
import Record_error_message from "@salesforce/label/c.Record_error_message";
import Record_success_message from "@salesforce/label/c.Record_success_message";
import newRecordHeaderLabel from "@salesforce/label/c.NewRecordHeader";
import defaultRecordTypeLabel from "@salesforce/label/c.DefaultRecordType";
import informationSectionLabel from "@salesforce/label/c.InformationSection";
import recordTypeFieldLabel from "@salesforce/label/c.RecordTypeField";
import ownerFieldLabel from "@salesforce/label/c.OwnerField";
import businessRuleFieldLabel from "@salesforce/label/c.BusinessRuleField";
import businessRulesGroupFieldLabel from "@salesforce/label/c.BusinessRulesGroupField";
import isActiveFieldLabel from "@salesforce/label/c.IsActiveField";
import businessRuleNameFieldLabel from "@salesforce/label/c.BusinessRuleNameField";
import isaBlueSheetrequiredSectionLabel from "@salesforce/label/c.IsaBlueSheetrequiredSection";
import opportunityStageFieldLabel from "@salesforce/label/c.OpportunityStageField";
import blueSheetRangeSectionLabel from "@salesforce/label/c.BlueSheetRangeSection";
import blueSheetRangeFieldLabel from "@salesforce/label/c.BlueSheetRangeField";
import optyAmountFieldLabel from "@salesforce/label/c.OptyAmountField";
import blueSheetUpdatedSectionLabel from "@salesforce/label/c.BlueSheetUpdatedSection";
import maxDaysBSUpdateFieldLabel from "@salesforce/label/c.MaxDaysBSUpdateField";
import SSOSectionLabel from "@salesforce/label/c.SSOSection";
import maxDaysOppStageFieldLabel from "@salesforce/label/c.MaxDaysOppStageField";
import blueSheetActionSectionLabel from "@salesforce/label/c.BlueSheetActionSection";
import minActionFieldLabel from "@salesforce/label/c.MinActionField";
import scorecardRequiredSectionLabel from "@salesforce/label/c.ScorecardRequiredSection";
import scorecardRequiredFieldLabel from "@salesforce/label/c.ScorecardRequiredField";
import buyingInfluenceSectionLabel from "@salesforce/label/c.BuyingInfluenceSection";
import buyingInfluenceRoleFieldLabel from "@salesforce/label/c.BuyingInfluenceRoleField";
import technicalLabel from "@salesforce/label/c.technical";
import userLabel from "@salesforce/label/c.user";
import economicLabel from "@salesforce/label/c.economic";
import coachLabel from "@salesforce/label/c.coach";
import yesLabel from "@salesforce/label/c.yes";
import noLabel from "@salesforce/label/c.no";
import categoryOpportunity from "@salesforce/label/c.CategoryOpportunity";
import categoryScorecard from "@salesforce/label/c.CategoryScorecard";
import categoryBuyingInfluence from "@salesforce/label/c.CategoryBuyingInfluence";
import categoryCompetitor from "@salesforce/label/c.CategoryCompetitor";
import BusinessRuleCategory from "@salesforce/label/c.BusinessRuleCategory";
import OpportunityCurrencyField from "@salesforce/label/c.OpportunityCurrencyField";
import MinimumRange from "@salesforce/label/c.MinimumRange";
import MaximumRange from "@salesforce/label/c.MaximumRange";
import MinimumNumberOfContactsOnBI from "@salesforce/label/c.MinimumNumberOfContactsOnBI";
import categoryMeetingPlan from "@salesforce/label/c.categoryMeetingPlan";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import upsertBusinessRule from "@salesforce/apex/BusinessRules.upsertBusinessRule";
import upsertGreenSheetBusinessRule from "@salesforce/apex/BusinessRules.upsertGreenSheetBusinessRule";
import getBusinessRule from "@salesforce/apex/BusinessRules.getBusinessRule";
import getOpportunityStagePicklistValues from "@salesforce/apex/BusinessRules.getOpportunityStagePicklistValues";
import getCurrencyFields from "@salesforce/apex/BusinessRules.getCurrencyFields";
import getCategoryPicklistValues from "@salesforce/apex/BusinessRules.getBRCategoryPicklistValues";
import getBusinessRulesGroupLookup from "@salesforce/apex/BusinessRules.getBusinessRulesGroupName";
import getCompetitiorLookup from "@salesforce/apex/BusinessRules.getCompetitiorLookup";
import { NavigationMixin } from "lightning/navigation";
import minimumOptyScoreRange from "@salesforce/label/c.MinimumOpportunityCriteriaScore";
import maximumOptyScoreRange from "@salesforce/label/c.MaximumOpportunityCriteriaScore";
import minimumBusinessScoreRange from "@salesforce/label/c.MinimumBusinessCriteriaScore";
import maximumBusinessScoreRange from "@salesforce/label/c.MaximumBusinessCriteriaScore";
import minimumTotalScoreRange from "@salesforce/label/c.MinimumTotalScore";
import maximumTotalScoreRange from "@salesforce/label/c.MaximumTotalScore";
import scorecardMaxDaysUpdate from "@salesforce/label/c.MaximumDaysUpdatedScorecard";
import scorecardUpdateHeader from "@salesforce/label/c.ScorecardUpdateHeader";
import totalScoreHeader from "@salesforce/label/c.TotalScoreHeader";
import opportunityCriteriaScoreHeader from "@salesforce/label/c.OpportunityCriteriaScoreHeader";
import businessCriteriaScoreHeader from "@salesforce/label/c.BusinessCriteriaScoreHeader";
import triggerMaxDaysScorecardHeader from "@salesforce/label/c.TriggerMaxDaysScorecardHeader";
import triggerTotalScoreHeader from "@salesforce/label/c.TriggerTotalScoreHeader";
import triggerBusinessScoreHeader from "@salesforce/label/c.TriggerBusinessScoreHeader";
import triggerOptyScoreHeader from "@salesforce/label/c.TriggerOptyScoreHeader";
import lastModifiedDateCheckLabel from "@salesforce/label/c.LastModifiedDateCheck";
import totalScoreCheckLabel from "@salesforce/label/c.TotalScoreCheck";
import opportunityCriteriaScoreCheckLabel from "@salesforce/label/c.OpportunityCriteriaScoreCheck";
import businessCriteriaScoreCheckLabel from "@salesforce/label/c.BusinessCriteriaScoreCheck";
import NumberofDaysBeforeMeeting from "@salesforce/label/c.NumberofDaysBeforeMeeting";
import NoConceptforBIEntered from "@salesforce/label/c.NoConceptforBIEntered";
import NoVBREntered from "@salesforce/label/c.NoVBREntered";
import NoBestActionCommitmentEntered from "@salesforce/label/c.NoBestActionCommitmentEntered";
import NoMinimumActionCommitmentEntered from "@salesforce/label/c.NoMinimumActionCommitmentEntered";
import TriggerNoConceptforBIEnteredHeader from "@salesforce/label/c.TriggerNoConceptforBIEnteredHeader";
import TriggerNoVBREnteredHeader from "@salesforce/label/c.TriggerNoVBREnteredHeader";
import TriggerNoBestActionCommitmentHeader from "@salesforce/label/c.TriggerNoBestActionCommitmentHeader";
import TriggerNoMinimumActionCommitmentHeader from "@salesforce/label/c.TriggerNoMinimumActionCommitmentHeader";
import competitior from "@salesforce/label/c.competitior";
import CustomizeAlerts from "@salesforce/label/c.CustomizeAlerts";
import AlertText from "@salesforce/label/c.AlertText";
import Insights from "@salesforce/label/c.Insights";
import InsightsLink from "@salesforce/label/c.InsightsLink";
import InsightsIndustry from "@salesforce/label/c.InsightsIndustry";
import InsightsDisplayLinkAs from "@salesforce/label/c.InsightsDisplayLinkAs";
import InsightsOpportunityType from "@salesforce/label/c.InsightsOpportunityType";
import AlertEnabled from "@salesforce/label/c.AlertEnabled";
import OverrideText from "@salesforce/label/c.OverrideText";
import CustomText from "@salesforce/label/c.CustomText";
import DefaultText from "@salesforce/label/c.DefaultText";
import InsightsOpportunityTypeSelectToolTip from "@salesforce/label/c.InsightsOpportunityTypeSelectToolTip";
import InsightsIndustrySelectToolTip from "@salesforce/label/c.InsightsIndustrySelectToolTip";
import Header from "@salesforce/label/c.Header";
import HeaderCustomeMaxError from "@salesforce/label/c.HeaderCustomeMaxError";
import AlertMaxError from "@salesforce/label/c.AlertMaxError";
import RulescheckError from "@salesforce/label/c.RulescheckError";
import RequiredFieldError from "@salesforce/label/c.RequiredFieldError";
import CurrencyRange from "@salesforce/label/c.CurrencyRange";
import InsightValues from "@salesforce/label/c.InsightValues";
import BRRetrieve from "@salesforce/label/c.BRRetrieve";
import IsCloseDatePastDue from "@salesforce/label/c.IsCloseDatePastDue";
import AlertOnPastDue from "@salesforce/label/c.AlertOnPastDue";
import ArePastDueBestActions from "@salesforce/label/c.ArePastDueBestActions";
import AlertOnDueDate from "@salesforce/label/c.AlertOnDueDate";
import IsCurrentPosNegative from "@salesforce/label/c.IsCurrentPosNegative";
import AlertOnPosition from "@salesforce/label/c.AlertOnPosition";
import WhoIsCompetition from "@salesforce/label/c.WhoIsCompetition";
import AlertOnNocompetitor from "@salesforce/label/c.AlertOnNocompetitor";
import PositionVSCompetition from "@salesforce/label/c.PositionVSCompetition";
import AlertOnPositionCompetition from "@salesforce/label/c.AlertOnPositionCompetition";
import EnterNumberOnly from "@salesforce/label/c.EnterNumberOnly";
import Customer_Timing_for_Priorities from "@salesforce/label/c.Customer_Timing_for_Priorities";
import AlertOnCustomerTimeWork from "@salesforce/label/c.AlertOnCustomerTimeWork";
import IsPersonalWin from "@salesforce/label/c.IsPersonalWin";
import AlertOnPersonalWin from "@salesforce/label/c.AlertOnPersonalWin";
import AlertOnBusinessResult from "@salesforce/label/c.AlertOnBusinessResult";
import AlertOnNoBusinessResult from "@salesforce/label/c.AlertOnNoBusinessResult";
import BuyingInfluenceRating from "@salesforce/label/c.BuyingInfluenceRating";
import AlertOnBuyingInfluence from "@salesforce/label/c.AlertOnBuyingInfluence";
import PotentialCoach from "@salesforce/label/c.PotentialCoach";
import AlertOnBuyingRating from "@salesforce/label/c.AlertOnBuyingRating";
import CoachInfluence from "@salesforce/label/c.CoachInfluence";
import CoachInfluenceAlert from "@salesforce/label/c.CoachInfluenceAlert";
import ModeCustomerTime from "@salesforce/label/c.ModeCustomerTime";
import AlertOnCustomerTime from "@salesforce/label/c.AlertOnCustomerTime";
import MinimumNumberOfBI from "@salesforce/label/c.MinimumNumberOfBI";
import FieldOfPlayBR from "@salesforce/label/c.FieldOfPlayBR";
import BuySellHierarchyView from "@salesforce/label/c.BuySellHierarchyView";
import competitorError from "@salesforce/label/c.CompetitorError";
import categoryPerspective from "@salesforce/label/c.CategoryPerspective";
import AlertTypeSeller from "@salesforce/label/c.AlertTypeSeller";
import AlertTypeManager from "@salesforce/label/c.AlertTypeManager";
import AlertTypeAction from "@salesforce/label/c.AlertTypeAction";
import getDefaultAlerts from "@salesforce/apex/CustomAlertRecommendations.getDefaultAlerts";
import getRecommendationsActionByRuleId from "@salesforce/apex/CustomAlertRecommendations.getRecommendationsActionByRuleId";
import Scorecard_Template_Name_Max_Char_Limit from "@salesforce/label/c.Scorecard_Template_Name_Max_Char_Limit";

export default class BusinessRulesNewPage extends NavigationMixin(LightningElement) {
    @track opportunityCurrencyFields = [];
    @track hasValuesinOpptyCurrency = false;
    @track categoryTypePicklistValues = [];
    @track hasValuesinCategoryField = false;
    @track CustomAlertRecords;

    @wire(getCategoryPicklistValues)
    categoryPicklistValues({ data }) {
        if (data) {
            const result = JSON.parse(data);
            for (let key in result) {
                if (result.hasOwnProperty(key)) {
                    this.categoryTypePicklistValues.push({ label: key, value: key }); //Here we are creating the array to show on UI.
                }
            }
            this.hasValuesinCategoryField = true;
        }
    }

    @wire(getCurrencyFields)
    currencyFieldsResult({ data }) {
        if (data) {
            const result = JSON.parse(data);
            for (let key in result) {
                if (result.hasOwnProperty(key)) {
                    this.opportunityCurrencyFields.push({ label: key, value: key }); //Here we are creating the array to show on UI.
                }
            }
            this.hasValuesinOpptyCurrency = true;
        }
    }

    @track brAutoName = "";
    @track stageValues = [];
    @track bsPicklistValues = [];
    @track bsRngPicklistValues = [];
    @track scrcrdPicklistValues = [];
    @track bsReqSelectedValue = "";
    @track bsRngSelectedValue = "";
    @track scrCrdSelectedValue = "";
    @track businessRuleName;
    @api isSaveDisabled = false;
    @track active = true;
    @track optyAmount;
    @track maxDaysBSUpdate;
    @track maxDaysOptyStage;
    @track minActionsOptyStage;
    @track brGroupId;
    @track readView = false;
    @track itemId = "";
    @api item;
    @track businessRuleRecord;
    @track oppStageSlctdPicklist = [];
    @track lookuptargetField;
    @track objectForLookup;
    @api recordId;
    @track ownerField = "";
    @track rolesPicklistValues = [];
    @track roleSelectedValue = "";
    @track selectedCategoryType;
    @track selectedCurrencyField;
    @track minimumRange;
    @track maximumRange;
    @track selectedGlobalOppStage = [];
    @track globalOptyStage = "";
    @track categoryOpty = false;
    @track categoryScr = false;
    @track categoryBI = false;
    @track categoryMeetingPlan = false;
    @api categoryActAlert = false;
    @api categoryMngrAlert = false;
    @track showMaxLimitErrorHeader = false;

    @api categoryActoptions = false;
    @track isDisableCategory = false;
    @track showMaxLimitErrorAlert = false;

    @track disableMinMaxRange = true;
    @track minNumberContact;
    @track triggerOnBluesheetRequired;
    @track isClosedDatePast;
    @track isPastActionDue;
    @track isCurrPosNegative;
    @track isCompetitorIdentified;
    @track isPosCompetitionZero;
    @track isCustTimeLater;
    @track isPersonWinIdentified;
    @track isBusinessResultIdentified;
    @track isNegativeRating;
    @track isHighRatedBINoCoach;
    @track isCoachWithLowBI;
    @track isDisconModeCustTiming;
    @track daysUpdatedScorecard;
    @track minTotalScore;
    @track maxTotalScore;
    @track minOpportunityCriteriaScore;
    @track maxOpportunityCriteriaScore;
    @track minBusinessCriteriaScore;
    @track maxBusinessCriteriaScore;
    @track lastModifiedDateCheck;
    @track businessCriteriaScoreCheck;
    @track opportunityCriteriaScoreCheck;
    @track totalScoreCheck;
    @track categoryComp;
    @track categoryPersp;
    @track isExpandableViewCompetitor = true;
    @track isExpandableViewPerspective = true;
    @track objectForLookupCompetitior;
    @track lookuptargetFieldCompetitior;
    @track insightsAlertText;
    @track insightsLinkText;
    @track competitorId;
    @track insightId;
    @api defaultText;

    //Manager variables
    @api defaultAlertHeaderMngr;
    @api defaultAlertMessageMngr;
    //Seller variables
    @api defaultAlertHeaderSeller;
    @api defaultAlertMessageSeller;
    //Action variables
    @api defaultAlertHeaderAction;
    @api defaultAlertMessageAction;

    @track isMinActCommitAdded = false;
    @track isBestActCommitAdded = false;
    @track isVBRAdded = false;
    @track isConceptForBIAdded = false;
    @track numDaysBeforeMeeting;
    //New Refactor
    @track listAlertTemplate = [];
    @track renderChildTemplate = false;
    @track countActiveRules = 0;
    @track maxCountReached = false;
    @track showErrorNotification = false;
    @track ruleNames = [];

    @track alertActionRecord = null;
    @track alertSellerRecord = null;
    @track alertManagerRecord = null;
    @track alertBalId;
    @track showMaxLimitErrorInsights = false;
    @track showMaxLimitErrorInsightsLink = false;
    @track blueSheetReqdValue;
    @track scorCardValueSelected;

    label = {
        InsightsDisplayLinkAs,
        InsightsIndustrySelectToolTip,
        InsightsOpportunityTypeSelectToolTip,
        InsightsOpportunityType,
        InsightsIndustry,
        cancelLabel,
        saveLabel,
        error_header,
        success_header,
        Record_error_message,
        Record_success_message,
        newRecordHeaderLabel,
        defaultRecordTypeLabel,
        informationSectionLabel,
        recordTypeFieldLabel,
        ownerFieldLabel,
        businessRuleFieldLabel,
        businessRulesGroupFieldLabel,
        isActiveFieldLabel,
        businessRuleNameFieldLabel,
        isaBlueSheetrequiredSectionLabel,
        opportunityStageFieldLabel,
        blueSheetRangeSectionLabel,
        blueSheetRangeFieldLabel,
        optyAmountFieldLabel,
        blueSheetUpdatedSectionLabel,
        maxDaysBSUpdateFieldLabel,
        SSOSectionLabel,
        maxDaysOppStageFieldLabel,
        blueSheetActionSectionLabel,
        minActionFieldLabel,
        scorecardRequiredSectionLabel,
        scorecardRequiredFieldLabel,
        buyingInfluenceSectionLabel,
        buyingInfluenceRoleFieldLabel,
        technicalLabel,
        userLabel,
        coachLabel,
        economicLabel,
        yesLabel,
        noLabel,
        BusinessRuleCategory,
        OpportunityCurrencyField,
        MinimumRange,
        MaximumRange,
        MinimumNumberOfContactsOnBI,
        minimumOptyScoreRange,
        maximumOptyScoreRange,
        minimumBusinessScoreRange,
        maximumBusinessScoreRange,
        minimumTotalScoreRange,
        maximumTotalScoreRange,
        scorecardMaxDaysUpdate,
        scorecardUpdateHeader,
        totalScoreHeader,
        opportunityCriteriaScoreHeader,
        businessCriteriaScoreHeader,
        triggerMaxDaysScorecardHeader,
        triggerTotalScoreHeader,
        triggerBusinessScoreHeader,
        triggerOptyScoreHeader,
        lastModifiedDateCheckLabel,
        totalScoreCheckLabel,
        opportunityCriteriaScoreCheckLabel,
        businessCriteriaScoreCheckLabel,
        categoryMeetingPlan,
        NumberofDaysBeforeMeeting,
        NoConceptforBIEntered,
        NoVBREntered,
        NoBestActionCommitmentEntered,
        NoMinimumActionCommitmentEntered,
        TriggerNoConceptforBIEnteredHeader,
        TriggerNoVBREnteredHeader,
        TriggerNoBestActionCommitmentHeader,
        TriggerNoMinimumActionCommitmentHeader,
        categoryCompetitor,
        competitior,
        CustomizeAlerts,
        AlertText,
        Insights,
        InsightsLink,
        AlertEnabled,
        OverrideText,
        CustomText,
        DefaultText,
        Header,
        HeaderCustomeMaxError,
        AlertMaxError,
        RulescheckError,
        RequiredFieldError,
        CurrencyRange, //KFS-2766
        InsightValues, //KFS-2766
        BRRetrieve, //KFS-2766
        IsCloseDatePastDue,
        AlertOnPastDue,
        ArePastDueBestActions,
        AlertOnDueDate,
        IsCurrentPosNegative,
        AlertOnPosition,
        WhoIsCompetition,
        AlertOnNocompetitor,
        PositionVSCompetition,
        AlertOnPositionCompetition,
        EnterNumberOnly,
        Customer_Timing_for_Priorities,
        AlertOnCustomerTimeWork,
        IsPersonalWin,
        AlertOnPersonalWin,
        AlertOnBusinessResult,
        AlertOnNoBusinessResult,
        BuyingInfluenceRating,
        AlertOnBuyingInfluence,
        PotentialCoach,
        AlertOnBuyingRating,
        CoachInfluence,
        CoachInfluenceAlert,
        ModeCustomerTime,
        AlertOnCustomerTime,
        MinimumNumberOfBI,
        FieldOfPlayBR,
        BuySellHierarchyView,
        competitorError,
        categoryPerspective,
        Scorecard_Template_Name_Max_Char_Limit
    };

    get OptyStages() {
        return this.stageValues;
    }

    get BsRequiredPicklistValues() {
        this.bsPicklistValues = [];
        this.bsPicklistValues.push({ label: yesLabel, value: yesLabel });
        this.bsPicklistValues.push({ label: noLabel, value: noLabel });
        return this.bsPicklistValues;
    }

    get BsRangePicklistValues() {
        this.bsRngPicklistValues = [];
        this.bsRngPicklistValues.push({ label: yesLabel, value: yesLabel });
        this.bsRngPicklistValues.push({ label: noLabel, value: noLabel });
        return this.bsRngPicklistValues;
    }

    get ScorecardPicklistValues() {
        this.scrcrdPicklistValues = [];
        this.scrcrdPicklistValues.push({ label: yesLabel, value: yesLabel });
        this.scrcrdPicklistValues.push({ label: noLabel, value: noLabel });
        return this.scrcrdPicklistValues;
    }

    get BiRolesPicklistValues() {
        this.rolesPicklistValues = [];
        this.rolesPicklistValues.push({ label: technicalLabel, value: technicalLabel });
        this.rolesPicklistValues.push({ label: coachLabel, value: coachLabel });
        this.rolesPicklistValues.push({ label: economicLabel, value: economicLabel });
        this.rolesPicklistValues.push({ label: userLabel, value: userLabel });
        return this.rolesPicklistValues;
    }
    handleGlobalOppStageChange(event) {
        this.selectedGlobalOppStage = event.detail.value;
        if (this.selectedGlobalOppStage.length) {
            this.globalOptyStage = this.selectedGlobalOppStage.join();
        } else {
            this.globalOptyStage = "";
        }
    }

    validateErrorNotification() {
        let returnvar = false;
        let counter = 0;
        let categoryFields = [];
        if (this.selectedCategoryType === categoryOpportunity) {
            categoryFields = [
                this.maxDaysBSUpdate,
                this.maxDaysOptyStage,
                this.minActionsOptyStage,
                this.blueSheetReqdValue,
                this.scorCardValueSelected,
                this.isClosedDatePast,
                this.isPastActionDue,
                this.isCurrPosNegative,
                this.isCompetitorIdentified,
                this.isPosCompetitionZero,
                this.isCustTimeLater
            ];
        }
        if (this.selectedCategoryType === categoryScorecard) {
            categoryFields = [
                this.lastModifiedDateCheck,
                this.opportunityCriteriaScoreCheck,
                this.totalScoreCheck,
                this.businessCriteriaScoreCheck,
                this.scorCardValueSelected
            ];
        }
        if (this.selectedCategoryType === categoryBuyingInfluence) {
            categoryFields = [
                this.isNegativeRating,
                this.isHighRatedBINoCoach,
                this.isCoachWithLowBI,
                this.isPersonWinIdentified,
                this.isBusinessResultIdentified,
                this.minNumberContact,
                this.isDisconModeCustTiming,
                this.roleSelectedValue
            ];
        }
        if (this.selectedCategoryType === categoryMeetingPlan) {
            categoryFields = [
                this.isMinActCommitAdded,
                this.isBestActCommitAdded,
                this.isVBRAdded,
                this.isConceptForBIAdded
            ];
        }
        categoryFields.forEach(e => {
            if (e || e === true) {
                counter++;
            }
        });
        if (counter > 1) {
            returnvar = true;
        }
        return returnvar;
    }

    handleMaxDaysBSUpdate(event) {
        this.maxDaysBSUpdate = event.target.value;
        this.getRecommendationsActionFromDB("BAL_3", this.maxDaysBSUpdate);
    }
    handleMaxDaysOptyStage(event) {
        this.maxDaysOptyStage = event.target.value;
        this.getRecommendationsActionFromDB("BAL_5", this.maxDaysOptyStage);
    }
    handleMinActionsOptyStage(event) {
        this.minActionsOptyStage = event.target.value;
        this.getRecommendationsActionFromDB("BAL_6", this.minActionsOptyStage);
    }
    handleMaximumRangeUpdate(event) {
        this.maximumRange = event.target.value;
    }
    handleMinimumRangeUpdate(event) {
        this.minimumRange = event.target.value;
    }
    handleCurrencyFieldChange(event) {
        this.selectedCurrencyField = event.target.value;
        if (this.selectedCurrencyField) {
            this.disableMinMaxRange = false;
        } else {
            this.disableMinMaxRange = true;
        }
    }
    handleCategoryValueChange(event) {
        this.selectedCategoryType = event.target.value;
        this.showSelectedCategorySection(this.selectedCategoryType);
        this.initializeAllSectionData();
    }
    handleRefresh(event) {
        this.isSaveDisabled = event.detail;
    }
    showSelectedCategorySection(selectedCategoryValue) {
        if (selectedCategoryValue === categoryOpportunity) {
            this.categoryOpty = true;
            this.categoryScr = false;
            this.categoryBI = false;
            this.categoryMeetingPlan = false;
            this.categoryComp = false;
            this.categoryPersp = false;
            this.isSaveDisabled = false;
        }
        if (selectedCategoryValue === categoryScorecard) {
            this.categoryScr = true;
            this.categoryBI = false;
            this.categoryOpty = false;
            this.categoryMeetingPlan = false;
            this.categoryComp = false;
            this.categoryPersp = false;
            this.isSaveDisabled = false;
        }
        if (selectedCategoryValue === categoryBuyingInfluence) {
            this.categoryBI = true;
            this.categoryScr = false;
            this.categoryOpty = false;
            this.categoryMeetingPlan = false;
            this.categoryComp = false;
            this.categoryPersp = false;
            this.isSaveDisabled = false;
        }
        if (selectedCategoryValue === categoryMeetingPlan) {
            this.categoryBI = false;
            this.categoryScr = false;
            this.categoryOpty = false;
            this.categoryMeetingPlan = true;
            this.categoryComp = false;
            this.categoryPersp = false;
            this.isSaveDisabled = false;
        }
        if (selectedCategoryValue === categoryCompetitor) {
            this.categoryBI = false;
            this.categoryScr = false;
            this.categoryOpty = false;
            this.categoryMeetingPlan = false;
            this.categoryComp = true;
            this.categoryPersp = false;
            this.isExpandableViewCompetitor = true;
            this.isSaveDisabled = false;
        }
        if (selectedCategoryValue === categoryPerspective) {
            this.categoryBI = false;
            this.categoryScr = false;
            this.categoryOpty = false;
            this.categoryMeetingPlan = false;
            this.categoryComp = false;
            this.categoryPersp = true;
            this.isExpandableViewPerspective = true;
            this.isSaveDisabled = true;
        }
        if (
            this.categoryBI === true ||
            this.categoryScr === true ||
            this.categoryOpty === true ||
            this.categoryMeetingPlan === true
        ) {
            this.categoryActoptions = true;
        }
    }
    mapCustomPerspectiveInsights(resultData) {
        let perspectiveJSON = {
            id: resultData.id,
            alertText: resultData.insights,
            alertLink: resultData.insightsLink,
            linkdisplayAs: resultData.displayLinkAs,
            industry: resultData.industry,
            optyType: resultData.optyType
        };
        this.isSaveDisabled = false;
        this.template.querySelector("c-b-s-create-perspective").setData(perspectiveJSON);
    }
    handleBsRequiredPicklistValue(event) {
        this.bsReqSelectedValue = event.target.value;
        if (this.bsReqSelectedValue === "Yes") {
            this.blueSheetReqdValue = true;
        } else {
            this.blueSheetReqdValue = false;
        }
        this.getRecommendationsActionFromDB("BAL_1", this.blueSheetReqdValue);
    }
    handleScorecardPicklistValue(event) {
        this.scrCrdSelectedValue = event.target.value;
        if (this.scrCrdSelectedValue === "Yes") {
            this.scorCardValueSelected = true;
        } else {
            this.scorCardValueSelected = false;
        }
        this.getRecommendationsActionFromDB("BAL_11", this.scorCardValueSelected);
    }
    handleBiRolesPicklistValue(event) {
        this.roleSelectedValue = event.target.value;
        this.getRecommendationsActionFromDB("BAL_12", this.roleSelectedValue);
    }
    handleValueSelcted(event) {
        this.brGroupId = event.detail;
    }
    getAllOptyStages() {
        getOpportunityStagePicklistValues().then(result => {
            let data = JSON.parse(result);
            for (let key in data) {
                if (data.hasOwnProperty(key)) {
                    this.stageValues.push({ label: key, value: data[key] }); //Here we are creating the array to show on UI.
                }
            }
        });
    }
    connectedCallback() {
        getBusinessRulesGroupLookup().then(result => {
            this.objectForLookup = result.lookupOnObject;
            this.lookuptargetField = result.targetField;
        });
        getCompetitiorLookup().then(result => {
            this.objectForLookupCompetitior = result.lookupOnObject;
            this.lookuptargetFieldCompetitior = result.targetField;
        });

        this.itemId = this.recordId;
        if (this.itemId == null) {
            this.getAllOptyStages();
        } else {
            this.getCurrentBusinessRule();
            this.isDisableCategory = true;
            this.getCustomAlertRecord();
        }
        // this.countActAlertChk();
    }
    handleActiveButtonClick(event) {
        if (event.target.checked === false) {
            this.active = false;
        } else {
            this.active = true;
        }
    }
    handleIsClosedDatePastClick(event) {
        this.isClosedDatePast = event.target.checked;
        this.getRecommendationsActionFromDB("BAL_4", this.isClosedDatePast);
    }
    handleIsPastActionDueClick(event) {
        this.isPastActionDue = event.target.checked;
        this.getRecommendationsActionFromDB("BAL_7", this.isPastActionDue);
    }
    handleIsCurrPosNegativeClick(event) {
        this.isCurrPosNegative = event.target.checked;
        this.getRecommendationsActionFromDB("BAL_8", this.isCurrPosNegative);
    }
    handleIsCompetitorIdentifiedClick(event) {
        this.isCompetitorIdentified = event.target.checked;
        this.getRecommendationsActionFromDB("BAL_9", this.isCompetitorIdentified);
    }
    handleIsPosCompetitionZeroClick(event) {
        this.isPosCompetitionZero = event.target.checked;
        this.getRecommendationsActionFromDB("BAL_10", this.isPosCompetitionZero);
    }
    handleIsCustTimeLaterClick(event) {
        this.isCustTimeLater = event.target.checked;
        this.getRecommendationsActionFromDB("BAL_13", this.isCustTimeLater);
    }
    handleIsPersonWinIdentifiedClick(event) {
        this.isPersonWinIdentified = event.target.checked;
        this.getRecommendationsActionFromDB("BAL_20", this.isPersonWinIdentified);
    }
    handleMinBINumberClick(event) {
        this.minNumberContact = event.target.value;
        this.getRecommendationsActionFromDB("BAL_22", this.minNumberContact);
    }

    handleIsBusinessResultIdentifiedClick(event) {
        this.isBusinessResultIdentified = event.target.checked;
        this.getRecommendationsActionFromDB("BAL_21", this.isBusinessResultIdentified);
    }

    handleIsNegativeRatingClick(event) {
        this.isNegativeRating = event.target.checked;
        this.getRecommendationsActionFromDB("BAL_18", this.isNegativeRating);
    }

    handleIsHighRatedBINoCoachClick(event) {
        this.isHighRatedBINoCoach = event.target.checked;
        this.getRecommendationsActionFromDB("BAL_19", this.isHighRatedBINoCoach);
    }

    handleIsCoachWithLowBIClick(event) {
        this.isCoachWithLowBI = event.target.checked;
        this.getRecommendationsActionFromDB("BAL_23", this.isCoachWithLowBI);
    }

    handleIsDisconModeCustTimingClick(event) {
        this.isDisconModeCustTiming = event.target.checked;
        this.getRecommendationsActionFromDB("BAL_24", this.isDisconModeCustTiming);
    }
    handleInsightsText(event) {
        this.insightsAlertText = event.target.value;
        if (this.insightsAlertText && this.insightsAlertText.length === 256) {
            this.showMaxLimitErrorInsights = true;
        } else {
            this.showMaxLimitErrorInsights = false;
        }
    }
    handleInsightsLinkText(event) {
        this.insightsLinkText = event.target.value;
        if (this.insightsLinkText && this.insightsLinkText.length === 256) {
            this.showMaxLimitErrorInsightsLink = true;
        } else {
            this.showMaxLimitErrorInsightsLink = false;
        }
    }
    handleValueSelctedCompetitor(event) {
        this.competitorId = event.detail;
    }

    fetchInputValues() {
        const inp = this.template.querySelectorAll("lightning-input");

        inp.forEach(function(element) {
            if (element.name === "BusinessRuleName") {
                this.businessRuleName = element.value;
            } else if (element.name === "OptyAmount") {
                this.optyAmount = element.value;
            } else if (element.name === "MaxDaysBSUpdate") {
                this.maxDaysBSUpdate = element.value;
            } else if (element.name === "MaxDaysOptyStage") {
                this.maxDaysOptyStage = element.value;
            } else if (element.name === "MinActionsOptyStage") {
                this.minActionsOptyStage = element.value;
            } // else if (element.name === "minNumberContact") {
            //     this.minNumberContact = element.value;
            // }
        }, this);
    }

    handleSave(event) {
        this.fetchInputValues(event);
        this.spinnerFlag = true;

        if (this.selectedCategoryType === "Meeting Plan") {
            this.upsertGreenSheetFields();
        } else if (
            (!this.selectedCurrencyField || (this.selectedCurrencyField && (this.minimumRange || this.maximumRange))) &&
            this.selectedCategoryType !== "Meeting Plan"
        ) {
            this.upsertBlueSheetFields();
        } else {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: error_header,
                    message: this.label.CurrencyRange, //KFS-2766
                    variant: error_header
                })
            );
        }
    }

    mapPerpectiveData(event) {
        this.perspectiveData = event.detail;
    }
    upsertBlueSheetFields() {
        this.template.querySelector("c-b-s-create-perspective").getData();
        if (
            this.categoryComp === true &&
            this.active === true &&
            (this.insightsAlertText === undefined ||
                this.insightsAlertText === "" ||
                this.competitorId === "" ||
                this.competitorId === undefined)
        ) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: error_header,
                    message: competitorError,
                    variant: error_header
                })
            );
        } else {
            let customRecommendationActionObject = {};
            if (this.showErrorNotification === false) {
                customRecommendationActionObject = {
                    action: this.alertActionRecord,
                    managerEmail: this.alertManagerRecord,
                    sellerEmail: this.alertSellerRecord,
                    balId: this.alertBalId
                };
            }
            let insightObject = {
                insights: this.insightsAlertText,
                insightsLink: this.insightsLinkText,
                accountId: this.competitorId,
                id: this.insightId
            };
            let insightObjectPersp = {
                insights: this.perspectiveData.alertText,
                insightsLink: this.perspectiveData.alertLink,
                displayLinkAs: this.perspectiveData.linkdisplayAs,
                industry: this.perspectiveData.industry,
                optyType: this.perspectiveData.optyType,
                id: this.insightId
            };
            let brData = {
                id: this.itemId,
                isActive: this.active,
                brName: this.businessRuleName,
                opAmt: this.optyAmount,
                maxDaysBs: this.maxDaysBSUpdate,
                bsRange: this.bsRngSelectedValue,
                bsReq: this.bsReqSelectedValue,
                maxDaysOp: this.maxDaysOptyStage,
                minActions: this.minActionsOptyStage,
                scrCrd: this.scrCrdSelectedValue,
                buyRole: this.roleSelectedValue,
                brGroup: this.brGroupId,
                optyCurrencyField: this.selectedCurrencyField,
                amtMinRange: this.minimumRange,
                amtMaxRange: this.maximumRange,
                brCategory: this.selectedCategoryType,
                globalOptyStage: this.globalOptyStage,
                minNumberOfBIContact: this.minNumberContact,
                triggerOnBluesheetRequired: this.triggerOnBluesheetRequired,
                isClosedDatePast: this.isClosedDatePast,
                isPastActionDue: this.isPastActionDue,
                isCurrPosNegative: this.isCurrPosNegative,
                isCompetitorIdentified: this.isCompetitorIdentified,
                isPosCompetitionZero: this.isPosCompetitionZero,
                isCustTimeLater: this.isCustTimeLater,
                isPersonWinIdentified: this.isPersonWinIdentified,
                isBusinessResultIdentified: this.isBusinessResultIdentified,
                isNegativeRating: this.isNegativeRating,
                isHighRatedBINoCoach: this.isHighRatedBINoCoach,
                isCoachWithLowBI: this.isCoachWithLowBI,
                isDisconModeCustTiming: this.isDisconModeCustTiming,
                lastModifiedCheck: this.lastModifiedDateCheck,
                maxDaysScorecardUpdated: this.daysUpdatedScorecard,
                totalScoreCheck: this.totalScoreCheck,
                minimumTotalScore: this.minTotalScore,
                maximumTotalScore: this.maxTotalScore,
                busCriteriaScoreCheck: this.businessCriteriaScoreCheck,
                minimumBusinessScore: this.minBusinessCriteriaScore,
                maximumBusinessScore: this.maxBusinessCriteriaScore,
                optyCriteriaScoreCheck: this.opportunityCriteriaScoreCheck,
                minimumOptyScore: this.minOpportunityCriteriaScore,
                maximumOptyScore: this.maxOpportunityCriteriaScore,
                customCompetitorInsights: insightObject,
                customPerspectiveInsights: insightObjectPersp,
                customRecommendationAction: customRecommendationActionObject
            };
            upsertBusinessRule({ busRule: JSON.stringify(brData) })
                .then(result => {
                    // Clear the user enter values
                    // Show success messsage
                    if (result.status === success_header) {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: success_header,
                                message: Record_success_message,
                                variant: success_header
                            })
                        );
                        this.itemId = result.recordId;
                        //this.readView = true;
                        this[NavigationMixin.GenerateUrl]({
                            type: "standard__recordPage",
                            attributes: {
                                recordId: this.itemId,
                                objectApiName: this.objectForLookup,
                                actionName: "view"
                            }
                        }).then(url => {
                            window.location.assign(url);
                        });
                    }
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
    }

    upsertGreenSheetFields() {
        this.spinnerFlag = true;
        let customRecommendationActionObject = {};
        if (this.showErrorNotification === false) {
            customRecommendationActionObject = {
                action: this.alertActionRecord,
                managerEmail: this.alertManagerRecord,
                sellerEmail: this.alertSellerRecord,
                balId: this.alertBalId
            };
        }

        let brData = {
            id: this.itemId,
            isActive: this.active,
            brName: this.businessRuleName,
            brGroup: this.brGroupId,
            optyCurrencyField: this.selectedCurrencyField,
            amtMinRange: this.minimumRange,
            amtMaxRange: this.maximumRange,
            brCategory: this.selectedCategoryType,
            globalOptyStage: this.globalOptyStage,
            isMinActCommitAdded: this.isMinActCommitAdded,
            isBestActCommitAdded: this.isBestActCommitAdded,
            isVBRAdded: this.isVBRAdded,
            isConceptForBIAdded: this.isConceptForBIAdded,
            numDaysBeforeMeeting: this.numDaysBeforeMeeting,
            customRecommendationAction: customRecommendationActionObject
        };

        upsertGreenSheetBusinessRule({ busRule: JSON.stringify(brData) })
            .then(result => {
                // Clear the user enter values
                // Show success messsage
                if (result.status === success_header) {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: success_header,
                            message: Record_success_message,
                            variant: success_header
                        })
                    );
                    this.itemId = result.recordId;
                    //this.readView = true;
                    this[NavigationMixin.GenerateUrl]({
                        type: "standard__recordPage",
                        attributes: {
                            recordId: this.itemId,
                            objectApiName: this.objectForLookup,
                            actionName: "view"
                        }
                    }).then(url => {
                        window.location.assign(url);
                    });
                }
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

    getCurrentBusinessRule() {
        getBusinessRule({ brId: this.itemId })
            .then(result => {
                if (result.blueSheetRuleWrapper) {
                    this.getBlueSheetData(result.blueSheetRuleWrapper);
                }
                if (result.greenSheetRuleWrapper) {
                    this.getGreenSheetData(result.greenSheetRuleWrapper);
                }
            })
            .catch(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: error_header,
                        message: this.label.BRRetrieve, //KFS-2766
                        variant: error_header
                    })
                );
            });
    }

    getBlueSheetData(element) {
        this.businessRuleName = element.brName;
        this.bsReqSelectedValue = element.bsReq;
        this.bsRngSelectedValue = element.bsRange;
        this.optyAmount = element.opAmt;
        this.maxDaysBSUpdate = element.maxDaysBs;
        this.maxDaysOptyStage = element.maxDaysOp;
        this.minActionsOptyStage = element.minActions;
        this.scrCrdSelectedValue = element.scrCrd;
        this.roleSelectedValue = element.buyRole;
        this.brGroupId = element.brGroup;
        this.brAutoName = element.name;
        this.triggerOnBluesheetRequired = element.triggerOnBluesheetRequired;
        this.isCustTimeLater = element.isCustTimeLater;
        this.isPersonWinIdentified = element.isPersonWinIdentified;
        this.isBusinessResultIdentified = element.isBusinessResultIdentified;
        this.isNegativeRating = element.isNegativeRating;
        this.isHighRatedBINoCoach = element.isHighRatedBINoCoach;
        this.isCoachWithLowBI = element.isCoachWithLowBI;
        this.isDisconModeCustTiming = element.isDisconModeCustTiming;
        this.isClosedDatePast = element.isClosedDatePast;
        this.isPastActionDue = element.isPastActionDue;
        this.isCurrPosNegative = element.isCurrPosNegative;
        this.isCompetitorIdentified = element.isCompetitorIdentified;
        this.isPosCompetitionZero = element.isPosCompetitionZero;
        this.isCustTimeLater = element.isCustTimeLater;
        this.minNumberContact = element.minNumberOfBIContact;

        if (element.isActive === "true") {
            this.active = true;
        } else {
            this.active = false;
        }
        //KFS-863 - new logic update
        this.globalOptyStage = element.globalOptyStage;
        if (element.globalOptyStage !== undefined && element.globalOptyStage.length > 0) {
            this.selectedGlobalOppStage = element.globalOptyStage.split(",");
        } else {
            this.globalOptyStage = null;
        }
        this.minimumRange = element.amtMinRange;
        this.maximumRange = element.amtMaxRange;
        this.selectedCategoryType = element.brCategory;
        this.selectedCurrencyField = element.optyCurrencyField;
        this.lastModifiedDateCheck = element.lastModifiedCheck;
        this.daysUpdatedScorecard = element.maxDaysScorecardUpdated;
        this.totalScoreCheck = element.totalScoreCheck;
        this.minTotalScore = element.minimumTotalScore;
        this.maxTotalScore = element.maximumTotalScore;
        this.businessCriteriaScoreCheck = element.busCriteriaScoreCheck;
        this.minBusinessCriteriaScore = element.minimumBusinessScore;
        this.maxBusinessCriteriaScore = element.maximumBusinessScore;
        this.opportunityCriteriaScoreCheck = element.optyCriteriaScoreCheck;
        this.minOpportunityCriteriaScore = element.minimumOptyScore;
        this.maxOpportunityCriteriaScore = element.maximumOptyScore;
        this.showSelectedCategorySection(this.selectedCategoryType);
        if (this.selectedCurrencyField) {
            this.disableMinMaxRange = false;
        } else {
            this.disableMinMaxRange = true;
        }
        if (element && element.customCompetitorInsights) {
            this.mapCustomCompetitionInsights(element.customCompetitorInsights);
        }
        if (element && element.customPerspectiveInsights) {
            this.mapCustomPerspectiveInsights(element.customPerspectiveInsights);
        }
        this.getAllOptyStages();
    }

    mapCustomCompetitionInsights(element) {
        this.insightsAlertText = element.insights;
        this.insightsLinkText = element.insightsLink;
        this.competitorId = element.accountId;
        this.insightId = element.id;
    }

    getGreenSheetData(element) {
        this.businessRuleName = element.brName;
        if (element.isActive === "true") {
            this.active = true;
        } else {
            this.active = false;
        }
        this.brGroupId = element.brGroup;
        this.brAutoName = element.name;
        this.globalOptyStage = element.globalOptyStage;
        if (element.globalOptyStage !== undefined && element.globalOptyStage.length > 0) {
            this.selectedGlobalOppStage = element.globalOptyStage.split(",");
        } else {
            this.globalOptyStage = null;
        }
        this.minimumRange = element.amtMinRange;
        this.maximumRange = element.amtMaxRange;
        this.selectedCategoryType = element.brCategory;
        this.selectedCurrencyField = element.optyCurrencyField;
        if (this.selectedCurrencyField) {
            this.disableMinMaxRange = false;
        } else {
            this.disableMinMaxRange = true;
        }
        this.isBestActCommitAdded = element.isBestActCommitAdded;
        this.isMinActCommitAdded = element.isMinActCommitAdded;
        this.isConceptForBIAdded = element.isConceptForBIAdded;
        this.isVBRAdded = element.isVBRAdded;
        this.brOwnerName = element.brOwnerName;
        this.brCreateBy = element.createdBy;
        this.createdDate = element.createdDate;
        this.lastModifiedDate = element.lastModifiedDate;
        this.brLastModifiedBy = element.lastModifiedBY;
        this.createdById = element.createdById;
        this.lastModifiedById = element.lastModifiedById;
        this.numDaysBeforeMeeting = element.numDaysBeforeMeeting;
        this.showSelectedCategorySection(this.selectedCategoryType);
        this.getAllOptyStages();
    }

    handleCancel() {
        if (this.itemId) {
            this[NavigationMixin.Navigate]({
                type: "standard__recordPage",
                attributes: {
                    recordId: this.itemId,
                    objectApiName: this.objectForLookup,
                    actionName: "view"
                }
            });
        } else {
            this[NavigationMixin.Navigate]({
                type: "standard__objectPage",
                attributes: {
                    objectApiName: this.objectForLookup,
                    actionName: "list"
                },
                state: {
                    filterName: "Recent"
                }
            });
        }
    }

    initializeAllSectionData() {
        this.bsReqSelectedValue = "";
        this.bsRngSelectedValue = "";
        this.scrCrdSelectedValue = "";
        this.optyStageBSReq = "";
        this.optyStageBSRange = "";
        this.optyStageBSUpdated = "";
        this.optyStageSSOSales = "";
        this.optyStageMinPossAction = "";
        this.optyStageBIRole = "";
        this.optyStageScorecardReq = "";
        this.optyAmount = "";
        this.maxDaysBSUpdate = "";
        this.maxDaysOptyStage = "";
        this.minActionsOptyStage = "";
        this.roleSelectedValue = "";
    }
    //start : inpunt field values for scorecard category
    handleScorecardLastModifiedDateCheck(event) {
        this.lastModifiedDateCheck = event.target.checked;
        this.getRecommendationsActionFromDB("BAL_14", this.lastModifiedDateCheck);
    }

    handleOpportunityCriteriaScoreCheck(event) {
        this.opportunityCriteriaScoreCheck = event.target.checked;
        this.getRecommendationsActionFromDB("BAL_16", this.opportunityCriteriaScoreCheck);
    }

    handleTotalScoreCheck(event) {
        this.totalScoreCheck = event.target.checked;
        this.getRecommendationsActionFromDB("BAL_15", this.totalScoreCheck);
    }

    handleBusinessCriteriaScoreCheck(event) {
        this.businessCriteriaScoreCheck = event.target.checked;
        this.getRecommendationsActionFromDB("BAL_17", this.businessCriteriaScoreCheck);
    }
    handleMaxDaysScorecardUpdated(event) {
        this.daysUpdatedScorecard = event.target.value;
    }

    handleMinTotalScore(event) {
        this.minTotalScore = event.target.value;
    }

    handleMaxTotalScore(event) {
        this.maxTotalScore = event.target.value;
    }

    handleMinOpportunityCriteriaScore(event) {
        this.minOpportunityCriteriaScore = event.target.value;
    }

    handleMaxOpportunityCriteriaScore(event) {
        this.maxOpportunityCriteriaScore = event.target.value;
    }

    handleMinBusinessCriteriaScore(event) {
        this.minBusinessCriteriaScore = event.target.value;
    }

    handleMaxBusinessCriteriaScore(event) {
        this.maxBusinessCriteriaScore = event.target.value;
    }
    //end : input field values for scorecard category

    //start : Input field values for meeting plan category
    handleisConceptForBIAddedClick(event) {
        this.isConceptForBIAdded = event.target.checked;
        this.getRecommendationsActionFromDB("BAL_28", this.isConceptForBIAdded);
    }
    handleisVBRAddedClick(event) {
        this.isVBRAdded = event.target.checked;
        this.getRecommendationsActionFromDB("BAL_27", this.isVBRAdded);
    }
    handleisBestActCommitAddedClick(event) {
        this.isBestActCommitAdded = event.target.checked;
        this.getRecommendationsActionFromDB("BAL_26", this.isBestActCommitAdded);
    }
    handleisMinActCommitAddedClick(event) {
        this.isMinActCommitAdded = event.target.checked;
        this.getRecommendationsActionFromDB("BAL_25", this.isMinActCommitAdded);
    }
    handleNumDaysBeforeMeetingChanged(event) {
        this.numDaysBeforeMeeting = event.target.value;
    }
    //end : Input field values for meeting plan category
    handleToggleCompetitor() {
        this.isExpandableViewCompetitor = !this.isExpandableViewCompetitor;
    }
    getDataFromBackend(ruleId) {
        getDefaultAlerts({ balId: ruleId })
            .then(data => {
                this.listAlertTemplate = [];
                this.renderChildTemplate = true;
                this.alertActionRecord = data.action;
                this.alertSellerRecord = data.sellerEmail;
                this.alertManagerRecord = data.managerEmail;
                if (ruleId === "BAL_12") {
                    let defaultMsg = data.action.defaultAlertMessage;
                    defaultMsg = defaultMsg.replace(
                        "{Business_Rules__c.Buying_Influence_Role__c}",
                        this.roleSelectedValue
                    );
                    data.action.defaultAlertMessage = defaultMsg;
                }
                this.listAlertTemplate.push(data.action);
                if (ruleId === "BAL_12") {
                    let defaultMsg = data.sellerEmail.defaultAlertMessage;
                    defaultMsg = defaultMsg.replace("{BI.Role__c}", this.roleSelectedValue);
                    data.sellerEmail.defaultAlertMessage = defaultMsg;
                }
                this.listAlertTemplate.push(data.sellerEmail);
                if (ruleId === "BAL_12") {
                    let defaultMsg = data.managerEmail.defaultAlertMessage;
                    defaultMsg = defaultMsg.replaceAll("{BI.Role__c}", this.roleSelectedValue);
                    //defaultMsg = defaultMsg.replace("{BI.Role__c}",this.roleSelectedValue);
                    data.managerEmail.defaultAlertMessage = defaultMsg;
                }
                this.listAlertTemplate.push(data.managerEmail);
            })
            .catch(error => {
                this.error = error;
            });
    }

    getRecommendationsActionFromDB(balIdSearched, fieldValue) {
        if (fieldValue) {
            if (!this.ruleNames.includes(balIdSearched)) {
                this.ruleNames.push(balIdSearched);
            }
        } else {
            let index = this.ruleNames.indexOf(balIdSearched);
            if (index >= 0) {
                this.ruleNames.splice(index, 1);
            }
        }
        this.alertBalId = this.ruleNames[0];
        this.showErrorNotification = this.validateErrorNotification();
        this.listAlertTemplate = [];
        if (this.showErrorNotification === true) {
            this.listAlertTemplate = [];
            let actionElement = {
                alertType: AlertTypeAction
            };
            this.listAlertTemplate.push(actionElement);
            let sellerElement = {
                alertType: AlertTypeSeller
            };
            this.listAlertTemplate.push(sellerElement);
            let managerElement = {
                alertType: AlertTypeManager
            };
            this.listAlertTemplate.push(managerElement);
            // for (let i = 0; i < 3; i++) {
            //     this.listAlertTemplate.push("");
            // }
            this.renderChildTemplate = true;
        } else {
            if (this.itemId && !this.ruleNames) {
                this.getCustomAlertRecord();
            } else {
                if (this.ruleNames[0]) {
                    this.getDataFromBackend(this.ruleNames[0]);
                } else {
                    this.showErrorNotification = true;
                }
            }
        }
    }
    validateIfErrorOnChild() {
        if (
            (this.alertActionRecord.overrideHeader === true && !this.alertActionRecord.customAlertHeader) ||
            (this.alertActionRecord.overrideMessage === true && !this.alertActionRecord.customAlertMessage) ||
            (this.alertSellerRecord.overrideHeader === true && !this.alertSellerRecord.customAlertHeader) ||
            (this.alertSellerRecord.overrideMessage === true && !this.alertSellerRecord.customAlertMessage) ||
            (this.alertManagerRecord.overrideHeader === true && !this.alertManagerRecord.customAlertHeader) ||
            (this.alertManagerRecord.overrideMessage === true && !this.alertManagerRecord.customAlertMessage)
        ) {
            this.isSaveDisabled = true;
        } else {
            this.isSaveDisabled = false;
        }
    }

    getUpdatedChildData(event) {
        let alertDataRecord = event.detail;
        this.alertBalId = alertDataRecord.balId;
        if (alertDataRecord.alertType === "Action") {
            this.alertActionRecord = alertDataRecord;
        } else if (alertDataRecord.alertType === "Seller Email") {
            this.alertSellerRecord = alertDataRecord;
        } else {
            this.alertManagerRecord = alertDataRecord;
        }
        this.validateIfErrorOnChild();
    }
    getCustomAlertRecord() {
        getRecommendationsActionByRuleId({ bsRuleId: this.itemId })
            .then(data => {
                this.renderChildTemplate = true;
                if (JSON.stringify(data) !== "{}") {
                    this.alertBalId = data.action.balId;
                    this.ruleNames.push(data.action.balId);
                    this.alertActionRecord = data.action;
                    this.alertSellerRecord = data.sellerEmail;
                    this.alertManagerRecord = data.managerEmail;
                    this.listAlertTemplate.push(data.action);
                    this.listAlertTemplate.push(data.sellerEmail);
                    this.listAlertTemplate.push(data.managerEmail);
                } else {
                    this.getBAlId();
                    this.showErrorNotification = this.validateErrorNotification();
                    if (this.showErrorNotification === true) {
                        for (let i = 0; i < 3; i++) {
                            this.listAlertTemplate.push("");
                        }
                        this.renderChildTemplate = true;
                    }
                }
            })
            .catch(error => {
                this.error = error;
            });
    }

    getBAlId() {
        // eslint-disable-next-line no-unused-expressions
        this.maxDaysBSUpdate ? this.ruleNames.push("BAL_3") : null;
        // eslint-disable-next-line no-unused-expressions
        this.maxDaysOptyStage ? this.ruleNames.push("BAL_5") : null;
        // eslint-disable-next-line no-unused-expressions
        this.minActionsOptyStage ? this.ruleNames.push("BAL_6") : null;
        // eslint-disable-next-line no-unused-expressions
        this.bsReqSelectedValue === "Yes" ? this.ruleNames.push("BAL_1") : null;
        // eslint-disable-next-line no-unused-expressions
        this.isClosedDatePast ? this.ruleNames.push("BAL_4") : null;
        // eslint-disable-next-line no-unused-expressions
        this.isPastActionDue ? this.ruleNames.push("BAL_7") : null;
        // eslint-disable-next-line no-unused-expressions
        this.isCurrPosNegative ? this.ruleNames.push("BAL_8") : null;
        // eslint-disable-next-line no-unused-expressions
        this.isCompetitorIdentified ? this.ruleNames.push("BAL_9") : null;
        // eslint-disable-next-line no-unused-expressions
        this.isPosCompetitionZero ? this.ruleNames.push("BAL_10") : null;
        // eslint-disable-next-line no-unused-expressions
        this.isCustTimeLater ? this.ruleNames.push("BAL_13") : null;

        // eslint-disable-next-line no-unused-expressions
        this.lastModifiedDateCheck ? this.ruleNames.push("BAL_14") : null;
        // eslint-disable-next-line no-unused-expressions
        this.opportunityCriteriaScoreCheck ? this.ruleNames.push("BAL_16") : null;
        // eslint-disable-next-line no-unused-expressions
        this.totalScoreCheck ? this.ruleNames.push("BAL_15") : null;
        // eslint-disable-next-line no-unused-expressions
        this.businessCriteriaScoreCheck ? this.ruleNames.push("BAL_17") : null;
        // eslint-disable-next-line no-unused-expressions
        this.scrCrdSelectedValue === "Yes" ? this.ruleNames.push("BAL_11") : null;

        // eslint-disable-next-line no-unused-expressions
        this.isNegativeRating ? this.ruleNames.push("BAL_18") : null;
        // eslint-disable-next-line no-unused-expressions
        this.isHighRatedBINoCoach ? this.ruleNames.push("BAL_19") : null;
        // eslint-disable-next-line no-unused-expressions
        this.isCoachWithLowBI ? this.ruleNames.push("BAL_23") : null;
        // eslint-disable-next-line no-unused-expressions
        this.isPersonWinIdentified ? this.ruleNames.push("BAL_20") : null;
        // eslint-disable-next-line no-unused-expressions
        this.isBusinessResultIdentified ? this.ruleNames.push("BAL_21") : null;
        // eslint-disable-next-line no-unused-expressions
        this.minNumberContact ? this.ruleNames.push("BAL_22") : null;
        // eslint-disable-next-line no-unused-expressions
        this.isDisconModeCustTiming ? this.ruleNames.push("BAL_24") : null;
        // eslint-disable-next-line no-unused-expressions
        this.roleSelectedValue ? this.ruleNames.push("BAL_12") : null;

        // eslint-disable-next-line no-unused-expressions
        this.isMinActCommitAdded ? this.ruleNames.push("BAL_25") : null;
        // eslint-disable-next-line no-unused-expressions
        this.isBestActCommitAdded ? this.ruleNames.push("BAL_26") : null;
        // eslint-disable-next-line no-unused-expressions
        this.isVBRAdded ? this.ruleNames.push("BAL_27") : null;
        // eslint-disable-next-line no-unused-expressions
        this.isConceptForBIAdded ? this.ruleNames.push("BAL_28") : null;
    }
}