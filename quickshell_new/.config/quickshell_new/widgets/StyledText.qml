import "../services" as S
import QtQuick

// qmllint disable missing-property
Text {
    renderType: S.Config.settings.fonts.useNativeRendering ? Text.NativeRendering : Text.QtRendering

    verticalAlignment: Text.AlignVCenter

    font {
        hintingPreference: Font.PreferFullHinting
        pointSize: S.Config.fontSize.normal
        family: S.Config.fontFamily.mono
    }

    color: S.Config.theme.on_surface
    linkColor: S.Config.theme.primary_fixed
}
