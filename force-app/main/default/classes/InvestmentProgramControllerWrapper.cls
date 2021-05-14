@SuppressWarnings('PMD.TooManyFields, PMD.ExcessivePublicCount')
public with sharing class InvestmentProgramControllerWrapper {
    @AuraEnabled
    public String id { get; set; }
    @AuraEnabled
    public String gsActionName { get; set; }
    @AuraEnabled
    public String gsActionAssignedToName { get; set; }
    @AuraEnabled
    public String gsInvProgramTitle { get; set; }
    @AuraEnabled
    public String gsInvProgramDescription { get; set; }
    @AuraEnabled
    public String gsInvProgramStatus { get; set; }
    @AuraEnabled
    public Date gsInvProgramDueDate { get; set; }
    @AuraEnabled
    public String gsInvProgramDueDateString { get; set; }
    @AuraEnabled
    public String goldSheet { get; set; }
    @AuraEnabled
    public String gsInvProgramAssignedTo { get; set; }
    @AuraEnabled
    public String accountId { get; set; }
    @AuraEnabled
    public boolean hasEditAccess { get; set; }
    @AuraEnabled
    public String cssClassforReadOnlyUsers { get; set; }

    public InvestmentProgramControllerWrapper(Investment_Program__c investmentProgram, boolean hasEditAccess) {
        this.id = investmentProgram.Id;
        this.gsActionName = investmentProgram.Name;
        this.gsInvProgramTitle = investmentProgram.Investment_Program_Title__c;
        this.gsInvProgramDescription = investmentProgram.Description__c;
        this.gsInvProgramStatus = investmentProgram.Status__c;
        this.gsInvProgramDueDate = investmentProgram.Due_Date__c;
        Date dt = (Date) investmentProgram.Due_Date__c;
        if (dt != null) {
            this.gsInvProgramDueDateString = DateTime.newInstance(dt.year(), dt.month(), dt.day()).format('MM/dd/YYYY');
        }
        this.gsInvProgramAssignedTo = investmentProgram.Assigned_To__c;
        this.gsActionAssignedToName = investmentProgram.Assigned_To__r.Name;
        this.goldSheet = investmentProgram.Fields_of_Play_Gold_Sheet__c;
        this.hasEditAccess = hasEditAccess;
        if (!this.hasEditAccess) {
            this.cssClassforReadOnlyUsers = 'slds-hide';
        }
    }
}