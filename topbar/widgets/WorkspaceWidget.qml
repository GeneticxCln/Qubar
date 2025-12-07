import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../../theme"

RowLayout {
    id: workspaceWidget
    spacing: 4
    
    // Dependencies
    required property var backend
    
    Repeater {
        model: backend.workspaces // List of WorkspaceModel objects
        
        Rectangle {
            id: wsButton
            
            // Layout properties
            Layout.preferredWidth: 32
            Layout.preferredHeight: 32
            Layout.alignment: Qt.AlignVCenter
            
            // Visual properties
            radius: 8
            color: {
                if (modelData.active) return Theme.workspaceActive
                if (hoverHandler.hovered) return Theme.tabHover
                return "transparent"
            }
            
            // Animation for color change
            Behavior on color { ColorAnimation { duration: 150 } }
            
            // Content (ID or Icon)
            Text {
                anchors.centerIn: parent
                text: modelData.id
                color: {
                    if (modelData.active) return Theme.textPrimary
                    if (modelData.occupied) return Theme.textSecondary
                    return Theme.textDim
                }
                font.bold: modelData.active
                font.pixelSize: Theme.fontSizeNormal
                font.family: Theme.fontFamily
            }
            
            // Occupancy dot (for inactive but occupied workspaces)
            Rectangle {
                visible: modelData.occupied && !modelData.active
                width: 4; height: 4; radius: 2
                color: Theme.textSecondary
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottomMargin: 4
            }
            
            // Interaction
            HoverHandler {
                id: hoverHandler
                cursorShape: Qt.PointingHandCursor
            }
            
            TapHandler {
                onTapped: {
                    backend.switchWorkspace(modelData.id)
                }
            }
        }
    }
}
