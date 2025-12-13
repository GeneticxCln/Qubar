import QtQuick
import Quickshell.Io

QtObject {
    id: stateManager
    
    // ═══════════════════════════════════════════════════════════
    // SIGNALS
    // ═══════════════════════════════════════════════════════════
    signal stateLoaded()
    signal stateSaved()
    signal stateError(string message)
    
    // ═══════════════════════════════════════════════════════════
    // PROPERTIES
    // ═══════════════════════════════════════════════════════════
    
    // File path for state persistence
    readonly property string statePath: Qt.getenv("HOME") + "/.config/quickshell/qubar_state.json"
    
    // Auto-save interval (ms) - 0 to disable
    property int autoSaveInterval: 30000  // 30 seconds
    
    // Current state
    property var state: ({
        version: 1,
        lastActiveWorkspace: 1,
        pinnedWindows: [],
        tabOrder: {},         // workspaceId -> [addresses in order]
        preferences: {
            showClock: true,
            showBattery: true,
            showNetwork: true,
            clockFormat: "24h"
        },
        windowPositions: {},  // address -> { workspace, order }
        lastUpdated: 0
    })
    
    property bool loaded: false
    property bool dirty: false
    
    // ═══════════════════════════════════════════════════════════
    // PUBLIC FUNCTIONS
    // ═══════════════════════════════════════════════════════════
    
    function load() {
        console.log("[StateManager] Loading state from:", statePath)
        loadProcess.start()
    }
    
    function save() {
        if (!dirty && loaded) {
            console.log("[StateManager] No changes to save")
            return
        }
        
        state.lastUpdated = Date.now()
        
        var json = JSON.stringify(state, null, 2)
        console.log("[StateManager] Saving state to:", statePath)
        
        saveProcess.stdin = json
        saveProcess.start()
    }
    
    function markDirty() {
        dirty = true
    }
    
    // ═══════════════════════════════════════════════════════════
    // STATE ACCESSORS
    // ═══════════════════════════════════════════════════════════
    
    function setLastActiveWorkspace(workspaceId) {
        if (state.lastActiveWorkspace !== workspaceId) {
            state.lastActiveWorkspace = workspaceId
            markDirty()
        }
    }
    
    function getLastActiveWorkspace() {
        return state.lastActiveWorkspace || 1
    }
    
    function addPinnedWindow(address, appId) {
        var found = state.pinnedWindows.some(function(p) {
            return p.address === address
        })
        
        if (!found) {
            state.pinnedWindows = state.pinnedWindows.concat([{
                address: address,
                appId: appId,
                pinnedAt: Date.now()
            }])
            markDirty()
        }
    }
    
    function removePinnedWindow(address) {
        var original = state.pinnedWindows.length
        state.pinnedWindows = state.pinnedWindows.filter(function(p) {
            return p.address !== address
        })
        
        if (state.pinnedWindows.length !== original) {
            markDirty()
        }
    }
    
    function isPinned(address) {
        return state.pinnedWindows.some(function(p) {
            return p.address === address
        })
    }
    
    function setTabOrder(workspaceId, addresses) {
        state.tabOrder[workspaceId] = addresses
        markDirty()
    }
    
    function getTabOrder(workspaceId) {
        return state.tabOrder[workspaceId] || []
    }
    
    function setPreference(key, value) {
        if (state.preferences[key] !== value) {
            state.preferences[key] = value
            markDirty()
        }
    }
    
    function getPreference(key, defaultValue) {
        return state.preferences.hasOwnProperty(key) ? state.preferences[key] : defaultValue
    }
    
    // ═══════════════════════════════════════════════════════════
    // PROCESSES
    // ═══════════════════════════════════════════════════════════
    
    Process {
        id: loadProcess
        command: ["cat", stateManager.statePath]
        
        onFinished: {
            if (exitCode === 0 && stdout.trim()) {
                try {
                    var loadedData = JSON.parse(stdout)
                    
                    // Merge with defaults to handle version upgrades
                    stateManager.state = Object.assign({}, stateManager.state, loadedData)
                    stateManager.loaded = true
                    stateManager.dirty = false
                    
                    console.log("[StateManager] State loaded, version:", stateManager.state.version)
                    stateLoaded()
                } catch (e) {
                    console.warn("[StateManager] Failed to parse state:", e.message)
                    stateManager.loaded = true
                    stateError("Failed to parse state: " + e.message)
                }
            } else {
                // File doesn't exist or is empty - use defaults
                console.log("[StateManager] No existing state, using defaults")
                stateManager.loaded = true
                stateLoaded()
            }
        }
        
        onError: (message) => {
            console.warn("[StateManager] Load error:", message)
            stateManager.loaded = true
            // Don't emit error - file might just not exist
            stateLoaded()
        }
    }
    
    Process {
        id: saveProcess
        command: ["tee", stateManager.statePath]
        
        onFinished: {
            if (exitCode === 0) {
                console.log("[StateManager] State saved")
                stateManager.dirty = false
                stateSaved()
            } else {
                console.error("[StateManager] Save failed, exit code:", exitCode)
                stateError("Failed to save state")
            }
        }
        
        onError: (message) => {
            console.error("[StateManager] Save error:", message)
            stateError(message)
        }
    }
    
    // ═══════════════════════════════════════════════════════════
    // AUTO-SAVE TIMER
    // ═══════════════════════════════════════════════════════════
    
    Timer {
        id: autoSaveTimer
        interval: stateManager.autoSaveInterval
        repeat: true
        running: stateManager.autoSaveInterval > 0
        
        onTriggered: {
            if (stateManager.dirty) {
                stateManager.save()
            }
        }
    }
    
    // ═══════════════════════════════════════════════════════════
    // INITIALIZATION
    // ═══════════════════════════════════════════════════════════
    
    function initialize() {
        console.log("[StateManager] Initializing...")
        load()
    }
    
    Component.onCompleted: {
        console.log("[StateManager] Module loaded")
    }
    
    Component.onDestruction: {
        // Save on exit if dirty
        if (dirty) {
            save()
        }
    }
}
