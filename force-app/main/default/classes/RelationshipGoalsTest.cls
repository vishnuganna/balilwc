@isTest
private with sharing class RelationshipGoalsTest {
    static void testData() {
        //create GoldSheet
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Account acc = TestDataUtil.createAccount(true);
            Gold_Sheet__c goldSheet = TestDataUtil.createGoldSheet(acc, true);
            List<Focus_Investment__c> f = TestDataUtil.createFocusInvestment(goldSheet, true);
            List<Stop_Investment__c> s = TestDataUtil.createStopInvestment(goldSheet, true);
            List<Action__c> a = TestDataUtil.createActions(goldSheet, true);
            List<Information_Needed__c> i = TestDataUtil.createInformationNeeded(goldSheet, true);
            List<Investment_Program__c> inv = TestDataUtil.createInvProgram(goldSheet, true);

            Relationship_Goal__c rg = new Relationship_Goal__c();
            rg.Fields_of_Play_Gold_Sheet__c = goldSheet.Id;
            rg.Goal_Name__c = 'Test Goal';
            rg.Description__c = 'Test Description';
            rg.Goal_Status__c = 'Incomplete';
            insert rg;

            Focus_Investment__c fc1 = new Focus_Investment__c(
                Fields_of_Play_Gold_Sheet__c = goldSheet.Id,
                Investment_Title__c = 'Test 1',
                Amount__c = 334,
                Status__c = 'Complete',
                Description__c = 'Test desc'
            );
            insert fc1;

            Stop_Investment__c sc1 = new Stop_Investment__c(
                Fields_of_Play_Gold_Sheet__c = goldSheet.Id,
                Investment_Title__c = 'Test 1',
                Amount__c = 334,
                Status__c = 'Complete',
                Description__c = 'Test desc'
            );
            insert sc1;

            Action__c act1 = new Action__c(
                Fields_of_Play_Gold_Sheet__c = goldSheet.Id,
                Action_Title__c = 'Test 1',
                Assigned_To__c = UserInfo.getUserId(),
                Status__c = 'Complete',
                Description__c = 'Test desc',
                Due_Date__c = date.today()
            );
            insert act1;

            Investment_Program__c inc1 = new Investment_Program__c(
                Fields_of_Play_Gold_Sheet__c = goldSheet.Id,
                Investment_Program_Title__c = 'Test 1',
                Assigned_To__c = UserInfo.getUserId(),
                Status__c = 'Complete',
                Description__c = 'Test desc',
                Due_Date__c = date.today()
            );
            insert inc1;

            Information_Needed__c info1 = new Information_Needed__c(
                Fields_of_Play_Gold_Sheet__c = goldSheet.Id,
                Information_Needed_Title__c = 'Test 1',
                Source__c = 'Source 1',
                Assigned_To__c = UserInfo.getUserId(),
                Status__c = 'Complete',
                Description__c = 'Test desc',
                Due_Date__c = date.today()
            );
            insert info1;

            Related_Activities__c rr = new Related_Activities__c();
            rr.Relationship_Goal__c = rg.id;
            rr.Action__c = act1.id;
            insert rr;

            Related_Activities__c rr1 = new Related_Activities__c();
            rr1.Relationship_Goal__c = rg.id;
            rr1.Focus_Investment__c = fc1.id;
            insert rr1;

            Related_Activities__c rr2 = new Related_Activities__c();
            rr2.Relationship_Goal__c = rg.id;
            rr2.Stop_Investment__c = sc1.id;
            insert rr2;

            Related_Activities__c rr3 = new Related_Activities__c();
            rr3.Relationship_Goal__c = rg.id;
            rr3.Information_Needed__c = info1.id;
            insert rr3;

            Related_Activities__c rr4 = new Related_Activities__c();
            rr4.Relationship_Goal__c = rg.id;
            rr4.Investment_Program__c = inc1.id;
            insert rr4;
        }
    }
    static testMethod void getRelationshipGoalTest() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            testData();
            Gold_Sheet__c g = [SELECT Id FROM Gold_Sheet__c LIMIT 1];
            Relationship_Goal__c rg = [
                SELECT Fields_of_Play_Gold_Sheet__c, Goal_Status__c, Goal_Name__c, Description__c
                FROM Relationship_Goal__c
                LIMIT 1
            ];
            Test.startTest();
            List<RelationshipGoalsWrapper> wrap = RelationshipGoals.getRelationshipGoal(g.Id, 'Incomplete');
            system.assertEquals(true, wrap.size() > 0);
            Test.stopTest();
        }
    }

    /*static testMethod void insertRelationshipGoalTest() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            testData();
            Relationship_Goal__c relationshipGoal = [
                SELECT Id, Fields_of_Play_Gold_Sheet__c, Goal_Name__c, Goal_Status__c, Description__c
                FROM Relationship_Goal__c
                LIMIT 1
            ];

            Test.startTest();
            Map<string, Object> mapRelationshipGoal = new Map<string, Object>();
            mapRelationshipGoal.put('goldsheetId', relationshipGoal.Fields_of_Play_Gold_Sheet__c);
            mapRelationshipGoal.put('goalName', relationshipGoal.Goal_Name__c);
            mapRelationshipGoal.put('description', relationshipGoal.Description__c);
            List<Object> listRelatedActivityObject = new List<Object>();
            Map<string, Object> mapRelatedActivityObjec = new Map<string, Object>();
            mapRelatedActivityObjec.put('objectName', 'Action__c');
            listRelatedActivityObject.add(mapRelatedActivityObjec);
            string RelatedActivityObject = JSON.serialize(listRelatedActivityObject);
            string relationshipGoalString = JSON.serialize(mapRelationshipGoal);
            RelationshipGoals.insertRelationshipGoal(relationshipGoalString, RelatedActivityObject);
            mapRelationshipGoal.put('Id', relationshipGoal.Id);
            mapRelationshipGoal.put('goalName', 'Test GoalName 13');
            string relationshipGoalString1 = JSON.serialize(mapRelationshipGoal);
            RelationshipGoals.updateRelationshipGoal(relationshipGoalString1);
            Relationship_Goal__c rg = [
                SELECT Id, Fields_of_Play_Gold_Sheet__c, Goal_Name__c, Goal_Status__c, Description__c
                FROM Relationship_Goal__c
                WHERE id = :relationshipGoal.id
                LIMIT 1
            ];

            System.assertEquals(rg.Goal_Name__c, 'Test GoalName 13');
            Test.stopTest();
        }
    }*/
    // static testMethod void updateRelationshipGoalTest() {
    //     User user = UserTest.createUserWithPerms();
    //     System.runAs(user) {
    //         testData();
    //         Relationship_Goal__c relationshipGoal = [
    //             SELECT Id, Fields_of_Play_Gold_Sheet__c, Goal_Name__c, Goal_Status__c, Description__c
    //             FROM Relationship_Goal__c
    //             LIMIT 1
    //         ];
    //         Map<string, Object> mapRelationshipGoal = new Map<string, Object>();
    //         mapRelationshipGoal.put('goalName', 'Test GoalName 5');
    //         mapRelationshipGoal.put('Id', relationshipGoal.Id);
    //         mapRelationshipGoal.put('description', relationshipGoal.Description__c);

    //         string relationshipGoalString1 = JSON.serialize(mapRelationshipGoal);
    //         Test.startTest();
    //         RelationshipGoals.updateRelationshipGoal(relationshipGoalString1);
    //         Relationship_Goal__c rg = [
    //             SELECT id, Fields_of_Play_Gold_Sheet__c, Goal_Name__c, Goal_Status__c, Description__c
    //             FROM Relationship_Goal__c
    //             WHERE id = :relationshipGoal.id
    //             LIMIT 1
    //         ];
    //         System.assertEquals(rg.Goal_Name__c, 'Test GoalName 5');
    //         Test.stopTest();
    //     }
    // }

    static testMethod void deleteRelationshipGoalTest() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            testData();
            Relationship_Goal__c rg = [
                SELECT Fields_of_Play_Gold_Sheet__c, Goal_Name__c, Goal_Status__c, Description__c
                FROM Relationship_Goal__c
                LIMIT 1
            ];
            Test.startTest();
            RelationshipGoals.deleteRelationshipGoal(rg.Id);
            List<RelationshipGoalsWrapper> wrap = RelationshipGoals.getRelationshipGoal(rg.Id, 'Incomplete');
            System.assertEquals(true, wrap.size() == 0);
            Test.stopTest();
        }
    }

    @IsTest
    static void insertRelationshipGoals() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            testData();
            Gold_Sheet__c bs = [SELECT Id, FOP_Name__c, Account__c FROM Gold_Sheet__c LIMIT 1];
            List<Object> actionList = new List<Object>();
            Map<String, Object> action1 = new Map<String, Object>();
            action1.put('GoldsheetId', bs.Id);
            action1.put('GoalName', 'Test One');
            Map<String, Object> action2 = new Map<String, Object>();
            action2.put('GoldsheetId', bs.Id);
            action2.put('GoalName', 'Test Two');
            actionList.add(action1);
            actionList.add(action2);
            String plans = JSON.serialize(actionList);
            Test.startTest();
            List<RelationshipGoalsWrapper> data = RelationshipGoals.getRelationshipGoal(bs.Id, 'Incomplete');
            System.assert(!data.isEmpty());
            System.assertEquals(1, data.size());
            // insert new list
            RelationshipGoals.insertRelationshipGoals(plans);
            // ensure count increased
            data = RelationshipGoals.getRelationshipGoal(bs.Id, 'Incomplete');
            System.assertEquals(3, data.size());
            Test.stopTest();
        }
    }
    static testMethod void getGoalStatusPicklistValuesTest() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Test.startTest();
            String Status = RelationshipGoals.getGoalStatusPicklistValues();
            System.assert(!String.isEmpty(Status));
            Test.stopTest();
        }
    }

    static testMethod void getRelationshipGoalAccessTest() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Test.startTest();
            Map<String, Boolean> objectPermissionValue = RelationshipGoals.getRelationshipGoalAccess();
            system.assertEquals(true, objectPermissionValue.size() > 0, 'Check access map size');
            Test.stopTest();
        }
    }

    static testMethod void getRelatedRecordsTest() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            testData();
            Gold_Sheet__c g = [SELECT Id FROM Gold_Sheet__c LIMIT 1];
            String s = g.id;
            List<String> str = new List<String>();
            str.add('Action');
            str.add('Focus Investment');
            str.add('Stop Investment');
            str.add('Information Needed');
            str.add('Investment Program');
            //List<RelatedActivitiesWrapper> raStatus1 = RelationshipGoals.getRelatedActivity(s);
            List<RelatedActivitiesWrapper> raStatus = RelationshipGoals.getRelatedRecords(g.id, true, str);
            System.assertEquals(true, raStatus.size() > 0);
        }
    }
}