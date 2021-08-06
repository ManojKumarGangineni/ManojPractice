({
	openCloseRegistratinoForm : function(component, event, helper) {
        var a = event.getSource().get("v.label");
        if(a == "Open registration form")
        {
            component.set("v.openRegistrationForm",true);
            component.set("v.ButtonLabel","Close the form");
        }
        if(a=="Close the form")
        {
            component.set("v.openRegistrationForm",false);
            component.set("v.ButtonLabel","Open registration form");
        }
		
	}
})