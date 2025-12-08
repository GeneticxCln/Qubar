import QtQuick
import QtQuick.Layouts
import "../../theme"

RowLayout {
    id: resourceWidget
    spacing: 16
    
    // Dependencies
    required property var backend
    property var sysInfo: backend.systemInfo
    
    // ═══════════════════════════════════════════════════════════
    // CPU
    // ═══════════════════════════════════════════════════════════
    RowLayout {
        spacing: 4
        
        // CPU Icon
        Text {
            text: "󰍛" // nf-md-chip
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 14
            color: getCpuColor(sysInfo ? sysInfo.cpuPercent : 0)
        }
        
        // CPU percentage
        Text {
            text: (sysInfo ? sysInfo.cpuPercent : 0) + "%"
            color: getCpuColor(sysInfo ? sysInfo.cpuPercent : 0)
            font.pixelSize: Theme.fontSizeSmall
            font.family: Theme.fontFamily
            font.bold: true
        }
    }
    
    // ═══════════════════════════════════════════════════════════
    // RAM
    // ═══════════════════════════════════════════════════════════
    RowLayout {
        spacing: 4
        
        // RAM Icon
        Text {
            text: "󰘚" // nf-md-memory
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 14
            color: getRamColor(sysInfo ? sysInfo.memoryPercent : 0)
        }
        
        // RAM percentage
        Text {
            text: (sysInfo ? sysInfo.memoryPercent : 0) + "%"
            color: getRamColor(sysInfo ? sysInfo.memoryPercent : 0)
            font.pixelSize: Theme.fontSizeSmall
            font.family: Theme.fontFamily
        }
    }
    
    // ═══════════════════════════════════════════════════════════
    // TEMPERATURE (if available)
    // ═══════════════════════════════════════════════════════════
    RowLayout {
        visible: sysInfo && sysInfo.cpuTemp > 0
        spacing: 4
        
        // Temp Icon
        Text {
            text: "󰔏" // nf-md-thermometer
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 14
            color: getTempColor(sysInfo ? sysInfo.cpuTemp : 0)
        }
        
        // Temperature
        Text {
            text: (sysInfo ? sysInfo.cpuTemp : 0) + "°C"
            color: getTempColor(sysInfo ? sysInfo.cpuTemp : 0)
            font.pixelSize: Theme.fontSizeSmall
            font.family: Theme.fontFamily
        }
    }
    
    // ═══════════════════════════════════════════════════════════
    // COLOR FUNCTIONS
    // ═══════════════════════════════════════════════════════════
    
    function getCpuColor(percent) {
        if (percent >= 90) return Theme.urgent
        if (percent >= 70) return Theme.warning
        return Theme.textSecondary
    }
    
    function getRamColor(percent) {
        if (percent >= 90) return Theme.urgent
        if (percent >= 80) return Theme.warning
        return Theme.textSecondary
    }
    
    function getTempColor(temp) {
        if (temp >= 85) return Theme.urgent
        if (temp >= 70) return Theme.warning
        return Theme.textSecondary
    }
}
