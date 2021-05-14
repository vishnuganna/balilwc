@isTest
public with sharing class BuyingInfluenceWrapperTest {
    @testSetup
    static void setup() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Account acc = TestDataUtil.createAccount(true);
            Opportunity op = TestDataUtil.createOpportunity(acc, true);
            Contact con = TestDataUtil.createContact(acc, true);
            Blue_Sheet__c bs = TestDataUtil.createBluesheet(op, true);
            List<Buying_Influence__c> biList = TestDataUtil.createBuyingInfluence(bs, con, true);
        }
    }

    @isTest
    static void validateConstructor() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Test.startTest();
            BuyingInfluenceWrapperClass biWrapper = new BuyingInfluenceWrapperClass();
            Test.stopTest();
            system.assertEquals(true, biWrapper != null);
        }
    }

    @isTest
    static void validateConstrPara() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            List<Buying_Influence__c> bi = [
                SELECT
                    Id,
                    Name,
                    Blue_Sheet__r.Opportunity__c,
                    Title__c,
                    Contact__r.Name,
                    Contact__r.FirstName,
                    Contact__r.LastName,
                    Contact__r.MailingState,
                    Contact__r.MailingCountry,
                    Blue_Sheet__c,
                    Buying_from_Someone_Else__c,
                    Location__c,
                    Over_Confident__c,
                    Rating_Text__c,
                    Search_Competitor__c,
                    Using_Budget_for_Something_Else__c,
                    Using_Internal_Resources__c,
                    Buying_From_Us__c,
                    Even_Keel__c,
                    Trouble__c,
                    Business_Results__c,
                    Personal_Wins__c,
                    Contact__c,
                    Rating__c,
                    Doing_Nothing__c,
                    Rating_Evidence__c,
                    High__c,
                    Medium__c,
                    Low__c,
                    Economic__c,
                    Coach__c,
                    Technical__c,
                    User__c,
                    Growth__c
                FROM Buying_Influence__c
                LIMIT 1
            ];
            Opportunity opp = [SELECT id, name FROM Opportunity LIMIT 1];

            Test.startTest();
            BuyingInfluenceWrapperClass biWrapper = new BuyingInfluenceWrapperClass(bi[0]);
            BuyingInfluenceWrapperClass.convertWrapperToObject(biWrapper);
            System.assertEquals(opp.name, 'Test Opportunity');
            Test.stopTest();
        }
    }
}