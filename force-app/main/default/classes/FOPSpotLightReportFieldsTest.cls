@istest
public with sharing class FOPSpotLightReportFieldsTest {
    @testSetup
    static void testData() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Account acc = TestDataUtil.createAccount(true);
            Contact con = TestDataUtil.createContact(acc, true);
            Gold_Sheet__c gs = TestDataUtil.createGoldSheet(acc, true);
        }
    }
    @isTest
    static void getUpdateRevenueTargetFieldsTest() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Account acc = [SELECT Name FROM Account WHERE Name = 'Test Account' LIMIT 1];
            Gold_Sheet__c goldSheet = [SELECT Id, Name FROM Gold_Sheet__c WHERE Account__c = :acc.Id LIMIT 1];
            List<Revenue_Target_Detail__c> rtd = TestDataUtil.createRevenueDetail(true);
            Revenue_Target__c rt = TestDataUtil.createRevenueTarget(goldSheet, rtd[0], true);
            Gold_Sheet__c goldSheetAfterUpdate = [
                SELECT
                    Id,
                    Name,
                    High_Target_Current_Year__c,
                    Low_Target_Current_Year__c,
                    Realistic_Target_Current_Year__c
                FROM Gold_Sheet__c
                WHERE Account__c = :acc.Id
                LIMIT 1
            ];
            system.assertEquals(
                30,
                goldSheetAfterUpdate.High_Target_Current_Year__c,
                'Error on getUpdateRevenueTargetFieldsTest'
            );
            system.assertEquals(
                5,
                goldSheetAfterUpdate.Low_Target_Current_Year__c,
                'Error on getUpdateRevenueTargetFieldsTest'
            );
            system.assertEquals(
                17,
                goldSheetAfterUpdate.Realistic_Target_Current_Year__c,
                'Error on getUpdateRevenueTargetFieldsTest'
            );
        }
    }
    @isTest
    static void getupdateRoleFieldStrategicPlayerTest() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Account acc = [SELECT Name FROM Account WHERE Name = 'Test Account' LIMIT 1];
            Contact con = [SELECT Id FROM Contact WHERE AccountId = :acc.Id LIMIT 1];
            Gold_Sheet__c goldSheet = [SELECT Id, Name FROM Gold_Sheet__c WHERE Account__c = :acc.Id LIMIT 1];
            List<Strategic_Player__c> sp = TestDataUtil.createListStrategicPlayer(goldSheet, con, true);
            Gold_Sheet__c goldSheetAfterUpdate = [
                SELECT
                    Id,
                    Name,
                    Strategic_Player_Antisponsor__c,
                    Strategic_Player_Coach__c,
                    Strategic_Player_Key_Player__c,
                    Strategic_Player_Sponsor__c
                FROM Gold_Sheet__c
                WHERE Account__c = :acc.Id
                LIMIT 1
            ];
            system.assertEquals(
                1,
                goldSheetAfterUpdate.Strategic_Player_Antisponsor__c,
                'Error on getupdateRoleFieldStrategicPlayerTest'
            );
            system.assertEquals(
                1,
                goldSheetAfterUpdate.Strategic_Player_Coach__c,
                'Error on getupdateRoleFieldStrategicPlayerTest'
            );
            system.assertEquals(
                0,
                goldSheetAfterUpdate.Strategic_Player_Key_Player__c,
                'Error on getupdateRoleFieldStrategicPlayerTest'
            );
            delete sp;
        }

    }
    @isTest
    static void getupdateRelationshopGoalsTest() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Account acc = [SELECT Name FROM Account WHERE Name = 'Test Account' LIMIT 1];
            Gold_Sheet__c goldSheet = [SELECT Id, Name FROM Gold_Sheet__c WHERE Account__c = :acc.Id LIMIT 1];
            TestDataUtil.createListGoals(goldSheet, true);
            Gold_Sheet__c goldSheetAfterUpdate = [
                SELECT Id, Name, Goals_Completed__c, Goals_Incomplete__c
                FROM Gold_Sheet__c
                WHERE Account__c = :acc.Id
                LIMIT 1
            ];
            system.assertEquals(2, goldSheetAfterUpdate.Goals_Completed__c, 'Error on getupdateRelationshopGoalsTest');
            system.assertEquals(1, goldSheetAfterUpdate.Goals_Incomplete__c, 'Error on getupdateRelationshopGoalsTest');
        }
    }
    @isTest
    static void getupdateFOPOpportunityCountTest() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Account acc = [SELECT Name FROM Account WHERE Name = 'Test Account' LIMIT 1];
            Opportunity opp = TestDataUtil.getOpportunity();
            Gold_Sheet__c goldSheet = [SELECT Id, Name FROM Gold_Sheet__c WHERE Account__c = :acc.Id LIMIT 1];
            TestDataUtil.createGoldSheetSSO(goldSheet, opp, true);
            Gold_Sheet__c goldSheetAfterUpdate = [
                SELECT Id, Name, Count_FOP_Opportunity__c
                FROM Gold_Sheet__c
                WHERE Account__c = :acc.Id
                LIMIT 1
            ];
            system.assertEquals(
                1,
                goldSheetAfterUpdate.Count_FOP_Opportunity__c,
                'Error on getupdateFOPOpportunityCountTest'
            );
            system.assertEquals(goldSheet.Name, goldSheetAfterUpdate.Name, 'Error on getupdateFOPOpportunityCountTest');
        }
    }
}