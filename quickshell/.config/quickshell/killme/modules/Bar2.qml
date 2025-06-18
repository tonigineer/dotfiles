// Bar.qml

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
// import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import Qt5Compat.GraphicalEffects

import "root:/config"
import "root:/common"
import "root:/services"
import "root:/widgets"

Scope {
    id: scope

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: bar

            property var modelData
            property double margin: Vanity.bar.marginContent
            screen: modelData

            // property var brightnessMonitor: Brightness.getMonitorForScreen(modelData)

            anchors {
                top: !Settings.bar.atBottom
                bottom: Settings.bar.atBottom
                left: true
                right: true
            }
            color: "#FFFFFF"
            // color: Vanity.bar.isTransparent ? "transparent" : Vanity.colors.background
            implicitWidth: content.implicitWidth + margin * 2
            implicitHeight: content.implicitHeight + margin * 2

            Rectangle {
                anchors.fill: parent
                anchors.margins: bar.margin
                color: "#FF00FF"
                implicitWidth: 30
                implicitHeight: 30
            }

            RowLayout {
                id: content
                spacing: 0
                anchors.fill: parent
                anchors.leftMargin: 15
                anchors.rightMargin: 15

                //             // rightMargin: 15

                // Left side
                RowLayout {
                    id: leftBlocks
                    spacing: 10
                    // leftMargin: 20
                    Layout.alignment: Qt.AlignLeft
                    Layout.fillWidth: true

                    //Blocks.Icon {}
                    // Blocks.Workspaces {}
                    //
                    //
                    //
                    Date {}
                    CustomIcon {
                        id: distroIcon

                        width: 20
                        height: 20
                        // source: Settings.bar.topLeftIcon == 'distro' ? SystemInfo.distroIcon : "spark-symbolic"
                        source: 'arch'
                    }

                    // ActiveWorkspace {
                    //     id: activeWorkspace
                    //     Layout.leftMargin: 10
                    //     anchors.centerIn: undefined

                    //     chopLength: {
                    //         var space = Math.floor(bar.width - (rightBlocks.implicitWidth + leftBlocks.implicitWidth));
                    //         return space * 0.08;
                    //     }

                    //     text: {
                    //         var str = activeWindowTitle;
                    //         return str.length > chopLength ? str.slice(0, chopLength) + '...' : str;
                    //     }

                    //     color: {
                    //         return Hyprland.focusedMonitor == Hyprland.monitorFor(screen) ? "#FFFFFF" : "#CCCCCC";
                    //     }
                    // }
                }

                Item {
                    Layout.fillWidth: true
                }

                //
                RowLayout {
                    id: leftBlocks33
                    spacing: 10
                    Layout.alignment: Qt.AlignLeft
                    Layout.fillWidth: true
                    anchors.centerIn: parent.centerIn

                    anchors.horizontalCenter: parent.horizontalCenter

                    // chopLength: {
                    //     var space = Math.floor(bar.width - (rightBlocks.implicitWidth + leftBlocks.implicitWidth));
                    //     return space * 0.08;
                    // }

                    //Blocks.Icon {}
                    // Blocks.Workspaces {}
                    //
                    //
                    CustomIcon {
                        id: distroIcon33

                        width: 20
                        height: 20
                        // source: Settings.bar.topLeftIcon == 'distro' ? SystemInfo.distroIcon : "spark-symbolic"
                        source: 'arch'
                    }
                }

                Item {
                    Layout.fillWidth: true
                }

                // Right side
                RowLayout {
                    id: rightBlocks
                    spacing: 0
                    Layout.alignment: Qt.AlignRight
                    Layout.fillWidth: true

                    CustomIcon {
                        id: distroIcon2

                        width: 20
                        height: 20
                        // source: Settings.bar.topLeftIcon == 'distro' ? SystemInfo.distroIcon : "spark-symbolic"
                        source: 'arch'
                    }

                    CustomIcon {
                        id: distroIcon3

                        width: 20
                        height: 20
                        // source: Settings.bar.topLeftIcon == 'distro' ? SystemInfo.distroIcon : "spark-symbolic"
                        source: 'arch'
                    }

                    // Blocks.SystemTray {}
                    // Blocks.Memory {}
                    // Blocks.Sound {}
                    // Blocks.Battery {}
                    // Blocks.Date {}
                    // Blocks.Time {}
                }
            }

            //     RowLayout {
            //         id: rowLayout

            //         anchors {
            //             verticalCenter: parent.verticalCenter
            //             // fill: parent
            //             left: parent.left
            //             right: parent.right
            //             // leftMargin: 20
            //             // rightMargin: 15
            //         }
            //         // spacing: 20

            //         RowLayout {
            //             id: rowLayout1

            //             anchors {
            //                 horizontalCenter: parent.left
            //                 fill: parent
            //                 // left: parent.left
            //                 // right: parent.right
            //                 // leftMargin: 20
            //                 // rightMargin: 15
            //             }
            //             CustomIcon {
            //                 id: distroIcon

            //                 anchors {
            //                     verticalCenter: parent.verticalCenter
            //                     // fill: parent
            //                     // left: parent.left
            //                     // right: parent.right
            //                     // leftMargin: 20
            //                     // rightMargin: 15
            //                 }

            //                 width: 20
            //                 height: 20
            //                 // source: Settings.bar.topLeftIcon == 'distro' ? SystemInfo.distroIcon : "spark-symbolic"
            //                 source: 'arch'
            //             }
            //         }

            //         RowLayout {
            //             id: rowLayout12

            //             anchors {
            //                 horizontalCenter: parent.right
            //                 fill: parent
            //                 // left: parent.left
            //                 // right: parent.right
            //                 // leftMargin: 20
            //                 // rightMargin: 15
            //             }
            //             CustomIcon {
            //                 id: distroIcon2

            //                 width: 20
            //                 height: 20
            //                 // source: Settings.bar.topLeftIcon == 'distro' ? SystemInfo.distroIcon : "spark-symbolic"
            //                 source: 'arch'
            //             }
            //         }

            //         // CustomIcon {
            //         //     id: distroIcon

            //         //     width: 20
            //         //     height: 20
            //         //     // source: Settings.bar.topLeftIcon == 'distro' ? SystemInfo.distroIcon : "spark-symbolic"
            //         //     source: 'arch'
            //         // }

            //         // CustomIcon {
            //         //     id: distroIcon2
            //         //     width: 20
            //         //     height: 20
            //         //     // source: Settings.bar.topLeftIcon == 'distro' ? SystemInfo.distroIcon : "spark-symbolic"
            //         //     source: 'arch'
            //         // }

            //         // CustomIcon {
            //         //     id: distroIcon3
            //         //     width: 20
            //         //     height: 20
            //         //     // source: Settings.bar.topLeftIcon == 'distro' ? SystemInfo.distroIcon : "spark-symbolic"
            //         //     source: 'arch'
            //         // }
            //     }
            // }

            // Item {
            //     id: leftSection

            //     anchors.top: parent.top
            //     anchors.bottom: parent.bottom
            //     implicitHeight: rowLayout.implicitHeight
            //     implicitWidth: rowLayout.implicitWidth

            //     RowLayout {
            //         id: rowLayout

            //         anchors {
            //             verticalCenter: parent.verticalCenter
            //             // fill: parent
            //             left: parent.left
            //             right: parent.right
            //             leftMargin: 20
            //             rightMargin: 15
            //         }
            //         // spacing: 20

            //         CustomIcon {
            //             id: distroIcon
            //             width: 20
            //             height: 20
            //             // source: Settings.bar.topLeftIcon == 'distro' ? SystemInfo.distroIcon : "spark-symbolic"
            //             source: 'arch'
            //         }

            //         ActiveWindow {
            //             id: acwin
            //             visible: true
            //             Layout.rightMargin: 10
            //             Layout.fillWidth: false
            //             Layout.fillHeight: true
            //             bar: root
            //         }
            //     }
            // }

            // Item {
            //     id: centerSection

            //     anchors.top: parent.top
            //     anchors.bottom: parent.bottom
            //     anchors.centerIn: content
            //     implicitHeight: rowLayout.implicitHeight
            //     implicitWidth: rowLayout.implicitWidth

            //     RowLayout {
            //         // id: rowLayout

            //         anchors {
            //             fill: parent
            //             // leftMargin: 20
            //             // rightMargin: 15
            //         }
            //         spacing: 20

            //         CustomIcon {
            //             id: distroIconCenter
            //             // anchors.left: parent.left

            //             // Layout.alignment: Qt.AlignLeft

            //             // anchors.left: parent.left
            //             // anchors.right: parent.right
            //             width: 20
            //             height: 20
            //             // source: Settings.bar.topLeftIcon == 'distro' ? SystemInfo.distroIcon : "spark-symbolic"
            //             source: 'arch'
            //             // Layout.fillWidth: false
            //         }
            //     }
            // }

            // Item {
            //     id: rightSection

            //     anchors.top: parent.top
            //     anchors.bottom: parent.bottom
            //     anchors.right: parent.right
            //     implicitHeight: rowLayout.implicitHeight
            //     implicitWidth: rowLayout.implicitWidth

            //     RowLayout {
            //         // id: rowLayout

            //         anchors {
            //             fill: parent
            //             // leftMargin: 20
            //             // rightMargin: 20
            //         }
            //         // spacing: 20

            //         CustomIcon {
            //             id: distroIconRight
            //             // anchors.left: parent.left

            //             // Layout.alignment: Qt.AlignLeft

            //             // anchors.left: parent.left
            //             // anchors.right: parent.right
            //             width: 20
            //             height: 20
            //             // source: Settings.bar.topLeftIcon == 'distro' ? SystemInfo.distroIcon : "spark-symbolic"
            //             source: 'arch'
            //             // Layout.fillWidth: false
            //         }

            //         // ActiveWindow {
            //         //     id: acwin
            //         //     visible: true
            //         //     Layout.rightMargin: 10
            //         //     Layout.fillWidth: false
            //         //     Layout.fillHeight: true
            //         //     bar: root
            //         // }
            //     }
        }
    }
}

