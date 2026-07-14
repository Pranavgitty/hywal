pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Io

import Quickshell
import Quickshell.Wayland

import "modules/wallpapers" as Wallpapers

PanelWindow {
    id: root

	property string stateFile: "/tmp/hywal.state"
	
	FileView {
	    id: stateWatcher
	
	    path: root.stateFile
	    watchChanges: true
	    printErrors: false
	
	    onFileChanged: reload()
	
	    onLoaded: {
            const state = text().trim()

            root.visible = (state === "show")

            console.log("State:", state)
            console.log("Visible:", root.visible)
        }
	}
	
    visible: true

    function toggle() {
        visible = !visible
    }

    function open() {
        visible = true
    }

    function close() {
        visible = false
    }

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    color: "transparent"

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    Rectangle {
        anchors.fill: parent
        color: Colors.md3.scrim.replace("#", "#b0")

        Rectangle {
            id: panel

            width: Math.min(parent.width * 0.88, 1500)
            height: Math.min(parent.height * 0.86, 900)

            anchors.centerIn: parent

            radius: 28
            color: Colors.md3.surface_container_high

            border.width: 1
            border.color: Colors.md3.outline_variant.replace("#", "#44")

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 32

                spacing: 24

                Text {
                    text: "Wallpaper Switcher"

                    color: Colors.md3.on_surface

                    font.pixelSize: 34
                    font.bold: true
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    radius: 20
                    color: Colors.md3.surface_container_low

                    border.width: 1
                    border.color: Colors.md3.outline_variant.replace("#", "#33")

                    Wallpapers.WallpaperGrid {
                        anchors.fill: parent
                        anchors.margins: 20
                    }
                }
            }
        }
    }

Shortcut {
    sequence: "Escape"

    onActivated: {
        Quickshell.execDetached([
            "hywalctl",
            "hide"
        ])
    }
}
}
