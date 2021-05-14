//KFS-8 : created wrapper to hold the data from object veriables
@SuppressWarnings('PMD.TooManyFields,PMD.ExcessivePublicCount')
public with sharing class ActionPlanWrapperClass {
    @AuraEnabled
    public String Id { get; set; }
    @AuraEnabled
    public String name { get; set; }
    @AuraEnabled
    public String actionType { get; set; }
    @AuraEnabled
    public String assignedTo { get; set; }
    @AuraEnabled
    public String blueSheet { get; set; }
    @AuraEnabled
    public String contact { get; set; }
    @AuraEnabled
    public String contactName { get; set; }
    @AuraEnabled
    public String assignedToName { get; set; }
    @AuraEnabled
    public String description { get; set; }
    @AuraEnabled
    public Date dueDate { get; set; }
    //@AuraEnabled public Boolean isBestAction{ get; set; }
    @AuraEnabled
    public Boolean bestAction { get; set; } //146
    @AuraEnabled
    public Boolean providingPerspective { get; set; } //255
    @AuraEnabled
    public String howWillYouProvidePerspective { get; set; } //255
    @AuraEnabled
    public String priority { get; set; }
    @AuraEnabled
    public Date startDate { get; set; }
    @AuraEnabled
    public String status { get; set; }
    @AuraEnabled
    public String summary { get; set; }
    @AuraEnabled
    public String user { get; set; }
    @AuraEnabled
    public boolean isShowFlag { get; set; }
    //@auraEnabled public String userName;

    //parameter constructor that excepts the data from object and assign it to wrapper
    public ActionPlanWrapperClass(Action_Plan__c actionPlan, boolean hasEditAccess) {
        this.Id = actionPlan.Id;
        this.name = actionPlan.Name;
        this.actionType = actionPlan.Action_Type__c;
        this.assignedTo = actionPlan.AssignedTo__c;
        this.assignedToName = actionPlan.AssignedTo__r.Name;
        this.blueSheet = actionPlan.Blue_Sheet__c;
        this.contact = actionPlan.Contact__c;
        this.contactName = actionPlan.Contact__r.Name;
        this.description = actionPlan.Description__c;
        this.dueDate = actionPlan.Due_Date__c;
        //this.isBestAction= actionPlan.Is_a_Best_Action__c;
        this.bestAction = actionPlan.Is_a_Best_Action__c; //146
        this.providingPerspective = actionPlan.IsProvidingPerspective__c; //255
        this.howWillYouProvidePerspective = actionPlan.ProvidingPerspectiveDescription__c; //255
        this.priority = actionPlan.Priority__c;
        this.startDate = actionPlan.Start_Date__c;
        this.status = actionPlan.Status__c;
        this.summary = actionPlan.Summary__c;
        this.user = actionPlan.User__c;
        this.isShowFlag = true;
        //this.userName = actionPlan.User__r.Name;
    }
}