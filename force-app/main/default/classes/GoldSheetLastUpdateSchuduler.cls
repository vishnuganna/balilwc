public with sharing class GoldSheetLastUpdateSchuduler implements Schedulable {
    public void execute(SchedulableContext context) {
        GoldSheetLandingPageAction gsObj = new GoldSheetLandingPageAction();
        gsObj.processGoldSheetLastUpdate();
        gsObj.processGoldSheetActivityDueDate();
    }
}