import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import "../theme"
import "widgets"

PopupWindow {
    id: settingsPanel
    
    // Positioning (Top Right, below bar)
    anchor.window: topBar  // Make sure to set this property when instantiating
    anchor.on: Anchor.BottomRight
    anchor.rect: AnchorRect.Selection // Or appropriate rect
    
    width: 340
    height: contentLayout.implicitHeight + 32
    
    // Visuals
    color: "transparent"
    
    // Dependencies
    required property var backend
    
    // Background with Blur
    Rectangle {
        anchors.fill: parent
        color: Theme.background
        radius: Theme.cornerRadius
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.1)
        
        // Shadow/Blur would go here
    }
    
    ColumnLayout {
        id: contentLayout
        anchors.fill: parent
        anchors.margins: 16
        spacing: 16
        
        // 1. SLIDERS
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 8
            
            // Volume
            SliderControl {
                Layout.fillWidth: true
                label: "Volume"
                icon: backend.audio.muted ? "🔇" : "🔊"
                value: backend.audio.volume
                from: 0
                to: 100
                
                onMoved: (val) => backend.audio.setVolume(val)
            }
            
            // Brightness
            SliderControl {
                Layout.fillWidth: true
                label: "Brightness"
                icon: "☀️"
                value: backend.display.brightness
                from: 5
                to: 100
                
                onMoved: (val) => backend.display.setBrightness(val)
            }
        }
        
        // Separator
        Rectangle { Layout.fillWidth: true; height: 1; color: Theme.textDim; opacity: 0.2 }
        
        // 2. QUICK TOGGLES (Grid)
        GridLayout {
            Layout.fillWidth: true
            columns: 2
            rowSpacing: 12
            columnSpacing: 12
            
            // WiFi
            QuickToggle {
                Layout.fillWidth: true
                label: "WiFi"
                icon: "📶"
                active: backend.network.wifiEnabled
                statusText: backend.network.currentNetwork || (active ? "On" : "Off")
                
                onClicked: backend.network.toggleWifi()
            }
            
            // Bluetooth
            QuickToggle {
                Layout.fillWidth: true
                label: "Bluetooth"
                icon: "ᛒ"
                active: backend.bluetooth.powered
                statusText: backend.bluetooth.pairedDevices.length + " paired"
                
                onClicked: backend.bluetooth.togglePower()
            }
            
            // Night Light
            QuickToggle {
                Layout.fillWidth: true
                label: "Night Light"
                icon: "🌙"
                active: backend.display.nightLightEnabled
                statusText: active ? "On" : "Off"
                
                onClicked: backend.display.toggleNightLight()
            }
            
            // VPN (Example - just toggles first available)
            QuickToggle {
                Layout.fillWidth: true
                label: "VPN"
                icon: "🛡️"
                active: backend.network.vpnConnections.some(v => v.active)
                statusText: active ? "Connected" : "Off"
                
                onClicked: {
                    // Logic to toggle primary VPN or show list
                    if (backend.network.vpnConnections.length > 0) {
                        backend.network.toggleVpn(backend.network.vpnConnections[0].name)
                    }
                }
            }
        }
        
        // Separator
        Rectangle { Layout.fillWidth: true; height: 1; color: Theme.textDim; opacity: 0.2 }
        
        // 3. FAN CONTROL
        FanControlWidget {
            Layout.fillWidth: true
            backend: settingsPanel.backend
        }
        
        // Separator
        Rectangle { Layout.fillWidth: true; height: 1; color: Theme.textDim; opacity: 0.2 }
        
        // 4. POWER CONTROLS
        PowerRow {
            Layout.fillWidth: true
            onAction: (type) => {
                switch(type) {
                    case "lock": backend.power.lockScreen(); break;
                    case "suspend": backend.power.suspend(); break;
                    case "logout": backend.power.logout(); break;
                    case "shutdown": backend.power.shutdown(); break;
                }
            }
        }
    }
}
