public with sharing class RedFlagStrengthMarkerWrapper {
    @AuraEnabled
    public Id parentId { get; set; }
    @AuraEnabled
    public String id { get; set; }
    @AuraEnabled
    public String name { get; set; }
    @AuraEnabled
    public String fieldApiName { get; set; }
    @AuraEnabled
    public Boolean redFlagSelected { get; set; }
    @AuraEnabled
    public Boolean strengthSelected { get; set; }
    @AuraEnabled
    public String objectApiName { get; set; }
    @AuraEnabled
    public String sourceId { get; set; }

    public RedFlagStrengthMarkerWrapper(Red_Flag_Strength_Marker__c rfs) {
        this.Id = rfs.Id;
        this.name = rfs.Name;
        this.parentId = rfs.Parent_Id__c;
        this.fieldApiName = rfs.Field_API_Name__c;
        this.redFlagSelected = rfs.Is_Red_Flag_Selected__c;
        this.strengthSelected = rfs.Is_Strength_Selected__c;
        this.objectApiName = rfs.Object_API_Name__c;
        this.sourceId = rfs.Source_ID__c;
    }
}