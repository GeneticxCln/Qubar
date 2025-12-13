import QtQuick
import Quickshell.Io

QtObject {
    id: mediaController
    
    // ═══════════════════════════════════════════════════════════
    // SIGNALS
    // ═══════════════════════════════════════════════════════════
    signal trackChanged()
    signal statusChanged()
    signal error(string message)
    
    // ═══════════════════════════════════════════════════════════
    // PROPERTIES
    // ═══════════════════════════════════════════════════════════
    property string playerName: ""
    property string title: ""
    property string artist: ""
    property string album: ""
    property string albumArt: ""
    property string status: "stopped" // playing, paused, stopped
    property int position: 0 // seconds
    property int length: 0 // seconds
    property bool hasPlayer: playerName !== ""
    
    // ═══════════════════════════════════════════════════════════
    // PUBLIC FUNCTIONS
    // ═══════════════════════════════════════════════════════════
    
    function playPause() {
        runCommand("playerctl play-pause")
    }
    
    function play() {
        runCommand("playerctl play")
    }
    
    function pause() {
        runCommand("playerctl pause")
    }
    
    function stop() {
        runCommand("playerctl stop")
    }
    
    function next() {
        runCommand("playerctl next")
    }
    
    function previous() {
        runCommand("playerctl previous")
    }
    
    function seek(seconds) {
        runCommand("playerctl position " + seconds)
    }
    
    function seekForward(seconds) {
        runCommand("playerctl position " + seconds + "+")
    }
    
    function seekBackward(seconds) {
        runCommand("playerctl position " + seconds + "-")
    }
    
    function setVolume(percent) {
        runCommand("playerctl volume " + (percent / 100))
    }
    
    function refresh() {
        statusProcess.start()
        metadataProcess.start()
    }
    
    // ═══════════════════════════════════════════════════════════
    // INTERNAL HELPERS
    // ═══════════════════════════════════════════════════════════
    
    function runCommand(cmd) {
        var proc = Qt.createQmlObject('\
            import Quickshell.Io\n\
            Process { running: false }\n\
        ', mediaController)
        
        proc.command = ["sh", "-c", cmd]
        
        proc.error.connect(function(msg) {
            console.warn("[MediaController] Command error:", msg)
            proc.destroy()
        })
        
        proc.exited.connect(function(code, status) {
            refresh()
            proc.destroy()
        })
        
        proc.running = true
    }
    
    // ═══════════════════════════════════════════════════════════
    // PROCESSES
    // ═══════════════════════════════════════════════════════════
    
    // Get player status
    Process {
        id: statusProcess
        command: ["playerctl", "status"]
        
        onFinished: {
            var out = stdout().trim().toLowerCase()
            if (out === "playing" || out === "paused" || out === "stopped") {
                mediaController.status = out
            } else {
                mediaController.status = "stopped"
            }
            statusChanged()
        }
    }
    
    // Get metadata
    Process {
        id: metadataProcess
        command: ["playerctl", "metadata", "--format", 
                  "{{playerName}}|||{{title}}|||{{artist}}|||{{album}}|||{{mpris:artUrl}}|||{{position}}|||{{mpris:length}}"]
        
        onFinished: {
            var parts = stdout().trim().split("|||")
            if (parts.length >= 5) {
                mediaController.playerName = parts[0] || ""
                mediaController.title = parts[1] || ""
                mediaController.artist = parts[2] || ""
                mediaController.album = parts[3] || ""
                
                // Handle art URL (file:// or http://)
                var artUrl = parts[4] || ""
                if (artUrl.startsWith("file://")) {
                    mediaController.albumArt = artUrl.replace("file://", "")
                } else {
                    mediaController.albumArt = artUrl
                }
                
                // Position and length (microseconds to seconds)
                mediaController.position = parseInt(parts[5] || 0) / 1000000
                mediaController.length = parseInt(parts[6] || 0) / 1000000
                
                trackChanged()
            } else {
                // No player
                mediaController.playerName = ""
                mediaController.title = ""
                mediaController.artist = ""
                mediaController.album = ""
                mediaController.albumArt = ""
                mediaController.position = 0
                mediaController.length = 0
            }
        }
    }
    
    // ═══════════════════════════════════════════════════════════
    // POLLING
    // ═══════════════════════════════════════════════════════════
    
    Timer {
        id: pollTimer
        interval: 1000
        repeat: true
        running: true
        onTriggered: mediaController.refresh()
    }
    
    // ═══════════════════════════════════════════════════════════
    // INITIALIZATION
    // ═══════════════════════════════════════════════════════════
    
    function initialize() {
        console.log("[MediaController] Initializing...")
        refresh()
    }
    
    Component.onCompleted: {
        console.log("[MediaController] Module loaded")
        refresh()
    }
}