//                 /*
//                     Functionality:  Scrolling in the left side
//                     of the bar changes the brightness.
//                 */
//                 MouseArea {
//                     id: barLeftSideArea
//                     property bool hovered: false
//                     property real lastScrollX: 0
//                     property real lastScrollY: 0
//                     property bool trackingScroll: false

//                     acceptedButtons: Qt.LeftButton
//                     anchors.left: parent.left
//                     hoverEnabled: true
//                     implicitHeight: Vanity.bar.height
//                     propagateComposedEvents: true
//                     width: (root.width - 500) / 2  // TODO: middle section width

//                     onEntered: event => {
//                         barLeftSideArea.hovered = true;
//                     }
//                     onExited: event => {
//                         barLeftSideArea.hovered = false;
//                         barLeftSideArea.trackingScroll = false;
//                     }
//                     onPressed: event => {
//                         if (event.button === Qt.LeftButton)
//                         // TODO: SCHAUEN, OB HERE AUCH PANEL geöffnet werden soll
//                         // Hyprland.dispatch('global quickshell:sidebarLeftOpen');
//                         {}
//                     }

//                     WheelHandler {
//                         onWheel: event => {
//                             if (event.angleDelta.y < 0)
//                                 root.brightnessMonitor.setBrightness(root.brightnessMonitor.brightness - 0.05);
//                             else if (event.angleDelta.y > 0)
//                                 root.brightnessMonitor.setBrightness(root.brightnessMonitor.brightness + 0.05);
//                             barLeftSideArea.lastScrollX = event.x;
//                             barLeftSideArea.lastScrollY = event.y;
//                             barLeftSideArea.trackingScroll = true;
//                         // console.log(root.brightnessMonitor.brightness);
//                         }
//                         acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
//                     }
//                     Item {
//                         // Left section
//                         anchors.fill: parent
//                         implicitHeight: leftSectionRowLayout.implicitHeight
//                         implicitWidth: leftSectionRowLayout.implicitWidth

