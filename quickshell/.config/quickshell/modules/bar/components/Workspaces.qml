import "root:/widgets"
import "root:/services"
import "root:/config"
import "root:/utils"

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Widgets
import Qt5Compat.GraphicalEffects

StyledRect {
    id: root

    required property var bar
    readonly property HyprlandMonitor monitor: Hyprland.monitorFor(bar.modelData)

    property var wsIdxIsOccupied: ({})
    property var wsIdxIsOnMonitor: ({})

    function recomputeWorkspaceMaps() {
        const occ = {};
        const onMo = {};

        for (const ws of Hyprland.workspaces.values) {
            occ[ws.id] = ws.lastIpcObject.windows > 0;
            onMo[ws.id] = ws.monitor === monitor;
        }

        wsIdxIsOccupied = occ;
        wsIdxIsOnMonitor = onMo;
    }

    Component.onCompleted: recomputeWorkspaceMaps()

    // Connections {
    //     target: Hyprland.workspaces
    //     function onValuesChanged() {
    //         recomputeWorkspaceMaps();
    //     // console.log(JSON.stringify(wsIdxIsOccupied));
    //     // console.log(monitor.id);
    //     // console.log(Hyprland.focusedMonitor);
    //     }
    // }

    Connections {
        target: Hyprland
        function onRawEvent() {
            recomputeWorkspaceMaps();
        // console.log(JSON.stringify(wsIdxIsOccupied));
        // console.log(monitor.id);
        // console.log(Hyprland.focusedMonitor);
        // console.log(Hyprland.workspaces.);
        }
    }

    radius: Appearance.rounding.full
    color: Colors.palette.m3surfaceContainer

    implicitWidth: rowLayout.implicitWidth + Appearance.padding.small * 2
    implicitHeight: rowLayout.implicitHeight + Appearance.padding.small * 2

    MouseArea {
        anchors.fill: parent
        anchors.leftMargin: -Config.border.thickness
        anchors.rightMargin: -Config.border.thickness

        onWheel: event => {
            const activeWs = Hyprland.activeToplevel?.workspace?.name;
            if (event.angleDelta.y < 0 && monitor.activeWorkspace?.id > Config.bar.workspaces.shown)
                return;
            if (event.angleDelta.y > 0 && monitor.activeWorkspace?.id <= 1)
                return;
            Hyprland.dispatch(`workspace r${event.angleDelta.y > 0 ? "-" : "+"}1`);
        }
    }

    // Workspaces - Background
    RowLayout {
        id: rowLayout
        // z: 1

        spacing: 0
        anchors.fill: parent

        layer.enabled: true
        layer.smooth: true

        Repeater {
            model: Config.bar.workspaces.shown

            Rectangle {
                // z: 1

                implicitWidth: Config.bar.sizes.innerHeight * Config.bar.workspaces.wsSizeMultiplier
                implicitHeight: Config.bar.sizes.innerHeight * 0.666

                color: monitor.activeWorkspace?.id === index + 1 ? (Hyprland.focusedMonitor === monitor ? Colors.palette.maroon : Colors.palette.m3inverseSurface) : Colors.palette.m3outlineVariant
                radius: Appearance.rounding.full

                property var leftOccupied: (wsIdxIsOnMonitor[index] && wsIdxIsOccupied[index]) || (monitor.activeWorkspace?.id === index)
                property var rightOccupied: (wsIdxIsOnMonitor[index + 2] && wsIdxIsOccupied[index + 2]) || (monitor.activeWorkspace?.id === index + 2)
                property var radiusLeft: leftOccupied ? 0 : Appearance.rounding.full
                property var radiusRight: rightOccupied ? 0 : Appearance.rounding.full

                topLeftRadius: radiusLeft
                bottomLeftRadius: radiusLeft
                topRightRadius: radiusRight
                bottomRightRadius: radiusRight

                opacity: (wsIdxIsOnMonitor[index + 1] && wsIdxIsOccupied[index + 1]) || (monitor.activeWorkspace?.id === index + 1) ? 1 : 0
            }
        }
    }

    // Workspaces - Content
    RowLayout {
        id: rowLayoutNumbers
        // z: 2

        spacing: 0
        anchors.fill: parent
        implicitHeight: Config.bar.sizes.innerHeight

        Repeater {
            model: Config.bar.workspaces.shown

            Button {
                id: button

                property int workspaceValue: index + 1

                onPressed: Hyprland.dispatch(`workspace ${workspaceValue}`)

                Layout.fillHeight: true
                width: Config.bar.sizes.innerHeight * Config.bar.workspaces.wsSizeMultiplier

                background: Item {
                    id: workspaceButtonBackground
                    implicitWidth: Config.bar.sizes.innerHeight * Config.bar.workspaces.wsSizeMultiplier
                    implicitHeight: Config.bar.sizes.innerHeight * Config.bar.workspaces.wsSizeMultiplier
                    property var biggestWindow: {
                        const windowsInThisWorkspace = HyprlandData.windowList.filter(w => w.workspace.id == button.workspaceValue);
                        return windowsInThisWorkspace.reduce((maxWin, win) => {
                            const maxArea = (maxWin?.size?.[0] ?? 0) * (maxWin?.size?.[1] ?? 0);
                            const winArea = (win?.size?.[0] ?? 0) * (win?.size?.[1] ?? 0);
                            return winArea > maxArea ? win : maxWin;
                        }, null);
                    }

                    property var mainAppIconSource: Quickshell.iconPath(AppSearch.guessIcon(biggestWindow?.class), "image-missing")

                    // Numbering
                    StyledText {
                        opacity: 1.0
                        z: 3

                        font.family: Appearance.font.family.mono
                        font.pixelSize: Appearance.font.normal - ((text.length - 1) * (text !== "10") * 2)

                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: Config.bar.workspaces.marginRight

                        // TODO: chinese numbering
                        text: `${button.workspaceValue}`
                        elide: Text.ElideRight
                        color: (monitor.activeWorkspace?.id == button.workspaceValue) ? Colors.palette.m3onPrimary : (wsIdxIsOccupied[index + 1] ? Colors.palette.m3onSecondaryContainer : Colors.palette.m3onTertiaryContainer)

                        Behavior on opacity {
                            NumberAnimation {
                                duration: Appearance.anim.durations.normal
                                easing.type: Easing.BezierSpline
                                easing.bezierCurve: Appearance.anim.curves.standard
                            }
                        }
                    }

                    // Main APP icon
                    Item {
                        anchors.centerIn: parent
                        width: parent.implicitWidth
                        height: parent.implicitHeight
                        opacity: Config.bar.workspaces.showIcons && wsIdxIsOccupied[index + 1] ? 1.0 : 0.0
                        visible: opacity > 0
                        IconImage {
                            id: mainAppIcon
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right: parent.right
                            anchors.rightMargin: Config.bar.workspaces.marginRight

                            source: workspaceButtonBackground.mainAppIconSource
                            implicitSize: 17

                            Behavior on opacity {
                                NumberAnimation {
                                    duration: Appearance.anim.durations.normal
                                    easing.type: Easing.BezierSpline
                                    easing.bezierCurve: Appearance.anim.curves.standard
                                }
                            }
                            Behavior on anchors.bottomMargin {}
                            Behavior on anchors.rightMargin {}
                            Behavior on implicitSize {}
                        }
                    }
                }
            }
        }
    }
}
