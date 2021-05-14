public with sharing class GetRecordDetailsOfOpportunity {
    /* public GetRecordDetailsOfOpportunity() {

    } 
   @AuraEnabled 
    public static String getBlueSheetId(string opptId) {
        List<Blue_Sheet__c> getOpptBlueSheet = new List<Blue_Sheet__c>();
        getOpptBlueSheet = [SELECT Id, Name FROM Blue_Sheet__c where Opportunity__c =: opptId limit 1];
        System.debug('Oppt Id'+opptId);
        System.debug('Bluesheet Id' + getOpptBlueSheet[0].Id);
        return string.valueof(getOpptBlueSheet[0].Id);
    }

    @AuraEnabled
    public static List<Action_Plan__c> getActionPlan(String opptId){
        List<Blue_Sheet__c> getOpptBlueSheet = [SELECT Id, Name FROM Blue_Sheet__c where Opportunity__c =: opptId limit 1];
        //KFC-146- Added Is_a_Best_Action__c Field in Query
        List<Action_plan__c> relActionPlan = [select id,Summary__c,Description__c,Priority__c,Status__c,Action_Type__c,Contact__r.Name,AssignedTo__r.Name,Start_Date__c,Due_Date__c,Is_a_Best_Action__c from Action_Plan__c where blue_sheet__c =:getOpptBlueSheet[0].Id Order By CreatedDate];
        if(relActionPlan.size()>0){
            return relActionPlan;
        }
        else{
            return null;
        }   
    }

    @AuraEnabled
    public static void insertActionPlan(String actnPlan){
        system.debug('Data***  '+ actnPlan);
        
        
        Map<String,Object> actnPlanDataMap =(Map<String,Object>)JSON.deserializeUntyped(actnPlan);
        Action_Plan__c actnPlanrcrd     = new Action_Plan__c();
        actnPlanrcrd.Blue_Sheet__c      = (String)actnPlanDataMap.get('BluesheetId');
        actnPlanrcrd.Is_a_Best_Action__c = (Boolean)actnPlanDataMap.get('bestActionvalue');//146
        actnPlanrcrd.Summary__c         = (String)actnPlanDataMap.get('Summary');
        actnPlanrcrd.Description__c     = (String)actnPlanDataMap.get('Description');
        actnPlanrcrd.Action_Type__c     = (String)actnPlanDataMap.get('ActionType');
        if((String)actnPlanDataMap.get('Contact')!='' && (String)actnPlanDataMap.get('Contact')!= null && (String)actnPlanDataMap.get('Contact')!= 'null' && (String)actnPlanDataMap.get('Contact')!='undefined'){
            actnPlanrcrd.Contact__c         = (String)actnPlanDataMap.get('Contact');
        }
        actnPlanrcrd.Status__c          = (String)actnPlanDataMap.get('Status');
        system.debug('Date***  '+ (String)actnPlanDataMap.get('StartDate'));
        if((String)actnPlanDataMap.get('StartDate')!='' && (String)actnPlanDataMap.get('StartDate')!= null && (String)actnPlanDataMap.get('StartDate')!= 'null' && (String)actnPlanDataMap.get('StartDate')!='undefined'){
            system.debug('DateIN***  '+ (String)actnPlanDataMap.get('StartDate'));
            actnPlanrcrd.Start_Date__c  = date.valueOf((String)actnPlanDataMap.get('StartDate'));
        }
        if((String)actnPlanDataMap.get('DueDate') != '' && (String)actnPlanDataMap.get('DueDate')!= null && (String)actnPlanDataMap.get('DueDate')!= 'null' && (String)actnPlanDataMap.get('DueDate')!='undefined'){
            system.debug('DateINO***  '+ (String)actnPlanDataMap.get('StartDate'));
            actnPlanrcrd.Due_Date__c    = date.valueOf((String)actnPlanDataMap.get('DueDate') );
        }
        
        actnPlanrcrd.Priority__c        = (String)actnPlanDataMap.get('Priority');
        actnPlanrcrd.Blue_Sheet__c      = (String)actnPlanDataMap.get('BluesheetId');
        if((String)actnPlanDataMap.get('AssignedTo')!='' && (String)actnPlanDataMap.get('AssignedTo')!= null && (String)actnPlanDataMap.get('AssignedTo')!= 'null' && (String)actnPlanDataMap.get('AssignedTo')!='undefined'){
            actnPlanrcrd.AssignedTo__c     = (String)actnPlanDataMap.get('AssignedTo');
        }
        system.debug('DataFinal***  '+ actnPlanrcrd);
        DataFactory.create(actnPlanrcrd);
        
    }
    
    @AuraEnabled
    public static Single_Sales_Objective__c getSingleSalesObject(Id opptId) {
        List<Blue_Sheet__c> getOpptBlueSheet = new List<Blue_Sheet__c>();
        List<Single_Sales_Objective__c> getobjSingleSales = new List<Single_Sales_Objective__c>();
        Single_Sales_Objective__c objSalesObject = new Single_Sales_Objective__c();

        getOpptBlueSheet = [SELECT Id, Name FROM Blue_Sheet__c where Opportunity__c =: opptId limit 1];
        system.debug('BlueSheetId '+getOpptBlueSheet[0].Id);
        getobjSingleSales = [SELECT Id, Name, Customer_Timing_for_Priorities__c, Customers_Stated_Objectives__c, Evaluation_of_Objectives__c, Blue_Sheet__c FROM Single_Sales_Objective__c where Blue_Sheet__c =: getOpptBlueSheet[0].Id limit 1];
        
        if (!getobjSingleSales.isEmpty() && getobjSingleSales.size() > 0) {
            objSalesObject = getobjSingleSales[0];
        }
        else {
            objSalesObject = null;
        }
        return objSalesObject;
    }
    
    @AuraEnabled
    public static Boolean IsSingleSalesObject(Id opptId) {
        List<Blue_Sheet__c> getOpptBlueSheet = new List<Blue_Sheet__c>();
        List<Single_Sales_Objective__c> getobjSingleSales = new List<Single_Sales_Objective__c>();
        boolean isSingleSalesRecord;

        getOpptBlueSheet = [SELECT Id, Name FROM Blue_Sheet__c where Opportunity__c =: opptId limit 1];
        getobjSingleSales = [SELECT Id, Name, Customer_Timing_for_Priorities__c, Customers_Stated_Objectives__c, Evaluation_of_Objectives__c, Blue_Sheet__c FROM Single_Sales_Objective__c where Blue_Sheet__c =: string.valueof(getOpptBlueSheet[0].Id) limit 1];

        if (!getobjSingleSales.isEmpty() && getobjSingleSales.size() > 0) {
            isSingleSalesRecord = true;
        }
        else {
            isSingleSalesRecord = false;
        }
        return isSingleSalesRecord;
    }*/
}