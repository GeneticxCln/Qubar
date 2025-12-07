import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../../theme"

Rectangle {
    id: appItem
    
    // Properties
    property var appData // {name, icon, desktopFile, ...}
    property bool selected: false
    
    signal launched()
    
    // Layout
    width: 100
    height: 110
    color: selected || hoverHandler.hovered ? Theme.tabHover : "transparent"
    radius: 8
    
    Behavior on color { ColorAnimation { duration: 100 } }
    
    ColumnLayout {
        anchors.centerIn: parent
        spacing: 8
        
        // Icon (Placeholder using Rectangle + Text if no image loader capable of icon theme)
        // In a real scenario, use Quickshell's image provider or a dedicated Icon component
        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            width: 48
            height: 48
            radius: 8
            color: Theme.accent
            
            Text {
                anchors.centerIn: parent
                text: appData && appData.name ? appData.name.charAt(0).toUpperCase() : "?"
                font.pixelSize: 24
                color: "#000"
            }
        }
        
        // Name
        Text {
            Layout.alignment: Qt.AlignHCenter
            Layout.maximumWidth: parent.parent.width - 16
            text: appData ? appData.name : ""
            color: Theme.textPrimary
            font.pixelSize: Theme.fontSizeSmall
            font.family: Theme.fontFamily
            elide: Text.ElideRight
            horizontalAlignment: Text.AlignHCenter
        }
    }
    
    HoverHandler {
        id: hoverHandler
        cursorShape: Qt.PointingHandCursor
    }
    
    TapHandler {
        onTapped: appItem.launched()
    }
}
