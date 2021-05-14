public with sharing class BlueSheetProgressWrapper {
    @AuraEnabled
    public String id;
    @AuraEnabled
    public String name;
    @AuraEnabled
    public String actionPlanProgress;
    @AuraEnabled
    public String buyingInfluenceProgress;
    @AuraEnabled
    public String competitionProgress;
    @AuraEnabled
    public String currentPositionProgress;
    @AuraEnabled
    public String scoreCardProgress;
    @AuraEnabled
    public String singleSalesObjectiveProgress;
    @AuraEnabled
    public String summaryOfMyPositionProgress;

    public BlueSheetProgressWrapper(Blue_Sheet__c bs) {
        this.Id = bs.Id;
        this.name = bs.Name;
        this.actionPlanProgress = bs.Action_Plan_Progress__c;
        this.buyingInfluenceProgress = bs.Buying_Influence_Progress__c;
        this.competitionProgress = bs.Competition_Progress__c;
        this.currentPositionProgress = bs.Current_Position_Progress__c;
        this.scoreCardProgress = bs.Scorecard_Progress__c;
        this.singleSalesObjectiveProgress = bs.SSO_Progress__c;
        this.summaryOfMyPositionProgress = bs.Summary_Position_Progress__c;
    }
}