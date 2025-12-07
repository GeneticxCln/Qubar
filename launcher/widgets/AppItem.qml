import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../../theme"

Rectangle {
    id: appItem
    
    // Properties
    required property var backend
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
        
        // Icon
        Item {
            Layout.alignment: Qt.AlignHCenter
            width: 48
            height: 48
            
            // Access qubar global (assuming it's available or passed down)
            // Ideally we pass backend.icons to it.
            // For now, let's assume 'launcherPanel' (parent's parent...) has backend access
            // Or use the `qubar` global if exposed.
            // Since we don't have a clean global 'qubar', we rely on `appItem.backend` 
            // which should be passed from Grid -> LauncherPanel -> Backend -> Icons
            
            // Let's add `required property var backend` to AppItem 
            
            Image {
                anchors.fill: parent
                source: backend.icons.getIcon(appData.icon, 48) || ""
                visible: source != ""
                asynchronous: true
                fillMode: Image.PreserveAspectFit
                
                onStatusChanged: if (status == Image.Error) visible = false
            }
            
            // Fallback
            Rectangle {
                anchors.fill: parent
                radius: 8
                color: Theme.accent
                visible: !parent.children[0].visible // Show if image invalid
                
                Text {
                    anchors.centerIn: parent
                    text: appData && appData.name ? appData.name.charAt(0).toUpperCase() : "?"
                    font.pixelSize: 24
                    color: "#000"
                }
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
