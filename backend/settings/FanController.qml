import QtQuick
import Quickshell.Io

QtObject {
    id: fanController
    
    // ═══════════════════════════════════════════════════════════
    // SIGNALS
    // ═══════════════════════════════════════════════════════════
    signal fansUpdated()
    signal error(string message)
    
    // ═══════════════════════════════════════════════════════════
    // PROPERTIES
    // ═══════════════════════════════════════════════════════════
    property bool hardwareDetected: false
    property string hwmonPath: ""
    property var fans: [] // [{channel, speed, rpm, mode}]
    property int cpuTemp: 0
    
    // Channels to monitor (customize for your hardware)
    property var pwmChannels: [1, 3, 6]
    
    // Presets
    readonly property var presets: ({
        "silent": 30,
        "quiet": 50,
        "performance": 80
    })
    
    // ═══════════════════════════════════════════════════════════
    // PUBLIC FUNCTIONS
    // ═══════════════════════════════════════════════════════════
    
    function detectHardware() {
        console.log("[FanController] Detecting hardware...")
        detectProcess.start()
    }
    
    function refresh() {
        if (!hardwareDetected) return
        
        // Read all fan data
        fans = []
        for (var i = 0; i < pwmChannels.length; i++) {
            readFanData(pwmChannels[i])
        }
        readTemperature()
    }
    
    function setFanSpeed(channel, percent) {
        if (!hardwareDetected) {
            error("Hardware not detected")
            return
        }
        
        var pwmValue = Math.round((percent / 100) * 255)
        pwmValue = Math.max(0, Math.min(255, pwmValue))
        
        console.log("[FanController] Setting PWM" + channel + " to " + percent + "% (" + pwmValue + ")")
        
        // Enable manual mode first
        setModeProcess.command = ["sudo", "tee", hwmonPath + "/pwm" + channel + "_enable"]
        setModeProcess.stdin = "1\n"
        setModeProcess.start()
        
        // Then set PWM value
        setSpeedProcess.command = ["sudo", "tee", hwmonPath + "/pwm" + channel]
        setSpeedProcess.stdin = pwmValue.toString() + "\n"
        setSpeedProcess.start()
    }
    
    function setAuto(channel) {
        if (!hardwareDetected) return
        
        console.log("[FanController] Setting PWM" + channel + " to auto mode")
        setModeProcess.command = ["sudo", "tee", hwmonPath + "/pwm" + channel + "_enable"]
        setModeProcess.stdin = "5\n"
        setModeProcess.start()
    }
    
    function applyPreset(presetName) {
        var speed = presets[presetName]
        if (speed === undefined) return
        
        console.log("[FanController] Applying preset:", presetName, "(" + speed + "%)")
        for (var i = 0; i < pwmChannels.length; i++) {
            setFanSpeed(pwmChannels[i], speed)
        }
    }
    
    function setAllAuto() {
        console.log("[FanController] Setting all fans to auto")
        for (var i = 0; i < pwmChannels.length; i++) {
            setAuto(pwmChannels[i])
        }
    }
    
    // ═══════════════════════════════════════════════════════════
    // INTERNAL HELPERS
    // ═══════════════════════════════════════════════════════════
    
    function readFanData(channel) {
        var proc = Qt.createQmlObject(`
            import Quickshell.Io
            Process {
                property int pwmChannel: ${channel}
                command: ["cat", "${hwmonPath}/pwm${channel}"]
            }
        `, fanController)
        
        proc.finished.connect(function() {
            var pwmVal = parseInt(proc.stdout.trim()) || 0
            var percent = Math.round((pwmVal / 255) * 100)
            
            // Now read RPM
            readRpm(channel, percent)
            proc.destroy()
        })
        
        proc.start()
    }
    
    function readRpm(channel, speed) {
        var proc = Qt.createQmlObject(`
            import Quickshell.Io
            Process {
                command: ["cat", "${hwmonPath}/fan${channel}_input"]
            }
        `, fanController)
        
        proc.finished.connect(function() {
            var rpm = parseInt(proc.stdout.trim()) || 0
            
            // Read mode
            readMode(channel, speed, rpm)
            proc.destroy()
        })
        
        proc.start()
    }
    
    function readMode(channel, speed, rpm) {
        var proc = Qt.createQmlObject(`
            import Quickshell.Io
            Process {
                command: ["cat", "${hwmonPath}/pwm${channel}_enable"]
            }
        `, fanController)
        
        proc.finished.connect(function() {
            var mode = parseInt(proc.stdout.trim()) || 0
            var modeStr = mode === 5 ? "auto" : (mode === 1 ? "manual" : "off")
            
            // Add to fans array
            var newFans = fans.slice() // Copy array
            newFans.push({
                channel: channel,
                speed: speed,
                rpm: rpm,
                mode: modeStr
            })
            fans = newFans
            
            // Check if all fans read
            if (fans.length === pwmChannels.length) {
                fansUpdated()
            }
            
            proc.destroy()
        })
        
        proc.start()
    }
    
    function readTemperature() {
        tempProcess.start()
    }
    
    // ═══════════════════════════════════════════════════════════
    // PROCESSES
    // ═══════════════════════════════════════════════════════════
    
    // Hardware detection
    Process {
        id: detectProcess
        command: ["sh", "-c", "find /sys/class/hwmon/ -name 'hwmon*' -exec sh -c 'if [ -f \"$1/name\" ] && grep -qE \"nct67\" \"$1/name\" 2>/dev/null; then echo \"$1\"; fi' _ {} \\; | head -1"]
        
        onFinished: {
            var path = stdout.trim()
            if (path) {
                fanController.hwmonPath = path
                fanController.hardwareDetected = true
                console.log("[FanController] Hardware detected at:", path)
                refresh()
            } else {
                console.warn("[FanController] NCT67** chip not found")
                fanController.error("NCT67** fan controller not detected")
            }
        }
    }
    
    // Set mode (manual/auto)
    Process {
        id: setModeProcess
        property string stdin: ""
        
        onStarted: {
            write(stdin)
        }
        
        onFinished: {
            refresh()
        }
    }
    
    // Set speed
    Process {
        id: setSpeedProcess
        property string stdin: ""
        
        onStarted: {
            write(stdin)
        }
        
        onFinished: {
            refresh()
        }
    }
    
    // Temperature
    Process {
        id: tempProcess
        command: ["sh", "-c", "sensors | grep 'Tctl:' | awk '{print $2}' | sed 's/+//;s/°C//'"]
        
        onFinished: {
            fanController.cpuTemp = parseInt(stdout.trim()) || 0
        }
    }
    
    // ═══════════════════════════════════════════════════════════
    // POLLING
    // ═══════════════════════════════════════════════════════════
    
    Timer {
        id: pollTimer
        interval: 5000
        repeat: true
        running: fanController.hardwareDetected
        onTriggered: fanController.refresh()
    }
    
    // ═══════════════════════════════════════════════════════════
    // INITIALIZATION
    // ═══════════════════════════════════════════════════════════
    
    function initialize() {
        console.log("[FanController] Initializing...")
        detectHardware()
    }
    
    Component.onCompleted: {
        console.log("[FanController] Module loaded")
    }
}
