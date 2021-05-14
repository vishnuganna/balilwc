public with sharing class GreenSheetSSOandCompanyPDF {
    public String greenSheetComponentsPDFData { get; set; }
    public static GreenSheetPDFWrapper greenSheetPDFWrapper { get; set; }

    public GreenSheetSSOandCompanyPDF() {
        String recordId = System.currentPageReference().getParameters().get('id');
        greenSheetPDFWrapper = new GreenSheetPDFWrapper();
        if (recordId != null) {
            greenSheetPDFWrapper.opportunitySSO = getSSOGreenSheet(recordId);
            greenSheetPDFWrapper.ourCompanyAttendee = getCompanyAttendeeInfo(recordId);
            greenSheetComponentsPDFData = JSON.serialize(greenSheetPDFWrapper);
        }
    }

    /*Method to get SSO records*/
    @AuraEnabled
    public static List<OpportunitySSOWrapper> getSSOGreenSheet(String greenSheetId) {
        List<Green_Sheet__c> greenSheetList = new List<Green_Sheet__c>();
        List<Opportunity> oppList = new List<Opportunity>();
        List<Single_Sales_Objective__c> greenSheetSSOList = new List<Single_Sales_Objective__c>();
        List<OpportunitySSOWrapper> greenSheetOppSSOWrapperList = new List<OpportunitySSOWrapper>();
        String blueSheetId;
        String relatedToId;
        String oppId;

        try {
            String greenSheetQuery = 'SELECT Id,Name,Task_Id__c,Related_To_Id__c FROM Green_Sheet__c WHERE Id =:greenSheetId';
            Map<String, Object> gsParams = new Map<String, Object>();
            gsParams.put('greenSheetId', greenSheetId);
            greenSheetList = DataFactory.read(greenSheetQuery, gsParams);
            relatedToId = greenSheetList[0].Related_To_Id__c;

            //check if greensheet is related to an opportunity
            if (relatedToId != null && relatedToId != '') {
                String relatedToIdSubstring = relatedToId.substring(0, 3);
                if (relatedToIdSubstring.equals('006')) {
                    oppId = relatedToId;
                    String oppQuery = 'SELECT Id,Name,Amount,Probability,StageName,CloseDate,Blue_Sheet__c FROM Opportunity WHERE Id =:oppId';
                    Map<String, Object> oppParams = new Map<String, Object>();
                    oppParams.put('oppId', oppId);
                    oppList = DataFactory.read(oppQuery, oppParams);
                }
            }

            //fetch related opportunity and SSO information
            if (!oppList.isEmpty()) {
                blueSheetId = oppList[0].Blue_Sheet__c;

                if (blueSheetId != null && blueSheetId != '') {
                    String ssoQuery = 'SELECT Id,Name,Blue_Sheet__c,Blue_Sheet__r.Opportunity__c,Customers_Stated_Objectives__c,Customer_Timing_for_Priorities__c,Evaluation_of_Objectives__c FROM Single_Sales_Objective__c WHERE Blue_Sheet__c =:blueSheetId';
                    Map<String, Object> paramters = new Map<String, Object>();
                    paramters.put('blueSheetId', blueSheetId);
                    greenSheetSSOList = DataFactory.read(ssoQuery, paramters);
                }

                for (Opportunity opp : oppList) {
                    OpportunitySSOWrapper oppSSOWrapper = new OpportunitySSOWrapper(opp);
                    if (!greenSheetSSOList.isEmpty()) {
                        OpportunitySSOWrapper.GreenSheetSSOWrapper ssoWrapper = new OpportunitySSOWrapper.GreenSheetSSOWrapper(
                            greenSheetSSOList[0]
                        );
                        oppSSOWrapper.gsSSOWrapper = ssoWrapper;
                    }
                    greenSheetOppSSOWrapperList.add(oppSSOWrapper);
                }
            }
            //System.debug('greenSheetOppSSOWrapperList>>>' + greenSheetOppSSOWrapperList);
        } catch (Exception ex) {
            //System.debug('exception ----' + ex);
            // System.debug('exception line----' + ex.getLineNumber());
            throw new GreenSheetSSOException('Error occured while getting data from Green Sheet SSO');
        }
        return greenSheetOppSSOWrapperList;
    }

    /*Method to get Our Company Attendees records*/
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
            //System.debug('ocaWrapperListToReturn>>>' + ocaWrapperListToReturn);
        } catch (Exception ex) {
            //System.debug('exception ----' + ex);
            //System.debug('exception line----' + ex.getLineNumber());
            throw new CompanyAttendeesException('Error occured while getting data from Green Sheet Company Attendees');
        }
        return ocaWrapperListToReturn;
    }

    private class GreenSheetSSOException extends Exception {
    }

    private class CompanyAttendeesException extends Exception {
    }
}