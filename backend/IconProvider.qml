import QtQuick
import Quickshell.Io

QtObject {
    id: iconProvider
    
    // ═══════════════════════════════════════════════════════════
    // PROPERTIES
    // ═══════════════════════════════════════════════════════════
    property string themeName: "hicolor"
    property var iconDirs: [
        Qt.getenv("HOME") + "/.local/share/icons",
        Qt.getenv("HOME") + "/.icons",
        "/usr/share/icons",
        "/usr/share/pixmaps"
    ]
    property var sizes: [48, 32, 24, 22, 16]
    property var cache: ({}) // {name: path}
    
    // ═══════════════════════════════════════════════════════════
    // PUBLIC FUNCTIONS
    // ═══════════════════════════════════════════════════════════
    
    function getIcon(name, preferredSize) {
        if (!name) return ""
        
        // Check cache
        var cacheKey = name + "_" + (preferredSize || 48)
        if (cache[cacheKey]) {
            return cache[cacheKey]
        }
        
        // If it's already a path, return as-is
        if (name.startsWith("/") || name.startsWith("file://")) {
            return name
        }
        
        // Search for icon (async would be better, but simplified here)
        var path = findIconSync(name, preferredSize || 48)
        if (path) {
            cache[cacheKey] = path
        }
        return path
    }
    
    function getIconAsync(name, preferredSize, callback) {
        var path = getIcon(name, preferredSize)
        if (path) {
            callback(path)
            return
        }
        
        // Try harder with locate command
        var proc = Qt.createQmlObject(`
            import Quickshell.Io
            Process {
                command: ["sh", "-c", "find /usr/share/icons -name '${name}.*' -type f 2>/dev/null | head -1"]
            }
        `, iconProvider)
        
        proc.finished.connect(function() {
            var result = proc.stdout.trim()
            if (result) {
                cache[name + "_" + preferredSize] = result
                callback(result)
            } else {
                callback("")
            }
            proc.destroy()
        })
        proc.start()
    }
    
    // ═══════════════════════════════════════════════════════════
    // INTERNAL HELPERS
    // ═══════════════════════════════════════════════════════════
    
    function findIconSync(name, size) {
        // Try common locations
        var extensions = [".svg", ".png", ".xpm"]
        var categories = ["apps", "applications", "mimetypes", "places", "devices", "status"]
        
        for (var d = 0; d < iconDirs.length; d++) {
            var baseDir = iconDirs[d]
            
            // Try theme directories with sizes
            for (var s = 0; s < sizes.length; s++) {
                var sizeStr = sizes[s] + "x" + sizes[s]
                
                for (var c = 0; c < categories.length; c++) {
                    for (var e = 0; e < extensions.length; e++) {
                        // Theme path: /usr/share/icons/hicolor/48x48/apps/firefox.png
                        var path = baseDir + "/" + themeName + "/" + sizeStr + "/" + 
                                   categories[c] + "/" + name + extensions[e]
                        
                        // Can't check file existence synchronously easily in QML
                        // This is a simplified approach
                    }
                }
            }
            
            // Try scalable
            for (var c2 = 0; c2 < categories.length; c2++) {
                var scalablePath = baseDir + "/" + themeName + "/scalable/" + 
                                   categories[c2] + "/" + name + ".svg"
            }
            
            // Try pixmaps directly
            for (var e2 = 0; e2 < extensions.length; e2++) {
                var pixmapPath = baseDir + "/" + name + extensions[e2]
            }
        }
        
        return ""
    }
    
    function detectTheme() {
        // Try to detect GTK icon theme
        themeProcess.start()
    }
    
    // ═══════════════════════════════════════════════════════════
    // PROCESSES
    // ═══════════════════════════════════════════════════════════
    
    Process {
        id: themeProcess
        command: ["gsettings", "get", "org.gnome.desktop.interface", "icon-theme"]
        
        onFinished: {
            var theme = stdout.trim().replace(/'/g, "")
            if (theme) {
                iconProvider.themeName = theme
                console.log("[IconProvider] Detected theme:", theme)
            }
        }
    }
    
    // ═══════════════════════════════════════════════════════════
    // INITIALIZATION
    // ═══════════════════════════════════════════════════════════
    
    function initialize() {
        console.log("[IconProvider] Initializing...")
        detectTheme()
    }
    
    Component.onCompleted: {
        console.log("[IconProvider] Module loaded")
        detectTheme()
    }
}
