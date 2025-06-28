pragma ComponentBehavior: Bound

import QtQuick

import "root:/widgets"
import "root:/services"
import "root:/utils"
import "root:/config"

Item {
    id: root

    // required property Brightness.Monitor monitor

    property color colour: Colors.palette.m3inverseSurface
    readonly property Item child: child

    implicitWidth: child.implicitWidth
    implicitHeight: child.implicitHeight

    // MouseArea {
    //     anchors.top: parent.top
    //     anchors.bottom: child.top
    //     anchors.left: parent.left
    //     anchors.right: parent.right

    //     onWheel: event => {
    //         if (event.angleDelta.y > 0)
    //             Audio.setVolume(Audio.volume + 0.1);
    //         else if (event.angleDelta.y < 0)
    //             Audio.setVolume(Audio.volume - 0.1);
    //     }
    // }

    // MouseArea {
    //     anchors.top: child.bottom
    //     anchors.bottom: parent.bottom
    //     anchors.left: parent.left
    //     anchors.right: parent.right

    //     onWheel: event => {
    //         const monitor = root.monitor;
    //         if (event.angleDelta.y > 0)
    //             monitor.setBrightness(monitor.brightness + 0.1);
    //         else if (event.angleDelta.y < 0)
    //             monitor.setBrightness(monitor.brightness - 0.1);
    //     }
    // }

    Item {
        id: child

        property Item current: current_text

        clip: true
        implicitHeight: icon.implicitHeight
        implicitWidth: Math.max(icon.implicitWidth + current.implicitWidth) + 20

        MaterialIcon {
            id: icon

            animate: true
            text: Icons.getAppCategoryIcon(Hyprland.activeClient?.wmClass, "desktop_windows")
            color: root.colour
            font.pointSize: metrics.font.pointSize
        }

        Title {
            id: current_text
        }

        Title {
            id: temp_text
        }

        TextMetrics {
            id: metrics

            text: Hyprland.activeClient?.wmClass ?? qsTr("Desktop")
            // text: Hyprland.activeClient?.title ?? qsTr("Desktop")

            font.pointSize: Appearance.font.size.small
            font.family: Appearance.font.family.mono

            onTextChanged: {
                const next = child.current === current_text ? temp_text : current_text;
                next.text = elidedText;
                child.current = next;
            }

            onElideWidthChanged: child.current.text = elidedText
        }

        Behavior on implicitWidth {
            NumberAnimation {
                duration: Appearance.anim.durations.normal
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Appearance.anim.curves.emphasized
            }
        }

        Behavior on implicitHeight {
            NumberAnimation {
                duration: Appearance.anim.durations.normal
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Appearance.anim.curves.emphasized
            }
        }
    }

    component Title: StyledText {
        id: text

        anchors.left: icon.right
        anchors.top: icon.top
        anchors.leftMargin: Appearance.spacing.small

        font.pointSize: metrics.font.pointSize
        font.family: metrics.font.family
        color: root.colour
        opacity: child.current === this ? 1 : 0

        width: implicitWidth
        height: implicitHeight

        Behavior on opacity {
            NumberAnimation {
                duration: Appearance.anim.durations.normal
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Appearance.anim.curves.standard
            }
        }
    }
}
