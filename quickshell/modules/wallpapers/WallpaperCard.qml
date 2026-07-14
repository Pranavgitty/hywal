pragma ComponentBehavior: Bound

import QtQuick

import "../.."

Rectangle {
    id: root

    required property string wallpaperPath
    property real carouselOffset: 0
    property bool gridMode: false
    property bool selected: false
    property bool isFocused: gridMode ? selected : Math.abs(carouselOffset) < 0.42
    property bool isHovered: pointer.containsMouse

    signal clicked(string wallpaper)
    signal doubleClicked(string wallpaper)

    readonly property real distance: Math.abs(carouselOffset)
    readonly property real proximity: Math.max(0, 1 - distance / 3.2)

    width: gridMode ? 250 : 430
    height: gridMode ? 166 : 270
    radius: 24
    clip: true
    transformOrigin: Item.Center

    // All movement comes from the carousel's continuous scroll position. This
    // keeps the cover-flow effect on the compositor rather than relaying out.
    scale: gridMode ? (isHovered ? 1.025 : 1) : 0.62 + proximity * 0.38 + (isHovered ? 0.025 : 0)
    opacity: gridMode ? 1 : 0.18 + proximity * 0.82
    z: gridMode ? (selected ? 2 : 1) : 1000 - Math.round(distance * 20)
    transform: gridMode ? [] : coverRotation
    Rotation {
        id: coverRotation
        origin.x: root.width / 2
        origin.y: root.height / 2
        axis.x: 0
        axis.y: 1
        axis.z: 0
        angle: Math.max(-58, Math.min(58, root.carouselOffset * 27))
    }

    color: Colors.md3.surface_container
    border.width: isFocused || selected ? 2 : 1
    border.color: isFocused || selected ? Colors.md3.primary : Colors.md3.outline_variant.replace("#", "#66")

    Image {
        anchors.fill: parent
        source: "file://" + root.wallpaperPath
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: true
        smooth: true
        mipmap: true
    }

    Rectangle {
        anchors.fill: parent
        color: Colors.md3.scrim.replace("#", "#")
        opacity: root.gridMode ? (root.isHovered ? 0.02 : 0.08) : 0.07 + root.distance * 0.15 - (root.isHovered ? 0.05 : 0)
        Behavior on opacity { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
    }

    Rectangle {
        anchors.fill: parent
        color: "transparent"
        border.width: root.isFocused || root.selected ? 1 : 0
        border.color: Colors.md3.primary.replace("#", "#99")
        radius: root.radius
    }

    Rectangle {
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        height: 78
        gradient: Gradient {
            GradientStop { position: 0; color: Colors.md3.scrim.replace("#", "#00") }
            GradientStop { position: 1; color: Colors.md3.scrim.replace("#", "#bb") }
        }
    }

    Text {
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            margins: 16
        }
        text: root.wallpaperPath.split("/").pop()
        color: Colors.md3.on_surface
        elide: Text.ElideRight
        font.pixelSize: 14
        font.weight: Font.DemiBold
    }

    MouseArea {
        id: pointer
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked(root.wallpaperPath)
        onDoubleClicked: root.doubleClicked(root.wallpaperPath)
    }

    Behavior on scale { NumberAnimation { duration: 190; easing.type: Easing.OutBack } }
    Behavior on opacity { NumberAnimation { duration: 190; easing.type: Easing.OutCubic } }
    Behavior on border.width { NumberAnimation { duration: 170; easing.type: Easing.OutCubic } }
}
