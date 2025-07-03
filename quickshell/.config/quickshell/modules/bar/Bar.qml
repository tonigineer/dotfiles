import "components" as Components
// import "components/workspaces" as HyprlandWorkspaces
import "root:/config"
import "root:/common"
import "root:/services"
import "root:/widgets"
import "root:/modules/bar/popouts" as BarPopouts
import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts

Item {
    id: bar

    property ShellScreen modelData
    required property BarPopouts.Wrapper popouts

    // function updatePopouts(): void {
    //     popouts.currentName = "network";
    //     popouts.currentCenter = 10;
    //     popouts.hasCurrent = true;
    //     // popouts.detachedMode  = "winfo";
    //     console.log("called")

    //     console.log(popouts.currentName)
    //     console.log(popouts.hasCurrent)
    //     console.log(popouts.detachedMode)


    //     // root.detachedMode === "winfo"
    // }
    // Component.onCompleted: updatePopouts()

    implicitHeight: 30

    Rectangle {
        id: background
        // radius: 20
        // border.width: 0
        // border.color: "white"
        anchors.fill: parent
        color: Colors.palette.m3background
    }

    RowLayout {
        id: content
        spacing: 20

        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        anchors.centerIn: parent
        anchors.fill: parent
        anchors.leftMargin: 20
        anchors.rightMargin: 20

        RowLayout {
            id: leftSection
            spacing: 20
            Layout.alignment: Qt.AlignLeft
            Layout.fillWidth: true

            Components.OsIcon {}

            // TODO: Brightness and Audio scrolling somewhere else
            // monitor: Brightness.getMonitorForScreen(root.screen)
            Components.ActiveWindow {}
        }

        Item {
            Layout.fillWidth: true
        }

        RowLayout {
            id: centerSection

            spacing: 20
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            Layout.fillWidth: true

            // TODO: below truely centers it, but throws warning
            //   WARN scene: QML RowLayout at **/modules/bar/Bar.qml[55:9]: Detected anchors on an item that is managed by a layout. This is undefined behavior; use Layout.alignment instead.
            // anchors.verticalCenter: parent.verticalCenter
            // anchors.horizontalCenter: parent.horizontalCenter
            Components.Workspaces {
                bar: bar
            }
        }

        Item {
            Layout.fillWidth: true
        }

        RowLayout {
            id: rightSection
            spacing: 20
            Layout.alignment: Qt.AlignRight
            Layout.fillWidth: true

            Components.Tray {}
            StyledRect {
                id: statusIcons

                // anchors.left: parent.left
                // anchors.right: parent.right
                // anchors.bottom: power.top
                anchors.bottomMargin: Appearance.spacing.normal

                radius: Appearance.rounding.full
                // color: Colors.palette.m3surfaceContainer
                color: "white"

                implicitHeight: parent.implicitHeight
                implicitWidth: 300

                Components.StatusIcons {
                    id: statusIconsInner

                    anchors.centerIn: parent
                }
            }
            Components.Clock {}
            Components.Power {}
        }
    }
}
