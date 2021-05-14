import { LightningElement, track, api } from "lwc";
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
import BusinessRuleCategory from "@salesforce/label/c.BusinessRuleCategory";
import OpportunityCurrencyField from "@salesforce/label/c.OpportunityCurrencyField";
import MinimumRange from "@salesforce/label/c.MinimumRange";
import MaximumRange from "@salesforce/label/c.MaximumRange";
import MinimumNumberOfContactsOnBI from "@salesforce/label/c.MinimumNumberOfContactsOnBI";
import BusinessRuleOwner from "@salesforce/label/c.BusinessRuleOwner";
import BusinessRuleSystemInformation from "@salesforce/label/c.BusinessRuleSystemInformation";
import BusinessRuleCreatedBy from "@salesforce/label/c.BusinessRuleCreatedBy";
import BusinessRuleLastModifiedBy from "@salesforce/label/c.BusinessRuleLastModifiedBy";
import getBusinessRulesGroupLookup from "@salesforce/apex/BusinessRules.getBusinessRulesGroupName";
import getBusinessRule from "@salesforce/apex/BusinessRules.getBusinessRule";
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
import categoryMeetingPlan from "@salesforce/label/c.categoryMeetingPlan";
import NumberofDaysBeforeMeeting from "@salesforce/label/c.NumberofDaysBeforeMeeting";
import NoConceptforBIEntered from "@salesforce/label/c.NoConceptforBIEntered";
import NoVBREntered from "@salesforce/label/c.NoVBREntered";
import NoBestActionCommitmentEntered from "@salesforce/label/c.NoBestActionCommitmentEntered";
import NoMinimumActionCommitmentEntered from "@salesforce/label/c.NoMinimumActionCommitmentEntered";
import TriggerNoConceptforBIEnteredHeader from "@salesforce/label/c.TriggerNoConceptforBIEnteredHeader";
import TriggerNoVBREnteredHeader from "@salesforce/label/c.TriggerNoVBREnteredHeader";
import TriggerNoBestActionCommitmentHeader from "@salesforce/label/c.TriggerNoBestActionCommitmentHeader";
import TriggerNoMinimumActionCommitmentHeader from "@salesforce/label/c.TriggerNoMinimumActionCommitmentHeader";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import competitior from "@salesforce/label/c.competitior";
import Insights from "@salesforce/label/c.Insights";
import InsightsLink from "@salesforce/label/c.InsightsLink";

import InsightsOpportunityType from "@salesforce/label/c.InsightsOpportunityType";
import InsightsIndustry from "@salesforce/label/c.InsightsIndustry";
import InsightsDisplayLinkAs from "@salesforce/label/c.InsightsDisplayLinkAs";
import InsightsCustomizeAlert from "@salesforce/label/c.InsightsCustomizeAlert";
import alertsLabel from "@salesforce/label/c.Alerts";
import ActionAlertConfiguration from "@salesforce/label/c.ActionAlertConfiguration";
import AlertEnabled from "@salesforce/label/c.AlertEnabled";
import OverrideText from "@salesforce/label/c.OverrideText";
import CustomText from "@salesforce/label/c.CustomText";
import DefaultText from "@salesforce/label/c.DefaultText";
import Header from "@salesforce/label/c.Header";
import AlertText from "@salesforce/label/c.AlertText";
import HeaderCustomeMaxError from "@salesforce/label/c.HeaderCustomeMaxError";
import AlertMaxError from "@salesforce/label/c.AlertMaxError";
import RulescheckError from "@salesforce/label/c.RulescheckError";
import BRRetrieve from "@salesforce/label/c.BRRetrieve";
import error_header from "@salesforce/label/c.error_header";
import Image from "@salesforce/label/c.Image";
import BuySellHierarchyView from "@salesforce/label/c.BuySellHierarchyView";
import FieldOfPlayBR from "@salesforce/label/c.FieldOfPlayBR";
import UtilityImage from "@salesforce/label/c.UtilityImage";

import AlertOnPastDue from "@salesforce/label/c.AlertOnPastDue";
import IsCloseDatePastDue from "@salesforce/label/c.IsCloseDatePastDue";
import ArePastDueBestActions from "@salesforce/label/c.ArePastDueBestActions";
import AlertOnDueDate from "@salesforce/label/c.AlertOnDueDate";
import IsCurrentPosNegative from "@salesforce/label/c.IsCurrentPosNegative";
import AlertOnPosition from "@salesforce/label/c.AlertOnPosition";
import WhoIsCompetition from "@salesforce/label/c.WhoIsCompetition";
import AlertOnNocompetitor from "@salesforce/label/c.AlertOnNocompetitor";
import PositionVSCompetition from "@salesforce/label/c.PositionVSCompetition";
import AlertOnPositionCompetition from "@salesforce/label/c.AlertOnPositionCompetition";
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
import categoryCompetitor from "@salesforce/label/c.CategoryCompetitor";

