import QtQuick
import Quickshell.Io

QtObject {
    id: powerController
    
    // ═══════════════════════════════════════════════════════════
    // SIGNALS
    // ═══════════════════════════════════════════════════════════
    signal actionStarted(string action)
    signal actionCompleted(string action)
    signal error(string action, string message)
    
    // ═══════════════════════════════════════════════════════════
    // PUBLIC FUNCTIONS
    // ═══════════════════════════════════════════════════════════
    
    function lockScreen() {
        console.log("[PowerController] Locking screen...")
        actionStarted("lock")
        lockProcess.start()
    }
    
    function suspend() {
        console.log("[PowerController] Suspending...")
        actionStarted("suspend")
        suspendProcess.start()
    }
    
    function logout() {
        console.log("[PowerController] Logging out...")
        actionStarted("logout")
        logoutProcess.start()
    }
    
    function reboot() {
        console.log("[PowerController] Rebooting...")
        actionStarted("reboot")
        rebootProcess.start()
    }
    
    function shutdown() {
        console.log("[PowerController] Shutting down...")
        actionStarted("shutdown")
        shutdownProcess.start()
    }
    
    // ═══════════════════════════════════════════════════════════
    // PROCESSES
    // ═══════════════════════════════════════════════════════════
    
    Process {
        id: lockProcess
        command: ["loginctl", "lock-session"]
        
        onFinished: {
            actionCompleted("lock")
        }
        
        onError: (msg) => {
            powerController.error("lock", msg)
        }
    }
    
    Process {
        id: suspendProcess
        command: ["systemctl", "suspend"]
        
        onFinished: {
            actionCompleted("suspend")
        }
        
        onError: (msg) => {
            powerController.error("suspend", msg)
        }
    }
    
    Process {
        id: logoutProcess
        command: ["hyprctl", "dispatch", "exit"]
        
        onFinished: {
            actionCompleted("logout")
        }
        
        onError: (msg) => {
            powerController.error("logout", msg)
        }
    }
    
    Process {
        id: rebootProcess
        command: ["systemctl", "reboot"]
        
        onFinished: {
            actionCompleted("reboot")
        }
        
        onError: (msg) => {
            powerController.error("reboot", msg)
        }
    }
    
    Process {
        id: shutdownProcess
        command: ["systemctl", "poweroff"]
        
        onFinished: {
            actionCompleted("shutdown")
        }
        
        onError: (msg) => {
            powerController.error("shutdown", msg)
        }
    }
    
    // ═══════════════════════════════════════════════════════════
    // INITIALIZATION
    // ═══════════════════════════════════════════════════════════
    
    Component.onCompleted: {
        console.log("[PowerController] Module loaded")
    }
}
