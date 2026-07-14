pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls

import "../.."

Item {
    id: root

    property string icon: ""
    property string tooltip: ""
    property bool checked: false
    property bool active: false
    signal clicked()

    width: 42
    height: 42
    activeFocusOnTab: true

    Rectangle {
        anchors.fill: parent
        radius: width / 2
        color: root.checked || pointer.containsMouse || root.activeFocus
               ? Colors.md3.secondary_container : "transparent"
        border.width: root.activeFocus ? 1 : 0
        border.color: Colors.md3.primary
        scale: pointer.pressed ? 0.9 : (pointer.containsMouse ? 1.06 : 1)
        Behavior on color { ColorAnimation { duration: 150 } }
        Behavior on scale { NumberAnimation { duration: 170; easing.type: Easing.OutBack } }
        Behavior on border.width { NumberAnimation { duration: 130; easing.type: Easing.OutCubic } }

        Rectangle {
            width: 20
            height: 20
            radius: 10
            anchors.centerIn: parent
            color: Colors.md3.primary
            opacity: pointer.pressed ? 0.20 : 0
            scale: pointer.pressed ? 1.8 : 0.3
            Behavior on opacity { NumberAnimation { duration: 210; easing.type: Easing.OutCubic } }
            Behavior on scale { NumberAnimation { duration: 210; easing.type: Easing.OutCubic } }
        }
    }

    Text {
        anchors.centerIn: parent
        text: root.icon
        color: Colors.md3.on_secondary_container
        font.pixelSize: 21
    }

    MouseArea {
        id: pointer
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: { root.forceActiveFocus(); root.clicked() }
    }

    Keys.onReturnPressed: root.clicked()
    Keys.onSpacePressed: root.clicked()
    ToolTip.visible: pointer.containsMouse
    ToolTip.text: root.tooltip
}
