import QtQuick

QtObject {
    id: windowModel
    
    // Core identifiers
    property string address: ""      // Hyprland window address (unique)
    property string title: ""        // Window title
    property string appId: ""        // Application class/ID
    property string icon: "application-x-executable"  // Icon name
    
    // Position
    property int workspaceId: 0      // Parent workspace ID
    
    // State flags
    property bool focused: false
    property bool fullscreen: false
    property bool floating: false
    property bool minimized: false
    property bool pinned: false      // Visible on all workspaces
    
    // Metadata
    property int pid: 0
    property string initialClass: "" // Original app class
    property string initialTitle: "" // Original title
    
    // Update from Hyprland data
    function updateFromHyprland(data) {
        if (data.title !== undefined) title = data.title
        if (data.class !== undefined) appId = data.class
        if (data.workspace !== undefined) workspaceId = data.workspace.id || data.workspace
        if (data.fullscreen !== undefined) fullscreen = data.fullscreen
        if (data.floating !== undefined) floating = data.floating
        if (data.pid !== undefined) pid = data.pid
        if (data.pinned !== undefined) pinned = data.pinned
    }
    
    // Clone for immutability patterns
    function clone() {
        var copy = Qt.createQmlObject('import QtQuick; import "." as Models; Models.WindowModel {}', windowModel)
        copy.address = address
        copy.title = title
        copy.appId = appId
        copy.icon = icon
        copy.workspaceId = workspaceId
        copy.focused = focused
        copy.fullscreen = fullscreen
        copy.floating = floating
        copy.minimized = minimized
        copy.pinned = pinned
        copy.pid = pid
        return copy
    }
}
