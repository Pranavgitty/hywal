pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import QtQml.Models
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string home: Quickshell.env("HOME")
    readonly property string configDir: (function() {
        var configHome = Quickshell.env("XDG_CONFIG_HOME") || (home + "/.config");
        return configHome + "/hywal";
    })()
    property string wallpaperDirectory: loadConfig().wallpaperDirectory || (home + "/Pictures/Switcher")
    property string stateDirectory: loadConfig().stateDirectory || (home + "/.local/state/hywal")
    readonly property alias wallpapers: wallpapersModel

    property string currentWallpaper: ""

    ListModel {
        id: wallpapersModel
    }

    // Watch for reload signal from daemon
    FileView {
        id: reloadWatcher
        path: root.stateDirectory + "/reload"
        watchChanges: true
        onFileChanged: {
            reload()
        }
    }

    // Config file viewer (load once at startup)
    FileView {
        id: configFile
        path: configDir + "/config.json"
        watchChanges: false
    }

    function loadConfig() {
        if (configFile.exists) {
            try {
                var text = configFile.text();
                return JSON.parse(text);
            } catch (e) {
                console.log("Failed to parse config:", e);
            }
        }
        return {};
    }

    function saveConfig(config) {
        try {
            configFile.write(JSON.stringify(config, null, 2));
        } catch (e) {
            console.log("Failed to save config:", e);
        }
    }

    function reload() {
        console.log("Reloading wallpapers from:", wallpaperDirectory);

        scanWallpapers.exec([
            home + "/.local/share/hywal/wallpaper-scanner.sh",
            wallpaperDirectory
        ])
    }

    function applyWallpaper(path) {
        currentWallpaper = path

        console.log("Applying wallpaper:", path)

        // Change wallpaper
        applyWallpaperProcess.exec([
            "awww",
            "img",
            path,
            "--transition-type", "grow",
            "--transition-duration", "0.8",
            "--transition-fps", "144",
            "--transition-bezier", ".54,0,.34,.99"
        ])

        // Generate Material You colors
        matugenProcess.exec([
            "matugen",
            "image",
            path,
            "--source-color-index",
            "0"
        ])
    }

    function setWallpaperDirectory(dir) {
        wallpaperDirectory = dir;
        var config = loadConfig();
        config.wallpaperDirectory = dir;
        saveConfig(config);
        reload();
    }

    Process {
        id: scanWallpapers

        stdout: StdioCollector {
            id: collector

            onStreamFinished: {
                const wallpapers = collector.text
                    .split("\n")
                    .map(line => line.trim())
                    .filter(line => line.length > 0)

                wallpapersModel.clear()

                for (const entry of wallpapers) {
                    const separator = entry.indexOf("\t")
                    const path = separator >= 0 ? entry.slice(0, separator) : entry
                    const thumbnail = separator >= 0 ? entry.slice(separator + 1) : path
                    wallpapersModel.append({ path: path, thumbnail: thumbnail })
                }

                console.log("Loaded", wallpapersModel.count, "wallpapers")
            }
        }

        stderr: StdioCollector {
            onStreamFinished: {
                if (text.trim().length)
                    console.log(text)
            }
        }
    }

    Process {
        id: applyWallpaperProcess

        stdout: StdioCollector {
            onStreamFinished: {
                if (text.trim().length)
                    console.log(text)
            }
        }

        stderr: StdioCollector {
            onStreamFinished: {
                if (text.trim().length)
                    console.log(text)
            }
        }
    }

    Process {
        id: matugenProcess

        stdout: StdioCollector {
            onStreamFinished: {
                if (text.trim().length)
                    console.log(text)
            }
        }

        stderr: StdioCollector {
            onStreamFinished: {
                if (text.trim().length)
                    console.log(text)
            }
        }
    }

    Component.onCompleted: {
        console.log("WallpaperService created")
        reload()
    }
}