pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls

import "."

Flickable {
    id: root

    clip: true
    boundsBehavior: Flickable.StopAtBounds

    contentWidth: width
    contentHeight: grid.implicitHeight

    Grid {
        id: grid

        width: root.width

        spacing: 16

        columns: Math.max(1, Math.floor(width / 236))

        Repeater {
            model: WallpaperService.wallpapers

            delegate: WallpaperCard {
                required property string path

                wallpaperPath: path

                onClicked: {
                    WallpaperService.applyWallpaper(path)
                }
            }
        }
    }
}