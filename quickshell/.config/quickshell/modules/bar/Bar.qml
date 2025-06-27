import QtQuick
import QtQuick.Layouts
// import QtQuick.Controls
// import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Widgets
// import Quickshell.Wayland
// import Qt5Compat.GraphicalEffects

import "components" as Widgets
import "components"
import "root:/config"
import "root:/common"

// import "root:/common"
// import "root:/services"

Scope {
    id: scope

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: bar

            property var modelData
            property double margin: Config.bar.margin
            screen: modelData

            anchors {
                top: !Config.bar.showAtBottom
                bottom: Config.bar.showAtBottom
                left: true
                right: true
            }

            color: Config.bar.marginColor
            implicitWidth: content.implicitWidth + margin * 2
            implicitHeight: content.implicitHeight + margin * (Config.bar.marginOnlyBottom ? 1 : 2)

            Rectangle {
                id: background
                radius: Config.bar.radius
                border.width: Config.bar.borderWidth
                border.color: Config.bar.borderColor
                anchors.fill: parent
                anchors.margins: Config.bar.marginOnlyBottom ? 0 : Config.bar.margin
                anchors.bottomMargin: Config.bar.margin
                color: Config.backgroundColor
            }

            RowLayout {
                id: content
                spacing: Config.bar.widgetSpacing
                anchors.fill: parent
                anchors.leftMargin: Config.bar.leftMargin
                anchors.rightMargin: Config.bar.rightMargin

                RowLayout {
                    id: leftSection
                    spacing: Config.bar.widgetSpacing
                    Layout.alignment: Qt.AlignLeft
                    Layout.fillWidth: true

                    Widgets.DistroIcon {}

                    ActiveWindow {
                        id: activeWindow
                        // TODO: Brightness and Audio scrolling somewhere else
                        // monitor: Brightness.getMonitorForScreen(root.screen)
                    }
                    //     Image {
                    //         id: iconImage
                    //         // anchors.fill: parent
                    //         // source: Quickshell.iconPath(root.appIcon, "image-missing")
                    //         source: "root:/assets/icons/arxiv"
                    //         // fillMode: Image.PreserveAspectCrop
                    //         // cache: false
                    //         antialiasing: true
                    //         asynchronous: true
                    //         // anchors.fill: parent
                    //         // width: root.rowHeight * modelData.aspect_ratio
                    //         // height: root.rowHeight
                    //         visible: opacity > 0
                    //         opacity: status === Image.Ready ? 1 : 0
                    //         fillMode: Image.PreserveAspectFit
                    //         // source: modelData.preview_url
                    //         sourceSize.width: 50
                    //         // sourceSize.height: 30

                    //         layer.enabled: true
                    //         // layer.effect: OpacityMask {
                    //         //     maskSource: Rectangle {
                    //         //         width: root.rowHeight * modelData.aspect_ratio
                    //         //         height: root.rowHeight
                    //         //         radius: imageRadius
                    //         //     }
                    //         // }
                    //     }
                }

                Item {
                    Layout.fillWidth: true
                }

                RowLayout {
                    id: centerSection
                    spacing: Config.bar.widgetSpacing
                    // Layout.alignment: Qt.AlignLeft
                    // Layout.fillWidth: true

                    // anchors.horizontalCenter: parent.horizontalCenter

                    // Widgets.Clock {}
                    // Widgets.Clock {}

                }

                Item {
                    Layout.fillWidth: true
                }

                RowLayout {
                    id: rightSection
                    spacing: Config.bar.widgetSpacing
                    Layout.alignment: Qt.AlignRight
                    Layout.fillWidth: true

                    Widgets.Tray {
                        bar: bar
                    }
                    Widgets.Clock {}
                }
            }
        }
    }
}
