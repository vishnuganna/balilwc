@SuppressWarnings('PMD.TooManyFields, PMD.ExcessivePublicCount, PMD.NcssMethodCount, PMD.NcssConstructorCount')
public with sharing class BusinessRulesGreenSheetWrapperClass {
    @AuraEnabled
    public String id;
    @AuraEnabled
    public String name;
    @AuraEnabled
    public String isActive;
    @AuraEnabled
    public String brName;
    @AuraEnabled
    public String brGroupName;
    @AuraEnabled
    public String brGroup;
    @AuraEnabled
    public String recordType;
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
    public boolean isMinActCommitAdded;
    @AuraEnabled
    public boolean isBestActCommitAdded;
    @AuraEnabled
    public boolean isVBRAdded;
    @AuraEnabled
    public boolean isConceptForBIAdded;
    @AuraEnabled
    public Decimal numDaysBeforeMeeting;
    @AuraEnabled
    public AlertRecommendationsWrapper customRecommendationAction;

    public BusinessRulesGreenSheetWrapperClass(Business_Rules__c br) {
        this.Id = br.Id;
        this.name = br.Name;
        this.isActive = String.ValueOf(br.IsActive__c);
        this.brName = br.Business_Rule_Name__c;
        String objName = ApexCommonUtil.getObjectwithNameSpace('Business_Rules__c');
        Id recTypeId = Schema.getGlobalDescribe()
            .get(objName)
            .getDescribe()
            .getRecordTypeInfosByName()
            .get('Default')
            .getRecordTypeId();
        this.recordType = String.ValueOf(recTypeId);
        this.brGroupName = br.Business_Rules_Group__r.Name;
        this.createdBy = br.createdBy.Name;
        this.createdDate = String.ValueOf(br.createdDate);
        this.createdById = br.createdById;
        this.lastModifiedBY = br.lastModifiedBy.Name;
        this.lastModifiedDate = String.ValueOf(br.lastModifiedDate);
        this.lastModifiedById = br.LastModifiedById;
        this.brGroup = br.Business_Rules_Group__c;
        this.optyCurrencyField = br.Opportunity_Currency_Fields__c;
        this.amtMinRange = String.ValueOf(br.Minimum_Range__c);
        this.amtMaxRange = String.ValueOf(br.Maximum_Range__c);
        this.brCategory = br.Business_Rule_Catagory__c;
        this.globalOptyStage = br.Opportunity_Stage_Global__c;
        this.brOwner = br.OwnerId;
        this.brOwnerName = br.Owner.Name;
        this.isBestActCommitAdded = br.Is_Best_Action_Commitment_Added__c;
        this.isMinActCommitAdded = br.Is_Minimum_Action_Commitment_Added__c;
        this.isConceptForBIAdded = br.Is_Concept_for_BI_Added__c;
        this.isVBRAdded = br.Is_Valid_Business_Reason_Added__c;
        this.numDaysBeforeMeeting = br.Number_of_Days_Before_Meeting__c;
    }
    public static Business_Rules__c convertWrapperToObject(BusinessRulesGreenSheetWrapperClass brWrapper) {
        Business_Rules__c br = new Business_Rules__c();
        if (brWrapper.isActive != null && brWrapper.isActive != '') {
            br.IsActive__c = Boolean.valueOf(brWrapper.isActive);
        }
        br.Business_Rule_Name__c = brWrapper.brName;
        br.Opportunity_Currency_Fields__c = brWrapper.optyCurrencyField;
        if (brWrapper.amtMinRange != null && brWrapper.amtMinRange != '') {
            br.Minimum_Range__c = Decimal.ValueOf(brWrapper.amtMinRange);
        }
        if (brWrapper.amtMaxRange != null && brWrapper.amtMaxRange != '') {
            br.Maximum_Range__c = Decimal.ValueOf(brWrapper.amtMaxRange);
        }
        br.Business_Rules_Group__c = brWrapper.brGroup;
        br.Business_Rule_Catagory__c = brWrapper.brCategory;
        br.Opportunity_Stage_Global__c = brWrapper.globalOptyStage;
        br.Is_Minimum_Action_Commitment_Added__c = brWrapper.isMinActCommitAdded;
        br.Is_Concept_for_BI_Added__c = brWrapper.isConceptForBIAdded;
        br.Is_Valid_Business_Reason_Added__c = brWrapper.isVBRAdded;
        br.Is_Best_Action_Commitment_Added__c = brWrapper.isBestActCommitAdded;
        br.Number_of_Days_Before_Meeting__c = brWrapper.numDaysBeforeMeeting;
        return br;
    }
}