import QtQuick

QtObject {
    id: workspaceModel
    
    // Core properties
    property int id: 0
    property string name: ""
    property bool active: false
    property bool occupied: false
    
    // Window references (list of WindowModel objects)
    property var windows: []
    
    // Computed
    property int windowCount: windows.length
    
    // Helper to check if workspace has a specific window
    function hasWindow(address) {
        return windows.some(w => w.address === address)
    }
    
    // Add window to this workspace
    function addWindow(windowModel) {
        if (!hasWindow(windowModel.address)) {
            windows = windows.concat([windowModel])
            occupied = true
        }
    }
    
    // Remove window from this workspace
    function removeWindow(address) {
        windows = windows.filter(w => w.address !== address)
        occupied = windows.length > 0
    }
}
