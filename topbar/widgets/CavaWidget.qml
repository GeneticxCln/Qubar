import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../../theme"

Item {
    id: cavaWidget
    
    // Dependencies
    required property var backend
    
    // Layout
    implicitWidth: barsRow.implicitWidth + 16
    implicitHeight: Theme.barHeight - 10
    
    // Only visible when music is playing
    visible: backend.media && backend.media.hasActivePlayer && backend.media.playing
    
    // Cava output data (12 bars)
    property var bars: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    property int barCount: 12
    property real maxBarHeight: 24
    
    // Background
    Rectangle {
        anchors.fill: parent
        radius: 6
        color: Theme.tabInactive
        opacity: 0.5
    }
    
    // Bars
    Row {
        id: barsRow
        anchors.centerIn: parent
        spacing: 2
        
        Repeater {
            model: cavaWidget.barCount
            
            Rectangle {
                width: 3
                height: Math.max(3, (cavaWidget.bars[index] || 0) * cavaWidget.maxBarHeight)
                radius: 1.5
                anchors.bottom: parent.bottom
                
                // Gradient color based on height
                color: {
                    var intensity = height / cavaWidget.maxBarHeight
                    if (intensity > 0.8) return Theme.accent
                    if (intensity > 0.6) return Qt.lighter(Theme.accent, 1.2)
                    if (intensity > 0.3) return Theme.textSecondary
                    return Theme.textDim
                }
                
                Behavior on height {
                    NumberAnimation { duration: 50 }
                }
                
                Behavior on color {
                    ColorAnimation { duration: 100 }
                }
            }
        }
    }
    
    // Cava process
    Process {
        id: cavaProcess
        running: cavaWidget.visible
        command: ["cava", "-p", cavaConfigPath]
        
        property string cavaConfigPath: Quickshell.env("HOME") + "/.config/cava/config_bar"
        
        onStdoutChanged: {
            parseCavaOutput(stdout())
        }
    }
    
    // Alternative: Read from FIFO if cava outputs to file
    Timer {
        interval: 50
        running: cavaWidget.visible && !cavaProcess.running
        repeat: true
        
        onTriggered: {
            // Fallback: Simulate bars based on music playing
            simulateBars()
        }
    }
    
    function parseCavaOutput(output) {
        // Cava raw output format: semicolon-separated values
        var values = output.trim().split(";")
        var newBars = []
        for (var i = 0; i < barCount; i++) {
            var val = parseInt(values[i]) || 0
            newBars.push(Math.min(1.0, val / 65535)) // Normalize to 0-1
        }
        bars = newBars
    }
    
    function simulateBars() {
        // Simulate audio bars when cava isn't available
        var newBars = []
        for (var i = 0; i < barCount; i++) {
            // Create wave-like pattern
            var base = Math.sin(Date.now() / 200 + i * 0.5) * 0.3 + 0.4
            var random = Math.random() * 0.3
            newBars.push(Math.min(1.0, Math.max(0.1, base + random)))
        }
        bars = newBars
    }
    
    // Tooltip
    Rectangle {
        anchors.fill: parent
        color: "transparent"
        
        MouseArea {
            id: hoverArea
            anchors.fill: parent
            hoverEnabled: true
        }
        
        ToolTip.visible: hoverArea.containsMouse
        ToolTip.text: "Audio Visualizer"
        ToolTip.delay: 500
    }
}
