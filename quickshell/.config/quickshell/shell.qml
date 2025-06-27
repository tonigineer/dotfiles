//@ pragma Env QS_NO_RELOAD_POPUP=1

import QtQuick
import Quickshell

import "root:/modules/bar"

Scope {
    property bool enableBar: true

    LazyLoader {
        active: enableBar
        component: Bar {}
    }
}
