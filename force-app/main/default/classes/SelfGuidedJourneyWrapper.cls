public with sharing class SelfGuidedJourneyWrapper {
    @AuraEnabled
    public String id { get; set; }
    @AuraEnabled
    public String sgjStatus { get; set; }
    @AuraEnabled
    public List<LessonsWrapper> lessons { get; set; }
    @AuraEnabled
    public Map<String, LessonModuleAssociation.ModuleWrapper> lessonModules { get; set; }

    public SelfGuidedJourneyWrapper(Self_Guided_Journey__c sgj) {
        this.id = sgj.Id;
        this.sgjStatus = sgj.Progress_Status__c;
        this.lessons = new List<LessonsWrapper>();
        this.lessonModules = new Map<String, LessonModuleAssociation.ModuleWrapper>();
    }
}