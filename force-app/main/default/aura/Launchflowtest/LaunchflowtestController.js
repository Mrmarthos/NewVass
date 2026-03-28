({
    init : function (component) {
        // Find the component whose aura:id is "flowData"
        var flow = component.find("test_won");
        // In that component, start your flow. Reference the flow's API Name.
        flow.startFlow("test_won");
    },
})