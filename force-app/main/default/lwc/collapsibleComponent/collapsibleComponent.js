import { LightningElement, track, api } from "lwc";
import greensheetssoapi from "@salesforce/apex/SsoGreenSheet.getSSOGreenSheet";
import checkAccess from "@salesforce/apex/OurCompanyAttendees.getCompanyAccess";
import AddNewFoP from "@salesforce/label/c.AddNewFoP";

export default class CollapsibleComponent extends LightningElement {
    @track isExpandableView = true;
    @api titleHeader;
    @api objectText;
    @api ssoView;
    @api biView;
    @api givingInfo;
    @api giView;
    @api issueView;
    @api compAttendView;
    @api companyView;
    @api ssoHeaderNavURL;
    @api commitmentView;
    @api getIdFromParent;
    @track showSSo = false;
    @api isaddNew;
    @api newModal = false;
    @track ssoobj;
    @api headerNavURL;
    @track maincontainer = "slds-card slds-card_boundary";
    @track isIconVisible = false;
    @track isCreateable;
    @track isUpdateable;
    @track isDeletable;

    label = {
        AddNewFoP
    };

    @api
    get showIcon() {
        return this.isIconVisible;
    }
    set showIcon(value) {
        this.isIconVisible = value;
    }
    handleToggleSection() {
        //    this.isaddNew = true;
        this.isExpandableView = !this.isExpandableView;
    }

    connectedCallback() {
        this.getCompanyData();
        greensheetssoapi({ greenSheetId: this.getIdFromParent })
            .then(res => {
                if (res.length > 0) {
                    this.showSSo = true;
                    this.ssoobj = res;
                } else {
                    this.showSSo = false;
                }
            })
            .catch(() => {});
    }

    getCompanyData() {
        checkAccess().then(result => {
            this.isCreateable = result.isCreateable;
            this.isUpdateable = result.isUpdateable;
            this.isDeletable = result.isDeletable;
        });
    }

    handleAddNew() {
        if (!this.isExpandableView) {
            this.isExpandableView = true;

            // eslint-disable-next-line
            setTimeout(() => {
                this.newModal = true;
                this.template.querySelector("c-our-company-attendees").handleAddNew();
            }, 1400);
            // eslint-enable-next-line
        } else {
            this.newModal = true;
            this.template.querySelector("c-our-company-attendees").handleAddNew();
        }
    }
}