({
	// Your renderer method overrides go here
    render : function(component,helper)
    {
        var a = this.superRender();
        console.log("This text is  from render function which gets executed when component is initialized");
        return a;
    },
    
})