@isTest
public with sharing class ModuleControllerTest {
    @isTest
    static void testUpdateModules() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            SelfGuidedLearning.createOrGetSelfGuidedJourneyDetails();
            Self_Guided_Journey__c sgjObj = [
                SELECT Id, Progress_Status__c
                FROM Self_Guided_Journey__c
                WHERE User__c = :user.Id
            ];
            System.assertEquals(sgjObj != null, true, 'Self Guided Journey record got created!');

            List<Lesson__c> lessonList = [
                SELECT Id, Lesson_Name_Id__c, Lesson_Progress_Status__c
                FROM Lesson__c
                WHERE Self_Guided_Journey__c = :sgjObj.Id AND Lesson_Name_Id__c = 'Lesson_3'
            ];

            String lessonRecId = lessonList[0].Id;
            Module__c module = [
                SELECT Id, Lesson__c, Module_Name_Id__c, Video_Progress__c, Bluesheet_Progress_Track__c
                FROM Module__c
                WHERE Lesson__c = :lessonRecId AND Module_Name_Id__c = 'Lesson_3_Module_1'
            ];

            Map<String, Object> inputData = new Map<String, Object>();
            inputData.put('moduleRecordId', module.Id);
            inputData.put('moduleBluesheetProgress', 'Complete');
            inputData.put('availBlueSheetButton', true);
            String jsonstring = JSON.Serialize(inputData);

            LessonModuleAssociation.ModuleWrapper wrap = ModuleController.updateModules(jsonstring, lessonRecId);
            Map<String, String> moduleWithStatusMap = ModuleController.moduleStatusMap(lessonRecId);
            Map<String, String> moduleIdWithNameMap = ModuleController.moduleIdNameMap(lessonRecId);
            System.assertEquals(moduleWithStatusMap != null, true, 'Status map is not null');
        }
    }
}