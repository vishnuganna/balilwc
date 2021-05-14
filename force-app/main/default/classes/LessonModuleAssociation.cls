@SuppressWarnings('PMD.NcssMethodCount')
public with sharing class LessonModuleAssociation {
    public class ModuleWrapper {
        @AuraEnabled
        public String moduleTitle { get; set; }
        @AuraEnabled
        public String moduleDesc { get; set; }
        @AuraEnabled
        public String modulevideoLink { get; set; }
        @AuraEnabled
        public String moduleTime { get; set; }
        @AuraEnabled
        public String moduleStatus { get; set; }
        @AuraEnabled
        public String moduleRecordId { get; set; }
        @AuraEnabled
        public String moduleNameId { get; set; }
        @AuraEnabled
        public String moduleNumber { get; set; }
        @AuraEnabled
        public Boolean availBlueSheetButton { get; set; }
        @AuraEnabled
        public string moduleBluesheetProgress { get; set; }
        @AuraEnabled
        public string lessonRecId { get; set; }
    }

    public static Map<String, ModuleWrapper> getLessonModuleMap(String lessonName, List<Module__c> modules) {
        Map<String, ModuleWrapper> moduleLst;
        switch on lessonName {
            when 'Introduction' {
                moduleLst = new Map<String, ModuleWrapper>();
                for (module__c module : modules) {
                    ModuleWrapper module1Data = new ModuleWrapper();
                    module1Data.moduleStatus = module.Video_Progress__c;
                    module1Data.moduleNameId = module.Module_Name_Id__c;
                    module1Data.moduleRecordId = module.Id;
                    module1Data.availBlueSheetButton = false;
                    module1Data.lessonRecId = module.Lesson__c;
                    module1Data.moduleBluesheetProgress = module.Bluesheet_Progress_Track__c;
                    if (module.Module_Name_Id__c == 'Introduction_Module_1') {
                        module1Data.moduleTitle = System.Label.Introduction_Module_1_Title;
                        module1Data.moduleDesc = System.Label.Introduction_Module_1_Desc;
                        module1Data.moduleTime = System.Label.Introduction_Module_1_Time;
                        module1Data.modulevideoLink = system.Label.Introduction_Module_1_Url;
                        module1Data.moduleNumber = System.Label.Module1;
                        moduleLst.put('Module_1', module1Data);
                    }
                    if (module.Module_Name_Id__c == 'Introduction_Module_2') {
                        module1Data.moduleTitle = System.Label.Introduction_Module_2_Title;
                        module1Data.moduleDesc = System.Label.Introduction_Module_2_Desc;
                        module1Data.moduleTime = System.Label.Introduction_Module_2_Time;
                        module1Data.modulevideoLink = system.Label.Introduction_Module_2_Url;
                        module1Data.moduleNumber = System.Label.Module2;
                        moduleLst.put('Module_2', module1Data);
                    }
                    if (module.Module_Name_Id__c == 'Introduction_Module_3') {
                        module1Data.moduleTitle = System.Label.Introduction_Module_3_Title;
                        module1Data.moduleDesc = System.Label.Introduction_Module_3_Desc;
                        module1Data.moduleTime = System.Label.Introduction_Module_3_Time;
                        module1Data.modulevideoLink = system.Label.Introduction_Module_3_Url;
                        module1Data.moduleNumber = System.Label.Module3;
                        moduleLst.put('Module_3', module1Data);
                    }
                }
            }
            when 'Lesson_1' {
                moduleLst = new Map<String, ModuleWrapper>();
                for (module__c module : modules) {
                    ModuleWrapper module1Data = new ModuleWrapper();
                    module1Data.moduleStatus = module.Video_Progress__c;
                    module1Data.moduleNameId = module.Module_Name_Id__c;
                    module1Data.moduleRecordId = module.Id;
                    module1Data.availBlueSheetButton = false;
                    module1Data.lessonRecId = module.Lesson__c;
                    module1Data.moduleBluesheetProgress = module.Bluesheet_Progress_Track__c;
                    if (module.Module_Name_Id__c == 'Lesson_1_Module_1') {
                        module1Data.moduleTitle = System.Label.Lesson_1_Module_1_Title;
                        module1Data.moduleDesc = System.Label.Lesson_1_Module_1_Desc;
                        module1Data.moduleTime = System.Label.Lesson_1_Module_1_Time;
                        module1Data.modulevideoLink = System.Label.Lesson_1_Module_1_Url;
                        module1Data.moduleNumber = System.Label.Module1;
                        moduleLst.put('Module_1', module1Data);
                    }
                    if (module.Module_Name_Id__c == 'Lesson_1_Module_2') {
                        module1Data.moduleTitle = System.Label.Lesson_1_Module_2_Title;
                        module1Data.moduleDesc = System.Label.Lesson_1_Module_2_Desc;
                        module1Data.moduleTime = System.Label.Lesson_1_Module_2_Time;
                        module1Data.modulevideoLink = System.Label.Lesson_1_Module_2_Url;
                        module1Data.moduleNumber = System.Label.Module2;
                        moduleLst.put('Module_2', module1Data);
                    }
                    if (module.Module_Name_Id__c == 'Lesson_1_Module_3') {
                        module1Data.moduleTitle = System.Label.Lesson_1_Module_3_Title;
                        module1Data.moduleDesc = System.Label.Lesson_1_Module_3_Desc;
                        module1Data.moduleTime = System.Label.Lesson_1_Module_3_Time;
                        module1Data.modulevideoLink = System.Label.Lesson_1_Module_3_Url;
                        module1Data.moduleNumber = System.Label.Module3;
                        moduleLst.put('Module_3', module1Data);
                    }
                }
            }
            when 'Lesson_2' {
                moduleLst = new Map<String, ModuleWrapper>();
                for (module__c module : modules) {
                    ModuleWrapper module1Data = new ModuleWrapper();
                    module1Data.moduleStatus = module.Video_Progress__c;
                    module1Data.moduleNameId = module.Module_Name_Id__c;
                    module1Data.moduleRecordId = module.Id;
                    module1Data.availBlueSheetButton = false;
                    module1Data.lessonRecId = module.Lesson__c;
                    module1Data.moduleBluesheetProgress = module.Bluesheet_Progress_Track__c;
                    if (module.Module_Name_Id__c == 'Lesson_2_Module_1') {
                        module1Data.moduleTitle = System.Label.Lesson_2_Module_1_Title;
                        module1Data.moduleDesc = System.Label.Lesson_2_Module_1_Desc;
                        module1Data.moduleTime = System.Label.Lesson_2_Module_1_Time;
                        module1Data.modulevideoLink = System.Label.Lesson_2_Module_1_Url;
                        module1Data.moduleNumber = System.Label.Module1;
                        moduleLst.put('Module_1', module1Data);
                    }
                    if (module.Module_Name_Id__c == 'Lesson_2_Module_2') {
                        module1Data.moduleTitle = System.Label.Lesson_2_Module_2_Title;
                        module1Data.moduleDesc = System.Label.Lesson_2_Module_2_Desc;
                        module1Data.moduleTime = System.Label.Lesson_2_Module_2_Time;
                        module1Data.modulevideoLink = System.Label.Lesson_2_Module_2_Url;
                        module1Data.moduleNumber = System.Label.Module2;
                        moduleLst.put('Module_2', module1Data);
                    }
                }
            }
            when 'Lesson_3' {
                moduleLst = new Map<String, ModuleWrapper>();
                for (module__c module : modules) {
                    ModuleWrapper module1Data = new ModuleWrapper();
                    module1Data.moduleStatus = module.Video_Progress__c;
                    module1Data.moduleNameId = module.Module_Name_Id__c;
                    module1Data.moduleRecordId = module.Id;
                    module1Data.availBlueSheetButton = true;
                    module1Data.moduleBluesheetProgress = module.Bluesheet_Progress_Track__c;
                    module1Data.lessonRecId = module.Lesson__c;
                    if (module.Module_Name_Id__c == 'Lesson_3_Module_1') {
                        module1Data.moduleTitle = System.Label.Lesson_3_Module_1_Title;
                        module1Data.moduleDesc = System.Label.Lesson_3_Module_1_Desc;
                        module1Data.moduleTime = System.Label.Lesson_3_Module_1_Time;
                        module1Data.modulevideoLink = System.Label.Lesson_3_Module_1_Url;
                        module1Data.moduleNumber = System.Label.Module1;
                        moduleLst.put('Module_1', module1Data);
                    }
                    if (module.Module_Name_Id__c == 'Lesson_3_Module_2') {
                        module1Data.moduleTitle = System.Label.Lesson_3_Module_2_Title;
                        module1Data.moduleDesc = System.Label.Lesson_3_Module_2_Desc;
                        module1Data.moduleTime = System.Label.Lesson_3_Module_2_Time;
                        module1Data.modulevideoLink = System.Label.Lesson_3_Module_2_Url;
                        module1Data.moduleNumber = System.Label.Module2;
                        moduleLst.put('Module_2', module1Data);
                    }
                    if (module.Module_Name_Id__c == 'Lesson_3_Module_3') {
                        module1Data.moduleTitle = System.Label.Lesson_3_Module_3_Title;
                        module1Data.moduleDesc = System.Label.Lesson_3_Module_3_Desc;
                        module1Data.moduleTime = System.Label.Lesson_3_Module_3_Time;
                        module1Data.modulevideoLink = System.Label.Lesson_3_Module_3_Url;
                        module1Data.moduleNumber = System.Label.Module3;
                        moduleLst.put('Module_3', module1Data);
                    }
                    if (module.Module_Name_Id__c == 'Lesson_3_Module_4') {
                        module1Data.moduleTitle = System.Label.Lesson_3_Module_4_Title;
                        module1Data.moduleDesc = System.Label.Lesson_3_Module_4_Desc;
                        module1Data.moduleTime = System.Label.Lesson_3_Module_4_Time;
                        module1Data.modulevideoLink = System.Label.Lesson_3_Module_4_Url;
                        module1Data.moduleNumber = System.Label.Module4;
                        moduleLst.put('Module_4', module1Data);
                    }
                }
            }
            when 'Lesson_4' {
                moduleLst = new Map<String, ModuleWrapper>();
                for (module__c module : modules) {
                    ModuleWrapper module1Data = new ModuleWrapper();
                    module1Data.moduleStatus = module.Video_Progress__c;
                    module1Data.moduleNameId = module.Module_Name_Id__c;
                    module1Data.moduleRecordId = module.Id;
                    module1Data.moduleBluesheetProgress = module.Bluesheet_Progress_Track__c;
                    module1Data.lessonRecId = module.Lesson__c;
                    if (module.Module_Name_Id__c == 'Lesson_4_Module_1') {
                        module1Data.availBlueSheetButton = true;
                        module1Data.moduleTitle = System.Label.Lesson_4_Module_1_Title;
                        module1Data.moduleDesc = System.Label.Lesson_4_Module_1_Desc;
                        module1Data.moduleTime = System.Label.Lesson_4_Module_1_Time;
                        module1Data.modulevideoLink = System.Label.Lesson_4_Module_1_Url;
                        module1Data.moduleNumber = System.Label.Module1;
                        moduleLst.put('Module_1', module1Data);
                    }
                    if (module.Module_Name_Id__c == 'Lesson_4_Module_2') {
                        module1Data.availBlueSheetButton = true;
                        module1Data.moduleTitle = System.Label.Lesson_4_Module_2_Title;
                        module1Data.moduleDesc = System.Label.Lesson_4_Module_2_Desc;
                        module1Data.moduleTime = System.Label.Lesson_4_Module_2_Time;
                        module1Data.modulevideoLink = System.Label.Lesson_4_Module_2_Url;
                        module1Data.moduleNumber = System.Label.Module2;
                        moduleLst.put('Module_2', module1Data);
                    }
                    if (module.Module_Name_Id__c == 'Lesson_4_Module_3') {
                        module1Data.availBlueSheetButton = false;
                        module1Data.moduleTitle = System.Label.Lesson_4_Module_3_Title;
                        module1Data.moduleDesc = System.Label.Lesson_4_Module_3_Desc;
                        module1Data.moduleTime = System.Label.Lesson_4_Module_3_Time;
                        module1Data.modulevideoLink = System.Label.Lesson_4_Module_3_Url;
                        module1Data.moduleNumber = System.Label.Module3;
                        moduleLst.put('Module_3', module1Data);
                    }
                    if (module.Module_Name_Id__c == 'Lesson_4_Module_4') {
                        module1Data.availBlueSheetButton = true;
                        module1Data.moduleTitle = System.Label.Lesson_4_Module_4_Title;
                        module1Data.moduleDesc = System.Label.Lesson_4_Module_4_Desc;
                        module1Data.moduleTime = System.Label.Lesson_4_Module_4_Time;
                        module1Data.modulevideoLink = System.Label.Lesson_4_Module_4_Url;
                        module1Data.moduleNumber = System.Label.Module4;
                        moduleLst.put('Module_4', module1Data);
                    }
                }
            }
            when 'Lesson_5' {
                moduleLst = new Map<String, ModuleWrapper>();
                for (module__c module : modules) {
                    ModuleWrapper module1Data = new ModuleWrapper();
                    module1Data.moduleStatus = module.Video_Progress__c;
                    module1Data.moduleNameId = module.Module_Name_Id__c;
                    module1Data.moduleRecordId = module.Id;
                    module1Data.moduleBluesheetProgress = module.Bluesheet_Progress_Track__c;
                    module1Data.lessonRecId = module.Lesson__c;
                    if (module.Module_Name_Id__c == 'Lesson_5_Module_1') {
                        module1Data.availBlueSheetButton = true;
                        module1Data.moduleTitle = System.Label.Lesson_5_Module_1_Title;
                        module1Data.moduleDesc = System.Label.Lesson_5_Module_1_Desc;
                        module1Data.moduleTime = System.Label.Lesson_5_Module_1_Time;
                        module1Data.modulevideoLink = System.Label.Lesson_5_Module_1_Url;
                        module1Data.moduleNumber = System.Label.Module1;
                        moduleLst.put('Module_1', module1Data);
                    }
                    if (module.Module_Name_Id__c == 'Lesson_5_Module_2') {
                        module1Data.availBlueSheetButton = false;
                        module1Data.moduleTitle = System.Label.Lesson_5_Module_2_Title;
                        module1Data.moduleDesc = System.Label.Lesson_5_Module_2_Desc;
                        module1Data.moduleTime = System.Label.Lesson_5_Module_2_Time;
                        module1Data.modulevideoLink = System.Label.Lesson_5_Module_2_Url;
                        module1Data.moduleNumber = System.Label.Module2;
                        moduleLst.put('Module_2', module1Data);
                    }
                    if (module.Module_Name_Id__c == 'Lesson_5_Module_3') {
                        module1Data.availBlueSheetButton = true;
                        module1Data.moduleTitle = System.Label.Lesson_5_Module_3_Title;
                        module1Data.moduleDesc = System.Label.Lesson_5_Module_3_Desc;
                        module1Data.moduleTime = System.Label.Lesson_5_Module_3_Time;
                        module1Data.modulevideoLink = System.Label.Lesson_5_Module_3_Url;
                        module1Data.moduleNumber = System.Label.Module3;
                        moduleLst.put('Module_3', module1Data);
                    }
                    if (module.Module_Name_Id__c == 'Lesson_5_Module_4') {
                        module1Data.availBlueSheetButton = false;
                        module1Data.moduleTitle = System.Label.Lesson_5_Module_4_Title;
                        module1Data.moduleDesc = System.Label.Lesson_5_Module_4_Desc;
                        module1Data.moduleTime = System.Label.Lesson_5_Module_4_Time;
                        module1Data.modulevideoLink = System.Label.Lesson_5_Module_4_Url;
                        module1Data.moduleNumber = System.Label.Module4;
                        moduleLst.put('Module_4', module1Data);
                    }
                    if (module.Module_Name_Id__c == 'Lesson_5_Module_5') {
                        module1Data.availBlueSheetButton = true;
                        module1Data.moduleTitle = System.Label.Lesson_5_Module_5_Title;
                        module1Data.moduleDesc = System.Label.Lesson_5_Module_5_Desc;
                        module1Data.moduleTime = System.Label.Lesson_5_Module_5_Time;
                        module1Data.modulevideoLink = System.Label.Lesson_5_Module_5_Url;
                        module1Data.moduleNumber = System.Label.Module5;
                        moduleLst.put('Module_5', module1Data);
                    }
                }
            }
            when 'Lesson_6' {
                moduleLst = new Map<String, ModuleWrapper>();
                for (module__c module : modules) {
                    ModuleWrapper module1Data = new ModuleWrapper();
                    module1Data.moduleStatus = module.Video_Progress__c;
                    module1Data.moduleNameId = module.Module_Name_Id__c;
                    module1Data.moduleRecordId = module.Id;
                    module1Data.moduleBluesheetProgress = module.Bluesheet_Progress_Track__c;
                    module1Data.lessonRecId = module.Lesson__c;
                    if (module.Module_Name_Id__c == 'Lesson_6_Module_1') {
                        module1Data.availBlueSheetButton = true;
                        module1Data.moduleTitle = System.Label.Lesson_6_Module_1_Title;
                        module1Data.moduleDesc = System.Label.Lesson_6_Module_1_Desc;
                        module1Data.moduleTime = System.Label.Lesson_6_Module_1_Time;
                        module1Data.modulevideoLink = System.Label.Lesson_6_Module_1_Url;
                        module1Data.moduleNumber = System.Label.Module1;
                        moduleLst.put('Module_1', module1Data);
                    }
                }
            }
            when 'Lesson_7' {
                moduleLst = new Map<String, ModuleWrapper>();
                for (module__c module : modules) {
                    ModuleWrapper module1Data = new ModuleWrapper();
                    module1Data.moduleStatus = module.Video_Progress__c;
                    module1Data.moduleNameId = module.Module_Name_Id__c;
                    module1Data.moduleRecordId = module.Id;
                    module1Data.moduleBluesheetProgress = module.Bluesheet_Progress_Track__c;
                    module1Data.lessonRecId = module.Lesson__c;
                    if (module.Module_Name_Id__c == 'Lesson_7_Module_1') {
                        module1Data.availBlueSheetButton = false;
                        module1Data.moduleTitle = System.Label.Lesson_7_Module_1_Title;
                        module1Data.moduleDesc = System.Label.Lesson_7_Module_1_Desc;
                        module1Data.moduleTime = System.Label.Lesson_7_Module_1_Time;
                        module1Data.modulevideoLink = System.Label.Lesson_7_Module_1_Url;
                        module1Data.moduleNumber = System.Label.Module1;
                        moduleLst.put('Module_1', module1Data);
                    }
                    if (module.Module_Name_Id__c == 'Lesson_7_Module_2') {
                        module1Data.availBlueSheetButton = true;
                        module1Data.moduleTitle = System.Label.Lesson_7_Module_2_Title;
                        module1Data.moduleNumber = System.Label.Module2;
                        moduleLst.put('Module_2', module1Data);
                    }
                    if (module.Module_Name_Id__c == 'Lesson_7_Module_3') {
                        module1Data.availBlueSheetButton = true;
                        module1Data.moduleTitle = System.Label.Lesson_7_Module_3_Title;
                        module1Data.moduleNumber = System.Label.Module3;
                        moduleLst.put('Module_3', module1Data);
                    }
                    if (module.Module_Name_Id__c == 'Lesson_7_Module_4') {
                        module1Data.availBlueSheetButton = true;
                        module1Data.moduleTitle = System.Label.Lesson_7_Module_4_Title;
                        module1Data.moduleNumber = System.Label.Module4;
                        moduleLst.put('Module_4', module1Data);
                    }
                }
            }
            when 'Lesson_8' {
                moduleLst = new Map<String, ModuleWrapper>();
                for (module__c module : modules) {
                    ModuleWrapper module1Data = new ModuleWrapper();
                    module1Data.moduleStatus = module.Video_Progress__c;
                    module1Data.moduleNameId = module.Module_Name_Id__c;
                    module1Data.moduleRecordId = module.Id;
                    module1Data.availBlueSheetButton = false;
                    module1Data.lessonRecId = module.Lesson__c;
                    module1Data.moduleBluesheetProgress = module.Bluesheet_Progress_Track__c;
                    if (module.Module_Name_Id__c == 'Lesson_8_Module_1') {
                        module1Data.moduleTitle = System.Label.Lesson_8_Module_1_Title;
                        module1Data.moduleDesc = System.Label.Lesson_8_Module_1_Desc;
                        module1Data.moduleTime = System.Label.Lesson_8_Module_1_Time;
                        module1Data.modulevideoLink = System.Label.Lesson_8_Module_1_Url;
                        module1Data.moduleNumber = System.Label.Module1;
                        moduleLst.put('Module_1', module1Data);
                    }
                    if (module.Module_Name_Id__c == 'Lesson_8_Module_2') {
                        module1Data.moduleTitle = System.Label.Lesson_8_Module_2_Title;
                        module1Data.moduleDesc = System.Label.Lesson_8_Module_2_Desc;
                        module1Data.moduleTime = System.Label.Lesson_8_Module_2_Time;
                        module1Data.modulevideoLink = System.Label.Lesson_8_Module_2_Url;
                        module1Data.moduleNumber = System.Label.Module2;
                        moduleLst.put('Module_2', module1Data);
                    }
                }
            }
            when 'Lesson_9' {
                moduleLst = new Map<String, ModuleWrapper>();
                for (module__c module : modules) {
                    ModuleWrapper module1Data = new ModuleWrapper();
                    module1Data.moduleStatus = module.Video_Progress__c;
                    module1Data.moduleNameId = module.Module_Name_Id__c;
                    module1Data.moduleRecordId = module.Id;
                    module1Data.moduleBluesheetProgress = module.Bluesheet_Progress_Track__c;
                    module1Data.lessonRecId = module.Lesson__c;
                    if (module.Module_Name_Id__c == 'Lesson_9_Module_1') {
                        module1Data.availBlueSheetButton = true;
                        module1Data.moduleTitle = System.Label.Lesson_9_Module_1_Title;
                        module1Data.moduleDesc = System.Label.Lesson_9_Module_1_Desc;
                        module1Data.moduleTime = System.Label.Lesson_9_Module_1_Time;
                        module1Data.modulevideoLink = System.Label.Lesson_9_Module_1_Url;
                        module1Data.moduleNumber = System.Label.Module1;
                        moduleLst.put('Module_1', module1Data);
                    }
                    if (module.Module_Name_Id__c == 'Lesson_9_Module_2') {
                        module1Data.availBlueSheetButton = false;
                        module1Data.moduleTitle = System.Label.Lesson_9_Module_2_Title;
                        module1Data.moduleDesc = System.Label.Lesson_9_Module_2_Desc;
                        module1Data.moduleTime = System.Label.Lesson_9_Module_2_Time;
                        module1Data.modulevideoLink = System.Label.Lesson_9_Module_2_Url;
                        module1Data.moduleNumber = System.Label.Module2;
                        moduleLst.put('Module_2', module1Data);
                    }
                    if (module.Module_Name_Id__c == 'Lesson_9_Module_3') {
                        module1Data.availBlueSheetButton = true;
                        module1Data.moduleTitle = System.Label.Lesson_9_Module_3_Title;
                        module1Data.moduleDesc = System.Label.Lesson_9_Module_3_Desc;
                        module1Data.moduleTime = System.Label.Lesson_9_Module_3_Time;
                        module1Data.modulevideoLink = System.Label.Lesson_9_Module_3_Url;
                        module1Data.moduleNumber = System.Label.Module3;
                        moduleLst.put('Module_3', module1Data);
                    }
                }
            }
        }
        return moduleLst;
    }
}