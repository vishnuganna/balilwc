/*import { LightningElement, track, wire, api } from 'lwc';
/*import {createRecord, getRecord, updateRecord, generateRecordInputForUpdate, getFieldValue} from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import SSO_OBJECT from '@salesforce/schema/Single_Sales_Objective__c';
import CUSTOMER_TIMING_FOR_PRIORITIES_FIELD from '@salesforce/schema/Single_Sales_Objective__c.Customer_Timing_for_Priorities__c';
import CUSTOMERS_STATED_OBJECTIVES_FIELD from '@salesforce/schema/Single_Sales_Objective__c.Customers_Stated_Objectives__c';
import EVALUATION_OF_OBJECTIVES_FIELD from '@salesforce/schema/Single_Sales_Objective__c.Evaluation_of_Objectives__c';
import BLUESHEETID_FIELD from '@salesforce/schema/Single_Sales_Objective__c.Blue_Sheet__c';
import ID_FIELD from '@salesforce/schema/Single_Sales_Objective__c.ID';
import getBlueSheetId from '@salesforce/apex/GetRecordDetailsOfOpportunity.getBlueSheetId';
import getIsRecordExists from '@salesforce/apex/GetRecordDetailsOfOpportunity.IsSingleSalesObject';
import getSingleSalesObject from '@salesforce/apex/GetRecordDetailsOfOpportunity.getSingleSalesObject';*/

