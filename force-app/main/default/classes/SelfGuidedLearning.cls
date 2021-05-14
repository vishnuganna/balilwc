@SuppressWarnings('PMD.NcssMethodCount,PMD.NcssTypeCount,PMD.NcssConstructorCount')
public with sharing class SelfGuidedLearning {
    @AuraEnabled
    public static SelfGuidedJourneyWrapper createOrGetSelfGuidedJourneyDetails() {
        String userId = UserInfo.getUserId();
        String sgjQuery = 'SELECT Id, Progress_Status__c FROM Self_Guided_Journey__c where User__c=: userId';
        Map<String, Object> paramters = new Map<String, Object>();
        paramters.put('userId', userId);
        SelfGuidedJourneyWrapper sgjwrapper;
        List<Self_Guided_Journey__c> sgjLst = DataFactory.read(sgjQuery, paramters);
        if (sgjLst == null || sgjLst.size() == 0) {
            // create SGJ record
            Self_Guided_Journey__c sgjObj = new Self_Guided_Journey__c();
            SelfGuidedJourneyWrapper sgjwrapperToSend = new SelfGuidedJourneyWrapper(sgjObj);
            sgjObj.Progress_Status__c = System.Label.NotStarted;
            sgjwrapperToSend.sgjStatus = sgjObj.Progress_Status__c;
            sgjObj.user__c = userId;
            List<Database.SaveResult> srLst = DataFactory.create(sgjObj);
            List<Database.SaveResult> srLstLesson;
            for (Database.SaveResult sr : srLst) {
                if (sr.isSuccess()) {
                    String sgjId = sr.getId();
                    sgjwrapperToSend.id = sgjId;
                    List<Lesson__c> lessonLst = new List<Lesson__c>();
                    lessonLst.add(getLessonObj('Introduction', sgjId));
                    lessonLst.add(getLessonObj('Lesson_1', sgjId));
                    lessonLst.add(getLessonObj('Lesson_2', sgjId));
                    lessonLst.add(getLessonObj('Lesson_3', sgjId));
                    lessonLst.add(getLessonObj('Lesson_4', sgjId));
                    lessonLst.add(getLessonObj('Lesson_5', sgjId));
                    lessonLst.add(getLessonObj('Lesson_6', sgjId));
                    lessonLst.add(getLessonObj('Lesson_7', sgjId));
                    lessonLst.add(getLessonObj('Lesson_8', sgjId));
                    lessonLst.add(getLessonObj('Lesson_9', sgjId));
                    srLstLesson = DataFactory.create(lessonLst);
                    if (srLstLesson[0].isSuccess()) {
                        createModuleListForLesson(sgjId);
                    }
                    List<LessonsWrapper> lessonsToReturn = getLessonRecords(sgjId);
                    sgjwrapperToSend.lessons = lessonsToReturn;
                }
            }
            sgjwrapper = sgjwrapperToSend;
        } else {
            SelfGuidedJourneyWrapper sgjwrapperToSend = new SelfGuidedJourneyWrapper(sgjLst[0]);
            String sgfId = sgjLst[0].Id;
            createModulesForLesson(sgfId);
            List<LessonsWrapper> lessonsToReturn = getLessonRecords(sgfId);
            sgjwrapperToSend.sgjStatus = sgjLst[0].Progress_Status__c;
            sgjwrapperToSend.lessons = lessonsToReturn;

            sgjwrapper = sgjwrapperToSend;
        }
        return sgjwrapper;
    }

    private static void createModulesForLesson(String sgjId) {
        Map<String, Lesson__c> mapLessonWithLessonName = new Map<String, Lesson__c>();
        String lessonQuery = 'Select Id, Lesson_Name_Id__c,Lesson_Progress_Status__c, Self_Guided_Journey__c from Lesson__c where Self_Guided_Journey__c=: sgjId ORDER BY Lesson_Name_Id__c ASC';
        Map<String, Object> parmters = new Map<String, Object>();
        parmters.put('sgjId', sgjId);
        List<Lesson__c> lessonLst = DataFactory.read(lessonQuery, parmters);
        for (Lesson__c lesson : lessonLst) {
            mapLessonWithLessonName.put(lesson.Lesson_Name_Id__c, lesson);
        }

        List<Module__c> moduleList = new List<Module__c>();
        String moduleQuery =
            'SELECT Id,name,Lesson__c,Lesson__r.Self_Guided_Journey__c,Module_Name_Id__c,Video_Progress__c,Lesson__r.Lesson_Name_Id__c,' +
            ' Bluesheet_Progress_Track__c FROM Module__c WHERE Lesson__r.Self_Guided_Journey__c =:sgjId ORDER BY Module_Name_Id__c ASC';
        Map<String, Object> moduleParmters = new Map<String, Object>();
        moduleParmters.put('sgjId', sgjId);
        moduleList = DataFactory.read(moduleQuery, moduleParmters);
        Map<String, List<Module__c>> lessonModuleMap = new Map<String, List<Module__c>>();
        for (Module__c module : moduleList) {
            if (!lessonModuleMap.containsKey(module.Lesson__r.Lesson_Name_Id__c)) {
                lessonModuleMap.put(module.Lesson__r.Lesson_Name_Id__c, new List<Module__c>{ module });
            } else {
                lessonModuleMap.get(module.Lesson__r.Lesson_Name_Id__c).add(module);
            }
        }

        Map<String, String> mapLessonAndModules = new Map<String, String>();
        mapLessonAndModules.put('Introduction', 'Introduction_Module_1,Introduction_Module_2,Introduction_Module_3');
        mapLessonAndModules.put('Lesson_1', 'Lesson_1_Module_1,Lesson_1_Module_2,Lesson_1_Module_3');
        mapLessonAndModules.put('Lesson_2', 'Lesson_2_Module_1,Lesson_2_Module_2');
        mapLessonAndModules.put('Lesson_3', 'Lesson_3_Module_1,Lesson_3_Module_2,Lesson_3_Module_3,Lesson_3_Module_4');
        mapLessonAndModules.put('Lesson_4', 'Lesson_4_Module_1,Lesson_4_Module_2,Lesson_4_Module_3,Lesson_4_Module_4');
        mapLessonAndModules.put(
            'Lesson_5',
            'Lesson_5_Module_1,Lesson_5_Module_2,Lesson_5_Module_3,Lesson_5_Module_4,Lesson_5_Module_5'
        );
        mapLessonAndModules.put('Lesson_6', 'Lesson_6_Module_1');
        mapLessonAndModules.put('Lesson_7', 'Lesson_7_Module_1,Lesson_7_Module_2,Lesson_7_Module_3,Lesson_7_Module_4');
        mapLessonAndModules.put('Lesson_8', 'Lesson_8_Module_1,Lesson_8_Module_2');
        mapLessonAndModules.put('Lesson_9', 'Lesson_9_Module_1,Lesson_9_Module_2,Lesson_9_Module_3');

        List<Module__c> modulesListToInsert = new List<Module__c>();
        for (String lessonName : mapLessonAndModules.keySet()) {
            if (!lessonModuleMap.containsKey(lessonName)) {
                String data = mapLessonAndModules.get(lessonName);
                List<String> modulesToBeCreate = new List<String>();
                modulesToBeCreate = data.split(',');
                for (String tobeCreated : modulesToBeCreate) {
                    modulesListToInsert.add(getModuleObj(mapLessonWithLessonName.get(lessonName).Id, tobeCreated));
                }
            }
        }

        if (modulesListToInsert != null && !modulesListToInsert.isEmpty()) {
            DataFactory.create(modulesListToInsert);
        }
    }

    private static Lesson__c getLessonObj(String lessonName, String selfGuidedObjId) {
        Lesson__c lessonObj = new Lesson__c();
        lessonObj.Lesson_Name_Id__c = lessonName;
        lessonObj.Lesson_Progress_Status__c = System.Label.SGJBegin;
        lessonObj.Self_Guided_Journey__c = selfGuidedObjId;
        return lessonObj;
    }

    private static List<LessonsWrapper> getLessonRecords(String sgjId) {
        List<LessonsWrapper> lessonList = new List<LessonsWrapper>();
        String lessonQuery = 'Select Id, Lesson_Name_Id__c,Lesson_Progress_Status__c, Self_Guided_Journey__c from Lesson__c where Self_Guided_Journey__c=: sgjId ORDER BY Lesson_Name_Id__c ASC';
        Map<String, Object> parmters = new Map<String, Object>();
        parmters.put('sgjId', sgjId);
        List<Lesson__c> lessonLst = DataFactory.read(lessonQuery, parmters);

        List<Module__c> moduleList = new List<Module__c>();
        String moduleQuery =
            'SELECT Id,name,Lesson__c,Lesson__r.Self_Guided_Journey__c,Module_Name_Id__c,Video_Progress__c,Lesson__r.Lesson_Name_Id__c,Bluesheet_Progress_Track__c' +
            ' FROM Module__c WHERE Lesson__r.Self_Guided_Journey__c =:sgjId ORDER BY Module_Name_Id__c ASC';
        Map<String, Object> moduleParmters = new Map<String, Object>();
        moduleParmters.put('sgjId', sgjId);
        moduleList = DataFactory.read(moduleQuery, moduleParmters);
        Map<String, List<Module__c>> lessonModuleMap = new Map<String, List<Module__c>>();
        for (Module__c module : moduleList) {
            if (!lessonModuleMap.containsKey(module.Lesson__r.Lesson_Name_Id__c)) {
                lessonModuleMap.put(module.Lesson__r.Lesson_Name_Id__c, new List<Module__c>{ module });
            } else {
                lessonModuleMap.get(module.Lesson__r.Lesson_Name_Id__c).add(module);
            }
        }
        for (Lesson__c lesson : lessonLst) {
            LessonsWrapper ls = new LessonsWrapper(lesson, lessonModuleMap);
            ls.sgjId = sgjId;
            lessonList.add(ls);
        }
        return lessonList;
    }

    private static Module__c getModuleObj(String lessonId, String moduleName) {
        Module__c moduleObj = new Module__c();
        moduleObj.Module_Name_Id__c = moduleName;
        moduleObj.Video_Progress__c = 'Begin';
        moduleObj.Lesson__c = lessonId;
        return moduleObj;
    }

    private static void createModuleListForLesson(String sgjId) {
        List<Lesson__c> lessonList = new List<Lesson__c>();
        String query = 'SELECT Id,Name,Lesson_Name_Id__c FROM Lesson__c WHERE Self_Guided_Journey__c=:sgjId';
        Map<String, Object> params = new Map<String, Object>();
        params.put('sgjId', sgjId);
        lessonList = DataFactory.read(query, params);

        List<Module__c> modulesList = new List<Module__c>();
        for (Lesson__c les : lessonList) {
            String lessonId = les.Id;
            if (les.Lesson_Name_Id__c == 'Introduction') {
                modulesList.add(getModuleObj(lessonId, 'Introduction_Module_1'));
                modulesList.add(getModuleObj(lessonId, 'Introduction_Module_2'));
                modulesList.add(getModuleObj(lessonId, 'Introduction_Module_3'));
            }
            if (les.Lesson_Name_Id__c == 'Lesson_1') {
                modulesList.add(getModuleObj(lessonId, 'Lesson_1_Module_1'));
                modulesList.add(getModuleObj(lessonId, 'Lesson_1_Module_2'));
                modulesList.add(getModuleObj(lessonId, 'Lesson_1_Module_3'));
            }
            if (les.Lesson_Name_Id__c == 'Lesson_2') {
                modulesList.add(getModuleObj(lessonId, 'Lesson_2_Module_1'));
                modulesList.add(getModuleObj(lessonId, 'Lesson_2_Module_2'));
            }
            if (les.Lesson_Name_Id__c == 'Lesson_3') {
                modulesList.add(getModuleObj(lessonId, 'Lesson_3_Module_1'));
                modulesList.add(getModuleObj(lessonId, 'Lesson_3_Module_2'));
                modulesList.add(getModuleObj(lessonId, 'Lesson_3_Module_3'));
                modulesList.add(getModuleObj(lessonId, 'Lesson_3_Module_4'));
            }
            if (les.Lesson_Name_Id__c == 'Lesson_4') {
                modulesList.add(getModuleObj(lessonId, 'Lesson_4_Module_1'));
                modulesList.add(getModuleObj(lessonId, 'Lesson_4_Module_2'));
                modulesList.add(getModuleObj(lessonId, 'Lesson_4_Module_3'));
                modulesList.add(getModuleObj(lessonId, 'Lesson_4_Module_4'));
            }
            if (les.Lesson_Name_Id__c == 'Lesson_5') {
                modulesList.add(getModuleObj(lessonId, 'Lesson_5_Module_1'));
                modulesList.add(getModuleObj(lessonId, 'Lesson_5_Module_2'));
                modulesList.add(getModuleObj(lessonId, 'Lesson_5_Module_3'));
                modulesList.add(getModuleObj(lessonId, 'Lesson_5_Module_4'));
                modulesList.add(getModuleObj(lessonId, 'Lesson_5_Module_5'));
            }
            if (les.Lesson_Name_Id__c == 'Lesson_6') {
                modulesList.add(getModuleObj(lessonId, 'Lesson_6_Module_1'));
            }
            if (les.Lesson_Name_Id__c == 'Lesson_7') {
                modulesList.add(getModuleObj(lessonId, 'Lesson_7_Module_1'));
                modulesList.add(getModuleObj(lessonId, 'Lesson_7_Module_2'));
                modulesList.add(getModuleObj(lessonId, 'Lesson_7_Module_3'));
                modulesList.add(getModuleObj(lessonId, 'Lesson_7_Module_4'));
            }
            if (les.Lesson_Name_Id__c == 'Lesson_8') {
                modulesList.add(getModuleObj(lessonId, 'Lesson_8_Module_1'));
                modulesList.add(getModuleObj(lessonId, 'Lesson_8_Module_2'));
            }
            if (les.Lesson_Name_Id__c == 'Lesson_9') {
                modulesList.add(getModuleObj(lessonId, 'Lesson_9_Module_1'));
                modulesList.add(getModuleObj(lessonId, 'Lesson_9_Module_2'));
                modulesList.add(getModuleObj(lessonId, 'Lesson_9_Module_3'));
            }
        }
        if (modulesList != null && !modulesList.isEmpty()) {
            DataFactory.create(modulesList);
        }
    }

    @AuraEnabled
    public static Boolean checkIfUserHasCompletedPrevLesson(String currentLessonNameId, String sgjId) {
        // true return means user has completed previous lesson or not applicable in case of Introduction
        // false means not completed
        boolean resultStatus = false;
        String previousLessonNameId = '';
        if (currentLessonNameId == 'Introduction') {
            resultStatus = true;
        } else {
            if (currentLessonNameId == 'Lesson_1') {
                previousLessonNameId = 'Introduction';
            } else {
                String lessonNumber = currentLessonNameId.split('_')[1];
                Integer previousLessonNumber = Integer.valueOf(lessonNumber) - 1;
                previousLessonNameId = 'Lesson_' + previousLessonNumber;
            }
            String lessonQuery = 'Select Id, Lesson_Name_Id__c,Lesson_Progress_Status__c from Lesson__c where Self_Guided_Journey__c=: sgjId AND Lesson_Name_Id__c =: previousLessonNameId';
            Map<String, Object> parmters = new Map<String, Object>();
            parmters.put('sgjId', sgjId);
            parmters.put('previousLessonNameId', previousLessonNameId);
            List<Lesson__c> lessonLst = DataFactory.read(lessonQuery, parmters);
            if (lessonLst[0].Lesson_Progress_Status__c == System.Label.SGJViewed) {
                resultStatus = true;
            } else {
                resultStatus = false;
            }
        }
        return resultStatus;
    }

    @AuraEnabled
    public static LessonsWrapper markLessonAsComplete(String lessonId) {
        String lessonQuery = 'SELECT Id, Lesson_Name_Id__c,Lesson_Progress_Status__c,Self_Guided_Journey__c FROM Lesson__c Where Id =:lessonId';
        Map<String, Object> parmters = new Map<String, Object>();
        parmters.put('lessonId', lessonId);
        List<Lesson__c> lessonLst = DataFactory.read(lessonQuery, parmters);
        List<Lesson__c> lessonListToUpdate = new List<Lesson__c>();
        for (Lesson__c lesson : lessonLst) {
            lesson.Lesson_Progress_Status__c = 'Viewed';
            lessonListToUpdate.add(lesson);
        }

        if (!lessonListToUpdate.isEmpty()) {
            DataFactory.modify(lessonListToUpdate);
        }
        LessonsWrapper wrapper = new LessonsWrapper(lessonListToUpdate[0], null);

        return wrapper;
    }

    @AuraEnabled
    public static LessonsWrapper getLessonRecordData(String lessonId) {
        String query =
            'SELECT Id,name,Lesson__c,Lesson__r.Self_Guided_Journey__c,Module_Name_Id__c,' +
            'Video_Progress__c,Lesson__r.Lesson_Name_Id__c,Lesson__r.Lesson_Progress_Status__c,Bluesheet_Progress_Track__c' +
            ' FROM Module__c WHERE Lesson__c =:lessonId ORDER BY Module_Name_Id__c ASC';

        Map<String, Object> moduleParmters = new Map<String, Object>();
        moduleParmters.put('lessonId', lessonId);
        List<Module__c> moduleList = DataFactory.read(query, moduleParmters);

        Map<String, List<Module__c>> mapLessonWithModule = new Map<String, List<Module__c>>();
        Lesson__c lessonRec = new Lesson__c();
        for (Module__c module : moduleList) {
            lessonRec = new Lesson__c();
            lessonRec.Lesson_Progress_Status__c = module.Lesson__r.Lesson_Progress_Status__c;
            lessonRec.Lesson_Name_Id__c = module.Lesson__r.Lesson_Name_Id__c;
            lessonRec.Id = module.Lesson__c;
            lessonRec.Self_Guided_Journey__c = module.Lesson__r.Self_Guided_Journey__c;
            if (!mapLessonWithModule.containsKey(module.Lesson__r.Lesson_Name_Id__c)) {
                mapLessonWithModule.put(module.Lesson__r.Lesson_Name_Id__c, new List<Module__c>{ module });
            } else {
                mapLessonWithModule.get(module.Lesson__r.Lesson_Name_Id__c).add(module);
            }
        }

        LessonsWrapper wrapper = new LessonsWrapper(lessonRec, mapLessonWithModule);
        return wrapper;
    }

    @AuraEnabled
    public static Boolean checkIfSelfGuidedLearningDisabled() {
        boolean resultStatus = false;
        Turn_Off_Guided_Learning__c settings = Turn_Off_Guided_Learning__c.getInstance();
        if (settings.Disable_Self_Guided_Learning__c) {
            resultStatus = settings.Disable_Self_Guided_Learning__c;
        }
        return resultStatus;
    }
}