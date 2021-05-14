@istest
public class RevenueTargetsControllerTest {
    @testSetup
    static void testData() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Account acc = TestDataUtil.createAccount(true);
            Contact con = TestDataUtil.createContact(acc, true);
            Gold_Sheet__c gs = TestDataUtil.createGoldSheet(acc, true);
            List<Revenue_Target_Detail__c> rtd = TestDataUtil.createRevenueDetail(true);
            Revenue_Target__c rt = TestDataUtil.createRevenueTarget(gs, rtd[0], true);
        }
    }
    static testMethod void testGetRevenueTargetData() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Account acc = [SELECT Name FROM Account WHERE Name = 'Test Account' LIMIT 1];
            Gold_Sheet__c goldSheet = [SELECT Id, Name FROM Gold_Sheet__c WHERE Account__c = :acc.Id LIMIT 1];
            Test.startTest();
            RevenueTargetWrapper wrapper = RevenueTargetsController.getRevenueTargetData(goldSheet.Id);
            RevenueTargetsController.getObjectPermission();
            system.assertEquals(wrapper.CurrentYearWrapper.cyLTRecurringRevenue, 34);
            system.assertEquals(wrapper.CurrentYearWrapper.cyAssumptions, 'Current Year');
            Test.stopTest();
        }
    }
    static testMethod void testSaveRevenueDetails() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Account acc = [SELECT Name FROM Account WHERE Name = 'Test Account' LIMIT 1];
            Gold_Sheet__c goldSheet = [SELECT Id, Name FROM Gold_Sheet__c WHERE Account__c = :acc.Id LIMIT 1];
            Test.startTest();
            RevenueTargetWrapper wrapper = RevenueTargetsController.getRevenueTargetData(goldSheet.Id);
            wrapper.CurrentYearWrapper.cyLTRecurringRevenue = 46;
            wrapper.CurrentYearWrapper.cyAssumptions = 'Current Year Test';
            String jsonstring = JSON.Serialize(wrapper);
            RevenueTargetsController.saveRevenueDetails(jsonstring);
            system.assertEquals(wrapper.CurrentYearWrapper.cyLTRecurringRevenue, 46);
            system.assertEquals(wrapper.CurrentYearWrapper.cyAssumptions, 'Current Year Test');
            Test.stopTest();
        }
    }
}