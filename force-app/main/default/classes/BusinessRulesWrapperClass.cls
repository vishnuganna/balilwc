@SuppressWarnings('PMD.TooManyFields, PMD.ExcessivePublicCount, PMD.NcssMethodCount, PMD.NcssConstructorCount')
public class BusinessRulesWrapperClass {
    @AuraEnabled
    public String id;
    @AuraEnabled
    public String name;
    @AuraEnabled
    public String bsRange;
    @AuraEnabled
    public String bsReq;
    @AuraEnabled
    public String isActive;
    @AuraEnabled
    public String brName;
    @AuraEnabled
    public String opAmt;
    @AuraEnabled
    public String maxDaysBs;
    @AuraEnabled
    public String maxDaysOp;
    @AuraEnabled
    public String minActions;
    @AuraEnabled
    public String scrCrd;
    @AuraEnabled
    public String buyRole;
    @AuraEnabled
    public String brGroup;
    @AuraEnabled
    public String recordType;
    @AuraEnabled
    public String brGroupName;
    @AuraEnabled
    public String optyCurrencyField;
    @AuraEnabled
    public String amtMinRange;
    @AuraEnabled
    public String amtMaxRange;
    @AuraEnabled
    public String brCategory;
    @AuraEnabled
    public String globalOptyStage;
    @AuraEnabled
    public String brOwner;
    @AuraEnabled
    public string brOwnerName;
    @AuraEnabled
    public string createdBy;
    @AuraEnabled
    public string createdDate;
    @AuraEnabled
    public string lastModifiedBY;
    @AuraEnabled
    public string lastModifiedDate;
    @AuraEnabled
    public string createdById;
    @AuraEnabled
    public string lastModifiedById;
    @AuraEnabled
    public string minNumberOfBIContact;
    @AuraEnabled
    public string triggerOnBluesheetRequired;
    @AuraEnabled
    public boolean isClosedDatePast;
    @AuraEnabled
    public Boolean isPastActionDue;
    @AuraEnabled
    public Boolean isCurrPosNegative;
    @AuraEnabled
    public Boolean isCompetitorIdentified;
    @AuraEnabled
    public Boolean isPosCompetitionZero;
    @AuraEnabled
    public Boolean isCustTimeLater;
    @AuraEnabled
    public Boolean isPersonWinIdentified;
    @AuraEnabled
    public Boolean isBusinessResultIdentified;
    @AuraEnabled
    public Boolean isNegativeRating;
    @AuraEnabled
    public Boolean isHighRatedBINoCoach;
    @AuraEnabled
    public Boolean isCoachWithLowBI;
    @AuraEnabled
    public Boolean isDisconModeCustTiming;
    @AuraEnabled
    public Boolean lastModifiedCheck;
    @AuraEnabled
    public String maxDaysScorecardUpdated;
    @AuraEnabled
    public Boolean totalScoreCheck;
    @AuraEnabled
    public String minimumTotalScore;
    @AuraEnabled
    public String maximumTotalScore;
    @AuraEnabled
    public Boolean optyCriteriaScoreCheck;
    @AuraEnabled
    public String minimumOptyScore;
    @AuraEnabled
    public String maximumOptyScore;
    @AuraEnabled
    public Boolean busCriteriaScoreCheck;
    @AuraEnabled
    public String minimumBusinessScore;
    @AuraEnabled
    public String maximumBusinessScore;
    @AuraEnabled
    public InsightAlertsWrapper customCompetitorInsights;
    @AuraEnabled
    public InsightAlertsWrapper customPerspectiveInsights;
    @AuraEnabled
    public AlertRecommendationsWrapper customRecommendationAction;

