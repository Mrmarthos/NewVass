({
	CheckMargen : function(cmp, event, helper) {
        var identificador=cmp.get("v.recordId") ;
        var action = cmp.get("c.CheckMargen");
        var eventFields =  event.getParam("fields");
        var field = 'Margen_Intercompany__c';
        var margen='15';
     
        if (eventFields.hasOwnProperty(field)) {
            margen=eventFields.Margen_Intercompany__c;
        }
        
        
        
        action.setParams({
            "Identificador"            : identificador
            
        });
        alert('AAAVER' + margen);
            action.setCallback(this, function(response) {
               var state = response.getState();
               if (state == "SUCCESS") {
 				alert('wewewe'+state);
                  var result=response.getReturnValue();
                 
                   if(result==true){
               		 alert('valid');
               			 
  
                   }else {
                       
                       alert('invalid');
                                          
                   }
                  
                   
                   
               }

          });
          $A.enqueueAction(action);
        
	},
    
    

 saveRec : function(component, event, helper) {
        var eventFields = event.getParam("fields");
        var field = 'sObjectFieldsIntercompany';
        if (eventFields.hasOwnProperty(field)) {
            if ( !eventFields.NumberOfEmployees ) {            
                event.preventDefault();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!!!",
                    "message": "Please fill Employees field",
                    "type": "error"
                });
                toastEvent.fire();
            }
        }
 }

})