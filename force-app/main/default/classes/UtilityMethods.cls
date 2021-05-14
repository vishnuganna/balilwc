/* Apex class for common reusable methods*/

public with sharing class UtilityMethods {
    public static String objectName(List<Id> objectIds) {
        String objectApiName = '';

        for (Id obId : objectIds) {
            String objId = (String) obId;
            String keyCode = objId.subString(0, 3);
            Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
            for (Schema.SObjectType objectInstance : gd.values()) {
                if (objectInstance.getDescribe().getKeyPrefix() == keyCode) {
                    objectApiName = objectInstance.getDescribe().getName();
                    //return objectApiName;
                }
            }
        }
        return objectApiName;
    }
}