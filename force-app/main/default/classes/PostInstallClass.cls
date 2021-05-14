@SuppressWarnings('PMD.AvoidGlobalModifier')
global class PostInstallClass implements InstallHandler {
    global void onInstall(InstallContext context) {
        if (context.isUpgrade() == false) {
            //First Install Of Package
            insertScoreCardTemplate();
            insertStandardProfilestoCustomProfile();
        }
        ManageBusinessRulesAlertMessages insertBusinessRulesMsg = new ManageBusinessRulesAlertMessages();
        insertBusinessRulesMsg.insertBusinessRulesMessages();
    }

    void insertStandardProfilestoCustomProfile() {
        //This will insert current organization's profile in 'Custom Profile' table
        CustomProfile cp = new CustomProfile();
        cp.copyStandardProfilestoCustomProfile();
    }
    void insertScoreCardTemplate() {
        List<Admin_Score_Card__c> lstAdminScoreCard = new List<Admin_Score_Card__c>();
        Admin_Score_Card__c scorecard = new Admin_Score_Card__c();
        scorecard.Admin_Scorecard_Name__c = System.Label.DefaultScorecardName;
        scorecard.Is_Active__c = true;
        scorecard.Is_Default__c = true;
        lstAdminScoreCard.add(scorecard);
        DataFactory.create(lstAdminScoreCard);

        List<Admin_Score_Card__c> lstAdmScore = new List<Admin_Score_Card__c>();
        String admScoreQuery = 'SELECT Id, Name FROM Admin_Score_Card__c WHERE Admin_Scorecard_Name__c = :cardName  LIMIT 1';
        Map<String, Object> params = new Map<String, Object>();
        params.put('cardName', System.Label.DefaultScorecardName);
        lstAdmScore = DataFactory.read(admScoreQuery, params);

        List<Admin_Scorecard_Criteria__c> lstCriterias = new List<Admin_Scorecard_Criteria__c>();

        Admin_Scorecard_Criteria__c adminscorecard = new Admin_Scorecard_Criteria__c();
        adminscorecard.Is_Active__c = true;
        adminscorecard.Admin_Score_Card__c = lstAdmScore[0].Id;
        adminscorecard.Title__c = System.Label.AdminScorecard1Title;
        adminscorecard.Section__c = System.Label.AdminScorecardSectionOpp;
        adminscorecard.Criteria_Definition__c = System.Label.AdminScorecard1Criteria_Definition;
        adminscorecard.Point_Value__c = 20;
        lstCriterias.add(adminscorecard);

        Admin_Scorecard_Criteria__c adminscorecard2 = new Admin_Scorecard_Criteria__c();
        adminscorecard2.Is_Active__c = true;
        adminscorecard2.Admin_Score_Card__c = lstAdmScore[0].Id;
        adminscorecard2.Title__c = System.Label.AdminScorecard2Title;
        adminscorecard2.Section__c = System.Label.AdminScorecardSectionOpp;
        adminscorecard2.Criteria_Definition__c = System.Label.AdminScorecard2Criteria_Definition;
        adminscorecard2.Point_Value__c = 20;
        lstCriterias.add(adminscorecard2);

        Admin_Scorecard_Criteria__c adminscorecard3 = new Admin_Scorecard_Criteria__c();
        adminscorecard3.Is_Active__c = true;
        adminscorecard3.Admin_Score_Card__c = lstAdmScore[0].Id;
        adminscorecard3.Title__c = System.Label.AdminScorecard3Title;
        adminscorecard3.Section__c = System.Label.AdminScorecardSectionOpp;
        adminscorecard3.Criteria_Definition__c = System.Label.AdminScorecard3Criteria_Definition;
        adminscorecard3.Point_Value__c = 20;
        lstCriterias.add(adminscorecard3);

        Admin_Scorecard_Criteria__c adminscorecard4 = new Admin_Scorecard_Criteria__c();
        adminscorecard4.Is_Active__c = true;
        adminscorecard4.Admin_Score_Card__c = lstAdmScore[0].Id;
        adminscorecard4.Title__c = System.Label.AdminScorecard4Title;
        adminscorecard4.Section__c = System.Label.AdminScorecardSectionOpp;
        adminscorecard4.Criteria_Definition__c =
            System.Label.AdminScorecard4Criteria_DefinitionL1 +
            System.Label.AdminScorecard4Criteria_DefinitionL2 +
            System.Label.AdminScorecard4Criteria_DefinitionL3 +
            System.Label.AdminScorecard4Criteria_DefinitionL4;
        adminscorecard4.Point_Value__c = 20;
        lstCriterias.add(adminscorecard4);

        Admin_Scorecard_Criteria__c adminscorecard5 = new Admin_Scorecard_Criteria__c();
        adminscorecard5.Is_Active__c = true;
        adminscorecard5.Admin_Score_Card__c = lstAdmScore[0].Id;
        adminscorecard5.Title__c = System.Label.AdminScorecard5Title;
        adminscorecard5.Section__c = System.Label.AdminScorecardSectionBusiness;
        adminscorecard5.Criteria_Definition__c = System.Label.AdminScorecard5Criteria_Definition;
        adminscorecard5.Point_Value__c = 20;
        lstCriterias.add(adminscorecard5);

        DataFactory.create(lstCriterias);
    }
}