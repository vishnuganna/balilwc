/*******************************************************************************************
 * @Name         ScorecardTemplateControllerTest
 * @Author       Janakiram Bali <janakiram.bali@atos.net>
 * @Date         2020-06-01
 * @Group
 * @Description  KFS-127 - Test Class for ScorecardTemplateController
 *******************************************************************************************/
/* MODIFICATION LOG
 * Version          Developer          Date               Description
 *-------------------------------------------------------------------------------------------
 *  1.0             janakiram Bali     2020-06-02          Initial Creation
 *********************************************************************
 */
@isTest
public with sharing class ScorecardTemplateControllerTest {
    static testMethod void adminScoreCardRecordTest() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Map<string, string> returnParams = new Map<string, string>();
            ScorecardWrapper scWrap = new ScorecardWrapper();
            Admin_Score_Card__c adminScoreCard = new Admin_Score_Card__c();
            adminScoreCard.Is_Active__c = true;
            adminScoreCard.Admin_Scorecard_Name__c = 'Test';
            adminScoreCard.Is_Default__c = true;
            insert adminScoreCard;
            Admin_Scorecard_Criteria__c admScrCrt = new Admin_Scorecard_Criteria__c();
            admScrCrt.Section__c = 'Opportunity';
            admScrCrt.Title__c = 'test';
            admScrCrt.Criteria_Definition__c = 'test';
            admScrCrt.Point_Value__c = 60;
            admScrCrt.Is_Active__c = true;
            admScrCrt.Admin_Score_Card__c = adminScoreCard.Id;
            insert admScrCrt;
            String jsonStr = '{"adminScoreCard":{"adminName":"Test","totalPoint":60,"isAct":true,"markAsDefault":true,"adminscorecardCriterias":[{"section":"Opportunity","title":"test","criteriaDef":"Test Def","isActiveCriteria" :true,"pointValue":60}]}}';
            scWrap = ScorecardTemplateController.upsertAdminScoreCardRecord(jsonStr);
            scWrap = ScorecardTemplateController.getData(adminScoreCard.Id);
            ScorecardTemplateController.getLanguagePicklistValues();
            system.assertNotEquals(scWrap, null);
            system.assert(scWrap != null);
        }
    }
}