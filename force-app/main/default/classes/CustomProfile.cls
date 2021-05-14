/*
KFS-429: This class is read standard profile records from org and insert/update/delete them in 'Custom Profile' custom object. It will always keep 'Custom Profile' custom object update to date with org standard profile records
*/
public with sharing class CustomProfile {
    public void copyStandardProfilestoCustomProfile() {
        List<Custom_profile__c> customProfileLstToInsert = new List<Custom_profile__c>();
        List<Custom_profile__c> customProfileLstToUpdate = new List<Custom_profile__c>();
        List<Custom_profile__c> customProfileLstToDelete = new List<Custom_profile__c>();
        List<Custom_profile__c> customProfileLst = getCustomProfileRecs();
        Map<String, Custom_profile__c> customProfileRecMap = new Map<String, Custom_profile__c>();
        Map<String, String> customProfileMap = new Map<String, String>();

        for (Custom_profile__c cprofileObj : customProfileLst) {
            customProfileMap.put(String.valueOf(cprofileObj.Profile_Id__c), cprofileObj.Name);
            customProfileRecMap.put(String.valueOf(cprofileObj.Profile_Id__c), cprofileObj);
        }

        Set<String> customProfileIdSet = customProfileMap.keySet();

        String soqlStandarProfile = 'Select Id,Name from Profile';

        Map<String, Object> parameters = new Map<String, Object>();
        List<Profile> standardProfileLst = DataFactory.read(soqlStandarProfile, parameters);
        Set<String> standardProfileIdSet = new Set<String>();
        for (Profile standardProfileObj : standardProfileLst) {
            standardProfileIdSet.add(standardProfileObj.Id);
            if (customProfileIdSet.contains(standardProfileObj.Id)) {
                /* standard profile found in custom profile.
                   Update name if required
                */
                String customProfileName = customProfileMap.get(standardProfileObj.Id);
                if (customProfileName != standardProfileObj.Name) {
                    Custom_profile__c customProfileRec = customProfileRecMap.get(standardProfileObj.Id);
                    customProfileRec.Name = standardProfileObj.Name;
                    customProfileLstToUpdate.add(customProfileRec);
                }
            } else {
                /* identify insert
                if both standard profile_id does not exists in Custom Profile, create Custom Profile record
                */
                Custom_profile__c customProfileRecCreate = new Custom_profile__c();
                customProfileRecCreate.Profile_Id__c = standardProfileObj.Id;
                customProfileRecCreate.Name = standardProfileObj.Name;
                customProfileLstToInsert.add(customProfileRecCreate);
            }
        }

        // Delete custom profile if standard profile is deleted.
        for (Custom_profile__c custoProfileDelete : customProfileLst) {
            if (!standardProfileIdSet.contains(custoProfileDelete.Profile_Id__c)) {
                customProfileLstToDelete.add(custoProfileDelete);
            }
        }

        if (!customProfileLstToInsert.isEmpty()) {
            DataFactory.create(customProfileLstToInsert);
        }

        if (!customProfileLstToUpdate.isEmpty()) {
            DataFactory.modify(customProfileLstToUpdate);
        }

        if (!customProfileLstToDelete.isEmpty()) {
            DataFactory.remove(customProfileLstToDelete);
        }
    }

    public List<Custom_profile__c> getCustomProfileRecs() {
        List<Custom_profile__c> customProfileLst = new List<Custom_profile__c>();
        String soqlProfile = 'Select Id, Name,Profile_Id__c from Custom_Profile__c';
        Map<String, Object> parameters = new Map<String, Object>();
        customProfileLst = DataFactory.read(soqlProfile, parameters);
        return customProfileLst;
    }
}