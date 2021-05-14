public with sharing class ModuleController {
    @AuraEnabled
    public static LessonModuleAssociation.ModuleWrapper updateModules(String inputData, String lessonRecId) {
        LessonModuleAssociation.ModuleWrapper wrapper = (LessonModuleAssociation.ModuleWrapper) System.JSON.deserialize(
            inputData,
            LessonModuleAssociation.ModuleWrapper.class
        );
        List<Module__c> moduleListToUpdate = new List<Module__c>();
        Module__c moduleRec = new Module__c();
        if (wrapper.moduleRecordId != null) {
            moduleRec.Id = wrapper.moduleRecordId;
            if (wrapper.moduleStatus != null) {
                moduleRec.Video_Progress__c = wrapper.moduleStatus;
            }
            moduleRec.Bluesheet_Progress_Track__c = wrapper.moduleBluesheetProgress;
            moduleListToUpdate.add(moduleRec);
        }
        if (!moduleListToUpdate.isEmpty()) {
            DataFactory.modify(moduleListToUpdate);
        }
        if (lessonRecId != null) {
            String query = 'SELECT Id,Name,Lesson_Progress_Status__c FROM Lesson__c WHERE Id=:lessonRecId';
            Map<String, Object> params = new Map<String, Object>();
            params.put('lessonRecId', lessonRecId);
            List<Lesson__c> lessonList = DataFactory.read(query, params);
            List<Lesson__c> lessonListToUpdate = new List<Lesson__c>();
            for (Lesson__c lesson : lessonList) {
                if (lesson.Lesson_Progress_Status__c != 'Resume' && lesson.Lesson_Progress_Status__c != 'Viewed') {
                    lesson.Lesson_Progress_Status__c = 'Resume';
                    lessonListToUpdate.add(lesson);
                }
            }
            if (!lessonListToUpdate.isEmpty()) {
                DataFactory.modify(lessonListToUpdate);
            }
        }
        LessonModuleAssociation.ModuleWrapper wrapperToReturn = getModuleData(wrapper.moduleRecordId);

        return wrapperToReturn;
    }

    private static LessonModuleAssociation.ModuleWrapper getModuleData(String recId) {
        String query = 'SELECT Id,Name,Video_Progress__c,Module_Name_Id__c,Bluesheet_Progress_Track__c FROM Module__c WHERE Id =:recId';
        Map<String, Object> parmters = new Map<String, Object>();
        parmters.put('recId', recId);
        List<Module__c> moduleList = DataFactory.read(query, parmters);
        LessonModuleAssociation.ModuleWrapper wrapper = new LessonModuleAssociation.ModuleWrapper();
        if (!moduleList.isEmpty()) {
            wrapper.moduleRecordId = moduleList[0].Id;
            wrapper.moduleNameId = moduleList[0].Module_Name_Id__c;
            wrapper.moduleStatus = moduleList[0].Video_Progress__c;
            wrapper.moduleBluesheetProgress = moduleList[0].Bluesheet_Progress_Track__c;
        }
        return wrapper;
    }

    @AuraEnabled
    public static Map<String, String> moduleStatusMap(String lessonId) {
        Map<String, String> moduleWithStatusMap = new Map<String, String>();
        String query = 'SELECT Id,Lesson__c,Module_Name_Id__c,Video_Progress__c FROM Module__c WHERE Lesson__c =:lessonId';
        Map<String, Object> parmters = new Map<String, Object>();
        parmters.put('lessonId', lessonId);
        List<Module__c> moduleList = DataFactory.read(query, parmters);
        for (Module__c module : moduleList) {
            moduleWithStatusMap.put(module.Module_Name_Id__c, module.Video_Progress__c);
        }
        return moduleWithStatusMap;
    }

    @AuraEnabled
    public static Map<String, String> moduleIdNameMap(String lessonId) {
        Map<String, String> moduleIdWithNameMap = new Map<String, String>();
        String query = 'SELECT Id,Lesson__c,Module_Name_Id__c FROM Module__c WHERE Lesson__c =:lessonId ORDER BY Module_Name_Id__c ASC';
        Map<String, Object> parmters = new Map<String, Object>();
        parmters.put('lessonId', lessonId);
        List<Module__c> moduleList = DataFactory.read(query, parmters);
        for (Module__c module : moduleList) {
            moduleIdWithNameMap.put(module.Module_Name_Id__c, module.Id);
        }
        return moduleIdWithNameMap;
    }
}