export default class SingleSalesObjective {
    /*  @api recordId;
    @track ssoId;
    //@track customerTimingForPriorities;
    @track customersStatedObjective;
    @track evaluationOfObjective;
    @track singleSalesObjective;
    @track value = '';
    @track blueSheetId;
    @track isRecordExists;
    @track singleSalesObject;
    @track createNewRecord = false;
    @track showNewRecordButton = false;
    @track showeditbutton = false;
    @track showErrorEval = false;
    @track showErrorCus = false;
    @track clickedButtonLabel;
    @track SHOW_MORE = 'unexpanded';
    @track SHOW_LESS = 'expanded'; 
    @track recordCreated = false;
    @track laterCheck = false;
    @track workCheck = false;
    @track activeCheck = false;
    @track urgentCheck = false;
    @api getIdFromParent;
    @api objectApiName;
    @track isCancel = false;
    @track isSaveClicked = false;
    @track ShowMoreText = false;
    @track ShowLessText = false;
    @track showText = false;
    @track ShowMoreTextEval = false;
    @track ShowLessTextEval = false;
    @track showTextEval = false;
    @track customersStatedObjective1;
    @track customersStatedObjective2;
    @track evaluationOfObjective1;
    @track evaluationOfObjective2;

    connectedCallback(){
        this.recordId = this.getIdFromParent;
        console.log( 'Opportunity Id:'+ this.recordId);
        getBlueSheetId({opptId: this.recordId})
		.then (result=>{
           
            this.blueSheetId = result;
            console.log( 'Bluesheet1234'+ this.blueSheetId);
            
		})
		.catch(error => {
			console.log('Error getIsRecordExists' +JSON.stringify(error));
        });
        
        
        getIsRecordExists({opptId: this.recordId})
		.then (result=>{
			this.isRecordExists = result;
			
		})
		.catch(error => {
			console.log('Error getIsRecordExists');
        });
        
        getSingleSalesObject({opptId: this.recordId})
		.then (result=>{
            console.log('Single Sales Object1'+this.recordId );
            //console.log('Single Sales Object2'+result );
            this.singleSalesObject = result;
            
            

			if (this.singleSalesObject === null) {
				this.showNewRecordButton = true;
				this.createNewRecord = false;
				this.showeditbutton = false;
			} else {
                
                this.ssoId = this.singleSalesObject.Id;
                this.value = this.singleSalesObject.Customer_Timing_for_Priorities__c;
                this.customersStatedObjective = this.singleSalesObject.Customers_Stated_Objectives__c;
                var customerDescription = this.customersStatedObjective;
                if(customerDescription.length > 100){
                    this.customersStatedObjective1=customerDescription.substr(0,100);
                    this.customersStatedObjective2=customerDescription.substr(100,customerDescription.length);                     
                    this.ShowMoreText =true;
                    this.ShowLessText=false;
                }else{
                    this.customersStatedObjective1=customerDescription;
                    this.customersStatedObjective2='';
                    this.ShowMoreText =false;
                    this.ShowLessText=false;
                }
                this.evaluationOfObjective = this.singleSalesObject.Evaluation_of_Objectives__c;
                var evaluationDescription = this.evaluationOfObjective;
                if(evaluationDescription.length > 100){   
                    this.evaluationOfObjective1=evaluationDescription.substr(0,100);
                    this.evaluationOfObjective2=evaluationDescription.substr(100,evaluationDescription.length); 
                    this.ShowMoreTextEval =true;
                    this.ShowLessTextEval =false;
                }else{
                    this.evaluationOfObjective1=evaluationDescription;
                    this.evaluationOfObjective2='';
                    this.ShowMoreTextEval =false;
                    this.ShowLessTextEval=false;
                }

                var customerDescription = this.customersStatedObjective;
                if(customerDescription.length > 100){
                    this.customersStatedObjective1=customerDescription.substr(0,100);
                    this.customersStatedObjective2=customerDescription.substr(100,customerDescription.length);                     
                    this.ShowMoreText =true;
                    this.ShowLessText=false;
                }else{
                    this.customersStatedObjective1=customerDescription;
                    this.customersStatedObjective2='';
                    this.ShowMoreText =false;
                    this.ShowLessText=false;
                }
                this.evaluationOfObjective = this.singleSalesObject.Evaluation_of_Objectives__c;
                var evaluationDescription = this.evaluationOfObjective;
                if(evaluationDescription.length > 100){   
                    this.evaluationOfObjective1=evaluationDescription.substr(0,100);
                    this.evaluationOfObjective2=evaluationDescription.substr(100,evaluationDescription.length); 
                    this.ShowMoreTextEval =true;
                }else{
                    this.evaluationOfObjective1=evaluationDescription;
                    this.evaluationOfObjective2='';
                    this.ShowMoreTextEval =false;
                    this.ShowLessTextEval=false;
                }
                
				this.showeditbutton = true;
				this.showNewRecordButton = false;
				this.createNewRecord = false;
			}
		})
		.catch(error => {
			console.log('Error getSingleSalesObject');
		});
    }

    // retrieving the data using wire service
    @wire(getSingleSalesObject, { opptId: '$recordId'})
    sso({ error, data }) {
        if (data) {
            this.singleSalesObject = data;
            if(this.singleSalesObject !== null){
                this.ssoId = this.singleSalesObject.Id;
                this.value = this.singleSalesObject.Customer_Timing_for_Priorities__c;
                this.customersStatedObjective = this.singleSalesObject.Customers_Stated_Objectives__c;
                this.evaluationOfObjective = this.singleSalesObject.Evaluation_of_Objectives__c;
				this.showeditbutton = true;
				this.showNewRecordButton = false;
				this.createNewRecord = false;
            }
        } 
    }

    

    handleShowMore(event) {
        this.showText= true;
        this.ShowMoreText =false;
        this.ShowLessText=true;
    }
    handleShowLess(event) {
        this.showText= false;
        this.ShowMoreText =true;
        this.ShowLessText=false;
        var customerDescription = this.customersStatedObjective;
        if(customerDescription.length > 100){
            this.customersStatedObjective1=customerDescription.substr(0,100);
        }
        this.template.querySelector('[data-id="XXXreadlcso1-up"]').scrollIntoView();
    }
    handleShowMoreEval(event) {
        this.showTextEval= true;
        this.ShowMoreTextEval =false;
        this.ShowLessTextEval=true;
    }
    handleShowLessEval(event) {
        this.showTextEval= false;
        this.ShowMoreTextEval =true;
        this.ShowLessTextEval=false;
        var evaluationDescription = this.evaluationOfObjective;
        if(evaluationDescription.length > 100){   
            this.evaluationOfObjective1=evaluationDescription.substr(0,100);
        }
        this.template.querySelector('[data-id="XXXreadlcso1-up"]').scrollIntoView();
    }

    handleClickEdit(event) {
        
        this.showeditbutton = false;
        this.createNewRecord = true;
        
       // getSingleSalesObject({opptId: this.recordId})
		//.then (result=>{
           // console.log('Single Sales Object1'+this.recordId );
           // this.singleSalesObject = result;
        //})
		//.catch(error => {
			//alert('Error getSingleSalesObject');
		//});
         
        //this.value = this.singleSalesObject.Customer_Timing_for_Priorities__c; 

        getSingleSalesObject({opptId: this.recordId})
		.then (result=>{
            console.log('Single Sales Object1'+this.recordId );
            //console.log('Single Sales Object2'+ JSON.stringify(result));
            
            this.singleSalesObject = result;
            
            if(this.singleSalesObject !== null){
                this.ssoId = this.singleSalesObject.Id;
                this.value = this.singleSalesObject.Customer_Timing_for_Priorities__c;
                this.customersStatedObjective = this.singleSalesObject.Customers_Stated_Objectives__c;
                this.evaluationOfObjective = this.singleSalesObject.Evaluation_of_Objectives__c;
                console.log('Single Sales Object1111'+this.customersStatedObjective.length );
                console.log('Single Sales Object2222'+this.evaluationOfObjective.length);
                if(this.customersStatedObjective === '-'){
                    this.customersStatedObjective = '';
                }
                if(this.evaluationOfObjective  === '-'){
                    this.evaluationOfObjective = '';
                }
            } 
            
				
		})
		.catch(error => {
			console.log('Error getSingleSalesObject');
        });
        console.log('Single Sales Object3333'+this.customersStatedObjective.length );
        console.log('Single Sales Object4444'+this.evaluationOfObjective.length);
        if(this.customersStatedObjective === '-'){
            this.customersStatedObjective = '';
        }
        if(this.evaluationOfObjective  === '-'){
            this.evaluationOfObjective = '';
        }
        if (this.value === undefined) {
            this.urgentCheck = false;
            this.laterCheck = false;
            this.workCheck = false;
            this.activeCheck = false;
        }
        if (this.value === 'Urgent') {
            this.urgentCheck = true;
            this.laterCheck = false;
            this.workCheck = false;
            this.activeCheck = false;
        } 
        if (this.value === 'Active') {
            this.activeCheck = true;
            this.laterCheck = false;
            this.workCheck = false;
            this.urgentCheck = false;
        }
        if (this.value === 'Work It In') {
            this.workCheck = true;
            this.laterCheck = false;
            this.activeCheck = false;
            this.urgentCheck = false;
        }
        if (this.value === 'Later') {
            this.laterCheck = true;
            this.workCheck = false;
            this.activeCheck = false;
            this.urgentCheck = false;
        }
        
    }

   

    handleClickNew(event) {
        this.showNewRecordButton = false;
        this.createNewRecord = true;
        this.showeditbutton = false;
    }

    handleChange3(event) {
        this.value = event.target.value;

        if ((this.value === 'Urgent' && this.urgentCheck === true) || (this.value === 'Active' && this.activeCheck === true) || (this.value === 'Work It In' && this.workCheck === true) || (this.value === 'Later' && this.laterCheck === true)) {
            this.value = '';
            this.urgentCheck = false;
            this.laterCheck = false;
            this.workCheck = false;
            this.activeCheck = false;
        } else {
            if(event.target.value === 'Urgent'){
                this.urgentCheck = true;
                this.laterCheck = false;
                this.workCheck = false;
                this.activeCheck = false;
    
            }
            if(event.target.value === 'Active'){
                this.activeCheck = true;
                this.laterCheck = false;
                this.workCheck = false;
                this.urgentCheck = false;
            }
            if(event.target.value === 'Work It In'){
                this.workCheck = true;
                this.laterCheck = false;
                this.activeCheck = false;
                this.urgentCheck = false;
            }
            if(event.target.value === 'Later'){
                this.laterCheck = true;
                this.workCheck = false;
                this.activeCheck = false;
                this.urgentCheck = false;
            }
        }
    }

    handleChange(event) {
        this.customersStatedObjective = event.target.value;
        this.handleShowMorShowLessAll();
        
    }

    handleChange2(event) {
        this.evaluationOfObjective = event.target.value;
        this.handleShowMorShowLessAll();
        
       // var evaluationOfObjective = event.target.value;
         //       if(evaluationOfObjective.length > 100){
           //         this.evaluationOfObjective1=evaluationOfObjective.substr(0,100);
             //       this.evaluationOfObjective2=evaluationOfObjective.substr(100,evaluationOfObjective.length);                     
               //     this.ShowMoreTextEval =true;
                 //   this.ShowLessTextEval=false;
                //}else{
                  //  if(evaluationOfObjective == ''){
                    //    this.evaluationOfObjective1="-";
                      //  this.evaluationOfObjective2='';
                    //}else{
                    //this.evaluationOfObjective1=evaluationOfObjective;
                    //this.evaluationOfObjective2='';
                    //this.ShowMoreTextEval =false;
                    //this.ShowLessTextEval=false;
                   // }
                //}
                
    }

    handlemaxlengtheval(event) {
        this.evaluationOfObjective = event.target.value;
        if (this.evaluationOfObjective.length === 32000) {
            this.showErrorEval = true;
        }
        else{
            this.showErrorEval = false;
        }
        //alert(this.evaluationOfObjective.length);
    }

    handlemaxlengthCus(event) {
        this.customersStatedObjective = event.target.value;
        //alert(this.customersStatedObjective.length);
        if (this.customersStatedObjective.length === 32000) {
            this.showErrorCus = true;
        }
        else{
            this.showErrorCus = false;
        }
        //alert(this.evaluationOfObjective.length);
    }

    handleradiochange(event){
        this.value = event.target.value;
    }


  

handleShowAll() {
  if(!this.isShowAll){
      this.showMoreClass = SHOW_LESS;
      this.showAllText = 'Show Less';
   } else {
      this.showMoreClass = SHOW_MORE;
      this.showMoreClass = 'Show More';   
   }
   this.isShowAll = !this.isShowAll; 

}

    handleCancel(event) {
       
        if (this.singleSalesObject === null ) {
            this.showeditbutton = false;
            this.createNewRecord = false;
            this.showNewRecordButton = true;
            this.value='';
    
        } else {
            if(this.singleSalesObject.Customer_Timing_for_Priorities__c === 'Urgent'){
                this.urgentCheck = true;
                this.laterCheck = false;
                this.workCheck = false;
                this.activeCheck = false;
    
            }
            if(this.singleSalesObject.Customer_Timing_for_Priorities__c === 'Active'){
                this.activeCheck = true;
                this.laterCheck = false;
                this.workCheck = false;
                this.urgentCheck = false;
            }
            if(this.singleSalesObject.Customer_Timing_for_Priorities__c === 'Work It In'){
                this.workCheck = true;
                this.laterCheck = false;
                this.activeCheck = false;
                this.urgentCheck = false;
            }
            if(this.singleSalesObject.Customer_Timing_for_Priorities__c === 'Later'){
                this.laterCheck = true;
                this.workCheck = false;
                this.activeCheck = false;
                this.urgentCheck = false;
            }
            //console.log(this.value);
            //console.log(this.customersStatedObjective);
            //console.log(this.evaluationOfObjective);
            //console.log(this.customersStatedObjective1);
            //console.log(this.evaluationOfObjective1);

            this.showeditbutton = true;
            this.createNewRecord = false;
            this.showNewRecordButton = false;
        }
        if(this.singleSalesObject !== null){
            this.ssoId = this.singleSalesObject.Id;
            this.value = this.singleSalesObject.Customer_Timing_for_Priorities__c;
            this.customersStatedObjective = this.singleSalesObject.Customers_Stated_Objectives__c;
            this.customersStatedObjective1 = this.customersStatedObjective;
            this.evaluationOfObjective = this.singleSalesObject.Evaluation_of_Objectives__c;
            this.evaluationOfObjective1 = this.evaluationOfObjective;
            this.handleShowMorShowLessAll();
           // console.log(this.value);
        //console.log(this.customersStatedObjective);
        //console.log(this.evaluationOfObjective);
        //console.log(this.customersStatedObjective1);
        //console.log(this.evaluationOfObjective1);
        }else{
            this.value = '';
            this.customersStatedObjective = '';
            this.evaluationOfObjective = '';
        }
        this.laterCheck = false;
        this.workCheck = false;
        this.activeCheck = false;
        this.urgentCheck = false;
        
        this.showErrorEval = false;
        this.showErrorCus = false;
    }

    handleShowMorShowLessAll() {
        var customerDescription = this.customersStatedObjective;
        if (customerDescription != undefined) {
            console.log('cso-');
            if(this.ShowMoreText == true)
            {
                
                if(customerDescription.length > 100){
                    this.customersStatedObjective1=customerDescription.substr(0,100);
                    this.customersStatedObjective2=customerDescription.substr(100,customerDescription.length);                     
                    this.ShowMoreText =true;
                    this.ShowLessText=false;
                }else{
                    this.customersStatedObjective1=customerDescription;
                    this.customersStatedObjective2='';
                    this.ShowMoreText =false;
                    this.ShowLessText=false;
                }
            } else {
                if(customerDescription.length > 100) { 
                    this.customersStatedObjective2 = customerDescription;
                    this.customersStatedObjective1 = '';
                    //console.log('XX:::'+this.singleSalesObject.Customers_Stated_Objectives__c.length);
                    console.log('XX:::'+this.customersStatedObjective2.length);
                    this.showText= true;
                    this.ShowMoreText =false;
                    this.ShowLessText=true;
                } else {
                    this.customersStatedObjective1 = customerDescription;
                    this.customersStatedObjective2 = '';
                    this.ShowMoreText =false;
                    this.ShowLessText=false;
                }
            }
        }
        var evaluationDescription = this.evaluationOfObjective;
        if (evaluationDescription != undefined) {
            if (this.ShowMoreTextEval == true) {
                if(evaluationDescription.length > 100){   
                    this.evaluationOfObjective1=evaluationDescription.substr(0,100);
                    this.evaluationOfObjective2=evaluationDescription.substr(100,evaluationDescription.length); 
                    this.ShowMoreTextEval =true;
                    this.ShowLessTextEval = false;
                }else{
                    this.evaluationOfObjective1=evaluationDescription;
                    this.evaluationOfObjective2='';
                    this.ShowMoreTextEval =false;
                    this.ShowLessTextEval=false;
                }
            } else {
                if(evaluationDescription.length > 100){   
                    this.evaluationOfObjective1 = '';
                    this.evaluationOfObjective2 = evaluationDescription;
                    this.showTextEval= true;
                    this.ShowMoreTextEval =false;
                    this.ShowLessTextEval=true;
                } else {
                    this.evaluationOfObjective1 = evaluationDescription;
                    this.evaluationOfObjective2 = '';
                    this.ShowMoreTextEval =false;
                    this.ShowLessTextEval=false;
                }
            }
        }
    }

    saveSSORec() {

        

        if(this.customersStatedObjective === null || this.customersStatedObjective === undefined || this.customersStatedObjective.trim() === ''){
            
            this.customersStatedObjective = '-';
            
        }
        if(this.evaluationOfObjective === null || this.evaluationOfObjective === undefined || this.evaluationOfObjective.trim() === ''){
            this.evaluationOfObjective = '-';
           
        }
        if(this.value === null || this.value === undefined || this.value.trim() === ''){
            
            this.value = '-';
        }
        
		if(this.singleSalesObject === null && !this.recordCreated){ 
            this.createSSO();
            this.recordCreated = true;
		}
		else{
			this.updateSSO();
        }
       
        if(this.customersStatedObjective === '-' || this.customersStatedObjective === null){
            this.customersStatedObjective1 = '-';
        }
        if(this.evaluationOfObjective === '-' || this.evaluationOfObjective === null){
        this.evaluationOfObjective1 = '-';
        }
        
        this.showeditbutton = true;
        this.createNewRecord = false;
        this.showNewRecordButton = false;
        this.showErrorEval = false;
        this.showErrorCus = false;
        this.isSaveClicked = true;

        
        var customerDescription = this.customersStatedObjective;
        
        this.showMoreShowLessOnCreateUpdate();

        
    }

    createSSO() {


        const fields = {};
        
        fields[CUSTOMER_TIMING_FOR_PRIORITIES_FIELD.fieldApiName] = this.value;
        fields[CUSTOMERS_STATED_OBJECTIVES_FIELD.fieldApiName] = this.customersStatedObjective;
        fields[EVALUATION_OF_OBJECTIVES_FIELD.fieldApiName] = this.evaluationOfObjective;
        fields[BLUESHEETID_FIELD.fieldApiName] = this.blueSheetId;
        const recordInput = { apiName: SSO_OBJECT.objectApiName, fields };
        
        createRecord(recordInput)
            .then(SinglealesObjective => {
            this.ssoId = SinglealesObjective.id;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Record Inserted',
                    variant: 'success',
                }),
            );
           
            return refreshApex(this.singleSalesObject);
        })
        .catch(error => {
            console.log(JSON.stringify(error));
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error creating account ERROR',
                    message: error.body.message,
                    variant: 'error',
                }),
            );
        });
        
    }
	
	updateSSO() {
       
        
        let record = {
            fields: {
                Id: this.ssoId,
                Customer_Timing_for_Priorities__c: this.value,
                Customers_Stated_Objectives__c:this.customersStatedObjective ,
                Evaluation_of_Objectives__c:this.evaluationOfObjective,
               // Blue_Sheet__c:this.blueSheetId.data,
            },
        };        
        updateRecord(record)
            .then(() => {
                
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Record Updated',
                        variant: 'success'
                    })
                );
                return refreshApex(this.singleSalesObject);
            })
        .catch(error => {
            console.log(JSON.stringify(error));
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error updating SingleSalesObjective ERROR',
                    message: error.body.message,
                    variant: 'error',
                }),
            );
        }); 
    }


    showMoreShowLessOnCreateUpdate() {
        if (this.singleSalesObject != null || this.customersStatedObjective.length > 0 || this.evaluationOfObjective >0) {
            //this.customersStatedObjective = this.singleSalesObject.Customers_Stated_Objectives__c;
            var customerDescription = this.customersStatedObjective;
            console.log('::sss:12sd:'+customerDescription.length );
            if(customerDescription.length > 100){
                this.customersStatedObjective1=customerDescription.substr(0,100);
                this.customersStatedObjective2=customerDescription.substr(100,customerDescription.length);                       
                this.ShowMoreText =true;
                this.ShowLessText=false;
                this.showText = false;
            }else{
                this.customersStatedObjective1=customerDescription;
                this.customersStatedObjective2='';
                this.ShowMoreText =false;
                this.ShowLessText=false;
            }

            
                var evaluationDescription = this.evaluationOfObjective;
                if(evaluationDescription.length > 100){   
                    this.evaluationOfObjective1=evaluationDescription.substr(0,100);
                    this.evaluationOfObjective2=evaluationDescription.substr(100,evaluationDescription.length); 
                    this.ShowMoreTextEval =true;
                    this.ShowLessTextEval =false;
                    this.showTextEval = false;
                }else{
                    this.evaluationOfObjective1=evaluationDescription;
                    this.evaluationOfObjective2='';
                    this.ShowMoreTextEval =false;
                    this.ShowLessTextEval=false;
                }
        }

    }

    deleteSSO() {
       
        
        let record = {
            fields: {
                Id: this.ssoId,
                Customer_Timing_for_Priorities__c: null,
                Customers_Stated_Objectives__c:null ,
                Evaluation_of_Objectives__c:null,
               // Blue_Sheet__c:this.blueSheetId.data,
            },
        };        
        updateRecord(record)
            .then(() => {
                
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Record Deleted',
                        variant: 'success'
                    })
                );
                return refreshApex(this.singleSalesObject);
            })
        .catch(error => {
            console.log(JSON.stringify(error));
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error Deleting SingleSalesObjective ERROR',
                    message: error.body.message,
                    variant: 'error',
                }),
            );
        }); 
    }*/
}