({
	onCarClick : function(component, event, helper) {
        var car = component.get("v.car");
		var evt = component.getEvent("onCarSelect");
        evt.setParams({
            "CarId" : car.Id
        });
        evt.fire();
	},
})