pragma Singleton

import Quickshell
import QtQuick

// TODO -- loading a color scheme to live update colors
// https://github.com/caelestia-dots/shell/blob/main/services/Colours.qml

Singleton {
    id: root

    property bool showPreview: false
    property bool light: false

    readonly property Colours palette: showPreview ? preview : current
    readonly property Colours current: Colours {}
    readonly property Colours preview: Colours {}

    readonly property Transparency transparency: Transparency {}

    function alpha(c: color, layer: bool): color {
        if (!transparency.enabled)
            return c;
        c = Qt.rgba(c.r, c.g, c.b, layer ? transparency.layers : transparency.base);
        if (layer)
            c.hsvValue = Math.max(0, Math.min(1, c.hslLightness + (light ? -0.2 : 0.2))); // TODO: edit based on colours (hue or smth)
        return c;
    }

    component Transparency: QtObject {
        readonly property bool enabled: false
        readonly property real base: 0.78
        readonly property real layers: 0.58
    }

    component Colours: QtObject {
        property color m3primary_paletteKeyColor: "#7870AB"
        property color m3secondary_paletteKeyColor: "#78748A"
        property color m3tertiary_paletteKeyColor: "#976A7D"
        property color m3neutral_paletteKeyColor: "#79767D"
        property color m3neutral_variant_paletteKeyColor: "#797680"
        property color m3background: "#141318"
        property color m3onBackground: "#E5E1E9"
        property color m3surface: "#141318"
        property color m3surfaceDim: "#141318"
        property color m3surfaceBright: "#3A383E"
        property color m3surfaceContainerLowest: "#0E0D13"
        property color m3surfaceContainerLow: "#1C1B20"
        property color m3surfaceContainer: "#201F25"
        property color m3surfaceContainerHigh: "#2B292F"
        property color m3surfaceContainerHighest: "#35343A"
        property color m3onSurface: "#E5E1E9"
        property color m3surfaceVariant: "#48454E"
        property color m3onSurfaceVariant: "#C9C5D0"
        property color m3inverseSurface: "#E5E1E9"
        property color m3inverseOnSurface: "#312F36"
        property color m3outline: "#938F99"
        property color m3outlineVariant: "#48454E"
        property color m3shadow: "#000000"
        property color m3scrim: "#000000"
        property color m3surfaceTint: "#C8BFFF"
        property color m3primary: "#C8BFFF"
        property color m3onPrimary: "#30285F"
        property color m3primaryContainer: "#473F77"
        property color m3onPrimaryContainer: "#E5DEFF"
        property color m3inversePrimary: "#5F5791"
        property color m3secondary: "#C9C3DC"
        property color m3onSecondary: "#312E41"
        property color m3secondaryContainer: "#484459"
        property color m3onSecondaryContainer: "#E5DFF9"
        property color m3tertiary: "#ECB8CD"
        property color m3onTertiary: "#482536"
        property color m3tertiaryContainer: "#B38397"
        property color m3onTertiaryContainer: "#000000"
        property color m3error: "#EA8DC1"
        property color m3onError: "#690005"
        property color m3errorContainer: "#93000A"
        property color m3onErrorContainer: "#FFDAD6"
        property color m3primaryFixed: "#E5DEFF"
        property color m3primaryFixedDim: "#C8BFFF"
        property color m3onPrimaryFixed: "#1B1149"
        property color m3onPrimaryFixedVariant: "#473F77"
        property color m3secondaryFixed: "#E5DFF9"
        property color m3secondaryFixedDim: "#C9C3DC"
        property color m3onSecondaryFixed: "#1C192B"
        property color m3onSecondaryFixedVariant: "#484459"
        property color m3tertiaryFixed: "#FFD8E7"
        property color m3tertiaryFixedDim: "#ECB8CD"
        property color m3onTertiaryFixed: "#301121"
        property color m3onTertiaryFixedVariant: "#613B4C"

        property color rosewater: "#B8C4FF"
        property color flamingo: "#DBB9F8"
        property color pink: "#F3B3E3"
        property color mauve: "#D0BDFE"
        property color red: "#F8B3D1"
        property color maroon: "#F6B2DA"
        property color peach: "#E4B7F4"
        property color yellow: "#C3C0FF"
        property color green: "#ADC6FF"
        property color teal: "#D4BBFC"
        property color sky: "#CBBEFF"
        property color sapphire: "#BDC2FF"
        property color blue: "#C7BFFF"
        property color lavender: "#EAB5ED"
    }
}
