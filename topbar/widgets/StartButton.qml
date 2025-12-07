import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../../theme"
import "../../modules/common/widgets"

RippleButton {
    id: startButton
    
    Layout.preferredWidth: 36
    Layout.preferredHeight: 36
    
    radius: 8
    color: "transparent"
    hoverColor: Theme.tabHover
    pressColor: Theme.accent
    
    // Icon
    icon: "☰"
    
    signal startClicked()
    
    }
    
    TapHandler {
        onTapped: {
            console.log("[StartButton] Launcher toggle requested")
            // TODO: Toggle launcher module
        }
    }
}
