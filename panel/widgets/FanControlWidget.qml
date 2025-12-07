import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../../theme"
import "."

ColumnLayout {
    id: fanControl
    
    required property var backend
    property var controller: backend.fans
    
    spacing: 8
    
    // Header
    RowLayout {
        Layout.fillWidth: true
        
        Text {
            text: "Fan Control"
            font.bold: true
            color: Theme.textPrimary
            font.pixelSize: Theme.fontSizeSmall
        }
        
        Item { Layout.fillWidth: true }
        
        Text {
            text: controller.hardwareDetected ? "CPU: " + controller.cpuTemp + "°C" : "No HW"
            color: controller.cpuTemp > 75 ? Theme.red : Theme.textSecondary
            font.pixelSize: Theme.fontSizeSmall
        }
    }
    
    // Presets
    RowLayout {
        Layout.fillWidth: true
        spacing: 8
        visible: controller.hardwareDetected
        
        Repeater {
            model: ["Silent", "Quiet", "Performance", "Auto"]
            
            Rectangle {
                Layout.fillWidth: true
                height: 30
                radius: 4
                color: hoverHandler.hovered ? Theme.tabHover : Qt.rgba(1, 1, 1, 0.1)
                
                Text {
                    anchors.centerIn: parent
                    text: modelData
                    color: Theme.textPrimary
                    font.pixelSize: 11
                }
                
                HoverHandler { id: hoverHandler; cursorShape: Qt.PointingHandCursor }
                TapHandler {
                    onTapped: {
                        if (modelData === "Auto") controller.setAllAuto()
                        else controller.applyPreset(modelData.toLowerCase())
                    }
                }
            }
        }
    }
    
    // Fan Channels
    ColumnLayout {
        Layout.fillWidth: true
        spacing: 4
        visible: controller.hardwareDetected
        
        Repeater {
            model: controller.fans
            
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                
                // Info Row
                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: "Fan " + modelData.channel
                        color: Theme.textSecondary
                        font.pixelSize: 11
                    }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: modelData.rpm + " RPM"
                        color: Theme.textDim
                        font.pixelSize: 10
                    }
                    Text {
                        text: "(" + modelData.mode + ")"
                        color: modelData.mode === "auto" ? Theme.accent : Theme.textDim
                        font.pixelSize: 10
                    }
                }
                
                // Slider
                SliderControl {
                    Layout.fillWidth: true
                    value: modelData.speed
                    from: 0
                    to: 100
                    icon: "❄️"
                    label: "" // Hiding label as we have custom header
                    
                    onMoved: (val) => controller.setFanSpeed(modelData.channel, val)
                }
            }
        }
    }
    
    // No Hardware Message
    Text {
        visible: !controller.hardwareDetected
        text: "NCT67xx chip not detected.\nPlease allow sudo access to hwmon."
        color: Theme.red
        font.pixelSize: 11
        wrapMode: Text.WordWrap
        Layout.fillWidth: true
        horizontalAlignment: Text.AlignHCenter
    }
}
