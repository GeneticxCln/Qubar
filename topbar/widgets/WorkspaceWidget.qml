import QtQuick
import QtQuick.Layouts
import "../../theme"

RowLayout {
    id: workspaceWidget
    spacing: 4
    
    // Dependencies
    required property var backend
    
    Repeater {
        model: backend.workspaces
        
        Rectangle {
            id: wsButton
            
            Layout.preferredWidth: 28
            Layout.preferredHeight: 28
            Layout.alignment: Qt.AlignVCenter
            
            radius: 6
            
            color: {
                if (modelData.active) return Theme.workspaceActive
                if (hoverHandler.containsMouse) return Theme.tabHover
                return "transparent"
            }
            
            border.width: modelData.active ? 0 : (modelData.occupied ? 1 : 0)
            border.color: Theme.textDim
            
            Behavior on color { ColorAnimation { duration: 100 } }
            Behavior on border.color { ColorAnimation { duration: 100 } }
            
            // Number
            Text {
                anchors.centerIn: parent
                text: modelData.id
                color: {
                    if (modelData.active) return Theme.background
                    if (modelData.occupied) return Theme.textPrimary
                    return Theme.textDim
                }
                font.bold: modelData.active
                font.pixelSize: 12
                font.family: Theme.fontFamily
            }
            
            // Active indicator (bottom line)
            Rectangle {
                visible: modelData.active
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottomMargin: 2
                width: parent.width * 0.6
                height: 2
                radius: 1
                color: Theme.background
                opacity: 0.5
            }
            
            MouseArea {
                id: hoverHandler
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                
                onClicked: backend.switchWorkspace(modelData.id)
            }
            
            ToolTip.visible: hoverHandler.containsMouse
            ToolTip.text: "Workspace " + modelData.id + (modelData.occupied ? " (" + modelData.windowCount + " windows)" : " (empty)")
            ToolTip.delay: 500
        }
    }
}
