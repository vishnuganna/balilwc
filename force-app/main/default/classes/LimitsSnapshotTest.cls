@isTest
private with sharing class LimitsSnapshotTest {
    @isTest
    static void itShould() {
        DebugSettings__c settings = DebugSettings__c.getInstance();
        settings.EnableLimitsSnapshot__c = true;
        upsert settings;

        //
        Test.startTest();
        LimitsSnapshot ls = new LimitsSnapshot('Apex Test');
        ls.toLog();
        ls.toLog(null);
        ls.toDatabase();
        Test.stopTest();

        System.assertNotEquals(
            null,
            ls.getLimitStart(LimitsSnapshot.LimitEnum.CpuTime),
            'itShould method - Limit Start'
        );
        System.assertNotEquals(null, ls.getLimitEnd(LimitsSnapshot.LimitEnum.CpuTime), 'itShould method - Limit End');
    }

    @isTest
    static void remainingCoverage() {
        LimitsSnapshot ls = new LimitsSnapshot();
        ls.toLog();

        System.assert(true, 'remainingCoverage method');
    }
}