/*******************************************************************************************
 * @Name         ScorecardTemplate
 * @Author       Janakiram Bali <janakiram.bali@atos.net>
 * @Date         2020-05-27
 * @Group
 * @Description  KFS-127 - This class contains all methods related to create,get and update adminscorecard object records with respective child records
 *******************************************************************************************/
/* MODIFICATION LOG
 * Version          Developer          Date               Description
 *-------------------------------------------------------------------------------------------
 *  1.0             janakiram Bali     2020-07-01          Initial Creation
 *********************************************************************
 *  2.0             Monika Deshmukh    2020-07-01           Update in logic
 *********************************************************************
 *  2.0             Monika Deshmukh    2020-07-02           Update in logic
 */

/**************************************************************************************
 * @Description  this method is used to get the Admin Score Card and Admin scorecard Criteria objects data from Wrapper class(ScorecardWrapper) with respective recordId
 * @Return - it retuns data from wrapper
 **************************************************************************************/
@SuppressWarnings('PMD.AvoidDeeplyNestedIfStmts')
public with sharing class ScorecardTemplateController {
    @AuraEnabled
    public static string getObjectName() {
        String objectName = util.getNamespaceWithUnderScores() == '' ? '' : util.getNamespaceWithUnderScores();
        objectName += 'Admin_Score_Card__c';
        return objectName;
    }

    @AuraEnabled
    public static ScorecardWrapper getData(String recordId) {
        ScorecardWrapper scWrap = new ScorecardWrapper();
        String query;
        List<Admin_Score_Card__c> admScoreCards;
        try {
            if (recordId != null) {
                admScoreCards = DataFactory.read(
                    'SELECT Id, Is_Active__c, name,Admin_Scorecard_Name__c, Is_Default__c,Language__c,Total_Points__c, (SELECT Id, Section__c,Order_Number__c, Title__c,Criteria_Definition__c, Point_Value__c,is_Active__c, Admin_Score_Card__c FROM Admin_Scorecard_Criterias__r) FROM Admin_Score_Card__c WHERE Id =:recordId',
                    new Map<String, Object>{ 'recordId' => recordId }
                );
                if (admScoreCards.size() > 0) {
                    ScorecardWrapper.adminScoreCard admScrCard = new ScorecardWrapper.adminScoreCard();
                    admScrCard.adminName = admScoreCards[0].Admin_Scorecard_Name__c;
                    admScrCard.isAct = admScoreCards[0].Is_Active__c;
                    admScrCard.markAsDefault = admScoreCards[0].Is_Default__c;
                    admScrCard.language = admScoreCards[0].Language__c;
                    admScrCard.totalPoint = admScoreCards[0].Total_Points__c;
                    admScrCard.parentId = admScoreCards[0].Id;
                    scWrap.adminScoreCard = admScrCard;
                    List<ScorecardWrapper.adminscorecardCriterias> lstAdmScrCrt = new List<ScorecardWrapper.adminscorecardCriterias>();
                    for (Admin_Scorecard_Criteria__c scrCrt : admScoreCards[0].Admin_Scorecard_Criterias__r) {
                        ScorecardWrapper.adminscorecardCriterias admScrCrt = new ScorecardWrapper.adminscorecardCriterias();
                        admScrCrt.section = scrCrt.Section__c;
                        admScrCrt.title = scrCrt.Title__c;
                        admScrCrt.criteriaDef = scrCrt.Criteria_Definition__c;
                        admScrCrt.pointValue = scrCrt.Point_Value__c;
                        admScrCrt.isActiveCriteria = scrCrt.Is_Active__c;
                        admScrCrt.orderNumber = scrCrt.Order_Number__c;
                        admScrCrt.childId = scrCrt.Id;
                        lstAdmScrCrt.add(admScrCrt);
                    }
                    scWrap.adminScoreCard.adminscorecardCriterias = lstAdmScrCrt;
                }
            }
        } catch (Exception exp) {
            System.debug('Exception occurs on getData' + exp.getMessage());
        }

        return scWrap;
    }

    /**************************************************************************************
     * @Description  This method is used to create and Update Admin Scorecard object records with respective Admin scorecard Criteria records
     * @Param String - it returns success status and error status while Updating and inserting
     * @Return
     **************************************************************************************/

    @AuraEnabled
    public static ScorecardWrapper upsertAdminScoreCardRecord(String inputString) {
        ScorecardWrapper returnParams = new ScorecardWrapper();
        String parentId;
        try {
            List<Admin_Score_Card__c> listToUdpate = new List<Admin_Score_Card__c>();
            map<Id, Admin_Score_Card__c> finalListToUdpate = new Map<Id, Admin_Score_Card__c>();

            ScorecardWrapper scoreCardWrap = new ScorecardWrapper();

            scoreCardWrap = (ScorecardWrapper) System.JSON.deserialize(inputString, ScorecardWrapper.class);

            if (scoreCardWrap.adminScoreCard != null) {
                if (scoreCardWrap.adminScoreCard.markAsDefault == true) {
                    //List<Admin_Score_Card__c> returnList = removeExistingDefault();
                    //listToUdpate.addAll(returnList);
                    removeExistingDefault(scoreCardWrap.adminScoreCard.language);
                }

                Admin_Score_Card__c adminScoreCard = new Admin_Score_Card__c();
                if (scoreCardWrap.adminScoreCard.parentId != null) {
                    adminScoreCard.id = scoreCardWrap.adminScoreCard.parentId;
                }
                adminScoreCard.Is_Active__c = scoreCardWrap.adminScoreCard.isAct;
                adminScoreCard.Admin_Scorecard_Name__c = scoreCardWrap.adminScoreCard.adminName;
                adminScoreCard.Is_Default__c = scoreCardWrap.adminScoreCard.markAsDefault;
                adminScoreCard.Language__c = scoreCardWrap.adminScoreCard.language;
                // DataFactory class is use to Update a record
                listToUdpate.add(adminScoreCard);
                finalListToUdpate.putall(listToUdpate);

                Database.UpsertResult[] urList = DataFactory.upsurt(finalListToUdpate.values());

                if (urList.size() > 0 && urList[0].isSuccess()) {
                    if (urList[0].getId() != null) {
                        parentId = urList[0].getId();
                    }
                    List<Admin_Scorecard_Criteria__c> adminscorecardCriterias = new List<Admin_Scorecard_Criteria__c>();
                    if (scoreCardWrap.adminScoreCard.adminscorecardCriterias.size() > 0) {
                        for (
                            ScorecardWrapper.adminscorecardCriterias childWrap : scoreCardWrap.adminScoreCard.adminscorecardCriterias
                        ) {
                            Admin_Scorecard_Criteria__c adminScroe = new Admin_Scorecard_Criteria__c();
                            if (childWrap.childId != null) {
                                adminScroe.Id = childWrap.childId;
                            }
                            adminScroe.Section__c = childWrap.section;
                            adminScroe.Title__c = childWrap.title;
                            adminScroe.Criteria_Definition__c = childWrap.criteriaDef;
                            adminScroe.Point_Value__c = childWrap.pointValue;
                            adminScroe.Is_Active__c = childWrap.isActiveCriteria;
                            adminScroe.Order_Number__c = childWrap.orderNumber;
                            if (childWrap.childId == null) {
                                adminScroe.Admin_Score_Card__c = urList[0].getId();
                            }
                            adminscorecardCriterias.add(adminScroe);
                        }
                    }
                    if (!adminscorecardCriterias.isEmpty()) {
                        DataFactory.upsurt(adminscorecardCriterias, true, true, true);
                    }
                    returnParams = getData(parentId);
                }
            }
        } catch (Exception exp) {
            system.debug('error------' + exp);
        }
        return returnParams;
    }

    /**************************************************************************************
     * @Description  - this method is used to update deafult scorecard template for Admin Scorecard
     * @Param String - if user updates any existing template or create a new template and mark that as default, all the existing templates that were marked as default should be uncheck.
     * @Return
     **************************************************************************************/

    public static void removeExistingDefault(String language) {
        List<Admin_Score_Card__c> scorecardTemplate = new List<Admin_Score_Card__c>();
        String query = 'SELECT Id,Name,Is_Default__c,Language__c from Admin_Score_Card__c WHERE Is_Default__c = true AND Language__c =: language ';
        map<String, Object> params = new Map<String, Object>();
        params.put('language', language);
        scorecardTemplate = DataFactory.read(query, params);

        List<Admin_Score_Card__c> listToUpdate = new List<Admin_Score_Card__c>();
        if (!scorecardTemplate.isEmpty()) {
            for (Admin_Score_Card__c adm : scorecardTemplate) {
                adm.Is_Default__c = false;
                listToUpdate.add(adm);
            }
        }

        DataFactory.modify(listToUpdate);
    }

    @AuraEnabled(cacheable=true)
    public static String getLanguagePicklistValues() {
        map<string, string> options = new Map<string, string>();
        //List<String>
        Schema.DescribeFieldResult fieldResult = User.LanguageLocaleKey.getDescribe();
        List<Schema.PicklistEntry> lang = fieldResult.getPicklistValues();

        for (Schema.PicklistEntry f : lang) {
            options.put(f.getLabel(), f.getValue());
        }
        System.debug('options' + options);
        return JSON.serialize(options);
    }
}