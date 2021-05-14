/* Test class for SEFieldsPopulation class*/

@isTest
public with sharing class SEFieldsPopulationTestClass {
    /*  @testSetup 
    static void setup() {
    
        Account testAcnt=new Account(Name='TestAcnt');        
        List<Account> acntList=new List<Account>();
        acntList.add(testAcnt);
        insert acntList;
        
        Contact testCon=new Contact(AccountId=testAcnt.id, FirstName='Test1', LastName='Con1', level__c='Primary');
        List<Contact> contList=new List<Contact>();
        contList.add(testCon);
        insert contList;
        
        Opportunity testOppty=new Opportunity(Name = 'TestOppty', AccountId=testAcnt.id, StageName='Qualification', CloseDate=System.today(), Amount=500);
        Opportunity testOppty1=new Opportunity(Name = 'TestOppty1', AccountId=testAcnt.id, StageName='Qualification', CloseDate=System.today(), Amount=5000);
        List<Opportunity> opList=new List<Opportunity>();
        opList.add(testOppty);
        opList.add(testOppty1);
        insert opList;
        
        Blue_Sheet__c bs=new Blue_Sheet__c(Opportunity__c=testOppty.id);
        Blue_Sheet__c bs1=new Blue_Sheet__c(Opportunity__c=testOppty1.id);
        List<Blue_Sheet__c> bsList=new List<Blue_Sheet__c>();
        bsList.add(bs);
        bsList.add(bs1);
        insert bsList;
        
        Current_Position__c testCp=new Current_Position__c(Current_Position__c='Comfort', Blue_Sheet__c=bs.id);
        Current_Position__c testCp1=new Current_Position__c(Current_Position__c='Fear', Blue_Sheet__c=bs1.id);
        List<Current_Position__c> cpList=new List<Current_Position__c>();
        cpList.add(testCP);
        cpList.add(testCP1);
        insert cpList;
        
        Single_Sales_Objective__c sso=new Single_Sales_Objective__c(Blue_Sheet__c=bs.id, Customer_Timing_for_Priorities__c='Active', Customers_Stated_Objectives__c='check', Evaluation_of_Objectives__c='check');
        List<Single_Sales_Objective__c> ssoList=new List<Single_Sales_Objective__c>();
        ssoList.add(sso);
        insert ssoList;
        
        Buying_Influence__c bi=new Buying_Influence__c(Blue_Sheet__c=bs.id, Rating__c='+4', Contact__c=testCon.id, Growth__c=true, Personal_Wins__c='personal win');
        List<Buying_Influence__c> biList=new List<Buying_Influence__c>();
        biList.add(bi);
        insert biList;
        
        Competition__c comp=new Competition__c(Blue_Sheet__c=bs.id, Competitive_Detail__c='detail', My_Position_Vs_Competitor__c='Zero', Competitor_Type__c='Named Competitor');
        Competition__c comp1=new Competition__c(Blue_Sheet__c=bs.id, Competitive_Detail__c='detail', My_Position_Vs_Competitor__c='Only Alternative', Competitor_Type__c='Doing Nothing');
        List<Competition__c> compList=new List<Competition__c>();
        compList.add(comp);
        insert compList;
        
        Strength__c testStr=new Strength__c(Blue_Sheet__c=bs.id);
        List<Strength__c> strList=new List<Strength__c>();
        strList.add(testStr);
        insert strList;
        
        Red_Flag__c testRf=new Red_Flag__c(Blue_Sheet__c=bs.id);
        List<Red_Flag__c> rfList=new List<Red_Flag__c>();
        rfList.add(testRf);
        insert rfList;
        
        Business_Rules__c br1=new Business_Rules__c(Field_Name__c='Customer Stated Objective', Criteria__c='Populated', Points__c=5);
        Business_Rules__c br2=new Business_Rules__c(Field_Name__c='Position is Positive', Criteria__c='Populated- Euphoria, Great, Secure, Comfort, OK', Points__c=15);
        Business_Rules__c br3=new Business_Rules__c(Field_Name__c='Position is Negative', Criteria__c='Populated- Concern, Discomfort, Worry, Fear, Panic', Points__c=2);
        Business_Rules__c br4=new Business_Rules__c(Field_Name__c='Competition Detail Field', Criteria__c='Populated', Points__c=10);
        Business_Rules__c br5=new Business_Rules__c(Field_Name__c='My Position Vs. Competition- Positive', Criteria__c='Only Alternative, Front Runner', Points__c=20);
        Business_Rules__c br6=new Business_Rules__c(Field_Name__c='Competition Type- Positive', Criteria__c='Populated- Named Competitor/Buying from Someone Else', Points__c=7);
        Business_Rules__c br7=new Business_Rules__c(Field_Name__c='Rating- Positive', Criteria__c='Plus 2 to Plus 5', Points__c=9);
        List<Business_Rules__c> brRules=new List<Business_Rules__c>();
        brRules.add(br1);
        brRules.add(br2);
        brRules.add(br3);
        brRules.add(br4);
        brRules.add(br5);
        brRules.add(br6);
        brRules.add(br7);
        insert brRules;
    }
    
    @isTest
    static void validateseFieldsPopulationforAcnt() {
    
        List<Account> acList=[Select id, name from Account];
        List<Id> acIdList=new List<Id>();
        for(Account ac:acList){
            acIdList.add(ac.id);
        }        
        Test.startTest();
        SEFieldsPopulation.seFieldsPopulation(acIdList);
        Test.stopTest();
    }
            
    @isTest
    static void validateseFieldsPopulationforOpp() {
    
        List<Opportunity> opList=[Select id, name from Opportunity];
        List<Id> opIdList=new List<Id>();
        for(Opportunity op:opList){
            opIdList.add(op.id);
        }        
        Test.startTest();
        SEFieldsPopulation.seFieldsPopulation(opIdList);
        Test.stopTest();
    }
    
    @isTest
    static void validateseFieldsPopulationforCon() {
    
        List<Contact> conList=[Select id, name, accountId from Contact];
        List<Id> conIdList=new List<Id>();
        for(Contact con:conList){
            conIdList.add(con.id);
        }        
        Test.startTest();
        SEFieldsPopulation.seFieldsPopulation(conIdList);
        Test.stopTest();
    }
    
    @isTest
    static void validateseFieldsPopulationforBS() {
    
        List<Blue_sheet__c> bsList=[Select id, name, Opportunity__c from Blue_sheet__c];
        List<Id> bsIdList=new List<Id>();
        for(Blue_sheet__c bs:bsList){
            bsIdList.add(bs.id);
        }        
        Test.startTest();
        SEFieldsPopulation.seFieldsPopulation(bsIdList);
        Test.stopTest();
    }
    
   @isTest
    static void validateseFieldsPopulationforSSO() {
    
        List<Single_Sales_Objective__c> ssoList=[Select id, name, Blue_Sheet__c, Customer_Timing_for_Priorities__c, Evaluation_of_Objectives__c, Customers_Stated_Objectives__c from Single_Sales_Objective__c];
        List<Id> ssoIdList=new List<Id>();
        for(Single_Sales_Objective__c sso:ssoList){
            ssoIdList.add(sso.id);
        }        
        List<Business_Rules__c> brRules = [Select id, Field_Name__c, Criteria__c, Points__c from Business_Rules__c];
        Test.startTest();
        SEFieldsPopulation.seFieldsPopulation(ssoIdList);
        Test.stopTest();
    }
    
    @isTest
    static void validateseFieldsPopulationforCP() {
    
        List<Current_Position__c> cpList=[Select id, name, Blue_Sheet__c, Current_Position__c from Current_Position__c];
        List<Id> cpIdList=new List<Id>();
        for(Current_Position__c cp:cpList){
            cpIdList.add(cp.id);
        }        
        List<Business_Rules__c> brRules = [Select id, Field_Name__c, Criteria__c, Points__c from Business_Rules__c];
        Test.startTest();
        SEFieldsPopulation.seFieldsPopulation(cpIdList);
        Test.stopTest();
    } 
    
    @isTest
    static void validateseFieldsPopulationforBI() {
    
        List<Buying_Influence__c> biList=[Select id, name, Blue_Sheet__c, Rating__c, Contact__c, Growth__c, Personal_Wins__c from Buying_Influence__c];
        List<Id> biIdList=new List<Id>();
        for(Buying_Influence__c bi:biList){
            biIdList.add(bi.id);
        }        
        Test.startTest();
        SEFieldsPopulation.seFieldsPopulation(biIdList);
        Test.stopTest();
    } 
    
    @isTest
    static void validateseFieldsPopulationforComp() {
    
        List<Competition__c> compList=[Select id, name, Blue_Sheet__c, Competitive_Detail__c, My_Position_Vs_Competitor__c, Competitor_Type__c from Competition__c];
        List<Id> compIdList=new List<Id>();
        for(Competition__c  comp:compList){
            compIdList.add(comp.id);
        }        
        List<Business_Rules__c> brRules = [Select id, Field_Name__c, Criteria__c, Points__c from Business_Rules__c];
        Test.startTest();
        SEFieldsPopulation.seFieldsPopulation(compIdList);
        Test.stopTest();
    } 
    
    @isTest
    static void validateseFieldsPopulationforStr() {
    
        List<Strength__c> strList=[Select id, name, Blue_Sheet__c from Strength__c];
        List<Id> strIdList=new List<Id>();
        for(Strength__c  str:strList){
            strIdList.add(str.id);
        }        
        Test.startTest();
        SEFieldsPopulation.seFieldsPopulation(strIdList);
        Test.stopTest();
    } 
    
    @isTest
    static void validateseFieldsPopulationforRF() {
    
        List<Red_Flag__c> rfList=[Select id, name, Blue_Sheet__c from Red_Flag__c];
        List<Id> rfIdList=new List<Id>();
        for(Red_Flag__c  rf:rfList){
            rfIdList.add(rf.id);
        }        
        Test.startTest();
        SEFieldsPopulation.seFieldsPopulation(rfIdList);
        Test.stopTest();
    } */
}