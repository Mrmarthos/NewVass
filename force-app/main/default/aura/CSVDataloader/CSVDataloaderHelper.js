({
    createCSVObject : function(cmp, csv,fichero) {
        var action = cmp.get('c.getCSVObject');
        var id = cmp.get("v.recordId");
        
        
        action.setParams({
            csv_str : csv,
            fichero: fichero,
            SoID : id
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state == "SUCCESS") {
                cmp.set("v.toggleSpinner2", false);  
                if(response.getReturnValue().headers[0].column_name==='oferta'){
                    cmp.set("v.toggleSpinner2", false);  
                    cmp.find("file").getElement().value='';
                    $A.get("e.c:ShowToastEvent")
                    .setParams({
                        type: 'error',
                        title: 'El codigo de oferta es incorrecto',
                        description:'',
                        delay: 7000
                    })
                    .fire();
                    
                }else if(response.getReturnValue().headers[0].column_name==='Version'){
                    cmp.set("v.toggleSpinner2", false);  
                    cmp.find("file").getElement().value='';
                    $A.get("e.c:ShowToastEvent")
                    .setParams({
                        type: 'error',
                        title: 'La versión del fichero es incorrecta',
                        description:'',
                        delay: 7000
                    })
                    .fire();
                    
                }else if(response.getReturnValue().headers[0].column_name==='exception'){
                    
                    cmp.set("v.toggleSpinner2", false);  
                    cmp.find("file").getElement().value='';
                    $A.get("e.c:ShowToastEvent")
                    .setParams({
                        type: 'error',
                        title: 'Se ha producido un error , por favor pongase en contacto con el administrador',
                        description:'',
                        delay: 7000
                    })
                    .fire();
                    
                }else{
                    
                    cmp.set("v.csvObject", response.getReturnValue());
                    
                }
                
            }
        });
        $A.enqueueAction(action);
    },
})