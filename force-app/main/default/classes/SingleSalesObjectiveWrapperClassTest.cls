@isTest
private with sharing class SingleSalesObjectiveWrapperClassTest {
    /*
    static void testData() {
		//create opportunity
        opportunity objOppt = new opportunity();
        objOppt.Name = 'Test Opportunity';
        objOppt.StageName = 'Needs Analysis';
        objOppt.CloseDate = date.today();
        insert objOppt;
        
        Blue_Sheet__c blueSheet = [SELECT Id, Name FROM Blue_Sheet__c WHERE Opportunity__c =: objOppt.Id LIMIT 1];
        
        Single_Sales_Objective__c sso = new Single_Sales_Objective__c();
        sso.Blue_Sheet__c = blueSheet.Id;
        sso.Customer_Timing_for_Priorities__c = 'Test Priorities';
        sso.Customers_Stated_Objectives__c = 'Test Objectives';
        sso.Evaluation_of_Objectives__c = 'Test Evaluation';
        insert sso;
    }
     
    static testMethod void ssoWrapperClass_testMethod() {
        testData();
        Test.startTest();
        Single_Sales_Objective__c sso = [SELECT Id, Name, Blue_Sheet__c, Customer_Timing_for_Priorities__c, 
                                         Customers_Stated_Objectives__c, Evaluation_of_Objectives__c FROM Single_Sales_Objective__c LIMIT 1];
        ssoWrapperClass wrap = new ssoWrapperClass(sso, true);
        Test.stopTest();
     }*/
}