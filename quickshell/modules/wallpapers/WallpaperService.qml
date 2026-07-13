pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import QtQml.Models
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string home: Quickshell.env("HOME")
    readonly property string wallpaperDirectory: home + "/Pictures/Switcher"
    readonly property alias wallpapers: wallpapersModel

    property string currentWallpaper: ""

    ListModel {
        id: wallpapersModel
    }

    function reload() {
        console.log("Reloading wallpapers...")

        scanWallpapers.exec([
            home + "/.local/share/hywal/wallpaper-scanner.sh"
        ])
    }

    function applyWallpaper(path) {
        currentWallpaper = path

        console.log("Applying wallpaper:", path)

        applyWallpaperProcess.exec([
            "caelestia",
            "wallpaper",
            "-f",
            path
        ])
    }

    Process {
        id: scanWallpapers

        stdout: StdioCollector {
            id: collector

            onStreamFinished: {
                const files = collector.text
                    .split("\n")
                    .map(line => line.trim())
                    .filter(line => line.length > 0)

                wallpapersModel.clear()

                for (const file of files)
                    wallpapersModel.append({ path: file })

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

    Component.onCompleted: {
        console.log("WallpaperService created")
        reload()
    }
}