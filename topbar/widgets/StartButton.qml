import QtQuick
import QtQuick.Layouts
import "../../theme"

Rectangle {
    id: startButton
    
    Layout.preferredWidth: 36
    Layout.preferredHeight: 36
    Layout.alignment: Qt.AlignVCenter
    
    radius: 8
    color: hoverArea.containsMouse ? (hoverArea.pressed ? Theme.accent : Theme.tabHover) : "transparent"
    
    Behavior on color { ColorAnimation { duration: 100 } }
    
    signal startClicked()
    
    // Icon
    Text {
        anchors.centerIn: parent
        text: "󰀻" // nf-md-apps (Nerd Font)
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 18
        color: hoverArea.containsMouse ? Theme.textPrimary : Theme.textSecondary
        
        Behavior on color { ColorAnimation { duration: 100 } }
    }
    
    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        
        onClicked: {
            console.log("[StartButton] Clicked")
            startButton.startClicked()
        }
    }
    
    ToolTip.visible: hoverArea.containsMouse
    ToolTip.text: "Application Launcher"
    ToolTip.delay: 500
}
