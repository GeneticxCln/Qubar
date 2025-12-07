import QtQuick
import "models" as Models

QtObject {
    id: windowTracker
    
    // ═══════════════════════════════════════════════════════════
    // DEPENDENCIES
    // ═══════════════════════════════════════════════════════════
    required property var hyprlandIPC
    required property var workspaceManager
    
    // ═══════════════════════════════════════════════════════════
    // SIGNALS
    // ═══════════════════════════════════════════════════════════
    signal windowsLoaded()
    signal windowOpened(var window)
    signal windowClosed(string address)
    signal windowFocused(string address, string previousAddress)
    signal windowMoved(string address, int fromWorkspace, int toWorkspace)
    signal windowTitleChanged(string address, string title)
    signal windowFullscreenChanged(string address, bool fullscreen)
    
    // ═══════════════════════════════════════════════════════════
    // PROPERTIES
    // ═══════════════════════════════════════════════════════════
    property var windows: ({})             // Map: address -> WindowModel
    property var windowList: []            // Array for iteration
    property var focusedWindow: null
    property string focusedWindowAddress: ""
    property bool loaded: false
    
    // ═══════════════════════════════════════════════════════════
    // PUBLIC FUNCTIONS
    // ═══════════════════════════════════════════════════════════
    
    function initialize() {
        console.log("[WindowTracker] Initializing...")
        loadWindows()
    }
    
    function loadWindows() {
        hyprlandIPC.query("clients", function(err, data) {
            if (err) {
                console.error("[WindowTracker] Failed to load windows:", err)
                return
            }
            
            var newWindows = {}
            var newWindowList = []
            
            for (var i = 0; i < data.length; i++) {
                var client = data[i]
                var window = createWindowFromHyprland(client)
                if (window) {
                    newWindows[window.address] = window
                    newWindowList.push(window)
                    
                    // Update workspace occupancy
                    workspaceManager.markWorkspaceOccupied(window.workspaceId, true)
                }
            }
            
            windows = newWindows
            windowList = newWindowList
            
            // Get focused window
            hyprlandIPC.query("activewindow", function(err2, activeData) {
                if (!err2 && activeData && activeData.address) {
                    setFocusedWindow(activeData.address)
                }
                
                loaded = true
                console.log("[WindowTracker] Loaded", windowList.length, "windows")
                windowsLoaded()
            })
        })
    }
    
    function getWindow(address) {
        return windows[address] || null
    }
    
    function getWindowsForWorkspace(workspaceId) {
        return windowList.filter(function(w) {
            return w.workspaceId === workspaceId
        })
    }
    
    function setFocusedWindow(address) {
        var previousAddress = focusedWindowAddress
        
        // Unfocus previous
        if (focusedWindow) {
            focusedWindow.focused = false
        }
        
        // Focus new
        var window = getWindow(address)
        if (window) {
            window.focused = true
            focusedWindow = window
            focusedWindowAddress = address
            
            if (previousAddress !== address) {
                console.log("[WindowTracker] Focused window:", previousAddress.slice(-8), "->", address.slice(-8))
                windowFocused(address, previousAddress)
            }
        } else {
            focusedWindow = null
            focusedWindowAddress = ""
            if (previousAddress !== "") {
                windowFocused("", previousAddress)
            }
        }
    }
    
    // ═══════════════════════════════════════════════════════════
    // INTERNAL HELPERS
    // ═══════════════════════════════════════════════════════════
    
    function createWindowFromHyprland(data) {
        var component = Qt.createComponent("models/WindowModel.qml")
        if (component.status === Component.Ready) {
            var window = component.createObject(windowTracker, {
                address: data.address || "",
                title: data.title || "Unknown",
                appId: data.class || "",
                icon: getIconForApp(data.class),
                workspaceId: data.workspace ? (data.workspace.id || data.workspace) : 0,
                fullscreen: data.fullscreen || false,
                floating: data.floating || false,
                pid: data.pid || 0,
                initialClass: data.initialClass || data.class || "",
                initialTitle: data.initialTitle || data.title || ""
            })
            return window
        } else {
            console.error("[WindowTracker] Failed to create WindowModel:", component.errorString())
            return null
        }
    }
    
    function getIconForApp(appClass) {
        // Map common app classes to icons
        // This can be expanded or use proper icon resolution
        var iconMap = {
            "firefox": "firefox",
            "chromium": "chromium",
            "google-chrome": "google-chrome",
            "code": "visual-studio-code",
            "Code": "visual-studio-code",
            "kitty": "kitty",
            "alacritty": "Alacritty",
            "dolphin": "system-file-manager",
            "thunar": "thunar",
            "nautilus": "org.gnome.Nautilus",
            "spotify": "spotify",
            "discord": "discord",
            "telegram-desktop": "telegram",
            "slack": "slack"
        }
        
        return iconMap[appClass] || appClass || "application-x-executable"
    }
    
    function addWindow(address, workspaceId, appClass, title) {
        if (windows[address]) return // Already exists
        
        var window = createWindowFromHyprland({
            address: address,
            title: title || "Unknown",
            class: appClass || "",
            workspace: { id: parseInt(workspaceId) || 0 }
        })
        
        if (window) {
            var newWindows = Object.assign({}, windows)
            newWindows[address] = window
            windows = newWindows
            windowList = windowList.concat([window])
            
            workspaceManager.markWorkspaceOccupied(window.workspaceId, true)
            
            console.log("[WindowTracker] Window opened:", appClass, "-", title)
            windowOpened(window)
        }
    }
    
    function removeWindow(address) {
        var window = windows[address]
        if (!window) return
        
        var wsId = window.workspaceId
        
        // Remove from map
        var newWindows = Object.assign({}, windows)
        delete newWindows[address]
        windows = newWindows
        
        // Remove from list
        windowList = windowList.filter(function(w) {
            return w.address !== address
        })
        
        // Update workspace occupancy
        var wsWindows = getWindowsForWorkspace(wsId)
        if (wsWindows.length === 0) {
            workspaceManager.markWorkspaceOccupied(wsId, false)
        }
        
        // Clear focus if needed
        if (focusedWindowAddress === address) {
            focusedWindow = null
            focusedWindowAddress = ""
        }
        
        console.log("[WindowTracker] Window closed:", address.slice(-8))
        windowClosed(address)
        
        window.destroy()
    }
    
    function moveWindow(address, newWorkspaceId) {
        var window = windows[address]
        if (!window) return
        
        var fromWorkspace = window.workspaceId
        var toWorkspace = parseInt(newWorkspaceId)
        
        if (fromWorkspace === toWorkspace) return
        
        window.workspaceId = toWorkspace
        
        // Update workspace occupancies
        var oldWsWindows = getWindowsForWorkspace(fromWorkspace)
        if (oldWsWindows.length === 0) {
            workspaceManager.markWorkspaceOccupied(fromWorkspace, false)
        }
        workspaceManager.markWorkspaceOccupied(toWorkspace, true)
        
        console.log("[WindowTracker] Window moved:", address.slice(-8), "from", fromWorkspace, "to", toWorkspace)
        windowMoved(address, fromWorkspace, toWorkspace)
    }
    
    function updateWindowTitle(address, title) {
        var window = windows[address]
        if (!window) return
        
        if (window.title !== title) {
            window.title = title
            console.log("[WindowTracker] Window title changed:", address.slice(-8), "->", title)
            windowTitleChanged(address, title)
        }
    }
    
    // Query window title from Hyprland (since windowtitle event only sends address)
    function queryWindowTitle(address) {
        hyprlandIPC.query("clients", function(err, clients) {
            if (err) {
                console.warn("[WindowTracker] Failed to query window title:", err)
                return
            }
            
            for (var i = 0; i < clients.length; i++) {
                if (clients[i].address === address) {
                    updateWindowTitle(address, clients[i].title || "Unknown")
                    return
                }
            }
        })
    }
    
    // ═══════════════════════════════════════════════════════════
    // IPC EVENT HANDLERS
    // ═══════════════════════════════════════════════════════════
    
    function handleIPCEvent(eventType, data) {
        switch (eventType) {
            case "openwindow":
                addWindow(data.address, data.workspace, data.class, data.title)
                break
                
            case "closewindow":
                removeWindow(data.address)
                break
                
            case "activewindow":
            case "activewindowv2":
                setFocusedWindow(data.address || "")
                break
                
            case "movewindow":
                moveWindow(data.address, data.workspace)
                break
                
            case "windowtitle":
                // Hyprland only sends address, query for actual title
                queryWindowTitle(data.address)
                break
                
            case "fullscreen":
                if (focusedWindow) {
                    focusedWindow.fullscreen = data.state
                    windowFullscreenChanged(focusedWindow.address, data.state)
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
            windowTracker.handleIPCEvent(eventType, data)
        }
    }
    
    Component.onCompleted: {
        console.log("[WindowTracker] Module loaded")
    }
}
