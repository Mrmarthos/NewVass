({
    init: function (cmp, event, helper) {
        var rowActions = helper.getRowActions.bind(this, cmp);
        cmp.set('v.columns', [
            {label: 'Description', fieldName: 'Descripcion', type: 'text', editable: true,iconName: 'standard:quick_text', typeAttributes: { required: true }},
            
            {
                label: 'Close date', fieldName: 'FechaHito', iconName: 'standard:event', type:'date-local', editable: true ,
                typeAttributes: {
                    year: 'numeric',
                    month: 'short',
                    day: 'numeric',
                    required: true
                    
                }
            },
            
            {label: 'Amount', fieldName: 'Importe', type: 'currency',  iconName: 'standard:currency', editable: false ,typeAttributes: {
                minimumFractionDigits: 0,
                maximumFractionDigits: 2} },
            
            {label: 'Percentage', fieldName: 'Porcentaje', type: 'number',  iconName: 'standard:calculated_insights', editable: true ,typeAttributes: {
                minimumFractionDigits: 0,
                maximumFractionDigits: 2} },
            
            
            
            
        ]);
            
            
            
            helper.fetchData(cmp,false);
            
            },
            
            generateData: function (cmp, event, helper) {
            var draftValues = event.getParam('draftValues');
            
            helper.saveEdition(cmp, draftValues);
            },
            
setData: function (cmp, event, helper) {
            
            if(cmp.find("hitos").get("v.value")>0){
            helper.fetchData(cmp,true);
            }else{
            alert("Debe indicar un nº de hitos");
            }
            
            },
            
 handleSaveEdition: function (cmp, event, helper) {
            
            
            helper.saveEdition(cmp, draftValues);
            },
            
 handleEditCellChange: function (cmp, event, helper) {
            
            var action = cmp.get("c.ActualizarHitosTabla");
            var datosmodificados = event.getParam('draftValues');
            var datos =   cmp.get('v.data');
         
            action.setParams({
                Identificador : cmp.get("v.recordId"),
                datosmodificados  :         datosmodificados,
             datosoriginales 				:   datos
            
            
            });
            
            action.setCallback(this, function(response) {
            var state = response.getState();
            var oRes = response.getReturnValue();
          
            if (state === "SUCCESS"){
              
                cmp.set("v.draftValues", oRes);
                cmp.set('v.data', oRes);
                
                
          
            }
            
            });
            $A.enqueueAction(action);  
            
            
            
            },
         
   save: function (cmp, event, helper) {
            var action = cmp.get("c.guardarHitos");
            var datosmodificados = event.getParam('draftValues');
            
            
            
            action.setParams({
            Identificador : cmp.get("v.recordId"),
            datosmodificados  :         datosmodificados
            
            
            
            });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
            	var oRes = response.getReturnValue();
                var toastEvent = $A.get("e.force:showToast");
                if (state === "SUCCESS"){
            		if(oRes===true){      
            
            		toastEvent.setParams({
                        "title": "Éxito!",
                        "message": "Información actualizada!",
                        "type": 'success',
     
                        });
            
            
                        toastEvent.fire();}
                    else{
                   toastEvent.setParams({
                        "title": "Error!",
                        "message": "Por favor compruebe la suma de los hitos de facturación",
                        "type": 'error',
     
                        });
                        toastEvent.fire();
                    }
                    
                  
                        
                }
                
                });
                $A.enqueueAction(action);  
                
          cmp.set("v.draftValues", null);
		 
            },
            });