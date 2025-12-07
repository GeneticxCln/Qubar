import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../../theme"

Rectangle {
    id: workspaceTile
    
    // Properties
    required property var backend
    required property int workspaceId
    required property var windows // Array of window objects
    required property bool active
    
    signal clicked()
    
    // Visuals
    color: active ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.2) : "transparent"
    border.width: active || hoverHandler.hovered ? 2 : 1
    border.color: active ? Theme.accent : (hoverHandler.hovered ? Theme.textSecondary : Qt.rgba(1, 1, 1, 0.1))
    radius: 12
    
    Behavior on color { ColorAnimation { duration: 150 } }
    Behavior on border.color { ColorAnimation { duration: 150 } }
    
    // Label (Workspace Number)
    Text {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.margins: 12
        text: workspaceId
        color: Theme.textDim
        font.pixelSize: 24
        font.bold: true
    }
    
    // Window Previews (Simplified as Icons + Titles for now)
    // In a real Hyprland setup with hyprshot/hyprland-pip, you might use an Image source provided by a plugin
    Flow {
        anchors.fill: parent
        anchors.margins: 20
        anchors.topMargin: 40 // Space for label
        spacing: 8
        clip: true
        
        Repeater {
            model: windows
            
            Rectangle {
                width: 120
                height: 80
                color: Qt.rgba(0, 0, 0, 0.3)
                radius: 6
                border.width: 1
                border.color: Qt.rgba(1, 1, 1, 0.1)
                
                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 4
                    
                    // Icon
                    Item {
                        Layout.alignment: Qt.AlignHCenter
                        width: 24
                        height: 24
                        
                        Image {
                            anchors.fill: parent
                            source: backend.icons.getIcon(modelData.class || modelData.appId, 24) || ""
                            visible: source != ""
                            asynchronous: true
                            fillMode: Image.PreserveAspectFit
                        }
                        
                        // Fallback
                        Rectangle {
                            anchors.fill: parent
                            radius: 12
                            color: Theme.accent
                            visible: !parent.children[0].visible
                            
                            Text {
                                anchors.centerIn: parent
                                text: modelData.appId ? modelData.appId.charAt(0).toUpperCase() : "?"
                                font.pixelSize: 12
                            }
                        }
                    }
                    
                    // Title
                    Text {
                        Layout.maximumWidth: 100
                        text: modelData.title
                        color: Theme.textSecondary
                        font.pixelSize: 9
                        elide: Text.ElideRight
                    }
                }
            }
        }
    }
    
    // Empty State
    Text {
        visible: windows.length === 0
        anchors.centerIn: parent
        text: "Empty"
        color: Theme.textDim
        opacity: 0.3
    }
    
    // Interaction
    HoverHandler {
        id: hoverHandler
        cursorShape: Qt.PointingHandCursor
    }
    
    TapHandler {
        onTapped: workspaceTile.clicked()
    }
}
