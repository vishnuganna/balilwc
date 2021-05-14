/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Apex controller class for fetching, saving and update of Buying Influence records.
*
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Sushma Bharti   
* @modifiedBy     Sushma Bharti   
* @maintainedBy   Sushma Bharti   
* @version        1.0
* @created        2020-05-14
* @modified       YYYY-MM-DD
* //@systemLayer    Invocation | Service | UtilityMethods | Selector | Domain | Test
//@systemLayer    LWC- buyingInfluence.js
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X            Sushma Bharti
* YYYY-MM-DD      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text.
*
* vX.X            Sushma Bharti
* YYYY-MM-DD      Each change to this file should be documented by incrementing the version number,
*                 and adding a new entry to this @changes list. Note that there is a single blank
*                 line between each @changes entry.
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/

public with sharing class BuyingInfluenceDetails {
    /**
     * ───────────────────────────────────────────────────────────────────────────────────────────────┐
     * Get all the Buying Influence records related to the current opportunity's Blue sheet
     * ────────────────────────────────────────────────────────────────────────────────────────────────
     * @param    recordId                Record id of opportunity record
     * @return   List<BuyingInfluenceWrapperClass>    List of BuyingInfluenceWrapperClass
     * ───────────────────────────────────────────────────────────────────────────────────────────────┘
     */
    @SuppressWarnings('PMD.NcssMethodCount')
    @AuraEnabled
    public static List<BuyingInfluenceWrapperClass> getBuyingInfluence(string oppId) {
        List<Buying_Influence__c> listBI = new List<Buying_Influence__c>();
        List<BuyingInfluenceWrapperClass> biWrapperListToReturn = new List<BuyingInfluenceWrapperClass>();

        try {
            //formation of query
            String biQuery = 'Select Id,Name,Contact__c,Contact__r.Name,Contact__r.FirstName,Contact__r.LastName,Contact__r.MailingState,Contact__r.MailingCountry,Blue_Sheet__c,Business_Results__c,Buying_From_Us__c,Buying_from_Someone_Else__c,Coach__c,Doing_Nothing__c,Economic__c,Even_Keel__c,Growth__c,High__c,Location__c,Low__c,Medium__c,Over_Confident__c,Personal_Wins__c,Rating__c,Rating_Evidence__c,Rating_Text__c,Search_Competitor__r.Name,Technical__c,Title__c,Trouble__c,User__c,Using_Budget_for_Something_Else__c,Using_Internal_Resources__c FROM Buying_Influence__c WHERE Blue_Sheet__r.Opportunity__c=:oppId';

            Map<String, Object> paramters = new Map<String, Object>();
            paramters.put('oppId', oppId);
            //get data from BI section
            listBI = DataFactory.read(biQuery, paramters);
            //iterate through list to get list of wrapper to return to UI
            for (Buying_Influence__c bi : listBI) {
                List<RedFlagStrengthMarkerWrapper> rfsWrapperList = new List<RedFlagStrengthMarkerWrapper>();
                String sourceId = bi.Id;
                rfsWrapperList = RedFlagStrengthData.getRFSWrapperList(sourceId);
                BuyingInfluenceWrapperClass wrapper = new BuyingInfluenceWrapperClass(bi);
                wrapper.rfsMarkerWrapper = rfsWrapperList;

                List<String> biRole = new List<String>();
                String biRoleListWithSpaces = '';
                String degree = '-';
                String mode = '-';
                String compPref = '-';
                String perWin = '';
                String busResult = '';
                String rating = '-';
                String evidence = '';
                String busResult1 = '-';
                String busResult2 = '';
                Boolean brMoreText = false;
                Boolean brLessText = false;

                //Buying influence role
                if (bi.Economic__c == true) {
                    biRole.add(Schema.Buying_Influence__c.fields.Economic__c.getDescribe().getLabel());
                }
                if (bi.Technical__c == true) {
                    biRole.add(Schema.Buying_Influence__c.fields.Technical__c.getDescribe().getLabel());
                }
                if (bi.Coach__c == true) {
                    biRole.add(Schema.Buying_Influence__c.fields.Coach__c.getDescribe().getLabel());
                }
                if (bi.User__c == true) {
                    biRole.add(Schema.Buying_Influence__c.fields.User__c.getDescribe().getLabel());
                }
                if (
                    bi.User__c == false &&
                    bi.Coach__c == false &&
                    bi.Technical__c == false &&
                    bi.Economic__c == false
                ) {
                    biRole.add('-');
                }
                biRoleListWithSpaces = String.join(biRole, ', ');
                //Degree of influence
                if (bi.High__c == true) {
                    degree = Schema.Buying_Influence__c.fields.High__c.getDescribe().getLabel();
                }
                if (bi.Low__c == true) {
                    degree = Schema.Buying_Influence__c.fields.Low__c.getDescribe().getLabel();
                }
                if (bi.Medium__c == true) {
                    degree = Schema.Buying_Influence__c.fields.Medium__c.getDescribe().getLabel();
                }

                //Competitive preference
                if (bi.Doing_Nothing__c == true) {
                    compPref = Schema.Buying_Influence__c.fields.Doing_Nothing__c.getDescribe().getLabel();
                }
                if (bi.Buying_from_Someone_Else__c == true) {
                    compPref = Schema.Buying_Influence__c.fields.Buying_from_Someone_Else__c.getDescribe().getLabel();
                }
                if (bi.Buying_From_Us__c == true) {
                    compPref = Schema.Buying_Influence__c.fields.Buying_From_Us__c.getDescribe().getLabel();
                }
                if (bi.Using_Budget_for_Something_Else__c == true) {
                    compPref = Schema.Buying_Influence__c.fields.Using_Budget_for_Something_Else__c.getDescribe()
                        .getLabel();
                }
                if (bi.Using_Internal_Resources__c == true) {
                    compPref = Schema.Buying_Influence__c.fields.Using_Internal_Resources__c.getDescribe().getLabel();
                }

                //Buying mode
                if (bi.Trouble__c == true) {
                    mode = Schema.Buying_Influence__c.fields.Trouble__c.getDescribe().getLabel();
                }
                if (bi.Over_Confident__c == true) {
                    mode = Schema.Buying_Influence__c.fields.Over_Confident__c.getDescribe().getLabel();
                }
                if (bi.Even_Keel__c == true) {
                    mode = Schema.Buying_Influence__c.fields.Even_Keel__c.getDescribe().getLabel();
                }
                if (bi.Growth__c == true) {
                    mode = Schema.Buying_Influence__c.fields.Growth__c.getDescribe().getLabel();
                }

                if (bi.Personal_Wins__c != null) {
                    perWin = bi.Personal_Wins__c;
                }
                if (bi.Rating__c != null) {
                    rating = bi.Rating__c;
                }
                if (bi.Rating_Evidence__c != null) {
                    evidence = bi.Rating_Evidence__c;
                }

                if (bi.Business_Results__c != null) {
                    busResult = bi.Business_Results__c;

                    /* if(busResult.length() > 100 ){                        
                        busResult1=busResult.substring(0,100); 
                        busResult2=busResult.substring(100,busResult.length());                         
                        brMoreText =true;
                    }else{
                        busResult1 = busResult;
                        busResult2 = '';
                        brMoreText = false;
                        brLessText = false;                        
                    } */
                }

                wrapper.biRole = biRole;
                wrapper.biRoleListWithSpaces = biRoleListWithSpaces;
                wrapper.degree = degree;
                wrapper.mode = mode;
                wrapper.compPref = compPref;
                wrapper.businessResults = busResult;
                //wrapper.businessResults1=busResult1;
                //wrapper.businessResults2=busResult2;
                //wrapper.brShowMoreText=brMoreText;
                //wrapper.brShowLessText=brLessText;

                wrapper.personalWins = perWin;
                wrapper.rating = rating;
                wrapper.ratingEvidence = evidence;

                biWrapperListToReturn.add(wrapper);
            }
        } catch (Exception ex) {
            system.System.debug('exception ----' + ex);
            //throw new Exception('Error occured while getting data from Buying Influence');
        }
        //return list of wrapper containing all Buying Influence data
        return biWrapperListToReturn;
    }

    /**
     * ───────────────────────────────────────────────────────────────────────────────────────────────┐
     * Get the BuyingInfluenceWrapperClass object.
     * ────────────────────────────────────────────────────────────────────────────────────────────────
     * @return   BuyingInfluenceWrapperClass      			Returns BuyingInfluenceWrapperClass object
     * ───────────────────────────────────────────────────────────────────────────────────────────────┘
     */
    @AuraEnabled
    public static BuyingInfluenceWrapperClass getWrapperObject() {
        return new BuyingInfluenceWrapperClass();
    }

    /**
     * ───────────────────────────────────────────────────────────────────────────────────────────────┐
     * Get the Blue Sheet record Id of buying influence.
     * ────────────────────────────────────────────────────────────────────────────────────────────────
     * @param    recordId                Record id of opportunity record
     * @return   String      			Stores the Bluesheet ID
     * ───────────────────────────────────────────────────────────────────────────────────────────────┘
     */

    @AuraEnabled
    public static String getBlueSheetId(string oppId) {
        String bsID = '';
        List<Blue_Sheet__c> listBS = new List<Blue_Sheet__c>();
        try {
            String bsQuery = 'SELECT Id, Name FROM Blue_Sheet__c where Opportunity__c =: oppId limit 1';
            Map<String, Object> paramters = new Map<String, Object>();
            paramters.put('oppId', oppId);
            //get data from BI section
            listBS = DataFactory.read(bsQuery, paramters);
            //iterate through list to get list of wrapper to return to UI
            for (Blue_Sheet__c bs : listBS) {
                BlueSheetWrapperClass wrapper = new BlueSheetWrapperClass(bs);
                bsID = string.valueof(wrapper.Id);
            }
        } catch (Exception ex) {
            system.System.debug('exception ----' + ex);
            //throw new Exception('Error occured while getting data from Blue Sheet');
        }
        return bsID;
    }

    /**
     * ───────────────────────────────────────────────────────────────────────────────────────────────┐
     * Save and update the record of buying influence.
     * ────────────────────────────────────────────────────────────────────────────────────────────────
     * @param    recordId                Record id of Buying influence record to be updated or created.
     * @return   Map<string,string>      Stores the  map of values
     * ───────────────────────────────────────────────────────────────────────────────────────────────┘
     */
    @SuppressWarnings('PMD.ExcessiveParameterList,PMD.NcssMethodCount')
    @AuraEnabled
    public static Map<String, Object> saveRecord(
        String jsonString,
        String blueSheetId,
        Map<String, Map<String, Object>> rfsMap,
        String oppId
    ) {
        Map<String, Object> resultMap = new Map<String, Object>();
        BuyingInfluenceWrapperClass biWrapper = (BuyingInfluenceWrapperClass) JSON.deserialize(
            jsonString,
            BuyingInfluenceWrapperClass.class
        );
        Buying_Influence__c bif = BuyingInfluenceWrapperClass.convertWrapperToObject(biWrapper);
        List<Database.SaveResult> srList;
        //String blueSheetId = bluesheet[0].Id;
        //String objectApiName = 'Buying_Influence__c';
        if (blueSheetId == null || blueSheetId == '') {
            blueSheetId = getBlueSheetId(oppId);
        }
        String objectApiName = util.getNamespaceWithUnderScores() == ''
            ? 'Buying_Influence__c'
            : util.getNamespaceWithUnderScores() + 'Buying_Influence__c';
        List<Red_Flag_Strength_Marker__c> markerList = new List<Red_Flag_Strength_Marker__c>();
        try {
            if (biWrapper.id == '') {
                String bsIdTmp = biWrapper.blueSheet;
                if (bsIdTmp == null || bsIdTmp == '') {
                    bif.Blue_Sheet__c = blueSheetId;
                }
                srList = DataFactory.create(bif);
                for (Database.SaveResult sr : srList) {
                    if (sr.isSuccess()) {
                        markerList = RedFlagStrengthData.createRFSrecords(blueSheetId, objectApiName, rfsMap);
                        DataFactory.create(markerList);
                    }
                }

                List<Red_Flag_Strength_Marker__c> markerListUpdated = new List<Red_Flag_Strength_Marker__c>();
                for (Red_Flag_Strength_Marker__c marker : markerList) {
                    marker.Source_ID__c = srList[0].getId();
                    markerListUpdated.add(marker);
                }
                DataFactory.modify(markerListUpdated);
            } else {
                bif.Id = biWrapper.id;
                String biId = bif.Id;
                srList = DataFactory.modify(bif);
                for (Database.SaveResult sr : srList) {
                    if (sr.isSuccess()) {
                        List<RedFlagStrengthMarkerWrapper> rfsWrapperList = RedFlagStrengthData.updateRFSRecords(
                            objectApiName,
                            biId,
                            oppId,
                            rfsMap
                        );
                    }
                }
            }
            List<RedFlagStrengthMarkerWrapper> rfsWrapperList = new List<RedFlagStrengthMarkerWrapper>();
            // Iterate through each returned result
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    resultMap.put('recordId', sr.getId());
                    String sourceId = sr.getId();
                    rfsWrapperList = RedFlagStrengthData.getRFSWrapperList(sourceId);
                }
            }

            resultMap.put('status', System.Label.success_header);
            resultMap.put('msg', System.Label.success_header);
            resultMap.put('rfsWrapperList', rfsWrapperList);
        } catch (Exception ex) {
            resultMap.put('status', System.Label.error_header);
            resultMap.put('msg', ex.getMessage());
            system.System.debug('exception ----' + ex);
        }
        return resultMap;
    }

    /**
     * ───────────────────────────────────────────────────────────────────────────────────────────────┐
     * Delete the record of buying influence.
     * ────────────────────────────────────────────────────────────────────────────────────────────────
     * @param    recordId                Record id of Buying influence record
     * @return   Map<string,string>      Stores the  map of values
     * ───────────────────────────────────────────────────────────────────────────────────────────────┘
     */
    @AuraEnabled
    public static Map<String, String> deleteRecord(String recordId) {
        Map<String, String> resultMap = new Map<String, String>();

        List<Red_Flag_Strength_Marker__c> rfsRecords = RedFlagStrengthData.getRFSrecords(recordId);
        try {
            List<Database.DeleteResult> srList = DataFactory.remove(recordId);
            for (Database.DeleteResult sr : srList) {
                if (sr.isSuccess()) {
                    DataFactory.remove(rfsRecords);
                }
            }
            resultMap.put('status', System.Label.success_header);
            resultMap.put('msg', System.Label.RecordDeleted);
        } catch (Exception exp) {
            resultMap.put('status', System.Label.error_header);
            resultMap.put('msg', exp.getMessage());
            system.System.debug('exception ----' + exp);
        }
        return resultMap;
    }

    @AuraEnabled
    public static wrapperLookupObject getObjectName() {
        wrapperLookupObject wrapper = new wrapperLookupObject();
        wrapper.lookupOnObject = util.getNamespaceWithUnderScores() == ''
            ? 'Buying_Influence__c'
            : util.getNamespaceWithUnderScores() + 'Buying_Influence__c';
        wrapper.targetField = util.getNamespaceWithUnderScores() == ''
            ? 'Search_Competitor__c'
            : util.getNamespaceWithUnderScores() + 'Search_Competitor__c';
        return wrapper;
    }

    public class wrapperLookupObject {
        @AuraEnabled
        public String lookupOnObject;
        @AuraEnabled
        public String targetField;
    }

    @AuraEnabled
    public static Map<String, Boolean> getBuyingInfluenceAccess() {
        Map<String, Boolean> accessMap = new Map<String, Boolean>();
        //String objName = 'Buying_Influence__c';
        String objName = util.getNamespaceWithUnderScores() == ''
            ? 'Buying_Influence__c'
            : util.getNamespaceWithUnderScores() + 'Buying_Influence__c';
        Boolean isCreateableObj = Schema.getGlobalDescribe().get(objName).getDescribe().isCreateable();
        Boolean isUpdateableObj = Schema.getGlobalDescribe().get(objName).getDescribe().isUpdateable();
        Boolean isDeletableObj = Schema.getGlobalDescribe().get(objName).getDescribe().isDeletable();
        accessMap.put('isCreateable', isCreateableObj);
        accessMap.put('isUpdateable', isUpdateableObj);
        accessMap.put('isDeletable', isDeletableObj);
        return accessMap;
    }
}