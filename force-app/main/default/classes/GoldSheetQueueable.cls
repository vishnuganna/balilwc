public with sharing class GoldSheetQueueable implements Queueable {
    public void execute(QueueableContext context) {
        GoldSheetLandingPageAction gsObj = new GoldSheetLandingPageAction();
        gsObj.processGoldSheetLastUpdate();
        gsObj.processGoldSheetActivityDueDate();
    }
}