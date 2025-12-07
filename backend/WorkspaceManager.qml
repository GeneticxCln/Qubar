import QtQuick
import "models" as Models

QtObject {
    id: workspaceManager
    
    // ═══════════════════════════════════════════════════════════
    // DEPENDENCIES
    // ═══════════════════════════════════════════════════════════
    required property var hyprlandIPC
    
    // ═══════════════════════════════════════════════════════════
    // SIGNALS
    // ═══════════════════════════════════════════════════════════
    signal workspacesLoaded()
    signal activeWorkspaceChanged(int id, int previousId)
    signal workspaceCreated(int id)
    signal workspaceDestroyed(int id)
    signal workspaceOccupiedChanged(int id, bool occupied)
    
    // ═══════════════════════════════════════════════════════════
    // PROPERTIES
    // ═══════════════════════════════════════════════════════════
    property var workspaces: []           // Array of WorkspaceModel
    property var activeWorkspace: null    // Current WorkspaceModel
    property int activeWorkspaceId: 0
    property bool loaded: false
    
    // Configuration
    property int maxWorkspaces: 9
    
    // ═══════════════════════════════════════════════════════════
    // PUBLIC FUNCTIONS
    // ═══════════════════════════════════════════════════════════
    
    function initialize() {
        console.log("[WorkspaceManager] Initializing...")
        loadWorkspaces()
    }
    
    function loadWorkspaces() {
        hyprlandIPC.query("workspaces", function(err, data) {
            if (err) {
                console.error("[WorkspaceManager] Failed to load workspaces:", err)
                return
            }
            
            // Initialize workspace slots
            var newWorkspaces = []
            for (var i = 1; i <= maxWorkspaces; i++) {
                var ws = createWorkspace(i)
                newWorkspaces.push(ws)
            }
            
            // Update with actual data from Hyprland
            for (var j = 0; j < data.length; j++) {
                var hyprWs = data[j]
                var wsId = hyprWs.id
                if (wsId >= 1 && wsId <= maxWorkspaces) {
                    newWorkspaces[wsId - 1].name = hyprWs.name || String(wsId)
                    newWorkspaces[wsId - 1].occupied = hyprWs.windows > 0
                }
            }
            
            workspaces = newWorkspaces
            
            // Get active workspace
            hyprlandIPC.query("activeworkspace", function(err2, activeData) {
                if (!err2 && activeData) {
                    setActiveWorkspace(activeData.id)
                }
                
                loaded = true
                console.log("[WorkspaceManager] Loaded", workspaces.length, "workspaces")
                workspacesLoaded()
            })
        })
    }
    
    function getWorkspace(id) {
        if (id >= 1 && id <= workspaces.length) {
            return workspaces[id - 1]
        }
        return null
    }
    
    function setActiveWorkspace(id) {
        var previousId = activeWorkspaceId
        
        // Deactivate previous
        if (activeWorkspace) {
            activeWorkspace.active = false
        }
        
        // Activate new
        var ws = getWorkspace(id)
        if (ws) {
            ws.active = true
            activeWorkspace = ws
            activeWorkspaceId = id
            
            if (previousId !== id) {
                console.log("[WorkspaceManager] Active workspace:", previousId, "->", id)
                activeWorkspaceChanged(id, previousId)
            }
        }
    }
    
    function markWorkspaceOccupied(id, occupied) {
        var ws = getWorkspace(id)
        if (ws && ws.occupied !== occupied) {
            ws.occupied = occupied
            workspaceOccupiedChanged(id, occupied)
        }
    }
    
    // ═══════════════════════════════════════════════════════════
    // INTERNAL HELPERS
    // ═══════════════════════════════════════════════════════════
    
    function createWorkspace(id) {
        var component = Qt.createComponent("models/WorkspaceModel.qml")
        if (component.status === Component.Ready) {
            var ws = component.createObject(workspaceManager, {
                id: id,
                name: String(id),
                active: false,
                occupied: false
            })
            return ws
        } else {
            console.error("[WorkspaceManager] Failed to create WorkspaceModel:", component.errorString())
            return null
        }
    }
    
    // ═══════════════════════════════════════════════════════════
    // IPC EVENT HANDLERS
    // ═══════════════════════════════════════════════════════════
    
    function handleIPCEvent(eventType, data) {
        switch (eventType) {
            case "workspace":
                // Active workspace changed
                var wsId = parseInt(data.name)
                if (!isNaN(wsId)) {
                    setActiveWorkspace(wsId)
                }
                break
                
            case "createworkspace":
                var newId = parseInt(data.name)
                if (!isNaN(newId) && newId >= 1 && newId <= maxWorkspaces) {
                    console.log("[WorkspaceManager] Workspace created:", newId)
                    workspaceCreated(newId)
                }
                break
                
            case "destroyworkspace":
                var destroyedId = parseInt(data.name)
                if (!isNaN(destroyedId) && destroyedId >= 1 && destroyedId <= maxWorkspaces) {
                    markWorkspaceOccupied(destroyedId, false)
                    console.log("[WorkspaceManager] Workspace destroyed:", destroyedId)
                    workspaceDestroyed(destroyedId)
                }
                break
        }
    }
    
    // ═══════════════════════════════════════════════════════════
    // CONNECTIONS
    // ═══════════════════════════════════════════════════════════
    
    Connections {
        target: hyprlandIPC
        function onEventReceived(eventType, data) {
            workspaceManager.handleIPCEvent(eventType, data)
        }
    }
    
    Component.onCompleted: {
        console.log("[WorkspaceManager] Module loaded")
    }
}
