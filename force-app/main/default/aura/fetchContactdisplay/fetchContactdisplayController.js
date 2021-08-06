({
	doInit : function(component, event, helper) {
        // fetch the method name from controller 
        var action = component.get('c.getContactlst');
     action.setParams({ 
         accountId : component.get("v.recordId") 
                      });
     action.setCallback(this, function(response) {
            //console.log(response.getReturnValue());
         var responseVal = response.getReturnValue();
         component.set("v.contactlist",responseVal);
        });
        $A.enqueueAction(action);
    }
	
})