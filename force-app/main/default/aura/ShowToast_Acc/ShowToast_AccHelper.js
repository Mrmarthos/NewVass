({
    showToast : function(type, message,title) {
        var toastEvent = $A.get("e.force:showToast");
                     toastEvent.setParams({
                     "type": type,
                     "message": message,
                     "title":title
        });
        toastEvent.fire();
    }
})