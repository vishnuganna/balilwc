@SuppressWarnings('PMD.NcssMethodCount,PMD.NcssTypeCount,PMD.NcssConstructorCount')
public with sharing class LessonsWrapper {
    @AuraEnabled
    public String sgjId { get; set; }
    @AuraEnabled
    public String lessonNameId { get; set; }
    @AuraEnabled
    public String lessonStatus { get; set; }
    @AuraEnabled
    public String lessonTitle { get; set; }
    @AuraEnabled
    public String lessonShortDesc { get; set; }
    @AuraEnabled
    public String lessonLongDesc { get; set; }
    @AuraEnabled
    public String lessonTime { get; set; }
    @AuraEnabled
    public String lessonRecordId { get; set; }
    @AuraEnabled
    public boolean showPopup { get; set; }
    @AuraEnabled
    public Map<String, LessonModuleAssociation.ModuleWrapper> lessonModules { get; set; }

    public LessonsWrapper(Lesson__c lesson, Map<String, List<Module__c>> lessonModuleMap) {
        this.lessonNameId = lesson.Lesson_Name_Id__c;
        this.sgjId = lesson.Self_Guided_Journey__c;
        switch on lessonNameId {
            when 'Introduction' {
                this.lessonStatus = lesson.Lesson_Progress_Status__c;
                this.showPopup = false;
                this.lessonTitle = System.Label.Introduction_Title;
                this.lessonShortDesc = System.Label.Introduction_ShortDesc;
                this.lessonLongDesc = System.Label.Introduction_LongDesc;
                this.lessonTime = System.Label.Introduction_Time;
                if (lessonModuleMap != null && lessonModuleMap.containsKey('Introduction')) {
                    this.lessonModules = LessonModuleAssociation.getLessonModuleMap(
                        lessonNameId,
                        lessonModuleMap.get('Introduction')
                    );
                }
                this.lessonRecordId = lesson.Id;
            }
            when 'Lesson_1' {
                this.lessonStatus = lesson.Lesson_Progress_Status__c;
                this.showPopup = false;
                this.lessonTitle = System.Label.Lesson_1_Title;
                this.lessonShortDesc = System.Label.Lesson_1_ShortDesc;
                this.lessonLongDesc = System.Label.Lesson_1_LongDesc;
                this.lessonTime = System.Label.Lesson_1_Time;
                if (lessonModuleMap != null && lessonModuleMap.containsKey('Lesson_1')) {
                    this.lessonModules = LessonModuleAssociation.getLessonModuleMap(
                        lessonNameId,
                        lessonModuleMap.get('Lesson_1')
                    );
                }
                this.lessonRecordId = lesson.Id;
            }
            when 'Lesson_2' {
                this.lessonStatus = lesson.Lesson_Progress_Status__c;
                this.showPopup = false;
                this.lessonTitle = System.Label.Lesson_2_Title;
                this.lessonShortDesc = System.Label.Lesson_2_ShortDesc;
                this.lessonLongDesc = System.Label.Lesson_2_LongDesc;
                this.lessonTime = System.Label.Lesson_2_Time;
                if (lessonModuleMap != null && lessonModuleMap.containsKey('Lesson_2')) {
                    this.lessonModules = LessonModuleAssociation.getLessonModuleMap(
                        lessonNameId,
                        lessonModuleMap.get('Lesson_2')
                    );
                }
                this.lessonRecordId = lesson.Id;
            }
            when 'Lesson_3' {
                this.lessonStatus = lesson.Lesson_Progress_Status__c;
                this.showPopup = false;
                this.lessonTitle = System.Label.Lesson_3_Title;
                this.lessonShortDesc = System.Label.Lesson_3_ShortDesc;
                this.lessonLongDesc = System.Label.Lesson_3_LongDesc;
                this.lessonTime = System.Label.Lesson_3_Time;
                if (lessonModuleMap != null && lessonModuleMap.containsKey('Lesson_3')) {
                    this.lessonModules = LessonModuleAssociation.getLessonModuleMap(
                        lessonNameId,
                        lessonModuleMap.get('Lesson_3')
                    );
                }
                this.lessonRecordId = lesson.Id;
            }
            when 'Lesson_4' {
                this.lessonStatus = lesson.Lesson_Progress_Status__c;
                this.showPopup = false;
                this.lessonTitle = System.Label.Lesson_4_Title;
                this.lessonShortDesc = System.Label.Lesson_4_ShortDesc;
                this.lessonLongDesc = System.Label.Lesson_4_LongDesc;
                this.lessonTime = System.Label.Lesson_4_Time;
                if (lessonModuleMap != null && lessonModuleMap.containsKey('Lesson_4')) {
                    this.lessonModules = LessonModuleAssociation.getLessonModuleMap(
                        lessonNameId,
                        lessonModuleMap.get('Lesson_4')
                    );
                }
                this.lessonRecordId = lesson.Id;
            }
            when 'Lesson_5' {
                this.lessonStatus = lesson.Lesson_Progress_Status__c;
                this.showPopup = false;
                this.lessonTitle = System.Label.Lesson_5_Title;
                this.lessonShortDesc = System.Label.Lesson_5_ShortDesc;
                this.lessonLongDesc = System.Label.Lesson_5_LongDesc;
                this.lessonTime = System.Label.Lesson_5_Time;
                if (lessonModuleMap != null && lessonModuleMap.containsKey('Lesson_5')) {
                    this.lessonModules = LessonModuleAssociation.getLessonModuleMap(
                        lessonNameId,
                        lessonModuleMap.get('Lesson_5')
                    );
                }
                this.lessonRecordId = lesson.Id;
            }
            when 'Lesson_6' {
                this.lessonStatus = lesson.Lesson_Progress_Status__c;
                this.showPopup = false;
                this.lessonTitle = System.Label.Lesson_6_Title;
                this.lessonShortDesc = System.Label.Lesson_6_ShortDesc;
                this.lessonLongDesc = System.Label.Lesson_6_LongDesc;
                this.lessonTime = System.Label.Lesson_6_Time;
                if (lessonModuleMap != null && lessonModuleMap.containsKey('Lesson_6')) {
                    this.lessonModules = LessonModuleAssociation.getLessonModuleMap(
                        lessonNameId,
                        lessonModuleMap.get('Lesson_6')
                    );
                }
                this.lessonRecordId = lesson.Id;
            }
            when 'Lesson_7' {
                this.lessonStatus = lesson.Lesson_Progress_Status__c;
                this.showPopup = false;
                this.lessonTitle = System.Label.Lesson_7_Title;
                this.lessonShortDesc = System.Label.Lesson_7_ShortDesc;
                this.lessonLongDesc = System.Label.Lesson_7_LongDesc;
                this.lessonTime = System.Label.Lesson_7_Time;
                if (lessonModuleMap != null && lessonModuleMap.containsKey('Lesson_7')) {
                    this.lessonModules = LessonModuleAssociation.getLessonModuleMap(
                        lessonNameId,
                        lessonModuleMap.get('Lesson_7')
                    );
                }
                this.lessonRecordId = lesson.Id;
            }
            when 'Lesson_8' {
                this.lessonStatus = lesson.Lesson_Progress_Status__c;
                this.showPopup = false;
                this.lessonTitle = System.Label.Lesson_8_Title;
                this.lessonShortDesc = System.Label.Lesson_8_ShortDesc;
                this.lessonLongDesc = System.Label.Lesson_8_LongDesc;
                this.lessonTime = System.Label.Lesson_8_Time;
                if (lessonModuleMap != null && lessonModuleMap.containsKey('Lesson_8')) {
                    this.lessonModules = LessonModuleAssociation.getLessonModuleMap(
                        lessonNameId,
                        lessonModuleMap.get('Lesson_8')
                    );
                }
                this.lessonRecordId = lesson.Id;
            }
            when 'Lesson_9' {
                this.lessonStatus = lesson.Lesson_Progress_Status__c;
                this.showPopup = false;
                this.lessonTitle = System.Label.Lesson_9_Title;
                this.lessonShortDesc = System.Label.Lesson_9_ShortDesc;
                this.lessonLongDesc = System.Label.Lesson_9_LongDesc;
                this.lessonTime = System.Label.Lesson_9_Time;
                if (lessonModuleMap != null && lessonModuleMap.containsKey('Lesson_9')) {
                    this.lessonModules = LessonModuleAssociation.getLessonModuleMap(
                        lessonNameId,
                        lessonModuleMap.get('Lesson_9')
                    );
                }
                this.lessonRecordId = lesson.Id;
            }
        }
    }
}