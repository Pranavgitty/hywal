pragma ComponentBehavior: Bound

import QtQuick

import "."

// A lightweight, non-copying filter adapter. Qt 6.11's experimental
// FunctionFilter crashes while ListModel is populated, so this keeps the one
// WallpaperService model intact and calculates only filtered positions.
QtObject {
    id: root

    property string query: ""
    readonly property string normalizedQuery: query.trim().toLowerCase()
    readonly property var model: WallpaperService.wallpapers
    readonly property int sourceCount: WallpaperService.wallpapers.count
    readonly property int count: filteredCount()
    signal filteredChanged()

    onQueryChanged: filteredChanged()
    onSourceCountChanged: filteredChanged()

    function matches(path) {
        return !normalizedQuery || String(path).toLowerCase().indexOf(normalizedQuery) !== -1
    }

    function filteredCount() {
        let total = 0
        for (let i = 0; i < sourceCount; ++i) {
            if (matches(WallpaperService.wallpapers.get(i).path))
                ++total
        }
        return total
    }

    function pathAt(filteredIndex) {
        let current = 0
        for (let i = 0; i < sourceCount; ++i) {
            const path = WallpaperService.wallpapers.get(i).path
            if (matches(path) && current++ === filteredIndex)
                return path
        }
        return ""
    }

    function indexOf(path) {
        let current = 0
        for (let i = 0; i < sourceCount; ++i) {
            const candidate = WallpaperService.wallpapers.get(i).path
            if (matches(candidate)) {
                if (candidate === path)
                    return current
                ++current
            }
        }
        return -1
    }
}
