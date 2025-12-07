import QtQuick

QtObject {
    id: systemInfoModel
    
    // ═══════════════════════════════════════════════════════════
    // CLOCK
    // ═══════════════════════════════════════════════════════════
    property string time: "00:00"           // "14:32"
    property string timeWithSeconds: "00:00:00"
    property string date: ""                // "Sat Dec 7"
    property string dateISO: ""             // "2024-12-07"
    property string dayOfWeek: ""           // "Saturday"
    
    // ═══════════════════════════════════════════════════════════
    // BATTERY
    // ═══════════════════════════════════════════════════════════
    property bool hasBattery: false
    property int batteryPercent: 0          // 0-100
    property bool charging: false
    property bool fullyCharged: false
    property int timeToEmpty: 0             // seconds
    property int timeToFull: 0              // seconds
    property string batteryState: "unknown" // "charging", "discharging", "full", "unknown"
    
    // ═══════════════════════════════════════════════════════════
    // NETWORK
    // ═══════════════════════════════════════════════════════════
    property bool networkConnected: false
    property string networkType: "none"     // "wifi", "ethernet", "none"
    property string networkName: ""         // SSID or interface name
    property int wifiSignalStrength: 0      // 0-100
    property string ipAddress: ""
    
    // ═══════════════════════════════════════════════════════════
    // AUDIO (from Pipewire)
    // ═══════════════════════════════════════════════════════════
    property int volume: 0                  // 0-100
    property bool muted: false
    property string audioSink: ""           // Current output device
    
    // ═══════════════════════════════════════════════════════════
    // SYSTEM
    // ═══════════════════════════════════════════════════════════
    property string hostname: ""
    property string username: ""
    
    // Update clock from Date object
    function updateClock(date) {
        var hours = String(date.getHours()).padStart(2, '0')
        var mins = String(date.getMinutes()).padStart(2, '0')
        var secs = String(date.getSeconds()).padStart(2, '0')
        
        time = hours + ":" + mins
        timeWithSeconds = hours + ":" + mins + ":" + secs
        
        var days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        var months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        
        dayOfWeek = days[date.getDay()]
        this.date = days[date.getDay()].slice(0, 3) + " " + months[date.getMonth()] + " " + date.getDate()
        dateISO = date.getFullYear() + "-" + String(date.getMonth() + 1).padStart(2, '0') + "-" + String(date.getDate()).padStart(2, '0')
    }
}
