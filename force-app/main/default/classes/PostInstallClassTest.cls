@isTest
public with sharing class PostInstallClassTest {
    @isTest
    static void testInstallScript() {
        //Test Install Script
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            PostInstallClass postinstall = new PostInstallClass();
            Test.testInstall(postinstall, null);
            Admin_Score_Card__c score = [
                SELECT Id, Name, Admin_Scorecard_Name__c
                FROM Admin_Score_Card__c
                WHERE Admin_Scorecard_Name__c = 'Strategic Selling® Scorecard'
                LIMIT 1
            ];
            System.assertEquals(score.Admin_Scorecard_Name__c, 'Strategic Selling® Scorecard', 'record not found');
            List<Admin_Scorecard_Criteria__c> a = [
                SELECT id, name
                FROM Admin_Scorecard_Criteria__c
                WHERE Admin_Score_Card__c = :score.Id
            ];
            System.assertEquals(a.size(), 5, 'record not found');
        }
    }
}