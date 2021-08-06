({
	doInit : function(component, event, helper) {
		helper.onSearch(component,helper);
	},
    doSearch : function(component, event, helper)
    {
        //this line will get all the arguments passed to aura:method
        var params = event.getParam('arguments');
       
        if(params)
        {
            //getting cartype id from argument list and setting component attribute value 
            component.set("v.carTypeIdComponent",params.carTypeId);
            helper.onSearch(component,helper);
        }
    },
    onCarSelect :function(component,event,helper)
    {
        component.set("v.selectedCarId",event.getParam('CarId'));
    },

})