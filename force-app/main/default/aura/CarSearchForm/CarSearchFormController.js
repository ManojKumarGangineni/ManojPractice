({
    doInit : function(component,event,helper)
    {
       // console.log("Car type before "+ carTypes);
        var carTypes = component.get("v.carTypes");
        var createcarRecord = $A.get("e.force:createRecord");
        if(createcarRecord)
        {
            component.set("v.showNew",true);
        }
        else{
            component.set("v.showNew",false);
            console.log("Event not supported");
            //alert("Event not supported to create record in lightning standalone application");
        }
        //will be fetching car type from background using Apex controller.
        //  component.set("v.carTypes",['Sports car','Luxury car', 'Premium car']);
        // var carTypes = component.get("v.carTypes");
        //console.log("Car type after "+ carTypes);
        // alert("component is initialization");
        helper.getCarType(component,helper); // calling the helpermethod getcarType.
    },
        
  onSearchClick : function(component, event, helper) {
      var searchFormSubmit	= component.getEvent("searchFormSubmit"); // we are fetching registered data
      searchFormSubmit.setParams({
          "carTypeId" : component.find("carTypeList").get("v.value") 
      });
      searchFormSubmit.fire();
    }, 
    
    createNewRecord : function(component,event,helper)
    {
        var createcarRecord = $A.get("e.force:createRecord");
        // object name is Car_Types_c is used to create new record
        createcarRecord.setParams({
            "entityApiName": "Car_Types__c" 
        })
        createcarRecord.fire(); //used to fire in order to create new record.
    },

    /* ToggleClick : function(component,event,helper){
        var currentValue = component.get("v.isNewAvailable"); //get the attribute value
        console.log("method is executed");
        //debugger;
        if(currentValue)
        {
            component.set("v.isNewAvailable", false); //set the attribute value
        }
        
        else{
            component.set("v.isNewAvailable", true); //set the attribute value
        }
        var result = component.get("v.isNewAvailable");
        console.log("the result value is"+result);
 
    }, */
   newValueSelected : function(component,event,helper)
    {
        var carTypeId = component.find('CarTypeList').get("v.value");    // This is syntax of using "<aura :id >" component. 
        //CarTypeList-> is Aura ID . which we are calling from component <aura:id> and using it in find(CarTypeList) 
        alert(carTypeId+ ' option selected');
  }, 

})