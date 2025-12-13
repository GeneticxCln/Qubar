import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: hyprlandIPC
    
    // ═══════════════════════════════════════════════════════════
    // SIGNALS
    // ═══════════════════════════════════════════════════════════
    signal socketConnected()
    signal socketDisconnected()
    signal eventReceived(string eventType, var data)
    signal error(string message)
    
    // ═══════════════════════════════════════════════════════════
    // PROPERTIES
    // ═══════════════════════════════════════════════════════════
    property bool connected: false
    property int reconnectAttempts: 0
    property int maxReconnectAttempts: 5
    property int reconnectDelay: 2000  // ms
    
    // Logging verbosity: 0=errors only, 1=warnings, 2=info, 3=debug (all events)
    property int logLevel: 1
    
    // Hyprland socket paths
    readonly property string hyprlandSignature: Qt.getenv("HYPRLAND_INSTANCE_SIGNATURE")
    readonly property string socketPath: "/tmp/hypr/" + hyprlandSignature + "/.socket.sock"
    readonly property string eventSocketPath: "/tmp/hypr/" + hyprlandSignature + "/.socket2.sock"
    
    // Logging helpers
    function logDebug(msg) { if (logLevel >= 3) console.log(msg) }
    function logInfo(msg) { if (logLevel >= 2) console.log(msg) }
    function logWarn(msg) { if (logLevel >= 1) console.warn(msg) }
    function logError(msg) { console.error(msg) }
    
    // ═══════════════════════════════════════════════════════════
    // SOCKET CONNECTIONS
    // ═══════════════════════════════════════════════════════════
    
    // Command socket (for sending commands and queries)
    Socket {
        id: commandSocket
        path: hyprlandIPC.socketPath
        
        onConnectedChanged: {
            if (connected) {
                console.log("[HyprlandIPC] Command socket connected")
            }
        }
        
        onError: (msg) => {
            console.error("[HyprlandIPC] Command socket error:", msg)
            hyprlandIPC.error(msg)
        }
    }
    
    // Event socket (for receiving events)
    Socket {
        id: eventSocket
        path: hyprlandIPC.eventSocketPath
        
        onConnectedChanged: {
            if (connected) {
                console.log("[HyprlandIPC] Event socket connected")
                hyprlandIPC.connected = true
                hyprlandIPC.reconnectAttempts = 0
                hyprlandIPC.socketConnected()
            } else {
                console.warn("[HyprlandIPC] Event socket disconnected")
                hyprlandIPC.connected = false
                hyprlandIPC.socketDisconnected()
                hyprlandIPC.attemptReconnect()
            }
        }
        
        onData: (data) => {
            hyprlandIPC.parseEvents(data)
        }
        
        onError: (msg) => {
            console.error("[HyprlandIPC] Event socket error:", msg)
            hyprlandIPC.error(msg)
        }
    }
    
    // ═══════════════════════════════════════════════════════════
    // RECONNECT LOGIC
    // ═══════════════════════════════════════════════════════════
    
    Timer {
        id: reconnectTimer
        interval: hyprlandIPC.reconnectDelay
        repeat: false
        onTriggered: hyprlandIPC.connect()
    }
    
    function attemptReconnect() {
        if (reconnectAttempts < maxReconnectAttempts) {
            reconnectAttempts++
            logInfo("[HyprlandIPC] Reconnect attempt " + reconnectAttempts + " of " + maxReconnectAttempts)
            reconnectTimer.start()
        } else {
            logError("[HyprlandIPC] Max reconnect attempts reached")
            error("Failed to connect to Hyprland after " + maxReconnectAttempts + " attempts")
        }
    }
    
    // ═══════════════════════════════════════════════════════════
    // PUBLIC FUNCTIONS
    // ═══════════════════════════════════════════════════════════
    
    function connect() {
        logInfo("[HyprlandIPC] Connecting to Hyprland...")
        logDebug("[HyprlandIPC] Signature: " + hyprlandSignature)
        
        if (!hyprlandSignature) {
            error("HYPRLAND_INSTANCE_SIGNATURE not set. Is Hyprland running?")
            return
        }
        
        eventSocket.connect()
    }
    
    // Send raw command to Hyprland
    function sendCommand(command) {
        if (!connected) {
            logWarn("[HyprlandIPC] Cannot send command - not connected")
            return false
        }
        
        logDebug("[HyprlandIPC] Sending command: " + command)
        commandSocket.write(command + "\n")
        return true
    }
    
    // Query Hyprland (returns via callback)
    function query(request, callback) {
        // Use Process for query since we need response
        var proc = Qt.createQmlObject('\
            import Quickshell.Io\n\
            Process {\
                property var callback\
                running: false\
            }\
        ', hyprlandIPC)
        
        proc.command = ["hyprctl", "-j", request]
        proc.callback = callback
        
        // Handle process errors to prevent memory leaks
        proc.error.connect(function(msg) {
            logError("[HyprlandIPC] Query process error: " + msg)
            proc.callback("Process error: " + msg, null)
            proc.destroy()
        })
        
        proc.exited.connect(function(code, status) {
            if (code !== 0) {
                proc.callback("Process exited with code " + code, null)
                proc.destroy()
                return
            }
            
            try {
                var result = JSON.parse(proc.stdout())
                proc.callback(null, result)
            } catch (e) {
                proc.callback("Failed to parse response: " + e.message, null)
            }
            proc.destroy()
        })
        
        proc.running = true
    }
    
    // Synchronous query using hyprctl
    function querySync(request) {
        // This is a blocking call - use sparingly
        var result = null
        var proc = Qt.createQmlObject('
            import Quickshell.Io
            Process {
                running: false
            }
        ', hyprlandIPC)
        
        proc.command = ["hyprctl", "-j", request]
        proc.start()
        proc.waitForFinished()
        
        try {
            result = JSON.parse(proc.stdout())
        } catch (e) {
            console.error("[HyprlandIPC] Query parse error:", e.message)
        }
        
        proc.destroy()
        return result
    }
    
    // ═══════════════════════════════════════════════════════════
    // EVENT PARSING
    // ═══════════════════════════════════════════════════════════
    
    function parseEvents(rawData) {
        // Validate input
        if (!rawData) {
            logWarn("[HyprlandIPC] Received empty/null event data")
            return
        }
        
        try {
            var dataStr = rawData.toString()
            if (!dataStr || dataStr.trim().length === 0) {
                return
            }
            
            var lines = dataStr.trim().split("\n")
            
            for (var i = 0; i < lines.length; i++) {
                var line = lines[i].trim()
                if (!line) continue
                
                // Hyprland events format: "eventname>>data"
                var separatorIndex = line.indexOf(">>")
                if (separatorIndex === -1) {
                    logDebug("[HyprlandIPC] Skipping malformed event line: " + line.substring(0, 50))
                    continue
                }
                
                var eventType = line.substring(0, separatorIndex)
                if (!eventType) {
                    logDebug("[HyprlandIPC] Empty event type, skipping")
                    continue
                }
                
                var eventData = line.substring(separatorIndex + 2)
                
                logDebug("[HyprlandIPC] Event: " + eventType + " Data: " + eventData)
                
                // Parse data based on event type
                var parsedData = parseEventData(eventType, eventData)
                eventReceived(eventType, parsedData)
            }
        } catch (e) {
            logError("[HyprlandIPC] Error parsing events: " + e.message)
        }
    }
    
    function parseEventData(eventType, rawData) {
        // Parse comma-separated data for different event types
        var parts = rawData.split(",")
        
        switch (eventType) {
            case "workspace":
            case "focusedmon":
                return { name: parts[0] }
                
            case "activewindow":
                return { class: parts[0], title: parts[1] || "" }
                
            case "activewindowv2":
                return { address: parts[0] }
                
            case "openwindow":
                return {
                    address: parts[0],
                    workspace: parts[1],
                    class: parts[2],
                    title: parts[3] || ""
                }
                
            case "closewindow":
                return { address: parts[0] }
                
            case "movewindow":
                return { address: parts[0], workspace: parts[1] }
                
            case "windowtitle":
                // Note: Hyprland only sends address, not the new title
                // The WindowTracker must query the title separately
                return { address: parts[0] }
                
            case "createworkspace":
            case "destroyworkspace":
                return { name: parts[0] }
                
            case "fullscreen":
                return { state: parts[0] === "1" }
                
            case "urgent":
                return { address: parts[0] }
                
            default:
                return { raw: rawData }
        }
    }
    
    // ═══════════════════════════════════════════════════════════
    // INITIALIZATION
    // ═══════════════════════════════════════════════════════════
    
    Component.onCompleted: {
        console.log("[HyprlandIPC] Module loaded")
    }
}
