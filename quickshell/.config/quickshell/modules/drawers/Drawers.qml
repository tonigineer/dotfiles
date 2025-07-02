pragma ComponentBehavior: Bound

import "root:/widgets"
import "root:/services"
import "root:/config"
import "root:/modules/bar"
import "root:/modules/session" as Session

import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick

Variants {
    model: Quickshell.screens

    Scope {
        id: scope

        required property ShellScreen modelData

        Exclusions {
            screen: scope.modelData
            bar: bar
        }

        PersistentProperties {
            id: visibilities

            property bool osd
            property bool session
            property bool launcher
            property bool dashboard

            Component.onCompleted: Visibilities.screens[scope.modelData] = this
        }

        StyledWindow {
            id: win

            screen: scope.modelData
            name: "drawers"

            WlrLayershell.exclusionMode: ExclusionMode.Ignore
            WlrLayershell.keyboardFocus: visibilities.launcher || visibilities.session ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
            WlrLayershell.layer: WlrLayer.Top

            mask: Region {
                x: 0
                y: 0
                width: win.width
                height: 30
            }

            anchors.top: true
            anchors.bottom: true
            anchors.left: true
            anchors.right: true

            Item {
                id: bar

                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                }

                implicitHeight: content.implicitHeight

                Bar {
                    id: content
                    modelData: scope.modelData

                    anchors.fill: parent
                }
            }

            Session.Wrapper {
                id: session

                visibilities: visibilities

                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
            }

            // Allow to interact with drawers
            HyprlandFocusGrab {
                active: visibilities.launcher || visibilities.session
                windows: [win]
                onCleared: {
                    visibilities.launcher = false;
                    visibilities.session = false;
                }
            }

            // Dim screen when session is open
            // StyledRect {
            //     anchors.fill: parent
            //     opacity: visibilities.session ? 0.75 : 0
            //     color: Colors.palette.m3scrim

            //     Behavior on opacity {
            //         NumberAnimation {
            //             duration: Appearance.anim.durations.normal
            //             easing.type: Easing.BezierSpline
            //             easing.bezierCurve: Appearance.anim.curves.standard
            //         }
            //     }
            // }

            // MultiEffect {
            //     anchors.fill: source
            //     source: background
            //     shadowEnabled: true
            //     blurMax: 15
            //     shadowColor: Qt.alpha(Colors.palette.m3shadow, 0.7)
            // }
        }
    }
}
