import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../../theme"

GridView {
    id: appGrid
    
    // Dependencies
    required property var backend
    
    // Model
    model: backend.launcher.filteredApps
    
    // Grid settings
    cellWidth: 110
    cellHeight: 120
    clip: true
    focus: true
    
    // Delegate
    delegate: AppItem {
        appData: modelData
        
        onLaunched: {
            backend.launcher.launch(modelData)
            // Signal to close launcher? handled by parent usually
            appGrid.appLaunched()
        }
    }
    
    signal appLaunched()
    
    // ScrollBar
    ScrollBar.vertical: ScrollBar {
        width: 6
        policy: ScrollBar.AsNeeded
        
        contentItem: Rectangle {
            implicitWidth: 6
            implicitHeight: 100
            radius: 3
            color: Theme.textDim
            opacity: 0.5
        }
    }
}
