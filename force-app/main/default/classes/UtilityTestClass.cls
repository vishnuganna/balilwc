@IsTest
public with sharing class UtilityTestClass {
    static testMethod void testIsNamespaced() {
        Boolean name = Util.isNamespaced();
        String nameSpace = Util.getNamespace();
        String nameSpaceUnderscore = Util.getNamespaceWithUnderScores();
        String applyNamespace = Util.applyNameSpace('testUtil');
        System.assert(true, 'testIsNamespaced method');
    }
}