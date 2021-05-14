@isTest
public with sharing class CompetitionTest {
    @testSetup
    static void setup() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Account acc = TestDataUtil.createAccount(true);
            Opportunity op = TestDataUtil.createOpportunity(acc, true);
            Blue_Sheet__c bs = TestDataUtil.createBluesheet(op, true);
            Competition__c comp = TestDataUtil.createCompetition(bs, acc, true);
        }
    }

    static testMethod void testGetCompetition() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            List<Competition__c> comp = [
                SELECT Id, Name, Blue_Sheet__r.Opportunity__c, Blue_Sheet__c
                FROM Competition__c
                WHERE My_Position_Vs_Competitor__c = 'Zero'
                LIMIT 1
            ];
            String opptyId = comp[0].Blue_Sheet__r.Opportunity__c;

            List<CompetitionWrapperClass> compWrap = Competition.getCompetition(opptyId);
            System.assertEquals(comp[0].Blue_Sheet__c, compWrap[0].blueSheet);
        }
    }
    static testMethod void testGetCompetitionNegative() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Opportunity op = new Opportunity();
            op.name = 'New opp test data';
            op.Amount = 45365.0;
            op.CloseDate = system.today() + 30;
            op.StageName = 'Needs Analysis';
            insert op;
            Opportunity opt = [SELECT Id FROM Opportunity WHERE Name = 'New opp test data' LIMIT 1];
            List<CompetitionWrapperClass> compWrap = Competition.getCompetition(opt.Id);
            System.assertEquals(0, compWrap.size());
        }
    }

    static testMethod void testUpdateCompetition() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Test.startTest();
            List<Competition__c> comp = [
                SELECT Id, Name, Blue_Sheet__r.Opportunity__c, Blue_Sheet__c, Competitive_Detail__c
                FROM Competition__c
                WHERE My_Position_Vs_Competitor__c = 'Zero'
            ];
            Account ac = [SELECT Id FROM Account LIMIT 1];
            String compId = comp[0].Id;
            String opptyId = comp[0].Blue_Sheet__r.Opportunity__c;

            map<String, String> competitorData = new Map<String, String>();
            competitorData.put('recordId', compId);
            competitorData.put('details', 'test comp Details');
            competitorData.put('posVsCmp', 'Zero');
            competitorData.put('accountId', ac.Id);

            Map<String, Map<String, Boolean>> rfsData = new Map<String, Map<String, Boolean>>();
            Map<String, Boolean> rfs = new Map<String, Boolean>();
            rfs.put('redFlagSelected', false);
            rfs.put('strengthSelected', false);
            rfs.put('noneSelected', false);
            rfs.put('fieldApiName', false);
            rfsData.put('competitor', rfs);
            //String jsonparsed = JSON.Serialize(compWrap[0]);
            //competition.updateCompetitorData(jsonparsed ,opptyId);
            Competition.updateCompetitorData(competitorData, opptyId, rfsData);
            List<Competition__c> comp2 = [
                SELECT Id, Name, Blue_Sheet__r.Opportunity__c, Blue_Sheet__c, Competitive_Detail__c
                FROM Competition__c
                WHERE My_Position_Vs_Competitor__c = 'Zero'
            ];
            String compdetails = comp2[0].Competitive_Detail__c;
            Test.stopTest();
            System.assertEquals(compdetails, competitorData.get('details'));
            //System.assertEquals(comp[0].Blue_Sheet__c, compWrap[0].blueSheet);
        }
    }
    static testMethod void testUpdateCompetitionWithoutAccount() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Test.startTest();
            List<Competition__c> comp = [
                SELECT Id, Name, Blue_Sheet__r.Opportunity__c, Blue_Sheet__c, Competitive_Detail__c
                FROM Competition__c
                WHERE My_Position_Vs_Competitor__c = 'Zero'
            ];
            String compId = comp[0].Id;
            String opptyId = comp[0].Blue_Sheet__r.Opportunity__c;

            map<String, String> competitorData = new Map<String, String>();
            competitorData.put('recordId', compId);
            competitorData.put('details', 'test comp Details');
            competitorData.put('posVsCmp', 'Zero');

            Map<String, Map<String, Boolean>> rfsData = new Map<String, Map<String, Boolean>>();
            Map<String, Boolean> rfs = new Map<String, Boolean>();
            rfs.put('redFlagSelected', false);
            rfs.put('strengthSelected', false);
            rfs.put('noneSelected', false);
            rfs.put('fieldApiName', false);
            rfsData.put('competitor', rfs);

            Competition.updateCompetitorData(competitorData, opptyId, rfsData);
            List<Competition__c> comp2 = [
                SELECT Id, Name, Blue_Sheet__r.Opportunity__c, Blue_Sheet__c, Competitive_Detail__c
                FROM Competition__c
                WHERE My_Position_Vs_Competitor__c = 'Zero'
            ];
            String compdetails = comp2[0].Competitive_Detail__c;
            Test.stopTest();
            System.assertEquals(compdetails, competitorData.get('details'));
        }
    }
    static testMethod void testSaveCompetition() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            List<Competition__c> comp = [
                SELECT Id, Name, Blue_Sheet__r.Opportunity__c, Blue_Sheet__c, Competitive_Detail__c
                FROM Competition__c
                WHERE My_Position_Vs_Competitor__c = 'Zero'
            ];

            String AccId = [SELECT Id FROM Account].Id;
            String compId = comp[0].Id;
            String opptyId = comp[0].Blue_Sheet__r.Opportunity__c;

            List<CompetitionWrapperClass> compWrap = Competition.getCompetition(opptyId);

            Map<String, String> compData = new Map<String, String>();
            compData.put(compWrap[0].Name, compWrap[0].competitiveDetail);

            Map<String, Map<String, Boolean>> rfsData = new Map<String, Map<String, Boolean>>();
            Map<String, Boolean> rfs = new Map<String, Boolean>();
            rfs.put('redFlagSelected', false);
            rfs.put('strengthSelected', false);
            rfs.put('noneSelected', false);
            rfs.put('fieldApiName', false);
            rfsData.put('competitor', rfs);

            Test.startTest();
            List<CompetitionWrapperClass> compWrapSave = Competition.saveCompetition(compData, opptyId, AccId, rfsData);
            Test.stopTest();

            System.assertEquals(comp[0].Blue_Sheet__c, compWrap[0].blueSheet);
        }
    }
    static testMethod void testRemoveCompetition() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            List<Competition__c> comp = [
                SELECT Id, Name, Blue_Sheet__r.Opportunity__c, Blue_Sheet__c
                FROM Competition__c
                WHERE My_Position_Vs_Competitor__c = 'Zero'
                LIMIT 1
            ];
            String opptyId = comp[0].Blue_Sheet__r.Opportunity__c;
            String recordId = comp[0].Id;

            //List<CompetitionWrapperClass> compWrap = competition.removeCompetition(recordId,opptyId);
            Competition.removeCompetition(recordId, opptyId);
            List<CompetitionWrapperClass> compWrap = Competition.getCompetition(opptyId);
            System.assertEquals(true, compWrap.size() == 0);

            // System.assertEquals(comp[0].Blue_Sheet__c, compWrap[0].blueSheet);
        }
    }

    static testMethod void testGetObjectName() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Competition.wrapperLookupObject wrapper = Competition.getObjectName();
            System.assertNotEquals(wrapper.lookupOnObject, null);
        }
    }
    static testMethod void testFindAccounts() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            List<Account> accountList = Competition.findAccountRecords('tes');
            Competition.getCompetitionAccess();
            System.assertEquals(accountList[0].Name, 'Test Account');
        }
    }
}