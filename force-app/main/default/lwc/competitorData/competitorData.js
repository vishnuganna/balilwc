import { LightningElement, api, track } from "lwc";
import removeCompetition from "@salesforce/apex/Competition.removeCompetition";
import updateCompetitorData from "@salesforce/apex/Competition.updateCompetitorData";
import objectForLookup from "@salesforce/apex/Competition.getObjectName";
import addCompetitior from "@salesforce/label/c.addCompetitior";
import buyingFromSomeOneElse from "@salesforce/label/c.buyingFromSomeOneElse";
import close from "@salesforce/label/c.close";
import competitionLabel from "@salesforce/label/c.competition";
import competitionTypeLabel from "@salesforce/label/c.competitionType";
import competitior from "@salesforce/label/c.competitior";
import competitiveDetail from "@salesforce/label/c.competitiveDetail";
import competitiveDetails from "@salesforce/label/c.competitiveDetails";
import deleteCompetition from "@salesforce/label/c.deleteCompetition";
import CompetitiondeleteMessage from "@salesforce/label/c.CompetitiondeleteMessage";
import doingNothing from "@salesforce/label/c.doingNothing";
import frontRunner from "@salesforce/label/c.frontRunner";
import myPositionvsCompetitior from "@salesforce/label/c.myPositionvsCompetitior";
import no from "@salesforce/label/c.no";
import onlyAlternative from "@salesforce/label/c.onlyAlternative";
import searchCompetitior from "@salesforce/label/c.searchCompetitior";
import shared from "@salesforce/label/c.shared";
import showLess from "@salesforce/label/c.showLess";
import showMore from "@salesforce/label/c.showMore";
import usingBudgetforSomething from "@salesforce/label/c.usingBudgetforSomething";
import usingInternalResource from "@salesforce/label/c.usingInternalResource";
import yes from "@salesforce/label/c.yes";
import zero from "@salesforce/label/c.zero";
import cancel from "@salesforce/label/c.cancel";
import save from "@salesforce/label/c.save";
import edit from "@salesforce/label/c.edit";
import deleteLabel from "@salesforce/label/c.delete";
import successheader from "@salesforce/label/c.success_header";
import errorheader from "@salesforce/label/c.error_header";
import deletemsg from "@salesforce/label/c.Record_delete_message";
import errormsg from "@salesforce/label/c.Record_error_message";
import successmsg from "@salesforce/label/c.Record_success_message";
import CompetitionHeaderURL from "@salesforce/label/c.CompetitionHeaderURL";
import myPosVsCompetitionURL from "@salesforce/label/c.myPosVsCompetitionURL";
import maxLimitErrorLabel from "@salesforce/label/c.maxLimitError";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import checkAccess from "@salesforce/apex/Competition.getCompetitionAccess";
import pubsub from "c/pubSub";
import Scorecard_Template_Required_Error from "@salesforce/label/c.Scorecard_Template_Required_Error";

export default class CompetitorData extends LightningElement {
    @api item;
    @track showEditView = false;
    @track ShowModal = false;
    @track ShowMoreText = false;
    @track showText = false;
    @track showLookUp = true;
    @track showAccountError = false;
    competitorId;
    competitiorData;
    @track competitiveDetail1 = "";
    @track competitiveDetail2 = "";
    @api parentid;
    @track iconname = "";
    @track iconcolor;
    @track result;

    @track compDetails = "";
    @track competitiorNameField;
    @track competitortypebutton;
    @track mypositionbutton = "";
    @track accountIdVar;
    @track rfsMarker;
    @track redFlagStrengthUpdateResult;

    renderData = true;

    @track showMaxLimitError = false;
    currentRecordItem;

    @track onlyalternative = false;
    @track frontrunner = false;
    @track shared = false;
    @track zero = false;
    @api showonbs = false;

    @track isUpdateable = false;
    @track isDeletable = false;
    @track showSaveButton = false;
    @track isRequired = true;

