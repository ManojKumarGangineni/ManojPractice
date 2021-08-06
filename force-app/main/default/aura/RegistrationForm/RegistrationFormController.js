({
	onClickCheckbox : function(component, event, helper) {
        helper.checkboxHelper(component,helper);
       },
    clickSubmit : function(component,event)
    {
        //access the value of attribute   
        var subClk =component.get("v.SubmitClick");
        if(subClk == "True")
        {
            alert('Not sucessfully ');
            component.set("v.SubmitClick","false");
      }
        else{
             alert('Succesfully');
            component.set("v.SubmitClick","true");
        }
    }
})