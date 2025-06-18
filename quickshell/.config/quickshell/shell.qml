import QtQuick
import Quickshell

import "root:/bar"

Scope {
    property bool enableBar: true

    LazyLoader {
        active: enableBar
        component: Bar {}
    }
}