    label = {
        addCompetitior,
        buyingFromSomeOneElse,
        close,
        competitionLabel,
        competitionTypeLabel,
        competitior,
        competitiveDetail,
        competitiveDetails,
        deleteCompetition,
        CompetitiondeleteMessage,
        doingNothing,
        frontRunner,
        myPositionvsCompetitior,
        no,
        onlyAlternative,
        searchCompetitior,
        shared,
        showLess,
        showMore,
        usingBudgetforSomething,
        usingInternalResource,
        yes,
        zero,
        cancel,
        save,
        edit,
        deleteLabel,
        maxLimitErrorLabel,
        successheader,
        errorheader,
        deletemsg,
        errormsg,
        successmsg,
        CompetitionHeaderURL,
        myPosVsCompetitionURL,
        Scorecard_Template_Required_Error
    };

    @track
    rfsDetails = {};

    convertMarkerMap() {
        const markers = this.currentRecordItem.rfsMarkerWrapper;
        const markersMap = this.getNewRfsDetails();
        markers.forEach(marker => {
            markersMap[marker.fieldApiName] = marker;
        });
        return markersMap;
    }

    getNewRfsDetails() {
        return {
            competitor: {
                redFlagSelected: false,
                strengthSelected: false,
                noneSelected: true,
                fieldApiName: "competitor"
            },
            competitiveDetail: {
                redFlagSelected: false,
                strengthSelected: false,
                noneSelected: true,
                fieldApiName: "competitiveDetail"
            }
        };
    }

    //If marker updated then updated
    handleMarkerChange(event) {
        const eventChangedMarker = event.detail;
        const rfsDetailsUpdate = JSON.parse(JSON.stringify(this.rfsDetails[eventChangedMarker.fieldApiName]));
        if (rfsDetailsUpdate != null) {
            Object.keys(rfsDetailsUpdate).forEach(key => {
                if (eventChangedMarker[key] !== undefined && eventChangedMarker[key] !== null) {
                    rfsDetailsUpdate[key] = eventChangedMarker[key];
                }
            });
            this.rfsDetails[eventChangedMarker.fieldApiName] = rfsDetailsUpdate;
        }
    }

    connectedCallback() {
        this.showonbs = true;
        this.currentRecordItem = JSON.parse(JSON.stringify(this.item));

        this.competitortypebutton = this.currentRecordItem.competitorType;
        this.mypositionbutton = this.currentRecordItem.myPositionVsCompetitor;
        this.compDetails = this.currentRecordItem.competitiveDetail;
        this.rfsDetails = this.convertMarkerMap();
        this.competitiorNameField = this.currentRecordItem.competitiorTyepName;
        this.accountIdVar = this.currentRecordItem.accountId;
        if (this.currentRecordItem.competitiorTyepName) {
            this.showLookUp = false;
        } else {
            this.showLookUp = true;
        }
        this.item = this.currentRecordItem;

        this.showIconForPosition();
        this.handleshowMoreless();

        checkAccess().then(result => {
            this.isUpdateable = result.isUpdateable;
            this.isDeletable = result.isDeletable;
        });
        objectForLookup().then(result => {
            this.objectForLookup = result.lookupOnObject;
            this.lookuptargetField = result.targetField;
        });
    }

    showIconForPosition() {
        this.onlyalternative = false;
        this.frontrunner = false;
        this.shared = false;
        this.zero = false;
        if (this.mypositionbutton === "Only Alternative") {
            this.onlyalternative = true;
        } else if (this.mypositionbutton === "Front Runner") {
            this.frontrunner = true;
        } else if (this.mypositionbutton === "Shared") {
            this.shared = true;
        } else if (this.mypositionbutton === "Zero") {
            this.zero = true;
        }
    }

