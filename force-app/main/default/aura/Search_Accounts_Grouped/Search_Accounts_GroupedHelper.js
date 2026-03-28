({
    showAccountsGrouped : function(component) {
        var nombreDelCliente = component.get('v.Group');
        var action = component.get('c.getAccs');
        action.setParams({
          accName : nombreDelCliente
        })
        component.set("v.isLoading", true);
        action.setCallback(this, $A.getCallback(function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
            console.log
            component.set('v.allData', response.getReturnValue());
            component.set('v.filteredData',response.getReturnValue());
            this.preparePagination(component, response.getReturnValue());
            component.set("v.isLoading", false);
            component.set("v.Message",response.getReturnValue());
            //Remover la clase al elemento para mostrarlo.
            $A.util.removeClass(component.find('hiddenTable'), 'hiddenTable');
            } else if (state === "ERROR") {
                var errors = response.getError();
                console.error(errors);
                component.set("v.Message",'Se debe introducir al menos una letra en el buscador.');
                component.set("v.isLoading", false);
                this.showToast(component.get('v.Message'),true);
            }
            console.log(JSON.stringify(response.getReturnValue()));
        }));
        
        $A.enqueueAction(action);
    },
    showToast : function(message,error) {
        var toastEvent = $A.get("e.force:showToast");
        if(error){
            toastEvent.setParams({
                "title": "Error!",
                "message": message,
                "type" : "error"
            });
        }else{
            toastEvent.setParams({
                "title": "Success!",
                "message": message,
                "type" : "success"
            });
        }
        toastEvent.fire();
    },
    preparePagination: function (component, accRecords) {
        let countTotalPage = Math.ceil(accRecords.length/component.get("v.pageSize"));
        let totalPage = countTotalPage > 0 ? countTotalPage : 1;
        component.set("v.totalPages", totalPage);
        component.set("v.currentPageNumber", 1);
        this.setPageDataAsPerPagination(component);
    },
    
    setPageDataAsPerPagination: function(component) {
        let data = [];
        let pageNumber = component.get("v.currentPageNumber");
        let pageSize = component.get("v.pageSize");
        //Lista con todas las oportunidades
        let filteredData = component.get('v.filteredData');
        //Manera de partir los registros utilizando las páginas 
        //ej: pag = 1 /// x = (1 - 1) * 15 = 0 -> x(valor 0) < 1 * 15 (15) muestra 15 registros, los 15 primeros
        let x = (pageNumber - 1) * pageSize;
        for (; x < (pageNumber) * pageSize; x++){
            if (filteredData[x]) {
                //Añade el registro a un array, que es el que se mostrará.
                data.push(filteredData[x]);
            }
        }
        //Opportunities es la variable que contiene los registros que se muestran.
        component.set("v.accounts", data);
    },
})