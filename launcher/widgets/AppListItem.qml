import QtQuick
import QtQuick.Layouts
import "../../theme"

Rectangle {
    id: appListItem
    
    // Properties
    required property var backend
    property var appData
    property bool isSelected: false
    
    signal clicked()
    signal launched()
    
    // Layout
    height: 36
    color: isSelected ? Theme.accent : (hoverArea.containsMouse ? Qt.rgba(1, 1, 1, 0.08) : "transparent")
    radius: 6
    
    Behavior on color { ColorAnimation { duration: 80 } }
    
    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        spacing: 10
        
        // Icon
        Item {
            Layout.preferredWidth: 24
            Layout.preferredHeight: 24
            
            Image {
                anchors.fill: parent
                source: backend.icons.getIcon(appData.icon, 24) || ""
                visible: source != ""
                asynchronous: true
                fillMode: Image.PreserveAspectFit
                
                onStatusChanged: if (status == Image.Error) visible = false
            }
            
            // Fallback icon
            Rectangle {
                anchors.fill: parent
                radius: 4
                color: isSelected ? Qt.rgba(0, 0, 0, 0.3) : Theme.accent
                visible: !parent.children[0].visible
                
                Text {
                    anchors.centerIn: parent
                    text: appData && appData.name ? appData.name.charAt(0).toUpperCase() : "?"
                    font.pixelSize: 12
                    font.bold: true
                    color: isSelected ? "#ffffff" : "#000000"
                }
            }
        }
        
        // App name
        Text {
            Layout.fillWidth: true
            text: appData ? appData.name : ""
            color: isSelected ? "#ffffff" : Theme.textPrimary
            font.pixelSize: 13
            font.family: Theme.fontFamily
            elide: Text.ElideRight
        }
        
        // Arrow indicator for selected
        Text {
            visible: isSelected
            text: "▶"
            color: "#ffffff"
            font.pixelSize: 10
            opacity: 0.7
        }
    }
    
    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        
        onClicked: appListItem.clicked()
        onDoubleClicked: appListItem.launched()
    }
    
    // Single click also launches (like rofi)
    Timer {
        id: launchTimer
        interval: 200
        onTriggered: {
            if (isSelected) {
                appListItem.launched()
            }
        }
    }
    
    // Launch on click if already selected
    Connections {
        target: hoverArea
        function onClicked() {
            if (isSelected) {
                appListItem.launched()
            } else {
                appListItem.clicked()
            }
        }
    }
}
