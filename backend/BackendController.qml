import QtQuick
import "settings" as settings

QtObject {
    id: backendController
    
    // ═══════════════════════════════════════════════════════════
    // SIGNALS
    // ═══════════════════════════════════════════════════════════
    signal backendReady()
    signal backendError(string module, string message)
    signal ipcWarning()
    signal ipcRecovered()
    
    // ═══════════════════════════════════════════════════════════
    // STATE
    // ═══════════════════════════════════════════════════════════
    property bool ready: false
    property bool ipcConnected: false
    property bool testMode: false
    
    // Logging: 0=errors, 1=warnings, 2=info, 3=debug
    property int logLevel: 1
    
    // Initialization tracking
    property bool _ipcReady: false
    property bool _workspacesReady: false
    property bool _windowsReady: false
    property bool _systemInfoReady: false
    
    // ═══════════════════════════════════════════════════════════
    // BACKEND MODULES
    // ═══════════════════════════════════════════════════════════
    
    // Layer 1: IPC
    HyprlandIPC {
        id: hyprlandIPC
        logLevel: backendController.logLevel
    }
    
    // Layer 2: State Managers
    WorkspaceManager {
        id: workspaceManager
        hyprlandIPC: hyprlandIPC
    }
    
    WindowTracker {
        id: windowTracker
        hyprlandIPC: hyprlandIPC
        workspaceManager: workspaceManager
    }
    
    SystemInfo {
        id: systemInfo
    }
    
    // Layer 3: Actions
    ActionDispatcher {
        id: actionDispatcher
        hyprlandIPC: hyprlandIPC
    }
    
    ShortcutManager {
        id: shortcutManager
        backend: backendController
    }
    
    // Signals for Shortcuts
    signal requestToggleLauncher()
    
    // Optional Modules
    TabGroupManager {
        id: tabGroupManager
    }
    
    EventDebouncer {
        id: eventDebouncer
    }
    
    StateManager {
        id: stateManager
    }
    
    // ═══════════════════════════════════════════════════════════
    // ADVANCED FEATURES
    // ═══════════════════════════════════════════════════════════
    
    property alias media: mediaController
    property alias notifications: notificationController
    property alias icons: iconProvider
    property alias screenshots: screenshotProvider
    
    MediaController {
        id: mediaController
    }
    
    NotificationController {
        id: notificationController
    }
    
    IconProvider {
        id: iconProvider
    }
    
    ScreenshotProvider {
        id: screenshotProvider
    }
    
    // ═══════════════════════════════════════════════════════════
    // SETTINGS CONTROLLERS
    // ═══════════════════════════════════════════════════════════
    
    property alias audio: audioController
    property alias display: displayController
    property alias network: networkController
    property alias bluetooth: bluetoothController
    property alias power: powerController
    
    settings.AudioController {
        id: audioController
    }
    
    settings.DisplayController {
        id: displayController
    }
    
    settings.NetworkController {
        id: networkController
    }
    
    settings.BluetoothController {
        id: bluetoothController
    }
    
    settings.PowerController {
        id: powerController
    }
    
    settings.FanController {
        id: fanController
    }
    
    property alias fans: fanController
    
    // ═══════════════════════════════════════════════════════════
    // APP LAUNCHER
    // ═══════════════════════════════════════════════════════════
    
    property alias launcher: appLauncher
    
    AppLauncher {
        id: appLauncher
    }
    
    // ═══════════════════════════════════════════════════════════
    // OVERVIEW CONTROLLER
    // ═══════════════════════════════════════════════════════════
    
    property alias overview: overviewController
    
    OverviewController {
        id: overviewController
        windowTracker: windowTracker
        workspaceManager: workspaceManager
        appLauncher: appLauncher
        actionDispatcher: actionDispatcher
    }
    
    // ═══════════════════════════════════════════════════════════
    // EXPOSED PROPERTIES (Unified API for frontend)
    // ═══════════════════════════════════════════════════════════
    
    // Workspaces
    readonly property var workspaces: workspaceManager.workspaces
    readonly property var activeWorkspace: workspaceManager.activeWorkspace
    readonly property int activeWorkspaceId: workspaceManager.activeWorkspaceId
    
    // Windows
    readonly property var windows: windowTracker.windowList
    readonly property var focusedWindow: windowTracker.focusedWindow
    readonly property string focusedWindowAddress: windowTracker.focusedWindowAddress
    
    // System Info
    readonly property var systemInfoData: systemInfo.info
    
    // Tab Groups
    readonly property var tabGroups: tabGroupManager.groupList
    
    // State
    readonly property var savedState: stateManager.state
    
    // ═══════════════════════════════════════════════════════════
    // EXPOSED FUNCTIONS (Unified API for frontend)
    // ═══════════════════════════════════════════════════════════
    
    // Workspace Actions
    function switchWorkspace(id) {
        return actionDispatcher.switchWorkspace(id)
    }
    
    function nextWorkspace() {
        return actionDispatcher.switchToNextWorkspace()
    }
    
    function previousWorkspace() {
        return actionDispatcher.switchToPreviousWorkspace()
    }
    
    // Window Actions
    function focusWindow(address) {
        return actionDispatcher.focusWindow(address)
    }
    
    function closeWindow(address) {
        return actionDispatcher.closeWindow(address)
    }
    
    function closeActiveWindow() {
        return actionDispatcher.closeActiveWindow()
    }
    
    function moveWindowToWorkspace(address, workspaceId) {
        return actionDispatcher.moveWindowToWorkspace(address, workspaceId)
    }
    
    function toggleFullscreen(address) {
        return actionDispatcher.toggleFullscreen(address)
    }
    
    function toggleFloating(address) {
        return actionDispatcher.toggleFloating(address)
    }
    
    // Get windows for specific workspace
    function getWindowsForWorkspace(workspaceId) {
        return windowTracker.getWindowsForWorkspace(workspaceId)
    }
    
    // Get specific workspace
    function getWorkspace(id) {
        return workspaceManager.getWorkspace(id)
    }
    
    // Tab Group Functions
    function getTabGroup(groupId) {
        return tabGroupManager.getGroup(groupId)
    }
    
    function getGroupForWindow(address) {
        return tabGroupManager.getGroupForWindow(address)
    }
    
    // State/Preferences
    function saveState() {
        stateManager.save()
    }
    
    function getPreference(key, defaultValue) {
        return stateManager.getPreference(key, defaultValue)
    }
    
    function setPreference(key, value) {
        stateManager.setPreference(key, value)
    }
    
    // Debounce helpers
    function debounceEvent(name, data, delay) {
        eventDebouncer.debounce(name, data, delay)
    }
    
    // ═══════════════════════════════════════════════════════════
    // TEST HOOKS
    // ═══════════════════════════════════════════════════════════
    
    function simulateEvent(eventType, data) {
        if (!testMode) {
            console.warn("[BackendController] simulateEvent only works in testMode")
            return
        }
        
        console.log("[BackendController] Simulating event:", eventType, JSON.stringify(data))
        workspaceManager.handleIPCEvent(eventType, data)
        windowTracker.handleIPCEvent(eventType, data)
    }
    
    function getState() {
        return {
            ready: ready,
            ipcConnected: ipcConnected,
            activeWorkspaceId: activeWorkspaceId,
            focusedWindowAddress: focusedWindowAddress,
            windowCount: windows.length,
            workspaces: workspaces.map(function(ws) {
                return {
                    id: ws.id,
                    name: ws.name,
                    active: ws.active,
                    occupied: ws.occupied,
                    windowCount: ws.windowCount
                }
            }),
            systemInfo: {
                time: systemInfoData.time,
                batteryPercent: systemInfoData.batteryPercent,
                networkConnected: systemInfoData.networkConnected
            }
        }
    }
    
    // ═══════════════════════════════════════════════════════════
    // INITIALIZATION SEQUENCE
    // ═══════════════════════════════════════════════════════════
    
    function initialize() {
        console.log("═══════════════════════════════════════════════════")
        console.log("[BackendController] Starting initialization...")
        console.log("═══════════════════════════════════════════════════")
        
        if (testMode) {
            console.log("[BackendController] Running in TEST MODE")
            _ipcReady = true
            ipcConnected = true
            initializeManagers()
            return
        }
        
        // Step 1: Connect IPC
        hyprlandIPC.connect()
    }
    
    function initializeManagers() {
        // Step 2: Initialize workspace manager
        workspaceManager.initialize()
    }
    
    function checkReady() {
        if (_ipcReady && _workspacesReady && _windowsReady) {
            ready = true
            console.log("═══════════════════════════════════════════════════")
            console.log("[BackendController] Backend READY")
            console.log("═══════════════════════════════════════════════════")
            console.log("[BackendController] State:", JSON.stringify(getState(), null, 2))
            backendReady()
        }
    }
    
    // ═══════════════════════════════════════════════════════════
    // SIGNAL CONNECTIONS
    // ═══════════════════════════════════════════════════════════
    
    Connections {
        target: hyprlandIPC
        
        function onSocketConnected() {
            console.log("[BackendController] IPC connected")
            _ipcReady = true
            ipcConnected = true
            
            if (!ready) {
                initializeManagers()
            } else {
                // Reconnected after disconnect
                ipcRecovered()
            }
        }
        
        function onSocketDisconnected() {
            console.log("[BackendController] IPC disconnected")
            ipcConnected = false
            ipcWarning()
        }
        
        function onError(message) {
            console.error("[BackendController] IPC error:", message)
            backendError("hyprlandIPC", message)
        }
    }
    
    Connections {
        target: workspaceManager
        
        function onWorkspacesLoaded() {
            console.log("[BackendController] Workspaces loaded")
            _workspacesReady = true
            
            // Step 3: Initialize window tracker
            windowTracker.initialize()
        }
    }
    
    Connections {
        target: windowTracker
        
        function onWindowsLoaded() {
            console.log("[BackendController] Windows loaded")
            _windowsReady = true
            
            // Step 4: Initialize system info
            systemInfo.initialize()
            _systemInfoReady = true
            
            // Step 5: Initialize state manager
            stateManager.initialize()
            
            checkReady()
        }
    }
    
    Connections {
        target: actionDispatcher
        
        function onActionFailed(action, error) {
            console.warn("[BackendController] Action failed:", action, "-", error)
            backendError("action", action + ": " + error)
        }
    }
    
    // Connect WindowTracker to TabGroupManager
    Connections {
        target: windowTracker
        
        function onWindowOpened(window) {
            // Auto-group windows if applicable
            tabGroupManager.addWindowToGroup(window)
        }
        
        function onWindowClosed(address) {
            tabGroupManager.removeWindowFromGroup(address)
        }
        
        function onWindowFocused(address, previousAddress) {
            tabGroupManager.setActiveWindowInGroup(address)
        }
    }
    
    // Connect workspace changes to state persistence
    Connections {
        target: workspaceManager
        
        function onActiveWorkspaceChanged(id, previousId) {
            stateManager.setLastActiveWorkspace(id)
        }
    }
    
    // Connect debouncer outputs
    Connections {
        target: eventDebouncer
        
        function onDebounced(eventName, data) {
            // Handle debounced events
            if (eventName.startsWith("windowtitle_")) {
                // Debounced title change - update window
                windowTracker.updateWindowTitle(data.address, data.title)
            }
        }
    }
    
    // ═══════════════════════════════════════════════════════════
    // AUTO-START
    // ═══════════════════════════════════════════════════════════
    
    Component.onCompleted: {
        console.log("[BackendController] Module loaded")
        
        // Auto-initialize after a brief delay to ensure all children are ready
        Qt.callLater(initialize)
    }
}
