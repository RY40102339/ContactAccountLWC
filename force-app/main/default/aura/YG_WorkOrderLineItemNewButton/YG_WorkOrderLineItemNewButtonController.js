({
	doInit : function(cmp, event, helper) {
       // $A.get('e.force:refreshView').fire();
       console.log('objectName>>>'+cmp.get("v.sObjectName"));
       helper.fetchRecordId(cmp, event, helper);
	},
    
    redirectBack : function(cmp, event, helper){
        helper.showSpinner(cmp);
        var url='/'+cmp.get('v.recordId');
        window.location.href = url;
       // window.location.reload();
       /* console.log('recordid>>>'+cmp.get('v.recordId'));
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": cmp.get('v.recordId'),
            "slideDevName": "related"
        });
        navEvt.fire();*/
       helper.hideSpinner(cmp);
    }
})