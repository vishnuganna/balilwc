import { LightningElement, track, api } from "lwc";

import revenue from "@salesforce/label/c.Revenue";
import csoPDF from "@salesforce/label/c.csoPDF";
import closeDate from "@salesforce/label/c.CloseDate";
import Customer_Timing_for_Priorities from "@salesforce/label/c.Customer_Timing_for_Priorities";
import Evaluation_of_Objective from "@salesforce/label/c.Evaluation_of_Objective";
import place_in_sales_funnel from "@salesforce/label/c.place_in_sales_funnel";
import LOCALE from "@salesforce/i18n/locale";

export default class GreensheetSso extends LightningElement {
    @track revenue;
    @track place_in_sales;
    @track closedate;
    @track customer_timing_status;
    @track Customer_Timing_for_Priorities;
    @track evaluationobj;

    @track _ssoData;

    @api
    get ssoData() {
        return this._ssoData;
    }

    set ssoData(value) {
        this.handledata(value[0]);
        this._ssoData = value;
    }

    label = {
        revenue,
        csoPDF,
        closeDate,
        place_in_sales_funnel,
        Customer_Timing_for_Priorities,
        Evaluation_of_Objective
    };

    handledata(obj) {
        this.revenue = obj.oppRevenue;
        this.place_in_sales = obj.oppStage;
        this.closedate = new Intl.DateTimeFormat(LOCALE).format(new Date(obj.oppCloseDate));
        if (obj.gsSSOWrapper) {
            this.customer_timing_status = obj.gsSSOWrapper.custTimingPriorities;
            this.Customer_Timing_for_Priorities = obj.gsSSOWrapper.customerStatedObjective;
            this.evaluationobj = obj.gsSSOWrapper.evaluationOfObjectives;
        }
    }
}