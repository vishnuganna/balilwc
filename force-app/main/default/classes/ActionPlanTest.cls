@isTest
private with sharing class ActionPlanTest {
    static void testData() {
        //create opportunity
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            opportunity objOppt = new opportunity();
            objOppt.Name = 'Test Opportunity';
            objOppt.StageName = 'Needs Analysis';
            objOppt.CloseDate = date.today();
            insert objOppt;

            Account acc = new Account();
            acc.Name = 'Test Account';
            insert acc;

            Contact con = new Contact();
            con.lastName = 'Test Contact';
            con.AccountId = acc.Id;
            insert con;

            Blue_Sheet__c blueSheet = new Blue_Sheet__c();
            blueSheet.Opportunity__c = objOppt.Id;
            insert blueSheet;

            Action_Plan__c ap = new Action_Plan__c();
            ap.Blue_Sheet__c = blueSheet.Id;
            ap.Summary__c = 'Test Summary';
            ap.Description__c = 'Test Description';
            ap.Is_a_Best_Action__c = true;
            ap.IsProvidingPerspective__c = false;
            ap.ProvidingPerspectiveDescription__c = '';
            insert ap;
        }
    }

    static testMethod void getactionPlanTest() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            testData();
            opportunity objOppt = [
                SELECT Name, StageName, CloseDate
                FROM Opportunity
                WHERE Name = 'Test Opportunity'
                LIMIT 1
            ];
            Action_Plan__c ap = [
                SELECT id, Blue_Sheet__c, Is_a_Best_Action__c, Summary__c, Description__c
                FROM Action_Plan__c
                LIMIT 1
            ];
            Blue_Sheet__c bs = [SELECT id FROM Blue_Sheet__c LIMIT 1];
            Contact con = [SELECT Id FROM Contact WHERE LastName = 'Test Contact' LIMIT 1];
            Best_Action_Task_Creation__c settings = Best_Action_Task_Creation__c.getInstance();
            settings.Enable_Task_Creation__c = true;
            upsert settings;
            Test.startTest();
            List<ActionPlanWrapperClass> wrap = actionPlan.getactionPlan(objOppt.Id);
            system.assertEquals(true, wrap.size() > 0);
            String ss = actionPlan.getBlueSheetId(objOppt.Id);
            system.assertEquals(bs.id, ss);
            //actionPlan.oppOwnerDetail(objOppt.Id);
            Map<String, String> sss = actionPlan.getOppOwner(objOppt.Id);
            system.assertEquals(true, sss.size() > 0);
            actionPlan.updateIsAction(ap.id, true);
            actionPlan.getContactFieldName();
            actionPlan.getAssignedToFieldName();
            actionPlan.deleteActionPlan(ap.id, 'TestTask', true);
            Test.stopTest();
        }
    }

    static testMethod void insertActionPlanTest() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            testData();
            opportunity objOppt = [
                SELECT Name, StageName, CloseDate, Id
                FROM Opportunity
                WHERE Name = 'Test Opportunity'
                LIMIT 1
            ];
            Action_Plan__c ap = [
                SELECT
                    Blue_Sheet__c,
                    Summary__c,
                    Is_a_Best_Action__c,
                    Description__c,
                    IsProvidingPerspective__c,
                    ProvidingPerspectiveDescription__c
                FROM Action_Plan__c
                LIMIT 1
            ];
            Contact con = [SELECT Id FROM Contact WHERE LastName = 'Test Contact' LIMIT 1];
            Best_Action_Task_Creation__c settings = Best_Action_Task_Creation__c.getInstance();
            settings.Enable_Task_Creation__c = true;
            upsert settings;
            Test.startTest();
            Map<string, Object> mapActionPlan = new Map<string, Object>();
            mapActionPlan.put('BluesheetId', ap.Blue_Sheet__c);
            mapActionPlan.put('OppId', objOppt.Id);
            mapActionPlan.put('Summary', ap.Summary__c);
            mapActionPlan.put('Description', ap.Description__c);
            mapActionPlan.put('Contact', con.Id);
            mapActionPlan.put('bestActionvalue', true);
            mapActionPlan.put('AssignedTo', UserInfo.getUserId());
            mapActionPlan.put('providingPerspectiveValue', ap.IsProvidingPerspective__c);
            mapActionPlan.put('StartDate', Date.valueOf(system.today()));
            mapActionPlan.put('DueDate', Date.valueOf(system.today()));
            string actionPlanString = JSON.serialize(mapActionPlan);
            actionPlan.insertActionPlan(actionPlanString);
            mapActionPlan.put('Summary', 'Test Summary 1');
            mapActionPlan.put('Id', ap.Id);
            mapActionPlan.put('Contact', con.Id);
            mapActionPlan.put('AssignedTo', UserInfo.getUserId());
            mapActionPlan.put('providingPerspectiveValue', false);
            mapActionPlan.put('StartDate', Date.valueOf(system.today() + 1));
            mapActionPlan.put('DueDate', Date.valueOf(system.today() + 1));

            string actionPlanString1 = JSON.serialize(mapActionPlan);
            actionPlan.updateActionPlan(actionPlanString1);
            ap = [SELECT Blue_Sheet__c, Summary__c, Is_a_Best_Action__c, Description__c FROM Action_Plan__c LIMIT 1];
            System.assertEquals(ap.Summary__c, 'Test Summary 1');
            Test.stopTest();
        }
    }

    static testMethod void updateActionPlanTest() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            testData();
            Action_Plan__c ap = [
                SELECT Id, Blue_Sheet__c, Summary__c, Is_a_Best_Action__c, Description__c
                FROM Action_Plan__c
                LIMIT 1
            ];
            Map<string, Object> mapActionPlan = new Map<string, Object>();
            mapActionPlan.put('Summary', 'Test Summary 1');
            mapActionPlan.put('Id', ap.Id);
            mapActionPlan.put('bestActionvalue', true);
            mapActionPlan.put('Contact', '');
            mapActionPlan.put('AssignedTo', '');
            mapActionPlan.put('StartDate', '');
            mapActionPlan.put('DueDate', '');
            mapActionPlan.put('providingPerspectiveValue', false);

            string actionPlanString1 = JSON.serialize(mapActionPlan);
            Test.startTest();
            actionPlan.updateActionPlan(actionPlanString1);
            ap = [SELECT Blue_Sheet__c, Summary__c, Is_a_Best_Action__c, Description__c FROM Action_Plan__c LIMIT 1];
            System.assertEquals(ap.Summary__c, 'Test Summary 1');
            Test.stopTest();
        }
    }

    @IsTest
    static void testInsertActionPlans() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            testData();
            Blue_Sheet__c bs = [SELECT Id, Opportunity__c FROM Blue_Sheet__c LIMIT 1];
            List<Object> actionList = new List<Object>();
            Map<String, Object> action1 = new Map<String, Object>();
            action1.put('BluesheetId', bs.Id);
            action1.put('Summary', 'Test One');
            Map<String, Object> action2 = new Map<String, Object>();
            action2.put('BluesheetId', bs.Id);
            action2.put('Summary', 'Test Two');
            actionList.add(action1);
            actionList.add(action2);
            String plans = JSON.serialize(actionList);
            Test.startTest();
            // ensure initial action plan
            List<ActionPlanWrapperClass> data = ActionPlan.getActionPlan(bs.Opportunity__c);
            System.assert(!data.isEmpty());
            System.assertEquals(1, data.size());
            // insert new list
            ActionPlan.insertActionPlans(plans);
            // ensure count increased
            data = ActionPlan.getActionPlan(bs.Opportunity__c);
            System.assertEquals(3, data.size());
            Test.stopTest();
        }
    }

    @IsTest
    static void testGetSsoList() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            testData();
            Blue_Sheet__c bs = [SELECT Id, Opportunity__c FROM Blue_Sheet__c LIMIT 1];
            Single_Sales_Objective__c sso = new Single_Sales_Objective__c();
            sso.Blue_Sheet__c = bs.Id;
            sso.Customers_Stated_Objectives__c = 'This is a test';
            List<Database.SaveResult> rec = DataFactory.create(sso);
            Red_Flag_Strength_Marker__c m1 = new Red_Flag_Strength_Marker__c();
            Database.SaveResult r = rec.get(0);
            m1.Source_ID__c = r.id;
            m1.Field_API_Name__c = 'CustomersStatedObjectives';
            m1.Object_API_Name__c = util.getNamespaceWithUnderScores() == ''
                ? 'Single_Sales_Objective__c'
                : util.getNamespaceWithUnderScores() + 'Single_Sales_Objective__c';
            //m1.Object_API_Name__c = 'Single_Sales_Objective__c';
            m1.Is_Red_Flag_Selected__c = false;
            m1.Is_Strength_Selected__c = true;
            m1.Blue_Sheet_Id__c = bs.Id;
            m1.Parent_Id__c = bs.Id;
            List<Red_Flag_Strength_Marker__c> mList = new List<Red_Flag_Strength_Marker__c>();
            mList.add(m1);
            DataFactory.create(mList);
            Test.startTest();
            String ssoList = ActionPlan.getSSOListData(bs.Id);
            List<Object> data = (List<Object>) JSON.deserializeUntyped(ssoList);
            System.assert(!data.isEmpty());
            System.assertEquals(1, data.size());
            Map<String, Object> dm = (Map<String, Object>) data.get(0);
            Test.stopTest();
        }
    }

    @IsTest
    static void testGetBiList() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            testData();
            Blue_Sheet__c bs = [SELECT Id, Opportunity__c FROM Blue_Sheet__c LIMIT 1];
            Contact c = [SELECT Id, Name FROM Contact LIMIT 1];
            // create BI
            Buying_Influence__c bi = new Buying_Influence__c();
            bi.Contact__c = c.Id;
            bi.Blue_Sheet__c = bs.Id;
            List<Database.SaveResult> rec = DataFactory.create(bi);
            // create some markers for fields
            Red_Flag_Strength_Marker__c m1 = new Red_Flag_Strength_Marker__c();
            Database.SaveResult r = rec.get(0);
            m1.Source_ID__c = r.id;
            m1.Field_API_Name__c = 'BuyingInfluenceRole';
            m1.Object_API_Name__c = util.getNamespaceWithUnderScores() == ''
                ? 'Buying_Influence__c'
                : util.getNamespaceWithUnderScores() + 'Buying_Influence__c';
            //m1.Object_API_Name__c = 'Buying_Influence__c';
            m1.Is_Red_Flag_Selected__c = false;
            m1.Is_Strength_Selected__c = true;
            m1.Parent_Id__c = bs.Id;
            Red_Flag_Strength_Marker__c m2 = new Red_Flag_Strength_Marker__c();
            m2.Source_ID__c = r.id;
            m2.Field_API_Name__c = 'BuyingMode';
            m2.Object_API_Name__c = util.getNamespaceWithUnderScores() == ''
                ? 'Buying_Influence__c'
                : util.getNamespaceWithUnderScores() + 'Buying_Influence__c';
            //m2.Object_API_Name__c = 'Buying_Influence__c';
            m2.Is_Red_Flag_Selected__c = true;
            m2.Is_Strength_Selected__c = false;
            m2.Parent_Id__c = bs.Id;
            List<Red_Flag_Strength_Marker__c> mList = new List<Red_Flag_Strength_Marker__c>();
            mList.add(m1);
            mList.add(m2);
            DataFactory.create(mList);
            Test.startTest();
            String biList = ActionPlan.getBIListData(bs.Id);
            List<Object> data = (List<Object>) JSON.deserializeUntyped(biList);
            System.assert(!data.isEmpty());
            System.assertEquals(2, data.size());
            // make sure the label is correct
            Map<String, Object> dm1 = (Map<String, Object>) data.get(0);
            System.assertEquals(c.Name + ': Role', dm1.get('label'));
            Map<String, Object> dm2 = (Map<String, Object>) data.get(1);
            System.assertEquals(c.Name + ': Buying Mode', dm2.get('label'));
            Test.stopTest();
        }
    }

    @IsTest
    static void testGetCompetitorList() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            testData();
            Blue_Sheet__c bs = [SELECT Id, Opportunity__c FROM Blue_Sheet__c LIMIT 1];
            Account a = [SELECT Id FROM Account LIMIT 1];
            Competition__c comp1 = new Competition__c();
            comp1.Blue_Sheet__c = bs.Id;
            comp1.Account__c = a.Id;
            Competition__c comp2 = new Competition__c();
            comp2.Blue_Sheet__c = bs.Id;
            comp2.Competitior_Name__c = 'Test Name';
            List<Competition__c> compList = new List<Competition__c>();
            compList.add(comp1);
            compList.add(comp2);
            List<Database.SaveResult> rec = DataFactory.create(compList);
            List<Red_Flag_Strength_Marker__c> mList = new List<Red_Flag_Strength_Marker__c>();
            Red_Flag_Strength_Marker__c m1 = new Red_Flag_Strength_Marker__c();
            Database.SaveResult r = rec.get(0);
            m1.Source_ID__c = r.id;
            m1.Field_API_Name__c = 'competitor';
            m1.Object_API_Name__c = util.getNamespaceWithUnderScores() == ''
                ? 'Competition__c'
                : util.getNamespaceWithUnderScores() + 'Competition__c';
            //m1.Object_API_Name__c = 'Competition__c';
            m1.Is_Red_Flag_Selected__c = false;
            m1.Is_Strength_Selected__c = true;
            m1.Blue_Sheet_Id__c = bs.Id;
            m1.Parent_Id__c = bs.Id;
            mList.add(m1);
            Red_Flag_Strength_Marker__c m2 = new Red_Flag_Strength_Marker__c();
            Database.SaveResult r1 = rec.get(1);
            m2.Source_ID__c = r1.id;
            m2.Field_API_Name__c = 'competitiveDetail';
            m2.Object_API_Name__c = util.getNamespaceWithUnderScores() == ''
                ? 'Competition__c'
                : util.getNamespaceWithUnderScores() + 'Competition__c';
            //m2.Object_API_Name__c = 'Competition__c';
            m2.Is_Red_Flag_Selected__c = false;
            m2.Is_Strength_Selected__c = true;
            m2.Blue_Sheet_Id__c = bs.Id;
            m2.Parent_Id__c = bs.Id;
            mList.add(m2);
            DataFactory.create(mList);
            Test.startTest();
            String compData = ActionPlan.getCompetitorListData(bs.Id);
            List<Object> data = (List<Object>) JSON.deserializeUntyped(compData);
            System.assert(!data.isEmpty());
            System.assertEquals(2, data.size());
            Test.stopTest();
        }
    }
    @IsTest
    static void testGetSOMPList() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            testData();
            Blue_Sheet__c bs = [SELECT Id, Opportunity__c FROM Blue_Sheet__c LIMIT 1];
            Summary_of_My_Position_Today__c somp = new Summary_of_My_Position_Today__c();
            somp.Blue_Sheet__c = bs.Id;
            somp.Summary__c = 'Test Data';
            somp.Is_a_Strength__c = true;
            somp.Is_a_Red_Flag__c = false;
            DataFactory.create(somp);
            Test.startTest();
            String sompData = ActionPlan.getSOMPListData(bs.Id);
            List<Object> data = (List<Object>) JSON.deserializeUntyped(sompData);
            System.assert(!data.isEmpty());
            System.assertEquals(1, data.size());
            Map<String, Object> sd = (Map<String, Object>) data.get(0);
            System.assertEquals(somp.Summary__c, sd.get('label'));
            System.assertEquals('somp0', sd.get('name'));
            System.assertEquals(somp.Is_a_Strength__c, sd.get('isStrength'));
            System.assertEquals(somp.Is_a_Red_Flag__c, sd.get('isRedFlag'));
            Test.stopTest();
        }
    }

    @IsTest
    static void testGetSuggestedActionMetaData() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            List<Suggested_Possible_Action__mdt> recs = [SELECT Id FROM Suggested_Possible_Action__mdt];
            Test.startTest();
            String suggestionData = ActionPlan.getSuggestedActionMetaData();
            System.assert(!String.isEmpty(suggestionData));
            List<Object> data = (List<Object>) JSON.deserializeUntyped(suggestionData);
            System.assertEquals(recs.size(), data.size());
            Test.stopTest();
        }
    }
    static testMethod void testGetObjectPermission() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Test.startTest();
            Map<String, Boolean> objectPermissionValue = ActionPlan.getActionPlanAccess();
            system.assertEquals(true, objectPermissionValue.size() > 0, 'Check access map size');
            Test.stopTest();
        }
    }

    static testMethod void testGetPicklistValues() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Test.startTest();
            String Status = ActionPlan.getStatusPicklistValues();
            System.assert(!String.isEmpty(Status));
            Test.stopTest();
        }
    }

    static testMethod void testGetActionTypePicklistValues() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Test.startTest();
            String ActionType = ActionPlan.getActionTypePicklistValues();
            System.assert(!String.isEmpty(ActionType));
            Test.stopTest();
        }
    }

    static testMethod void testGetPriorityPicklistValues() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Test.startTest();
            String Priority = ActionPlan.getPriorityPicklistValues();
            System.assert(!String.isEmpty(Priority));
            Test.stopTest();
        }
    }
    static testMethod void UndeleteactionPlanTest() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            testData();
            opportunity objOppt = [
                SELECT Name, StageName, CloseDate, Id
                FROM Opportunity
                WHERE Name = 'Test Opportunity'
                LIMIT 1
            ];
            Action_Plan__c ap = [
                SELECT
                    Blue_Sheet__c,
                    Summary__c,
                    Is_a_Best_Action__c,
                    Description__c,
                    IsProvidingPerspective__c,
                    ProvidingPerspectiveDescription__c
                FROM Action_Plan__c
                LIMIT 1
            ];
            Contact con = [SELECT Id FROM Contact WHERE LastName = 'Test Contact' LIMIT 1];
            Best_Action_Task_Creation__c settings = Best_Action_Task_Creation__c.getInstance();
            settings.Enable_Task_Creation__c = true;
            upsert settings;
            Test.startTest();
            Map<string, Object> mapActionPlan = new Map<string, Object>();
            mapActionPlan.put('BluesheetId', ap.Blue_Sheet__c);
            mapActionPlan.put('OppId', objOppt.Id);
            mapActionPlan.put('Summary', ap.Summary__c);
            mapActionPlan.put('Description', ap.Description__c);
            mapActionPlan.put('Contact', con.Id);
            mapActionPlan.put('bestActionvalue', true);
            mapActionPlan.put('AssignedTo', UserInfo.getUserId());
            mapActionPlan.put('providingPerspectiveValue', ap.IsProvidingPerspective__c);
            mapActionPlan.put('StartDate', Date.valueOf(system.today()));
            mapActionPlan.put('DueDate', Date.valueOf(system.today()));
            string actionPlanString = JSON.serialize(mapActionPlan);
            actionPlan.insertActionPlan(actionPlanString);
            Action_Plan__c ap1 = [
                SELECT
                    Blue_Sheet__c,
                    Summary__c,
                    Is_a_Best_Action__c,
                    Description__c,
                    IsProvidingPerspective__c,
                    ProvidingPerspectiveDescription__c
                FROM Action_Plan__c
                ORDER BY createdDate DESC
                LIMIT 1
            ];

            mapActionPlan.put('Summary', 'Test Summary 1');
            mapActionPlan.put('Id', ap1.Id);
            mapActionPlan.put('Contact', con.Id);
            mapActionPlan.put('AssignedTo', UserInfo.getUserId());
            mapActionPlan.put('providingPerspectiveValue', false);
            mapActionPlan.put('StartDate', Date.valueOf(system.today() + 1));
            mapActionPlan.put('DueDate', Date.valueOf(system.today() + 1));
            mapActionPlan.put('bestActionvalue', false);
            string actionPlanString1 = JSON.serialize(mapActionPlan);
            actionPlan.updateActionPlan(actionPlanString1);
            ap = [
                SELECT Blue_Sheet__c, Summary__c, Is_a_Best_Action__c, Description__c
                FROM Action_Plan__c
                ORDER BY createdDate DESC
                LIMIT 1
            ];
            System.assertEquals(ap.Summary__c, 'Test Summary 1');
            actionPlan.undeleteTask(ap.Id);
            Test.stopTest();
        }
    }
}