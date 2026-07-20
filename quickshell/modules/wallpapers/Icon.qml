pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls

import "../.."

Item {
    id: root

    property string icon: ""
    property bool filled: false
    property real size: 24
    property color color: Colors.md3.on_surface_variant
    property string tooltip: ""

    width: size
    height: size

    // Material Design Icons as Unicode (widely available in Noto fonts)
    // Grid view (4 squares)
    readonly property string iconGrid: "\u{E3C9}"        // grid_view
    // List/Coverflow view
    readonly property string iconList: "\u{E896}"        // view_list
    // Slideshow/Play
    readonly property string iconSlideshow: "\u{E037}"   // play_arrow
    // Search
    readonly property string iconSearch: "\u{E8B6}"      // search
    // More options
    readonly property string iconMore: "\u{E5D3}"        // more_vert
    // Settings
    readonly property string iconSettings: "\u{E8B8}"    // settings
    // Favorite/Star
    readonly property string iconStar: "\u{E838}"        // star
    readonly property string iconStarOutline: "\u{E839}" // star_outline
    // Delete
    readonly property string iconDelete: "\u{E872}"      // delete
    // Info
    readonly property string iconInfo: "\u{E88E}"        // info
    // Download
    readonly property string iconDownload: "\u{E2C4}"    // download
    // Upload
    readonly property string iconUpload: "\u{E2C6}"      // upload
    // Refresh
    readonly property string iconRefresh: "\u{E5D5}"     // refresh
    // Check
    readonly property string iconCheck: "\u{E5CA}"       // check
    // Close
    readonly property string iconClose: "\u{E5CD}"       // close
    // Chevron left
    readonly property string iconChevronLeft: "\u{E5CB}" // chevron_left
    // Chevron right
    readonly property string iconChevronRight: "\u{E5CC}" // chevron_right
    // Home
    readonly property string iconHome: "\u{E88A}"        // home
    // Folder
    readonly property string iconFolder: "\u{E2C7}"      // folder
    // Image
    readonly property string iconImage: "\u{E3F4}"       // image
    // Palette
    readonly property string iconPalette: "\u{E40A}"     // palette

    // Get icon char based on icon name
    function getIconChar(name) {
        switch (name) {
            case "grid": return root.iconGrid
            case "list": return root.iconList
            case "slideshow": return root.iconSlideshow
            case "search": return root.iconSearch
            case "more": return root.iconMore
            case "settings": return root.iconSettings
            case "star": return root.filled ? root.iconStar : root.iconStarOutline
            case "delete": return root.iconDelete
            case "info": return root.iconInfo
            case "download": return root.iconDownload
            case "upload": return root.iconUpload
            case "refresh": return root.iconRefresh
            case "check": return root.iconCheck
            case "close": return root.iconClose
            case "chevron-left": return root.iconChevronLeft
            case "chevron-right": return root.iconChevronRight
            case "home": return root.iconHome
            case "folder": return root.iconFolder
            case "image": return root.iconImage
            case "palette": return root.iconPalette
            default: return name
        }
    }

    Text {
        anchors.centerIn: parent
        text: root.icon ? root.getIconChar(root.icon) : ""
        color: root.color
        font.pixelSize: root.size
        font.family: "Material Symbols Rounded, Material Symbols Outlined, Noto Sans Symbols 2, Noto Sans, sans-serif"
    }

    // Fallback for older systems without Material Symbols font
    // Uses simple Unicode characters that work everywhere
    property string fallbackIcon: {
        switch (root.icon) {
            case "grid": return "⊞";
            case "list": return "☰";
            case "slideshow": return "▶";
            case "search": return "🔍";
            case "more": return "⋮";
            case "settings": return "⚙";
            case "star": return root.filled ? "★" : "☆";
            case "delete": return "🗑";
            case "info": return "ℹ";
            case "refresh": return "⟳";
            case "check": return "✓";
            case "close": return "✕";
            case "chevron-left": return "‹";
            case "chevron-right": return "›";
            case "home": return "⌂";
            case "folder": return "📁";
            case "image": return "🖼";
            case "palette": return "🎨";
            default: return root.icon;
        }
    }

    // Use fallback if Material Symbols font not available
    // This is handled by the font.family fallback chain above
}