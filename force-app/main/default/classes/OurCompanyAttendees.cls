public with sharing class OurCompanyAttendees {
    public class WrapperLookupObject {
        @AuraEnabled
        public String lookupOnObject;
        @AuraEnabled
        public String targetField;
    }

    /* get required objects fro lookup component */
    @AuraEnabled
    public static WrapperLookupObject getLookupObjects() {
        WrapperLookupObject wrapper = new WrapperLookupObject();
        String apiName = 'Company_Attendee__c';
        wrapper.lookupOnObject = ApexCommonUtil.getObjectwithNameSpace(apiName);
        apiName = 'Name__c';
        wrapper.targetField = ApexCommonUtil.getObjectwithNameSpace(apiName);
        return wrapper;
    }

    @AuraEnabled
    public static List<OurCompanyAttendeeWrapper> getCompanyAttendeeInfo(String greenSheetId) {
        Boolean isUpdatable = false;
        List<Company_Attendee__c> listOCA = new List<Company_Attendee__c>();
        List<OurCompanyAttendeeWrapper> ocaWrapperListToReturn = new List<OurCompanyAttendeeWrapper>();
        if (Schema.sObjectType.Company_Attendee__c.isUpdateable()) {
            isUpdatable = true;
        }
        try {
            String ocaQuery = 'Select Id,Name,Name__c,Name__r.Name,Name__r.Title,Green_Sheet__c FROM Company_Attendee__c WHERE Green_Sheet__c=:greenSheetId ORDER BY createddate DESC';
            Map<String, Object> paramters = new Map<String, Object>();
            paramters.put('greenSheetId', greenSheetId);

            listOCA = DataFactory.read(ocaQuery, paramters);

            for (Company_Attendee__c oca : listOCA) {
                OurCompanyAttendeeWrapper wrapper = new OurCompanyAttendeeWrapper(oca, isUpdatable);
                ocaWrapperListToReturn.add(wrapper);
            }
        } catch (Exception ex) {
            System.debug('exception ----' + ex);
        }
        return ocaWrapperListToReturn;
    }
    @AuraEnabled
    public static Map<String, Boolean> getCompanyAccess() {
        Map<String, Boolean> accessMap = new Map<String, Boolean>();
        String objName = 'Company_Attendee__c';
        accessMap = ApexCommonUtil.getObjectAccess(objName);
        return accessMap;
    }
    @AuraEnabled
    public static void removeCompanyAttendee(String companyId) {
        try {
            String objName = 'Company_Attendee__c';
            ApexCommonUtil.deleteRecord(companyId, objName);
        } catch (Exception ex) {
            throw new OurCompanyAttendeesException('Error occured while deleting data from Company Attendee');
        }
    }
    @AuraEnabled
    public static void saveCompanyAttendee(String userId, String greenSheetId) {
        if (greenSheetId != null && userId != null) {
            List<Company_Attendee__c> listOCA = new List<Company_Attendee__c>();
            String ocaQuery = 'Select Name__c FROM Company_Attendee__c WHERE Green_Sheet__c=:greenSheetId  and Name__c=:userId';
            Map<String, Object> paramters = new Map<String, Object>();
            paramters.put('greenSheetId', greenSheetId);
            paramters.put('userId', userId);

            listOCA = DataFactory.read(ocaQuery, paramters);

            if (listOCA.isEmpty()) {
                List<Company_Attendee__c> listCompanyAttendeeInsert = new List<Company_Attendee__c>();
                Company_Attendee__c comp = new Company_Attendee__c();
                comp.Name__c = userId;
                comp.Green_Sheet__c = greenSheetId;
                listCompanyAttendeeInsert.add(comp);
                if (!listCompanyAttendeeInsert.isEmpty()) {
                    DataFactory.create(listCompanyAttendeeInsert);
                }
            } else {
                throw new OurCompanyAttendeesException('Company attendee already exists');
            }
        }
    }
    private class OurCompanyAttendeesException extends Exception {
    }
}