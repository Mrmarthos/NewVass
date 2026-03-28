({
    handleUploadFinished : function(component, event, helper) {
        var fileInput = component.find("file").getElement();
        var file = fileInput.files[0];
        if(file) {
            console.log("UPLOADED")
            var reader = new FileReader();
            component.set("v.toggleSpinner2", true);  
          
            reader.readAsText(file, 'UTF-8');
            
            
      
            reader.onload = function(evt) {
                var csv = evt.target.result;
                component.set("v.csvString", csv);
                
            }
            
        }
    },

    handleGetCSV : function(component, event, helper) {
        var csv = component.get("v.csvString");
        if(csv!==null){
            
        
        var fileInput = component.find("file").getElement();
        var file = fileInput.files[0];
        var reader = new FileReader();
        var fichero;
        reader.readAsDataURL(file);
        reader.onload = function(evt) {
                 fichero = reader.result;
            	 var base64Mark = 'base64,';
            	var dataStart = fichero.indexOf(base64Mark) + base64Mark.length;
                  
                    fichero = fichero.substring(dataStart);
                    if(csv != null) {
                        component.set("v.Fichero", fichero); 
                        helper.createCSVObject(component, csv);
						                       
                    }
            
            }
        
 
        }
        
    },

    cleanData : function(component, event, helper) {
        component.set("v.csvString", null);
        component.set("v.csvObject", null);
        component.find("file").getElement().value='';

    },
    
    carga : function(component, event, helper) {
       
        
        var action = component.get('c.ActualizarLineas');
        var datos = component.get("v.csvObject");
        var fichero =  component.get("v.Fichero");
        var comentarios =  component.find("comments").get("v.value");
         var id = component.get("v.recordId");
        
         component.set("v.toggleSpinner", true);  
  
        action.setParams({
            datos : datos,
            comentarios:comentarios,
            fichero:fichero,
            SoId:id
      
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state == "SUCCESS") {
       
                if(response.getReturnValue()===false){
                    
                    component.set("v.csvString", null);
                    component.set("v.toggleSpinner", false);  
                    component.set("v.csvObject", null);
                    component.find("file").getElement().value='';
                    $A.get("e.c:ShowToastEvent")
                    .setParams({
                        type: 'error',
                        title: 'No se ha podido actualizar las lineas de proyecto, revise el excel o pongase en contacto con el administrador',
                        description:'',
                        delay: 7000
                    })
                    .fire();
                    
                    
                }else{
                    
                    component.set("v.csvString", null);
                    component.set("v.toggleSpinner", false);  
                    component.set("v.csvObject", null);
                    component.find("file").getElement().value='';
                    $A.get("e.c:ShowToastEvent")
                    .setParams({
                        type: 'success',
                        title: 'Información actualizada!',
                        description: '',
                        delay: 7000
                    })
                    .fire();
                }
            }
        });
        $A.enqueueAction(action);
       
    },

    
})