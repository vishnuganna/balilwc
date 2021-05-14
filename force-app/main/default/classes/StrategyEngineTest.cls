@isTest
public with sharing class StrategyEngineTest {
    @testSetup
    static void setup() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Account acc = TestDataUtil.createAccount(true);
            Opportunity op = TestDataUtil.createOpportunity(acc, true);
            Blue_Sheet__c bs = TestDataUtil.createBluesheet(op, true);
            Contact con = TestDataUtil.createContact(acc, true);
            List<Buying_Influence__c> buying = TestDataUtil.createBuyingInfluence(bs, con, true);
            Single_Sales_Objective__c sso = TestDataUtil.createSSO(bs, true);
            TestDataUtil.createBusinessRules(true);
        }
    }

    static testMethod void testCreateBlueSheet() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Account Acct = [SELECT Id FROM Account];

            Opportunity oppty = new Opportunity(
                Name = 'BlueSheet Creation',
                AccountId = Acct.Id,
                StageName = 'Qualification',
                CloseDate = date.TODAY().addDays(30)
            );
            Test.startTest();
            insert oppty;
            StrategyEngine.createBlueSheet(oppty.Id);
            Blue_Sheet__c bs = [SELECT id, Opportunity__c FROM Blue_Sheet__c WHERE Opportunity__c = :oppty.Id];
            Test.stopTest();
            System.assertEquals(oppty.Id, bs.Opportunity__c);
        }
    }
    static testMethod void testUpdateBuyingInfluence() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            List<Buying_Influence__c> buy = [
                SELECT Id, Personal_Wins__c, Growth__c, Rating__c, Over_Confident__c, Even_Keel__c
                FROM Buying_Influence__c
            ];
            buy[0].Personal_Wins__c = '';
            buy[0].Rating__c = '-1';
            buy[0].Growth__c = false;
            buy[0].Even_Keel__c = true;
            update buy[0];
            System.assertEquals(buy[0].Even_Keel__c, true);
            System.assertEquals(buy[0].Growth__c, false);
        }
    }
    static testMethod void testUpdateBuyingInfluence1() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            List<Buying_Influence__c> buy = [
                SELECT
                    Id,
                    Personal_Wins__c,
                    Growth__c,
                    Rating__c,
                    Over_Confident__c,
                    Trouble__c,
                    Rating_Evidence__c,
                    Business_Results__c,
                    Buying_from_Someone_Else__c,
                    Technical__c,
                    Medium__c
                FROM Buying_Influence__c
            ];
            buy[0].Personal_Wins__c = 'win';
            buy[0].Rating__c = '+1';
            buy[0].Trouble__c = true;
            buy[0].Rating_Evidence__c = '';
            buy[0].Business_Results__c = '';
            buy[0].Buying_from_Someone_Else__c = true;
            buy[0].Technical__c = true;
            buy[0].Medium__c = true;
            update buy[0];

            System.assertEquals(buy[0].Technical__c, true);
            System.assertEquals(buy[0].Medium__c, true);
        }
    }

    static testMethod void testUpdateSSO() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Single_Sales_Objective__c sso = [
                SELECT Id, Name, Customers_Stated_Objectives__c, Evaluation_of_Objectives__c
                FROM Single_Sales_Objective__c
            ];
            sso.Evaluation_of_Objectives__c = '';
            sso.Customers_Stated_Objectives__c = '';
            Test.startTest();
            update sso;
            Single_Sales_Objective__c singlesale = [
                SELECT Id, Name, Customers_Stated_Objectives__c, Evaluation_of_Objectives__c
                FROM Single_Sales_Objective__c
            ];
            System.assertEquals(null, singlesale.Evaluation_of_Objectives__c);
            Test.stopTest();
        }
    }

    /*

    static testMethod void testBestActionlogic_BAL_1() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            List<Strategy_Engine__c> seLst = new List<Strategy_Engine__c>();
            Blue_Sheet__c bs = [SELECT id, Opportunity__c FROM Blue_Sheet__c LIMIT 1];
            Strategy_Engine__c se = TestDataUtil.createStrategyEngine(bs, false);
            se.Place_in_Sales_Funnel__c = 'Qualification';
            se.Opportunity_Amount__c = 200;
            seLst.add(se);
            insert seLst;
            Business_Rules__c br = [SELECT id, Is_a_Blue_Sheet_required__c FROM Business_Rules__c LIMIT 1];
            br.Is_a_Blue_Sheet_required__c = 'No';
            update br;
            update seLst;
        }
    }

    static testMethod void testBestActionlogic_BAL_2() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            List<Strategy_Engine__c> seLst = new List<Strategy_Engine__c>();
            Blue_Sheet__c bs = [SELECT id, Opportunity__c FROM Blue_Sheet__c LIMIT 1];
            Strategy_Engine__c se = TestDataUtil.createStrategyEngine(bs, false);
            se.Place_in_Sales_Funnel__c = 'Qualification';
            se.Opportunity_Amount__c = 200;
            seLst.add(se);
            insert seLst;
            Business_Rules__c br = [SELECT id, BS_Req_for_certain_Rev_Range__c FROM Business_Rules__c LIMIT 1];
            br.BS_Req_for_certain_Rev_Range__c = 'No';
            update br;
            update seLst;
        }
    }

    static testMethod void testBestActionlogic_BAL_3() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            List<Strategy_Engine__c> seLst = new List<Strategy_Engine__c>();
            Blue_Sheet__c bs = [SELECT id, Opportunity__c FROM Blue_Sheet__c LIMIT 1];
            Strategy_Engine__c se = TestDataUtil.createStrategyEngine(bs, false);
            se.Place_in_Sales_Funnel__c = 'Qualification';
            se.Opportunity_Amount__c = 200;
            se.Bluesheet_Last_Modified_Date__c = DateTime.now() - 10;
            seLst.add(se);
            insert seLst;
            se.Bluesheet_Last_Modified_Date__c = DateTime.now() - 1;
            update se;
        }
    }

    static testMethod void testBestActionlogic_BAL_4() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            List<Strategy_Engine__c> seLst = new List<Strategy_Engine__c>();
            Blue_Sheet__c bs = [SELECT id, Opportunity__c FROM Blue_Sheet__c LIMIT 1];
            Strategy_Engine__c se = TestDataUtil.createStrategyEngine(bs, false);
            se.Place_in_Sales_Funnel__c = 'Qualification';
            se.Opportunity_Amount__c = 200;
            se.Opty_Close_Date__c = Date.today() - 1;
            seLst.add(se);
            insert seLst;
            se.Opty_Close_Date__c = Date.today() + 1;
            update se;
        }
    }

    static testMethod void testBestActionlogic_BAL_5() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            List<Strategy_Engine__c> seLst = new List<Strategy_Engine__c>();
            Blue_Sheet__c bs = [SELECT id, Opportunity__c FROM Blue_Sheet__c LIMIT 1];
            Strategy_Engine__c se = TestDataUtil.createStrategyEngine(bs, false);
            se.Place_in_Sales_Funnel__c = 'Qualification';
            se.Opportunity_Amount__c = 200;
            se.Opty_Stage_Last_Modified_Date__c = Date.today() - 10;
            seLst.add(se);
            insert seLst;
            se.Opty_Stage_Last_Modified_Date__c = Date.today() + 10;
            update se;
        }
    }

    static testMethod void testBestActionlogic_BAL_6() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            List<Strategy_Engine__c> seLst = new List<Strategy_Engine__c>();
            Blue_Sheet__c bs = [SELECT id, Opportunity__c FROM Blue_Sheet__c LIMIT 1];
            Strategy_Engine__c se = TestDataUtil.createStrategyEngine(bs, false);
            se.Place_in_Sales_Funnel__c = 'Qualification';
            se.Opportunity_Amount__c = 200;
            se.Bluesheet_Count_Actions__c = 5;
            seLst.add(se);
            insert seLst;
            se.Bluesheet_Count_Actions__c = 10;
            update se;
        }
    }

    static testMethod void testBestActionlogic_BAL_7() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            List<Strategy_Engine__c> seLst = new List<Strategy_Engine__c>();
            Blue_Sheet__c bs = [SELECT id, Opportunity__c FROM Blue_Sheet__c LIMIT 1];
            Strategy_Engine__c se = TestDataUtil.createStrategyEngine(bs, false);
            se.Place_in_Sales_Funnel__c = 'Qualification';
            se.Opportunity_Amount__c = 200;
            se.Best_Action_Due_Date__c = Date.today() - 5;
            seLst.add(se);
            insert seLst;
            se.Best_Action_Due_Date__c = Date.today() + 5;
            update se;
        }
    }
*/
    /*
     static testMethod void testBestActionlogic_BAL_A1() {
        Business_Rules__c br1 = new Business_Rules__c(
            Is_a_Blue_Sheet_required__c = 'Yes',
            Opty_Amount_1__c = 100,
            Opty_Stage_1__c = 'Qualification',
            Max_Days_Allowed_Since_Last_BS_Update__c = 5
        );
        insert br1;
        
        List<Strategy_Engine__c> seLst = new List<Strategy_Engine__c>();
        Blue_Sheet__c bs = [Select id, Opportunity__c from Blue_Sheet__c limit 1];
        Strategy_Engine__c se = TestDataUtil.createStrategyEngine(bs,false);
        se.Place_in_Sales_Funnel__c = 'Qualification';
        se.Opportunity_Amount__c = 200;
        
        seLst.add(se);
        //insert seLst;
        String soqlRecommedations = 'Select Id,BestActionLogic__c,Business_Rules__c,Seller_Recommended_Action_Message__c,Manager_Recommended_Action_Message__c,Strategy_Engine__c from Recommendations__c';
        Map<String,Object> parameters = new Map<String,Object>();
        
        List<Recommendations__c> recommendationsLst = DataFactory.read(soqlRecommedations,parameters);
        System.debug(recommendationsLst);
        
        se.Bluesheet_Last_Modified_Date__c = DateTime.now() - 10;
        update se;
        
     }*/
}