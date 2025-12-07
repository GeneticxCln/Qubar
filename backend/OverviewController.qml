import QtQuick
import Quickshell.Io

QtObject {
    id: overviewController
    
    // ═══════════════════════════════════════════════════════════
    // SIGNALS
    // ═══════════════════════════════════════════════════════════
    signal overviewToggled(bool visible)
    signal workspaceSelected(int id)
    signal windowSelected(string address)
    
    // ═══════════════════════════════════════════════════════════
    // PROPERTIES
    // ═══════════════════════════════════════════════════════════
    property bool visible: false
    property int workspaceCount: 10
    property var workspaceWindows: ({}) // {workspaceId: [windows]}
    
    // Search
    property string searchQuery: ""
    property var searchResults: [] // Filtered apps/windows
    
    // Dependencies (set by BackendController)
    property var windowTracker: null
    property var workspaceManager: null
    property var appLauncher: null
    property var actionDispatcher: null
    
    // ═══════════════════════════════════════════════════════════
    // PUBLIC FUNCTIONS
    // ═══════════════════════════════════════════════════════════
    
    function toggle() {
        visible = !visible
        if (visible) {
            refresh()
        }
        overviewToggled(visible)
    }
    
    function show() {
        visible = true
        refresh()
        overviewToggled(true)
    }
    
    function hide() {
        visible = false
        searchQuery = ""
        overviewToggled(false)
    }
    
    function refresh() {
        // Group windows by workspace
        if (!windowTracker) return
        
        var grouped = {}
        for (var i = 1; i <= workspaceCount; i++) {
            grouped[i] = []
        }
        
        var windows = windowTracker.windows || []
        for (var j = 0; j < windows.length; j++) {
            var win = windows[j]
            var wsId = win.workspaceId || 1
            if (grouped[wsId]) {
                grouped[wsId].push(win)
            }
        }
        
        workspaceWindows = grouped
    }
    
    function switchToWorkspace(id) {
        if (actionDispatcher) {
            actionDispatcher.switchWorkspace(id)
        }
        hide()
        workspaceSelected(id)
    }
    
    function focusWindow(address) {
        if (actionDispatcher) {
            actionDispatcher.focusWindow(address)
        }
        hide()
        windowSelected(address)
    }
    
    function search(query) {
        searchQuery = query.toLowerCase().trim()
        
        if (!searchQuery) {
            searchResults = []
            return
        }
        
        var results = []
        
        // Search windows
        if (windowTracker) {
            var windows = windowTracker.windows || []
            for (var i = 0; i < windows.length; i++) {
                var win = windows[i]
                if (win.title.toLowerCase().includes(searchQuery) ||
                    (win.appId && win.appId.toLowerCase().includes(searchQuery))) {
                    results.push({
                        type: "window",
                        name: win.title,
                        icon: win.appId,
                        data: win
                    })
                }
            }
        }
        
        // Search apps
        if (appLauncher) {
            var apps = appLauncher.applications || []
            for (var j = 0; j < apps.length; j++) {
                var app = apps[j]
                if (app.name.toLowerCase().includes(searchQuery)) {
                    results.push({
                        type: "app",
                        name: app.name,
                        icon: app.icon,
                        data: app
                    })
                }
            }
        }
        
        searchResults = results.slice(0, 20) // Limit results
    }
    
    function activateResult(result) {
        if (result.type === "window") {
            focusWindow(result.data.address)
        } else if (result.type === "app") {
            if (appLauncher) {
                appLauncher.launch(result.data)
            }
            hide()
        }
    }
    
    // ═══════════════════════════════════════════════════════════
    // HELPERS
    // ═══════════════════════════════════════════════════════════
    
    function getWorkspaceWindows(workspaceId) {
        return workspaceWindows[workspaceId] || []
    }
    
    function isWorkspaceActive(workspaceId) {
        if (!workspaceManager) return false
        return workspaceManager.activeWorkspaceId === workspaceId
    }
    
    function isWorkspaceOccupied(workspaceId) {
        var wins = getWorkspaceWindows(workspaceId)
        return wins.length > 0
    }
    
    // ═══════════════════════════════════════════════════════════
    // INITIALIZATION
    // ═══════════════════════════════════════════════════════════
    
    function initialize() {
        console.log("[OverviewController] Initializing...")
        refresh()
    }
    
    Component.onCompleted: {
        console.log("[OverviewController] Module loaded")
    }
}
