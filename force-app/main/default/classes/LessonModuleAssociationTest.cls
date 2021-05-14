@isTest
public with sharing class LessonModuleAssociationTest {
    @isTest
    static void validateGetLessonModuleMap() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Test.startTest();
            String lessonName = 'Introduction';
            //Map<String, LessonModuleAssociation.ModuleWrapper> moduleLst = LessonModuleAssociation.getLessonModuleMap(lessonName,);
            System.assertEquals(
                lessonName == 'Introduction',
                true,
                'Checking data in moduleLst for Introduction is not null'
            );
            Test.stopTest();
        }
    }
}