import getRecommendationsActionByRuleId from "@salesforce/apex/CustomAlertRecommendations.getRecommendationsActionByRuleId";

export default class BusinessRuleViewPage extends NavigationMixin(LightningElement) {
    @api recordId;
    @track businessRuleName;
    @track bsReqSelectedValue;
    @track bsRngSelectedValue;
    @track optyAmount;
    @track maxDaysBSUpdate;
    @track maxDaysOptyStage;
    @track minActionsOptyStage;
    @track scrCrdSelectedValue;
    @track roleSelectedValue;
    @track brGroupId;
    @track brAutoName;
    @track brGroupName;
    @track active;
    @track globalOptyStage;
    @track minimumRange;
    @track maximumRange;
    @track selectedCategoryType;
    @track selectedCurrencyField;
    @track objectForLookup;
    @track lookuptargetField;
    @track itemId;
    @track readView = true;
    @track categoryOpty = false;
    @track categoryScr = false;
    @track categoryBI = false;
    @track categoryComp = false;
    @track categoryActAlert = true;

    @track brOwner;
    @track brOwnerName;
    @track brCreateBy;
    @track brLastModifiedBy;
    @track createdDate;
    @track lastModifiedDate;
    @track createdById;
    @track lastModifiedById;
    @track minNumberContact;
    @track scrMaxDaysUpdate;
    @track minTotalScore;
    @track maxTotalScore;
    @track minOptyScore;
    @track maxOptyScore;
    @track minBusinessScore;
    @track maxBusinessScore;
    @track totalScoreCheck;
    @track lastModifiedDateCheck;
    @track opportunityCriteriaScoreCheck;
    @track businessCriteriaScoreCheck;
    @track insights;
    @track insightsLink;
    @track accountName;
    //Add --Starts
    @track alertTemplateRecord;
    @track isDefaultAlertHeader;
    @track isDefaultAlertMessage;
    @track isCustomAlertHeader;
    @track isCustomAlertMessage;
    @track isAlertEnabled;
    @track isOverrideHeader;
    @track isOverrideMessage;

    @track categoryMeetingPlan = false;
    @track noConceptEntered;
    @track noValidResonEntered;
    @track noBestActCommitmentEntered;
    @track minActionCommitmentEntered;
    @track numDaysBeforeMeeting;

    @track customDataAlerId;
    @track customDataAlertEnabled = "No";
    @track customDataCustomAlertHeader;
    @track customDataCustomAlertMessage;
    @track customDataDefaultAlertHeader = "";
    @track customDataDefaultAlertMessage;
    @track customDataOverrideHeader = "No";
    @track customDataOverrideMessage = "No";
    @track viewCategoryActAlert = true;
    @track customPerspectiveInsights;
    @track customPerspectiveInsightsLink;
    @track insightsDisplayLinkASText;
    @track customPerspectiveInsightsInsudtry;
    @track customPerspectiveInsightsOptType;
    @track isCustomPerspectiveInsights = false;
    @track viewPerspectiveInsights = true;

    @track isClosedDatePastDue;
    @track isBestActionPastDue;
    @track isCurrentPosNegative;
    @track isCompetitorAccount;
    @track positionVsCompetitor;
    @track custTimeForPriorityAvail;

    @track isBusinessResultavail;
    @track isPersonalWinAvail;
    @track biNegativeRating;
    @track biHighRateNoCoach;
    @track biLowDegreeCoach;
    @track biCustTimeUrgentKeel;

    //Add --Ends
    label = {
        InsightsDisplayLinkAs,
        InsightsCustomizeAlert,
        InsightsIndustry,
        InsightsOpportunityType,
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
        BusinessRuleOwner,
        BusinessRuleSystemInformation,
        BusinessRuleCreatedBy,
        BusinessRuleLastModifiedBy,
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
        competitior,
        Insights,
        InsightsLink,
        alertsLabel,
        ActionAlertConfiguration,
        AlertEnabled,
        OverrideText,
        CustomText,
        DefaultText,
        Header,
        AlertText,
        HeaderCustomeMaxError,
        AlertMaxError,
        RulescheckError,
        BRRetrieve, //KFS-2766
        error_header, //KFS-2766
        Image,
        BuySellHierarchyView,
        FieldOfPlayBR,
        UtilityImage,
        AlertOnPastDue,
        IsCloseDatePastDue,
        ArePastDueBestActions,
        AlertOnDueDate,
        IsCurrentPosNegative,
        AlertOnPosition,
        WhoIsCompetition,
        AlertOnNocompetitor,
        PositionVSCompetition,
        AlertOnPositionCompetition,
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
        categoryCompetitor
    };

