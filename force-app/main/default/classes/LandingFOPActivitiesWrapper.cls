public with sharing class LandingFOPActivitiesWrapper {
    @AuraEnabled
    public String fopName;
    @AuraEnabled
    public Id fopId;
    @AuraEnabled
    public String accName;
    @AuraEnabled
    public String activityTitle;
    @AuraEnabled
    public String accOwnerName;
    @AuraEnabled
    public String activityDueDate;
    @AuraEnabled
    public String objName;
    @AuraEnabled
    public String dateField;

    //its required, dont delete it
    @SuppressWarnings('PMD.EmptyStatementBlock')
    public LandingFOPActivitiesWrapper() {
    }

    public LandingFOPActivitiesWrapper(KF_Sell_Best__c bestAct) {
        this.fopName = bestAct.Fields_of_Play_Gold_Sheet__r.FOP_Name__c;
        this.fopId = bestAct.Fields_of_Play_Gold_Sheet__c;
        this.activityTitle = bestAct.Activity_Title__c;
        this.accOwnerName = bestAct.Fields_of_Play_Gold_Sheet__r.Owner.Name;
        this.activityDueDate = String.valueOf(bestAct.Activity_Due_Date__c);
        this.objName = bestAct.Associated_Object__c;
    }

    /*  public LandingFOPActivitiesWrapper(Information_Needed__c infoNeeded) {
        this.fopName = infoNeeded.Fields_of_Play_Gold_Sheet__r.FOP_Name__c;
        this.activityId = infoNeeded.Id;
        this.accName = infoNeeded.Fields_of_Play_Gold_Sheet__r.Account__r.Name;
        this.accOwnerFirstName = infoNeeded.Fields_of_Play_Gold_Sheet__r.Account__r.Owner.FirstName;
        this.accOwnerLastName = infoNeeded.Fields_of_Play_Gold_Sheet__r.Account__r.Owner.LastName;
        this.activityDueDate = String.valueOf(infoNeeded.Due_Date__c);
        this.activityTitle = infoNeeded.Information_Needed_Title__c + ' - Information Needed';
    }

    public LandingFOPActivitiesWrapper(Action__c actions) {
        this.fopName = actions.Fields_of_Play_Gold_Sheet__r.FOP_Name__c;
        this.activityId = actions.Id;
        this.accName = actions.Fields_of_Play_Gold_Sheet__r.Account__r.Name;
        this.accOwnerFirstName = actions.Fields_of_Play_Gold_Sheet__r.Account__r.Owner.FirstName;
        this.accOwnerLastName = actions.Fields_of_Play_Gold_Sheet__r.Account__r.Owner.LastName;
        this.activityDueDate = String.valueOf(actions.Due_Date__c);
        this.activityTitle = actions.Action_Title__c + ' - Actions';
    }

    public LandingFOPActivitiesWrapper(Investment_Program__c invProgs) {
        this.fopName = invProgs.Fields_of_Play_Gold_Sheet__r.FOP_Name__c;
        this.activityId = invProgs.Id;
        this.accName = invProgs.Fields_of_Play_Gold_Sheet__r.Account__r.Name;
        this.accOwnerFirstName = invProgs.Fields_of_Play_Gold_Sheet__r.Account__r.Owner.FirstName;
        this.accOwnerLastName = invProgs.Fields_of_Play_Gold_Sheet__r.Account__r.Owner.LastName;
        this.activityDueDate = String.valueOf(invProgs.Due_Date__c);
        this.activityTitle = invProgs.Investment_Program_Title__c + ' - Investment Program';
    }*/
}