    handleShowMore() {
        this.showText = true;
        this.ShowMoreText = false;
        this.ShowLessText = true;
    }
    handleShowLess() {
        this.showText = false;
        this.ShowLessText = false;
        this.ShowMoreText = true;
        if (this.template.querySelector(".divClass") != null) {
            this.template.querySelector(".divClass").scrollIntoView(true);
        }
    }
    handleshowMoreless() {
        var description = this.item.competitiveDetail;
        if (description) {
            if (description.length > 100) {
                this.competitiveDetail1 = "";
                this.competitiveDetail2 = "";
                this.competitiveDetail1 = description.substr(0, 100);
                this.competitiveDetail2 = description.substr(100, description.length);
                this.ShowMoreText = true;
            } else {
                this.competitiveDetail1 = description;
                this.competitiveDetail2 = "";
                this.ShowMoreText = false;
                this.ShowLessText = false;
            }
        }
    }
    //call method after page elements are rendered in order to get elements with classes
    renderedCallback() {
        let tempItem = JSON.parse(JSON.stringify(this.item));

        if (this.renderData === true) {
            this.template.querySelectorAll(".competitorpositionButtons").forEach(function(el) {
                //find the button with value saved in backend
                if (tempItem.myPositionVsCompetitor === el.value) {
                    el.classList.add("btnClicked");
                }
            });
            this.template.querySelectorAll(".competitorTypeButtons").forEach(function(el) {
                //find the button with value saved in backend
                if (tempItem.competitorType === el.value) {
                    el.classList.add("btnClicked");
                }
            });
        }
        this.renderData = false;
    }

    handleEdit() {
        this.showSaveButton = false;
        this.renderData = true;
        this.compDetails = this.currentRecordItem.competitiveDetail;
        this.competitiorNameField = this.currentRecordItem.competitiorTyepName;
        this.competitortypebutton = this.currentRecordItem.competitorType;
        this.mypositionbutton = this.currentRecordItem.myPositionVsCompetitor;
        this.accountIdVar = this.currentRecordItem.accountId;
        this.rfsDetails = this.convertMarkerMap();
        this.showText = false;
        this.ShowLessText = false;
        this.ShowMoreText = true;
        if (this.competitortypebutton !== "Buying from Someone Else") {
            this.showLookUp = false;
        } else {
            this.showLookUp = true;
        }

        this.showEditView = true;
        const selectedEvent = new CustomEvent("editclicked", {
            detail: true
        });
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
    }

    callButtonShowEvent() {
        const selectedEvent = new CustomEvent("enablebutton", {
            detail: true
        });
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
    }

    handleCancel() {
        this.compDetails = this.currentRecordItem.competitiveDetail;
        this.competitiorNameField = this.currentRecordItem.competitiorTyepName;
        this.competitortypebutton = this.currentRecordItem.competitorType;
        this.mypositionbutton = this.currentRecordItem.myPositionVsCompetitor;
        this.accountIdVar = this.currentRecordItem.accountId;
        if (this.accountIdVar) {
            this.showLookUp = true;
        } else {
            this.showLookUp = false;
        }

        //  alert(this.currentRecordItem.accountName);

        this.showEditView = false;
        this.showAccountError = false;
        this.rfsDetails = this.convertMarkerMap();
        this.callButtonShowEvent();
    }
    handleTextChange(event) {
        this.compDetails = event.target.value;
    }
    handleContactChange(event) {
        this.accountIdVar = event.detail.selectedRecordId;
        if (this.accountIdVar) {
            this.showAccountError = false;
            this.competitiorNameField = "";
        }

        if (this.accountIdVar && this.accountIdVar.length > 0) {
            this.showSaveButton = false;
        } else {
            this.showSaveButton = true;
        }
    }
    handleCompetitionType(event) {
        this.competitortypebutton = event.target.value;
        this.accountIdVar = event.detail;
        this.showSaveButton = false;

        if (this.accountIdVar === undefined || this.accountIdVar === "") {
            this.showAccountError = true;
            this.showSaveButton = true;
        } else {
            this.showSaveButton = false;
        }

        if (event.target.value !== "Buying from Someone Else") {
            this.competitiorNameField = event.target.value;
            this.showLookUp = false;
            this.accountIdVar = null;
            this.showSaveButton = false;
        } else {
            this.showSaveButton = true;
            this.showLookUp = true;
            if (this.accountIdVar) {
                this.showAccountError = true;
            }
        }
        this.template.querySelectorAll(".competitorTypeButtons").forEach(function(el) {
            el.classList.remove("btnClicked");
        });
        event.currentTarget.classList.toggle("btnClicked");
    }
    handlepositionVsCompetitor(event) {
        this.mypositionbutton = event.currentTarget.value;
        this.showIconForPosition();
        this.template.querySelectorAll(".competitorpositionButtons").forEach(function(el) {
            el.classList.remove("btnClicked");
        });
        event.currentTarget.classList.toggle("btnClicked");
    }

