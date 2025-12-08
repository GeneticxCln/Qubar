import QtQuick
import QtQuick.Layouts
import "../../theme"

Item {
    id: root
    width: parent.width
    height: 60
    
    signal openWallpaperPicker()
    
    Rectangle {
        anchors.fill: parent
        color: Theme.currentTheme.backgroundAlt
        radius: Theme.currentTheme.cornerRadius
        
        RowLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 15
            
            Rectangle {
                width: 40
                height: 40
                radius: 20
                color: Theme.currentTheme.background
                border.width: 1
                border.color: Theme.currentTheme.accent
                
                Text {
                    anchors.centerIn: parent
                    text: "🎨"
                    font.pixelSize: 18
                }
            }
            
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                
                Text {
                    text: "Wallpaper"
                    color: Theme.currentTheme.textPrimary
                    font.family: Theme.currentTheme.fontFamily
                    font.bold: true
                }
                
                Text {
                    text: "Click to change"
                    color: Theme.currentTheme.textSecondary
                    font.pixelSize: Theme.currentTheme.fontSizeSmall
                }
            }
        }
        
        MouseArea {
            anchors.fill: parent
            onClicked: root.openWallpaperPicker()
            cursorShape: Qt.PointingHandCursor
        }
    }
}
