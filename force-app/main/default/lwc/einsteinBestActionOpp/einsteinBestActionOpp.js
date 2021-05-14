import { LightningElement, api } from "lwc";
import NextBest from "@salesforce/resourceUrl/Next_Best";
import ScorecardRequiredField from "@salesforce/label/c.ScorecardRequiredField";
import LoremIpsumDolor from "@salesforce/label/c.LoremIpsumDolor";
import CurabiturEgestas from "@salesforce/label/c.CurabiturEgestas";
import CreateNow from "@salesforce/label/c.CreateNow";
import Ignore from "@salesforce/label/c.Ignore";
import LooksLikeALink from "@salesforce/label/c.LooksLikeALink";

export default class EinsteinBestActionOpp extends LightningElement {
    label = {
        ScorecardRequiredField,
        LoremIpsumDolor,
        CurabiturEgestas,
        CreateNow,
        Ignore,
        LooksLikeALink
    };

    @api imageLink = NextBest;
}