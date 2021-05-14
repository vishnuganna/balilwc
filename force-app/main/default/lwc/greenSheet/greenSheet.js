import { api, LightningElement, track } from "lwc";
import ssoGreenSheetURL from "@salesforce/label/c.sSoHeaderURL";
import ssoHeader from "@salesforce/label/c.SingleSalesObjectiveRevenue";
import greensheetaccessapi from "@salesforce/apex/SsoGreenSheet.getGreenSheetAccess";
import buyingInfluence from "@salesforce/label/c.buyingInfluence";
import GSbuying_InfluenceHeaderURL from "@salesforce/label/c.GSbuying_InfluenceHeaderURL";
import gettingInformation from "@salesforce/label/c.gettingInformation";
import gettingInformationHeaderURL from "@salesforce/label/c.gettingInformationHeaderURL";
import basicIssueHeader from "@salesforce/label/c.basicIssueHeader";
import basicIssueHeaderURL from "@salesforce/label/c.basicIssueHeaderURL";
import givingInfoHeaderURL from "@salesforce/label/c.giving_Info_URL";
import greensheetssoapi from "@salesforce/apex/SsoGreenSheet.getSSOGreenSheet";
import GSGetting_CommitmentURL from "@salesforce/label/c.GSGetting_CommitmentURL";
import GSGetting_Commitment from "@salesforce/label/c.GSGetting_Commitment";
import OurCompanyAttendees from "@salesforce/label/c.OurCompanyAttendees";
import LWCComponentPlace from "@salesforce/label/c.LWCComponentPlace";
import PlaceBILWC from "@salesforce/label/c.PlaceBILWC";
import giving_Info_Giving_Information from "@salesforce/label/c.giving_Info_Giving_Information";

export default class GreenSheet extends LightningElement {
    @api recordId;
    @api titleHeader;
    @api objectText;
    @api ssoView = false;
    @api biView = false;
    @api compAttendView = false;
    @api isaddNew = false;
    @api companyView = false;
    @track showgreensheet = false;
    @api newRecordModalFlag;
    @track showSSo = false;

    allLabel = {
        ssoGreenSheetURL,
        ssoHeader,
        buyingInfluence,
        GSbuying_InfluenceHeaderURL,
        basicIssueHeader,
        basicIssueHeaderURL,
        gettingInformation,
        gettingInformationHeaderURL,
        givingInfoHeaderURL,
        GSGetting_CommitmentURL,
        GSGetting_Commitment,
        OurCompanyAttendees,
        LWCComponentPlace,
        PlaceBILWC,
        giving_Info_Giving_Information
    };

    connectedCallback() {
        greensheetaccessapi()
            .then(res => {
                if (res.isViewable) {
                    this.showgreensheet = true;
                } else {
                    this.showgreensheet = false;
                }
            })
            .catch(() => {});

        greensheetssoapi({ greenSheetId: this.recordId })
            .then(res => {
                if (res.length > 0) {
                    this.showSSo = true;
                } else {
                    this.showSSo = false;
                }
            })
            .catch(() => {});
    }
}