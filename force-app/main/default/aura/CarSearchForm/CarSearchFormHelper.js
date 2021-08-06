({
   
 getCarType : function(component,helper) {
      /*   
  ========= Commenting due to usage of Base component  =============== 
   
      var action = component.get("c.getCarTypes");
        
        action.setCallback(
            this, function(data){
            var state = data.getState();
            if(state === "SUCCESS")
            {
                component.set("v.carTypes",data.getReturnValue());
            }
            else if(state === "ERROR")
            {
                alert("unknown error");
            }
            
        });
        $A.enqueueAction(action); 
       end ========================================*/
    
    /* ===== Usage of inheritance to call base method ====== */
  helper.callServer(
    component,"c.getCarTypes",
    function(response){
    component.set("v.carTypes", response);

});
}  
})