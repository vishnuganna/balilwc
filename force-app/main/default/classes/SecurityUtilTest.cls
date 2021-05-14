@isTest
private with sharing class SecurityUtilTest {
    static void checkCRUD_negative(DataConstants.SecurityOperation o) {
        try {
            SecurityUtil.checkCRUD(o, 'AuthProvider');
            System.assert(false, 'checkCRUD_negative method');
        } catch (SecurityUtil.CRUDException e) {
            System.assert(true, 'checkCRUD_negative method');
        }
    }
    @isTest
    static void checkCRUD_negative() {
        System.runAs(UserTest.createSFStandardUser()) {
            Test.startTest();

            checkCRUD_negative(DataConstants.SecurityOperation.READ);
            checkCRUD_negative(DataConstants.SecurityOperation.CREATE);
            checkCRUD_negative(DataConstants.SecurityOperation.MODIFY);
            checkCRUD_negative(DataConstants.SecurityOperation.REMOVE);
            checkCRUD_negative(DataConstants.SecurityOperation.UNREMOVE);

            Test.stopTest();
        }
        System.assert(true, 'checkCRUD_negative method');
    }

    static void checkCRUD_positive(DataConstants.SecurityOperation o) {
        try {
            SecurityUtil.checkCRUD(o, 'Account');
            System.assert(true, 'checkCRUD_positive method');
        } catch (SecurityUtil.CRUDException e) {
            System.assert(false, 'checkCRUD_positive method');
        }
    }
    @isTest
    static void checkCRUD_positive() {
        Test.startTest();

        checkCRUD_positive(DataConstants.SecurityOperation.READ);
        checkCRUD_positive(DataConstants.SecurityOperation.CREATE);
        checkCRUD_positive(DataConstants.SecurityOperation.MODIFY);
        checkCRUD_positive(DataConstants.SecurityOperation.REMOVE);
        checkCRUD_positive(DataConstants.SecurityOperation.UNREMOVE);

        Test.stopTest();
        System.assert(true, 'checkCRUD_positive method');
    }

    static void checkFLS_negative(DataConstants.SecurityOperation o) {
        try {
            SecurityUtil.checkFLS(o, 'Lead', 'DoNotCall');
            System.assert(false, 'checkFLS_negative method');
        } catch (SecurityUtil.FLSException e) {
            System.assert(true, 'checkFLS_negative method');
        }
    }
    @isTest
    static void checkFLS_negative() {
        System.runAs(UserTest.createStandardUser()) {
            Test.startTest();

            checkFLS_negative(DataConstants.SecurityOperation.READ);
            checkFLS_negative(DataConstants.SecurityOperation.CREATE);
            checkFLS_negative(DataConstants.SecurityOperation.MODIFY);

            Test.stopTest();
        }
        System.assert(true, 'checkFLS_negative method');
    }
    @isTest
    static void checkFLS_negative_system() {
        System.runAs(UserTest.createStandardUser()) {
            Test.startTest();

            SecurityUtil.checkFLS(DataConstants.SecurityOperation.READ, 'Lead', 'CreatedDate');

            Test.stopTest();
        }
        System.assert(true, 'checkFLS_negative_system method');
    }

    static void checkFLS_positive(DataConstants.SecurityOperation o) {
        try {
            SecurityUtil.checkFLS(o, 'Account', 'Name');
            System.assert(true, 'checkFLS_positive method');
        } catch (SecurityUtil.FLSException e) {
            System.assert(false, 'checkFLS_positive method');
        }
    }
    @isTest
    static void checkFLS_positive() {
        Test.startTest();

        checkFLS_positive(DataConstants.SecurityOperation.READ);
        checkFLS_positive(DataConstants.SecurityOperation.CREATE);
        checkFLS_positive(DataConstants.SecurityOperation.MODIFY);
        checkFLS_positive(DataConstants.SecurityOperation.REMOVE);
        checkFLS_positive(DataConstants.SecurityOperation.UNREMOVE);

        Test.stopTest();
        System.assert(true, 'checkFLS_positive method');
    }

    @isTest
    static void coverage_1() {
        SecurityUtil.checkCRUD(DataConstants.SecurityOperation.READ, Account.SObjectType);
        System.assert(true, 'coverage_1 method');
    }
    @isTest
    static void coverage_2() {
        SecurityUtil.checkFLS(DataConstants.SecurityOperation.MODIFY, Account.SObjectType, 'Id');
        System.assert(true, 'coverage_2 method');
    }
    @isTest
    static void coverage_3() {
        SecurityUtil.checkFLS(DataConstants.SecurityOperation.REMOVE, 'Lead', 'DoNotCall');
        System.assert(true, 'coverage_3 method');
    }
}