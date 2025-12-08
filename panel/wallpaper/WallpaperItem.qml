import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import "../../theme"

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
        clip: true
        
        Behavior on border.color { ColorAnimation { duration: 150 } }
        
        // Image Thumbnail
        Image {
            id: thumbnail
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: nameBg.top
            anchors.margins: 2
            
            source: "file://" + root.modelData.path
            sourceSize.width: 300 // Downscale for performance
            sourceSize.height: 200
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            cache: true
            
            // Loading indicator
            BusyIndicator {
                anchors.centerIn: parent
                running: thumbnail.status === Image.Loading
                visible: running
            }
            
            // Error state
            Text {
                anchors.centerIn: parent
                text: "⚠️"
                font.pixelSize: 24
                visible: thumbnail.status === Image.Error
            }
        }
        
        // Name Label Background
        Rectangle {
            id: nameBg
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 36
            color: Qt.rgba(0, 0, 0, 0.5)
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
    }
}
