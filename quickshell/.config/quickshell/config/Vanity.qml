pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell

import "root:/config/themes"

Singleton {
    id: root

    property QtObject theme: Rosepine

    property QtObject animation
    property QtObject color
    property QtObject font
    property QtObject rounding

    property QtObject bar

    animation: QtObject {
        property QtObject animationCurves: QtObject {
            readonly property list<real> expressiveFastSpatial: [0.42, 1.67, 0.21, 0.90, 1, 1] // Default, 350ms
            readonly property list<real> expressiveDefaultSpatial: [0.38, 1.21, 0.22, 1.00, 1, 1] // Default, 500ms
            readonly property list<real> expressiveSlowSpatial: [0.39, 1.29, 0.35, 0.98, 1, 1] // Default, 650ms
            readonly property list<real> expressiveEffects: [0.34, 0.80, 0.34, 1.00, 1, 1] // Default, 200ms
            readonly property list<real> emphasized: [0.05, 0, 2 / 15, 0.06, 1 / 6, 0.4, 5 / 24, 0.82, 0.25, 1, 1, 1]
            readonly property list<real> emphasizedAccel: [0.3, 0, 0.8, 0.15, 1, 1]
            readonly property list<real> emphasizedDecel: [0.05, 0.7, 0.1, 1, 1, 1]
            readonly property list<real> standard: [0.2, 0, 0, 1, 1, 1]
            readonly property list<real> standardAccel: [0.3, 0, 1, 1, 1, 1]
            readonly property list<real> standardDecel: [0, 0, 0, 1, 1, 1]
        }

        property QtObject elementMove: QtObject {
            property int duration: 500
            property int type: Easing.BezierSpline
            property list<real> bezierCurve: root.animation.animationCurves.expressiveDefaultSpatial
            property int velocity: 650
            property Component numberAnimation: Component {
                NumberAnimation {
                    duration: root.animation.elementMove.duration
                    easing.type: root.animations.elementMove.type
                    easing.bezierCurve: root.animations.elementMove.bezierCurve
                }
            }
        }
        property QtObject elementMoveEnter: QtObject {
            property int duration: 400
            property int type: Easing.BezierSpline
            property list<real> bezierCurve: root.animation.animationCurves.emphasizedDecel
            property int velocity: 650
            property Component numberAnimation: Component {
                NumberAnimation {
                    duration: root.animation.elementMoveEnter.duration
                    easing.type: root.animation.elementMoveEnter.type
                    easing.bezierCurve: root.animation.elementMoveEnter.bezierCurve
                }
            }
        }
    }

    color: QtObject {
        property color background: theme.background
    }

    font: QtObject {

        property string bar: "Monaspace Krypton"
        property string text: "Monaspace Krypton"
        property string tooltip: "Monaspace Krypton"

        property string iconMaterial: "Material Symbols Rounded"

        property QtObject pixelSize: QtObject {
            property int smallest: 10
            property int smaller: 13
            property int small: 15
        }

        // property string main: if us "Monaspace Krypton"
    }
    rounding: QtObject {}

    bar: QtObject {
        property bool isTransparent: false
        property int height: 30
        property real marginContent: 2
    }
}