//                         // ScrollHint {
//                         //     reveal: barLeftSideArea.hovered
//                         //     icon: "light_mode"
//                         //     tooltipText: qsTr("Scroll to change brightness")
//                         //     side: "left"
//                         //     anchors.left: parent.left
//                         //     anchors.verticalCenter: parent.verticalCenter
//                         // }

//                         RowLayout { // Content
//                             id: leftSectionRowLayout
//                             anchors.fill: parent
//                             spacing: 10

//                             CustomIcon {
//                                 id: distroIcon
//                                 anchors.left: parent.left

//                                 // anchors.left: parent.left
//                                 // anchors.right: parent.right
//                                 width: 20
//                                 height: 20
//                                 // source: Settings.bar.topLeftIcon == 'distro' ? SystemInfo.distroIcon : "spark-symbolic"
//                                 source: 'arch'
//                             }

//                             // ColorOverlay {
//                             //     anchors.fill: distroIcon
//                             //     source: distroIcon
//                             //     color: "#FFFFFF"
//                             // }

//                             ActiveWindow {
//                                 id: acwin
//                                 visible: true
//                                 Layout.rightMargin: 10
//                                 Layout.fillWidth: false
//                                 Layout.fillHeight: true
//                                 bar: root
//                             }

//                             CustomIcon {
//                                 id: distroIcon2
//                                 anchors.left: acwin.right

//                                 // anchors.left: parent.left
//                                 // anchors.right: parent.right
//                                 width: 20
//                                 height: 20
//                                 // source: Settings.bar.topLeftIcon == 'distro' ? SystemInfo.distroIcon : "spark-symbolic"
//                                 source: 'arch'
//                             }
//                         }
//                     }
//                 }
//             }

//             ClockWidget {
//                 anchors.centerIn: parent
//             }
//         }
//     }
// }
