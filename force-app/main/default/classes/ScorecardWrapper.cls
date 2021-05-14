/**
/*******************************************************************************************
* @Name         ScorecardDetail 
* @Author       Janakiram Bali <janakiram.bali@atos.net>
* @Date         2020-05-27
* @Group        
* @Description  KFS-127 this WrapperClass used in ScorecardDetailController
*******************************************************************************************/
/* MODIFICATION LOG
 * Version          Developer          Date               Description
 *-------------------------------------------------------------------------------------------
 *  1.0             janakiram Bali     2020-06-01          Initial Creation
 *********************************************************************
 */
public with sharing class ScorecardWrapper {
    @AuraEnabled
    public adminScoreCard adminScoreCard;

    public class adminScoreCard {
        @AuraEnabled
        public String adminName;
        @auraEnabled
        public String parentId;
        @AuraEnabled
        public Boolean isAct;
        @AuraEnabled
        public Boolean markAsDefault;
        @AuraEnabled
        public Double totalPoint;
        @auraEnabled
        public String language;
        @AuraEnabled
        public adminscorecardCriterias[] adminscorecardCriterias;
    }

    public class adminscorecardCriterias {
        @AuraEnabled
        public String section;
        @auraEnabled
        public String childId;
        @AuraEnabled
        public String title;
        @AuraEnabled
        public String criteriaDef;
        @AuraEnabled
        public Double pointValue;
        @AuraEnabled
        public Double orderNumber;
        @AuraEnabled
        public Boolean isActiveCriteria;
    }
}