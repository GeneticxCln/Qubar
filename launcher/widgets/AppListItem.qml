import QtQuick
import QtQuick.Layouts
import "../../theme"

Rectangle {
    id: appListItem
    
    // Properties
    required property var backend
    required property int index
    property var appData
    property bool isSelected: false
    
    signal clicked()
    signal launched()
    signal favoriteToggled()
    
    // Layout
    height: 38
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
                id: appIcon
                anchors.fill: parent
                source: backend && backend.icons ? backend.icons.getIcon(appData.icon, 24) : ""
                visible: status === Image.Ready && source != ""
                asynchronous: true
                fillMode: Image.PreserveAspectFit
            }
            
            // Fallback icon
            Rectangle {
                anchors.fill: parent
                radius: 4
                color: isSelected ? Qt.rgba(0, 0, 0, 0.3) : Theme.accent
                visible: appIcon.status !== Image.Ready || appIcon.source == ""
                
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
        
        // Favorite star
        Text {
            text: backend && backend.launcher && backend.launcher.isFavorite(appData) ? "★" : "☆"
            color: isSelected ? "#ffffff" : (backend && backend.launcher && backend.launcher.isFavorite(appData) ? "#ffd700" : Theme.textDim)
            font.pixelSize: 14
            visible: hoverArea.containsMouse || isSelected
            opacity: starHover.containsMouse ? 1.0 : 0.6
            
            MouseArea {
                id: starHover
                anchors.fill: parent
                anchors.margins: -4
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                
                onClicked: (mouse) => {
                    mouse.accepted = true
                    if (backend && backend.launcher) {
                        backend.launcher.toggleFavorite(appData)
                    }
                    appListItem.favoriteToggled()
                }
            }
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
        acceptedButtons: Qt.LeftButton
        
        onClicked: {
            if (isSelected) {
                // Already selected, launch it
                appListItem.launched()
            } else {
                // Select it
                appListItem.clicked()
            }
        }
    }
}
