pragma ComponentBehavior: Bound

import "root:/widgets"
import "root:/config"
import Quickshell
import QtQuick

Scope {
    id: root

    required property ShellScreen screen
    required property Item bar

    ExclusionZone {
        anchors.left: true
        // exclusiveZone: root.bar.implicitWidth
    }

    ExclusionZone {
        anchors.top: true
        exclusiveZone: root.bar.implicitHeight
    }

    ExclusionZone {
        anchors.right: true
        // exclusiveZone: root.bar.implicitWidth
    }

    ExclusionZone {
        // exclusiveZone: root.bar.implicitWidth
        anchors.bottom: true
    }

    component ExclusionZone: StyledWindow {
        screen: root.screen
        name: "border-exclusion"
        // exclusiveZone: root.bar.implicitHeight
        mask: Region {}
    }
}
