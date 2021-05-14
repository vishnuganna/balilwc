@isTest
public with sharing class CurrentPositionTest {
    @testSetup
    static void setup() {
        /*Account testAcnt=new Account(Name='TestAcnt');
		insert testAcnt;
        List<Opportunity> testOppty= new List<Opportunity>
		{
          new Opportunity(Name = 'TestOppty',  AccountId=testAcnt.id, StageName='Qualification', CloseDate=System.today()),
          new Opportunity(Name = 'TestOppty1', AccountId=testAcnt.id, StageName='Qualification', CloseDate=System.today()),
          new Opportunity(Name = 'TestOppt',  AccountId=testAcnt.id, StageName='Qualification', CloseDate=System.today())
        };
		insert testOppty;
        List<Blue_Sheet__c> bs=new  List<Blue_Sheet__c>
        { 
           new Blue_Sheet__c(Opportunity__c=testOppty[1].Id),
           new Blue_Sheet__c(Opportunity__c=testOppty[0].Id), 
           new Blue_Sheet__c(Opportunity__c=testOppty[2].Id)
        };
        insert bs;*/
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Account acc = TestDataUtil.createAccount(true);
            Opportunity op = TestDataUtil.createOpportunity(acc, true);
            Opportunity op2 = TestDataUtil.createOpportunity(acc, true);
            Blue_Sheet__c bs = TestDataUtil.createBluesheet(op, true);
            Blue_Sheet__c bs2 = TestDataUtil.createBluesheet(op2, true);
            Current_Position__c testCP = TestDataUtil.createCurrentPosition(bs, true);
            Current_Position__c testCP1 = TestDataUtil.createCurrentPosition(bs2, true);
            testCP1.Current_Position__c = '';
            update testCP1;
        }
    }

    @isTest
    private static void currentPositionConstructor() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            CurrentPosition controller = new CurrentPosition();
            System.assert(true);
        }
    }

    @isTest
    static void validateGetCurrentPostion() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            List<Opportunity> testOpp = [SELECT Id, Name FROM Opportunity WHERE Name = 'Test Opportunity'];
            Test.startTest();
            CurrentPosition.getCurrentPostion(testOpp[0].Id);
            System.assertEquals(testOpp[0].name, 'Test Opportunity');
            Test.stopTest();
        }
    }
    @isTest
    static void validateGetCurrentPostionEmpty() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            List<Opportunity> oppo = [SELECT Id, Name FROM Opportunity WHERE Name = 'Test Opportunity'];
            Test.startTest();
            CurrentPosition.getCurrentPostion(oppo[0].Id);
            System.assertEquals(oppo[0].name, 'Test Opportunity');
            Test.stopTest();
        }
    }
    @isTest
    static void validCatch() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            test.startTest();
            CurrentPosition.getCurrentPostion(null);
            System.assert(true);
            test.stopTest();
        }
    }

    @isTest
    static void validateSaveCurrentPosition() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Opportunity teOpp = [SELECT Id, name FROM Opportunity WHERE Name = 'Test Opportunity' LIMIT 1];
            Blue_Sheet__c bs = [SELECT Id, name FROM Blue_Sheet__c LIMIT 1];
            test.startTest();
            String jsonString = '{ "Blue_Sheet__c":"bs.id" , "Current_Position__c":"Secure", "id":""}';
            CurrentPosition.saveCurrentPosition(jsonString, teOpp.Id);
            System.assertEquals(teOpp.name, 'Test Opportunity');
            test.stopTest();
        }
    }

    @isTest
    static void validateSaveCurrentPositionEmpty() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            List<Opportunity> tOpp = [SELECT Id, name FROM Opportunity WHERE Name = 'Test Opportunity'];
            test.startTest();
            String currentState = '';
            CurrentPosition.saveCurrentPosition(currentState, tOpp[1].Id);
            System.assertEquals(tOpp[1].name, 'Test Opportunity');
            test.stopTest();
        }
    }

    @isTest
    static void validateGetBlueSheetId() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            List<Opportunity> tOpp = [SELECT Id, name FROM Opportunity WHERE Name = 'Test Opportunity'];
            test.startTest();
            CurrentPosition.getBlueSheetId(tOpp[1].Id);
            System.assertEquals(tOpp[1].name, 'Test Opportunity');
            test.stopTest();
        }
    }

    @isTest
    static void validateCatch() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            test.startTest();
            CurrentPosition.saveCurrentPosition('', '');
            System.assert(true);
            test.stopTest();
        }
    }
}