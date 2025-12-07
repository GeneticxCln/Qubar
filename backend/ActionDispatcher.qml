import QtQuick

QtObject {
    id: actionDispatcher
    
    // ═══════════════════════════════════════════════════════════
    // DEPENDENCIES
    // ═══════════════════════════════════════════════════════════
    required property var hyprlandIPC
    
    // ═══════════════════════════════════════════════════════════
    // SIGNALS
    // ═══════════════════════════════════════════════════════════
    signal actionSucceeded(string action, var data)
    signal actionFailed(string action, string error)
    
    // ═══════════════════════════════════════════════════════════
    // WORKSPACE ACTIONS
    // ═══════════════════════════════════════════════════════════
    
    function switchWorkspace(id) {
        return executeAction("workspace " + id, "switchWorkspace", { id: id })
    }
    
    function switchToNextWorkspace() {
        return executeAction("workspace e+1", "nextWorkspace", {})
    }
    
    function switchToPreviousWorkspace() {
        return executeAction("workspace e-1", "previousWorkspace", {})
    }
    
    // ═══════════════════════════════════════════════════════════
    // WINDOW ACTIONS
    // ═══════════════════════════════════════════════════════════
    
    function focusWindow(address) {
        return executeAction("focuswindow address:" + address, "focusWindow", { address: address })
    }
    
    function closeWindow(address) {
        return executeAction("closewindow address:" + address, "closeWindow", { address: address })
    }
    
    function closeActiveWindow() {
        return executeAction("killactive", "closeActiveWindow", {})
    }
    
    function moveWindowToWorkspace(address, workspaceId) {
        return executeAction(
            "movetoworkspacesilent " + workspaceId + ",address:" + address,
            "moveWindow",
            { address: address, workspace: workspaceId }
        )
    }
    
    function moveActiveWindowToWorkspace(workspaceId) {
        return executeAction(
            "movetoworkspace " + workspaceId,
            "moveActiveWindow",
            { workspace: workspaceId }
        )
    }
    
    // ═══════════════════════════════════════════════════════════
    // WINDOW STATE TOGGLES
    // ═══════════════════════════════════════════════════════════
    
    function toggleFullscreen(address) {
        if (address) {
            // Focus first, then toggle
            executeAction("focuswindow address:" + address, null, {})
        }
        return executeAction("fullscreen 0", "toggleFullscreen", { address: address })
    }
    
    function toggleFloating(address) {
        if (address) {
            executeAction("focuswindow address:" + address, null, {})
        }
        return executeAction("togglefloating", "toggleFloating", { address: address })
    }
    
    function minimizeWindow(address) {
        if (address) {
            executeAction("focuswindow address:" + address, null, {})
        }
        return executeAction("togglespecialworkspace minimized", "minimize", { address: address })
    }
    
    function pinWindow(address) {
        if (address) {
            executeAction("focuswindow address:" + address, null, {})
        }
        return executeAction("pin", "pinWindow", { address: address })
    }
    
    // ═══════════════════════════════════════════════════════════
    // FOCUS NAVIGATION
    // ═══════════════════════════════════════════════════════════
    
    function focusNext() {
        return executeAction("cyclenext", "focusNext", {})
    }
    
    function focusPrevious() {
        return executeAction("cyclenext prev", "focusPrevious", {})
    }
    
    function focusDirection(direction) {
        // direction: l, r, u, d (left, right, up, down)
        return executeAction("movefocus " + direction, "focusDirection", { direction: direction })
    }
    
    // ═══════════════════════════════════════════════════════════
    // SPECIAL ACTIONS
    // ═══════════════════════════════════════════════════════════
    
    function reloadHyprland() {
        return executeAction("reload", "reloadHyprland", {})
    }
    
    function exitHyprland() {
        return executeAction("exit", "exitHyprland", {})
    }
    
    function lockScreen() {
        // This uses hyprlock if installed
        return executeCommand("hyprlock", "lockScreen", {})
    }
    
    // ═══════════════════════════════════════════════════════════
    // INTERNAL EXECUTION
    // ═══════════════════════════════════════════════════════════
    
    function executeAction(command, actionName, data) {
        if (!hyprlandIPC || !hyprlandIPC.connected) {
            if (actionName) {
                console.warn("[ActionDispatcher] Cannot execute - IPC not connected")
                actionFailed(actionName, "IPC not connected")
            }
            return false
        }
        
        console.log("[ActionDispatcher] Executing:", command)
        
        var success = hyprlandIPC.sendCommand("dispatch " + command)
        
        if (success && actionName) {
            actionSucceeded(actionName, data)
        } else if (!success && actionName) {
            actionFailed(actionName, "Failed to send command")
        }
        
        return success
    }
    
    function executeCommand(command, actionName, data) {
        // For non-dispatch commands (raw)
        if (!hyprlandIPC || !hyprlandIPC.connected) {
            if (actionName) {
                actionFailed(actionName, "IPC not connected")
            }
            return false
        }
        
        console.log("[ActionDispatcher] Raw command:", command)
        
        var success = hyprlandIPC.sendCommand(command)
        
        if (success && actionName) {
            actionSucceeded(actionName, data)
        } else if (!success && actionName) {
            actionFailed(actionName, "Failed to send command")
        }
        
        return success
    }
    
    // ═══════════════════════════════════════════════════════════
    // INITIALIZATION
    // ═══════════════════════════════════════════════════════════
    
    Component.onCompleted: {
        console.log("[ActionDispatcher] Module loaded")
    }
}
