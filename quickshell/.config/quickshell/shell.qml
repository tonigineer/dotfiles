import Quickshell

import "./modules"

Scope {
    property bool enableBar: true
    // property bool enableDock: true
    // property bool enableCheatSheet: true

    LazyLoader {
        active: enableBar
        component: Bar {}
    }
}
