pragma ComponentBehavior: Bound

import "root:/widgets"
import "root:/services"
import "root:/config"
import "root:/modules/bar"
import "root:/modules/session" as Session
import "root:/modules/bar/popouts" as BarPopouts

import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick

Variants {
    model: Quickshell.screens


    Scope {
        id: scope

        required property ShellScreen modelData
        readonly property BarPopouts.Wrapper popouts: popouts

        Exclusions {
            screen: scope.modelData
            bar: bar
        }

        BarPopouts.Wrapper {
            id: popouts

            screen: scope.modelData
            x: 100
            y: 100

            // currentName:"network"
            // currentCenter:0
            // hasCurrent: true

            // visible: true
            // x: isDetached ? (root.width - nonAnimWidth) / 2 : 0
            // y: {
            //     if (isDetached)
            //         return (root.height - nonAnimHeight) / 2;

            //     const off = currentCenter - Config.border.thickness - nonAnimHeight / 2;
            //     const diff = root.height - Math.floor(off + nonAnimHeight);
            //     if (diff < 0)
            //         return off + diff;
            //     return off;
            // }
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

                // Interactions {
                //     screen: scope.modelData
                //     popouts: panels.popouts
                //     visibilities: visibilities
                //     panels: panels
                //     bar: content

                //     Panels {
                //         id: panels

                //         screen: scope.modelData
                //         visibilities: visibilities
                //         bar: bar
                //     }
                // }

                Bar {
                    id: content
                    modelData: scope.modelData
                    popouts: scope.popouts

                    anchors.fill: parent
                }
            }




            // BarPopouts.Wrapper {
            //     id: barpopouts
            //     screen: scope.modelData

            //     visibilities: visibilities

            //     // anchors.horizontalCenter: parent.horizontalCenter
            //     // anchors.top: bar.bottom
            //     x: 100
            //     y: 100
            // }

            // BarPopouts.Wrapper2 {
            //     id: barpopouts2
            //     screen: scope.modelData

            //     currentName: "traymenu0"
            //     // currentCenter: 0
            //     // hasCurrent: true

            //     detachedMode: "winfo"

            //     // visibilities: visibilities

            //     // anchors.horizontalCenter: parent.horizontalCenter
            //     // anchors.top: bar.bottom
            //     x: 1500
            //     y: 30
            // }


            // Interactions {
            //     screen: scope.modelData
            //     popouts: panels.popouts
            //     visibilities: visibilities
            //     panels: panels
            //     bar: bar

            //     Panels {
            //         id: panels

            //         screen: scope.modelData
            //         visibilities: visibilities
            //         bar: bar
            //     }
            // }



            //
            //     BarPopouts.Wrapper {
            //     id: popouts

            //     screen: root.screen

            //     x: 100
            //     y: 100
            // }

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
