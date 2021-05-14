@SuppressWarnings('PMD.ExcessivePublicCount, PMD.ExcessiveClassLength')
public with sharing class TestDataUtil {
    public static Account createAccount(boolean isInsert) {
        /*Account Acct= new Account(
                Name = 'Test Account'
            );
        */

        // insert Acct;
        Account ac = new Account(name = 'Test Account', Industry = 'Transportation');
        if (isInsert) {
            DataFactory.create(ac);
        }
        return ac;
    }

    public static Contact createContact(Account ac, boolean isInsert) {
        Contact con = new Contact(firstname = 'Test', lastname = 'Contact', Accountid = ac.id);
        if (isInsert) {
            DataFactory.create(con);
        }
        return con;
    }

    public static Opportunity createOpportunity(Account acct, boolean isInsert) {
        Opportunity oppty = new Opportunity(
            Name = 'Test Opportunity',
            AccountId = Acct.Id,
            StageName = 'Qualification',
            Type = 'Existing Customer - Replacement',
            CloseDate = date.TODAY().addDays(30)
        );
        if (isInsert) {
            DataFactory.create(oppty);
        }
        return oppty;
    }

    public static Blue_Sheet__c createBluesheet(Opportunity oppty, boolean isInsert) {
        Blue_Sheet__c bs = new Blue_Sheet__c(
            Opportunity__c = oppty.Id,
            Progress__c = 'Not Started',
            Competition_Progress__c = 'Not Started',
            Current_Position_Progress__c = 'Not Started',
            Buying_Influence_Progress__c = 'Not Started'
        );
        if (isInsert) {
            DataFactory.create(bs);
        }
        return bs;
    }

    public static Current_Position__c createCurrentPosition(Blue_Sheet__c bs, boolean isInsert) {
        Current_Position__c cp = new Current_Position__c(Blue_Sheet__c = bs.Id, Current_Position__c = 'Comfort');
        if (isInsert) {
            DataFactory.create(cp);
        }
        return cp;
    }
    public static Admin_Score_Card__c createAdminScoreCard(boolean isInsert) {
        Admin_Score_Card__c admin = new Admin_Score_Card__c(
            Admin_Scorecard_Name__c = 'Strategy Selling ScoreCard',
            Is_Active__c = true,
            Is_Default__c = true
        );
        if (isInsert) {
            DataFactory.create(admin);
        }
        return admin;
    }

    public static List<Admin_Scorecard_Criteria__c> createAdminScoreCardCriteris(
        Admin_Score_Card__c admin,
        boolean isInsert
    ) {
        List<Admin_Scorecard_Criteria__c> adminList = new List<Admin_Scorecard_Criteria__c>();

        Admin_Scorecard_Criteria__c adminscore = new Admin_Scorecard_Criteria__c(
            Criteria_Definition__c = 'Crieria 1',
            Is_Active__c = true,
            Point_Value__c = 20,
            Admin_Score_Card__c = admin.Id,
            Section__c = 'Opportunity',
            Title__c = 'Title 1'
        );
        Admin_Scorecard_Criteria__c adminscore1 = new Admin_Scorecard_Criteria__c(
            Criteria_Definition__c = 'Crieria 2',
            Is_Active__c = true,
            Point_Value__c = 40,
            Admin_Score_Card__c = admin.Id,
            Section__c = 'Opportunity',
            Title__c = 'Title 2'
        );
        Admin_Scorecard_Criteria__c adminscore2 = new Admin_Scorecard_Criteria__c(
            Criteria_Definition__c = 'Crieria 3',
            Is_Active__c = true,
            Point_Value__c = 40,
            Admin_Score_Card__c = admin.Id,
            Section__c = 'Business',
            Title__c = 'Title 3'
        );
        adminList.add(adminscore);
        adminList.add(adminscore1);
        adminList.add(adminscore2);
        if (isInsert) {
            DataFactory.create(adminList);
        }
        return adminList;
    }
    public static Score_Card__c createScoreCard(Blue_Sheet__c bs, boolean isInsert) {
        Score_Card__c sc = new Score_Card__c(Blue_Sheet__c = bs.Id, Potential_Score__c = 60);
        if (isInsert) {
            DataFactory.create(sc);
        }
        return sc;
    }

    public static Score_Card_Detail__c createScoreCardDetails(Score_Card__c sc, boolean isInsert) {
        Score_Card_Detail__c scd = new Score_Card_Detail__c(
            Score_Card__c = sc.Id,
            Criteria_Definition__c = 'Test Criteria',
            Current_Score__c = 20,
            Point_Value__c = 20,
            Score_Value__c = 'Yes',
            Section__c = 'Opportunity',
            Title__c = 'Test Title'
        );
        if (isInsert) {
            DataFactory.create(scd);
        }
        return scd;
    }

    public static Single_Sales_Objective__c createSSO(Blue_Sheet__c bs, boolean isInsert) {
        Single_Sales_Objective__c sso = new Single_Sales_Objective__c(
            Blue_Sheet__c = bs.Id,
            Customers_Stated_Objectives__c = 'Test Record',
            Customer_Timing_for_Priorities__c = 'Active',
            Evaluation_of_Objectives__c = 'Test Record'
        );
        if (isInsert) {
            DataFactory.create(sso);
        }
        return sso;
    }

    public static Competition__c createCompetition(Blue_Sheet__c bs, Account acct, boolean isInsert) {
        Competition__c comp = new Competition__c(
            Blue_Sheet__c = bs.Id,
            Competitive_Detail__c = 'test Com Detail',
            Competitor_Type__c = 'Doing Nothing',
            My_Position_Vs_Competitor__c = 'Zero'
            // Account__c =acct.Id
        );
        if (isInsert) {
            DataFactory.create(comp);
        }
        return comp;
    }

    public static List<Competition__c> createListCompetition(Blue_Sheet__c bs, Account acc, boolean isInsert) {
        List<Competition__c> competitionList = new List<Competition__c>();
        Competition__c comp1 = new Competition__c(
            Blue_Sheet__c = bs.Id,
            Competitor_Type__c = 'Doing Nothing',
            My_Position_Vs_Competitor__c = 'Zero'
        );
        Competition__c comp2 = new Competition__c(
            Blue_Sheet__c = bs.Id,
            Competitive_Detail__c = 'test Com Detail',
            Competitor_Type__c = 'Doing Nothing',
            My_Position_Vs_Competitor__c = 'Zero'
        );
        Competition__c comp3 = new Competition__c(
            Blue_Sheet__c = bs.Id,
            Competitive_Detail__c = 'test Com Detail',
            Competitor_Type__c = 'Doing Nothing'
        );

        competitionList.add(comp1);
        competitionList.add(comp2);
        competitionList.add(comp3);

        if (isInsert) {
            DataFactory.create(competitionList);
        }

        return competitionList;
    }

    public static Action_Plan__c createActionPlan(Blue_Sheet__c bs, boolean isInsert) {
        Action_Plan__c ap = new Action_Plan__c(
            Blue_Sheet__c = bs.Id,
            Summary__c = 'test Com Detail',
            Is_a_Best_Action__c = true,
            Description__c = 'test'
            // Account__c =acct.Id
        );
        if (isInsert) {
            DataFactory.create(ap);
        }
        return ap;
    }

    public static List<Buying_Influence__c> createBuyingInfluence(Blue_Sheet__c bs, Contact cont, boolean isInsert) {
        List<Buying_Influence__c> biList = new List<Buying_Influence__c>();
        Buying_Influence__c bi1 = new Buying_Influence__c(
            Blue_Sheet__c = bs.Id,
            Business_Results__c = 'check',
            Personal_Wins__c = 'wins',
            Contact__c = cont.Id,
            Rating__c = '+4',
            Doing_Nothing__c = true,
            Rating_Evidence__c = 'testRate',
            High__c = true,
            Economic__c = true,
            Coach__c = true,
            Technical__c = true,
            User__c = true,
            Growth__c = true
        );

        Buying_Influence__c bi2 = new Buying_Influence__c(
            Blue_Sheet__c = bs.Id,
            Business_Results__c = 'check',
            Personal_Wins__c = 'wins',
            Contact__c = cont.Id,
            Rating__c = '+1',
            Buying_From_us__c = true,
            Rating_Evidence__c = 'testRate',
            Medium__c = true,
            Economic__c = false,
            Coach__c = false,
            Technical__c = false,
            User__c = false,
            Trouble__c = true
        );

        Buying_Influence__c bi3 = new Buying_Influence__c(
            Blue_Sheet__c = bs.Id,
            Business_Results__c = 'check',
            Personal_Wins__c = 'wins',
            Contact__c = cont.Id,
            Rating__c = '-1',
            Using_Internal_Resources__c = true,
            Rating_Evidence__c = 'testRate',
            Low__c = true,
            Economic__c = false,
            Coach__c = false,
            Technical__c = false,
            User__c = false,
            Even_Keel__c = true
        );

        biList.add(bi1);
        biList.add(bi2);
        biList.add(bi3);

        if (isInsert && Schema.sObjectType.Buying_Influence__c.fields.Business_Results__c.isCreateable()) {
            //Insert biList;
            DataFactory.create(bi1);
            DataFactory.create(bi2);
            DataFactory.create(bi3);
        }

        return biList;
    }

    public static Strategy_Engine__c createStrategySSO(Blue_Sheet__c bs, boolean isInsert) {
        Strategy_Engine__c se = new Strategy_Engine__c(
            Source_ID__c = bs.Id
            // SSO_Name__c=sso.Name,
            // Customer_Timing_for_Priorities__c=sso.Customer_Timing_for_Priorities__c,
            // Customer_Stated_Objective__c=sso.Customers_Stated_Objectives__c
        );
        if (isInsert) {
            DataFactory.create(se);
        }
        return se;
    }

    public static List<Business_Rules__c> createBusinessRules(boolean isInsert) {
        List<Business_Rules__c> brLst = new List<Business_Rules__c>();
        return brLst;
    }

    public static Strategy_Engine__c createStrategyEngine(Blue_Sheet__c bs, boolean isInsert) {
        Strategy_Engine__c se = new Strategy_Engine__c(
            Source_ID__c = bs.Id
            // SSO_Name__c=sso.Name,
            // Customer_Timing_for_Priorities__c=sso.Customer_Timing_for_Priorities__c,
            // Customer_Stated_Objective__c=sso.Customers_Stated_Objectives__c
        );
        if (isInsert) {
            DataFactory.create(se);
        }
        return se;
    }

    public static List<Summary_of_My_Position_Today__c> createSummaryOfMyPosition(Blue_Sheet__c bs, boolean isInsert) {
        List<Summary_of_My_Position_Today__c> sompList = new List<Summary_of_My_Position_Today__c>();
        Summary_of_My_Position_Today__c sompFirst = new Summary_of_My_Position_Today__c(
            Blue_Sheet__c = bs.Id,
            Description__c = 'test description',
            Is_a_Red_Flag__c = true,
            Is_a_Strength__c = false,
            Summary__c = 'test summary'
        );
        Summary_of_My_Position_Today__c sompSecond = new Summary_of_My_Position_Today__c(
            Blue_Sheet__c = bs.Id,
            Description__c = 'test description',
            Is_a_Red_Flag__c = false,
            Is_a_Strength__c = true,
            Summary__c = 'test summary'
        );
        sompList.add(sompFirst);
        sompList.add(sompSecond);

        if (isInsert) {
            DataFactory.create(sompFirst);
            DataFactory.create(sompSecond);
        }
        return sompList;
    }

    public static String getOppStageId() {
        OpportunityStage__c os = new OpportunityStage__c();
        os.Name = 'Qualification';
        DataFactory.create(os);
        return os.Id;
    }
    public static Gold_Sheet__c createGoldSheet(Account ac, boolean isInsert) {
        Gold_Sheet__c goldsheet = new Gold_Sheet__c(
            Account__c = ac.Id,
            Critical_Vulnerability_Desc__c = 'Critical Description Sample',
            Critical_Vulnerability_Title__c = 'Critical Title Sample'
        );
        if (isInsert && Schema.sObjectType.Gold_Sheet__c.fields.Account__c.isCreateable()) {
            insert goldsheet;
        }
        return goldsheet;
    }
    public static List<Strategic_Player__c> createListStrategicPlayer(Gold_Sheet__c gs, contact con, boolean isInsert) {
        List<Strategic_Player__c> strategicPlayerList = new List<Strategic_Player__c>();
        Strategic_Player__c sp1 = new Strategic_Player__c(
            Gold_Sheet__c = gs.Id,
            Strategic_Player_Role__c = 'Sponsor',
            Buy_Sell_Position__c = 'Level 1: Commodities',
            //  Team_Member__c=team.Id,
            Strategic_Player__c = con.Id
        );
        Strategic_Player__c sp2 = new Strategic_Player__c(
            Gold_Sheet__c = gs.Id,
            Strategic_Player_Role__c = 'Strategic Coach',
            Buy_Sell_Position__c = 'Level 2: Differentiated Quality Products/Services',
            // Team_Member__c=team.Id,
            Strategic_Player__c = con.Id
        );
        Strategic_Player__c sp3 = new Strategic_Player__c(
            Gold_Sheet__c = gs.Id,
            Strategic_Player_Role__c = 'Anti Sponsor',
            Buy_Sell_Position__c = 'Level 3: Personalized Services and Support',
            //Team_Member__c=team.Id,
            Strategic_Player__c = con.Id
        );

        strategicPlayerList.add(sp1);
        strategicPlayerList.add(sp2);
        strategicPlayerList.add(sp3);

        if (isInsert && Schema.sObjectType.Strategic_Player__c.fields.Strategic_Player_Role__c.isCreateable()) {
            insert strategicPlayerList;
        }

        return strategicPlayerList;
    }
    public static List<Focus_Investment__c> createFocusInvestment(Gold_Sheet__c gs, boolean isInsert) {
        List<Focus_Investment__c> fcIList = new List<Focus_Investment__c>();
        Focus_Investment__c fc1 = new Focus_Investment__c(
            Fields_of_Play_Gold_Sheet__c = gs.Id,
            Investment_Title__c = 'Test 1',
            Amount__c = 334,
            Status__c = 'Complete',
            Description__c = 'Test desc'
        );
        Focus_Investment__c fc2 = new Focus_Investment__c(
            Fields_of_Play_Gold_Sheet__c = gs.Id,
            Investment_Title__c = 'Test 2',
            Amount__c = 3345,
            Status__c = 'Incomplete',
            Description__c = 'Test desc 234'
        );
        fcIList.add(fc1);
        fcIList.add(fc2);
        if (isInsert && Schema.sObjectType.Focus_Investment__c.fields.Status__c.isCreateable()) {
            insert fcIList;
        }
        return fcIList;
    }

    public static List<Stop_Investment__c> createStopInvestment(Gold_Sheet__c gs, boolean isInsert) {
        List<Stop_Investment__c> fcIList = new List<Stop_Investment__c>();
        Stop_Investment__c fc1 = new Stop_Investment__c(
            Fields_of_Play_Gold_Sheet__c = gs.Id,
            Investment_Title__c = 'Test 1',
            Amount__c = 334,
            Status__c = 'Complete',
            Description__c = 'Test desc'
        );
        Stop_Investment__c fc2 = new Stop_Investment__c(
            Fields_of_Play_Gold_Sheet__c = gs.Id,
            Investment_Title__c = 'Test 2',
            Amount__c = 3345,
            Status__c = 'Incomplete',
            Description__c = 'Test desc 234'
        );
        fcIList.add(fc1);
        fcIList.add(fc2);
        if (isInsert && Schema.sObjectType.Stop_Investment__c.fields.Status__c.isCreateable()) {
            insert fcIList;
        }
        return fcIList;
    }
    public static List<Action__c> createActions(Gold_Sheet__c gs, boolean isInsert) {
        List<Action__c> actList = new List<Action__c>();
        Action__c act1 = new Action__c(
            Fields_of_Play_Gold_Sheet__c = gs.Id,
            Action_Title__c = 'Test 1',
            Assigned_To__c = UserInfo.getUserId(),
            Status__c = 'Complete',
            Description__c = 'Test desc',
            Due_Date__c = date.today()
        );
        Action__c act2 = new Action__c(
            Fields_of_Play_Gold_Sheet__c = gs.Id,
            Action_Title__c = 'Test 2',
            Assigned_To__c = UserInfo.getUserId(),
            Status__c = 'Incomplete',
            Description__c = 'Test desc 234',
            Due_Date__c = date.today()
        );
        actList.add(act1);
        actList.add(act2);
        if (isInsert && Schema.sObjectType.Action__c.fields.Assigned_To__c.isCreateable()) {
            insert actList;
        }
        return actList;
    }

    public static List<Revenue_Target_Detail__c> createRevenueDetail(boolean isInsert) {
        List<Revenue_Target_Detail__c> rdList = new List<Revenue_Target_Detail__c>();
        Revenue_Target_Detail__c rd1 = new Revenue_Target_Detail__c(
            Assumptions__c = 'Current Year',
            High_Lost_Revenue__c = 60,
            High_New_Revenue__c = 50,
            High_Recurring_Revenue__c = 40,
            High_Target__c = 30,
            Low_Lost_Revenue__c = 10,
            Low_New_Revenue__c = 35,
            Low_Recurring_Revenue__c = 34,
            Low_Target__c = 5,
            Realistic_Lost_Revenue__c = 23,
            Realistic_New_Revenue__c = 67,
            Realistic_Recurring_Revenue__c = 26,
            Realistic_Target__c = 17,
            Name = 'test1'
        );
        Revenue_Target_Detail__c rd2 = new Revenue_Target_Detail__c(
            Assumptions__c = 'Next Year',
            High_Lost_Revenue__c = 60,
            High_New_Revenue__c = 50,
            High_Recurring_Revenue__c = 40,
            High_Target__c = 30,
            Low_Lost_Revenue__c = 10,
            Low_New_Revenue__c = 35,
            Low_Recurring_Revenue__c = 34,
            Low_Target__c = 5,
            Realistic_Lost_Revenue__c = 23,
            Realistic_New_Revenue__c = 67,
            Realistic_Recurring_Revenue__c = 26,
            Realistic_Target__c = 17,
            Name = 'Test'
        );
        rdList.add(rd1);
        rdList.add(rd2);
        if (isInsert && Schema.sObjectType.Revenue_Target_Detail__c.fields.High_Lost_Revenue__c.isCreateable()) {
            insert rdList;
        }
        return rdList;
    }

    public static Revenue_Target__c createRevenueTarget(
        Gold_Sheet__c gs,
        Revenue_Target_Detail__c rtd,
        boolean isInsert
    ) {
        Revenue_Target__c rt = new Revenue_Target__c(Current_Year__c = rtd.Id, Gold_Sheet__c = gs.Id);
        if (isInsert && Schema.sObjectType.Revenue_Target__c.fields.Current_Year__c.isCreateable()) {
            insert rt;
        }
        return rt;
    }

    public static List<Investment_Program__c> createInvProgram(Gold_Sheet__c gs, boolean isInsert) {
        List<Investment_Program__c> fcIList = new List<Investment_Program__c>();
        Investment_Program__c fc1 = new Investment_Program__c(
            Fields_of_Play_Gold_Sheet__c = gs.Id,
            Investment_Program_Title__c = 'Test 1',
            Assigned_To__c = UserInfo.getUserId(),
            Status__c = 'Complete',
            Description__c = 'Test desc',
            Due_Date__c = date.today()
        );
        Investment_Program__c fc2 = new Investment_Program__c(
            Fields_of_Play_Gold_Sheet__c = gs.Id,
            Investment_Program_Title__c = 'Test 2',
            Assigned_To__c = UserInfo.getUserId(),
            Status__c = 'Incomplete',
            Description__c = 'Test desc 234',
            Due_Date__c = date.today()
        );
        fcIList.add(fc1);
        fcIList.add(fc2);
        if (isInsert && Schema.sObjectType.Investment_Program__c.fields.Investment_Program_Title__c.isCreateable()) {
            insert fcIList;
        }
        return fcIList;
    }
    public static List<Information_Needed__c> createInformationNeeded(Gold_Sheet__c gs, boolean isInsert) {
        List<Information_Needed__c> informationNeededList = new List<Information_Needed__c>();
        Information_Needed__c info1 = new Information_Needed__c(
            Fields_of_Play_Gold_Sheet__c = gs.Id,
            Information_Needed_Title__c = 'Test 1',
            Source__c = 'Source 1',
            Assigned_To__c = UserInfo.getUserId(),
            Status__c = 'Complete',
            Description__c = 'Test desc',
            Due_Date__c = date.today()
        );
        Information_Needed__c info2 = new Information_Needed__c(
            Fields_of_Play_Gold_Sheet__c = gs.Id,
            Information_Needed_Title__c = 'Test 2',
            Source__c = 'Source 2',
            Assigned_To__c = UserInfo.getUserId(),
            Status__c = 'Incomplete',
            Description__c = 'Test desc 234',
            Due_Date__c = date.today()
        );
        informationNeededList.add(info1);
        informationNeededList.add(info2);
        if (isInsert && Schema.sObjectType.Information_Needed__c.fields.Source__c.isCreateable()) {
            insert informationNeededList;
        }
        return informationNeededList;
    }
    public static Gold_Sheet_Single_Sales_Objective__c createGoldSheetSSO(
        Gold_Sheet__c gs,
        Opportunity opp,
        boolean isInsert
    ) {
        Gold_Sheet_Single_Sales_Objective__c gsSSO = new Gold_Sheet_Single_Sales_Objective__c(
            Opportunity__c = opp.Id,
            Gold_Sheet__c = gs.Id
        );
        if (isInsert && Schema.sObjectType.Gold_Sheet_Single_Sales_Objective__c.fields.Gold_Sheet__c.isCreateable()) {
            insert gsSSO;
        }
        return gsSSO;
    }

    public static Opportunity getOpportunity() {
        Opportunity os = new Opportunity();
        os.Name = 'Dummy';
        return os;
    }

    public static Business_Rules__c getBusinessRuleBal2() {
        Business_Rules__c br = new Business_Rules__c();
        return br;
    }
    public static List<Field_of_Play_Trend__c> createListFopTrends(Gold_Sheet__c gs, boolean isInsert) {
        List<Field_of_Play_Trend__c> fopTrendsList = new List<Field_of_Play_Trend__c>();
        Field_of_Play_Trend__c td1 = new Field_of_Play_Trend__c(
            Gold_Sheet__c = gs.Id,
            Trend__c = 'Sponsor',
            Trend_Description__c = 'Commodities'
        );
        Field_of_Play_Trend__c td2 = new Field_of_Play_Trend__c(
            Gold_Sheet__c = gs.Id,
            Trend__c = 'Strategic Coach',
            Trend_Description__c = 'Differentiated Quality Products/Services'
        );

        Field_of_Play_Trend__c td3 = new Field_of_Play_Trend__c(
            Gold_Sheet__c = gs.Id,
            Trend__c = 'Anti Sponsor',
            Trend_Description__c = 'Personalized Services and Support'
        );

        fopTrendsList.add(td1);
        fopTrendsList.add(td2);
        fopTrendsList.add(td3);

        if (isInsert && Schema.sObjectType.Field_of_Play_Trend__c.fields.Trend__c.isCreateable()) {
            insert fopTrendsList;
        }

        return fopTrendsList;
    }

    public static List<Field_of_Play_Opportunity__c> createListFopOpps(
        Gold_Sheet__c gs,
        contact con,
        boolean isInsert
    ) {
        List<Field_of_Play_Opportunity__c> fopOppsList = new List<Field_of_Play_Opportunity__c>();
        Field_of_Play_Opportunity__c td1 = new Field_of_Play_Opportunity__c(
            Gold_Sheet__c = gs.Id,
            FOP_Opportunity__c = 'Sponsor',
            KPI__c = 'KPI 1',
            FOP_Opportunity_Desc__c = 'Commodities',
            FOP_Owner__c = con.Id,
            Opportunity_Title__c = 'Title 1'
        );
        Field_of_Play_Opportunity__c td2 = new Field_of_Play_Opportunity__c(
            Gold_Sheet__c = gs.Id,
            FOP_Opportunity__c = 'Strategic Coach',
            KPI__c = 'KPI 2',
            FOP_Opportunity_Desc__c = 'Differentiated Quality Products/Services',
            FOP_Owner__c = con.Id,
            Opportunity_Title__c = 'Title 2'
        );

        Field_of_Play_Opportunity__c td3 = new Field_of_Play_Opportunity__c(
            Gold_Sheet__c = gs.Id,
            FOP_Opportunity__c = 'Anti Sponsor',
            KPI__c = 'KPI 3',
            FOP_Opportunity_Desc__c = 'Personalized Services and Support',
            FOP_Owner__c = con.Id,
            Opportunity_Title__c = 'Title 3'
        );

        fopOppsList.add(td1);
        fopOppsList.add(td2);
        fopOppsList.add(td3);

        if (isInsert && Schema.sObjectType.Field_of_Play_Opportunity__c.fields.FOP_Opportunity__c.isCreateable()) {
            insert fopOppsList;
        }

        return fopOppsList;
    }

    public static List<FOP_Strategic_Strength__c> createListFopStrengths(Gold_Sheet__c gs, boolean isInsert) {
        List<FOP_Strategic_Strength__c> fopStrengthsList = new List<FOP_Strategic_Strength__c>();
        FOP_Strategic_Strength__c td1 = new FOP_Strategic_Strength__c(
            Gold_Sheet__c = gs.Id,
            Strength__c = 'Sponsor',
            Strength_Description__c = 'Commodities'
        );
        FOP_Strategic_Strength__c td2 = new FOP_Strategic_Strength__c(
            Gold_Sheet__c = gs.Id,
            Strength__c = 'Strategic Coach',
            Strength_Description__c = 'Differentiated Quality Products/Services'
        );

        FOP_Strategic_Strength__c td3 = new FOP_Strategic_Strength__c(
            Gold_Sheet__c = gs.Id,
            Strength__c = 'Anti Sponsor',
            Strength_Description__c = 'Personalized Services and Support'
        );

        fopStrengthsList.add(td1);
        fopStrengthsList.add(td2);
        fopStrengthsList.add(td3);

        if (isInsert && Schema.sObjectType.FOP_Strategic_Strength__c.fields.Strength__c.isCreateable()) {
            insert fopStrengthsList;
        }

        return fopStrengthsList;
    }

    public static Buy_Sell_Hierarchy__c createBuySellHierarchy(Gold_Sheet__c gs, boolean isInsert) {
        Buy_Sell_Hierarchy__c buySell = new Buy_Sell_Hierarchy__c(
            Fields_of_Play_Gold_Sheet__c = gs.Id,
            Us_Next_Year__c = 'Level 5: Organizational Issues',
            Us_This_Year__c = 'Level 5: Organizational Issues'
        );

        if (isInsert && Schema.sObjectType.Buy_Sell_Hierarchy__c.fields.Us_Next_Year__c.isCreateable()) {
            insert buySell;
        }

        return buySell;
    }

    public static Charter_Statement__c createCharterStatement(Gold_Sheet__c gs, boolean isInsert) {
        Charter_Statement__c charterStatement = new Charter_Statement__c(
            Fields_of_Play_Gold_Sheet__c = gs.Id,
            Charter_Statement__c = 'Level 5: Organizational Issues'
        );

        if (isInsert && Schema.sObjectType.Charter_Statement__c.fields.Charter_Statement__c.isCreateable()) {
            insert charterStatement;
        }

        return charterStatement;
    }

    public static List<Relationship_Goal__c> createListGoals(Gold_Sheet__c gs, boolean isInsert) {
        List<Relationship_Goal__c> relationshipGoalList = new List<Relationship_Goal__c>();
        Relationship_Goal__c td1 = new Relationship_Goal__c(
            Fields_of_Play_Gold_Sheet__c = gs.Id,
            Goal_Name__c = 'Goal 1',
            Goal_Status__c = 'Complete'
        );
        Relationship_Goal__c td2 = new Relationship_Goal__c(
            Fields_of_Play_Gold_Sheet__c = gs.Id,
            Goal_Name__c = 'Goal 2',
            Goal_Status__c = 'Complete'
        );

        Relationship_Goal__c td3 = new Relationship_Goal__c(
            Fields_of_Play_Gold_Sheet__c = gs.Id,
            Goal_Name__c = 'Goal 3',
            Goal_Status__c = 'Incomplete'
        );

        relationshipGoalList.add(td1);
        relationshipGoalList.add(td2);
        relationshipGoalList.add(td3);

        if (isInsert && Schema.sObjectType.Relationship_Goal__c.fields.Goal_Name__c.isCreateable()) {
            insert relationshipGoalList;
        }

        return relationshipGoalList;
    }

    public static List<Milestone__c> createMilestones(Gold_Sheet__c gs, boolean isInsert) {
        List<Milestone__c> milestonesList = new List<Milestone__c>();
        Milestone__c td1 = new Milestone__c(
            Gold_Sheet__c = gs.Id,
            Meeting_Date__c = System.today(),
            Meeting_Notes__c = 'Complete',
            Milestone_Number__c = 'Milestone 1'
        );
        Milestone__c td2 = new Milestone__c(
            Gold_Sheet__c = gs.Id,
            Meeting_Date__c = System.today() + 1,
            Meeting_Notes__c = 'Complete',
            Milestone_Number__c = 'Milestone 2'
        );

        Milestone__c td3 = new Milestone__c(
            Gold_Sheet__c = gs.Id,
            Meeting_Date__c = System.today() - 1,
            Meeting_Notes__c = 'Incomplete',
            Milestone_Number__c = 'Milestone 3'
        );

        Milestone__c td4 = new Milestone__c(
            Gold_Sheet__c = gs.Id,
            Meeting_Date__c = System.today() - 1,
            Meeting_Notes__c = 'Incomplete',
            Milestone_Number__c = 'Milestone 4'
        );

        Milestone__c td5 = new Milestone__c(
            Gold_Sheet__c = gs.Id,
            Meeting_Date__c = System.today() - 1,
            Meeting_Notes__c = 'Incomplete',
            Milestone_Number__c = 'Milestone 5'
        );

        milestonesList.add(td1);
        milestonesList.add(td2);
        milestonesList.add(td3);
        milestonesList.add(td4);
        milestonesList.add(td5);

        if (isInsert && Schema.sObjectType.Milestone__c.fields.Milestone_Number__c.isCreateable()) {
            insert milestonesList;
        }

        return milestonesList;
    }
    public static List<Milestone__c> createListMilestones(Gold_Sheet__c gs, Strategic_Player__c sp, boolean isInsert) {
        List<Milestone__c> mileStoneList = new List<Milestone__c>();
        Milestone__c mile1 = new Milestone__c(
            Gold_Sheet__c = gs.Id,
            Meeting_Date__c = date.TODAY().addDays(10),
            Meeting_Notes__c = 'Test Meeting Notes',
            Milestone_Number__c = 'Milestone 1'
        );
        Milestone__c mile2 = new Milestone__c(
            Gold_Sheet__c = gs.Id,
            Meeting_Date__c = date.TODAY().addDays(20),
            Meeting_Notes__c = 'Test Meeting Notes',
            Milestone_Number__c = 'Milestone 2'
        );
        Milestone__c mile3 = new Milestone__c(
            Gold_Sheet__c = gs.Id,
            Meeting_Date__c = date.TODAY().addDays(30),
            Meeting_Notes__c = 'Test Meeting Notes',
            Milestone_Number__c = 'Milestone 3'
        );
        Milestone__c mile4 = new Milestone__c(
            Gold_Sheet__c = gs.Id,
            Meeting_Date__c = date.TODAY(),
            Meeting_Notes__c = 'Test Meeting Notes',
            Milestone_Number__c = 'Milestone 4'
        );
        Milestone__c mile5 = new Milestone__c(
            Gold_Sheet__c = gs.Id,
            Meeting_Date__c = date.TODAY().addDays(35),
            Meeting_Notes__c = 'Test Meeting Notes',
            Milestone_Number__c = 'Milestone 5',
            Strategic_Player__c = sp.Id
        );

        mileStoneList.add(mile1);
        mileStoneList.add(mile2);
        mileStoneList.add(mile3);
        mileStoneList.add(mile4);
        mileStoneList.add(mile5);

        if (isInsert && Schema.sObjectType.Milestone__c.fields.Milestone_Number__c.isCreateable()) {
            DataFactory.create(mileStoneList);
        }

        return mileStoneList;
    }
    public static List<Task> createTaskList(User user, boolean isInsert) {
        List<Task> taskList = new List<Task>();
        Task task = new Task(Subject = 'Test task1', Priority = 'Normal', Status = 'Not Started', OwnerId = user.Id);
        Task task1 = new Task(Subject = 'Test task2', Priority = 'High', Status = 'In Progress', OwnerId = user.Id);
        Task task2 = new Task(Subject = 'Test task3', Priority = 'Low', Status = 'Completed', OwnerId = user.Id);
        taskList.add(task);
        taskList.add(task1);
        taskList.add(task2);
        if (isInsert) {
            DataFactory.create(taskList);
        }
        return taskList;
    }

    public static Task createTask(User user, boolean isInsert) {
        List<Task> taskList = new List<Task>();
        Task task = new Task(Subject = 'Test task1', Priority = 'Normal', Status = 'Not Started', OwnerId = user.Id);
        taskList.add(task);
        if (isInsert) {
            DataFactory.create(taskList);
        }
        return taskList[0];
    }

    public static Green_Sheet__c createGreenSheet(Task task, boolean isInsert) {
        Green_Sheet__c greenSheet = new Green_Sheet__c(Task_Id__c = task.Id, Task_Name__c = task.Subject);
        if (isInsert && Schema.sObjectType.Green_Sheet__c.fields.Task_Id__c.isCreateable()) {
            insert greenSheet;
        }
        return greenSheet;
    }

    public static List<Green_Sheet_Buying_Influence__c> createGreenSheetBuyingInfluence(
        Id greenSheetId,
        boolean isInsert,
        Contact con
    ) {
        List<Green_Sheet_Buying_Influence__c> greenBiList = new List<Green_Sheet_Buying_Influence__c>();
        Green_Sheet_Buying_Influence__c greenBI1 = new Green_Sheet_Buying_Influence__c(
            Contact__c = con.Id,
            Buying_Influence_Role__c = 'economic',
            Concept__c = 'Test Concept1',
            Green_Sheet__c = greenSheetId
        );
        Green_Sheet_Buying_Influence__c greenBI2 = new Green_Sheet_Buying_Influence__c(
            Contact__c = con.Id,
            Buying_Influence_Role__c = 'economic,user',
            Concept__c = 'Test Concept2',
            Green_Sheet__c = greenSheetId
        );
        Green_Sheet_Buying_Influence__c greenBI3 = new Green_Sheet_Buying_Influence__c(
            Contact__c = con.Id,
            Buying_Influence_Role__c = 'economic,technical,coach',
            Concept__c = 'Test Concept3',
            Green_Sheet__c = greenSheetId
        );
        greenBiList.add(greenBI1);
        greenBiList.add(greenBI2);
        greenBiList.add(greenBI3);
        if (isInsert) {
            DataFactory.create(greenBiList);
        }
        return greenBiList;
    }
    public static List<Company_Attendee__c> createCompanyAttendees(Id greenSheetId, boolean isInsert, User user) {
        List<Company_Attendee__c> companyList = new List<Company_Attendee__c>();
        Company_Attendee__c company1 = new Company_Attendee__c(Green_Sheet__c = greenSheetId, Name__c = user.Id);
        Company_Attendee__c company2 = new Company_Attendee__c(Green_Sheet__c = greenSheetId, Name__c = user.Id);
        Company_Attendee__c company3 = new Company_Attendee__c(Green_Sheet__c = greenSheetId, Name__c = user.Id);
        companyList.add(company1);
        companyList.add(company2);
        companyList.add(company3);
        if (isInsert) {
            DataFactory.create(companyList);
        }
        return companyList;
    }

    public static Green_Sheet__c createGreenSheetVBR(Task task, boolean isInsert) {
        Green_Sheet__c greenSheet = new Green_Sheet__c(
            Task_Id__c = task.Id,
            Task_Name__c = task.Subject,
            Credibility__c = 'Established',
            Reason__c = 'Reason Test',
            To_Increase_Credibility__c = 'Increase Credibility Test'
        );
        if (isInsert && Schema.sObjectType.Green_Sheet__c.fields.Task_Id__c.isCreateable()) {
            insert greenSheet;
        }
        return greenSheet;
    }

    public static List<Getting_Information__c> createGreenSheetGettingInfoQuestion(
        Green_Sheet__c gs,
        boolean isInsert
    ) {
        List<Getting_Information__c> giQuestionsList = new List<Getting_Information__c>();
        Getting_Information__c giQuestion1 = new Getting_Information__c(
            Green_Sheet__c = gs.Id,
            Question_Type__c = 'New Information',
            Question__c = 'Is the a test Question?',
            Golden_Silence__c = false
        );
        Getting_Information__c giQuestion2 = new Getting_Information__c(
            Green_Sheet__c = gs.Id,
            Question_Type__c = 'Attitude',
            Question__c = 'Is the a test Question?',
            Golden_Silence__c = false
        );
        Getting_Information__c giQuestion3 = new Getting_Information__c(
            Green_Sheet__c = gs.Id,
            Question_Type__c = 'Confirmation',
            Question__c = 'Is the a test Question?',
            Golden_Silence__c = false
        );
        giQuestionsList.add(giQuestion1);
        giQuestionsList.add(giQuestion2);
        giQuestionsList.add(giQuestion3);
        if (isInsert && Schema.sObjectType.Getting_Information__c.isCreateable()) {
            DataFactory.create(giQuestionsList);
        }
        return giQuestionsList;
    }

    public static List<Giving_Information__c> createGreenSheetGivingInfo(Green_Sheet__c gs, boolean isInsert) {
        List<Giving_Information__c> givingInfoList = new List<Giving_Information__c>();
        Giving_Information__c giInfo1 = new Giving_Information__c(
            Green_Sheet__c = gs.Id,
            Title__c = 'New Information',
            Description__c = 'Is the a test giving information?',
            IsProviding_Perspective__c = false
        );
        Giving_Information__c giInfo2 = new Giving_Information__c(
            Green_Sheet__c = gs.Id,
            Title__c = 'Attitude',
            Description__c = 'Is the a test giving information?',
            IsProviding_Perspective__c = false
        );
        Giving_Information__c giInfo3 = new Giving_Information__c(
            Green_Sheet__c = gs.Id,
            Title__c = 'Confirmation',
            Description__c = 'Is the a test giving information?',
            IsProviding_Perspective__c = false
        );
        givingInfoList.add(giInfo1);
        givingInfoList.add(giInfo2);
        givingInfoList.add(giInfo3);
        if (isInsert && Schema.sObjectType.Giving_Information__c.isCreateable()) {
            DataFactory.create(givingInfoList);
        }
        return givingInfoList;
    }
    public static List<Basic_Issues__c> createGSBasicIssuesQuestion(Green_Sheet__c gs, boolean isInsert) {
        List<Basic_Issues__c> gsBasicIssuesQuestionsList = new List<Basic_Issues__c>();
        Basic_Issues__c basicIssuesQuestion1 = new Basic_Issues__c(
            Green_Sheet__c = gs.Id,
            Question_Type__c = 'Basic Issue',
            Question__c = 'Is the a test Issue?'
        );
        Basic_Issues__c basicIssuesQuestion2 = new Basic_Issues__c(
            Green_Sheet__c = gs.Id,
            Question_Type__c = 'Basic Issue Question',
            Question__c = 'Is the a test Issue?'
        );
        gsBasicIssuesQuestionsList.add(basicIssuesQuestion1);
        gsBasicIssuesQuestionsList.add(basicIssuesQuestion2);
        if (isInsert && Schema.sObjectType.Basic_Issues__c.isCreateable()) {
            DataFactory.create(gsBasicIssuesQuestionsList);
        }
        return gsBasicIssuesQuestionsList;
    }

    public static List<Getting_Commitment__c> createGreenSheetGettingCommitment(Green_Sheet__c gs, boolean isInsert) {
        List<Getting_Commitment__c> gcList = new List<Getting_Commitment__c>();
        Getting_Commitment__c gc1 = new Getting_Commitment__c(
            Green_Sheet__c = gs.Id,
            Best_Action_Commitment__c = 'best action1',
            Minimum_Acceptable_Action_Commit__c = 'min action1'
        );

        gcList.add(gc1);

        if (isInsert && Schema.sObjectType.Getting_Commitment__c.isCreateable()) {
            DataFactory.create(gcList);
        }
        return gcList;
    }

    public static List<Commitment_Question__c> createGreenSheetCommitmentQuestion(
        Getting_Commitment__c gc,
        boolean isInsert
    ) {
        List<Commitment_Question__c> gcList = new List<Commitment_Question__c>();
        Commitment_Question__c gc1 = new Commitment_Question__c(
            Getting_Commitment__c = gc.Id,
            Question__c = 'question1'
        );
        Commitment_Question__c gc2 = new Commitment_Question__c(
            Getting_Commitment__c = gc.Id,
            Question__c = 'question2'
        );

        gcList.add(gc1);
        gcList.add(gc2);

        if (isInsert && Schema.sObjectType.Commitment_Question__c.isCreateable()) {
            DataFactory.create(gcList);
        }
        return gcList;
    }
    public static List<Business_Rules__c> createBusinessRulesRecords(boolean isInsert) {
        List<Business_Rules__c> brLst = new List<Business_Rules__c>();
        Business_Rules__c br1 = new Business_Rules__c(
            Business_Rule_Name__c = 'Competitior Business Rule 1',
            Business_Rule_Catagory__c = 'Competitor'
        );
        Business_Rules__c br2 = new Business_Rules__c(
            Business_Rule_Name__c = 'Competitior Business Rule 2',
            Business_Rule_Catagory__c = 'Competitor'
        );

        brLst.add(br1);
        brLst.add(br2);
        if (isInsert) {
            DataFactory.create(brLst);
        }
        return brLst;
    }
    public static List<Insight_Alert__c> createInsightAlert(List<Business_Rules__c> br, Account acc, boolean isInsert) {
        List<Insight_Alert__c> inAlertst = new List<Insight_Alert__c>();
        Insight_Alert__c alert1 = new Insight_Alert__c(
            Business_Rules__c = br[0].Id,
            Competitor__c = acc.Id,
            Insights__c = 'Insight Text1',
            Insights_Link__c = 'Insight Link1'
        );
        Insight_Alert__c alert2 = new Insight_Alert__c(
            Business_Rules__c = br[1].Id,
            Competitor__c = acc.Id,
            Insights__c = 'Insight Text2',
            Insights_Link__c = 'Insight Link2'
        );

        inAlertst.add(alert1);
        if (isInsert) {
            DataFactory.create(inAlertst);
        }
        return inAlertst;
    }

    public static KF_Sell_Best__c createKfSellBestAction(Opportunity opp, Green_Sheet__c grn, Boolean isInsert) {
        KF_Sell_Best__c kfSellBest = new KF_Sell_Best__c(
            Action_Title__c = 'Negative Current Position',
            Alert_Type__c = 'Greensheet',
            Opportunity__c = opp.Id,
            BestActionRuleId__c = 'BAL_8',
            Seller_Email_Text__c = 'The current position for this opportunity is negative.',
            Seller_URL_Link__c = 'https://kfsell.kornferry.com/Blue+Sheet+Reinforcement/Position.mp4',
            Seller_URL_Text__c = 'Position.mp4',
            Manager_Recommended_Action__c = 'You own an opportunity with a negative Current Position.',
            Manager_URL_Link__c = 'https://kfsell.kornferry.com/ManagerSupport/SupportYourTeamEuphoria-Panic.pdf',
            Manager_URL_Text__c = 'Support Your Team - Euphoria-Panic.pdf',
            Green_Sheet__c = grn.Id
        );

        if (isInsert) {
            DataFactory.create(kfSellBest);
        }
        return kfSellBest;
    }

    public static List<Insight_Alert__c> createInsightAlertPerspective(List<Business_Rules__c> br, boolean isInsert) {
        List<Insight_Alert__c> inAlertsPersp = new List<Insight_Alert__c>();
        Insight_Alert__c alert1 = new Insight_Alert__c(
            Business_Rules__c = br[0].Id,
            Insights__c = 'Insight Text1',
            Insights_Link__c = 'Insight Link1',
            Opportunity_Type__c = 'New Customer',
            Industry__c = 'Agriculture'
        );
        inAlertsPersp.add(alert1);
        if (isInsert) {
            DataFactory.create(inAlertsPersp);
        }
        return inAlertsPersp;
    }
    public static List<KF_Sell_Best__c> createKfSellBestAction_BAL(
        Opportunity opp,
        Green_Sheet__c grn,
        Boolean isInsert
    ) {
        List<KF_Sell_Best__c> insertKfSellBest = new List<KF_Sell_Best__c>();
        KF_Sell_Best__c kfSellBest;
        for (integer i = 1; i <= 28; i++) {
            kfSellBest = new KF_Sell_Best__c(
                Action_Title__c = 'RecomAction_BAL_' + i + '_actionMsg',
                Action_Title_Manager__c = 'RecomAction_BAL_' + i + '_actionMsg',
                Action_Title_Seller__c = 'RecomAction_BAL_' + i + '_actionMsg',
                Alert_Type__c = 'Seller Email',
                Opportunity__c = opp.Id,
                BestActionRuleId__c = 'BAL_' + i,
                Seller_Email_Text__c = 'RecomAction_BAL_' + i + '_SellerEmailText',
                Seller_Recommended_Action__c = 'RecomAction_BAL_' + i + '_SellerMessage',
                Manager_Recommended_Action__c = 'RecomAction_BAL_' + i + '_ManagerMessage',
                Green_Sheet__c = grn.Id
            );
            insertKfSellBest.add(kfSellBest);
        }

        if (isInsert) {
            DataFactory.create(insertKfSellBest);
        }
        return insertKfSellBest;
    }
}