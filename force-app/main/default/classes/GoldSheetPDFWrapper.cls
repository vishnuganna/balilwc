@SuppressWarnings('PMD.ExcessivePublicCount')
public with sharing class GoldSheetPDFWrapper {
    public List<StrategicPlayerWrapper> strategicPlayers { get; set; }
    public List<FieldOfPlayTrendWrapperClass> fopTrends { get; set; }
    public List<FieldOfPlayOppController.PlayOppWrapper> fopOpportunities { get; set; }
    public List<StrategicStrengthWrapper> strategicStrengths { get; set; }
    public CriticalVulnerabilityWrapper criticalVulnerability { get; set; }
    public GoldSheetAndAccountDataWrapperClass goldSheetAccountInfo { get; set; }
    public BuySellHierarchyWrapper buySellHierarchyData { get; set; }
    public List<FocusInvestmentWrapper> focusInvestments { get; set; }
    public List<StopInvestmentWrapper> stopInvestments { get; set; }
    public CharterStatementWrapper charterStatement { get; set; }
    public List<RelationshipGoalsWrapper> relationshipGoals { get; set; }
    public List<ActionPlanActivitiesActionsWrapper> actionsList { get; set; }
    public List<InformationNeededWrapper> informationNeededList { get; set; }
    public List<InvestmentProgramControllerWrapper> investmentProgramList { get; set; }
    public Map<String, List<MilestoneWrapper>> milestoneWrapperList { get; set; }
    public RevenueTargetWrapper revenueTargets { get; set; }
    public List<GoldSheetSSOWrapper> goldSheetSSOData { get; set; }
    public Decimal expectedRevenueTotal { get; set; }
}