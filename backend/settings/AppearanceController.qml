import QtQuick
import Quickshell.Io

QtObject {
    id: appearanceController
    
    // ═══════════════════════════════════════════════════════════
    // SIGNALS
    // ═══════════════════════════════════════════════════════════
    signal settingsChanged()
    signal error(string message)
    
    // ═══════════════════════════════════════════════════════════
    // PROPERTIES
    // ═══════════════════════════════════════════════════════════
    
    // Blur settings
    property bool blurEnabled: true
    property int blurSize: 8
    property int blurPasses: 3
    
    // Opacity settings
    property real activeOpacity: 1.0
    property real inactiveOpacity: 0.95
    
    // Animation settings
    property bool animationsEnabled: true
    property string animationSpeed: "normal" // "fast", "normal", "slow"
    
    // Border settings
    property string borderStyle: "rainbow" // "rainbow", "accent", "solid"
    property string borderColor: "81a1c1"
    
    // Shadow settings
    property bool shadowsEnabled: true
    property int shadowRange: 20
    
    // Corner rounding
    property int cornerRounding: 10
    
    // Gaps
    property int gapsIn: 5
    property int gapsOut: 10
    
    // Script path
    readonly property string scriptPath: Quickshell.env("HOME") + "/Qubar/scripts/appearance.sh"
    
    // ═══════════════════════════════════════════════════════════
    // FUNCTIONS
    // ═══════════════════════════════════════════════════════════
    
    function setBlur(enabled) {
        blurEnabled = enabled
        runCommand(enabled ? "blur-enable" : "blur-disable")
    }
    
    function setBlurSize(size) {
        blurSize = size
        runCommand("blur-size", size)
    }
    
    function setBlurPasses(passes) {
        blurPasses = passes
        runCommand("blur-passes", passes)
    }
    
    function setActiveOpacity(opacity) {
        activeOpacity = opacity
        runCommand("active-opacity", opacity.toFixed(2))
    }
    
    function setInactiveOpacity(opacity) {
        inactiveOpacity = opacity
        runCommand("inactive-opacity", opacity.toFixed(2))
    }
    
    function setAnimations(enabled) {
        animationsEnabled = enabled
        runCommand(enabled ? "animations-enable" : "animations-disable")
    }
    
    function setAnimationSpeed(speed) {
        animationSpeed = speed
        runCommand("animation-speed", speed)
    }
    
    function setBorderStyle(style) {
        borderStyle = style
        switch(style) {
            case "rainbow":
                runCommand("border-rainbow")
                break
            case "accent":
                runCommand("border-accent")
                break
            case "solid":
                runCommand("border-solid", borderColor)
                break
        }
    }
    
    function setShadows(enabled) {
        shadowsEnabled = enabled
        runCommand(enabled ? "shadow-enable" : "shadow-disable")
    }
    
    function setShadowRange(range) {
        shadowRange = range
        runCommand("shadow-range", range)
    }
    
    function setCornerRounding(radius) {
        cornerRounding = radius
        runCommand("rounding", radius)
    }
    
    function setGapsIn(gaps) {
        gapsIn = gaps
        runCommand("gaps-in", gaps)
    }
    
    function setGapsOut(gaps) {
        gapsOut = gaps
        runCommand("gaps-out", gaps)
    }
    
    function refresh() {
        console.log("[AppearanceController] Refreshing settings...")
        refreshProcess.running = true
    }
    
    function runCommand(cmd, arg) {
        if (arg !== undefined) {
            commandProcess.command = [scriptPath, cmd, String(arg)]
        } else {
            commandProcess.command = [scriptPath, cmd]
        }
        commandProcess.running = true
    }
    
    // ═══════════════════════════════════════════════════════════
    // PROCESSES
    // ═══════════════════════════════════════════════════════════
    
    Process {
        id: commandProcess
        running: false
        
        onExited: (code, status) => {
            if (code !== 0) {
                console.warn("[AppearanceController] Command failed:", commandProcess.stderr())
                appearanceController.error("Failed to apply setting")
            } else {
                console.log("[AppearanceController] Setting applied")
                appearanceController.settingsChanged()
            }
        }
    }
    
    Process {
        id: refreshProcess
        command: [appearanceController.scriptPath, "get-all"]
        running: false
        
        onExited: (code, status) => {
            if (code === 0) {
                try {
                    var data = JSON.parse(refreshProcess.stdout())
                    appearanceController.blurEnabled = data.blur
                    appearanceController.blurSize = data.blurSize
                    appearanceController.blurPasses = data.blurPasses
                    appearanceController.animationsEnabled = data.animations
                    appearanceController.activeOpacity = data.activeOpacity
                    appearanceController.inactiveOpacity = data.inactiveOpacity
                    appearanceController.shadowsEnabled = data.shadows
                    appearanceController.cornerRounding = data.rounding
                    appearanceController.gapsIn = data.gapsIn
                    appearanceController.gapsOut = data.gapsOut
                    console.log("[AppearanceController] Settings refreshed")
                } catch (e) {
                    console.warn("[AppearanceController] Failed to parse settings:", e)
                }
            }
        }
    }
    
    // ═══════════════════════════════════════════════════════════
    // INITIALIZATION
    // ═══════════════════════════════════════════════════════════
    
    Component.onCompleted: {
        console.log("[AppearanceController] Module loaded")
        refresh()
    }
}
