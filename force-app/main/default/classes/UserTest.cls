/**
 * This test class should be used as a central place for creating all
 * personas user records, and assigning those user records to any
 * permission sets utilized by the application.
 * <p>
 * This class should be modified to include methods for each persona.
 * This is used in test classes.
 */
@isTest
public with sharing class UserTest {
    private static Integer userNumber = 0;

    public static User createSFStandardUser() {
        return createUserWithProfile([SELECT Id FROM Profile WHERE Name = 'Standard User'].Id);
    }

    public static User createStandardUser() {
        return createUserWithProfile([SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id);
    }
    public static User createUserWithProfile(Id profileId) {
        return createUserWithProfile(profileId, null);
    }

    public static User createUserWithProfile(Id profileId, String email) {
        Integer userNum = userNumber++;
        if (email == null) {
            email = 'unit.test.user@' + UserInfo.getOrganizationId() + '.test.com';
        }
        User u = new User(
            FirstName = 'Test',
            LastName = 'User ',
            Email = email,
            Username = email,
            title = 'Manager',
            Alias = ('tuser' + userNum).right(8),
            Phone = '503-555-1212',
            ProfileId = profileId,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US'
        );
        if (Userinfo.isMultiCurrencyOrganization()) {
            ((SObject) u).put('CurrencyIsoCode', 'USD');
        }
        insert u;

        return u;
    }

    public static User createUserAsManager() {
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        Integer userNum = userNumber++;
        String email;
        if (email == null) {
            email = 'unit.test.user.manager@' + UserInfo.getOrganizationId() + '.test.com';
        }
        User u = new User(
            FirstName = 'Test',
            LastName = 'User ',
            Email = email,
            Username = email + userNum,
            title = 'Manager',
            ProfileId = profileId,
            Alias = ('tuser' + userNum).right(8),
            Phone = '503-555-1212',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US'
        );
        if (Userinfo.isMultiCurrencyOrganization()) {
            ((SObject) u).put('CurrencyIsoCode', 'USD');
        }
        insert u;

        return u;
    }
    public static User createUserWithPerms() {
        List<User> users = [
            SELECT Id, Name, Email, title
            FROM User
            WHERE Email = :'unit.test.user@' + UserInfo.getOrganizationId() + '.test.com'
        ];
        if (users.size() > 0) {
            return users[0];
        }
        return createUser(new List<String>{ 'KF_Admin', 'Blue_Sheet_Edit' });
    }

    private static User createUser(List<String> permissionSets) {
        User u = createStandardUser();

        // add user to perm sets
        List<PermissionSetAssignment> psas = new List<PermissionSetAssignment>();
        for (PermissionSet ps : [SELECT Id, Name FROM PermissionSet WHERE Name IN :permissionSets]) {
            psas.add(new PermissionSetAssignment(AssigneeId = u.Id, PermissionSetId = ps.Id));
        }
        insert psas;
        return u;
    }
    public static User createPlatformUser() {
        return createUserWithProfile([SELECT Id FROM Profile WHERE Name = 'Standard Platform User'].Id);
    }
}