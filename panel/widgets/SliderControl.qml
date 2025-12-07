import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../../theme"

RowLayout {
    id: sliderControl
    spacing: 12
    
    // Properties
    property string label: "Volume"
    property string icon: "🔊"
    property int value: 0
    property int from: 0
    property int to: 100
    
    signal moved(int value)
    
    // Icon
    Rectangle {
        implicitWidth: 32
        implicitHeight: 32
        radius: 16
        color: Theme.tabInactive
        
        Text {
            anchors.centerIn: parent
            text: sliderControl.icon
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.textPrimary
        }
    }
    
    // Slider
    Slider {
        id: control
        Layout.fillWidth: true
        from: sliderControl.from
        to: sliderControl.to
        value: sliderControl.value
        
        // Custom styling would go here (omitted for brevity, using Basic style)
        
        onMoved: {
            sliderControl.moved(Math.round(value))
        }
    }
    
    // Percentage Label
    Text {
        text: Math.round(control.value) + "%"
        color: Theme.textPrimary
        font.pixelSize: Theme.fontSizeSmall
        Layout.preferredWidth: 30
        horizontalAlignment: Text.AlignRight
    }
}
