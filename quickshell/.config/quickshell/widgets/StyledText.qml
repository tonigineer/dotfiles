pragma ComponentBehavior: Bound

import QtQuick

import "root:/services"
import "root:/config"

Text {
    id: root

    property bool animate: false
    property string animateProp: "scale"
    property real animateFrom: 0
    property real animateTo: 1
    property int animateDuration: Appearance.anim.durations.normal

    renderType: Text.NativeRendering
    textFormat: Text.PlainText
    color: Colors.palette.m3onSurface
    font.family: Appearance.font.family.mono
    font.pointSize: Appearance.font.size.small

    Behavior on color {
        ColorAnimation {
            duration: Appearance.anim.durations.normal
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Appearance.anim.curves.standard
        }
    }

    Behavior on text {
        enabled: root.animate

        SequentialAnimation {
            Anim {
                to: root.animateFrom
                easing.bezierCurve: Appearance.anim.curves.standardAccel
            }
            PropertyAction {}
            Anim {
                to: root.animateTo
                easing.bezierCurve: Appearance.anim.curves.standardDecel
            }
        }
    }

    component Anim: NumberAnimation {
        target: root
        property: root.animateProp
        duration: root.animateDuration / 2
        easing.type: Easing.BezierSpline
    }
}
