import "../services" as S
import "../widgets" as W
import QtQuick
import Quickshell

W.StyledText {
    property real fill
    property int grade: 0

    font {
        hintingPreference: Font.PreferFullHinting

        // qmllint disable missing-property
        pointSize: S.Config.fontSize.normal
        family: S.Config.fontFamily.material
    }
}
