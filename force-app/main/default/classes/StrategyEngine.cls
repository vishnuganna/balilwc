/*
 * ─────────────────────────────────────────────────────────────────────────────────────────────────
 * KFS-276 (part of main US KFS-125) : Apex class to map source object fields to strategy engine fields
 * ──────────────────────────────────────────────────────────────────────────────────────────────────
 * @author         Keerthana Mohanasundaram
 * @created        05/22/2020
 *
 * Most of the methods in this class are called from the triggers of the different Blue Sheet Objects.
 */

public with sharing class StrategyEngine {
    public static List<Recommendations__c> recommDeleteListBI = new List<Recommendations__c>();
    public static List<Recommendations__c> competitionDeleteList = new List<Recommendations__c>();
    public static List<Recommendations__c> actionPlanDeleteList = new List<Recommendations__c>();
    // This methods is called from BlueSheet_Landingpage LWC Component
    @AuraEnabled
    public static String createBlueSheet(String opptyId) {
        if (Schema.sObjectType.Blue_Sheet__c.isCreateable() || Schema.sObjectType.Blue_Sheet__c.isUpdateable()) {
            String bluesheetQuery =
                'Select Id,Name,Opportunity__c' + ' FROM Blue_Sheet__c WHERE Opportunity__c=:opptyId LIMIT 1';

            Map<String, Object> paramters = new Map<String, Object>();
            paramters.put('opptyId', opptyId);
            List<Blue_Sheet__c> listBlueSheet = DataFactory.read(bluesheetQuery, paramters);

            String opptyQuery =
                'Select Id,Name,StageName,Amount,LastModifiedDate,CloseDate,Blue_Sheet_Count__c,AccountId,Account.Name' +
                ' FROM Opportunity WHERE Id =:opptyId LIMIT 1';

            Map<String, Object> opptyparamters = new Map<String, Object>();
            opptyparamters.put('opptyId', opptyId);
            List<opportunity> opptyList = DataFactory.read(opptyQuery, opptyparamters);

            String contactQuery =
                'Select Id,Name,level__c FROM Contact WHERE level__c =\'Primary\' AND AccountId IN' +
                ' (SELECT AccountId FROM Opportunity WHERE Id =:opptyId) ';
            Map<String, Object> contactparamters = new Map<String, Object>();
            contactparamters.put('opptyId', opptyId);
            List<contact> contactList = DataFactory.read(contactQuery, contactparamters);

            String blueSheetId;
            // Create Blue Sheet and Strategy Engine record
            if (listBlueSheet.isEmpty()) {
                Blue_Sheet__c blue = new Blue_Sheet__c();
                blue.Opportunity__c = opptyId;
                blue.Progress__c = 'Not Started';
                blue.SSO_Progress__c = 'Not Started';
                blue.Current_Position_Progress__c = 'Not Started';
                blue.Scorecard_Progress__c = 'Not Started';
                blue.Competition_Progress__c = 'Not Started';
                blue.Buying_Influence_Progress__c = 'Not Started';
                blue.Summary_Position_Progress__c = 'Not Started';
                blue.Action_Plan_Progress__c = 'Not Started';
                DataFactory.create(blue);
                blueSheetId = blue.Id;
                String blueSheetNewQuery = 'Select Id,Name,LastModifiedDate,Count_Actions__c FROM Blue_Sheet__c WHERE Id =:blueSheetId';
                Map<String, Object> blueSheetNewparamters = new Map<String, Object>();
                blueSheetNewparamters.put('blueSheetId', blueSheetId);
                List<Blue_Sheet__c> bluesheetList = DataFactory.read(blueSheetNewQuery, blueSheetNewparamters);
                Strategy_Engine__c strategy = new Strategy_Engine__c();
                strategy.Source_ID__c = blue.Id;
                strategy.Blue_Sheet__c = blue.Id;
                strategy.Opportunity__c = opptyList[0].Id;
                strategy.Opportunity_Name__c = opptyList[0].Name;
                strategy.Opportunity_Amount__c = opptyList[0].Amount;
                strategy.Opty_Close_Date__c = opptyList[0].CloseDate;
                strategy.Place_in_Sales_Funnel__c = opptyList[0].StageName;
                strategy.Opty_Stage_Last_Modified_Date__c = opptyList[0].LastModifiedDate;
                strategy.Is_Master__c = true;
                if (opptyList[0].AccountId != null) {
                    strategy.Account_Name__c = opptyList[0].Account.Name;
                }
                if (contactList.size() > 0) {
                    strategy.Contact_Name__c = contactList[0].Name;
                }
                strategy.Blue_Sheet_Name__c = bluesheetList[0].Name;
                strategy.Bluesheet_Last_Modified_Date__c = bluesheetList[0].LastModifiedDate;
                DataFactory.create(strategy);
                opptyList[0].Blue_Sheet_Count__c = 1;
                opptyList[0].Blue_Sheet__c = blue.Id;
                DataFactory.upsurt(opptyList);
                BestActionLogic.upsertRecommendations(opptyId);
            } else {
                blueSheetId = listBlueSheet[0].Id;
            }
            return blueSheetId;
        } else {
            if (
                Schema.sObjectType.Blue_Sheet__c.isAccessible() &&
                Schema.sObjectType.Blue_Sheet__c.fields.Action_Plan_Progress__c.isAccessible()
            ) {
                String bluesheetQuery =
                    'Select Id,Name,Opportunity__c' + ' FROM Blue_Sheet__c WHERE Opportunity__c=:opptyId LIMIT 1';
                Map<String, Object> paramters = new Map<String, Object>();
                paramters.put('opptyId', opptyId);
                List<Blue_Sheet__c> listBlueSheet = DataFactory.read(bluesheetQuery, paramters);
                if (listBlueSheet.isEmpty()) {
                    return '';
                } else {
                    return listBlueSheet[0].Id;
                }
            } else {
                return 'NoBSAccess';
            }
        }
    }

    @AuraEnabled
    public static String getOppId(String blueSheetId) {
        String oppID = '';
        Map<Id, Blue_Sheet__c> bsInfoMap = new Map<Id, Blue_Sheet__c>();
        Set<String> blueSheetIdSet = new Set<String>();
        try {
            blueSheetIdSet.add(blueSheetId);
            bsInfoMap = ApexCommonUtil.getBlueSheetInfo(blueSheetIdSet);
            if (bsInfoMap != null && !bsInfoMap.isEmpty()) {
                Blue_Sheet__c bs = bsInfoMap.get(blueSheetId);
                oppID = bs.Opportunity__c;
            }
        } catch (Exception ex) {
            system.System.debug('exception ----' + ex);
        }
        return oppID;
    }

    public static void updateSingleSalesObjective(List<Single_Sales_Objective__c> ssoRecords) {
        List<String> ssoBlueSheetIds = new List<String>();
        for (Single_Sales_Objective__c sso : ssoRecords) {
            ssoBlueSheetIds.add(sso.Blue_Sheet__c);
        }

        String query =
            'SELECT Id,Source_ID__c,Customer_Stated_Objective__c ' +
            'FROM Strategy_Engine__c' +
            ' WHERE Source_ID__c IN:ssoBlueSheetIds';

        Map<String, Object> params = new Map<String, Object>();
        params.put('ssoBlueSheetIds', ssoBlueSheetIds);

        List<Strategy_Engine__c> strategyEngineRecords = DataFactory.read(query, params);

        Map<String, Strategy_Engine__c> SERecordsCreate = new Map<String, Strategy_Engine__c>();

        for (Strategy_Engine__c SE : strategyEngineRecords) {
            SERecordsCreate.put(SE.Source_ID__c, SE);
        }
        List<Strategy_Engine__c> updateStrategyEngine = new List<Strategy_Engine__c>();
        //Populating SSO Section of Strategy Engine record
        for (Single_Sales_Objective__c sso : ssoRecords) {
            if (SERecordsCreate.containsKey(sso.Blue_Sheet__c)) {
                if (sso.Customers_Stated_Objectives__c != null) {
                    SERecordsCreate.get(sso.Blue_Sheet__c).Customer_Stated_Objective__c = 'True';
                } else {
                    SERecordsCreate.get(sso.Blue_Sheet__c).Customer_Stated_Objective__c = 'False';
                }
                if (sso.Evaluation_of_Objectives__c != null) {
                    SERecordsCreate.get(sso.Blue_Sheet__c).Evaluation_of_Objective__c = 'True';
                } else {
                    SERecordsCreate.get(sso.Blue_Sheet__c).Evaluation_of_Objective__c = 'False';
                }
                if (
                    sso.Customer_Timing_for_Priorities__c == 'Urgent' ||
                    sso.Customer_Timing_for_Priorities__c == 'Active'
                ) {
                    SERecordsCreate.get(sso.Blue_Sheet__c).Customer_Timing_for_Priorities__c = 'Positive';
                } else {
                    SERecordsCreate.get(sso.Blue_Sheet__c).Customer_Timing_for_Priorities__c = 'Negative';
                }
                SERecordsCreate.get(sso.Blue_Sheet__c).SSO_Name__c = sso.name;
                updateStrategyEngine.add(SERecordsCreate.get(sso.Blue_Sheet__c));
            }
        }
        DataFactory.modify(updateStrategyEngine);
    }
    public static void updateCurrentPosition(List<Current_Position__c> cpRecords) {
        List<String> cpBlueSheetIds = new List<String>();
        for (Current_Position__c cp : cpRecords) {
            cpBlueSheetIds.add(cp.Blue_Sheet__c);
        }

        String query =
            'SELECT Id,Source_ID__c,Current_Position_Name__c,CurrentPosition__c,Current_Position__c ' +
            'FROM Strategy_Engine__c' +
            ' WHERE Source_ID__c IN:cpBlueSheetIds';

        Map<String, Object> params = new Map<String, Object>();
        params.put('cpBlueSheetIds', cpBlueSheetIds);

        List<Strategy_Engine__c> strategyEngineRecords = DataFactory.read(query, params);
        Map<String, Strategy_Engine__c> SERecordsCreate = new Map<String, Strategy_Engine__c>();

        for (Strategy_Engine__c SE : strategyEngineRecords) {
            SERecordsCreate.put(SE.Source_ID__c, SE);
        }
        List<Strategy_Engine__c> updateStrategyEngine = new List<Strategy_Engine__c>();
        List<String> cpPositiveValues = new List<String>{ 'Euphoria', 'Great', 'Secure', 'Comfort', 'Ok' };
        //Populating Current Position Section of Strategy Engine record
        for (Current_Position__c cp : cpRecords) {
            if (SERecordsCreate.containsKey(cp.Blue_Sheet__c)) {
                if (cpPositiveValues.contains(cp.Current_Position__c)) {
                    SERecordsCreate.get(cp.Blue_Sheet__c).Position__c = 'Positive';
                } else {
                    SERecordsCreate.get(cp.Blue_Sheet__c).Position__c = 'Negative';
                }

                SERecordsCreate.get(cp.Blue_Sheet__c).Current_Position_Name__c = cp.name;
                SERecordsCreate.get(cp.Blue_Sheet__c).CurrentPosition__c = cp.Id;
                SERecordsCreate.get(cp.Blue_Sheet__c).Current_Position__c = cp.Current_Position__c;
                updateStrategyEngine.add(SERecordsCreate.get(cp.Blue_Sheet__c));
            }
        }
        DataFactory.modify(updateStrategyEngine);
    }
    public static void updateCompetition(List<Competition__c> compRecords) {
        List<String> competitionIds = new List<String>();
        for (Competition__c competition : compRecords) {
            competitionIds.add(competition.Id);
        }
        String query =
            'SELECT Id,Source_ID__c,Customer_Stated_Objective__c ' +
            'FROM Strategy_Engine__c' +
            ' WHERE Source_ID__c IN:competitionIds';

        Map<String, Object> params = new Map<String, Object>();
        params.put('competitionIds', competitionIds);
        List<Strategy_Engine__c> strategyEngineRecords = DataFactory.read(query, params);

        Map<String, Strategy_Engine__c> SERecordsCreate = new Map<String, Strategy_Engine__c>();
        List<Strategy_Engine__c> updateStrategyEngine = new List<Strategy_Engine__c>();
        // if strategyEngineRecords has records then update logic
        if (strategyEngineRecords.size() > 0) {
            for (Strategy_Engine__c SE : strategyEngineRecords) {
                SERecordsCreate.put(SE.Source_ID__c, SE);
            }

            for (Competition__c competition : compRecords) {
                if (SERecordsCreate.containsKey(competition.Id)) {
                    if (competition.Competitive_Detail__c != null) {
                        SERecordsCreate.get(competition.Id).Competition_Detail_Field__c = 'True';
                    } else {
                        SERecordsCreate.get(competition.Id).Competition_Detail_Field__c = 'False';
                    }
                    SERecordsCreate.get(competition.Id).Competition_Type__c = competition.Competitor_Type__c;
                    SERecordsCreate.get(competition.Id)
                        .My_Position_Vs_Competition__c = competition.My_Position_Vs_Competitor__c;
                    SERecordsCreate.get(competition.Id).Competitor_Name__c = competition.Name;
                    SERecordsCreate.get(competition.Id).Competitor__c = competition.Competitor_Type__c;
                    SERecordsCreate.get(competition.Id)
                        .Position_vs_Competition__c = competition.My_Position_Vs_Competitor__c;
                    updateStrategyEngine.add(SERecordsCreate.get(competition.Id));
                }
            }
            DataFactory.modify(updateStrategyEngine);
        } else {
            // create logic if no records exits in strategyEngineRecords
            Set<Id> compIdSet = new Set<Id>();
            for (Competition__c competition : compRecords) {
                compIdSet.add(competition.id);
            }
            String opQuery = 'Select Id, Name, Blue_Sheet__r.Opportunity__c from Competition__c where Id=:compIdSet';
            Map<String, Object> parameters = new Map<String, Object>();
            parameters.put('compIdSet', compIdSet);
            List<Competition__c> compLst = DataFactory.read(opQuery, parameters);
            Map<String, String> compOppMap = new Map<String, String>();
            for (Competition__c comp : compLst) {
                compOppMap.put(comp.id, comp.Blue_Sheet__r.Opportunity__c);
            }

            for (Competition__c competition : compRecords) {
                Strategy_Engine__c strategy = new Strategy_Engine__c();
                strategy.Source_ID__c = competition.Id;
                strategy.Competition__c = competition.Id;
                strategy.Blue_Sheet__c = competition.Blue_Sheet__c;
                strategy.Competition_Type__c = competition.Competitor_Type__c;
                strategy.My_Position_Vs_Competition__c = competition.My_Position_Vs_Competitor__c;
                strategy.Competitor_Name__c = competition.Name;
                strategy.Opportunity_Name__c = competition.Opportunity_Name__c;
                strategy.Blue_Sheet_Name__c = competition.Blue_Sheet_Name__c;
                if (competition.Competitive_Detail__c != null) {
                    strategy.Competition_Detail_Field__c = 'True';
                } else {
                    strategy.Competition_Detail_Field__c = 'False';
                }
                strategy.Competitor__c = competition.Competitor_Type__c;
                strategy.Position_vs_Competition__c = competition.My_Position_Vs_Competitor__c;
                strategy.Opportunity__c = compOppMap.get(competition.Id);
                updateStrategyEngine.add(strategy);
            }
            DataFactory.create(updateStrategyEngine);
        }
    }

    public static void DeleteCompetition(List<Competition__c> deleteCompRecords) {
        List<Id> compIdsDelete = new List<Id>();
        for (Competition__c delComps : deleteCompRecords) {
            compIdsDelete.add(delComps.Id);
        }
        String query =
            'SELECT Id,Source_ID__c,Customer_Stated_Objective__c ' +
            'FROM Strategy_Engine__c' +
            ' WHERE Source_ID__c IN:compIdsDelete';

        Map<String, Object> params = new Map<String, Object>();
        params.put('compIdsDelete', compIdsDelete);
        List<Strategy_Engine__c> strategyEngineRecords = DataFactory.read(query, params);
        DataFactory.remove(strategyEngineRecords);
    }
    @SuppressWarnings('PMD.NcssMethodCount')
    public static void updateBuyingInfluence(List<Buying_Influence__c> buyingRecords) {
        List<String> buyingIds = new List<String>();
        for (Buying_Influence__c buy : buyingRecords) {
            buyingIds.add(buy.Id);
        }
        String query =
            'SELECT Id,Source_ID__c,Customer_Stated_Objective__c ' +
            'FROM Strategy_Engine__c' +
            ' WHERE Source_ID__c IN:buyingIds';
        Map<String, Object> params = new Map<String, Object>();
        params.put('buyingIds', buyingIds);
        List<Strategy_Engine__c> strategyEngineRecords = DataFactory.read(query, params);
        Map<String, Strategy_Engine__c> SERecordsCreate = new Map<String, Strategy_Engine__c>();
        List<Strategy_Engine__c> updateStrategyEngine = new List<Strategy_Engine__c>();
        // if strategyEngineRecords has records then update logic
        if (strategyEngineRecords.size() > 0) {
            for (Strategy_Engine__c SE : strategyEngineRecords) {
                SERecordsCreate.put(SE.Source_ID__c, SE);
            }

            for (Buying_Influence__c buy : buyingRecords) {
                if (SERecordsCreate.containsKey(buy.Id)) {
                    SERecordsCreate.get(buy.Id).Buying_Influence_Name__c = buy.Name;
                    if (buy.Over_Confident__c) {
                        SERecordsCreate.get(buy.Id).Buying_Mode__c = 'Over Confident';
                    } else if (buy.Growth__c) {
                        SERecordsCreate.get(buy.Id).Buying_Mode__c = 'Growth';
                    } else if (buy.Trouble__c) {
                        SERecordsCreate.get(buy.Id).Buying_Mode__c = 'Trouble';
                    } else if (buy.Even_Keel__c) {
                        SERecordsCreate.get(buy.Id).Buying_Mode__c = 'Even Keel';
                    } else {
                        SERecordsCreate.get(buy.Id).Buying_Mode__c = '';
                    }

                    if (
                        buy.Rating__c == '+1' ||
                        buy.Rating__c == '+2' ||
                        buy.Rating__c == '+3' ||
                        buy.Rating__c == '+4' ||
                        buy.Rating__c == '+5'
                    ) {
                        SERecordsCreate.get(buy.Id).Rating__c = 'Positive';
                    } else {
                        SERecordsCreate.get(buy.Id).Rating__c = 'Negative';
                    }
                    if (buy.High__c) {
                        SERecordsCreate.get(buy.Id).Degree_of_Influence__c = 'High';
                    } else if (buy.Medium__c) {
                        SERecordsCreate.get(buy.Id).Degree_of_Influence__c = 'Medium';
                    } else if (buy.Low__c) {
                        SERecordsCreate.get(buy.Id).Degree_of_Influence__c = 'Low';
                    } else {
                        SERecordsCreate.get(buy.Id).Degree_of_Influence__c = '';
                    }

                    /*if(buy.Economic__c){
                       SERecordsCreate.get(buy.Id).Buying_Influence_Role__c = 'Economic';
                       }
                     else if(buy.Technical__c){
                       SERecordsCreate.get(buy.Id).Buying_Influence_Role__c = 'Technical';
                       }
                     else if(buy.User__c){
                       SERecordsCreate.get(buy.Id).Buying_Influence_Role__c = 'User';
                       }
                     else if(buy.Coach__c){
                        SERecordsCreate.get(buy.Id).Buying_Influence_Role__c = 'Coach';
                     }else{
                        SERecordsCreate.get(buy.Id).Buying_Influence_Role__c = '';
                      }*/

                    List<String> biRole = new List<String>();
                    if (buy.Economic__c) {
                        biRole.add('Economic');
                        //strategy.Buying_Influence_Role__c = 'Economic';
                    }
                    if (buy.Technical__c) {
                        biRole.add('Technical');
                    }
                    if (buy.User__c) {
                        biRole.add('User');
                    }
                    if (buy.Coach__c) {
                        biRole.add('Coach');
                    }
                    if (
                        buy.User__c == false &&
                        buy.Coach__c == false &&
                        buy.Technical__c == false &&
                        buy.Economic__c == false
                    ) {
                        biRole.add('');
                    }
                    SERecordsCreate.get(buy.Id).Buying_Influence_Role__c = String.join(biRole, ',');

                    if (buy.Rating_Evidence__c != null) {
                        SERecordsCreate.get(buy.Id).Rating_Evidence__c = 'True';
                    } else {
                        SERecordsCreate.get(buy.Id).Rating_Evidence__c = 'False';
                    }

                    if (buy.Business_Results__c != null) {
                        SERecordsCreate.get(buy.Id).Business_Results__c = 'True';
                    } else {
                        SERecordsCreate.get(buy.Id).Business_Results__c = 'False';
                    }

                    if (buy.Personal_Wins__c != null) {
                        SERecordsCreate.get(buy.Id).Personal_Wins__c = 'True';
                    } else {
                        SERecordsCreate.get(buy.Id).Personal_Wins__c = 'False';
                    }

                    if (buy.Using_Budget_for_Something_Else__c) {
                        SERecordsCreate.get(buy.Id).Competitive_Preference__c = 'Using Budget For Something Else';
                    } else if (buy.Using_Internal_Resources__c) {
                        SERecordsCreate.get(buy.Id).Competitive_Preference__c = 'Using Internal Resource';
                    } else if (buy.Buying_from_Someone_Else__c) {
                        SERecordsCreate.get(buy.Id).Competitive_Preference__c = 'Buying From Someone Else';
                    } else if (buy.Doing_Nothing__c) {
                        SERecordsCreate.get(buy.Id).Competitive_Preference__c = 'Doing Nothing';
                    } else if (buy.Buying_From_Us__c) {
                        SERecordsCreate.get(buy.Id).Competitive_Preference__c = 'Buying From Us';
                    } else {
                        SERecordsCreate.get(buy.Id).Competitive_Preference__c = '';
                    }
                    updateStrategyEngine.add(SERecordsCreate.get(buy.Id));
                }
                DataFactory.modify(updateStrategyEngine);
            }

            // create logic if no records exits in strategyEngineRecords
        } else {
            Set<Id> biIdSet = new Set<Id>();
            for (Buying_Influence__c bi : buyingRecords) {
                biIdSet.add(bi.id);
            }
            String opQuery = 'Select Id, Name, Blue_Sheet__r.Opportunity__c,Blue_Sheet__r.Opportunity__r.StageName from Buying_Influence__c where Id=:biIdSet';
            Map<String, Object> parameters = new Map<String, Object>();
            parameters.put('biIdSet', biIdSet);
            List<Buying_Influence__c> biLst = DataFactory.read(opQuery, parameters);
            Map<String, String> biOppMap = new Map<String, String>();
            Map<String, String> biOppStagenameMap = new Map<String, String>();
            for (Buying_Influence__c bi : biLst) {
                biOppMap.put(bi.id, bi.Blue_Sheet__r.Opportunity__c);
                biOppStagenameMap.put(bi.id, bi.Blue_Sheet__r.Opportunity__r.StageName);
            }

            for (Buying_Influence__c buy : buyingRecords) {
                Strategy_Engine__c strategy = new Strategy_Engine__c();
                strategy.Source_ID__c = buy.Id;
                strategy.Buying_Influence__c = buy.Id;
                strategy.Blue_Sheet__c = buy.Blue_Sheet__c;
                strategy.Buying_Influence_Name__c = buy.Name;
                strategy.Opportunity_Name__c = buy.Opportunity_Name__c;
                strategy.Blue_Sheet_Name__c = buy.Blue_Sheet_Name__c;
                strategy.Opportunity__c = biOppMap.get(buy.Id);
                strategy.Place_in_Sales_Funnel__c = biOppStagenameMap.get(buy.Id);

                if (buy.Rating_Evidence__c != null) {
                    strategy.Rating_Evidence__c = 'True';
                } else {
                    strategy.Rating_Evidence__c = 'False';
                }

                if (buy.Business_Results__c != null) {
                    strategy.Business_Results__c = 'True';
                } else {
                    strategy.Business_Results__c = 'False';
                }

                if (buy.Personal_Wins__c != null) {
                    strategy.Personal_Wins__c = 'True';
                } else {
                    strategy.Personal_Wins__c = 'False';
                }

                if (buy.Using_Budget_for_Something_Else__c) {
                    strategy.Competitive_Preference__c = 'Using Budget For Something Else';
                } else if (buy.Using_Internal_Resources__c) {
                    strategy.Competitive_Preference__c = 'Using Internal Resource';
                } else if (buy.Buying_from_Someone_Else__c) {
                    strategy.Competitive_Preference__c = 'Buying From Someone Else';
                } else if (buy.Doing_Nothing__c) {
                    strategy.Competitive_Preference__c = 'Doing Nothing';
                } else if (buy.Buying_From_Us__c) {
                    strategy.Competitive_Preference__c = 'Buying From Us';
                } else {
                    strategy.Competitive_Preference__c = '';
                }

                /* if(buy.Economic__c){
                  strategy.Buying_Influence_Role__c = 'Economic';
                  }
                 else if(buy.Technical__c){
                  strategy.Buying_Influence_Role__c = 'Technical';
                  }
                 else if(buy.User__c){
                  strategy.Buying_Influence_Role__c = 'User';
                  }
                 else if(buy.Coach__c){
                  strategy.Buying_Influence_Role__c = 'Coach';
                 }
                 else{
                   strategy.Buying_Influence_Role__c = '';
                 }*/

                List<String> biRole = new List<String>();
                if (buy.Economic__c) {
                    biRole.add('Economic');
                    //strategy.Buying_Influence_Role__c = 'Economic';
                }
                if (buy.Technical__c) {
                    biRole.add('Technical');
                    //strategy.Buying_Influence_Role__c = 'Technical';
                }
                if (buy.User__c) {
                    biRole.add('User');
                    //strategy.Buying_Influence_Role__c = 'User';
                }
                if (buy.Coach__c) {
                    biRole.add('Coach');
                    //strategy.Buying_Influence_Role__c = 'Coach';
                }
                if (
                    buy.User__c == false &&
                    buy.Coach__c == false &&
                    buy.Technical__c == false &&
                    buy.Economic__c == false
                ) {
                    biRole.add('');
                }
                strategy.Buying_Influence_Role__c = String.join(biRole, ',');

                if (buy.High__c) {
                    strategy.Degree_of_Influence__c = 'High';
                } else if (buy.Medium__c) {
                    strategy.Degree_of_Influence__c = 'Medium';
                } else if (buy.Low__c) {
                    strategy.Degree_of_Influence__c = 'Low';
                } else {
                    strategy.Degree_of_Influence__c = '';
                }

                if (
                    buy.Rating__c == '+1' ||
                    buy.Rating__c == '+2' ||
                    buy.Rating__c == '+3' ||
                    buy.Rating__c == '+4' ||
                    buy.Rating__c == '+5'
                ) {
                    strategy.Rating__c = 'Positive';
                } else {
                    strategy.Rating__c = 'Negative';
                }

                if (buy.Over_Confident__c) {
                    strategy.Buying_Mode__c = 'Over Confident';
                } else if (buy.Growth__c) {
                    strategy.Buying_Mode__c = 'Growth';
                } else if (buy.Trouble__c) {
                    strategy.Buying_Mode__c = 'Trouble';
                } else if (buy.Even_Keel__c) {
                    strategy.Buying_Mode__c = 'Even Keel';
                } else {
                    strategy.Buying_Mode__c = '';
                }

                updateStrategyEngine.add(strategy);
            }
            DataFactory.create(updateStrategyEngine);
        }
    }
    public static void DeleteBuyingInfluence(List<Buying_Influence__c> deleteBuyingRecords) {
        List<Id> buyingIdsDelete = new List<Id>();
        for (Buying_Influence__c delComps : deleteBuyingRecords) {
            buyingIdsDelete.add(delComps.Id);
        }
        String query =
            'SELECT Id,Source_ID__c,Customer_Stated_Objective__c ' +
            'FROM Strategy_Engine__c' +
            ' WHERE Source_ID__c IN:buyingIdsDelete';

        Map<String, Object> params = new Map<String, Object>();
        params.put('buyingIdsDelete', buyingIdsDelete);
        List<Strategy_Engine__c> strategyEngineRecords = DataFactory.read(query, params);
        DataFactory.remove(strategyEngineRecords);
    }

    public static void actionPlanUpdate(List<Action_Plan__c> actionRecords) {
        List<String> actionBlueSheetIds = new List<String>();
        for (Action_Plan__c action : actionRecords) {
            actionBlueSheetIds.add(action.Blue_Sheet__c);
        }

        String query =
            'SELECT Id,Source_ID__c,Customer_Stated_Objective__c ' +
            'FROM Strategy_Engine__c' +
            ' WHERE Source_ID__c IN:actionBlueSheetIds';

        Map<String, Object> params = new Map<String, Object>();
        params.put('actionBlueSheetIds', actionBlueSheetIds);
        List<Strategy_Engine__c> strategyEngineRecords = DataFactory.read(query, params);

        Map<String, Strategy_Engine__c> SERecordsCreate = new Map<String, Strategy_Engine__c>();

        for (Strategy_Engine__c SE : strategyEngineRecords) {
            SERecordsCreate.put(SE.Source_ID__c, SE);
        }

        String blueSheetNewQuery = 'Select Id,Name,LastModifiedDate,Count_Actions__c FROM Blue_Sheet__c WHERE Id =:actionBlueSheetIds';
        Map<String, Object> blueSheetNewparamters = new Map<String, Object>();
        blueSheetNewparamters.put('actionBlueSheetIds', actionBlueSheetIds);
        List<Blue_Sheet__c> bluesheetList = DataFactory.read(blueSheetNewQuery, blueSheetNewparamters);
        List<Strategy_Engine__c> updateStrategyEngine = new List<Strategy_Engine__c>();
        for (Blue_Sheet__c action : bluesheetList) {
            if (SERecordsCreate.containsKey(action.Id)) {
                SERecordsCreate.get(action.Id).Bluesheet_Count_Actions__c = action.Count_Actions__c + 1;
                updateStrategyEngine.add(SERecordsCreate.get(action.Id));
            }
        }
        DataFactory.modify(updateStrategyEngine);
    }
    public static void deleteActionPlan(List<Action_Plan__c> actionRecords) {
        List<String> actionBlueSheetIds = new List<String>();
        for (Action_Plan__c action : actionRecords) {
            actionBlueSheetIds.add(action.Blue_Sheet__c);
        }

        String query =
            'SELECT Id,Source_ID__c,Customer_Stated_Objective__c ' +
            'FROM Strategy_Engine__c' +
            ' WHERE Source_ID__c IN:actionBlueSheetIds';

        Map<String, Object> params = new Map<String, Object>();
        params.put('actionBlueSheetIds', actionBlueSheetIds);
        List<Strategy_Engine__c> strategyEngineRecords = DataFactory.read(query, params);

        Map<String, Strategy_Engine__c> SERecordsCreate = new Map<String, Strategy_Engine__c>();

        for (Strategy_Engine__c SE : strategyEngineRecords) {
            SERecordsCreate.put(SE.Source_ID__c, SE);
        }

        String blueSheetNewQuery = 'Select Id,Name,LastModifiedDate,Count_Actions__c FROM Blue_Sheet__c WHERE Id =:actionBlueSheetIds';
        Map<String, Object> blueSheetNewparamters = new Map<String, Object>();
        blueSheetNewparamters.put('actionBlueSheetIds', actionBlueSheetIds);
        List<Blue_Sheet__c> bluesheetList = DataFactory.read(blueSheetNewQuery, blueSheetNewparamters);
        List<Strategy_Engine__c> updateStrategyEngine = new List<Strategy_Engine__c>();
        for (Blue_Sheet__c action : bluesheetList) {
            if (SERecordsCreate.containsKey(action.Id)) {
                SERecordsCreate.get(action.Id).Bluesheet_Count_Actions__c = action.Count_Actions__c - 1;
                updateStrategyEngine.add(SERecordsCreate.get(action.Id));
            }
        }
        DataFactory.modify(updateStrategyEngine);
    }

    public static void updateScoreCardInSEInsertDelete(List<Score_Card__c> scoreCardLst, String actionType) {
        Set<String> bsIdsSet = new Set<String>();
        for (Score_Card__c scObj : scoreCardLst) {
            bsIdsSet.add(scObj.Blue_Sheet__c);
        }

        String scoreCardSpql = 'Select Id,Score_Card__c,Blue_Sheet__c from Strategy_Engine__c where Is_Master__c=true AND Blue_Sheet__c =:bsIdsSet';
        List<Strategy_Engine__c> seListUpdate = new List<Strategy_Engine__c>();
        Map<String, Object> soqlParamMap = new Map<String, Object>();
        soqlParamMap.put('bsIdsSet', bsIdsSet);
        List<Strategy_Engine__c> seList = DataFactory.read(scoreCardSpql, soqlParamMap);
        Map<String, Strategy_Engine__c> mapscIdSEObj = new Map<String, Strategy_Engine__c>();
        for (Strategy_Engine__c seObj : seList) {
            mapscIdSEObj.put(seObj.Blue_Sheet__c, seObj);
        }
        for (Score_Card__c scObj : scoreCardLst) {
            Strategy_Engine__c seObjUpdate = mapscIdSEObj.get(scObj.Blue_Sheet__c);
            if (seObjUpdate != null) {
                if (actionType == 'Insert' || actionType == 'Update') {
                    seObjUpdate.Score_Card__c = scObj.Id;
                } else if (actionType == 'Delete') {
                    seObjUpdate.Score_Card__c = null;
                }

                seListUpdate.add(seObjUpdate);
            }
        }

        if (!seListUpdate.isEmpty()) {
            DataFactory.modify(seListUpdate);
        }
    }

    /*  public static void deleteRecommendationRecBeforeForBI(Map<Id, Buying_Influence__c> biRecMaps) {
        Set<Id> biIdsSet = new Set<Id>();
        biIdsSet = biRecMaps.keySet();
        String recommSoql = 'Select Id,Blue_Sheet__c from Recommendations__c Where Buying_Influence__c =:biIdsSet';

        Map<String, Object> soqlParamMap = new Map<String, Object>();
        soqlParamMap.put('biIdsSet', biIdsSet);
        StrategyEngine.recommDeleteListBI = DataFactory.read(recommSoql, soqlParamMap);
    }
*/
    public static void deleteRecommendationRecAfterForBI(Map<Id, Buying_Influence__c> biRecMaps) {
        Set<String> bsIdsSetStr = new Set<String>();
        for (Buying_Influence__c tmpBI : biRecMaps.values()) {
            bsIdsSetStr.add(tmpBI.Blue_Sheet__c);
        }
        List<Recommendations__c> recommToDelete = new List<Recommendations__c>();
        Map<String, Blue_Sheet__c> mapBsIdAndRecord = ApexCommonUtil.getBSAndChildRecs(bsIdsSetStr);
        for (Buying_Influence__c tmpBI : biRecMaps.values()) {
            Blue_Sheet__c bsObj = mapBsIdAndRecord.get(tmpBI.Blue_Sheet__c);
            List<Buying_Influence__c> biLst = bsObj.Buying_Influences__r;
            if (biLst == null || (biLst != null && biLst.isEmpty())) {
                List<Recommendations__c> recommLst = bsObj.Recommendations__r;
                for (Recommendations__c recommObj : recommLst) {
                    if (recommObj.BestActionLogic__c == 'BAL_12') {
                        recommToDelete.add(recommObj);
                    }
                }
            }
        }

        if (!recommToDelete.isEmpty()) {
            DataFactory.remove(recommToDelete);
        }
    }

    public static void deleteRecommendationRecBeforeForCompetition(Map<Id, Competition__c> competitionRecMaps) {
        Set<Id> compIdsSet = new Set<Id>();
        compIdsSet = competitionRecMaps.keySet();
        String compSoql = 'Select Id from Recommendations__c Where Competition__c =:compIdsSet';

        Map<String, Object> soqlParamMap = new Map<String, Object>();
        soqlParamMap.put('compIdsSet', compIdsSet);
        StrategyEngine.competitionDeleteList = DataFactory.read(compSoql, soqlParamMap);
    }

    public static void deleteRecommendationRecAfterForCompetition() {
        List<Recommendations__c> recommToDelete = StrategyEngine.competitionDeleteList;
        if (!recommToDelete.isEmpty()) {
            DataFactory.remove(recommToDelete);
        }
    }

    public static void deleteRecommendationRecBeforeForActionPlan(Map<Id, Action_Plan__c> actionPlanRecMaps) {
        Set<Id> actionPlandsSet = new Set<Id>();
        actionPlandsSet = actionPlanRecMaps.keySet();
        String apSoql = 'Select Id from Recommendations__c Where Action_Plan__c =:actionPlandsSet';

        Map<String, Object> soqlParamMap = new Map<String, Object>();
        soqlParamMap.put('actionPlandsSet', actionPlandsSet);
        StrategyEngine.actionPlanDeleteList = DataFactory.read(apSoql, soqlParamMap);
    }

    public static void deleteRecommendationRecAfterForActionPlan() {
        List<Recommendations__c> recommToDelete = StrategyEngine.actionPlanDeleteList;
        if (!recommToDelete.isEmpty()) {
            DataFactory.remove(recommToDelete);
        }
    }
    @SuppressWarnings('PMD.CognitiveComplexity')
    public static void updateStrategyEngine(List<Opportunity> oppNewLst, Map<Id, Opportunity> oppOldMap) {
        if (Schema.sObjectType.Blue_Sheet__c.fields.Action_Plan_Progress__c.isUpdateable()) {
            List<Opportunity> oppChangedLst = getOppChanged(oppNewLst, oppOldMap);
            Set<String> oppIdSet = ApexCommonUtil.getSetOfIdFromList(oppChangedLst);

            Map<String, Strategy_Engine__c> mapOppIdSEObj = getStrategyEngineRec(oppIdSet);
            List<Strategy_Engine__c> seLstUpdate = new List<Strategy_Engine__c>();
            for (Opportunity oppChanged : oppChangedLst) {
                Opportunity oppOld = oppOldMap.get(oppChanged.Id);
                Strategy_Engine__c se = mapOppIdSEObj.get(oppChanged.Id);
                if (se != null) {
                    if (oppChanged.Name != oppOld.Name || oppChanged.CloseDate != oppOld.closeDate) {
                        se.Opportunity_Name__c = oppChanged.Name;
                        se.Opty_Close_Date__c = oppChanged.CloseDate;
                    }
                    if (oppChanged.StageName != oppOld.StageName) {
                        se.Opty_Stage_Last_Modified_Date__c = Datetime.now();
                        se.Place_in_Sales_Funnel__c = oppChanged.StageName;
                    }
                    seLstUpdate.add(se);
                }
            }
            if (!seLstUpdate.isEmpty()) {
                List<Strategy_Engine__c> seUpdateLstFinal = removeDupesSE(seLstUpdate);
                DataFactory.modify(seUpdateLstFinal);
            }
        }
    }

    private static List<Strategy_Engine__c> removeDupesSE(List<Strategy_Engine__c> seLst) {
        List<Strategy_Engine__c> seLstToUpdate = new List<Strategy_Engine__c>();
        Map<String, Strategy_Engine__c> mapSE = new Map<String, Strategy_Engine__c>();
        for (Strategy_Engine__c se : seLst) {
            if (!mapSE.containsKey(se.Id)) {
                mapSE.put(se.Id, se);
            }
        }
        return mapSE.values();
    }

    private static Map<String, Strategy_Engine__c> getStrategyEngineRec(Set<String> oppIdSet) {
        String seSoql = 'Select Id, Opportunity_Name__c, Opty_Close_Date__c, Opportunity__c, Opty_Stage_Last_Modified_Date__c,Place_in_Sales_Funnel__c from Strategy_Engine__c where Is_Master__c = true AND Opportunity__c =: oppIdSet';
        List<Strategy_Engine__c> seListUpdate = new List<Strategy_Engine__c>();
        Map<String, Object> soqlParamMap = new Map<String, Object>();
        soqlParamMap.put('oppIdSet', oppIdSet);
        List<Strategy_Engine__c> seList = DataFactory.read(seSoql, soqlParamMap);
        Map<String, Strategy_Engine__c> mapOppIdSEObj = new Map<String, Strategy_Engine__c>();
        for (Strategy_Engine__c seObj : seList) {
            mapOppIdSEObj.put(seObj.Opportunity__c, seObj);
        }
        return mapOppIdSEObj;
    }

    private static List<Opportunity> getOppChanged(List<Opportunity> oppNewLst, Map<Id, Opportunity> oppOldMap) {
        List<Opportunity> oppChangedList = new List<Opportunity>();
        for (Opportunity opp : oppNewLst) {
            Opportunity oppOld = oppOldMap.get(opp.Id);

            if (opp.Name != oppOld.Name || opp.CloseDate != oppOld.closeDate || opp.StageName != oppOld.StageName) {
                oppChangedList.add(opp);
            }
        }
        return oppChangedList;
    }
}