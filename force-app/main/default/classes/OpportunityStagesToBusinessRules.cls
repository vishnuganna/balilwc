public with sharing class OpportunityStagesToBusinessRules {
    public static List<String> getOpptyStageValues() {
        List<String> opptyStageValues = new List<String>();
        Schema.DescribeFieldResult fieldResult = Opportunity.StageName.getDescribe();
        List<Schema.PicklistEntry> stagePickListValues = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry pickListVal : stagePickListValues) {
            opptyStageValues.add(pickListVal.getLabel());
        }
        return opptyStageValues;
    }
    public void createOpportunityStage() {
        List<String> opptyStagePickListValues = getOpptyStageValues();
        List<OpportunityStage__c> insertLstOpptyStage = new List<OpportunityStage__c>();
        List<OpportunityStage__c> deleteLstOpptyStage = new List<OpportunityStage__c>();

        //Query Custom Object Opportunity Stage

        String opptyStageQuery = 'Select Id,Name FROM OpportunityStage__c';
        Map<String, Object> paramters = new Map<String, Object>();
        List<OpportunityStage__c> listOpptyStage = DataFactory.read(opptyStageQuery, paramters);
        List<String> listOpptyStageNames = new List<String>();

        //Loop Through Opportunity Stage Custom Object and Compare with opptyStagePickListValues to delete values
        for (OpportunityStage__c listStage : listOpptyStage) {
            listOpptyStageNames.add(listStage.Name);
            if (!opptyStagePickListValues.contains(listStage.Name)) {
                deleteLstOpptyStage.add(listStage);
            }
        }
        //Loop through opptyStagePickListValues and compare with Opportunity Stage Custom Object to add values
        for (String stagePickListVal : opptyStagePickListValues) {
            if (!listOpptyStageNames.contains(stagePickListVal)) {
                OpportunityStage__c opptyStage = new OpportunityStage__c();
                opptyStage.Name = stagePickListVal;
                insertLstOpptyStage.add(opptyStage);
            }
        }

        if (!insertLstOpptyStage.isEmpty()) {
            DataFactory.create(insertLstOpptyStage);
        }
        if (!deleteLstOpptyStage.isEmpty()) {
            DataFactory.remove(deleteLstOpptyStage);
        }
    }
}