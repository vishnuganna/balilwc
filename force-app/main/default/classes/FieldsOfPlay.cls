/*******************************************************************************************
 * @Name         FieldsOfPlay
 * @Author       Janakiram Bali
 * @Date         2020-08-27
 * @Group
 * @Description  KFS-1228 - This class contains to update Last Updated Date on Gold Sheet object based Child objects modifications
 *******************************************************************************************/
/* MODIFICATION LOG
 * Version          Developer                      Date               Description
 *-------------------------------------------------------------------------------------------
 *  1.0            Janakiram Bali                  2020-09-11          Initial Creation
 *********************************************************************
 */
public with sharing class FieldsOfPlay {
    public static boolean LastUpdatedDate = true;
    public static boolean LastUpdatedDateInsert = true;
    public static void goldSheetLastUpdatedDateAndTime(List<sObject> objectsList) {
        List<sObject> objList = new List<sObject>();
        Set<sObject> setObj = new Set<sObject>();
        for (sObject s : objectsList) {
            Object str = s.getSObjectType();
            Gold_Sheet__c goldSheet = new Gold_Sheet__c();
            if (String.valueOf(str) == ApexCommonUtil.getObjectwithNameSpace('Gold_Sheet__c')) {
                goldSheet.id = (Id) s.get('Id');
            } else if (
                String.valueOf(str) == ApexCommonUtil.getObjectwithNameSpace('Strategic_Player__c') ||
                String.valueOf(str) == ApexCommonUtil.getObjectwithNameSpace('Field_of_Play_Opportunity__c') ||
                String.valueOf(str) == ApexCommonUtil.getObjectwithNameSpace('Field_of_Play_Trend__c') ||
                String.valueOf(str) == ApexCommonUtil.getObjectwithNameSpace('Milestone__c') ||
                String.valueOf(str) == ApexCommonUtil.getObjectwithNameSpace('Gold_Sheet_Single_Sales_Objective__c') ||
                String.valueOf(str) == ApexCommonUtil.getObjectwithNameSpace('Revenue_Target__c') ||
                String.valueOf(str) == ApexCommonUtil.getObjectwithNameSpace('Green_Sheet__c') ||
                String.valueOf(str) == ApexCommonUtil.getObjectwithNameSpace('FOP_Strategic_Strength__c') ||
                String.valueOf(str) == ApexCommonUtil.getObjectwithNameSpace('Red_Flag__c') ||
                String.valueOf(str) == ApexCommonUtil.getObjectwithNameSpace('Strength__c')
            ) {
                goldSheet.id = (Id) s.get(ApexCommonUtil.getObjectwithNameSpace('Gold_Sheet__c'));
            } else {
                goldSheet.id = (Id) s.get(ApexCommonUtil.getObjectwithNameSpace('Fields_of_Play_Gold_Sheet__c'));
            }
            goldSheet.Last_Updated__c = (DateTime) s.get('LastModifiedDate');
            setObj.add(goldSheet);
        }
        objList.addAll(setObj);
        if (objList.size() > 0) {
            DataFactory.modify(objList);
        }
    }
}