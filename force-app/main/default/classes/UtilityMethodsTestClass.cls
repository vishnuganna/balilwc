/* Test class for utilityMethods class*/

@isTest
public with sharing class UtilityMethodsTestClass {
    @isTest
    static void validateobjectName() {
        Account testAcnt = new Account(Name = 'TestAcnt');
        List<Account> acntList = new List<Account>();
        acntList.add(testAcnt);
        insert acntList;

        List<Id> acIdList = new List<Id>();
        for (Account ac : acntList) {
            acIdList.add(ac.id);
        }

        Test.startTest();
        string objName = utilityMethods.objectName(acIdList);
        Test.stopTest();
        system.assertEquals(objName, 'Account');
    }
}