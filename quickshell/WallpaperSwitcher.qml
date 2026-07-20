pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import Quickshell.Io
import Quickshell
import Quickshell.Wayland

import "modules/wallpapers" as Wallpapers

PanelWindow {
    id: root

    readonly property string stateFile: (function() {
        var stateHome = Quickshell.env("XDG_STATE_HOME") || (Quickshell.env("HOME") + "/.local/state");
        return stateHome + "/hywal/state";
    })()

    property bool slideshowActive: false
    property bool gridMode: false
    property string selectedPath: ""

    function toggle() { visible = !visible }
    function open() { visible = true }
    function close() { visible = false }

    function select(path) {
        if (path)
            selectedPath = path
    }

    function apply(path) {
        if (!path)
            return
        Wallpapers.WallpaperService.applyWallpaper(path)
        Quickshell.execDetached(["hywalctl", "hide"])
    }

    function activeView() { return gridMode ? gridView : coverflowView }

    FileView {
        path: root.stateFile
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
        onLoaded: root.visible = text().trim() === "show"
    }

    Wallpapers.WallpaperModel {
        id: wallpaperModel
        query: toolbar.searchText
    }

    visible: true
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    color: "transparent"
    anchors { top: true; bottom: true; left: true; right: true }

    Item {
        anchors.fill: parent

        Item {
            id: stage
            width: Math.min(parent.width * 0.94, 1680)
            height: Math.min(parent.height * 0.82, 760)
            anchors.centerIn: parent
            opacity: root.visible ? 1 : 0
            scale: root.visible ? 1 : 0.97
            Behavior on opacity { NumberAnimation { duration: 260; easing.type: Easing.OutCubic } }
            Behavior on scale { NumberAnimation { duration: 360; easing.type: Easing.OutBack; easing.overshoot: 0.45 } }

            Rectangle {
                width: toolbar.width + 10; height: toolbar.height + 10
                anchors.centerIn: toolbar
                anchors.verticalCenterOffset: 6
                radius: toolbar.radius + 6
                color: Colors.md3.shadow.replace("#", "#70")
            }

            Wallpapers.Toolbar {
                id: toolbar
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 26
                gridMode: root.gridMode
                slideshowActive: root.slideshowActive
                onGridToggled: root.gridMode = !root.gridMode
                onSlideshowToggled: root.slideshowActive = !root.slideshowActive
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: toolbar.bottom
                anchors.topMargin: 14
                text: root.selectedPath ? root.selectedPath.split("/").pop()
                                        : (wallpaperModel.count ? "Choose a wallpaper" : "No wallpapers found")
                color: Colors.md3.on_surface_variant
                font.pixelSize: 14
                font.weight: Font.Medium
                opacity: 0.9
            }

            Item {
                id: viewStack
                anchors { left: parent.left; right: parent.right; top: toolbar.bottom; bottom: parent.bottom; topMargin: 42; bottomMargin: 30 }
                clip: false

                Wallpapers.WallpaperGrid {
                    id: coverflowView
                    anchors.fill: parent
                    wallpaperModel: wallpaperModel
                    selectedPath: root.selectedPath
                    active: !root.gridMode
                    opacity: root.gridMode ? 0 : 1
                    scale: root.gridMode ? 0.985 : 1
                    z: root.gridMode ? 1 : 2
                    Behavior on opacity { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
                    Behavior on scale { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
                    onSelectedPathChanged: root.select(selectedPath)
                }

                Wallpapers.WallpaperGridView {
                    id: gridView
                    anchors.fill: parent
                    wallpaperModel: wallpaperModel
                    selectedPath: root.selectedPath
                    active: root.gridMode
                    opacity: root.gridMode ? 1 : 0
                    scale: root.gridMode ? 1 : 1.015
                    z: root.gridMode ? 2 : 1
                    Behavior on opacity { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
                    Behavior on scale { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
                    onSelected: path => root.select(path)
                    onApplyRequested: path => root.apply(path)
                }
            }
        }
    }

    Shortcut {
        sequence: "Escape"
        enabled: !toolbar.searchOpen
        onActivated: Quickshell.execDetached(["hywalctl", "hide"])
    }
    Shortcut { sequence: "Ctrl+F"; onActivated: toolbar.openSearch() }
    Shortcut { sequence: "Left"; enabled: !toolbar.searchFocused; onActivated: root.activeView().selectRelative(-1) }
    Shortcut { sequence: "Right"; enabled: !toolbar.searchFocused; onActivated: root.activeView().selectRelative(1) }
    Shortcut { sequence: "Up"; enabled: !toolbar.searchFocused; onActivated: root.activeView().selectRelative(-1) }
    Shortcut { sequence: "Down"; enabled: !toolbar.searchFocused; onActivated: root.activeView().selectRelative(1) }
    Shortcut { sequence: "Return"; enabled: !toolbar.searchFocused; onActivated: root.activeView().applySelection() }
    Shortcut { sequence: "Enter"; enabled: !toolbar.searchFocused; onActivated: root.activeView().applySelection() }
}