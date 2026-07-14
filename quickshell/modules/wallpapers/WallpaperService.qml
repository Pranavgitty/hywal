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