//KFS-8 : created wrapper to hold the data from object veriables
public class RelationshipGoalsWrapper {
    @AuraEnabled
    public String Id { get; set; }
    @AuraEnabled
    public String name { get; set; }
    @AuraEnabled
    public String goalStatus { get; set; }
    @AuraEnabled
    public String goldsheetId { get; set; }
    @AuraEnabled
    public String description { get; set; }
    @AuraEnabled
    public String goalName { get; set; }
    @AuraEnabled
    public String accountId { get; set; }
    @AuraEnabled
    public Map<String, RedFlagStrengthMarkerWrapper> rfsMarkerPdfWrapper { get; set; }
    @AuraEnabled
    public List<RelatedActivitiesWrapper> relatedActivitiesWrapper { get; set; }

    @SuppressWarnings('PMD.EmptyStatementBlock')
    public RelationshipGoalsWrapper() {
    }

    //parameter constructor that excepts the data from object and assign it to wrapper
    public RelationshipGoalsWrapper(Relationship_Goal__c relationshipGoal, boolean hasEditAccess) {
        this.Id = relationshipGoal.Id;
        this.name = relationshipGoal.Name;
        this.goalStatus = relationshipGoal.Goal_Status__c;
        this.goldsheetId = relationshipGoal.Fields_of_Play_Gold_Sheet__c;
        this.description = relationshipGoal.Description__c;
        this.goalName = relationshipGoal.Goal_Name__c;
    }
}