import QtQuick
import Quickshell.Io

QtObject {
    id: displayController
    
    // ═══════════════════════════════════════════════════════════
    // SIGNALS
    // ═══════════════════════════════════════════════════════════
    signal brightnessChanged(int brightness)
    signal nightLightChanged(bool enabled)
    signal error(string message)
    
    // ═══════════════════════════════════════════════════════════
    // PROPERTIES
    // ═══════════════════════════════════════════════════════════
    property int brightness: 100      // 0-100
    property int maxBrightness: 100
    property bool nightLightEnabled: false
    property int nightLightTemp: 4500 // Kelvin
    
    // ═══════════════════════════════════════════════════════════
    // PUBLIC FUNCTIONS
    // ═══════════════════════════════════════════════════════════
    
    function setBrightness(value) {
        var clamped = Math.max(5, Math.min(100, value)) // Min 5% to avoid black screen
        brightnessSetProcess.command = ["brightnessctl", "set", clamped + "%"]
        brightnessSetProcess.start()
    }
    
    function increaseBrightness(step) {
        setBrightness(brightness + (step || 10))
    }
    
    function decreaseBrightness(step) {
        setBrightness(brightness - (step || 10))
    }
    
    function toggleNightLight() {
        if (nightLightEnabled) {
            disableNightLight()
        } else {
            enableNightLight()
        }
    }
    
    function enableNightLight() {
        // Kill existing, then start with warm temperature
        nightLightProcess.command = ["sh", "-c", "pkill gammastep; gammastep -O " + nightLightTemp]
        nightLightProcess.start()
        nightLightEnabled = true
        nightLightChanged(true)
    }
    
    function disableNightLight() {
        nightLightProcess.command = ["pkill", "gammastep"]
        nightLightProcess.start()
        nightLightEnabled = false
        nightLightChanged(false)
    }
    
    function refresh() {
        brightnessGetProcess.start()
        maxBrightnessProcess.start()
    }
    
    // ═══════════════════════════════════════════════════════════
    // PROCESSES
    // ═══════════════════════════════════════════════════════════
    
    Process {
        id: brightnessGetProcess
        command: ["brightnessctl", "get"]
        
        onFinished: {
            var current = parseInt(stdout.trim())
            if (!isNaN(current) && displayController.maxBrightness > 0) {
                displayController.brightness = Math.round((current / displayController.maxBrightness) * 100)
                brightnessChanged(displayController.brightness)
            }
        }
        
        onError: (msg) => {
            console.warn("[DisplayController] Get brightness error:", msg)
            displayController.error(msg)
        }
    }
    
    Process {
        id: maxBrightnessProcess
        command: ["brightnessctl", "max"]
        
        onFinished: {
            var max = parseInt(stdout.trim())
            if (!isNaN(max)) {
                displayController.maxBrightness = max
            }
        }
    }
    
    Process {
        id: brightnessSetProcess
        onFinished: {
            displayController.refresh()
        }
    }
    
    Process {
        id: nightLightProcess
    }
    
    // ═══════════════════════════════════════════════════════════
    // INITIALIZATION
    // ═══════════════════════════════════════════════════════════
    
    function initialize() {
        console.log("[DisplayController] Initializing...")
        refresh()
        // Check if gammastep is running
        checkNightLightProcess.start()
    }
    
    Process {
        id: checkNightLightProcess
        command: ["pgrep", "gammastep"]
        
        onFinished: {
            displayController.nightLightEnabled = (exitCode === 0)
        }
    }
    
    Component.onCompleted: {
        console.log("[DisplayController] Module loaded")
    }
}
