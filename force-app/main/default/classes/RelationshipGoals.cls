public with sharing class RelationshipGoals {
    //Method to fetch data from relationshipgoal  and show it on UI under  relationshipgoal  section of gold sheet
    @AuraEnabled
    public static List<RelationshipGoalsWrapper> getRelationshipGoal(string goldsheetId, String sortFilter) {
        List<Relationship_Goal__c> listRelationshipGoal = new List<Relationship_Goal__c>();
        Boolean isUpdatable;
        List<RelatedActivitiesWrapper> relatedActivitiesWrapperList = new List<RelatedActivitiesWrapper>();
        List<RelationshipGoalsWrapper> relationshipGoalWrapperListToReturn = new List<RelationshipGoalsWrapper>();
        try {
            //formation of query
            String relationshipGoalQuery;
            if (sortFilter == 'Complete') {
                relationshipGoalQuery =
                    ' Select Id,Name,CreatedDate,Goal_Status__c,Fields_of_Play_Gold_Sheet__c' +
                    ' ,Description__c, Goal_Name__c' +
                    ' FROM Relationship_Goal__c Where Fields_of_Play_Gold_Sheet__c =:goldsheetId Order By Goal_Status__c Desc,createdDate Desc';
            } else if (sortFilter == 'Incomplete') {
                relationshipGoalQuery =
                    ' Select Id,Name,CreatedDate,Goal_Status__c,Fields_of_Play_Gold_Sheet__c' +
                    ' ,Description__c, Goal_Name__c' +
                    ' FROM Relationship_Goal__c Where Fields_of_Play_Gold_Sheet__c =:goldsheetId Order By Goal_Status__c Asc,createdDate Desc';
            } else {
                relationshipGoalQuery =
                    ' Select Id,Name,CreatedDate,Goal_Status__c,Fields_of_Play_Gold_Sheet__c' +
                    ' ,Description__c, Goal_Name__c' +
                    ' FROM Relationship_Goal__c Where Fields_of_Play_Gold_Sheet__c =:goldsheetId Order By createdDate Desc';
            }
            Map<String, Object> paramters = new Map<String, Object>();
            paramters.put('goldsheetId', goldsheetId);
            //get data from cometition section
            listRelationshipGoal = DataFactory.read(relationshipGoalQuery, paramters);
            //iterate through list to get list of wrapper to return to UI
            Set<String> goalIdSet = new Set<String>();
            Map<String, Relationship_Goal__c> mapRelationshipGoal = new Map<String, Relationship_Goal__c>();
            for (Relationship_Goal__c relationshipGoal : listRelationshipGoal) {
                goalIdSet.add(relationshipGoal.Id);
                mapRelationshipGoal.put(relationshipGoal.Id, relationshipGoal);
            }
            Set<String> relatedActivityIdSet = new Set<String>();
            List<RelatedActivitiesWrapper> relatedActivityWrap = getRelatedActivity(goalIdSet);
            for (RelatedActivitiesWrapper raWrap : relatedActivityWrap) {
                relatedActivityIdSet.add(raWrap.Id);
            }

            String raQuery = 'Select Id, Relationship_Goal__c from Related_Activities__c where Id =: relatedActivityIdSet';
            Map<String, String> mapRelatedActAndRGoalId = new Map<String, String>();
            Map<String, Object> raparamters = new Map<String, Object>();
            raparamters.put('relatedActivityIdSet', relatedActivityIdSet);
            List<Related_Activities__c> raLst = DataFactory.read(raQuery, raparamters);
            for (Related_Activities__c raObj : raLst) {
                mapRelatedActAndRGoalId.put(raObj.Id, raObj.Relationship_Goal__c);
            }

            Map<String, List<RelatedActivitiesWrapper>> mapRGidAndRActivity = new Map<String, List<RelatedActivitiesWrapper>>();
            for (RelatedActivitiesWrapper raWrap : relatedActivityWrap) {
                String relationshipGoalId = mapRelatedActAndRGoalId.get(raWrap.Id);
                Relationship_Goal__c relationshipGoal = mapRelationshipGoal.get(relationshipGoalId);
                if (mapRGidAndRActivity.containsKey(relationshipGoalId)) {
                    List<RelatedActivitiesWrapper> raWrapLst = mapRGidAndRActivity.get(relationshipGoalId);
                    raWrapLst.add(raWrap);
                    mapRGidAndRActivity.put(relationshipGoalId, raWrapLst);
                } else {
                    List<RelatedActivitiesWrapper> raWrapLst = new List<RelatedActivitiesWrapper>();
                    raWrapLst.add(raWrap);
                    mapRGidAndRActivity.put(relationshipGoalId, raWrapLst);
                }
            }

            for (Relationship_Goal__c relationshipGoal : listRelationshipGoal) {
                RelationshipGoalsWrapper rgWrapper = new RelationshipGoalsWrapper(relationshipGoal, isUpdatable);
                rgWrapper.relatedActivitiesWrapper = mapRGidAndRActivity.get(relationshipGoal.Id);
                relationshipGoalWrapperListToReturn.add(rgWrapper);
            }
            /*for (Relationship_Goal__c relationshipGoal : listRelationshipGoal) {
                RelationshipGoalsWrapper wrapper = new RelationshipGoalsWrapper(relationshipGoal, isUpdatable);
                String goalId = relationshipGoal.Id;
                wrapper.relatedActivitiesWrapper = getRelatedActivity(goalId);
                relationshipGoalWrapperListToReturn.add(wrapper);
            }*/
        } catch (Exception ex) {
            throw new relationshipGoalException('Error occured while getting data from relationshipGoal');
        }
        //return list of wrapper containing all relationshipGoal data

        return relationshipGoalWrapperListToReturn;
    }

    @AuraEnabled
    public static void upsertRelationshipGoal(String relationshipGoalObject, String relatedActivityObject) {
        List<Relationship_Goal__c> listRelationshipGoal = new List<Relationship_Goal__c>();
        RelationshipGoalsWrapper relationshipGoalWrapper = (RelationshipGoalsWrapper) JSON.deserialize(
            relationshipGoalObject,
            RelationshipGoalsWrapper.class
        );
        String goldSheetId = relationshipGoalWrapper.goldsheetId;
        if (goldSheetId != null) {
            Relationship_Goal__c relationShipGoal = new Relationship_Goal__c();
            if (relationshipGoalWrapper.id != null) {
                relationShipGoal.Id = relationshipGoalWrapper.id;
            }
            relationShipGoal.Fields_of_Play_Gold_Sheet__c = goldsheetId;
            relationShipGoal.Goal_Name__c = relationshipGoalWrapper.goalName;
            relationShipGoal.Description__c = relationshipGoalWrapper.description;
            relationShipGoal.Goal_Status__c = relationshipGoalWrapper.goalStatus;
            listRelationshipGoal.add(relationShipGoal);
        }
        Database.UpsertResult[] urList = DataFactory.upsurt(listRelationshipGoal);

        if (relationshipGoalWrapper.id != null) {
            String goalId = relationshipGoalWrapper.id;
            if (relatedActivityObject != null) {
                upsertRelatedActivity(relatedActivityObject, goalId);
            }
        } else if (urList.size() > 0 && urList[0].isSuccess()) {
            if (urList[0].getId() != null) {
                String goalId = urList[0].getId();
                upsertRelatedActivity(relatedActivityObject, goalId);
            }
        }
    }

    @AuraEnabled
    public static void deleteRelationshipGoal(String recordId) {
        String query = 'SELECT Id from Relationship_Goal__c WHERE Id=:recordId';

        map<String, Object> params = new Map<String, Object>();
        params.put('recordId', recordId);
        List<Relationship_Goal__c> relationshipGoalRec = DataFactory.read(query, params);

        DataFactory.remove(relationshipGoalRec);
    }

    private static void removeRelatedActivities(List<String> activityIds) {
        String query = 'SELECT Id from Related_Activities__c WHERE Id in :activityIds';
        Map<String, Object> paramters = new Map<String, Object>();
        paramters.put('activityIds', activityIds);
        List<Related_Activities__c> relatedActivities = DataFactory.read(query, paramters);
        DataFactory.remove(relatedActivities);
    }

    @AuraEnabled(cacheable=true)
    public static String getGoalStatusPicklistValues() {
        map<string, string> options = new Map<string, string>();
        //List<String>
        Schema.DescribeFieldResult fieldResult = Relationship_Goal__c.Goal_Status__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

        for (Schema.PicklistEntry f : ple) {
            options.put(f.getValue(), f.getLabel());
        }
        return JSON.serialize(options);
    }

    private class relationshipGoalException extends Exception {
    }
    public class wrapperLookupObject {
        @AuraEnabled
        public String lookupOnObject;
        @AuraEnabled
        public String targetField;
    }

    /**
     * Method to insert relationshipGoal in bulk
     *
     * @param relationshipGoals JSON array of relationshipGoals
     */
    @AuraEnabled
    public static void insertRelationshipGoals(final String relationshipGoalObjects) {
        // get top level array / list
        List<Object> data = (List<Object>) JSON.deserializeUntyped(relationshipGoalObjects);
        // only continue if we have data
        if (data.isEmpty()) {
            return;
        }
        // build list of new relationshipGoals
        List<Relationship_Goal__c> newGoals = new List<Relationship_Goal__c>();
        for (Object item : data) {
            Relationship_Goal__c newRG = new Relationship_Goal__c();
            Map<String, Object> rgData = (Map<String, Object>) item;
            newRG.Fields_of_Play_Gold_Sheet__c = (String) rgData.get('GoldsheetId');
            newRG.Goal_Name__c = (String) rgData.get('goalName');
            newRG.Description__c = (String) rgData.get('Description');
            newRG.Goal_Status__c = (String) rgData.get('goalStatus');
            newGoals.add(newRG);
        }
        // save
        DataFactory.create(newGoals);
    }

    @AuraEnabled
    public static Map<String, Boolean> getRelationshipGoalAccess() {
        Map<String, Boolean> accessMap = new Map<String, Boolean>();
        String objName = 'Relationship_Goal__c';
        accessMap = ApexCommonUtil.getObjectAccess(objName);
        return accessMap;
    }
    //924 Starts
    @AuraEnabled
    public static List<RelatedActivitiesWrapper> getRelatedRecords(
        string goldsheetId,
        Boolean isSelect,
        List<String> activities
    ) {
        // List<String> data = (List<String>) JSON.deserializeUntyped(activities);
        String id = goldsheetId;
        String fiQuery = 'SELECT Id, Amount__c, Status__c, Description__c, Investment_Title__c, Fields_of_Play_Gold_Sheet__c FROM Focus_Investment__c WHERE Fields_of_Play_Gold_Sheet__c = :id';
        List<Focus_Investment__c> focusInvestemntLst = getRARecordsLst(fiQuery, goldsheetId);

        String stopInvQuery = 'SELECT Id, Amount__c, Status__c, Description__c, Investment_Title__c, Fields_of_Play_Gold_Sheet__c FROM Stop_Investment__c WHERE Fields_of_Play_Gold_Sheet__c = :id';
        List<Stop_Investment__c> stopInvestemntLst = getRARecordsLst(stopInvQuery, goldsheetId);

        String actionQuery = 'SELECT Id, Due_Date__c, Status__c, Description__c, Assigned_To__c, Assigned_To__r.Name,  Action_Title__c, Fields_of_Play_Gold_Sheet__c FROM Action__c WHERE Fields_of_Play_Gold_Sheet__c = :id';
        List<Action__c> actionLst = getRARecordsLst(actionQuery, goldsheetId);

        String infoNeededQuery = 'SELECT Id, Due_Date__c, Status__c, Source__c, Assigned_To__c,      Description__c, Information_Needed_Title__c, Fields_of_Play_Gold_Sheet__c FROM Information_Needed__c WHERE Fields_of_Play_Gold_Sheet__c = :id';
        List<Information_Needed__c> infoNeededQueryLst = getRARecordsLst(infoNeededQuery, goldsheetId);

        String investmentProgQuery = 'SELECT Id, Due_Date__c, Status__c, Assigned_To__c, Description__c,   Investment_Program_Title__c, Fields_of_Play_Gold_Sheet__c FROM Investment_Program__c WHERE Fields_of_Play_Gold_Sheet__c = :id';
        List<Investment_Program__c> investmentProgLst = getRARecordsLst(investmentProgQuery, goldsheetId);

        List<RelatedActivitiesWrapper> fiList = new List<RelatedActivitiesWrapper>();
        for (String s : activities) {
            if (s == 'Focus Investment') {
                String focus;
                for (Focus_Investment__c fi : focusInvestemntLst) {
                    RelatedActivitiesWrapper f = new RelatedActivitiesWrapper();
                    f.objectName = 'Focus_Investment__c';
                    f.activityId = fi.id;
                    f.Amount = fi.Amount__c;
                    f.raStatus = fi.Status__c;
                    f.description = fi.Description__c;
                    focus = fi.Investment_Title__c + '\n' + s;
                    f.Name = focus;
                    f.objectLabel = s;
                    f.title = fi.Investment_Title__c;
                    fiList.add(f);
                }
            }
            if (s == 'Stop Investment') {
                string stop;
                for (Stop_Investment__c siObj : stopInvestemntLst) {
                    RelatedActivitiesWrapper f = new RelatedActivitiesWrapper();
                    f.objectName = 'Stop_Investment__c';
                    f.activityId = siObj.id;
                    f.Amount = siObj.Amount__c;
                    f.raStatus = siObj.Status__c;
                    f.description = siObj.Description__c;
                    stop = siObj.Investment_Title__c + '\n' + s;
                    f.Name = stop;
                    f.objectLabel = s;
                    f.title = siObj.Investment_Title__c;
                    fiList.add(f);
                }
            }
            if (s == 'Action') {
                string act;
                for (Action__c actionObj : actionLst) {
                    RelatedActivitiesWrapper f = new RelatedActivitiesWrapper();
                    f.objectName = 'Action__c';
                    f.activityId = actionObj.id;
                    f.DueDate = actionObj.Due_Date__c;
                    f.raStatus = actionObj.Status__c;
                    f.description = actionObj.Description__c;
                    f.Who = actionObj.Assigned_To__r.Name;
                    act = actionObj.Action_Title__c + '\n' + s;
                    f.Name = act;
                    f.objectLabel = s;
                    f.title = actionObj.Action_Title__c;
                    fiList.add(f);
                }
            }

            if (s == 'Information Needed') {
                string info;
                for (Information_Needed__c infoNeedObj : infoNeededQueryLst) {
                    RelatedActivitiesWrapper f = new RelatedActivitiesWrapper();
                    f.objectName = 'Information_Needed__c';
                    f.activityId = infoNeedObj.id;
                    f.DueDate = infoNeedObj.Due_Date__c;
                    f.raStatus = infoNeedObj.Status__c;
                    f.description = infoNeedObj.Description__c;
                    f.Who = infoNeedObj.Assigned_To__c;
                    f.Source = infoNeedObj.Source__c;
                    info = infoNeedObj.Information_Needed_Title__c + '\n' + s;
                    f.Name = info;
                    f.objectLabel = s;
                    f.title = infoNeedObj.Information_Needed_Title__c;
                    fiList.add(f);
                }
            }

            if (s == 'Investment Program') {
                string invt;
                for (Investment_Program__c investProgObj : investmentProgLst) {
                    RelatedActivitiesWrapper f = new RelatedActivitiesWrapper();
                    f.objectName = 'Investment_Program__c';
                    f.activityId = investProgObj.id;
                    f.DueDate = investProgObj.Due_Date__c;
                    f.raStatus = investProgObj.Status__c;
                    f.description = investProgObj.Description__c;
                    f.Who = investProgObj.Assigned_To__c;
                    invt = investProgObj.Investment_Program_Title__c + '\n' + s;
                    f.Name = invt;
                    f.objectLabel = s;
                    f.title = investProgObj.Investment_Program_Title__c;
                    fiList.add(f);
                }
            }
        }
        return fiList;
    }

    public static List<RelatedActivitiesWrapper> getRelatedActivity(Set<String> goalIdSet) {
        List<Related_Activities__c> listrelatedActivity = new List<Related_Activities__c>();
        List<Relationship_Goal__c> listRelationshipGoal = new List<Relationship_Goal__c>();
        Boolean isUpdatable;
        List<RelatedActivitiesWrapper> relatedActivitiesWrapperListToReturn = new List<RelatedActivitiesWrapper>();
        try {
            String relatedActivityQuery = 'Select Id, Action__c, Investment_Program__c, Information_Needed__c, Focus_Investment__c, Stop_Investment__c, Relationship_Goal__c  FROM Related_Activities__c Where Relationship_Goal__c =:goalIdSet  order by Relationship_Goal__c,Investment_Program__c,Information_Needed__c,Action__c,Stop_Investment__c,Focus_Investment__c';
            Map<String, Object> paramters = new Map<String, Object>();
            paramters.put('goalIdSet', goalIdSet);
            listrelatedActivity = DataFactory.read(relatedActivityQuery, paramters);
            Set<String> actionIdSet = new Set<String>();
            Set<String> focusInvIdSet = new Set<String>();
            Set<String> stopInvIdSet = new Set<String>();
            Set<String> infoNeededIdSet = new Set<String>();
            Set<String> investmentProgIdSet = new Set<String>();

            Map<String, Set<String>> mapChildParentId = new Map<String, Set<String>>();
            for (Related_Activities__c relatedActivity : listrelatedActivity) {
                if (relatedActivity.Action__c != null) {
                    actionIdSet.add(relatedActivity.Action__c);
                } else if (relatedActivity.Investment_Program__c != null) {
                    investmentProgIdSet.add(relatedActivity.Investment_Program__c);
                } else if (relatedActivity.Information_Needed__c != null) {
                    infoNeededIdSet.add(relatedActivity.Information_Needed__c);
                } else if (relatedActivity.Focus_Investment__c != null) {
                    focusInvIdSet.add(relatedActivity.Focus_Investment__c);
                } else if (relatedActivity.Stop_Investment__c != null) {
                    stopInvIdSet.add(relatedActivity.Stop_Investment__c);
                }
            }

            Map<String, SObject> mapIdRecAll = new Map<String, SObject>();
            if (!focusInvIdSet.isEmpty()) {
                String query = 'SELECT Id, Investment_Title__c, Description__c, Status__c, Amount__c FROM Focus_Investment__c WHERE Id =: idsSet';
                Map<String, SObject> mapIdRec = getRARecords(query, focusInvIdSet, 'Focus_Investment__c');
                mapIdRecAll.putAll(mapIdRec);
            }

            if (!actionIdSet.isEmpty()) {
                String query = 'SELECT Id, Action_Title__c,Description__c,Status__c,Due_Date__c,Assigned_To__c,Assigned_To__r.Name FROM Action__c WHERE Id =: idsSet';
                Map<String, SObject> mapIdRec = getRARecords(query, actionIdSet, 'Action__c');
                mapIdRecAll.putAll(mapIdRec);
            }

            if (!investmentProgIdSet.isEmpty()) {
                String query = 'SELECT Id, Investment_Program_Title__c, Description__c, Status__c, Due_Date__c, Assigned_To__c, Assigned_To__r.Name FROM Investment_Program__c WHERE Id =: idsSet';
                Map<String, SObject> mapIdRec = getRARecords(query, investmentProgIdSet, 'Investment_Program__c');
                mapIdRecAll.putAll(mapIdRec);
            }

            if (!infoNeededIdSet.isEmpty()) {
                String query = 'SELECT Id, Information_Needed_Title__c, Description__c, Status__c, Source__c, Due_Date__c, Assigned_To__c, Assigned_To__r.Name FROM Information_Needed__c WHERE Id =: idsSet';
                Map<String, SObject> mapIdRec = getRARecords(query, infoNeededIdSet, 'Information_Needed__c');
                mapIdRecAll.putAll(mapIdRec);
            }

            if (!stopInvIdSet.isEmpty()) {
                String query = 'SELECT Id, Investment_Title__c, Description__c, Status__c, Amount__c FROM Stop_Investment__c WHERE Id =: idsSet';
                Map<String, SObject> mapIdRec = getRARecords(query, stopInvIdSet, 'Stop_Investment__c');
                mapIdRecAll.putAll(mapIdRec);
            }
            relatedActivitiesWrapperListToReturn = getRelatedActivitiesMap(
                listrelatedActivity,
                mapIdRecAll,
                isUpdatable
            );
        } catch (Exception ex) {
            throw new relationshipGoalException('Error occured while getting data from Related Activities');
        }
        //return list of wrapper containing all relationshipGoal data
        return relatedActivitiesWrapperListToReturn;
    }

    private static List<RelatedActivitiesWrapper> getRelatedActivitiesMap(
        List<Related_Activities__c> listrelatedActivity,
        Map<String, SObject> mapIdRecAll,
        Boolean isUpdatable
    ) {
        List<RelatedActivitiesWrapper> relatedActivitiesWrapperListToReturn = new List<RelatedActivitiesWrapper>();
        for (Related_Activities__c relatedActivity : listrelatedActivity) {
            if (relatedActivity.Action__c != null) {
                Action__c obj = (Action__c) mapIdRecAll.get(relatedActivity.Action__c);
                RelatedActivitiesWrapper actionWrap = new RelatedActivitiesWrapper(
                    obj,
                    isUpdatable,
                    relatedActivity.Id
                );
                relatedActivitiesWrapperListToReturn.add(actionWrap);
            } else if (relatedActivity.Investment_Program__c != null) {
                Investment_Program__c obj = (Investment_Program__c) mapIdRecAll.get(
                    relatedActivity.Investment_Program__c
                );
                RelatedActivitiesWrapper actionWrap = new RelatedActivitiesWrapper(
                    obj,
                    isUpdatable,
                    relatedActivity.Id
                );
                relatedActivitiesWrapperListToReturn.add(actionWrap);
            } else if (relatedActivity.Information_Needed__c != null) {
                Information_Needed__c obj = (Information_Needed__c) mapIdRecAll.get(
                    relatedActivity.Information_Needed__c
                );
                RelatedActivitiesWrapper actionWrap = new RelatedActivitiesWrapper(
                    obj,
                    isUpdatable,
                    relatedActivity.Id
                );
                relatedActivitiesWrapperListToReturn.add(actionWrap);
            } else if (relatedActivity.Focus_Investment__c != null) {
                Focus_Investment__c obj = (Focus_Investment__c) mapIdRecAll.get(relatedActivity.Focus_Investment__c);
                RelatedActivitiesWrapper actionWrap = new RelatedActivitiesWrapper(
                    obj,
                    isUpdatable,
                    relatedActivity.Id
                );
                relatedActivitiesWrapperListToReturn.add(actionWrap);
            } else if (relatedActivity.Stop_Investment__c != null) {
                Stop_Investment__c obj = (Stop_Investment__c) mapIdRecAll.get(relatedActivity.Stop_Investment__c);
                RelatedActivitiesWrapper actionWrap = new RelatedActivitiesWrapper(
                    obj,
                    isUpdatable,
                    relatedActivity.Id
                );
                relatedActivitiesWrapperListToReturn.add(actionWrap);
            }
        }
        return relatedActivitiesWrapperListToReturn;
    }

    private static List<SObject> getRARecordsLst(String query, String id) {
        Map<String, SObject> recordsMap = new Map<String, SObject>();
        Map<String, Object> qryParamters = new Map<String, Object>();
        qryParamters.put('id', id);
        List<SObject> records = DataFactory.read(query, qryParamters);
        return records;
    }

    private static Map<String, SObject> getRARecords(String query, Set<String> idsSet, String objType) {
        Map<String, SObject> recordsMap = new Map<String, SObject>();
        Map<String, Object> qryParamters = new Map<String, Object>();
        qryParamters.put('idsSet', idsSet);
        List<SObject> records = DataFactory.read(query, qryParamters);
        for (SObject obj : records) {
            recordsMap.put(obj.Id, obj);
        }
        return recordsMap;
    }

    @AuraEnabled
    public static void upsertRelatedActivity(String relatedActivityObject, String goalId) {
        Set<String> goalIdSet = new Set<String>();
        goalIdSet.add(goalId);
        List<RelatedActivitiesWrapper> existingActivities = getRelatedActivity(goalIdSet);

        List<RelatedActivitiesWrapper> listRelatedActivityWrapper = (List<RelatedActivitiesWrapper>) JSON.deserialize(
            relatedActivityObject,
            List<RelatedActivitiesWrapper>.class
        );
        List<String> activitiesToRemove = compareActivities(existingActivities, listRelatedActivityWrapper);
        removeRelatedActivities(activitiesToRemove);
        List<Related_Activities__c> listRelatedActivitiesToSave = new List<Related_Activities__c>();
        for (RelatedActivitiesWrapper item : listRelatedActivityWrapper) {
            Related_Activities__c relatedActivity = new Related_Activities__c();
            if (item.id != null) {
                relatedActivity.Id = item.Id;
            } else {
                relatedActivity.Relationship_Goal__c = goalId;
            }
            String objName = item.objectName;
            if (objName == 'Action__c') {
                relatedActivity.Action__c = item.activityId;
            }
            if (objName == 'Investment_Program__c') {
                relatedActivity.Investment_Program__c = item.activityId;
            }
            if (objName == 'Information_Needed__c') {
                relatedActivity.Information_Needed__c = item.activityId;
            }
            if (objName == 'Focus_Investment__c') {
                relatedActivity.Focus_Investment__c = item.activityId;
            }
            if (objName == 'Stop_Investment__c') {
                relatedActivity.Stop_Investment__c = item.activityId;
            }
            listRelatedActivitiesToSave.add(relatedActivity);
        }
        DataFactory.upsurt(listRelatedActivitiesToSave);
    }

    //924 Ends

    private static List<String> compareActivities(
        List<RelatedActivitiesWrapper> existingActivities,
        List<RelatedActivitiesWrapper> activitiesToSave
    ) {
        List<String> activitiesToBeRemoved = new List<String>();
        for (RelatedActivitiesWrapper existingActivity : existingActivities) {
            boolean isExists = false;
            for (RelatedActivitiesWrapper activityToSave : activitiesToSave) {
                if (existingActivity.activityId == activityToSave.activityId) {
                    isExists = true;
                    break;
                }
            }

            if (isExists == false) {
                activitiesToBeRemoved.add(existingActivity.Id);
            }
        }
        return activitiesToBeRemoved;
    }
}