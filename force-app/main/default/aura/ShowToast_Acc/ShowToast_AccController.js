({

    getAccount : function(component,event,helper){
        var message = component.get("v.messageText");
        var type = component.get("v.type");
        var title = component.get("v.title");
        var action = component.get("c.getCurrentAccount"); 
        action.setParams({
           "accId" : component.get("v.recordId")
       });
       console.log('Record ID-------------> ' +component.get("v.recordId"));
        action.setCallback(this, function(response){
        var state = response.getState(); 
        if(state == 'SUCCESS') {
            if(response.getReturnValue()[0].Validacion_NIF__c == false){
                console.log('es falso');
                
                helper.showToast(type, message,title);
                
            }
            console.log(response.getReturnValue());
            console.log(JSON.stringify(response.getReturnValue()));
        }
       });
       
       $A.enqueueAction(action);
       
    }
})