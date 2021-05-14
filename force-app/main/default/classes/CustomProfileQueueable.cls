public with sharing class CustomProfileQueueable implements Queueable {
    public void execute(QueueableContext context) {
        CustomProfile cp = new CustomProfile();
        cp.copyStandardProfilestoCustomProfile();
    }
}