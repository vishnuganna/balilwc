public with sharing class GoldSheetRevenueTabPDFController {
    public String goldSheetRevenuePDFData { get; set; }
    public static GoldSheetPDFWrapper goldSheetRevenuePDFWrapper { get; set; }

    public GoldSheetRevenueTabPDFController() {
        String recordId = System.currentPageReference().getParameters().get('id');
        goldSheetRevenuePDFWrapper = new GoldSheetPDFWrapper();
        if (recordId != null) {
            goldSheetRevenuePDFWrapper.revenueTargets = getRevenueTargetData(recordId);
            goldSheetRevenuePDFWrapper.goldSheetSSOData = getGoldSheetSSOData(recordId);
            goldSheetRevenuePDFWrapper.expectedRevenueTotal = getSSOTotalRevenue(recordId);
            goldSheetRevenuePDFData = JSON.serialize(goldSheetRevenuePDFWrapper);
        }
    }

    @AuraEnabled
    public static RevenueTargetWrapper getRevenueTargetData(String goldsheetId) {
        List<Revenue_Target__c> listRevenueTarget = new List<Revenue_Target__c>();
        RevenueTargetWrapper wrapper;
        try {
            String query = 'Select Id,Name,Current_Year__c,Next_Year__c,Custom_Year__c,Custom_Date__c,Gold_Sheet__c FROM Revenue_Target__c WHERE Gold_Sheet__c =:goldsheetId';
            Map<String, Object> paramters = new Map<String, Object>();
            paramters.put('goldsheetId', goldsheetId);
            listRevenueTarget = DataFactory.read(query, paramters);
            if (!listRevenueTarget.isEmpty()) {
                for (Revenue_Target__c revenueTarget : listRevenueTarget) {
                    wrapper = new RevenueTargetWrapper(revenueTarget);
                    wrapper.CurrentYearWrapper = RevenueTargetsController.getRevenueTargetDetails(
                        revenueTarget.Current_Year__c
                    );
                    if (revenueTarget.Next_Year__c != null) {
                        wrapper.NewYearWrapper = RevenueTargetsController.getRevenueTargetDetails(
                            revenueTarget.Next_Year__c
                        );
                    }
                    if (revenueTarget.Custom_Year__c != null) {
                        wrapper.CustomDateWrapper = RevenueTargetsController.getRevenueTargetDetails(
                            revenueTarget.Custom_Year__c
                        );
                    }
                }
            }
        } catch (Exception ex) {
            system.System.debug('exception ----' + ex);
            system.System.debug('exception line----' + ex.getLineNumber());
        }
        return wrapper;
    }

    @AuraEnabled
    public static List<GoldSheetSSOWrapper> getGoldSheetSSOData(String goldsheetId) {
        List<Gold_Sheet_Single_Sales_Objective__c> listGoldSheetSSo = new List<Gold_Sheet_Single_Sales_Objective__c>();
        List<GoldSheetSSOWrapper> goldSheetSSoWrapperListToReturn = new List<GoldSheetSSOWrapper>();
        Boolean isDeletable = false;
        if (Schema.sObjectType.Gold_Sheet_Single_Sales_Objective__c.isDeletable()) {
            isDeletable = true;
        }
        try {
            String opptyField = ApexCommonUtil.getCustomSettingsForRevenue();
            String fieldName = 'Opportunity__r.' + opptyField;
            String query =
                'SELECT Id,Name,Opportunity__c,Opportunity__r.Name,Opportunity__r.StageName,Opportunity__r.CloseDate,' +
                'Opportunity__r.Account.Name,Opportunity__r.AccountId,' +
                fieldName +
                ' FROM Gold_Sheet_Single_Sales_Objective__c WHERE Gold_Sheet__c =:goldsheetId ORDER BY createdDate DESC';
            Map<String, Object> paramters = new Map<String, Object>();
            paramters.put('goldsheetId', goldsheetId);
            listGoldSheetSSo = DataFactory.read(query, paramters);

            if (!listGoldSheetSSo.isEmpty()) {
                for (Gold_Sheet_Single_Sales_Objective__c sso : listGoldSheetSSo) {
                    GoldSheetSSOWrapper wrapper = new GoldSheetSSOWrapper(sso, isDeletable, opptyField);
                    goldSheetSSoWrapperListToReturn.add(wrapper);
                }
            }
        } catch (Exception ex) {
            System.debug('exception ----' + ex);
            System.debug('exception line----' + ex.getLineNumber());
            throw new GoldSheetSSOException('Error occured while getting data from Gold Sheet SSO');
        }
        return goldSheetSSoWrapperListToReturn;
    }

    @AuraEnabled
    public static Decimal getSSOTotalRevenue(String goldsheetId) {
        Decimal totalRevenue = 0.0;
        try {
            List<GoldSheetSSOWrapper> goldSheetSSoWrapperListToReturn = new List<GoldSheetSSOWrapper>();
            goldSheetSSoWrapperListToReturn = getGoldSheetSSOData(goldsheetId);
            if (!goldSheetSSoWrapperListToReturn.isEmpty()) {
                for (GoldSheetSSOWrapper sso : goldSheetSSoWrapperListToReturn) {
                    if (sso.expectedRevenue != null) {
                        totalRevenue = totalRevenue + sso.expectedRevenue;
                    }
                }
            }
        } catch (Exception ex) {
            System.debug('exception ----' + ex);
            System.debug('exception line----' + ex.getLineNumber());
            throw new GoldSheetSSOException('Error occured while getting data from Gold Sheet SSO');
        }
        return totalRevenue;
    }

    private class RevenueTaregtsException extends Exception {
    }

    private class GoldSheetSSOException extends Exception {
    }
}