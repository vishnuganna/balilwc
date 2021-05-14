@isTest
public with sharing class ApexCommonUtilTest {
    @isTest
    static void userTitle() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            String title = ApexCommonUtil.getUserTitle(user.Id);
            System.assertEquals(title, 'Manager', 'User is manager');
        }
    }

    @isTest
    static void getSetOfStringType() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Set<Id> idSet = new Set<Id>();
            idSet.add(user.Id);
            Set<String> setOfStr = ApexCommonUtil.getSetOfStringType(idSet);
            for (String str : setOfStr) {
                System.assertEquals(str, user.Id);
            }
        }
    }

    @isTest
    static void modifyWithEmptyCheck() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            List<User> usrLst = new List<User>();
            user.email = 'abc@abc.com';
            usrLst.add(user);
            ApexCommonUtil.modifyWithEmptyCheck(usrLst);
            User tmp = usrLst[0];
            System.assertEquals(tmp.email, 'abc@abc.com', 'Update is successful');
        }
    }

    @isTest
    static void getPermissionSetLst() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Set<String> psSet = new Set<String>();
            psSet.add('KF_Admin');
            List<PermissionSetAssignment> psaLst = ApexCommonUtil.getPermissionSetLst(psSet, user.Id);
            System.assertEquals(psaLst.size() > 0, true, 'User has KF_Admin permission set');
        }
    }
}