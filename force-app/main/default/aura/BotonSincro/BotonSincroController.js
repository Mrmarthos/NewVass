({
	myAction : function(component, event, helper) {
	
        
        var action = component.get("c.SendPreventa"); 
        
         action.setParams({
            "Identificador" : component.get("v.recordId"),
             "ejecucion" :false
        });
        
        
             action.setCallback(this, function(a){
            var state = a.getState(); // get the response state
            if(state == 'SUCCESS') {
            
              alert('Syncing..')
            }
        });
        
        $A.enqueueAction(action);

	}
})