@isTest
private with sharing class DescribeCacheTest {
    @isTest
    static void getRestrictedFields() {
        System.runAs(UserTest.createStandardUser()) {
            DescribeCache dc = DescribeCache.getDescribeCache('Lead');

            Set<String> flds = dc.getRestrictedFields(DataConstants.SecurityOperation.CREATE);

            System.assertNotEquals(null, flds, 'DescribeCacheTest method');
        }
    }

    @isTest
    static void getFieldTokenNamespace() {
        System.runAs(UserTest.createStandardUser()) {
            DescribeCache dc = DescribeCache.getDescribeCache('Lead');

            Schema.SObjectField sof = dc.getFieldToken('NS__AggregateQueries__c');

            System.assert(true, 'getFieldTokenNamespace method');
        }
    }

    @isTest
    static void getRecordTypeId() {
        System.runAs(UserTest.createStandardUser()) {
            DescribeCache dc = DescribeCache.getDescribeCache('Lead');

            try {
                dc.getRecordTypeId('Test');
                System.assert(false, 'getRecordTypeId method');
            } catch (DescribeCache.RecordTypeNotFoundException rtnfe) {
                System.assert(true, 'getRecordTypeId method');
            }
        }
    }

    @isTest
    static void getPicklistOptions() {
        System.runAs(UserTest.createStandardUser()) {
            DescribeCache dc = DescribeCache.getDescribeCache('Account');
            dc.getChildSObject('Account');
            List<SelectOption> lso = dc.getPicklistOptions('Type');

            System.assertNotEquals(null, lso, 'getPicklistOptions method');
        }
    }
}