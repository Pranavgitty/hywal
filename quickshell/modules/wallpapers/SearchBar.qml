pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls

import "../.."

Item {
    id: root

    property bool open: false
    property alias text: input.text
    readonly property bool inputActiveFocus: input.activeFocus

    signal opened()
    signal closed()

    width: open ? 210 : 42
    height: 42
    activeFocusOnTab: true
    Behavior on width { NumberAnimation { duration: 230; easing.type: Easing.OutCubic } }

    function show() {
        open = true
        input.forceActiveFocus()
        opened()
    }

    function hide() {
        input.text = ""
        open = false
        closed()
    }

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: Colors.md3.surface_container_low
        border.width: root.open || root.activeFocus ? 1 : 0
        border.color: Colors.md3.primary
        Behavior on border.width { NumberAnimation { duration: 130; easing.type: Easing.OutCubic } }
    }

    Text {
        anchors.centerIn: parent
        visible: !root.open
        text: "⌕"
        color: Colors.md3.on_surface_variant
        font.pixelSize: 25
    }

    TextField {
        id: input
        anchors.fill: parent
        anchors.leftMargin: 15
        anchors.rightMargin: 12
        visible: root.open
        placeholderText: "Search wallpapers"
        color: Colors.md3.on_surface
        placeholderTextColor: Colors.md3.on_surface_variant
        font.pixelSize: 13
        background: Item {}
        selectByMouse: true
        Keys.onEscapePressed: event => { root.hide(); event.accepted = true }
    }

    MouseArea {
        id: searchPointer
        anchors.fill: parent
        visible: !root.open
        cursorShape: Qt.PointingHandCursor
        onClicked: root.show()
    }

    Keys.onReturnPressed: root.show()
    Keys.onSpacePressed: root.show()
    ToolTip.visible: !root.open && searchPointer.containsMouse
    ToolTip.text: "Search wallpapers"
}
