({
    send : function(component, event, helper) {
         
        /*var action = component.get("c.SendPreventaOpor"); 
    	var lps=component.get("v.selectedRowsList");
        
        if(lps.length === 0){
            alert('Seleccione al menos una linea de proyecto');
            return ;
        }
      component.set("v.toggleSpinner", true);  
        action.setParams({
            "Identificador" : component.get("v.recordId"),
            "lps" : lps,
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
        
        $A.enqueueAction(action);*/
        var action = component.get("c.SendCorreoForm"); 
    	var lps=component.get("v.selectedRowsList");
        
        if(lps.length === 0){
            alert('Seleccione al menos una linea de proyecto');
            return ;
        }
      component.set("v.toggleSpinner", true);  
        action.setParams({
            "Identificador" : component.get("v.recordId"),
            "lps" : lps,
            "ejecucion" : true 
            
        });
     
        action.setCallback(this, function(a){
            var state = a.getState(); // get the response state
            console.log(state);
            if(state == 'SUCCESS') {
                console.log("Éxito al mandar el correo.");
                console.log(a.getReturnValue());
                component.set("v.Message",a.getReturnValue());
                component.set("v.toggleSpinner",false);
                component.set("v.showsuccess",true);
                 component.set("v.showlp",false);
            }
        });
        
        $A.enqueueAction(action);
        
    },
    
    sendall : function(component, event, helper) {
        component.set("v.toggleSpinner", true);  
        
        /*var action = component.get("c.SendPreventaOpor");
        action.setParams({
            "Identificador" : component.get("v.recordId"),
            "lps" : component.get("v.data"),
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
        
        $A.enqueueAction(action);*/
        
        
        var action = component.get("c.SendCorreoForm"); 
    	var lps=component.get("v.data");
        
        if(lps.length === 0){
            alert('Seleccione al menos una linea de proyecto');
            return ;
        }
      component.set("v.toggleSpinner", true);  
        action.setParams({
            "Identificador" : component.get("v.recordId"),
            "lps" : lps,
            "ejecucion" : true 
            
        });
     
        action.setCallback(this, function(a){
            var state = a.getState(); // get the response state
            if(state == 'SUCCESS') {
                console.log("Éxito al mandar el correo.")
                console.log(a.getReturnValue());
                component.set("v.Message",a.getReturnValue());
                component.set("v.toggleSpinner",false);
                 component.set("v.showsuccess",true);
                component.set("v.showlp",false);
            }
        });
        
        $A.enqueueAction(action);
    },
    
    doInit : function(component, event, helper) {
     
        component.set('v.columns', [
            {label: 'Line Number', fieldName: 'Name', type: 'text'},
            {label: 'Record Type Name', fieldName: 'Nombre_Tipo_Registro__c', type: 'text'},
            {label: 'Management', fieldName: 'Gerencia__c', type: 'text'},
            {label: 'Área', fieldName: 'Area__c', type: 'terxt'} ,
            {label: 'Amount', fieldName: 'Importe_total_2__c', type: 'text'},
            {label: 'Start Date', fieldName: 'Fecha_Inicio__c', type: 'Date'} ,
            {label: 'End Date', fieldName: 'Fecha_Fin__c', type: 'Date'} ,
            {label: 'Income Type*', fieldName: 'Tipo_de_ingreso__c', type: 'Text'}                                                                                               
       

        ]);
        
        var action = component.get("c.getLps"); 
        
        action.setParams({
            "Identificador" : component.get("v.recordId")     
            
        });
        
        
        action.setCallback(this, function(a){
            var state = a.getState(); // get the response state
            if(state == 'SUCCESS') {
                
                component.set("v.data",a.getReturnValue());
                            
            }
        });
        
        $A.enqueueAction(action);
        
    },
    
    updateSelectedText: function (cmp, event) {
        var selectedRows = event.getParam('selectedRows');
        cmp.set('v.selectedRowsCount', selectedRows.length);
        
        cmp.set("v.selectedRowsList" ,event.getParam('selectedRows') );
    },
    

   
    
    
})