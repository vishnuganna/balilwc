public with sharing class CurrentPositionWrapper {
    @AuraEnabled
    public String id;
    //  @AuraEnabled public String name;
    @AuraEnabled
    public String position;
    @AuraEnabled
    public String bluesheet;

    public CurrentPositionWrapper(Current_Position__c cp) {
        this.Id = cp.Id;
        //this.name = cp.Name;
        this.position = cp.Current_Position__c;
        this.bluesheet = cp.Blue_Sheet__c;
    }

    public static Current_Position__c convertWrapperToObject(CurrentPositionWrapper cpWrapper) {
        Current_Position__c cp = new Current_Position__c();
        cp.Blue_Sheet__c = cpWrapper.bluesheet;
        cp.Current_Position__c = cpWrapper.position;
        return cp;
    }
}