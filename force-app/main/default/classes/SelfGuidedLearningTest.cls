@isTest
public with sharing class SelfGuidedLearningTest {
    @isTest
    static void testCreateSGJandLessonRec() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            SelfGuidedLearning.createOrGetSelfGuidedJourneyDetails();
            Self_Guided_Journey__c sgjObj = [
                SELECT Id, Progress_Status__c
                FROM Self_Guided_Journey__c
                WHERE User__c = :user.Id
            ];
            System.assertEquals(sgjObj != null, true, 'Self Guided Journey record got created!');

            List<Lesson__c> lessonLst = [
                SELECT Id, Lesson_Name_Id__c, Lesson_Progress_Status__c
                FROM Lesson__c
                WHERE Self_Guided_Journey__c = :sgjObj.Id
            ];
            System.assertEquals(lessonLst.size() == 10, true, '10 Lesson record got created!');

            SelfGuidedLearning.createOrGetSelfGuidedJourneyDetails();
            SelfGuidedLearning.markLessonAsComplete(lessonLst[0].Id);
            SelfGuidedLearning.getLessonRecordData(lessonLst[0].Id);
        }
    }

    @isTest
    static void testCheckIfUserHasCompletedPrevLesson() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            // create SGJ and Lesson records
            SelfGuidedLearning.createOrGetSelfGuidedJourneyDetails();
            Self_Guided_Journey__c sgjObj = [SELECT Id FROM Self_Guided_Journey__c WHERE User__c = :user.Id];
            String sgjObjId = sgjObj.Id;
            String currentLessonNameId = 'Introduction';
            boolean b = SelfGuidedLearning.checkIfUserHasCompletedPrevLesson(currentLessonNameId, sgjObjId);
            System.assertEquals(b, true, 'You can access Introduction Module');

            currentLessonNameId = 'Lesson_1';
            b = SelfGuidedLearning.checkIfUserHasCompletedPrevLesson(currentLessonNameId, sgjObjId);
            System.assertEquals(b, false, 'You can not access Lesson 1 Module');

            Lesson__c lesson = [
                SELECT Id, Lesson_Progress_Status__c
                FROM Lesson__c
                WHERE Self_Guided_Journey__c = :sgjObjId AND Lesson_Name_Id__c = 'Introduction'
            ];
            lesson.Lesson_Progress_Status__c = 'Viewed';
            update lesson;

            b = SelfGuidedLearning.checkIfUserHasCompletedPrevLesson(currentLessonNameId, sgjObjId);
            System.assertEquals(b, true, 'You can access Lesson 1 Module');

            currentLessonNameId = 'Lesson_2';
            b = SelfGuidedLearning.checkIfUserHasCompletedPrevLesson(currentLessonNameId, sgjObjId);
            System.assertEquals(b, false, 'You can not access Lesson 2 Module');

            lesson = [
                SELECT Id, Lesson_Progress_Status__c
                FROM Lesson__c
                WHERE Self_Guided_Journey__c = :sgjObjId AND Lesson_Name_Id__c = 'Lesson_1'
            ];
            lesson.Lesson_Progress_Status__c = 'Viewed';
            update lesson;

            b = SelfGuidedLearning.checkIfUserHasCompletedPrevLesson(currentLessonNameId, sgjObjId);
            System.assertEquals(b, true, 'You can access Lesson 2 Module');
        }
    }

    @isTest
    static void testcheckIfSelfGuidedLearningDisabled() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Turn_Off_Guided_Learning__c settings = Turn_Off_Guided_Learning__c.getInstance();
            settings.Disable_Self_Guided_Learning__c = true;
            upsert settings;
            Boolean isSelfGuidedLearningDisabled = SelfGuidedLearning.checkIfSelfGuidedLearningDisabled();
            System.assertEquals(isSelfGuidedLearningDisabled, true, 'Self guided learning disabled');
        }
    }
}