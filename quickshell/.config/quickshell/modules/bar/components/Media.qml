pragma ComponentBehavior: Bound

import "root:/widgets"
import "root:/services"
import "root:/utils"
import "root:/config"
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Mpris
import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts

Item {
    id: root

    property real playerProgress: {
        const active = Players.active;
        return active?.length ? active.position / active.length : 0;
    }

    function limitStr(s: string, length: int): string {
        return s.length > length ? s.slice(0, length - s.length - 3) + '...' : s;
    }

    function test() {
        console.log(playerProgress);
    }

    Component.onCompleted: test()

    implicitWidth: details.implicitWidth + Appearance.spacing.small * 0 + 2 * Appearance.spacing.large
    implicitHeight: Config.bar.sizes.innerHeight
    visible: Players.active

    Layout.rightMargin: Appearance.spacing.large

    RowLayout {
        id: details

        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 0

        Ref {
            service: Cava
        }

        Text {
            id: cavaValues
            property var blocks: ["\u2581", "\u2582", "\u2583", "\u2584", "\u2585", "\u2586", "\u2587", "\u2588"]

            function toBlock(v) {
                return blocks[Math.max(0, Math.min(v, 7))];
            }

            text: Cava.values.map(toBlock).join("")
            color: Colors.palette.m3onErrorContainer
            font.pointSize: Appearance.font.size.normal
            font.family: Appearance.font.family.mono

            Layout.rightMargin: Appearance.spacing.large
            Layout.bottomMargin: Config.bar.sizes.innerHeight / 4
            Layout.preferredHeight: Config.bar.sizes.innerHeight / 2

            layer.enabled: true
            layer.effect: MultiEffect {
                // source: cavaValues  // if needed for all
                saturation: 0.2
                blurEnabled: true
                blurMax: 7
                blur: 1
            }
        }

        ElideText {
            id: title
            label: limitStr((Players.active?.trackTitle ?? qsTr("No media")) || qsTr("Unknown title"), 20)
            color: Colors.palette.m3primary
            font.pointSize: Appearance.font.size.small - 1
        }

        ElideText {
            id: artist
            label: limitStr((Players.active?.trackArtist ?? qsTr("No media")) || qsTr("Unknown artist"), 20)
            color: Colors.palette.m3secondary
            font.pointSize: Appearance.font.size.small - 1
        }

        CircularProgress {
            lineWidth: 2
            value: playerProgress
            size: Appearance.font.size.large

            secondaryColor: Colors.palette.m3onBackground
            primaryColor: Colors.palette.m3error

            MaterialIcon {
                anchors.centerIn: parent

                animate: true
                text: Players.active?.isPlaying ? "music_note" : "pause"
                color: Colors.palette.m3onSecondaryContainer
                font.pixelSize: Appearance.font.size.small
            }
        }
    }

    component ElideText: StyledText {
        id: elideText

        property alias label: metrics.text

        Layout.fillWidth: true

        // animate: true
        text: metrics.elidedText

        TextMetrics {
            id: metrics

            font.family: elideText.font.family
            font.pointSize: elideText.font.pointSize
            elide: Text.ElideRight
            elideWidth: elideText.width
        }
    }

    component Control: StyledRect {
        id: control

        required property string icon
        required property bool canUse
        property int fontSize: Appearance.font.size.extraLarge
        property int padding
        property bool fill: true
        property bool primary
        function onClicked(): void {
        }

        implicitWidth: Math.max(icon.implicitWidth, icon.implicitHeight) + padding * 2
        implicitHeight: implicitWidth

        radius: Appearance.rounding.full
        color: primary && canUse ? Colors.palette.m3primary : "transparent"

        StateLayer {
            disabled: !control.canUse
            radius: parent.radius
            color: control.primary ? Colors.palette.m3onPrimary : Colors.palette.m3onSurface

            function onClicked(): void {
                control.onClicked();
            }
        }

        MaterialIcon {
            id: icon

            anchors.centerIn: parent
            anchors.horizontalCenterOffset: -font.pointSize * 0.02
            anchors.verticalCenterOffset: font.pointSize * 0.02

            animate: true
            fill: control.fill ? 1 : 0
            text: control.icon
            color: control.canUse ? control.primary ? Colors.palette.m3onPrimary : Colors.palette.m3onSurface : Colors.palette.m3outline
            font.pointSize: control.fontSize
        }
    }
}
