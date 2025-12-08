import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import "../../theme"
import "../../modules/common/widgets" // For RippleButton if available, or just use basic MouseArea

Item {
    id: root
    
    required property var modelData
    required property var backend
    
    // Size passed from GridView
    width: 280
    height: 190
    
    signal clicked()
    
    // Background card
    Rectangle {
        id: card
        anchors.fill: parent
        anchors.margins: 5
        color: Theme.currentTheme.backgroundAlt
        radius: Theme.currentTheme.cornerRadius
        border.width: 1
        border.color: hoverHandler.hovered ? Theme.currentTheme.accent : "transparent"
        
        Behavior on border.color { ColorAnimation { duration: 150 } }
        
        // Image Thumbnail
        Image {
            id: thumbnail
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: nameBg.top
            anchors.margins: 2
            
            source: root.modelData.path
            sourceSize.width: 300 // Downscale for performance
            sourceSize.height: 200
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            cache: true
            
            layer.enabled: true
            layer.effect: OpacityMask {
                maskSource: Rectangle {
                    width: thumbnail.width
                    height: thumbnail.height
                    radius: Theme.currentTheme.cornerRadius - 2
                }
            }
            
            // Loading indicator
            BusyIndicator {
                anchors.centerIn: parent
                running: thumbnail.status === Image.Loading
                visible: running
            }
        }
        
        // Name Label Background
        Rectangle {
            id: nameBg
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: 1
            height: 36
            color: "transparent"
            radius: Theme.currentTheme.cornerRadius
            
            // Bottom rounded corners only logic is complex in pure Rectangle, 
            // so we rely on the container clipping or just use standardized radius.
        }
        
        // Name Label
        Text {
            anchors.fill: nameBg
            anchors.margins: 5
            text: root.modelData.name
            color: Theme.currentTheme.textPrimary
            font.family: Theme.currentTheme.fontFamily
            font.pixelSize: Theme.currentTheme.fontSizeSmall
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
        }
        
        // Hover effect
        HoverHandler {
            id: hoverHandler
        }
        
        // Click interaction
        MouseArea {
            anchors.fill: parent
            onClicked: root.clicked()
            cursorShape: Qt.PointingHandCursor
        }
        
        // Checkmark for current wallpaper (optional, if we could track it)
        /*
        Rectangle {
            anchors.top: parent.top
            anchors.right: parent.right
            width: 24
            height: 24
            radius: 12
            color: Theme.currentTheme.accent
            visible: root.backend.wallpapers.currentWallpaper === root.modelData.path
            
            Text {
                anchors.centerIn: parent
                text: "✓"
                color: Theme.currentTheme.background
            }
        }
        */
    }
}
