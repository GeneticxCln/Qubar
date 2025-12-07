import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../../theme"

Rectangle {
    id: quickToggle
    
    // Layout
    implicitWidth: 100
    implicitHeight: 60
    radius: 12
    
    // Properties
    property string label: "WiFi"
    property string icon: "📶"
    property bool active: false
    property string statusText: active ? "On" : "Off"
    
    signal clicked()
    
    // Visuals
    color: active ? Theme.accent : Theme.tabInactive
    
    Behavior on color { ColorAnimation { duration: 150 } }
    
    RowLayout {
        anchors.centerIn: parent
        anchors.margins: 8
        spacing: 8
        
        // Icon
        Text {
            text: quickToggle.icon
            color: quickToggle.active ? "#000" : Theme.textPrimary
            font.pixelSize: 18
        }
        
        // Labels
        ColumnLayout {
            spacing: 2
            
            Text {
                text: quickToggle.label
                color: quickToggle.active ? "#000" : Theme.textPrimary
                font.bold: true
                font.pixelSize: Theme.fontSizeNormal
            }
            
            Text {
                text: quickToggle.statusText
                color: quickToggle.active ? "#222" : Theme.textSecondary
                font.pixelSize: Theme.fontSizeSmall
                elide: Text.ElideRight
                Layout.maximumWidth: 60
            }
        }
    }
    
    // Interactions
    HoverHandler {
        id: hoverHandler
        cursorShape: Qt.PointingHandCursor
    }
    
    TapHandler {
        onTapped: quickToggle.clicked()
    }
    
    // Hover effect overlay
    Rectangle {
        anchors.fill: parent
        radius: parent.radius
        color: "#FFFFFF"
        opacity: hoverHandler.hovered ? 0.1 : 0
        Behavior on opacity { NumberAnimation { duration: 150 } }
    }
}
