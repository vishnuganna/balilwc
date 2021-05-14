@isTest
private with sharing class GetRecordDetailsOfOpportunityTest {
    /*static testMethod void GetRecordDetailsOfOpportunity() {
        //create opportunity
        opportunity objOppt = new opportunity();
        objOppt.Name = 'Test Opportunity';
        objOppt.StageName = 'Needs Analysis';
        objOppt.CloseDate = date.today();

        insert objOppt;

        //create bluesheet
        Blue_Sheet__c  objBlueSheet = new Blue_Sheet__c();
        objBlueSheet.Opportunity__c = objOppt.Id;

        insert objBlueSheet;

        //create Single Sales Objective
        Single_Sales_Objective__c objSSO = new Single_Sales_Objective__c();
        objSSO.Blue_Sheet__c = objBlueSheet.Id;
        objSSO.Customers_Stated_Objectives__c = 'Test Record';
        objSSO.Customer_Timing_for_Priorities__c = 'Active';
        objSSO.Evaluation_of_Objectives__c = 'Test Record';

        insert objSSO;

        //create opportunity without SSO
        opportunity objOpptWOS = new opportunity();
        objOpptWOS.Name = 'Test Opportunity';
        objOpptWOS.StageName = 'Needs Analysis';
        objOpptWOS.CloseDate = date.today();

        insert objOpptWOS;

        //create bluesheet without SSO
        Blue_Sheet__c  objBlueSheetWOS = new Blue_Sheet__c();
        objBlueSheetWOS.Opportunity__c = objOpptWOS.Id;

        insert objBlueSheetWOS;

        Test.startTest();
        GetRecordDetailsOfOpportunity objRecDetails = new GetRecordDetailsOfOpportunity();

            GetRecordDetailsOfOpportunity.getBlueSheetId(objOppt.Id);

            GetRecordDetailsOfOpportunity.getSingleSalesObject(objOppt.Id);

            Boolean getResult = GetRecordDetailsOfOpportunity.IsSingleSalesObject(objOppt.Id);

           // GetRecordDetailsOfOpportunity.getSingleSalesObject(objOpptWOS.Id);

            Boolean getResultF = GetRecordDetailsOfOpportunity.IsSingleSalesObject(objOpptWOS.Id);
        Test.stopTest();

        
    }
    static testMethod void GetRecordDetailsOfOpportunitySSO() {
        //create opportunity
        opportunity objOppt = new opportunity();
        objOppt.Name = 'Test Opportunity';
        objOppt.StageName = 'Needs Analysis';
        objOppt.CloseDate = date.today();

        insert objOppt;

        //create bluesheet
        Blue_Sheet__c  objBlueSheet = new Blue_Sheet__c();
        objBlueSheet.Opportunity__c = objOppt.Id;

        insert objBlueSheet;

        //create Single Sales Objective
        Single_Sales_Objective__c objSSO = new Single_Sales_Objective__c();
        objSSO.Blue_Sheet__c = objBlueSheet.Id;
        objSSO.Customers_Stated_Objectives__c = 'Test Record';
        objSSO.Customer_Timing_for_Priorities__c = 'Active';
        objSSO.Evaluation_of_Objectives__c = 'Test Record';

        insert objSSO;

        //create opportunity without SSO
        opportunity objOpptWOS = new opportunity();
        objOpptWOS.Name = 'Test Opportunity';
        objOpptWOS.StageName = 'Needs Analysis';
        objOpptWOS.CloseDate = date.today();

        insert objOpptWOS;

        //create bluesheet without SSO
        Blue_Sheet__c  objBlueSheetWOS = new Blue_Sheet__c();
        objBlueSheetWOS.Opportunity__c = objOpptWOS.Id;

        insert objBlueSheetWOS;

        Test.startTest();
        GetRecordDetailsOfOpportunity objRecDetails = new GetRecordDetailsOfOpportunity();

            GetRecordDetailsOfOpportunity.getBlueSheetId(objOppt.Id);

            //GetRecordDetailsOfOpportunity.getSingleSalesObject(objOppt.Id);

            Boolean getResult = GetRecordDetailsOfOpportunity.IsSingleSalesObject(objOppt.Id);

            GetRecordDetailsOfOpportunity.getSingleSalesObject(objOpptWOS.Id);

            Boolean getResultF = GetRecordDetailsOfOpportunity.IsSingleSalesObject(objOpptWOS.Id);
        Test.stopTest();

        
    }*/
}