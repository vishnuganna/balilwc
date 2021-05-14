/*******************************************************************************************
 * @Name         RevenueTargetsController
 * @Author       Keerthana Mohanasundaram,Monika Deshmukh
 * @Date         2020-08-13
 * @Group
 * @Description  KFS-334 - This class contains all methods related to create,get and update Revenue Targets on Gold Sheet object
 *******************************************************************************************/
/* MODIFICATION LOG
 * Version          Developer          Date               Description
 *-------------------------------------------------------------------------------------------
 *  1.0             Keerthana Mohanasundaram     2020-08-13          Initial Creation
 **  2.0           Monika Deshmukh              2020-08-14          Updates
 *********************************************************************
 */

public with sharing class RevenueTargetsController {
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
                    wrapper.CurrentYearWrapper = getRevenueTargetDetails(revenueTarget.Current_Year__c);
                    if (revenueTarget.Next_Year__c != null) {
                        wrapper.NewYearWrapper = getRevenueTargetDetails(revenueTarget.Next_Year__c);
                    }
                    if (revenueTarget.Custom_Year__c != null) {
                        wrapper.CustomDateWrapper = getRevenueTargetDetails(revenueTarget.Custom_Year__c);
                    }
                }
            }
        } catch (Exception ex) {
            system.System.debug('exception ----' + ex);
            system.System.debug('exception line----' + ex.getLineNumber());
        }
        return wrapper;
    }

    public static RevenueTargetDetailWrapper getRevenueTargetDetails(String recordId) {
        List<Revenue_Target_Detail__c> listRevenueTargetDetail = new List<Revenue_Target_Detail__c>();
        RevenueTargetDetailWrapper wrapper;
        try {
            //formation of query
            String revenueQuery =
                'Select Id,Name,Assumptions__c,High_Lost_Revenue__c,High_New_Revenue__c,High_Recurring_Revenue__c,Tab_Type__c,' +
                'High_Target__c,Low_Lost_Revenue__c,Low_New_Revenue__c,Low_Recurring_Revenue__c,Low_Target__c,' +
                'Realistic_Lost_Revenue__c,Realistic_New_Revenue__c,Realistic_Recurring_Revenue__c,Realistic_Target__c FROM Revenue_Target_Detail__c WHERE Id=:recordId';
            Map<String, Object> paramters = new Map<String, Object>();
            paramters.put('recordId', recordId);
            //get data from cometition section
            listRevenueTargetDetail = DataFactory.read(revenueQuery, paramters);
            //iterate through list to get list of wrapper to return to UI
            if (!listRevenueTargetDetail.isEmpty()) {
                wrapper = new RevenueTargetDetailWrapper(listRevenueTargetDetail[0]);
            }
        } catch (Exception ex) {
            system.System.debug('exception ----' + ex);
            system.System.debug('exception line----' + ex.getLineNumber());
        }
        //return list of wrapper containing all competition data
        return wrapper;
    }
    @AuraEnabled
    public static Map<String, Boolean> getObjectPermission() {
        Map<String, Boolean> accessMap = new Map<String, Boolean>();
        String objName = util.getNamespaceWithUnderScores() == ''
            ? 'Revenue_Target_Detail__c'
            : util.getNamespaceWithUnderScores() + 'Revenue_Target_Detail__c';
        accessMap = ApexCommonUtil.getObjectAccess(objName);
        return accessMap;
    }

    @AuraEnabled
    public static void saveRevenueDetails(String inputString) {
        List<Revenue_Target_Detail__c> revenueTargetToUpsert = new List<Revenue_Target_Detail__c>();
        RevenueTargetWrapper targetWrapper = (RevenueTargetWrapper) system.JSON.deserialize(
            inputString,
            RevenueTargetWrapper.class
        );
        try {
            if (targetWrapper != null) {
                RevenueTargetDetailWrapper inputWrapper = targetWrapper.CurrentYearWrapper;
                RevenueTargetDetailWrapper inputNextYearWrapper = targetWrapper.NewYearWrapper;
                RevenueTargetDetailWrapper inputCustomYearWrapper = targetWrapper.CustomDateWrapper;
                if (inputWrapper != null) {
                    Revenue_Target_Detail__c revenueDetail = mapRevenueDetailFields(inputWrapper);
                    revenueTargetToUpsert.add(revenueDetail);
                }
                if (inputNextYearWrapper != null) {
                    Revenue_Target_Detail__c revenueNYDetail = mapRevenueDetailFields(inputNextYearWrapper);
                    revenueTargetToUpsert.add(revenueNYDetail);
                }
                if (inputCustomYearWrapper != null) {
                    Revenue_Target_Detail__c revenueCDDetail = mapRevenueDetailFields(inputCustomYearWrapper);
                    revenueTargetToUpsert.add(revenueCDDetail);
                }
            }
            List<Database.UpsertResult> upsertResult;
            if (!revenueTargetToUpsert.isEmpty()) {
                upsertResult = DataFactory.upsurt(revenueTargetToUpsert, true, true, true);
            }

            if (!upsertResult.isEmpty()) {
                upsertReveueTarget(targetWrapper, upsertResult);
            }
        } catch (Exception e) {
            throw new RevenueTaregtsException('Error while saving data.' + e.getMessage());
        }
    }

    public static Revenue_Target_Detail__c mapRevenueDetailFields(RevenueTargetDetailWrapper inputWrapper) {
        Revenue_Target_Detail__c revenueDetail = new Revenue_Target_Detail__c();
        if (inputWrapper.recordId != null) {
            revenueDetail.Id = inputWrapper.recordId;
        }
        revenueDetail.Low_Recurring_Revenue__c = inputWrapper.cyLTRecurringRevenue;
        revenueDetail.Low_Lost_Revenue__c = inputWrapper.cyLTLostRevenue;
        revenueDetail.Low_New_Revenue__c = inputWrapper.cyLTNewRevenue;
        revenueDetail.Low_Target__c = inputWrapper.cyLowTarget;
        revenueDetail.Realistic_Recurring_Revenue__c = inputWrapper.cyRTRecurringRevenue;
        revenueDetail.Realistic_Lost_Revenue__c = inputWrapper.cyRTLostRevenue;
        revenueDetail.Realistic_New_Revenue__c = inputWrapper.cyRTNewRevenue;
        revenueDetail.Realistic_Target__c = inputWrapper.cyRealisticTarget;
        revenueDetail.High_Recurring_Revenue__c = inputWrapper.cyHTRecurringRevenue;
        revenueDetail.High_Lost_Revenue__c = inputWrapper.cyHTLostRevenue;
        revenueDetail.High_New_Revenue__c = inputWrapper.cyHTNewRevenue;
        revenueDetail.High_Target__c = inputWrapper.cyHighTarget;
        revenueDetail.Assumptions__c = inputWrapper.cyAssumptions;
        revenueDetail.Tab_Type__c = inputWrapper.tabType;
        return revenueDetail;
    }

    public static void upsertReveueTarget(
        RevenueTargetWrapper targetWrapper,
        List<Database.UpsertResult> upsertResult
    ) {
        set<Id> successRec = new Set<Id>();
        for (Database.UpsertResult result : upsertResult) {
            successRec.add(result.getId());
        }
        String detailQuery = 'Select Id,Name,Tab_Type__c FROM Revenue_Target_Detail__c WHERE Id IN:successRec';
        List<Revenue_Target_Detail__c> listRevDetails = DataFactory.read(
            detailQuery,
            new Map<String, Object>{ 'successRec' => successRec }
        );
        String goldSheetId = targetWrapper.goldSheetId;
        String queryRevTarget = 'SELECT Id,Name from Revenue_Target__c WHERE Gold_Sheet__c=: goldSheetId';
        List<Revenue_Target__c> revenueTargetList = DataFactory.read(
            queryRevTarget,
            new Map<String, Object>{ 'goldSheetId' => goldSheetId }
        );
        List<Revenue_Target__c> revenueTargetToInsert = new List<Revenue_Target__c>();
        Revenue_Target__c revenueTarget = new Revenue_Target__c();
        if (!revenueTargetList.isEmpty()) {
            revenueTarget.Id = revenueTargetList[0].Id;
        }
        for (Revenue_Target_Detail__c detail : listRevDetails) {
            if (detail.Tab_Type__c == 'Current Year') {
                revenueTarget.Current_Year__c = detail.Id;
            }
            if (detail.Tab_Type__c == 'Next Year') {
                revenueTarget.Next_Year__c = detail.Id;
            }
            if (detail.Tab_Type__c == 'Custom Year') {
                revenueTarget.Custom_Year__c = detail.Id;
            }
        }
        revenueTarget.Gold_Sheet__c = goldSheetId;
        revenueTarget.Custom_Date__c = targetWrapper.customDate;
        revenueTargetToInsert.add(revenueTarget);

        if (!revenueTargetToInsert.isEmpty()) {
            DataFactory.upsurt(revenueTargetToInsert, true, true, true);
        }
    }

    private class RevenueTaregtsException extends Exception {
    }
}