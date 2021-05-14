//KFS-64 : Wrapper class to hold the data from Blue Sheet object fields
public with sharing class BlueSheetWrapperClass {
    @AuraEnabled
    public String id;
    @AuraEnabled
    public String name;

    public BlueSheetWrapperClass(Blue_Sheet__c bs) {
        this.Id = bs.Id;
        this.name = bs.Name;
    }
}