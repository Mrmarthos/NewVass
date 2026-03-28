({
    fetchData: function (cmp,boolean) {
        
        
        var action = cmp.get("c.CalculateHitos");
          
        action.setParams({
            Identificador : cmp.get("v.recordId"),
            Numerohitos:cmp.find("hitos").get("v.value")
      
      
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                var oRes = response.getReturnValue();
                if(oRes.length > 0){
                        cmp.set('v.data', oRes);
                        cmp.set("v.showTable", true);
                    if(boolean===true){
                       cmp.set("v.draftValues", oRes);

                    }
                   
                    
               
                    
                }
            }
            
        });
        $A.enqueueAction(action);  
    },
    
 
    getRowActions: function (cmp, row, doneCallback) {
        var actions = [];
        var deleteAction = {
            'label': 'Delete',
            'iconName': 'utility:delete',
            'name': 'delete'
        };
        
        
        
        actions.push(deleteAction);
        
        // simulate a trip to the server
        setTimeout($A.getCallback(function () {
            doneCallback(actions);
        }), 200);
    }

 
});