    public BusinessRulesWrapperClass(Business_Rules__c br) {
        this.Id = br.Id;
        this.name = br.Name;
        this.bsRange = br.BS_Req_for_certain_Rev_Range__c;
        this.bsReq = br.Is_a_Blue_Sheet_required__c;
        this.isActive = String.ValueOf(br.IsActive__c);
        this.brName = br.Business_Rule_Name__c;
        //this.opAmt = String.ValueOf(br.Opty_Amount_2__c);
        //number fields
        this.maxDaysBs = String.ValueOf(br.Max_Days_Allowed_Since_Last_BS_Update__c);
        this.maxDaysOp = String.ValueOf(br.Max_Days_Allowed_in_a_Opty_Stage__c);
        this.minActions = String.ValueOf(br.Min_Number_of_Actions_For_a_Opty_Stage__c);
        //number fields end
        this.scrCrd = br.Scorecard_Required__c;
        this.isPersonWinIdentified = br.is_person_win_identified__c;
        this.isBusinessResultIdentified = br.is_business_result_identified__c;
        this.isNegativeRating = br.is_negative_rating__c;
        this.isHighRatedBINoCoach = br.is_high_rated_BI_no_coach__c;
        this.isCoachWithLowBI = br.is_coach_with_low_BI__c;
        this.isDisconModeCustTiming = br.is_discon_mode_cust_timing__c;
        this.buyRole = br.Buying_Influence_Role__c;
        this.brGroup = br.Business_Rules_Group__c;
        this.triggerOnBluesheetRequired = String.ValueOf(br.trigger_bluesheet_required__c);
        this.isClosedDatePast = br.is_closed_date_past__c;
        this.isPastActionDue = br.is_past_action_due__c;
        this.isCurrPosNegative = br.is_curr_pos_negative__c;
        this.isCompetitorIdentified = br.is_competitor_identified__c;
        this.isPosCompetitionZero = br.is_pos_competition_zero__c;
        this.isCustTimeLater = br.is_cust_time_later__c;
        String objName = ApexCommonUtil.getObjectwithNameSpace('Business_Rules__c');
        Id recTypeId = Schema.getGlobalDescribe()
            .get(objName)
            .getDescribe()
            .getRecordTypeInfosByName()
            .get('Default')
            .getRecordTypeId();
        this.recordType = String.ValueOf(recTypeId);
        this.brGroupName = br.Business_Rules_Group__r.Name;
        //KFS-863 additional logic
        this.optyCurrencyField = br.Opportunity_Currency_Fields__c;
        //number fields
        this.amtMinRange = br.Minimum_Range__c != null ? String.ValueOf(br.Minimum_Range__c) : null;
        this.amtMaxRange = br.Maximum_Range__c != null ? String.ValueOf(br.Maximum_Range__c) : null;
        //number fields end
        this.brCategory = br.Business_Rule_Catagory__c;
        this.globalOptyStage = br.Opportunity_Stage_Global__c;
        this.brOwner = br.OwnerId;
        this.brOwnerName = br.Owner.Name;
        this.createdBy = br.createdBy.Name;
        this.createdDate = String.ValueOf(br.createdDate);
        this.createdById = br.createdById;
        this.lastModifiedBY = br.lastModifiedBy.Name;
        this.lastModifiedDate = String.ValueOf(br.lastModifiedDate);
        this.lastModifiedById = br.LastModifiedById;
        //number field
        this.minNumberOfBIContact = br.Min_Number_Buying_Influence_Contacts__c != null
            ? String.ValueOf(br.Min_Number_Buying_Influence_Contacts__c)
            : null;
        this.lastModifiedCheck = br.Check_Scorecard_Last_Modified__c;
        //number field
        this.maxDaysScorecardUpdated = br.Scorecard_Number_of_Days_Updated__c != null
            ? String.ValueOf(br.Scorecard_Number_of_Days_Updated__c)
            : null;
        this.totalScoreCheck = br.Check_Total_Score__c;
        //number field
        this.minimumTotalScore = br.Minimum_Score__c != null ? String.ValueOf(br.Minimum_Score__c) : null;
        this.maximumTotalScore = br.Maximum_Score__c != null ? String.ValueOf(br.Maximum_Score__c) : null;
        //end
        this.optyCriteriaScoreCheck = br.Check_Opportunity_Score__c;
        //number field
        this.minimumOptyScore = br.OpportunityCriteria_Minimum_Score__c != null
            ? String.ValueOf(br.OpportunityCriteria_Minimum_Score__c)
            : null;
        this.maximumOptyScore = br.OpportunityCriteria_Maximum_Score__c != null
            ? String.ValueOf(br.OpportunityCriteria_Maximum_Score__c)
            : null;
        //end
        this.busCriteriaScoreCheck = br.Check_Business_Criteria_Score__c;
        //number field
        this.minimumBusinessScore = br.BusinessCriteria_Minimum_Score__c != null
            ? String.ValueOf(br.BusinessCriteria_Minimum_Score__c)
            : null;
        this.maximumBusinessScore = br.BusinessCriteria_Maximum_Score__c != null
            ? String.ValueOf(br.BusinessCriteria_Maximum_Score__c)
            : null;
        //end
    }

