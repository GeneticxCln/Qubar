import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../../theme"

Rectangle {
    id: searchBar
    
    implicitHeight: 40
    color: Qt.rgba(0, 0, 0, 0.2)
    radius: 8
    border.width: 1
    border.color: hasFocus ? Theme.accent : Qt.rgba(1, 1, 1, 0.1)
    
    property alias text: input.text
    property bool hasFocus: input.activeFocus
    
    signal textChanged(string text)
    
    RowLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 8
        
        Text {
            text: "🔍"
            font.pixelSize: 14
        }
        
        TextInput {
            id: input
            Layout.fillWidth: true
            color: Theme.textPrimary
            font.pixelSize: Theme.fontSizeNormal
            font.family: Theme.fontFamily
            selectByMouse: true
            
            Text {
                text: "Search apps..."
                color: Theme.textDim
                visible: !input.text && !input.activeFocus
                anchors.fill: parent
            }
            
            onTextChanged: searchBar.textChanged(text)
        }
        
        // Clear button
        Text {
            visible: input.text.length > 0
            text: "✖"
            color: Theme.textDim
            font.pixelSize: 12
            
            TapHandler {
                onTapped: input.text = ""
            }
        }
    }
}
