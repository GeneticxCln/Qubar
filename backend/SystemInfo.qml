import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower
import "models" as Models

QtObject {
    id: systemInfo
    
    // ═══════════════════════════════════════════════════════════
    // SIGNALS
    // ═══════════════════════════════════════════════════════════
    signal clockTick()
    signal batteryChanged()
    signal networkChanged()
    signal audioChanged()
    signal providerError(string provider, string message)
    
    // ═══════════════════════════════════════════════════════════
    // DATA MODEL
    // ═══════════════════════════════════════════════════════════
    property var info: Models.SystemInfoModel {}
    
    // ═══════════════════════════════════════════════════════════
    // CLOCK
    // ═══════════════════════════════════════════════════════════
    
    Timer {
        id: clockTimer
        interval: 1000
        repeat: true
        running: true
        
        onTriggered: {
            updateClock()
        }
    }
    
    function updateClock() {
        var now = new Date()
        info.updateClock(now)
        clockTick()
    }
    
    // ═══════════════════════════════════════════════════════════
    // BATTERY (via UPower)
    // ═══════════════════════════════════════════════════════════
    
    // UPower device binding
    property var batteryDevice: UPower.displayDevice
    
    Connections {
        target: systemInfo.batteryDevice
        
        function onPercentageChanged() {
            updateBattery()
        }
        
        function onStateChanged() {
            updateBattery()
        }
    }
    
    function updateBattery() {
        if (!batteryDevice) {
            info.hasBattery = false
            return
        }
        
        try {
            info.hasBattery = batteryDevice.isPresent || batteryDevice.type === UPowerDeviceType.Battery
            info.batteryPercent = Math.round(batteryDevice.percentage || 0)
            
            var state = batteryDevice.state
            info.charging = (state === UPowerDeviceState.Charging)
            info.fullyCharged = (state === UPowerDeviceState.FullyCharged)
            
            if (info.charging) {
                info.batteryState = "charging"
            } else if (info.fullyCharged) {
                info.batteryState = "full"
            } else if (state === UPowerDeviceState.Discharging) {
                info.batteryState = "discharging"
            } else {
                info.batteryState = "unknown"
            }
            
            info.timeToEmpty = batteryDevice.timeToEmpty || 0
            info.timeToFull = batteryDevice.timeToFull || 0
            
            batteryChanged()
        } catch (e) {
            console.warn("[SystemInfo] Battery error:", e.message)
            providerError("battery", e.message)
            info.hasBattery = false
        }
    }
    
    // ═══════════════════════════════════════════════════════════
    // NETWORK
    // ═══════════════════════════════════════════════════════════
    
    Timer {
        id: networkTimer
        interval: 5000  // Check every 5 seconds
        repeat: true
        running: true
        
        onTriggered: {
            updateNetwork()
        }
    }
    
    Process {
        id: networkProcess
        command: ["nmcli", "-t", "-f", "TYPE,STATE,CONNECTION", "device"]
        
        onFinished: {
            parseNetworkOutput(stdout)
        }
        
        onError: (msg) => {
            console.warn("[SystemInfo] Network check failed:", msg)
            providerError("network", msg)
            info.networkConnected = false
            info.networkType = "none"
        }
    }
    
    function updateNetwork() {
        networkProcess.start()
    }
    
    function parseNetworkOutput(output) {
        var lines = output.trim().split("\n")
        var connected = false
        var networkType = "none"
        var networkName = ""
        
        for (var i = 0; i < lines.length; i++) {
            var parts = lines[i].split(":")
            if (parts.length >= 3) {
                var type = parts[0]
                var state = parts[1]
                var connection = parts[2]
                
                if (state === "connected") {
                    connected = true
                    if (type === "wifi") {
                        networkType = "wifi"
                        networkName = connection
                    } else if (type === "ethernet") {
                        networkType = "ethernet"
                        networkName = "Ethernet"
                    }
                }
            }
        }
        
        var changed = (info.networkConnected !== connected || 
                       info.networkType !== networkType ||
                       info.networkName !== networkName)
        
        info.networkConnected = connected
        info.networkType = networkType
        info.networkName = networkName
        
        if (changed) {
            console.log("[SystemInfo] Network:", networkType, connected ? "connected" : "disconnected", networkName)
            networkChanged()
        }
        
        // Get WiFi signal strength if connected to WiFi
        if (networkType === "wifi") {
            updateWifiSignal()
        } else {
            info.wifiSignalStrength = 0
        }
    }
    
    Process {
        id: wifiSignalProcess
        command: ["nmcli", "-t", "-f", "SIGNAL", "device", "wifi", "list", "--rescan", "no"]
        
        onFinished: {
            var lines = stdout.trim().split("\n")
            if (lines.length > 0 && lines[0]) {
                var signal = parseInt(lines[0])
                if (!isNaN(signal)) {
                    info.wifiSignalStrength = signal
                }
            }
        }
    }
    
    function updateWifiSignal() {
        wifiSignalProcess.start()
    }
    
    // ═══════════════════════════════════════════════════════════
    // AUDIO (placeholder - can integrate with Pipewire service)
    // ═══════════════════════════════════════════════════════════
    
    Process {
        id: audioProcess
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
        
        onFinished: {
            parseAudioOutput(stdout)
        }
    }
    
    Timer {
        id: audioTimer
        interval: 2000
        repeat: true
        running: true
        
        onTriggered: {
            audioProcess.start()
        }
    }
    
    function parseAudioOutput(output) {
        // Output format: "Volume: 0.50 [MUTED]" or "Volume: 0.50"
        var match = output.match(/Volume:\s*([\d.]+)/)
        if (match) {
            var vol = Math.round(parseFloat(match[1]) * 100)
            var muted = output.includes("[MUTED]")
            
            var changed = (info.volume !== vol || info.muted !== muted)
            
            info.volume = vol
            info.muted = muted
            
            if (changed) {
                audioChanged()
            }
        }
    }
    
    // ═══════════════════════════════════════════════════════════
    // SYSTEM INFO
    // ═══════════════════════════════════════════════════════════
    
    function loadSystemInfo() {
        info.hostname = Qt.platform.hostname || ""
        info.username = Qt.getenv("USER") || ""
    }
    
    // ═══════════════════════════════════════════════════════════
    // INITIALIZATION
    // ═══════════════════════════════════════════════════════════
    
    function initialize() {
        console.log("[SystemInfo] Initializing...")
        
        loadSystemInfo()
        updateClock()
        updateBattery()
        updateNetwork()
        audioProcess.start()
        
        console.log("[SystemInfo] Initialized")
    }
    
    Component.onCompleted: {
        console.log("[SystemInfo] Module loaded")
    }
}
