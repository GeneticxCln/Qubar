import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: appLauncher
    
    // ═══════════════════════════════════════════════════════════
    // SIGNALS
    // ═══════════════════════════════════════════════════════════
    signal applicationsLoaded()
    signal appLaunched(string name)
    signal error(string message)
    
    // ═══════════════════════════════════════════════════════════
    // PROPERTIES
    // ═══════════════════════════════════════════════════════════
    property var applications: []       // All parsed apps
    property var recentApps: []         // Recently launched (max 10)
    property var favoriteApps: []       // User favorites
    property var launchCounts: ({})     // { desktopFile: count }
    property var lastLaunched: ({})     // { desktopFile: timestamp }
    property string searchQuery: ""
    property string activeCategory: "all"
    property var filteredApps: []       // Search/filter results
    property bool loading: false
    
    // File paths
    readonly property string dataDir: Qt.getenv("HOME") + "/.local/share/qubar"
    readonly property string favoritesFile: dataDir + "/favorites.json"
    readonly property string statsFile: dataDir + "/launch_stats.json"
    
    // ═══════════════════════════════════════════════════════════
    // SMART RANKING - Frequency + Recency based scoring
    // ═══════════════════════════════════════════════════════════
    
    function getAppScore(app) {
        if (!app || !app.desktopFile) return 0
        
        var score = 0
        var df = app.desktopFile
        
        // Frequency score (0-50 points)
        var count = launchCounts[df] || 0
        score += Math.min(count * 5, 50)
        
        // Recency score (0-50 points) - decay over time
        var lastTime = lastLaunched[df] || 0
        if (lastTime > 0) {
            var hoursSince = (Date.now() - lastTime) / (1000 * 60 * 60)
            if (hoursSince < 1) score += 50
            else if (hoursSince < 6) score += 40
            else if (hoursSince < 24) score += 30
            else if (hoursSince < 72) score += 20
            else if (hoursSince < 168) score += 10
        }
        
        // Favorite bonus
        if (isFavorite(app)) score += 100
        
        return score
    }
    
    function sortBySmartRanking(apps) {
        return apps.slice().sort(function(a, b) {
            var scoreA = getAppScore(a)
            var scoreB = getAppScore(b)
            
            if (scoreB !== scoreA) {
                return scoreB - scoreA // Higher score first
            }
            // Fallback: alphabetical
            return a.name.localeCompare(b.name)
        })
    }
    
    // ═══════════════════════════════════════════════════════════
    // FUZZY SEARCH
    // ═══════════════════════════════════════════════════════════
    
    function fuzzyMatch(text, query) {
        if (!text || !query) return { matches: false, score: 0 }
        
        text = text.toLowerCase()
        query = query.toLowerCase()
        
        // Exact match (highest score)
        if (text.includes(query)) {
            return { matches: true, score: 100 - text.indexOf(query) }
        }
        
        // Abbreviation match (first letters of words)
        var words = text.split(/[\s\-_]+/)
        var abbrev = words.map(w => w.charAt(0)).join('')
        if (abbrev.includes(query)) {
            return { matches: true, score: 80 }
        }
        
        // Fuzzy character match
        var queryIdx = 0
        var score = 0
        var consecutive = 0
        
        for (var i = 0; i < text.length && queryIdx < query.length; i++) {
            if (text[i] === query[queryIdx]) {
                queryIdx++
                consecutive++
                score += consecutive * 2 // Bonus for consecutive matches
            } else {
                consecutive = 0
            }
        }
        
        if (queryIdx === query.length) {
            return { matches: true, score: score }
        }
        
        return { matches: false, score: 0 }
    }
    
    function searchApps(apps, query) {
        if (!query || query.trim() === "") {
            return sortBySmartRanking(apps)
        }
        
        query = query.trim().toLowerCase()
        
        var results = []
        for (var i = 0; i < apps.length; i++) {
            var app = apps[i]
            
            // Match against name, categories, keywords
            var nameMatch = fuzzyMatch(app.name, query)
            var catMatch = fuzzyMatch(app.categories || "", query)
            var kwMatch = fuzzyMatch(app.keywords || "", query)
            
            var bestScore = Math.max(nameMatch.score, catMatch.score * 0.5, kwMatch.score * 0.7)
            
            if (nameMatch.matches || catMatch.matches || kwMatch.matches) {
                results.push({ app: app, searchScore: bestScore })
            }
        }
        
        // Sort by search score + smart ranking
        results.sort(function(a, b) {
            var scoreA = a.searchScore + getAppScore(a.app)
            var scoreB = b.searchScore + getAppScore(b.app)
            return scoreB - scoreA
        })
        
        return results.map(r => r.app)
    }
    
    // ═══════════════════════════════════════════════════════════
    // PUBLIC FUNCTIONS
    // ═══════════════════════════════════════════════════════════
    
    function loadApplications() {
        loading = true
        console.log("[AppLauncher] Loading applications...")
        loadProcess.running = true
    }
    
    function launch(app) {
        if (!app || !app.desktopFile) {
            error("Invalid app")
            return
        }
        
        console.log("[AppLauncher] Launching:", app.name)
        
        // Track stats
        var df = app.desktopFile
        launchCounts[df] = (launchCounts[df] || 0) + 1
        lastLaunched[df] = Date.now()
        saveStats()
        
        // Add to recent
        addToRecent(app)
        
        // Launch via gtk-launch
        launchProcess.command = ["gtk-launch", df.replace(/\.desktop$/, "")]
        launchProcess.running = true
        
        appLaunched(app.name)
    }
    
    function search(query) {
        searchQuery = query
        applyFilters()
    }
    
    function filterByCategory(categoryId) {
        activeCategory = categoryId
        applyFilters()
    }
    
    function applyFilters() {
        var baseApps = applications
        
        // Apply category filter first
        if (activeCategory === "favorites") {
            baseApps = favoriteApps
        } else if (activeCategory === "terminal") {
            baseApps = applications.filter(function(app) {
                return app.categories && (
                    app.categories.includes("TerminalEmulator") ||
                    app.name.toLowerCase().includes("terminal") ||
                    app.name.toLowerCase().includes("konsole") ||
                    app.name.toLowerCase().includes("kitty") ||
                    app.name.toLowerCase().includes("alacritty")
                )
            })
        } else if (activeCategory === "files") {
            baseApps = applications.filter(function(app) {
                return app.categories && (
                    app.categories.includes("FileManager") ||
                    app.name.toLowerCase().includes("files") ||
                    app.name.toLowerCase().includes("nautilus") ||
                    app.name.toLowerCase().includes("dolphin")
                )
            })
        } else if (activeCategory === "settings") {
            baseApps = applications.filter(function(app) {
                return app.categories && (
                    app.categories.includes("Settings") ||
                    app.name.toLowerCase().includes("settings") ||
                    app.name.toLowerCase().includes("preferences") ||
                    app.name.toLowerCase().includes("configuration")
                )
            })
        }
        
        // Then apply search
        filteredApps = searchApps(baseApps, searchQuery)
        
        console.log("[AppLauncher] Filtered:", activeCategory, "search:", searchQuery, "->", filteredApps.length)
    }
    
    // ═══════════════════════════════════════════════════════════
    // FAVORITES MANAGEMENT
    // ═══════════════════════════════════════════════════════════
    
    function isFavorite(app) {
        if (!app) return false
        return favoriteApps.some(a => a.desktopFile === app.desktopFile)
    }
    
    function addToFavorites(app) {
        if (!app || isFavorite(app)) return
        
        var newFavorites = favoriteApps.slice()
        newFavorites.push(app)
        favoriteApps = newFavorites
        saveFavorites()
        console.log("[AppLauncher] Added to favorites:", app.name)
    }
    
    function removeFromFavorites(app) {
        if (!app) return
        favoriteApps = favoriteApps.filter(a => a.desktopFile !== app.desktopFile)
        saveFavorites()
        console.log("[AppLauncher] Removed from favorites:", app.name)
    }
    
    function toggleFavorite(app) {
        if (isFavorite(app)) {
            removeFromFavorites(app)
        } else {
            addToFavorites(app)
        }
    }
    
    // ═══════════════════════════════════════════════════════════
    // PERSISTENCE
    // ═══════════════════════════════════════════════════════════
    
    function saveFavorites() {
        var favList = favoriteApps.map(a => a.desktopFile)
        saveFavoritesProcess.stdin = JSON.stringify(favList, null, 2)
        saveFavoritesProcess.start()
    }
    
    function loadFavorites() {
        loadFavoritesProcess.running = true
    }
    
    function saveStats() {
        var stats = {
            counts: launchCounts,
            lastLaunched: lastLaunched
        }
        saveStatsProcess.stdin = JSON.stringify(stats, null, 2)
        saveStatsProcess.start()
    }
    
    function loadStats() {
        loadStatsProcess.running = true
    }
    
    // ═══════════════════════════════════════════════════════════
    // INTERNAL HELPERS
    // ═══════════════════════════════════════════════════════════
    
    function addToRecent(app) {
        var recent = recentApps.filter(a => a.desktopFile !== app.desktopFile)
        recent.unshift(app)
        recentApps = recent.slice(0, 10)
    }
    
    property int pendingParseCount: 0
    property var parsedApps: []
    
    function parseDesktopFiles(fileList) {
        parsedApps = []
        var files = fileList.trim().split("\n").filter(f => f.trim() !== "")
        pendingParseCount = files.length
        
        if (files.length === 0) {
            finishLoading()
            return
        }
        
        console.log("[AppLauncher] Parsing", files.length, "desktop files...")
        
        // Read all files at once with a single cat command
        var cmd = "cat " + files.map(f => '"' + f + '"').join(" ") + " 2>/dev/null"
        batchParseProcess.command = ["bash", "-c", cmd]
        batchParseProcess.running = true
        
        // Store file list for later
        appLauncher._pendingFiles = files
    }
    
    property var _pendingFiles: []
    
    function parseBatchContent(content) {
        // Split by desktop entry boundaries
        var files = _pendingFiles
        var apps = []
        
        // Parse each file individually for accuracy
        for (var i = 0; i < files.length; i++) {
            var file = files[i]
            // Extract just the filename
            var filename = file.split("/").pop()
            
            // Simple parse - read file directly
            parseIndividualFile(file, apps)
        }
    }
    
    function parseIndividualFile(filePath, resultsArray) {
        // Create inline parser for each file
        var proc = Qt.createQmlObject('\
            import QtQuick\n\
            import Quickshell.Io\n\
            Process {\
                property string filePath: ""\
                running: false\
            }\
        ', appLauncher)
        
        proc.filePath = filePath
        proc.command = ["cat", filePath]
        
        // Handle process errors
        proc.error.connect(function(msg) {
            console.warn("[AppLauncher] Process error for:", filePath, msg)
            pendingParseCount--
            if (pendingParseCount <= 0) {
                finishLoading()
            }
            proc.destroy()
        })
        
        proc.exited.connect(function(code, status) {
            try {
                if (code === 0) {
                    var app = parseDesktopEntry(proc.stdout(), filePath)
                    if (app) {
                        parsedApps.push(app)
                    }
                }
            } catch (e) {
                console.warn("[AppLauncher] Parse error for:", filePath, e.message)
            }
            
            pendingParseCount--
            
            if (pendingParseCount <= 0) {
                finishLoading()
            }
            
            proc.destroy()
        })
        
        proc.running = true
    }
    
    function finishLoading() {
        // Sort alphabetically first, then smart ranking will be applied during filtering
        parsedApps.sort(function(a, b) {
            return a.name.localeCompare(b.name)
        })
        
        applications = parsedApps
        filteredApps = sortBySmartRanking(parsedApps)
        loading = false
        
        console.log("[AppLauncher] Loaded", applications.length, "applications")
        applicationsLoaded()
        
        // Restore favorites references
        restoreFavoriteReferences()
    }
    
    function restoreFavoriteReferences() {
        // After apps are loaded, update favoriteApps with full app objects
        if (_loadedFavoriteIds && _loadedFavoriteIds.length > 0) {
            var restored = []
            for (var i = 0; i < _loadedFavoriteIds.length; i++) {
                var id = _loadedFavoriteIds[i]
                var app = applications.find(a => a.desktopFile === id)
                if (app) restored.push(app)
            }
            favoriteApps = restored
            console.log("[AppLauncher] Restored", restored.length, "favorites")
        }
    }
    
    property var _loadedFavoriteIds: []
    
    function parseDesktopEntry(content, filePath) {
        if (!content) return null
        
        // Skip if NoDisplay=true or hidden
        if (content.includes("NoDisplay=true") || content.includes("Hidden=true")) {
            return null
        }
        
        // Only handle Application type
        if (!content.includes("Type=Application")) {
            return null
        }
        
        var app = {
            name: extractValue(content, "Name"),
            icon: extractValue(content, "Icon") || "application-x-executable",
            exec: extractValue(content, "Exec"),
            categories: extractValue(content, "Categories"),
            keywords: extractValue(content, "Keywords"),
            comment: extractValue(content, "Comment"),
            desktopFile: filePath.split("/").pop()
        }
        
        if (!app.name) return null
        
        return app
    }
    
    function extractValue(content, key) {
        var regex = new RegExp("^" + key + "=(.*)$", "m")
        var match = content.match(regex)
        return match ? match[1].trim() : ""
    }
    
    // ═══════════════════════════════════════════════════════════
    // PROCESSES
    // ═══════════════════════════════════════════════════════════
    
    Process {
        id: loadProcess
        command: ["find", "/usr/share/applications", Qt.getenv("HOME") + "/.local/share/applications",
                  "-maxdepth", "1", "-name", "*.desktop", "-type", "f"]
        running: false
        
        onExited: (code, status) => {
            if (code === 0) {
                parseDesktopFiles(stdout())
            } else {
                console.error("[AppLauncher] Find failed")
                loading = false
            }
        }
    }
    
    Process {
        id: batchParseProcess
        running: false
        // Handled via individual parsing now
    }
    
    Process {
        id: launchProcess
        running: false
        
        onExited: (code, status) => {
            if (code !== 0) {
                console.warn("[AppLauncher] Launch may have failed")
            }
        }
    }
    
    Process {
        id: saveFavoritesProcess
        command: ["bash", "-c", "mkdir -p " + appLauncher.dataDir + " && tee " + appLauncher.favoritesFile]
        running: false
        
        onExited: (code, status) => {
            if (code === 0) {
                console.log("[AppLauncher] Favorites saved")
            }
        }
    }
    
    Process {
        id: saveStatsProcess
        command: ["bash", "-c", "mkdir -p " + appLauncher.dataDir + " && tee " + appLauncher.statsFile]
        running: false
        
        onExited: (code, status) => {
            if (code === 0) {
                console.log("[AppLauncher] Stats saved")
            }
        }
    }
    
    Process {
        id: loadFavoritesProcess
        command: ["cat", appLauncher.favoritesFile]
        running: false
        
        onExited: (code, status) => {
            if (code === 0) {
                try {
                    var ids = JSON.parse(stdout())
                    _loadedFavoriteIds = ids
                    console.log("[AppLauncher] Loaded", ids.length, "favorite IDs")
                } catch (e) {
                    console.log("[AppLauncher] No favorites file or invalid")
                }
            }
            appLauncher._favoritesLoaded = true
            appLauncher._checkInitComplete()
        }
    }
    
    Process {
        id: loadStatsProcess
        command: ["cat", appLauncher.statsFile]
        running: false
        
        onExited: (code, status) => {
            if (code === 0) {
                try {
                    var stats = JSON.parse(stdout())
                    launchCounts = stats.counts || {}
                    lastLaunched = stats.lastLaunched || {}
                    console.log("[AppLauncher] Loaded launch stats")
                } catch (e) {
                    console.log("[AppLauncher] No stats file or invalid")
                }
            }
            appLauncher._statsLoaded = true
            appLauncher._checkInitComplete()
        }
    }
    
    // Track initialization state
    property bool _statsLoaded: false
    property bool _favoritesLoaded: false
    
    function initialize() {
        console.log("[AppLauncher] Initializing...")
        _statsLoaded = false
        _favoritesLoaded = false
        loadStats()
        loadFavorites()
    }
    
    function _checkInitComplete() {
        if (_statsLoaded && _favoritesLoaded) {
            console.log("[AppLauncher] Stats and favorites loaded, now loading apps...")
            loadApplications()
        }
    }
    
    Component.onCompleted: {
        console.log("[AppLauncher] Module loaded")
        initialize() // Auto-initialize
    }
}
