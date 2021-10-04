({
	fetchRecordId : function(cmp) {
       
		var pageRef = cmp.get("v.pageReference");
        console.log(JSON.stringify(pageRef));
        var attributeDetails = pageRef.attributes;
        
        cmp.set('v.objectApliName',attributeDetails.objectApiName);
        var state = pageRef.state; // state holds any query params
        
        var base64Context = state.inContextOfRef;
        console.log('base64Context = '+base64Context);
        
        if (base64Context.startsWith("1\.")) {
            base64Context = base64Context.substring(2);
            console.log('base64Context = '+base64Context); 
        }
        
        var addressableContext = JSON.parse(window.atob(base64Context));
        
        console.log('recordid>>>'+addressableContext.attributes.recordId);
        var recId=addressableContext.attributes.recordId;
        cmp.set('v.recordId',recId);
        
        this.fetchFieldSet(cmp);
	},
    
    fetchFieldSet : function(cmp){
        var getFormAction = cmp.get('c.fetchMainMethods');
        getFormAction.setParams({
            recordId: cmp.get('v.recordId'),
            childObject: cmp.get("v.sObjectName")
        });

        getFormAction.setCallback(this, 
            function(response) {
            	var state = response.getState();
            	console.log('FieldSetFormController getFormAction callback');
            	console.log("callback state: " + state);
                let fieldSetRight=[];
                let fieldSetLeft=[];
              
            	if (cmp.isValid() && state === "SUCCESS") {
	                var form = response.getReturnValue();
	                cmp.set('v.fields', form.Fields); 
                    cmp.set('v.recordTypeId',form.childRecordtype);
                    cmp.set('v.recordTypeName',form.childRecordtypeName);
                    fieldSetRight=form.Fields.slice(0, parseInt(form.Fields.length/2));
                    fieldSetLeft=form.Fields.slice((parseInt(form.Fields.length/2)),parseInt(form.Fields.length));
                
                    cmp.set('v.fieldSetR', fieldSetRight);
                    cmp.set('v.fieldSetL', fieldSetLeft);
                    this.hideSpinner(cmp);
                }
            }
        );
        $A.enqueueAction(getFormAction);
    },
    
    showSpinner: function (component) {
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
    },
     
    hideSpinner: function (component) {
        var spinner = component.find("mySpinner");
        $A.util.addClass(spinner, "slds-hide");
    }
})