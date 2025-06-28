import QtQuick
import Quickshell.Widgets

import "root:/config"

ClippingRectangle {
    id: root

    color: "transparent"

    Behavior on color {
        ColorAnimation {
            duration: Appearance.anim.durations.normal
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Appearance.anim.curves.standard
        }
    }
}
