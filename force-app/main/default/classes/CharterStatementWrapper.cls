/*******************************************************************************************
 * @Name         CharterStatementWrapper
 * @Author       Janakiram Bali
 * @Date         2020-08-03
 * @Group
 * @Description  KFS-333 -
 *******************************************************************************************/
/* MODIFICATION LOG
 * Version          Developer          Date               Description
 *-------------------------------------------------------------------------------------------
 *  1.0             Janakiram Bali     2020-08-03          Initial Creation
 *********************************************************************
 */
public class CharterStatementWrapper {
    @AuraEnabled
    public String charterStatement { get; set; }
    @AuraEnabled
    public String goldsheetId { get; set; }
    @AuraEnabled
    public boolean hasEditAccess { get; set; }
    @AuraEnabled
    public List<RedFlagStrengthMarkerWrapper> rfsMarkerWrapper { get; set; }
    @AuraEnabled
    public Map<String, RedFlagStrengthMarkerWrapper> rfsMarkerPdfWrapper { get; set; }

    @SuppressWarnings('PMD.EmptyStatementBlock')
    public CharterStatementWrapper() {
    }

    public CharterStatementWrapper(Gold_Sheet__c gsRecord, boolean isUpdatable) {
        this.charterStatement = gsRecord.Charter_Statement__c;
        this.goldsheetId = gsRecord.Id;
        this.hasEditAccess = isUpdatable;
        this.rfsMarkerWrapper = new List<RedFlagStrengthMarkerWrapper>();
    }
}