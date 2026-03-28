({
	doInit : function(component, event, helper) {
	
        
        var action = component.get("c.SendPreventaOpor"); 
        
 		action.setParams({
            "Identificador" : component.get("v.recordId"),
            "lps" : null,
            "ejecucion" : true 
            
        });
        
        
             action.setCallback(this, function(a){
            var state = a.getState(); // get the response state
            if(state == 'SUCCESS') {
                if(a.getReturnValue().includes('No se ha podido sincronizar con SAP:')===true){
                      component.set("v.showError",true);
                }else{
                     component.set("v.showsuccess",true);
                    
                }
               
                component.set("v.Message",a.getReturnValue());
                component.set("v.toggleSpinner",false);
            }
        });
        
        $A.enqueueAction(action);

	}
})