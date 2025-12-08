import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "widgets" as widgets
import Quickshell
import "../theme"

PopupWindow {
    id: settingsPanel
    
    width: 340
    height: contentLayout.implicitHeight + 32
    
    // Visuals
    color: "transparent"
    
    // Dependencies
    required property var backend
    
    // Signal for opening wallpaper picker
    signal openWallpaperPicker()
    
    // Background with Blur
    Rectangle {
        anchors.fill: parent
        color: Theme.background
        radius: Theme.cornerRadius
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.1)
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
            widgets.SliderControl {
                Layout.fillWidth: true
                label: "Volume"
                icon: backend && backend.audio && backend.audio.muted ? "🔇" : "🔊"
                value: backend && backend.audio ? backend.audio.volume : 50
                from: 0
                to: 100
                
                onMoved: (val) => {
                    if (backend && backend.audio) backend.audio.setVolume(val)
                }
            }
            
            // Brightness
            widgets.SliderControl {
                Layout.fillWidth: true
                label: "Brightness"
                icon: "☀️"
                value: backend && backend.display ? backend.display.brightness : 100
                from: 5
                to: 100
                
                onMoved: (val) => {
                    if (backend && backend.display) backend.display.setBrightness(val)
                }
            }
        }
        
        // Separator
        Rectangle { Layout.fillWidth: true; height: 1; color: Theme.textDim; opacity: 0.2 }
        
        // WALLPAPER WIDGET
        widgets.WallpaperWidget {
            Layout.fillWidth: true
            onOpenWallpaperPicker: settingsPanel.openWallpaperPicker()
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
            widgets.QuickToggle {
                Layout.fillWidth: true
                label: "WiFi"
                icon: "📶"
                active: backend && backend.network ? backend.network.wifiEnabled : false
                statusText: backend && backend.network && backend.network.currentNetwork ? 
                           backend.network.currentNetwork : (active ? "On" : "Off")
                
                onClicked: {
                    if (backend && backend.network) backend.network.toggleWifi()
                }
            }
            
            // Bluetooth
            widgets.QuickToggle {
                Layout.fillWidth: true
                label: "Bluetooth"
                icon: "ᛒ"
                active: backend && backend.bluetooth ? backend.bluetooth.powered : false
                statusText: backend && backend.bluetooth ? 
                           backend.bluetooth.pairedDevices.length + " paired" : "Off"
                
                onClicked: {
                    if (backend && backend.bluetooth) backend.bluetooth.togglePower()
                }
            }
            
            // Night Light
            widgets.QuickToggle {
                Layout.fillWidth: true
                label: "Night Light"
                icon: "🌙"
                active: backend && backend.display ? backend.display.nightLightEnabled : false
                statusText: active ? "On" : "Off"
                
                onClicked: {
                    if (backend && backend.display) backend.display.toggleNightLight()
                }
            }
            
            // Theme Toggle
            widgets.QuickToggle {
                Layout.fillWidth: true
                label: "Theme"
                icon: Theme.currentThemeName === "dark" ? "🌙" : 
                      Theme.currentThemeName === "light" ? "☀️" : "🎨"
                active: Theme.currentThemeName !== "dark"
                statusText: Theme.currentThemeName.charAt(0).toUpperCase() + 
                           Theme.currentThemeName.slice(1)
                
                onClicked: Theme.toggleTheme()
            }
        }
        
        // Separator
        Rectangle { Layout.fillWidth: true; height: 1; color: Theme.textDim; opacity: 0.2 }

        // 3. MEDIA CONTROL
        widgets.MediaPlayerWidget {
            Layout.fillWidth: true
            backend: settingsPanel.backend
        }
        
        // Separator
        Rectangle { Layout.fillWidth: true; height: 1; color: Theme.textDim; opacity: 0.2 }
        
        // 4. FAN CONTROL
        widgets.FanControlWidget {
            Layout.fillWidth: true
            backend: settingsPanel.backend
        }
        
        // Separator
        Rectangle { Layout.fillWidth: true; height: 1; color: Theme.textDim; opacity: 0.2 }
        
        // 5. POWER CONTROLS
        widgets.PowerRow {
            Layout.fillWidth: true
            onAction: (type) => {
                if (!backend || !backend.power) return
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
