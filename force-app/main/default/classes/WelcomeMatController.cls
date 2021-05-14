/**
 * Methods to retrieve and update users welcome mat setting
 */
public with sharing class WelcomeMatController {
    /**
     * Gets current users welcome mat setting
     *
     * @return true / false based on user setting
     */
    @AuraEnabled
    public static Boolean getHideWelcomeMat() {
        User user = getUser();
        return (user == null) ? false : user.Hide_KF_Sell_Welcome_Mat__c;
    }

    /**
     * Updates user welcome mat setting
     *
     * @param hideWelcomeMat new welcome mat setting
     */
    @AuraEnabled
    public static void updateWelcomeMatSetting(Boolean hideWelcomeMat) {
        User user = getUser();
        // only update if changed
        if (user.Hide_KF_Sell_Welcome_Mat__c != hideWelcomeMat) {
            user.Hide_KF_Sell_Welcome_Mat__c = hideWelcomeMat;
            DataFactory.modify(user);
        }
    }

    /**
     * Helper to get user by ID
     *
     * @return found user or NULL
     */
    private static User getUser() {
        Map<String, Object> params = new Map<String, Object>();
        params.put('userId', UserInfo.getUserId());
        List<User> users = DataFactory.read('SELECT Hide_KF_Sell_Welcome_Mat__c FROM User WHERE Id = :userId', params);
        return (users.isEmpty()) ? null : users.get(0);
    }
}