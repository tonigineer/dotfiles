import QtQuick
// import Quickshell

import "root:/config"

Item {
    id: root
    property bool reveal
    property bool vertical: false
    clip: true

    implicitWidth: (reveal || vertical) ? childrenRect.width : 0
    implicitHeight: (reveal || !vertical) ? childrenRect.height : 0
    visible: width > 0 && height > 0

    Behavior on implicitWidth {
        enabled: true
        animation: Vanity.animation.elementMoveEnter.numberAnimation.createObject(this)
    }
}
