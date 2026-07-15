pragma ComponentBehavior: Bound

import QtQuick

import "."

Item {
    id: root

    required property var wallpaperModel
    property string selectedPath: ""
    property bool active: true
    readonly property int count: wallpaperModel.count
    readonly property int columns: Math.max(2, Math.floor(width / 246))
    readonly property real cellWidth: width / columns
    readonly property real cellHeight: cellWidth * 0.66 + 18
    signal selected(string path)
    signal applyRequested(string path)

    function selectRelative(delta) {
        if (!count)
            return
        const index = wallpaperModel.indexOf(selectedPath)
        selectIndex(Math.max(0, Math.min(count - 1, (index < 0 ? 0 : index) + delta)))
    }

    function selectIndex(index) {
        const path = wallpaperModel.pathAt(index)
        if (!path)
            return
        selectedPath = path
        selected(path)
        const row = Math.floor(index / columns)
        const target = Math.max(0, Math.min(viewport.contentHeight - viewport.height,
                                             row * cellHeight - (viewport.height - cellHeight) / 2))
        scrollAnimation.to = target
        scrollAnimation.restart()
    }

    function applySelection() {
        if (selectedPath)
            applyRequested(selectedPath)
    }

    Flickable {
        id: viewport
        anchors.fill: parent
        anchors.margins: 10
        clip: true
        interactive: root.active
        boundsBehavior: Flickable.StopAtBounds
        contentWidth: width
        contentHeight: Math.max(height, Math.ceil(root.count / root.columns) * root.cellHeight)

        WheelHandler {
            target: null
            onWheel: event => {
                const delta = event.angleDelta.y !== 0 ? event.angleDelta.y : event.pixelDelta.y
                if (delta !== 0) {
                    viewport.contentY = Math.max(0, Math.min(viewport.contentHeight - viewport.height,
                                                             viewport.contentY - delta))
                    event.accepted = true
                }
            }
        }

        Repeater {
            model: root.wallpaperModel.model
            delegate: WallpaperCard {
                required property string path
                required property string thumbnail
                readonly property int filteredIndex: root.wallpaperModel.indexOf(path)

                visible: filteredIndex >= 0
                width: root.cellWidth - 18
                height: root.cellHeight - 18
                x: (filteredIndex % root.columns) * root.cellWidth + 9
                y: Math.floor(filteredIndex / root.columns) * root.cellHeight + 9
                gridMode: true
                selected: root.selectedPath === path
                wallpaperPath: path
                thumbnailPath: thumbnail
                carouselOffset: 0

                onClicked: root.selectIndex(filteredIndex)
                onDoubleClicked: root.applyRequested(path)
            }
        }
    }

    NumberAnimation {
        id: scrollAnimation
        target: viewport
        property: "contentY"
        duration: 260
        easing.type: Easing.OutCubic
    }

    Connections {
        target: root.wallpaperModel
        function onFilteredChanged() {
            const index = root.wallpaperModel.indexOf(root.selectedPath)
            root.selectIndex(index >= 0 ? index : 0)
        }
    }
}
