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

	property string stateFile: "/tmp/wallpaper-switcher.state"
	
	FileView {
	    id: stateWatcher
	
	    path: root.stateFile
	    watchChanges: true
	    printErrors: false
	
	    onFileChanged: reload()
	
	    onLoaded: {
	        const state = text().trim()
	
	        console.log("State:", state)
	
	        root.visible = (state === "show")
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
        color: "#B0121212"

        Rectangle {
            id: panel

            width: Math.min(parent.width * 0.88, 1500)
            height: Math.min(parent.height * 0.86, 900)

            anchors.centerIn: parent

            radius: 28
            color: "#CC1A1A1A"

            border.width: 1
            border.color: "#44FFFFFF"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 32

                spacing: 24

                Text {
                    text: "Wallpaper Switcher"

                    color: "white"

                    font.pixelSize: 34
                    font.bold: true
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    radius: 20
                    color: "#22181818"

                    border.width: 1
                    border.color: "#33FFFFFF"

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
            "wallpaperctl",
            "hide"
        ])
    }
}
}