    public static Business_Rules__c convertWrapperToObject(BusinessRulesWrapperClass brWrapper) {
        Business_Rules__c br = new Business_Rules__c();
        br.BS_Req_for_certain_Rev_Range__c = brWrapper.bsRange;
        br.Is_a_Blue_Sheet_required__c = brWrapper.bsReq;
        if (brWrapper.isActive != null && brWrapper.isActive != '') {
            br.IsActive__c = Boolean.valueOf(brWrapper.isActive);
        }

        if (brWrapper.triggerOnBluesheetRequired != null && brWrapper.triggerOnBluesheetRequired != '') {
            br.trigger_bluesheet_required__c = Boolean.valueOf(brWrapper.triggerOnBluesheetRequired);
        }

        br.is_closed_date_past__c = (brWrapper.isClosedDatePast == null) ? false : brWrapper.isClosedDatePast;
        br.is_past_action_due__c = (brWrapper.isPastActionDue == null) ? false : brWrapper.isPastActionDue;
        br.is_curr_pos_negative__c = (brWrapper.isCurrPosNegative == null) ? false : brWrapper.isCurrPosNegative;
        br.is_competitor_identified__c = (brWrapper.isCompetitorIdentified == null)
            ? false
            : brWrapper.isCompetitorIdentified;
        br.is_pos_competition_zero__c = (brWrapper.isPosCompetitionZero == null)
            ? false
            : brWrapper.isPosCompetitionZero;
        br.is_cust_time_later__c = (brWrapper.isCustTimeLater == null) ? false : brWrapper.isCustTimeLater;
        br.is_person_win_identified__c = (brWrapper.isPersonWinIdentified == null)
            ? false
            : brWrapper.isPersonWinIdentified;
        br.is_business_result_identified__c = (brWrapper.isBusinessResultIdentified == null)
            ? false
            : brWrapper.isBusinessResultIdentified;
        br.is_negative_rating__c = (brWrapper.isNegativeRating == null) ? false : brWrapper.isNegativeRating;
        br.is_high_rated_BI_no_coach__c = (brWrapper.isHighRatedBINoCoach == null)
            ? false
            : brWrapper.isHighRatedBINoCoach;
        br.is_coach_with_low_BI__c = (brWrapper.isCoachWithLowBI == null) ? false : brWrapper.isCoachWithLowBI;
        br.is_discon_mode_cust_timing__c = (brWrapper.isDisconModeCustTiming == null)
            ? false
            : brWrapper.isDisconModeCustTiming;
        br.Business_Rule_Name__c = brWrapper.brName;
        /*if (brWrapper.opAmt != null && brWrapper.opAmt != '') {
            br.Opty_Amount_2__c = Decimal.ValueOf(brWrapper.opAmt);
        }*/
        if (brWrapper.maxDaysBs != null && brWrapper.maxDaysBs != '') {
            br.Max_Days_Allowed_Since_Last_BS_Update__c = Decimal.ValueOf(brWrapper.maxDaysBs);
        } else {
            br.Max_Days_Allowed_Since_Last_BS_Update__c = null;
        }
        if (brWrapper.maxDaysOp != null && brWrapper.maxDaysOp != '') {
            br.Max_Days_Allowed_in_a_Opty_Stage__c = Decimal.ValueOf(brWrapper.maxDaysOp);
        } else {
            br.Max_Days_Allowed_in_a_Opty_Stage__c = null;
        }
        if (brWrapper.minActions != null && brWrapper.minActions != '') {
            br.Min_Number_of_Actions_For_a_Opty_Stage__c = Decimal.ValueOf(brWrapper.minActions);
        } else {
            br.Min_Number_of_Actions_For_a_Opty_Stage__c = null;
        }
        br.Scorecard_Required__c = brWrapper.scrCrd;
        br.Buying_Influence_Role__c = brWrapper.buyRole;
        br.Business_Rules_Group__c = brWrapper.brGroup;
        String objName = ApexCommonUtil.getObjectwithNameSpace('Business_Rules__c');
        Id recTypeId = Schema.getGlobalDescribe()
            .get(objName)
            .getDescribe()
            .getRecordTypeInfosByName()
            .get('Default')
            .getRecordTypeId();
        br.recordTypeId = recTypeId;
        //KFS-863 additional logic
        br.Opportunity_Currency_Fields__c = brWrapper.optyCurrencyField;
        if (brWrapper.amtMinRange != null && brWrapper.amtMinRange != '') {
            br.Minimum_Range__c = Decimal.ValueOf(brWrapper.amtMinRange);
        } else {
            br.Minimum_Range__c = null;
        }
        if (brWrapper.amtMaxRange != null && brWrapper.amtMaxRange != '') {
            br.Maximum_Range__c = Decimal.ValueOf(brWrapper.amtMaxRange);
        } else {
            br.Maximum_Range__c = null;
        }
        br.Business_Rule_Catagory__c = brWrapper.brCategory;
        br.Opportunity_Stage_Global__c = brWrapper.globalOptyStage;
        if (brWrapper.minNumberOfBIContact != null && brWrapper.minNumberOfBIContact != '') {
            br.Min_Number_Buying_Influence_Contacts__c = Decimal.ValueOf(brWrapper.minNumberOfBIContact);
        } else {
            br.Min_Number_Buying_Influence_Contacts__c = null;
        }
        br.Check_Scorecard_Last_Modified__c = (brWrapper.lastModifiedCheck == null)
            ? false
            : brWrapper.lastModifiedCheck;
        if (brWrapper.maxDaysScorecardUpdated != null && brWrapper.maxDaysScorecardUpdated != '') {
            br.Scorecard_Number_of_Days_Updated__c = Decimal.ValueOf(brWrapper.maxDaysScorecardUpdated);
        }
        br.Check_Total_Score__c = (brWrapper.totalScoreCheck == null) ? false : brWrapper.totalScoreCheck;
        if (brWrapper.minimumTotalScore != null && brWrapper.minimumTotalScore != '') {
            br.Minimum_Score__c = Decimal.ValueOf(brWrapper.minimumTotalScore);
        } else {
            br.Minimum_Score__c = null;
        }
        if (brWrapper.maximumTotalScore != null && brWrapper.maximumTotalScore != '') {
            br.Maximum_Score__c = Decimal.ValueOf(brWrapper.maximumTotalScore);
        } else {
            br.Maximum_Score__c = null;
        }
        br.Check_Opportunity_Score__c = (brWrapper.optyCriteriaScoreCheck == null)
            ? false
            : brWrapper.optyCriteriaScoreCheck;
        if (brWrapper.minimumOptyScore != null && brWrapper.minimumOptyScore != '') {
            br.OpportunityCriteria_Minimum_Score__c = Decimal.ValueOf(brWrapper.minimumOptyScore);
        } else {
            br.OpportunityCriteria_Minimum_Score__c = null;
        }
        if (brWrapper.maximumOptyScore != null && brWrapper.maximumOptyScore != '') {
            br.OpportunityCriteria_Maximum_Score__c = Decimal.ValueOf(brWrapper.maximumOptyScore);
        } else {
            br.OpportunityCriteria_Maximum_Score__c = null;
        }
        br.Check_Business_Criteria_Score__c = (brWrapper.busCriteriaScoreCheck == null)
            ? false
            : brWrapper.busCriteriaScoreCheck;
        if (brWrapper.minimumBusinessScore != null && brWrapper.minimumBusinessScore != '') {
            br.BusinessCriteria_Minimum_Score__c = Decimal.ValueOf(brWrapper.minimumBusinessScore);
        } else {
            br.BusinessCriteria_Minimum_Score__c = null;
        }
        if (brWrapper.maximumBusinessScore != null && brWrapper.maximumBusinessScore != '') {
            br.BusinessCriteria_Maximum_Score__c = Decimal.ValueOf(brWrapper.maximumBusinessScore);
        } else {
            br.BusinessCriteria_Maximum_Score__c = null;
        }
        return br;
    }
}