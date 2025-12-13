import QtQuick
import Quickshell.Io

QtObject {
    id: audioController
    
    // ═══════════════════════════════════════════════════════════
    // SIGNALS
    // ═══════════════════════════════════════════════════════════
    signal volumeChanged(int volume, bool muted)
    signal sinksChanged()
    signal error(string message)
    
    // ═══════════════════════════════════════════════════════════
    // PROPERTIES
    // ═══════════════════════════════════════════════════════════
    property int volume: 0          // 0-100
    property bool muted: false
    property var sinks: []          // List of audio sinks
    property string activeSink: "@DEFAULT_AUDIO_SINK@"
    
    // Polling interval
    property int pollInterval: 2000
    
    // ═══════════════════════════════════════════════════════════
    // PUBLIC FUNCTIONS
    // ═══════════════════════════════════════════════════════════
    
    function setVolume(value) {
        var clamped = Math.max(0, Math.min(100, value))
        volumeSetProcess.command = ["wpctl", "set-volume", activeSink, (clamped / 100).toFixed(2)]
        volumeSetProcess.start()
    }
    
    function increaseVolume(step) {
        setVolume(volume + (step || 5))
    }
    
    function decreaseVolume(step) {
        setVolume(volume - (step || 5))
    }
    
    function toggleMute() {
        muteProcess.command = ["wpctl", "set-mute", activeSink, "toggle"]
        muteProcess.start()
    }
    
    function setMuted(mute) {
        muteProcess.command = ["wpctl", "set-mute", activeSink, mute ? "1" : "0"]
        muteProcess.start()
    }
    
    function refresh() {
        volumeGetProcess.start()
    }
    
    // ═══════════════════════════════════════════════════════════
    // PROCESSES
    // ═══════════════════════════════════════════════════════════
    
    // Get volume
    Process {
        id: volumeGetProcess
        command: ["wpctl", "get-volume", audioController.activeSink]
        
        onFinished: {
            // Output: "Volume: 0.50" or "Volume: 0.50 [MUTED]"
            var output = stdout()
            var match = output.match(/Volume:\s*([\d.]+)/)
            if (match) {
                audioController.volume = Math.round(parseFloat(match[1]) * 100)
                audioController.muted = output.includes("[MUTED]")
                volumeChanged(audioController.volume, audioController.muted)
            }
        }
        
        onError: (msg) => {
            console.warn("[AudioController] Get volume error:", msg)
            audioController.error(msg)
        }
    }
    
    // Set volume
    Process {
        id: volumeSetProcess
        onFinished: {
            audioController.refresh()
        }
        onError: (msg) => {
            console.warn("[AudioController] Set volume error:", msg)
            audioController.error("Failed to set volume: " + msg)
        }
    }
    
    // Toggle/set mute
    Process {
        id: muteProcess
        onFinished: {
            audioController.refresh()
        }
        onError: (msg) => {
            console.warn("[AudioController] Mute error:", msg)
            audioController.error("Failed to set mute: " + msg)
        }
    }
    
    // ═══════════════════════════════════════════════════════════
    // POLLING TIMER
    // ═══════════════════════════════════════════════════════════
    
    Timer {
        id: pollTimer
        interval: audioController.pollInterval
        repeat: true
        running: true
        onTriggered: audioController.refresh()
    }
    
    // ═══════════════════════════════════════════════════════════
    // INITIALIZATION
    // ═══════════════════════════════════════════════════════════
    
    function initialize() {
        console.log("[AudioController] Initializing...")
        refresh()
    }
    
    Component.onCompleted: {
        console.log("[AudioController] Module loaded")
    }
}
