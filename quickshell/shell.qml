//@ pragma UseQApplication

pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

import "."

ShellRoot {

    Connections {
        target: Quickshell

        function onReloadCompleted() {
            Quickshell.inhibitReloadPopup()
        }
    }

    WallpaperSwitcher {
    }
}