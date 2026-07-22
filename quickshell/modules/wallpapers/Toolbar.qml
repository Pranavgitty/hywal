pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import "."

Rectangle {
    id: root

    property bool gridMode: false
    property bool slideshowActive: false
    property alias searchText: search.text
    property alias searchOpen: search.open
    readonly property bool searchFocused: search.inputActiveFocus
    signal gridToggled()
    signal slideshowToggled()

    width: row.implicitWidth + 22
    height: 62
    radius: height / 2
    color: Colors.md3.surface_container_highest.replace("#", "#dd")
    border.width: 1
    border.color: Colors.md3.outline_variant.replace("#", "#66")

    function openSearch() { search.show() }
    function closeSearch() { search.hide() }

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 6

        ToolbarButton {
            icon: root.gridMode ? "list" : "grid"
            tooltip: root.gridMode ? "Switch to cover flow" : "Switch to grid"
            checked: root.gridMode
            onClicked: root.gridToggled()
        }

        ToolbarButton {
            icon: "slideshow"
            tooltip: "Slideshow"
            checked: root.slideshowActive
            onClicked: root.slideshowToggled()
        }

        Rectangle { width: 1; height: 28; color: Colors.md3.outline_variant.replace("#", "#88") }

        SearchBar { id: search }

        ToolbarButton { icon: "more"; tooltip: "More options" }
    }
}