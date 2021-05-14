public with sharing class BlueSheetPDFWrapper {
    public SingleSalesObjectiveController.SingleSalesObjectiveWrapper singleSalesObjectives { get; set; }
    public string currentPostion { get; set; }
    public scoreCardOpptyWrapper scoreCard { get; set; }
    public List<CompetitionWrapperClass> competitions { get; set; }
    public List<BuyingInfluenceWrapperClass> buyingInfluences { get; set; }
    public BlueSheetPDFController.PositionSummaryPdfWrapper positionSummarys { get; set; }
    public List<ActionPlanWrapperClass> actionPlans { get; set; }
    public BlueSheetAndOpportunityDataWrapperClass blueSheet { get; set; }
    public SingleSalesObjectiveBSWrapper singleSalesObjective { get; set; }
}