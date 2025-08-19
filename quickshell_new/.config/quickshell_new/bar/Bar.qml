import "../services" as S
import "../widgets" as W
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

// qmllint disable uncreatable-type
PanelWindow {
    id: root

    // qmllint disable missing-property
    property real barHeight: S.Config.settings.bar.height
    property real barSpacing: 15

    anchors.top: true
    anchors.left: true
    anchors.right: true

    color: "transparent"
    implicitHeight: root.barHeight
    exclusiveZone: root.barHeight

    WlrLayershell.namespace: "hyprland-shell:bar"
    WlrLayershell.layer: WlrLayer.Top

    // Backgroun
    Rectangle {
        id: barBackground
        color: S.Config.theme.background

        anchors {
            fill: parent
        }
    }

    Text {
        id: middle
        text: "middle"

        anchors.centerIn: parent
    }

    Text {
        id: left
        text: "let"

        anchors.verticalCenter: parent.verticalCenter
    }

    RowLayout {
        spacing: root.barSpacing

        anchors {
            top: parent.top
            bottom: parent.bottom
            right: parent.right
        }

        W.StyledRect {

            implicitHeight: root.barHeight * 0.75
            implicitWidth: connectivity.implicitWidth + root.barSpacing + connectivity.spacing * 2

            Connectivity {
                id: connectivity
                anchors.centerIn: parent
            }
        }

        W.StyledRect {

            color: "transparent"

            implicitHeight: root.barHeight * 0.75
            implicitWidth: clock.implicitWidth + root.barSpacing

            Clock {
                id: clock
                Layout.topMargin: root.topContentMargin
                Layout.bottomMargin: root.bottomContentMargin
            }

            Layout.rightMargin: root.barSpacing
        }
    }

    mask: Region {
        width: root.width
        height: root.exclusiveZone
    }
}
