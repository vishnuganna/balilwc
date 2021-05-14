/* Apex class for Strategy Engine functionality build. To map source object fields to strategy engine fields
 and populate business criteria and points */

public with sharing class SEFieldsPopulation {
    /*   @InvocableMethod
     public static void seFieldsPopulation(List<Id> objectIds) {
        Map<String, List<String>> seCMDTMap = new Map<String, List<String>>();
        List<StrategyEngine__mdt> seCMDT = new List<StrategyEngine__mdt>();
        //List<StrategyEngineFields__mdt> sefCMDT = new List<StrategyEngineFields__mdt>();
        List<String> allSEFieldsForQuery = new List<String>();
        List<String> fieldsForQuery = new List<String>();
        List<Business_Rules__c> brRules = new List<Business_Rules__c>();
        Map<String,List<String>> brMap = new Map<String,List<String>>();
        List<Strategy_Engine__c> seLastList = new List<Strategy_Engine__c>();
        List<Strategy_Engine__c> seMapList = new List<Strategy_Engine__c>();
        List<Strategy_Engine__c> sEngList = new List<Strategy_Engine__c>();
        List<Strategy_Engine__c> seList =  new List<Strategy_Engine__c>();
        List<Opportunity> oppList = new List<Opportunity>();
        List<Blue_Sheet__c> bsList = new List<Blue_Sheet__c>();
        String qry = '';
        Map<String, Id> cpcreateMap = new Map<String, Id>();
        Map<String, Id> cpupdateMap = new Map<String, Id>();
        Map<String, Id> ssocreateMap = new Map<String, Id>();
        Map<String, Id> ssoupdateMap = new Map<String, Id>();
               
        String objectApiName = UtilityMethods.objectName(objectIds);
        
        seCMDT = [select ObjectName__c, FieldNames__c, SourceFieldName__c, TargetFieldName__c, BR_FieldName__c from StrategyEngine__mdt where ObjectName__c = :objectApiName];        
        for(StrategyEngine__mdt cmd:seCMDT){
            fieldsForQuery.add(cmd.FieldNames__c);
        }
        
        //for cloning of all fields of SE as +ve/-ve fields can't be captured in seCMDT
      
        Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map <String, Schema.SObjectField> fieldMap = schemaMap.get('Strategy_Engine__c').getDescribe().fields.getMap();
        for(Schema.SObjectField sfield : fieldMap.Values())
        {
            schema.describefieldresult dfield = sfield.getDescribe();
            allSEFieldsForQuery.add(dfield.getname());
        }
        
        
        brRules = [Select id, Field_Name__c, Criteria__c, Points__c from Business_Rules__c];        
        for(Business_Rules__c br:brRules){
            List<String> brRow = new List<String>();
            brRow.add(br.Criteria__c);
            brRow.add(String.valueOf(br.Points__c));
            brMap.put(br.Field_Name__c, brRow);            
        }
        
        
        //Opportunity changes update in all SE
        if(objectApiName == 'Opportunity'){
            Map<String, String> oppbsMap = new Map<String, String>();
            oppList = [Select id, name from Opportunity where Id in:objectIds];
                                    
            //to find SE related to a particular opp, we need names of opp and BS
            bsList = [Select id, name, opportunity__c, opportunity__r.name from Blue_Sheet__c where opportunity__c in :objectIds];
            List<String> bsNames = new List<String>();
            for(Blue_Sheet__c bs:bsList){
                bsNames.add(bs.name);
                oppbsMap.put(bs.name, bs.opportunity__r.name);
            }
            
            //find all SE related to bsnames
            sEngList = [Select id, Opportunity_Name__c, Blue_Sheet_Name__c, Criteria__c, Points__c, Object_API_Name__c from Strategy_Engine__c where Blue_Sheet_Name__c in :bsNames];
            for(Strategy_Engine__c s:sEngList){
                String opName = oppbsMap.get(s.Blue_Sheet_Name__c);
                Opportunity opty = [Select id, name, AccountId, stagename, amount, closedate from Opportunity where name = :opName];
                s.Opportunity_Name__c = opty.name;
                s.Place_in_Sales_Funnel__c = opty.stagename;
                s.SSO_Close_Date__c = opty.closedate;                
                s.Opportunity_Amount__c = opty.amount;

                if(brMap.containsKey('SSO Close Date') && (Date)opty.CloseDate != null){
                    //system.debug('##'+mt.BR_FieldName__c+'  '+brMap.containsKey(mt.BR_FieldName__c));
                    //if(s.Criteria__c==null && s.Points__c==null){
                    if(s.Object_API_Name__c==objectApiName){
                        s.put('Criteria__c', brMap.get('SSO Close Date')[0]);
                        s.put('Points__c', Integer.valueOf((brMap.get('SSO Close Date')[1])));
                    }
                }
                if(brMap.containsKey('Place in Sales Funnel') && (String)opty.stagename != null){
                    //system.debug('##'+mt.BR_FieldName__c+'  '+brMap.containsKey(mt.BR_FieldName__c));
                    if(s.Object_API_Name__c==objectApiName){
                        s.put('Criteria__c', brMap.get('Place in Sales Funnel')[0]);
                        s.put('Points__c', Integer.valueOf((brMap.get('Place in Sales Funnel')[1])));
                    }
                } 
                seList.add(s);
            }            
        }
        
        
        //Account changes update in all SE
        else if(objectApiName == 'Account'){
            oppList = [Select id, name, AccountId, Account.name from Opportunity where AccountId in :objectIds];
            
            Map<Id, String> opAcMap = new Map<Id, String>();
            //List<ID> oppIds = new List<ID>();
            for(Opportunity o:oppList){
                //oppIds.add(o.Id);
                opAcMap.put(o.id, o.Account.name);
            }

            bsList = [Select id, name, opportunity__c from Blue_Sheet__c where opportunity__c in :opAcMap.keyset()];
            Map<String, String> bsAcMap = new Map<String, String>();
            List<String> bsNames = new List<String>();
            for(Blue_Sheet__c bs:bsList){
                bsNames.add(bs.name);
                bsAcMap.put(bs.name, opAcMap.get(bs.opportunity__c));
            }
            
            //find all SE related to oppnames
            sEngList = [Select id, Account_Name__c, Blue_Sheet_Name__c from Strategy_Engine__c where Blue_Sheet_Name__c in :bsNames];
            for(Strategy_Engine__c s:sEngList){
                String acName = bsAcMap.get(s.Blue_Sheet_Name__c);
                Account acnt = [Select id, name from Account where name = :acName];
                s.Account_Name__c = acnt.name; 
                //Contact c = [Select id, name, AccountId, level__c from Contact where level__c = 'Primary' and AccountId = :opty.AccountId];   
                //s.Contact_Name__c = c.name;
                seList.add(s);
            }   
        }
        
        //Contact changes update in all SE
        else if(objectApiName == 'Contact'){
            List<Contact> conList = [Select id, name, AccountId, level__c, Account.name from Contact where level__c = 'Primary' and Id in :objectIds];
            List<Id> acIds = new List<Id>();
            Map<String, String> acConMap = new Map<String, String>();
            for(Contact c:conList){
                acIds.add(c.AccountId);
                acConMap.put(c.Account.name, c.name);    //Ac name & con name
            }
            
            oppList = [Select id, name, AccountId, Account.name from Opportunity where AccountId in :acIds];
            
            Map<Id, String> opConMap = new Map<Id, String>();
            //List<ID> oppIds = new List<ID>();
            for(Opportunity o:oppList){
                //oppIds.add(o.Id);
                opConMap.put(o.id, acConMap.get(o.Account.name));    //opp is & con name
            }

            bsList = [Select id, name, opportunity__c from Blue_Sheet__c where opportunity__c in:opConMap.keyset()];
            Map<String, String> bsConMap = new Map<String, String>();
            List<String> bsNames = new List<String>();
            for(Blue_Sheet__c bs:bsList){
                bsNames.add(bs.name);
                bsConMap.put(bs.name, opConMap.get(bs.opportunity__c));    //bs name & con name
            }
            
            //find all SE related to oppnames
            sEngList = [Select id, Contact_Name__c, Blue_Sheet_Name__c from Strategy_Engine__c where Blue_Sheet_Name__c in :bsNames];
            for(Strategy_Engine__c s:sEngList){
                String conName = bsConMap.get(s.Blue_Sheet_Name__c);
                Contact cont = [Select id, name from Contact where name = :conName];
                s.Contact_Name__c = cont.name; 
                seList.add(s);
            }
        }
        
        //Contact SE create
        else if(objectApiName == 'Blue_Sheet__c'){
            List<String> blsNames = new List<String>();
            List<Blue_Sheet__c> testList = [Select id, name from Blue_Sheet__c where id in :objectIds];
            for(Blue_Sheet__c bs:testList){
                blsNames.add(bs.name);
            }
            seMapList = [Select id, Blue_Sheet_Name__c, Source_ID__c, Object_API_Name__c, Account_Name__c, Opportunity_Name__c, Opportunity_Amount__c, SSO_Close_Date__c, Place_in_Sales_Funnel__c, Is_Last__c, Criteria__c, Points__c from Strategy_Engine__c where Is_Last__c = True and Object_API_Name__c = 'Account' and Blue_Sheet_Name__c in :blsNames];
            
            bsList = [Select id, name, opportunity__c from Blue_Sheet__c where id in :objectIds];
            Map<String, String> bsOppMap = new Map<String, String>();
            for(Blue_Sheet__c bs:bsList){
                bsOppMap.put(bs.name, bs.opportunity__c);    //bs name & opp name
            }
            
            oppList = [Select id, name, AccountId from Opportunity where Id in:bsOppMap.values()];
            Map<Id, Id> OppAcMap = new Map<Id, Id>();
            for(Opportunity op:oppList){
                OppAcMap.put(op.id, op.AccountId);    //opp id & ac name
            }
            
            List<Contact> conList = [Select id, name, AccountId, level__c from Contact where level__c = 'Primary' and AccountId in:OppAcMap.values()];
            Map<Id, String> conAcMap = new Map<Id, String>();
            Map<Id, Id> conAcIdMap = new Map<Id, Id>();
            if(conList.size()>0){
                for(Contact co:conList){
                    conAcMap.put(co.AccountId, co.name);    //ac id & con name
                    conAcIdMap.put(co.AccountId, co.id);
                }
                
                Map<String, String> bsConMap = new Map<String, String>();
                Map<String, Id> bsConIdMap = new Map<String, Id>();
                for(String bsn:bsOppMap.keyset()){
                    bsConMap.put(bsn, conAcMap.get(OppAcMap.get(bsOppMap.get(bsn))));
                    bsConIdMap.put(bsn, conAcIdMap.get(OppAcMap.get(bsOppMap.get(bsn))));
                }
                
                for(Strategy_Engine__c se:seMapList){
                    Strategy_Engine__c contactSE = new Strategy_Engine__c();
                    contactSE = se.clone(false, false, false, false);
                    String conName = bsConMap.get(se.Blue_Sheet_Name__c);
                    contactSE.Contact_Name__c = conName;
                    contactSE.Object_API_Name__c = 'Contact';
                    contactSE.Is_Last__c = true;
                    contactSE.Criteria__c=''; 
                    contactSE.Points__c=null;
                    contactSE.Source_ID__c = bsConIdMap.get(se.Blue_Sheet_Name__c);
                    seList.add(contactSE);
                    se.Is_Last__c = false;
                    seLastList.add(se);
                }
            }
            update seLastList;
        }
        
        //Single Sales Objective    
        else if(objectApiName == 'Single_Sales_Objective__c'){
                List<Single_Sales_Objective__c> ssoList = new List<Single_Sales_Objective__c>();
                qry = 'Select Id, Blue_Sheet__r.Name, '+String.join(fieldsForQuery,',')+' from '+objectApiName+' where Id in :objectIds';
                ssoList = Database.query(qry);
                
                //fetch records for both (either related to current object or is_last checked object) from SE
                //seMapList = [Select id, Blue_Sheet_Name__c, Source_ID__c, Object_API_Name__c, Is_Last__c from Strategy_Engine__c where Is_Last__c = True or Object_API_Name__c = :objectAPIname];
                
                seMapList = [Select id, Blue_Sheet_Name__c, Source_ID__c, Object_API_Name__c, Is_Last__c from Strategy_Engine__c where Is_Last__c = True];
                
                Map<String, Id> seBSMap = new Map<String, Id>();        //map of BS name and and se id of SE last checked records 
                for(Strategy_Engine__c s:seMapList){
                    seBSMap.put(s.Blue_Sheet_Name__c, s.id);
                }
                                                
                Map<String, Id> seMap = SEFieldsPopulation.seMap();    //map of all SE records source id and se id


                
                for(Single_Sales_Objective__c cps:ssoList){
                    if(seMap.containsKey(cps.id)){
                        ssoupdateMap.put(cps.Blue_Sheet__r.Name, seMap.get(cps.id));
                    }else{
                        //find BS related to this cps, in SE find last record related to this BS and send it in createmap
                        Strategy_Engine__c temp = new Strategy_Engine__c(id = seBSMap.get(cps.Blue_Sheet__r.Name));
                        ssocreateMap.put(cps.Blue_Sheet__r.Name,seBSMap.get(cps.Blue_Sheet__r.Name));
                        temp.Is_Last__c = false;
                        seLastList.add(temp);
                    }
                }
                
                
                update seLastList;
                      
                for(Single_Sales_Objective__c sso:ssoList){    
                    Strategy_Engine__c se = new Strategy_Engine__c();    
                    if(ssocreateMap.containskey(sso.Blue_Sheet__r.Name)){                        
                        Id seid = ssocreateMap.get(sso.Blue_Sheet__r.Name);
                        qry = 'Select '+String.join(allSEFieldsForQuery,',')+' from Strategy_Engine__c where Id  = :seid';
                        Strategy_Engine__c str = Database.query(qry);
                        se = str.clone(false, false, false, false);
                        se.Criteria__c='';
                        se.Points__c=null;
                        se.Is_Last__c = true;
                    }else{
                        se.put('id',ssoupdateMap.get(sso.Blue_Sheet__r.Name));
                    }        
                    //Strategy_Engine__c se = new Strategy_Engine__c(id = ssoupdateMap.get(sso.Blue_Sheet__r.Name));
                    se.Blue_Sheet_Name__c = sso.Blue_Sheet__r.Name;
                    for(StrategyEngine__mdt mt:seCMDT){
                        if(mt.SourceFieldName__c == 'Customer_Timing_for_Priorities__c'){
                            String priority = (String)sso.get(mt.SourceFieldName__c);   
                            if(priority == 'Active' || priority == 'Urgent'){                                
                                se.put('Customer_Timing_for_Priorities_Positive__c', priority);
                                se.put('Customer_Timing_for_Priorities_Negative__c', '');
                                if(brMap.containsKey(mt.BR_FieldName__c)){
                                    se.put('Criteria__c', brMap.get(mt.BR_FieldName__c)[0]);
                                    se.put('Points__c', Integer.valueOf((brMap.get(mt.BR_FieldName__c)[1])));
                                } 
                            } 
                            else if(priority == 'Later' || priority == 'Work it in'){
                                se.put('Customer_Timing_for_Priorities_Negative__c', priority);
                                se.put('Customer_Timing_for_Priorities_Positive__c', '');
                                if(brMap.containsKey('Customer Timing for Priorities- Negative')){
                                    se.put('Criteria__c', brMap.get('Customer Timing for Priorities- Negative')[0]);
                                    se.put('Points__c', Integer.valueOf((brMap.get('Customer Timing for Priorities- Negative')[1])));
                                } 
                            }   
                                    
                        }
                        else{
                            se.put(mt.TargetFieldName__c,(String)sso.get(mt.SourceFieldName__c)); 
                            if(brMap.containsKey(mt.BR_FieldName__c)){
                                se.put('Criteria__c', brMap.get(mt.BR_FieldName__c)[0]);
                                se.put('Points__c', Integer.valueOf((brMap.get(mt.BR_FieldName__c)[1])));
                            }                             
                        }  
                                          
                    }
                    //se.Is_Last__c = true;
                    se.Object_API_Name__c = objectAPIName;
                    se.Source_ID__c = sso.id;
                    seList.add(se);
                }               
                
            }
            
            //Current Position
            else if(objectApiName == 'Current_Position__c'){
                List<Current_Position__c> cpList = new List<Current_Position__c>();
                qry = 'Select Id, Blue_Sheet__r.Name, '+String.join(fieldsForQuery,',')+' from '+objectApiName+' where Id in :objectIds';
                cpList = Database.query(qry);
                
                //fetch records for both (either related to current object or is_last checked object) from SE
                //seMapList = [Select id, Blue_Sheet_Name__c, Source_ID__c, Object_API_Name__c, Is_Last__c from Strategy_Engine__c where Is_Last__c = True or Object_API_Name__c = :objectAPIname];
                
                seMapList = [Select id, Blue_Sheet_Name__c, Source_ID__c, Object_API_Name__c, Is_Last__c from Strategy_Engine__c where Is_Last__c = True];
                
                Map<String, Id> seBSMap = new Map<String, Id>();        //map of BS name and and se id of SE last checked records 
                for(Strategy_Engine__c s:seMapList){
                    seBSMap.put(s.Blue_Sheet_Name__c, s.id);
                }
                
                Map<String, Id> seMap = SEFieldsPopulation.seMap();    //map of all SE records source id and se id
                
                for(Current_Position__c cps:cpList){
                    if(seMap.containsKey(cps.id)){
                        cpupdateMap.put(cps.Blue_Sheet__r.Name, seMap.get(cps.id));
                    }else{
                        //find BS related to this cps, in SE find last record related to this BS and send it in createmap
                        Strategy_Engine__c temp = new Strategy_Engine__c(id = seBSMap.get(cps.Blue_Sheet__r.Name));
                        cpcreateMap.put(cps.Blue_Sheet__r.Name,seBSMap.get(cps.Blue_Sheet__r.Name));
                        temp.Is_Last__c = false;
                        seLastList.add(temp);
                    }
                }
                                
                update seLastList;
                      
                for(Current_Position__c cps:cpList){    
                    Strategy_Engine__c se = new Strategy_Engine__c();    
                    if(cpcreateMap.containskey(cps.Blue_Sheet__r.Name)){                        
                        Id seid = cpcreateMap.get(cps.Blue_Sheet__r.Name);
                        qry = 'Select '+String.join(allSEFieldsForQuery,',')+' from Strategy_Engine__c where Id  = :seid';
                        Strategy_Engine__c str = Database.query(qry);
                        se = str.clone(false, false, false, false);
                        se.Criteria__c='';
                        se.Points__c=null;
                        se.Is_Last__c = true;
                    }else{
                        se.put('id',cpupdateMap.get(cps.Blue_Sheet__r.Name));
                    }        
                    //Strategy_Engine__c se = new Strategy_Engine__c(id = cpupdateMap.get(cps.Blue_Sheet__r.Name));
                    se.Blue_Sheet_Name__c = cps.Blue_Sheet__r.Name;
                    for(StrategyEngine__mdt mt:seCMDT){
                        if(mt.SourceFieldName__c == 'Current_Position__c' && (String)cps.get(mt.SourceFieldName__c) != null){
                            String position = (String)cps.get(mt.SourceFieldName__c);   
                            if(position == 'Euphoria' || position == 'Great' || position == 'Comfort' || position == 'Secure' || position == 'Ok'){                                
                                se.put('Position_is_Positive__c', position);
                                se.put('Position_is_Negative__c', '');
                                if(brMap.containsKey(mt.BR_FieldName__c)){
                                    se.put('Criteria__c', brMap.get(mt.BR_FieldName__c)[0]);
                                    se.put('Points__c', Integer.valueOf((brMap.get(mt.BR_FieldName__c)[1])));
                                }
                            } 
                            else if(position == 'Discomfort' || position == 'Fear' || position == 'Worry' || position == 'Panic' || position == 'Concern'){
                                se.put('Position_is_Negative__c', position);
                                se.put('Position_is_Positive__c', '');
                                if(brMap.containsKey('Position is Negative')){
                                    se.put('Criteria__c', brMap.get('Position is Negative')[0]);
                                    se.put('Points__c', Integer.valueOf((brMap.get('Position is Negative')[1])));
                                }
                            }                           
                        }
                        else{
                            se.put(mt.TargetFieldName__c,(String)cps.get(mt.SourceFieldName__c));  
                        }                                             
                    }
                    //se.Is_Last__c = true;
                    se.Object_API_Name__c = objectAPIName;
                    se.Source_ID__c = cps.id;
                    seList.add(se);
                }                         
                
                
           
            }
            
            //Buying Influence
            else if(objectApiName == 'Buying_Influence__c'){
                List<Buying_Influence__c> biList = new List<Buying_Influence__c>();
                qry = 'Select Id, Blue_Sheet__r.Name, '+String.join(fieldsForQuery,',')+' from '+objectApiName+' where Id in :objectIds';
                biList = Database.query(qry);
                
                //fetch records for both (either related to current object or is_last checked object) from SE
                //seMapList = [Select id, Blue_Sheet_Name__c, Source_ID__c, Object_API_Name__c, Is_Last__c from Strategy_Engine__c where Is_Last__c = True or Object_API_Name__c = :objectAPIname];
                
                seMapList = [Select id, Blue_Sheet_Name__c, Source_ID__c, Object_API_Name__c, Is_Last__c from Strategy_Engine__c where Is_Last__c = True];
                
                Map<String, Id> seBSMap = new Map<String, Id>();        //map of BS name and and se id of SE last checked records 
                for(Strategy_Engine__c s:seMapList){
                    seBSMap.put(s.Blue_Sheet_Name__c, s.id);
                }
                
                Map<String, Id> bicreateMap = new Map<String, Id>();
                Map<String, Id> biupdateMap = new Map<String, Id>();
                
                Map<String, Id> seMap = SEFieldsPopulation.seMap();    //map of all SE records source id and se id

             
                for(Buying_Influence__c bi:biList){
                    if(seMap.containsKey(bi.id)){
                        biupdateMap.put(bi.Blue_Sheet__r.Name, seMap.get(bi.id));
                    }else{
                        //find BS related to this bi, in SE find last record related to this BS and send it in createmap
                        Strategy_Engine__c temp = new Strategy_Engine__c(id = seBSMap.get(bi.Blue_Sheet__r.Name));
                        bicreateMap.put(bi.Blue_Sheet__r.Name,seBSMap.get(bi.Blue_Sheet__r.Name));
                        temp.Is_Last__c = false;
                        seLastList.add(temp);
                    }
                }
                                
                update seLastList;
                      
                for(Buying_Influence__c bin:biList){    
                    Strategy_Engine__c se = new Strategy_Engine__c();    
                    if(bicreateMap.containskey(bin.Blue_Sheet__r.Name)){                        
                        Id seid = bicreateMap.get(bin.Blue_Sheet__r.Name);
                        qry = 'Select '+String.join(allSEFieldsForQuery,',')+' from Strategy_Engine__c where Id  = :seid';
                        Strategy_Engine__c str = Database.query(qry);
                        se = str.clone(false, false, false, false);
                        se.Criteria__c='';
                        se.Points__c=null;
                        se.Is_Last__c = true;
                    }else{
                        se.put('id',biupdateMap.get(bin.Blue_Sheet__r.Name));
                    }        
                    //Strategy_Engine__c se = new Strategy_Engine__c(id = biupdateMap.get(bin.Blue_Sheet__r.Name));
                    se.Blue_Sheet_Name__c = bin.Blue_Sheet__r.Name;
                    for(StrategyEngine__mdt mt:seCMDT){
                        
                 
                        if(mt.SourceFieldName__c == 'Growth__c' || mt.SourceFieldName__c == 'Trouble__c' || mt.SourceFieldName__c == 'Even_Keel__c' || mt.SourceFieldName__c == 'Over_Confident__c'){
                            if((Boolean)bin.get('Growth__c') == True || (Boolean)bin.get('Trouble__c') == True || (Boolean)bin.get('Even_Keel__c') == True || (Boolean)bin.get('Over_Confident__c') == True){
                                se.put(mt.TargetFieldName__c,'True');
                            }
                            else if((Boolean)bin.get('Growth__c') == False && (Boolean)bin.get('Trouble__c') == False && (Boolean)bin.get('Even_Keel__c') == False && (Boolean)bin.get('Over_Confident__c') == False){
                                se.put(mt.TargetFieldName__c,'');
                            }
                        }else if(mt.SourceFieldName__c == 'High__c' || mt.SourceFieldName__c == 'Medium__c' || mt.SourceFieldName__c == 'Low__c'){
                            if((Boolean)bin.get('High__c') == True || (Boolean)bin.get('Medium__c') == True || (Boolean)bin.get('Low__c') == True){
                                se.put(mt.TargetFieldName__c,'True');
                            }
                            else if((Boolean)bin.get('High__c') == False && (Boolean)bin.get('Medium__c') == False && (Boolean)bin.get('Low__c') == False){
                                se.put(mt.TargetFieldName__c,'');
                            }
                        }else if(mt.SourceFieldName__c == 'User__c' || mt.SourceFieldName__c == 'Coach__c' || mt.SourceFieldName__c == 'Technical__c' || mt.SourceFieldName__c == 'Economic__c'){
                            if((Boolean)bin.get('User__c') == True || (Boolean)bin.get('Coach__c') == True || (Boolean)bin.get('Technical__c') == True || (Boolean)bin.get('Economic__c') == True){
                                se.put(mt.TargetFieldName__c,'True');
                            }
                            else if((Boolean)bin.get('User__c') == False && (Boolean)bin.get('Coach__c') == False && (Boolean)bin.get('Technical__c') == False && (Boolean)bin.get('Economic__c') == False){
                                se.put(mt.TargetFieldName__c,'');
                            }
                        }else if(mt.SourceFieldName__c == 'Using_Budget_For_Something_Else__c' || mt.SourceFieldName__c == 'Using_Internal_Resources__c' || mt.SourceFieldName__c == 'Buying_From_Someone_Else__c' || mt.SourceFieldName__c == 'Doing_Nothing__c' || mt.SourceFieldName__c == 'Buying_From_Us__c'){
                            if((Boolean)bin.get('Using_Budget_For_Something_Else__c') == True || (Boolean)bin.get('Using_Internal_Resources__c') == True || (Boolean)bin.get('Buying_From_Someone_Else__c') == True || (Boolean)bin.get('Doing_Nothing__c') == True || (Boolean)bin.get('Buying_From_Us__c') == True){
                                se.put(mt.TargetFieldName__c,'True');
                            }
                            else if((Boolean)bin.get('Using_Budget_For_Something_Else__c') == False && (Boolean)bin.get('Using_Internal_Resources__c') == False && (Boolean)bin.get('Buying_From_Someone_Else__c') == False && (Boolean)bin.get('Doing_Nothing__c') == False && (Boolean)bin.get('Buying_From_Us__c') == False){
                                se.put(mt.TargetFieldName__c,'');
                            }
                        }
                        else if(mt.SourceFieldName__c == 'Rating__c'){
                            String rate = (String)bin.get(mt.SourceFieldName__c);   
                            if(rate == '+2' || rate == '+3' || rate == '+4' || rate == '+5'){                                
                                se.put('Rating_Positive__c', rate);
                                se.put('Rating_Negative__c', '');
                                if(brMap.containsKey(mt.BR_FieldName__c)){
                                    se.put('Criteria__c', brMap.get(mt.BR_FieldName__c)[0]);
                                    se.put('Points__c', Integer.valueOf((brMap.get(mt.BR_FieldName__c)[1])));
                                }  
                            } 
                            else if(rate == '+1' || rate == '-1' || rate == '-2' || rate == '-3' || rate == '-4' || rate == '-5'){
                                se.put('Rating_Negative__c', rate);
                                se.put('Rating_Positive__c', '');
                                if(brMap.containsKey('Rating- Negative')){
                                    se.put('Criteria__c', brMap.get('Rating- Negative')[0]);
                                    se.put('Points__c', Integer.valueOf((brMap.get('Rating- Negative')[1])));
                                }  
                            }                           
                        }
                        else{
                            se.put(mt.TargetFieldName__c,(String)bin.get(mt.SourceFieldName__c));  
                            if(brMap.containsKey(mt.BR_FieldName__c)){
                                se.put('Criteria__c', brMap.get(mt.BR_FieldName__c)[0]);
                                se.put('Points__c', Integer.valueOf((brMap.get(mt.BR_FieldName__c)[1])));
                            }                           
                        } 
                                               
                    }
                    se.Object_API_Name__c = objectAPIName;
                    se.Source_ID__c = bin.id;
                    seList.add(se);
                }                                
            }
            
            //Competitor
            else if(objectApiName == 'Competition__c'){
                system.debug('%%%in COMPETITOR');
                List<Competition__c> compList = new List<Competition__c>();
                qry = 'Select Id, Blue_Sheet__r.Name, '+String.join(fieldsForQuery,',')+' from '+objectApiName+' where Id in :objectIds';
                System.debug('qry--'+qry);
                compList = Database.query(qry);
                
                
                seMapList = [Select id, Blue_Sheet_Name__c, Source_ID__c, Object_API_Name__c, Is_Last__c from Strategy_Engine__c where Is_Last__c = True];
                
                Map<String, Id> seBSMap = new Map<String, Id>();        //map of BS name and and se id of SE last checked records 
                for(Strategy_Engine__c s:seMapList){
                    seBSMap.put(s.Blue_Sheet_Name__c, s.id);
                }
                
                Map<String, Id> compCreateMap = new Map<String, Id>();
                Map<String, Id> compUpdateMap = new Map<String, Id>();
                
                Map<String, Id> seMap = SEFieldsPopulation.seMap();    //map of all SE records source id and se id
                
                for(Competition__c cmp:compList){
                    if(seMap.containsKey(cmp.id)){
                        compUpdateMap.put(cmp.Blue_Sheet__r.Name, seMap.get(cmp.id));
                    }else{
                        //find BS related to this cmp, in SE find last record related to this BS and send it in createmap
                        Strategy_Engine__c temp = new Strategy_Engine__c(id = seBSMap.get(cmp.Blue_Sheet__r.Name));
                        compCreateMap.put(cmp.Blue_Sheet__r.Name,seBSMap.get(cmp.Blue_Sheet__r.Name));
                        temp.Is_Last__c = false;
                        seLastList.add(temp);
                    }
                }
                                
                update seLastList;
                      
                for(Competition__c cmpn:compList){    
                    Strategy_Engine__c se = new Strategy_Engine__c();    
                    if(compCreateMap.containskey(cmpn.Blue_Sheet__r.Name)){                        
                        Id seid = compCreateMap.get(cmpn.Blue_Sheet__r.Name);
                        qry = 'Select '+String.join(allSEFieldsForQuery,',')+' from Strategy_Engine__c where Id  = :seid';
                        Strategy_Engine__c str = Database.query(qry);
                        se = str.clone(false, false, false, false);
                        se.Criteria__c='';
                        se.Points__c=null;
                        se.Is_Last__c = true;
                    }else{
                        se.put('id',compUpdateMap.get(cmpn.Blue_Sheet__r.Name));
                    }        
                    //Strategy_Engine__c se = new Strategy_Engine__c(id = compUpdateMap.get(cmpn.Blue_Sheet__r.Name));
                    se.Blue_Sheet_Name__c = cmpn.Blue_Sheet__r.Name;
                    for(StrategyEngine__mdt mt:seCMDT){
                         if(mt.SourceFieldName__c == 'Competitor_Type__c'){
                            String ctype = (String)cmpn.get(mt.SourceFieldName__c);   
                            if(ctype == 'Named Competitor' || ctype == 'Buying from Someone Else'){                                
                                se.put('Competition_Type_Positive__c', ctype);
                                se.put('Competition_Type_Negative__c', '');
                                if(brMap.containsKey(mt.BR_FieldName__c)){
                                    se.put('Criteria__c', brMap.get(mt.BR_FieldName__c)[0]);
                                    se.put('Points__c', Integer.valueOf((brMap.get(mt.BR_FieldName__c)[1])));
                                }  
                            } 
                            else if(ctype == 'Doing Nothing' || ctype == 'Using Budget for Something Else' || ctype == 'Using Internal Resources'){
                                se.put('Competition_Type_Negative__c', ctype);
                                se.put('Competition_Type_Positive__c', '');
                                if(brMap.containsKey('Competition Type- Negative')){
                                    se.put('Criteria__c', brMap.get('Competition Type- Negative')[0]);
                                    se.put('Points__c', Integer.valueOf((brMap.get('Competition Type- Negative')[1])));
                                }  
                            }                           
                        }
                        else if(mt.SourceFieldName__c == 'My_Position_Vs_Competitor__c'){
                            String posvscmp = (String)cmpn.get(mt.SourceFieldName__c);   
                            if(posvscmp == 'Only Alternative' || posvscmp == 'Front Runner'){                                
                                se.put('My_Position_Vs_Competition_Positive__c', posvscmp);
                                se.put('My_Position_Vs_Competition_Negative__c', '');
                                if(brMap.containsKey(mt.BR_FieldName__c)){
                                    se.put('Criteria__c', brMap.get(mt.BR_FieldName__c)[0]);
                                    se.put('Points__c', Integer.valueOf((brMap.get(mt.BR_FieldName__c)[1])));
                                }  
                            } 
                            else if(posvscmp == 'Shared' || posvscmp == 'Zero'){
                                se.put('My_Position_Vs_Competition_Negative__c', posvscmp);
                                se.put('My_Position_Vs_Competition_Positive__c', '');
                                if(brMap.containsKey('My Position Vs. Competition- Negative')){
                                    se.put('Criteria__c', brMap.get('My Position Vs. Competition- Negative')[0]);
                                    se.put('Points__c', Integer.valueOf((brMap.get('My Position Vs. Competition- Negative')[1])));
                                }  
                            } 
                        }
                        else{
                            se.put(mt.TargetFieldName__c,(String)cmpn.get(mt.SourceFieldName__c));    
                            if(brMap.containsKey(mt.BR_FieldName__c)){
                                    se.put('Criteria__c', brMap.get(mt.BR_FieldName__c)[0]);
                                    se.put('Points__c', Integer.valueOf((brMap.get(mt.BR_FieldName__c)[1])));
                            }                         
                        }  
                        
                    }
                    se.Object_API_Name__c = objectAPIName;
                    se.Source_ID__c = cmpn.id;
                    seList.add(se);
                }                                
            }
            
            //Strength
            else if(objectApiName == 'Strength__c'){
                system.debug('%%%in Strength');
                List<Strength__c> strengthList = new List<Strength__c>();
                qry = 'Select Id, Blue_Sheet__r.Name, '+String.join(fieldsForQuery,',')+' from '+objectApiName+' where Id in :objectIds';
                strengthList = Database.query(qry);
                
                
                seMapList = [Select id, Blue_Sheet_Name__c, Source_ID__c, Object_API_Name__c, Is_Last__c from Strategy_Engine__c where Is_Last__c = True];
                
                Map<String, Id> seBSMap = new Map<String, Id>();        //map of BS name and and se id of SE last checked records 
                for(Strategy_Engine__c s:seMapList){
                    seBSMap.put(s.Blue_Sheet_Name__c, s.id);
                }
                
                Map<String, Id> strCreateMap = new Map<String, Id>();
                Map<String, Id> strUpdateMap = new Map<String, Id>();
                
                Map<String, Id> seMap = SEFieldsPopulation.seMap();    //map of all SE records source id and se id
                
                for(Strength__c str:strengthList){
                    if(seMap.containsKey(str.id)){
                        strUpdateMap.put(str.Blue_Sheet__r.Name, seMap.get(str.id));
                    }else{
                        //find BS related to this str, in SE find last record related to this BS and send it in createmap
                        Strategy_Engine__c temp = new Strategy_Engine__c(id = seBSMap.get(str.Blue_Sheet__r.Name));
                        strCreateMap.put(str.Blue_Sheet__r.Name,seBSMap.get(str.Blue_Sheet__r.Name));
                        temp.Is_Last__c = false;
                        seLastList.add(temp);
                    }
                }
                
                
                update seLastList;
                      
                for(Strength__c strn:strengthList){    
                    Strategy_Engine__c se = new Strategy_Engine__c();    
                    if(strCreateMap.containskey(strn.Blue_Sheet__r.Name)){                        
                        Id seid = strCreateMap.get(strn.Blue_Sheet__r.Name);
                        qry = 'Select '+String.join(allSEFieldsForQuery,',')+' from Strategy_Engine__c where Id  = :seid';
                        Strategy_Engine__c str = Database.query(qry);
                        se = str.clone(false, false, false, false);
                        se.Criteria__c='';
                        se.Points__c=null;
                        se.Is_Last__c = true;
                    }else{
                        se.put('id',strUpdateMap.get(strn.Blue_Sheet__r.Name));
                    }        
                    //Strategy_Engine__c se = new Strategy_Engine__c(id = strUpdateMap.get(strn.Blue_Sheet__r.Name));
                    se.Blue_Sheet_Name__c = strn.Blue_Sheet__r.Name;
                    for(StrategyEngine__mdt mt:seCMDT){                         
                        se.put(mt.TargetFieldName__c,(String)strn.get(mt.SourceFieldName__c));
                    }
                    se.Object_API_Name__c = objectAPIName;
                    se.Source_ID__c = strn.id;
                    seList.add(se);
                }                                
            }
            
            //Red Flag
            else if(objectApiName == 'Red_Flag__c'){
                List<Red_Flag__c> rfList = new List<Red_Flag__c>();
                qry = 'Select Id, Blue_Sheet__r.Name, '+String.join(fieldsForQuery,',')+' from '+objectApiName+' where Id in :objectIds';
                rfList = Database.query(qry);
                
                
                seMapList = [Select id, Blue_Sheet_Name__c, Source_ID__c, Object_API_Name__c, Is_Last__c from Strategy_Engine__c where Is_Last__c = True];
                
                Map<String, Id> seBSMap = new Map<String, Id>();        //map of BS name and and se id of SE last checked records 
                for(Strategy_Engine__c s:seMapList){
                    seBSMap.put(s.Blue_Sheet_Name__c, s.id);
                }
                
                Map<String, Id> rfCreateMap = new Map<String, Id>();
                Map<String, Id> rfUpdateMap = new Map<String, Id>();
                
                Map<String, Id> seMap = SEFieldsPopulation.seMap();    //map of all SE records source id and se id
                
                for(Red_Flag__c red:rfList){
                    if(seMap.containsKey(red.id)){
                        rfUpdateMap.put(red.Blue_Sheet__r.Name, seMap.get(red.id));
                    }else{
                        //find BS related to this red, in SE find last record related to this BS and send it in createmap
                        Strategy_Engine__c temp = new Strategy_Engine__c(id = seBSMap.get(red.Blue_Sheet__r.Name));
                        rfCreateMap.put(red.Blue_Sheet__r.Name,seBSMap.get(red.Blue_Sheet__r.Name));
                        temp.Is_Last__c = false;
                        seLastList.add(temp);
                    }
                }
                
                
                update seLastList;
                      
                for(Red_Flag__c rdfg:rfList){    
                    Strategy_Engine__c se = new Strategy_Engine__c();    
                    if(rfCreateMap.containskey(rdfg.Blue_Sheet__r.Name)){                        
                        Id seid = rfCreateMap.get(rdfg.Blue_Sheet__r.Name);
                        qry = 'Select '+String.join(allSEFieldsForQuery,',')+' from Strategy_Engine__c where Id  = :seid';
                        Strategy_Engine__c red = Database.query(qry);
                        se = red.clone(false, false, false, false);
                        se.Criteria__c='';
                        se.Points__c=null;
                        se.Is_Last__c = true;
                    }else{
                        se.put('id',rfUpdateMap.get(rdfg.Blue_Sheet__r.Name));                       
                    }        
                    //Strategy_Engine__c se = new Strategy_Engine__c(id = rfUpdateMap.get(rdfg.Blue_Sheet__r.Name));
                    se.Blue_Sheet_Name__c = rdfg.Blue_Sheet__r.Name;
                    for(StrategyEngine__mdt mt:seCMDT){                         
                        se.put(mt.TargetFieldName__c,(String)rdfg.get(mt.SourceFieldName__c));
                    }
                    se.Object_API_Name__c = objectAPIName;
                    se.Source_ID__c = rdfg.id;
                    seList.add(se);
                }                                
            }
            
            
            if(seList.size()>0){
                try{
                      upsert seList;
                   }catch(Exception e){
                      System.debug('Exception while saving record::'+e.getMessage());
                   }
            } 
            
            if(cpupdateMap != null){
                updateAllSEforCP(cpupdateMap);
            }
            
            if(ssoupdateMap != null){
                updateAllSEforSSO(ssoupdateMap);
            }
    }
    
    public static Map<String, Id> seMap(){
        List<Strategy_Engine__c> seSourceList = [Select id, Source_ID__c from Strategy_Engine__c];
        Map<String, Id> seSourceMap = new Map<String, Id>();
        for(Strategy_Engine__c sEng:seSourceList){
            seSourceMap.put(sEng.Source_ID__c, sEng.id);
        }  
        return seSourceMap;
    }
    
    public static void updateAllSEforCP(Map<String, Id> cpupdateMap){
        Map<Id, Id> fromToSE = new Map<Id,Id>();
        Map<Id, String> cpSEMapPositive = new Map<Id,String>();
        Map<Id, String> cpSEMapNegative = new Map<Id,String>();
        Strategy_Engine__c seRec = new Strategy_Engine__c();
        List<Strategy_Engine__c> seList = new List<Strategy_Engine__c>();
        
        List<Strategy_Engine__c> cpSEList = [Select id, name, Blue_Sheet_Name__c, Position_is_Positive__c, Position_is_Negative__c from Strategy_Engine__c where Id in :cpupdateMap.values()];
        system.debug('cpSEList'+cpSEList);
        for(Strategy_Engine__c se:cpSEList){
            if(se.Position_is_Positive__c != null){
                cpSEMapPositive.put(se.id, se.Position_is_Positive__c);        //map of already updated se id and +position
            }
            if(se.Position_is_Negative__c != null){
                cpSEMapNegative.put(se.id, se.Position_is_Negative__c );    //map of already updated se id and -position
            }
        }
        List<Strategy_Engine__c> updateSErecords = [Select id, name, Blue_Sheet_Name__c, Current_Position_Name__c, Position_is_Positive__c, Position_is_Negative__c from Strategy_Engine__c where Blue_Sheet_Name__c in :cpupdateMap.keyset()];
        for(Strategy_Engine__c se:updateSErecords){
            if(cpupdateMap.containsKey(se.Blue_Sheet_Name__c) ){        
                fromToSE.put(se.id,cpupdateMap.get(se.Blue_Sheet_Name__c));    //map of to be updated se id and already update se id
            }
            //if(se.Position_is_Positive__c! = seRec.Position_is_Positive__c){} //cpSEMapPositive.get(fromToSE.get(se.id))            
        }
        for(Strategy_Engine__c se:updateSErecords){
      
            if(se.Current_Position_Name__c != null){
                if(cpSEMapPositive.containsKey(fromToSE.get(se.id))){
                    se.Position_is_Positive__c = cpSEMapPositive.get(fromToSE.get(se.id));
                    System.debug('se.Position_is_Positive__c---'+se.Position_is_Positive__c);
                    se.Position_is_Negative__c = '';
                }
                else if(cpSEMapNegative.containsKey(fromToSE.get(se.id))){
                    se.Position_is_Negative__c = cpSEMapNegative.get(fromToSE.get(se.id));
                    se.Position_is_Positive__c = '';
                }
                                        
            }
            seList.add(se);
        }
        
        System.debug('seList---'+seList);
            if(seList.size()>0){
                try{
                      upsert seList;
                   }catch(Exception e){
                      System.debug('Exception while saving record::'+e.getMessage());
                   }
        } 
    }
    
    public static void updateAllSEforSSO(Map<String, Id> ssoupdateMap){
        Map<Id, Id> fromToSE = new Map<Id,Id>();
        Map<Id, String> ctpSEMapPositive = new Map<Id,String>();
        Map<Id, String> ctpSEMapNegative = new Map<Id,String>();
        Map<Id, String> csoSEMap = new Map<Id,String>();
        Map<Id, String> eooSEMap = new Map<Id,String>();
        List<Strategy_Engine__c> seList = new List<Strategy_Engine__c>();
        Strategy_Engine__c seRec = new Strategy_Engine__c();
        
        List<Strategy_Engine__c> ssoSEList = [Select id, name, Blue_Sheet_Name__c, SSO_Name__c, Customer_Stated_Objective__c, Customer_Timing_for_Priorities_Negative__c, Customer_Timing_for_Priorities_Positive__c, Evaluation_of_Objective__c from Strategy_Engine__c where Id in :ssoupdateMap.values()];
        for(Strategy_Engine__c se:ssoSEList){
            if(se.Customer_Timing_for_Priorities_Positive__c != null){
                ctpSEMapPositive.put(se.id, se.Customer_Timing_for_Priorities_Positive__c);        //map of already updated se id and +position
            }
            if(se.Customer_Timing_for_Priorities_Negative__c != null){
                ctpSEMapNegative.put(se.id, se.Customer_Timing_for_Priorities_Negative__c );    //map of already updated se id and -position
            }
            if(se.Customer_Stated_Objective__c != null){
                csoSEMap.put(se.id, se.Customer_Stated_Objective__c);        //map of already updated se id and cso
            }
            if(se.Evaluation_of_Objective__c != null){
                eooSEMap.put(se.id, se.Evaluation_of_Objective__c );    //map of already updated se id and eoo
            }
        }
        List<Strategy_Engine__c> updateSErecords = [Select id, name, Blue_Sheet_Name__c, SSO_Name__c, Customer_Stated_Objective__c, Customer_Timing_for_Priorities_Negative__c, Customer_Timing_for_Priorities_Positive__c, Evaluation_of_Objective__c from Strategy_Engine__c where Blue_Sheet_Name__c in:ssoupdateMap.keyset()];
        for(Strategy_Engine__c se:updateSErecords){
            if(ssoupdateMap.containsKey(se.Blue_Sheet_Name__c) ){        
                fromToSE.put(se.id,ssoupdateMap.get(se.Blue_Sheet_Name__c));    //map of to be updated se id and already update se id
            }
        }
        for(Strategy_Engine__c se:updateSErecords){
            if(se.SSO_Name__c != null){
                if(ctpSEMapPositive.containsKey(fromToSE.get(se.id))){      //value of source SE(already updated) to be pulled into target SE
                    se.Customer_Timing_for_Priorities_Positive__c = ctpSEMapPositive.get(fromToSE.get(se.id));
                    se.Customer_Timing_for_Priorities_Negative__c = '';
                }
                if(ctpSEMapNegative.containsKey(fromToSE.get(se.id))){ 
                    se.Customer_Timing_for_Priorities_Negative__c = ctpSEMapNegative.get(fromToSE.get(se.id));
                    se.Customer_Timing_for_Priorities_Positive__c = '';
                }
                if(eooSEMap.containsKey(fromToSE.get(se.id))){
                    se.Evaluation_of_Objective__c = eooSEMap.get(fromToSE.get(se.id));
                }
                if(csoSEMap.containsKey(fromToSE.get(se.id))){
                    se.Customer_Stated_Objective__c = csoSEMap.get(fromToSE.get(se.id));
                }
                else{                                        
                    se.Customer_Stated_Objective__c = '';
                    se.Evaluation_of_Objective__c = '';
                }
            }
            seList.add(se);
        }
        
            if(seList.size()>0){
                try{
                      upsert seList;
                      System.debug('DONE');
                   }catch(Exception e){
                        System.debug('Exception while saving record::'+e.getMessage());
                   }
        }
    } */
}