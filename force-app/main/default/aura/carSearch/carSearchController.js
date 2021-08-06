({
	doFormSubmit : function(component, event, helper) {
		//fetching cartypeId attribute value from event
		var carTypeId1 = event.getParam('carTypeId');
                console.log('Selected carTypeId' + carTypeId1 );
// will get all the cars belong to the carTypeId and display results in carsearchResults component 
         var carSearchResultComp = component.find("carSearchResult");
        //call the aura:method in the child component.
      
        var carSearchCmpResult = carSearchResultComp.searchCars(carTypeId1);

         
	},
})