({
    showAccs : function(component,event,helper){
      
        helper.showAccountsGrouped(component);
},
init : function(component,event,helper){
    component.set('v.camposAcc', [
        { label: 'Name', fieldName: 'Name', type: 'text'}
    ]);
    
},
aniadirId : function(component,event,helper){
    //Esta función se encargará de hacer algo con las cuentas seleccionadas. llamará al método con las cuentas como parámetro.
    component.set("v.isLoading",true);
    var accsSelected=component.get("v.selectedRowsList");
    console.log(JSON.stringify(accsSelected));
    var action = component.get("c.aniadirIdExterna");
        action.setParams({
            "Identificador" : component.get("v.recordId"),
            "accs" : accsSelected
        });
        action.setCallback(this, function(a){
            var state = a.getState();// get the response state
            console.log(state); 
            if(state == 'SUCCESS') {
                component.set("v.showsuccess",true);  
                component.set("v.Message",a.getReturnValue());
                component.set("v.isLoading",false);
                $A.util.addClass(component.find('hiddenTable'), 'hiddenTable');
                helper.showToast("Account's SAP Group ID has been updated.",false);
            }else if(state == 'ERROR'){
                component.set("v.isLoading",false);
                helper.showToast("An error has ocurred",true);
            }
        });
        
        $A.enqueueAction(action);
    
},
updateSelectedText : function(component,event,helper){
    component.set("v.selectedRowsList" ,event.getParam('selectedRows') );
},
onNext: function(component, event, helper) {        
    let pageNumber = component.get("v.currentPageNumber");
    component.set("v.currentPageNumber", pageNumber + 1);
    helper.setPageDataAsPerPagination(component);
},
 
onPrev: function(component, event, helper) {        
    let pageNumber = component.get("v.currentPageNumber");
    component.set("v.currentPageNumber", pageNumber - 1);
    helper.setPageDataAsPerPagination(component);
},

onPageSizeChange: function(component, event, helper) {        
    helper.preparePagination(component, component.get('v.filteredData'));
},

})