    connectedCallback() {
        getBusinessRulesGroupLookup().then(result => {
            this.objectForLookup = result.lookupOnObject;
            this.lookuptargetField = result.targetField;
        });

        this.itemId = this.recordId;
        if (this.itemId != null) {
            this.getCurrentBusinessRule();
            // this.getActionAlert();
        }
    }

    getCurrentBusinessRule() {
        this.getRecommendationsDataByBSRuleId(this.itemId);
        getBusinessRule({ brId: this.itemId })
            .then(result => {
                if (result.blueSheetRuleWrapper && result.blueSheetRuleWrapper.brCategory !== "Meeting Plan") {
                    if (
                        result.blueSheetRuleWrapper.brCategory === "Scorecard" ||
                        result.blueSheetRuleWrapper.brCategory === "Opportunity" ||
                        result.blueSheetRuleWrapper.brCategory === "Buying Influences"
                    ) {
                        this.getRecommendationsDataByBSRuleId(this.itemId);
                    }
                    if (result.blueSheetRuleWrapper.brCategory === categoryCompetitor) {
                        this.categoryActAlert = false;
                    }
                    this.mapBlueSheetFields(result.blueSheetRuleWrapper);
                }
                if (result.greenSheetRuleWrapper && result.greenSheetRuleWrapper.brCategory === "Meeting Plan") {
                    this.getRecommendationsDataByBSRuleId(this.itemId);
                    this.mapGreenSheetFields(result.greenSheetRuleWrapper);
                }
                if (result.blueSheetRuleWrapper && result.blueSheetRuleWrapper.customPerspectiveInsights != null) {
                    this.mapCustomPerspectiveInsights(result.blueSheetRuleWrapper.customPerspectiveInsights);
                    this.categoryActAlert = false;
                }
                //console.log("greesheet ---" + JSON.stringify(result.greenSheetRuleWrapper));
            })
            .catch(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.label.error_header, //KFS-2766
                        message: this.label.BRRetrieve, //KFS-2766
                        variant: this.label.error_header
                    })
                );
            });
    }

    mapCustomPerspectiveInsights(resultData) {
        this.isCustomPerspectiveInsights = true;
        this.customPerspectiveInsights = resultData.insights;
        this.customPerspectiveInsightsLink = resultData.insightsLink;
        this.insightsDisplayLinkASText = resultData.displayLinkAs;
        this.customPerspectiveInsightsInsudtry = resultData.industry;
        this.customPerspectiveInsightsOptType = resultData.optyType;
    }
    mapCheckboxes(element) {
        this.isClosedDatePastDue = element.isClosedDatePast;
        this.isBestActionPastDue = element.isPastActionDue;
        this.isCurrentPosNegative = element.isCurrPosNegative;
        this.isCompetitorAccount = element.isCompetitorIdentified;
        this.positionVsCompetitor = element.isPosCompetitionZero;
        this.isBusinessResultavail = element.isBusinessResultIdentified;
        this.isPersonalWinAvail = element.isPersonWinIdentified;
        this.custTimeForPriorityAvail = element.isCustTimeLater;
        this.biNegativeRating = element.isNegativeRating;
        this.biHighRateNoCoach = element.isHighRatedBINoCoach;
        this.biLowDegreeCoach = element.isCoachWithLowBI;
        this.biCustTimeUrgentKeel = element.isDisconModeCustTiming;
    }

    mapBlueSheetFields(element) {
        this.mapCheckboxes(element);
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
        this.brGroupName = element.brGroupName;
        this.brOwnerName = element.brOwnerName;
        this.brCreateBy = element.createdBy;
        this.createdDate = element.createdDate;
        this.lastModifiedDate = element.lastModifiedDate;
        this.brLastModifiedBy = element.lastModifiedBY;
        this.createdById = element.createdById;
        this.lastModifiedById = element.lastModifiedById;
        this.minNumberContact = element.minNumberOfBIContact;
        if (element.brCategory === categoryCompetitor) {
            this.insights = element.customCompetitorInsights.insights;
            this.insightsLink = element.customCompetitorInsights.insightsLink;
            this.accountName = element.customCompetitorInsights.accountName;
        }
        if (element.isActive === "true") {
            this.active = true;
        } else {
            this.active = false;
        }
        //KFS-863 - new logic update
        this.brOwner = element.brOwner;
        this.globalOptyStage = element.globalOptyStage;
        this.minimumRange = element.amtMinRange;
        this.maximumRange = element.amtMaxRange;
        this.selectedCategoryType = element.brCategory;
        this.selectedCurrencyField = element.optyCurrencyField;
        this.scrMaxDaysUpdate = element.maxDaysScorecardUpdated;
        this.minTotalScore = element.minimumTotalScore;
        this.maxTotalScore = element.maximumTotalScore;
        this.minOptyScore = element.minimumOptyScore;
        this.maxOptyScore = element.maximumOptyScore;
        this.minBusinessScore = element.minimumBusinessScore;
        this.maxBusinessScore = element.maximumBusinessScore;
        if (element.totalScoreCheck === true) {
            this.totalScoreCheck = true;
        } else {
            this.totalScoreCheck = false;
        }
        if (element.lastModifiedCheck === true) {
            this.lastModifiedDateCheck = true;
        } else {
            this.lastModifiedDateCheck = false;
        }
        if (element.optyCriteriaScoreCheck === true) {
            this.opportunityCriteriaScoreCheck = true;
        } else {
            this.opportunityCriteriaScoreCheck = false;
        }
        if (element.busCriteriaScoreCheck === true) {
            this.businessCriteriaScoreCheck = true;
        } else {
            this.businessCriteriaScoreCheck = false;
        }
        this.showSelectedCategorySection(this.selectedCategoryType);
    }
    mapGreenSheetFields(element) {
        if (element.isActive === "true") {
            this.active = true;
        } else {
            this.active = false;
        }
        this.businessRuleName = element.brName;
        this.brGroupId = element.brGroup;
        this.brAutoName = element.name;
        this.brGroupName = element.brGroupName;
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
        this.noBestActCommitmentEntered = element.isBestActCommitAdded;
        this.minActionCommitmentEntered = element.isMinActCommitAdded;
        this.noConceptEntered = element.isConceptForBIAdded;
        this.noValidResonEntered = element.isVBRAdded;
        this.brOwnerName = element.brOwnerName;
        this.brCreateBy = element.createdBy;
        this.createdDate = element.createdDate;
        this.lastModifiedDate = element.lastModifiedDate;
        this.brLastModifiedBy = element.lastModifiedBY;
        this.createdById = element.createdById;
        this.lastModifiedById = element.lastModifiedById;
        this.numDaysBeforeMeeting = element.numDaysBeforeMeeting;
        this.showSelectedCategorySection(this.selectedCategoryType);
    }

    showSelectedCategorySection(selectedCategoryValue) {
        if (selectedCategoryValue === categoryOpportunity) {
            this.categoryOpty = true;
            this.categoryScr = false;
            this.categoryBI = false;
            this.categoryMeetingPlan = false;
            this.categoryComp = false;
        }
        if (selectedCategoryValue === categoryScorecard) {
            this.categoryScr = true;
            this.categoryBI = false;
            this.categoryOpty = false;
            this.categoryMeetingPlan = false;
            this.categoryComp = false;
        }
        if (selectedCategoryValue === categoryBuyingInfluence) {
            this.categoryBI = true;
            this.categoryScr = false;
            this.categoryOpty = false;
            this.categoryMeetingPlan = false;
            this.categoryComp = false;
        }
        if (selectedCategoryValue === categoryMeetingPlan) {
            this.categoryBI = false;
            this.categoryScr = false;
            this.categoryOpty = false;
            this.categoryMeetingPlan = true;
            this.categoryComp = false;
        }
        if (selectedCategoryValue === categoryCompetitor) {
            this.categoryBI = false;
            this.categoryScr = false;
            this.categoryOpty = false;
            this.categoryMeetingPlan = false;
            this.categoryComp = true;
        }
    }
    handleToggleSection() {
        //    this.isaddNew = true;
        this.viewCategoryActAlert = !this.viewCategoryActAlert;
    }

    handleTogglePerspectiveInsights() {
        this.viewPerspectiveInsights = !this.viewPerspectiveInsights;
    }
    viewOwnerRecord(event) {
        this[NavigationMixin.Navigate]({
            type: "standard__recordPage",
            attributes: {
                recordId: event.target.value,
                objectApiName: "User",
                actionName: "view"
            }
        });
    }

    viewBRGRecord(event) {
        this[NavigationMixin.Navigate]({
            type: "standard__recordPage",
            attributes: {
                recordId: event.target.value,
                objectApiName: this.lookuptargetField,
                actionName: "view"
            }
        });
    }

    getRecommendationsDataByBSRuleId(ruleId) {
        getRecommendationsActionByRuleId({ bsRuleId: ruleId })
            .then(data => {
                this.customDataAlerId = data.action.alerId;
                this.customDataAlertEnabled = data.action.alertEnabled ? "Yes" : "No";
                this.customDataCustomAlertHeader = data.action.customAlertHeader;
                this.customDataCustomAlertMessage = data.action.customAlertMessage;
                this.customDataDefaultAlertHeader = data.action.defaultAlertHeader;
                this.customDataDefaultAlertMessage = data.action.defaultAlertMessage;
                this.customDataOverrideHeader = data.action.overrideHeader ? "Yes" : "No";
                this.customDataOverrideMessage = data.action.overrideMessage ? "Yes" : "No";
            })
            .catch(error => {
                this.error = error;
            });
    }
}