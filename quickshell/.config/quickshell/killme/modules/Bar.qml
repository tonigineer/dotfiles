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
            id: root

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
                id: content

                anchors.fill: parent
                anchors.margins: root.margin
                color: "#FF0000"
                implicitWidth: 30
                implicitHeight: 30

                /*
                    Functionality:  Scrolling in the left side
                    of the bar changes the brightness.
                */
                MouseArea {
                    id: barLeftSideArea
                    property bool hovered: false
                    property real lastScrollX: 0
                    property real lastScrollY: 0
                    property bool trackingScroll: false

                    acceptedButtons: Qt.LeftButton
                    anchors.left: parent.left
                    hoverEnabled: true
                    implicitHeight: Vanity.bar.height
                    propagateComposedEvents: true
                    width: (root.width - 500) / 2  // TODO: middle section width

                    onEntered: event => {
                        barLeftSideArea.hovered = true;
                    }
                    onExited: event => {
                        barLeftSideArea.hovered = false;
                        barLeftSideArea.trackingScroll = false;
                    }
                    onPressed: event => {
                        if (event.button === Qt.LeftButton)
                        // TODO: SCHAUEN, OB HERE AUCH PANEL geöffnet werden soll
                        // Hyprland.dispatch('global quickshell:sidebarLeftOpen');
                        {}
                    }

                    WheelHandler {
                        onWheel: event => {
                            if (event.angleDelta.y < 0)
                                root.brightnessMonitor.setBrightness(root.brightnessMonitor.brightness - 0.05);
                            else if (event.angleDelta.y > 0)
                                root.brightnessMonitor.setBrightness(root.brightnessMonitor.brightness + 0.05);
                            barLeftSideArea.lastScrollX = event.x;
                            barLeftSideArea.lastScrollY = event.y;
                            barLeftSideArea.trackingScroll = true;
                        // console.log(root.brightnessMonitor.brightness);
                        }
                        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                    }
                    Item {
                        // Left section
                        anchors.fill: parent
                        implicitHeight: leftSectionRowLayout.implicitHeight
                        implicitWidth: leftSectionRowLayout.implicitWidth

                        // ScrollHint {
                        //     reveal: barLeftSideArea.hovered
                        //     icon: "light_mode"
                        //     tooltipText: qsTr("Scroll to change brightness")
                        //     side: "left"
                        //     anchors.left: parent.left
                        //     anchors.verticalCenter: parent.verticalCenter
                        // }

                        RowLayout { // Content
                            id: leftSectionRowLayout
                            anchors.fill: parent
                            spacing: 10

                            CustomIcon {
                                id: distroIcon
                                anchors.left: parent.left

                                // anchors.left: parent.left
                                // anchors.right: parent.right
                                width: 20
                                height: 20
                                // source: Settings.bar.topLeftIcon == 'distro' ? SystemInfo.distroIcon : "spark-symbolic"
                                source: 'arch'
                            }

                            // ColorOverlay {
                            //     anchors.fill: distroIcon
                            //     source: distroIcon
                            //     color: "#FFFFFF"
                            // }

                            ActiveWindow {
                                id: acwin
                                visible: true
                                Layout.rightMargin: 10
                                Layout.fillWidth: false
                                Layout.fillHeight: true
                                bar: root
                            }

                            CustomIcon {
                                id: distroIcon2
                                anchors.left: acwin.right

                                // anchors.left: parent.left
                                // anchors.right: parent.right
                                width: 20
                                height: 20
                                // source: Settings.bar.topLeftIcon == 'distro' ? SystemInfo.distroIcon : "spark-symbolic"
                                source: 'arch'
                            }
                        }
                    }
                }
            }

            ClockWidget {
                anchors.centerIn: parent
            }
        }
    }
}
