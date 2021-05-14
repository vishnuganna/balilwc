/**
 * Holds methods to generate links to external applications
 */
public with sharing class ExternalLinks {
    /**
     * Build / return link with JWT for KF Learn
     * @return PageReference for KF Learn
     */
    @AuraEnabled
    public static String getKFLearnUrl() {
        // URL string
        String url = 'none';
        KF_Learn_API_Key__mdt[] apiKeys;

        // get KF learn config from meta data
        String configQuery =
            'SELECT QualifiedApiName, License_ID__c, Client_ID__c, Profile__c, URL__c, Environment__c ' +
            'FROM KF_Learn_Config__mdt';
        Map<String, Object> paramters = new Map<String, Object>();
        KF_Learn_Config__mdt[] configs = DataFactory.read(configQuery, paramters);

        if (configs.size() > 0) {
            KF_Learn_Config__mdt configMdt = configs[0];
            if (configMdt.Environment__c == null) {
                return url;
            }
            String environmentVar = configMdt.Environment__c;
            environmentVar = util.getNamespaceWithUnderScores() == ''
                ? environmentVar
                : util.getNamespaceWithUnderScores() + environmentVar;

            // Get API key
            String apiKeyQuery = 'SELECT API_Key__c FROM KF_Learn_API_Key__mdt where QualifiedApiName = :environment';
            Map<String, Object> apiKeyparamters = new Map<String, Object>();
            apiKeyparamters.put('environment', environmentVar);
            apiKeys = DataFactory.read(apiKeyQuery, apiKeyparamters);
        }
        if (apiKeys.size() > 0 && configs.size() > 0) {
            // get the first data element, for now
            KF_Learn_API_Key__mdt apiKey = apiKeys[0];
            KF_Learn_Config__mdt config = configs[0];

            //ensure we have a license and client ID
            if (apiKey.API_Key__c == null || config.License_ID__c == null || config.Client_ID__c == null) {
                return url;
            }

            //build / issue JWT
            JWT jwt = new JWT.JWTBuilder()
                .setAlgorithm('HS256')
                .setProperty('firstName', UserInfo.getFirstName())
                .setProperty('lastName', UserInfo.getLastName())
                .setProperty('email', UserInfo.getUserName())
                .setProperty('studentLicenseIds', config.License_ID__c)
                .setProperty('clientId', config.Client_ID__c)
                .setPrivateKey(apiKey.API_Key__c)
                .build();
            url = config.URL__c + '/access/jwt?jwt=' + jwt.issue();
        }
        return url;
    }
}