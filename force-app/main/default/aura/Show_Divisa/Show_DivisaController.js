({
doInit: function(cmp){
    var action = cmp.get("c.getUserDivisa");
    action.setCallback(this, function(response){
        var state = response.getState();
        if (state === "SUCCESS") {
            cmp.set("v.Divisa", response.getReturnValue());
         }
      });
       $A.enqueueAction(action);
     }
 })