import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import "../../../theme"

Button {
    id: root
    
    // Custom Properties
    property color color: "transparent"
    property color hoverColor: Theme.tabHover
    property color pressColor: Theme.accent
    property color rippleColor: Qt.rgba(1, 1, 1, 0.2)
    property real radius: 8
    
    // Content
    property alias icon: iconText.text
    property alias label: labelText.text
    
    // Background
    background: Rectangle {
        id: bg
        radius: root.radius
        color: root.down ? Qt.rgba(root.pressColor.r, root.pressColor.g, root.pressColor.b, 0.5) : (root.hovered ? root.hoverColor : root.color)
        
        Behavior on color { ColorAnimation { duration: 150 } }
        
        // Ripple Effect
        Item {
            id: rippleArea
            anchors.fill: parent
            layer.enabled: true
            layer.effect: OpacityMask {
                maskSource: Rectangle {
                    width: rippleArea.width
                    height: rippleArea.height
                    radius: root.radius
                }
            }
            
            MouseArea {
                anchors.fill: parent
                pressed: false // Pass through
                onPressed: (mouse) => {
                    rippleAnim.startX = mouse.x
                    rippleAnim.startY = mouse.y
                    rippleAnim.restart()
                    mouse.accepted = false
                }
            }
            
            Rectangle {
                id: ripple
                width: 0; height: 0
                radius: width / 2
                color: root.rippleColor
                opacity: 0
                
                transform: Translate {
                    x: -ripple.width / 2
                    y: -ripple.height / 2
                }
            }
            
            SequentialAnimation {
                id: rippleAnim
                property real startX
                property real startY
                
                ScriptAction {
                    script: {
                        ripple.x = rippleAnim.startX
                        ripple.y = rippleAnim.startY
                        ripple.width = 0
                        ripple.height = 0
                        ripple.opacity = 0.5
                    }
                }
                
                ParallelAnimation {
                    NumberAnimation {
                        target: ripple
                        properties: "width,height"
                        to: Math.max(root.width, root.height) * 3
                        duration: 400
                        easing.type: Easing.OutQuad
                    }
                    NumberAnimation {
                        target: ripple
                        property: "opacity"
                        to: 0
                        duration: 400
                    }
                }
            }
        }
    }
    
    // Foreground (Icon + Label)
    contentItem: RowLayout {
        anchors.centerIn: parent
        spacing: 8
        
        Text {
            id: iconText
            visible: text !== ""
            color: Theme.textPrimary
            font.pixelSize: 16
        }
        
        Text {
            id: labelText
            visible: text !== ""
            color: Theme.textPrimary
            font.pixelSize: Theme.fontSizeNormal
            font.family: Theme.fontFamily
        }
    }
}
