import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../../theme"

RowLayout {
    spacing: 12
    Layout.alignment: Qt.AlignHCenter
    
    signal action(string type)
    
    component PowerButton: Rectangle {
        property string icon: ""
        property color btnColor: Theme.tabInactive
        property string actionName: ""
        
        implicitWidth: 40
        implicitHeight: 40
        radius: 20
        color: hoverHandler.hovered ? Qt.pixelAligned(Qt.lighter(btnColor, 1.2)) : btnColor
        
        Behavior on color { ColorAnimation { duration: 150 } }
        
        Text {
            anchors.centerIn: parent
            text: icon
            font.pixelSize: 16
        }
        
        HoverHandler { id: hoverHandler; cursorShape: Qt.PointingHandCursor }
        TapHandler { onTapped: action(actionName) }
    }
    
    PowerButton { icon: "🔒"; actionName: "lock"; btnColor: Theme.tabInactive }
    PowerButton { icon: "💤"; actionName: "suspend"; btnColor: Theme.tabInactive }
    PowerButton { icon: "🚪"; actionName: "logout"; btnColor: Theme.urgent }
    PowerButton { icon: "⏻"; actionName: "shutdown"; btnColor: Theme.urgent }
}
