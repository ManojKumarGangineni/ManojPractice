({
	onclick : function(component, event, helper) {
		var str = component.get("v.StrVal");
        component.set("v.StrVal","New Value Updated");
       var checkAtt = component.find("Findme");
        //alert('checkAtt');
        
        component.set("v.age",30);
	}
})