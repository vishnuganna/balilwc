public with sharing class RulesAdapter {
    public void executeRules(List<SObject> records, RulesEngineConfig.Scope scope) {
        if (Schema.sObjectType.Blue_Sheet__c.isUpdateable() || Schema.sObjectType.Green_Sheet__c.isUpdateable()) {
            if (records.isEmpty()) {
                return;
            }
            final set<String> objectIds = getObjectIds(records);

            RulesEngine.execute(objectIds, scope);
        }
    }

    private set<String> getObjectIds(List<SObject> records) {
        SObject rec = records.get(0);
        set<String> parentObjectIds = new Set<String>();

        switch on rec {
            when Action_plan__c a {
                parentObjectIds = getParentIdsFromActionPlan(records);
            }
            when Blue_Sheet__c b {
                parentObjectIds = getbluesheetIds(records);
            }
            when Opportunity o {
                parentObjectIds = getOptyIds(records);
            }
            when Competition__c c {
                parentObjectIds = getParentIdsFromCompetition(records);
            }
            when Score_Card__c s {
                parentObjectIds = getParentIdsFromScoreCard(records);
            }
            when Current_Position__c crr {
                parentObjectIds = getParentIdsFromCurrentPosition(records);
            }
            when Single_sales_Objective__c sso {
                parentObjectIds = getParentIdsFromSSO(records);
            }
            when Buying_Influence__c bi {
                parentObjectIds = getParentIdsFromBuyingInfluence(records);
            }
            when Green_Sheet__c gs {
                parentObjectIds = getGreenSheetIds(records);
            }
            when Green_Sheet_Buying_Influence__c gsBI {
                parentObjectIds = getGreenSheetBIds(records);
            }
            when Getting_Commitment__c com {
                parentObjectIds = getGreenSheetCommitmentIds(records);
            }
        }
        return parentObjectIds;
    }
    private set<String> getbluesheetIds(List<Sobject> records) {
        set<String> objectIds = new Set<String>();
        List<Blue_Sheet__c> blueSheets = records;
        for (Blue_Sheet__c blueSheet : blueSheets) {
            objectIds.add(String.valueOf(blueSheet.Id));
        }

        return objectIds;
    }
    private set<String> getOptyIds(List<Sobject> records) {
        set<String> objectIds = new Set<String>();
        List<Opportunity> opportunities = records;
        for (Opportunity opty : opportunities) {
            objectIds.add(String.valueOf(opty.Id));
        }
        return objectIds;
    }
    private set<String> getParentIdsFromActionPlan(List<SObject> records) {
        set<String> objectIds = new Set<String>();
        List<Action_plan__c> actionPlans = records;
        for (Action_plan__c plan : actionPlans) {
            objectIds.add(String.valueOf(plan.Blue_Sheet__c));
        }
        return objectIds;
    }
    private set<String> getParentIdsFromCompetition(List<SObject> records) {
        set<String> objectIds = new Set<String>();
        List<Competition__c> competitions = records;
        for (Competition__c comp : competitions) {
            objectIds.add(String.valueOf(comp.Blue_Sheet__c));
        }
        return objectIds;
    }
    private set<String> getParentIdsFromCurrentPosition(List<SObject> records) {
        set<String> objectIds = new Set<String>();
        List<Current_Position__c> positions = records;
        for (Current_Position__c cp : positions) {
            objectIds.add(String.valueOf(cp.Blue_Sheet__c));
        }
        return objectIds;
    }
    private set<String> getParentIdsFromSSO(List<SObject> records) {
        set<String> objectIds = new Set<String>();
        List<Single_sales_Objective__c> ssoList = records;
        for (Single_sales_Objective__c sso : ssoList) {
            objectIds.add(String.valueOf(sso.Blue_Sheet__c));
        }
        return objectIds;
    }
    private set<String> getParentIdsFromBuyingInfluence(List<SObject> records) {
        set<String> objectIds = new Set<String>();
        List<Buying_Influence__c> buyingInfluences = records;
        for (Buying_Influence__c bi : buyingInfluences) {
            objectIds.add(String.valueOf(bi.Blue_Sheet__c));
        }
        return objectIds;
    }
    private set<String> getParentIdsFromScoreCard(List<SObject> records) {
        set<String> objectIds = new Set<String>();
        List<Score_Card__c> scoreCards = records;
        for (Score_Card__c card : scoreCards) {
            objectIds.add(String.valueOf(card.Blue_Sheet__c));
        }
        return objectIds;
    }
    private set<String> getGreenSheetIds(List<SObject> records) {
        set<String> objectIds = new Set<String>();
        List<Green_Sheet__c> greenSheets = records;
        for (Green_Sheet__c greenSheet : greenSheets) {
            objectIds.add(String.valueOf(greenSheet.Id));
        }
        return objectIds;
    }
    private set<String> getGreenSheetBIds(List<SObject> records) {
        set<String> objectIds = new Set<String>();
        List<Green_Sheet_Buying_Influence__c> greenSheetBIs = records;
        for (Green_Sheet_Buying_Influence__c greenSheetBI : greenSheetBIs) {
            objectIds.add(String.valueOf(greenSheetBI.Green_Sheet__c));
        }
        return objectIds;
    }
    private set<String> getGreenSheetCommitmentIds(List<SObject> records) {
        set<String> objectIds = new Set<String>();
        List<Getting_Commitment__c> commitments = records;
        for (Getting_Commitment__c com : commitments) {
            objectIds.add(String.valueOf(com.Green_Sheet__c));
        }
        return objectIds;
    }
}