@isTest
public with sharing class EmailAlertServiceTest {
    @testSetup
    static void testData() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            ManageBusinessRulesAlertMessages insertBusinessRulesMsg = new ManageBusinessRulesAlertMessages();
            insertBusinessRulesMsg.insertBusinessRulesMessages();
            String oppStageId = TestDataUtil.getOppStageId();
            Business_Rules_Group__c brg = new Business_Rules_Group__c();
            brg.name = 'EasterGrp';
            insert brg;
            Business_Rules_Group_Member__c brgm = new Business_Rules_Group_Member__c();
            brgm.Member_Name__c = user.Id;
            brgm.Business_Rules_Group__c = brg.Id;
            insert brgm;
            List<Business_Rules__c> brLst = new List<Business_Rules__c>();
            Business_Rules__c br1 = new Business_Rules__c(
                IsActive__c = true,
                Opportunity_Stage_Global__c = 'Qualification,Prospecting',
                Business_Rule_Catagory__c = 'Opportunity',
                Opportunity_Currency_Fields__c = 'Amount',
                Minimum_Range__c = 1000,
                Maximum_Range__c = 10000,
                Max_Days_Allowed_in_a_Opty_Stage__c = 2,
                Is_a_Blue_Sheet_required__c = 'Yes',
                is_closed_date_past__c = true,
                Business_Rules_Group__c = brg.Id
            );
            Business_Rules__c br2 = new Business_Rules__c(
                IsActive__c = true,
                Opportunity_Stage_Global__c = 'Qualification',
                Business_Rule_Catagory__c = 'Meeting Plan',
                Is_Minimum_Action_Commitment_Added__c = true,
                Is_Concept_for_BI_Added__c = true,
                Is_Valid_Business_Reason_Added__c = true,
                Is_Best_Action_Commitment_Added__c = true,
                Number_of_Days_Before_Meeting__c = 4,
                Business_Rules_Group__c = brg.Id
            );
            brLst.add(br1);
            brLst.add(br2);
            insert brLst;
            Account acc = TestDataUtil.createAccount(true);
        }


        /*System.runAs(user2) {
             
             
             //Blue_Sheet__c blueSheet = TestDataUtil.createBluesheet(oppuser2, true);
             //Competition__c competition = TestDataUtil.createCompetition(blueSheet, acc2, true);
         }*/
        /* System.runAs(userManager) {
             Account acc2 = TestDataUtil.createAccount(true);
             Opportunity oppUserM = TestDataUtil.createOpportunity(acc2, true);
             Blue_Sheet__c blueSheetUserM = TestDataUtil.createBluesheet(oppUserM, true);
             Competition__c competitionUserM = TestDataUtil.createCompetition(blueSheetUserM, acc2, true);
         }*/
    }

    @isTest
    static void createBlueSheetAlert() {
        User user = UserTest.createUserWithPerms();
        User userManager = UserTest.createUserAsManager();
        user.ManagerId = userManager.Id;
        update user;

        System.runAs(user) {
            List<Folder> folderLst = [SELECT Id, name, AccessType FROM Folder];
            String folderId = '';
            for (Folder f : folderLst) {
                system.debug(f.name + '---FOlder---' + f.AccessType);
                if (f.Name == 'KF Sell') {
                    folderId = f.Id;
                    //break;
                }
            }

            EmailTemplate e = new EmailTemplate(
                developerName = 'kf_alert_email',
                FolderId = userInfo.getUserId(),
                TemplateType = 'Text',
                Name = 'kf_alert_email',
                Subject = 'KF Sell Actions Report'
            ); // plus any other fields that you want to set
            insert e;

            Account acc = [SELECT Id FROM Account LIMIT 1];
            Opportunity op = TestDataUtil.createOpportunity(acc, false);
            op.amount = 3000;
            insert op;
            Contact con = TestDataUtil.createContact(acc, true);
            List<Task> taskList = TestDataUtil.createTaskList(user, false);
            for (Task t : taskList) {
                t.ActivityDate = system.Date.today() + 3;
                t.WhatId = op.Id;
            }
            insert taskList;
            Green_Sheet__c greenSheet = TestDataUtil.createGreenSheet(taskList[0], false);
            greenSheet.Meeting_Date__c = taskList[0].ActivityDate;
            greenSheet.Opportunity__c = op.Id;
            greenSheet.Reason__c = null;
            insert greenSheet;

            Test.startTest();
            Business_Rules__c br1 = [
                SELECT Id, Name, Business_Rule_Catagory__c
                FROM Business_Rules__c
                WHERE Business_Rule_Catagory__c = 'Opportunity'
                LIMIT 1
            ];
            List<KF_Sell_Best__c> bestAction = [
                SELECT Id, Name, Seller_Recommended_Action__c, Action_Title__c, BestActionRuleId__c
                FROM KF_Sell_Best__c
                WHERE BestActionRuleId__c = 'BAL_1' AND Business_Rules__c = :br1.Id
                LIMIT 1
            ];
            system.assertEquals(bestAction.size(), 1, 'Checking size of best action list');
            GreenSheetRulesEvaluatorBatch greensheetBatch = new GreenSheetRulesEvaluatorBatch();
            Database.executeBatch(greensheetBatch, 150);
            //system.assertEquals(bestAction[0].BestActionRuleId__c, 'BAL_1', 'Checking BAL ID');
            String schedmon5am = '0 00 05 ? * 2'; //Every Monday, 5AM
            EmailAlertService emailJob = new EmailAlertService();
            System.schedule('ScheduleClassNameStr - Monday 5AM', schedmon5am, emailJob);
            Test.stopTest();
            Business_Rules__c br2 = [
                SELECT Id, Name, Business_Rule_Catagory__c
                FROM Business_Rules__c
                WHERE Business_Rule_Catagory__c = 'Meeting Plan'
                LIMIT 1
            ];
            List<KF_Sell_Best__c> bestAction2 = [
                SELECT Id, Name, Seller_Recommended_Action__c, Action_Title__c
                FROM KF_Sell_Best__c
                WHERE Green_Sheet__c = :greenSheet.Id AND Business_Rules__c = :br2.Id AND BestActionRuleId__c = 'BAL_27'
            ];
            system.assertEquals(1, bestAction2.size(), 'record does not match');
        }
    }

    /*
    @isTest
    static void testbuildWrapperCollection() {
        User user = UserTest.createUserWithPerms();
        User users = [SELECT Id, Name, ManagerId FROM User WHERE ManagerId != null LIMIT 1];
        String userid = users.ManagerId;
        User usersMan = [SELECT Id, Name FROM User WHERE Id = :userid LIMIT 1];
        user.ManagerId = users.ManagerId;
        user.Email = 'bhagyashree.mandlik@atos.net';
        update user;
        System.runAs(user) {
            Business_Rules_Group__c brg = new Business_Rules_Group__c();
            brg.name = 'EasterGrp';
            insert brg;
            Business_Rules_Group_Member__c brgm = new Business_Rules_Group_Member__c();
            brgm.Member_Name__c = user.Id;
            brgm.Business_Rules_Group__c = brg.Id;
            insert brgm;
            List<Business_Rules__c> brLst = new List<Business_Rules__c>();
            Business_Rules__c br1 = new Business_Rules__c(
                Business_Rules_Group__c = brg.Id,
                IsActive__c = true,
                is_curr_pos_negative__c = true,
                is_closed_date_past__c = true
            );
            brLst.add(br1);

            Business_Rules__c br2 = new Business_Rules__c(
                Business_Rules_Group__c = brg.Id,
                IsActive__c = true,
                Is_Valid_Business_Reason_Added__c = true,
                Is_Minimum_Action_Commitment_Added__c = true,
                Is_Concept_for_BI_Added__c = true,
                Is_Best_Action_Commitment_Added__c = true,
                Number_of_Days_Before_Meeting__c = 4
            );
            brLst.add(br2);
            insert brLst;

            Account acc2 = TestDataUtil.createAccount(true);
            Contact con = TestDataUtil.createContact(acc2, true);
            Opportunity oppuser2 = TestDataUtil.createOpportunity(acc2, false);
            oppuser2.CloseDate = date.TODAY().addDays(-30);
            insert oppuser2;
            Opportunity op1 = [SELECT Id, OwnerId, CloseDate FROM Opportunity WHERE Name = 'Test Opportunity'];
            List<Task> taskList = TestDataUtil.createTaskList(user, true);
            taskList[0].WhatId = op1.Id;
            taskList[0].ActivityDate = date.TODAY().addDays(3);
            update taskList[0];
            Green_Sheet__c greenSheet = TestDataUtil.createGreenSheet(taskList[0], true);
            Green_Sheet_Buying_Influence__c greenBI1 = new Green_Sheet_Buying_Influence__c(
                Contact__c = con.Id,
                Buying_Influence_Role__c = 'economic',
                Green_Sheet__c = greenSheet.Id
            );
            insert greenBI1;
            taskList[1].WhatId = oppuser2.Id;
            taskList[1].ActivityDate = date.TODAY().addDays(2);
            update taskList[1];
            Green_Sheet__c greenSheet1 = TestDataUtil.createGreenSheet(taskList[1], true);
            Getting_Commitment__c gc1 = new Getting_Commitment__c(Green_Sheet__c = greenSheet1.Id);
            insert gc1;
            List<Commitment_Question__c> commitQuestList = TestDataUtil.createGreenSheetCommitmentQuestion(gc1, true);
            StrategyEngine.createBlueSheet(op1.id);
            KF_Sell_Best__c kfSellBest = TestDataUtil.createKfSellBestAction(op1, greenSheet, true);

            Test.startTest();
            EmailAlertService.getUserManager(user.Id);
            String hour = String.valueOf(Datetime.now().hour());
            String min = String.valueOf(Datetime.now().minute() + 2);
            String ss = String.valueOf(Datetime.now().second());
            //parse to cron expression
            String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';
            system.debug(nextFireTime);
            EmailAlertService s = new EmailAlertService();
            //  System.schedule('Job Started At ' + String.valueOf(Datetime.now()), nextFireTime, s);
            Test.stopTest();
            System.assertEquals(true, true, 'This line execution means no exception and Email sent');
        }
        /*System.runAs(usersMan) {
            Test.startTest();
            EmailAlertService.getUserManager(user.Id);
            String hour = String.valueOf(Datetime.now().hour());
            String min = String.valueOf(Datetime.now().minute() + 2);
            String ss = String.valueOf(Datetime.now().second());
            //parse to cron expression
            String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';
            system.debug(nextFireTime);
            EmailAlertService s = new EmailAlertService();
            System.schedule('Job Started At ' + String.valueOf(Datetime.now()), nextFireTime, s);
            Test.stopTest();

            // EmailAlertService.processTOSendEmail();
            System.assertEquals(true, true, 'This line execution means no exception and Manager Email sent');
            // Test.stopTest();
        }
    }*/

    /*
    UserTest.createUser(new  List<String>{ 'KF_Admin', 'Blue_Sheet_Edit' })
    static void processEmailData () {       
        Test.startTest();           
        Test.stopTest();        
    }*/
}