pragma Singleton

import QtQuick
// import QtCore
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property alias settings: settingsJson
    property alias theme: themeJson

    // qmllint disable missing-property
    property JsonObject fontSize: JsonObject {
        property int base: root.settings.fonts.basePointSize
        property int h1: base * 1.5
        property int h2: base * 1.35
        property int h3: base * 1.2
        property int large: base * 1.1
        property int normal: base
        property int small: base * 0.9
    }

    property JsonObject fontFamily: JsonObject {
        property string sans: "Monaspace Neon"
        property string mono: "Monaspace Krypton"
        property string material: "Material Symbols Rounded"
    }

    property JsonObject anim: JsonObject {
        property JsonObject durations: JsonObject {
            readonly property int small: 200
            readonly property int normal: 400
            readonly property int large: 600
            readonly property int extraLarge: 1000
            readonly property int expressiveFastSpatial: 350
            readonly property int expressiveDefaultSpatial: 500
            readonly property int expressiveEffects: 200
        }
        property JsonObject curves: JsonObject {
            readonly property list<real> emphasized: [0.05, 0, 2 / 15, 0.06, 1 / 6, 0.4, 5 / 24, 0.82, 0.25, 1, 1, 1]
            readonly property list<real> emphasizedAccel: [0.3, 0, 0.8, 0.15, 1, 1]
            readonly property list<real> emphasizedDecel: [0.05, 0.7, 0.1, 1, 1, 1]
            readonly property list<real> standard: [0.2, 0, 0, 1, 1, 1]
            readonly property list<real> standardAccel: [0.3, 0, 1, 1, 1, 1]
            readonly property list<real> standardDecel: [0, 0, 0, 1, 1, 1]
            readonly property list<real> expressiveFastSpatial: [0.42, 1.67, 0.21, 0.9, 1, 1]
            readonly property list<real> expressiveDefaultSpatial: [0.38, 1.21, 0.22, 1, 1, 1]
            readonly property list<real> expressiveEffects: [0.34, 0.8, 0.34, 1, 1, 1]
        }
    }

    function formatDateTime(dateTime) {
        return Qt.formatDateTime(dateTime, getConfigDateFormat());
    }

    readonly property int numDateFormats: 3

    function getConfigDateFormat() {
        if (settings.misc.dateFormat == 0)
            return "d. MMM yyyy hh:mm";
        if (settings.misc.dateFormat == 1)
            return "dd/MM/yyyy hh:mm";
        if (settings.misc.dateFormat == 2)
            return "hh:mm";
    }

    FileView {
        path: Quickshell.shellPath("config.json")

        watchChanges: true
        onFileChanged: reload()
        onAdapterUpdated: writeAdapter()
        onLoadFailed: error => {
            if (error == FileViewError.FileNotFound) {
                writeAdapter();
            }
        }

        // qmllint disable unresolved-type
        JsonAdapter {
            id: settingsJson
            property JsonObject bar: JsonObject {
                property int height: 30
            }
            property JsonObject fonts: JsonObject {
                property int basePointSize: 10
                property bool useNativeRendering: false
            }
            property JsonObject misc: JsonObject {
                property int dateFormat: 0
            }
        }
    }

    FileView {
        path: Quickshell.shellPath("theme.json")

        watchChanges: true
        onFileChanged: reload()
        onAdapterUpdated: writeAdapter()
        onLoadFailed: error => {
            if (error == FileViewError.FileNotFound) {
                writeAdapter();
            }
        }

        JsonAdapter {
            id: themeJson
            property color background: "#141318"
            property color error: "#EA8DC1"
            property color error_container: "#93000a"
            property color inverse_on_surface: "#312F36"
            property color inverse_primary: "#B8C4FF"
            property color inverse_surface: "#efdee1"
            property color on_background: "#E5E1E9"
            property color on_error: "#690005"
            property color on_error_container: "#ffdad6"
            property color on_primary: "#551d2e"
            property color on_primary_container: "#ffd9e0"
            property color on_primary_fixed: "#3a071a"
            property color on_primary_fixed_variant: "#efdee1"
            property color on_secondary: "#efdee1"
            property color on_secondary_container: "#efdee1"
            property color on_secondary_fixed: "#efdee1"
            property color on_secondary_fixed_variant: "#713344"
            property color on_surface: "#efdee1"
            property color on_surface_variant: "#efdee1"
            property color on_tertiary: "#efdee1"
            property color on_tertiary_container: "#efdee1"
            property color on_tertiary_fixed: "#efdee1"
            property color on_tertiary_fixed_variant: "#efdee1"
            property color outline: "#efdee1"
            property color outline_variant: "#efdee1"
            property color primary: "#efdee1"
            property color primary_container: "#efdee1"
            property color primary_fixed: "#efdee1"
            property color primary_fixed_dim: "#efdee1"
            property color scrim: "#efdee1"
            property color secondary: "#efdee1"
            property color secondary_container: "#efdee1"
            property color secondary_fixed: "#efdee1"
            property color secondary_fixed_dim: "#efdee1"
            property color shadow: "#efdee1"
            property color surface: "#efdee1"
            property color surface_bright: "#efdee1"
            property color surface_container: "#201F25"
            property color surface_container_high: "#efdee1"
            property color surface_container_highest: "#efdee1"
            property color surface_container_low: "#efdee1"
            property color surface_container_lowest: "#efdee1"
            property color surface_dim: "#efdee1"
            property color surface_tint: "#efdee1"
            property color surface_variant: "#efdee1"
            property color tertiary: "#efdee1"
            property color tertiary_container: "#efdee1"
            property color tertiary_fixed: "#efdee1"
            property color tertiary_fixed_dim: "#efdee1"
        }
    }
}
