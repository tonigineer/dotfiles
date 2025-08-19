import "../services" as S
import QtQuick

Rectangle {
    id: root

    radius: 10

    // qmllint disable missing-property
    color: S.Config.theme.surface_container

    Behavior on color {
        ColorAnimation {
            duration: S.Config.anim.durations.normal
            easing.type: Easing.BezierSpline
            easing.bezierCurve: S.Config.anim.curves.standard
        }
    }

    Behavior on implicitWidth {
        NumberAnimation {
            duration: S.Config.anim.durations.normal
            easing.type: Easing.BezierSpline
            easing.bezierCurve: S.Config.anim.curves.emphasized
        }
    }

    Behavior on implicitHeight {
        NumberAnimation {
            duration: S.Config.anim.durations.normal
            easing.type: Easing.BezierSpline
            easing.bezierCurve: S.Config.anim.curves.emphasized
        }
    }
}
