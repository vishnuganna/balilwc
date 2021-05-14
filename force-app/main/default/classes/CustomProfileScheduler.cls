/*
Job to Keep 'Custom Profile'(Used in Business Rules Group Member table) table in sync with organization's Profiles
*/
public with sharing class CustomProfileScheduler implements Schedulable {
    public void execute(SchedulableContext context) {
        CustomProfile cp = new CustomProfile();
        cp.copyStandardProfilestoCustomProfile();
    }
}