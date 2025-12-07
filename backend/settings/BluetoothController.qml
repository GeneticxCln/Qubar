import QtQuick
import Quickshell.Io

QtObject {
    id: bluetoothController
    
    // ═══════════════════════════════════════════════════════════
    // SIGNALS
    // ═══════════════════════════════════════════════════════════
    signal devicesChanged()
    signal connectionChanged(string mac, bool connected)
    signal powerChanged(bool on)
    signal error(string message)
    
    // ═══════════════════════════════════════════════════════════
    // PROPERTIES
    // ═══════════════════════════════════════════════════════════
    property bool powered: false
    property bool scanning: false
    property var pairedDevices: []    // [{name, mac, connected}]
    property var availableDevices: [] // [{name, mac}]
    
    // ═══════════════════════════════════════════════════════════
    // PUBLIC FUNCTIONS
    // ═══════════════════════════════════════════════════════════
    
    function togglePower() {
        var state = powered ? "off" : "on"
        powerProcess.command = ["bluetoothctl", "power", state]
        powerProcess.start()
    }
    
    function startScan() {
        scanning = true
        scanProcess.command = ["bluetoothctl", "scan", "on"]
        scanProcess.start()
        
        // Stop scan after 10 seconds
        scanTimer.start()
    }
    
    function stopScan() {
        scanning = false
        scanStopProcess.start()
    }
    
    function connect(mac) {
        connectProcess.command = ["bluetoothctl", "connect", mac]
        connectProcess.start()
    }
    
    function disconnect(mac) {
        disconnectProcess.command = ["bluetoothctl", "disconnect", mac]
        disconnectProcess.start()
    }
    
    function refresh() {
        pairedProcess.start()
        powerCheckProcess.start()
    }
    
    // ═══════════════════════════════════════════════════════════
    // PROCESSES
    // ═══════════════════════════════════════════════════════════
    
    // Power toggle
    Process {
        id: powerProcess
        onFinished: {
            bluetoothController.powered = !bluetoothController.powered
            powerChanged(bluetoothController.powered)
        }
    }
    
    // Check power state
    Process {
        id: powerCheckProcess
        command: ["bluetoothctl", "show"]
        
        onFinished: {
            bluetoothController.powered = stdout.includes("Powered: yes")
        }
    }
    
    // List paired devices
    Process {
        id: pairedProcess
        command: ["bluetoothctl", "devices", "Paired"]
        
        onFinished: {
            var devices = []
            var lines = stdout.trim().split("\n")
            for (var i = 0; i < lines.length; i++) {
                // Format: "Device XX:XX:XX:XX:XX:XX Name"
                var match = lines[i].match(/Device ([A-F0-9:]+) (.+)/)
                if (match) {
                    devices.push({
                        mac: match[1],
                        name: match[2],
                        connected: false // Will be updated by info check
                    })
                }
            }
            
            bluetoothController.pairedDevices = devices
            devicesChanged()
            
            // Check connection status for each
            devices.forEach(function(d) {
                checkDeviceConnection(d.mac)
            })
        }
    }
    
    function checkDeviceConnection(mac) {
        var proc = Qt.createQmlObject(`
            import Quickshell.Io
            Process {
                command: ["bluetoothctl", "info", "${mac}"]
            }
        `, bluetoothController)
        
        proc.finished.connect(function() {
            var isConnected = proc.stdout.includes("Connected: yes")
            
            // Update device in list
            var devices = bluetoothController.pairedDevices.map(function(d) {
                if (d.mac === mac) {
                    d.connected = isConnected
                }
                return d
            })
            bluetoothController.pairedDevices = devices
            
            proc.destroy()
        })
        
        proc.start()
    }
    
    // Scan
    Process {
        id: scanProcess
    }
    
    Process {
        id: scanStopProcess
        command: ["bluetoothctl", "scan", "off"]
    }
    
    Timer {
        id: scanTimer
        interval: 10000
        onTriggered: bluetoothController.stopScan()
    }
    
    // Connect
    Process {
        id: connectProcess
        
        onFinished: {
            if (exitCode === 0) {
                console.log("[BluetoothController] Connected")
                refresh()
            } else {
                error("Connection failed")
            }
        }
    }
    
    // Disconnect
    Process {
        id: disconnectProcess
        
        onFinished: {
            refresh()
        }
    }
    
    // ═══════════════════════════════════════════════════════════
    // INITIALIZATION
    // ═══════════════════════════════════════════════════════════
    
    function initialize() {
        console.log("[BluetoothController] Initializing...")
        refresh()
    }
    
    Component.onCompleted: {
        console.log("[BluetoothController] Module loaded")
    }
}
