import QtQuick
import QtQuick.Layouts

import "root:/config"

Text {
    id: root
    property real iconSize: Vanity?.font.pixelSize.small ?? 16
    property real fill: 0
    property real truncatedFill: Math.round(fill * 100) / 100 // Reduce memory consumption spikes from constant font remapping
    renderType: Text.CurveRendering
    font {
        hintingPreference: Font.PreferFullHinting
        family: Vanity?.font.iconMaterial ?? "Material Symbols Rounded"
        pixelSize: iconSize
    }
    verticalAlignment: Text.AlignVCenter
    color: Vanity.theme.background_dark

    // Behavior on fill {
    //     NumberAnimation {
    //         duration: Appearance?.animation.elementMoveFast.duration ?? 200
    //         easing.type: Appearance?.animation.elementMoveFast.type ?? Easing.BezierSpline
    //         easing.bezierCurve: Appearance?.animation.elementMoveFast.bezierCurve ?? [0.34, 0.80, 0.34, 1.00, 1, 1]
    //     }
    // }

    font.variableAxes: {
        "FILL": truncatedFill,
        // "wght": font.weight,
        // "GRAD": 0,
        "opsz": iconSize
    }
}
