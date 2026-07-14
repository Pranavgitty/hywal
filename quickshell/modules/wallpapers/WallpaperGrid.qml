pragma ComponentBehavior: Bound

import Quickshell
import QtQuick

import "."

Item {
    id: root

    required property var wallpaperModel
    property int selectedIndex: 0
    property string selectedPath: ""
    property bool active: true
    readonly property int count: wallpaperModel.count

    function clampIndex(index) {
        return Math.max(0, Math.min(count - 1, index))
    }

    function select(index, animated) {
        if (count === 0)
            return

        selectedIndex = clampIndex(index)
        selectedPath = wallpaperModel.pathAt(selectedIndex)
        const target = Math.max(0, Math.min(viewport.contentWidth - viewport.width,
                                             selectedIndex * viewport.step))
        if (animated) {
            snapAnimation.to = target
            snapAnimation.restart()
        } else {
            viewport.contentX = target
        }
    }

    function selectRelative(delta) {
        select(selectedIndex + delta, true)
    }

    function selectPath(path) {
        const index = wallpaperModel.indexOf(path)
        if (index >= 0)
            select(index, false)
    }

    function applySelection() {
        if (selectedPath) {
            WallpaperService.applyWallpaper(selectedPath)
            Quickshell.execDetached(["hywalctl", "hide"])
        }
    }

    function scrollByWheel(angleDelta, pixelDelta) {
        const delta = angleDelta.y !== 0 ? angleDelta.y
                    : (angleDelta.x !== 0 ? angleDelta.x
                    : (pixelDelta.y !== 0 ? pixelDelta.y : pixelDelta.x))
        if (delta !== 0)
            selectRelative(delta > 0 ? -1 : 1)
    }

    onSelectedPathChanged: {
        const index = wallpaperModel.indexOf(selectedPath)
        if (index >= 0 && index !== selectedIndex)
            select(index, false)
    }

    Flickable {
        id: viewport
        anchors.fill: parent
        anchors.leftMargin: -130
        anchors.rightMargin: -130
        clip: false
        interactive: root.active && root.count > 1
        boundsBehavior: Flickable.StopAtBounds
        flickDeceleration: 2600
        maximumFlickVelocity: 4200

        readonly property real cardWidth: 430
        readonly property real step: Math.max(188, cardWidth * 0.52)
        readonly property real visualIndex: contentX / step

        contentWidth: Math.max(width, width + Math.max(0, root.count - 1) * step)
        contentHeight: height

        onMovementEnded: root.select(Math.round(visualIndex), true)
        onWidthChanged: root.select(root.selectedIndex, false)

        WheelHandler {
            target: null
            onWheel: event => {
                if (event.angleDelta.x !== 0 || event.angleDelta.y !== 0
                        || event.pixelDelta.x !== 0 || event.pixelDelta.y !== 0) {
                    root.scrollByWheel(event.angleDelta, event.pixelDelta)
                    event.accepted = true
                }
            }
        }

        Repeater {
            model: root.wallpaperModel.model
            delegate: WallpaperCard {
                required property string path
                readonly property int filteredIndex: root.wallpaperModel.indexOf(path)

                visible: filteredIndex >= 0
                x: (viewport.width - width) / 2 + filteredIndex * viewport.step
                y: (viewport.height - height) / 2 - Math.max(0, 1 - Math.abs(carouselOffset) / 2.7) * 16
                wallpaperPath: path
                carouselOffset: filteredIndex - viewport.visualIndex

                onClicked: function(wallpaper) {
                    root.select(filteredIndex, true)
                    root.applySelection()
                }
            }
        }
    }

    NumberAnimation {
        id: snapAnimation
        target: viewport
        property: "contentX"
        duration: 460
        easing.type: Easing.OutBack
        easing.overshoot: 0.55
    }

    Connections {
        target: root.wallpaperModel
        function onFilteredChanged() {
            const current = root.wallpaperModel.indexOf(root.selectedPath)
            root.select(current >= 0 ? current : 0, false)
        }
    }
}
