import QtQuick
import Quickshell.Io

QtObject {
    id: screenshotProvider
    
    // ═══════════════════════════════════════════════════════════
    // SIGNALS
    // ═══════════════════════════════════════════════════════════
    signal screenshotCaptured(string path)
    signal error(string message)
    
    // ═══════════════════════════════════════════════════════════
    // PROPERTIES
    // ═══════════════════════════════════════════════════════════
    property string outputDir: "/tmp/qubar-screenshots"
    property var windowScreenshots: ({}) // {address: path}
    property var workspaceScreenshots: ({}) // {id: path}
    property bool capturing: false
    
    // ═══════════════════════════════════════════════════════════
    // PUBLIC FUNCTIONS
    // ═══════════════════════════════════════════════════════════
    
    function captureWindow(address, callback) {
        if (capturing) return
        capturing = true
        
        var filename = outputDir + "/window_" + address.replace("0x", "") + ".png"
        
        // Use hyprshot for Hyprland
        var proc = Qt.createQmlObject(`
            import Quickshell.Io
            Process {
                command: ["sh", "-c", "mkdir -p ${outputDir} && hyprctl dispatch focuswindow address:${address} && sleep 0.1 && hyprshot -m window -o ${outputDir} -f window_${address.replace('0x', '')}.png --silent"]
            }
        `, screenshotProvider)
        
        proc.finished.connect(function() {
            capturing = false
            if (proc.exitCode === 0) {
                windowScreenshots[address] = filename
                screenshotCaptured(filename)
                if (callback) callback(filename)
            } else {
                // Fallback to grim
                captureWindowWithGrim(address, callback)
            }
            proc.destroy()
        })
        
        proc.start()
    }
    
    function captureWindowWithGrim(address, callback) {
        capturing = true
        
        var filename = outputDir + "/window_" + address.replace("0x", "") + ".png"
        
        var proc = Qt.createQmlObject(`
            import Quickshell.Io
            Process {
                command: ["sh", "-c", "mkdir -p ${outputDir} && hyprctl clients -j | jq -r '.[] | select(.address==\"${address}\") | \"\\(.at[0]),\\(.at[1]) \\(.size[0])x\\(.size[1])\"' | xargs -I {} grim -g '{}' ${filename}"]
            }
        `, screenshotProvider)
        
        proc.finished.connect(function() {
            capturing = false
            if (proc.exitCode === 0) {
                windowScreenshots[address] = filename
                screenshotCaptured(filename)
                if (callback) callback(filename)
            } else {
                error("Failed to capture window")
                if (callback) callback("")
            }
            proc.destroy()
        })
        
        proc.start()
    }
    
    function captureWorkspace(workspaceId, callback) {
        if (capturing) return
        capturing = true
        
        var filename = outputDir + "/workspace_" + workspaceId + ".png"
        
        var proc = Qt.createQmlObject(`
            import Quickshell.Io
            Process {
                command: ["sh", "-c", "mkdir -p ${outputDir} && hyprctl dispatch workspace ${workspaceId} && sleep 0.2 && grim ${filename}"]
            }
        `, screenshotProvider)
        
        proc.finished.connect(function() {
            capturing = false
            if (proc.exitCode === 0) {
                workspaceScreenshots[workspaceId] = filename
                screenshotCaptured(filename)
                if (callback) callback(filename)
            } else {
                error("Failed to capture workspace")
                if (callback) callback("")
            }
            proc.destroy()
        })
        
        proc.start()
    }
    
    function captureScreen(callback) {
        if (capturing) return
        capturing = true
        
        var timestamp = Date.now()
        var filename = outputDir + "/screen_" + timestamp + ".png"
        
        var proc = Qt.createQmlObject(`
            import Quickshell.Io
            Process {
                command: ["sh", "-c", "mkdir -p ${outputDir} && grim ${filename}"]
            }
        `, screenshotProvider)
        
        proc.finished.connect(function() {
            capturing = false
            if (proc.exitCode === 0) {
                screenshotCaptured(filename)
                if (callback) callback(filename)
            } else {
                error("Failed to capture screen")
                if (callback) callback("")
            }
            proc.destroy()
        })
        
        proc.start()
    }
    
    function getWindowScreenshot(address) {
        return windowScreenshots[address] || ""
    }
    
    function getWorkspaceScreenshot(workspaceId) {
        return workspaceScreenshots[workspaceId] || ""
    }
    
    function clearCache() {
        windowScreenshots = {}
        workspaceScreenshots = {}
        
        var proc = Qt.createQmlObject(`
            import Quickshell.Io
            Process {
                command: ["rm", "-rf", "${outputDir}"]
            }
        `, screenshotProvider)
        proc.finished.connect(function() { proc.destroy() })
        proc.start()
    }
    
    // ═══════════════════════════════════════════════════════════
    // INITIALIZATION
    // ═══════════════════════════════════════════════════════════
    
    function initialize() {
        console.log("[ScreenshotProvider] Initializing...")
        // Ensure output directory exists
        var proc = Qt.createQmlObject(`
            import Quickshell.Io
            Process { command: ["mkdir", "-p", "${outputDir}"] }
        `, screenshotProvider)
        proc.finished.connect(function() { proc.destroy() })
        proc.start()
    }
    
    Component.onCompleted: {
        console.log("[ScreenshotProvider] Module loaded")
    }
}
