({
	add : function(component, event, helper) {
		var inputval1 =component.get("v.inputone");
       var inputval2= component.get("v.Inputtwo");
        alert(parseInt(inputval1) + parseInt(inputval2));
    component.set("v.output",parseInt(inputval1) + parseInt(inputval2));
	},
    sub : function(component, event, helper) {
		var inputval1 =component.get("v.inputone");
       var inputval2= component.get("v.Inputtwo");
        alert(parseInt(inputval1) - parseInt(inputval2));
    component.set("v.output",parseInt(inputval1) - parseInt(inputval2));
	},
 mul : function(component, event, helper) {
		var inputval1 =component.get("v.inputone");
       var inputval2= component.get("v.Inputtwo");
        alert(parseInt(inputval1) * parseInt(inputval2));
    component.set("v.output",parseInt(inputval1) * parseInt(inputval2));
	},
div : function(component, event, helper) {
		var inputval1 =component.get("v.inputone");
       var inputval2= component.get("v.Inputtwo");
        alert(parseInt(inputval1) / parseInt(inputval2));
    component.set("v.output",parseInt(inputval1) / parseInt(inputval2));
	},    
    MapClick:function(component,event,helper)
    {
        var maps = [];
			for(var i=0;i<10;i++)
            {
                maps.push({key : i,
                         value : 'test'+ i
                         });
            }
       component.set('v.mapvar',maps);
    }

})