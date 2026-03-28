({
  close: function(cmp, event, helper) {
    $A.util.addClass(cmp.find('divToast'), "slds-hide");
    
  },

  handleShowToast: function(cmp, event, helper) {
    cmp.set("v.type", event.getParam("type"));
    cmp.set("v.title", event.getParam("title"));
    cmp.set("v.description", event.getParam("description"));
    cmp.set("v.delay", event.getParam("delay"));
	
    $A.util.removeClass(cmp.find('divToast'), "slds-hide");

    window.setTimeout(
      $A.getCallback(function() {
        if (cmp.isValid()) {
          $A.util.addClass(cmp.find('divToast'), "slds-hide");
        }
      }), cmp.get("v.delay")
    );
       
  }
})