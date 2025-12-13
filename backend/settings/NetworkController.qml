import QtQuick
import Quickshell.Io

QtObject {
    id: networkController
    
    // ═══════════════════════════════════════════════════════════
    // SIGNALS
    // ═══════════════════════════════════════════════════════════
    signal networksChanged()
    signal connectionStatusChanged(bool connected)
    signal vpnStatusChanged(bool connected)
    signal error(string message)
    
    // ═══════════════════════════════════════════════════════════
    // PROPERTIES
    // ═══════════════════════════════════════════════════════════
    property bool wifiEnabled: true
    property bool connected: false
    property string currentNetwork: ""
    property var availableNetworks: []  // [{ssid, signal, security, connected}]
    property var vpnConnections: []     // [{name, active}]
    
    // ═══════════════════════════════════════════════════════════
    // PUBLIC FUNCTIONS
    // ═══════════════════════════════════════════════════════════
    
    function scanNetworks() {
        wifiScanProcess.start()
    }
    
    function connectToNetwork(ssid, password) {
        if (password) {
            wifiConnectProcess.command = ["nmcli", "device", "wifi", "connect", ssid, "password", password]
        } else {
            wifiConnectProcess.command = ["nmcli", "device", "wifi", "connect", ssid]
        }
        wifiConnectProcess.start()
    }
    
    function disconnect() {
        wifiDisconnectProcess.start()
    }
    
    function toggleWifi() {
        var state = wifiEnabled ? "off" : "on"
        wifiToggleProcess.command = ["nmcli", "radio", "wifi", state]
        wifiToggleProcess.start()
    }
    
    function toggleVpn(name) {
        var vpn = vpnConnections.find(v => v.name === name)
        if (vpn) {
            var action = vpn.active ? "down" : "up"
            vpnToggleProcess.command = ["nmcli", "connection", action, name]
            vpnToggleProcess.start()
        }
    }
    
    function refresh() {
        wifiListProcess.start()
        vpnListProcess.start()
    }
    
    // ═══════════════════════════════════════════════════════════
    // PROCESSES
    // ═══════════════════════════════════════════════════════════
    
    // List available WiFi networks
    Process {
        id: wifiListProcess
        command: ["nmcli", "-t", "-f", "SSID,SIGNAL,SECURITY,ACTIVE", "device", "wifi", "list"]
        
        onFinished: {
            var networks = []
            var lines = stdout().trim().split("\n")
            for (var i = 0; i < lines.length; i++) {
                var parts = lines[i].split(":")
                if (parts.length >= 4 && parts[0]) {
                    networks.push({
                        ssid: parts[0],
                        signal: parseInt(parts[1]) || 0,
                        security: parts[2] || "Open",
                        connected: parts[3] === "yes"
                    })
                    
                    if (parts[3] === "yes") {
                        networkController.currentNetwork = parts[0]
                        networkController.connected = true
                    }
                }
            }
            
            networkController.availableNetworks = networks
            networksChanged()
        }
    }
    
    // Scan for networks
    Process {
        id: wifiScanProcess
        command: ["nmcli", "device", "wifi", "rescan"]
        
        onFinished: {
            wifiListProcess.start()
        }
    }
    
    // Connect to network
    Process {
        id: wifiConnectProcess
        
        onFinished: {
            if (exitCode === 0) {
                console.log("[NetworkController] Connected successfully")
                refresh()
            } else {
                error("Failed to connect: " + stderr())
            }
        }
    }
    
    // Track detected wifi interface
    property string wifiInterface: "wlan0"  // Will be updated dynamically
    
    // Disconnect
    Process {
        id: wifiDisconnectProcess
        command: ["nmcli", "device", "disconnect", networkController.wifiInterface]
        
        onFinished: {
            networkController.connected = false
            networkController.currentNetwork = ""
            connectionStatusChanged(false)
        }
    }
    
    // Detect WiFi interface
    Process {
        id: detectInterfaceProcess
        command: ["nmcli", "-t", "-f", "TYPE,DEVICE", "device"]
        
        onFinished: {
            var lines = stdout().trim().split("\n")
            for (var i = 0; i < lines.length; i++) {
                var parts = lines[i].split(":")
                if (parts[0] === "wifi" && parts[1]) {
                    networkController.wifiInterface = parts[1]
                    console.log("[NetworkController] Detected WiFi interface:", parts[1])
                    break
                }
            }
        }
    }
    
    // Toggle WiFi
    Process {
        id: wifiToggleProcess
        
        onFinished: {
            // Query actual state instead of blindly toggling
            checkWifiStateProcess.start()
        }
    }
    
    // Check actual WiFi radio state
    Process {
        id: checkWifiStateProcess
        command: ["nmcli", "radio", "wifi"]
        
        onFinished: {
            var state = stdout().trim()
            networkController.wifiEnabled = (state === "enabled")
            refresh()
        }
    }
    
    // List VPN connections
    Process {
        id: vpnListProcess
        command: ["nmcli", "-t", "-f", "NAME,TYPE,ACTIVE", "connection", "show"]
        
        onFinished: {
            var vpns = []
            var lines = stdout().trim().split("\n")
            for (var i = 0; i < lines.length; i++) {
                var parts = lines[i].split(":")
                if (parts.length >= 3 && parts[1].includes("vpn")) {
                    vpns.push({
                        name: parts[0],
                        active: parts[2] === "yes"
                    })
                }
            }
            networkController.vpnConnections = vpns
        }
    }
    
    // Toggle VPN
    Process {
        id: vpnToggleProcess
        
        onFinished: {
            refresh()
        }
    }
    
    // ═══════════════════════════════════════════════════════════
    // INITIALIZATION
    // ═══════════════════════════════════════════════════════════
    
    function initialize() {
        console.log("[NetworkController] Initializing...")
        detectInterfaceProcess.start()  // Detect wifi interface first
        refresh()
    }
    
    Component.onCompleted: {
        console.log("[NetworkController] Module loaded")
    }
}
