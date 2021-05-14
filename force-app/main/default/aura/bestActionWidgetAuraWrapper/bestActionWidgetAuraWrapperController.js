({
    doInit: function(component, event, helper) {
        let refreshLabel = component.get("v.refreshFlag");
        refreshLabel = !refreshLabel;
        component.set("v.refreshFlag", refreshLabel);
    }
});