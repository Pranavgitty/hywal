pragma ComponentBehavior: Bound

import QtQuick

Rectangle {
    id: root

    required property string wallpaperPath

    signal clicked(string wallpaper)

    width: 260
    height: 160

    radius: 18

    clip: true

    color: "#252525"

    border.width: 1
    border.color: "#33FFFFFF"

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

        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: "#00000000"
            }

            GradientStop {
                position: 1.0
                color: "#AA000000"
            }
        }
    }

    Text {
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom

            leftMargin: 12
            rightMargin: 12
            bottomMargin: 10
        }

        text: wallpaperPath.split("/").pop()

        color: "white"

        elide: Text.ElideRight

        font.pixelSize: 13
        font.bold: true
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true

        cursorShape: Qt.PointingHandCursor

        onClicked: root.clicked(root.wallpaperPath)

        onEntered: {
            root.scale = 1.04
        }

        onExited: {
            root.scale = 1.0
        }
    }

    Behavior on scale {
        NumberAnimation {
            duration: 120
        }
    }
}