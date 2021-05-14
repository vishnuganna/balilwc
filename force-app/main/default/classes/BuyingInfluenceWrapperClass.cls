/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* KFS-64 : Wrapper class to hold the data from BI object fields.
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
@SuppressWarnings('PMD.TooManyFields,PMD.ExcessivePublicCount')
public with sharing class BuyingInfluenceWrapperClass {
    @AuraEnabled
    public Id blueSheet { get; set; }
    @AuraEnabled
    public String id { get; set; }
    @AuraEnabled
    public String name { get; set; }
    @AuraEnabled
    public String businessResults { get; set; }
    @AuraEnabled
    public String businessResults1 { get; set; }
    @AuraEnabled
    public String businessResults2 { get; set; }
    @AuraEnabled
    public Boolean brShowMoreText { get; set; }
    @AuraEnabled
    public Boolean brShowLessText { get; set; }
    @AuraEnabled
    public String contact { get; set; }
    @AuraEnabled
    public Boolean buyingFromUs { get; set; }
    @AuraEnabled
    public Boolean buyingfromSomeoneElse { get; set; }
    @AuraEnabled
    public Boolean coach { get; set; }
    @AuraEnabled
    public Boolean economic { get; set; }
    @AuraEnabled
    public Boolean doingNothing { get; set; }
    @AuraEnabled
    public Boolean growth { get; set; }
    @AuraEnabled
    public Boolean evenKeel { get; set; }
    @AuraEnabled
    public Boolean high { get; set; }
    @AuraEnabled
    public Boolean low { get; set; }
    @AuraEnabled
    public Boolean medium { get; set; }
    @AuraEnabled
    public String location { get; set; }
    @AuraEnabled
    public Boolean overConfident { get; set; }
    @AuraEnabled
    public Boolean trouble { get; set; }
    @AuraEnabled
    public Boolean user { get; set; }
    @AuraEnabled
    public Boolean usingBudget { get; set; }
    @AuraEnabled
    public Boolean internalResources { get; set; }
    @AuraEnabled
    public String personalWins { get; set; }
    @AuraEnabled
    public String rating { get; set; }
    @AuraEnabled
    public String ratingEvidence { get; set; }
    @AuraEnabled
    public String ratingText { get; set; }
    @AuraEnabled
    public String searchCompetitor { get; set; }
    @AuraEnabled
    public String title { get; set; }
    @AuraEnabled
    public String contactFname { get; set; }
    @AuraEnabled
    public String contactLname { get; set; }
    @AuraEnabled
    public String MailingState { get; set; }
    @AuraEnabled
    public String MailingCountry { get; set; }
    @AuraEnabled
    public Boolean technical { get; set; }
    @AuraEnabled
    public List<String> biRole { get; set; }
    @AuraEnabled
    public String biRoleListWithSpaces { get; set; }
    @AuraEnabled
    public String degree { get; set; }
    @AuraEnabled
    public String mode { get; set; }
    @AuraEnabled
    public String compPref { get; set; }
    @AuraEnabled
    public List<RedFlagStrengthMarkerWrapper> rfsMarkerWrapper { get; set; }
    @AuraEnabled
    public Map<String, RedFlagStrengthMarkerWrapper> rfsMarkerPdfWrapper { get; set; }

    public BuyingInfluenceWrapperClass() {
        this.personalWins = '';
        this.ratingEvidence = '';
        this.businessResults = '';
    }

    /**
     * ───────────────────────────────────────────────────────────────────────────────────────────────┐
     * Parameter constructor that accepts the data from object and assign it to wrapper.
     * ────────────────────────────────────────────────────────────────────────────────────────────────
     * @param    Buying_Influence__c     Object of Buying influence record
     * ───────────────────────────────────────────────────────────────────────────────────────────────┘
     */

    public BuyingInfluenceWrapperClass(Buying_Influence__c bi) {
        this.Id = bi.Id;
        this.name = bi.Name;
        this.blueSheet = bi.Blue_Sheet__c;
        this.businessResults = bi.Business_Results__c;
        this.contact = bi.Contact__c;
        this.contactFname = bi.Contact__r.FirstName;
        this.contactLname = bi.Contact__r.LastName;
        this.MailingState = bi.Contact__r.MailingState;
        this.MailingCountry = bi.Contact__r.MailingCountry;
        this.buyingFromUs = bi.Buying_From_Us__c;
        this.buyingfromSomeoneElse = bi.Buying_from_Someone_Else__c;
        this.coach = bi.Coach__c;
        this.doingNothing = bi.Doing_Nothing__c;
        this.economic = bi.Economic__c;
        this.evenKeel = bi.Even_Keel__c;
        this.growth = bi.Growth__c;
        this.high = bi.High__c;
        this.location = bi.Location__c;
        this.low = bi.Low__c;
        this.medium = bi.Medium__c;
        this.overConfident = bi.Over_Confident__c;
        this.personalWins = bi.Personal_Wins__c;
        this.rating = bi.Rating__c;
        this.ratingEvidence = bi.Rating_Evidence__c;
        this.ratingText = bi.Rating_Text__c;
        this.searchCompetitor = bi.Search_Competitor__c;
        this.technical = bi.Technical__c;
        this.title = bi.Title__c;
        this.trouble = bi.Trouble__c;
        this.user = bi.User__c;
        this.usingBudget = bi.Using_Budget_for_Something_Else__c;
        this.internalResources = bi.Using_Internal_Resources__c;
        this.biRole = new List<String>();
        this.biRoleListWithSpaces = '';
        this.mode = '';
        this.compPref = '';
        this.degree = '';
        this.businessResults1 = '';
        this.businessResults2 = '';
        this.brShowMoreText = false;
        this.brShowLessText = false;
        this.rfsMarkerWrapper = new List<RedFlagStrengthMarkerWrapper>();
    }

    /**
     * ───────────────────────────────────────────────────────────────────────────────────────────────┐
     * Parameter constructor that accepts BuyingInfluenceWrapperClass object and returns it as BuyingInfluence object.
     * ────────────────────────────────────────────────────────────────────────────────────────────────
     * @param    Buying_Influence__c     Object of Buying influence record
     * @return   Buying_Influence__c     Object of Buying_Influence__c
     * ───────────────────────────────────────────────────────────────────────────────────────────────┘
     */
    public static Buying_Influence__c convertWrapperToObject(BuyingInfluenceWrapperClass biWrapper) {
        Buying_Influence__c bi = new Buying_Influence__c();
        //bi.Id= biWrapper.Id;
        //bi.Name=biWrapper.name;
        bi.Blue_Sheet__c = biWrapper.blueSheet;
        bi.Business_Results__c = biWrapper.businessResults;
        //bi.Business_Results__c=biWrapper.businessResults1;
        bi.Contact__c = biWrapper.contact;
        bi.Buying_From_Us__c = biWrapper.buyingFromUs;
        bi.Buying_from_Someone_Else__c = biWrapper.buyingfromSomeoneElse;
        bi.Coach__c = biWrapper.coach;
        bi.Doing_Nothing__c = biWrapper.doingNothing;
        bi.Economic__c = biWrapper.economic;
        bi.Even_Keel__c = biWrapper.evenKeel;
        bi.Growth__c = biWrapper.growth;
        bi.High__c = biWrapper.high;
        //bi.Location__c=biWrapper.location;
        bi.Low__c = biWrapper.low;
        bi.Medium__c = biWrapper.medium;
        bi.Over_Confident__c = biWrapper.overConfident;
        bi.Personal_Wins__c = biWrapper.personalWins;
        bi.Rating__c = biWrapper.rating;
        bi.Rating_Evidence__c = biWrapper.ratingEvidence;
        //bi.Rating_Text__c=biWrapper.ratingText;
        //bi.Search_Competitor__c=biWrapper.searchCompetitor;
        if (biWrapper.searchCompetitor == '') {
            bi.Search_Competitor__c = null;
        } else {
            bi.Search_Competitor__c = biWrapper.searchCompetitor;
        }
        bi.Technical__c = biWrapper.technical;
        //bi.Title__c=biWrapper.title;
        bi.Trouble__c = biWrapper.trouble;
        bi.User__c = biWrapper.user;
        bi.Using_Budget_for_Something_Else__c = biWrapper.usingBudget;
        bi.Using_Internal_Resources__c = biWrapper.internalResources;

        return bi;
    }
}