({
	doInit : function(component, event, helper) {
      
        var carDetls = component.get('v.car');
      console.log('carDetls'+JSON.stringify(carDetls));
        var navEvt = $A.get("e.force:navigateToSObject");
        
        if(navEvt)
        {
            component.set("v.showCardAction",true);
        }
        else
        {
             component.set("v.showCardAction",false);
        }
		
	},
    onFullDetails :  function(component, event, helper) 
    {
         var navEvt = $A.get("e.force:navigateToSObject");
        if(navEvt)
        {
            navEvt.setParams({
               'recordId' : component.get("v.car").Id,
                'slideDevName' : "detail"
            });
            navEvt.fire();
        }
        else
        {
            alert('Event not supported');
        }
    }
})