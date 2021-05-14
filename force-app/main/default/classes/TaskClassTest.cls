@isTest
public with sharing class TaskClassTest {
    @testSetup
    static void setup() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Account acc = TestDataUtil.createAccount(true);
            TestDataUtil.createOpportunity(acc, true);
            Opportunity op1 = TestDataUtil.createOpportunity(acc, false);
            //Opportunity op2 = TestDataUtil.createOpportunity(acc, false);
            //op2.Name = op2.Name + '-2';
            List<Opportunity> oppLst = new List<Opportunity>();
            oppLst.add(op1);
            //oppLst.add(op2);
            insert oppLst;
        }
    }

    @isTest
    static void deleteGreenSheetRecord_test() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            List<Opportunity> oppLst = [SELECT Id FROM Opportunity LIMIT 1];
            Task tsk = new Task();
            tsk.Subject = 'Follow up with Lead';
            tsk.WhatId = oppLst[0].Id;
            tsk.OwnerId = UserInfo.getUserId();
            tsk.Status = 'New';
            tsk.Type = 'Call';
            insert tsk;
            GreenSheetNavigate.createGreenSheet(tsk.Id);
            Green_Sheet__c gs = [SELECT Id FROM Green_Sheet__c LIMIT 1];
            System.assertEquals(gs != null, true, 'Green Sheet record created!');
            //tsk.WhatId = oppLst[1].Id;
            update tsk;
            delete tsk;
            List<Green_Sheet__c> gsLst = [SELECT Id FROM Green_Sheet__c LIMIT 1];
            System.assertEquals(gsLst.isEmpty(), true, 'Green Sheet record deleted!');
        }
    }
}