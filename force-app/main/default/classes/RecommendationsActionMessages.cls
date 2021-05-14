/*
 * ─────────────────────────────────────────────────────────────────────────────────────────────────┐
 * KFS-277 (part of main US KFS-277) : Class to hold the BestAction messages
 * ──────────────────────────────────────────────────────────────────────────────────────────────────
 * @author         Rakesh Singh
 * @created        2020-05-30
 * Note: if there is single quote in any msg, escape it in this class
 */

public with sharing class RecommendationsActionMessages {
    public Map<String, RecommendationsActionWrapper> getRecommendationsActionMessages() {
        Map<String, RecommendationsActionWrapper> mapRuleMSg = new Map<String, RecommendationsActionWrapper>();
        //List<RecommendationsActionWrapper> recommenActionMessagesLst = new List<RecommendationsActionWrapper>();

        RecommendationsActionWrapper msgWrapper1 = new RecommendationsActionWrapper();
        msgWrapper1.balId = 'BAL_1';
        msgWrapper1.evaluation = 'RecomAction_BAL_1_Evaluation';
        msgWrapper1.sellerRecommendedActionMessage = 'RecomAction_BAL_1_SellerMessage';
        msgWrapper1.managerRecommendedActionMessage = 'RecomAction_BAL_1_ManagerMessage';
        msgWrapper1.sellerEmailText = 'RecomAction_BAL_1_SellerEmailText';
        msgWrapper1.actionMsg = 'RecomAction_BAL_1_actionMsg';
        msgWrapper1.sellerUrlText = '';
        msgWrapper1.sellerUrlLink = '';
        msgWrapper1.managerUrlText = '';
        msgWrapper1.managerUrlLink = '';
        msgWrapper1.associatedObject = 'Blue Sheet';
        mapRuleMSg.put(msgWrapper1.balId, msgWrapper1);

        RecommendationsActionWrapper msgWrapper2 = new RecommendationsActionWrapper();
        msgWrapper2.balId = 'BAL_2';
        msgWrapper2.evaluation = 'RecomAction_BAL_2_Evaluation';
        msgWrapper2.sellerRecommendedActionMessage = 'RecomAction_BAL_2_SellerMessage';
        msgWrapper2.managerRecommendedActionMessage = 'RecomAction_BAL_2_ManagerMessage';
        msgWrapper2.sellerEmailText = 'RecomAction_BAL_2_SellerEmailText';
        msgWrapper2.actionMsg = 'RecomAction_BAL_2_actionMsg';
        msgWrapper2.sellerUrlText = '';
        msgWrapper2.sellerUrlLink = '';
        msgWrapper2.managerUrlText = '';
        msgWrapper2.managerUrlLink = '';
        msgWrapper2.associatedObject = 'Blue Sheet';
        mapRuleMSg.put(msgWrapper2.balId, msgWrapper2);

        RecommendationsActionWrapper msgWrapper3 = new RecommendationsActionWrapper();
        msgWrapper3.balId = 'BAL_3';
        msgWrapper3.evaluation = 'RecomAction_BAL_3_Evaluation';
        msgWrapper3.sellerRecommendedActionMessage = 'RecomAction_BAL_3_SellerMessage';
        //msgWrapper3.managerRecommendedActionMessage = 'The seller has not worked on the blue sheet in a while.  Is this deal still active?';
        msgWrapper3.managerRecommendedActionMessage = 'RecomAction_BAL_3_ManagerMessage';
        msgWrapper3.sellerEmailText = 'RecomAction_BAL_3_SellerEmailText';
        msgWrapper3.actionMsg = 'RecomAction_BAL_3_actionMsg';
        msgWrapper3.sellerUrlText = 'Acquire_Funnel.mp4';
        msgWrapper3.sellerUrlLink = 'https://kfsell.kornferry.com/Blue+Sheet+Reinforcement/Acquire_Funnel.mp4';
        msgWrapper3.managerUrlText = 'Support Your Team - Sales Funnel v3.pdf';
        msgWrapper3.managerUrlLink = 'https://kfsell.kornferry.com/Manager+Support/Support+Your+Team+-+Sales+Funnel+v3.pdf';
        msgWrapper3.associatedObject = 'Blue Sheet';
        mapRuleMSg.put(msgWrapper3.balId, msgWrapper3);

        RecommendationsActionWrapper msgWrapper4 = new RecommendationsActionWrapper();
        msgWrapper4.balId = 'BAL_4';
        msgWrapper4.evaluation = 'RecomAction_BAL_4_Evaluation';
        msgWrapper4.sellerRecommendedActionMessage = 'RecomAction_BAL_4_SellerMessage';
        msgWrapper4.managerRecommendedActionMessage = 'RecomAction_BAL_4_ManagerMessage';
        msgWrapper4.sellerEmailText = 'RecomAction_BAL_4_SellerEmailText';
        msgWrapper4.actionMsg = 'RecomAction_BAL_4_actionMsg';
        msgWrapper4.sellerUrlText = 'Acquire_Funnel.mp4';
        msgWrapper4.sellerUrlLink = 'https://kfsell.kornferry.com/Blue+Sheet+Reinforcement/Acquire_Funnel.mp4';
        msgWrapper4.managerUrlText = 'Support Your Team - Sales Funnel v3.pdf';
        msgWrapper4.managerUrlLink = 'https://kfsell.kornferry.com/Manager+Support/Support+Your+Team+-+Sales+Funnel+v3.pdf';
        msgWrapper4.associatedObject = 'Opportunity';
        mapRuleMSg.put(msgWrapper4.balId, msgWrapper4);

        RecommendationsActionWrapper msgWrapper5 = new RecommendationsActionWrapper();
        msgWrapper5.balId = 'BAL_5';
        msgWrapper5.evaluation = 'RecomAction_BAL_5_Evaluation';
        msgWrapper5.sellerRecommendedActionMessage = 'RecomAction_BAL_5_SellerMessage';
        msgWrapper5.managerRecommendedActionMessage = 'RecomAction_BAL_5_ManagerMessage';
        msgWrapper5.sellerEmailText = 'RecomAction_BAL_5_SellerEmailText';
        msgWrapper5.actionMsg = 'RecomAction_BAL_5_actionMsg';
        msgWrapper5.sellerUrlText = 'Acquire_Funnel.mp4';
        msgWrapper5.sellerUrlLink = 'https://kfsell.kornferry.com/Blue+Sheet+Reinforcement/Acquire_Funnel.mp4';
        msgWrapper5.managerUrlText = 'Support Your Team - Sales Funnel v3.pdf';
        msgWrapper5.managerUrlLink = 'https://kfsell.kornferry.com/Manager+Support/Support+Your+Team+-+Sales+Funnel+v3.pdf';
        msgWrapper5.associatedObject = 'Single Sales Objective';
        mapRuleMSg.put(msgWrapper5.balId, msgWrapper5);

        RecommendationsActionWrapper msgWrapper6 = new RecommendationsActionWrapper();
        msgWrapper6.balId = 'BAL_6';
        msgWrapper6.evaluation = 'RecomAction_BAL_6_Evaluation';
        msgWrapper6.sellerRecommendedActionMessage = 'RecomAction_BAL_6_SellerMessage';
        //msgWrapper6.managerRecommendedActionMessage = 'It\'s time for a deal review with the seller.';
        msgWrapper6.managerRecommendedActionMessage = 'RecomAction_BAL_6_ManagerMessage';
        msgWrapper6.sellerEmailText = 'RecomAction_BAL_6_SellerEmailText';
        msgWrapper6.actionMsg = 'RecomAction_BAL_6_actionMsg';
        msgWrapper6.sellerUrlText = 'Acquire_StratAction.mp4';
        msgWrapper6.sellerUrlLink = 'https://kfsell.kornferry.com/Blue+Sheet+Reinforcement/Acquire_StratAction.mp4';
        msgWrapper6.managerUrlText = 'Support Your Team - Strategy to Action.pdf';
        msgWrapper6.managerUrlLink = 'https://kfsell.kornferry.com/Manager+Support/Support+Your+Team+-+Strategy+to+Action.pdf';
        msgWrapper6.associatedObject = 'Action Plan';
        mapRuleMSg.put(msgWrapper6.balId, msgWrapper6);

        RecommendationsActionWrapper msgWrapper7 = new RecommendationsActionWrapper();
        msgWrapper7.balId = 'BAL_7';
        msgWrapper7.evaluation = 'RecomAction_BAL_7_Evaluation';
        msgWrapper7.sellerRecommendedActionMessage = 'RecomAction_BAL_7_SellerMessage';
        msgWrapper7.managerRecommendedActionMessage = 'RecomAction_BAL_7_ManagerMessage';
        msgWrapper7.sellerEmailText = 'RecomAction_BAL_7_SellerEmailText';
        msgWrapper7.actionMsg = 'RecomAction_BAL_7_actionMsg';
        msgWrapper7.sellerUrlText = 'Acquire_Funnel.mp4';
        msgWrapper7.sellerUrlLink = 'https://kfsell.kornferry.com/Blue+Sheet+Reinforcement/Acquire_Funnel.mp4';
        msgWrapper7.managerUrlText = 'Support Your Team - Best Action Plans and Win-Results.pdf';
        msgWrapper7.managerUrlLink = 'https://kfsell.kornferry.com/Manager+Support/Support+Your+Team+-+Win-Results+v3.pdf';
        msgWrapper7.associatedObject = 'Action Plan';
        mapRuleMSg.put(msgWrapper7.balId, msgWrapper7);

        RecommendationsActionWrapper msgWrapper8 = new RecommendationsActionWrapper();
        msgWrapper8.balId = 'BAL_8';
        msgWrapper8.evaluation = 'RecomAction_BAL_8_Evaluation';
        msgWrapper8.sellerRecommendedActionMessage = 'RecomAction_BAL_8_SellerMessage';
        msgWrapper8.managerRecommendedActionMessage = 'RecomAction_BAL_8_ManagerMessage';
        msgWrapper8.sellerEmailText = 'RecomAction_BAL_8_SellerEmailText';
        msgWrapper8.actionMsg = 'RecomAction_BAL_8_actionMsg';
        msgWrapper8.sellerUrlText = 'Position.mp4';
        msgWrapper8.sellerUrlLink = 'https://kfsell.kornferry.com/Blue+Sheet+Reinforcement/Position.mp4';
        msgWrapper8.managerUrlText = 'Support Your Team - Euphoria-Panic.pdf';
        msgWrapper8.managerUrlLink = 'https://kfsell.kornferry.com/Manager+Support/Support+Your+Team+-+Euphoria-Panic.pdf';
        msgWrapper8.associatedObject = 'Current Position';
        mapRuleMSg.put(msgWrapper8.balId, msgWrapper8);

        RecommendationsActionWrapper msgWrapper9 = new RecommendationsActionWrapper();
        msgWrapper9.balId = 'BAL_9';
        msgWrapper9.evaluation = 'RecomAction_BAL_9_Evaluation';
        msgWrapper9.sellerRecommendedActionMessage = 'RecomAction_BAL_9_SellerMessage';
        msgWrapper9.managerRecommendedActionMessage = 'RecomAction_BAL_9_ManagerMessage';
        msgWrapper9.sellerEmailText = 'RecomAction_BAL_9_SellerEmailText';

        msgWrapper9.actionMsg = 'RecomAction_BAL_9_actionMsg';
        msgWrapper9.sellerUrlText = 'Acquire_CompAlt.mp4';
        msgWrapper9.sellerUrlLink = 'https://kfsell.kornferry.com/Blue+Sheet+Reinforcement/Acquire_CompAlt.mp4';
        msgWrapper9.managerUrlText = 'AdvnCnctsStratSell_MgrTips_OptimizingYourPosition_v2.pdf';
        msgWrapper9.managerUrlLink = 'https://kfsell.kornferry.com/Manager+Support/AdvnCnctsStratSell_MgrTips_OptimizingYourPosition_v2.pdf';
        msgWrapper9.associatedObject = 'Competition';
        mapRuleMSg.put(msgWrapper9.balId, msgWrapper9);

        RecommendationsActionWrapper msgWrapper10 = new RecommendationsActionWrapper();
        msgWrapper10.balId = 'BAL_10';
        msgWrapper10.evaluation = 'RecomAction_BAL_10_Evaluation';
        msgWrapper10.sellerRecommendedActionMessage = 'RecomAction_BAL_10_SellerMessage';
        msgWrapper10.managerRecommendedActionMessage = 'RecomAction_BAL_10_ManagerMessage';
        msgWrapper10.sellerEmailText = 'RecomAction_BAL_10_SellerEmailText';
        msgWrapper10.actionMsg = 'RecomAction_BAL_10_actionMsg';
        msgWrapper10.sellerUrlText = 'Acquire_PositionVsComp.mp4';
        msgWrapper10.sellerUrlLink = 'https://kfsell.kornferry.com/Blue+Sheet+Navigation+Links/Acquire_PositionVsComp.mp4';
        msgWrapper10.managerUrlText = 'AdvnCnctsStratSell_MgrTips_OptimizingYourPosition_v2.pdf';
        msgWrapper10.managerUrlLink = 'https://kfsell.kornferry.com/Manager+Support/AdvnCnctsStratSell_MgrTips_OptimizingYourPosition_v2.pdf';
        msgWrapper10.associatedObject = 'Competition';
        mapRuleMSg.put(msgWrapper10.balId, msgWrapper10);

        RecommendationsActionWrapper msgWrapper11 = new RecommendationsActionWrapper();
        msgWrapper11.balId = 'BAL_11';
        msgWrapper11.evaluation = 'RecomAction_BAL_11_Evaluation';
        msgWrapper11.sellerRecommendedActionMessage = 'RecomAction_BAL_11_SellerMessage';
        msgWrapper11.managerRecommendedActionMessage = 'RecomAction_BAL_11_ManagerMessage';
        msgWrapper11.sellerEmailText = 'RecomAction_BAL_11_SellerEmailText';
        msgWrapper11.actionMsg = 'RecomAction_BAL_11_actionMsg';
        msgWrapper11.sellerUrlText = '';
        msgWrapper11.sellerUrlLink = '';
        msgWrapper11.managerUrlText = '';
        msgWrapper11.managerUrlLink = '';
        msgWrapper11.associatedObject = 'Scorecard';
        mapRuleMSg.put(msgWrapper11.balId, msgWrapper11);

        RecommendationsActionWrapper msgWrapper12 = new RecommendationsActionWrapper();
        msgWrapper12.balId = 'BAL_12';
        msgWrapper12.evaluation = 'RecomAction_BAL_12_Evaluation';
        msgWrapper12.sellerRecommendedActionMessage = 'RecomAction_BAL_12_SellerMessage';
        msgWrapper12.managerRecommendedActionMessage = 'RecomAction_BAL_12_ManagerMessage';
        msgWrapper12.sellerEmailText = 'RecomAction_BAL_12_SellerEmailText';
        msgWrapper12.actionMsg = 'RecomAction_BAL_12_actionMsg';
        msgWrapper12.sellerUrlText = 'Acquire_Roles.mp4';
        msgWrapper12.sellerUrlLink = 'https://kfsell.kornferry.com/Blue+Sheet+Reinforcement/Acquire_Roles.mp4';
        msgWrapper12.managerUrlText = 'Support Your Team - Buying Influences v3.pdf';
        msgWrapper12.managerUrlLink = 'https://kfsell.kornferry.com/Manager+Support/Support+Your+Team+-+Buying+Influences+v3.pdf';
        msgWrapper12.associatedObject = 'Buying Influence';
        mapRuleMSg.put(msgWrapper12.balId, msgWrapper12);

        //KFS-863 - msg for newly added rule
        RecommendationsActionWrapper msgWrapper13 = new RecommendationsActionWrapper();
        msgWrapper13.balId = 'BAL_13';
        msgWrapper13.evaluation = 'RecomAction_BAL_13_Evaluation';
        msgWrapper13.sellerRecommendedActionMessage = 'RecomAction_BAL_13_SellerMessage';
        msgWrapper13.managerRecommendedActionMessage = 'RecomAction_BAL_13_ManagerMessage';
        msgWrapper13.sellerEmailText = 'RecomAction_BAL_13_SellerEmailText';
        msgWrapper13.actionMsg = 'RecomAction_BAL_13_actionMsg';
        msgWrapper13.sellerUrlText = 'Acquire_TimingPriorities.mp4';
        msgWrapper13.sellerUrlLink = 'https://kfsell.kornferry.com/Blue+Sheet+Navigation+Links/Acquire_TimingPriorities.mp4';
        msgWrapper13.managerUrlText = '{sellerName} owns an opportunity with a disconnect between Modes and Customer Timing for Priorities. Coach the seller on the relationship between Modes and the Customer Timing for Priorities. To help you prepare, consider viewing this resource:';
        msgWrapper13.managerUrlLink = 'https://kfsell.kornferry.com/Manager+Support/AdvnCnctsStratSell_MgrTips_OptimizingYourPosition_v2.pdf';
        msgWrapper13.associatedObject = 'Single Sales Objective';
        mapRuleMSg.put(msgWrapper13.balId, msgWrapper13);

        //Scorecard Rules

        RecommendationsActionWrapper msgWrapper14 = new RecommendationsActionWrapper();
        msgWrapper14.balId = 'BAL_14';
        msgWrapper14.evaluation = '';
        msgWrapper14.sellerRecommendedActionMessage = 'RecomAction_BAL_14_SellerMessage';
        msgWrapper14.managerRecommendedActionMessage = 'RecomAction_BAL_14_ManagerMessage';
        msgWrapper14.sellerEmailText = 'RecomAction_BAL_14_SellerEmailText';
        msgWrapper14.actionMsg = 'RecomAction_BAL_14_actionMsg';
        msgWrapper14.sellerUrlText = 'Acquire_Funnel.mp4';
        msgWrapper14.sellerUrlLink = 'https://kfsell.kornferry.com/Blue+Sheet+Reinforcement/Acquire_Funnel.mp4';
        msgWrapper14.managerUrlText = '{sellerName} hasn\'t updated the scorecard even though the deal has moved through the sales process. Use this process to help you prepare for a coaching session:';
        msgWrapper14.managerUrlLink = 'https://kfsell.kornferry.com/Manager+Support/Support+Your+Team+-+Sales+Funnel+v3.pdf';
        msgWrapper14.associatedObject = 'Scorecard';
        mapRuleMSg.put(msgWrapper14.balId, msgWrapper14);

        RecommendationsActionWrapper msgWrapper15 = new RecommendationsActionWrapper();
        msgWrapper15.balId = 'BAL_15';
        msgWrapper15.evaluation = '';
        msgWrapper15.sellerRecommendedActionMessage = 'RecomAction_BAL_15_SellerMessage';
        msgWrapper15.managerRecommendedActionMessage = 'RecomAction_BAL_15_ManagerMessage';
        msgWrapper15.sellerEmailText = 'RecomAction_BAL_15_SellerEmailText';
        msgWrapper15.actionMsg = 'RecomAction_BAL_15_actionMsg';
        msgWrapper15.sellerUrlText = '10_Opportunity_Scorecard.mp4';
        msgWrapper15.sellerUrlLink = 'https://kfsell.kornferry.com/Blue+Sheet+Reinforcement/10_Opportunity_Scorecard.mp4';
        msgWrapper15.managerUrlText = '{sellerName} hasn a scorecard that doesn\'t meet the organization\'s standards. Scorecard score is a coaching opportunity at your next review. To help you prepare, review this resource:';
        msgWrapper15.managerUrlLink = 'https://kfsell.kornferry.com/Manager+Support/Support+Your+Team+-+Sales+Funnel+v3.pdf';
        msgWrapper15.associatedObject = 'Scorecard';
        mapRuleMSg.put(msgWrapper15.balId, msgWrapper15);

        RecommendationsActionWrapper msgWrapper16 = new RecommendationsActionWrapper();
        msgWrapper16.balId = 'BAL_16';
        msgWrapper16.evaluation = '';
        msgWrapper16.sellerRecommendedActionMessage = 'RecomAction_BAL_16_SellerMessage';
        msgWrapper16.managerRecommendedActionMessage = 'RecomAction_BAL_16_ManagerMessage';
        msgWrapper16.sellerEmailText = 'RecomAction_BAL_16_SellerEmailText';
        msgWrapper16.actionMsg = 'RecomAction_BAL_16_actionMsg';
        msgWrapper16.sellerUrlText = '10_Opportunity_Scorecard.mp4';
        msgWrapper16.sellerUrlLink = 'https://kfsell.kornferry.com/Blue+Sheet+Reinforcement/10_Opportunity_Scorecard.mp4';
        msgWrapper16.managerUrlText = '{sellerName} hasn a scorecard that doesn\'t meet the organization\'s standards. Scorecard score is a coaching opportunity at your next review. To help you prepare, review this resource:';
        msgWrapper16.managerUrlLink = 'https://kfsell.kornferry.com/Manager+Support/Support+Your+Team+-+Sales+Funnel+v3.pdf';
        msgWrapper16.associatedObject = 'Scorecard';
        mapRuleMSg.put(msgWrapper16.balId, msgWrapper16);

        RecommendationsActionWrapper msgWrapper17 = new RecommendationsActionWrapper();
        msgWrapper17.balId = 'BAL_17';
        msgWrapper17.evaluation = '';
        msgWrapper17.sellerRecommendedActionMessage = 'RecomAction_BAL_17_SellerMessage';
        msgWrapper17.managerRecommendedActionMessage = 'RecomAction_BAL_17_ManagerMessage';
        msgWrapper17.sellerEmailText = 'RecomAction_BAL_17_SellerEmailText';
        msgWrapper17.actionMsg = 'RecomAction_BAL_17_actionMsg';
        msgWrapper17.sellerUrlText = '10_Opportunity_Scorecard.mp4';
        msgWrapper17.sellerUrlLink = 'https://kfsell.kornferry.com/Blue+Sheet+Reinforcement/10_Opportunity_Scorecard.mp4';
        msgWrapper17.managerUrlText = '{sellerName} hasn a scorecard that doesn\'t meet the organization\'s standards. Scorecard score is a coaching opportunity at your next review. To help you prepare, review this resource:';
        msgWrapper17.managerUrlLink = 'https://kfsell.kornferry.com/Manager+Support/Support+Your+Team+-+Sales+Funnel+v3.pdf';
        msgWrapper17.associatedObject = 'Scorecard';
        mapRuleMSg.put(msgWrapper17.balId, msgWrapper17);

        //KFS-1332 - msg for newly added rule
        RecommendationsActionWrapper msgWrapper18 = new RecommendationsActionWrapper();
        msgWrapper18.balId = 'BAL_18';
        msgWrapper18.evaluation = 'RecomAction_BAL_18_Evaluation';
        msgWrapper18.sellerRecommendedActionMessage = 'RecomAction_BAL_18_SellerMessage';
        msgWrapper18.managerRecommendedActionMessage = 'RecomAction_BAL_18_ManagerMessage';
        msgWrapper18.sellerEmailText = 'RecomAction_BAL_18_SellerEmailText';
        msgWrapper18.actionMsg = 'RecomAction_BAL_18_actionMsg';
        msgWrapper18.sellerUrlText = '08_Improving_Ratings.mp4';
        msgWrapper18.sellerUrlLink = 'https://kfsell.kornferry.com/Blue+Sheet+Reinforcement/08_Improving_Ratings.mp4';
        msgWrapper18.managerUrlText =
            '{sellerName} owns an opportunity with a low rated {BIRole}.' +
            'Coach the seller on actions to take to increase the Rating for the Buying Influence to at least +2, and ideally +3, +4 or +5.';
        msgWrapper18.managerUrlLink = 'https://kfsell.kornferry.com/Manager+Support/Support+Your+Team+-+Ratings+v3.pdf';
        msgWrapper18.associatedObject = 'Buying Influence';
        mapRuleMSg.put(msgWrapper18.balId, msgWrapper18);

        RecommendationsActionWrapper msgWrapper19 = new RecommendationsActionWrapper();
        msgWrapper19.balId = 'BAL_19';
        msgWrapper19.evaluation = 'RecomAction_BAL_19_Evaluation';
        msgWrapper19.sellerRecommendedActionMessage = 'RecomAction_BAL_19_SellerMessage';
        msgWrapper19.managerRecommendedActionMessage = 'RecomAction_BAL_19_ManagerMessage';
        msgWrapper19.sellerEmailText = 'RecomAction_BAL_19_SellerEmailText';
        msgWrapper19.actionMsg = 'RecomAction_BAL_19_actionMsg';
        msgWrapper19.sellerUrlText = 'Acquire_Coach.mp4';
        msgWrapper19.sellerUrlLink = 'https://kfsell.kornferry.com/Blue+Sheet+Reinforcement/Acquire_Coach.mp4';
        msgWrapper19.managerUrlText =
            '{sellerName} owns an opportunity with a high rated Buying Influence and no Coach identified.' +
            'Coach the seller on leveraging high rated Buying Influences and developing Coaches. ' +
            'To help you prepare, consider viewing this resource:' +
            'Coach the seller on actions to take to increase the Rating for the Buying Influence to at least +2, and ideally +3, +4 or +5.';
        msgWrapper19.managerUrlLink = 'https://kfsell.kornferry.com/Manager+Support/Support+Your+Team+-+Ratings+v3.pdf';
        msgWrapper19.associatedObject = 'Buying Influence';
        mapRuleMSg.put(msgWrapper19.balId, msgWrapper19);

        RecommendationsActionWrapper msgWrapper20 = new RecommendationsActionWrapper();
        msgWrapper20.balId = 'BAL_20';
        msgWrapper20.evaluation = 'RecomAction_BAL_20_Evaluation';
        msgWrapper20.sellerRecommendedActionMessage = 'RecomAction_BAL_20_SellerMessage';
        msgWrapper20.managerRecommendedActionMessage = 'RecomAction_BAL_20_ManagerMessage';
        msgWrapper20.sellerEmailText = 'RecomAction_BAL_20_SellerEmailText';
        msgWrapper20.actionMsg = 'RecomAction_BAL_20_actionMsg';
        msgWrapper20.sellerUrlText = 'Acquire_WinResults.mp4';
        msgWrapper20.sellerUrlLink = 'https://kfsell.kornferry.com/Blue+Sheet+Reinforcement/Acquire_WinResults.mp4';
        msgWrapper20.managerUrlText =
            '{sellerName}owns an opportunity without Personal Wins or Business Results for a Buying Influence.' +
            'Coach the seller on populating the "Personal Win(s)" and "Business Result(s)" fields.' +
            'To help you prepare, consider viewing the following resources:';
        msgWrapper20.managerUrlLink = 'https://kfsell.kornferry.com/Manager+Support/Support+Your+Team+-+Win-Results+v3.pdf';
        msgWrapper20.associatedObject = 'Buying Influence';
        mapRuleMSg.put(msgWrapper20.balId, msgWrapper20);

        RecommendationsActionWrapper msgWrapper21 = new RecommendationsActionWrapper();
        msgWrapper21.balId = 'BAL_21';
        msgWrapper21.evaluation = 'RecomAction_BAL_21_Evaluation';
        msgWrapper21.sellerRecommendedActionMessage = 'RecomAction_BAL_21_SellerMessage';
        msgWrapper21.managerRecommendedActionMessage = 'RecomAction_BAL_21_ManagerMessage';
        msgWrapper21.sellerEmailText = 'RecomAction_BAL_21_SellerEmailText';
        msgWrapper21.actionMsg = 'RecomAction_BAL_21_actionMsg';
        msgWrapper21.sellerUrlText = 'Acquire_WinResults.mp4';
        msgWrapper21.sellerUrlLink = 'https://kfsell.kornferry.com/Blue+Sheet+Reinforcement/Acquire_WinResults.mp4';
        msgWrapper21.managerUrlText =
            '{sellerName} owns an opportunity without Personal Wins or Business Results for a Buying Influence.' +
            'Coach the seller on populating the "Personal Win(s)" and "Business Result(s)" fields.' +
            'To help you prepare, consider viewing the following resources:';
        msgWrapper21.managerUrlLink = 'https://kfsell.kornferry.com/Manager+Support/Support+Your+Team+-+Win-Results+v3.pdf';
        msgWrapper21.associatedObject = 'Buying Influence';
        mapRuleMSg.put(msgWrapper21.balId, msgWrapper21);

        RecommendationsActionWrapper msgWrapper22 = new RecommendationsActionWrapper();
        msgWrapper22.balId = 'BAL_22';
        msgWrapper22.evaluation = 'RecomAction_BAL_22_Evaluation';
        msgWrapper22.sellerRecommendedActionMessage = 'RecomAction_BAL_22_SellerMessage';
        msgWrapper22.managerRecommendedActionMessage = 'RecomAction_BAL_22_ManagerMessage';
        msgWrapper22.sellerEmailText = 'RecomAction_BAL_22_SellerEmailText';
        msgWrapper22.actionMsg = 'RecomAction_BAL_22_actionMsg';
        msgWrapper22.sellerUrlText = '05_Uncovering_Unkown_Buying_Influences.mp4';
        msgWrapper22.sellerUrlLink = 'https://kfsell.kornferry.com/Blue+Sheet+Reinforcement/05_Uncovering_Unknown_Buying_Influences.mp4';
        msgWrapper22.managerUrlText =
            '{sellerName} has not identified a sufficient number of buying influences for this opportunity.' +
            'Work with the seller to identify who else can have an impact on this opportunity.';
        msgWrapper22.managerUrlLink = 'https://kfsell.kornferry.com/Blue+Sheet+Reinforcement/05_Uncovering_Unknown_Buying_Influences.mp4';
        msgWrapper22.associatedObject = 'Buying Influence';
        mapRuleMSg.put(msgWrapper22.balId, msgWrapper22);

        RecommendationsActionWrapper msgWrapper23 = new RecommendationsActionWrapper();
        msgWrapper23.balId = 'BAL_23';
        msgWrapper23.evaluation = 'RecomAction_BAL_23_Evaluation';
        msgWrapper23.sellerRecommendedActionMessage = 'RecomAction_BAL_23_SellerMessage';
        msgWrapper23.managerRecommendedActionMessage = 'RecomAction_BAL_23_ManagerMessage';
        msgWrapper23.sellerEmailText = 'RecomAction_BAL_23_SellerEmailText';
        msgWrapper23.actionMsg = 'RecomAction_BAL_23_actionMsg';
        msgWrapper23.sellerUrlText = 'Acquire_Coach.mp4';
        msgWrapper23.sellerUrlLink = 'https://kfsell.kornferry.com/Blue+Sheet+Reinforcement/Acquire_Coach.mp4';
        msgWrapper23.managerUrlText =
            '{sellerName} owns an opportunity with a Coach that has a low Degree of Influence.' +
            'Consider meeting with the seller to discuss identifying and developing effective coaches.' +
            'To help you prepare, review this resource:';
        msgWrapper23.managerUrlLink = 'https://kfsell.kornferry.com/Manager+Support/Support+Your+Team+-+Rating+Coach.pdf';
        msgWrapper23.associatedObject = 'Buying Influence';
        mapRuleMSg.put(msgWrapper23.balId, msgWrapper23);

        RecommendationsActionWrapper msgWrapper24 = new RecommendationsActionWrapper();
        msgWrapper24.balId = 'BAL_24';
        msgWrapper24.evaluation = 'RecomAction_BAL_24_Evaluation';
        msgWrapper24.sellerRecommendedActionMessage = 'RecomAction_BAL_24_SellerMessage';
        msgWrapper24.managerRecommendedActionMessage = 'RecomAction_BAL_24_ManagerMessage';
        msgWrapper24.sellerEmailText = 'RecomAction_BAL_24_SellerEmailText';
        msgWrapper24.actionMsg = 'RecomAction_BAL_24_actionMsg';
        msgWrapper24.sellerUrlText = '07_Influencing_Modes.mp4';
        msgWrapper24.sellerUrlLink = 'https://kfsell.kornferry.com/Blue+Sheet+Reinforcement/07_Influencing_Modes.mp4';
        msgWrapper24.managerUrlText =
            '{sellerName} owns an opportunity with a disconnect between the Buying Influence’s Mode and the' +
            'Customer Timing for Priorities.To help you coach the seller on the relationship ' +
            'between Modes and the Customer Timing for Priorities, consider viewing this resource:';
        msgWrapper24.managerUrlLink = 'https://kfsell.kornferry.com/Manager+Support/Support+Your+Team+-+Modes+and+Customer+Timing+v3.pdf';
        msgWrapper24.associatedObject = 'Buying Influence';
        mapRuleMSg.put(msgWrapper24.balId, msgWrapper24);

        //Green Sheet Rules

        RecommendationsActionWrapper msgWrapper25 = new RecommendationsActionWrapper();
        msgWrapper25.balId = 'BAL_25';
        msgWrapper25.evaluation = 'RecomAction_BAL_25_Evaluation';
        msgWrapper25.sellerRecommendedActionMessage = 'RecomAction_BAL_25_SellerMessage';
        msgWrapper25.managerRecommendedActionMessage = '';
        msgWrapper25.sellerEmailText = 'RecomAction_BAL_25_SellerEmailText';
        msgWrapper25.actionMsg = 'RecomAction_BAL_25_actionMsg';
        msgWrapper25.sellerUrlText = 'Quick Refresher';
        msgWrapper25.sellerUrlLink = 'https://kfsell.kornferry.com/Green+Sheet+Reinforcement/MinAction.mp4';
        msgWrapper25.managerUrlText = '';
        msgWrapper25.managerUrlLink = '';
        msgWrapper25.associatedObject = 'Geeting Commitment';
        mapRuleMSg.put(msgWrapper25.balId, msgWrapper25);

        RecommendationsActionWrapper msgWrapper26 = new RecommendationsActionWrapper();
        msgWrapper26.balId = 'BAL_26';
        msgWrapper26.evaluation = 'RecomAction_BAL_26_Evaluation';
        msgWrapper26.sellerRecommendedActionMessage = 'RecomAction_BAL_26_SellerMessage';
        msgWrapper26.managerRecommendedActionMessage = '';
        msgWrapper26.sellerEmailText = 'RecomAction_BAL_26_SellerEmailText';
        msgWrapper26.actionMsg = 'RecomAction_BAL_26_actionMsg';
        msgWrapper26.sellerUrlText = 'Quick Refresher';
        msgWrapper26.sellerUrlLink = 'https://kfsell.kornferry.com/Green+Sheet+Reinforcement/BestActionCommit.mp4';
        msgWrapper26.managerUrlText = '';
        msgWrapper26.managerUrlLink = '';
        msgWrapper26.associatedObject = 'Geeting Commitment';
        mapRuleMSg.put(msgWrapper26.balId, msgWrapper26);

        RecommendationsActionWrapper msgWrapper27 = new RecommendationsActionWrapper();
        msgWrapper27.balId = 'BAL_27';
        msgWrapper27.evaluation = 'RecomAction_BAL_27_Evaluation';
        msgWrapper27.sellerRecommendedActionMessage = 'RecomAction_BAL_27_SellerMessage';
        msgWrapper27.managerRecommendedActionMessage = '';
        msgWrapper27.sellerEmailText = 'RecomAction_BAL_27_SellerEmailText';
        msgWrapper27.actionMsg = 'RecomAction_BAL_27_actionMsg';
        msgWrapper27.sellerUrlText = 'Quick Refresher';
        msgWrapper27.sellerUrlLink = 'https://kfsell.kornferry.com/Green+Sheet+Reinforcement/VBR.mp4';
        msgWrapper27.managerUrlText = '';
        msgWrapper27.managerUrlLink = '';
        msgWrapper27.associatedObject = 'Green Sheet';
        mapRuleMSg.put(msgWrapper27.balId, msgWrapper27);

        RecommendationsActionWrapper msgWrapper28 = new RecommendationsActionWrapper();
        msgWrapper28.balId = 'BAL_28';
        msgWrapper28.evaluation = 'RecomAction_BAL_28_Evaluation';
        msgWrapper28.sellerRecommendedActionMessage = 'RecomAction_BAL_28_SellerMessage';
        msgWrapper28.managerRecommendedActionMessage = '';
        msgWrapper28.sellerEmailText = 'RecomAction_BAL_28_SellerEmailText';
        msgWrapper28.actionMsg = 'RecomAction_BAL_28_actionMsg';
        msgWrapper28.sellerUrlText = 'Quick Refresher';
        msgWrapper28.sellerUrlLink = 'https://kfsell.kornferry.com/Green+Sheet+Reinforcement/Concept.mp4';
        msgWrapper28.managerUrlText = '';
        msgWrapper28.managerUrlLink = '';
        msgWrapper28.associatedObject = 'Green Sheet Buying Influence';
        mapRuleMSg.put(msgWrapper28.balId, msgWrapper28);

        return mapRuleMSg;
    }
}