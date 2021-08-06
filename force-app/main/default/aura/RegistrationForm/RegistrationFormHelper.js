({
	checkboxHelper : function(component,helper) {
        var checkBoxVal = component.find("CheckBoxs").get("v.checked");
   
		component.set("v.Checkboxvals",checkBoxVal);
		
	}
})