    dispatchEventToParent() {
        const selectedEvent = new CustomEvent("updateprogressfromchild", {
            detail: true
        });
        this.dispatchEvent(selectedEvent);
    }

    handleDelete(event) {
        this.ShowModal = true;
        this.competitorId = event.target.value;
    }
    deleteModal() {
        this.ShowModal = false;

        removeCompetition({ recordId: this.competitorId, oppId: this.parentid })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.label.successheader,
                        message: this.label.deletemsg,
                        variant: "success"
                    })
                );
                pubsub.fire("refreshBestActionGrid", "");
                //call a event and pass result as prameter to parent
                const selectedEvent = new CustomEvent("deleterecord", {
                    detail: true
                });

                // Dispatches the event.
                this.dispatchEvent(selectedEvent);
            })
            .catch(() => {
                this.Result = undefined;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.label.errorheader,
                        message: this.label.errormsg,
                        variant: "error"
                    })
                );
            });
    }
    closeModal() {
        this.ShowModal = false;
    }
    handleSave() {
        //this.competitiorData = event.target.value;
        if (
            this.competitortypebutton !== "Buying from Someone Else" ||
            (this.competitortypebutton === "Buying from Someone Else" &&
                this.accountIdVar != null &&
                this.accountIdVar !== "")
        ) {
            let tempItem = JSON.parse(JSON.stringify(this.item));

            let IPDetails = {
                recordId: tempItem.id,
                compType: this.competitortypebutton,
                posVsCmp: this.mypositionbutton,
                details: this.compDetails,
                compNameType: this.competitiorNameField,
                accountId: this.accountIdVar
            };

            //updateCompetitorData ({competitorData:JSON.stringify(this.competitiorData),oppId:this.parentid})
            updateCompetitorData({ competitorData: IPDetails, oppId: this.parentid, rfsData: this.rfsDetails })
                .then(() => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: this.label.successheader,
                            message: this.label.successmsg,
                            variant: "success"
                        })
                    );
                    //call a event and pass result as prameter to parent
                    const selectedEvent = new CustomEvent("deleterecord", {
                        detail: true
                    });
                    // Dispatches the event.
                    this.dispatchEvent(selectedEvent);
                    this.dispatchEventToParent();
                    pubsub.fire("refreshBestActionGrid", "");
                })
                .catch(() => {
                    this.Result = undefined;
                });
            if (this.accountIdVar) {
                this.showLookUp = true;
            }
            this.showEditView = false;
            this.handleshowMoreless();
            this.showIconForPosition();
            this.callButtonShowEvent();
        } else {
            this.showAccountError = true;
            this.showSaveButton = true;
        }
    }
    handleMaxLimitError(event) {
        var checkCompetitionTypeLimit = event.target.value;
        if (checkCompetitionTypeLimit.length === 32000 && checkCompetitionTypeLimit !== "") {
            this.showMaxLimitError = true;
        } else {
            this.showMaxLimitError = false;
        }
    }
}